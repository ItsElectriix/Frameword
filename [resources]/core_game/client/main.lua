--- Dispatch/PVP/Vehicle Rewards ---
PedDensity = 0.6
VehicleDensity = 0.7
local allowpolice = 0
local firstCam = false
local crosshairShowing, crosshairEditing, forceCross = false, false, false
local pistolThreadRunning = false

local powerPlantPos = vector3(2729.47, 1514.56, 23.79)
local islandLocation = vector3(4838.461, -5108.197, -0.5019509)
local isOnIsland = false

local fullPickupList = {`PICKUP_AMMO_BULLET_MP`,`PICKUP_AMMO_FIREWORK`,`PICKUP_AMMO_FLAREGUN`,`PICKUP_AMMO_GRENADELAUNCHER`,`PICKUP_AMMO_GRENADELAUNCHER_MP`,`PICKUP_AMMO_HOMINGLAUNCHER`,`PICKUP_AMMO_MG`,`PICKUP_AMMO_MINIGUN`,`PICKUP_AMMO_MISSILE_MP`,`PICKUP_AMMO_PISTOL`,`PICKUP_AMMO_RIFLE`,`PICKUP_AMMO_RPG`,`PICKUP_AMMO_SHOTGUN`,`PICKUP_AMMO_SMG`,`PICKUP_AMMO_SNIPER`,`PICKUP_ARMOUR_STANDARD`,`PICKUP_CAMERA`,`PICKUP_CUSTOM_SCRIPT`,`PICKUP_GANG_ATTACK_MONEY`,`PICKUP_HEALTH_SNACK`,`PICKUP_HEALTH_STANDARD`,`PICKUP_MONEY_CASE`,`PICKUP_MONEY_DEP_BAG`,`PICKUP_MONEY_MED_BAG`,`PICKUP_MONEY_PAPER_BAG`,`PICKUP_MONEY_PURSE`,`PICKUP_MONEY_SECURITY_CASE`,`PICKUP_MONEY_VARIABLE`,`PICKUP_MONEY_WALLET`,`PICKUP_PARACHUTE`,`PICKUP_PORTABLE_CRATE_FIXED_INCAR`,`PICKUP_PORTABLE_CRATE_UNFIXED`,`PICKUP_PORTABLE_CRATE_UNFIXED_INCAR`,`PICKUP_PORTABLE_CRATE_UNFIXED_INCAR_SMALL`,`PICKUP_PORTABLE_CRATE_UNFIXED_LOW_GLOW`,`PICKUP_PORTABLE_DLC_VEHICLE_PACKAGE`,`PICKUP_PORTABLE_PACKAGE`,`PICKUP_SUBMARINE`,`PICKUP_VEHICLE_ARMOUR_STANDARD`,`PICKUP_VEHICLE_CUSTOM_SCRIPT`,`PICKUP_VEHICLE_CUSTOM_SCRIPT_LOW_GLOW`,`PICKUP_VEHICLE_HEALTH_STANDARD`,`PICKUP_VEHICLE_HEALTH_STANDARD_LOW_GLOW`,`PICKUP_VEHICLE_MONEY_VARIABLE`,`PICKUP_VEHICLE_WEAPON_APPISTOL`,`PICKUP_VEHICLE_WEAPON_ASSAULTSMG`,`PICKUP_VEHICLE_WEAPON_COMBATPISTOL`,`PICKUP_VEHICLE_WEAPON_GRENADE`,`PICKUP_VEHICLE_WEAPON_MICROSMG`,`PICKUP_VEHICLE_WEAPON_MOLOTOV`,`PICKUP_VEHICLE_WEAPON_PISTOL`,`PICKUP_VEHICLE_WEAPON_PISTOL50`,`PICKUP_VEHICLE_WEAPON_SAWNOFF`,`PICKUP_VEHICLE_WEAPON_SMG`,`PICKUP_VEHICLE_WEAPON_SMOKEGRENADE`,`PICKUP_VEHICLE_WEAPON_STICKYBOMB`,`PICKUP_WEAPON_ADVANCEDRIFLE`,`PICKUP_WEAPON_APPISTOL`,`PICKUP_WEAPON_ASSAULTRIFLE`,`PICKUP_WEAPON_ASSAULTSHOTGUN`,`PICKUP_WEAPON_ASSAULTSMG`,`PICKUP_WEAPON_AUTOSHOTGUN`,`PICKUP_WEAPON_BAT`,`PICKUP_WEAPON_BATTLEAXE`,`PICKUP_WEAPON_BOTTLE`,`PICKUP_WEAPON_BULLPUPRIFLE`,`PICKUP_WEAPON_BULLPUPSHOTGUN`,`PICKUP_WEAPON_CARBINERIFLE`,`PICKUP_WEAPON_COMBATMG`,`PICKUP_WEAPON_COMBATPDW`,`PICKUP_WEAPON_COMBATPISTOL`,`PICKUP_WEAPON_COMPACTLAUNCHER`,`PICKUP_WEAPON_COMPACTRIFLE`,`PICKUP_WEAPON_CROWBAR`,`PICKUP_WEAPON_DAGGER`,`PICKUP_WEAPON_DBSHOTGUN`,`PICKUP_WEAPON_FIREWORK`,`PICKUP_WEAPON_FLAREGUN`,`PICKUP_WEAPON_FLASHLIGHT`,`PICKUP_WEAPON_GRENADE`,`PICKUP_WEAPON_GRENADELAUNCHER`,`PICKUP_WEAPON_GUSENBERG`,`PICKUP_WEAPON_GOLFCLUB`,`PICKUP_WEAPON_HAMMER`,`PICKUP_WEAPON_HATCHET`,`PICKUP_WEAPON_HEAVYPISTOL`,`PICKUP_WEAPON_HEAVYSHOTGUN`,`PICKUP_WEAPON_HEAVYSNIPER`,`PICKUP_WEAPON_HOMINGLAUNCHER`,`PICKUP_WEAPON_KNIFE`,`PICKUP_WEAPON_KNUCKLE`,`PICKUP_WEAPON_MACHETE`,`PICKUP_WEAPON_MACHINEPISTOL`,`PICKUP_WEAPON_MARKSMANPISTOL`,`PICKUP_WEAPON_MARKSMANRIFLE`,`PICKUP_WEAPON_MG`,`PICKUP_WEAPON_MICROSMG`,`PICKUP_WEAPON_MINIGUN`,`PICKUP_WEAPON_MINISMG`,`PICKUP_WEAPON_MOLOTOV`,`PICKUP_WEAPON_MUSKET`,`PICKUP_WEAPON_NIGHTSTICK`,`PICKUP_WEAPON_PETROLCAN`,`PICKUP_WEAPON_PIPEBOMB`,`PICKUP_WEAPON_PISTOL`,`PICKUP_WEAPON_PISTOL50`,`PICKUP_WEAPON_POOLCUE`,`PICKUP_WEAPON_PROXMINE`,`PICKUP_WEAPON_PUMPSHOTGUN`,`PICKUP_WEAPON_RAILGUN`,`PICKUP_WEAPON_REVOLVER`,`PICKUP_WEAPON_RPG`,`PICKUP_WEAPON_SAWNOFFSHOTGUN`,`PICKUP_WEAPON_SMG`,`PICKUP_WEAPON_SMOKEGRENADE`,`PICKUP_WEAPON_SNIPERRIFLE`,`PICKUP_WEAPON_SNSPISTOL`,`PICKUP_WEAPON_SPECIALCARBINE`,`PICKUP_WEAPON_STICKYBOMB`,`PICKUP_WEAPON_STUNGUN`,`PICKUP_WEAPON_SWITCHBLADE`,`PICKUP_WEAPON_VINTAGEPISTOL`,`PICKUP_WEAPON_WRENCH`}

