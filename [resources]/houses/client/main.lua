local Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, 
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177, 
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70, 
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
    ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local inside = false
local closesthouse = nil
local hasKey = false
local isOwned = false

local stashLoc = {}
local closetLoc = {}

local isLoggedIn = true
local contractOpen = false

local cam = nil
local viewCam = false

local curFurniture = false
local spawnedFurniture = {}

local inHoldersMenu = false

local HouseBlips = {}

RegisterNetEvent('BJCore:Client:OnPlayerLoaded')
AddEventHandler('BJCore:Client:OnPlayerLoaded', function()
    isLoggedIn = true
    TriggerEvent('bj-houses:client:setupHouseBlips')
    TriggerServerEvent("bj-houses:server:setHouses")
    ClosestThread()
end)

RegisterNetEvent('BJCore:Player:SetPlayerData')
AddEventHandler('BJCore:Player:SetPlayerData', function(Player)
    PlayerData = Player
end)

RegisterNetEvent('bj-houses:client:sellHouse')
AddEventHandler('bj-houses:client:sellHouse', function()
    if closesthouse ~= nil and hasKey then
        TriggerServerEvent('bj-houses:server:viewHouse', closesthouse)
    end
end)

RegisterNetEvent('BJCore:Client:OnPlayerUnload')
AddEventHandler('BJCore:Client:OnPlayerUnload', function()
    isLoggedIn = false
    for k,v in pairs(HouseBlips) do
        RemoveBlip(v)
    end
end)

function ClosestThread()
    Citizen.CreateThread(function()
        while isLoggedIn do
            if not inside then
                SetClosestHouse()
            end
            Citizen.Wait(5000)
        end
    end)
end

function doorText(x, y, z, text)
    SetTextScale(0.325, 0.325)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.011, -0.025+ factor, 0.03, 0, 0, 0, 68)
    ClearDrawOrigin()
end

local houseObj = {}
local POIOffsets = nil
local entering = false
local data = nil

RegisterNetEvent('bj-houses:client:setHouseConfig')
AddEventHandler('bj-houses:client:setHouseConfig', function(houseConfig)
    closesthouse = nil
    Config.Houses = houseConfig
end)

RegisterNetEvent('bj-houses:client:lockHouse')
AddEventHandler('bj-houses:client:lockHouse', function(bool, house)
    Config.Houses[house].locked = bool
end)

