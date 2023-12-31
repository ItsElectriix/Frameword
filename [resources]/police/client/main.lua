Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, 
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177, 
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70, 
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
    ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

isLoggedIn = true

isHandcuffed = false
cuffType = 1
isEscorted = false
draggerId = 0
PlayerData = {}
PlayerJob = {}
onDuty = false

databankOpen = false

local DutyBlips, InfBlips = {}, {}

BJCore = nil
Citizen.CreateThread(function() 
    while BJCore == nil do
        TriggerEvent("BJCore:GetObject", function(obj) BJCore = obj end)
        Citizen.Wait(200)
    end
    SetCarItemsInfo()
    while not BJCore.Functions.IsPlayerLoaded() do Citizen.Wait(500); end
    PlayerData = BJCore.Functions.GetPlayerData()
    PlayerJob = PlayerData.job
    onDuty = PlayerJob.onduty
    isLoggedIn = true
    startInfBlipUpdate()
end)

RegisterNetEvent("BJCore:Player:SetPlayerData")
AddEventHandler("BJCore:Player:SetPlayerData", function(data)
    PlayerData = data
    if (PlayerJob ~= nil) and PlayerJob.name ~= "police" or not onDuty or not HasGPSItem() then
        if DutyBlips ~= nil then 
            for k, v in pairs(DutyBlips) do
                RemoveBlip(v)
            end
        end
        DutyBlips = {}
        if InfBlips ~= nil then
            for k, v in pairs(InfBlips) do
                RemoveBlip(v)
            end
        end
        InfBlips = {}
        TriggerServerEvent("police:server:UpdateBlips")
    end
    startInfBlipUpdate()
end)

RegisterNetEvent('BJCore:Client:OnJobUpdate')
AddEventHandler('BJCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
    onDuty = PlayerJob.onduty
    TriggerServerEvent("police:server:UpdateBlips")
    if JobInfo.name == "police" or JobInfo.name == "ambulance" then
        -- if PlayerJob.onduty then
        --     print("reset")
        --     TriggerServerEvent("BJCore:ToggleDuty")
        --     onDuty = false
        -- end
        startInfBlipUpdate()
    end

    if (PlayerJob ~= nil) and PlayerJob.name ~= "police" or not onDuty or not HasGPSItem() then
        if DutyBlips ~= nil then 
            for k, v in pairs(DutyBlips) do
                RemoveBlip(v)
            end
        end
        DutyBlips = {}
        if InfBlips ~= nil then
            for k, v in pairs(InfBlips) do
                RemoveBlip(v)
            end
        end
        InfBlips = {}
    end
end)

RegisterNetEvent('BJCore:Client:OnPlayerLoaded')
AddEventHandler('BJCore:Client:OnPlayerLoaded', function()
    isLoggedIn = true
    PlayerData = BJCore.Functions.GetPlayerData()
    PlayerJob = PlayerData.job
    onDuty = PlayerData.job.onduty
    local text = "**On Duty**"
    if not onDuty then text = "**Off Duty**"; end
    TriggerServerEvent("bj-log:server:CreateLog", PlayerData.job.name.."_duty", "Duty Alert", "green", "**"..PlayerData.charinfo.firstname.." "..PlayerData.charinfo.lastname.."** ("..PlayerData.citizenid..") has gone "..text.. " (Connected/Logged In)")
    isHandcuffed = false
    TriggerServerEvent("BJCore:Server:SetMetaData", "ishandcuffed", false)
    TriggerServerEvent("police:server:SetHandcuffStatus", false)
    TriggerServerEvent("police:server:UpdateBlips")
    TriggerServerEvent("police:server:UpdateCurrentCops")
    TriggerServerEvent("police:server:CheckBills")

    if BJCore.Functions.GetPlayerData().metadata["tracker"] then
        local trackerClothingData = {outfitData = {["accessory"] = { item = 13, texture = 0}}}
        TriggerEvent('bj-clothing:client:loadOutfit', trackerClothingData)
    else
        local trackerClothingData = {outfitData = {["accessory"]   = { item = -1, texture = 0}}}
        TriggerEvent('bj-clothing:client:loadOutfit', trackerClothingData)
    end

    if (PlayerJob ~= nil) and PlayerJob.name ~= "police" or not onDuty or not HasGPSItem() then
        if DutyBlips ~= nil then 
            for k, v in pairs(DutyBlips) do
                RemoveBlip(v)
            end
        end
        DutyBlips = {}
        if InfBlips ~= nil then
            for k, v in pairs(InfBlips) do
                RemoveBlip(v)
            end
        end
        InfBlips = {}
    end
    startInfBlipUpdate()
end)

