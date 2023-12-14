local currentGarage = 1

Citizen.CreateThread(function()
    while BJCore == nil do Citizen.Wait(500); end
    while not BJCore.Functions.IsPlayerLoaded() do Citizen.Wait(250); end
    isLoggedIn = true
    while true do
        Citizen.Wait(1)
        if isLoggedIn and BJCore ~= nil then
            local nearby = false
            local pos = GetEntityCoords(PlayerPedId())
            if PlayerJob.name == "doctor" or PlayerJob.name == "ambulance" then
            
                for k, v in pairs(Config.Locations["duty"]) do
                    if #(pos - v) < 10 then
                        nearby = true
                        if #(pos - v) < 1.5 then
                            if onDuty then
                                BJCore.Functions.DrawText3D(v.x, v.y, v.z, "[~g~E~w~] Go off duty")
                            else
                                BJCore.Functions.DrawText3D(v.x, v.y, v.z, "[~r~E~w~] Go on duty")
                            end
                            if IsControlJustReleased(0, Keys["E"]) then
                                --onDuty = not onDuty
                                TriggerServerEvent("BJCore:ToggleDuty")
                                TriggerServerEvent("police:server:UpdateBlips")
                            end
                        end  
                    end
                end

                for k, v in pairs(Config.Locations["armory"]) do
                    if #(pos - v) < 10 then
                        if onDuty then
                            nearby = true
                            if #(pos - v) < 1.5 then
                                BJCore.Functions.DrawText3D(v.x, v.y, v.z, "[~g~E~w~] Inventory")
                                if IsControlJustReleased(0, Keys["E"]) then
                                    TriggerServerEvent("inventory:server:OpenInventory", "shop", "Itemshop_hospital", Config.Items)
                                end
                            end  
                        end
                    end
                end
        
                for k, v in pairs(Config.Locations["vehicle"]) do
                    if #(pos.xyz - v.xyz) < 10.5 then
                        nearby = true
                        DrawMarker(2, v.x, v.y, v.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 255, 255, 255, 222, false, false, false, true, false, false, false)
                        if #(pos.xyz - v.xyz) < 1.5 then
                            if IsPedInAnyVehicle(PlayerPedId(), false) then
                                BJCore.Functions.DrawText3D(v.x, v.y, v.z, "[~g~E~w~] Store vehicle")
                            else
                                BJCore.Functions.DrawText3D(v.x, v.y, v.z, "[~g~E~w~] Vehicles")
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
                            Menu.renderGUI()
                        end
                    end
                end
        
                for k, v in pairs(Config.Locations["helicopter"]) do
                    if #(pos.xyz - v.xyz) < 7.5 then
                        if onDuty then
                            nearby = true
                            DrawMarker(2, v.x, v.y, v.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 255, 255, 255, 222, false, false, false, true, false, false, false)
                            if #(pos.xyz - v.xyz) < 1.5 then
                                if IsPedInAnyVehicle(PlayerPedId(), false) then
                                    BJCore.Functions.DrawText3D(v.x, v.y, v.z, "[~g~E~w~] Store Helicopter")
                                else
                                    BJCore.Functions.DrawText3D(v.x, v.y, v.z, "[~g~E~w~] Take out Helicopter")
                                end
                                if IsControlJustReleased(0, Keys["E"]) then
                                    if IsPedInAnyVehicle(PlayerPedId(), false) then
                                        BJCore.Functions.DeleteVehicle(GetVehiclePedIsIn(PlayerPedId()))
                                    else
                                        local coords = Config.Locations["helicopter"][k]
                                        BJCore.Functions.SpawnVehicle(Config.Helicopter, function(veh)
                                            SetVehicleLivery(veh, 1)
                                            SetVehicleNumberPlateText(veh, "EMS"..tostring(math.random(1000, 9999)))
                                            SetEntityHeading(veh, coords.w)
                                            exports['legacyfuel']:SetFuel(veh, 100.0)
                                            closeMenuFull()
                                            TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
                                            TriggerEvent('keys:addNew', veh, GetVehicleNumberPlateText(veh))
                                            SetVehicleEngineOn(veh, true, true)
                                        end, coords, true)
                                    end
                                end
                            end  
                        end
                    end
                end
            end

            for k, v in pairs(Config.Locations["hidden"]) do
                if #(pos - v) < 9.5 then
                    nearby = true
                    if #(pos - v) < 2.0 then
                        local price = 1.8
                        if k == 1 then price = 2.3; end
                        BJCore.Functions.DrawText3D(v.x, v.y, v.z, "[~r~H~w~] Treat | Price: "..price.." IMP")
                        if IsControlJustReleased(0, Keys["H"]) then
                            HiddenTreatment(price)
                        end
                    end
                end
            end
            if not nearby then
                Citizen.Wait(500)
            end
        else
            Citizen.Wait(1000)
        end
    end
end)