local raidHouse = {}
RegisterNetEvent("police:client:stormram")
AddEventHandler("police:client:stormram", function()
    local plyPed = PlayerPedId()
    local plyPos = GetEntityCoords(plyPed)
    if closesthouse ~= nil then
        if #(plyPos - Config.Houses[closesthouse].coords.enter.xyz) < 1.5 then
            exports['mythic_progbar']:Progress({
                name = "stormram",
                duration = math.random(15000, 20000),
                label = "Interacting",
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
                    TriggerServerEvent('bj-houses:server:lockHouse', false, closesthouse)
                    TriggerServerEvent("bj-houses:server:setRaid", closesthouse, true)
                else
                    BJCore.Functions.Notify("Cancelled", "error")
                end
            end)
        end
    end
end)

RegisterNetEvent("bj-houses:client:setRaid")
AddEventHandler("bj-houses:client:setRaid", function(data) raidHouse = data end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local plyPed = PlayerPedId()
        local pos = GetEntityCoords(plyPed, true)
        if closesthouse ~= nil then
            if #(pos.xy - Config.Houses[closesthouse].coords.enter.xy) < 20 then
                if hasKey or (PlayerData.job.name == "police" and raidHouse[closesthouse] == true) then
                    -- ENTER HOUSE
                    if not inside then
                        if closesthouse ~= nil then
                            if #(pos - Config.Houses[closesthouse].coords.enter.xyz) < 1.5 then
                                if Config.Houses[closesthouse].locked then
                                    doorText(Config.Houses[closesthouse].coords.enter.x, Config.Houses[closesthouse].coords.enter.y, Config.Houses[closesthouse].coords.enter.z + 1.2, '[~g~E~w~] Enter house | [~g~L~w~] House is ~r~locked')
                                    if IsControlJustPressed(0, Keys["L"]) then
                                        TriggerEvent('dooranim')
                                        TriggerEvent('InteractSound_CL:PlayOnOne', 'houses_door_unlock', 0.8)
                                        TriggerServerEvent('bj-houses:server:lockHouse', false, closesthouse)
                                    end
                                else
                                    doorText(Config.Houses[closesthouse].coords.enter.x, Config.Houses[closesthouse].coords.enter.y, Config.Houses[closesthouse].coords.enter.z + 1.2, '[~g~E~w~] Enter house | [~g~L~w~] House is ~b~unlocked')
                                    if IsControlJustPressed(0, Keys["L"]) then
                                        TriggerEvent('dooranim')
                                        TriggerEvent('InteractSound_CL:PlayOnOne', 'houses_door_lock', 0.8)
                                        TriggerServerEvent('bj-houses:server:lockHouse', true, closesthouse)
                                    end
                                end
                                if IsControlJustPressed(0, Keys["E"]) then
                                    enterOwnedHouse(closesthouse)
                                end
                            end
                        end
                    end

                    -- EXIT HOUSE
                    if inside then
                        if not entering then
                            local lockedText = "~r~locked"
                            if not Config.Houses[closesthouse].locked then lockedText = "~b~unlocked"; end
                            if #(pos - vector3(Config.Houses[closesthouse].coords.enter.x + POIOffsets.exit.x, Config.Houses[closesthouse].coords.enter.y + POIOffsets.exit.y, Config.Houses[closesthouse].coords.enter.z - 25 + POIOffsets.exit.z)) < 1.5 then
                                BJCore.Functions.DrawText3D(Config.Houses[closesthouse].coords.enter.x + POIOffsets.exit.x, Config.Houses[closesthouse].coords.enter.y + POIOffsets.exit.y, Config.Houses[closesthouse].coords.enter.z - 25 + POIOffsets.exit.z, '[~g~E~w~] Leave house | [~g~L~w~] House is '..lockedText)
                                if IsControlJustPressed(0, Keys["E"]) then
                                    leaveOwnedHouse(closesthouse, false)
                                end
                                if IsControlJustPressed(0, Keys["L"]) then
                                    TriggerEvent('dooranim')
                                    TriggerServerEvent('bj-houses:server:lockHouse', not Config.Houses[closesthouse].locked, closesthouse)
                                    if Config.Houses[closesthouse].locked then
                                        TriggerEvent('InteractSound_CL:PlayOnOne', 'houses_door_unlock', 0.8)     
                                    else
                                        TriggerEvent('InteractSound_CL:PlayOnOne', 'houses_door_lock', 0.8)
                                    end
                                end
                            end
                        end
                    end

                    -- -- STASH
                    if inside then
                        if closesthouse ~= nil then
                            if stashLocation ~= nil and type(stashLocation) == 'vector3' then
                                if #(pos - stashLocation) < 1.5 then
                                    BJCore.Functions.DrawText3D(stashLocation.x, stashLocation.y, stashLocation.z, '[~g~E~w~] Stash')
                                    if IsControlJustPressed(0, Keys["E"]) then
                                        TriggerEvent('InteractSound_CL:PlayOnOne', 'StashOpen', 0.8)
                                        TriggerServerEvent("inventory:server:OpenInventory", "stash", closesthouse, nil, "Property Stash: "..closesthouse)
                                        TriggerServerEvent("inventory:server:OpenInventory", "stash", closesthouse)
                                        TriggerEvent("inventory:client:SetCurrentStash", closesthouse)
                                    end
                                end
                            end

                            if outfitLocation ~= nil and type(outfitLocation) == 'vector3' then
                                if #(pos - outfitLocation) < 1.5 then
                                    BJCore.Functions.DrawText3D(outfitLocation.x, outfitLocation.y, outfitLocation.z, '[~g~E~w~] Outfits')
                                    if IsControlJustPressed(0, Keys["E"]) then
                                        TriggerEvent('InteractSound_CL:PlayOnOne', 'Stash', 0.6)
                                        TriggerEvent('bj-clothing:client:openOutfitMenu')
                                    end
                                end
                            end  

                            if logoutLocation ~= nil and type(logoutLocation) == 'vector3' then
                                if #(pos - logoutLocation) < 1.5 then
                                    BJCore.Functions.DrawText3D(logoutLocation.x, logoutLocation.y, logoutLocation.z, '[~r~E~w~] Logout')
                                    if IsControlJustPressed(0, Keys["E"]) then
                                        leaveOwnedHouse(closesthouse, true)
                                    end
                                end
                            end                                                       
                        end
                    end
                else
                    if not isOwned then
                        if closesthouse ~= nil then
                            if #(pos - vector3(Config.Houses[closesthouse].coords.enter.x, Config.Houses[closesthouse].coords.enter.y, Config.Houses[closesthouse].coords.enter.z)) < 1.5 then
                                if not viewCam then
                                    BJCore.Functions.DrawText3D(Config.Houses[closesthouse].coords.enter.x, Config.Houses[closesthouse].coords.enter.y, Config.Houses[closesthouse].coords.enter.z + 1.2, '[~g~E~w~] To view this house',0.8)
                                    if IsControlJustPressed(0, Keys["E"]) then
                                        TriggerServerEvent('bj-houses:server:viewHouse', closesthouse)
                                    end
                                end
                            end
                        end
                    elseif isOwned then
                        if closesthouse ~= nil then
                            if not inOwned then
                                if #(pos - vector3(Config.Houses[closesthouse].coords.enter.x, Config.Houses[closesthouse].coords.enter.y, Config.Houses[closesthouse].coords.enter.z)) < 1.5 then
                                    if not Config.Houses[closesthouse].locked then
                                        BJCore.Functions.DrawText3D(Config.Houses[closesthouse].coords.enter.x, Config.Houses[closesthouse].coords.enter.y, Config.Houses[closesthouse].coords.enter.z + 1.2, '[~g~E~w~] To enter',0.8)
                                        if IsControlJustPressed(0, Keys["E"])  then
                                            enterNonOwnedHouse(closesthouse)
                                        end
                                    else
                                        --BJCore.Functions.DrawText3D(Config.Houses[closesthouse].coords.enter.x, Config.Houses[closesthouse].coords.enter.y, Config.Houses[closesthouse].coords.enter.z + 1.2, 'Door Locked')
                                    end
                                end
                            elseif inOwned then
                                if #(pos - vector3(Config.Houses[closesthouse].coords.enter.x + POIOffsets.exit.x, Config.Houses[closesthouse].coords.enter.y + POIOffsets.exit.y, Config.Houses[closesthouse].coords.enter.z - 25 + POIOffsets.exit.z)) < 1.5 then
                                    BJCore.Functions.DrawText3D(Config.Houses[closesthouse].coords.enter.x + POIOffsets.exit.x, Config.Houses[closesthouse].coords.enter.y + POIOffsets.exit.y, Config.Houses[closesthouse].coords.enter.z - 25 + POIOffsets.exit.z, '[~g~E~w~] Leave house',0.8)
                                    if IsControlJustPressed(0, Keys["E"]) then
                                        leaveNonOwnedHouse(closesthouse)
                                    end
                                end
                            end
                        end
                    end
                end
            else
                Citizen.Wait(1000)
            end
        else
            Citizen.Wait(100)
        end
    end
end)

function openContract(bool)
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        type = "toggle",
        status = bool,
    })
    contractOpen = bool