RegisterNetEvent('police:client:sendBillingMail')
AddEventHandler('police:client:sendBillingMail', function(amount)
    SetTimeout(math.random(2500, 4000), function()
        local gender = "Mr."
        if BJCore.Functions.GetPlayerData().charinfo.gender == 1 then
            gender = "Mrs."
        end
        local charinfo = BJCore.Functions.GetPlayerData().charinfo
        TriggerServerEvent('phone:server:sendNewMail', {
            sender = "Central Judicial Collection Agency",
            subject = "Debt collection",
            message = "Dear " .. gender .. " " .. charinfo.lastname .. ",<br /><br />The Central Judicial Collection Agency (CJCA) charged the fines you received from the police.<br />There is <strong>€"..amount.."</strong> withdrawn from your account.<br /><br />Kind regards,<br />Mr. I.K. Graai",
            button = {}
        })
    end)
end)

local tabletProp = nil
RegisterNetEvent('police:client:toggleDatabank')
AddEventHandler('police:client:toggleDatabank', function()
    databankOpen = not databankOpen
    if databankOpen then
        RequestAnimDict("amb@code_human_in_bus_passenger_idles@female@tablet@base")
        while not HasAnimDictLoaded("amb@code_human_in_bus_passenger_idles@female@tablet@base") do
            Citizen.Wait(0)
        end
        local tabletModel = GetHashKey("prop_cs_tablet")
        local bone = GetPedBoneIndex(PlayerPedId(), 60309)
        RequestModel(tabletModel)
        while not HasModelLoaded(tabletModel) do
            Citizen.Wait(100)
        end
        tabletProp = CreateObject(tabletModel, 1.0, 1.0, 1.0, 1, 1, 0)
        AttachEntityToEntity(tabletProp, PlayerPedId(), bone, 0.03, 0.002, -0.0, 10.0, 160.0, 0.0, 1, 0, 0, 0, 2, 1)
        TaskPlayAnim(PlayerPedId(), "amb@code_human_in_bus_passenger_idles@female@tablet@base", "base", 3.0, 3.0, -1, 49, 0, 0, 0, 0)
        SetNuiFocus(true, true)
        SendNUIMessage({
            type = "databank",
        })
    else
        DetachEntity(tabletProp, true, true)
        DeleteObject(tabletProp)
        TaskPlayAnim(PlayerPedId(), "amb@code_human_in_bus_passenger_idles@female@tablet@base", "exit", 3.0, 3.0, -1, 49, 0, 0, 0, 0)
        SetNuiFocus(false, false)
        SendNUIMessage({
            type = "closedatabank",
        })
    end
end)


RegisterNUICallback("closeDatabank", function(data, cb)
    databankOpen = false
    DetachEntity(tabletProp, true, true)
    DeleteObject(tabletProp)
    SetNuiFocus(false, false)
    TaskPlayAnim(PlayerPedId(), "amb@code_human_in_bus_passenger_idles@female@tablet@base", "exit", 3.0, 3.0, -1, 49, 0, 0, 0, 0)
end)

RegisterNetEvent('BJCore:Client:OnPlayerUnload')
AddEventHandler('BJCore:Client:OnPlayerUnload', function()
    TriggerServerEvent('police:server:UpdateBlips')
    TriggerServerEvent("police:server:SetHandcuffStatus", false)
    TriggerServerEvent("police:server:UpdateCurrentCops")
    isLoggedIn = false
    isHandcuffed = false
    isEscorted = false
    onDuty = false
    ClearPedTasks(PlayerPedId())
    DetachEntity(PlayerPedId(), true, false)
    if DutyBlips ~= nil then 
        for k, v in pairs(DutyBlips) do
            RemoveBlip(v)
        end
        DutyBlips = {}
    end
    if InfBlips ~= nil then
        for k, v in pairs(InfBlips) do
            RemoveBlip(v)
        end
    end
    InfBlips = {}
end)

