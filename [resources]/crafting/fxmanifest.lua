fx_version 'adamant'
games { 'gta5' }

ui_page 'html/index.html'

client_scripts {
  '@core/nuiinput.lua',
  'config.lua',
  'client.lua',
}

server_scripts {
  'config.lua',
  'recipes.lua',
  'server.lua',
}

files {
 "html/index.html",

 "html/img/weed.png",
 "html/img/bagofweed.png",
 "html/img/drugscales.png",
 "html/img/ziplock.png",

 "html/img/craft_button.png",
 "html/img/reset_button.png",
 "html/img/left_arrow.png",
 "html/img/right_arrow.png",
}