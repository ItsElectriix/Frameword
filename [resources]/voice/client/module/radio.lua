--- event syncRadioData
--- syncs the current players on the radio to the client
---@param radioTable table the table of the current players on the radio
function syncRadioData(radioTable)
	radioData = radioTable
    local uiTable = {}
	for tgt, enabled in pairs(radioTable) do
		if tgt ~= playerServerId then
			toggleVoice(tgt, enabled, 'radio')
		end
        uiTable[tostring(tgt)] = {
            talking = enabled,
            name = PlayersCoords[tgt] and PlayersCoords[tgt].radioName or 'Unknown'
        }
	end
	playerTargets(radioData, callData)
    if GetConvarInt('voice_enableUi', 1) == 1 then
		SendNUIMessage({
			radioList = uiTable
		})
	end
end
RegisterNetEvent('pma-voice:syncRadioData', syncRadioData)

--- event setTalkingOnRadio
--- sets the players talking status, triggered when a player starts/stops talking.
---@param plySource number the players server id.
---@param enabled boolean whether the player is talking or not.
function setTalkingOnRadio(plySource, enabled)
	if plySource ~= playerServerId then
		toggleVoice(plySource, enabled, 'radio')
		radioData[plySource] = enabled
		playerTargets(radioData, callData)
		playMicClicks(enabled)
	end
    if GetConvarInt('voice_enableUi', 1) == 1 then
		SendNUIMessage({
			radioTalkSource = plySource,
            radioIsTalking = enabled,
            radioTalkName = PlayersCoords[plySource] and PlayersCoords[plySource].radioName or 'Unknown'
		})
	end
end
RegisterNetEvent('pma-voice:setTalkingOnRadio', setTalkingOnRadio)

--- event addPlayerToRadio
--- adds a player onto the radio.
---@param plySource number the players server id to add to the radio.
function addPlayerToRadio(plySource)
	radioData[plySource] = false
	playerTargets(radioData, callData)
    if GetConvarInt('voice_enableUi', 1) == 1 then
		SendNUIMessage({
			radioPlayerAdded = plySource,
            currentPlayerName = PlayersCoords[plySource] and PlayersCoords[plySource].radioName or 'Unknown'
		})
	end
end
RegisterNetEvent('pma-voice:addPlayerToRadio', addPlayerToRadio)

--- event removePlayerFromRadio
--- removes the player (or self) from the radio
---@param plySource number the players server id to remove from the radio.
function removePlayerFromRadio(plySource)
	if plySource == playerServerId then
		for tgt, enabled in pairs(radioData) do
			if tgt ~= playerServerId then
				toggleVoice(tgt, false)
			end
		end
		radioData = {}
		playerTargets(radioData, callData)
        if GetConvarInt('voice_enableUi', 1) == 1 then
            SendNUIMessage({
                clearRadio = true
            })
        end
	else
		radioData[plySource] = nil
		toggleVoice(plySource, false)
		playerTargets(radioData, callData)
        if GetConvarInt('voice_enableUi', 1) == 1 then
            SendNUIMessage({
                radioPlayerRemoved = plySource
            })
        end
	end
end
RegisterNetEvent('pma-voice:removePlayerFromRadio', removePlayerFromRadio)

--- function setRadioChannel
--- sets the local players current radio channel and updates the server
---@param channel number the channel to set the player to, or 0 to remove them.
function setRadioChannel(channel)
	if GetConvarInt('voice_enableRadios', 1) ~= 1 then return end
	TriggerServerEvent('pma-voice:setPlayerRadio', channel)
	voiceData.radio = channel
	if GetConvarInt('voice_enableUi', 1) == 1 then
		SendNUIMessage({
			radioChannel = channel,
			radioEnabled = voiceData.radioEnabled
		})
	end
end

--- exports setRadioChannel
--- sets the local players current radio channel and updates the server
---@param channel number the channel to set the player to, or 0 to remove them.
exports('setRadioChannel', setRadioChannel)
-- mumble-voip compatability
exports('SetRadioChannel', setRadioChannel)

--- exports removePlayerFromRadio
--- sets the local players current radio channel and updates the server
exports('removePlayerFromRadio', function()
	setRadioChannel(0)
end)

--- exports addPlayerToRadio
--- sets the local players current radio channel and updates the server
---@param radio number the channel to set the player to, or 0 to remove them.
exports('addPlayerToRadio', function(radio)
	local radio = tonumber(radio)
	if radio then
		setRadioChannel(radio)
	end
end)

--- check if the player is dead
--- seperating this so if people use different methods they can customize
--- it to their need as this will likely never be changed.
isRPDead = false
RegisterNetEvent('ems:deathcheck')
AddEventHandler('ems:deathcheck', function()
    if not isRPDead then
        isRPDead = true
    else
        isRPDead = false
    end
end)

function isDead()
	if GetResourceState("pma-ambulance") ~= "missing" then
		if LocalPlayer.state.isDead then
			return true
		end
	elseif (isRPDead or LocalPlayer.state.InLaststand == true) then
		print("rpdead")
		return true
	end
	return false
end

RegisterCommand('+radiotalk', function()
	if GetConvarInt('voice_enableRadios', 1) ~= 1 then return end
	if isDead() then return end

	if not voiceData.radioPressed and voiceData.radioEnabled then
		if voiceData.radio > 0 then
			TriggerServerEvent('pma-voice:setTalkingOnRadio', true)
            if GetConvarInt('voice_enableUi', 1) == 1 then
                SendNUIMessage({
                    radioTalkSource = playerServerId,
                    radioIsTalking = true
                })
            end
			voiceData.radioPressed = true
			playMicClicks(true)
			Citizen.CreateThread(function()
		        local lib = "random@arrests"
		        local anim = "generic_radio_chatter"

		        LoadAnimDict("random@arrests")
				TriggerEvent("pma-voice:radioActive", true)
				while voiceData.radioPressed do
					print("loop anim")
					Wait(0)
					if not IsEntityPlayingAnim(PlayerPedId(), lib, anim, 3) then
		                TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, 0.0, -1, 49, 0, false, false, false)
		            end
					SetControlNormal(0, 249, 1.0)
					SetControlNormal(1, 249, 1.0)
					SetControlNormal(2, 249, 1.0)
				end
				StopAnimTask(PlayerPedId(), lib, anim, 3.0)
			end)
		end
	end
end, false)

RegisterCommand('-radiotalk', function()
	if voiceData.radio > 0 or voiceData.radioEnabled then
		--if not isDead() then
			voiceData.radioPressed = false
			TriggerEvent("pma-voice:radioActive", false)
			playMicClicks(false)
			TriggerServerEvent('pma-voice:setTalkingOnRadio', false)
	        if GetConvarInt('voice_enableUi', 1) == 1 then
	            SendNUIMessage({
	                radioTalkSource = playerServerId,
	                radioIsTalking = false
	            })
	        end
	    --end
	end
end, false)
RegisterKeyMapping('+radiotalk', 'Talk over Radio', 'keyboard', GetConvar('voice_defaultRadio', 'LMENU'))

--- event syncRadio
--- syncs the players radio, only happens if the radio was set server side.
---@param radioChannel number the radio channel to set the player to.
function syncRadio(radioChannel)
	if GetConvarInt('voice_enableRadios', 1) ~= 1 then return end
	voiceData.radio = radioChannel
end
RegisterNetEvent('pma-voice:clSetPlayerRadio', syncRadio)
