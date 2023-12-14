thermite.init = function()
	Citizen.Wait(3000)
	thermite.uiMsg("Init")
	thermite.uiMsg("ApplyConfig",uiCfg)
end

thermite.uiMsg = function(f,a)
	SendNUIMessage({
		["function"] = f,
		["arguments"] = a,
	})
end

AddEventHandler("thermite:init", function()
	thermite.init()
end)

thermite.uiFocus = function(f)
	SetNuiFocus(f,f)
end

thermite.startMinigame = function(callback,diff,speed,inc)
	if cfg.useItem then
		BJCore.Functions.TriggerServerCallback('thermite:getThermiteCount', function(data)
			if data <= 0 then
				callback(false,messages.notEnoughItem)
				return
			end
			local settings = {
				scoreInc   = (inc   or uiCfg.scoreInc),
				difficulty = (diff  or uiCfg.difficulty),
				speedScale = (speed or uiCfg.speedScale),
			}
			
			thermite.result = false

			thermite.uiMsg("ApplyConfig",settings)
			thermite.uiMsg("SetAlpha",1.0)
			thermite.uiMsg("Start")
			thermite.uiFocus(true)
			
			if callback then
				while not thermite.result do Wait(0); end
				local success = (thermite.result == 1 and true or false)
				local msg = thermite.resultMsg
		
				thermite.result = false
				thermite.resultMsg = false
		
				callback(success,msg)
				return
			end
		end)
	end
end

thermite.onStart = function(...)
	--print("On Start")
end

thermite.onStop = function(...)
	--print("On Stop")  
end

thermite.onStartCountdown = function(...)
	--print("On Start Count")  
end

thermite.onCount = function(...)
	--print("On Count")  
end

thermite.onHit = function(...)
	--print("On Hit")  
end

thermite.onMiss = function(...)
	--print("On Miss")  
end

thermite.onFail = function(...)
	thermite.uiFocus(false)
	Wait(2000)
	thermite.uiMsg("SetAlpha",0.0)

	if cfg.fireOnFail then
		local r = math.random(100)
		if r <= cfg.fireChance then
			StartEntityFire(PlayerPedId())
		end
	end

	if cfg.useItem and cfg.takeItemOnFail then
		TriggerServerEvent('thermite:takeThermite',cfg.takeOnFailCount)
	end

	thermite.resultMsg = messages.failMsg
	thermite.result    = 0  
end

thermite.onSuccess = function(...)
	thermite.uiFocus(false)
	Wait(2000)
	thermite.uiMsg("SetAlpha",0.0)

	if cfg.useItem and cfg.takeItemOnSuccess then
		TriggerServerEvent('thermite:takeThermite',cfg.takeOnSuccessCount)
	end

	FreezeEntityPosition(PlayerPedId(),true)

	local ply = PlayerPedId()
	local weapon = GetHashKey('WEAPON_PETROLCAN')
	GiveWeaponToPed(ply, weapon, 1, false, true)
	SetCurrentPedWeapon(ply, weapon, true)
	Wait(3000)

	exports['mythic_progbar']:Progress({
		name = "thermite_process",
		duration = 5000,
		label = "Pouring Thermite",
		canCancel = false,
		controlDisables = {
			disableMovement = true,
			disableCarMovement = true,
			disableMouse = false,
			disableCombat = true,
			disableInteract = true
		},
		animation = {
			animDict = "weapon@w_sp_jerrycan",
			anim = "fire",
			}
	}, function(status)
		if not status then
			RemoveWeaponFromPed(ply,weapon)

			local pos = GetEntityCoords(PlayerPedId())
			FreezeEntityPosition(PlayerPedId(),false)

			exports['core']:SendAlert('inform', 'Move away from the thermite!', 2500)

			Wait(5000)
			
			local fire = thermite.startExplosion(pos)

			thermite.resultMsg = messages.successMsg
			thermite.result    = 1  

			thermite.endFire(fire)
		end
	end)
end

thermite.startExplosion = function(pos)
	local explosionType = 3
	local radius = 1.0
	local damage = 50.0

	local found,z = GetGroundZFor_3dCoord(pos.x,pos.y,pos.z)
	AddExplosion(pos.x,pos.y,pos.z, 0, damage, true,false,radius,false,false,1.0)
	local fire = StartScriptFire(pos.x,pos.y,(found and z or pos.z), 25, false)
	return fire
end

thermite.endFire = function(fire)
	Citizen.CreateThread(function(...)
		local startTime = GetGameTimer()
		while (GetGameTimer() - startTime) < 15000 do Wait(0); end
		RemoveScriptFire(fire)
	end)
end

RegisterNUICallback('onStart',thermite.onStart)
RegisterNUICallback('onStop',thermite.onStop)
RegisterNUICallback('onStartCountdown',thermite.onStartCountdown)
RegisterNUICallback('onCount',thermite.onCount)
RegisterNUICallback('onHit',thermite.onHit)
RegisterNUICallback('onMiss',thermite.onMiss)
RegisterNUICallback('onFail',thermite.onFail)
RegisterNUICallback('onSuccess',thermite.onSuccess)

if cfg.debug then
	RegisterCommand('testtherm', function(...) thermite.startMinigame(); end)
end

AddEventHandler('thermite:start',thermite.startMinigame)
Citizen.CreateThread(thermite.init)