local infinityPlayers = {}
local jobInfoCache = {}

RegisterNetEvent('bj_infinity:player:coords')
AddEventHandler('bj_infinity:player:coords', function(infPlayers)
    infinityPlayers = infPlayers
end)

RegisterNetEvent('police:client:UpdateBlips')
AddEventHandler('police:client:UpdateBlips', function(players)
    if PlayerJob ~= nil and (PlayerJob.name == 'police' or PlayerJob.name == 'ambulance' or PlayerJob.name == 'doctor') and onDuty then
        if DutyBlips ~= nil then 
            for k, v in pairs(DutyBlips) do
                RemoveBlip(v)
            end
        end
        if InfBlips ~= nil then
            for k, v in pairs(InfBlips) do
                RemoveBlip(v)
            end
        end
        InfBlips = {}
        DutyBlips = {}
        jobInfoCache = {}
        if players ~= nil then
            for k, data in pairs(players) do
                jobInfoCache[data.source] = data
            end
        end
    end
end)

local blipLoopRunning = false

function startInfBlipUpdate()
    if not HasGPSItem() then return; end
    if not blipLoopRunning then 
        blipLoopRunning = true
        Citizen.CreateThread(function()
            local playerId = GetPlayerServerId(PlayerId())
            while (onDuty and HasGPSItem()) do
                for k,data in pairs(jobInfoCache) do
                    if k ~= playerId then
                        local id = GetPlayerFromServerId(data.source)
                        if id ~= -1 and NetworkIsPlayerActive(id) then
                            if InfBlips[data.source]then
                                RemoveBlip(InfBlips[data.source])
                                InfBlips[data.source] = nil
                            end
                            CreateDutyBlips(id, data.label, data.job)
                        elseif infinityPlayers[data.source] then
                            CreateInfinityDutyBlips(infinityPlayers[k].pos, data)
                        end
                    end
                end
                Wait(50)
            end
            blipLoopRunning = false
        end)
    end
end

function CreateInfinityDutyBlips(playerCoords, playerInfo)
    if InfBlips[playerInfo.source] then
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(playerInfo.label)
        EndTextCommandSetBlipName(InfBlips[playerInfo.source])
        SetBlipCoords(InfBlips[playerInfo.source], playerCoords.x, playerCoords.y, playerCoords.z)
    else
        local blip = AddBlipForCoord(playerCoords.x, playerCoords.y, playerCoords.z)
        SetBlipSprite(blip, 1)
        SetBlipScale(blip, 1.0)
        if playerInfo.job == "police" then
            SetBlipColour(blip, 38)
        else
            SetBlipColour(blip, 5)
        end
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(playerLabel)
        EndTextCommandSetBlipName(blip)
        
        InfBlips[playerInfo.source] = blip
    end
end

function CreateDutyBlips(playerId, playerLabel, playerJob)
    local ped = GetPlayerPed(playerId)
    local blip = GetBlipFromEntity(ped)
    if not DoesBlipExist(blip) then
        blip = AddBlipForEntity(ped)
        SetBlipSprite(blip, 1)
        ShowHeadingIndicatorOnBlip(blip, true)
        SetBlipRotation(blip, math.ceil(GetEntityHeading(ped)))
        SetBlipScale(blip, 1.0)
        if playerJob == "police" then
            SetBlipColour(blip, 38)
        else
            SetBlipColour(blip, 5)
        end
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(playerLabel)
        EndTextCommandSetBlipName(blip)
        
        table.insert(DutyBlips, blip)
    end
end

