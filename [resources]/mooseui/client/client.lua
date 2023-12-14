local MUI = mooseUI

local playerLoaded = false

local currentCharId = nil

local x = 1.000
local y = 1.000

local Status = {}
local hunger = -1
local thrist = -1
local showUi = false
local voice = {default = 6.0, shout = 13.0, whisper = 2.0, current = 0, level = nil}
local isDead = false

PlayerData = {}

RegisterNetEvent('ems:deathcheck')
AddEventHandler('ems:deathcheck', function(dead)
	isDead = dead
end)

RegisterNetEvent('BJCore:Player:SetPlayerData')
AddEventHandler('BJCore:Player:SetPlayerData', function(Player)
    PlayerData = Player
	Status = {hunger=PlayerData.metadata['hunger'],thirst=PlayerData.metadata['thirst'],stress=100-PlayerData.metadata['stress']}
	if not isDead then
		SendNUIMessage({
			action = "updateStatus",
			st = Status,
		})
	end
end)

RegisterNetEvent('BJCore:Client:OnJobUpdate')
AddEventHandler('BJCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
end)

RegisterNetEvent("BJCore:Client:OnPlayerLoaded")
AddEventHandler("BJCore:Client:OnPlayerLoaded", function()
    playerLoaded = true
    SendNUIMessage({
	    action = 'showui'
    })
	 SendNUIMessage({
	    type = 'usingStamina',
	    DoShow = false
	})    
end)


function MUI:Awake(...)
  while not BJCore do Citizen.Wait(1000); end
  while not playerLoaded do Citizen.Wait(1000); end
  
  self:Start()
	-- ESX.TriggerServerCallback('mooseUI:GetCharacterId', function(id)
	-- 	currentCharId = id
	-- 	exports['tbh_customcommands']:SetData('CharId', currentCharId)
	-- 	SendNUIMessage({
	-- 		action = 'set-char',
	-- 		charId = currentCharId
	-- 	})
	-- end)
end

function MUI:Start(data)
  while not BJCore do Citizen.Wait(0); end
  while not playerLoaded do Citizen.Wait(0); end
  SendNUIMessage({
    action = 'showui'
  })
  MUI:UIStuff()
  showUi = true
  isHidden = true
  SendNUIMessage({
    type = 'usingStamina',
    DoShow = false
  })
end

function MUI:UIStuff()
	Status = {hunger=PlayerData.metadata['hunger'],thirst=PlayerData.metadata['thirst'],stress=100-PlayerData.metadata['stress']}
	if not isDead then
		SendNUIMessage({
			action = "updateStatus",
			st = Status,
		})
	end
    local playerId, ped, maxHealth = PlayerId(), PlayerPedId(), GetEntityMaxHealth(PlayerPedId())
    Citizen.CreateThread(function()
        while true do
            playerId, ped, maxHealth = PlayerId(), PlayerPedId(), GetEntityMaxHealth(PlayerPedId())
            Wait(1500)
        end
    end)
	Citizen.CreateThread(function()
		while true do
			if not isDead then
				SendNUIMessage({
					action = 'tick',
					show = IsPauseMenuActive(),
					health = GetEntityHealth(ped)/(maxHealth / 100),
					armor = GetPedArmour(ped),
					stamina = 100 - GetPlayerSprintStaminaRemaining(playerId)
				})
			end
			if MUI.VoiceType == 0 or MUI.VoiceType == 2 then
				if NetworkIsPlayerTalking(playerId) then
					SendNUIMessage({
						action = 'voice-color',
						isTalking = true
					})
				else
					SendNUIMessage({
						action = 'voice-color',
						isTalking = false
					})
				end
			end
            if showUi then
			    Citizen.Wait(200)
            else
                Citizen.Wait(1000)
            end
		end
	end)
	if MUI.VoiceType == 0 then
		Citizen.CreateThread(function()
			while true do
				Citizen.Wait(1)
				if IsControlJustPressed(1, 246) and IsControlPressed(1, 21) then
					voice.current = (voice.current + 1) % 3
					if voice.current == 0 then
						NetworkSetTalkerProximity(voice.default)
						SendNUIMessage({
							action = 'set-voice',
							value = 66
						})
					elseif voice.current == 1 then
						NetworkSetTalkerProximity(voice.shout)
						SendNUIMessage({
							action = 'set-voice',
							value = 100
						})
					elseif voice.current == 2 then
						NetworkSetTalkerProximity(voice.whisper)
						SendNUIMessage({
							action = 'set-voice',
							value = 33
						})
					end
				end
			end
		end)
    elseif MUI.VoiceType == 1 then
        NetworkSetTalkerProximity(0.0)
	end
end

AddEventHandler('onClientMapStart', function()
    if voice.current == 0 then
      NetworkSetTalkerProximity(voice.default)
    elseif voice.current == 1 then
      NetworkSetTalkerProximity(voice.shout)
    elseif voice.current == 2 then
      NetworkSetTalkerProximity(voice.whisper)
    end  
end)

RegisterNetEvent('mooseUI:client:UpdateStatus')
AddEventHandler('mooseUI:client:UpdateStatus', function(status)
	for k,v in pairs(status) do
		--print('Setting '..k..' to '..tostring(v))
		Status[k] = v
	end
	if not isDead then
		SendNUIMessage({
			action = "updateStatus",
			st = Status,
		})
	end
end)

RegisterNetEvent('mooseUI:client:UpdateTalkType')
AddEventHandler('mooseUI:client:UpdateTalkType', function(talkType)
	SendNUIMessage({
		action = "type-update",
		talkType = talkType
	})
end)

