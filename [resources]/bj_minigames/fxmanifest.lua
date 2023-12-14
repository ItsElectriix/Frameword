games { 'rdr3', 'gta5' }
fx_version 'bodacious'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'BanHammer'
description 'Set of minigames for CFX games.'
version '0.0.1'

ui_page "html/index.html"

client_scripts{
    'client.lua',
    'scaleform/scaleformshared.lua',
    'scaleform/fingerprintdata.lua',
    'scaleform/fingerprint.lua',
    'scaleform/bruteforce.lua',
    'scaleform/datacrack.lua',
    'scaleform/connecthack.lua'
}

files {
    "html/index.html",
    "html/vendor/createjs.min.js",
    "html/vendor/TweenMax.min.js",
    "html/sound.js",
    "html/minigames.js",
    "html/script.js",
    "html/style.css",
}
