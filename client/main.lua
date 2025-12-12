RegisterNetEvent('s_givecar:openClaimsUI', function(options)
    debug('Opening claims UI with ' .. #(options or {}) .. ' options')
    lib.registerContext({
        id = 's_givecar_claims_ui',
        title = 'Your Vehicle Claims',
        options = options or {},
    })
    lib.showContext('s_givecar_claims_ui')
    debug('Claims UI context shown')
end)

RegisterNetEvent('s_givecar:claimVehicle', function(data)
    debug('Claiming vehicle with claimId: ' .. tostring(data and data.claimId or 'nil'))
    if not data or not data.claimId then 
        debug('Invalid claim data received')
        return 
    end
    TriggerServerEvent('s_givecar:processVehicleClaim', data.claimId)
    debug('Sent claim request to server for claimId: ' .. tostring(data.claimId))
end)


exports('openClaimsUI', function(source)
    debug('Export openClaimsUI called for source: ' .. tostring(source))
    local claims = GetPlayerVehicleClaims(source)
    debug('Retrieved ' .. #claims .. ' claims for player')
    local options = BuildClaimsMenuOptions(claims)
    TriggerEvent('s_givecar:openClaimsUI', options)
end)