RegisterNetEvent('mooseUI:client:UpdateTalkRange')
AddEventHandler('mooseUI:client:UpdateTalkRange', function(talkMode, maxRanges)
    if not maxRanges then maxRanges = 3; end
	local val = 100
    local partsPerMode = math.floor(100 / maxRanges)
	if talkMode == maxRanges then
		val = 100
	else
        val = partsPerMode * talkMode
	end
	SendNUIMessage({
		action = "range-update",
		voiceVal = val
	})
end)

RegisterNetEvent('mooseUI:client:UpdateTokoData')
AddEventHandler('mooseUI:client:UpdateTokoData', function(talkMode, isTalking, talkType)
	local val = 100
	if talkMode == 1 then
		val = 66
	elseif talkMode == 2 then
		val = 33
	end
	SendNUIMessage({
		action = "toko-update",
		isTalking = isTalking,
		voiceVal = val,
		talkType = talkType
	})
end)

RegisterNetEvent('mooseUI:client:UpdateTalking')
AddEventHandler('mooseUI:client:UpdateTalking', function(isTalking)
    SendNUIMessage({
        action = 'voice-color',
        isTalking = isTalking
    })
end)

local function getStamina()
	Citizen.CreateThread(function(...)
		while true do
			if 100 - (GetPlayerSprintStaminaRemaining(PlayerId())) < 99.9 and not IsPedInAnyVehicle(PlayerPedId(),false) then  
				isHidden = false
				SendNUIMessage({
					type = 'usingStamina',
					DoShow = true
				})
			else
				if not isHidden then
					isHidden = true
					SendNUIMessage({
						type = 'usingStamina',
						DoShow = false
					})
				end
			end
			Citizen.Wait(30)
		end
	end)	
end
getStamina()

local hungerHidden, thirstHidden = false, false
function MUI:getStatus( ... )
    while not BJCore do Citizen.Wait(0); end
	while not playerLoaded do Citizen.Wait(0); end
	local fiftyPercent = (100 / 2)	
    while true do
    if Status.hunger ~= nil then
      if Status.hunger <= fiftyPercent then
        hungerHidden = false
        SendNUIMessage({
          type = 'minHunger',
          DoShow = true
        })
      else
        if not hungerHidden then
          hungerHidden = true
          SendNUIMessage({
            type = 'minHunger',
            DoShow = false
          })
        end
      end
    end
    Citizen.Wait(1000)
    if Status.thirst ~= nil then
      if Status.thirst <= fiftyPercent then
        thirstHidden = false
        SendNUIMessage({
          type = 'minThirst',
          DoShow = true
        })
      else
        if not thirstHidden then
          thirstHidden = true
          SendNUIMessage({
            type = 'minThirst',
            DoShow = false
          })
        end
      end
    end
  end
end

local hasRun = false
local newChar = false

AddEventHandler("tac_identity:showRegisterIdentity", function()
	newChar = true
end)

AddEventHandler("skinchanger:loadSkin", function()	
	if not hasRun then
		hasRun = true
		Wait(2000)
		getMugshot()
		if newChar then
			Citizen.CreateThread(function()
				Wait(600000) -- Wait 10 mins
				getMugshot()
			end)
			newChar = false
		end
	end
end)

function getMugshot()
	
	-- ESX.TriggerServerCallback('mooseUI:GetCharacterId', function(id)
	-- 	-- Register the ped headshot
	-- 	Citizen.CreateThread(function()
	-- 		local ped = PlayerPedId()
	-- 		local mugshot = RegisterPedheadshot(ped)
		
	-- 		while not IsPedheadshotReady(mugshot) do
	-- 			Wait(0)
	-- 		end
		
	-- 		-- Loop necessary to be able to draw the mugshot
	-- 		local i = 0
		
	-- 		while i < 20 do
	-- 			Wait(1)
				
	-- 			-- Draws the mugshot at the players screen
	-- 			DrawSprite(GetPedheadshotTxdString(mugshot), GetPedheadshotTxdString(mugshot), 0.045, 0.085, 0.09, 0.18, 0.0, 255, 255, 255, 1000)
		
	-- 			i = i + 1
		
	-- 			-- Makes the sprite a second
	-- 			if i == 10 then
	-- 				local x, y = GetActiveScreenResolution()
					
	-- 				x = x * 0.09
	-- 				y = y * 0.18
					
	-- 				-- Screenshot the screen using screenshot-basic
	-- 				exports['screenshot-basic']:requestScreenshotUpload("http://chars.lls.gg/api/char-upload?f="..id..".jpg&w="..x.."&h="..x, "files[]", {encoding = 'jpg', x = 0, y = 0, w = 160, h = 170}, function(data)
	-- 					-- Unregister the ped headshot
	-- 				end)
	-- 			end
	-- 		end
			
	-- 		UnregisterPedheadshot(mugshot)
	-- 	end)
	-- end)
	
end

RegisterNetEvent('bj-ui:client:openUI:multichar')
AddEventHandler('bj-ui:client:openUI:multichar', function()
	MUI:Awake()
end)

function MUI:ToggleUI()
	showUi = not showUi
	TriggerEvent('hud:toggle', showUi)
end

AddEventHandler('hud:toggle', function(show)
	if show then
		SendNUIMessage({
			action = 'showui'
		})
	else 
		SendNUIMessage({
			action = 'hideui'
		})
	end
end)

RegisterNetEvent("BJCore:Client:OnPlayerUnload")
AddEventHandler("BJCore:Client:OnPlayerUnload", function()
    playerLoaded = false
    SendNUIMessage({
		action = 'hideui'
	})
end)

RegisterCommand('hud', function(...) MUI:ToggleUI(...); end)
Citizen.CreateThread(function(...) MUI:getStatus(...); end)
Citizen.CreateThread(function()
	Citizen.Wait(1000)
	MUI:Awake()
end)