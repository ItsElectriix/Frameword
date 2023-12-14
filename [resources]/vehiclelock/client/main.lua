local vehicleData = {}
local busy = false
local hasExited = false
local neededAttempts = 0
local succeededAttempts = 0
local isHotwiring = false
local alertSend = false
citizenid = nil

Citizen.CreateThread(function()
    while not BJCore do Citizen.Wait(1000); end
    while not BJCore.Functions.IsPlayerLoaded() do Citizen.Wait(1000); end
    TriggerServerEvent("vehiclelock:getVehicleData")
    while not vehicleData do Citizen.Wait(1000); end
    Update()
end)

function Update()
    while true do
        Citizen.Wait(0)
        local ped = PlayerPedId()
        local pedExist = DoesEntityExist(ped)
        local pedinVeh = IsPedInAnyVehicle(ped, false)

        if DoesEntityExist(GetVehiclePedIsTryingToEnter(ped)) then
            local vehicle = GetVehiclePedIsTryingToEnter(ped)
            local plate = GetVehicleNumberPlateText(vehicle)
            TriggerServerEvent('vehiclelock:getLockStatus', plate, 'outside', hasKey(vehicle))
            Wait(2500)
        end

        if pedExist and not pedinVeh then
            if not hasExited then
                hasExited = true
                local lastvehicle = GetPlayersLastVehicle()
                if lastvehicle ~= 0 then
                    local plate = GetVehicleNumberPlateText(lastvehicle)
                    TriggerServerEvent('vehiclelock:getLockStatus', plate, 'exiting', hasKey(lastvehicle))
                    lastvehicle = nil
                end
            end
        elseif pedExist and pedinVeh then
            if hasExited then
                hasExited = false
            end
        end
    end
end

RegisterKeyMapping('-vehicelock', 'Vehicle Lock~', 'keyboard', 'G')
RegisterCommand('-vehicelock', function()
    if busy == false and GetLastInputMethod(0) then
        busy = true
        getVehicle()
    end
end)

getVehicle = function()
    local player = PlayerPedId()
    local coords = GetEntityCoords(player)
    local lockStatus
    local vehicle = nil

    if IsPedInAnyVehicle(player, false) then
        vehicle = GetVehiclePedIsIn(player, false)
        if vehicle then
            if isaVehicle(vehicle) then
                if GetPedInVehicleSeat(vehicle, -1) == player or GetPedInVehicleSeat(vehicle, 0) == player then
                    local plate = GetVehicleNumberPlateText(vehicle)
                    TriggerServerEvent('vehiclelock:getLockStatus', plate, 'inside', hasKey(vehicle))
                end
            end
        end
        busy = false
        return
    else
        local coords2 = GetOffsetFromEntityInWorldCoords(player, 0.0, 255.0, 0.0)
        local targetVehicle = getvehicleRay(coords, coords2, 200)

        if (targetVehicle ~= nil and targetVehicle ~= 0) then
            vehicle = targetVehicle
        end

        if not vehicle then
            busy = false
            return
        elseif not GetVehicleNumberPlateText(vehicle) then
            busy = false
            return
        else
            if isaVehicle(vehicle) then
                local plate = GetVehicleNumberPlateText(vehicle)
                TriggerServerEvent('vehiclelock:getLockStatus', plate, 'remote', hasKey(vehicle))
            end
        end
    end
end

isaVehicle = function(vehicle)
    if not DoesEntityExist(vehicle) and not IsEntityAVehicle(vehicle) then
        return false
    end
        return true
end

hornandLights = function(vehicle, times, timer, duration)
    local vehicleHorn = GetVehicleMod(vehicle, 14)
    local count = 0
    local lights = 2

    SetVehicleMod(vehicle, 14, -1, false)

    Citizen.CreateThread(function()
        while count < times do
            StartVehicleHorn(vehicle, duration, "HELDDOWN", false)
            SetVehicleLights(vehicle, lights)
            if lights == 2 then lights = 0; elseif lights == 0 then lights = 2; end
            count = count + 1
            Wait(timer)
        end
        Wait(20)
        SetVehicleLights(vehicle, 0)
        SetVehicleMod(vehicle,14, vehicleHorn, false)
    end)
end
exports("hornandLights", hornandLights)

