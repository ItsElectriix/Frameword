local PlayerData = {}
local ApartmentKeys = {}
local inside, viewing, raiding = false, false, false
local entryStopped = false
function entryUpdate()
    while not BJCore.Functions.IsPlayerLoaded() do Citizen.Wait(1000); end
    entryStopped = false
    while not inside do
        local plyPed = PlayerPedId()
        local plyPos = GetEntityCoords(plyPed)
        local closestKey, closestVal, closestDist = getClosestAction(plyPos, Config.Buildings, "entry")
        local isNear = false
        if closestDist < 50 then
            isNear = true
            if closestDist < 2 then
                BJCore.Functions.DrawText3D(closestVal.entry.x, closestVal.entry.y, closestVal.entry.z+0.3, "~b~"..closestVal.label, 0.7)
                BJCore.Functions.DrawText3D(closestVal.entry.x, closestVal.entry.y, closestVal.entry.z+0.2, "[~g~E~w~] Options", 0.7)
                if BJCore.Functions.GetKeyPressed("E") then
                    inOptionsMenu = true
                    OptionsMenu(closestKey)
                    Menu.hidden = not Menu.hidden
                end
                if IsControlJustPressed(1, 177) and not Menu.hidden then
                    closeMenuFull()
                    PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                end
                if inOptionsMenu then
                    Menu.renderGUI()
                end
            end
            SetParkedVehicleDensityMultiplierThisFrame(0)
        end
        if not isNear then Citizen.Wait(1000); end
        Citizen.Wait(0)
    end
    entryStopped = true
end

function enterBuilding(building, id, raid, new)
    TriggerEvent("BJCore:Player:UpdatePlayerPosition")
    TriggerEvent("bj-core:client:pauseLastPos", true)
    closeMenuFull()
    TriggerEvent('dooranim')
    inside, insideId, raiding = building, id, raid and raid or false
    if viewing then
        local carryObject = exports["inventory"]:GetCarryingObject()
        if carryObject ~= nil then carryObject = NetworkGetNetworkIdFromEntity(carryObject); end
        TriggerServerEvent("apartments:server:HandleBucket", true, building, viewing, carryObject)
        BJCore.Functions.PersistentNotify("start", "viewAp", "Currently viewing: "..Config.Buildings[inside].label.." | Price: "..BJCore.Config.Currency.Symbol..Config.Buildings[inside].price.. " fortnightly", "primary")
    else
        local carryObject = exports["inventory"]:GetCarryingObject()
        if carryObject ~= nil then carryObject = NetworkGetNetworkIdFromEntity(carryObject); end
        TriggerServerEvent("apartments:server:HandleBucket", true, building, id, carryObject)
    end
    -- SetPedPopulationBudget(0)
    -- SetVehiclePopulationBudget(0)
    TriggerEvent('InteractSound_CL:PlayOnOne', 'houses_door_open', 0.5)
    StartPlayerTeleport(PlayerId(), Config.Buildings[inside].insidePos.entry, 0.0)
    while IsPlayerTeleportActive() do Citizen.Wait(1); end
    if Config.Buildings[inside].doorModel then
        local doorObj = GetClosestObjectOfType(Config.Buildings[inside].doorPos.xyz, 1.0, Config.Buildings[inside].doorModel, 0, 0, 0)
        FreezeEntityPosition(doorObj, true)
        SetEntityHeading(doorObj, Config.Buildings[inside].doorPos.w)
    end
    if id == PlayerData.citizenid then TriggerEvent("inApartment", true); end
    if IsScreenFadedOut() then DoScreenFadeIn(500); end
    if new then
        TriggerEvent("bj-clothing:client:CreateFirstCharacter")
    end
    insideUpdate(Config.Buildings[inside])
end

