local currentGarage = 1
local allowedDepartmentCodes = {
    ["C"] = true, -- CID
    ["N"] = true, -- Narc
    ["S"] = true, -- Swat
}
Citizen.CreateThread(function()
    local LastScanned = 0
    local MRPDDetector = vector3(441.06, -989.23, 30.69)
    while BJCore == nil do
        Citizen.Wait(200)
    end
    local ishc = IsUCWhitelist()
    while true do
        Citizen.Wait(1)
        if isLoggedIn then
            local pos = GetEntityCoords(PlayerPedId())
            local nearby = false
            if PlayerJob.name ~= "police" and #(pos - MRPDDetector) < 5 then
                nearby = true
                if #(pos - MRPDDetector) < 0.7 and GetGameTimer() - LastScanned > 7000 then
                    LastScanned = GetGameTimer()
                    BJCore.Functions.Notify("Scanning... Please wait", "primary", 1500)
                    Wait(1500)
                    TriggerServerEvent('police:server:CheckForWeapons')
                end
            end
            if PlayerJob.name == "police" then    
                local nearby = false

                for k, v in pairs(Config.Locations["duty"]) do
                    if #(pos - v) < 5 then
                        nearby = true
                        if #(pos - v) < 1.5 then
                            if not onDuty then
                                BJCore.Functions.DrawText3D(v.x, v.y, v.z, "[~g~E~w~] Get on duty", 0.7)
                            else
                                BJCore.Functions.DrawText3D(v.x, v.y, v.z, "[~r~E~w~] Get off duty", 0.7)
                            end
                            if IsControlJustReleased(0, Keys["E"]) then
                                --onDuty = not onDuty
                                TriggerServerEvent("BJCore:ToggleDuty")
                                TriggerServerEvent("police:server:UpdateCurrentCops")
                                TriggerServerEvent("police:server:UpdateBlips")
                                TriggerEvent('qb-policealerts:ToggleDuty', onDuty)
                            end
                        -- elseif #(pos - v) < 2.5) then
                        --     BJCore.Functions.DrawText3D(v.x, v.y, v.z, "on/off duty")
                        end
                    end
                end

                for k, v in pairs(Config.Locations["evidence"]) do
                    if #(pos - v) < 5 then
                        nearby = true
                        if #(pos - v) < 1.0 then
                            BJCore.Functions.DrawText3D(v.x, v.y, v.z, "[~g~E~w~] Evidence Locker", 0.7)
                            if IsControlJustReleased(0, Keys["E"]) then
                                local lockerNum = getInput('Input')
                                local validInput = false
                                if lockerNum then
                                    if type(tonumber(lockerNum)) == "number" then
                                        validInput = true
                                    end
                                    if #lockerNum > 1 and allowedDepartmentCodes[string.sub(lockerNum, 1, 1)] and type(tonumber(string.sub(lockerNum, 2))) == "number" then
                                        validInput = true
                                    end
                                end
                                if validInput then 
                                    TriggerServerEvent("inventory:server:OpenInventory", "stash", "policeevidence_"..lockerNum, {
                                        maxweight = 4000000,
                                        slots = 500,
                                    }, "Police Evidence: "..lockerNum)
                                    TriggerEvent("inventory:client:SetCurrentStash", "policeevidence_"..lockerNum)
                                else
                                    SetTimecycleModifier('default')
                                    exports['core']:SendAlert('error', 'Input only numbers or department codes', 2500) 
                                end
                            end
                        -- elseif #(pos.x, pos.y, pos.z, v) < 1.5) then
                        --     BJCore.Functions.DrawText3D(v.x, v.y, v.z, "evidence stash")
                        end
                    end
                end

                for k, v in pairs(Config.Locations["trash"]) do
                    if #(pos - v) < 5 then
                        nearby = true
                        if #(pos - v) < 1.0 then
                            BJCore.Functions.DrawText3D(v.x, v.y, v.z, "[~g~E~w~] Trash", 0.7)
                            if IsControlJustReleased(0, Keys["E"]) then
                                TriggerServerEvent("inventory:server:OpenInventory", "bin", "policetrash", {
                                    maxweight = 4000000,
                                    slots = 300,
                                }, "Trash Locker")
                                TriggerEvent("inventory:client:SetCurrentBin", "policetrash")
                            end
                        -- elseif #(pos.x, pos.y, pos.z, v) < 1.5) then
                        --     BJCore.Functions.DrawText3D(v.x, v.y, v.z, "Bin")
                        end
                    end
                end

                for k, v in pairs(Config.Locations["vehicle"]) do
                    if #(pos.xyz - v.xyz) < 10.0 then
                        if onDuty then
                            nearby = true
                            DrawMarker(2, v.x, v.y, v.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 255, 255, 255, 222, false, false, false, true, false, false, false)
                            if #(pos.xyz - v.xyz) < 1.5 then
                                if IsPedInAnyVehicle(PlayerPedId(), false) then
                                    BJCore.Functions.DrawText3D(v.x, v.y, v.z, "[~g~E~w~] Store Vehicle", 0.7)
                                else
                                    BJCore.Functions.DrawText3D(v.x, v.y, v.z, "[~g~E~w~] Vehicles", 0.7)
                                end
                                if IsControlJustReleased(0, Keys["E"]) then
                                    if IsPedInAnyVehicle(PlayerPedId(), false) then
                                        BJCore.Functions.DeleteVehicle(GetVehiclePedIsIn(PlayerPedId()))
                                    else
                                        MenuGarage()
                                        currentGarage = k
                                        Menu.hidden = not Menu.hidden
                                    end
                                end
                                if IsControlJustPressed(1, 177) and not Menu.hidden then
                                    close()
                                    PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                                end
                                Menu.renderGUI()
                            end  
                        end
                    end
                end

                for k, v in pairs(Config.Locations["impound"]) do
                    if #(pos.xyz - v.xyz) < 10.0 then
                        if onDuty then
                            nearby = true
                            DrawMarker(2, v.x, v.y, v.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 0, 0, 222, false, false, false, true, false, false, false)
                            if #(pos.xyz - v.xyz) < 1.5 then
                                if IsPedInAnyVehicle(PlayerPedId(), false) then
                                    BJCore.Functions.DrawText3D(v.x, v.y, v.z, "[~g~E~w~] Store Vehicle", 0.7)
                                else
                                    BJCore.Functions.DrawText3D(v.x, v.y, v.z, "[~g~E~w~] Police Impound", 0.7)
                                end
                                if IsControlJustReleased(0, Keys["E"]) then
                                    if IsPedInAnyVehicle(PlayerPedId(), false) then
                                        BJCore.Functions.DeleteVehicle(GetVehiclePedIsIn(PlayerPedId()))
                                    else
                                        MenuImpound()
                                        currentGarage = k
                                        Menu.hidden = not Menu.hidden
                                    end
                                end
                                if IsControlJustPressed(1, 177) and not Menu.hidden then
                                    close()
                                    PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                                end
                                Menu.renderGUI()
                            end  
                        end
                    end
                end

                for k, v in pairs(Config.Locations["boat"]) do
                    if #(pos.xyz - v["garage"]) < 10.0 then
                        if onDuty then
                            nearby = true
                            DrawMarker(2, v.x, v.y, v.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 255, 255, 255, 222, false, false, false, true, false, false, false)
                            if #(pos.xyz - v["garage"]) < 1.5 then
                                BJCore.Functions.DrawText3D(v["garage"].x, v["garage"].y, v["garage"].z, "[~g~E~w~] Police Boat", 0.7)
                                if IsControlJustReleased(0, Keys["E"]) then
                                    BJCore.Functions.SpawnVehicle(Config.Boat, function(veh)
                                        SetVehicleLivery(veh, 0)
                                        SetVehicleNumberPlateText(veh, "ZULU"..tostring(math.random(1000, 9999)))
                                        SetEntityHeading(veh, v["spawn"].w)
                                        exports['legacyfuel']:SetFuel(veh, 100.0)
                                        TriggerEvent('keys:addNew', veh, GetVehicleNumberPlateText(veh))
                                        closeMenuFull()
                                        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
                                        TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(veh))
                                        SetVehicleEngineOn(veh, true, true)
                                    end, v["spawn"], true)
                                end
                            end  
                        end
                    end
                    if #(pos.xyz - v["spawn"].xyz) < 10.0 then
                        if onDuty and IsPedInAnyBoat(PlayerPedId()) then
                            nearby = true
                            DrawMarker(2, v["spawn"].x, v["spawn"].y, v["spawn"].z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 255, 255, 255, 222, false, false, false, true, false, false, false)
                            if #(pos.xyz - v["spawn"].xyz) < 1.5 then
                                BJCore.Functions.DrawText3D(v["spawn"].x, v["spawn"].y, v["spawn"].z, "[~g~E~w~] Store Boat", 0.7)
                                if IsControlJustReleased(0, Keys["E"]) then
                                    BJCore.Functions.DeleteVehicle(GetVehiclePedIsIn(PlayerPedId()))
                                end
                            end  
                        end
                    end
                end

                for k, v in pairs(Config.Locations["helicopter"]) do
                    if #(pos.xyz - v.xyz) < 7.5 then
                        if onDuty then
                            nearby = true
                            DrawMarker(2, v.x, v.y, v.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 0, 0, 222, false, false, false, true, false, false, false)
                            if #(pos.xyz - v.xyz) < 1.5 then
                                if IsPedInAnyVehicle(PlayerPedId(), false) then
                                    BJCore.Functions.DrawText3D(v.x, v.y, v.z, "[~g~E~w~] Store Heli", 0.7)
                                else
                                    BJCore.Functions.DrawText3D(v.x, v.y, v.z, "[~g~E~w~] Take out Heli", 0.7)
                                end
                                if IsControlJustReleased(0, Keys["E"]) then
                                    if IsPedInAnyVehicle(PlayerPedId(), false) then
                                        BJCore.Functions.DeleteVehicle(GetVehiclePedIsIn(PlayerPedId()))
                                    else
                                        local coords = Config.Locations["helicopter"][k]
                                        BJCore.Functions.SpawnVehicle(Config.Helicopter, function(veh)
                                            SetVehicleLivery(veh, 0)
                                            SetVehicleNumberPlateText(veh, "ZULU"..tostring(math.random(1000, 9999)))
                                            SetEntityHeading(veh, coords.w)
                                            exports['legacyfuel']:SetFuel(veh, 100.0)
                                            TriggerEvent('keys:addNew', veh, GetVehicleNumberPlateText(veh))
                                            closeMenuFull()
                                            TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
                                            TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(veh))
                                            SetVehicleEngineOn(veh, true, true)
                                        end, coords, true)
                                    end
                                end
                            end  
                        end
                    end
                end

                for k, v in pairs(Config.Locations["armory"]) do
                    --if #(pos - v) < 5.0) and IsArmoryWhitelist() then
                    if #(pos - v) < 5.0 then                        
                        if onDuty then
                            nearby = true
                            if #(pos - v) < 1.5 then
                                BJCore.Functions.DrawText3D(v.x, v.y, v.z, "[~g~E~w~] Armory", 0.7)
                                if IsControlJustReleased(0, Keys["E"]) then
                                    SetWeaponSerials()
                                    TriggerServerEvent("inventory:server:OpenInventory", "shop", "police", Config.Items)
                                end
                            -- elseif #(pos - v) < 2.5 then
                            --     BJCore.Functions.DrawText3D(v.x, v.y, v.z, "Armory")
                            end  
                        end
                    end
                end

                for k, v in pairs(Config.Locations["stash"]) do
                    if #(pos - v) < 5.0 then
                        if onDuty then
                            nearby = true
                            if #(pos - v) < 1.5 then
                                BJCore.Functions.DrawText3D(v.x, v.y, v.z, "[~g~E~w~] Personal Locker", 0.7)
                                if IsControlJustReleased(0, Keys["E"]) then
                                    TriggerServerEvent("inventory:server:OpenInventory", "stash", "policestash_"..BJCore.Functions.GetPlayerData().citizenid, nil, "Personal Locker: "..BJCore.Functions.GetPlayerData().citizenid)
                                    TriggerEvent("inventory:client:SetCurrentStash", "policestash_"..BJCore.Functions.GetPlayerData().citizenid)
                                end
                            -- elseif #(pos - v) < 2.5 then
                            --     BJCore.Functions.DrawText3D(v.x, v.y, v.z, "Personal stash")
                            end  
                        end
                    end
                end

                for k, v in pairs(Config.Locations["fingerprint"]) do
                    if #(pos - v) < 5.0 then
                        if onDuty then
                            nearby = true
                            if #(pos - v) < 1.5 then
                                BJCore.Functions.DrawText3D(v.x, v.y, v.z, "[~g~E~w~] Scan Fingerprint", 0.7)
                                if IsControlJustReleased(0, Keys["E"]) then
                                    local player, distance = GetClosestPlayer()
                                    if player ~= -1 and distance < 2.5 then
                                        local playerId = GetPlayerServerId(player)
                                        TriggerServerEvent("police:server:showFingerprint", playerId)
                                    else
                                        BJCore.Functions.Notify("No one nearby", "error")
                                    end
                                end
                            -- elseif #(pos - v) < 2.5 then
                            --     BJCore.Functions.DrawText3D(v.x, v.y, v.z, "Finger scan")
                            end  
                        end
                    end
                end

                if ishc then
                    for k, v in pairs(Config.Locations["ids"]) do
                        if #(pos - v) < 5.0 then
                            if onDuty then
                                nearby = true
                                if #(pos - v) < 1.5 then
                                    BJCore.Functions.DrawText3D(v.x, v.y, v.z, "[~g~E~w~] Create ID", 0.7)
                                    if IsControlJustReleased(0, Keys["E"]) then
                                        local res, dataAdded = getIdMetadataInput()
                                        if dataAdded == 6 then
                                            TriggerServerEvent('police:server:createIdentityCard', res)
                                        else
                                            BJCore.Functions.Notify("All data must be input", "error")
                                        end
                                    end
                                -- elseif #(pos - v) < 2.5 then
                                --     BJCore.Functions.DrawText3D(v.x, v.y, v.z, "Finger scan")
                                end  
                            end
                        end
                    end
                end
                if not nearby then Citizen.Wait(1000); end
            else
                Citizen.Wait(2000)
            end
        end
    end
