Config = {}

-- Car Jacking
Config.HandsUpTime = 8 -- set the time NPC stands with their hands up
Config.PedGivesKeyChance = 60 -- set the chance of NPC giving keys upon threatening
Config.AlertTime = {min = 1, max = 8} -- set min and max seconds, from car being successfully robbed, to alert police

BJCore = nil
TriggerEvent('BJCore:GetObject', function(obj) BJCore = obj end)
Citizen.CreateThread(function(...) while BJCore == nil do TriggerEvent("BJCore:GetObject", function(obj) BJCore = obj end); Citizen.Wait(1000); end; end)