fx_version 'cerulean'
game 'gta5'
author 'Scorpion'
version '1.0.1'
description 'Give vehicles to a player.'


shared_script '@ox_lib/init.lua'

client_scripts{
    'client/main.lua',
}


server_scripts{
    '@oxmysql/lib/MySQL.lua',
    'shared/utils.lua',
    'server/functions.lua',
    'server/logs.lua',
    'server/main.lua',
    'server/commands.lua',
}


shared_scripts{
    'config/config.lua',
    'shared/utils.lua',
}