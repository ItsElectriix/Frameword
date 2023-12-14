-- BJCore Command Events
RegisterNetEvent('BJCore:Command:TeleportToPlayer')
AddEventHandler('BJCore:Command:TeleportToPlayer', function(targetcoords)
	local entity = PlayerPedId()
	if IsPedInAnyVehicle(entity, false) then
		entity = GetVehiclePedIsUsing(entity)
	end
	SetEntityCoords(entity, targetcoords)
end)

RegisterNetEvent('BJCore:Command:TeleportToCoords')
AddEventHandler('BJCore:Command:TeleportToCoords', function(x, y, z)
	x = x + 0.0
	y = y + 0.0
	z = z + 0.0

	RequestCollisionAtCoord(x, y, z)

	while not HasCollisionLoadedAroundEntity(PlayerPedId()) do
		RequestCollisionAtCoord(x, y, z)
		Citizen.Wait(1)
	end

	local entity = PlayerPedId()
	if IsPedInAnyVehicle(entity, false) then
		entity = GetVehiclePedIsUsing(entity)
	end
	SetEntityCoords(entity, x, y, z)
end)

RegisterNetEvent('BJCore:Command:SpawnVehicle')
AddEventHandler('BJCore:Command:SpawnVehicle', function(model)
	BJCore.Functions.SpawnVehicle(model, function(vehicle)
		TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
	end)
end)

RegisterNetEvent('BJCore:Command:DeleteVehicle')
AddEventHandler('BJCore:Command:DeleteVehicle', function()
	local vehicle = BJCore.Functions.GetClosestVehicle()
	if IsPedInAnyVehicle(PlayerPedId()) then vehicle = GetVehiclePedIsIn(PlayerPedId(), false) else vehicle = BJCore.Functions.GetClosestVehicle() end
	BJCore.Functions.DeleteVehicle(vehicle)
end)

RegisterNetEvent('BJCore:Command:Revive')
AddEventHandler('BJCore:Command:Revive', function()
	local coords = BJCore.Functions.GetCoords(PlayerPedId())
	NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z+0.2, coords.w, true, false)
	SetPlayerInvincible(PlayerPedId(), false)
	ClearPedBloodDamage(PlayerPedId())
end)

RegisterNetEvent('BJCore:Command:GoToMarker')
AddEventHandler('BJCore:Command:GoToMarker', function()
	Citizen.CreateThread(function()
		local entity = PlayerPedId()
		if IsPedInAnyVehicle(entity, false) then
			entity = GetVehiclePedIsUsing(entity)
		end
		local success = false
		local blipFound = false
		local blipIterator = GetBlipInfoIdIterator()
		local blip = GetFirstBlipInfoId(8)

		while DoesBlipExist(blip) do
			if GetBlipInfoIdType(blip) == 4 then
				cx, cy, cz = table.unpack(Citizen.InvokeNative(0xFA7C7F0AADF25D09, blip, Citizen.ReturnResultAnyway(), Citizen.ResultAsVector())) --GetBlipInfoIdCoord(blip)
				blipFound = true
				break
			end
			blip = GetNextBlipInfoId(blipIterator)
		end

		if blipFound then
			DoScreenFadeOut(250)
			while IsScreenFadedOut() do
				Citizen.Wait(250)
			end
			local groundFound = false
			local yaw = GetEntityHeading(entity)
			
			for i = 0, 1000, 1 do
				SetEntityCoordsNoOffset(entity, cx, cy, ToFloat(i), false, false, false)
				SetEntityRotation(entity, 0, 0, 0, 0 ,0)
				SetEntityHeading(entity, yaw)
				SetGameplayCamRelativeHeading(0)
				Citizen.Wait(0)
				--groundFound = true
				if GetGroundZFor_3dCoord(cx, cy, ToFloat(i), cz, false) then --GetGroundZFor3dCoord(cx, cy, i, 0, 0) GetGroundZFor_3dCoord(cx, cy, i)
					cz = ToFloat(i)
					groundFound = true
					break
				end
			end
			if not groundFound then
				cz = -300.0
			end
			success = true
		end

		if success then
			SetEntityCoordsNoOffset(entity, cx, cy, cz, false, false, true)
			SetGameplayCamRelativeHeading(0)
			if IsPedSittingInAnyVehicle(PlayerPedId()) then
				if GetPedInVehicleSeat(GetVehiclePedIsUsing(PlayerPedId()), -1) == PlayerPedId() then
					SetVehicleOnGroundProperly(GetVehiclePedIsUsing(PlayerPedId()))
				end
			end
			--HideLoadingPromt()
			DoScreenFadeIn(250)
		end
	end)
end)

