resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description 'ESX Ambulance Job'

version '1.0.7'

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'locales/fi.lua',
	'config.lua',
	'server/sv_ambulancejob.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'locales/fi.lua',
	'config.lua',
	'client/cl_ambulancejob.lua'
}

dependency 'es_extended'