function HiddenTreatment(price)
    local player, distance = BJCore.Functions.GetClosestPlayer()
    if player ~= -1 and distance < 1.5 then
        local playerId = GetPlayerServerId(player)    
        BJCore.Functions.TriggerServerCallback('ems:server:CanPayHidden', function(canPay)
            if canPay then
                local difficulty, speed, timeout = 2, 4, 3000
                TriggerEvent('bj_minigames:start', 'Lockbox', { difficulty = difficulty, speed = speed, attempts = 1, stages = math.random(4, 7), stageTimeout = timeout }, function(data)
                    BJCore.Functions.Notify("Lockpicking success", "success")
                    TriggerServerEvent('bj-hud:Server:GainStress', math.random(2, 4))
                    TriggerServerEvent('ems:server:HiddenRevive', playerId, price)
                end, function(data)
                    local c = math.random(5)
                    local o = math.random(5)
                    if c == o then
                        TriggerServerEvent('bj-hud:Server:GainStress', math.random(1, 4))
                    end
                end)                
            else
                BJCore.Functions.Notify("Not enough IMP to pay for treatment", "error")
            end 
        end, price)
    else
        BJCore.Functions.Notify("Player not found. Try again?", "error")
    end
end

RegisterNetEvent('ems:server:HiddenTreatment')
AddEventHandler('ems:server:HiddenTreatment', function()
    exports['mythic_progbar']:Progress({
        name = "illegal_hospital",
        duration = 60000,
        label = "Healing",
        useWhileDead = true,
        canCancel = false,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }
    }, function(status)
        if not status then
            TriggerEvent('hospital:client:Revive')
        end
    end)
end)

local wasDead = false

local CurHospital, PatientID, LayingDown, CurBed = false, false, false, false
local withinDist, curAction = false, false
function Update()
    -- local unarmedHash = GetHashKey('WEAPON_UNARMED')
    -- local unarmedHash2 = unarmedHash % 0x100000000
    while true do
        sleep = 0
        local plyPed = PlayerPedId()
        local plyPos = GetEntityCoords(plyPed)
        local closestHKey,closestHVal,closestHDist = GetClosestHospital(plyPos)
        if closestHDist < Config.LoadZoneDist then
            CurHospital = closestHKey
        else
            if PatientID then
                CheckPlayerOut(CurHospital)
            end            
            CurHospital = false
            withinDist, curAction, CurBed = false, nil, false
            sleep = 1000
        end
        local pos, rot = false, false
        if CurHospital then
            local nearby = false
            local checkDeskDist = #(plyPos - Config.Hospitals[CurHospital]["checkIn"])
            if checkDeskDist < Config.InteractDist then
                withinDist, curAction = true, "Check In"
                local pos = Config.Hospitals[CurHospital]["checkIn"]
                if PatientID then BJCore.Functions.DrawText3D(pos.x, pos.y, pos.z, "[~r~E~w~] Check Out", 0.7)
                else BJCore.Functions.DrawText3D(pos.x, pos.y, pos.z, "[~g~E~w~] Check In", 0.7); end
            else
                withinDist, curAction, CurBed = false, nil, false
            end
            if PatientID and PatientID ~= 0 then
                local dist = #(plyPos - Config.Hospitals[CurHospital]["beds"][PatientID]["pos"].xyz)
                --local closestKey,closestVal,closestDist = GetClosestBed(plyPos, CurHospital)
                if dist < Config.DrawTextDist and dist < Config.InteractDist then
                    withinDist, curAction, CurBed = true, "Lay Down", PatientID or false
                    pos = Config.Hospitals[CurHospital]["beds"][PatientID]["pos"].xyz
                    rot = Config.Hospitals[CurHospital]["beds"][PatientID]["rot"] or false
                    if not LayingDown then
                        BJCore.Functions.DrawText3D(pos.x,pos.y,pos.z+1.0, "[~g~E~w~] Use bed", 0.7)
                    end   
                end
            end
            if withinDist and curAction then
                if BJCore.Functions.GetKeyPressed("E") then
                    DoAction(curAction, pos or false, rot or false)
                end
            end
        else
            sleep = 1000
            withinDist, curAction, CurBed = false, nil, false
            exports['core']:PersistentAlert('end', MedicNotifId)
            exports['core']:PersistentAlert('end', HospNotifId1)
            exports['core']:PersistentAlert('end', HospNotifId2)            
        end
        -- if PatientID then
        --     local _, weapon = GetCurrentPedWeapon(plyPed)
        --     if weapon ~= unarmedHash and weapon ~= unarmedHash2 then
        --         SetCurrentPedWeapon(plyPed, unarmedHash, true)
        --     end
        --     DisablePlayerFiring(PlayerId())
        -- end
        Citizen.Wait(sleep)
    end
