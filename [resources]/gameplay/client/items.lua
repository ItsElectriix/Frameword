local alcoholCount = 0
local onWeed = false
local usingBinoculars = false

Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(10)
        if alcoholCount > 0 then
            Citizen.Wait(1000 * 60 * 15)
            alcoholCount = alcoholCount - 1
        else
            Citizen.Wait(2000)
        end
    end
end)

local fov_max = 70.0
local fov_min = 5.0 -- max zoom level (smaller fov is more zoom)
local zoomspeed = 10.0 -- camera zoom speed
local speed_lr = 8.0 -- speed by which the camera pans left-right
local speed_ud = 8.0 -- speed by which the camera pans up-down
        
local binoculars = false
local fov = (fov_max+fov_min)*0.5

exports('UsingBinoculars', function()
    return usingBinoculars
end)

RegisterNetEvent("binoculars:Toggle")
AddEventHandler("binoculars:Toggle", function()
    usingBinoculars = not usingBinoculars
    if usingBinoculars then
        local lPed = PlayerPedId()
        if not ( IsPedSittingInAnyVehicle( lPed ) ) then
            Citizen.CreateThread(function()
                TaskStartScenarioInPlace(GetPlayerPed(-1), "WORLD_HUMAN_BINOCULARS", 0, 1)
                PlayAmbientSpeech1(GetPlayerPed(-1), "GENERIC_CURSE_MED", "SPEECH_PARAMS_FORCE")
            end)
        end
        exports['mythic_progbar']:Progress({
            name = "gameplay_binos",
            duration = 2000,
            label = "Using Binoculars",
            canCancel = false,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
                disableInteract = true
            },
        }, function(status)
            if not status then
                Citizen.CreateThread(function()
                    SetTimecycleModifier("default")
    
                    SetTimecycleModifierStrength(0.3)
                            
                    local scaleform = RequestScaleformMovie("BINOCULARS")
                            
                    while not HasScaleformMovieLoaded(scaleform) do
                        Citizen.Wait(10)
                    end
                    local vehicle = GetVehiclePedIsIn(lPed)
                    local cam = CreateCam("DEFAULT_SCRIPTED_FLY_CAMERA", true)
                
                    AttachCamToEntity(cam, lPed, 0.0,0.0,0.75, true)
                    SetCamRot(cam, 0.0,0.0,GetEntityHeading(lPed))
                    SetCamFov(cam, fov)
                    RenderScriptCams(true, false, 0, 1, 0)
                    PushScaleformMovieFunction(scaleform, "SET_CAM_LOGO")
                    PushScaleformMovieFunctionParameterInt(0) -- 0 for nothing, 1 for LSPD logo
                    PopScaleformMovieFunctionVoid()
                
                    TriggerEvent('hud:toggle', false)
                    while usingBinoculars and not IsEntityDead(lPed) and (GetVehiclePedIsIn(lPed) == vehicle) and true do
                        if IsControlJustPressed(0, 177) then -- Toggle off binoculars (backspace)
                            PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
                            ClearPedTasks(GetPlayerPed(-1))
                            usingBinoculars = false
                        end
                    
                        local zoomvalue = (1.0/(fov_max-fov_min))*(fov-fov_min)
                        CheckInputRotation(cam, zoomvalue)
                    
                        HandleZoom(cam)
                    
                        DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
                        SetEntityLocallyInvisible(PlayerPedId())
                        Citizen.Wait(2)
                    end
                
                    TriggerEvent('hud:toggle', true)
                    usingBinoculars = false
                    ClearPedTasks(GetPlayerPed(-1))
                    ClearTimecycleModifier()
                    fov = (fov_max+fov_min)*0.5
                    RenderScriptCams(false, false, 0, 1, 0)
                    SetScaleformMovieAsNoLongerNeeded(scaleform)
                    DestroyCam(cam, false)
                    SetNightvision(false)
                    SetSeethrough(false)
                end)
            end
        end)
    end
end)

function CheckInputRotation(cam, zoomvalue)
	local rightAxisX = GetDisabledControlNormal(0, 220)
	local rightAxisY = GetDisabledControlNormal(0, 221)
	local rotation = GetCamRot(cam, 2)
	if rightAxisX ~= 0.0 or rightAxisY ~= 0.0 then
		new_z = rotation.z + rightAxisX*-1.0*(speed_ud)*(zoomvalue+0.1)
		new_x = math.max(math.min(20.0, rotation.x + rightAxisY*-1.0*(speed_lr)*(zoomvalue+0.1)), -89.5)
		SetCamRot(cam, new_x, 0.0, new_z, 2)
	end
end

