Config = {}

Config.Vehicles = {
    ["fpiuleg2"] = "Ford Explorer",
    ["tarleg"] = "Ford Taurus",
    ["bikeleg2"] = "Motorbike",
    ["mustang19"] = "Mustang",
    ["charger"] = "Dodge Charger",
    ["tahoe13"] = "Chevy Tahoe",
    ["crownvic"] = "Crown Victoria",
    ["ramleg"] = "Ford Explorer",
    ["fibc"] = "Unmarked 4x4",
    ["fibd"] = "Unmarked Dominatorr",
    ["fibn2"] = "Unmarked Minicat",
    ["fibs"] = "Unmarked Speedo",
    ["fibg2"] = "Unmarked Landstalker",
    ["fibd2"] = "Unmarked Drafter",
    ["fibj"] = "Unmarked Ocelot",
    ["fibn3"] = "Unmarked Lampadanti",
    ["fibr"] = "Unmarked Rumpo",
    ["police"] = "police"
}

BJCore = nil
TriggerEvent('BJCore:GetObject', function(obj) BJCore = obj end)
Citizen.CreateThread(function(...) while BJCore == nil do TriggerEvent("BJCore:GetObject", function(obj) BJCore = obj end); Citizen.Wait(1000); end; end)