end

function DoAction(action, pos, rot)
    withinDist, curAction, CurBed = false, nil, false
    local plyPed = PlayerPedId()  
    if action == "Check In" then
        if PatientID then
            CheckPlayerOut()
        else
            --if (GetEntityHealth(PlayerPedId()) < 200) then
                BJCore.Functions.TriggerServerCallback('Pillbox:GetCapacity', function(hasCapacity,id)
                    if not hasCapacity then
                        exports['core']:SendAlert('inform', 'The hospital is currently full', 2500)
                    else
                        CheckPlayerIn(id)
                    end
                end, CurHospital)
            -- else
            --     exports['core']:SendAlert('error', 'You don\'t need medical attention', 3500)
            -- end
        end
    elseif action == "Lay Down" and pos and rot then
        LayingDown = not LayingDown
        if LayingDown then
            PutInBed(plyPed,pos,rot.y)
        end
    end
end

local MedicNotifId = 'EMS_MEDIC'
local HospNotifId1 = 'HOSP_NOTIF1'
local HospNotifId2 = 'HOSP_NOTIF2'
local HospNotifId3 = 'HOSP_NOTIF3'
local cam = nil
BeingTreated, doPay = false, false
function PutInBed(ped,pos,heading)
    isInHospitalBed = true
    DoScreenFadeOut(950)
    Wait(1000)
    cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 1, true, true)
    AttachCamToPedBone(cam, PlayerPedId(), 31085, 0, 0, 1.0 , true)
    SetCamFov(cam, 90.0)
    SetCamRot(cam, -90.0, 0.0, GetEntityHeading(PlayerPedId()) + 180, true)
    SetEntityCoordsNoOffset(ped, pos, 0, 0, 0)
    SetEntityHeading(ped, heading)
    BJCore.Functions.TriggerServerCallback('Pillbox:GetOnlineEMS', function(count)
        while not HasAnimDictLoaded("amb@lo_res_idles@") do RequestAnimDict("amb@lo_res_idles@"); Citizen.Wait(0); end
        TaskPlayAnim(ped, "amb@lo_res_idles@", "lying_face_up_lo_res_base", 8.0, 1.0, -1, 45, 1.0, 0, 0, 0)
        RemoveAnimDict("amb@lo_res_idles@") 

        Citizen.CreateThread(function(...) 
            while LayingDown do
                Citizen.Wait(0)
                DisablePlayerFiring(PlayerId(), true) -- Disable weapon firing
                DisableControlAction(0,  25, true) -- INPUT_AIM
                DisableControlAction(0,  30, true) -- UP
                DisableControlAction(0,  31, true) -- DOWN
                DisableControlAction(0,  32, true) -- UP
                DisableControlAction(0,  33, true) -- DOWN
                DisableControlAction(0,  34, true) -- LEFT
                DisableControlAction(0,  35, true) -- RIGHT
                DisableControlAction(0,  323, true) -- X           
                DisableControlAction(0, 142, true) -- MeleeAttackAlternate
                DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
                DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
                DisableControlAction(0, 46, true) -- VehicleMouseControlOverride
            end
        end)

        Wait(1000)
        DoScreenFadeIn(10000)
        local bedInteract = false
        if not count or count < Config.MinEMSCount then
            exports['core']:SendAlert('inform', 'There are no medics on call', 5500)
            exports['core']:PersistentAlert('start', HospNotifId1, 'inform', 'Press [H] to be treated by local doctors')
            if not isDead then
                exports['core']:PersistentAlert('start', HospNotifId2, 'inform', 'Press [E] to leave the bed')
            end

            while cam ~= nil do
                if not bedInteract then
                    if not isDead then
                        if IsControlJustPressed(0, 38) then
                            LeaveBed()
                            bedInteract = true                        
                        end
                    end               
                    if IsControlJustPressed(0, 74) or BeingTreated then
                        DoHealing()
                        bedInteract = true
                    end
                end
                Wait(0)
            end
        else
            TriggerServerEvent('MF_Trackables:Notify', 'Somebody requires medical attention at a Hospital', Config.Hospitals[CurHospital]["checkIn"], 'ambulance', 'hospital')
            exports['core']:PersistentAlert('start', MedicNotifId, 'inform', 'Waiting for a Medic')

            local timer = GetGameTimer()
            while (GetGameTimer() - timer) < (((Config.AutoHealTimer + 1)*Config.OnlineEMSTimerMultiplier) * 1000) and not BeingTreated do
                Citizen.Wait(0)
            end
            
            if not BeingTreated then
                exports['core']:SendAlert('inform', 'The medics on call have not responded', 7500)
                exports['core']:PersistentAlert('start', HospNotifId1, 'inform', 'Press [H] to be treated by local doctors')
                if not isDead then
                    exports['core']:PersistentAlert('start', HospNotifId2, 'inform', 'Press [E] to leave the bed')
                end               

                while cam ~= nil do
                    if not bedInteract then
                        if IsControlJustPressed(0, 74) then
                            DoHealing()
                            bedInteract = true
                        end
                        if not isDead then
                            if IsControlJustPressed(0, 38) then
                                LeaveBed()
                                bedInteract = true                        
                            end
                        end
                    end                  
                    Wait(0)
                end
            else
                exports['core']:SendAlert('inform', 'A medic is treating you', 5500)
                DoHealing()
            end
        end
    end)   
