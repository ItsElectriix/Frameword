local onDrugs = false
local drugLevel = -1
local isDead = false
local staMod = false
local doRun = false
local alcoholUsed = 0

local onCoke = false
local onMeth = false
local onWeed = false
local onOpium = false
local onPungJuice = false
local onAlcohol = false

local drugAdders = {
    coke = 25,
    meth = 20,
    weed = 15,
    opium = 20,
    pungsjuice = 25,
    alcohol = 60,
}

local drugTimers = {
    coke = 0,
    meth = 0,
    weed = 0,
    opium = 0,
    pungsjuice = 0,
    alcohol = 0,
}

function Awake(...)
    while not BJCore do Citizen.Wait(1000); end
    while not BJCore.Functions.IsPlayerLoaded() do Citizen.Wait(1000); end
end

AddEventHandler('tac_status:loaded', function(status)
    Citizen.CreateThread(function()
        while true do
            Wait(1000)
            TriggerEvent('bj-status:client:getStatus', function(status)     
                if status.drug > 0 then        
                    local start = true
                    if onDrugs then
                        start = false
                    end

                    local level = 0
                    if status.drug <= 999999 then
                        level = 0
                    else
                        if not isDead then
                            Overdose()
                        end
                    end

                    if level ~= onDrugs then
                    end

                    onDrugs = true
                    drugLevel = level
                end

                if status.drug == 0 then         
                    if onDrugs then
                        Reset()
                    end

                    onDrugs = false
                    drugLevel = -1
                end
            end)
        end
    end)
end)

AddEventHandler('bj-core:client:onPlayerDeath', function()
    isDead = true
end)

AddEventHandler('tac_ambulancejob:multicharacter', function()
    if isDead then
        Reset()
    end  
  
    isDead = false
end)

function DrunkEffect()
	local plyPed = PlayerPedId()
	alcoholUsed = alcoholUsed + 1
	TriggerEvent('tac_basicneeds:onDrink')
	Citizen.Wait(700)
	DoScreenFadeOut(300)
	Citizen.Wait(300)
	SetPedIsDrunk(plyPed, true)
	if alcoholUsed / 10 > 1 then
		ShakeGameplayCam("DRUNK_SHAKE", 1)
	else
		ShakeGameplayCam("DRUNK_SHAKE", alcoholUsed / 10)
	end
	SetPedConfigFlag(plyPed, 100, true)
	if alcoholUsed < 3 then
		Utils.LoadAnimDict("move_m@drunk@slightlydrunk")
		SetPedMovementClipset(plyPed, "move_m@drunk@slightlydrunk", true)
	elseif alcoholUsed < 5 then
		Utils.LoadAnimDict("move_m@drunk@moderatedrunk")
		SetPedMovementClipset(plyPed, "move_m@drunk@moderatedrunk", true)
		SetTimecycleModifier("Drunk")
	else
		Utils.LoadAnimDict("move_m@drunk@verydrunk")
		SetPedMovementClipset(plyPed, "move_m@drunk@verydrunk", true)
	end
	DoScreenFadeIn(1500)
end

function WeedEffect() 
    local plyPed = PlayerPedId()

    Utils.LoadAnimDict("move_m@hipster@a")

    TaskStartScenarioInPlace(plyPed, "WORLD_HUMAN_SMOKING_POT", 0, 1)
    Citizen.Wait(500)  
    DoScreenFadeOut(3000)
    Citizen.Wait(3000)
    SetTimecycleModifier("trevorspliff")   
    ClearPedTasksImmediately(plyPed)  
    DoScreenFadeIn(1500)
    SetPedMotionBlur(plyPed, true)
    SetPedMovementClipset(plyPed, "move_m@hipster@a", true)
    SetPedIsDrunk(plyPed, true)
    TriggerEvent('tac_status:remove','hunger',100000)
end

function OpiumEffect() 
    local plyPed = PlayerPedId()

    Utils.LoadAnimDict("move_m@drunk@moderatedrunk")  

    TaskStartScenarioInPlace(plyPed, "WORLD_HUMAN_SMOKING_POT", 0, 1)
    Citizen.Wait(3000)
    ClearPedTasksImmediately(plyPed)
    SetTimecycleModifier("spectator5")
    SetPedMotionBlur(plyPed, true)
    SetPedMovementClipset(plyPed, "move_m@drunk@moderatedrunk", true)
    SetPedIsDrunk(plyPed, true) 
