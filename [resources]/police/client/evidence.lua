StatusList = {
	["fight"] = "Red hands",
	["widepupils"] = "Wide pupils",
	["redeyes"] = "Red eyes",
	["weedsmell"] = "Smells of weed",
	["alcohol"] = "Breath smells like alcohol",
	["gunpowder"] = "Gunpowder in clothing",
	["chemicals"] = "smells of chemical",
	["heavybreath"] = "Breathing heavily",
	["sweat"] = "Sweating a lot",
    ["handbleed"] = "Blood on hands",
	["confused"] = "Confused",
	["alcohol"] = "Smells of alcohol",
	["heavyalcohol"] = "Strong smell of alcohol",
    ["heavybreathing"] = "Heavy breathing",
    ["bodysweat"] = "Body sweat",
    ["clothingsweat"] = "Clothing sweat",
    ["wetclothing"] = "Soaked clothing",
    ["wirecuts"] = "Wire cuts",
    ["scratchhands"] = "Scratch marks on hands",
    ["dazed"] = "Looks dazed",
	["freshbandage"] = "Fresh bandaging",
	["inkedhands"] = "Hands are full of ink"
}

CurrentStatusList = {}
Casings = {}
CasingsNear = {}
CurrentCasing = nil
Blooddrops = {}
BlooddropsNear = {}
CurrentBlooddrop = nil
Fingerprints = {}
FingerprintsNear = {}
CurrentFingerprint = 0

RegisterNetEvent('evidence:client:GetStatus')
AddEventHandler('evidence:client:GetStatus', function(statusId,target)
	local data = false
	if CurrentStatusList and CurrentStatusList ~= nil and CurrentStatusList[statusId] ~= nil then data = CurrentStatusList[statusId]; end
	TriggerServerEvent("police:server:ReturnStatus", data, target)
end)

RegisterNetEvent('evidence:client:SetStatus')
AddEventHandler('evidence:client:SetStatus', function(statusId, time)
	if time > 0 and StatusList[statusId] ~= nil then 
		if (CurrentStatusList == nil or CurrentStatusList[statusId] == nil) or (CurrentStatusList[statusId] ~= nil and CurrentStatusList[statusId].time < 20) then
			CurrentStatusList[statusId] = {text = StatusList[statusId], time = time}
			if statusId ~= "gunpowder" then TriggerEvent("chatMessage", "STATUS", "warning", CurrentStatusList[statusId].text); end
		end
	elseif StatusList[statusId] ~= nil then
		CurrentStatusList[statusId] = nil
	end
	TriggerServerEvent("evidence:server:UpdateStatus", CurrentStatusList)
end)

RegisterNetEvent('evidence:client:AddBlooddrop')
AddEventHandler('evidence:client:AddBlooddrop', function(bloodId, citizenid, bloodtype, coords)
    Blooddrops[bloodId] = {
		citizenid = citizenid,
		bloodtype = bloodtype,
		coords = vector3(coords.x, coords.y, coords.z - 0.9)
	}
end)

RegisterNetEvent("evidence:client:RemoveBlooddrop")
AddEventHandler("evidence:client:RemoveBlooddrop", function(bloodId)
	Blooddrops[bloodId] = nil
	BlooddropsNear[bloodId] = nil
    CurrentBlooddrop = 0
end)

RegisterNetEvent('evidence:client:AddFingerPrint')
AddEventHandler('evidence:client:AddFingerPrint', function(fingerId, fingerprint, coords)
    Fingerprints[fingerId] = {
		fingerprint = fingerprint,
		coords = vector3(coords.x, coords.y, coords.z - 0.9)
	}
end)

RegisterNetEvent("evidence:client:RemoveFingerprint")
AddEventHandler("evidence:client:RemoveFingerprint", function(fingerId)
	Fingerprints[fingerId] = nil
	FingerprintsNear[fingerId] = nil
    CurrentFingerprint = 0
end)

