Keys = {
    ['ESC'] = 322, ['F1'] = 288, ['F2'] = 289, ['F3'] = 170, ['F5'] = 166, ['F6'] = 167, ['F7'] = 168, ['F8'] = 169, ['F9'] = 56, ['F10'] = 57,
    ['~'] = 243, ['1'] = 157, ['2'] = 158, ['3'] = 160, ['4'] = 164, ['5'] = 165, ['6'] = 159, ['7'] = 161, ['8'] = 162, ['9'] = 163, ['-'] = 84, ['='] = 83, ['BACKSPACE'] = 177,
    ['TAB'] = 37, ['Q'] = 44, ['W'] = 32, ['E'] = 38, ['R'] = 45, ['T'] = 245, ['Y'] = 246, ['U'] = 303, ['P'] = 199, ['['] = 39, [']'] = 40, ['ENTER'] = 18,
    ['CAPS'] = 137, ['A'] = 34, ['S'] = 8, ['D'] = 9, ['F'] = 23, ['G'] = 47, ['H'] = 74, ['K'] = 311, ['L'] = 182,
    ['LEFTSHIFT'] = 21, ['Z'] = 20, ['X'] = 73, ['C'] = 26, ['V'] = 0, ['B'] = 29, ['N'] = 249, ['M'] = 244, [','] = 82, ['.'] = 81,
    ['LEFTCTRL'] = 36, ['LEFTALT'] = 19, ['SPACE'] = 22, ['RIGHTCTRL'] = 70,
    ['HOME'] = 213, ['PAGEUP'] = 10, ['PAGEDOWN'] = 11, ['DELETE'] = 178,
    ['LEFT'] = 174, ['RIGHT'] = 175, ['TOP'] = 27, ['DOWN'] = 173,
}

local inCityhallPage = false
local cityhall = {}

cityhall.Open = function()
    SendNUIMessage({
        action = "open",
        data = {
            currency = BJCore.Config.Currency.Symbol,
            licensePrices = Config.IdAndLicensePrice
        }
    })
    SetNuiFocus(true, true)
    inCityhallPage = true
end

cityhall.Close = function()
    SendNUIMessage({
        action = "close"
    })
    SetNuiFocus(false, false)
    inCityhallPage = false
end

RegisterNUICallback('close', function()
    SetNuiFocus(false, false)
    inCityhallPage = false
end)

local inRange = false
local creatingCompany = false
local currentName = nil
Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        inRange = false

        local distCity = GetDistanceBetweenCoords(pos, Config.Cityhall.coords.x, Config.Cityhall.coords.y, Config.Cityhall.coords.z, true)
        local distCityTest = GetDistanceBetweenCoords(pos, Config.DriverTest.coords.x, Config.DriverTest.coords.y, Config.DriverTest.coords.z, true)
        local distDriverSchool = GetDistanceBetweenCoords(pos, Config.DrivingSchool.coords.x, Config.DrivingSchool.coords.y, Config.DrivingSchool.coords.z, true)

        if distCity < 1.5 then
            inRange = true
            BJCore.Functions.DrawText3D(Config.Cityhall.coords.x, Config.Cityhall.coords.y, Config.Cityhall.coords.z, '[~g~E~w~] Cityhall', 0.7)
            if IsControlJustPressed(0, Keys["E"]) then
                cityhall.Open()
            end
        end
        if distCityTest < 1.5 then
            inRange = true
            if creatingCompany then
                BJCore.Functions.DrawText3D(Config.DriverTest.coords.x, Config.DriverTest.coords.y, Config.DriverTest.coords.z, '[~g~E~w~] Create company ('..BJCore.Config.Currency.Symbol..Config.CompanyPrice..') | [~r~G~w~] Cancel', 0.7)
                if IsControlJustPressed(0, Keys["E"]) then
                    TriggerServerEvent("companies:server:createCompany", currentName)
                    creatingCompany = false
                end
                if IsControlJustPressed(0, Keys["G"]) then
                    creatingCompany = false
                end
            else
                BJCore.Functions.DrawText3D(Config.DriverTest.coords.x, Config.DriverTest.coords.y, Config.DriverTest.coords.z, '[~g~E~w~] Request driving lessons', 0.7)
                if IsControlJustPressed(0, Keys["E"]) then
                    if BJCore.Functions.GetPlayerData().metadata["licences"]["driver"] then
                        BJCore.Functions.Notify("You already have your driving license, request it to your left")
                    else
                        TriggerServerEvent("cityhall:server:sendDriverTest")
                    end
                end

            
                --[[if IsControlJustPressed(0, Keys["G"]) then
                    BJCore.Functions.Notify("Voer een bedrijfsnaam in..", false, 10000)
                    DisplayOnscreenKeyboard(1, "Naam", "", "Naam", "", "", "", 128 + 1)
                    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
                        Citizen.Wait(7)
                    end
                    currentName = GetOnscreenKeyboardResult()
                    if currentName ~= nil and currentName ~= "" then
                        creatingCompany = true
                    end
                end]]--
            end
        end

        if distDriverSchool < 1.5 then
            inRange = true
            BJCore.Functions.DrawText3D(Config.DrivingSchool.coords.x, Config.DrivingSchool.coords.y, Config.DrivingSchool.coords.z, '[~g~E~w~] Request driving lessons', 0.7)
            if IsControlJustPressed(0, Keys["E"]) then
                if BJCore.Functions.GetPlayerData().metadata["licences"]["driver"] then
                    BJCore.Functions.Notify("You have already obtained your driving license, request it at the city hall!")
                else
                    TriggerServerEvent("cityhall:server:sendDriverTest")
                end
            end
        end

        if distCity > 10 and distCityTest > 10 and distDriverSchool > 10 then
            Citizen.Wait(2000)
        end

        Citizen.Wait(2)
    end