function insideUpdate(data)
    while inside do
        local plyPed = PlayerPedId()
        local plyPos = GetEntityCoords(plyPed)
        local closestKey, closestVal, closestDist = getClosestAction(plyPos, data.insidePos, "action")
        local isNear = false
        if closestDist < 10 then
            isNear = true
            if closestDist < 2 then
                if (closestKey ~= "entry" and (hasKey(inside, insideId) or raiding)) and not viewing then
                    BJCore.Functions.DrawText3D(closestVal.x, closestVal.y, closestVal.z, Config.ActionText[closestKey], 0.7)
                    if BJCore.Functions.GetKeyPressed("E") then
                        handleAction(closestKey)
                    end
                elseif closestKey == "entry" then
                    BJCore.Functions.DrawText3D(closestVal.x, closestVal.y, closestVal.z, Config.ActionText[closestKey], 0.7)
                    if BJCore.Functions.GetKeyPressed("E") then
                        handleAction(closestKey)
                    end
                end
            end
        end
        if viewing then
            if GetGameTimer() - viewing >= Config.ViewingTime * 60 * 1000 then
               viewing = false
               handleAction("entry")
            end
        end
        -- SetParkedVehicleDensityMultiplierThisFrame(0)
        -- SetAmbientVehicleRangeMultiplierThisFrame(0)
        -- SetRandomVehicleDensityMultiplierThisFrame(0)
        -- SetVehicleDensityMultiplierThisFrame(0)
        -- SetPedDensityMultiplierThisFrame(0)
        if not isNear then Citizen.Wait(1000); end
        if not inside then return; end
        Citizen.Wait(0)
    end
end

function handleAction(action)
    if action == "entry" then
        closeMenuFull()
        TriggerEvent('dooranim')
        BJCore.Functions.PersistentNotify("end", "viewAp")
        local carryObject = exports["inventory"]:GetCarryingObject()
        if carryObject ~= nil then carryObject = NetworkGetNetworkIdFromEntity(carryObject); end
        TriggerServerEvent("apartments:server:HandleBucket", false, nil, nil, carryObject)
        TriggerEvent('InteractSound_CL:PlayOnOne', 'houses_door_close', 0.5)
        StartPlayerTeleport(PlayerId(), Config.Buildings[inside].entry, 0.0)
        TriggerEvent("inApartment", false)
        -- SetPedPopulationBudget(0.7)
        -- SetVehiclePopulationBudget(0.7)
        inside, insideId, viewing, raiding = false, false, false, false
        TriggerEvent("bj-core:client:pauseLastPos", false)
        if entryStopped then entryUpdate(); end
    elseif action == "stash" then
        TriggerEvent('InteractSound_CL:PlayOnOne', 'StashOpen', 0.8)
        TriggerServerEvent("inventory:server:OpenInventory", "stash", Config.Buildings[inside].name.."_"..insideId, nil, "Stash: "..Config.Buildings[inside].label.."-"..insideId)
        TriggerEvent("inventory:client:SetCurrentStash", Config.Buildings[inside].name.."_"..insideId)
    elseif action == "outfits" then
        TriggerEvent('InteractSound_CL:PlayOnOne', 'Stash', 0.6)
        TriggerEvent('bj-clothing:client:openOutfitMenu')
    elseif action == "logout" then
        DoScreenFadeOut(1500)
        Wait(1500)
        local carryObject = exports["inventory"]:GetCarryingObject()
        if carryObject ~= nil then carryObject = NetworkGetNetworkIdFromEntity(carryObject); end
        TriggerServerEvent("apartments:server:HandleBucket", false, nil, nil, carryObject)
        SetEntityAlpha(PlayerPedId(), 0, false)
        StartPlayerTeleport(PlayerId(), Config.Buildings[inside].entry, 0.0)
        inside = false
        TriggerEvent("BJCore:Player:UpdatePlayerPosition")
        TriggerServerEvent('bj-core:multichar:server:logout')
    end
end

function getClosestAction(plyPos, data, type)
    local closestKey,closestVal,closestDist
    for k,v in pairs(data) do
        local dist = 0
        if type == "action" then
            dist = #(plyPos - v.xyz)
        else
            dist = #(plyPos - v.entry.xyz)
        end
        if not closestDist or dist < closestDist then
            closestKey = k
            closestVal = v
            closestDist = dist
        end
    end
    if not closestDist then return false,false,999999
    else return closestKey,closestVal,closestDist
    end