function getvehicleRay(plyCoord, lookCoord)
    local offset = 0
    local rayHandle
    local vehicle

    for i = 0, 100 do
        rayHandle = CastRayPointToPoint(plyCoord.x, plyCoord.y, plyCoord.z, lookCoord.x, lookCoord.y, lookCoord.z + offset, 10, PlayerPedId(), 0)
        a, b, c, d, vehicle = GetRaycastResult(rayHandle)

        offset = offset - 1

        if vehicle ~= 0 then break end
    end

    local dist = #(plyCoord - GetEntityCoords(vehicle))

    if dist > 25 then vehicle = nil end

    return vehicle ~= nil and vehicle or 0
end

--animation for key fob
function playAnim()
    local player = PlayerPedId()
    if not IsPedInAnyVehicle(player) then
        RequestAnimDict('anim@mp_player_intmenu@key_fob@')
        while not HasAnimDictLoaded('anim@mp_player_intmenu@key_fob@') do
            Citizen.Wait(0)
            RequestAnimDict('anim@mp_player_intmenu@key_fob@')
        end
        TaskPlayAnim(player, 'anim@mp_player_intmenu@key_fob@', 'fob_click_fp', 8.0, 8.0, -1, 48, 1, false, false, false)
    end
end

RegisterNetEvent('vehiclelock:setvehicleLock')
AddEventHandler('vehiclelock:setvehicleLock', function(plate, lockstatus, call, owner)

    if call == 'notauth' then
        busy = false
        return
    end

    local player = PlayerPedId()
    local coords = GetEntityCoords(player)
    local vehicles = BJCore.Functions.GetVehiclesInArea(coords, 10 * 2)
    local message = nil

    if lockstatus == false then lockstatus = 1; elseif lockstatus == true then lockstatus = 2; end

    if owner and call ~= 'outside' and call ~= 'exiting' and call ~= 'inside' then
        vehicleKeys = CreateObject(GetHashKey("prop_cuff_keys_01"), 0, 0, 0, true, true, true)
        AttachEntityToEntity(vehicleKeys, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.11, 0.03, -0.03, 90.0, 0.0, 0.0, true, true, false, true, 1, true)
        if not BJCore.Functions.GetPlayerData().metadata["intrunk"] then playAnim(); end

        Wait(500)
    end

    for i=1, #vehicles do
        if GetVehicleNumberPlateText(vehicles[i]) == plate then
            if call ~= 'outside' and call ~= 'exiting' then
                if lockstatus == 1 then
                    PlayVehicleDoorOpenSound(vehicles[i], 1)
                    if call ~= 'inside' then
                        hornandLights(vehicles[i], 3, 200, 10)
                        SetVehicleAlarm(vehicles[i], false)
                    end
                        message = 'Vehicle unlocked'
                elseif lockstatus == 2 or lockstatus == 4 then
                    PlayVehicleDoorCloseSound(vehicles[i], 0)
                    if call ~= 'inside' then
                        hornandLights(vehicles[i], 2, 200, 10)
                        SetVehicleAlarm(vehicles[i], true)
                    end
                    if lockstatus == 2 then
                        message = 'Vehicle locked'
                    elseif lockstatus == 4 then
                        message = 'Child locked'
                    end
                end

                if owner then
                    BJCore.Functions.Notify(message,'primary')
                end

            end
            SetVehicleDoorsLocked(vehicles[i], lockstatus)
        end
    end
    DeletePropEntity(vehicleKeys)

    busy = false
end)

function DeletePropEntity(entity)
    NetworkRequestControlOfEntity(entity)

    local timeout = 2000
    while timeout > 0 and not NetworkHasControlOfEntity(entity) do
        Wait(100)
        timeout = timeout - 100
    end
    SetEntityAsMissionEntity(entity,true,true)
    DeleteEntity(entity)
end

-- RegisterCommand("givevkeys", function(source)
--  local plyPed = PlayerPedId()
--  local target = nil
--  local vehicle = GetVehiclePedIsIn(plyPed, false)

--  local closestPlayer, closestPlayerDistance = BJCore.Functions.GetClosestPlayer()
--  if closestPlayer ~= -1 and closestPlayerDistance <= 2.5 then
--      target = GetPlayerServerId(closestPlayer)
--  end

--  if target ~= nil and target ~= 0 then
--      giveKey(target)
--  else
--      BJCore.Functions.Notify('Target player not found. Try again','error')
--  end

-- end, false)

