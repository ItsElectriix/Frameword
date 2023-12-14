cokeFieldsCreated = false
cokefield = {
	["A"] = false,
	["B"] = false,
	["C"] = false,
	["D"] = false,
}

local curCokeYard = false
local curCokeYardData = nil

local CokeFieldData = {
	["A"] = {},
	["B"] = {},
	["C"] = {},
	["D"] = {},
}

local curHarvest = false

local policeReq = {
	["harvest"] = 2,
	["process"] = 2,
	["purify"] = 4,
}

local AccessData = {}

function ManageCokeFieldZones()
	for k,v in pairs(cokefield) do
		cokefield[k]:onPlayerInOut(function(isPointInside, point)
			if isPointInside then
				curCokeYard = k
				print("Entered Zone: "..k)
				print("Point: "..BJCore.Common.Dump(point))
				TriggerEvent("IsInCokeField", true)
				CokeFieldTick()
			else
				if curCokeYard == k then
					print("Left Zone: "..k)
					print("Point: "..BJCore.Common.Dump(point))
					TriggerEvent("IsInCokeField", false)
					curCokeYard = false
					curCokeYardData = nil
				end
			end
		end)
	end
end

function DestroyFieldZones()
	TriggerEvent("IsInCokeField", false)
	for k,v in pairs(cokefield) do
		if v ~= false then
			cokefield[k]:destroy()
		end
	end
	print("Destroyed Field Zones")
	curCokeYard = false
	cokeFieldsCreated = false
end