end

function OptionsMenu(building)
    ped = PlayerPedId()
    MenuTitle = "Options"
    TriggerEvent("police:client:pauseKeybind", true)
    ClearMenu()
    Menu.selection = 1
    local text = "Apartment"
    if Config.Buildings[building].isOffice then text = "Office"; end
    Menu.addButton(Config.Buildings[building].label, "yeet", Config.Buildings[building].label, "", "", "BuildingName")
    if (PlayerData.office ~= nil and PlayerData.office == Config.Buildings[building].name) or (PlayerData.apartment ~= nil and PlayerData.apartment == Config.Buildings[building].name) or (PlayerData.freeApartment ~= nil and PlayerData.freeApartment == Config.Buildings[building].name) then
        Menu.addButton("Enter "..text, "enterBuilding", building, PlayerData.citizenid)
        if not Config.Buildings[building].isFree then
            Menu.addButton("Renew Lease", "renewLease", building)
        end
    else
        if not Config.Buildings[building].isFree then
            Menu.addButton("View "..text, "viewBuilding", building, PlayerData.citizenid)
            Menu.addButton("Lease "..text, "leaseBuilding", building)
        end
    end
    Menu.addButton("", "yeet", nil, nil, nil, "spacer")
    local curApt = ApartmentKeys[Config.Buildings[building].name]
    if curApt ~= nil then
        for k,v in pairs(curApt) do
            if v then
                Menu.addButton("Enter "..text.." #"..k, "enterBuilding", building, curApt[k])
            end
        end
    end
    Menu.addButton(text.."s", "getApartments", building, text, false)
    if PlayerData.job.name == "police" and PlayerData.job.onduty then
        Menu.addButton("Raid "..text.."s", "getApartments", building, text, true)
    end
    Menu.addButton("Close Menu", "closeMenuFull", nil)
end

function getApartments(building, text, raid)
    BJCore.Functions.TriggerServerCallback("apartments:server:getList", function(result)
        MenuTitle = "Apartment List"
        ClearMenu()
        Menu.selection = 1
        Menu.addButton(Config.Buildings[building].label, "yeet", Config.Buildings[building].label, "", "", "BuildingName")
        if result == nil then
            --BJCore.Functions.Notify("There are no active leases", "error", 5000)
        else
            if raid then
                for k, v in pairs(result) do
                    Menu.addButton("Enter "..text.." #"..v.id, "enterBuilding", building, v.citizenid, raid)
                end
            else
                for k, v in pairs(result) do
                    if v.citizenid ~= PlayerData.citizenid then
                        Menu.addButton("Ring "..text.." #"..v.id, "ringDoor", v.building, v.citizenid, raid)
                    end
                end
            end
        end
        Menu.addButton("Back", "OptionsMenu", building)
    end, building)
end

function ringDoor(building, id)
    closeMenuFull()
    BJCore.Functions.Notify("You have rung the door bell")
    TriggerServerEvent("apartments:server:ringDoor", building, id)
end

function renewLease(building)
    TriggerServerEvent("apartments:server:renewApartment", building)
end

local curLeasing = nil
function leaseBuilding(building)
    local proceed = true
    if Config.Buildings[building].isOffice and PlayerData.office ~= nil then print("found office") proceed = false; end
    if PlayerData.apartment ~= nil then print("found apartment") proceed = false; end
    if proceed then
        curLeasing = building
        BJCore.Functions.PersistentNotify("start", "apartlease", "<u><b>"..Config.Buildings[building].label.."</b></u><br><br> Pending Lease <br><b>Price:</b> "..BJCore.Config.Currency.Symbol..""..Config.Buildings[building].price.." fortnightly<br><br> /lease [accept/decline]", "success", { ['background-color'] = '#ff8800', ['color'] = '#ffffff' })
        Wait(10000)
        BJCore.Functions.PersistentNotify("end", "apartlease")
    else
        BJCore.Functions.Notify("You can only lease 1 apartment and 1 office", "error")
    end
end