end

function enterOwnedHouse(house)
    TriggerEvent("bj-core:client:pauseLastPos", true)
    TriggerEvent('InteractSound_CL:PlayOnOne', 'houses_door_open', 0.8)
    local coords = { x = Config.Houses[closesthouse].coords.enter.x, y = Config.Houses[closesthouse].coords.enter.y, z= Config.Houses[closesthouse].coords.enter.z - 25}
    data = handleInteriors(coords, Config.Houses[house].tier)
    TriggerEvent('bj-weathersync:client:DisableSync')
    SetRainFxIntensity(0.0)
    SetWeatherTypePersist('EXTRASUNNY')
    SetWeatherTypeNow('EXTRASUNNY')
    SetWeatherTypeNowPersist('EXTRASUNNY')
    NetworkOverrideClockTime(23, 0, 0)
    loadFurniture(Config.Houses[closesthouse].coords.enter)
    Citizen.Wait(100)
    houseObj = data[1]
    POIOffsets = data[2]
    inside = true
    entering = true
    Citizen.Wait(500)
    TriggerEvent('furni:client:enteredHouse', Config.Houses[closesthouse].coords.enter, closesthouse) 
    BJCore.Functions.TriggerServerCallback('bj-houses:server:getHouseOwner', function(result)
        if BJCore.Functions.GetPlayerData().citizenid == result then
            TriggerEvent('bj-houses:client:insideHouse', true)
        end
    end, closesthouse)
    setHouseLocations()  
    TriggerEvent('weed:client:getHousePlants', closesthouse)
    Citizen.Wait(100)
    entering = false
