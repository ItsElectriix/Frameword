BJCore = nil
Citizen.CreateThread(function(...) while BJCore == nil do TriggerEvent('BJCore:GetObject', function(obj) BJCore = obj end); Citizen.Wait(1000); end; end)

local isShowing = false
local resourceName = GetCurrentResourceName()

RegisterCommand('mdt', function(source, args, rawCommand) TriggerEvent('openMDT'); end)

AddEventHandler('openMDT', function()
    local PlayerData = BJCore.Functions.GetPlayerData()
	if PlayerData.job.name == 'police' then
		if not isShowing then
			SendNUIMessage({
				type = "showApp",
                resName = resourceName
			})
			SetNuiFocus(true, true)
			startAnim()
			isShowing = true
		else
			SendNUIMessage({
				type = "hideApp"
			})
			isShowing = false
		end
	end
end)

function populateVehicleName(vehicles)
    if vehicles then
        for _,v in ipairs(vehicles) do
            local name = GetDisplayNameFromVehicleModel(v.vehicle)
            if GetLabelText(name) ~= 'NULL' then
                name = GetLabelText(name)
            end
            v.model = name
        end
    end
end

RegisterNUICallback("civilianSearch", function(data, cb)
    BJCore.Functions.TriggerServerCallback("bj-mdt:civilianSearch", function(civilians)
        cb(json.encode(civilians))
    end, data)
end)

RegisterNUICallback("vehicleSearch", function(data, cb)
    BJCore.Functions.TriggerServerCallback("bj-mdt:vehicleSearch", function(vehicles)
        populateVehicleName(vehicles)
        cb(json.encode(vehicles))
    end, data)
end)

RegisterNUICallback("markerSearch", function(data, cb)
    BJCore.Functions.TriggerServerCallback("bj-mdt:markerSearch", function(markerData)
        cb(json.encode(markerData))
    end, data)
end)

RegisterNUICallback("civilianLoad", function(data, cb)
    BJCore.Functions.TriggerServerCallback("bj-mdt:civilianLoad", function(civilian)
        populateVehicleName(civilian.vehicles)
        cb(json.encode(civilian))
    end, data)
end)

RegisterNUICallback("recordLoad", function(data, cb)
    BJCore.Functions.TriggerServerCallback("bj-mdt:recordLoad", function(record)
        cb(json.encode(record))
    end, data)
end)

RegisterNUICallback("getCrimes", function(data, cb)
    BJCore.Functions.TriggerServerCallback("bj-mdt:getCrimes", function(crimes)
        cb(json.encode(crimes))
    end, data)
end)

RegisterNUICallback("addRecord", function(data, cb)
    BJCore.Functions.TriggerServerCallback("bj-mdt:addRecord", function()
        cb('OK')
    end, data)
end)

RegisterNUICallback("addPhoto", function(data, cb)
    BJCore.Functions.TriggerServerCallback("bj-mdt:addPhoto", function()
        cb('OK')
    end, data)
end)

RegisterNUICallback("addNote", function(data, cb)
    BJCore.Functions.TriggerServerCallback("bj-mdt:addNote", function()
        cb('OK')
    end, data)
end)

RegisterNUICallback("addMarker", function(data, cb)
    BJCore.Functions.TriggerServerCallback("bj-mdt:addMarker", function()
        cb('OK')
    end, data)
end)

RegisterNUICallback("addDigRef", function(data, cb)
    BJCore.Functions.TriggerServerCallback("bj-mdt:addDigRef", function()
        cb('OK')
    end, data)
end)

RegisterNUICallback("setMarkers", function(data, cb)
    BJCore.Functions.TriggerServerCallback("bj-mdt:setMarkers", function()
        cb('OK')
    end, data)
end)

RegisterNUICallback("getCharData", function(data, cb)
    local PlayerData = BJCore.Functions.GetPlayerData()
	if PlayerData then
        cb(json.encode({
            citizenid = PlayerData.citizenid,
            name = PlayerData.charinfo.firstname..' '..PlayerData.charinfo.lastname
        }))
    else
        cb()
    end
end)

RegisterNUICallback("doFineAndJail", function(data, cb)
    if data and data.serverid then
        if data.time and data.time > 0 then
            TriggerServerEvent('police:server:JailPlayer', tonumber(data.serverid), tonumber(data.time))
        end
        if data.fine and data.fine > 0 then
            TriggerServerEvent('police:server:BillPlayer', tonumber(data.serverid), tonumber(data.fine))
        end
    end
end)

RegisterNUICallback("closeUi", function(data, cb)
    isShowing = false
	stopAnim()
	DeleteObject(tab)
    SetNuiFocus(false, false)
end)

if SetNuiCloseCallback then
    SetNuiCloseCallback(function()
	    SendNUIMessage({
		    type = "hideApp"
	    })
    end)
end