end)

RegisterNetEvent('cityhall:client:sendDriverEmail')
AddEventHandler('cityhall:client:sendDriverEmail', function(charinfo)
    print("test: "..BJCore.Common.Dump(charinfo))
    SetTimeout(math.random(2500, 4000), function()
        local gender = "Mr. "
        if BJCore.Functions.GetPlayerData().charinfo.gender == 1 then
            gender = "Mrs. "
        end
        --local charinfo = BJCore.Functions.GetPlayerData().charinfo
        TriggerServerEvent('phone:server:sendNewMail', {
            sender = "City hall",
            subject = "Request driving lessons",
            message = "Dear " .. gender .. BJCore.Functions.GetPlayerData().charinfo.lastname .. ",<br /><br />We have just received a message that someone wants to take driving lessons.<br />If you are willing to teach, please contact <br />Name: <strong>".. charinfo.firstname .. " " .. charinfo.lastname .. "</strong><br />Phone number: <strong>"..charinfo.phone.."</strong><br/><br/>Kind regards,<br />Cityhall Los Santos",
            button = {}
        })
    end)
end)

local idTypes = {
    ["id-card"] = {
        label = "ID-card",
        item = "id_card"
    },
    ["driverslicense"] = {
        label = "Driver License",
        item = "driver_license"
    }
}

RegisterNUICallback('requestId', function(data)
    if inRange then
        local idType = data.idType

        TriggerServerEvent('cityhall:server:requestId', idTypes[idType])
        BJCore.Functions.Notify('You requested your '..idTypes[idType].label..' for '..BJCore.Config.Currency.Symbol..Config.IdAndLicensePrice, 'success', 3500)
    else
        BJCore.Functions.Notify('Unfortunately it isnt working', 'error')
    end
end)

RegisterNUICallback('requestLicenses', function(data, cb)
    local PlayerData = BJCore.Functions.GetPlayerData()
    local licensesMeta = PlayerData.metadata["licences"]
    local availableLicenses = {}

    for type,_ in pairs(licensesMeta) do
        if licensesMeta[type] then
            local licenseType = nil
            local label = nil

            if type == "driver" then licenseType = "driverslicense" label = "Driver license" end

            table.insert(availableLicenses, {
                idType = licenseType,
                label = label
            })
        end
    end
    cb(availableLicenses)
end)

local AvailableJobs = {
    "trucker",
    "taxi",
    "tow",
    "reporter",
    "garbage",
}

function IsAvailableJob(job)
    local retval = false
    for k, v in pairs(AvailableJobs) do
        if v == job then
            retval = true
        end
    end
    return retval
end

RegisterNUICallback('applyJob', function(data)
    if inRange then
        if IsAvailableJob(data.job) then
            TriggerServerEvent('cityhall:server:ApplyJob', data.job)
        else
            TriggerServerEvent('cityhall:server:banPlayer')
            TriggerServerEvent("bj-log:server:CreateLog", "anticheat", "POST Request (Abuse)", "red", "** @everyone " ..GetPlayerName(player).. "** has been banned for abusing localhost:13172, sending POST request\'s")         
        end
    else
        BJCore.Functions.Notify('Unfortunately it isnt working...', 'error')
    end
end)

RegisterNetEvent("cityhall:client:showLawyerLicense")
AddEventHandler("cityhall:client:showLawyerLicense", function(sourcePos, data)
    local pos = GetEntityCoords(PlayerPedId(), false)
    if #(pos - sourcePos) < 2.0 then
        TriggerEvent('chat:addMessage', {
            template = '<div class="chat-message advert"><div class="chat-message-body"><strong>{0}:</strong><br><br> <strong>Pass-ID:</strong> {1} <br><strong>First Name:</strong> {2} <br><strong>Last Name:</strong> {3} <br><strong>BSN:</strong> {4} </div></div>',
            args = {'Lawyer License', data.id, data.firstname, data.lastname, data.citizenid}
        })
    end
end)