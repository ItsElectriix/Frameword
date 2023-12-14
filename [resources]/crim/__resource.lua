resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

client_scripts {
	'@core/nuiinput.lua',
    'config.lua',
    'client/gui.lua',
    'client/main.lua',
    'client/scenes.lua',
    'client/drilling.lua',
    'client/storerob.lua',
    'client/methcooking.lua',
    'client/safecracker.lua',
    'client/chopshopnew.lua',
    'client/hackdependancy.lua',
    'client/datacrack.lua',
    'client/moneywash.lua',
    'client/hacking.lua',
}

server_scripts {
    'config.lua',
    'server/main.lua',
    'server/methcooking.lua',
    'server/safecracker.lua',
}

ui_page "html/index.html"

files { 
    -- Safecracker
    'LockPart1.png',
    'LockPart2.png',

    -- Hacking minigame
    "html/index.html",
    "html/success.ogg",
    "html/intro.ogg",
    "html/fail.ogg",
    "sounds/dlcheist3_game.dat151.rel",
    "sounds/dlcheist3_game.dat151.nametable",
    "sounds/dlcheist3_sounds.dat54.rel",
    "sounds/dlcheist3_sounds.dat54.nametable",
    "sounds/dlcheist3/door_hacking.awc",
    "sounds/dlcheist3/fingerprint_match.awc"    
}

data_file "AUDIO_GAMEDATA" "sounds/dlcheist3_game.dat"
data_file "AUDIO_SOUNDDATA" "sounds/dlcheist3_sounds.dat"
data_file "AUDIO_WAVEPACK" "sounds/dlcheist3"