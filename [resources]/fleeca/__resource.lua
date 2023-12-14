resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

client_scripts {
	'@core/nuiinput.lua',
	'config.lua',
	'utils.lua',
	'client.lua',
	'fingerprint.lua',
}

server_scripts {	
	'config.lua',
	'utils.lua',
	'server.lua',
}

files {
    "movies/script.js",
    "movies/style.css",
    "movies/intro.gif",
    "movies/success.gif",
    "movies/fail.gif",
    "movies/blank.png",
    "movies/movie.html",
}

ui_page "movies/movie.html"