CokeMarkerColour = {
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

function CokeFieldTick()
	Citizen.CreateThread(function()
		local plyPed = PlayerPedId()
		while curCokeYard do
			local plyPos = GetEntityCoords(plyPed)
			for k,v in pairs(CokeFieldData[curCokeYard]) do
				local r,g,b = 0,0,0
				DrawMarker(1, v.pos.x, v.pos.y, v.pos.z-1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 4.0, 4.0, 0.7, CokeMarkerColour[v.status].r, CokeMarkerColour[v.status].g, CokeMarkerColour[v.status].b, 180, false, true, 0, false)
				if v.status == "harvested" then

				elseif v.status == "pending" then
				elseif v.status == "processing" then
				end
			end
			if curHarvest then
				local dist = #(plyPos - curHarvest)
				if dist > 2.0 then
					BJCore.Functions.PersistentNotify("end", "CokeHarvest")
					TriggerServerEvent("coke:server:leavePendingHarvest", curCokeYard, curHarvest)
					curHarvest = false
				end
			end
			Citizen.Wait(0)
		end
		if not curCokeYard and curHarvest then
			BJCore.Functions.PersistentNotify("end", "CokeHarvest")
			TriggerServerEvent("coke:server:leavePendingHarvest", curCokeYard, curHarvest)
			curHarvest = false
		end
	end)
end

RegisterNetEvent("coke:client:attemptLeafClip", function()
	if not curCokeYard then BJCore.Functions.Notify("Cannot be used here", "error") return; end
	if curHarvest then return; end
	if AccessData[PlayerData.citizenid] == nil then BJCore.Functions.Notify("You don't have access to these fields", "error") return; end
	--if CurrentCops < policeReq["harvest"] then BJCore.Functions.Notify("Not enough police on to do this") return; end
	exports['mythic_progbar']:Progress({
		name = "coke_pre_inspect",
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
			TriggerServerEvent("coke:server:attemptLeafClip", GetEntityCoords(PlayerPedId()), curCokeYard)
		else
			ClearPedTasks(ped)
			BJCore.Functions.Notify("Cancelled", "error")
		end
	end)
end)

local curProcess = nil
RegisterNetEvent("coke:client:pendingProcess", function(type, key)
	curProcess = {}
	curProcess.type = type
	curProcess.key = key
	FreezeEntityPosition(PlayerPedId(), true)
	BJCore.Functions.PersistentNotify("start", "CokeTransform", "You require an additional person to begin this process. They can join you on the other side of the table", "primary")
end)

RegisterNetEvent("coke:client:leaveProcess", function()
	curProcess = nil
	FreezeEntityPosition(PlayerPedId(), false)
	BJCore.Functions.PersistentNotify("end", "CokeTransform")
end)

RegisterNetEvent("coke:client:startGroupHarvest", function(pos)
	BJCore.Functions.PersistentNotify("end", "CokeHarvest")
	exports['mythic_progbar']:Progress({
		name = "coke_group_harvest",
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
			animDict = "amb@world_human_gardener_plant@male@base",
			anim = "base",
		},        
	}, function(status)
		if not status then
			ClearPedTasks(PlayerPedId())
			TriggerServerEvent("coke:server:completeHarvest", curCokeYard, pos)
		else
			ClearPedTasks(PlayerPedId())
			BJCore.Functions.Notify("Cancelled", "error")
		end
	end)
end)

RegisterNetEvent("coke:client:pendingGroupHarvest", function(pos)
	curHarvest = pos
	BJCore.Functions.PersistentNotify("start", "CokeHarvest", "You require an additional person to begin harvesting. Stay within the marked area", "primary")
end)

local inLab = false

local BarrelData = {}
local barrelObjects = {}

local ProcessLocations = {}

local processing = false

local CokeProcessLocations = vector3(835.63983, -828.5337, 26.331464)

Citizen.CreateThread(function()
	for k,v in pairs(Config.CokeLabLocations) do
		barrelObjects[k] = {}
	end
	while true do
		local plyPos = GetEntityCoords(PlayerPedId())
		local nearby = false
		for k,v in pairs(Config.CokeLabLocations) do
			local dist = #(plyPos - v.xyz)
			if dist < 10 then
				nearby = true
				if dist < 1.2 then
					BJCore.Functions.DrawText3D(v.x, v.y, v.z, "[~r~E~w~] Enter")
					if IsControlJustPressed(0, 38) then
						EnterCokeLab(k, v)
					end
				end
			end
		end
		if not nearby then Citizen.Wait(500); end
		Citizen.Wait(0)
	end
end)

function EnterCokeLab(index, entry)
	StartPlayerTeleport(PlayerId(), 1088.6163, -3187.464, -38.99346, 183.93, true, true, true)
	TriggerEvent('InteractSound_CL:PlayOnOne', 'houses_door_open', 0.6)
	local carryObject = exports["inventory"]:GetCarryingObject()
	if carryObject ~= nil then carryObject = NetworkGetNetworkIdFromEntity(carryObject); end
	TriggerServerEvent("coke:server:setLabBucket", index, true, carryObject)
	inLab = index
	local LastPressed = 0
	while inLab do
		local plyPed = PlayerPedId()
		local plyPos = GetEntityCoords(PlayerPedId())
		local exit = vector3(1088.6163, -3187.464, -38.99346)
		local dist = #(plyPos - exit)
		if dist < 1.2 then
			BJCore.Functions.DrawText3D(exit.x, exit.y, exit.z, "[~r~E~w~] Exit")
			if IsControlJustPressed(0, 38) and GetGameTimer() - LastPressed > 1500 then
				LastPressed = GetGameTimer()
				--StartPlayerTeleport(PlayerId(), entry.x, entry.y, entry.z+1.0, entry.w, true, false, true)
				FreezeEntityPosition(PlayerPedId(), true)
				DoScreenFadeOut(250)
				Wait(250)
				TriggerEvent('InteractSound_CL:PlayOnOne', 'houses_door_close', 0.5)
				SetEntityCoords(PlayerPedId(), entry.x, entry.y, entry.z)
				SetEntityHeading(PlayerPedId(), entry.w)
				while not HasCollisionLoadedAroundEntity(PlayerPedId()) do Citizen.Wait(0); end
				Wait(500)
				FreezeEntityPosition(PlayerPedId(), false)
				DoScreenFadeIn(250)
				inLab = false
			end
		end
		if #(plyPos - Config.CokeLabStash) < 1.5 then
			BJCore.Functions.DrawText3D(1096.8835, -3192.455, -38.99342, "[~r~E~w~] Lab Stash")
			if IsControlJustPressed(0, 38) and GetGameTimer() - LastPressed > 1500 and not processing then
				LastPressed = GetGameTimer()
				TriggerServerEvent("inventory:server:OpenInventory", "stash", "cokelab_"..index, {
					maxweight = 5000000,
					slots = 500,
				}, 'Coke Lab Stash')
				TriggerEvent("inventory:client:SetCurrentStash", "cokelab_"..index)
			end
		end
		for k,v in pairs(Config.CokeLabProductionPos["prepare"]) do
			if barrelObjects[index][k] == nil and not DoesEntityExist(barrelObjects[index][k]) then
				barrelObjects[index][k] = CreateObject(`prop_barrel_03a`, v.x, v.y, v.z, false, false)
				FreezeEntityPosition(barrelObjects[index][k], true)
				PlaceObjectOnGroundProperly(barrelObjects[index][k])
				SetEntityCoords(barrelObjects[index][k], v.x, v.y, v.z)
			end
			local dist = #(plyPos - v)
			if dist < 1.0 then
				if BarrelData[index][k].inUse then
					BJCore.Functions.DrawText3D(v.x, v.y, v.z+0.5, "~r~In Use ~w~| Stage: "..BarrelData[index][k].stage.."/3")
				elseif BarrelData[index][k].cooking then
					BJCore.Functions.DrawText3D(v.x, v.y, v.z+0.5, "~r~Processing")
				elseif BarrelData[index][k].processing then
					BJCore.Functions.DrawText3D(v.x, v.y, v.z+0.5, "~g~Ready ~w~| Stage: "..BarrelData[index][k].stage.."/3")
				else
					BJCore.Functions.DrawText3D(v.x, v.y, v.z+0.5, "~g~Available")
				end
				BJCore.Functions.DrawText3D(v.x, v.y, v.z+0.4, "[~r~E~w~] Process Leaves")
				if IsControlJustPressed(0, 38) and GetGameTimer() - LastPressed > 1500 and not processing then
					LastPressed = GetGameTimer()
					TriggerServerEvent("coke:server:doProcess", "prepare", index, k)
				end
			end
		end
		for k,v in pairs(Config.CokeLabProductionPos["extract"]) do
			local dist = #(plyPos - v)
			if dist < 1.0 then
				BJCore.Functions.DrawText3D(v.x, v.y, v.z, "[~r~E~w~] Extract")
				if IsControlJustPressed(0, 38) and GetGameTimer() - LastPressed > 1500 and not processing then
					LastPressed = GetGameTimer()
					TriggerServerEvent("coke:server:doProcess", "extract", index)
				end
			end
		end
		for k,v in pairs(Config.CokeLabProductionPos["process"]) do
			for i,pos in pairs(v) do
				local dist = #(plyPos - pos)
				if dist < 1.0 then
					if curProcess ~= nil and not processing then
						BJCore.Functions.DrawText3D(pos.x, pos.y, pos.z, "[~r~E~w~] Leave")
						if IsControlJustPressed(0, 38) and GetGameTimer() - LastPressed > 1500 then
							LastPressed = GetGameTimer()
							TriggerServerEvent("coke:server:leaveProcess", index, k, i)
						end
					else
						if not ProcessLocations[index][k][i].client then
							BJCore.Functions.DrawText3D(pos.x, pos.y, pos.z, "[~r~E~w~] Process (~b~"..k.."~w~)")
							if IsControlJustPressed(0, 38) and GetGameTimer() - LastPressed > 1500 and not processing then
								LastPressed = GetGameTimer()
								TriggerServerEvent("coke:server:attemptProcess", index, k, i)
							end
						else
							BJCore.Functions.DrawText3D(pos.x, pos.y, pos.z, "~r~In Use")
						end
					end
				end
			end
		end
		for k,v in pairs(Config.CokeLabProductionPos["package"]) do
			local dist = #(plyPos - v)
			if dist < 1.0 then
				BJCore.Functions.DrawText3D(v.x, v.y, v.z, "[~r~E~w~] Package")
				if IsControlJustPressed(0, 38) and GetGameTimer() - LastPressed > 1500 and not processing then
					LastPressed = GetGameTimer()
					TriggerServerEvent("coke:server:doProcess", "package", index)
				end
			end
		end
		Citizen.Wait(0)
	end
	inLab = false
	for k,v in pairs(barrelObjects[index]) do
		DeleteEntity(v)
		barrelObjects[index][k] = nil
	end
	local carryObject = exports["inventory"]:GetCarryingObject()
	if carryObject ~= nil then carryObject = NetworkGetNetworkIdFromEntity(carryObject); end
	TriggerServerEvent("coke:server:setLabBucket", index, false, carryObject)
end

-- local ProcessTime = { -- in seconds
-- 	["prepare"] = 120,
-- 	["extract"] = 60,
-- 	["process"] = 240,
-- 	["package"] = 60
-- }

local ProcessTime = { -- in seconds
	["prepare"] = 3,
	["extract"] = 3,
	["process"] = 3,
	["package"] = 3
}

local ProcessText = {
	["prepare"] = "Preparing Leaves",
	["extract"] = "Extracting",
	["process"] = "Processing",
	["package"] = "Packaging",
}

RegisterNetEvent("coke:client:startProcess", function(type, key, data)
	processing = true
	clothingCheckTick()
	local animDict = "anim@amb@business@coc@coc_unpack_cut_left@"
    local anim = "coke_cut_v5_coccutter"
    if type == "prepare" then
    	if data == 1 then
    		animDict = "weapon@w_sp_jerrycan"
			anim = "fire"
			local weapon = GetHashKey('WEAPON_PETROLCAN')
			GiveWeaponToPed(PlayerPedId(), weapon, 1, false, true)
			SetCurrentPedWeapon(PlayerPedId(), weapon, true)
		else
			animDict = "amb@prop_human_bum_bin@base"
			anim = "base"
		end
	end
	local processTime = ProcessTime[type]*1000
	local scaleDown = false
	for i = 1, #Config.ProductionScaleTime, 1 do
		if PlayerData.metadata["cokelab"] >= Config.ProductionScaleTime[i].rep then
			scaleDown = Config.ProductionScaleTime[i].scale/100
		end
	end
	if scaleDown then
		processTime = ProductionScaleTime - (ProductionScaleTime*scaleDown)
	end
	if type ~= "packing" then
		local fail = nil
		for i = 1, #Config.ProductionFailureChance, 1 do
			if PlayerData.metadata["cokelab"] <= Config.ProductionFailureChance[i].rep then
				fail = Config.ProductionFailureChance[i].chance
			end
		end
		local chance = math.random(100)
		if chance <= fail then
			chanceFailProcess(processTime)
		end
	end
	exports['mythic_progbar']:Progress({
		name = "coke_process"..type,
		duration = processTime,
		label = ProcessText[type],
		useWhileDead = false,
		canCancel = true,
		controlDisables = {
			disableMovement = true,
			disableCarMovement = true,
			disableMouse = false,
			disableCombat = true,
		},
        animation = {
            animDict = animDict,
            anim = anim,
        },
	}, function(status)
		if not status then
			processing = false
			ClearPedTasks(PlayerPedId())
			if type == "process" then
				TriggerServerEvent("coke:server:finishProcessStage", inLab, key, data)
			else
				TriggerServerEvent("coke:server:finishProcess", inLab, type, key, data)
			end
		else
			processing = false
			ClearPedTasks(PlayerPedId())
			BJCore.Functions.Notify("Cancelled", "error")
			if type == "process" then
				TriggerServerEvent("coke:server:forceCancelProcess", inLab, key, data)
			elseif type == "prepare" then
				TriggerServerEvent("coke:server:forceCancelPrepare", inLab, key)
			end
		end
		RemoveWeaponFromPed(PlayerPedId(),GetHashKey('WEAPON_PETROLCAN'))
	end)
end)

function chanceFailProcess(time)
	Citizen.CreateThread(function()
		SetTimeout(math.random(time-(time/2), time-1000), function()
			TriggerEvent("mythic_progbar:client:cancel")
			BJCore.Functions.Notify("You failed this process", "error")
		end)
	end)
end

function clothingCheckTick()
	if (not exports["crim"]:IsWearingGloves() or not exports["crim"]:IsWearingMask()) then
		BJCore.Functions.PersistentNotify("start", "CokeWarn", "You should probably be wearing some protection", "primary")
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
		BJCore.Functions.PersistentNotify("end", "CokeWarn")
	end)