RegisterCommand("lease", function(s,a,r)
    if a[1] == nil then return; end
    if a[1] == "decline" then curLeasing = nil BJCore.Functions.PersistentNotify("end", "apartlease") return; end
    if a[1] == "accept" then
        BJCore.Functions.PersistentNotify("end", "apartlease")
        BJCore.Functions.TriggerServerCallback("apartments:server:leaseApartment", function(id)
            if id then
                if Config.Buildings[id].isOffice then
                    PlayerData.office = Config.Buildings[id].name
                else
                    PlayerData.apartment = Config.Buildings[id].name
                end
                OptionsMenu(id)
            end
        end, curLeasing)
    end
end)

function viewBuilding(building)
    closeMenuFull()
    viewing = GetGameTimer()
    insideId = PlayerData.citizenid
    enterBuilding(building)
end

function optionMenu(citizenData)
    ped = PlayerPedId()
    MenuTitle = "Select Option:"
    ClearMenu()
    Menu.addButton("Remove Key", "removeHouseKey", citizenData)
    Menu.addButton("Back", "HouseKeysMenu",nil)
end

local lastRing = 0, 
RegisterNetEvent("apartments:client:receiveRing")
AddEventHandler("apartments:client:receiveRing", function(target, building, id)
    if not inside then return; end
    if inside == building and insideId == id then
        lastRing = target
        BJCore.Functions.Notify("Player ID: "..target.." has rung the door bell. Use /ringaccept to let them in", "primary", 7000)
        Wait(10000)
        lastRing = 0
    end
end)

RegisterCommand("ringaccept", function(s,a,r)
    if lastRing == 0 then return; end
    TriggerServerEvent("apartments:server:acceptRing", lastRing, inside, insideId)
end)

RegisterNetEvent("apartments:client:acceptedRing")
AddEventHandler("apartments:client:acceptedRing", function(building, owner)
    if inside then return; end
    enterBuilding(building, owner)
end)

AddEventHandler("apartments:client:manageKeys", function()
    AptsKeysMenu()
end)

RegisterNetEvent('apartments:client:giveAptKey')
AddEventHandler('apartments:client:giveAptKey', function(data)
    local player, distance = GetClosestPlayer()
    if player ~= -1 and distance < 2.5 then
        local playerId = GetPlayerServerId(player)
        TriggerServerEvent('apartments:server:giveAptKey', playerId, inside, insideId)
    else
        BJCore.Functions.Notify("Target not found. Try again?", "error")
    end
end)

function AptsMenuTick()
    Citizen.CreateThread(function()
        while inHoldersMenu do
            Citizen.Wait(1)
            Menu.renderGUI()
        end
    end)
end

function AptsKeysMenu()
    MenuTitle = "Key Management"
    ClearMenu()
    BJCore.Functions.TriggerServerCallback('apartments:server:getKeyHolders', function(holders)
        MenuTitle = "Key Holders:"
        ClearMenu()
        Menu.selection = 1
        Menu.addButton("Keys: "..Config.Buildings[inside].label, "yeet", Config.Buildings[inside].label, "", "", "BuildingName")
        if holders == nil or next(holders) == nil then
            BJCore.Functions.Notify("No key holders found", "error", 3500)
            --closeMenuFull()
        else
            TriggerEvent("police:client:pauseKeybind", true)
            for k, v in pairs(holders) do
                Menu.addButton(holders[k].firstname .. " " .. holders[k].lastname, "keyOptionMenu", holders[k])
            end
            inHoldersMenu = true
            Menu.hidden = not Menu.hidden
            AptsMenuTick()
        end
        Menu.addButton("Close Menu", "closeMenuFull", nil)
    end, inside, insideId)
end

function keyOptionMenu(citizenData)
    ped = PlayerPedId()
    MenuTitle = "Select Option:"
    ClearMenu()
    Menu.addButton("Remove Key", "removeHouseKey", citizenData)
    Menu.addButton("Back", "AptsKeysMenu", nil)
end

