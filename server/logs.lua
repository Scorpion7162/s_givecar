local Config = require('config.config')
Log = {}
Log.GiveCar = GetConvar('FIVEMANAGE_LOGS_API_KEY', 'default') -- fivemanage apikey or discord webhook

---@param playerId integer
---@param logUrl string
---@param title string
---@param type? 'success' | 'danger' | 'info'
---@param data {key: string, value: any}[]
function SendLog(playerId, logUrl, title, type, data)
    local playerId = playerId
    if not logUrl then return false end
    local player = GetFrameworkPlayer(playerId)
    if not player then
        warn('Player not found for ID: %s', playerId)
        return false
    end

    if Config.logs == 'fivemanage' then
        local metadata = {}
        if data then
            for _, entry in ipairs(data) do
                metadata[entry.key] = entry.value
            end
        end

        local payload = {
            level = type or 'info',
            message = title,
            metadata = metadata,
            resource = 's_givecar',
        }

        local headers = {
            ['Authorization'] = logUrl,
            ['X-Fivemanage-Dataset'] = 'default',
            ['Content-Type'] = 'application/json'
        }

        PerformHttpRequest(
            'https://api.fivemanage.com/api/logs',
            function()
            end,
            'POST',
            json.encode(payload),
            headers
        )
        return true
    elseif Config.logs == 'Discord' then
        local color = 0xff6700
        if type == 'success' then color = 0x2ecc71 end
        if type == 'danger' then color = 0xe74c3c end

        local fields = {
            {
                name = 'Player',
                value = string.format('%s (id: %s)', player.name, tostring(playerId)),
                inline = false
            }
        }
        for _, row in pairs(data) do
            fields[#fields + 1] = {
                name = row.key,
                value = tostring(row.value),
                inline = true
            }
        end

        local body = {
            username = 's_givecar',
            avatar_url =
            '',
            content = '',
            embeds = {
                {
                    type = 'rich',
                    title = title,
                    description = '',
                    color = color,
                    fields = fields
                }
            }
        }

        PerformHttpRequest(
            logUrl,
            function() end,
            'POST',
            json.encode(body),
            { ['Content-Type'] = 'application/json' }
        )
        return true
    else
        debugprint('No logging method configured')
    end
end


