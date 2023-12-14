local MinigameOpen, SoundID, Timer, StayClosed = false, 0, 0, false
function SCStartMinigame(rewards, stayClosed)
	local txd = CreateRuntimeTxd(Config.SCConfig.TextureDict)
	for i = 1, 2 do CreateRuntimeTextureFromImage(txd, tostring(i), "LockPart" .. i .. ".PNG") end

	MinigameOpen = true
	SoundID 	  = GetSoundId() 
	Timer 		  = GetGameTimer()
    StayClosed = (stayClosed or false)

	if not RequestAmbientAudioBank(Config.SCConfig.AudioBank, false) then RequestAmbientAudioBank(Config.SCConfig.AudioBankName, false); end
	if not HasStreamedTextureDictLoaded(Config.SCConfig.TextureDict, false) then RequestStreamedTextureDict(Config.SCConfig.TextureDict, false); end

	Citizen.CreateThread(function() SCUpdate(rewards,stayClosed); end)	
end

RegisterNetEvent('safecracker:StartMinigame')
AddEventHandler('safecracker:StartMinigame', function(rewards,stayClosed) SCStartMinigame(rewards,stayClosed); end)

function SCUpdate(rewards)
	if not MinigameOpen then return; end	
	Citizen.CreateThread(function() SCHandleMinigame(rewards,stayClosed); end)
	while MinigameOpen do
		SCInputCheck()  
		if IsEntityDead(GetPlayerPed(PlayerId())) then SCEndMinigame(false, false); end
		Citizen.Wait(0)
	end
end

local LockRotation = 0
function SCInputCheck()
	if not MinigameOpen then return; end	
	local leftKeyPressed 	= IsControlPressed( 0, Keys[ 'LEFT' ] ) 	or 0
	local rightKeyPressed 	= IsControlPressed( 0, Keys[ 'RIGHT' ] )	or 0
	if 		IsControlPressed( 0, Keys[ 'G' ] ) 			then SCEndMinigame(false); end
	if 		IsControlPressed( 0, Keys[ 'Z' ] ) 			then rotSpeed 	=   0.1; modifier = 33;
  elseif 	IsControlPressed( 0, Keys[ 'LEFTSHIFT' ] )	then rotSpeed 	=   1.0; modifier = 50; 
  else 																 rotSpeed	=   0.4; modifier = 90; end

    local lockRotation = math.max(modifier / rotSpeed, 0.1)

    if leftKeyPressed ~= 0 or rightKeyPressed ~= 0 then
    	LockRotation = LockRotation - ( rotSpeed * tonumber( leftKeyPressed ) )
    	LockRotation = LockRotation + ( rotSpeed * tonumber( rightKeyPressed ) )
    	if (GetGameTimer() - Timer) > lockRotation then 
    		PlaySoundFrontend(0, Config.SCConfig.SafeTurnSound, Config.SCConfig.SafeSoundset, false)
    		Timer = GetGameTimer() 
    	end
    end
end

function SCHandleMinigame(rewards) 
	if not MinigameOpen then return; end

	local lockRot 		 = math.random(385.00, 705.00)	

	local lockNumbers 	 = {}
	local correctGuesses = {}

	lockNumbers[1] = 1
	lockNumbers[2] = math.random(					 45.0, 					359.0)
	lockNumbers[3] = math.random(lockNumbers[2] -	719.0, lockNumbers[2] - 405.0)
	lockNumbers[4] = math.random(lockNumbers[3] +  	 45.0, lockNumbers[3] + 359.0)

	-----------------------
	-- REDO LOCK NUMBERS --
	-----------------------
	-- Make numbers persist if chosen.
	-- Add number count for difficulty.
	-- Multiples of 2 are positive, 45 - 359;
	-- Multiples of 3 are negative, 719 - 405;
	-- Everything else is negative, 45 - 359;


	local isDebug = false
	---------------------------------------------
	-- Still havn't done, you're welcome to ^^ --
	---------------------------------------------

	if isDebug then
		print("Here ya go, bloody cheater.")
		for i = 1,4 do
			print(lockNumbers[i])
		end
		Wait(4000)
	end
	--------------------------------------
	-- Comment this out for a challenge --
	--------------------------------------

    local correctCount	= 1
    local hasRandomized	= false

    LockRotation = 0.0 + lockRot
	while MinigameOpen do	
		--				Texture Dictionary, Texture Name, xPos, yPos, xSize, ySize, 		   Heading,   R,   G,   B,   A,
		SetTextComponentFormat('STRING')
		AddTextComponentString('~INPUT_DETONATE~ cancel ~INPUT_MULTIPLAYER_INFO~ slow (hold). ~INPUT_SPRINT~ fast (hold).')
		DisplayHelpTextFromStringLabel(0, 0, 1, - 1)
		DrawSprite(Config.SCConfig.TextureDict, 		 "1",  0.8,  0.5,  0.15,  0.26, -LockRotation, 255, 255, 255, 255)
		DrawSprite(Config.SCConfig.TextureDict, 		 "2",  0.8,  0.5, 0.176, 0.306, 		      -0.0, 255, 255, 255, 255)	
		
		if isDebug then
				print(LockRotation)
		end
		
		hasRandomized = true

		local lockVal = math.floor(LockRotation)

		if 		correctCount > 1 and 	correctCount < 5 and lockVal + (Config.SCConfig.LockTolerance * 3.60) < lockNumbers[correctCount - 1] and lockNumbers[correctCount - 1] < lockNumbers[correctCount] then SCEndMinigame(false, rewards); MinigameOpen = false; 
		elseif 	correctCount > 1 and 	correctCount < 5 and lockVal - (Config.SCConfig.LockTolerance * 3.60) > lockNumbers[correctCount - 1] and lockNumbers[correctCount - 1] > lockNumbers[correctCount] then SCEndMinigame(false, rewards); MinigameOpen = false; 
		elseif 	correctCount > 4 then 	SCEndMinigame(true, rewards)
		end

		for k,v in pairs(lockNumbers) do
		  	if not hasRandomized then LockRotation = lockRot; end
			if lockVal == v and correctCount == k then
				local canAdd = true
				for key,val in pairs(correctGuesses) do
					if val == lockVal and key == correctCount then
						canAdd = false
					end
				end

				if canAdd then 				
					PlaySoundFrontend(-1, Config.SCConfig.SafePinSound, Config.SCConfig.SafeSoundset, true)
					correctGuesses[correctCount] = lockVal
					correctCount = correctCount + 1; 
				end   				  			
			end
		end
		Citizen.Wait(0)
	end