end

local SpawnedCokeReqPed = nil
local StartPos = nil
local HasDropOff = false
local DropOffLocation = nil
local CokeFieldNPC = nil

Citizen.CreateThread(function()
	TriggerServerEvent("coke:server:getStartPosition")
	while StartPos == nil do Citizen.Wait(100); end
	if next(PlayerData) == nil then PlayerData = BJCore.Functions.GetPlayerData(); end
	while true do
		local nearby = false
		local plyPed = PlayerPedId()
		local plyPos = GetEntityCoords(plyPed)
		local LastPressed = 0
		if #(plyPos.xyz - StartPos.xyz) < 85 then
			if SpawnedCokeReqPed == nil or not DoesEntityExist(SpawnedCokeReqPed) then
				CreateStartCokePed(StartPos)
			end
			if #(plyPos.xyz - StartPos.xyz) < 10 then
				nearby = true
				if #(plyPos.xyz - StartPos.xyz) < 1.6 then
					BJCore.Functions.DrawText3D(StartPos.x,StartPos.y,StartPos.z+1,"[~r~E~s~] Talk")
					if IsControlJustReleased(0, 38) and GetGameTimer() - LastPressed > 1000 then
						LastPressed = GetGameTimer()
						ClearPedTasks(SpawnedCokeReqPed)
						Wait(3000)
						TaskStartScenarioInPlace(SpawnedCokeReqPed, 'WORLD_HUMAN_CLIPBOARD', 0, true)
						Wait(math.random(5000, 8000))
						if not HasDropOff then
							BJCore.Functions.TriggerServerCallback("crim:server:getRep", function(rep)
								if rep and rep >= Config.ReqDealerRep then
									GiveDropOff()
								else
									BJCore.Functions.Notify("I've never heard of you! Get out of my face!", "error", 10000)
									Wait(500)
									ClearPedTasks(SpawnedCokeReqPed)
									Wait(2500)
									TaskGoStraightToCoord(SpawnedCokeReqPed, StartPos.xyz, 1.0, -1, StartPos.w, 2.0)
									Wait(1000)
									TaskStartScenarioInPlace(SpawnedCokeReqPed, 'WORLD_HUMAN_LEANING', 0, true)
								end
							end, 'dealerrep')
						else
							BJCore.Functions.Notify("You already have an active task", "error")
						end
					end
				end
			end
		else
			if DoesEntityExist(SpawnedCokeReqPed) then
				DeleteEntity(SpawnedCokeReqPed)
				SpawnedCokeReqPed = nil
			end
		end

		if #(plyPos.xyz - Config.CokeFieldNPC.xyz) < 85 then
			if CokeFieldNPC == nil or not DoesEntityExist(CokeFieldNPC) then
				CreateCokeFieldPed()
			end
			if #(plyPos.xyz - Config.CokeFieldNPC.xyz) < 10 then
				nearby = true
				if #(plyPos.xyz - Config.CokeFieldNPC.xyz) < 1.6 then
					BJCore.Functions.DrawText3D(Config.CokeFieldNPC.x,Config.CokeFieldNPC.y,Config.CokeFieldNPC.z+1.0,"[~r~E~s~] Talk")
					if IsControlJustReleased(0, 38) and GetGameTimer() - LastPressed > 1000 then
						LastPressed = GetGameTimer()
						if AccessData[PlayerData.citizenid] then
							BJCore.Functions.Notify("Harvest what you can from these fields. You'll need at least 2 people to do this. Don't bring any unnecessary attention to these parts", "primary", 5000)
							local chance = math.random(100)
							if chance < 20 then
								-- hint of lab location
							end
						else
							BJCore.Functions.Notify("There's nothing here for you", "error")
						end
					end
				end
			end
		else
			if DoesEntityExist(CokeFieldNPC) then
				DeleteEntity(CokeFieldNPC)
				CokeFieldNPC = nil
			end
		end
		if not nearby then Citizen.Wait(1000); end
		Citizen.Wait(1)
	end
end)

