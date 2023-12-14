local PlayerData = {}
local whitelistedWeapons = {}
local playerPed = PlayerPedId()
local playerPosition = nil
local streetHash1 = 0
local streetHash2 = 0
local streetName1 = ''
local streetName2 = ''
local vehicle = 0
local isInPoliceVehicle = false
local playerSex = ''
local zoneName = ''
local showGunshots = true

Citizen.CreateThread(function()
    while not BJCore do Citizen.Wait(1000); end
    while not BJCore.Functions.IsPlayerLoaded() do Citizen.Wait(1000); end
    PlayerData = BJCore.Functions.GetPlayerData()
    init()
    initWhitelistedWeapons()

    Citizen.CreateThread(getPlayerSexLoop)
    Citizen.CreateThread(gatherDataLoop)
    --Citizen.CreateThread(initDecorLoop)
    --Citizen.CreateThread(decorLoop)

    Citizen.CreateThread(carJackingLoop)
    --Citizen.CreateThread(meleeCombatLoop)
    Citizen.CreateThread(shootingLoop)
    Citizen.CreateThread(firearmLoop)
    --Citizen.CreateThread(explosionLoop)

    Citizen.CreateThread(rangesLoop)
end)

function init()
    while not BJCore do Wait(1000); end
    while not BJCore.Functions.IsPlayerLoaded() do Wait(1000); end
end

function initWhitelistedWeapons()
    for _, weaponModel in pairs(Config.WeaponWhitelist) do
        whitelistedWeapons[GetHashKey(weaponModel)] = true
    end
end

function getPlayerSexLoop()
    while true do
        if IsPedMale(PlayerPedId()) then
            playerSex = "male"
        else
            playerSex = "female"
        end
        Wait(30000)
    end
end

function gatherDataLoop()
    while true do
        playerPed = PlayerPedId()
        playerPosition = GetEntityCoords(playerPed,  true)

        local IPL = GetInteriorAtCoords(playerPosition.x, playerPosition.y, playerPosition.z)

        if Config.IplUpdatedLocations[IPL] ~= nil then
			if Config.IplUpdatedLocations[IPL] == true then
				playerPosition = true

			else
				playerPosition = Config.IplUpdatedLocations[IPL]
			end
        end

		if playerPosition ~= true then
			streetHash1, streetHash2 = Citizen.InvokeNative(0x2EB41072B4C1E4C0, playerPosition.x, playerPosition.y, playerPosition.z, Citizen.PointerValueInt(), Citizen.PointerValueInt())
			streetName1 = GetStreetNameFromHashKey(streetHash1)
			streetName2 = GetStreetNameFromHashKey(streetHash2)

			vehicle = GetVehiclePedIsIn(playerPed, false)
			if vehicle == nil or vehicle == 0 then
				vehicle = GetVehiclePedIsTryingToEnter(playerPed)
			end
			isInPoliceVehicle = IsPedInAnyPoliceVehicle(playerPed)

			local zoneNameId = GetNameOfZone(playerPosition.x, playerPosition.y, playerPosition.y)
			zoneName = ZoneNames[string.upper(zoneNameId)]
        end

        Wait(250)
    end
end

function initDecorLoop()
    while true do
        if NetworkIsSessionStarted() then
            DecorRegister('IsOutlaw',  3)
            DecorSetInt(playerPed, 'IsOutlaw', 1)
            return
        end

        Wait(0)
    end
end

function decorLoop()
    while true do
        if DecorGetInt(playerPed, 'IsOutlaw') == 2 then
            Wait(Config.Timer * 60000)
            DecorSetInt(playerPed, 'IsOutlaw', 1)
        end

        Wait(0)
    end
end

function carJackingLoop()
    while true do
        Wait(10)

        if not isPlayerPoliceOfficer() then

            if IsPedTryingToEnterALockedVehicle(playerPed) or IsPedJacking(playerPed) then

                local plate = GetVehicleNumberPlateText(vehicle)
                local currVeh = vehicle
                Wait(250)

                --DecorSetInt(playerPed, 'IsOutlaw', 2)
                if playerPosition ~= true and getRandomNpc(15.0,false) then
                    local valid = exports["vehiclelock"]:hasKey(vehicle)
                    if not valid then
                        Wait(math.random(1000, 5000))
                        TriggerServerEvent('thiefInProgressPos', playerPosition.x, playerPosition.y, playerPosition.z)

                        local vehicleName = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(currVeh)))

                        if streetHash2 == 0 and isInPoliceVehicle then
                            if vehicleName == "NULL" then
                                triggerAlert('POLICE vehicle jacking in progress by a '..playerSex, playerPosition, "carjack")
                            else
                                triggerAlert('POLICE vehicle jacking in progress ('..vehicleName..') by a '..playerSex, playerPosition, "carjack")
                            end
                        elseif streetHash2 == 0 then
                            if vehicleName == "NULL" then
                                triggerAlert('Vehicle jacking in progress by a '..playerSex, playerPosition, "carjack")
                            else
                                triggerAlert('Vehicle jacking in progress ('..vehicleName..') by a '..playerSex, playerPosition, "carjack")
                            end
                        elseif isInPoliceVehicle then
                            if vehicleName == "NULL" then
                                triggerAlert('POLICE vehicle jacking in progress by a '..playerSex, playerPosition, "carjack")
                            else
                                triggerAlert('POLICE vehicle jacking in progress ('..vehicleName..') by a '..playerSex, playerPosition, "carjack")
                            end
                        else
                            if vehicleName == "NULL" then
                                triggerAlert('Vehicle jacking in progress by a '..playerSex, playerPosition, "carjack")
                            else
                                triggerAlert('Vehicle jacking in progress ('..vehicleName..' ) by a '..playerSex, playerPosition, "carjack")
                            end
                        end
                    end
                end
                Wait(2750)
            end
        else
            Wait(5000)
        end
    end
