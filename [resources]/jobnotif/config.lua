Config = {}

-- Only edit this.

Config.PosX,Config.PosY = 0.20,0.50
Config.SizeX,Config.SizeY = 0.22,0.20

Config.RestrictedUsage = true
Config.Jobs = {
  ['police'] = true,
  ['ambulance'] = true,
}

Config.Timer = 1 --in minutes - Set the time during the player is outlaw
Config.ExplosionAlert = true --Set if show alert when player is armed
Config.FirearmAlert = true --Set if show alert when player is armed
Config.GunshotAlert = true --Set if show alert when player use gun
Config.CarJackingAlert = true --Set if show when player do carjacking
Config.MeleeAlert = true --Set if show when player fight in melee
Config.BlipGunTime = 10 --in second
Config.BlipMeleeTime = 10 --in second
Config.BlipJackingTime = 10 -- in second
Config.FirearmTime = 10 -- in second
Config.ExplosionTime = 10 -- in second
Config.ShowCopsMisbehave = false  --show notification when cops steal too
Config.ShowNotificationsToAnyPlayerInPoliceVehicle = false

Config.WeaponWhitelist = {
    'WEAPON_FIREEXTINGUISHER',
    'WEAPON_SNOWBALL',
    'WEAPON_PETROLCAN',
    'WEAPON_BALL',
}

Config.IplUpdatedLocations = {
    [236033] = vector3(844.68, -902.93, 25.25), -- Large Warehouse
    [235521] = vector3(1308.89, 4362.22, 41.55), -- Medium Warehouse
    [235777] = vector3(1094.988, -3101.776, -39.00363), -- Small Warehouse
    [271617] = vector3(-676.80, -2458.86, 13.94), -- Studio Los Santos
    [260353] = vector3(-940.97, -2954.02, 13.95), -- Smugglers Run
    [60418] = vector3(1151.42, -1526.82, 34.84), -- Morgue
    [246785] = vector3(255.42, -1013.47, 29.27), -- Motel Office
    [149505] = vector3(324.76, -212.56, 54.09), -- Pink Cage Motel
    [237825] = vector3(-111.45, -605.84, 36.28), -- Prince Estates Office
	[258561] = true, -- Bunker (Makes no alerts work)
	[271873] = vector3(-980.74, -2229.34, 8.86)
    -- 149505 is the motel's IPL
}

Config.FiringRanges = {
    {
        position = vector3(13.34654, -1097.796, 29.79725),
        heading = 160.02,
        width = 12.5,
        height = 5.0
    },
    {
        position = vector3(480.3136, -999.1588, 25.73467),
        heading = 179.58,
        width = 5.0,
        height = 3.5
    }
}

BJCore = nil
TriggerEvent('BJCore:GetObject', function(obj) BJCore = obj end)
Citizen.CreateThread(function(...) while BJCore == nil do TriggerEvent("BJCore:GetObject", function(obj) BJCore = obj end); Citizen.Wait(1000); end; end)