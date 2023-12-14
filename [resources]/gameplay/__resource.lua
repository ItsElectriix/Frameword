resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'
ui_page 'html/carcontrol.html'

file {
  'html/carbon.jpg',
  'html/carcontrol.html',
  'html/doorFrontLeft.png',
  'html/doorFrontRight.png',
  'html/doorRearLeft.png',
  'html/doorRearRight.png',
  'html/frontHood.png',
  'html/ignition.png',
  'html/rearHood.png',
  'html/rearHood2.png',
  'html/seatFrontLeft.png',
  'html/template.html',
  'html/windowFrontLeft.png',
  'html/windowFrontRight.png',
  'html/windowRearLeft.png',
  'html/windowRearRight.png',
  'html/interiorLight.png',
}

client_scripts {
	'@core/nuiinput.lua',
    '@emotes/NativeUI.lua',
    'config.lua',
    'client/main.lua',
    'client/carwash.lua',
    --'client/drugeffects.lua', -- incomplete
    --'client/streetracing.lua',
    'client/hostage.lua',
    'client/extras.lua',
    'client/teleport.lua',
    'client/items.lua',
    'client/weapondraw.lua',
    'client/dui.lua',
    'client/airport.lua'
}

server_scripts {
    'config.lua',
    'server/main.lua',
    'server/items.lua',
    'server/airport.lua',
}

exports {
	'UsingBinoculars'
}