local function SetGamePlayVars()
    Citizen.CreateThread(function()
        SetAudioFlag('DisableFlightMusic', true)
        -- SetMapZoomDataLevel(0, 0.96, 0.9, 0.08, 0.0, 0.0) -- Level 0
        -- SetMapZoomDataLevel(1, 1.6, 0.9, 0.08, 0.0, 0.0) -- Level 1
        -- SetMapZoomDataLevel(2, 8.6, 0.9, 0.08, 0.0, 0.0) -- Level 2
        -- SetMapZoomDataLevel(3, 12.3, 0.9, 0.08, 0.0, 0.0) -- Level 3
        -- SetMapZoomDataLevel(4, 22.3, 0.9, 0.08, 0.0, 0.0) -- Level 4        
        SetMapZoomDataLevel(0, 0.96, 0.9, 0.08, 0.0, 0.0) -- Level 0
        SetMapZoomDataLevel(1, 1.6, 0.9, 0.08, 0.0, 0.0) -- Level 1
        SetMapZoomDataLevel(2, 8.6, 0.9, 0.08, 0.0, 0.0) -- Level 2
        SetMapZoomDataLevel(3, 12.3, 0.9, 0.08, 0.0, 0.0) -- Level 3
        SetMapZoomDataLevel(4, 24.3, 0.9, 0.08, 0.0, 0.0) -- Level 4
        SetMapZoomDataLevel(5, 55.0, 0.0, 0.1, 2.0, 1.0) -- ZOOM_LEVEL_GOLF_COURSE
        SetMapZoomDataLevel(6, 450.0, 0.0, 0.1, 1.0, 1.0) -- ZOOM_LEVEL_INTERIOR
        SetMapZoomDataLevel(7, 4.5, 0.0, 0.0, 0.0, 0.0) -- ZOOM_LEVEL_GALLERY
        SetMapZoomDataLevel(8, 11.0, 0.0, 0.0, 2.0, 3.0) -- ZOOM_LEVEL_GALLERY_MAXIMIZE
        SetAllLowPriorityVehicleGeneratorsActive(true)
        --SetEnableVehicleSlipstreaming(true)
        SetCreateRandomCops(false) -- Enable/Disable Random Cops
        SetCreateRandomCopsNotOnScenarios(false) --- Enable/Disable Spawn Cops Off Scenarios
        SetCreateRandomCopsOnScenarios(false)
        SetGarbageTrucks(true)
        SetRandomBoats(true)
        SetPedPopulationBudget(PedDensity)
        SetVehiclePopulationBudget(VehicleDensity)
        WaterOverrideSetStrength(1.5)
        SetDeepOceanScaler(0.0)
        for i = 1, 25 do
            EnableDispatchService(i, false)
        end

        -- SetForceVehicleTrails(true)
        -- SetForcePedFootstepsTracks(true)
        -- ForceSnowPass(true)
        -- RequestScriptAudioBank("ICE_FOOTSTEPS", false)
        -- RequestScriptAudioBank("SNOW_FOOTSTEPS", false)
        -- RequestNamedPtfxAsset("core_snow")
        -- while not HasNamedPtfxAssetLoaded("core_snow") do
        --     Wait(0)
        -- end
        -- UseParticleFxAssetNextCall("core_snow")        

        -- enable pvp
        for i = 0, 255 do
            if NetworkIsPlayerConnected(i) then
                if NetworkIsPlayerConnected(i) and GetPlayerPed(i) ~= nil then
                    SetCanAttackFriendly(GetPlayerPed(i), true, true)
                end
            end
        end

        NetworkSetFriendlyFireOption(true)

        SetMaxWantedLevel(0)
        for k,v in pairs(fullPickupList) do
            ToggleUsePickupsForPlayer(PlayerId(), v, false)
        end
	end)
	
    Citizen.CreateThread(function()
        local crosshairShowing = false
        while true do
            Citizen.Wait(1)
            local plyPed = PlayerPedId()
			SetPlayerHealthRechargeMultiplier(PlayerId(), 0.0)
			--SetRandomVehicleDensityMultiplierThisFrame(VehicleDensity)
            -- SetVehicleDensityMultiplierThisFrame(VehicleDensity)
            -- SetPedDensityMultiplierThisFrame(PedDensity)
            SetPedSuffersCriticalHits(plyPed, false)
            CanShuffleSeat(plyPed, false)
            -- Disable vehicle rewards
            DisablePlayerVehicleRewards(PlayerId())
            local veh = GetVehiclePedIsIn(plyPed,false)
            if veh ~= nil then
                if GetPedInVehicleSeat(GetVehiclePedIsIn(plyPed, false), 0) == plyPed then
                    SetPedConfigFlag(plyPed, 184, true)
                    if GetIsTaskActive(plyPed, 165) then
                        SetPedIntoVehicle(plyPed, GetVehiclePedIsIn(plyPed, false), 0)
                    end
                end
            end       
            if IsPedSittingInAnyVehicle(plyPed) then
                local driver = GetPedInVehicleSeat(veh, -1)
                if IsPlayerFreeAiming(PlayerId()) or (IsControlPressed(1, 91) and GetLastInputMethod(0)) or ((IsControlPressed(1, 69) or IsControlPressed(1, 68)) and not GetLastInputMethod(2) and driver ~= plyPed) then
                    if GetFollowVehicleCamViewMode() == 4 and not firstCam then
                        firstCam = true
                    else
                        if not firstCam then 
                            SetFollowVehicleCamViewMode(4)
                            firstCam = true
                        end
                    end
                else
                    if not (IsControlPressed(1, 92) and not GetLastInputMethod(2) and driver ~= plyPed) then
                        if firstCam == true then
                            SetFollowVehicleCamViewMode(1)
                            firstCam = false
                        end
                    end        
                end           
                --local veh = GetVehiclePedIsIn(plyPed, false)
                -- if GetPedInVehicleSeat(veh, -1) == plyPed then
                --     SetVehicleDensityMultiplierThisFrame(VehicleDensity)
                --     SetParkedVehicleDensityMultiplierThisFrame(0.0)
                -- else
                --     SetVehicleDensityMultiplierThisFrame(0.0)
                --     SetParkedVehicleDensityMultiplierThisFrame(VehicleDensity)
                --end
                -- DisableControlAction(0, 14, true)
                -- DisableControlAction(0, 15, true)
                -- DisableControlAction(0, 16, true)
                -- DisableControlAction(0, 17, true)  
                -- DisableControlAction(0, 99, true)
                -- DisableControlAction(0, 96, true)   
                -- DisableControlAction(0, 97, true)  
                -- DisableControlAction(0, 115, true) 
                -- DisableControlAction(0, 241, true)  
                -- DisableControlAction(0, 242, true)
                -- DisableControlAction(0, 261, true)  
                -- DisableControlAction(0, 263, true)
                -- DisableControlAction(0, 334, true)
                -- DisableControlAction(0, 335, true)  
                -- DisableControlAction(0, 336, true) 
                -- DisableControlAction(0, 50, true)
                -- DisableControlAction(0, 180, true) 
                -- DisableControlAction(0, 181, true)
                -- DisableControlAction(0, 198, true) 
                -- DisableControlAction(0, 81, true)
                -- DisableControlAction(0, 82, true) 
            else       
                SetFollowVehicleCamViewMode(1)
                -- SetParkedVehicleDensityMultiplierThisFrame(0.0)
                -- SetVehicleDensityMultiplierThisFrame(VehicleDensity)
            end
            if forceCross then
                crosshairShowing = true 
                SendNUIMessage({ type = 'showCrosshair' })
            else
                crosshairShowing = false
                SendNUIMessage({ type = 'hideCrosshair' })
            end
            if IsPlayerFreeAiming(PlayerId()) then
                if not crosshairShowing then
                    crosshairShowing = true
                    SendNUIMessage({ type = 'showCrosshair' })
                end
                --local ratio = GetAspectRatio()
                --DrawRect(0.5, 0.5, 0.001, 0.001 * ratio, 255, 255, 255, 150)
            elseif crosshairShowing and not crosshairEditing and not forceCross then
                crosshairShowing = false
                SendNUIMessage({ type = 'hideCrosshair' })
            end 

            HideHudComponentThisFrame(19)
            HideHudComponentThisFrame(20)
            HideHudComponentThisFrame(21)
            HideHudComponentThisFrame(22)
            HideHudComponentThisFrame(3) -- SP Cash display 
            HideHudComponentThisFrame(4)  -- MP Cash display
            HideHudComponentThisFrame(6) -- Vehicle Name
            HideHudComponentThisFrame(7) -- Area Name
            HideHudComponentThisFrame(8) -- Vehicle Class
            HideHudComponentThisFrame(9) -- Street Name
            HideHudComponentThisFrame(13) -- Cash changes
            HideHudComponentThisFrame(14)
        end
    end)

    -- Citizen.CreateThread(function()
    --     while true do
    --         Wait(1000)

    --         local id = PlayerId()
    --         if allowpolice == 0 then
    --             SetMaxWantedLevel(0)
    --             -- SetPlayerWantedLevel(id, 0, false)
    --             -- SetPlayerWantedLevelNow(id, false)
    --         else
    --             if allowpolice == 1 then
    --                 for i = 1, 25 do
    --                     EnableDispatchService(i, false)
    --                 end
    --             else
    --                 for i = 1, 25 do
    --                     EnableDispatchService(i, true)
    --                 end
    --             end

    --             SetPlayerWantedLevel(id, 2, false)
    --             SetPlayerWantedLevelNoDrop(id, 2, false)
    --             SetPlayerWantedLevelNow(id)
    --             print(GetPlayerWantedLevel(id))
    --         end
    --         InvalidateIdleCam() -- disable idle cams
    --         N_0x9e4cfff989258472() -- disable idle cams while in vehicle
    --     end
    -- end)

    function ToggleIslandIpls(on)
        local func = RemoveIpl
        if on then func = RequestIpl; end

        func("h4_islandairstrip")
        func("h4_islandairstrip_props")
        func("h4_islandx_mansion")
        func("h4_islandx_mansion_props")
        func("h4_islandx_props")
        func("h4_islandxdock")
        func("h4_islandxdock_props")
        func("h4_islandxdock_props_2")
        func("h4_islandxtower")
        func("h4_islandx_maindock")
        func("h4_islandx_maindock_props")
        func("h4_islandx_maindock_props_2")
        func("h4_IslandX_Mansion_Vault")
        func("h4_islandairstrip_propsb")
        func("h4_beach")
        func("h4_beach_props")
        func("h4_beach_bar_props")
        func("h4_islandx_barrack_props")
        func("h4_islandx_checkpoint")
        func("h4_islandx_checkpoint_props")
        func("h4_islandx_Mansion_Office")
        func("h4_islandx_Mansion_LockUp_01")
        func("h4_islandx_Mansion_LockUp_02")
        func("h4_islandx_Mansion_LockUp_03")
        func("h4_islandairstrip_hangar_props")
        func("h4_IslandX_Mansion_B")
        func("h4_islandairstrip_doorsclosed")
        func("h4_Underwater_Gate_Closed")
        func("h4_mansion_gate_closed")
        func("h4_aa_guns")
        func("h4_IslandX_Mansion_GuardFence")
        func("h4_IslandX_Mansion_Entrance_Fence")
        func("h4_IslandX_Mansion_B_Side_Fence")
        func("h4_IslandX_Mansion_Lights")
        func("h4_islandxcanal_props")
        func("h4_beach_props_party")
        func("h4_islandX_Terrain_props_06_a")
        func("h4_islandX_Terrain_props_06_b")
        func("h4_islandX_Terrain_props_06_c")
        func("h4_islandX_Terrain_props_05_a")
        func("h4_islandX_Terrain_props_05_b")
        func("h4_islandX_Terrain_props_05_c")
        func("h4_islandX_Terrain_props_05_d")
        func("h4_islandX_Terrain_props_05_e")
        func("h4_islandX_Terrain_props_05_f")
        func("H4_islandx_terrain_01")
        func("H4_islandx_terrain_02")
        func("H4_islandx_terrain_03")
        func("H4_islandx_terrain_04")
        func("H4_islandx_terrain_05")
        func("H4_islandx_terrain_06")
        func("h4_ne_ipl_00")
        func("h4_ne_ipl_01")
        func("h4_ne_ipl_02")
        func("h4_ne_ipl_03")
        func("h4_ne_ipl_04")
        func("h4_ne_ipl_05")
        func("h4_ne_ipl_06")
        func("h4_ne_ipl_07")
        func("h4_ne_ipl_08")
        func("h4_ne_ipl_09")
        func("h4_nw_ipl_00")
        func("h4_nw_ipl_01")
        func("h4_nw_ipl_02")
        func("h4_nw_ipl_03")
        func("h4_nw_ipl_04")
        func("h4_nw_ipl_05")
        func("h4_nw_ipl_06")
        func("h4_nw_ipl_07")
        func("h4_nw_ipl_08")
        func("h4_nw_ipl_09")
        func("h4_se_ipl_00")
        func("h4_se_ipl_01")
        func("h4_se_ipl_02")
        func("h4_se_ipl_03")
        func("h4_se_ipl_04")
        func("h4_se_ipl_05")
        func("h4_se_ipl_06")
        func("h4_se_ipl_07")
        func("h4_se_ipl_08")
        func("h4_se_ipl_09")
        func("h4_sw_ipl_00")
        func("h4_sw_ipl_01")
        func("h4_sw_ipl_02")
        func("h4_sw_ipl_03")
        func("h4_sw_ipl_04")
        func("h4_sw_ipl_05")
        func("h4_sw_ipl_06")
        func("h4_sw_ipl_07")
        func("h4_sw_ipl_08")
        func("h4_sw_ipl_09")
        func("h4_islandx_mansion")
        func("h4_islandxtower_veg")
        func("h4_islandx_sea_mines")
        func("h4_islandx")
        func("h4_islandx_barrack_hatch")
        func("h4_islandxdock_water_hatch")
        func("h4_beach_party")
        func("h4_mph4_terrain_01_grass_0")
        func("h4_mph4_terrain_01_grass_1")
        func("h4_mph4_terrain_02_grass_0")
        func("h4_mph4_terrain_02_grass_1")
        func("h4_mph4_terrain_02_grass_2")
        func("h4_mph4_terrain_02_grass_3")
        func("h4_mph4_terrain_04_grass_0")
        func("h4_mph4_terrain_04_grass_1")
        func("h4_mph4_terrain_04_grass_2")
        func("h4_mph4_terrain_04_grass_3")
        func("h4_mph4_terrain_05_grass_0")
        func("h4_mph4_terrain_06_grass_0")
        func("h4_mph4_airstrip_interior_0_airstrip_hanger")
    end

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(1000)
			local pos = GetEntityCoords(PlayerPedId(), false)
            local dist = #(pos - powerPlantPos)
            local islandDist = #(islandLocation - pos)
            if dist > 150.0 then
               ClearAreaOfCops(pos, 400.0)
            else
                Wait(5000)
            end

            if not isOnIsland and islandDist < 3000.0 then
                isOnIsland = true
                print('Swapping to island')
                --Citizen.InvokeNative(0x9A9D1BA639675CF1, "HeistIsland", true)
                Citizen.InvokeNative(0x5E1460624D194A38, true)

                SetScenarioGroupEnabled('Heist_Island_Peds', true)
                SetAudioFlag("PlayerOnDLCHeist4Island", true)
                SetAmbientZoneListStatePersistent("AZL_DLC_Hei4_Island_Zones", true, true)
                SetAmbientZoneListStatePersistent("AZL_DLC_Hei4_Island_Disabled_Zones", false, true)
                SetDeepOceanScaler(0.1)

                ToggleIslandIpls(true)
            elseif isOnIsland and islandDist > 3000.0 then
                isOnIsland = false
                print('Swapping to mainland')
                --Citizen.InvokeNative(0x9A9D1BA639675CF1, "HeistIsland", false)
                Citizen.InvokeNative(0x5E1460624D194A38, false)

                SetScenarioGroupEnabled("Heist_Island_Peds", false)
                SetAudioFlag("PlayerOnDLCHeist4Island", false)
                SetAmbientZoneListStatePersistent("AZL_DLC_Hei4_Island_Zones", false, false)
                SetAmbientZoneListStatePersistent("AZL_DLC_Hei4_Island_Disabled_Zones", false, false)
                ResetDeepOceanScaler()

                ToggleIslandIpls(false)
            end

            N_0xf4f2c0d4ee209e20() -- afk timer reset
            --RemoveWeaponDrops()
        end
    end)

    Citizen.CreateThread(function()
        while true do
            -- Remove weapon drops more often
            --RemoveImportantDrops()

            if Config.DisablePistolWhipping and not pistolThreadRunning and IsPedArmed(PlayerPedId(), 6) then
                StartPistolWhippingThread()
            end
            Wait(25)
        end
    end)
