games { 'gta5' }
fx_version 'cerulean'

ui_page {
	'html/ui.html'
}

files {
	'html/ui.html',
	'html/css/main.css',
	'html/js/app.js',
	'html/images/*.png'
}

client_scripts {
	'@core/nuiinput.lua',
    'config.lua',
    'client/warmenu.lua',
    'client/main.lua',
    'client/commands.lua',
    'client/fireworks.lua',
    'client/moneysafes.lua',
    'client/scoreboard.lua',
    'client/casino.lua',
}

server_scripts {
    'config.lua',
    'server/main.lua',
    'server/scoreboard.lua',
    'server/casino.lua',
}