RegisterNetEvent("evidence:client:ClearBlooddropsInArea")
AddEventHandler("evidence:client:ClearBlooddropsInArea", function()
	local pos = GetEntityCoords(PlayerPedId())
	local blooddropList = {}
    exports['mythic_progbar']:Progress({
        name = "clear_blooddrops",
        duration = 5000,
        label = "Clearning blood",
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = false,
            disableCarMovement = false,
            disableMouse = false,
            disableCombat = true,
        }
    }, function(status)
        if not status then
			if Blooddrops ~= nil and next(Blooddrops) ~= nil then 
				for bloodId, v in pairs(Blooddrops) do
					if #(pos - Blooddrops[bloodId].coords) < 10.0 then
						table.insert(blooddropList, bloodId)
					end
				end
				TriggerServerEvent("evidence:server:ClearBlooddrops", blooddropList)
				BJCore.Functions.Notify("Blood cleared :)")
			end
        else
            BJCore.Functions.Notify("Cancelled", "error")                      
        end
    end)
end)

RegisterNetEvent('evidence:client:AddCasing')
AddEventHandler('evidence:client:AddCasing', function(casingId, weapon, coords, serial)
    Casings[casingId] = {
		type = weapon,
		serial = serial ~= nil and serial or "Serial number not visible..",
		coords = vector3(coords.x, coords.y, coords.z - 0.9)
	}
end)

RegisterNetEvent("evidence:client:RemoveCasing")
AddEventHandler("evidence:client:RemoveCasing", function(casingId)
	Casings[casingId] = nil
	CasingsNear[casingId] = nil
    CurrentCasing = 0
end)

RegisterNetEvent("evidence:client:ClearCasingsInArea")
AddEventHandler("evidence:client:ClearCasingsInArea", function()
	local pos = GetEntityCoords(PlayerPedId())
	local casingList = {}
    exports['mythic_progbar']:Progress({
        name = "clear_casings",
        duration = 5000,
        label = "Removing bullet casings",
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = false,
            disableCarMovement = false,
            disableMouse = false,
            disableCombat = true,
        }
    }, function(status)
        if not status then
			if Casings ~= nil and next(Casings) ~= nil then 
				for casingId, v in pairs(Casings) do
					if #(pos - Casings[casingId].coords) < 10.0 then
						table.insert(casingList, casingId)
					end
				end
				TriggerServerEvent("evidence:server:ClearCasings", casingList)
				BJCore.Functions.Notify("Bullet sleeves removed :)")
			end
        else
            BJCore.Functions.Notify("Cancelled", "error")                      
        end
    end)
end)

local shotAmount = 0

--[[
	Decrease time of every status every 10 seconds
]]
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10000)
		if isLoggedIn then
			if CurrentStatusList ~= nil and next(CurrentStatusList) ~= nil then
				for k, v in pairs(CurrentStatusList) do
					if CurrentStatusList[k].time > 0 then
						CurrentStatusList[k].time = CurrentStatusList[k].time - 10
					else
						CurrentStatusList[k].time = 0
					end
				end
				TriggerServerEvent("evidence:server:UpdateStatus", CurrentStatusList)
			end
			if shotAmount > 0 then
				shotAmount = 0
			end
		end
	end
end)