end

local inMeleeCombat = false

function meleeCombatLoop()
    while true do
        Wait(500)

        if IsPedInMeleeCombat(playerPed) and not inMeleeCombat then
            inMeleeCombat = true
            --DecorSetInt(playerPed, 'IsOutlaw', 2)

			local x,currWeapon = GetCurrentPedWeapon(PlayerPedId())
            if currWeapon ~= -1569615261 and (not isPlayerPoliceOfficer() or Config.ShowCopsMisbehave) and playerPosition ~= true and getRandomNpc(15.0,false) then
                TriggerServerEvent('meleeInProgressPos', playerPosition.x, playerPosition.y, playerPosition.z)

                if streetHash2 == 0 then
                    triggerAlert("A "..playerSex..'started a fight', playerPosition)
                else
                    triggerAlert("A "..playerSex..' started a fight', playerPosition)
                end

                Wait(15000)
            end
        else
            Wait(500)
            inMeleeCombat = false
        end
    end
end

function shootingLoop()
    while true do
        Wait(10)
        if not isPlayerPoliceOfficer() and showGunshots then
            local wHash = GetSelectedPedWeapon(playerPed)
            if playerPosition ~= true and IsPedShooting(playerPed) and GetAmmoInPedWeapon(playerPed, wHash) >= 1 and not whitelistedWeapons[wHash] then
                --DecorSetInt(playerPed, 'IsOutlaw', 2)

                --if not isPlayerPoliceOfficer() or Config.ShowCopsMisbehave then
                    local hasSuppressor = false
                    -- for k,v in ipairs(PlayerData.loadout) do
                    -- 	local weaponHash = GetHashKey(v.name)
                    -- 	if weaponHash == wHash then
                    -- 		for k2,v2 in ipairs(v.components) do
                    -- 			if ESX.GetWeaponComponent(v.name, v2).name == 'suppressor' then
                    -- 				hasSuppressor = true
                    -- 				break
                    -- 			end
                    -- 		end
                    -- 		break
                    -- 	end
                    -- end
                    local chance = math.random(1, 5)
                    if not hasSuppressor or (hasSuppressor and chance == 1) then
                        TriggerServerEvent('gunshotInProgressPos', playerPosition.x, playerPosition.y, playerPosition.z)
                        if IsPedInAnyVehicle(playerPed, true) then
                            if streetHash2 == 0 then
                                triggerAlert("A "..playerSex..' fired gunshots from vehicle', playerPosition, 'shotsfired')
                            else
                                triggerAlert("A "..playerSex..' fired gunshots from vehicle', playerPosition, 'shotsfired')
                            end
                        else
                            if streetHash2 == 0 then
                                triggerAlert("A "..playerSex..' fired gunshots', playerPosition, 'shotsfired')
                            else
                                triggerAlert("A "..playerSex..' fired gunshots', playerPosition, 'shotsfired')
                            end
                        end

                        Wait(15000)
                    end
                --end
            end
        else
            Wait(1000)
        end
    end
end

local firearmSpotted = false
function firearmLoop()
    while true do
        Wait(10)
        if not isPlayerPoliceOfficer() and showGunshots then
            local wHash = GetSelectedPedWeapon(playerPed)
            if not whitelistedWeapons[wHash] and GetWeaponDamageType(wHash) == 1 and IsPlayerFreeAiming(PlayerId()) and not firearmSpotted then
                firearmSpotted = true
                --DecorSetInt(playerPed, 'IsOutlaw', 2)

                Wait(3000)

                if IsPlayerFreeAiming(PlayerId()) and playerPosition ~= true and getRandomNpc(10.0,false) then
                    TriggerServerEvent('firearmInProgressPos', playerPosition.x, playerPosition.y, playerPosition.z)

                    if streetHash2 == 0 then
                        triggerAlert("A "..playerSex..' seen with firearm', playerPosition, 'firearm')
                    else
                        triggerAlert("A "..playerSex..' seen with firearm', playerPosition, 'firearm')
                    end

                    Wait(60000)
                else
                    firearmSpotted = false
                end
            else
                firearmSpotted = false
            end
        else
            Wait(1000)
        end
    end
