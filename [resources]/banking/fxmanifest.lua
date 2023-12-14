fx_version "adamant"
game "gta5"

client_script {
	"@core/nuiinput.lua",
    "config.lua",    
    "client/client.lua",
}

server_script {
    "config.lua",  
    "server/banking.lua",
}

ui_page "web/html/index.html"

files {
    "web/html/index.html",
    "web/html/main.js"
}