RegisterNetEvent('keys:giveKey')
AddEventHandler('keys:giveKey', function()
    local coordA = GetEntityCoords(PlayerPedId(), 1)
    local coordB = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 100.0, 0.0)
    local veh = getvehicleRay(coordA, coordB)
    if veh == nil or veh == 0 then veh = GetVehiclePedIsIn(PlayerPedId(), false); end

    if veh == nil or not DoesEntityExist(veh) then BJCore.Functions.Notify('Vehicle not found','error') return; end
    if not hasKey(veh) then BJCore.Functions.Notify('You have no keys for this vehicle','error') return; end

    if #(GetEntityCoords(veh) - GetEntityCoords(PlayerPedId(), 0)) > 3 then
        BJCore.Functions.Notify('Too far from vehicle','error')
        return
    end

    local t, distance = BJCore.Functions.GetClosestPlayer()
    if distance ~= -1 and distance < 5 then
        TriggerServerEvent('vehiclelock:giveKeys', GetPlayerServerId(t), GetVehicleNumberPlateText(veh))
    else
        BJCore.Functions.Notify('No player near you, try again?','error')
    end
end)

local function runningTick()
    local plyPed = PlayerPedId()
    local plyVeh = GetVehiclePedIsUsing(plyPed)
    local isPlayerDriving = GetPedInVehicleSeat(plyVeh, -1) == plyPed
    local plate = GetVehicleNumberPlateText(plyVeh)

    if IsPedGettingIntoAVehicle(plyPed) then return; end

    if plyVeh and isPlayerDriving then
        if IsDisabledControlJustReleased(1, 96) and not IsThisModelAHeli(GetEntityModel(plyVeh)) and not IsPauseMenuActive() and (not exports.gameplay or not exports.gameplay:UsingBinoculars()) then
            TriggerEvent("car:engine")
        end
    else
        Wait(200)
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        runningTick()
    end
end)

RegisterNetEvent('car:engine')
AddEventHandler('car:engine', function()
    TriggerEvent("keys:hasKeys", GetVehiclePedIsUsing(PlayerPedId()))
end)

RegisterNetEvent('keys:hasKeys')
AddEventHandler('keys:hasKeys', function(veh)
    local plate = GetVehicleNumberPlateText(veh)
    local allow = hasKey(veh)
    TriggerEvent("car:engineHasKeys", veh, allow)
end)

local waitKeys = false
local stalled = false
AddEventHandler("vehiclelock:client:vehicleStall", function(b)
    stalled = b
end)

RegisterNetEvent('car:engineHasKeys')
AddEventHandler('car:engineHasKeys', function(targetVehicle, allow)
    if IsVehicleEngineOn(targetVehicle) then
        if not waitKeys then
            waitKeys = true
            SetVehicleEngineOn(targetVehicle,0,1,1)
            SetVehicleUndriveable(targetVehicle,true)
            if not stalled then
                BJCore.Functions.Notify("Engine Halted",'primary')
            end
            Citizen.Wait(300)
            waitKeys = false
        end
    else
        if allow then
            if not waitKeys then
                waitKeys = true
                TriggerEvent("keys:startvehicle")
                if not stalled then
                    BJCore.Functions.Notify("Engine Started",'primary')
                end
                Citizen.Wait(300)
                waitKeys = false
            end
        else
            BJCore.Functions.Notify("You don't have keys to this vehicle",'error')
        end
    end
end)

Citizen.CreateThread( function()
    local latestveh = 0
    local engineWasRunning = false
    while true do
        Citizen.Wait(0)
        local plyPed = PlayerPedId()
        if IsPedInAnyVehicle(plyPed, false) then
            local veh = GetVehiclePedIsUsing(plyPed)
            local plate = GetVehicleNumberPlateText(veh)
            if not GetIsTaskActive(plyPed, 2) then
                engineWasRunning = GetIsVehicleEngineRunning(veh)
            end
            if GetPedInVehicleSeat(veh, -1) == plyPed then
                if latestveh ~= veh and not engineWasRunning then
                    TriggerEvent("keys:shutoffengine")
                end
                latestveh = veh
                if latestveh == veh then Citizen.Wait(250); end
                if GetIsTaskActive(plyPed, 2) then
                    if engineWasRunning then
                        SetVehicleEngineOn(latestveh, true, true, true)
                    end
                end
            end
        else
            neededAttempts = 0
            succeededAttempts = 0
            latestveh = false
            Wait(500)
        end
    end
end)

