resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

server_scripts {
    "common/common.js",
	"config.lua",
	"shared.lua",
	"server/main.lua",
	"server/discordapi.lua",
	"server/functions.lua",
	"server/player.lua",
	--"server/loops.lua",
	"server/events.lua",
	"server/commands.lua",
	"server/debug.lua",
	"common/functions.lua",
}

client_scripts {
    "common/common.js",
	"config.lua",
	"shared.lua",
	"client/main.lua",
	"client/functions.lua",
	"client/loops.lua",
	"client/events.lua",
	"client/debug.lua",
	"common/functions.lua",
	"nuiinput.lua"
}

ui_page {
	'html/ui.html'
}

files {
	'html/ui.html',
	'html/css/main.css',
	'html/js/app.js',
}

dependencies {
    'yarn'
}