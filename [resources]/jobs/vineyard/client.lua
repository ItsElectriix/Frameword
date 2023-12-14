fieldsCreated = false
fields = {
	["A"] = false,
	["B"] = false,
	["C"] = false,
	["D"] = false,
	["E"] = false,
	["F"] = false,
	["G"] = false,
	["H"] = false,
	["I"] = false,
	["J"] = false,
	["K"] = false,
	["L"] = false,
	["M"] = false,
}

local curField = false
local curFieldData = nil

function ManageFieldZones()
	for k,v in pairs(fields) do
		fields[k]:onPlayerInOut(function(isPointInside, point)
			if isPointInside then
				curField = k
				print("Entered Zone: "..k)
				print("Point: "..BJCore.Common.Dump(point))
				TriggerEvent("IsInVineyard", true)
				VineyardTick()
			else
				if curField == k then
					print("Left Zone: "..k)
					print("Point: "..BJCore.Common.Dump(point))
					TriggerEvent("IsInVineyard", false)
					curField = false
					curFieldData = nil
				end
			end
		end)
	end
end

function DestroyFieldZones()
	TriggerEvent("IsInVineyard", false)
	for k,v in pairs(fields) do
		if v ~= false then
			fields[k]:destroy()
		end
	end
	print("Destroyed Field Zones")
	curField = false
	fieldsCreated = false
end

local curVine = false
function VineyardTick()
	Citizen.CreateThread(function()
		TriggerServerEvent("vineyard:server:getFieldData", curField)
		while curFieldData == nil do Citizen.Wait(100); end
		local plyPed = PlayerPedId()
		while curField do
			local plyPos = GetEntityCoords(plyPed)
			for k,v in pairs(curFieldData) do
				local dist = #(plyPos - v.data.pos)
				if dist < 25 then
					local colour = Config.GrapeColourTypes[v.data.type]
					DrawMarker(Config.VineMarkerStages[v.data.stage], v.data.pos.x, v.data.pos.y, v.data.pos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.4, 0.4, 0.4, Config.VineMarkerColours[colour].r, Config.VineMarkerColours[colour].g, Config.VineMarkerColours[colour].b, 180, false, true, 0, false)
					if dist < 4 then
						curVine = k
						if dist < 2 then
							local textColour = "~g~"
							if colour == "red" then textColour = "~p~"; end
							if v.data.health <= 0 then
								BJCore.Functions.DrawText3D(v.data.pos.x, v.data.pos.y, v.data.pos.z-0.12, "Type: "..textColour..Config.GrapeTypesLabels[v.data.type].. "~w~ | Vine has died")
							else
								BJCore.Functions.DrawText3D(v.data.pos.x, v.data.pos.y, v.data.pos.z-0.12, "Type: "..textColour..Config.GrapeTypesLabels[v.data.type].. "~w~ | Stage: "..v.data.stage.."/3")
								BJCore.Functions.DrawText3D(v.data.pos.x, v.data.pos.y, v.data.pos.z-0.22, "Food: ~b~"..v.data.food.."%~w~ | Water: ~b~"..v.data.water.."%")
								BJCore.Functions.DrawText3D(v.data.pos.x, v.data.pos.y, v.data.pos.z-0.32, "Health: ~b~"..v.data.health.."%")
							end
						end
					else
						if curVine and curVine == k then
							curVine = false
						end
					end
				end
			end
			Citizen.Wait(0)
		end
	end)
end

function VineYardProcessTick()
	Citizen.CreateThread(function()
		while PlayerData.job.name == Config.VineyardJob do
			local plyPos = GetEntityCoords(PlayerPedId())
			local distProcess = #(plyPos - Config.VineyardProcess)
			if distProcess < 10 then
				if distProcess < 2 then
					BJCore.Functions.DrawText3D(Config.VineyardProcess.x, Config.VineyardProcess.y, Config.VineyardProcess.z, "[~g~E~w~] Process & Bottle")
					if IsControlJustPressed(0, 38) then
						ProceesBottle()
					end
				end
			else
				Citizen.Wait(500)
			end
			Citizen.Wait(0)
		end
	end)
end

function ProceesBottle()
	BJCore.Functions.TriggerServerCallback("vineyard:server:getGrapes", function(data)
		if data.wine and data.times > 0 and data.bottles then
		    exports['mythic_progbar']:Progress({
		        name = "process_grapes",
		        duration = Config.VineyardProcessTimes["process"]*data.times*1000,
		        label = "Processing",
		        useWhileDead = false,
		        canCancel = true,
		        controlDisables = {
		            disableMovement = true,
		            disableCarMovement = true,
		            disableMouse = false,
		            disableCombat = true,
		        },
		        animation = {
		            animDict = "amb@prop_human_bum_bin@idle_b",
		            anim = "idle_d",
		            flags = 16,
		        },        
		    }, function(status)
		        if not status then
		            ClearPedTasks(PlayerPedId())
				    exports['mythic_progbar']:Progress({
				        name = "bottle_grapes",
				        duration = Config.VineyardProcessTimes["bottle"]*data.times*1000,
				        label = "Bottling",
				        useWhileDead = false,
				        canCancel = true,
				        controlDisables = {
				            disableMovement = true,
				            disableCarMovement = true,
				            disableMouse = false,
				            disableCombat = true,
				        },
				        animation = {
				            animDict = "amb@prop_human_bum_bin@idle_b",
				            anim = "idle_d",
				            flags = 16,
				        },        
				    }, function(status)
				        if not status then
				            ClearPedTasks(PlayerPedId())
				            TriggerServerEvent('vineyard:server:bottleWine', data.wine, data.times)
				        else
				            ClearPedTasks(PlayerPedId())
				            BJCore.Functions.Notify("Cancelled", "error")
				        end
				    end)
		        else
		            ClearPedTasks(PlayerPedId())
		            BJCore.Functions.Notify("Cancelled", "error")
		        end
		    end)
		else
			print("data: "..BJCore.Common.Dump(data))
			if not data.wine then
				BJCore.Functions.Notify("You don't have any grape clusters to process")
			elseif data.times == 0 then
				BJCore.Functions.Notify("You don't have enough grape clusters to process and bottle")
			elseif not data.bottles then
				BJCore.Functions.Notify("You don't have enough emtpy wine bottles to process x"..data.times, "error", 5000)
			end
		end
	end)
