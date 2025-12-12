local Config = require('config.config')
function GeneratePlate()
    debug('Generating plate with format: ' .. Config.plateformat)
    local plate = lib.string.random(Config.plateformat)
    debug('Generated plate: ' .. tostring(plate))
    return plate
end

function error(msg)
    print('^1ERROR: ' .. msg .. '^0')
end

function debug(msg)
    if Config.debug then
    print('^2DEBUG: ' .. msg .. '^0')
    end
end

function info(msg)
    print('^3INFO: ' .. msg .. '^0')
end

function LoadFramework()
    debug('LoadFramework called with config framework: ' .. tostring(Config.framework))
    if Config.framework == 'auto' then
        debug('Auto-detecting framework')
        if GetResourceState('qb-core') == 'started' then
            debug('Detected qb-core framework')
            return 'qb-core'
        elseif GetResourceState('es_extended') == 'started' then
            debug('Detected es_extended framework')
            return 'esx'
        elseif GetResourceState('qbx_core') == 'started' then
            debug('Detected qbx_core framework')
            return 'qbx_core'
        else
            error('No supported framework found! Please start either qb-core, esx, or qbx_core.')
        end
    elseif not (Config.framework == 'qb-core' or Config.framework == 'esx' or Config.framework == 'qbx_core') then
        error('Invalid framework specified in config! Supported frameworks are \'qb-core\', \'esx\', \'qbx_core\', or \'auto - which auto detects framework\'.')
    end
    debug('Using configured framework: ' .. tostring(Config.framework))
end


function GetFrameworkObject()
    debug('GetFrameworkObject called')
    local framework = LoadFramework()
    debug('Framework loaded: ' .. tostring(framework))

    if framework == 'qb-core' then
        debug('Getting QB-Core object')
        return exports['qb-core']:GetCoreObject()
    elseif framework == 'esx' then
        debug('Getting ESX shared object')
        return exports['es_extended']:getSharedObject()
    end
end