end

function StartPistolWhippingThread()
    Citizen.CreateThread(function()
        pistolThreadRunning = true
        local ped = PlayerPedId()
        while IsPedArmed(ped, 6) do
            DisableControlAction(1, 140, true)
            DisableControlAction(1, 141, true)
            DisableControlAction(1, 142, true)
            Wait(1)
        end
        pistolThreadRunning = false
    end)
end

AddEventHandler("forceCrosshair", function(b)
    forceCross = b
end)

function RemoveDrops(pickupList)
    --local PlayerPed = PlayerPedId()
    --local pedPos = GetEntityCoords(PlayerPed, false)

    for a = 1, #pickupList do
        --if IsPickupWithinRadius(pickupList[a], pedPos.x, pedPos.y, pedPos.z, 30.0) then
            RemoveAllPickupsOfType(pickupList[a])
        --end
    end
end

local importantList = {`PICKUP_WEAPON_ADVANCEDRIFLE`,`PICKUP_WEAPON_APPISTOL`,`PICKUP_WEAPON_ASSAULTRIFLE`,`PICKUP_WEAPON_ASSAULTSHOTGUN`,`PICKUP_WEAPON_ASSAULTSMG`,`PICKUP_WEAPON_CARBINERIFLE`,`PICKUP_WEAPON_COMBATMG`,`PICKUP_WEAPON_COMBATPDW`,`PICKUP_WEAPON_COMBATPISTOL`,`PICKUP_WEAPON_COMPACTLAUNCHER`,`PICKUP_WEAPON_COMPACTRIFLE`,`PICKUP_WEAPON_DBSHOTGUN`,`PICKUP_WEAPON_GUSENBERG`,`PICKUP_WEAPON_HEAVYPISTOL`,`PICKUP_WEAPON_HEAVYSHOTGUN`,`PICKUP_WEAPON_MICROSMG`,`PICKUP_WEAPON_MINIGUN`,`PICKUP_WEAPON_MINISMG`,`PICKUP_WEAPON_PISTOL`,`PICKUP_WEAPON_PISTOL50`,`PICKUP_WEAPON_PUMPSHOTGUN`,`PICKUP_WEAPON_REVOLVER`,`PICKUP_WEAPON_SAWNOFFSHOTGUN`,`PICKUP_WEAPON_SMG`,`PICKUP_WEAPON_SNIPERRIFLE`,`PICKUP_WEAPON_SNSPISTOL`,`PICKUP_WEAPON_SPECIALCARBINE`,`PICKUP_WEAPON_STUNGUN`,`PICKUP_WEAPON_VINTAGEPISTOL`}
local fullPickupList = {`PICKUP_AMMO_BULLET_MP`,`PICKUP_AMMO_FIREWORK`,`PICKUP_AMMO_FLAREGUN`,`PICKUP_AMMO_GRENADELAUNCHER`,`PICKUP_AMMO_GRENADELAUNCHER_MP`,`PICKUP_AMMO_HOMINGLAUNCHER`,`PICKUP_AMMO_MG`,`PICKUP_AMMO_MINIGUN`,`PICKUP_AMMO_MISSILE_MP`,`PICKUP_AMMO_PISTOL`,`PICKUP_AMMO_RIFLE`,`PICKUP_AMMO_RPG`,`PICKUP_AMMO_SHOTGUN`,`PICKUP_AMMO_SMG`,`PICKUP_AMMO_SNIPER`,`PICKUP_ARMOUR_STANDARD`,`PICKUP_CAMERA`,`PICKUP_CUSTOM_SCRIPT`,`PICKUP_GANG_ATTACK_MONEY`,`PICKUP_HEALTH_SNACK`,`PICKUP_HEALTH_STANDARD`,`PICKUP_MONEY_CASE`,`PICKUP_MONEY_DEP_BAG`,`PICKUP_MONEY_MED_BAG`,`PICKUP_MONEY_PAPER_BAG`,`PICKUP_MONEY_PURSE`,`PICKUP_MONEY_SECURITY_CASE`,`PICKUP_MONEY_VARIABLE`,`PICKUP_MONEY_WALLET`,`PICKUP_PARACHUTE`,`PICKUP_PORTABLE_CRATE_FIXED_INCAR`,`PICKUP_PORTABLE_CRATE_UNFIXED`,`PICKUP_PORTABLE_CRATE_UNFIXED_INCAR`,`PICKUP_PORTABLE_CRATE_UNFIXED_INCAR_SMALL`,`PICKUP_PORTABLE_CRATE_UNFIXED_LOW_GLOW`,`PICKUP_PORTABLE_DLC_VEHICLE_PACKAGE`,`PICKUP_PORTABLE_PACKAGE`,`PICKUP_SUBMARINE`,`PICKUP_VEHICLE_ARMOUR_STANDARD`,`PICKUP_VEHICLE_CUSTOM_SCRIPT`,`PICKUP_VEHICLE_CUSTOM_SCRIPT_LOW_GLOW`,`PICKUP_VEHICLE_HEALTH_STANDARD`,`PICKUP_VEHICLE_HEALTH_STANDARD_LOW_GLOW`,`PICKUP_VEHICLE_MONEY_VARIABLE`,`PICKUP_VEHICLE_WEAPON_APPISTOL`,`PICKUP_VEHICLE_WEAPON_ASSAULTSMG`,`PICKUP_VEHICLE_WEAPON_COMBATPISTOL`,`PICKUP_VEHICLE_WEAPON_GRENADE`,`PICKUP_VEHICLE_WEAPON_MICROSMG`,`PICKUP_VEHICLE_WEAPON_MOLOTOV`,`PICKUP_VEHICLE_WEAPON_PISTOL`,`PICKUP_VEHICLE_WEAPON_PISTOL50`,`PICKUP_VEHICLE_WEAPON_SAWNOFF`,`PICKUP_VEHICLE_WEAPON_SMG`,`PICKUP_VEHICLE_WEAPON_SMOKEGRENADE`,`PICKUP_VEHICLE_WEAPON_STICKYBOMB`,`PICKUP_WEAPON_ADVANCEDRIFLE`,`PICKUP_WEAPON_APPISTOL`,`PICKUP_WEAPON_ASSAULTRIFLE`,`PICKUP_WEAPON_ASSAULTSHOTGUN`,`PICKUP_WEAPON_ASSAULTSMG`,`PICKUP_WEAPON_AUTOSHOTGUN`,`PICKUP_WEAPON_BAT`,`PICKUP_WEAPON_BATTLEAXE`,`PICKUP_WEAPON_BOTTLE`,`PICKUP_WEAPON_BULLPUPRIFLE`,`PICKUP_WEAPON_BULLPUPSHOTGUN`,`PICKUP_WEAPON_CARBINERIFLE`,`PICKUP_WEAPON_COMBATMG`,`PICKUP_WEAPON_COMBATPDW`,`PICKUP_WEAPON_COMBATPISTOL`,`PICKUP_WEAPON_COMPACTLAUNCHER`,`PICKUP_WEAPON_COMPACTRIFLE`,`PICKUP_WEAPON_CROWBAR`,`PICKUP_WEAPON_DAGGER`,`PICKUP_WEAPON_DBSHOTGUN`,`PICKUP_WEAPON_FIREWORK`,`PICKUP_WEAPON_FLAREGUN`,`PICKUP_WEAPON_FLASHLIGHT`,`PICKUP_WEAPON_GRENADE`,`PICKUP_WEAPON_GRENADELAUNCHER`,`PICKUP_WEAPON_GUSENBERG`,`PICKUP_WEAPON_GOLFCLUB`,`PICKUP_WEAPON_HAMMER`,`PICKUP_WEAPON_HATCHET`,`PICKUP_WEAPON_HEAVYPISTOL`,`PICKUP_WEAPON_HEAVYSHOTGUN`,`PICKUP_WEAPON_HEAVYSNIPER`,`PICKUP_WEAPON_HOMINGLAUNCHER`,`PICKUP_WEAPON_KNIFE`,`PICKUP_WEAPON_KNUCKLE`,`PICKUP_WEAPON_MACHETE`,`PICKUP_WEAPON_MACHINEPISTOL`,`PICKUP_WEAPON_MARKSMANPISTOL`,`PICKUP_WEAPON_MARKSMANRIFLE`,`PICKUP_WEAPON_MG`,`PICKUP_WEAPON_MICROSMG`,`PICKUP_WEAPON_MINIGUN`,`PICKUP_WEAPON_MINISMG`,`PICKUP_WEAPON_MOLOTOV`,`PICKUP_WEAPON_MUSKET`,`PICKUP_WEAPON_NIGHTSTICK`,`PICKUP_WEAPON_PETROLCAN`,`PICKUP_WEAPON_PIPEBOMB`,`PICKUP_WEAPON_PISTOL`,`PICKUP_WEAPON_PISTOL50`,`PICKUP_WEAPON_POOLCUE`,`PICKUP_WEAPON_PROXMINE`,`PICKUP_WEAPON_PUMPSHOTGUN`,`PICKUP_WEAPON_RAILGUN`,`PICKUP_WEAPON_REVOLVER`,`PICKUP_WEAPON_RPG`,`PICKUP_WEAPON_SAWNOFFSHOTGUN`,`PICKUP_WEAPON_SMG`,`PICKUP_WEAPON_SMOKEGRENADE`,`PICKUP_WEAPON_SNIPERRIFLE`,`PICKUP_WEAPON_SNSPISTOL`,`PICKUP_WEAPON_SPECIALCARBINE`,`PICKUP_WEAPON_STICKYBOMB`,`PICKUP_WEAPON_STUNGUN`,`PICKUP_WEAPON_SWITCHBLADE`,`PICKUP_WEAPON_VINTAGEPISTOL`,`PICKUP_WEAPON_WRENCH`}