end
exports('enterOwnedHouse', enterOwnedHouse)

function leaveOwnedHouse(house, logout)
    DoScreenFadeOut(350)
    Citizen.Wait(350)
    TriggerEvent('InteractSound_CL:PlayOnOne', 'houses_door_close', 0.7)
    TriggerEvent('bj-weathersync:client:EnableSync')
    Wait(500)
    exports['interior']:DespawnInterior(houseObj, function()
        if curFurniture then
            for k,v in pairs(curFurniture) do
                SetEntityAsMissionEntity(v.object,true,true)
                DeleteObject(v.object)
                DeleteEntity(v.object)
                curFurniture[k].object = nil
            end
        end
        Citizen.Wait(100)
        TriggerEvent("weed:client:leaveHouse")
        TriggerEvent('furni:client:leaveHouse', Config.Houses[closesthouse].coords.enter, closesthouse)
        TriggerEvent('bj-houses:client:insideHouse', false)
        if logout then
            SetEntityAlpha(PlayerPedId(), 0, false)
            FreezeEntityPosition(PlayerPedId(), true)
            TriggerServerEvent('bj-core:multichar:server:logout')
        else
            DoScreenFadeIn(250)
            SetEntityCoords(PlayerPedId(), Config.Houses[closesthouse].coords.enter.x, Config.Houses[closesthouse].coords.enter.y, Config.Houses[closesthouse].coords.enter.z + 0.5)
            SetEntityHeading(PlayerPedId(), Config.Houses[closesthouse].coords.enter.w)
        end
        inside = false
        TriggerEvent("bj-core:client:pauseLastPos", false)
    end)
end

function enterNonOwnedHouse(house)
    TriggerEvent("bj-core:client:pauseLastPos", true)
    TriggerEvent('InteractSound_CL:PlayOnOne', 'houses_door_open', 0.8)
    local coords = { x = Config.Houses[closesthouse].coords.enter.x, y = Config.Houses[closesthouse].coords.enter.y, z= Config.Houses[closesthouse].coords.enter.z - 25}
    data = handleInteriors(coords, Config.Houses[house].tier)
    TriggerEvent('bj-weathersync:client:DisableSync')
    SetRainFxIntensity(0.0)
    SetWeatherTypePersist('EXTRASUNNY')
    SetWeatherTypeNow('EXTRASUNNY')
    SetWeatherTypeNowPersist('EXTRASUNNY')
    NetworkOverrideClockTime(23, 0, 0)
    loadFurniture(Config.Houses[closesthouse].coords.enter)
    Citizen.Wait(100)
    houseObj = data[1]
    POIOffsets = data[2]
    inside = true
    entering = true
    Citizen.Wait(500)
    TriggerEvent('bj-houses:client:insideHouse', true)
    TriggerEvent('weed:client:getHousePlants', house)
    Citizen.Wait(100)
    inOwned = true
    entering = false
end

function leaveNonOwnedHouse(house)
    DoScreenFadeOut(350)
    Citizen.Wait(350)
    TriggerEvent('InteractSound_CL:PlayOnOne', 'houses_door_close', 0.7)
    TriggerEvent('bj-weathersync:client:EnableSync')
    Wait(500)
    exports['interior']:DespawnInterior(houseObj, function()
        if curFurniture then
            for k,v in pairs(curFurniture) do
                SetEntityAsMissionEntity(v.object,true,true)
                DeleteObject(v.object)
                DeleteEntity(v.object)
                curFurniture[k].object = nil
            end
        end
        TriggerEvent('bj-weathersync:client:EnableSync')
        Citizen.Wait(100)
        TriggerEvent('bj-houses:client:insideHouse', false)
        DoScreenFadeIn(250)
        SetEntityCoords(PlayerPedId(), Config.Houses[house].coords.enter.x, Config.Houses[house].coords.enter.y, Config.Houses[house].coords.enter.z + 0.5)
        SetEntityHeading(PlayerPedId(), Config.Houses[house].coords.enter.w)
        inOwned = false
        inside = false
        TriggerEvent("weed:client:leaveHouse")
        TriggerEvent("bj-core:client:pauseLastPos", false)        
    end)