RegisterNetEvent('police:client:SendPoliceEmergencyAlert')
AddEventHandler('police:client:SendPoliceEmergencyAlert', function()
    local pos = GetEntityCoords(PlayerPedId())
    local s1, s2 = Citizen.InvokeNative(0x2EB41072B4C1E4C0, pos.x, pos.y, pos.z, Citizen.PointerValueInt(), Citizen.PointerValueInt())
    local street1 = GetStreetNameFromHashKey(s1)
    local street2 = GetStreetNameFromHashKey(s2)
    local streetLabel = street1
    if street2 ~= nil then 
        streetLabel = streetLabel .. " " .. street2
    end
    local alertTitle = "Police"
    if PlayerJob.name == "ambulance" or PlayerJob.name == "doctor" then
        alertTitle = "EMS"
    end

    local MyId = GetPlayerServerId(PlayerId())

    print("job: "..PlayerJob.name)
    if PlayerJob.name == "ambulance" or PlayerJob.name == "doctor" then
        TriggerServerEvent("police:server:SendPoliceEmergencyAlert", streetLabel, pos, false)
        TriggerServerEvent('MF_Trackables:Notify',"EMS is requiring assistance", pos,'police','emspanic')
        TriggerServerEvent('MF_Trackables:Notify',"EMS is requiring assistance", pos,'ambulance','emspanic')
    else
        TriggerServerEvent("police:server:SendPoliceEmergencyAlert", streetLabel, pos, BJCore.Functions.GetPlayerData().metadata["callsign"])
        TriggerServerEvent('MF_Trackables:Notify',BJCore.Functions.GetPlayerData().metadata["callsign"].." is requiring assistance", pos,'police','assistance')
    end
    -- TriggerServerEvent('policealerts:server:AddPoliceAlert', {
    --     timeOut = 10000,
    --     alertTitle = alertTitle,
    --     coords = {
    --         x = pos.x,
    --         y = pos.y,
    --         z = pos.z,
    --     },
    --     details = {
    --         [1] = {
    --             icon = '<i class="fas fa-passport"></i>',
    --             detail = MyId .. ' | ' .. BJCore.Functions.GetPlayerData().charinfo.firstname .. ' ' .. BJCore.Functions.GetPlayerData().charinfo.lastname,
    --         },
    --         [2] = {
    --             icon = '<i class="fas fa-globe-europe"></i>',
    --             detail = streetLabel,
    --         },
    --     },
    --     callSign = BJCore.Functions.GetPlayerData().metadata["callsign"],
    -- }, true)
end)

RegisterNetEvent('police:PlaySound')
AddEventHandler('police:PlaySound', function()
    PlaySound(-1, "Lose_1st", "GTAO_FM_Events_Soundset", 0, 0, 1)
end)