print(tostring(#importantList)..' Important Weapons')

function RemoveImportantDrops()
    RemoveDrops(importantList)
end

function RemoveWeaponDrops()
    RemoveDrops(fullPickupList)
end

RegisterCommand('crosshair', function()
    SendNUIMessage({ type = 'focusUi' })
    SetNuiFocus(true, true)
    crosshairEditing = true
end)

RegisterNUICallback('UnfocusUi', function()
    SetNuiFocus(false, false)
    crosshairEditing = false
end)

RegisterNetEvent('bj_gameplay:enableDispatch')
AddEventHandler('bj_gameplay:enableDispatch', function()
    local dist = #(GetEntityCoords(PlayerPedId()) - vector3(2729.47, 1514.56, 23.79))
    -- if job == police then return; end
    if dist < 100.0 then
        if allowpolice > 0 then
            allowpolice = 240
            return
        else
            allowpolice = 240
        end

        while allowpolice > 0 do
            Wait(1000)
            allowpolice = allowpolice - 1
        end

        allowpolice = 0
    end
end)
SetGamePlayVars()

local relationshipTypes = {
  "PLAYER",
  "COP",
  "MISSION2",
  "MISSION3",
  "MISSION4",
  "MISSION5",
  "MISSION6",
  "MISSION7",
  "MISSION8",
}

Citizen.CreateThread(function()
    while true do
        Wait(600)
        for _, group in ipairs(relationshipTypes) do
            if group == "COP" then
                SetRelationshipBetweenGroups(3, `PLAYER`,GetHashKey(group))
                SetRelationshipBetweenGroups(3, GetHashKey(group), `PLAYER`)
                SetRelationshipBetweenGroups(0, `MISSION2`,GetHashKey(group))
                SetRelationshipBetweenGroups(0, GetHashKey(group), `MISSION2`)
            else
                SetRelationshipBetweenGroups(0, `PLAYER`,GetHashKey(group))
                SetRelationshipBetweenGroups(0, GetHashKey(group), `PLAYER`)
                SetRelationshipBetweenGroups(0, `MISSION2`,GetHashKey(group))
                SetRelationshipBetweenGroups(0, GetHashKey(group), `MISSION2`)
            end  
            SetRelationshipBetweenGroups(5, GetHashKey(group), `MISSION8`)
        end


        SetRelationshipBetweenGroups(1, `PLAYER`, `AMBIENT_GANG_WEICHENG`)
        SetRelationshipBetweenGroups(1, `AMBIENT_GANG_WEICHENG`, `PLAYER`)
        SetRelationshipBetweenGroups(1, `PLAYER`, `AMBIENT_GANG_FAMILY`)
        SetRelationshipBetweenGroups(1, `AMBIENT_GANG_FAMILY`, `PLAYER`)
        SetRelationshipBetweenGroups(1, `PLAYER`, `AMBIENT_GANG_BALLAS`)
        SetRelationshipBetweenGroups(1, `AMBIENT_GANG_BALLAS`, `PLAYER`)

        SetRelationshipBetweenGroups(1, `PLAYER`, `AMBIENT_GANG_SALVA`)
        SetRelationshipBetweenGroups(1, `AMBIENT_GANG_SALVA`, `PLAYER`)
        SetRelationshipBetweenGroups(1, `PLAYER`, `AMBIENT_GANG_MEXICAN`)
        SetRelationshipBetweenGroups(1, `AMBIENT_GANG_MEXICAN`, `PLAYER`)

        SetRelationshipBetweenGroups(1, `AMBIENT_GANG_LOST`, `AMBIENT_GANG_WEICHENG`)
        SetRelationshipBetweenGroups(1, `AMBIENT_GANG_WEICHENG`, `AMBIENT_GANG_LOST`)
        SetRelationshipBetweenGroups(1, `AMBIENT_GANG_LOST`, `AMBIENT_GANG_FAMILY`)
        SetRelationshipBetweenGroups(1, `AMBIENT_GANG_FAMILY`, `AMBIENT_GANG_LOST`)
        SetRelationshipBetweenGroups(1, `AMBIENT_GANG_LOST`, `AMBIENT_GANG_BALLAS`)
        SetRelationshipBetweenGroups(1, `AMBIENT_GANG_BALLAS`, `AMBIENT_GANG_LOST`)

        SetRelationshipBetweenGroups(1, `AMBIENT_GANG_LOST`, `AMBIENT_GANG_SALVA`)
        SetRelationshipBetweenGroups(1, `AMBIENT_GANG_SALVA`, `AMBIENT_GANG_LOST`)
        SetRelationshipBetweenGroups(1, `AMBIENT_GANG_LOST`, `AMBIENT_GANG_MEXICAN`)
        SetRelationshipBetweenGroups(1, `AMBIENT_GANG_MEXICAN`, `AMBIENT_GANG_LOST`)

        --WEST SIDE
        SetRelationshipBetweenGroups(1, `MISSION4`, `AMBIENT_GANG_WEICHENG`)
        SetRelationshipBetweenGroups(1, `AMBIENT_GANG_WEICHENG`, `MISSION4`)

        -- MEDIC / POLICE WEST SIDE
        SetRelationshipBetweenGroups(1, `AMBIENT_GANG_WEICHENG`, `MISSION2`)
        SetRelationshipBetweenGroups(1, `MISSION2`, `AMBIENT_GANG_WEICHENG`)

        --CENTRAL
        SetRelationshipBetweenGroups(1, `MISSION5`, `AMBIENT_GANG_FAMILY`)
        SetRelationshipBetweenGroups(1, `AMBIENT_GANG_FAMILY`, `MISSION5`)
        SetRelationshipBetweenGroups(1, `MISSION5`, `AMBIENT_GANG_BALLAS`)
        SetRelationshipBetweenGroups(1, `AMBIENT_GANG_BALLAS`, `MISSION5`)

        -- MEDIC / POLICE CENTRAL
        SetRelationshipBetweenGroups(1, `AMBIENT_GANG_BALLAS`, `MISSION2`)
        SetRelationshipBetweenGroups(1, `MISSION2`, `AMBIENT_GANG_BALLAS`)
        SetRelationshipBetweenGroups(1, `AMBIENT_GANG_FAMILY`, `MISSION2`)
        SetRelationshipBetweenGroups(1, `MISSION2`, `AMBIENT_GANG_FAMILY`)

        --EAST SIDE
        SetRelationshipBetweenGroups(1, `MISSION6`, `AMBIENT_GANG_SALVA`)
        SetRelationshipBetweenGroups(1, `AMBIENT_GANG_SALVA`, `MISSION6`)
        SetRelationshipBetweenGroups(1, `MISSION6`, `AMBIENT_GANG_MEXICAN`)
        SetRelationshipBetweenGroups(1, `AMBIENT_GANG_MEXICAN`, `MISSION6`)

        -- MEDIC / POLICE EAST SIDE
        SetRelationshipBetweenGroups(1, `AMBIENT_GANG_SALVA`, `MISSION2`)
        SetRelationshipBetweenGroups(1, `MISSION2`, `AMBIENT_GANG_SALVA`)
        SetRelationshipBetweenGroups(1, `MISSION2`, `AMBIENT_GANG_MEXICAN`)
        SetRelationshipBetweenGroups(1, `AMBIENT_GANG_MEXICAN`, `MISSION2`)


        SetRelationshipBetweenGroups(1, -86095805, `MISSION2`)
        SetRelationshipBetweenGroups(1, `MISSION2`, -86095805)

        SetRelationshipBetweenGroups(1,1191392768, `MISSION2`)
        SetRelationshipBetweenGroups(1, `MISSION2`,1191392768)

        SetRelationshipBetweenGroups(1, `MISSION2`, 45677184)
        SetRelationshipBetweenGroups(1, 45677184, `MISSION2`)

        SetRelationshipBetweenGroups(3, `PLAYER`, `MISSION7`)
        SetRelationshipBetweenGroups(3, `MISSION7`, `PLAYER`)

        SetRelationshipBetweenGroups(0, `MISSION7`, `COP`)
        SetRelationshipBetweenGroups(0, `COP`, `MISSION7`)

        SetRelationshipBetweenGroups(0, `MISSION2`, `MISSION7`)
        SetRelationshipBetweenGroups(0, `MISSION7`, `MISSION2`)

        SetRelationshipBetweenGroups(0, `MISSION7`, `MISSION7`)

        SetRelationshipBetweenGroups(3, `COP`,`PLAYER`)
        SetRelationshipBetweenGroups(3, `PLAYER`, `COP`)

        SetRelationshipBetweenGroups(0, `PLAYER`, `MISSION3`)
        SetRelationshipBetweenGroups(0, `MISSION3`,`PLAYER`)

        -- LOST MC
        SetRelationshipBetweenGroups(1, `PLAYER`, `AMBIENT_GANG_LOST`)
        SetRelationshipBetweenGroups(1, `AMBIENT_GANG_LOST`, `PLAYER`)
        SetRelationshipBetweenGroups(1,  `COP`, `AMBIENT_GANG_LOST`)
        SetRelationshipBetweenGroups(1,  `AMBIENT_GANG_LOST`, `COP`)
    end
end)