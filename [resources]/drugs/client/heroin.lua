heroinFieldsCreated = false
heroinfield = {
	["A"] = false,
}

local curHeroinYard = false
local curHeroinYardData = nil

local HeroinFieldData = {
	["A"] = {},
}

local curHarvest = false

local policeReq = {
	["harvest"] = 3,
	["process"] = 4,
	["purify"] = 4,
}

function ManageHeroinFieldZones()
	for k,v in pairs(heroinfield) do
		heroinfield[k]:onPlayerInOut(function(isPointInside, point)
			if isPointInside then
				curHeroinYard = k
				print("Entered Zone: "..k)
				print("Point: "..BJCore.Common.Dump(point))
				TriggerEvent("IsInHeroinField", true)
				HeroinFieldTick()
			else
				if curHeroinYard == k then
					print("Left Zone: "..k)
					print("Point: "..BJCore.Common.Dump(point))
					TriggerEvent("IsInHeroinField", false)
					curHeroinYard = false
					curHeroinYardData = nil
				end
			end
		end)
	end
end

function DestroyHeroinFieldZones()
	TriggerEvent("IsInHeroinField", false)
	for k,v in pairs(heroinfield) do
		if v ~= false then
			heroinfield[k]:destroy()
		end
	end
	print("Destroyed Field Zones")
	curHeroinYard = false
	heroinFieldsCreated = false
end

