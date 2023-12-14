BJCore = {}
BJCore.Config = BJConfig
BJCore.Shared = BJShared
BJCore.ServerCallbacks = {}
BJCore.UseableItems = {}

function GetCoreObject()
	return BJCore
end

RegisterServerEvent('BJCore:GetObject')
AddEventHandler('BJCore:GetObject', function(cb)
	cb(GetCoreObject())
end)

Citizen.CreateThread(function()
	SetConvarServerInfo("PoweredBy", "BJCore Custom Framework")
end)

AddEventHandler('txAdmin:events:scheduledRestart', function(eventData)
    if eventData.secondsRemaining == 60 then
        CreateThread(function()
            Wait(50000)
            for k, v in pairs(BJCore.Functions.GetPlayers()) do
                local Player = BJCore.Functions.GetPlayer(v)
                if Player ~= nil then 
                    DropPlayer(Player.PlayerData.source, "Server Restart")
                end
            end
        end)
    end
end)