end)

AddTextEntry('idcard_citizenid', 'Citizen ID # | Example: ERA73291')
AddTextEntry('idcard_firstname', 'First Name')
AddTextEntry('idcard_lastname', 'Last Name')
AddTextEntry('idcard_gender', 'Gender | Enter 0 for male, 1 for female')
AddTextEntry('idcard_birthdate', 'Date of Birth | Format: YYYY-MM-DD')
AddTextEntry('idcard_nationality', 'Nationality')

local idMetadata = {
    'citizenid',
    'firstname',
    'lastname',
    'birthdate',
    'gender',
    'nationality'
}

function getIdMetadataInput()
    local newMetadata = {}
    local dataAdded = 0
    for _,v in ipairs(idMetadata) do
        newMetadata[v] = getInput('idcard_'..v)
        if newMetadata[v] and newMetadata[v] ~= '' then
            dataAdded = dataAdded + 1
        end
    end
    SetTimecycleModifier('default')
    return newMetadata, dataAdded
end

local performanceModIndices = {11,12,13,16}
function PerformanceUpgradeVehicle(vehicle, customWheels)
    customWheels = customWheels or false
    local max
    if DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle) then
        for _, modType in ipairs(performanceModIndices) do
            max = GetNumVehicleMods(vehicle, modType) - 1
            SetVehicleMod(vehicle, modType, max, customWheels)
        end
        if GetEntityModel(Vehicle) ~= GetHashKey('crownvic') then
            ToggleVehicleMod(vehicle, 18, true) -- Turbo
        end
    end