HeroinMarkerColour = {
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
function HeroinFieldTick()
	Citizen.CreateThread(function()
		local plyPed = PlayerPedId()
		while curHeroinYard do
			local plyPos = GetEntityCoords(plyPed)
			for k,v in pairs(HeroinFieldData[curHeroinYard]) do
				local r,g,b = 0,0,0
				DrawMarker(1, v.pos.x, v.pos.y, v.pos.z-1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 4.0, 4.0, 0.7, HeroinMarkerColour[v.status].r, HeroinMarkerColour[v.status].g, HeroinMarkerColour[v.status].b, 180, false, true, 0, false)
				if v.status == "harvested" then

				elseif v.status == "pending" then
				elseif v.status == "processing" then
				end
			end
			if curHarvest then
				local dist = #(plyPos - curHarvest)
				if dist > 2.0 then
					BJCore.Functions.PersistentNotify("end", "HeroinHarvest")
					TriggerServerEvent("heroin:server:leavePendingHarvest", curHeroinYard, curHarvest)
					curHarvest = false
				end
			end
			Citizen.Wait(0)
		end
		if not curHeroinYard and curHarvest then
			BJCore.Functions.PersistentNotify("end", "HeroinHarvest")
			TriggerServerEvent("heroin:server:leavePendingHarvest", curHeroinYard, curHarvest)
			curHarvest = false
		end
	end)
end

RegisterNetEvent("heroin:client:attemptLeafClip", function()
	if not curHeroinYard then return; end
	if curHarvest then return; end
	if CurrentCops < policeReq["harvest"] then BJCore.Functions.Notify("Not enough police on to do this") return; end
	if IsEntityInWater(PlayerPedId()) then BJCore.Functions.Notify("You cannot do this in water", "error") return; end
	if BJCore.Functions.GetSurfaceType() ~= 223086562 then BJCore.Functions.Notify("You cannot do this on this surface", "error") return; end
	exports['mythic_progbar']:Progress({
		name = "heroin_pre_inspect",
		duration = 10000,
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
			TriggerServerEvent("heroin:server:attemptLeafClip", GetEntityCoords(PlayerPedId()), curHeroinYard)
		else
			ClearPedTasks(ped)
			BJCore.Functions.Notify("Cancelled", "error")
		end
	end)
end)

RegisterNetEvent("heroin:client:startGroupHarvest", function(pos)
	BJCore.Functions.PersistentNotify("end", "HeroinHarvest")
	exports['mythic_progbar']:Progress({
		name = "heroin_pre_inspect",
		duration = 25000,
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
			TriggerServerEvent("heroin:server:completeHarvest", curHeroinYard, pos)
		else
			ClearPedTasks(PlayerPedId())
			BJCore.Functions.Notify("Cancelled", "error")
		end
	end)
end)

RegisterNetEvent("heroin:client:pendingGroupHarvest", function(pos)
	curHarvest = pos
	BJCore.Functions.PersistentNotify("start", "HeroinHarvest", "You require an additional person to begin harvesting. Stay within the marked area", "primary")
end)

RegisterNetEvent("heroin:client:updateFieldData", function(data) HeroinFieldData = data end)

RegisterNetEvent("BJCore:Client:OnPlayerLoaded")
AddEventHandler("BJCore:Client:OnPlayerLoaded", function()
	if not heroinFieldsCreated then
		CreateHeroinFieldPolyZone()
	end
end)

RegisterNetEvent('BJCore:Client:OnPlayerUnload')
AddEventHandler('BJCore:Client:OnPlayerUnload', function()
	DestroyHeroinFieldZones()
end)

AddEventHandler('onResourceStop', function(resource)
	if resource ~= GetCurrentResourceName() then return; end
	DestroyHeroinFieldZones()
	BJCore.Functions.PersistentNotify("end", "HeroinHarvest")
	BJCore.Functions.PersistentNotify("end", "HeroinTransform")
	BJCore.Functions.PersistentNotify("end", "HeroinWarn")
end)

local HeroinProcessLocations = {
	[1] = vector3(-204.8385, 6097.3041, 31.522281),
}

Citizen.CreateThread(function()
	while true do
		local plyPos = GetEntityCoords(PlayerPedId())
		local nearby = false
		for k,v in pairs(HeroinProcessLocations) do
			local dist = #(plyPos - v)
			if dist < 10 then
				nearby = true
				if dist < 2 then
					BJCore.Functions.DrawText3D(v.x, v.y, v.z, "[~r~E~w~] Enter")
					if IsControlJustPressed(0, 38) then
						CreateHeroinShell(v, k)
					end
				end
			end
		end
		if not nearby then Citizen.Wait(1000); end
		Citizen.Wait(0)
	end
end)

local builtShell = {}
local inShell = false

local transformPositions = {
	["transform"] = {
		[1] = {
			[1] = vector3(-200.8482, 6100.2788, 2.5603935),
			[2] = vector3(-199.0806, 6101.2021, 2.5603935),
		}
	},
	["purify"] = {
		[1] = {
			[1] = vector3(-198.8899, 6094.621, 2.5603942),
			[2] = vector3(-197.2489, 6093.9453, 2.5603942)
		}
	}
}

local curProcess = nil

function CreateHeroinShell(pos, index)
	builtShell = exports["interior"]:CreateCoke(vector3(pos.x, pos.y, pos.z - 30.0))
	TriggerEvent('InteractSound_CL:PlayOnOne', 'houses_door_open', 0.6)
	inShell = true
	while inShell do
		local plyPed = PlayerPedId()
		local plyPos = GetEntityCoords(PlayerPedId())
		local exit = vector3(pos.x + builtShell[2].exit.x, pos.y + builtShell[2].exit.y, pos.z-29)
		local dist = #(plyPos - exit)
		if dist < 2 then
			BJCore.Functions.DrawText3D(exit.x, exit.y, exit.z, "[~r~E~w~] Exit")
			if IsControlJustPressed(0, 38) then
				FreezeEntityPosition(PlayerPedId(), true)
				DoScreenFadeOut(250)
				Wait(250)
				exports["interior"]:DespawnInterior(builtShell[1], function()
					TriggerEvent('InteractSound_CL:PlayOnOne', 'houses_door_close', 0.5)
					SetEntityCoords(PlayerPedId(), pos)
					SetEntityHeading(PlayerPedId(), 178.83)
					while not HasCollisionLoadedAroundEntity(PlayerPedId()) do Citizen.Wait(0); end
					FreezeEntityPosition(PlayerPedId(), false)
					DoScreenFadeIn(250)
					inShell = false
				end)
			end
		end
		for k,v in pairs(transformPositions["transform"][index]) do
			local dist = #(plyPos - v)
			if dist < 1.0 then
				if curProcess ~= nil then
					if curProcess.type == "transform" then
						BJCore.Functions.DrawText3D(v.x, v.y, v.z, "[~r~E~w~] Leave")
						if IsControlJustPressed(0, 38) then
							TriggerServerEvent("heroin:server:leaveProcess", "transform", k, index)
						end
					end
				else
					BJCore.Functions.DrawText3D(v.x, v.y, v.z, "[~r~E~w~] Process Rawmorphine")
					if IsControlJustPressed(0, 38) then
						TriggerServerEvent("heroin:server:attemptProcess", "transform", k, index)
					end
				end
			end
		end
		for k,v in pairs(transformPositions["purify"][index]) do
			local dist = #(plyPos - v)
			if dist < 1.0 then
				if curProcess ~= nil then
					if curProcess.type == "purify" then
						BJCore.Functions.DrawText3D(v.x, v.y, v.z, "[~r~E~w~] Leave")
						if IsControlJustPressed(0, 38) then
							TriggerServerEvent("heroin:server:leaveProcess", "purify", k, index)
						end
					end
				else
					BJCore.Functions.DrawText3D(v.x, v.y, v.z, "[~r~E~w~] Purify & Pack")
					if IsControlJustPressed(0, 38) then
						TriggerServerEvent("heroin:server:attemptProcess", "purify", k, index)
					end
				end
			end
		end
		Citizen.Wait(0)
	end
	inShell = false
end

RegisterNetEvent("heroin:client:pendingProcess", function(type, key)
	curProcess = {}
	curProcess.type = type
	curProcess.key = key
	FreezeEntityPosition(PlayerPedId(), true)
	BJCore.Functions.PersistentNotify("start", "HeroinTransform", "You require an additional person to begin this process", "primary")
end)

RegisterNetEvent("heroin:client:leaveProcess", function()
	curProcess = nil
	FreezeEntityPosition(PlayerPedId(), false)
	BJCore.Functions.PersistentNotify("end", "HeroinTransform")
end)

local ProcessTime = {
	["transform"] = 2, -- per one
	["purify"] = 4 -- per one
}

local processing = false
RegisterNetEvent("heroin:client:startProcess", function(type, key, amount, index)
	processing = true
	BJCore.Functions.PersistentNotify("end", "HeroinTransform")
	if CurrentCops < policeReq["process"]then BJCore.Functions.Notify("Not enough police on to do this") return; end
	clothingCheckTickHeroin()
	exports['mythic_progbar']:Progress({
		name = "heroin_process",
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
			animDict = "mp_fm_intro_cut",
			anim = "fixing_a_ped",
			flags = 1,
		},
	}, function(status)
		if not status then
			processing = false
			ClearPedTasks(PlayerPedId())
			Citizen.Wait(math.random(500, 1500))
			TriggerServerEvent("heroin:server:finishProcess", type, index)
		else
			processing = false
			ClearPedTasks(PlayerPedId())
			BJCore.Functions.Notify("Cancelled", "error")
			TriggerServerEvent("heroin:server:forceCancelProcess", type, key, index)
		end
	end)
end)

function clothingCheckTickHeroin()
	if (not exports["crim"]:IsWearingGloves() or not exports["crim"]:IsWearingMask()) then
		BJCore.Functions.PersistentNotify("start", "MethWarn", "You should probably be wearing some protection", "primary")
	end
	Citizen.CreateThread(function()
		while processing do
			if not exports["crim"]:IsWearingGloves() then
				SetEntityHealth(PlayerPedId(), GetEntityHealth(PlayerPedId()) - 5)
			end
			if not exports["crim"]:IsWearingMask() then
				SetEntityHealth(PlayerPedId(), GetEntityHealth(PlayerPedId()) - 5)
			end
			Citizen.Wait(5000)
		end
		BJCore.Functions.PersistentNotify("end", "MethWarn")
	end)
end


RegisterNetEvent("drugs-client-GiveDrugMoney")
AddEventHandler("drugs-client-GiveDrugMoney", function(source)
    TriggerServerEvent("drugs-server-GiveDrugMoney", source)
end)