end

function DoHealing()
    exports['core']:PersistentAlert('end', MedicNotifId)
    exports['core']:PersistentAlert('end', HospNotifId1)
    exports['core']:PersistentAlert('end', HospNotifId2)
    local ped = PlayerPedId()
    exports['mythic_progbar']:Progress({
        name = "pill_healing",
        duration = (Config.AutoHealTimer - 2) * 1000,
        label = "Healing",
        useWhileDead = true,
        canCancel = false,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }
    }, function(status)
        if not status then
            SetEntityHealth(ped,200)
            ClearPedBloodDamage(ped)
            ResetPedVisibleDamage(ped)
            TriggerEvent('hospital:client:Revive')
            LeaveBed()
            doPay = true
        end
    end)
end

function LeaveBed()
    exports['core']:PersistentAlert('end', HospNotifId1)
    exports['core']:PersistentAlert('end', HospNotifId2)
    local ped = PlayerPedId()
    local getOutDict = 'switch@franklin@bed'
    local getOutAnim = 'sleep_getup_rubeyes'
    while not HasAnimDictLoaded(getOutDict) do RequestAnimDict(getOutDict) Citizen.Wait(0); end

    RenderScriptCams(0, true, 200, true, true)
    DestroyCam(cam, false)

    local h = 0
    if Config.Hospitals[CurHospital]["beds"][PatientID]["invert"] then h = Config.Hospitals[CurHospital]["beds"][PatientID]["pos"].y + 90
    else h = Config.Hospitals[CurHospital]["beds"][PatientID]["pos"].y - 90; end
    SetEntityHeading(ped, h)
    ClearPedTasks(ped)
    TaskPlayAnim(ped, getOutDict, getOutAnim, 8.0, -8.0, -1, 0, 0, false, false, false)
    Citizen.Wait(6000)
    ClearPedTasks(ped)
    isInHospitalBed = false
    RemoveAnimDict(getOutDict)
    LayingDown = false
end

function CheckPlayerIn(id)
    PatientID = id
    local canDo = false
    local dead = BJCore.Functions.GetPlayerData().metadata['isdead']
    if not dead then dead = InLaststand; end
    wasDead = dead
    TriggerServerEvent('Pillbox:CheckIn',id,CurHospital)
    if dead then
        exports['mythic_progbar']:Progress({
            name = "pill_checkin_dead",
            duration = 5000,
            label = "Checking In",
            useWhileDead = true,
            canCancel = false,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }
        }, function(status)
            if not status then
                Citizen.CreateThread(function(...)
                    DoScreenFadeOut(1000)
                    Wait(1100)
                    isInHospitalBed = true
                    TriggerEvent('ems:client:revive')
                    local timer = GetGameTimer()
                    while (GetGameTimer() - timer) < 2000 do
                        Citizen.Wait(0)
                        DoScreenFadeOut(1)
                    end
                    local loc = Config.Hospitals[CurHospital]["beds"][id]["pos"].xyz
                    local rot = Config.Hospitals[CurHospital]["beds"][id]["rot"]
                    PutInBed(PlayerPedId(),loc,rot.y)
                    LayingDown = true
                    canDo = true
                end)
            end
        end)
    else
        exports['mythic_progbar']:Progress({
            name = "pill_checkin_alive",
            duration = 5000,
            label = "Checking In",
            useWhileDead = true,
            canCancel = false,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            },
            animation = {
                animDict = "missheistdockssetup1clipboard@base",
                anim = "base",
                flags = 49,
            },
            prop = {
                model = "p_amb_clipboard_01",
                bone = 18905,
                coords = { x = 0.10, y = 0.02, z = 0.08 },
                rotation = { x = -80.0, y = 0.0, z = 0.0 },
            },
            -- propTwo = {
            --     model = "prop_pencil_01",
            --     bone = 58866,
            --     coords = { x = 0.12, y = 0.0, z = 0.001 },
            --     rotation = { x = -150.0, y = 0.0, z = 0.0 },
            -- },
        }, function(status)
            if not status then
                canDo = true
                exports['core']:SendAlert('inform', 'You have checked in. Go to an available bed to be seen to', 3500)
            end
        end)
    end

    while not canDo do Citizen.Wait(0); end
