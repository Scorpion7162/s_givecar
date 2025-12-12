local framework = LoadFramework()
local Config = require('config.config')

function GetFrameworkPlayer(source)
    debug('GetFrameworkPlayer called for source: ' .. tostring(source) .. ' with framework: ' .. tostring(framework))
    if framework == 'qb-core' then
        local player = exports['qb-core']:GetPlayer(source)
        debug('QB-Core player retrieved: ' .. tostring(player ~= nil))
        return player
    elseif framework == 'esx' then
        local player = exports['es_extended']:getSharedObject().GetPlayerFromId(source)
        debug('ESX player retrieved: ' .. tostring(player ~= nil))
        return player
    elseif framework == 'qbx_core' then
        local player = exports.qbx_core:GetPlayer(source)
        debug('QBX player retrieved: ' .. tostring(player ~= nil))
        return player
    end
end


function GetPlayerLicense(source)
    debug('GetPlayerLicense called for source: ' .. tostring(source))
    local player = GetFrameworkPlayer(source)
    if not player then 
        debug('Failed to get player for license lookup')
        return nil 
    end
    
    local license
    if framework == 'qb-core' or framework == 'qbx_core' then
        license = player.PlayerData.license
    elseif framework == 'esx' then
        license = player.identifier
    end
    debug('Player license retrieved: ' .. tostring(license))
    return license
end

function GetPlayerIdentifier(source)
    debug('GetPlayerIdentifier called for source: ' .. tostring(source))
    local player = GetFrameworkPlayer(source)
    if not player then 
        debug('Failed to get player for identifier lookup')
        return nil 
    end
    
    local identifier
    if framework == 'qb-core' or framework == 'qbx_core' then
        identifier = player.PlayerData.citizenid
    elseif framework == 'esx' then
        identifier = player.identifier
    end
    debug('Player identifier retrieved: ' .. tostring(identifier))
    return identifier
end

function GetPlayerVehicleClaims(source)
    debug('GetPlayerVehicleClaims called for source: ' .. tostring(source))
    local identifier = GetPlayerIdentifier(source)
    if not identifier then 
        debug('No identifier found, returning empty claims')
        return {} 
    end

    debug('Querying claims table for identifier: ' .. tostring(identifier))
    local claims = MySQL.query.await('SELECT * FROM '..Config.claimstable..' WHERE identifier = ?', {identifier})
    debug('Retrieved ' .. #(claims or {}) .. ' claims from database')
    return claims or {}
end

function BuildClaimsMenuOptions(claims)
    debug('BuildClaimsMenuOptions called with ' .. #claims .. ' claims')
    local options = {}
    
    for _, claim in ipairs(claims) do
        local vehicle = claim.vehicle_model or claim.model
        local plate = claim.plate or 'N/A'
        debug('Building menu option for vehicle: ' .. vehicle .. ', plate: ' .. plate)
        table.insert(options, {
            title = vehicle .. ' - ' .. plate,
            description = 'Claimed on: ' .. (claim.claimed_date or claim.date or 'Unknown'),
            event = 's_givecar:claimVehicle',
            args = {
                claimId = claim.id,
            },
        })
    end

    if #options == 0 then
        debug('No claims found, adding default option')
        table.insert(options, {
            title = 'No Vehicle Claims',
            description = 'You have no vehicle claims at this time.',
            disabled = true,
        })
    end

    debug('Built ' .. #options .. ' menu options')
    return options
end