function CreateStartCokePed(pos)
	local modelHash = `a_m_y_stlat_01`
	while not HasModelLoaded(modelHash) do RequestModel(modelHash) Citizen.Wait(10); end
	SpawnedCokeReqPed = CreatePed(4, modelHash, pos, false, true)
	TaskStartScenarioInPlace(SpawnedCokeReqPed, 'WORLD_HUMAN_LEANING', 0, true)
	SetEntityAsMissionEntity(SpawnedCokeReqPed, true, true)
	SetModelAsNoLongerNeeded(modelHash)
	SetBlockingOfNonTemporaryEvents(SpawnedCokeReqPed, true)
	SetEntityInvincible(SpawnedCokeReqPed, true)
	FreezeEntityPosition(CokeFieldNPC, true)
end

local randomDelay = 0 
function GiveDropOff()
	if not HasDropOff then
		HasDropOff = true
		BJCore.Functions.Notify("We'll be in touch")
		randomDelay = math.random(20000, 45000)
		DropOffLocation = Config.DropOffLocations[math.random(#Config.DropOffLocations)]
		SetTimeout(randomDelay, function()
			TriggerServerEvent('phone:server:sendNewMail', {
				sender = "Unknown",
				subject = "Re: Drop Off",
				message = "Interested in handling some heavier gear? <br /> Drop off the following at the location below.<br />"..BuildRequirmentString().."(Press the tick icon to set location)",
				button = {
					enabled = true,
					buttonEvent = "coke:client:SetDropOffMarker",
				}
			})
			randomDelay = 0
			DropOffThread()
		end)
	elseif randomDelay ~= 0 then
		BJCore.Functions.Notify("Wait to be contacted. Get outta here!", "error")
	end
end

function BuildRequirmentString()
	local count = 1
	local req = "<br />"
	for i = 1, #Config.RequiredItemsForAccess, 1 do
		if PlayerData.metadata["cokefield"] <= Config.RequiredItemsForAccess[i].rep then
			for i,data in pairs(Config.RequiredItemsForAccess[i].cost) do
				req = req..BJCore.Shared.Items[data.item].label.." x"..data.amount.."<br />"
			end
			break
		end
	end
	return req
end

local DropOffBlip = nil
AddEventHandler("coke:client:SetDropOffMarker", function()
	SetNewWaypoint(DropOffLocation.x, DropOffLocation.y)
	DropOffBlip = AddBlipForCoord(DropOffLocation["x"],DropOffLocation["y"],DropOffLocation["z"])
	SetBlipSprite(DropOffBlip, 440)
	SetBlipScale(DropOffBlip, 1.0)
	SetBlipColour(DropOffBlip, 46)
	SetBlipAsShortRange(DropOffBlip, false)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Drop Off")
	EndTextCommandSetBlipName(DropOffBlip)
end)

local DropOffBin = nil
local DroppedOff = false
function DropOffThread()
	Citizen.CreateThread(function()
		local LastPressed = 0
		while HasDropOff do
			local dist = #(GetEntityCoords(PlayerPedId()) - DropOffLocation.xyz)
			local nearby = false
			if dist < 100 then
				if DropOffBin == nil and not DoesEntityExist(DropOffBin) then
					DropOffBin = CreateObject(`prop_dumpster_01a`, DropOffLocation.x, DropOffLocation.y, DropOffLocation.z, true, true)
					SetEntityHeading(DropOffBin, DropOffLocation.w)
				end
				if dist < 15 and not DroppedOff then
					nearby = true
					if dist < 2.0 then
						BJCore.Functions.DrawText3D(DropOffLocation.x, DropOffLocation.y, DropOffLocation.z+1.0, "[~r~E~w~] Drop Off")
						if IsControlJustReleased(0, 38) and GetGameTimer() - LastPressed > 1000 then
							LastPressed = GetGameTimer()
							TriggerServerEvent("coke:server:dropOffPrice")
							RequestAnimDict("pickup_object")
							while not HasAnimDictLoaded("pickup_object") do
								Citizen.Wait(7)
							end
							TaskPlayAnim(PlayerPedId(), "pickup_object" ,"pickup_low" ,8.0, -8.0, -1, 1, 0, false, false, false )
							Citizen.Wait(2000)
							ClearPedTasks(PlayerPedId())
						end
					end
				end
			end
			if DroppedOff then
				if dist > 80 then
					TriggerServerEvent("BJCore:RequestEntityDelete", NetworkGetNetworkIdFromEntity(DropOffBin))
					DropOffBin = nil
					DroppedOff = false
					HasDropOff = false
				end
			end
			if not nearby then Citizen.Wait(1000); end
			Citizen.Wait(0)
		end
	end)
end

RegisterNetEvent("coke:client:completeDropOff", function(progress)
	RemoveBlip(DropOffBlip)
	DropOffBlip = nil
	DroppedOff = true
	if progress then
		BJCore.Functions.Notify("Drop off complete. Leave the area and wait to be contacted")
		SetTimeout(math.random(25000, 55000), function()
			TriggerServerEvent('phone:server:sendNewMail', {
				sender = "Unknown",
				subject = "Re: Next Step",
				message = "Make your way to Cayo Perico and bring some plant shears. (Press tick button to set gps location)",
				button = {
					enabled = true,
					buttonEvent = "coke:client:SetCokeFieldMarker",
				}
			})
		end)
	end
end)

local CokeFieldBlip = nil
AddEventHandler("coke:client:SetCokeFieldMarker", function()
	SetNewWaypoint(Config.CokeFieldNPC.x, Config.CokeFieldNPC.y)
	CokeFieldBlip = AddBlipForCoord(Config.CokeFieldNPC["x"],Config.CokeFieldNPC["y"],Config.CokeFieldNPC["z"])
	SetBlipSprite(CokeFieldBlip, 514)
	SetBlipScale(CokeFieldBlip, 1.0)
	SetBlipColour(CokeFieldBlip, 0)
	SetBlipAsShortRange(CokeFieldBlip, false)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Unknown")
	EndTextCommandSetBlipName(CokeFieldBlip)
end)

function CreateCokeFieldPed()
	local modelHash = `S_M_M_FieldWorker_01`
	while not HasModelLoaded(modelHash) do RequestModel(modelHash) Citizen.Wait(10); end
	CokeFieldNPC = CreatePed(4, modelHash, Config.CokeFieldNPC, false, true)
	SetEntityAsMissionEntity(CokeFieldNPC, true, true)
	SetModelAsNoLongerNeeded(modelHash)
	SetBlockingOfNonTemporaryEvents(CokeFieldNPC, true)
	SetEntityInvincible(CokeFieldNPC, true)
	FreezeEntityPosition(CokeFieldNPC, true)
end

RegisterNetEvent("coke:client:updateFieldData", function(data) CokeFieldData = data end)

RegisterNetEvent("BJCore:Client:OnPlayerLoaded")
AddEventHandler("BJCore:Client:OnPlayerLoaded", function()
	if not cokeFieldsCreated then
		CreateCokeFieldPolyZone()
	end
end)

RegisterNetEvent('BJCore:Client:OnPlayerUnload')
AddEventHandler('BJCore:Client:OnPlayerUnload', function()
	DestroyFieldZones()
end)

AddEventHandler('onResourceStop', function(resource)
	if resource ~= GetCurrentResourceName() then return; end
	DestroyFieldZones()
	BJCore.Functions.PersistentNotify("end", "CokeHarvest")
	BJCore.Functions.PersistentNotify("end", "CokeTransform")
	BJCore.Functions.PersistentNotify("end", "CokeWarn")
	TriggerServerEvent("BJCore:RequestEntityDelete", NetworkGetNetworkIdFromEntity(DropOffBin))
	for lab in pairs(Config.CokeLabLocations) do
		for k,v in pairs(barrelObjects[lab]) do
			DeleteEntity(v)
			barrelObjects[lab][k] = nil
		end
	end
end)

RegisterNetEvent("coke:client:getStartPosition", function(pos, data, bData, pData) StartPos = pos AccessData = data BarrelData = bData ProcessLocations = pData ; end)
RegisterNetEvent("coke:client:syncAccessData", function(data) AccessData = data; end)
RegisterNetEvent("coke:client:syncBarrelData", function(data) BarrelData = data; print(BJCore.Common.Dump(BarrelData)) end)
RegisterNetEvent("coke:client:syncProcessLocations", function(data) ProcessLocations = data end)