end


function SCEndMinigame(won, rewards)
	--if not MinigameOpen then return; end

	MinigameOpen = false	

	local msg = ""
	if won then 
		PlaySoundFrontend(SoundID, Config.SCConfig.SafeFinalSound, Config.SCConfig.SafeSoundset, true)
		msg = "You cracked the lock"
	    if not StayClosed then
		  SCOpenSafeDoor()	
	    end

		Citizen.Wait(100)

		PlaySoundFrontend(SoundID, Config.SCConfig.SafeOpenSound, Config.SCConfig.SafeSoundset, true)
		TriggerServerEvent('safecracker:AddReward', rewards)
		
	else	
		PlaySoundFrontend(SoundID, Config.SCConfig.SafeResetSound, Config.SCConfig.SafeSoundset, true)
		msg = "You failed to crack the lock"
	end

	BJCore.Functions.Notify(msg,'primary')
	TriggerEvent('safecracker:EndMinigame', won)
end

RegisterNetEvent('safecracker:EndGame')
AddEventHandler('safecracker:EndGame', function(won, rewards) SCEndMinigame(won, rewards); end)

function SCOpenSafeDoor()
  Citizen.CreateThread(function(...)
    local objs = BJCore.Functions.GetObjects()
    local doorHash = (GetHashKey(Config.SCSafeModels.Door) % 0x100000000)
    for k,v in pairs(objs) do
      if (GetEntityModel(v)% 0x100000000) == doorHash then 

        local doorHeading = GetEntityPhysicsHeading(v)
        local doorPosition = GetEntityCoords(v)

        SetEntityCollision(v, false, false)
        FreezeEntityPosition(v, false)

        local targetHeading = doorHeading + 150
        local tick = 0
        while targetHeading > GetEntityHeading(v) and tick < 500 do    
          tick = tick + 1
          SetEntityHeading(v, GetEntityHeading(v) + 0.3)
          SetEntityCoords(v, doorPosition, false, false, false, false)
          Citizen.Wait(0)
        end

        if not (GetEntityHeading(v) >= targetHeading) then SetEntityHeading(v, targetHeading); end
      end
    end  
  end)
end

function SCAwake(...)
    while not BJCore do Citizen.Wait(1000); end
    while not BJCore.Functions.IsPlayerLoaded() do Citizen.Wait(1000); end
    SCStart()
end

function SCStart(...)
	SCUpdate()
end

local DoorObj, DoorHeading, Objects = 0, 0, {}
function SCSpawnSafeObject(table, position, heading)
	if not table then table = Config.SCSafeObjects; end
	if not table or not position or not heading then return; end
	if type(table) ~= 'table' or type(position) ~= 'vector3' or type(heading) ~= 'number' then return; end

	SCLoadModelTable(Config.SCSafeModels)

	local retTable = {}
	local i = 0
	for k,v in pairs(table) do
		i = i + 1
		local hash = GetHashKey(v.ModelName) % 0x100000000
		local newHeading = heading + v.Heading

		local newObj = CreateObject(hash, v.Pos.x + position.x, v.Pos.y + position.y, v.Pos.z + position.z, false, false, false)

		if v.ModelName == Config.SCSafeModels.Door then 
			DoorObj = newObj
			DoorHeading = GetEntityHeading(DoorObj)
		end

		SetEntityAsMissionEntity(newObj, true)
		FreezeEntityPosition(newObj, true)
		SetEntityHeading(newObj, newHeading)

		if v.Rot.x ~= 0.0 or v.Rot.y ~= 0.0 or v.Rot.z ~= 0.0 then SetEntityRotation(newObj, v.Rot.x, v.Rot.y, v.Rot.z, 1, true); end
		retTable[v.ModelName] = newObj		
	end

	SCReleaseModelTable(Config.SCSafeModels)
	Objects = retTable
	return retTable
end

function SCDelSafe()
	for k,v in pairs(Objects) do DeleteObject(v); end
end

RegisterNetEvent('safecracker:SpawnSafe')
AddEventHandler('safecracker:SpawnSafe', function(tab, pos, heading, cb) if cb then cb(SCSpawnSafeObject(tab,pos,heading)) else SCSpawnSafeObject(tab,pos,heading); end; end)

function SCLoadModelTable(table)
  if type(table) ~= 'table' then return false; end
  for k,v in pairs(table) do
    if type(v) == 'string' then
      local hk = GetHashKey(v) % 0x100000000
      while not HasModelLoaded(hk) do
        RequestModel(hk)
        Citizen.Wait(0)
      end
    end
  end
  return true
end

function SCReleaseModelTable(table)
  if type(table) ~= 'table' then return false; end
  for k,v in pairs(table) do
    if type(v) == 'string' then
      local hk = GetHashKey(v) % 0x100000000
      if HasModelLoaded(hk) then
        SetModelAsNoLongerNeeded(hk)
      end
    end
  end
  return true
end

Citizen.CreateThread(function(...) SCAwake(...); end)