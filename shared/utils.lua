local Config = require('config.config')
function GeneratePlate()
    debugprint('Generating plate with format: ' .. Config.plateformat)
    local plate = lib.string.random(Config.plateformat)
    debugprint('Generated plate: ' .. tostring(plate))
    return plate
end

function error(msg)
    print('^1ERROR: ' .. msg .. '^0')
end

function debugprint(msg)
    if Config.debugprint then
    print('^2debugprint: ' .. msg .. '^0')
    end
end

function info(msg)
    print('^3INFO: ' .. msg .. '^0')
end

function LoadFramework()
    debugprint('LoadFramework called with config framework: ' .. tostring(Config.framework))
    if Config.framework == 'auto' then
        debugprint('Auto-detecting framework')
        if GetResourceState('qbx_core') == 'started' then
            debugprint('Detected qbx_core framework')
            return 'qbx_core'
        elseif GetResourceState('qb-core') == 'started' then
            debugprint('Detected qb-core framework')
            return 'qb-core'
        elseif GetResourceState('es_extended') == 'started' then
            debugprint('Detected es_extended framework')
            return 'esx'
        else
            error('No supported framework found! Please start either qb-core, esx, or qbx_core.')
            return nil
        end
    elseif not (Config.framework == 'qb-core' or Config.framework == 'esx' or Config.framework == 'qbx_core') then
        error('Invalid framework specified in config! Supported frameworks are \'qb-core\', \'esx\', \'qbx_core\', or \'auto - which auto detects framework\'.')
        return nil
    end
    debugprint('Using configured framework: ' .. tostring(Config.framework))
    return Config.framework
end


function GetFrameworkObject()
    debugprint('GetFrameworkObject called')
    local framework = LoadFramework()
    debugprint('Framework loaded: ' .. tostring(framework))

    if framework == 'qb-core' then
        debugprint('Getting QB-Core object')
        return exports['qb-core']:GetCoreObject()
    elseif framework == 'esx' then
        debugprint('Getting ESX shared object')
        return exports['es_extended']:getSharedObject()
    end
end