function HandleZoom(cam)
	local lPed = GetPlayerPed(-1)
	if not ( IsPedSittingInAnyVehicle( lPed ) ) then

		if IsDisabledControlJustPressed(0,241) then -- Scrollup
			fov = math.max(fov - zoomspeed, fov_min)
		end
		if IsDisabledControlJustPressed(0,242) then
			fov = math.min(fov + zoomspeed, fov_max) -- ScrollDown
		end
		local current_fov = GetCamFov(cam)
		if math.abs(fov-current_fov) < 0.1 then
			fov = current_fov
		end
		SetCamFov(cam, current_fov + (fov - current_fov)*0.05)
	else
		if IsDisabledControlJustPressed(0,17) then -- Scrollup
			fov = math.max(fov - zoomspeed, fov_min)
		end
		if IsDisabledControlJustPressed(0,16) then
			fov = math.min(fov + zoomspeed, fov_max) -- ScrollDown
		end
		local current_fov = GetCamFov(cam)
		if math.abs(fov-current_fov) < 0.1 then -- the difference is too small, just set the value directly to avoid unneeded updates to FOV of order 10^-5
			fov = current_fov
		end
		SetCamFov(cam, current_fov + (fov - current_fov)*0.05) -- Smoothing of camera zoom
	end
end