end

AddTextEntry('Input', 'Input Report/Evidence # | e.g 123456')
function getInput(titleText)
    SetTimecycleModifier('hud_def_blur')
    DisplayOnscreenKeyboard(0, titleText, "P2", "", "", "", "", 10)
    while true do
        Citizen.Wait(0)
        local status = UpdateOnscreenKeyboard()
        if status == 1 then
            return GetOnscreenKeyboardResult()
        elseif status == 2 then
            return
        elseif status == 3 then
            return
        end
    end
end

local inFingerprint = false
local FingerPrintSessionId = nil

RegisterNetEvent('police:client:showFingerprint')
AddEventHandler('police:client:showFingerprint', function(playerId)
    openFingerprintUI()
    FingerPrintSessionId = playerId
end)

RegisterNetEvent('police:client:showFingerprintId')
AddEventHandler('police:client:showFingerprintId', function(fid)
    SendNUIMessage({
        type = "updateFingerprintId",
        fingerprintId = fid
    })
    PlaySound(-1, "Event_Start_Text", "GTAO_FM_Events_Soundset", 0, 0, 1)
end)

RegisterNUICallback('doFingerScan', function(data)
    TriggerServerEvent('police:server:showFingerprintId', FingerPrintSessionId)
end)

function openFingerprintUI()
    SendNUIMessage({
        type = "fingerprintOpen"
    })
    inFingerprint = true
    SetNuiFocus(true, true)
