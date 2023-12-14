Config = Config or {}

Config.IdAndLicensePrice = 50

Config.Cityhall = {
    coords = {x = -552.0, y = -191.68, z = 38.22},
}

Config.DriverTest = {
    coords = {x = -549.86, y = -191.75, z = 38.22},
}

Config.DrivingSchool = {
    coords = {x = 215.49, y = -1398.70, z = 142.33},
}

Config.CompanyPrice = 25000

BJCore = nil
TriggerEvent('BJCore:GetObject', function(obj) BJCore = obj end)
Citizen.CreateThread(function(...) while BJCore == nil do TriggerEvent("BJCore:GetObject", function(obj) BJCore = obj end); Citizen.Wait(1000); end; end)