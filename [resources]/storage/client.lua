function playersafes:Awake(...)
    while not BJCore do Citizen.Wait(1000); end
    while not BJCore.Functions.IsPlayerLoaded() do Citizen.Wait(1000); end
    self.PlayerData = BJCore.Functions.GetPlayerData()
    TriggerServerEvent('playersafes:GetStartup')
end

function playersafes:Start(data, data2)
    self.Safes = data or {}
    self.SpawnedSafes = {}
    self.Bins = data2 or {}
    self.SpawnedBins = {}
    self:Update()
end

RegisterNetEvent('BJCore:Player:SetPlayerData')
AddEventHandler('BJCore:Player:SetPlayerData', function(Player)
    playersafes.PlayerData = Player
end)

RegisterNetEvent('playersafes:GotStartup')
AddEventHandler('playersafes:GotStartup', function(...) playersafes:Start(...); end)

RegisterNetEvent("playersafes:client:staffDelSafe", function()
    self = playersafes
    local closestSafe, closestDist = self:GetClosestSafe2()
    if closestDist and closestDist < self.DrawTextDist then
        TriggerServerEvent('playersafes:server:DelSafe', closestSafe)
    else
        exports['core']:SendAlert('error', "Safe not found. Try again?")
    end
end)

RegisterNetEvent('playersafes:getPlayerSafe')
AddEventHandler('playersafes:getPlayerSafe', function(option)
    local self = playersafes
    local closestSafe,closestDist = self:GetClosestSafe2()
    if closestDist and closestDist < self.DrawTextDist then
        local isOwner = false        
        if (closestSafe.citizenid and closestSafe.citizenid == self.PlayerData.citizenid) then 
            isOwner = true
        else 
            isOwner = false
        end
        if option == "access" then
            TriggerEvent('bj_minigames:start', 'Pincode', { maxCharacters = 6, passcode = tostring(closestSafe.pin) }, function(data)
                -- TriggerServerEvent("inventory:server:OpenInventory", "safe", closestSafe.safeid)
                -- TriggerEvent('inventory:client:SetCurrentSafe', closestSafe.safeid)
                local key = "safe_"..closestSafe.safeid
                TriggerServerEvent("inventory:server:OpenInventory", "stash", key, nil, 'Safe')
                TriggerEvent("inventory:client:SetCurrentStash", key)
            end, function(data)
                exports['core']:SendAlert('error', "Wrong pin entered")
            end)
        elseif option == "pickup" then
            if isOwner then
                local deleting = true
                TriggerEvent("chatMessage", "SYSTEM", "warning", "Picking up a safe will delete its items. You will lose access to any items held in this safe")
                while deleting do
                    Citizen.Wait(0)
                    BJCore.Functions.DrawText3D(closestSafe.location.x, closestSafe.location.y, closestSafe.location.z, "[~g~7~s~] Confirm Pickup | [~r~8~s~] Cancel")
                    if Utils.GetKeyPressed("7") and closestDist <= self.InteractDist then  
                        TriggerServerEvent('playersafes:PickupSafe', closestSafe)
                        deleting = false
                    end
                    if Utils.GetKeyPressed("8") and closestDist <= self.InteractDist then
                        deleting = false
                    end
                end
            else
                BJCore.Functions.Notify("You don't own this safe", "error")
            end
        end
        -- if not isOwner and (self.PlayerData.job and self.PlayerData.job ~= 'police') then
        --     self.NUIClosed = false
        --     self.CrackingSafe = closestSafe
        --     TriggerEvent('safecracker:StartMinigame',{},true)
        --     FreezeEntityPosition(PlayerPedId(),true)
        --     while self.CrackingSafe do Citizen.Wait(0); end
        -- else
        --     self.NUIClosed = false
        --     currentSafeInv = {
        --         id = closestSafe.safeid
        --     }
        --     BJCore.Functions.TriggerServerCallback('playersafes:GetSafeInventory', function(inventory)
        --         if inventory ~= nil then print("found inventory"); end
        --         TriggerEvent('bj-inventory:client:openCustomInventory', {
        --             inventoryData = inventory,
        --             slots = 80,
        --             functions = safeInventoryFunctions
        --         })
        --     end, closestSafe.safeid)          
        -- end
    else
        exports['core']:SendAlert('error', "Safe not found. Try again?")
    end    
end)