--[[
	Gunpowder Status when shooting
]]
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		--if IsPedShooting(PlayerPedId()) or IsPedDoingDriveby(PlayerPedId()) then
		if IsPedShooting(PlayerPedId()) then
			local weapon = GetSelectedPedWeapon(PlayerPedId())
			if weapon ~= GetHashKey("WEAPON_UNARMED") and weapon ~= GetHashKey("WEAPON_SNOWBALL") and weapon ~= GetHashKey("WEAPON_STUNGUN") and weapon ~= GetHashKey("WEAPON_PETROLCAN") and weapon ~= GetHashKey("WEAPON_FIREEXTINGUISHER") then
				shotAmount = shotAmount + 1
				--if shotAmount > 5 and (CurrentStatusList == nil or CurrentStatusList["gunpowder"] == nil) then
				if (CurrentStatusList == nil or CurrentStatusList["gunpowder"] == nil) then
					--if math.random(1, 10) <= 7 then
						TriggerEvent("evidence:client:SetStatus", "gunpowder", 2700)
					--end
				end
				DropBulletCasing(weapon)
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do 
		Citizen.Wait(1)
		if PlayerJob.name == "police" and onDuty then
			if IsPlayerFreeAiming(PlayerId()) and GetSelectedPedWeapon(PlayerPedId()) == GetHashKey("WEAPON_FLASHLIGHT") then		
				if CurrentCasing ~= nil and CurrentCasing ~= 0 then 			
					local pos = GetEntityCoords(PlayerPedId())
					if #(pos - Casings[CurrentCasing].coords) < 1.5 then
						BJCore.Functions.DrawText3D(Casings[CurrentCasing].coords.x, Casings[CurrentCasing].coords.y, Casings[CurrentCasing].coords.z, "[~g~G~w~] Casing ~b~#"..Casings[CurrentCasing].type)
						if IsControlJustReleased(0, Keys["G"]) then
							BJCore.Functions.TriggerServerCallback('police:server:hasEmptyEvidenceBag', function(hasEnough)
								if hasEnough then
									TriggerEvent('animations:client:EmoteCommandStart', {"kneel3"})
								    exports['mythic_progbar']:Progress({
								        name = "collect_evidence",
								        duration = math.random(5000,15000),
								        label = "Collecting evidence",
								        useWhileDead = false,
								        canCancel = true,
								        controlDisables = {
								            disableMovement = true,
								            disableCarMovement = true,
								            disableMouse = false,
								            disableCombat = true,
								        },
								        animation = {
								            animDict = "amb@world_human_bum_wash@male@low@idle_a",
								            anim = "idle_a",
								            flags = 14,
								        },
								    }, function(status)
								        if not status then
								        	TriggerEvent('animations:client:EmoteCommandStart', {"c"})
											local s1, s2 = Citizen.InvokeNative(0x2EB41072B4C1E4C0, Casings[CurrentCasing].coords.x, Casings[CurrentCasing].coords.y, Casings[CurrentCasing].coords.z, Citizen.PointerValueInt(), Citizen.PointerValueInt())
											local street1 = GetStreetNameFromHashKey(s1)
											local street2 = GetStreetNameFromHashKey(s2)
											local streetLabel = street1
											if street2 ~= nil then
												streetLabel = streetLabel .. " | " .. street2
											end
											local info = {
												label = "Bullet Casing",
												type = "casing",
												street = streetLabel:gsub("%'", ""),
												ammolabel = Config.AmmoLabels[BJCore.Shared.Weapons[Casings[CurrentCasing].type]["ammotype"]],
												ammotype = Casings[CurrentCasing].type,
												serial = Casings[CurrentCasing].serial,
											}
											TriggerServerEvent("evidence:server:AddCasingToInventory", CurrentCasing, info)
								        else
								            BJCore.Functions.Notify("Cancelled", "error")
								        end
								    end)
								end
							end)
						end
					end
				end

				if CurrentBlooddrop ~= nil and CurrentBlooddrop ~= 0 then 
					local pos = GetEntityCoords(PlayerPedId())
					if #(pos - Blooddrops[CurrentBlooddrop].coords) < 1.5 then
						BJCore.Functions.DrawText3D(Blooddrops[CurrentBlooddrop].coords.x, Blooddrops[CurrentBlooddrop].coords.y, Blooddrops[CurrentBlooddrop].coords.z, "[~g~G~w~] Blood ~b~#"..DnaHash(Blooddrops[CurrentBlooddrop].citizenid))
						if IsControlJustReleased(0, Keys["G"]) then
							BJCore.Functions.TriggerServerCallback('police:server:hasEmptyEvidenceBag', function(hasEnough)
								if hasEnough then
									TriggerEvent('animations:client:EmoteCommandStart', {"kneel3"})
								    exports['mythic_progbar']:Progress({
								        name = "collect_evidence",
								        duration = math.random(5000,15000),
								        label = "Collecting evidence",
								        useWhileDead = false,
								        canCancel = true,
								        controlDisables = {
								            disableMovement = true,
								            disableCarMovement = true,
								            disableMouse = false,
								            disableCombat = true,
								        },
								        animation = {
								            animDict = "amb@world_human_bum_wash@male@low@idle_a",
								            anim = "idle_a",
								            flags = 14,
								        },
								    }, function(status)
								        if not status then
								        	TriggerEvent('animations:client:EmoteCommandStart', {"c"})
											local s1, s2 = Citizen.InvokeNative(0x2EB41072B4C1E4C0, Blooddrops[CurrentBlooddrop].coords.x, Blooddrops[CurrentBlooddrop].coords.y, Blooddrops[CurrentBlooddrop].coords.z, Citizen.PointerValueInt(), Citizen.PointerValueInt())
											local street1 = GetStreetNameFromHashKey(s1)
											local street2 = GetStreetNameFromHashKey(s2)
											local streetLabel = street1
											if street2 ~= nil then
												streetLabel = streetLabel .. " | " .. street2
											end
											local info = {
												label = "Blood sample",
												type = "blood",
												street = streetLabel:gsub("%'", ""),
												dnalabel = DnaHash(Blooddrops[CurrentBlooddrop].citizenid),
												bloodtype = Blooddrops[CurrentBlooddrop].bloodtype,
											}
											TriggerServerEvent("evidence:server:AddBlooddropToInventory", CurrentBlooddrop, info)
								        else
								            BJCore.Functions.Notify("Cancelled", "error")
								        end
								    end)
								end
							end)
						end
					end
				end

				if CurrentFingerprint ~= nil and CurrentFingerprint ~= 0 then 
					local pos = GetEntityCoords(PlayerPedId())
					if #(pos - Fingerprints[CurrentFingerprint].coords) < 1.5 then
						BJCore.Functions.DrawText3D(Fingerprints[CurrentFingerprint].coords.x, Fingerprints[CurrentFingerprint].coords.y, Fingerprints[CurrentFingerprint].coords.z, "[~g~G~w~] Fingerprint ")
						if IsControlJustReleased(0, Keys["G"]) then
							BJCore.Functions.TriggerServerCallback('police:server:hasEmptyEvidenceBag', function(hasEnough)
								if hasEnough then
									TriggerEvent('animations:client:EmoteCommandStart', {"kneel3"})
								    exports['mythic_progbar']:Progress({
								        name = "collect_evidence",
								        duration = math.random(5000,15000),
								        label = "Collecting evidence",
								        useWhileDead = false,
								        canCancel = true,
								        controlDisables = {
								            disableMovement = true,
								            disableCarMovement = true,
								            disableMouse = false,
								            disableCombat = true,
								        },
								        animation = {
								            animDict = "amb@world_human_bum_wash@male@low@idle_a",
								            anim = "idle_a",
								            flags = 14,
								        },
								    }, function(status)
								        if not status then
								        	TriggerEvent('animations:client:EmoteCommandStart', {"c"})
											local s1, s2 = Citizen.InvokeNative(0x2EB41072B4C1E4C0, Fingerprints[CurrentFingerprint].coords.x, Fingerprints[CurrentFingerprint].coords.y, Fingerprints[CurrentFingerprint].coords.z, Citizen.PointerValueInt(), Citizen.PointerValueInt())
											local street1 = GetStreetNameFromHashKey(s1)
											local street2 = GetStreetNameFromHashKey(s2)
											local streetLabel = street1
											if street2 ~= nil then
												streetLabel = streetLabel .. " | " .. street2
											end
											local info = {
												label = "Fingerprint",
												type = "fingerprint",
												street = streetLabel:gsub("%'", ""),
												fingerprint = Fingerprints[CurrentFingerprint].fingerprint,
											}
											TriggerServerEvent("evidence:server:AddFingerprintToInventory", CurrentFingerprint, info)
								        else
								            BJCore.Functions.Notify("Cancelled", "error")
								        end
								    end)
								end
							end)
						end
					end
				end
			else
				Citizen.Wait(1000)
			end
		else
			Citizen.Wait(5000)
		end
	end