--   if Config.UseHospitalClothing then
--     local plyPed = PlayerPedId()
--     TriggerEvent('skinchanger:getSkin', function(skin)
--       if skin.sex == 0 then
--         TriggerEvent('skinchanger:loadClothes', skin, Outfits['patient_wear'].male)
--       else
--         TriggerEvent('skinchanger:loadClothes', skin, Outfits['patient_wear'].female)
--       end
--     end)  
--   end
end


function CheckPlayerOut(curH)
    if curH == nil then curH = CurHospital; end
    local duration = 2500
    if wasDead then
        duration = 7500
    end
    exports['mythic_progbar']:Progress({
        name = "pill_checkout",
        duration = duration,
        label = "Checking Out",
        useWhileDead = true,
        canCancel = false,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = "missheistdockssetup1clipboard@base",
            anim = "base",
            flags = 49,
        },
        prop = {
            model = "p_amb_clipboard_01",
            bone = 18905,
            coords = { x = 0.10, y = 0.02, z = 0.08 },
            rotation = { x = -80.0, y = 0.0, z = 0.0 },
        },
        propTwo = {
            model = "prop_pencil_01",
            bone = 58866,
            coords = { x = 0.12, y = 0.0, z = 0.001 },
            rotation = { x = -150.0, y = 0.0, z = 0.0 },
        },
    }, function(status)
        if not status then
            TriggerServerEvent('Pillbox:CheckOut',PatientID,curH)
            -- BJCore.Functions.TriggerServerCallback('tac_skin:getPlayerSkin', function(skin, jobSkin, ped)
            --  if ped ~= nil then
            --         local model = GetHashKey(ped)
            --      if IsModelInCdimage(model) and IsModelValid(model) then
            --          RequestModel(model)
            --          while not HasModelLoaded(model) do
            --              Citizen.Wait(0)
            --          end
            --          SetPlayerModel(PlayerId(), model)
            --         if ped ~= "mp_f_freemode_01" and ped ~= "mp_m_freemode_01" then 
            --             SetPedRandomComponentVariation(PlayerPedId(), true)
            --         else
            --           SetPedComponentVariation(PlayerPedId(), 11, 0, 240, 0)
            --           SetPedComponentVariation(PlayerPedId(), 8, 0, 240, 0)
            --           SetPedComponentVariation(PlayerPedId(), 11, 6, 1, 0)
            --         end
            --      end
            --  else
            --      TriggerEvent('skinchanger:loadSkin', skin)
            --  end
            -- end)
            if doPay then TriggerServerEvent('Pillbox:pay'); end
            PatientID = false
            LayingDown = false
            doPay = false
        end
    end)
end

function GetClosestHospital(plyPos)
    local closestKey,closestVal,closestDist
    for k,v in pairs(Config.Hospitals) do
        local dist = #(plyPos - v["checkIn"])
        if not closestDist or dist < closestDist then
            closestKey = k
            closestVal = v
            closestDist = dist
        end
    end
    if not closestDist then return false,false,999999
    else return closestKey,closestVal,closestDist
    end
end

function GetClosestAction(plyPos, hKey)
    local plyPos = plyPos
    local closestKey,closestVal,closestDist
    for k,v in pairs(Config.Hospitals[hKey]["beds"]) do
        if v then
            local coords = v
            local text = v
            if v.x == nil then
                coords = v.circle
                text = v.text
            end
            local dist = #(plyPos - coords)
            if not closestDist or dist < closestDist then
                closestKey = k
                closestVal = text
                closestDist = dist
            end
        end
    end
    if not closestKey then return false,false,999999
    else return closestKey,closestVal,closestDist
    end
