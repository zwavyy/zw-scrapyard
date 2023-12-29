fx_version 'cerulean'
game 'gta5'
lua54 'yes'
name "zw-scrapyard"
description "Zwavy Scrapyard"
author 'zwavyy'
version "1.0.0"

shared_scripts {
	'@es_extended/imports.lua',
	'@ox_lib/init.lua',
	'shared/*.lua'
}

client_scripts {
	'client/*.lua'
}

server_scripts {
	'server/*.lua'
}
