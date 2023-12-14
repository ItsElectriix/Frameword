local PlayerData = {}
local isInstructorMode = false
local isInVehicle = false
local usingClipboard = false
local curTest = {
    cid = -1,
    instructor = '',
    points = 10,
    passed = true,
    results = {},
}
local actions = {
    vehicle = 0,
    isBraking = false,
    isHornOn = false,
}
local drivingSchools = {
    vector3(214.56, -1400.21, 30.58),
}
BJCore = nil
Citizen.CreateThread(function(...) 
    while BJCore == nil do 
        TriggerEvent("BJCore:GetObject", function(obj) BJCore = obj end)
        Citizen.Wait(1000)
    end
    PlayerData = BJCore.Functions.GetPlayerData()
    if BJCore.Functions.IsPlayerLoaded() then
        if PlayerData.job.name == "drivinginstructor" then
            checkForDrivingSchool()
        end
    end
end)

function updateNUI(tempData)
    tempData = tempData or false
    if PlayerData.metadata["isdead"] then
        if not usingClipboard then
            SetNuiFocus(false,false)
            SendNUIMessage({show = false})
            TriggerEvent("drivingInstructor:clipboard")
        end
        return
    end
    if usingClipboard then
        if (not tempData) then
            SetNuiFocus(true,true)
            SendNUIMessage({show = true, data = curTest})
        else
            SetNuiFocus(true,false)
            SendNUIMessage({show = true, data = tempData, readonly = true})

            Citizen.CreateThread(function()
                while usingClipboard do
                    Citizen.Wait(1)
                    if IsControlJustPressed(1, 322) then -- ESC
                        SendNUIMessage({close = true})
                    end
                end
            end)
        end
    else
        SetNuiFocus(false,false)
        SendNUIMessage({show = false})
    end
    TriggerEvent("drivingInstructor:clipboard", (not tempData))
end

function updateInstructor()
    if isInstructorMode then
        checkForVehicle()
        BJCore.Functions.Notify("Instructor Mode: Enabled")
    else
        BJCore.Functions.Notify("Instructor Mode: Disabled")
    end

    TriggerEvent("drivingInstructor:update", isInstructorMode)
end

function isVehicleAllowed(vehhicle)
    local vehicleClass = GetVehicleClass(vehhicle)
    --  8: Motorcycles, 13: Cycles, 15: Helicopters, 16: Planes, 17: Service, 18: Emergency, 19: Military, 21: Trains  
    return (vehicleClass ~= 8 and vehicleClass ~= 13 and vehicleClass ~= 15 and vehicleClass ~= 16 and vehicleClass ~= 17 and vehicleClass ~= 18 and vehicleClass ~= 19 and vehicleClass ~= 21)
end

function checkForVehicle()
    isInVehicle = false

    Citizen.CreateThread(function()
        local playerPed = PlayerPedId()
        while isInstructorMode do
            local playerVeh = GetVehiclePedIsIn(playerPed, false)
            if isInVehicle then
                if playerVeh == 0 then
                    isInVehicle = false
                end
            else
                if playerVeh ~= 0 and isVehicleAllowed(playerVeh) then
                    if exports["vehiclelock"]:hasKey(playerVeh) then
                        isInVehicle = true
                        instructorControls(playerPed, playerVeh) -- Got in vehicle, start checking for instructor actions
                    end
                end
            end
            Wait(1000)
        end
    end)
end

function instructorControls(playerPed, veh)
    Citizen.CreateThread(function()
        local isBraking = false
        local isHorning = false
        while (isInstructorMode and isInVehicle) do
            if GetPedInVehicleSeat(veh, 0) == playerPed then
                if not isBraking and IsControlJustPressed(0, 22) then -- Braking ("SPACE")
                    isBraking = true
                    sendActionToDriver(veh, 1)
                elseif isBraking and IsControlJustReleased(0, 22) then -- Unbrake ("SPACE")
                    isBraking = false
                    sendActionToDriver(veh, 2)
                elseif IsControlJustPressed(0, 38) then -- Vehicle kill switch toggle ("E")
                    sendActionToDriver(veh, 3) -- Engine toggle
                elseif not isHorning and IsControlJustPressed(0, 74) then
                    print("on horn")
                    isHorning = true
                    sendActionToDriver(veh, 4)
                elseif isHorning and IsControlJustReleased(0, 74) then
                    print("off horn")
                    isHorning = false
                    sendActionToDriver(veh, 5)
                end
            end

            Wait(1)
        end

        sendActionToDriver(veh, 6) -- Clear any remaining actions
    end)
end

function sendActionToDriver(vehicle, action)
    local driverPed = GetPedInVehicleSeat(vehicle, -1)
    if driverPed > 0 then
        TriggerServerEvent('driving:vehicleAction', GetPlayerServerId(NetworkGetPlayerIndexFromPed(driverPed)), action)
    else
        TriggerEvent('drivingInstructor:vehicleAction', action)
    end
end

