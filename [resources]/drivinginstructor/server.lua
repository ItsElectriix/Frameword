BJCore = nil
TriggerEvent('BJCore:GetObject', function(obj) BJCore = obj end)

RegisterNetEvent('driving:vehicleAction')
AddEventHandler('driving:vehicleAction', function(target, action) TriggerClientEvent('drivingInstructor:vehicleAction', target, action); end)

RegisterNetEvent('driving:submitTest')
AddEventHandler('driving:submitTest', function(testData)
	local src = source
    local Player = BJCore.Functions.GetPlayerByCitizenId(string.upper(testData.cid))
    if Player ~= nil then
    	TriggerClientEvent('drivingInstructor:viewResults', Player.PlayerData.source, testData)
    else
        TriggerClientEvent('BJCore:Notify', src, "Person with that CID not found. Please check CID is correct")
    end
end)