end

function TreatPlayer()
    local plyPed = PlayerPedId()
    local plyPos = GetEntityCoords(plyPed)
    if CurHospital and CurHospital ~= nil then
        local closestKey,closestVal,closestDist = GetClosestBed(plyPos, CurHospital) 
        if closestDist < Config.InteractDist then
            local closestPly = BJCore.Functions.GetClosestPlayer()
            local closestPed = GetPlayerPed(closestPly)
            if closestPed ~= plyPed then
                TaskStartScenarioInPlace(plyPed, "PROP_HUMAN_BUM_BIN", 0, true)
                Wait(5000)
                TriggerServerEvent('Pillbox:TreatPlayer', GetPlayerServerId(closestPly))
                Wait(5000)
                TaskStartScenarioInPlace(plyPed, "PROP_HUMAN_BUM_BIN", 0, false)
                Wait(1000)
                ClearPedTasksImmediately(plyPed)
            end
        else
            BJCore.Functions.Notify("You're not near a hospital bed", "error")
        end
    end
end

function GetClosestBed(plyPos, hKey)
    local key,val,dist
    for k,v in pairs(Config.Hospitals[hKey]["beds"]) do
        local nDist = #(plyPos.xyz - v["pos"].xyz)
        if not dist or nDist < dist then
            key = k
            val = v
            dist = nDist
        end
    end
    if key then return key,val,dist
    else return false,false,false
    end
end

RegisterNetEvent('Pillbox:DoNotify')
RegisterNetEvent('Pillbox:GetTreated')
RegisterNetEvent('Pillbox:TreatPlayer')
AddEventHandler('Pillbox:DoNotify', function(...) TriggerServerEvent('MF_Trackables:Notify', 'Somebody requires medical attention at PillBox Hospital', HospitalPosition, 'ambulance'); end)
AddEventHandler('Pillbox:GetTreated', function(...) BeingTreated = true end)
AddEventHandler('Pillbox:TreatPlayer', function(...) TreatPlayer(...); end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        if isStatusChecking then
            for k, v in pairs(statusChecks) do
                local x,y,z = table.unpack(GetPedBoneCoords(statusCheckPed, v.bone))
                BJCore.Functions.DrawText3D(x, y, z, v.label)
            end
        end

        if isHealingPerson then
            if not IsEntityPlayingAnim(PlayerPedId(), healAnimDict, healAnim, 3) then
                loadAnimDict(healAnimDict)  
                TaskPlayAnim(PlayerPedId(), healAnimDict, healAnim, 3.0, 3.0, -1, 49, 0, 0, 0, 0)
            end
        end
        --if not isStatusChecking and not isHealingPerson then Citizen.Wait(250); end
    end
end)

RegisterNetEvent('hospital:client:SendAlert')
AddEventHandler('hospital:client:SendAlert', function(msg)
    PlaySound(-1, "Menu_Accept", "Phone_SoundSet_Default", 0, 0, 1)
    TriggerEvent("chatMessage", "PAGER", "error", msg)
end)

RegisterNetEvent('112:client:SendAlert')
AddEventHandler('112:client:SendAlert', function(msg, blipSettings)
    if (PlayerJob.name == "police" or PlayerJob.name == "ambulance" or PlayerJob.name == "doctor") and onDuty then
        if blipSettings ~= nil then
            local transG = 250
            local blip = AddBlipForCoord(blipSettings.x, blipSettings.y, blipSettings.z)
            SetBlipSprite(blip, blipSettings.sprite)
            SetBlipColour(blip, blipSettings.color)
            SetBlipDisplay(blip, 4)
            SetBlipAlpha(blip, transG)
            SetBlipScale(blip, blipSettings.scale)
            SetBlipAsShortRange(blip, false)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(blipSettings.text)
            EndTextCommandSetBlipName(blip)
            while transG ~= 0 do
                Wait(180 * 4)
                transG = transG - 1
                SetBlipAlpha(blip, transG)
                if transG == 0 then
                    SetBlipSprite(blip, 2)
                    RemoveBlip(blip)
                    return
                end
            end
        end
    end
end)