end

RegisterNUICallback('closeFingerprint', function()
    SetNuiFocus(false, false)
    inFingerprint = false
end)

RegisterNetEvent('police:client:SendEmergencyMessage')
AddEventHandler('police:client:SendEmergencyMessage', function(message)
    local coords = GetEntityCoords(PlayerPedId())
    
    TriggerServerEvent("police:server:SendEmergencyMessage", coords, message)
    TriggerEvent("police:client:CallAnim")
end)

RegisterNetEvent('police:client:Send311Message')
AddEventHandler('police:client:Send311Message', function(message)
    local coords = GetEntityCoords(PlayerPedId())
    
    TriggerServerEvent("police:server:Send311Message", coords, message)
    TriggerEvent("police:client:CallAnim")
end)

RegisterNetEvent('police:client:EmergencySound')
AddEventHandler('police:client:EmergencySound', function()
    PlaySound(-1, "Event_Start_Text", "GTAO_FM_Events_Soundset", 0, 0, 1)
end)

RegisterNetEvent('police:client:CallAnim')
AddEventHandler('police:client:CallAnim', function()
    local isCalling = true
    local callCount = 5
    loadAnimDict("cellphone@")   
    TaskPlayAnim(PlayerPedId(), 'cellphone@', 'cellphone_call_listen_base', 3.0, -1, -1, 49, 0, false, false, false)
    Citizen.Wait(1000)
    Citizen.CreateThread(function()
        while isCalling do
            Citizen.Wait(1000)
            callCount = callCount - 1
            if callCount <= 0 then
                isCalling = false
                StopAnimTask(PlayerPedId(), 'cellphone@', 'cellphone_call_listen_base', 1.0)
            end
        end
    end)
end)