end)

--[[
	Bullet Casings stuff
]]
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)
		if isLoggedIn then 
			if PlayerJob.name == "police" and onDuty then
				if IsPlayerFreeAiming(PlayerId()) and GetSelectedPedWeapon(PlayerPedId()) == GetHashKey("WEAPON_FLASHLIGHT") then
					if next(Casings) ~= nil then
						local pos = GetEntityCoords(PlayerPedId(), true)
						for k, v in pairs(Casings) do
							if #(pos - v.coords) < 12.5 then
								CasingsNear[k] = v
								if #(pos - v.coords) < 1.5 then
									CurrentCasing = k
								end
							else
								CasingsNear[k] = nil
							end
						end
					else
						CasingsNear = {}
					end
					if next(Blooddrops) ~= nil then
						local pos = GetEntityCoords(PlayerPedId(), true)
						for k, v in pairs(Blooddrops) do
							if #(pos - v.coords) < 12.5 then
								BlooddropsNear[k] = v
								if #(pos - v.coords) < 1.5 then
									CurrentBlooddrop = k
								end
							else
								BlooddropsNear[k] = nil
							end
						end
					else
						BlooddropsNear = {}
					end
					if next(Fingerprints) ~= nil then
						local pos = GetEntityCoords(PlayerPedId(), true)
						for k, v in pairs(Fingerprints) do
							if #(pos - v.coords) < 12.5 then
								FingerprintsNear[k] = v
								if #(pos - v.coords) < 1.5 then
									CurrentFingerprint = k
								end
							else
								FingerprintsNear[k] = nil
							end
						end
					else
						FingerprintsNear = {}
					end
				else
					Citizen.Wait(1000)
				end
			else
				Citizen.Wait(5000)
			end
		end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
		if isLoggedIn and BlooddropsNear ~= nil then
			if IsPlayerFreeAiming(PlayerId()) and GetSelectedPedWeapon(PlayerPedId()) == GetHashKey("WEAPON_FLASHLIGHT") then
				if PlayerJob.name == "police" and onDuty then
					for k, v in pairs(BlooddropsNear) do
						if v ~= nil then
							DrawMarker(27, v.coords.x, v.coords.y, v.coords.z - 0.05, 0.0, 0.0, 0.0, 180.0, 0.0, 0.0, 0.11, 0.11, 0.3, 250, 0, 50, 255, false, true, 2, false, false, false, false)
						end
					end
				end
			else
				Citizen.Wait(1000)
			end
		else
			Citizen.Wait(1000)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
		if isLoggedIn and CasingsNear ~= nil then
			if IsPlayerFreeAiming(PlayerId()) and GetSelectedPedWeapon(PlayerPedId()) == GetHashKey("WEAPON_FLASHLIGHT") then
				if PlayerJob.name == "police" and onDuty then
					for k, v in pairs(CasingsNear) do
						if v ~= nil then
							DrawMarker(27, v.coords.x, v.coords.y, v.coords.z - 0.05, 0.0, 0.0, 0.0, 180.0, 0.0, 0.0, 0.11, 0.11, 0.3, 50, 0, 250, 255, false, true, 2, false, false, false, false)
						end
					end
				end
			else
				Citizen.Wait(1000)
			end
		else
			Citizen.Wait(1000)
        end
    end
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
		if isLoggedIn and FingerprintsNear ~= nil then
			if IsPlayerFreeAiming(PlayerId()) and GetSelectedPedWeapon(PlayerPedId()) == GetHashKey("WEAPON_FLASHLIGHT") then
				if PlayerJob.name == "police" and onDuty then
					for k, v in pairs(FingerprintsNear) do
						if v ~= nil then
							DrawMarker(27, v.coords.x, v.coords.y, v.coords.z - 0.05, 0.0, 0.0, 0.0, 180.0, 0.0, 0.0, 0.11, 0.11, 0.3, 23, 173, 12, 255, false, true, 2, false, false, false, false)
						end
					end
				end
			else
				Citizen.Wait(1000)
			end
		else
			Citizen.Wait(1000)
        end
    end