end

function handleInteriors(coords, tier)
    local idata = nil
    if tier == 1 then
        idata = exports['interior']:CreateTier1House(coords, false)
    elseif tier == 2 then
        idata = exports['interior']:CreateTier2House(coords, false)   
    elseif tier == 3 then
        idata = exports['interior']:CreateCaravanShell(coords, false)
    end
    return idata
end

function getHouseEntrance(house)
    return Config.Houses[house].coords.enter
end

local shellSpawn = vector3(0,0,0)
local offsetDebug = false
local debugShell = nil
RegisterNetEvent("utils:spawnShell")
AddEventHandler("utils:spawnShell", function(shellName)
    print(shellName)
    shellName = GetHashKey(shellName)
    if debugShell == nil then
        RequestModel(shellName)
        while not HasModelLoaded(shellName) do
            Citizen.Wait(1000)
        end
        local pos = GetEntityCoords(PlayerPedId())
        local spawnp = vector3(pos.z, pos.y, pos.z-25.0)
        shellSpawn = spawnp
        debugShell = CreateObject(shellName, spawnp.x, spawnp.y, spawnp.z, false, false, false)
        FreezeEntityPosition(debugShell, true)
        Wait(1000)
        SetEntityCoords(PlayerPedId(), spawnp.x, spawnp.y, spawnp.z+2.0, 0, 0, 0, false)
        offsetDebug = true
        showOffSetTick()
    else
        SetEntityCoords(PlayerPedId(), shellSpawn.x, shellSpawn.y, shellSpawn.z+25, 0, 0, 0, false)
        DeleteEntity(debugShell)
        offsetDebug = false
        debugShell = nil
    end
end)

function showOffSetTick()
    Citizen.CreateThread(function()
        while offsetDebug do
            DrawGenericText(GetEntityCoords(PlayerPedId())-shellSpawn.." | h: "..GetEntityHeading(PlayerPedId()))
            Citizen.Wait(0)
        end
    end)
end

function DrawGenericText(text)
    SetTextColour(186, 186, 186, 255)
    SetTextFont(4)
    SetTextScale(0.378, 0.378)
    SetTextWrap(0.0, 1.0)
    SetTextCentre(false)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 205)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(0.40, 0.00)
end

function loadFurniture(pos)
    if curFurniture then
        for k,v in pairs(curFurniture) do
            local hash = GetHashKey(v.model)
            RequestModel(hash)
            while not HasModelLoaded(hash) do RequestModel(hash) Wait(0); end

            local obj = CreateObject(hash, pos.x + v.pos.x, pos.y + v.pos.y, pos.z + v.pos.z, false,false,false)
            Wait(10)
            SetEntityCoordsNoOffset(obj, pos.x + v.pos.x, pos.y + v.pos.y, pos.z + v.pos.z)
            SetEntityRotation(obj, v.rot.x, v.rot.y, v.rot.z, 2)

            FreezeEntityPosition(obj, true)
            curFurniture[k].object = obj
        end
    end
end

RegisterNetEvent('bj-houses:client:createHouses')
AddEventHandler('bj-houses:client:createHouses', function()
    local tier = getInput('InputTier')
    if tier == nil or tier == 0 then return SetTimecycleModifier('default'); end
    local price = getInput('InputPrice')
    SetTimecycleModifier('default')
    local plyPed = PlayerPedId()
    local pos = GetEntityCoords(plyPed)
    local heading = GetEntityHeading(plyPed)
    local s1, s2 = Citizen.InvokeNative(0x2EB41072B4C1E4C0, pos.x, pos.y, pos.z, Citizen.PointerValueInt(), Citizen.PointerValueInt())
    local street = GetStreetNameFromHashKey(s1)
    local coords = {
        enter   = { x = pos.x, y = pos.y, z = pos.z-1.0, h = heading},
        cam     = { x = pos.x, y = pos.y, z = pos.z, h = heading, yaw = -10.00},
    }
    street = street:gsub("%-", " ")
    TriggerServerEvent('bj-houses:server:addNewHouse', street, coords, tonumber(price), tonumber(tier))
end)