RegisterNetEvent('police:client:ImpoundVehicle')
AddEventHandler('police:client:ImpoundVehicle', function(fullImpound, price)
    local vehicle = BJCore.Functions.GetClosestVehicle()
    if vehicle ~= 0 and vehicle ~= nil then
        local pos = GetEntityCoords(PlayerPedId())
        local vehpos = GetEntityCoords(vehicle)
        if #(pos - vehpos) < 2.0 and not IsPedInAnyVehicle(PlayerPedId()) then
            local plate = GetVehicleNumberPlateText(vehicle)
            exports['mythic_progbar']:Progress({
                name = "impound_vehicle",
                duration = math.random(2000,3000),
                label = "Impounding",
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
                    TriggerServerEvent("police:server:Impound", plate, fullImpound, price)
                    TriggerServerEvent("BJCore:RequestVehicleDelete", VehToNet(vehicle))
                    --BJCore.Functions.DeleteVehicle(vehicle)
                else
                    BJCore.Functions.Notify("Cancelled", "error")
                end
            end)            
        end
    end
end)

RegisterNetEvent('police:client:CheckStatus')
AddEventHandler('police:client:CheckStatus', function()
    BJCore.Functions.GetPlayerData(function(PlayerData)
        local player, distance = GetClosestPlayer()
        if player ~= -1 and distance < 2.5 then
            local playerId = GetPlayerServerId(player)
            BJCore.Functions.TriggerServerCallback('police:GetPlayerStatus', function(result)
                if result ~= nil and #result > 0 then
                    for k, v in pairs(result) do
                        TriggerEvent("chatMessage", "STATUS", "warning", v)
                    end
                else
                    BJCore.Functions.Notify("Target has no status markers", "primary")
                end
            end, playerId)
        else
            BJCore.Functions.Notify("No one nearby", "error")
        end
    end)
end)

function MenuImpound()
    TriggerEvent('police:client:pauseKeybind', true)
    ped = PlayerPedId();
    MenuTitle = "Impounded"
    ClearMenu()
    Menu.addButton("Vehicles", "ImpoundVehicleList", nil)
    Menu.addButton("Close menu", "close", nil) 
end

function ImpoundVehicleList()
    BJCore.Functions.TriggerServerCallback("police:GetImpoundedVehicles", function(result)
        ped = PlayerPedId();
        MenuTitle = "Vehicles:"
        ClearMenu()

        if result == nil then
            BJCore.Functions.Notify("There are no impounded vehicles", "error", 5000)
            closeMenuFull()
        else
            for k, v in pairs(result) do
                enginePercent = round(v.engine / 10, 0)
                bodyPercent = round(v.body / 10, 0)
                currentFuel = v.fuel

                Menu.addButton(BJCore.Shared.VehicleModels[tonumber(v.hash)]["name"].." | "..v.plate, "TakeOutImpound", v, "Impounded", " Engine: " .. enginePercent .. "%", " Body: " .. bodyPercent.. "%", " Fuel: "..currentFuel.. "%")
            end
        end
            
        Menu.addButton("Back", "MenuImpound",nil)
    end)
end

function TakeOutImpound(vehicle)
    enginePercent = round(vehicle.engine / 10, 0)
    bodyPercent = round(vehicle.body / 10, 0)
    currentFuel = vehicle.fuel
    local coords = Config.Locations["impound"][currentGarage]
    BJCore.Functions.SpawnVehicle(vehicle.vehicle, function(veh)
        BJCore.Functions.TriggerServerCallback('garages:server:GetVehicleProperties', function(properties)
            BJCore.Functions.SetVehicleProperties(veh, properties)
            SetVehicleNumberPlateText(veh, vehicle.plate)
            SetEntityHeading(veh, coords.w)
            exports['legacyfuel']:SetFuel(veh, vehicle.fuel)
            doCarDamage(veh, vehicle)
            closeMenuFull()
            TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
            TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(veh))
            SetVehicleEngineOn(veh, true, true)
        end, vehicle.plate)
    end, coords, true)
