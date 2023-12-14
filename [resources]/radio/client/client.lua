-- Code
local radioMenu = false
local isLoggedIn = false
local lastChannel = nil
local onRadio = false

function enableRadio(enable)
   if enable then
        SetNuiFocus(enable, enable)
        PhonePlayIn()
        SendNUIMessage({
            type = "open",
        })
        radioMenu = enable
   end
end

RegisterNetEvent("radio:SetRadioVolume")
AddEventHandler("radio:SetRadioVolume", function(value)
    if Config.UsingSaltyChat then
        exports.saltychat:SetRadioVolume(value)
    end
end)

RegisterNetEvent('BJCore:Client:OnPlayerLoaded')
AddEventHandler('BJCore:Client:OnPlayerLoaded', function()
    isLoggedIn = true
end)

RegisterNetEvent('BJCore:Client:OnPlayerUnload')
AddEventHandler('BJCore:Client:OnPlayerUnload', function()
    isLoggedIn = false
    if Config.UsingSaltyChat then
        exports.saltychat:SetRadioChannel('', true)
    else
        exports.voice:setRadioChannel(0)
    end
end)

Citizen.CreateThread(function()
    if not Config.UsingSaltyChat then
        exports.voice:setVoiceProperty('micClicks', true)
    end
    while true do
        if BJCore~= nil then
            if isLoggedIn then
                BJCore.Functions.TriggerCallback('radio:server:GetItem', function(hasItem)
                    if not hasItem then
                        if Config.UsingSaltyChat then
                            exports.saltychat:SetRadioChannel('', true)
                        else
                            exports.voice:setRadioChannel(0)
                        end
                    end
                end, "radio")
            end
        end
        Citizen.Wait(10000)
    end
end)

RegisterNetEvent('radio:client:toggleSecondaryRadio')
AddEventHandler('radio:client:toggleSecondaryRadio', function()
    if Config.UsingSaltyChat then
        if exports.saltychat:GetRadioChannel(false) ~= Config.SecondaryRadioChannel then
            TriggerEvent('radio:client:joinSecondaryRadio')
        end
    else
        TriggerEvent('radio:client:leaveSecondaryRadio')
    end
end)

RegisterNetEvent('radio:client:joinSecondaryRadio')
AddEventHandler('radio:client:joinSecondaryRadio', function()
    local PlayerData = BJCore.Functions.GetPlayerData()

    if Config.SecondaryAllowedJobs[PlayerData.job.name] then
        if Config.UsingSaltyChat then
            exports.saltychat:SetRadioChannel(Config.SecondaryRadioChannel, false)
            BJCore.Functions.Notify('Connected to '..Config.SecondaryRadioChannel..' as a secondary channel', 'primary')
        end
    else
        BJCore.Functions.Notify('This fequency is not available', 'error')
    end
end)

RegisterNetEvent('radio:client:leaveSecondaryRadio')
AddEventHandler('radio:client:leaveSecondaryRadio', function()
    if Config.UsingSaltyChat then
        if exports.saltychat:GetRadioChannel(false) == Config.SecondaryRadioChannel then
            exports.saltychat:SetRadioChannel('', false)
            BJCore.Functions.Notify('Disconnected from secondary channel', 'error')
        end
    end
end)

RegisterNetEvent('radio:client:toggleRadio')
AddEventHandler('radio:client:toggleRadio', function()
    if Config.UsingSaltyChat then
        if exports.saltychat:GetRadioChannel(true) == lastChannel or lastChannel == nil then
            leaveRadio()
        else
            if lastChannel == nil then
                BJCore.Functions.Notify('You\'ve not yet connected to a radio', 'error')
            else
                joinRadio(lastChannel)
            end
        end
    else
        if onRadio then
            leaveRadio()
        else
            if lastChannel ~= nil then
                joinRadio(tostring(lastChannel))
            end
        end
    end
end)

RegisterNetEvent('radio:client:doJoinRadio')
AddEventHandler('radio:client:doJoinRadio', function(channel)
    joinRadio(tostring(channel))
end)

RegisterNUICallback('joinRadio', function(data, cb)
    local _source = source
    local PlayerData = BJCore.Functions.GetPlayerData()
    local playerName = GetPlayerName(PlayerId())

    joinRadio(tostring(data.channel))
    cb('ok')
end)

function joinRadio(channel)
    if Config.UsingSaltyChat then
        if exports.saltychat:GetRadioChannel(true) == channel then
            BJCore.Functions.Notify('You are already connected to that channel', 'error')
        end
    else
        if tonumber(channel) <= Config.MaxFrequency then
            TriggerServerEvent('radio:server:joinRadio', channel)
        else
            BJCore.Functions.Notify('This fequency is not available', 'error')
        end
    end
end

RegisterNUICallback('leaveRadio', function(data, cb)
    local playerName = GetPlayerName(PlayerId())
    --  TriggerServerEvent("InteractSound_SV:PlayOnSource", "off", 0.1)
    leaveRadio()
    cb('ok')
end)

RegisterNUICallback('escape', function(data, cb)
    SetNuiFocus(false, false)
    radioMenu = false
    PhonePlayOut()
    cb('ok')
end)

RegisterNetEvent('radio:use')
AddEventHandler('radio:use', function()
    enableRadio(true)
end)

RegisterNetEvent('radio:onRadioDrop')
AddEventHandler('radio:onRadioDrop', function()
    local playerName = GetPlayerName(PlayerId())
    leaveRadio()
    --BJCore.Functions.Notify(Config.messages['you_leave'], 'primary')
end)

function leaveRadio()
    BJCore.Functions.Notify(Config.messages['you_leave'], 'error')
    if Config.UsingSaltyChat then
        exports.saltychat:SetRadioChannel('', true)
    else
        onRadio = false
        exports.voice:setVoiceProperty('radioEnabled', false)
        exports.voice:setRadioChannel(0)
    end
end

RegisterNetEvent('radio:client:radioJoined')
AddEventHandler('radio:client:radioJoined', function(channel)
    if Config.UsingSaltyChat then
        exports.saltychat:SetRadioChannel(tostring(channel), true)
        SendNUIMessage({
            type = 'updateChannel',
            value = channel
        })
        lastChannel = channel
    else
        lastChannel = channel
        onRadio = true
        exports.voice:setVoiceProperty('radioEnabled', true)
        exports.voice:setRadioChannel(channel)
    end
end)

function SplitStr(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		table.insert(t, str)
	end
	return t
end