local advancedOnly = {
    [GetHashKey('stockade')] = true
}

function needsAdvanced(model)
    local ret = false
    if advancedOnly[model] then
        ret = true
    end
    return ret
end

-- Thread to trigger aim & steal:
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        local plyPed = PlayerPedId()
        if StealingVehicle(plyPed) then
            Citizen.Wait(5)
        end
    end
end)

searchableCar = nil
function StealingVehicle(plyPed)
    local aiming, entity = GetEntityPlayerIsFreeAimingAt(PlayerId())
    if IsPedInAnyVehicle(PlayerPedId(), false) then return false end
    if aiming then
        local pedType = GetPedType(entity)
        local animalped = false
        if pedType == 6 or pedType == 27 or pedType == 29 or pedType == 28 then
            animalped = true
        end

        if animalped then return false end
        if not DoesEntityExist(entity) then return false end
        if not IsEntityAPed(entity) then return false end
        if not IsPedArmed(PlayerPedId(), 6) then return false end
        if IsPedAPlayer(entity) then return false end
        if IsPedArmed(entity, 7) then return false end
        if IsEntityDead(entity) then return false end
        if IsPedDeadOrDying(entity, 1) then return false end
        if GetEntityModel(entity) == -520477356 then return false end -- G4S Guards

        if IsPedInAnyVehicle(entity, false) and GetEntitySpeed(veh) < 1.5 then
            if GetVehiclePedIsIn(entity) then
                local robCar = GetVehiclePedIsUsing(entity)

                if not DoesEntityExist(robCar) then return false end
                if #(GetEntityCoords(plyPed) - GetEntityCoords(robCar)) > 5.0 then return false end

                local _, taskSequence = OpenSequenceTask()
                TaskSetBlockingOfNonTemporaryEvents(0, true)
                TaskLeaveVehicle(0, robCar, 256)
                TaskHandsUp(0, (Config.HandsUpTime*1000), plyPed, -1)
                CloseSequenceTask(taskSequence)

                SetPedDropsWeaponsWhenDead(entity,false)
                SetPedFleeAttributes(entity, 0, 0)
                SetPedCombatAttributes(entity, 17, 1)
                TaskSetBlockingOfNonTemporaryEvents(entity, true)
                SetPedSeeingRange(entity, 0.0)
                SetPedHearingRange(entity, 0.0)
                SetPedAlertness(entity, 0)
                SetPedKeepTask(entity, true)

                TaskPerformSequence(entity, taskSequence)

                Citizen.Wait((Config.HandsUpTime*1000))
                while not HasAnimDictLoaded("mp_common") do RequestAnimDict("mp_common") Citizen.Wait(0); end

                local keyDropChance = (math.random() * 100)
                if keyDropChance <= Config.PedGivesKeyChance  then
                    TaskPlayAnim(entity, "mp_common", "givetake1_a", 1.0, 1.0, -1, 1, 0, 0, 0, 0 )
                    Citizen.Wait(1400)
                    ClearPedTasks(entity)
                    BJCore.Functions.Notify('Received keys','primary')
                    TriggerEvent("keys:addNew",robCar,GetVehicleNumberPlateText(robCar))
                else
                    BJCore.Functions.Notify('The driver ran away with the keys','primary')
                end
                TaskSmartFleePed(entity, plyPed, 40.0, 20000)
                TaskSetBlockingOfNonTemporaryEvents(entity, false)
                searchableCar = robCar
                Citizen.Wait(math.random(Config.AlertTime.min,Config.AlertTime.max))
                --AlertPoAlertPoliceFunction(robCar)
            end
        else
            return false
        end

        return true
    end

    return false
end