RegisterNetEvent('bj-houses:client:addGarage')
AddEventHandler('bj-houses:client:addGarage', function()
    if closesthouse ~= nil then 
        local plyPed = PlayerPedId()
        local pos = GetEntityCoords(plyPed)
        local heading = GetEntityHeading(plyPed)
        local coords = {
            x = pos.x,
            y = pos.y,
            z = pos.z,
            h = heading,
        }
        TriggerServerEvent('bj-houses:server:addGarage', closesthouse, coords)
    else
        BJCore.Functions.Notify("No house around..", "error")
    end
end)

AddTextEntry('InputPrice', 'Input Price')
AddTextEntry('InputTier', 'Input Tier Number')
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

RegisterNetEvent('bj-houses:client:setupHouseBlips')
AddEventHandler('bj-houses:client:setupHouseBlips', function()
    Citizen.CreateThread(function()
        Citizen.Wait(2000)
        if isLoggedIn then
            BJCore.Functions.TriggerServerCallback('bj-houses:server:getOwnedHouses', function(ownedHouses)
                for i=1, #ownedHouses, 1 do
                    local house = Config.Houses[ownedHouses[i]]
                    HouseBlip = AddBlipForCoord(house.coords.enter)

                    SetBlipSprite (HouseBlip, 40)
                    SetBlipDisplay(HouseBlip, 4)
                    SetBlipScale  (HouseBlip, 0.65)
                    SetBlipAsShortRange(HouseBlip, true)
                    SetBlipColour(HouseBlip, 3)

                    BeginTextCommandSetBlipName("STRING")
                    AddTextComponentSubstringPlayerName(house.address)
                    EndTextCommandSetBlipName(HouseBlip)
                    table.insert(HouseBlips, HouseBlip)
                end
            end)
        end
    end)
end)

RegisterNetEvent('bj-houses:client:SetClosestHouse')
AddEventHandler('bj-houses:client:SetClosestHouse', function()
    SetClosestHouse()
end)

function setViewCam(coords, heading, yaw)
    cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", coords.x, coords.y, coords.z, yaw, 0.00, heading, 80.00, false, 0)
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 500, true, true)
    viewCam = true
end

function disableViewCam()
    RenderScriptCams(false, true, 500, true, true)
    SetCamActive(cam, false)
    DestroyCam(cam, true)
    viewCam = false
end

RegisterNUICallback('buy', function()
    openContract(false)
    disableViewCam()
    TriggerServerEvent('bj-houses:server:buyHouse', closesthouse)
end)

RegisterNUICallback('exit', function()
    openContract(false)
    disableViewCam()
end)

RegisterNetEvent('bj-houses:client:viewHouse')
AddEventHandler('bj-houses:client:viewHouse', function(houseprice, brokerfee, bankfee, taxes, firstname, lastname)
    setViewCam(Config.Houses[closesthouse].coords.cam, Config.Houses[closesthouse].coords.cam.heading, Config.Houses[closesthouse].coords.yaw)
    Citizen.Wait(500)
    openContract(true)
    SendNUIMessage({
        type = "setupContract",
        firstname = firstname,
        lastname = lastname,
        street = Config.Houses[closesthouse].address,
        houseprice = houseprice,
        brokerfee = brokerfee,
        bankfee = bankfee,
        taxes = taxes,
        totalprice = (houseprice + brokerfee + bankfee + taxes)
    })
end)