RegisterNetEvent('hospital:client:AiCall')
AddEventHandler('hospital:client:AiCall', function()
    local PlayerPeds = {}
    for _, player in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(player)
        table.insert(PlayerPeds, ped)
    end
    local player = PlayerPedId()
    local coords = GetEntityCoords(player)
    local closestPed, closestDistance = BJCore.Functions.GetClosestPed(coords, PlayerPeds)
    local gender = BJCore.Functions.GetPlayerData().gender
    local s1, s2 = Citizen.InvokeNative(0x2EB41072B4C1E4C0, coords.x, coords.y, coords.z, Citizen.PointerValueInt(), Citizen.PointerValueInt())
    local street1 = GetStreetNameFromHashKey(s1)
    local street2 = GetStreetNameFromHashKey(s2)
    if closestDistance < 50.0 and closestPed ~= 0 then
        MakeCall(closestPed, gender, street1, street2)
    end
end)

function MakeCall(ped, male, street1, street2)
    local callAnimDict = "cellphone@"
    local callAnim = "cellphone_call_listen_base"
    local rand = (math.random(6,9) / 100) + 0.3
    local rand2 = (math.random(6,9) / 100) + 0.3
    local coords = GetEntityCoords(PlayerPedId())
    local blipsettings = {
        x = coords.x,
        y = coords.y,
        z = coords.z,
        sprite = 280,
        color = 4,
        scale = 0.9,
        text = "Injured person"
    }

    if math.random(10) > 5 then
        rand = 0.0 - rand
    end

    if math.random(10) > 5 then
        rand2 = 0.0 - rand2
    end

    local moveto = GetOffsetFromEntityInWorldCoords(PlayerPedId(), rand, rand2, 0.0)

    TaskGoStraightToCoord(ped, moveto, 2.5, -1, 0.0, 0.0)
    SetPedKeepTask(ped, true) 

    local dist = #(moveto.xy - GetEntityCoords(ped).xy)

    while dist > 3.5 and isDead do
        TaskGoStraightToCoord(ped, moveto, 2.5, -1, 0.0, 0.0)
        dist = #(moveto.xy - GetEntityCoords(ped).xy)
        Citizen.Wait(100)
    end

    ClearPedTasksImmediately(ped)
    TaskLookAtEntity(ped, PlayerPedId(), 5500.0, 2048, 3)
    TaskTurnPedToFaceEntity(ped, PlayerPedId(), 5500)

    Citizen.Wait(3000)

    --TaskStartScenarioInPlace(ped,"WORLD_HUMAN_STAND_MOBILE", 0, 1)
    loadAnimDict(callAnimDict)
    TaskPlayAnim(ped, callAnimDict, callAnim, 1.0, 1.0, -1, 49, 0, 0, 0, 0)

    SetPedKeepTask(ped, true) 

    Citizen.Wait(5000)
    TriggerServerEvent('MF_Trackables:Notify', 'Injured person reported', GetEntityCoords(PlayerPedId()), 'ambulance', 'hospital')
    TriggerServerEvent("hospital:server:MakeDeadCall", blipsettings, male, street1, street2)

    SetEntityAsNoLongerNeeded(ped)
    ClearPedTasks(ped)
end

RegisterNetEvent('hospital:client:RevivePlayer')
AddEventHandler('hospital:client:RevivePlayer', function()
    BJCore.Functions.GetPlayerData(function(PlayerData)
        if PlayerJob.name == "ambulance" then
            local player, distance = BJCore.Functions.GetClosestPlayer()
            if player ~= -1 and distance < 5.0 then
                local playerId = GetPlayerServerId(player)
                isHealingPerson = true
                exports['mythic_progbar']:Progress({
                    name = "hospital_revive",
                    duration = 10000,
                    label = "Reviving",
                    useWhileDead = true,
                    canCancel = true,
                    controlDisables = {
                        disableMovement = true,
                        disableCarMovement = true,
                        disableMouse = false,
                        disableCombat = true,
                    },
                    animation = {
                        animDict = healAnimDict,
                        anim = healAnim,
                        flags = 16,
                    },
                }, function(status)
                    if not status then
                        isHealingPerson = false
                        StopAnimTask(PlayerPedId(), healAnimDict, "exit", 1.0)
                        BJCore.Functions.Notify("You revived a person")
                        TriggerServerEvent("hospital:server:RevivePlayer", playerId)
                    else
                        isHealingPerson = false
                        StopAnimTask(PlayerPedId(), healAnimDict, "exit", 1.0)
                        BJCore.Functions.Notify("Failed", "error")                        
                    end
                end)
            end
        end
    end)
end)