function isNearDrivingSchool()
    for i = 1, #drivingSchools do
        local drivingSchool = drivingSchools[i]
        local ply = PlayerPedId()
        local plyCoords = GetEntityCoords(ply)
        local distance = #(drivingSchool - plyCoords)
        if distance < 3.0 then
            BJCore.Functions.DrawText3D(drivingSchool["x"], drivingSchool["y"], drivingSchool["z"], "[~g~E~w~] Toggle Driving Instructor Mode" )
        end
        if distance < 3.0 then
            return true
        end
    end
end

local currentGarage = 1
local garage = vector4(219.85, -1384.59, 30.56, 273.55)
local instructorThreadRunning = false
function checkForDrivingSchool()
    if instructorThreadRunning == true then
        return
    end
    -- Check for instructor toggle
    Citizen.CreateThread(function()
        instructorThreadRunning = true
        while PlayerData.job.name == "drivinginstructor" do
            Citizen.Wait(0)            
            local nearby = false
            local plyPos = GetEntityCoords(PlayerPedId())

            if isNearDrivingSchool() then
                nearby = true
                if IsControlJustPressed(1, 38) then -- [E] key
                    TriggerEvent('drivingInstructor:instructorToggle', not isInstructorMode, PlayerData.charinfo.firstname.." "..PlayerData.charinfo.lastname)
                    --TriggerServerEvent('driving:toggleInstructorMode', isInstructorMode)
                end
            end

            if #(plyPos.xyz - garage.xyz) < 7.5 then
                nearby = true
                DrawMarker(2, garage.x, garage.y, garage.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 255, 255, 255, 222, false, false, false, true, false, false, false)
                if #(plyPos.xyz - garage.xyz) < 1.5 then
                    if IsPedInAnyVehicle(PlayerPedId(), false) then
                        BJCore.Functions.DrawText3D(garage.x, garage.y, garage.z, "[~g~E~w~] Store vehicle")
                    else
                        BJCore.Functions.DrawText3D(garage.x, garage.y, garage.z, "[~g~E~w~] Vehicles")
                    end
                    if IsControlJustReleased(0, 38) then
                        if IsPedInAnyVehicle(PlayerPedId(), false) then
                            BJCore.Functions.DeleteVehicle(GetVehiclePedIsIn(PlayerPedId()))
                        else
                            MenuGarage()
                            currentGarage = k
                            Menu.hidden = not Menu.hidden
                        end
                    end
                    Menu.renderGUI()
                end  
            end
            if not nearby then
                Wait(2500)
            end
        end
        instructorThreadRunning = false
    end)
end

RegisterNUICallback('close', function(data, cb)
    if isInstructorMode and (data and data.cid and data.cid ~= -1) then
        curTest.cid = data.cid
        curTest.points = data.points
        curTest.passed = data.passed
        curTest.results = data.results
    end

    usingClipboard = false
    updateNUI()
    cb('ok')
end)

RegisterNetEvent("drivingInstructor:instructorToggle")
AddEventHandler("drivingInstructor:instructorToggle", function(mode, name)
    isInstructorMode = mode

    if name then
        curTest.instructor = name
    end

    updateInstructor()
end)

RegisterNetEvent("drivingInstructor:testToggle")
AddEventHandler("drivingInstructor:testToggle", function()
    if not isInstructorMode then
        if usingClipboard then
            usingClipboard = false
            updateNUI()
        else
            BJCore.Functions.Notify("You must be in driving instructor mode to do this", "error")
        end
    else
        usingClipboard = not usingClipboard

        updateNUI()
    end
end)

RegisterNetEvent("drivingInstructor:submitTest")
AddEventHandler("drivingInstructor:submitTest", function()
    if not isInstructorMode then
        BJCore.Functions.Notify("You must be in driving instructor mode to do this", "error")
        return
    end

    if curTest.cid == nil  then
        BJCore.Functions.Notify("You have not filled out the persons CID", "error")
        return
    end

    TriggerServerEvent('driving:submitTest', curTest)
end)

RegisterNetEvent("drivingInstructor:viewResults")
AddEventHandler("drivingInstructor:viewResults", function(testData)
    usingClipboard = true

    updateNUI(testData)
end)

RegisterNetEvent("drivingInstructor:vehicleAction")
AddEventHandler("drivingInstructor:vehicleAction", function(action)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 then
        actions.isBraking = false
        return
    else
        actions.vehicle = vehicle
    end

    if action == 1 then -- Brake
        actions.isBraking = true
        Citizen.CreateThread(function()
            local veh = actions.vehicle -- Localize here incase vehicle changes at some point before turning brakes back off
            local ped = PlayerPedId()
            while actions.isBraking do
                TaskVehicleTempAction(ped, veh, 24, 1)
                Citizen.Wait(0)
            end
        end)
    elseif action == 2 then -- Release Brake
        actions.isBraking = false
    elseif action == 3 then -- Engine Toggle
        if GetIsVehicleEngineRunning(actions.vehicle) then -- Turn Off
            SetVehicleEngineOn(actions.vehicle,0,1,1)
            SetVehicleUndriveable(actions.vehicle, true)
        else -- Turn On
            SetVehicleEngineOn(actions.vehicle,1,1,1)
            SetVehicleUndriveable(actions.vehicle, false)
        end
    elseif action == 4 then
        actions.isHornOn = true
        Citizen.CreateThread(function()
            local veh = actions.vehicle
            while actions.isHornOn do
                SetControlNormal(0, 86, 1.0)
                Citizen.Wait(0)
            end
        end)
    elseif action == 5 then
        actions.isHornOn = false
        SetControlNormal(0, 86, 0.0)
    elseif action == 6 then -- Instructor is no longer in control, clear any of their actions
        actions.isBraking = false
    end
end)