local jacking = false
Citizen.CreateThread( function()
    while true do
        Citizen.Wait(1)
        local run = false
        if GetVehiclePedIsTryingToEnter(PlayerPedId()) ~= nil and GetVehiclePedIsTryingToEnter(PlayerPedId()) ~= 0 then
            run = true
            local curveh = GetVehiclePedIsTryingToEnter(PlayerPedId())
            local plate1 = GetVehicleNumberPlateText(curveh)
            if not hasKey(curveh) then
                if not needsAdvanced(GetEntityModel(curveh)) then
                    local pedDriver = GetPedInVehicleSeat(curveh, -1)
                    if pedDriver ~= 0 and (not IsPedAPlayer(pedDriver) and IsEntityDead(pedDriver)) then
                        if IsEntityDead(pedDriver) and not jacking then
                            jacking = true
                            exports['mythic_progbar']:Progress({
                                name = "taking_keys",
                                duration = 3000,
                                label = "Taking keys",
                                canCancel = false,
                                controlDisables = {
                                    disableMovement = false,
                                    disableCarMovement = false,
                                    disableMouse = false,
                                    disableCombat = false,
                                    disableInteract = false
                                },
                            }, function(status)
                                if not status then
                                    BJCore.Functions.Notify('Received keys','primary')
                                    TriggerEvent("keys:addNew",curveh,plate1)
                                    jacking = false
                                end
                            end)

                        end
                    end
                end
            end
        end

        if IsPedJacking(PlayerPedId()) then
            run = true
            local veh = GetVehiclePedIsUsing(PlayerPedId())
            local plate = GetVehicleNumberPlateText(veh)
            local stayhere = true

            while stayhere do
                local inCar = IsPedInAnyVehicle(PlayerPedId(), false)
                if not inCar then
                    stayhere = false
                end

                if IsVehicleEngineOn(veh) and not hasKey(veh) then
                    TriggerEvent("keys:shutoffengine")
                    stayhere = false
                end
                Citizen.Wait(1)
            end
        end

        if not run then Wait(100); end
    end
end)

AddEventHandler('vehiclelock:hotwire', function() doHotwire() end)

RegisterCommand('hw', function()
    doHotwire()
end)