end

function MenuOutfits()
    ped = PlayerPedId();
    MenuTitle = "Outfits"
    ClearMenu()
    Menu.addButton("My Outfits", "OutfitsLijst", nil)
    Menu.addButton("Close menu", "closeMenuFull", nil) 
end

function changeOutfit()
    Wait(200)
    loadAnimDict("clothingshirt")       
    TaskPlayAnim(PlayerPedId(), "clothingshirt", "try_shirt_positive_d", 8.0, 1.0, -1, 49, 0, 0, 0, 0)
    Wait(3100)
    TaskPlayAnim(PlayerPedId(), "clothingshirt", "exit", 8.0, 1.0, -1, 49, 0, 0, 0, 0)
end

function OutfitsLijst()
    BJCore.Functions.TriggerServerCallback('apartments:GetOutfits', function(outfits)
        ped = PlayerPedId();
        MenuTitle = "My Outfits :"
        ClearMenu()

        if outfits == nil then
            BJCore.Functions.Notify("You have no outfits saved...", "error", 3500)
            closeMenuFull()
        else
            for k, v in pairs(outfits) do
                Menu.addButton(outfits[k].outfitname, "optionMenu", outfits[k]) 
            end
        end
        Menu.addButton("Back", "MenuOutfits",nil)
    end)
