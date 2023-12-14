isLoggedIn = false
PlayerData = nil

RegisterNetEvent('BJCore:Player:SetPlayerData')
AddEventHandler('BJCore:Player:SetPlayerData', function(val)
    PlayerData = val
end)

local choosingSpawn = false
local cam = nil

RegisterNetEvent('bj-spawnlocation:client:openUI')
AddEventHandler('bj-spawnlocation:client:openUI', function(value)
    if choosingSpawn then return; end
    -- print("spawn fade: "..tostring(IsScreenFadedOut()))
    -- print("jail: "..tostring(PlayerData.metadata["injail"]))
    -- print("dead: "..tostring(PlayerData.metadata["isdead"]))
    -- print("char id: "..tostring(PlayerData.cid))
    while not BJCore.Functions.IsPlayerLoaded() do Citizen.Wait(250); end
    Citizen.Wait(100)
    BJCore.Functions.TriggerServerCallback("bj-spawnlocation:server:getProperties", function(properties)
        print("[SPAWN] before spawn select: "..GetEntityModel(PlayerPedId()))
        FreezeEntityPosition(PlayerPedId(), true)
        cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", 195.17, -933.77, 29.7 + 150, -85.00, 0.00, 0.00, 100.00, false, 0)
        SetCamActive(cam, true)
        RenderScriptCams(true, false, 1, true, true)
        Citizen.Wait(500)
        if PlayerData.metadata["injail"] > 0 or PlayerData.metadata["isdead"] then
            choosingSpawn = true
            RenderScriptCams(false, true, 500, true, true)
            SetCamActive(cam, false)
            DestroyCam(cam, true)
            SetNuiFocus(false, false)
            SendNUIMessage({
                type = "ui",
                status = false
            })    
            if PlayerData.metadata["injail"] > 0 then
                TriggerEvent("chatMessage", "SYSTEM", "warning", "You have been put back into jail to serve the remainder of your sentence")                    
                FreezeEntityPosition(PlayerPedId(), false)
                TriggerEvent("prison:client:Enter", PlayerData.metadata["injail"])
                choosingSpawn = false             
            elseif PlayerData.metadata["isdead"] then
                --FreezeEntityPosition(PlayerPedId(), true)
                TriggerEvent("chatMessage", "SYSTEM", "warning", "You last left/disconnect while dead. You\'ll spawn in dead at your last saved position")
                spawnLastPos()
                choosingSpawn = false
            end       
        else
            if properties ~= nil and next(properties) ~= nil then
                if properties["houses"] ~= nil then
                    for k,v in pairs(properties["houses"]) do
                        properties["houses"][k].address = exports["houses"]:GetHouseAddress(v.house)
                    end
                end
                
                if properties["apartments"] ~= nil then
                    for k,v in pairs(properties["apartments"]) do
                        properties["apartments"][k].address = exports["apartments"]:GetBuildingLabel(v.building).." #"..v.id
                    end
                end
                print(BJCore.Common.Dump(properties))
                SendNUIMessage({
                    type = 'properties',
                    properties = properties
                })
            end
            SetDisplay(value)
        end
    end)
end)

function spawnLastPos()   
    SetDisplay(false)
    RequestCollisionAtCoord(PlayerData.position.x, PlayerData.position.y, PlayerData.position.z)
    local time = GetGameTimer()
    while (not HasCollisionLoadedAroundEntity(PlayerPedId()) and (GetGameTimer() - time) < 5000) do print("[SPAWN] waiting for collision") Citizen.Wait(0); end        
    SetEntityCoords(PlayerPedId(), PlayerData.position.x, PlayerData.position.y, PlayerData.position.z)
    Citizen.Wait(1000)
    FreezeEntityPosition(PlayerPedId(), false)
    Citizen.Wait(1000)
    RenderScriptCams(false, true, 500, true, true)
    SetCamActive(cam, false)
    DestroyCam(cam, true)
    Citizen.Wait(500)
    DoScreenFadeIn(3000)
end

RegisterNUICallback("exit", function(data)
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = "ui",
        status = false
    })
    choosingSpawn = false
end)

RegisterNUICallback('setCam', function(data)
    local location = tostring(data.posname)

    if location == "current" then
        local campos = PlayerData.position

        cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", campos.x, campos.y, campos.z + 150, -85.00, 0.00, 0.00, 100.00, false, 0)
        SetCamActive(cam, true)
        RenderScriptCams(true, false, 1, true, true)
    elseif location == "property" then
        local pos = exports["houses"]:GetHousePos(data.key)
        if pos then
            cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", pos.x, pos.y, pos.z + 150, -85.00, 0.00, 0.00, 100.00, false, 0)
            SetCamActive(cam, true)
            RenderScriptCams(true, false, 1, true, true)
        end
    elseif location == "apartment" then
        local pos = exports["apartments"]:GetBuildingPos(data.key)
        if pos then
            cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", pos.x, pos.y, pos.z + 150, -85.00, 0.00, 0.00, 100.00, false, 0)
            SetCamActive(cam, true)
            RenderScriptCams(true, false, 1, true, true)
        end
    else
        local campos = BJ.Locations[location].coords

        cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", campos.x, campos.y, campos.z + 150, -85.00, 0.00, 0.00, 100.00, false, 0)
        SetCamActive(cam, true)
        RenderScriptCams(true, false, 1, true, true)
    end
end)

