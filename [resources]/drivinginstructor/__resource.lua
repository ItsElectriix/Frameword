resource_manifest_version '05cfa83c-a124-4cfa-a768-c24a5811d8f9'
server_script "server.lua"
client_script "@core/nuiinput.lua"
client_script "gui.lua"
client_script "client.lua"

ui_page 'html/ui.html'
files {
    'html/clip.png',
	'html/pricedown.ttf',
    "html/ui.html",
	'html/styles.css',
	'html/scripts.js',
	'html/debounce.min.js'
}
