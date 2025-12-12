RegisterNetEvent('s_givecar:openClaimsUI', function(options)
    debugprint('Opening claims UI')
    lib.registerContext({
        id = 's_givecar_claims_ui',
        title = 'Your Vehicle Claims',
        options = options or {},
    })
    lib.showContext('s_givecar_claims_ui')
    debugprint('Claims UI context shown')
end)

RegisterNetEvent('s_givecar:claimVehicle', function(data)
    debugprint('Claiming vehicle with claimId: ' .. tostring(data and data.claimId or 'nil'))
    if not data or not data.claimId then 
        debugprint('Invalid claim data received')
        return 
    end
    TriggerServerEvent('s_givecar:processVehicleClaim', data.claimId)
    debugprint('Sent claim request to server for claimId: ' .. tostring(data.claimId))
end)


exports('openClaimsUI', function(source)
    debugprint('Export openClaimsUI called for source: ' .. tostring(source))
    local claims = GetPlayerVehicleClaims(source)
    debugprint('Retrieved claims for player')
    local options = BuildClaimsMenuOptions(claims)
    TriggerEvent('s_givecar:openClaimsUI', options)
end)