-- Other stuff
RegisterNetEvent('BJCore:Player:SetPlayerData')
AddEventHandler('BJCore:Player:SetPlayerData', function(val)
	BJCore.PlayerData = val
    local newInv = {}

    for i,item in pairs(BJCore.PlayerData.items) do
        local itemInfo = BJCore.Shared.Items[item.name:lower()]
        newInv[i] = {
            slot = item.slot,
            name = item.name,
            amount = item.amount,
            info = item.info,
            label = itemInfo["label"], 
			description = itemInfo["description"] ~= nil and itemInfo["description"] or "", 
			weight = itemInfo["weight"], 
			type = itemInfo["type"], 
			unique = itemInfo["unique"], 
			useable = itemInfo["useable"], 
			image = itemInfo["image"], 
			shouldClose = itemInfo["shouldClose"],
			combinable = itemInfo["combinable"]
        }
    end

    TriggerEvent('BJCore:Player:UpdateClientInventoryCache', newInv)
end)

RegisterNetEvent('BJCore:Player:UpdateClientInventoryCache')
AddEventHandler('BJCore:Player:UpdateClientInventoryCache', function(itemCache)
    if BJCore.PlayerData then
        BJCore.PlayerData.items = itemCache
    end
end)

RegisterNetEvent('BJCore:Player:UpdatePlayerData')
AddEventHandler('BJCore:Player:UpdatePlayerData', function(isLogout)
	local data = {}
	data.position = BJCore.Functions.GetCoords(PlayerPedId())
	TriggerServerEvent('BJCore:UpdatePlayer', data, isLogout or false)
end)

RegisterNetEvent('BJCore:Player:UpdatePlayerPosition')
AddEventHandler('BJCore:Player:UpdatePlayerPosition', function()
	local position = BJCore.Functions.GetCoords(PlayerPedId())
	TriggerServerEvent('BJCore:UpdatePlayerPosition', position)
end)

RegisterNetEvent('BJCore:Client:LocalOutOfCharacter')
AddEventHandler('BJCore:Client:LocalOutOfCharacter', function(sourcePos, playerName, message)
    local pos = GetEntityCoords(PlayerPedId(), false)
    if #(pos - sourcePos) < 20.0 then
		TriggerEvent("chatMessage", "OOC " .. playerName, "normal", message)
    end
end)	

RegisterNetEvent('BJCore:Notify')
AddEventHandler('BJCore:Notify', function(text, ntype, length)
	BJCore.Functions.Notify(text, ntype or 'primary', length)
end)

RegisterNetEvent('BJCore:PersistentNotify')
AddEventHandler('BJCore:PersistentNotify', function(data)
	BJCore.Functions.PersistentNotify(data.action, data.id, data.text, data.type, data.style)
end)

RegisterNetEvent('BJCore:Client:TriggerServerCallback')
AddEventHandler('BJCore:Client:TriggerServerCallback', function(name, ...)
	if BJCore.ServerCallbacks[name] ~= nil then
		BJCore.ServerCallbacks[name](...)
		BJCore.ServerCallbacks[name] = nil
	end
end)

RegisterNetEvent("BJCore:Client:UseItem")
AddEventHandler('BJCore:Client:UseItem', function(item)
	TriggerServerEvent("BJCore:Server:UseItem", item)
end)

RegisterNetEvent("mythic_notify:client:SendAlert")
AddEventHandler("mythic_notify:client:SendAlert",function(data)
	if data.type == 'inform' then data.type = 'primary'; end
	BJCore.Functions.Notify(data.text,data.type,data.length or 3000)
end)

RegisterNetEvent('mythic_notify:client:PersistentAlert')
AddEventHandler('mythic_notify:client:PersistentAlert', function(data)
	BJCore.Functions.PersistentNotify(data.action, data.id, data.text, data.type, data.style)
end)

RegisterNetEvent('bj-core:client:DeleteVehicleReceived')
AddEventHandler('bj-core:client:DeleteVehicleReceived', function(veh)
    local vehicle = NetToVeh(veh)
	BJCore.Functions.DeleteVehicle(vehicle)
end)

RegisterNetEvent('bj-core:client:DeleteEntityReceived')
AddEventHandler('bj-core:client:DeleteEntityReceived', function(id)
    local ent = NetworkGetEntityFromNetworkId(id)
    SetEntityAsMissionEntity(ent, true, true)
	DeleteEntity(ent)
end)

AddEventHandler("bj-core:client:pauseLastPos", function(b)
	pausePosUpdate = b
end)

triggered = false
AddEventHandler("playerSpawned", function()
    if not triggered then 
        triggered = true
        Citizen.Wait((1000 * 20))
        TriggerServerEvent('DiscordAPI:PlayerLoaded')
    end
end)