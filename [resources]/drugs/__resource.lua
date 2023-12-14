resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

ui_page 'index.html'

client_scripts {
    '@polyzone/client.lua',
    '@polyzone/BoxZone.lua',
    '@polyzone/EntityZone.lua',
    '@polyzone/CircleZone.lua',
    '@polyzone/ComboZone.lua',
    'config.lua',
    'client/main.lua',
    'client/weed.lua',
    'client/cornerselling.lua',
    'client/fx.lua',
    'client/coke.lua',
    'client/coke_polyZones.lua',
    'client/heroin.lua',
    'client/heroin_polyZones.lua',
    'client/meth.lua',
    'client/spice.lua',
    'client/spice_polyZones.lua',
    'client/bulkseller.lua',
}

server_scripts {
    'config.lua',
    'server/main.lua',
    'server/weed.lua',
    'server/cornerselling.lua',
    'server/coke.lua',
    'server/heroin.lua',
    'server/spice.lua',
}

files {
  'index.html',
  'sounds/*.ogg'
}