RegisterNetEvent("drivingInstructor:clipboard")
AddEventHandler("drivingInstructor:clipboard", function(isWriting)
    local ped = PlayerPedId()
    local anim = "amb@world_human_clipboard@male@base"
    local board = "clipboard01"
    if isWriting then
        anim = "amb@medic@standing@timeofdeath@base"
        board = "clipboard02"
    end

    RequestAnimDict(anim)
    while not HasAnimDictLoaded(anim) do
        Citizen.Wait(0)
    end

    if usingClipboard then
        local intrunk = PlayerData.metadata["intrunk"]
        if not intrunk then
            TaskPlayAnim(ped, anim, "base", 2.0, 3.0, -1, 49, 0, 0, 0, 0)
        end
        Citizen.Wait(450)

        TriggerEvent("attachItem",board)
        Citizen.Wait(150)

        while usingClipboard do
            local dead = PlayerData.metadata["isdead"]
            if dead then
                usingClipboard = false
                updateNUI()
            end
            intrunk = PlayerData.metadata["intrunk"]
            if not intrunk and not IsEntityPlayingAnim(ped, anim, "base", 3) then
                TaskPlayAnim(ped, anim, "base", 2.0, 3.0, -1, 49, 0, 0, 0, 0)
            end
            Citizen.Wait(1)
        end

        intrunk = PlayerData.metadata["intrunk"]
        if not intrunk then
            ClearPedTasks(ped)
        end
        TriggerEvent("destroyProp")
    else
        TriggerEvent("destroyProp")
        intrunk = PlayerData.metadata["intrunk"]
        if not intrunk then
            ClearPedTasks(ped)
            Citizen.Wait(400)
            TaskPlayAnim(ped, anim, "exit", 2.0, 1.0, 5.0, 49, 0, 0, 0, 0)
            Citizen.Wait(400)
            ClearPedTasks(ped)
        end
    end
end)

function MenuGarage()
    TriggerEvent('police:client:pauseKeybind', true)
    ped = PlayerPedId();
    MenuTitle = "Garage"
    ClearMenu()
    Menu.addButton("Vehicles", "VehicleList", nil)
    Menu.addButton("Close menu", "closeMenuFull", nil)
end

local ConfigVehicles = {
    ["asea"] = "Asea"
}
function VehicleList(isDown)
    ped = PlayerPedId();
    MenuTitle = "Vehicles:"
    ClearMenu()
    for k, v in pairs(ConfigVehicles) do
        Menu.addButton(ConfigVehicles[k], "TakeOutVehicle", k, "Garage", " Engine: 100%", " Body: 100%", " Fuel: 100%")
    end  
    Menu.addButton("Back", "MenuGarage",nil)
end

function TakeOutVehicle(vehicleInfo)
    local coords = garage
    BJCore.Functions.SpawnVehicle(vehicleInfo, function(veh)
        SetVehicleNumberPlateText(veh, "LEARN"..tostring(math.random(100, 999)))
        SetEntityHeading(veh, coords.w)
        exports['legacyfuel']:SetFuel(veh, 100.0)
        closeMenuFull()
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        TriggerEvent('keys:addNew', veh, GetVehicleNumberPlateText(veh))
        SetVehicleEngineOn(veh, true, true)
    end, coords, true)
end

function closeMenuFull()
    TriggerEvent('police:client:pauseKeybind', false)
    Menu.hidden = true
    currentGarage = nil
    ClearMenu()
end

RegisterNetEvent('BJCore:Player:SetPlayerData')
AddEventHandler('BJCore:Player:SetPlayerData', function(Player)
    PlayerData = Player
end)

RegisterNetEvent('BJCore:Client:OnPlayerLoaded')
AddEventHandler('BJCore:Client:OnPlayerLoaded', function()
    if PlayerData.job.name == "drivinginstructor" then
        checkForDrivingSchool()
    end
end)

RegisterNetEvent('BJCore:Client:OnJobUpdate')
AddEventHandler('BJCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
    if JobInfo.name == "drivinginstructor" then
        checkForDrivingSchool()
    end
end)

RegisterNetEvent('BJCore:Client:OnPlayerUnload')
AddEventHandler('BJCore:Client:OnPlayerUnload', function()
    PlayerData = {}
end)