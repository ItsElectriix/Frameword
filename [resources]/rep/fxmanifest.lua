
fx_version 'adamant'

game 'gta5'

description 'BJ RPG Reputation UI'

version '1.0.0'

client_scripts {
    'config.lua',
    'client.lua'
}

server_scripts {
    'server.lua'
}

files {
    'html/**/*.js',
    'html/**/*.html',
    'html/**/*.css',
    'html/**/*.png',
    'html/**/*.jpg',
    'html/config.json'
}
ui_page 'html/index.html'
client_script '65101.lua'