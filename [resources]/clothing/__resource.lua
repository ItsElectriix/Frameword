resource_manifest_version "44febabe-d386-4d18-afbe-5e627f4af937"

ui_page "html/index.html"

server_scripts {
	"config.lua",
	"server/main.lua",
}

client_scripts {
	"@core/nuiinput.lua",
	"config.lua",
	"client/main.lua",
}

files {
	'html/index.html',
	'html/style.css',
	'html/reset.css',
	'html/script.js',
}