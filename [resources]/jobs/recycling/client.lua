local carryPackage = nil
local onDuty = false
local isHolding = false
local inside = false
Citizen.CreateThread(function ()
    while true do
        local nearby = false
        local pos = GetEntityCoords(PlayerPedId(), true)
        local time = GetClockHours()

        if #(pos - Config['recycle'].outsideLocation) < 10.0 then
            nearby = true
            if #(pos - Config['recycle'].outsideLocation) < 1.3 then
                BJCore.Functions.DrawText3D(Config['recycle'].outsideLocation.x, Config['recycle'].outsideLocation.y, Config['recycle'].outsideLocation.z, "[~g~E~w~] Enter Recycling Center")
                if IsControlJustReleased(0, 38) then
                    if time > 18 or time < 9 then
                        BJCore.Functions.Notify("Recycling Center is only open during the day. Come back then", "primary")
                    else
                        DoScreenFadeOut(500)
                        while not IsScreenFadedOut() do
                            Citizen.Wait(10)
                        end
                        SetEntityCoords(PlayerPedId(), Config['recycle'].insideLocation.x, Config['recycle'].insideLocation.y, Config['recycle'].insideLocation.z)
                        DoScreenFadeIn(500)
                        if not inside then
                            inside = true
                            insideTick()
                        end
                    end
                end                   
            end
        end

        if #(pos - Config['recycle'].insideLocation) < 15 and not IsPedInAnyVehicle(PlayerPedId(), false) and not onDuty then
            nearby = true
            DrawMarker(27, Config['recycle'].insideLocation.x, Config['recycle'].insideLocation.y, Config['recycle'].insideLocation.z, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 0.5001, 98, 102, 185,100, 0, 0, 0,0)
            if #(pos - Config['recycle'].insideLocation) < 1.3 then
                BJCore.Functions.DrawText3D(Config['recycle'].insideLocation.x, Config['recycle'].insideLocation.y, Config['recycle'].insideLocation.z + 1, "[~g~E~w~] Exit")
                if IsControlJustReleased(0, 38) then
                    DoScreenFadeOut(500)
                    while not IsScreenFadedOut() do
                        Citizen.Wait(10)
                    end
                    SetEntityCoords(PlayerPedId(), Config['recycle'].outsideLocation.x, Config['recycle'].outsideLocation.y, Config['recycle'].outsideLocation.z + 1)
                    DoScreenFadeIn(500)
                    inside = false
                    isHolding = false
                    onDuty = false
                end
            end
        end

        if #(pos - vector3(1049.15,-3100.63,-39.95)) < 15 and not IsPedInAnyVehicle(PlayerPedId(), false) and carryPackage == nil then
            nearby = true
            DrawMarker(27, 1049.15,-3100.63,-39.95, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 0.5001, 255, 0, 0,100, 0, 0, 0,0)
            if #(pos - vector3(1049.15,-3100.63,-39.95)) < 1.3 then
                if onDuty then
                    BJCore.Functions.DrawText3D(1049.15,-3100.63,-39.95 + 1, "[~g~E~w~] Clock Off")
                else
                    BJCore.Functions.DrawText3D(1049.15,-3100.63,-39.95 + 1, "[~g~E~w~] Clock In")
                end
                if IsControlJustReleased(0, 38) then
                    onDuty = not onDuty
                    if onDuty then
                        BJCore.Functions.Notify("You have clocked in")
                    else
                        BJCore.Functions.PersistentNotify('end', 'recycle')
                        BJCore.Functions.Notify("You have clocked off", "error")
                    end
                end
            end
        end
        if not nearby then
            Citizen.Wait(500)
        end
        Citizen.Wait(3)
    end
end)

local packagePos = nil
local doneLastTask = false