RegisterNetEvent('hospital:client:CheckStatus')
AddEventHandler('hospital:client:CheckStatus', function()
    BJCore.Functions.GetPlayerData(function(PlayerData)
        if PlayerJob.name == "doctor" or PlayerJob.name == "ambulance" or PlayerJob.name == "police" then
            local player, distance = BJCore.Functions.GetClosestPlayer()
            if player ~= -1 and distance < 5.0 then
                local playerId = GetPlayerServerId(player)
                statusCheckPed = GetPlayerPed(player)
                BJCore.Functions.TriggerServerCallback('hospital:GetPlayerStatus', function(result)
                    if result ~= nil then
                        for k, v in pairs(result) do
                            if k ~= "BLEED" and k ~= "WEAPONWOUNDS" then
                                table.insert(statusChecks, {bone = Config.BoneIndexes[k], label = v.label .." (".. Config.WoundStates[v.severity] ..")"})
                            elseif result["WEAPONWOUNDS"] ~= nil then 
                                for k, v in pairs(result["WEAPONWOUNDS"]) do
                                    TriggerEvent("chatMessage", "STATUS CHECK", "error", WeaponDamageList[v])
                                end
                            elseif result["BLEED"] > 0 then
                                TriggerEvent("chatMessage", "STATUS CHECK", "error", "Is "..Config.BleedingStates[v].label)
                            end
                        end
                        isStatusChecking = true
                        statusCheckTime = Config.CheckTime
                    else
                        BJCore.Functions.Notify("Target has no health markers", "primary")
                    end
                end, playerId)
            else
                BJCore.Functions.Notify("No one nearby", "error")
            end
        end
    end)
end)

RegisterNetEvent('hospital:client:TreatWounds')
AddEventHandler('hospital:client:TreatWounds', function()
    BJCore.Functions.GetPlayerData(function(PlayerData)
        if PlayerJob.name == "doctor" or PlayerJob.name == "ambulance" then
            local player, distance = BJCore.Functions.GetClosestPlayer()
            if player ~= -1 and distance < 2.0 then
                local playerId = GetPlayerServerId(player)
                isHealingPerson = true
                exports['mythic_progbar']:Progress({
                    name = "hospital_healwounds",
                    duration = 5000,
                    label = "Healing wounds",
                    useWhileDead = true,
                    canCancel = true,
                    controlDisables = {
                        disableMovement = true,
                        disableCarMovement = true,
                        disableMouse = false,
                        disableCombat = true,
                    },
                    animation = {
                        animDict = healAnimDict,
                        anim = healAnim,
                        flags = 16,
                    },
                }, function(status)
                    if not status then
                        isHealingPerson = false
                        StopAnimTask(PlayerPedId(), healAnimDict, "exit", 1.0)
                        BJCore.Functions.Notify("You treated this persons wounds")
                        TriggerServerEvent("hospital:server:TreatWounds", playerId)
                    else
                        isHealingPerson = false
                        StopAnimTask(PlayerPedId(), healAnimDict, "exit", 1.0)
                        BJCore.Functions.Notify("Failed", "error")                      
                    end
                end)
            end
        end
    end)
end)

function MenuGarage(isDown)
    ped = PlayerPedId();
    MenuTitle = "Garage"
    ClearMenu()
    Menu.addButton("Vehicles", "VehicleList", isDown)
    Menu.addButton("Close Menu", "closeMenuFull", nil) 
end

function VehicleList(isDown)
    ped = PlayerPedId();
    MenuTitle = "Vehicles:"
    ClearMenu()
    for k, v in pairs(Config.Vehicles) do
        Menu.addButton(Config.Vehicles[k], "TakeOutVehicle", {k, isDown}, "Garage", " Engine: 100%", " Body: 100%", " Fuel: 100%")
    end
        
    Menu.addButton("Back", "MenuGarage",nil)
end

function TakeOutVehicle(vehicleInfo)
    local coords = Config.Locations["vehicle"][currentGarage]
    BJCore.Functions.SpawnVehicle(vehicleInfo[1], function(veh)
        SetVehicleNumberPlateText(veh, "AMBU"..tostring(math.random(1000, 9999)))
        SetEntityHeading(veh, coords.w)
        exports['legacyfuel']:SetFuel(veh, 100.0)
        closeMenuFull()
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        TriggerEvent('keys:addNew', veh, GetVehicleNumberPlateText(veh))
        SetVehicleEngineOn(veh, true, true)
    end, coords, true)
end

function closeMenuFull()
    Menu.hidden = true
    currentGarage = nil
    ClearMenu()
end

Citizen.CreateThread(function()
    while not BJCore do Wait(1000); end
    while not BJCore.Functions.IsPlayerLoaded() do Wait(1000); end
    Update()
end)