end

local gasStations = {
    vector3(49.4187, 2778.793, 58.043),
    vector3(263.894, 2606.463, 44.983),
    vector3(1039.958, 2671.134, 39.550),
    vector3(1207.260, 2660.175, 37.899),
    vector3(2539.685, 2594.192, 37.944),
    vector3(2679.858, 3263.946, 55.240),
    vector3(2005.055, 3773.887, 32.403),
    vector3(1687.156, 4929.392, 42.078),
    vector3(1701.314, 6416.028, 32.763),
    vector3(179.857, 6602.839, 31.868),
    vector3(-94.4619, 6419.594, 31.489),
    vector3(-2554.996, 2334.40, 33.078),
    vector3(-1800.375, 803.661, 138.651),
    vector3(-1437.622, -276.747, 46.207),
    vector3(-2096.243, -320.286, 13.168),
    vector3(-724.619, -935.1631, 19.213),
    vector3(-526.019, -1211.003, 18.184),
    vector3(-70.2148, -1761.792, 29.534),
    vector3(265.648, -1261.309, 29.292),
    vector3(819.653, -1028.846, 26.403),
    vector3(1208.951, -1402.567,35.224),
    vector3(1181.381, -330.847, 69.316),
    vector3(620.843, 269.100, 103.089),
    vector3(2581.321, 362.039, 108.468),
    vector3(176.631, -1562.025, 29.263),
    vector3(176.631, -1562.025, 29.263),
    vector3(-319.292, -1471.715, 30.549),
    vector3(1784.324, 3330.55, 41.253)
}

local explosionSpotted = false
function explosionLoop()
    while true do
        Wait(0)
        local dstcheck = 1000.0
        for k,v in pairs(gasStations) do
            local dist = #(v - playerPosition)
            if dist < 20 and dist < dstcheck then
                dstcheck = dist
                if IsExplosionInSphere(9,v,60.0) then
                    explosionSpotted = true

                    TriggerServerEvent('explosionInProgressPos', v)

                    if streetHash2 == 0 then
                        triggerAlert('Explosion reported', v)
                    else
                        triggerAlert('Explosion reported', v)
                    end
                    Wait(9000)
                    explosionSpotted = false
                end
            end
        end
        if dstcheck > 60 then
            Citizen.Wait(math.ceil(dstcheck*5))
        end
    end
end

RegisterNetEvent('thiefPlace')
AddEventHandler('thiefPlace', function(tx, ty, tz)
    if Config.CarJackingAlert and isPlayerPoliceOfficerOrInVehicle() then
        showExpiringBlip(tx, ty, tz, 10, 1, Config.BlipJackingTime)
    end
end)

RegisterNetEvent('gunshotPlace')
AddEventHandler('gunshotPlace', function(gx, gy, gz)
    if Config.GunshotAlert and isPlayerPoliceOfficerOrInVehicle() then
        showExpiringBlip(gx, gy, gz, 10, 1, Config.BlipGunTime)
    end
end)

RegisterNetEvent('meleePlace')
AddEventHandler('meleePlace', function(mx, my, mz)
    if Config.MeleeAlert and isPlayerPoliceOfficerOrInVehicle() then
        showExpiringBlip(mx, my, mz, 270, 17, Config.BlipMeleeTime)
    end
end)

RegisterNetEvent('firearmPlace')
AddEventHandler('firearmPlace', function(fx, fy, fz)
    if Config.FirearmAlert and isPlayerPoliceOfficerOrInVehicle() then
        showExpiringBlip(fx, fy, fz, 10, 1, Config.FirearmTime)
    end
end)

RegisterNetEvent('explosionPlace')
AddEventHandler('explosionPlace', function(pos)
    if Config.ExplosionAlert and isPlayerPoliceOfficerOrInVehicle() then
        local xx, xy, xz = table.unpack(pos)
        showExpiringBlip(xx, xy, xz, 436, 47, Config.ExplosionTime)
    end
end)

function isPlayerPoliceOfficerOrInVehicle()
    return isPlayerPoliceOfficer() or (Config.ShowNotificationsToAnyPlayerInPoliceVehicle and isInPoliceVehicle)
end

function isPlayerPoliceOfficer()
    if Config.ShowCopsMisbehave then
        return false
    end
    return PlayerData.job ~= nil and PlayerData.job.name == 'police'