end

function MethEffect()  
    local plyPed = PlayerPedId()

    Utils.LoadAnimDict("move_injured_generic")

    TaskStartScenarioInPlace(plyPed, "WORLD_HUMAN_SMOKING_POT", 0, 1)
    Citizen.Wait(3000)
    ClearPedTasksImmediately(plyPed)
    SetTimecycleModifier("Drug_deadman_blend")
    SetPedMotionBlur(plyPed, true)
    SetPedMovementClipset(plyPed, "move_injured_generic", true)
    SetPedIsDrunk(plyPed, true)
end

function CokeEffect()
    local plyPed = PlayerPedId()

    Utils.LoadAnimDict("move_m@brave")
    Utils.LoadAnimDict("missfbi3_party")

    TaskPlayAnim(PlayerPedId(), "missfbi3_party", "snort_coke_b_male3", 8.0, 1.0, 4700, 49, 0.0)
    Citizen.Wait(4000)
    DoScreenFadeOut(700)
    Citizen.Wait(700)
    SetTimecycleModifier("LostTimeFlash")
    DoScreenFadeIn(700)
    ClearPedSecondaryTask(PlayerPedId())
    SetPedMovementClipset(plyPed, "move_m@brave", true)
    AddArmourToPed(plyPed, 20)
end

function GrapeFantaEffect()
	local plyPed = PlayerPedId()
	
	TriggerEvent('tac_basicneeds:onDrink')
	Citizen.Wait(700)
	DoScreenFadeOut(300)
	Citizen.Wait(300)
	SetTimecycleModifier("drug_flying_base")
	SetTimecycleModifierStrength(0.5)
	SetExtraTimecycleModifier("drug_flying_02")
	DoScreenFadeIn(300)
	startRunning()
end

function startRunning()
	doRun = true
	SetRunSprintMultiplierForPlayer(PlayerId(), 1.2)
	Citizen.CreateThread(function()
		while doRun do
			Wait(200)
			RestorePlayerStamina(PlayerId(), 0.01)
		end
	end)
end

function Overdose()
    Citizen.CreateThread(function()
        local plyPed = PlayerPedId()
        SetEntityHealth(plyPed, 0)
        ClearTimecycleModifier()
        ClearExtraTimecycleModifier()
        ResetScenarioTypesEnabled()
        ResetPedMovementClipset(plyPed, 0)
        SetPedIsDrunk(plyPed, false)
        SetPedConfigFlag(plyPed, 100, false)
        SetPedMotionBlur(plyPed, false)
        ShakeGameplayCam("DRUNK_SHAKE", 0)
        doRun = false
        alcoholUsed = 0
        SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
        exports['mythic_notify']:SendAlert('error', "You have overdosed.", 2500)
    end)
end

function Reset()
    Citizen.CreateThread(function()
        local plyPed = PlayerPedId()  
        ClearTimecycleModifier()
        ClearExtraTimecycleModifier()
        ResetScenarioTypesEnabled()
        ResetPedMovementClipset(plyPed, 0)
        SetPedIsDrunk(plyPed, false)
        SetPedConfigFlag(plyPed, 100, false)
        SetPedMotionBlur(plyPed, false) 
        ShakeGameplayCam("DRUNK_SHAKE", 0)
        doRun = false
        alcoholUsed = 0
        SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
    end)
    staMod = false 
    TriggerEvent('tac_status:set', 'drug', 0)
    TriggerEvent('health:changeModifier', 1)
    TriggerEvent('MF_SkeletalSystem:RegDamage')
end

RegisterCommand('reset', function(...)
    Reset()
end)

-- Modifiers

local hmodifier = 1.0
local smodifier = 1.0
local max = 2.0
local min = 0.1

Citizen.CreateThread(function()
    local plyPed = PlayerPedId()
    local lastHealth = GetEntityHealth(plyPed)
    while true do
        local health = GetEntityHealth(plyPed)
        if health ~= lastHealth then
            if health < lastHealth then
                local diff = lastHealth - health
                local fixd = math.floor(diff * hmodifier)
                lastHealth = health + math.max(0,fixd)
                SetEntityHealth(playPed, lastHealth)
            else
                lastHealth = health
            end
        end
        Wait(0)
    end
end)