RegisterNUICallback('spawnplayer', function(data)
    while PlayerData == nil do
        print("[SPAWN] spawn select waiting for playerdata")
        Wait(10)
    end
    local location = tostring(data.spawnloc)
    local ped = PlayerPedId()
    print("[SPAWN] on tp spawn select: "..GetEntityModel(PlayerPedId()))
    if location == "current" then
        print("[SPAWN] spawning latest pos: "..PlayerData.position.x.." "..PlayerData.position.y.." "..PlayerData.position.z)
        SetDisplay(false)
        DoScreenFadeOut(2000)
        Citizen.Wait(2000)
        RequestCollisionAtCoord(PlayerData.position.x, PlayerData.position.y, PlayerData.position.z)
        local time = GetGameTimer()
        while (not HasCollisionLoadedAroundEntity(ped) and (GetGameTimer() - time) < 6000) do print("[SPAWN] waiting for collision around player") Citizen.Wait(0); end     
        SetEntityCoords(ped, PlayerData.position.x, PlayerData.position.y, PlayerData.position.z)
        Citizen.Wait(1000)
        FreezeEntityPosition(ped, false)
        Citizen.Wait(1000)
        RenderScriptCams(false, true, 500, true, true)
        SetCamActive(cam, false)
        DestroyCam(cam, true)
        Citizen.Wait(500)
        DoScreenFadeIn(3000)
    elseif location == "property" then
        print("[SPAWN] spawning at property: "..data.key)
        SetDisplay(false)
        DoScreenFadeOut(2000)
        Citizen.Wait(2000)
        local propertyEnter = exports["houses"]:GetHousePos(data.key)
        SetEntityCoords(ped, propertyEnter.x, propertyEnter.y, propertyEnter.z)
        RequestCollisionAtCoord(propertyEnter.x, propertyEnter.y, propertyEnter.z)
        local time = GetGameTimer()
        while (not HasCollisionLoadedAroundEntity(ped) and (GetGameTimer() - time) < 6000) do print("[SPAWN] waiting for collision around player") Citizen.Wait(0); end
        TriggerEvent("bj-houses:client:SetClosestHouse")
        RenderScriptCams(false, true, 500, true, true)
        SetCamActive(cam, false)
        DestroyCam(cam, true)
        Wait(1500)        
        exports["houses"]:enterOwnedHouse(data.key)
    elseif location == "apartment" then
        print("[SPAWN] spawning at apartment: "..data.key)
        SetDisplay(false)
        DoScreenFadeOut(2000)
        Citizen.Wait(2000)
        local propertyEnter = exports["apartments"]:GetBuildingPos(data.key)
        SetEntityCoords(ped, propertyEnter.x, propertyEnter.y, propertyEnter.z)
        RequestCollisionAtCoord(propertyEnter.x, propertyEnter.y, propertyEnter.z)
        local time = GetGameTimer()
        while (not HasCollisionLoadedAroundEntity(ped) and (GetGameTimer() - time) < 6000) do print("[SPAWN] waiting for collision around player") Citizen.Wait(0); end
        RenderScriptCams(false, true, 500, true, true)
        SetCamActive(cam, false)
        DestroyCam(cam, true)
        Wait(1500)        
        exports["apartments"]:EnterOwnedApartment(data.key)
    else
        local pos = BJ.Locations[location].coords
        print("[SPAWN] spawning selected pos: "..BJCore.Common.Dump(pos))
        SetDisplay(false)
        DoScreenFadeOut(2000)
        Citizen.Wait(2000)
        local time = GetGameTimer()
        while (not HasCollisionLoadedAroundEntity(ped) and (GetGameTimer() - time) < 6000) do print("[SPAWN] waiting for collision around player") Citizen.Wait(0); end       
        SetEntityCoords(ped, pos.x, pos.y, pos.z)
        SetEntityHeading(ped, pos.h)
        Citizen.Wait(1000)
        FreezeEntityPosition(ped, false)
        Citizen.Wait(1000)        
        RenderScriptCams(false, true, 500, true, true)
        SetCamActive(cam, false)
        DestroyCam(cam, true)
        Citizen.Wait(500)
        DoScreenFadeIn(3000)
    end
end)

function SetDisplay(bool)
    choosingSpawn = bool
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        type = "ui",
        status = bool
    })
    if bool and IsScreenFadedOut() then
        DoScreenFadeIn(1000)
        Wait(1000)
    end
end

-- Citizen.CreateThread(function()
--     while true do
--         Citizen.Wait(0)

--         if IsDisabledControlJustPressed(0, BJCore.Functions.getKey("H")) then
--             SetDisplay(true)
--             Citizen.Wait(3000)
--         end
--     end
-- end)

Citizen.CreateThread(function()
    while choosingSpawn do
        Citizen.Wait(0)

        DisableAllControlActions(0)
    end
end)

RegisterNetEvent('BJCore:Client:OnPlayerLoaded')
AddEventHandler('BJCore:Client:OnPlayerLoaded', function()
    isLoggedIn = true
end)

RegisterNetEvent('BJCore:Client:OnPlayerUnload')
AddEventHandler('BJCore:Client:OnPlayerUnload', function()
    isLoggedIn = false
    PlayerData = {}
end)

RegisterNetEvent('BJCore:Player:SetPlayerData')
AddEventHandler('BJCore:Player:SetPlayerData', function(Player)
    PlayerData = Player
end)