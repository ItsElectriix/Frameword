BJCore = {}
BJCore.PlayerData = {}
BJCore.Config = BJConfig
BJCore.Shared = BJShared
BJCore.ServerCallbacks = {}

isLoggedIn = false

function GetCoreObject()
	return BJCore
end

RegisterNetEvent('BJCore:GetObject')
AddEventHandler('BJCore:GetObject', function(cb)
	cb(GetCoreObject())
end)

RegisterNetEvent('BJCore:Client:OnPlayerLoaded')
AddEventHandler('BJCore:Client:OnPlayerLoaded', function()
	ShutdownLoadingScreenNui()
	isLoggedIn = true
end)

RegisterNetEvent('BJCore:Client:OnPlayerUnload')
AddEventHandler('BJCore:Client:OnPlayerUnload', function()
    isLoggedIn = false
end)
