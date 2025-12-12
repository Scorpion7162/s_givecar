local Config = require('config.config')

lib.addCommand(Config.command, {
    help = 'Give a vehicle to a player',
    params = {
        {
            name = 'id',
            help = 'Player ID to give the vehicle to',
            type = 'number',
        },
        {
            name = 'model',
            help = 'Vehicle model to give',
            type = 'string',
        },
        {
            name = 'customplate',
            help = 'Custom plate for the vehicle (optional)',
            type = 'string',
            optional = true,
        },
    },
    restricted = Config.restricted,
}, function(source, args, rawCommand)
    debug('Command ' .. Config.command .. ' executed by source: ' .. tostring(source))
    local targetId = args.id
    local vehicleModel = args.model
    local customPlate = args.customplate
    debug('Target ID: ' .. tostring(targetId) .. ', Model: ' .. tostring(vehicleModel) .. ', Custom Plate: ' .. tostring(customPlate or 'N/A'))
    local targetPlayer = GetFrameworkPlayer(targetId)
    debug('Retrieved target player: ' .. tostring(targetPlayer ~= nil))

   SendLog(source, Log.ApplyPlate, 'Gave vehicle', 'success', {
        { key = 'Target ID', value = targetId },
        { key = 'Source ID', value = source },
        { key = 'Target Player Name', value = targetPlayer.name },
        { key = 'Source Player Name', value = GetFrameworkPlayer(source).name },
        { key = 'Vehicle Model', value = vehicleModel },
        { key = 'Custom Plate', value = customPlate or 'N/A' },
    })

end)


lib.addCommand(Config.claimscommand, {
    help = 'Open the vehicle claims UI',
    restricted = false,
}, function(source, args, rawCommand)
    debug('Command ' .. Config.claimscommand .. ' executed by source: ' .. tostring(source))
    local claims = GetPlayerVehicleClaims(source)
    debug('Found ' .. #claims .. ' claims for source: ' .. tostring(source))
    local options = BuildClaimsMenuOptions(claims)
    TriggerClientEvent('s_givecar:openClaimsUI', source, options)
    debug('Sent claims UI to client with ' .. #options .. ' options to source: ' .. tostring(source))
end)