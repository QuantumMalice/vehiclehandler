fx_version  'cerulean'
game        'gta5'
lua54       'yes'

name        'vehiclehandler'
description 'Collision/damage handling for FiveM.'
author      'QuantumMalice'
version     '1.1.2'

files {
    'data/*.lua',
    'modules/handler.lua',
}

shared_scripts {
    '@ox_lib/init.lua',
}

client_scripts {
    'client.lua',
}

server_scripts {
    'server.lua',
}