function removeHouseKey(citizenData)
    TriggerServerEvent('apartments:server:removeKey', inside, insideId, citizenData)
    closeMenuFull()
end

function hasKey(building, id)
    local ret = false
    if id == PlayerData.citizenid then
        ret = true
    else
        if ApartmentKeys[Config.Buildings[building].name] ~= nil then
            for k,v in pairs(ApartmentKeys[Config.Buildings[building].name]) do
                if v and v == id then
                    ret = true
                    break
                end
            end
        end
    end
    return ret
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

Citizen.CreateThread(function() entryUpdate(); end)

RegisterNetEvent('BJCore:Client:OnPlayerUnload')
AddEventHandler('BJCore:Client:OnPlayerUnload', function()
    PlayerData = {}
end)

RegisterNetEvent('BJCore:Client:OnPlayerLoaded')
AddEventHandler('BJCore:Client:OnPlayerLoaded', function()
    PlayerData = BJCore.Functions.GetPlayerData()
    BJCore.Functions.TriggerServerCallback("apartments:server:GetOwned", function(buildings)
        for k,v in pairs(buildings) do
            if v.isOffice == 1 then
                PlayerData.office = v.building
            elseif Config.Buildings[getBuildingId(v.building)].isFree then
                PlayerData.freeApartment = v.building
            else
                PlayerData.apartment = v.building
            end
        end
    end)
    BJCore.Functions.TriggerServerCallback("apartments:server:GetKeys", function(tab)
        ApartmentKeys = tab or {}
    end)
end)

RegisterNetEvent('BJCore:Client:OnJobUpdate')
AddEventHandler('BJCore:Client:OnJobUpdate', function(job)
    PlayerData.job = job
end)

RegisterNetEvent("apartment:client:syncKeys")
AddEventHandler("apartment:client:syncKeys", function(action, building, id, owner)
    if action == "add" then
        if ApartmentKeys[building] == nil then
            ApartmentKeys[building] = {}
        end
        ApartmentKeys[building][id] = owner
    elseif action == "remove" then
        ApartmentKeys[building][id] = false
    end
end)

RegisterNetEvent("apartments:client:terminate")
AddEventHandler("apartments:client:terminate", function(type)
    if type == "apartment" then
        PlayerData.apartment = nil
    else
        PlayerData.office = nil
    end
end)

AddEventHandler("apartments:leaseFirstApartment", function(spawn)
    local busy = true
    if not spawn then busy = false; end
    if PlayerData.freeApartment ~= nil then return; end
    BJCore.Functions.TriggerServerCallback("apartments:server:leaseApartment", function(id)
        if id then
            if Config.Buildings[id].isOffice then
                PlayerData.office = Config.Buildings[id].name
            elseif Config.Buildings[id].isFree then
                PlayerData.freeApartment = Config.Buildings[id].name
            else
                PlayerData.apartment = Config.Buildings[id].name
            end
            busy = false
        end
    end, Config.FreeApartment)
    while busy do Citizen.Wait(10); end
    if spawn then
        enterBuilding(Config.FreeApartment, PlayerData.citizenid, nil, true)
    else
        BJCore.Functions.Notify("You have been given a free apartment located at: ", "primary", 20000)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return; end
    local carryObject = exports["inventory"]:GetCarryingObject()
    if carryObject ~= nil then carryObject = NetworkGetNetworkIdFromEntity(carryObject); end
    TriggerServerEvent("apartments:server:HandleBucket", false, nil, nil, carryObject)
end)

function GetBuildingLabel(building)
    return Config.Buildings[getBuildingId(building)].label
end
exports("GetBuildingLabel", GetBuildingLabel)

function GetBuildingPos(building)
    return Config.Buildings[getBuildingId(building)].entry
end
exports("GetBuildingPos", GetBuildingPos)

function EnterOwnedApartment(building)
    enterBuilding(getBuildingId(building), PlayerData.citizenid)
end
exports("EnterOwnedApartment", EnterOwnedApartment)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return; end
    BJCore.Functions.PersistentNotify("end", "apartlease")
    BJCore.Functions.PersistentNotify("end", "viewAp")
end)