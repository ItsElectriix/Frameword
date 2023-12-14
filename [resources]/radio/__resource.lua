resource_manifest_version '77731fab-63ca-442c-a67b-abc70f28dfa5'

client_script {
  '@core/nuiinput.lua',
  'config.lua',
  'client/client.lua',
  'client/animation.lua',
}

server_script {
  'config.lua',
  'server/server.lua',
  'server/towers.lua',
}

ui_page('html/ui.html')

files {
  'html/ui.html',
  'html/js/script.js',
  'html/css/style.css',
  'html/img/cursor.png',
  'html/img/radio.png',  
  'worldRadioTowers.json',
}
