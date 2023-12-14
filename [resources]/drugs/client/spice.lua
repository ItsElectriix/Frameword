spiceFieldsCreated = false
spicefield = {
	["A"] = false,
	["B"] = false,
	["C"] = false,
	["D"] = false,
}

local curSpiceYard = false
local curSpiceYardData = nil

local SpiceFieldData = {
	["A"] = {},
	["B"] = {},
	["C"] = {},
	["D"] = {},
}

local curHarvest = false

function ManageSpiceFieldZones()
	for k,v in pairs(spicefield) do
		spicefield[k]:onPlayerInOut(function(isPointInside, point)
			if isPointInside then
				curSpiceYard = k
				print("Entered Zone: "..k)
				print("Point: "..BJCore.Common.Dump(point))
				TriggerEvent("IsInSpiceField", true)
				SpiceFieldTick()
			else
				if curSpiceYard == k then
					print("Left Zone: "..k)
					print("Point: "..BJCore.Common.Dump(point))
					TriggerEvent("IsInSpiceField", false)
					curSpiceYard = false
					curSpiceYardData = nil
				end
			end
		end)
	end
end

function DestroyFieldZones()
	TriggerEvent("IsInSpiceField", false)
	for k,v in pairs(spicefield) do
		if v ~= false then
			spicefield[k]:destroy()
		end
	end
	print("Destroyed Field Zones")
	curSpiceYard = false
	spiceFieldsCreated = false
end

SpiceMarkerColour = {
	["harvested"] = {
		r = 235,
		g = 23,
		b = 23,
	},
	["pending"] = {
		r = 235,
		g = 126,
		b = 23,
	},
	["processing"] = {
		r = 23,
		g = 69,
		b = 235,
	},		
}

local curTree = false
function SpiceFieldTick()
	Citizen.CreateThread(function()
		local plyPed = PlayerPedId()
		while curSpiceYard do
			local plyPos = GetEntityCoords(plyPed)
			for k,v in pairs(SpiceFieldData[curSpiceYard]) do
				local r,g,b = 0,0,0
				DrawMarker(1, v.pos.x, v.pos.y, v.pos.z-1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 4.0, 4.0, 0.7, SpiceMarkerColour[v.status].r, SpiceMarkerColour[v.status].g, SpiceMarkerColour[v.status].b, 180, false, true, 0, false)
				if v.status == "harvested" then

				elseif v.status == "pending" then
				elseif v.status == "processing" then
				end
			end
			if curHarvest then
				local dist = #(plyPos - curHarvest)
				if dist > 2.0 then
					BJCore.Functions.PersistentNotify("end", "SpiceHarvest")
					TriggerServerEvent("spice:server:leavePendingHarvest", curSpiceYard, curHarvest)
					curHarvest = false
				end
			end
			Citizen.Wait(0)
		end
		if not curSpiceYard and curHarvest then
			BJCore.Functions.PersistentNotify("end", "SpiceHarvest")
			TriggerServerEvent("spice:server:leavePendingHarvest", curSpiceYard, curHarvest)
			curHarvest = false
		end
	end)
end

