local MFC = Crafting
local hasSynced = false
Recipes = {}

function MFC:Awake(...)
    while not BJCore do Citizen.Wait(100); end
    while not BJCore.Functions.IsPlayerLoaded() do Citizen.Wait(1000); end
    self.Tables = {}
    self.CraftingItems = {}
    self.Open = false;
    self.PlayerData = BJCore.Functions.GetPlayerData();
    BJCore.Functions.TriggerServerCallback('Crafting:GetStartData', function(retTab, retRecipes)
        self.SpawnedTables = {}
        self.CraftingTables = retTab or {}
        print("Recipes: "..BJCore.Common.Dump(retRecipes))
        Recipes = retRecipes
        self:Update()
    end)
end

function MFC:Update(...)
    local lastCheck = 0
    local lastPos = false
    while true do

        local plyPed = PlayerPedId()
        local plyPos = GetEntityCoords(plyPed)

        if (GetGameTimer() - lastCheck > 5000) or (lastPos and #(plyPos.xy - lastPos.xy) > 100.0) then
            sleep = 0
            lastCheck = GetGameTimer()
            lastPos = plyPos
            for k,v in pairs(self.CraftingTables) do
                local dist = #(plyPos.xy - v.location.xy)
                if not self.SpawnedTables[v.location] then
                    if dist < self.LoadTableDist and not self.SpawnedTables[v.location] then
                        self:SpawnTable(v.location,v.type)
                    end
                else
                    if dist > (self.LoadTableDist) and self.SpawnedTables[v.location] then
                        self:DespawnTable(v.location)
                    end
                end
            end
        else
            sleep = 1000
        end

        local closest, closestDist = self:GetClosestTable()
        if closestDist and closestDist < self.DrawTextDist and self.SpawnedTables[closest.location] and not self.Crafting then
            sleep = 0
            BJCore.Functions.DrawText3D(closest.location.x, closest.location.y, closest.location.z+1.5, MFC.CraftText[closest.type], 0.7)
            if IsControlJustPressed(0, 38) then
                self:UseTable(closest)
            end
        else
            if closestDist > 50 then sleep = 1000; end
        end
        for k,v in pairs(self.CraftingLocations) do
            local dist = #(plyPos - v.pos.xyz)
            if dist < 1.0 then
                sleep = 0
                BJCore.Functions.DrawText3D(v.pos.x, v.pos.y, v.pos.z, "[~g~E~w~] "..v.label)
                if IsControlJustPressed(0, 38) then
                    TriggerEvent('inventory:client:SetCurrentCraft', 'crafting-static'..v.label.."_"..k)
                    TriggerServerEvent('inventory:server:OpenInventory', 'crafting', 'static'..v.label.."_"..k, {tabType = v.type}, v.label)
                end
            end
        end
        Citizen.Wait(sleep)
    end
end



RegisterNetEvent('Crafting:deleteCraftingTable')
AddEventHandler('Crafting:deleteCraftingTable', function()
    local closest, closestDist = MFC:GetClosestTable()
    if closestDist and closestDist < MFC.DrawTextDist and MFC.SpawnedTables[closest.location] then
	  hasSynced = false
      TriggerServerEvent('Crafting:TableRemoved', closest.id)
	else
        BJCore.Functions.Notify("No table found within range", 'error')
    end
end)

RegisterNetEvent('Crafting:TableClosed')
AddEventHandler('Crafting:TableClosed', function()
    MFC.Crafting = false
end)

function MFC:SpawnTable(pos, type)
    self.SpawnedTables[pos] = true
    local hash = GetHashKey(self.BenchModel[type])
    RequestModel(hash);
    while not HasModelLoaded(hash) do RequestModel(hash); Citizen.Wait(0); end
    local newTable = CreateObject(hash, pos.x, pos.y, pos.z, false, false, false) or nil
    PlaceObjectOnGroundProperly(newTable)
    SetEntityHeading(newTable, pos.w)
    SetEntityAsMissionEntity(newTable, true, true)
    FreezeEntityPosition(newTable, true)
    self.SpawnedTables[pos] = newTable
    SetModelAsNoLongerNeeded(hash)
end

function MFC:DespawnTable(pos)
    local obj = self.SpawnedTables[pos]
    if not obj then
        return
    end
    SetEntityAsMissionEntity(obj, true, true)
    DeleteObject(obj)
    DeleteEntity(obj)
    self.SpawnedTables[pos] = nil
end

function MFC:UseTable(table)
    local right,fwd,up,posB = GetEntityMatrix(self.SpawnedTables[table.location])
    local tPos = table.location.xyz + (fwd*0.8) + vector3(0,0,1.0)
    if table.type ~= "reg" then tPos = table.location.xyz - (right*0.8) + vector3(0,0,1.0); end
    local pPos = GetEntityCoords(PlayerPedId())
    local wOff = table.location.w+90.0
    if table.type ~= "reg" then wOff = table.location.w; end
    if #(pPos.xy - tPos.xy) > 1.1 then
        TaskGoStraightToCoord(PlayerPedId(), tPos.x, tPos.y, tPos.z, 10.0, 10, wOff, 0.5)
    end
    local waitTimer = 1500
    while #(pPos.xy - tPos.xy) > 1.15 and waitTimer > 0 do
        pPos = GetEntityCoords(PlayerPedId()) or nil
        Citizen.Wait(0)
        waitTimer = waitTimer - 1
        if waitTimer == 0 then
            print('Failed to get coords')
        end
    end

    TriggerEvent('inventory:client:SetCurrentCraft', 'crafting-'..table.id)
    TriggerServerEvent('inventory:server:OpenInventory', 'crafting', table.id, {tabType = table.type})
    self.Crafting = true
    while self.Crafting do Wait(100); end
end

function MFC:GetClosestTable()
    local closest,closestDist
    local pos = GetEntityCoords(PlayerPedId())
    for k,v in pairs(self.CraftingTables) do
        local dist = #(pos.xy - v.location.xy)
        if (not closestDist or dist < closestDist) then
            closest = v
            closestDist = dist
        end
    end
    if closest then return closest,closestDist else return false,999999; end
end

function MFC:DoUi(ttype)
    self.PlayerData = BJCore.Functions.GetPlayerData()

    local craftingItems = {}
    local knownRecipes = {}
    for k,v in pairs(self.PlayerData.items) do
        table.insert(craftingItems,{name = v.name, count = v.amount})
    end
    local selRecipes = Recipes
    if ttype and ttype == "wep" then selRecipes = WepRecipes; end

    self.Open = not self.Open;
    SendNUIMessage({
        type = 'openUI',
        enable = self.Open,
        require = self.RequireRecipes;
        recipes = selRecipes,
        items = craftingItems,
        --knownRecipes = knownRecipes,
    });

    SetNuiFocus(self.Open,self.Open);

    if self.Crafting and not self.Open then self.Crafting = false; end
end

function MFC:PostData(data)
    if data then
        local plyPed = PlayerPedId()
        self:DoUi()

        local craftTime = (CraftTime[data] or 3.0)
        exports['mythic_progbar']:Progress({
            name = "progress_bar",
            duration = craftTime * 1000,
            label = "Crafting",
            canCancel = false,
            controlDisables = {
                disableMovement = false,
                disableCarMovement = false,
                disableMouse = false,
                disableCombat = false,
                disableInteract = false
            },
            animation = {
                animDict = "anim@amb@business@coc@coc_unpack_cut_left@",
                anim = "coke_cut_v5_coccutter",
            },
        }, function(status)
            if not status then
                self.Crafting = false
                TriggerServerEvent('Crafting:TryCraft',data)
            end
        end)
    end
end

function MFC:PlaceTable(type)
    local plyPed = PlayerPedId()
    local forward, right, up, pPos = GetEntityMatrix(plyPed)
    local pos = (pPos + forward)
    local heading = GetEntityHeading(plyPed)
    local hOffset
    if type == "reg" then hOffset = heading - 90 else hOffset = heading; end
    local location = vector4(pos.x, pos.y, pos.z-1.0, hOffset)
    BJCore.Functions.Notify("You placed a Crafting Table. Loading...", 'primary')
    TriggerServerEvent('Crafting:TablePlaced',location,type)
end

function MFC:SyncTables(data, tableDeleted)
    local despawnLocation = nil
    if tableDeleted ~= nil then
        for k,v in pairs(self.CraftingTables) do
            if v.id and v.id == tableDeleted then
                despawnLocation = v.location
                break
            end
        end
    end

    self.CraftingTables = data

    if despawnLocation ~= nil then
        self:DespawnTable(despawnLocation)
    end
end

echo = function(...)
    local args = {...}
    local printStr = ''
    local first = true
    for k,v in pairs(args) do
        if first then
            first = false
            printStr = '[ARG1] : ' .. tostring(v)
        else
            printStr = printStr .. ' || [ARG' .. k .. '] : ' .. tostring(v)
        end
    end
    print("[ECHO] || "..printStr)
end

function MFC:CraftRespond(response,label,items)
    if response then
        BJCore.Functions.Notify("You crafted: "..label, 'primary')
    else
        BJCore.Functions.Notify("You failed to craft: "..label, 'error')
        for k,v in pairs(items) do
            BJCore.Functions.Notify(v,'primary',5000)
        end
    end
end

-- RegisterCommand('testcraft', function()
--     local id = '123'
--     TriggerEvent('inventory:client:SetCurrentCraft', 'crafting-'..id)
--     TriggerServerEvent('inventory:server:OpenInventory', 'crafting', id, {})
-- end)

RegisterNetEvent('BJCore:Player:SetPlayerData')
AddEventHandler('BJCore:Player:SetPlayerData', function(Player)
    MFC.PlayerData = Player
end)

-- RegisterNetEvent('bj-inventory:usableItem:regcraft')
-- AddEventHandler('bj-inventory:usableItem:regcraft', function(item) TriggerServerEvent('Crafting:UseTable', item); end)
-- RegisterNetEvent('bj-inventory:usableItem:advcraft')
-- AddEventHandler('bj-inventory:usableItem:advcraft', function(item) TriggerServerEvent('Crafting:UseTable', item); end)
-- RegisterNetEvent('bj-inventory:usableItem:wepcraft')
-- AddEventHandler('bj-inventory:usableItem:wepcraft', function(item) TriggerServerEvent('Crafting:UseTable', item); end)
RegisterNetEvent('Crafting:PlaceTable')
AddEventHandler('Crafting:PlaceTable', function(type) MFC:PlaceTable(type); end)
RegisterNetEvent('Crafting:ReopenTable')
AddEventHandler('Crafting:ReopenTable', function()
    local closest, closestDist = MFC:GetClosestTable()
    if closestDist and closestDist < MFC.DrawTextDist and MFC.SpawnedTables[closest.location] then
        MFC:UseTable(closest)
    end
end)
RegisterNetEvent('Crafting:CraftRespond')
AddEventHandler('Crafting:CraftRespond', function(...) MFC:CraftRespond(...); end)
RegisterNetEvent('Crafting:SyncTables')
AddEventHandler('Crafting:SyncTables', function(...) MFC:SyncTables(...); end)
RegisterNUICallback('dopost', function(data, cb) MFC:PostData(data); if cb then cb(true); end; end)
RegisterNUICallback('close', function(data, cb) MFC:DoUi(); if cb then cb(true); end; end)
Citizen.CreateThread(function(...) MFC:Awake(...); end)

exports('GetRecipes', function()
    return Recipes
end)