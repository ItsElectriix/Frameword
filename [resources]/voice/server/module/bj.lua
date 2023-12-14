players = {}

local infinityEnabled = GetConvar("onesync", "off") == "on"

PhoneticAlphabet = {
	"Alpha",
	"Bravo",
	"Charlie",
	"Delta",
	"Echo",
	"Foxtrot",
	"Golf",
	"Hotel",
	"India",
	"Juliet",
	"Kilo",
	"Lima",
	"Mike",
	"November",
	"Oscar",
	"Papa",
	"Quebec",
	"Romeo",
	"Sierra",
	"Tango",
	"Uniform",
	"Victor",
	"Whisky",
	"XRay",
	"Yankee",
	"Zulu",
}

function GetRandomPhoneticLetter()
	math.randomseed(GetGameTimer())

	return PhoneticAlphabet[math.random(1, #PhoneticAlphabet)]
end

RegisterNetEvent("bj_infinity:player:ready")
AddEventHandler("bj_infinity:player:ready", function()
    players[source] = {
        pos = vector3(0.0, 0.0, 0.0),
        name = GetPlayerName(source),
        radioName = (GetRandomPhoneticLetter() .. "-" .. source)
    }
end)

exports('GetInfinityPlayers', function()
	return players
end)

AddEventHandler('playerDropped', function()
    local serverID = tonumber(source);
	Wait(200)
    players[serverID] = nil
end)

RegisterCommand('radioname', function(source, args, raw)
    SetPlayerRadioName(source, table.concat(args, ' '))
end)

function SetPlayerRadioName(serverId, name)
	if players[serverId] then
		local value = name or (GetRandomPhoneticLetter() .. "-" .. serverId)
		players[serverId].radioName = value
		TriggerClientEvent("bj:voice:radio:nameUpdated", -1, serverId, value)
	end
end

exports('SetPlayerRadioName', SetPlayerRadioName)

Citizen.CreateThread(function()
    while true do
        if infinityEnabled then
            for k,v in pairs(players) do
                local ped = GetPlayerPed(k)
                if ped then
                    players[k].pos = GetEntityCoords(ped)
                else
                    players[k] = nil
                end
            end
        end
        TriggerClientEvent("bj_infinity:player:coords", -1, players)
        Wait(1000)
    end
end)

exports("RegisterRadioFrequency", function(...)
    TriggerEvent('radio:registerAuthorizedFrequency', ...)
end)