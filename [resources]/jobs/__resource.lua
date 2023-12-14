resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

ui_page 'html/ui.html'

client_scripts {
    '@polyzone/client.lua',
    'config.lua',
    'client.lua',
    'gui.lua',
    'delivery/client.lua',
    'fishing/client.lua',
    'hunting/client.lua',
    'hotdog/client.lua',
    'recycling/client.lua',
    'smelting/client.lua',
    'carpenter/client.lua',
    'mining/client.lua',
    'vineyard/client.lua',
    'vineyard/client_polyZones.lua',
    'lumber/client.lua',
    'lumber/client_polyZones.lua',
    'restaurant/client.lua',
    'fueler/client.lua',
}

server_scripts {
	'config.lua',
	'server.lua',
    'restaurant/server.lua',
}

files {
    'html/ui.html',
    'html/ui.css',
    'html/ui.js',
    'html/icon.png',
}