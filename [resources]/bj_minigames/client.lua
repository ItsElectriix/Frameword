ScaleformMinigames = {}

local currentMgCallbacks = {}

local allowedTypes = {
    ['Lockbox'] = 'nui-nomouse',
    ['Lockpick'] = 'nui',
    ['Pincode'] = 'nui',
    ['Connection'] = 'nui',
    ['Safecrack'] = 'nui',
    ['Bruteforce'] = 'scaleform',
    ['Datacrack'] = 'scaleform',
    ['Hackconnect'] = 'scaleform',
    ['Fingerprint'] = 'scaleform',
}

local runningNoMouseUI = false

--RegisterNetEvent('bj_minigames:start')
AddEventHandler('bj_minigames:start', function(mgType, mgData, mgSuccess, mgFail)
    TriggerEvent('game:client:pauseKeybind', true)
    if allowedTypes[mgType] then
        if mgData == nil then
            mgData = {}
        end
        if mgSuccess == nil or (type(mgSuccess) ~= 'function' and type(mgSuccess) ~= 'table') then
            mgSuccess = function() end
        end
        if mgFail == nil or (type(mgFail) ~= 'function' and type(mgFail) ~= 'table') then
            mgFail = function() end
        end
        currentMgCallbacks[mgType] = {
            success = mgSuccess,
            fail = mgFail
        }
        if allowedTypes[mgType] == 'nui' then
            SetCursorLocation(0.5, 0.5)
            SetNuiFocus(true, true)
            if mgType == 'Pincode' then SetTimecycleModifier('hud_def_blur'); end
            SendNUIMessage({ type = 'startGame', mgType = mgType, mgData = mgData })
        elseif allowedTypes[mgType] == 'nui-nomouse' then
            runningNoMouseUI = true
            Citizen.CreateThread(function()
                while runningNoMouseUI do
                    DisableControlAction(0, 24, true)
                    DisableControlAction(0, 69, true)
					DisableControlAction(0, 92, true)
					DisableControlAction(0, 142, true)
					DisableControlAction(0, 237, true)
					DisableControlAction(0, 257, true)
                    if IsDisabledControlJustPressed(0, 24) then
                        SendNUIMessage({
                            type = "mouseClicked",
                            mgType = mgType
                        })
                    end
                    Wait(2)
                end
            end)
            SendNUIMessage({ type = 'startGame', mgType = mgType, mgData = mgData })
        elseif allowedTypes[mgType] == 'scaleform' then
            ScaleformMinigames[mgType](mgData)
            TriggerEvent('ui:client:toggleHud', false)
        end
    else
        print('BJ_Minigames: Unkown Minigame: '..mgType)
    end
end)

AddEventHandler('bj_minigames:stop', function(mgType)
    if allowedTypes[mgType] then
        SendNUIMessage({ type = 'stopGame', mgType = mgType })
    else
        print('BJ_Minigames: Unknown Minigame: '..mgType)
    end
end)

AddEventHandler('bj:minigameResult', function(type, result, data, nui)
    TriggerEvent('game:client:pauseKeybind', false)
    if nui then
        runningNoMouseUI = false
        SetTimecycleModifier('default')
        SetNuiFocus(false, false)
        SendNUIMessage({
            type = "hideUI"
        })
    else
        TriggerEvent('ui:client:toggleHud', true)
    end
    if currentMgCallbacks[type] then
        if result and currentMgCallbacks[type].success ~= nil then
            currentMgCallbacks[type].success(data)
        elseif result == false and currentMgCallbacks[type].fail ~= nil then
            currentMgCallbacks[type].fail(data)
        end
    end
end)

RegisterNUICallback('minigameResult', function(data)
    TriggerEvent('bj:minigameResult', data.type, data.result, data.data, true)
end)

function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
        if v ~= 0 then 
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
        end
       end
       return s .. '} '
    else
       return tostring(o)
    end
end

RegisterNetEvent("core:resetUi")
AddEventHandler("core:resetUi", function()
    TriggerEvent('bj:minigameResult', '', false, {}, true)
end)