end

function optionMenu(outfitData)
    ped = PlayerPedId();
    MenuTitle = "What now?"
    ClearMenu()

    Menu.addButton("Choose Outfit", "selectOutfit", outfitData) 
    Menu.addButton("Delete Outfit", "removeOutfit", outfitData) 
    Menu.addButton("Back", "OutfitsLijst",nil)
end

function selectOutfit(oData)
    TriggerServerEvent('clothes:selectOutfit', oData.model, oData.skin)
    BJCore.Functions.Notify(oData.outfitname.." chosen", "success", 2500)
    closeMenuFull()
    changeOutfit()
end

function removeOutfit(oData)
    TriggerServerEvent('clothes:removeOutfit', oData.outfitname)
    BJCore.Functions.Notify(oData.outfitname.." is deleted", "success", 2500)
    closeMenuFull()
end

function MenuGarage()
    TriggerEvent('police:client:pauseKeybind', true)
    ped = PlayerPedId();
    MenuTitle = "Garage"
    ClearMenu()
    Menu.addButton("Vehicles", "VehicleList", nil)
    Menu.addButton("Close menu", "close", nil) 
end

function close()
    TriggerEvent('police:client:pauseKeybind', false)
    Menu.hidden = true
end

function VehicleList(isDown)
    ped = PlayerPedId();
    MenuTitle = "Vehicles:"
    ClearMenu()
    for k, v in pairs(Config.Vehicles) do
        Menu.addButton(Config.Vehicles[k], "TakeOutVehicle", k, "Garage", " Engine: 100%", " Body: 100%", " Fuel: 100%")
    end
    if IsArmoryWhitelist() then
        for veh, label in pairs(Config.WhitelistedVehicles) do
            Menu.addButton(label, "TakeOutVehicle", veh, "Garage", " Engine: 100%", " Body: 100%", " Fuel: 100%")
        end
    end
    if IsSwatWhitelist() then
        for veh, label in pairs(Config.SwatVehicles) do
            Menu.addButton(label, "TakeOutVehicle", veh, "Garage", " Engine: 100%", " Body: 100%", " Fuel: 100%")
        end        
    end
    if IsUCWhitelist() then
        for veh, label in pairs(Config.UCVehicles) do
            Menu.addButton(label, "TakeOutVehicle", veh, "Garage", " Engine: 100%", " Body: 100%", " Fuel: 100%")
        end
    end   
    Menu.addButton("Back", "MenuGarage",nil)
end

function TakeOutVehicle(vehicleInfo)
    local coords = Config.Locations["vehicle"][currentGarage]
    print(BJCore.Common.Dump(vehicleInfo))

    BJCore.Functions.SpawnVehicle(vehicleInfo, function(veh)
        SetVehicleNumberPlateText(veh, "LSPD"..tostring(math.random(1000, 9999)))
        SetEntityHeading(veh, coords.w)
        PerformanceUpgradeVehicle(veh)
        for i = 1, 30 do
            SetVehicleExtra(veh, i, 0)
        end
        exports['legacyfuel']:SetFuel(veh, 100.0)
        close()
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        --TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(veh))
        TriggerEvent('keys:addNew', veh, GetVehicleNumberPlateText(veh))
        --TriggerServerEvent("inventory:server:addTrunkItems", GetVehicleNumberPlateText(veh), Config.CarItems)
        SetVehicleEngineOn(veh, true, true)
    end, coords, true)