function SetClosestHouse()
    local pos = GetEntityCoords(PlayerPedId(), true)
    local current = nil
    local dist = nil

    for id, house in pairs(Config.Houses) do
        if current ~= nil then
            local distChk = #(pos.xy - Config.Houses[id].coords.enter.xy)
            if distChk < dist then
                current = id
                dist = distChk
            end
        else
            dist = #(pos.xy - Config.Houses[id].coords.enter.xy)
            current = id
        end
    end
    closesthouse = current
    if closesthouse ~= nil then
        BJCore.Functions.TriggerServerCallback('bj-houses:server:hasKey', function(result)
            hasKey = result
        end, closesthouse)

        BJCore.Functions.TriggerServerCallback('bj-houses:server:isOwned', function(result)
            isOwned = result
        end, closesthouse)

        BJCore.Functions.TriggerServerCallback('bj-houses:server:getFurniture', function(result)
            curFurniture = result
        end, closesthouse)
        TriggerEvent('garages:client:setHouseGarage', closesthouse, hasKey, Config.Houses[closesthouse].garage)
    end
end

function setHouseLocations()
    if closesthouse ~= nil then
        BJCore.Functions.TriggerServerCallback('bj-houses:server:getHouseLocations', function(result)
            if result ~= nil then
                if result.stash ~= nil then
                    stashLocation = json.decode(result.stash)
                    stashLocation = vector3(stashLocation.x, stashLocation.y, stashLocation.z)
                end

                if result.outfit ~= nil then
                    outfitLocation = json.decode(result.outfit)
                    outfitLocation = vector3(outfitLocation.x, outfitLocation.y, outfitLocation.z)
                end

                if result.logout ~= nil then
                    logoutLocation = json.decode(result.logout)
                    logoutLocation = vector3(logoutLocation.x, logoutLocation.y, logoutLocation.z)
                end
            end
        end, closesthouse)
    end
end

RegisterNetEvent('bj-houses:client:setLocation')
AddEventHandler('bj-houses:client:setLocation', function(data)
    local plyPos = GetEntityCoords(PlayerPedId())
    local coords = {x = plyPos.x, y = plyPos.y, z = plyPos.z}

    if inside then
        if hasKey then
            if data == 'stash' then
                TriggerServerEvent('bj-houses:server:setLocation', coords, closesthouse, 1)
            elseif data == 'outfit' then
                TriggerServerEvent('bj-houses:server:setLocation', coords, closesthouse, 2)
            elseif data == 'logout' then
                TriggerServerEvent('bj-houses:server:setLocation', coords, closesthouse, 3)
            end
        else
            BJCore.Functions.Notify("You don't own your house", 'error')
        end
    -- else    
    --     BJCore.Functions.Notify('You are not in a house..', 'error')
    end
end)

RegisterNetEvent('bj-houses:client:refreshLocations')
AddEventHandler('bj-houses:client:refreshLocations', function(house, location, type)
    if closesthouse == house then
        if inside then
            if type == 1 then
                stashLocation = json.decode(location)
                stashLocation = vector3(stashLocation.x, stashLocation.y, stashLocation.z)
            elseif type == 2 then
                outfitLocation = json.decode(location)
                outfitLocation = vector3(outfitLocation.x, outfitLocation.y, outfitLocation.z)
            elseif type == 3 then
                logoutLocation = json.decode(location)
                logoutLocation = vector3(logoutLocation.x, logoutLocation.y, logoutLocation.z)
            end
        end
    end
end)

function GetHouseAddress(id)
    if Config.Houses[id] ~= nil then
        return Config.Houses[id].address
    else
        return id
    end
end
exports('GetHouseAddress', GetHouseAddress)

function GetHousePos(id)
    if Config.Houses[id] ~= nil then
        return Config.Houses[id].coords.enter
    else
        return false
    end
end
exports('GetHousePos', GetHousePos)

function GetClosestPlayer()
    local closestPlayers = BJCore.Functions.GetPlayersFromCoords()
    local closestDistance = -1
    local closestPlayer = -1
    local coords = GetEntityCoords(PlayerPedId())

    for i=1, #closestPlayers, 1 do
        if closestPlayers[i] ~= PlayerId() then
            local pos = GetEntityCoords(GetPlayerPed(closestPlayers[i]))
            local distance = #(pos - coords)

            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = closestPlayers[i]
                closestDistance = distance
            end
        end
    end

    return closestPlayer, closestDistance
end

RegisterNetEvent('bj-houses:client:giveHouseKey')
AddEventHandler('bj-houses:client:giveHouseKey', function(data)
    local player, distance = GetClosestPlayer()
    if player ~= -1 and distance < 2.5 and closesthouse ~= nil then
        local playerId = GetPlayerServerId(player)
        TriggerServerEvent('bj-houses:server:giveHouseKey', playerId, closesthouse)
    else
        BJCore.Functions.Notify("Target not found. Try again?", "error")
    end
end)