RegisterNetEvent("spice:client:attemptLeafClip", function()
	if not curSpiceYard then return; end
	if curHarvest then return; end

	exports['mythic_progbar']:Progress({
		name = "spice_pre_inspect",
		duration = 12000,
		label = "Inspecting",
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
			TriggerServerEvent("spice:server:attemptLeafClip", GetEntityCoords(PlayerPedId()), curSpiceYard)
		else
			ClearPedTasks(ped)
			BJCore.Functions.Notify("Cancelled", "error")
		end
	end)
end)

RegisterNetEvent("spice:client:startGroupHarvest", function(pos)
	BJCore.Functions.PersistentNotify("end", "SpiceHarvest")
	exports['mythic_progbar']:Progress({
		name = "spice_pre_inspect",
		duration = 30000,
		label = "Harvesting",
		useWhileDead = false,
		canCancel = false,
		controlDisables = {
			disableMovement = true,
			disableCarMovement = true,
			disableMouse = false,
			disableCombat = true,
		},
		animation = {
			animDict = "amb@world_human_gardener_plant@male@idle_a",
			anim = "idle_b",
			flags = 31,
		},        
	}, function(status)
		if not status then
			ClearPedTasks(PlayerPedId())
			TriggerServerEvent("spice:server:completeHarvest", curSpiceYard, pos)
		else
			ClearPedTasks(PlayerPedId())
			BJCore.Functions.Notify("Cancelled", "error")
		end
	end)
end)

RegisterNetEvent("spice:client:pendingGroupHarvest", function(pos)
	curHarvest = pos
	BJCore.Functions.PersistentNotify("start", "SpiceHarvest", "You require an additional person to begin harvesting. Stay within the marked area", "primary")
end)

RegisterNetEvent("spice:client:updateFieldData", function(data) SpiceFieldData = data end)

RegisterNetEvent("BJCore:Client:OnPlayerLoaded")
AddEventHandler("BJCore:Client:OnPlayerLoaded", function()
	if not spiceFieldsCreated then
		CreateSpiceFieldPolyZone()
	end
end)

RegisterNetEvent('BJCore:Client:OnPlayerUnload')
AddEventHandler('BJCore:Client:OnPlayerUnload', function()
	DestroyFieldZones()
end)

AddEventHandler('onResourceStop', function(resource)
	if resource ~= GetCurrentResourceName() then return; end
	DestroyFieldZones()
	BJCore.Functions.PersistentNotify("end", "SpiceHarvest")
	BJCore.Functions.PersistentNotify("end", "SpiceTransform")
	BJCore.Functions.PersistentNotify("end", "SpiceWarn")
end)

local SpiceProcessLocations = vector3(1469.8654, 6550.395, 14.904129)

Citizen.CreateThread(function()
	while true do
		local plyPos = GetEntityCoords(PlayerPedId())
		local nearby = false
		local dist = #(plyPos - SpiceProcessLocations)
		if dist < 10 then
			nearby = true
			if dist < 2 then
				BJCore.Functions.DrawText3D(SpiceProcessLocations.x, SpiceProcessLocations.y, SpiceProcessLocations.z, "[~r~E~w~] Enter")
				if IsControlJustPressed(0, 38) then
					CreateSpiceShell(SpiceProcessLocations)
				end
			end
		end
		if not nearby then Citizen.Wait(1000); end
		Citizen.Wait(0)
	end
end)

local builtShell = {}
local inShell = false

local transformPositionsSpice = {
	["transform"] = {
		[1] = vector3(1452.8765, 6542.0058, -13.10062),
		[2] =  vector3(1454.795, 6542.1181, -13.09153),
	},
	["purify"] = {
		[1] = vector3(1453.7041, 6537.7993, -13.09301),
		[2] = vector3(1455.5415, 6537.9672, -13.08834)
	}
}

local curProcess = nil

function CreateSpiceShell(pos)
	builtShell = exports["interior"]:CreateWeed(vector3(pos.x, pos.y, pos.z - 30.0))
	TriggerEvent('InteractSound_CL:PlayOnOne', 'houses_door_open', 0.6)
	inShell = true
	while inShell do
		local plyPed = PlayerPedId()
		local plyPos = GetEntityCoords(PlayerPedId())
		local exit = vector3(SpiceProcessLocations.x + builtShell[2].exit.x, SpiceProcessLocations.y + builtShell[2].exit.y, SpiceProcessLocations.z-29)
		local dist = #(plyPos - exit)
		if dist < 2 then
			BJCore.Functions.DrawText3D(exit.x, exit.y, exit.z, "[~r~E~w~] Exit")
			if IsControlJustPressed(0, 38) then
				FreezeEntityPosition(PlayerPedId(), true)
				DoScreenFadeOut(250)
				Wait(250)
				exports["interior"]:DespawnInterior(builtShell[1], function()
					TriggerEvent('InteractSound_CL:PlayOnOne', 'houses_door_close', 0.5)
					SetEntityCoords(PlayerPedId(), 1469.8654, 6550.395, 14.904129)
					SetEntityHeading(PlayerPedId(), 355.75)
					while not HasCollisionLoadedAroundEntity(PlayerPedId()) do Citizen.Wait(0); end
					FreezeEntityPosition(PlayerPedId(), false)
					DoScreenFadeIn(250)
					inShell = false
				end)
			end
		end
		for k,v in pairs(transformPositionsSpice["transform"]) do
			local dist = #(plyPos - v)
			if dist < 1.0 then
				if curProcess ~= nil then
					if curProcess.type == "transform" then
						BJCore.Functions.DrawText3D(v.x, v.y, v.z, "[~r~E~w~] Leave")
						if IsControlJustPressed(0, 38) then
							TriggerServerEvent("spice:server:leaveProcess", "transform", k)
						end
					end
				else
					BJCore.Functions.DrawText3D(v.x, v.y, v.z, "[~r~E~w~] Process Spice")
					if IsControlJustPressed(0, 38) then
						TriggerServerEvent("spice:server:attemptProcess", "transform", k)
					end
				end
			end
		end
		for k,v in pairs(transformPositionsSpice["purify"]) do
			local dist = #(plyPos - v)
			if dist < 1.0 then
				if curProcess ~= nil then
					if curProcess.type == "purify" then
						BJCore.Functions.DrawText3D(v.x, v.y, v.z, "[~r~E~w~] Leave")
						if IsControlJustPressed(0, 38) then
							TriggerServerEvent("spice:server:leaveProcess", "purify", k)
						end
					end
				else
					BJCore.Functions.DrawText3D(v.x, v.y, v.z, "[~r~E~w~] Sort and pack")
					if IsControlJustPressed(0, 38) then
						TriggerServerEvent("spice:server:attemptProcess", "purify", k)
					end
				end
			end
		end
		Citizen.Wait(0)
	end
	inShell = false
end

RegisterNetEvent("spice:client:pendingProcess", function(type, key)
	curProcess = {}
	curProcess.type = type
	curProcess.key = key
	FreezeEntityPosition(PlayerPedId(), true)
	BJCore.Functions.PersistentNotify("start", "SpiceTransform", "You require an additional person to begin this process", "primary")
end)

RegisterNetEvent("spice:client:leaveProcess", function()
	curProcess = nil
	FreezeEntityPosition(PlayerPedId(), false)
	BJCore.Functions.PersistentNotify("end", "SpiceTransform")
end)

local ProcessTime = {
	["transform"] = 2, -- per one
	["purify"] = 5 -- per one
}

local processing = false
RegisterNetEvent("spice:client:startProcess", function(type, key, amount)
	processing = true
	BJCore.Functions.PersistentNotify("end", "SpiceTransform")

	-- clothingCheckTickspice()
	exports['mythic_progbar']:Progress({
		name = "spice_process",
		duration = (ProcessTime[type]*amount)*1000,
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
			animDict = "anim@amb@business@coc@coc_unpack_cut@",
			anim = "fullcut_cycle_v3_spicecutter",
			flags = 1,
		},
		prop = {
			model = "prop_cs_business_card",
			bone = 6286,
			coords = { x = 0.09, y = 0.03, z = -0.065 },
			rotation = { x = 0.0, y = 180.0, z = 90.0 },
		},
	}, function(status)
		if not status then
			processing = false
			ClearPedTasks(PlayerPedId())
			Citizen.Wait(math.random(500, 1500))
			TriggerServerEvent("spice:server:finishProcess", type)
		else
			processing = false
			ClearPedTasks(PlayerPedId())
			BJCore.Functions.Notify("Cancelled", "error")
			TriggerServerEvent("spice:server:forceCancelProcess", type, key)
		end
	end)
end)	

-- function clothingCheckTickspice()
-- 	if (not exports["crim"]:IsWearingGloves() or not exports["crim"]:IsWearingMask()) then
-- 		BJCore.Functions.PersistentNotify("start", "spiceWarn", "You should probably be wearing some protection", "primary")
-- 	end
-- 	Citizen.CreateThread(function()
-- 		while processing do
-- 			if not exports["crim"]:IsWearingGloves() then
-- 				SetEntityHealth(PlayerPedId(), GetEntityHealth(PlayerPedId()) - 5)
-- 			end
-- 			if not exports["crim"]:IsWearingMask() then
-- 				SetEntityHealth(PlayerPedId(), GetEntityHealth(PlayerPedId()) - 5)
-- 			end
-- 			Citizen.Wait(5000)
-- 		end
-- 		BJCore.Functions.PersistentNotify("end", "spiceWarn")
-- 	end)
-- end

RegisterNetEvent("drugs-client-GiveDrugMoney")
AddEventHandler("drugs-client-GiveDrugMoney", function(source)
    TriggerServerEvent("drugs-server-GiveDrugMoney", source)
end)