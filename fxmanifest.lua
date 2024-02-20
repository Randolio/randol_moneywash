fx_version 'cerulean'
game 'gta5'

author 'Randolio'

shared_scripts {
    '@ox_lib/init.lua',
}

server_scripts { 'bridge/server/**.lua', 'sv_moneywash.lua' }

client_scripts { 'bridge/client/**.lua', 'cl_moneywash.lua' }

lua54 'yes'