end)

local lastTarget
local target
local targetLastHealth
local bodySweat = 0
local sweatTriggered = false
Citizen.CreateThread(function()
    while true do
        Wait(300)

        if IsPedInAnyVehicle(PlayerPedId(), false) then
        	local vehicle = GetVehiclePedIsUsing(PlayerPedId())
        	local bicycle = IsThisModelABicycle(GetEntityModel(vehicle))
        	local speed = GetEntitySpeed(vehicle)
        	if bicycle and speed > 0 then
        		sweatTriggered = true
        		if bodySweat < 180000 then
        			bodySweat = bodySweat + (150 + math.ceil(speed * 40))
        		else
        			bodySweat = bodySweat + (150 + math.ceil(speed * 11))
        		end

        		if bodySweat > 300000 then
	        		bodySweat = 300000
	        	end
        	end
        end        

        if IsPedInMeleeCombat(PlayerPedId()) then
        	bodySweat = bodySweat + 4000
        	sweatTriggered = true
        	target = GetMeleeTargetForPed(PlayerPedId())
        	if target == lastTarget or lastTarget == nil then
        		if IsPedAPlayer(target) then
        			lastTarget = target
        		end
        	else
        		if IsPedAPlayer(target) then
	        		targetLastHealth = GetEntityHealth(target)
	        		lastTarget = target
	        	end
        	end
        end

        if IsPedSwimming(PlayerPedId()) then
        	local speed = GetEntitySpeed(PlayerPedId())
        	if speed > 0 then
        		sweatTriggered = true
        		TriggerEvent("evidence:client:SetStatus", "bodysweat", 0)
        		TriggerEvent("evidence:client:SetStatus", "clothingsweat", 0)
        		TriggerEvent("evidence:client:SetStatus", "wetclothing", 600)
        		if bodySweat < 180000 then
        			bodySweat = bodySweat + (150 + math.ceil(speed * 40))
        		else
        			bodySweat = bodySweat + (150 + math.ceil(speed * 11))
        		end
        		
        		if bodySweat > 210000 then
        			TriggerEvent("evidence:client:SetStatus", "heavybreathing", 600)
	        		bodySweat = 210000
	        	end
        	end
        end

        if IsPedRunning(PlayerPedId()) then
        	bodySweat = bodySweat + 3000
        	if bodySweat > 800000 then
        		bodySweat = 800000
        	end
        elseif bodySweat > 0.0 then
        	if not sweatTriggered then
        		bodySweat = 0.0
        	end
        	if bodySweat < 100000 then
        		bodySweat = bodySweat - 1500
        	end
        	bodySweat = bodySweat - 100
        	if bodySweat == 0.0 then
        		sweatTriggered = false
        	end
        end
        if bodySweat > 200000 and not IsPedSwimming(PlayerPedId()) then
        	TriggerEvent("evidence:client:SetStatus", "heavybreathing", 300)
        end  

        if bodySweat > 300000 and not IsPedSwimming(PlayerPedId()) and CurrentStatusList['wirecuts'] and CurrentStatusList['wirecuts'].time < 50 then
        	TriggerEvent("evidence:client:SetStatus", "bodysweat", 450)
        end 
        if bodySweat > 800000 and not IsPedSwimming(PlayerPedId()) and CurrentStatusList['wirecuts'] and CurrentStatusList['wirecuts'].time < 50 then
        	sweatTriggered = true
        	TriggerEvent("evidence:client:SetStatus", "clothingsweat", 600)
        end
    end
end)

