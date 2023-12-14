playersafes = {}

playersafes.DrawTextDist  = 001.5
playersafes.InteractDist  = 001.2
playersafes.LoadSafeDist  = 050.0
playersafes.DespawnDist   = 050.0

BJCore = nil
TriggerEvent('BJCore:GetObject', function(obj) BJCore = obj end)
Citizen.CreateThread(function(...) while BJCore == nil do TriggerEvent("BJCore:GetObject", function(obj) BJCore = obj end); Citizen.Wait(1000); end; end)