RegisterNetEvent('police:client:PoliceEmergencyAlert')
AddEventHandler('police:client:PoliceEmergencyAlert', function(callsign, streetLabel, coords)
    if (PlayerJob.name == 'police' or PlayerJob.name == 'ambulance' or PlayerJob.name == 'doctor') and onDuty then
        local transG = 250
        local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(blip, 487)
        SetBlipColour(blip, 4)
        SetBlipDisplay(blip, 4)
        SetBlipAlpha(blip, transG)
        SetBlipScale(blip, 1.2)
        SetBlipFlashes(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString("10-13 | Callsign: "..callsign)
        EndTextCommandSetBlipName(blip)
        while transG ~= 0 do
            Wait(180 * 4)
            transG = transG - 1
            SetBlipAlpha(blip, transG)
            if transG == 0 then
                SetBlipSprite(blip, 2)
                RemoveBlip(blip)
                return
            end
        end
    end
end)

RegisterNetEvent('police:client:GunShotAlert')
AddEventHandler('police:client:GunShotAlert', function(streetLabel, isAutomatic, fromVehicle, coords, vehicleInfo)
    if PlayerJob.name == 'police' and onDuty then        
        local msg = ""
        local blipSprite = 313
        local blipText = "Shots fired"
        local MessageDetails = {}
        if fromVehicle then
            blipText = "Shots fired from a vehicle"
            MessageDetails = {
                [1] = {
                    icon = '<i class="fas fa-car"></i>',
                    detail = vehicleInfo.name,
                },
                [2] = {
                    icon = '<i class="fas fa-closed-captioning"></i>',
                    detail = vehicleInfo.plate,
                },
                [3] = {
                    icon = '<i class="fas fa-globe-europe"></i>',
                    detail = streetLabel,
                },
            }
        else
            blipText = "Shots fired"
            MessageDetails = {
                [1] = {
                    icon = '<i class="fas fa-globe-europe"></i>',
                    detail = streetLabel,
                },
            }
        end

        TriggerEvent('qb-policealerts:client:AddPoliceAlert', {
            timeOut = 4000,
            alertTitle = blipText,
            coords = {
                x = coords.x,
                y = coords.y,
                z = coords.z,
            },
            details = MessageDetails,
            callSign = BJCore.Functions.GetPlayerData().metadata["callsign"],
        })

        PlaySound(-1, "Lose_1st", "GTAO_FM_Events_Soundset", 0, 0, 1)
        local transG = 250
        local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(blip, blipSprite)
        SetBlipColour(blip, 0)
        SetBlipDisplay(blip, 4)
        SetBlipAlpha(blip, transG)
        SetBlipScale(blip, 0.8)
        SetBlipAsShortRange(blip, false)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(blipText)
        EndTextCommandSetBlipName(blip)
        while transG ~= 0 do
            Wait(180 * 4)
            transG = transG - 1
            SetBlipAlpha(blip, transG)
            if transG == 0 then
                SetBlipSprite(blip, 2)
                RemoveBlip(blip)
                return
            end
        end
    end
end)

RegisterNetEvent('police:client:VehicleCall')
AddEventHandler('police:client:VehicleCall', function(pos, alertTitle, streetLabel, modelPlate, modelName)
    if PlayerJob.name == 'police' and onDuty then
        TriggerEvent('qb-policealerts:client:AddPoliceAlert', {
            timeOut = 4000,
            alertTitle = alertTitle,
            coords = {
                x = pos.x,
                y = pos.y,
                z = pos.z,
            },
            details = {
                [1] = {
                    icon = '<i class="fas fa-car"></i>',
                    detail = modelName,
                },
                [2] = {
                    icon = '<i class="fas fa-closed-captioning"></i>',
                    detail = modelPlate,
                },
                [3] = {
                    icon = '<i class="fas fa-globe-europe"></i>',
                    detail = streetLabel,
                },
            },
            callSign = BJCore.Functions.GetPlayerData().metadata["callsign"],
        })
        PlaySound(-1, "Lose_1st", "GTAO_FM_Events_Soundset", 0, 0, 1)
        local transG = 250
        local blip = AddBlipForCoord(pos.x, pos.y, pos.z)
        SetBlipSprite(blip, 380)
        SetBlipColour(blip, 1)
        SetBlipDisplay(blip, 4)
        SetBlipAlpha(blip, transG)
        SetBlipScale(blip, 1.0)
        SetBlipAsShortRange(blip, false)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString("Alert: Vehicle burglary")
        EndTextCommandSetBlipName(blip)
        while transG ~= 0 do
            Wait(180 * 4)
            transG = transG - 1
            SetBlipAlpha(blip, transG)
            if transG == 0 then
                SetBlipSprite(blip, 2)
                RemoveBlip(blip)
                return
            end
        end
    end
end)

RegisterNetEvent('police:client:HouseRobberyCall')
AddEventHandler('police:client:HouseRobberyCall', function(coords, msg, gender, streetLabel)
    if PlayerJob.name == 'police' and onDuty then
        TriggerEvent('qb-policealerts:client:AddPoliceAlert', {
            timeOut = 5000,
            alertTitle = "Burglary attempt",
            coords = {
                x = coords.x,
                y = coords.y,
                z = coords.z,
            },
            details = {
                [1] = {
                    icon = '<i class="fas fa-venus-mars"></i>',
                    detail = gender,
                },
                [2] = {
                    icon = '<i class="fas fa-globe-europe"></i>',
                    detail = streetLabel,
                },
            },
            callSign = BJCore.Functions.GetPlayerData().metadata["callsign"],
        })

        PlaySound(-1, "Lose_1st", "GTAO_FM_Events_Soundset", 0, 0, 1)
        local transG = 250
        local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(blip, 411)
        SetBlipColour(blip, 1)
        SetBlipDisplay(blip, 4)
        SetBlipAlpha(blip, transG)
        SetBlipScale(blip, 0.7)
        SetBlipAsShortRange(blip, false)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString("Alert: Burglary house")
        EndTextCommandSetBlipName(blip)
        while transG ~= 0 do
            Wait(180 * 4)
            transG = transG - 1
            SetBlipAlpha(blip, transG)
            if transG == 0 then
                SetBlipSprite(blip, 2)
                RemoveBlip(blip)
                return
            end
        end
    end
end)

RegisterNetEvent('112:client:SendPoliceAlert')
AddEventHandler('112:client:SendPoliceAlert', function(notifyType, data, blipSettings)
    if PlayerJob.name == 'police' and onDuty then
        -- if notifyType == "flagged" then
        --     TriggerEvent('qb-policealerts:client:AddPoliceAlert', {
        --         timeOut = 5000,
        --         alertTitle = "Burglary attempt",
        --         details = {
        --             [1] = {
        --                 icon = '<i class="fas fa-video"></i>',
        --                 detail = data.camId,
        --             },
        --             [2] = {
        --                 icon = '<i class="fas fa-closed-captioning"></i>',
        --                 detail = data.plate,
        --             },
        --             [3] = {
        --                 icon = '<i class="fas fa-globe-europe"></i>',
        --                 detail = data.streetLabel,
        --             },
        --         },
        --         callSign = BJCore.Functions.GetPlayerData().metadata["callsign"],
        --     })
        --     RadarSound()
        -- end
    
        if blipSettings ~= nil then
            local transG = 250
            local blip = AddBlipForCoord(blipSettings.x, blipSettings.y, blipSettings.z)
            SetBlipSprite(blip, blipSettings.sprite)
            SetBlipColour(blip, blipSettings.color)
            SetBlipDisplay(blip, 4)
            SetBlipAlpha(blip, transG)
            SetBlipScale(blip, blipSettings.scale)
            SetBlipAsShortRange(blip, false)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(blipSettings.text)
            EndTextCommandSetBlipName(blip)
            while transG ~= 0 do
                Wait(180 * 4)
                transG = transG - 1
                SetBlipAlpha(blip, transG)
                if transG == 0 then
                    SetBlipSprite(blip, 2)
                    RemoveBlip(blip)
                    return
                end
            end
        end
    end
end)

RegisterNetEvent('police:client:PoliceAlertMessage')
AddEventHandler('police:client:PoliceAlertMessage', function(title, streetLabel, coords)
    if PlayerJob.name == 'police' and onDuty then
        TriggerEvent('qb-policealerts:client:AddPoliceAlert', {
            timeOut = 5000,
            alertTitle = title,
            details = {
                [1] = {
                    icon = '<i class="fas fa-globe-europe"></i>',
                    detail = streetLabel,
                },
            },
            callSign = BJCore.Functions.GetPlayerData().metadata["callsign"],
        })

        PlaySound(-1, "Lose_1st", "GTAO_FM_Events_Soundset", 0, 0, 1)
        local transG = 100
        local blip = AddBlipForRadius(coords.x, coords.y, coords.z, 100.0)
        SetBlipSprite(blip, 9)
        SetBlipColour(blip, 1)
        SetBlipAlpha(blip, transG)
        SetBlipAsShortRange(blip, false)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString("911 - "..title)
        EndTextCommandSetBlipName(blip)
        while transG ~= 0 do
            Wait(180 * 4)
            transG = transG - 1
            SetBlipAlpha(blip, transG)
            if transG == 0 then
                SetBlipSprite(blip, 2)
                RemoveBlip(blip)
                return
            end
        end
    end
end)

RegisterNetEvent('police:server:SendEmergencyMessageCheck')
AddEventHandler('police:server:SendEmergencyMessageCheck', function(nameInfo, message, coords)
    local PlayerData = BJCore.Functions.GetPlayerData()
    if ((PlayerData.job.name == "police" or PlayerData.job.name == "ambulance" or PlayerData.job.name == "doctor") and onDuty) then
        TriggerEvent('chatMessage', "911 ALERT - " .. nameInfo, "warning", message)
        TriggerEvent("police:client:EmergencySound")
        local transG = 250
        local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(blip, 280)
        SetBlipColour(blip, 4)
        SetBlipDisplay(blip, 4)
        SetBlipAlpha(blip, transG)
        SetBlipScale(blip, 0.9)
        SetBlipAsShortRange(blip, false)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString("911 alert")
        EndTextCommandSetBlipName(blip)
        while transG ~= 0 do
            Wait(180 * 4)
            transG = transG - 1
            SetBlipAlpha(blip, transG)
            if transG == 0 then
                SetBlipSprite(blip, 2)
                RemoveBlip(blip)
                return
            end
        end
    end
end)

RegisterNetEvent('police:server:Send311Check')
AddEventHandler('police:server:Send311Check', function(nameInfo, message, coords)
    local PlayerData = BJCore.Functions.GetPlayerData()
    if ((PlayerData.job.name == "police" or PlayerData.job.name == "ambulance" or PlayerData.job.name == "doctor") and onDuty) then
        TriggerEvent('chatMessage', "311 Message - " .. nameInfo, "warning", message)
        --TriggerEvent("police:client:EmergencySound")
    end
end)

RegisterNetEvent('police:client:Send112AMessage')
AddEventHandler('police:client:Send112AMessage', function(message)
    local PlayerData = BJCore.Functions.GetPlayerData()
    if ((PlayerData.job.name == "police" or PlayerData.job.name == "ambulance") and onDuty) then
        TriggerEvent('chatMessage', "ANONYMOUS 911 REPORT", "warning", message)
        TriggerEvent("police:client:EmergencySound")
    end
end)

RegisterNetEvent('police:client:Send311AMessage')
AddEventHandler('police:client:Send311AMessage', function(message)
    local PlayerData = BJCore.Functions.GetPlayerData()
    if ((PlayerData.job.name == "police" or PlayerData.job.name == "ambulance") and onDuty) then
        TriggerEvent('chatMessage', "ANONYMOUS 311 MESSAGE", "warning", message)
    end
end)

RegisterNetEvent('police:client:Send911Reply')
AddEventHandler('police:client:Send911Reply', function(prefix, message)
    local PlayerData = BJCore.Functions.GetPlayerData()
    if ((PlayerData.job.name == "police" or PlayerData.job.name == "ambulance") and onDuty) then
        TriggerEvent('chatMessage', "911 REPLY - "..prefix, "warning", message)
        TriggerEvent("police:client:EmergencySound")
    end
end)

RegisterNetEvent('police:client:Send311Reply')
AddEventHandler('police:client:Send311Reply', function(prefix, message)
    local PlayerData = BJCore.Functions.GetPlayerData()
    if ((PlayerData.job.name == "police" or PlayerData.job.name == "ambulance") and onDuty) then
        TriggerEvent('chatMessage', "311 REPLY - "..prefix, "warning", message)
    end
end)

RegisterNetEvent('police:client:SendToJail')
AddEventHandler('police:client:SendToJail', function(time)
    TriggerServerEvent("police:server:SetHandcuffStatus", false)
    isHandcuffed = false
    isEscorted = false
    ClearPedTasks(PlayerPedId())
    DetachEntity(PlayerPedId(), true, false)
    TriggerEvent("prison:client:Enter", time)
    TriggerEvent("radio:onRadioDrop")
end)

function RadarSound()
    PlaySoundFrontend( -1, "Beep_Green", "DLC_HEIST_HACKING_SNAKE_SOUNDS", 1 )
    Citizen.Wait(100)
    PlaySoundFrontend( -1, "Beep_Red", "DLC_HEIST_HACKING_SNAKE_SOUNDS", 1 )
    Citizen.Wait(100)
    PlaySoundFrontend( -1, "Beep_Green", "DLC_HEIST_HACKING_SNAKE_SOUNDS", 1 )
    Citizen.Wait(100)
    PlaySoundFrontend( -1, "Beep_Red", "DLC_HEIST_HACKING_SNAKE_SOUNDS", 1 )
    Citizen.Wait(100)   
end

function GetClosestPlayer()
    local closestPlayers = BJCore.Functions.GetPlayersFromCoords()
    local closestDistance = -1
    local closestPlayer = -1
    local coords = GetEntityCoords(PlayerPedId())

    for i=1, #closestPlayers, 1 do
        if closestPlayers[i] ~= PlayerId() then
            local pos = GetEntityCoords(GetPlayerPed(closestPlayers[i]))
            local distance = #(pos - coords)

            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = closestPlayers[i]
                closestDistance = distance
            end
        end
    end

    return closestPlayer, closestDistance
end

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(10)
    end
end

function HasGPSItem()
    local ret = false
    for k,v in pairs(PlayerData.items) do
        if v.name == Config.GPSItem then
            ret = true
            break
        end
    end
    return ret
end
