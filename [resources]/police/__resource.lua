resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

client_scripts {
	'@core/nuiinput.lua',
    '@polyzone/client.lua',
	'config.lua',
	'client/main.lua',
	'client/camera.lua',
	'client/interactions.lua',
	'client/job.lua',
	'client/gui.lua',
	'client/anpr.lua',
	'client/evidence.lua',
	'client/objects.lua',
	'client/tracker.lua',
	'client/prison.lua',
	'client/service.lua'
}

server_scripts {
	'config.lua',
	'server/main.lua',
}

ui_page "html/index.html"

files {
    "html/index.html",
    "html/vue.min.js",
	"html/script.js",
	"html/tablet-frame.png",
	"html/fingerprint.png",
	"html/main.css",
	"html/vcr-ocd.ttf",
}

exports {
	'IsHandcuffed',
	'IsArmoryWhitelist'
}

lua54 'yes'