RegisterNetEvent("consumables:client:UseJoint")
AddEventHandler("consumables:client:UseJoint", function()
    exports['mythic_progbar']:Progress({
        name = "smoke_joint",
        duration = 1500,
        label = "Lighting joint",
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
            TriggerEvent("inventory:client:ItemBox", BJCore.Shared.Items["joint"], "remove")
            if IsPedInAnyVehicle(PlayerPedId(), false) then
                TriggerEvent('animations:client:EmoteCommandStart', {"smoke3"})
            else
                TriggerEvent('animations:client:EmoteCommandStart', {"smokeweed"})
            end
            JointEffect()
            TriggerEvent("evidence:client:SetStatus", "weedsmell", 300)
            TriggerEvent('animations:client:SmokeWeed')
        end
    end)
end)

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(5)
    end
end

function EquipParachuteAnim()
    loadAnimDict("clothingshirt")        
    TaskPlayAnim(PlayerPedId(), "clothingshirt", "try_shirt_positive_d", 8.0, 1.0, -1, 49, 0, 0, 0, 0)
end

local ParachuteEquiped = false

RegisterNetEvent("consumables:client:UseParachute")
AddEventHandler("consumables:client:UseParachute", function()
    EquipParachuteAnim()
    exports['mythic_progbar']:Progress({
        name = "use_parachute",
        duration = 5000,
        label = "Equiping parachute",
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
            local ped = PlayerPedId()
            TriggerEvent("inventory:client:ItemBox", BJCore.Shared.Items["parachute"], "remove")
            GiveWeaponToPed(ped, GetHashKey("GADGET_PARACHUTE"), 1, false)
            local ParachuteData = {
                outfitData = {
                    ["bag"]   = { item = 7, texture = 0},
                }
            }
            TriggerEvent('bj-clothing:client:loadOutfit', ParachuteData)
            ParachuteEquiped = true
            TaskPlayAnim(ped, "clothingshirt", "exit", 8.0, 1.0, -1, 49, 0, 0, 0, 0)
        end
    end)
end)

RegisterNetEvent("consumables:client:ResetParachute")
AddEventHandler("consumables:client:ResetParachute", function()
    if ParachuteEquiped then 
        EquipParachuteAnim()
        exports['mythic_progbar']:Progress({
            name = "reset_parachute",
            duration = 40000,
            label = "Packing parachute",
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
                local ped = PlayerPedId()
                TriggerEvent("inventory:client:ItemBox", BJCore.Shared.Items["parachute"], "add")
                local ParachuteRemoveData = { 
                    outfitData = { 
                        ["bag"] = { item = 0, texture = 0}
                    }
                }
                TriggerEvent('bj-clothing:client:loadOutfit', ParachuteRemoveData)
                TaskPlayAnim(ped, "clothingshirt", "exit", 8.0, 1.0, -1, 49, 0, 0, 0, 0)
                TriggerServerEvent("smallpenis:server:AddParachute")
                ParachuteEquiped = false
            end
        end)
    else
        BJCore.Functions.Notify("You dont have a parachute", "error")
    end
end)

RegisterNetEvent("consumables:client:UseRedSmoke")
AddEventHandler("consumables:client:UseRedSmoke", function()
    if ParachuteEquiped then
        local ped = PlayerPedId()
        SetPlayerParachuteSmokeTrailColor(ped, 255, 0, 0)
        SetPlayerCanLeaveParachuteSmokeTrail(ped, true)
        TriggerEvent("inventory:client:Itembox", BJCore.Shared.Items["smoketrailred"], "remove")
    else
        BJCore.Functions.Notify("You need to have a parachute to activate smoke", "error")    
    end
end)

RegisterNetEvent("consumables:client:UseArmor")
AddEventHandler("consumables:client:UseArmor", function()
    exports['mythic_progbar']:Progress({
        name = "use_armor",
        duration = 8000,
        label = "Equiping Armour",
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
            TriggerEvent("inventory:client:ItemBox", BJCore.Shared.Items["armor"], "remove")
            TriggerServerEvent('hospital:server:SetArmor', 100)
            TriggerServerEvent("BJCore:Server:RemoveItem", "armor", 1)
            SetPedArmour(PlayerPedId(), 100)
        end
    end)
end)

local currentVest = nil
local currentVestTexture = nil
RegisterNetEvent("consumables:client:UseHeavyArmor")
AddEventHandler("consumables:client:UseHeavyArmor", function()
    local ped = PlayerPedId()
    local PlayerData = BJCore.Functions.GetPlayerData()
    exports['mythic_progbar']:Progress({
        name = "use_heavyarmor",
        duration = 5000,
        label = "Equiping Heavy Armour",
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
            if PlayerData.charinfo.gender == 0 then
                currentVest = GetPedDrawableVariation(ped, 9)
                currentVestTexture = GetPedTextureVariation(ped, 9)
                if GetPedDrawableVariation(ped, 9) == 7 then
                    SetPedComponentVariation(ped, 9, 19, GetPedTextureVariation(ped, 9), 2)
                else
                    SetPedComponentVariation(ped, 9, 5, 2, 2) -- blauw
                end
            else
                currentVest = GetPedDrawableVariation(ped, 30)
                currentVestTexture = GetPedTextureVariation(ped, 30)
                SetPedComponentVariation(ped, 9, 30, 0, 2)
            end
            TriggerEvent("inventory:client:ItemBox", BJCore.Shared.Items["heavyarmor"], "remove")
            TriggerServerEvent("BJCore:Server:RemoveItem", "heavyarmor", 1)
            SetPedArmour(ped, 100)
        end
    end)
end)

RegisterNetEvent("consumables:client:ResetArmor")
AddEventHandler("consumables:client:ResetArmor", function()
    local ped = PlayerPedId()
    if currentVest ~= nil and currentVestTexture ~= nil then
        exports['mythic_progbar']:Progress({
            name = "remove_armor",
            duration = 5000,
            label = "Removing Armour",
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
                SetPedComponentVariation(ped, 9, currentVest, currentVestTexture, 2)
                SetPedArmour(ped, 0)
                TriggerEvent("inventory:client:ItemBox", BJCore.Shared.Items["heavyarmor"], "add")
                TriggerServerEvent("BJCore:Server:AddItem", "heavyarmor", 1)
            end
        end)
    else
        BJCore.Functions.Notify("You're not wearing a vest", "error")
    end
end)

RegisterNetEvent("consumables:client:DrinkAlcohol")
AddEventHandler("consumables:client:DrinkAlcohol", function(itemName)
    TriggerEvent('animations:client:EmoteCommandStart', {"drink"})
    exports['mythic_progbar']:Progress({
        name = "drink_alcohol",
        duration = math.random(3000, 6000),
        label = "Drinking",
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
            TriggerEvent('animations:client:EmoteCommandStart', {"c"})
            TriggerEvent("inventory:client:ItemBox", BJCore.Shared.Items[itemName], "remove")
            TriggerServerEvent("BJCore:Server:RemoveItem", itemName, 1)
            TriggerServerEvent("BJCore:Server:SetMetaData", "thirst", BJCore.Functions.GetPlayerData().metadata["thirst"] + Consumeables[itemName])
            alcoholCount = alcoholCount + 1
            if alcoholCount > 1 and alcoholCount < 4 then
                TriggerEvent("evidence:client:SetStatus", "alcohol", 200)
            elseif alcoholCount >= 4 then
                TriggerEvent("evidence:client:SetStatus", "heavyalcohol", 200)
            end
            local alcoholStrength = 0.5
            if itemName == "vodka" or itemName == "whiskey" then alcoholStrength = 1.0 end
            TriggerEvent("fx:run", "alcohol", 180, alcoholStrength)
        else
            TriggerEvent('animations:client:EmoteCommandStart', {"c"})
            BJCore.Functions.Notify("Cancelled", "error")
        end
    end)
end)

RegisterNetEvent("consumables:client:Cokebaggy")
AddEventHandler("consumables:client:Cokebaggy", function()
    exports['mythic_progbar']:Progress({
        name = "snort_coke",
        duration = math.random(5000, 8000),
        label = "Snorting coke",
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = false,
            disableCarMovement = false,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = "switch@trevor@trev_smoking_meth",
            anim = "trev_smoking_meth_loop",
            flags = 49,
        },        
    }, function(status)
        if not status then
            StopAnimTask(PlayerPedId(), "switch@trevor@trev_smoking_meth", "trev_smoking_meth_loop", 1.0)
            TriggerServerEvent("BJCore:Server:RemoveItem", "cokebaggy", 1)
            TriggerEvent("inventory:client:ItemBox", BJCore.Shared.Items["cokebaggy"], "remove")
            TriggerEvent("evidence:client:SetStatus", "widepupils", 200)
            CokeBaggyEffect()
        else
            StopAnimTask(PlayerPedId(), "switch@trevor@trev_smoking_meth", "trev_smoking_meth_loop", 1.0)
            BJCore.Functions.Notify("Cancelled", "error")
        end
    end)
end)

RegisterNetEvent("consumables:client:Crackbaggy")
AddEventHandler("consumables:client:Crackbaggy", function()
    exports['mythic_progbar']:Progress({
        name = "smoke_crack",
        duration = math.random(7000, 10000),
        label = "Smoking crack",
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = false,
            disableCarMovement = false,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = "switch@trevor@trev_smoking_meth",
            anim = "trev_smoking_meth_loop",
            flags = 49,
        },        
    }, function(status)
        if not status then
            StopAnimTask(PlayerPedId(), "switch@trevor@trev_smoking_meth", "trev_smoking_meth_loop", 1.0)
            TriggerServerEvent("BJCore:Server:RemoveItem", "crack_baggy", 1)
            TriggerEvent("inventory:client:ItemBox", BJCore.Shared.Items["crack_baggy"], "remove")
            TriggerEvent("evidence:client:SetStatus", "widepupils", 300)
            CrackBaggyEffect()
        else
            StopAnimTask(PlayerPedId(), "switch@trevor@trev_smoking_meth", "trev_smoking_meth_loop", 1.0)
            BJCore.Functions.Notify("Cancelled", "error")
        end
    end) 
end)

RegisterNetEvent('consumables:client:EcstasyBaggy')
AddEventHandler('consumables:client:EcstasyBaggy', function()
    exports['mythic_progbar']:Progress({
        name = "use_ecstasy",
        duration = 3000,
        label = "Popping pill",
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = false,
            disableCarMovement = false,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = "mp_suicide",
            anim = "pill",
            flags = 49,
        },        
    }, function(status)
        if not status then
            StopAnimTask(PlayerPedId(), "mp_suicide", "pill", 1.0)
            TriggerServerEvent("BJCore:Server:RemoveItem", "xtcbaggy", 1)
            TriggerEvent("inventory:client:ItemBox", BJCore.Shared.Items["xtcbaggy"], "remove")
            EcstasyEffect()
        else
            StopAnimTask(PlayerPedId(), "mp_suicide", "pill", 1.0)
            BJCore.Functions.Notify("Cancelled", "error")
        end
    end)     
end)

RegisterNetEvent("consumables:client:Eat")
AddEventHandler("consumables:client:Eat", function(itemName)
    TriggerEvent('animations:client:EmoteCommandStart', {"eat"})
    exports['mythic_progbar']:Progress({
        name = "on_eat",
        duration = 3000,
        label = "Eating",
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
            TriggerEvent("inventory:client:ItemBox", BJCore.Shared.Items[itemName], "remove")
            TriggerEvent('animations:client:EmoteCommandStart', {"c"})
            TriggerServerEvent("BJCore:Server:SetMetaData", "hunger", BJCore.Functions.GetPlayerData().metadata["hunger"] + Consumeables[itemName])
            TriggerServerEvent('bj-hud:Server:RelieveStress', math.random(2, 4))
        end
    end)
end)

RegisterNetEvent("consumables:client:Drink")
AddEventHandler("consumables:client:Drink", function(itemName)
    TriggerEvent('animations:client:EmoteCommandStart', {"drink"})
    exports['mythic_progbar']:Progress({
        name = "drink_something",
        duration = 2500,
        label = "Drinking",
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
            TriggerEvent("inventory:client:ItemBox", BJCore.Shared.Items[itemName], "remove")
            TriggerEvent('animations:client:EmoteCommandStart', {"c"})
            TriggerServerEvent("BJCore:Server:SetMetaData", "thirst", BJCore.Functions.GetPlayerData().metadata["thirst"] + Consumeables[itemName])
        end
    end)
end)

function EcstasyEffect()
    local startStamina = 30
    SetFlash(0, 0, 500, 7000, 500)
    while startStamina > 0 do 
        Citizen.Wait(1000)
        startStamina = startStamina - 1
        RestorePlayerStamina(PlayerId(), 1.0)
        if math.random(1, 100) < 51 then
            SetFlash(0, 0, 500, 7000, 500)
            ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.08)
        end
    end
    if IsPedRunning(PlayerPedId()) then
        SetPedToRagdoll(PlayerPedId(), math.random(1000, 3000), math.random(1000, 3000), 3, 0, 0, 0)
    end

    startStamina = 0
end

function JointEffect()
    if not onWeed then
        local RelieveOdd = math.random(35, 45)
        onWeed = true
        local weedTime = Config.JointEffectTime
        Citizen.CreateThread(function()
            while onWeed do 
                SetPlayerHealthRechargeMultiplier(PlayerId(), 1.8)
                Citizen.Wait(1000)
                weedTime = weedTime - 1
                if weedTime == RelieveOdd then
                    TriggerServerEvent('bj-hud:Server:RelieveStress', math.random(14, 18))
                end
                if weedTime <= 0 then
                    onWeed = false
                end
            end
        end)
    end
end

function CrackBaggyEffect()
    local startStamina = 8
    AlienEffect()
    SetRunSprintMultiplierForPlayer(PlayerId(), 1.3)
    while startStamina > 0 do 
        Citizen.Wait(1000)
        if math.random(1, 100) < 10 then
            RestorePlayerStamina(PlayerId(), 1.0)
        end
        startStamina = startStamina - 1
        if math.random(1, 100) < 60 and IsPedRunning(PlayerPedId()) then
            SetPedToRagdoll(PlayerPedId(), math.random(1000, 2000), math.random(1000, 2000), 3, 0, 0, 0)
        end
        if math.random(1, 100) < 51 then
            AlienEffect()
        end
    end
    if IsPedRunning(PlayerPedId()) then
        SetPedToRagdoll(PlayerPedId(), math.random(1000, 3000), math.random(1000, 3000), 3, 0, 0, 0)
    end

    startStamina = 0
    SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
end

function CokeBaggyEffect()
    local startStamina = 20
    AlienEffect()
    SetRunSprintMultiplierForPlayer(PlayerId(), 1.1)
    while startStamina > 0 do 
        Citizen.Wait(1000)
        if math.random(1, 100) < 20 then
            RestorePlayerStamina(PlayerId(), 1.0)
        end
        startStamina = startStamina - 1
        if math.random(1, 100) < 10 and IsPedRunning(PlayerPedId()) then
            SetPedToRagdoll(PlayerPedId(), math.random(1000, 3000), math.random(1000, 3000), 3, 0, 0, 0)
        end
        if math.random(1, 300) < 10 then
            AlienEffect()
            Citizen.Wait(math.random(3000, 6000))
        end
    end
    if IsPedRunning(PlayerPedId()) then
        SetPedToRagdoll(PlayerPedId(), math.random(1000, 3000), math.random(1000, 3000), 3, 0, 0, 0)
    end

    startStamina = 0
    SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
end

function AlienEffect()
    StartScreenEffect("DrugsMichaelAliensFightIn", 3.0, 0)
    Citizen.Wait(math.random(5000, 8000))
    StartScreenEffect("DrugsMichaelAliensFight", 3.0, 0)
    Citizen.Wait(math.random(5000, 8000))    
    StartScreenEffect("DrugsMichaelAliensFightOut", 3.0, 0)
    StopScreenEffect("DrugsMichaelAliensFightIn")
    StopScreenEffect("DrugsMichaelAliensFight")
    StopScreenEffect("DrugsMichaelAliensFightOut")
end

local IsBlindFolded = false
RegisterNetEvent("gameplay:client:UseBlindfold", function()
    if IsBlindFolded then return; end
    local cPlayer = BJCore.Functions.GetClosestPlayerRadius(2.0)
    if cPlayer ~= nil then
        TriggerServerEvent("gameplay:server:DoBlindfold", GetPlayerServerId(cPlayer))
    else
        TriggerEvent("gameplay:client:GetBlindfolded")
    end
end)

RegisterNetEvent("gameplay:client:GetBlindfolded", function()
    if IsBlindFolded then
        IsBlindFolded = false
        DoScreenFadeIn(300)
    else
        BJCore.Functions.Notify("You have been blindfolded")
        IsBlindFolded = true
        DoScreenFadeOut(300)
    end
end)