function playersafes:Update(...)
    while true do
        local nearby = false
        local closestSafe,closestDist = self:GetClosestSafe()
        local closestBin,closestBinDist = self:GetClosestBin()
        
        if closestDist and closestDist < 50 then nearby = true; end
        if closestBinDist and closestBinDist < 50 then nearby = true; end
        if not nearby then Citizen.Wait(1000); end
        Citizen.Wait(500)
    end
end

function playersafes:DestroySafe(safe)
    local rList = {}
    for k,v in pairs(self.SpawnedSafes) do
        if v and v.id and v.id == safe.safeid then
            for k,v in pairs(v.obj) do DeleteObject(v); end
            table.insert(rList,k)
        end
    end
    for k,v in pairs(rList) do self.SpawnedSafes[v] = nil; self.Safes[v] = nil; end
end

function playersafes:GetClosestSafe()
    local plyPed = PlayerPedId()
    local plyPos = GetEntityCoords(plyPed)
    local closest,closestDist
    for k,v in pairs(self.Safes) do
        local v3 = vector3(v.location.x, v.location.y, v.location.z)
        local dist = #(plyPos - v3)
        if (not closestDist or dist < closestDist) then
            closest = v
            closestDist = dist
        end
        if dist < self.LoadSafeDist and not self.SpawnedSafes[k] then
            self:SpawnThisSafe(k,v.location)
        elseif dist > self.DespawnDist and self.SpawnedSafes[k] then
            for key,val in pairs(self.SpawnedSafes[k].obj) do DeleteObject(val); end
            self.SpawnedSafes[k] = false
        end
    end
    if closestDist then return closest,closestDist
    else return false,999999
    end
end

function playersafes:GetClosestSafe2()
    local plyPed = PlayerPedId()
    local plyPos = GetEntityCoords(plyPed)
    local closest,closestDist
    for k,v in pairs(self.Safes) do
        local v3 = vector3(v.location.x, v.location.y, v.location.z)
        local dist = #(plyPos - v3)
        if (not closestDist or dist < closestDist) then
            closest = v
            closestDist = dist
        end
    end
    if closestDist then return closest,closestDist
    else return false,999999
    end
end

function IsNearSafe()
    local closestSafe,closestDist = playersafes:GetClosestSafe2()
    if closestDist and closestDist < playersafes.DrawTextDist then
        return true
    else
        return false
    end
end
exports('IsNearSafe', IsNearSafe)

function playersafes:SpawnThisSafe(key,pos)
    local safeData = self.Safes[key]
    local plyPed = PlayerPedId()
    local forward,right,up,pPos = GetEntityMatrix(plyPed)
    local nPos = vector3(pos.x,pos.y,pos.z - 0.9)
    TriggerEvent('safecracker:SpawnSafe', false, nPos, safeData.location.heading, function(safe) 
        self.SpawnedSafes[key] = { obj = safe, id = safeData.safeid } 
    end)  
    while not self.SpawnedSafes[key] do Citizen.Wait(0); end
end

function playersafes:SpawnSafe(safe)
    local plyPed = PlayerPedId()
    local forward,right,up,pPos = GetEntityMatrix(plyPed)
    local pos = (pPos + forward)
    local heading = GetEntityHeading(plyPed)
    safe.location = {x = pos.x, y = pos.y, z = pos.z, heading = heading}
    exports['core']:SendAlert('success', "Safe placed")
    exports['core']:SendAlert('inform', " Default Pin: 123456 | Use /setsafepin to set new pin", 10000)
    TriggerServerEvent('playersafes:SafeSpawned',safe)
end

