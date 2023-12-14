isLoggedIn = false
PlayerJob = {}

function vehCatTemplate()
    local vehicleCategorys = {
        ["coupes"] = {
            label = "Coupes",
            vehicles = {}
        },
        ["sedans"] = {
            label = "Sedans",
            vehicles = {}
        },
        ["muscle"] = {
            label = "Muscle",
            vehicles = {}
        },
        ["suvs"] = {
            label = "SUVs",
            vehicles = {}
        },
        ["compacts"] = {
            label = "Compacts",
            vehicles = {}
        },
        ["vans"] = {
            label = "Vans",
            vehicles = {}
        },
        ["super"] = {
            label = "Super",
            vehicles = {}
        },
        ["sports"] = {
            label = "Sports",
            vehicles = {}
        },
        ["sportsclassics"] = {
            label = "Sports Classics",
            vehicles = {}
        },
        ["motorcycles"] = {
            label = "Motorcycles",
            vehicles = {}
        },
        ["offroad"] = {
            label = "Offroad",
            vehicles = {}
        },
        ["commercial"] = {
            label = "Commercial",
            vehicles = {}
        },
        ["bicycles"] = {
            label = "Bicycles",
            vehicles = {}
        },
    }
    return vehicleCategorys
end

local wasDealer = false
RegisterNetEvent('BJCore:Client:OnPlayerLoaded')
AddEventHandler('BJCore:Client:OnPlayerLoaded', function()
    BJCore.Functions.GetPlayerData(function(PlayerData)
        PlayerJob = PlayerData.job
    end)
    TriggerServerEvent("vehicleshop:server:getSaleData")
    TriggerServerEvent("vehicleshop:server:dealersOnline")
    isLoggedIn = true
    if IsDelearship(PlayerJob.name) then
        TriggerServerEvent("vehicleshop:server:updateDealersOnline")
        wasDealer = true
        if not runningLocationTick then
            JobLocationsThread()
        end
    end
end)

RegisterNetEvent('BJCore:Client:OnPlayerUnload')
AddEventHandler('BJCore:Client:OnPlayerUnload', function()
    runningLocationTick = false
end)

RegisterNetEvent('BJCore:Client:OnJobUpdate')
AddEventHandler('BJCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
    if IsDelearship(PlayerJob.name) then
        wasDealer = true
        TriggerServerEvent("vehicleshop:server:updateDealersOnline")
        if not runningLocationTick then
            JobLocationsThread()
        end
    end
    if wasDealer and not IsDelearship(PlayerJob.name) then
        wasDealer = false
        TriggerServerEvent("vehicleshop:server:updateDealersOnline")
        if runningLocationTick then
            runningLocationTick = false
        end
    end
end)

dealersOnline = {}
RegisterNetEvent("vehicleshop:client:dealersOnline")
AddEventHandler("vehicleshop:client:dealersOnline", function(data) dealersOnline = data end)

vehShopCats = {}
Citizen.CreateThread(function()
    for index,_ in pairs(Config.VehicleShops) do
        vehShopCats[index] = vehCatTemplate()
        for k, v in pairs(BJCore.Shared.Vehicles) do
            local isIndex = false
            if type(v["shop"]) == "table" then
                for k,v in pairs(v["shop"]) do
                    if v == index then
                        isIndex = true
                    end
                end
            else
                if v["shop"] == index then
                    isIndex = true
                end
            end
            if isIndex then
                for cat,_ in pairs(vehShopCats[index]) do
                    if v["category"] == cat then
                        table.insert(vehShopCats[index][cat].vehicles, BJCore.Shared.Vehicles[k])
                    end
                end
            end
        end
    end
    setUpCats()
end)

local CurAction = false
function JobLocationsThread()
    runningLocationTick = true
    while runningLocationTick do
        local nearby = false
        local plyPed = PlayerPedId()
        local plyPos = GetEntityCoords(plyPed)
        local closestDealership, closestDealershipDist = GetClosestDelearship(plyPos)
        if closestDealershipDist <= 40 then
            nearby = true
            if nearby and closestDealership then
                local actKey, actVal, actDist = GetClosestAction(plyPos, closestDealership)
                if not CurAction or CurAction.key ~= actKey then
                    CurAction = { key = actKey, val = actVal }
                end
                if actDist < 1.5 then
                    local text = Config.ActionText[actKey]
                    if actKey == "duty" then
                        if PlayerJob.onduty then
                            text = "Go Off "..text
                        else
                            text = "Go On "..text
                        end
                    elseif actKey == "vehicle" then
                        Menu.renderGUI()
                        if IsPedInAnyVehicle(plyPed) then text = "Store Vehicle"; end
                    end
                    if PlayerJob.onduty or actKey == "duty" then
                        BJCore.Functions.DrawText3D(actVal.x, actVal.y, actVal.z, "[~g~E~s~] "..text)
                        if BJCore.Functions.GetKeyPressed("E") then
                            HandleAction(CurAction)
                        end
                    end
                end
                if actDist > 40 then Citizen.Wait(1000); end
            end
        else
            CurAction = false
        end
        if not nearby then Citizen.Wait(1000); end
        Citizen.Wait(0)
    end
end

function HandleAction(act)
    if act.key == "stash" then
        TriggerEvent("inventory:client:SetCurrentStash", PlayerJob.name.."stash")
        TriggerServerEvent("inventory:server:OpenInventory", "stash", PlayerJob.name.."stash", {
            maxweight = 4000000,
            slots = 500,
        }, Config.VehicleShops[PlayerJob.name].label)
    elseif act.key == "vehicle" then
        if IsPedInAnyVehicle(PlayerPedId()) then
            DeleteVehicle(GetVehiclePedIsIn(PlayerPedId()))
        else
            VehicleList()
            Menu.hidden = not Menu.hidden
        end
    elseif act.key == "duty" then
        TriggerServerEvent("BJCore:ToggleDuty")
    end
end

function VehicleList()
    ClearMenu()
    for k, v in pairs(Config.GarageList[PlayerJob.name]) do
        Menu.addButton(v, "SpawnListVehicle", k) 
    end
    Menu.addButton("Close menu", "CloseMenu", nil) 
end

function SpawnListVehicle(model)
    BJCore.Functions.SpawnVehicle(model, function(veh)
        SetEntityHeading(veh, Config.JobLocations[PlayerJob.name]["vehicle"].w)
        exports['legacyfuel']:SetFuel(veh, 100.0)
        Menu.hidden = true
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        TriggerEvent('keys:addNew', veh, GetVehicleNumberPlateText(veh))
        SetVehicleEngineOn(veh, true, true)
    end, Config.JobLocations[PlayerJob.name]["vehicle"], true)
end

function GetClosestDelearship(plyPos)
    local closestKey,closestVal,closestDist
    for k,v in pairs(Config.VehicleShops) do
        local dist = #(plyPos - v["pos"])
        if not closestDist or dist < closestDist then
            closestKey = k
            closestDist = dist
        end
    end
    if not closestDist then return false,999999
    else return closestKey,closestDist
    end
end

function GetClosestAction(plyPos, key)
    local closestKey,closestVal,closestDist
    for k,v in pairs(Config.JobLocations[key]) do
        if v then
            local dist = #(plyPos - v.xyz)
            if not closestDist or dist < closestDist then
                closestKey = k
                closestVal = v
                closestDist = dist
            end
        end
    end
    if not closestDist then return false,false,999999
    else return closestKey,closestVal,closestDist
    end
end