end

AddEventHandler("vineyard:client:pickVine", function()
	if not curVine then BJCore.Functions.Notify("Grape vine not found. Move closer to one", "error") return; end
	if curFieldData[curVine].data.stage ~= 3 then BJCore.Functions.Notify("This vine isn't ready to be picked", "error") return; end
    exports['mythic_progbar']:Progress({
        name = "pick_grape_vine",
        duration = 9500,
        label = "Picking",
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = "amb@world_human_gardener_plant@male@base",
            anim = "base",
            flags = 16,
        },        
    }, function(status)
        if not status then
            ClearPedTasks(PlayerPedId())
            TriggerServerEvent('vineyard:server:pickVine', curField, curVine, curField[curVine].data.type)
        else
            ClearPedTasks(PlayerPedId())
            BJCore.Functions.Notify("Cancelled", "error")
        end
    end)
end)

AddEventHandler("vineyard:client:removeVine", function()
	if not curVine then BJCore.Functions.Notify("Grape vine not found. Move closer to one", "error") return; end
    exports['mythic_progbar']:Progress({
        name = "remove_grape_vine",
        duration = 9500,
        label = "Removing",
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = "amb@world_human_gardener_plant@male@base",
            anim = "base",
            flags = 16,
        },        
    }, function(status)
        if not status then
            ClearPedTasks(PlayerPedId())
            TriggerServerEvent('vineyard:server:removeVine', curField, curVine)
        else
            ClearPedTasks(PlayerPedId())
            BJCore.Functions.Notify("Cancelled", "error")
        end
    end)
end)

RegisterNetEvent("vineyard:client:feedPlant", function(item, type)
	if not curVine then return; end
	local text = "Watering"
	if type == "food" then text = "Feeding"; end
    exports['mythic_progbar']:Progress({
        name = "feed_grape_vine",
        duration = 9500,
        label = text,
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = "amb@world_human_gardener_plant@male@base",
            anim = "base",
            flags = 16,
        },        
    }, function(status)
        if not status then
            ClearPedTasks(PlayerPedId())
            TriggerServerEvent('vineyard:server:feedPlant', item, type, curField, curVine)
        else
            ClearPedTasks(PlayerPedId())
            BJCore.Functions.Notify("Cancelled", "error")
        end
    end)
end)

RegisterNetEvent("vineyard:client:getFieldData", function(data) curFieldData = data end)

RegisterNetEvent("vineyard:client:syncFieldData", function(field, data)
	if curField ~= field then return; end
	curVine = false
	curFieldData = data
end)

RegisterNetEvent("BJCore:Client:OnPlayerLoaded")
AddEventHandler("BJCore:Client:OnPlayerLoaded", function()
    if not fieldsCreated and PlayerData.job.name == Config.VineyardJob then
    	VineYardProcessTick()
    	CreateFieldsPolyZone()
    end
end)

RegisterNetEvent('BJCore:Client:OnPlayerUnload')
AddEventHandler('BJCore:Client:OnPlayerUnload', function()
    DestroyFieldZones()
end)

RegisterNetEvent('BJCore:Client:OnJobUpdate')
AddEventHandler('BJCore:Client:OnJobUpdate', function(JobInfo)
    if fieldsCreated and JobInfo.name ~= Config.VineyardJob then
    	DestroyFieldZones()
	elseif not fieldsCreated and JobInfo.name == Config.VineyardJob then
		VineYardProcessTick()
        CreateFieldsPolyZone()
    end
end)

RegisterNetEvent("vineyard:client:plantSeed", function(item, type)
	if not curField then BJCore.Functions.Notify("You must be in a vineyard field to plant this", "error") return; end
	if BJCore.Functions.GetSurfaceType() ~= -700658213 then BJCore.Functions.Notify("You cannot plant in this surface", "error") return; end
	if curVine then BJCore.Functions.Notify("You can't plant this close to another vine", "error") return; end
    exports['mythic_progbar']:Progress({
        name = "plant_grape_vine",
        duration = 9500,
        label = "Planting",
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = "amb@world_human_gardener_plant@male@base",
            anim = "base",
            flags = 16,
        },        
    }, function(status)
        if not status then
            ClearPedTasks(PlayerPedId())
            local plantPos = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0, 0.75, 0)
            TriggerServerEvent('vineyard:server:placeVine', curField, {x=plantPos.x, y=plantPos.y, z=plantPos.z}, type)
            TriggerServerEvent('vineyard:server:removeSeed', item)
        else
            ClearPedTasks(PlayerPedId())
            BJCore.Functions.Notify("Cancelled", "error")
        end
    end)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return; end
    DestroyFieldZones()
end)