RegisterCommand("setsafepin", function()
    self = playersafes
    local closestSafe, closestDist = self:GetClosestSafe2()
    if closestDist and closestDist < self.DrawTextDist then
        local isOwner = false        
        if (closestSafe.citizenid and closestSafe.citizenid == self.PlayerData.citizenid) then 
            isOwner = true
            TriggerEvent('bj_minigames:start', 'Pincode', { maxCharacters = 6 }, function(data)
                TriggerServerEvent("playersafes:UpdatePin", closestSafe.safeid, tonumber(data))
            end, function(data)
                -- print('Callback Failure: ')
                -- print(data)
            end)
            
        else 
            exports['core']:SendAlert('error', "You don't own this safe")
            isOwner = false
        end
    else
        exports['core']:SendAlert('error', "Safe not found. Try again?")
    end
end)

RegisterCommand("getsafepin", function()
    self = playersafes
    local closestSafe, closestDist = self:GetClosestSafe2()
    if closestDist and closestDist < self.DrawTextDist then
        local isOwner = false        
        if (closestSafe.citizenid and closestSafe.citizenid == self.PlayerData.citizenid) then
            isOwner = true
            exports['core']:SendAlert('inform', "Current Safe Pin: "..tostring(closestSafe.pin), 5000)
            
        else 
            exports['core']:SendAlert('error', "You don't own this safe")
            isOwner = false
        end
    else
        exports['core']:SendAlert('error', "Safe not found. Try again?")
    end
end)

RegisterNetEvent('playersafes:SpawnSafe')
AddEventHandler('playersafes:SpawnSafe', function(safe) playersafes:SpawnSafe(safe); end)
RegisterNetEvent('playersafes:SafeAdded')
AddEventHandler('playersafes:SafeAdded', function(safe,key) playersafes.Safes[key] = safe; end)
RegisterNetEvent('playersafes:DelSafe')
AddEventHandler('playersafes:DelSafe', function(safe) playersafes:DestroySafe(safe); end)
RegisterNetEvent('playersafes:SetSafes')
AddEventHandler('playersafes:SetSafes', function(safes) playersafes.Safes = safes; end)
Citizen.CreateThread(function(...) playersafes:Awake(...); end)

DecorRegister('BinId', 3)
function playersafes:GetClosestBin()
    local plyPed = PlayerPedId()
    local plyPos = GetEntityCoords(plyPed)
    local closest,closestDist
    for k,v in pairs(self.Bins) do
        local dist = #(plyPos - v.pos)
        if (not closestDist or dist < closestDist) then
            closest = v
            closestDist = dist
        end
        if dist < 200 and not self.SpawnedBins[k] then
            local worldobj = GetClosestObjectOfType(v.pos, 1.5, v.model, false)
            if worldobj ~= 0 then SetEntityAsMissionEntity(worldobj, true) DeleteObject(worldobj); end
            local obj = CreateObject(v.model, v.pos, false, true, false)
            SetEntityAsMissionEntity(obj, true)
            FreezeEntityPosition(obj, true)
            SetEntityHeading(obj, v.heading)
            DecorSetInt(obj, 'BinId', v.binid)
            self.SpawnedBins[k] = { obj = obj, id = v.binid } 
        elseif dist > 250 and self.SpawnedBins[k] then
            DeleteObject(self.SpawnedBins[k].obj)
            self.SpawnedBins[k] = false
        end
    end
    if closestDist then return closest,closestDist
    else return false,999999
    end
end

RegisterNetEvent('bins:GetBin')
AddEventHandler('bins:GetBin', function()
    local bin, dist, binHash = GetCloseBins()
    if bin then
        ClearPedTasksImmediately(PlayerPedId())
        local binId = DecorGetInt(bin, 'BinId') or 0
        TriggerServerEvent("inventory:server:OpenInventory", "bin", binId)
        TriggerEvent('inventory:client:SetCurrentBin', binId)        
    else 
        exports['core']:SendAlert('error', "Bin not found. Try again?")
    end
end)

local binModels = {
    [1] = 218085040,
    [2] = 666561306,
    [3] = -58485588,
    [4] = -206690185,
    [5] = 1511880420,
    [6] = 682791951,  
}