-- local SilentWeapons = {
-- 	"WEAPON_PETROLCAN",
-- 	"WEAPON_STUNGUN",
-- 	"WEAPON_FIREEXTINGUISHER",
-- 	"WEAPON_UNARMED",	
-- }
-- Citizen.CreateThread( function()
--     local currentWeapon = GetSelectedPedWeapon(PlayerPedId())
-- 	local isArmed = false
-- 	local timeCheck = 0
--     while true do
--         Citizen.Wait(50)
--         if not isArmed then
--             if IsPedArmed(PlayerPedId(), 7) and not IsPedArmed(PlayerPedId(), 1) then
--                 currentWeapon = GetSelectedPedWeapon(PlayerPedId())
--                 isArmed = true
--                 timeCheck = 7
--             end
-- 		end
-- 		if isArmed then
-- 			if PlayerJob.name ~= "police" then
-- 				if IsPedShooting(PlayerPedId()) and not IsSilentWeapon(currentWeapon) and IsPedNearby() then
-- 					local coords = GetEntityCoords(PlayerPedId())
-- 					local automatic = false
-- 					if BJCore.Shared.Weapons[currentWeapon]["ammotype"] ~= "AMMO_PISTOL" then
-- 						automatic = true
-- 					end
-- 					local s1, s2 = Citizen.InvokeNative(0x2EB41072B4C1E4C0, coords.x, coords.y, coords.z, Citizen.PointerValueInt(), Citizen.PointerValueInt())
-- 					local streetLabel = GetStreetNameFromHashKey(s1)
-- 					local street2 = GetStreetNameFromHashKey(s2)
-- 					if street2 ~= nil and street2 ~= "" then 
-- 						streetLabel = streetLabel .. " " .. street2
-- 					end
-- 					if IsPedInAnyVehicle(PlayerPedId(), true) then
-- 						local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
-- 						local vehicleInfo = {
-- 							plate = GetVehicleNumberPlateText(vehicle),
-- 							name = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
-- 						}
-- 						TriggerServerEvent("police:server:GunshotAlert", streetLabel, automatic, true, coords, vehicleInfo)
-- 					else
-- 						TriggerServerEvent("police:server:GunshotAlert", streetLabel, automatic, false, coords)
-- 					end
-- 					Citizen.Wait(15000)
-- 				end

-- 				if timeCheck == 0 then
-- 					isArmed = false
-- 				else
-- 					timeCheck = timeCheck - 1
-- 				end
-- 			else
-- 				Citizen.Wait(5000)
-- 			end
-- 		else
-- 			Citizen.Wait(2500)
--         end
--     end
-- end)

