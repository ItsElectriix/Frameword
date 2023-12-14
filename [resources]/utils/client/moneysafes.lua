local ClosestSafe = nil
local IsAuthorized = false

local PlayerData = {}

function SetClosestSafe()
    local pos = GetEntityCoords(PlayerPedId())
    local current = nil
    local dist = nil
    for id, house in pairs(Config.Safes) do
        if current ~= nil then
            if #(pos - Config.Safes[id].coords) < dist then
                current = id
                dist = #(pos - Config.Safes[id].coords)
            end
        else
            dist = #(pos - Config.Safes[id].coords)
            current = id
        end
    end
    ClosestSafe = current
    if ClosestSafe ~= nil then
        if current == "police" then
            IsAuthorized = exports['police']:IsArmoryWhitelist()
        elseif current == "mechanic" then
            IsAuthorized = IsManagementWhitelist("mechanic")
        elseif current == "pdm" then 
            IsAuthorized = IsManagementWhitelist("pdm")
        elseif current == "grovestcustom" then
            IsAuthorized = IsManagementWhitelist("grovestcustom")
        elseif current == "handlebar" then
            IsAuthorized = IsManagementWhitelist("handlebar")
        elseif Config.ManagementWhitelist[current] then
            IsAuthorized = IsManagementWhitelist(current)
        end
    end
end

function IsManagementWhitelist(job)
    local retval = false
    local citizenid = BJCore.Functions.GetPlayerData().citizenid    
    for k, v in pairs(Config.ManagementWhitelist[job]) do
        if v == citizenid then
            retval = true
            break
        end
    end
    return retval
end

RegisterNetEvent("BJCore:Client:OnPlayerLoaded")
AddEventHandler("BJCore:Client:OnPlayerLoaded", function()
    Citizen.CreateThread(function()
        PlayerData = BJCore.Functions.GetPlayerData()
        while true do
            SetClosestSafe()
            Citizen.Wait(2500)
        end
    end)
end)

Citizen.CreateThread(function()
    while true do
        local inRange = false
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)

        if ClosestSafe ~= nil then
            if PlayerData.job.name == ClosestSafe then
                if IsAuthorized then
                    local data = Config.Safes[ClosestSafe]
                    local distance = #(pos - data.coords)
                    if distance < 20 then
                        inRange = true
                        if distance < Config.MinimumSafeDistance then
                            BJCore.Functions.DrawText3D(data.coords.x, data.coords.y, data.coords.z, '~g~'..BJCore.Config.Currency.Symbol..data.money)
                            BJCore.Functions.DrawText3D(data.coords.x, data.coords.y, data.coords.z - 0.1, '~b~/deposit~w~ - Deposit money')
                            BJCore.Functions.DrawText3D(data.coords.x, data.coords.y, data.coords.z - 0.2, '~b~/withdraw~w~ - Withdraw money')
                        end
                    end
                else
                    Citizen.Wait(1750)
                end
            else
                Citizen.Wait(1750)
            end
        else
            Citizen.Wait(1750)
        end
        Citizen.Wait(1)
    end
end)

RegisterNetEvent('moneysafe:client:AddJobSafe')
AddEventHandler('moneysafe:client:AddJobSafe', function(safeName, coords, managers, owner)
    if type(coords) ~= 'vector3' then
        coords = vector3(coords.x, coords.y, coords.z)
    end
    if not Config.Safes[safeName] then
        Config.Safes[safeName] = {
            money = 0,
            coords = coords,
        }
    else
        Config.Safes[safeName].coords = coords
    end
    Config.ManagementWhitelist[safeName] = managers
    table.insert(Config.ManagementWhitelist[safeName], owner)
end)

RegisterNetEvent('moneysafe:client:DepositMoney')
AddEventHandler('moneysafe:client:DepositMoney', function(amount)
    if ClosestSafe ~= nil then
        if IsAuthorized then
            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)
            local data = Config.Safes[ClosestSafe]
            local distance = #(pos - data.coords)
            
            if distance < Config.MinimumSafeDistance then
                TriggerServerEvent('moneysafe:server:DepositMoney', ClosestSafe, amount)
            end
        end
    end
end)

RegisterNetEvent('moneysafe:client:WithdrawMoney')
AddEventHandler('moneysafe:client:WithdrawMoney', function(amount)
    if ClosestSafe ~= nil then
        if IsAuthorized then
            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)
            local data = Config.Safes[ClosestSafe]
            local distance = #(pos - data.coords)
            
            if distance < Config.MinimumSafeDistance then
                TriggerServerEvent('moneysafe:server:WithdrawMoney', ClosestSafe, amount)
            end
        end
    end
end)

RegisterNetEvent('BJCore:Client:OnJobUpdate')
AddEventHandler('BJCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
end)

RegisterNetEvent('moneysafe:client:UpdateSafe')
AddEventHandler('moneysafe:client:UpdateSafe', function(SafeData, k)
    if not Config.Safes[k] and SafeData.coords then
        Config.Safes[k] = SafeData
    else
        Config.Safes[k].money = SafeData.money
    end
end)

exports('DoesMoneysafeExist', function(safe)
    if Config.Safes[safe] then
        return true
    end
    return false
end)

exports('GetMoneysafe', function(safe)
    if Config.Safes[safe] then
        return Config.Safes[safe]
    end
    return false
end)