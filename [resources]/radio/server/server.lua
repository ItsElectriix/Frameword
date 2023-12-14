BJCore = nil
TriggerEvent('BJCore:GetObject', function(obj) BJCore = obj end)

-- Code

local authorizedRadios = {}

AddEventHandler('radio:registerAuthorizedFrequency', function(radioID, authFunc)
    RegisterRadioFrequency(radioID, authFunc)
end)

function RegisterRadioFrequency(radioID, authFunc)
    if authFunc and type(authFunc) == 'function' then
        print('Unable to register radio, invalid auth functions')
        return
    end

    radioID = tostring(radioID)

    if not authorizedRadios[radioID] then
        authorizedRadios[radioID] = {
            channel = radioID,
            auth = authFunc
        }
    else
        authorizedRadios[radioID].auth = authFunc
    end

    print('Registered Authorized Frequency: '..radioID)
end

BJCore.Functions.CreateUseableItem("radio", function(source, item)
  local Player = BJCore.Functions.GetPlayer(source)
  TriggerClientEvent('radio:use', source)
end)

BJCore.Functions.RegisterServerCallback('radio:server:GetItem', function(source, cb, item)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    if Player ~= nil then 
        local RadioItem = Player.Functions.GetItemByName(item)
        if RadioItem ~= nil then
            cb(true)
        else
            cb(false)
        end
    else
        cb(false)
    end
end)

if Config.UsingSaltyChat then
    BJCore.Commands.Add("toggleshared", "Toggle the shared radio", {}, true, function(source, args)
        TriggerClientEvent('radio:client:toggleSecondaryRadio', source)
    end)

    BJCore.Commands.Add("radiovol", "Set radio volume", {{name="value", help="0% - 160%"}}, true, function(source, args)
        local _source = source
        local Player = BJCore.Functions.GetPlayer(_source)
        if #args > 0 then
            local vol = tonumber(args[1])
            if vol == nil then
                TriggerClientEvent('BJCore:Notify', _source, 'Invalid volume level', 'error')
            elseif vol < 0 or vol > 160 then
                TriggerClientEvent('BJCore:Notify', _source, 'You must enter a value between 0 & 160', 'error')
            else
                TriggerClientEvent('BJCore:Notify', _source, 'Volume set to: '..tostring(vol)..'%', 'primary')
                TriggerClientEvent("radio:SetRadioVolume", _source, vol / 100)
            end
        else
            TriggerClientEvent('BJCore:Notify', _source, 'You must enter a value between 0 & 160', 'error')
        end  
    end)
end

RegisterServerEvent('radio:server:joinRadio')
AddEventHandler('radio:server:joinRadio', function(channel)
    local _source = tonumber(source)
    channel = tostring(channel)
    local Player = BJCore.Functions.GetPlayer(_source)
    if Player ~= nil then 
        local RadioItem = Player.Functions.GetItemByName('radio')
        if RadioItem ~= nil then
            if not authorizedRadios[channel] or (authorizedRadios[channel].auth(_source, channel)) then
                TriggerClientEvent('radio:client:radioJoined', _source, tonumber(channel))
                --TriggerClientEvent("InteractSound_CL:PlayOnOne", _source, "on", 0.1)
                TriggerClientEvent('BJCore:Notify', _source, 'Connected to radio: ' .. channel .. '.00 MHz', 'error')
            else
                TriggerClientEvent('BJCore:Notify', _source, 'Radio is Encrypted', 'error')
            end
        end
    end
end)

Citizen.CreateThread(function()
    TriggerEvent('bj:voice:radio:ready')
end)