end

function closeMenuFull()
    TriggerEvent('police:client:pauseKeybind', false)
    Menu.hidden = true
    currentGarage = nil
    ClearMenu()
end

function doCarDamage(currentVehicle, veh)
    smash = false
    damageOutside = false
    damageOutside2 = false 
    local engine = veh.engine + 0.0
    local body = veh.body + 0.0
    if engine < 200.0 then
        engine = 200.0
    end
    
    if engine  > 1000.0 then
        engine = 950.0
    end

    if body < 150.0 then
        body = 150.0
    end
    if body < 950.0 then
        smash = true
    end

    if body < 920.0 then
        damageOutside = true
    end

    if body < 920.0 then
        damageOutside2 = true
    end

    Citizen.Wait(100)
    SetVehicleEngineHealth(currentVehicle, engine)
    if smash then
        SmashVehicleWindow(currentVehicle, 0)
        SmashVehicleWindow(currentVehicle, 1)
        SmashVehicleWindow(currentVehicle, 2)
        SmashVehicleWindow(currentVehicle, 3)
        SmashVehicleWindow(currentVehicle, 4)
    end
    if damageOutside then
        SetVehicleDoorBroken(currentVehicle, 1, true)
        SetVehicleDoorBroken(currentVehicle, 6, true)
        SetVehicleDoorBroken(currentVehicle, 4, true)
    end
    if damageOutside2 then
        SetVehicleTyreBurst(currentVehicle, 1, false, 990.0)
        SetVehicleTyreBurst(currentVehicle, 2, false, 990.0)
        SetVehicleTyreBurst(currentVehicle, 3, false, 990.0)
        SetVehicleTyreBurst(currentVehicle, 4, false, 990.0)
    end
    if body < 1000 then
        SetVehicleBodyHealth(currentVehicle, 985.1)
    end
end

function SetCarItemsInfo()
    local items = {}
    for k, item in pairs(Config.CarItems) do
        local itemInfo = BJCore.Shared.Items[item.name:lower()]
        items[item.slot] = {
            name = itemInfo["name"],
            amount = tonumber(item.amount),
            info = item.info,
            label = itemInfo["label"],
            description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
            weight = itemInfo["weight"], 
            type = itemInfo["type"], 
            unique = itemInfo["unique"], 
            useable = itemInfo["useable"], 
            image = itemInfo["image"],
            slot = item.slot,
        }
    end
    Config.CarItems = items
end

function IsArmoryWhitelist()
    local retval = false
    local citizenid = BJCore.Functions.GetPlayerData().citizenid
    for k, v in pairs(Config.ArmoryWhitelist) do
        if v == citizenid then
            retval = true
            break
        end
    end
    return retval
end

function IsUCWhitelist()
    local retval = false
    local citizenid = BJCore.Functions.GetPlayerData().citizenid
    for k, v in pairs(Config.UCWhitelist) do
        if v == citizenid then
            retval = true
            break
        end
    end
    return retval
end

function IsSwatWhitelist()
    local retval = false
    local citizenid = BJCore.Functions.GetPlayerData().citizenid
    for k, v in pairs(Config.SwatWhitelist) do
        if v == citizenid then
            retval = true
            break
        end
    end
    return retval
end

function SetWeaponSerials()
    for k, v in pairs(Config.Items.items) do
        if k < 6 then
            Config.Items.items[k].info.serial = tostring("LSPD:"..BJCore.Functions.GetPlayerData().citizenid..":"..Config.RandomInt(2) .. Config.RandomStr(3) .. Config.RandomInt(1) .. Config.RandomStr(2) .. Config.RandomInt(3) .. Config.RandomStr(4))
        end
    end
end

function round(num, numDecimalPlaces)
    return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end