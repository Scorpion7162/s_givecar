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
    debugprint('Command ' .. Config.command .. ' executed by source: ' .. tostring(source))
    local targetId = args.id
    local vehicleModel = args.model
    local customPlate = args.customplate
    debugprint('Target ID: ' .. tostring(targetId) .. ', Model: ' .. tostring(vehicleModel) .. ', Custom Plate: ' .. tostring(customPlate or 'N/A'))
    
    local targetPlayer = GetFrameworkPlayer(targetId)
    if not targetPlayer then
        debugprint('Target player not found')
        lib.notify(source, {
            title = 'Error',
            description = 'Target player not found',
            type = 'error'
        })
        return
    end
    debugprint('Retrieved target player: ' .. tostring(targetPlayer ~= nil))

    local plate = customPlate or GeneratePlate()
    debugprint('Using plate: ' .. tostring(plate))
    
    local targetIdentifier = GetPlayerIdentifier(targetId)
    if not targetIdentifier then
        debugprint('Failed to get target identifier')
        lib.notify(source, {
            title = 'Error',
            description = 'Failed to get player identifier',
            type = 'error'
        })
        return
    end
    
    if Config.saveandcollect then
        -- Add to claims table for later collection
        debugprint('Adding vehicle to claims table for later collection')
        MySQL.insert('INSERT INTO '..Config.claimstable..' (identifier, vehicle_model, plate, garage) VALUES (?, ?, ?, ?)', {
            targetIdentifier,
            vehicleModel,
            plate,
            Config.defaultgarage
        })
        debugprint('Vehicle claim added to database')
        
        if Config.notifyplayer then
            lib.notify(targetId, {
                title = 'Vehicle Available',
                description = 'A '..vehicleModel..' is available for claim. Use /'..Config.claimscommand,
                type = 'inform'
            })
        end
        
        lib.notify(source, {
            title = 'Success',
            description = 'Vehicle claim created for player '..targetId,
            type = 'success'
        })
    else
        -- Directly add to garage
        debugprint('Directly adding vehicle to player garage')
        local success = AddVehicleToGarage(targetId, vehicleModel, plate, Config.defaultgarage)
        
        if success then
            if Config.notifyplayer then
                lib.notify(targetId, {
                    title = 'Vehicle Received',
                    description = 'A '..vehicleModel..' has been added to your garage',
                    type = 'success'
                })
            end
            
            lib.notify(source, {
                title = 'Success',
                description = 'Vehicle given to player '..targetId,
                type = 'success'
            })
        else
            lib.notify(source, {
                title = 'Error',
                description = 'Failed to give vehicle',
                type = 'error'
            })
        end
    end

    SendLog(source, Log.ApplyPlate, 'Gave vehicle', 'success', {
        { key = 'Target ID', value = targetId },
        { key = 'Source ID', value = source },
        { key = 'Target Player Name', value = targetPlayer.name or 'Unknown' },
        { key = 'Source Player Name', value = GetFrameworkPlayer(source).name or 'Unknown' },
        { key = 'Vehicle Model', value = vehicleModel },
        { key = 'Plate', value = plate },
        { key = 'Method', value = Config.saveandcollect and 'Claim' or 'Direct' },
    })

end)


lib.addCommand(Config.claimscommand, {
    help = 'Open the vehicle claims UI',
    restricted = false,
}, function(source, args, rawCommand)
    debugprint('Command ' .. Config.claimscommand .. ' executed by source: ' .. tostring(source))
    local claims = GetPlayerVehicleClaims(source)
    debugprint('Found ' .. #claims .. ' claims for source: ' .. tostring(source))
    local options = BuildClaimsMenuOptions(claims)
    TriggerClientEvent('s_givecar:openClaimsUI', source, options)
    debugprint('Sent claims UI to client with ' .. #options .. ' options to source: ' .. tostring(source))
end)