Citizen.CreateThread(function()
    local ply = PlayerId()
    local lastStamina = GetPlayerSprintStaminaRemaining(ply)
    while true do
        local stamina = GetPlayerSprintStaminaRemaining(ply)
        if staMod and stamina ~= lastStaminaw then
            if stamina < lastStamina then
                local diff = math.abs(lastStamina - stamina)
                local fixd = math.floor(diff * smodifier)
                local add = diff - fixd
                local per = add / 100
                RestorePlayerStamina(ply,math.max(0,per))
                lastStamina = stamina - math.max(0,add)
            else
                lastStamina = stamina
            end
        end
        Wait(0)
    end
end)

RegisterNetEvent('health:changeModifier')
AddEventHandler('health:changeModifier', function(mod) 
    if mod > max then mod = max; end
    if mod < min then mod = min; end
    hmodifier = mod
end)

RegisterNetEvent('stamina:changeModifier')
AddEventHandler('stamina:changeModifier', function(mod) 
    if mod > max then mod = max; end
    if mod < min then mod = min; end
    smodifier = mod
end)
---

RegisterNetEvent('DrugEffects:useDrug')
AddEventHandler('DrugEffects:useDrug', function(drug) useDrug(drug); end)

Citizen.CreateThread(function(...) Awake(...); end)

-- Timers

function useDrug(drug)
    addTime(drug)
  
    if drug == "coke" then
        CokeEffect()
    elseif drug == "meth" then
        MethEffect()
    elseif drug == "weed" then
        WeedEffect()
    elseif drug == "opium" then
        OpiumEffect()
    elseif drug == "pungsjuice" then
        GrapeFantaEffect()
    elseif drug == "alcohol" then
        DrunkEffect()
    end
end

function addTime(k)
    local v = drugTimers[k]
    drugTimers[k] = v + (drugAdders[k]*1000)
end

Citizen.CreateThread(function(...)
    while true do
        if drugTimers["coke"] > 0 then
            if not onCoke then
                onCoke = true
                staMod = true
                TriggerEvent('stamina:changeModifier', 0.5)
                SetRunSprintMultiplierForPlayer(ply, 1.1)
            end
        else
            if onCoke then
                onCoke = false
                if not onMeth and not onCoke and not onWeed and not onOpium then
                    staMod = false
                    SetRunSprintMultiplierForPlayer(ply, 1.0)
                end
            end
        end

        if drugTimers["meth"] > 0 then
            if not onMeth then
                onMeth = true
                TriggerEvent('MF_SkeletalSystem:HalfDamage')
                TriggerEvent('health:changeModifier', 0.5)
            end
        else
            if onMeth then
                onMeth = false        
                if not onMeth and not onCoke and not onWeed and not onOpium then
                    TriggerEvent('MF_SkeletalSystem:RegDamage')
                    TriggerEvent('health:changeModifier', 1.0)
                end
            end
        end

        if drugTimers["weed"] > 0 then
            if not onWeed then
                onWeed = true
                SetRunSprintMultiplierForPlayer(ply, 1.25)
                SetSwimMultiplierForPlayer(ply, 1.25)  
            end
        else
            if onWeed then
                onWeed = false
                if not onMeth and not onCoke and not onWeed and not onOpium then
                    SetRunSprintMultiplierForPlayer(ply, 1.0)
                    SetSwimMultiplierForPlayer(ply, 1.0) 
                end
            end
        end

        if drugTimers["opium"] > 0 then
            if not onOpium then
                onOpium = true
                TriggerEvent('MF_SkeletalSystem:HalfDamage')
                TriggerEvent('health:changeModifier', 0.5)
            end
        else
            if onOpium then
                onOpium = false
                if not onMeth and not onCoke and not onWeed and not onOpium then
                    TriggerEvent('MF_SkeletalSystem:RegDamage')
                    TriggerEvent('health:changeModifier', 1.0)
                end
            end
        end
        
        if drugTimers["alcohol"] > 0 then
            if not onAlcohol then
                onAlcohol = true
            end
        else
            if onAlcohol then
                onAlcohol = false
            end
        end
        Wait(0)
    end
end)

Citizen.CreateThread(function(...)
    local lastTime = GetGameTimer()
    while true do
        for k,v in pairs(drugTimers) do
            if v > 0.0 then
                v = v - (GetGameTimer() - lastTime)
            end
        end
        lastTime = GetGameTimer()
        Wait(0)
    end
end)