function GetCloseBins()
    for i = 1, #binModels do
      local objFound = GetClosestObjectOfType(GetEntityCoords(PlayerPedId()), 0.75, binModels[i], 0, 0, 0)
  
      if DoesEntityExist(objFound) then
        TaskTurnPedToFaceEntity(PlayerPedId(), objFound, 3.0)
        return objFound, GetEntityCoords(objFound), binModels[i]
      end
    end
  
    return false, 999999, false
end

function IsNearBin()
    local bin, dist, binHash = GetCloseBins()
    if bin then return true
    else return false; end
end
exports('IsNearBin', IsNearBin)

RegisterNetEvent('bins:SyncBins')
AddEventHandler('bins:SyncBins', function(data) playersafes.Bins = data; end)

RegisterNetEvent("storage:client:OpenStorageItem")
AddEventHandler("storage:client:OpenStorageItem", function(item, data)
    TriggerServerEvent("inventory:server:OpenInventory", "stash", "itemstorage_"..item.info.stashId, data, item.label.." Storage")
    TriggerEvent("inventory:client:SetCurrentStash", "itemstorage_"..item.info.stashId)
end)

inCashStorage = false
RegisterNetEvent("storage:client:OpenCashStorageItem")
AddEventHandler("storage:client:OpenCashStorageItem", function(item, max)
    ClearMenu()
    MenuTitle = "Cash Storage:"
    TriggerEvent("police:client:pauseKeybind", true)
    Menu.addButton(item.label.." (Max "..BJCore.Config.Currency.Symbol..max..")", "yeet", nil, nil, "Garage")
    Menu.addButton("Amount: "..BJCore.Config.Currency.Symbol..item.info.cash, "yeet", nil)
    Menu.addButton("Add", "ManageCashStorage", "add", item)
    Menu.addButton("Remove", "ManageCashStorage", "remove", item)
    Menu.addButton("Close", "closeMenuFull", nil)
    Menu.hidden = not Menu.hidden
    inCashStorage = true
    Menu.selection = 2
    CashStorageTick()
end)

function ManageCashStorage(action, item)
    local input = BJCore.Functions.GetOnscreenKeyboardInput("Amount:", "", 10)
    if type(tonumber(input)) == "number" then
        TriggerServerEvent("storage:server:manageCashStorage", action, tonumber(input), item)
        closeMenuFull()
    else
        BJCore.Functions.Notify("Input a number only", "error")
    end
end

function CashStorageTick()
    Citizen.CreateThread(function()
        while inCashStorage do
            Citizen.Wait(1)
            Menu.renderGUI()
        end
    end)
end

RegisterNetEvent("thermite:client:onuse")
AddEventHandler("thermite:client:onuse", function()
    if not IsNearSafe() then return; end
    local self = playersafes
    local closestSafe,closestDist = self:GetClosestSafe2()
    if closestDist and closestDist < self.DrawTextDist then
        TriggerEvent('thermite:start', function(result,msg)
            if result then
                while true do
                    Citizen.Wait(0)
                    local dist = #(GetEntityCoords(PlayerPedId()) - vector3(closestSafe.location.x, closestSafe.location.y, closestSafe.location.z))
                    if dist < playersafes.DrawTextDist then
                        break
                    else
                        BJCore.Functions.DrawText3D(closestSafe.location.x, closestSafe.location.y, closestSafe.location.z, "Move here to access safe")
                    end
                end
                if math.random(1, 100) <= 50 and not exports["crim"]:IsWearingGloves() then
                    TriggerServerEvent("evidence:server:CreateFingerDrop", GetEntityCoords(PlayerPedId()))
                end
                local key = "safe_"..closestSafe.safeid
                TriggerServerEvent("inventory:server:OpenInventory", "stash", key, nil, 'Safe')
                TriggerEvent("inventory:client:SetCurrentStash", key)
            end
            BJCore.Functions.Notify(msg,'primary')
        end, 0.5,1.8,0.3)
    end
end)