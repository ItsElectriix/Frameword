BJCore = nil
Citizen.CreateThread(function(...) while BJCore == nil do TriggerEvent("BJCore:GetObject", function(obj) BJCore = obj end); Citizen.Wait(1000); end; end)

local selectingChar = false

local cam = nil
local cam2 = nil

local nuiReady = false

RegisterNUICallback('nuiReady', function()
    nuiReady = true
end)

RegisterNetEvent('testywesty')
AddEventHandler('testywesty', function( ... )
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)

            if NetworkIsSessionStarted() and nuiReady then
                ShutdownLoadingScreenNui()
                ShutdownLoadingScreen()
                --TriggerServerEvent('bj-core:multichar:server:playerJoin')
                TriggerServerEvent("bj-scoreboard:server:playerJoin")
                TriggerEvent('bj-core:multichar:client:startCam')
                --TriggerEvent('bj-ui:client:closeUI:multichar')
                TriggerEvent('bj-core:multichar:client:setupCharacters')
                ShowChar(true)
                return
            end
        end
    end)
end)

RegisterNetEvent('bj-core:multichar:client:selectChar')
AddEventHandler('bj-core:multichar:client:selectChar', function()
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "charSelect",
        status = true
    })
    selectingChar = true
end)

RegisterNetEvent('bj-core:multichar:client:sendToCharSelect')
AddEventHandler('bj-core:multichar:client:sendToCharSelect', function()
    BJCore.Functions.TriggerServerCallback('bj-core:multichar:server:getChar', function(data)
        StopScreenEffect('DeathFailOut')
        StopScreenEffect('DeathFailMPIn')
        StopScreenEffect('DeathFailNeutralIn')
        if not IsScreenFadedOut() then
            DoScreenFadeOut(500)
            Wait(400)
        end
        TriggerEvent('bj-core:multichar:client:startCam')
        TriggerEvent('bj-ui:client:closeUI:multichar')
        SendNUIMessage({type = "setupCharacters", characters = data.plyChars, currencySymbol = BJCore.Config.Currency.Symbol, numChar = data.numChar})
        Wait(50)
        ShowChar(true)
    end)
end)

RegisterNetEvent('bj-core:multichar:client:setupCharacters')
AddEventHandler('bj-core:multichar:client:setupCharacters', function()
    BJCore.Functions.TriggerServerCallback('bj-core:multichar:server:getChar', function(data)
		ShutdownLoadingScreenNui()
		SendNUIMessage({type = "setupCharacters", characters = data.plyChars, currencySymbol = BJCore.Config.Currency.Symbol, numChar = data.numChar})
    end)
end)

RegisterNUICallback('closeCharSelection', function()
    ShowChar(false)
end)

RegisterNUICallback('refreshCharacters', function()
    BJCore.Functions.TriggerServerCallback('bj-core:multichar:server:refreshChars', function(data)
        SendNUIMessage({type = "refreshCharacters", characters = data, currencySymbol = BJCore.Config.Currency.Symbol})
    end)
end)

RegisterNUICallback('selectCharacter', function(data)
    ShowChar(false)
    DoScreenFadeOut(1000)
    Citizen.Wait(1000)
    print("[MULTICHAR] selected char")
    exports.spawnmanager:setAutoSpawn(false)
    --TriggerEvent('bj-spawnlocation:client:openUI', true)
    SetTimecycleModifier('default')
    SetCamActive(cam, false)
    DestroyCam(cam, true)
    print("[MULTICHAR] sent event to load char")
    print("fade?: "..tostring(IsScreenFadedOut()))
    TriggerServerEvent('bj-core:multichar:server:charSelect', data.cid)
end)

RegisterNUICallback('deleteCharacter', function(data)
    TriggerServerEvent('bj-core:multichar:server:deleteChar', data.cid)
end)

RegisterNUICallback('createCharacter', function(data)
    ShowChar(false)
    local charData = data.charData
    TriggerServerEvent('bj-core:multichar:server:createCharacter', charData)
    DoScreenFadeOut(500)
    Citizen.Wait(500)
    SetTimecycleModifier('default')
end)

local SpawnOptions = {
	{
		coords = vector3(122.6056, -211.204, 54.55782),
		heading = 257.82
	},
	{
		coords = vector3(71.54115, -1399.961, 29.37615),
		heading = 351.56
	},
	{
		coords = vector3(71.54115, -1399.961, 29.37615),
		heading = 351.56
	},
	{
		coords = vector3(430.0151, -800.2345, 29.49115),
		heading = 158.55
	}
}

RegisterNetEvent('bj-core:multichar:client:spawnNewChar')
AddEventHandler('bj-core:multichar:client:spawnNewChar', function()
    while not DoesEntityExist(PlayerPedId()) do print("[MULTICHAR] wait fam new char") Citizen.Wait(0); end
    local ped = PlayerPedId()
	local spawn = SpawnOptions[math.random(1, #SpawnOptions)]
    SetEntityCoords(ped, spawn.coords.x, spawn.coords.y, spawn.coords.z)
    SetEntityHeading(ped, spawn.heading)
    FreezeEntityPosition(ped, false)
    exports.spawnmanager:setAutoSpawn(false)
    RenderScriptCams(false, true, 500, true, true)
    SetCamActive(cam, false)
    DestroyCam(cam, true)
    Citizen.Wait(500)
    DoScreenFadeIn(500)
end)

function ShowChar(value)
    SetNuiFocus(value, value)
    SendNUIMessage({
        type = "charSelect",
        status = value
    })
    selectingChar = value
end

RegisterNetEvent('bj-core:multichar:client:startCam')
AddEventHandler('bj-core:multichar:client:startCam', function()
    DoScreenFadeIn(10)
    SetTimecycleModifier('hud_def_blur')
    SetTimecycleModifierStrength(1.0)
    FreezeEntityPosition(PlayerPedId(), true)
    cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", -358.56, -981.96, 286.25, 320.00, 0.00, -50.00, 90.00, false, 0)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 1, true, true)
end)

-- RegisterNetEvent('bj-core:multichar:client:destroyCam')
-- AddEventHandler('bj-core:multichar:client:destroyCam', function(spawn)
--     SetTimecycleModifier('default')
--     local pos = spawn
--     SetEntityCoords(PlayerPedId(), pos.x, pos.y, pos.z)
--     DoScreenFadeIn(500)
--     Citizen.Wait(500)
--     cam2 = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", -358.56, -981.96, 286.25, 300.00,0.00,0.00, 100.00, false, 0)
--     PointCamAtCoord(cam2, pos.x,pos.y,pos.z+200)
--     SetCamActiveWithInterp(cam2, cam, 900, true, true)
--     Citizen.Wait(900)

--     cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", pos.x,pos.y,pos.z+200, 300.00,0.00,0.00, 100.00, false, 0)
--     PointCamAtCoord(cam, pos.x,pos.y,pos.z+2)
--     SetCamActiveWithInterp(cam, cam2, 3700, true, true)
--     Citizen.Wait(3700)
--     PlaySoundFrontend(-1, "Zoom_Out", "DLC_HEIST_PLANNING_BOARD_SOUNDS", 1)
--     RenderScriptCams(false, true, 500, true, true)
--     PlaySoundFrontend(-1, "CAR_BIKE_WHOOSH", "MP_LOBBY_SOUNDS", 1)
--     FreezeEntityPosition(PlayerPedId(), false)
--     Citizen.Wait(500)
--     SetCamActive(cam, false)
--     DestroyCam(cam, true)
--     DisplayHud(true)
--     DisplayRadar(true)

--     print('yes 2345')
-- end)