end

function showExpiringBlip(x, y, z, sprite, color, decayTime)
    local transparency = 250
    local blip = AddBlipForCoord(x, y, z)
    SetBlipSprite(blip, sprite)
    SetBlipColour(blip, color)
    SetBlipAlpha(blip, transparency)
    SetBlipAsShortRange(blip, 1)

    while transparency > 0 do
        Wait(decayTime * 4)
        transparency = transparency - 1
        SetBlipAlpha(blip, transparency)
    end

    RemoveBlip(blip)
end

function triggerAlert(message, position, type)
	TriggerServerEvent('Trackables:Notify', message, position, 'police', type)
end

function getRandomNpc(reqDist,isGunshot)
    local plyPed = PlayerPedId()
    local plyPos = GetEntityCoords(plyPed)
    local handle, ped = FindFirstPed()
    local success
    local retPed = nil
    local distanceFrom
    repeat
        local pedPos = GetEntityCoords(ped)
        local dist = #(plyPos - pedPos)
        if canPedBeUsed(ped,isGunshot) and dist < reqDist and (distanceFrom == nil or dist < distanceFrom) then
            distanceFrom = dist
            retPed = ped
        end
        success, ped = FindNextPed(handle)
    until not success

    EndFindPed(handle)

    return retPed
end

exports('getRandomNpc',getRandomNpc)

function canPedBeUsed(ped,isGunshot)
    if ped == nil then
        return false
    end

    if ped == PlayerPedId() then
        return false
    end

    if GetEntityHealth(ped) < GetEntityMaxHealth(ped) then
      return false
    end

    if GetHashKey("mp_f_deadhooker") == GetEntityModel(ped) then
      return false
    end

    if GetHashKey("mp_m_shopkeep_01") == GetEntityModel(ped) then
      return false
    end

    if GetHashKey("s_m_m_security_01") == GetEntityModel(ped) then
      return false
    end

    if -520477356 == GetEntityModel(ped) then
      return false
    end

    if GetHashKey("csb_jackhowitzer") == GetEntityModel(ped) then
        return false
    end

    if not HasEntityClearLosToEntity(PlayerPedId(), ped, 17) and not isGunshot then
      return false
    end

    if not DoesEntityExist(ped) then
        return false
    end

    if IsPedAPlayer(ped) then
        return false
    end

    if IsPedFatallyInjured(ped) then
        return false
    end

    if IsPedArmed(ped, 7) then
        return false
    end

    if IsPedInMeleeCombat(ped) then
        return false
    end

    if IsPedShooting(ped) then
        return false
    end

    if IsPedDucking(ped) then
        return false
    end

    if IsPedBeingJacked(ped) then
        return false
    end

    if IsPedSwimming(ped) then
        return false
    end

    if IsPedJumpingOutOfVehicle(ped) or IsPedBeingJacked(ped) then
        return false
    end

    local pedType = GetPedType(ped)
    if pedType == 6 or pedType == 27 or pedType == 29 or pedType == 28 then
        return false
    end

    if IsPlayerFreeAimingAtEntity(PlayerId(),ped) then
    	return false
    end

    if IsPedFleeing(ped) then
    	return false
    end

    if IsPedEvasiveDiving(ped) then
    	return false
    end

    if GetIsTaskActive(ped,152) or GetIsTaskActive(ped,176) then
    	return false
    end

--[[    if IsPedInAnyVehicle(ped, false) then
    	return false
    end--]]
    ClearPedTasks(ped)
    RequestAnimDict("cellphone@")
    while not HasAnimDictLoaded("cellphone@") do Citizen.Wait(0); end
    TaskPlayAnim(ped, "cellphone@", "cellphone_call_listen_base", 1.0, 1.0, -1, 49, 0, 0, 0, 0)
    return true
end

function rangesLoop()
    local ranges = {}
    for k,v in pairs(Config.FiringRanges) do
        local boxZone = BoxZone:Create(v.position, v.height, v.width, {
            name="box_zone_"..tostring(k),
            heading=v.heading,
            offset={0.0, 0.0, 0.0},
            scale={1.0, 1.0, 1.0},
            debugPoly=false,
        })

        table.insert(ranges, boxZone)
    end

    while true do
        local sleep = 1000
        if playerPosition then
            local isInside = false
            for k,v in pairs(ranges) do
                if v:isPointInside(playerPosition) then
                    sleep = 500
                    isInside = true
                    break
                end
            end
            showGunshots = not isInside
        end
        Wait(sleep)
    end
end


RegisterNetEvent('BJCore:Player:SetPlayerData')
AddEventHandler('BJCore:Player:SetPlayerData', function(Player)
    PlayerData = Player
end)
RegisterNetEvent('BJCore:Client:OnJobUpdate')
AddEventHandler('BJCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
end)
