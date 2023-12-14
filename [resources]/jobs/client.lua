PlayerData = {}
HuntingRep = 0
FishingRep = 0
GarbageRep = 0
DeliveryRep = 0
PlayerLoaded = true
PlayerJob = {}

RegisterNetEvent('BJCore:Player:SetPlayerData')
AddEventHandler('BJCore:Player:SetPlayerData', function(Player)
    PlayerData = Player
    PlayerJob = Player.job
    HuntingRep = PlayerData.metadata["jobrep"]["hunting"]
    FishingRep = PlayerData.metadata["jobrep"]["fishing"]
    GarbageRep = PlayerData.metadata["jobrep"]["garabge"]
    DeliveryRep = PlayerData.metadata["jobrep"]["delivery"]        
end)

RegisterNetEvent('BJCore:Client:OnJobUpdate')
AddEventHandler('BJCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
    PlayerJob = JobInfo
end)

RegisterNetEvent("BJCore:Client:OnPlayerLoaded")
AddEventHandler("BJCore:Client:OnPlayerLoaded", function()
    PlayerLoaded = true
    TriggerServerEvent("recycle:server:AddCitizen")
end)

RegisterNetEvent('BJCore:Client:OnPlayerUnload')
AddEventHandler('BJCore:Client:OnPlayerUnload', function()
	PlayerLoaded = false
	PlayerData = {}
	HuntingRep = 0
	FishingRep = 0
	GarbageRep = 0
	DeliveryRep = 0
end)

RegisterNetEvent('jobs:client:GetJobRep')
AddEventHandler('jobs:client:GetJobRep', function(data)
	HuntingRep = data["hunting"]
	FishingRep = data["fishing"]
	GarbageRep = data["garbage"]
	DeliveryRep = data["delivery"]
end)