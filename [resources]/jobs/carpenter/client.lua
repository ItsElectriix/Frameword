local spawnedPeds = {}
local carpenterPos = vector4(-495.28, 5286.39, 79.63, 335.05)
local isNearCarpenter = false
Citizen.CreateThread(function()
	while true do
		local sleep = 0
		local plyPed = PlayerPedId()
		local plyPos = GetEntityCoords(plyPed)
		local dist = #(plyPos - carpenterPos.xyz)
		if dist < 30 then
			if spawnedPeds[carpenterPos] == nil or not DoesEntityExist(spawnedPeds[carpenterPos]) then
				local phash = GetHashKey('s_m_m_lathandy_01')
				while not HasModelLoaded(phash) do RequestModel(phash); Citizen.Wait(0); end
				local vped = CreatePed(4, phash, carpenterPos, false, true)
				SetEntityVisible(vped, true, false)
				SetBlockingOfNonTemporaryEvents(vped, true)
				SetPedCanPlayAmbientAnims(vped, true)
				SetPedCanRagdollFromPlayerImpact(vped, false)
				SetEntityInvincible(vped, true)
				FreezeEntityPosition(vped, true)
				TaskStartScenarioInPlace(vped, 'WORLD_HUMAN_CLIPBOARD', 0, true)
				spawnedPeds[carpenterPos] = vped
			end
		else
			if spawnedPeds[carpenterPos] ~= nil then
				DeleteEntity(spawnedPeds[carpenterPos])
				spawnedPeds[carpenterPos] = nil
			end
		end     
		if dist < 2 then
			BJCore.Functions.DrawText3D(carpenterPos.x, carpenterPos.y, carpenterPos.z+1.0, "Craftsman")
			if not isNearCarpenter then
				isNearCarpenter = true
				TriggerEvent('isNearCarpenter', isNearCarpenter)
			end
		else
			if dist > 10 then sleep = 1000; end
            if isNearCarpenter then
            	isNearCarpenter = false
            	TriggerEvent('isNearCarpenter', isNearCarpenter)
            end
		end
		Citizen.Wait(sleep)
	end
end)

RegisterNetEvent("carpenter:client:collectOrder")
AddEventHandler("carpenter:client:collectOrder", function(ID) if not isNearCarpenter then return BJCore.Functions.Notify("You're not at the Craftsman location", "error"); end TriggerServerEvent("carpenter:server:giveOrder", ID) end)
AddEventHandler("carpenter:client:DoOrder", function(oKey) TriggerServerEvent("carpenter:server:orderItem", oKey[1]); end)
AddEventHandler("carpenter:client:GetOrders", function() TriggerServerEvent("carpenter:server:getPlayerOrders"); end)