RegisterNetEvent('bj-houses:client:removeHouseKey')
AddEventHandler('bj-houses:client:removeHouseKey', function()
    if closesthouse ~= nil then 
        inHoldersMenu = true
        HouseMenuTick()
        HouseKeysMenu()
        Menu.hidden = not Menu.hidden
    end
end)

function HouseMenuTick()
    Citizen.CreateThread(function()
        while inHoldersMenu do
            Citizen.Wait(1)
            Menu.renderGUI()
        end
    end)
end

function HouseKeysMenu()
    ped = PlayerPedId()
    MenuTitle = "Key Management"
    ClearMenu()
    BJCore.Functions.TriggerServerCallback('bj-houses:server:getHouseKeyHolders', function(holders)
        ped = PlayerPedId()
        MenuTitle = "Key Holders:"
        ClearMenu()
        if holders == nil or next(holders) == nil then
            BJCore.Functions.Notify("No key holders found", "error", 3500)
            closeMenuFull()
        else
            TriggerEvent("police:client:pauseKeybind", true)
            for k, v in pairs(holders) do
                Menu.addButton(holders[k].firstname .. " " .. holders[k].lastname, "optionMenu", holders[k]) 
            end
        end
        Menu.addButton("Close Menu", "closeMenuFull", nil) 
    end, closesthouse)
end

function optionMenu(citizenData)
    ped = PlayerPedId()
    MenuTitle = "Select Option:"
    ClearMenu()
    Menu.addButton("Remove Key", "removeHouseKey", citizenData) 
    Menu.addButton("Back", "HouseKeysMenu",nil)
end

function removeHouseKey(citizenData)
    TriggerServerEvent('bj-houses:server:removeHouseKey', closesthouse, citizenData)
    closeMenuFull()
end

function closeMenuFull()
    Menu.hidden = true
    currentGarage = nil
    inHoldersMenu = false
    ClearMenu()
    TriggerEvent("police:client:pauseKeybind", false)
end

function ClearMenu()
    --Menu = {}
    Menu.GUI = {}
    Menu.buttonCount = 0
    Menu.selection = 0
end

function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

RegisterNetEvent('bj-houses:client:doAdminDelete')
AddEventHandler('bj-houses:client:doAdminDelete', function(full)
    local pos = GetEntityCoords(PlayerPedId())
    if closesthouse ~= nil then
        local house = Config.Houses[closesthouse]
        local dist = #(pos.xy - house.coords.enter.xy)
        if dist < 20 then
            TriggerEvent('bj-houses:client:doAdminInfo', true, function()
                TriggerServerEvent('bj-houses:server:doAdminDelete', closesthouse, full)
            end)
        else
            BJCore.Functions.Notify('No entrace to a player house nearby', 'error')
        end
    end
end)

RegisterNetEvent('bj-houses:client:doAdminInfo')
AddEventHandler('bj-houses:client:doAdminInfo', function(isDelete, cb)
    local pos = GetEntityCoords(PlayerPedId())
    if closesthouse ~= nil then
        local house = Config.Houses[closesthouse]
        local dist = #(pos.xy - house.coords.enter.xy)
        if dist < 20 then
            local detailString = "Closest House Info:\n\n"
            if isDelete then
                detailString = "Closest House Deleted:\n\n"
            end
            for k,v in pairs(house) do
                if k ~= 'owned' and type(v) ~= 'table' and type(v) ~= 'vector3' then
                    detailString = detailString..firstToUpper(k)..': '..tostring(v)..'\n'
                end
            end
            BJCore.Functions.TriggerServerCallback('bj-houses:server:getHouseOwner', function(result)
                if result then
                    detailString = detailString..'Owner: '..result
                else
                    detailString = detailString..'Owner: Not Owned'
                end
                TriggerEvent("chat:addMessage", {
                    templateId = 'print',
                    multiline = true,
                    args = { detailString }
                })
                if cb then
                    cb()
                end
            end, closesthouse)
        else
            BJCore.Functions.Notify('No entrance to a player house nearby', 'error')
        end
    end
end)