function insideTick()
    Citizen.CreateThread(function ()
        for k, pickuploc in pairs(Config['recycle'].pickupLocations) do
            local model = GetHashKey(Config['recycle'].warehouseObjects[math.random(1, #Config['recycle'].warehouseObjects)])
            RequestModel(model)
            while not HasModelLoaded(model) do Citizen.Wait(0) end
            local obj = CreateObject(model, pickuploc.x, pickuploc.y, pickuploc.z, false, true, true)
            PlaceObjectOnGroundProperly(obj)
            FreezeEntityPosition(obj, true)
        end
        while inside do
            Citizen.Wait(7)
            if onDuty then
                if packagePos ~= nil then
                    local pos = GetEntityCoords(PlayerPedId(), true)
                    if carryPackage == nil then
                        if #(pos - packagePos) < 2.3 then
                            BJCore.Functions.DrawText3D(packagePos.x,packagePos.y,packagePos.z+ 1, "[~g~E~w~] Grab package")
                            if IsControlJustReleased(0, 38) then
                                TaskStartScenarioInPlace(PlayerPedId(), "PROP_HUMAN_BUM_BIN", 0, true)
                                exports['mythic_progbar']:Progress({
                                    name = "pickup_reycle_package",
                                    duration = math.random(5000, 8000),
                                    label = "Tasking",
                                    useWhileDead = false,
                                    canCancel = true,
                                    controlDisables = {
                                        disableMovement = true,
                                        disableCarMovement = true,
                                        disableMouse = false,
                                        disableCombat = true,
                                    },
                                }, function(status)
                                    if not status then
                                        ClearPedTasks(PlayerPedId())
                                        PickupPackage()
                                    else
                                        BJCore.Functions.Notify("Cancelled", "error")
                                    end
                                end)
                            end
                        elseif not doneLastTask then
                            BJCore.Functions.DrawText3D(packagePos.x, packagePos.y, packagePos.z + 1, "Package")
                        end
                    else
                        if #(pos - Config['recycle'].dropLocation) < 2.0 then
                            BJCore.Functions.DrawText3D(Config['recycle'].dropLocation.x, Config['recycle'].dropLocation.y, Config['recycle'].dropLocation.z, "[~g~E~w~] Drop off")
                            if IsControlJustReleased(0, 38) then
                                DropPackage()
                                ScrapAnim()
                                doneLastTask = true
                                exports['mythic_progbar']:Progress({
                                    name = "pickup_reycle_package2",
                                    duration = math.random(5000, 8000),
                                    label = "Tasking",
                                    useWhileDead = false,
                                    canCancel = true,
                                    controlDisables = {
                                        disableMovement = true,
                                        disableCarMovement = true,
                                        disableMouse = false,
                                        disableCombat = true,
                                    },
                                }, function(status)
                                    if not status then
                                        StopAnimTask(PlayerPedId(), "mp_car_bomb", "car_bomb_mechanic", 1.0)
                                        TriggerServerEvent('recycle:server:getItem')
                                        BJCore.Functions.PersistentNotify('start', 'recycle', 'Waiting for next task..', 'primary')
                                        Citizen.Wait(math.random(5000,15000))
                                        BJCore.Functions.PersistentNotify('end', 'recycle')
                                        doneLastTask = false
                                        GetRandomPackage()
                                    else
                                        BJCore.Functions.Notify("Cancelled", "error")
                                    end
                                end)
                            end
                        else
                            BJCore.Functions.DrawText3D(Config['recycle'].dropLocation.x, Config['recycle'].dropLocation.y, Config['recycle'].dropLocation.z, "Deliver")
                        end
                    end
                else
                    GetRandomPackage()
                end
            end
        end
    end)
end

function ScrapAnim()
    local time = 5
    loadAnimDict("mp_car_bomb")
    TaskPlayAnim(PlayerPedId(), "mp_car_bomb", "car_bomb_mechanic" ,3.0, 3.0, -1, 16, 0, false, false, false)
    openingDoor = true
    Citizen.CreateThread(function()
        while openingDoor do
            TaskPlayAnim(PlayerPedId(), "mp_car_bomb", "car_bomb_mechanic", 3.0, 3.0, -1, 16, 0, 0, 0, 0)
            Citizen.Wait(1000)
            time = time - 1
            if time <= 0 then
                openingDoor = false
                StopAnimTask(PlayerPedId(), "mp_car_bomb", "car_bomb_mechanic", 1.0)
            end
        end
    end)
end

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(5)
    end
end

function GetRandomPackage()
    BJCore.Functions.TriggerServerCallback('recycle:server:CheckAvailableTasks', function(tasks)
        if tasks and tasks > 0 then
            local randSeed = math.random(1, #Config["recycle"].pickupLocations)
            packagePos = {}
            packagePos = Config["recycle"].pickupLocations[randSeed]
        else
            BJCore.Functions.Notify("You have no more tasks available to do. Please come back later", "error", 7000)
            onDuty = false
            BJCore.Functions.Notify("You have been clocked off", "error")
            carryPackage = nil
            isHolding = false  
            packagePos = nil          
        end
    end)
end

function PickupPackage()
    local pos = GetEntityCoords(PlayerPedId(), true)
    RequestAnimDict("anim@heists@box_carry@")
    while (not HasAnimDictLoaded("anim@heists@box_carry@")) do
        Citizen.Wait(7)
    end
    TaskPlayAnim(PlayerPedId(), "anim@heists@box_carry@" ,"idle", 5.0, -1, -1, 50, 0, false, false, false)
    local model = GetHashKey("prop_cs_cardbox_01")
    RequestModel(model)
    while not HasModelLoaded(model) do Citizen.Wait(0) end
    local object = CreateObject(model, pos.x, pos.y, pos.z, true, true, true)
    AttachEntityToEntity(object, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.05, 0.1, -0.3, 300.0, 250.0, 20.0, true, true, false, true, 1, true)
    carryPackage = object
    isHolding = true
    holdingTick()
end

function DropPackage()
    ClearPedTasks(PlayerPedId())
    DetachEntity(carryPackage, true, true)
    DeleteObject(carryPackage)
    carryPackage = nil
    isHolding = false
    packagePos = nil
end

function holdingTick()
    Citizen.CreateThread(function()
        while isHolding do
            if IsPedRunning(PlayerPedId()) then
                SetPedToRagdoll(PlayerPedId(),2000,2000, 3, 0, 0, 0)
                Wait(2100)
                TaskPlayAnim(PlayerPedId(),"anim@heists@box_carry@","idle",2.0, -8, 180000000, 49, 0, 0, 0, 0)
            end
            Citizen.Wait(0)
        end
    end)
end