local hotwiring = false
function doHotwire()
    local car = GetVehiclePedIsIn(PlayerPedId())
    if not hasKey(car) and GetPedInVehicleSeat(car, -1) == PlayerPedId() then
        BJCore.Functions.TriggerServerCallback("BJCore:HasItem", function(has)
            if has then
                if needsAdvanced(GetEntityModel(car)) then return BJCore.Functions.Notify("You can't hotwire this vehicle", "error"); end
                hotwiring = true
                hotwireTick()
                local dict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@"
                local anim = "machinic_loop_mechandplayer"

                RequestAnimDict(dict)
                while not HasAnimDictLoaded(dict) do
                    RequestAnimDict(dict)
                    Citizen.Wait(100)
                end
                TaskPlayAnim(PlayerPedId(), dict, anim, 8.0, 8.0, -1, 16, -1, false, false, false)
                TriggerServerEvent("bj-hud:Server:GainStress", math.random(1,3))
                TriggerEvent('bj_minigames:start', 'Connection', { cable = math.random(3,5), timeout = 7500 }, function(data)
                    hotwiring = false
                    TriggerEvent('keys:startvehicle')
                    StopAnimTask(PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
                    BJCore.Functions.Notify('Hotwire Success','primary')
                end, function(data)
                    hotwiring = false
                    StopAnimTask(PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
                    BJCore.Functions.Notify('Hotwire Failed','primary')
                end)
                if math.random(100) <= 50 then TriggerEvent("evidence:client:SetStatus", "wirecuts", 1200); end
                if math.random(100) <= 25 then TriggerServerEvent("BJCore:Server:RemoveItem", "screwdriverset", 1, nil) BJCore.Functions.Notify("Your tool kit broke", "error"); end
            else
                BJCore.Functions.Notify("You don't have any tools to do this", "error")
            end
        end, "screwdriverset")
    end
end

function hotwireTick()
    Citizen.CreateThread(function()
        while hotwiring do
            if not IsPedInAnyVehicle(PlayerPedId(), true) then
                TriggerEvent('bj_minigames:stop', 'Connection')
                hotwiring = false
                break
            end
            Citizen.Wait(1)
        end
    end)
end

local count = 0
local runningshutoff = false

RegisterNetEvent('keys:startvehicle')
AddEventHandler('keys:startvehicle', function()
    local veh = GetVehiclePedIsUsing(PlayerPedId())
    if GetVehicleEngineHealth(veh) > 199 then
        count = 0
        SetVehicleEngineOn(veh, false, true, true)
        Citizen.Wait(100)

        SetVehicleUndriveable(veh,false)
        SetVehicleEngineOn(veh, true, false, true)
        Citizen.Wait(100)

        if not Citizen.InvokeNative(0xAE31E7DF9B5B132E, veh) then
            SetVehicleEngineOn(veh, true, true, true)
        end
    else
       SetVehicleEngineOn(veh, false, false, true)
       SetVehicleUndriveable(veh, true)
    end
end)

RegisterNetEvent('keys:shutoffengine')
AddEventHandler('keys:shutoffengine', function()
    count = 1000
    if runningshutoff then return; end
    runningshutoff = true
    while count > 0 do
        local veh = GetVehiclePedIsUsing(PlayerPedId())
        Citizen.Wait(1)
        SetVehicleEngineOn(veh, false, true, true)
        count = count - 1
    end

    count = 0
    runningshutoff = false
end)

RegisterNetEvent('keys:addNew')
AddEventHandler('keys:addNew', function(veh, plate)
    if veh == nil then return; end
    plate = plate or GetVehicleNumberPlateText(veh)
    local plateStripped = string.gsub(plate, "%s+", "")
    if not vehicleData[plateStripped] then
        vehicleData[plateStripped] = true
        TriggerServerEvent("vehiclelock:addNewKey", plateStripped)
    end
end)

RegisterNetEvent('keys:receiveKeys')
AddEventHandler('keys:receiveKeys', function(plate)
    if plate == nil then return; end
    local plateStripped = string.gsub(plate, "%s+", "")
    if not vehicleData[plateStripped] then
        vehicleData[plateStripped] = true
        TriggerServerEvent("vehiclelock:addNewKey", plateStripped)
        BJCore.Functions.Notify('You have received keys for vehicle: '..plate,'primary')
    else
        BJCore.Functions.Notify('You already have keys to this vehicle','error')
    end
end)

function hasKey(veh)
    local has = false
    local plate = nil
    if Entity(veh).state.plate and Entity(veh).state.plate ~= nil then
        plate = Entity(veh).state.plate
    else
        plate = GetVehicleNumberPlateText(veh)
    end
    local plateStripped = string.gsub(plate, "%s+", "")
    if vehicleData[plateStripped] then has = true; end
    return has
end

exports('hasKey', hasKey);

local MissionVehicles = {}
AddEventHandler("vehiclelock:setMissionVehicle", function(vehicle, b)
    if b then
        MissionVehicles[vehicle] = true
    else
        MissionVehicles[vehicle] = nil
    end
end)

RegisterNetEvent('vehiclelock:syncToClients')
AddEventHandler('vehiclelock:syncToClients', function(data) vehicleData = data end)

-- RegisterNetEvent('BJCore:Player:SetPlayerData')
-- AddEventHandler('BJCore:Player:SetPlayerData', function(Player)
--     if citizenid == nil or citizenid ~= Player.citizenid then
--         citizenid = Player.citizenid
--         vehicleData = {}
--         TriggerServerEvent("vehiclelock:getVehicleData")
--     end
-- end)

RegisterNetEvent('vehiclelock:client:UseLockPickItem')
AddEventHandler('vehiclelock:client:UseLockPickItem', function(isAdvanced)
    if IsPedInAnyVehicle(PlayerPedId()) then
        if not hasKey(GetVehiclePedIsIn(PlayerPedId(), true)) then
            LockpickIgnition(isAdvanced)
        end
    elseif CanLockpickVehicle() then
        LockpickDoor(isAdvanced)
    elseif exports["doorlock"]:doorCheck() then
        TriggerEvent("doorlock:client:startLockpick")
    end
end)

local LockpickIgnitionTick = false
function LockpickIgnition(isAdvanced)
    if NeededAttempts == 0 then
        NeededAttempts = math.random(2, 4)
    end
    --if not HasKey then
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
        if vehicle ~= nil and vehicle ~= 0 then
            if GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() then
                if (needsAdvanced(GetEntityModel(vehicle)) and not isAdvanced) then return BJCore.Functions.Notify("You need an advanced lockpick to do this", "error"); end
                if MissionVehicles[vehicle] then TriggerEvent("missions:client:lockpicking"); end
                IsHotwiring = true
                PoliceCall()

                local difficulty = 3
                local speed = 4
                local timeout = 2750

                if isAdvanced then
                    difficulty, speed, timeout = 2, 4, 3500
                end

                local dict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@"
                local anim = "machinic_loop_mechandplayer"

                RequestAnimDict(dict)
                while not HasAnimDictLoaded(dict) do
                    RequestAnimDict(dict)
                    Citizen.Wait(100)
                end
                TaskPlayAnim(PlayerPedId(), dict, anim, 8.0, 8.0, -1, 16, -1, false, false, false)
                LockpickIgnitionTick = true
                lockpickEngineTick()
                TriggerEvent('bj_minigames:start', 'Lockbox', { difficulty = difficulty, speed = speed, attempts = 1, stages = NeededAttempts, stageTimeout = timeout }, function(data)
                    StopAnimTask(PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
                    TriggerServerEvent('fibheist:ChanceRemove', (isAdvanced and 'advancedlockpick' or 'lockpick'))
                    TriggerEvent('keys:addNew', vehicle, GetVehicleNumberPlateText(vehicle))
                    IsHotwiring = false
                    BJCore.Functions.Notify("Lockpicking success", "success")
                    --ClearPedTasksImmediately(PlayerPedId())
                    TriggerServerEvent('bj-hud:Server:GainStress', math.random(2, 4))
                    LockpickIgnitionTick = false
                end, function(data)
                    StopAnimTask(PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
                    TriggerServerEvent('fibheist:ChanceRemove', (isAdvanced and 'advancedlockpick' or 'lockpick'))
                    BJCore.Functions.Notify("Lockpicking failed", "error")
                    --ClearPedTasksImmediately(PlayerPedId())
                    IsHotwiring = false
                    local c = math.random(5)
                    local o = math.random(5)
                    if c == o then
                        TriggerServerEvent('bj-hud:Server:GainStress', math.random(1, 4))
                    end
                    LockpickIgnitionTick = false
                end)
                if math.random(100) <= 50 then TriggerEvent("evidence:client:SetStatus", "scratchhands", 1200); end
            end
        end
   -- end
end

function lockpickEngineTick()
    Citizen.CreateThread(function()
        while LockpickIgnitionTick do
            if not IsPedInAnyVehicle(PlayerPedId(), true) then
                TriggerEvent('bj_minigames:stop', 'Lockbox')
                LockpickIgnitionTick = false
                break
            end
            Citizen.Wait(1)
        end
    end)
end

function CanLockpickVehicle()
    local ret = false
    local vehicle = BJCore.Functions.GetClosestVehicle()
    if vehicle ~= nil and vehicle ~= -1 then
        local vehpos = GetEntityCoords(vehicle)
        local pos = GetEntityCoords(PlayerPedId())
        if #(pos - vehpos) < 1.5 then
            ret = true
        end
    end
    return ret
end

local openingDoor = false
function LockpickDoor(isAdvanced)
    local vehicle = BJCore.Functions.GetClosestVehicle()
    if vehicle ~= nil and vehicle ~= 0 then
        local vehpos = GetEntityCoords(vehicle)
        local pos = GetEntityCoords(PlayerPedId())
        if #(pos - vehpos) < 1.5 then
            if (needsAdvanced(GetEntityModel(vehicle)) and not isAdvanced) then return BJCore.Functions.Notify("You need an advanced lockpick to do this", "error"); end
            if MissionVehicles[vehicle] then TriggerEvent("missions:client:lockpicking"); end
            local vehLockStatus = GetVehicleDoorLockStatus(vehicle)
            if (vehLockStatus > 1) then
                LockpickDoorAnim()
                PoliceCall()
                IsHotwiring = true
                SetVehicleAlarm(vehicle, true)
                SetVehicleAlarmTimeLeft(vehicle, lockpickTime)
                local difficulty = 3
                local speed = 4
                local timeout = 2750

                if isAdvanced then
                    difficulty, speed, timeout = 2, 4, 3500
                end
                TriggerEvent('bj_minigames:start', 'Lockbox', { difficulty = difficulty, speed = speed, attempts = 1, stages = NeededAttempts, stageTimeout = timeout }, function(data)
                    openingDoor = false
                    StopAnimTask(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 1.0)
                    IsHotwiring = false
                    TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 5, "unlock", 0.3)
                    SetVehicleDoorsLocked(vehicle, 0)
                    SetVehicleDoorsLockedForAllPlayers(vehicle, false)
                    TriggerServerEvent('vehiclelock:lockPick', GetVehicleNumberPlateText(vehicle))
                    BJCore.Functions.Notify("Door open")
                end, function(data)
                    openingDoor = false
                    StopAnimTask(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 1.0)
                    BJCore.Functions.Notify("Failed", "error")
                    IsHotwiring = false
                end)
                if math.random(100) <= 50 then TriggerEvent("evidence:client:SetStatus", "scratchhands", 1200); end
            end
        end
    end
end

function LockpickDoorAnim()
    loadAnimDict("veh@break_in@0h@p_m_one@")
    TaskPlayAnim(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds" ,3.0, 3.0, -1, 16, 0, false, false, false)
    openingDoor = true
    Citizen.CreateThread(function()
        while openingDoor do
            TaskPlayAnim(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 3.0, 3.0, -1, 16, 0, 0, 0, 0)
            Citizen.Wait(1000)
            if not openingDoor then
                StopAnimTask(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 1.0)
            end
        end
    end)
end

function PoliceCall()
    if not AlertSend then
        local pos = GetEntityCoords(PlayerPedId())
        local chance = 20
        if GetClockHours() >= 1 and GetClockHours() <= 6 then
            chance = 10
        end
        if math.random(1, 100) <= chance then
            if exports['jobnotif']:getRandomNpc(25.0, false) then
                local msg = ""
                if IsPedInAnyVehicle(PlayerPedId()) then
                    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                    local modelName = GetEntityModel(vehicle)
                    if BJCore.Shared.VehicleModels[modelName] ~= nil then
                        Name = BJCore.Shared.Vehicles[BJCore.Shared.VehicleModels[modelName]["model"]]["brand"] .. ' ' .. BJCore.Shared.Vehicles[BJCore.Shared.VehicleModels[modelName]["model"]]["name"]
                    else
                        Name = "Unknown"
                    end
                    local modelPlate = GetVehicleNumberPlateText(vehicle)
                    local msg = "Vehicle theft attempt at " ..streetLabel.. ". Vehicle: " .. Name .. ", Licensplate: " .. modelPlate
                    TriggerServerEvent('MF_Trackables:Notify', msg, pos,'police','carjack')
                else
                    local vehicle = BJCore.Functions.GetClosestVehicle()
                    local modelName = GetEntityModel(vehicle)
                    local modelPlate = GetVehicleNumberPlateText(vehicle)
                    if BJCore.Shared.VehicleModels[modelName] ~= nil then
                        Name = BJCore.Shared.Vehicles[BJCore.Shared.VehicleModels[modelName]["model"]]["brand"] .. ' ' .. BJCore.Shared.Vehicles[BJCore.Shared.VehicleModels[modelName]["model"]]["name"]
                    else
                        Name = "Unknown"
                    end
                    local msg = "Vehicle theft attempt at " ..streetLabel.. ". Vehicle: " .. Name .. ", Licenceplate: " .. modelPlate
                    TriggerServerEvent('MF_Trackables:Notify',msg, pos,'police','carjack')
                end
            end
        end
        AlertSend = true
        SetTimeout(2 * (60 * 1000), function()
            AlertSend = false
        end)
    end
end

function loadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Citizen.Wait(0)
    end
end

RegisterNetEvent('BJCore:Client:OnPlayerLoaded')
AddEventHandler('BJCore:Client:OnPlayerLoaded', function() TriggerServerEvent("vehiclelock:getVehicleData") end)
RegisterNetEvent('BJCore:Client:OnPlayerUnload')
AddEventHandler('BJCore:Client:OnPlayerUnload', function() vehicleData = {}; end)
RegisterNetEvent('vehiclelock:resetKeys')
AddEventHandler('vehiclelock:resetKeys', function() vehicleData = {}; TriggerServerEvent("vehiclelock:getVehicleData"); end)