function IsPedNearby()
	local retval = false
	local PlayerPeds = {}
    for _, player in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(player)
        table.insert(PlayerPeds, ped)
    end
    local player = PlayerPedId()
    local coords = GetEntityCoords(player)
	local closestPed, closestDistance = BJCore.Functions.GetClosestPed(coords, PlayerPeds)
	if not IsEntityDead(closestPed) and closestDistance < 100.0 then
		retval = true
	end
	return retval
end

function IsSilentWeapon(weapon)
	local retval = false
	for k, v in pairs(SilentWeapons) do
		if GetHashKey(v) == weapon then 
			retval = true
		end
	end
	if not retval then 
		BJCore.Functions.TriggerServerCallback('police:IsSilencedWeapon', function(result)
			retval = result
			return result
		end, weapon)
		Citizen.Wait(100)
		return retval
	else
		return retval
	end
end

function DropBulletCasing(weapon)
	local randX = math.random() + math.random(-1, 1)
	local randY = math.random() + math.random(-1, 1)
	local coords = nil
	if IsPedInAnyVehicle(PlayerPedId()) then
		coords = GetOffsetFromEntityInWorldCoords(GetVehiclePedIsIn(PlayerPedId(), false), randX, randY, 0.85)
	else
		coords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), randX, randY, 0)
	end
	TriggerServerEvent("evidence:server:CreateCasing", weapon, coords)
	Citizen.Wait(300)
end

function DnaHash(s)
    local h = string.gsub(s, ".", function(c)
		return string.format("%02x", string.byte(c))
	end)
    return h
end