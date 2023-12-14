local MFC = Crafting
MFC.Characters = {}

local UsbItems = {
    ['blackusb'] = true,
    ['greenusb'] = true,
    ['redusb'] = true,
    ['blueusb'] = true,
}

function MFC:Awake(...)
    while not BJCore do Citizen.Wait(200); end
    self:sT()
end

function MFC:sT()
    self.CraftingTables = {}
    exports['ghmattimysql']:execute('SELECT * FROM craftingtables',{},function(data)
        for k,v in pairs(data) do
        local loc = json.decode(v.location) or {x=0.0,y=0.0,z=0.0,heading=0.0,type='reg'}
        self.CraftingTables[k] = {
            location = vector4(loc.x,loc.y,loc.z,loc.heading),
            type = loc.type,
            id = v.id,
            owner = v.owner
        }
        end
    end)
end

function MFC:UseTable(source, itemdata)
    local pData = BJCore.Functions.GetPlayer(source)
    while not pData do Citizen.Wait(0); end
    local item = pData.Functions.GetItemByName(itemdata)
    if item and item.amount and item.amount > 0 then
        pData.Functions.RemoveItem(itemdata, 1)
        TriggerClientEvent('Crafting:PlaceTable', source, MFC:Type(itemdata))
    end
end

function MFC:Type(item)
    local tabletype
    if item == "regcrafting" then tabletype = 'reg'
    elseif item == "advcraft" then tabletype = 'adv'
    elseif item =="weapcrafting" then tabletype = 'wep'; end
    return tabletype
end

function CompactItemsIntoRecipeFormat(items)
    local rowInfo = {false,false,false}
    for i = #items, 1, -1 do
        row = items[i]
        local allEmpty = true
        for k,v in ipairs(row) do
            if v then
                allEmpty = false;
                break
            end
        end
        if allEmpty then
            table.remove(items, i)
            rowInfo[i] = true
        end
    end
    if not rowInfo[1] and rowInfo[2] and not rowInfo[3] then
        table.insert(items, 2, {false,false,false})
    end
    if #items > 0 then
        for i = 3, 1, -1 do
            local allEmpty = true
            for k,r in ipairs(items) do
                if items[k][i] then
                    allEmpty = false
                    break
                end
            end
            if allEmpty then
                for k,r in ipairs(items) do
                    table.remove(items[k], i)
                end
            end
        end
    end
    return items
end

RegisterNetEvent('Crafting:TryCraft')
AddEventHandler('Crafting:TryCraft', function(source, name, id, items)
    local pData = BJCore.Functions.GetPlayer(source)
    while not pData do pData = BJCore.Functions.GetPlayer(source); Citizen.Wait(0); end
    local recipe = Recipes[name] or WepRecipes[name]
    items = CompactItemsIntoRecipeFormat(items)
    if name == "bankcard" then
        print("items: "..BJCore.Common.Dump(items))
    end
    if recipe then
        local hasAll = true
        for r,row in ipairs(recipe.slotRecipe) do
            for i,item in ipairs(row) do
                if item then
                    if not items[r] or (items[r][i] and items[r][i].name ~= item or item == false) then
                        hasAll = false
                        break
                    end
                end
            end
        end
        if hasAll then
            local usbCheck = true
            for r,row in ipairs(recipe.slotRecipe) do
                for i,item in ipairs(row) do
                    if UsbItems[item] then
                        local usbItem = items[r][i]
                        if usbItem.info then
                            if usbItem.info.encrypted then
                                usbCheck = false
                            end
                        end
                    end
                end
            end
            if usbCheck then
                local itemMetadata = {}
                local hasItemsLeft = false
                for r,row in ipairs(recipe.slotRecipe) do
                    for i,item in ipairs(row) do
                        if item then
                            if recipe.itemsToKeep[item] and items[r][i] then
                                pData.Functions.AddItem(items[r][i].name, 1, nil, items[r][i].info)
                            end

                            if type(items[r][i].info) == 'table' then
                                for k,v in pairs(items[r][i].info) do
                                    if recipe.metadataToCopy[k] then
                                        itemMetadata[k] = v
                                    end
                                end
                            end

                            if items[r][i] then
                                if items[r][i].amount > 1 then
                                    items[r][i].amount = items[r][i].amount - 1
                                    hasItemsLeft = true
                                else
                                    items[r][i] = nil
                                end
                            end
                        end
                    end
                end

                for k,v in pairs(recipe.rewards) do
                    if k == "rep" then
                        for rep,amount in pairs(recipe.rewards[k]) do
                            pData.Functions.SetMetaData(rep, pData.PlayerData.metadata[rep]+amount)
                        end
                    else
                        local metadata = nil
                        if recipe.newMetadata and next(recipe.newMetadata) ~= nil and recipe.newMetadata[k] ~= nil then
                            for mKey, mData in pairs(recipe.newMetadata[k]) do
                                itemMetadata[mKey] = mData
                            end
                        end
                        print("itemMetadata: "..BJCore.Common.Dump(itemMetadata))
                        pData.Functions.AddItem(k, v, nil, itemMetadata)
                        TriggerClientEvent('inventory:client:ItemBox', source, BJCore.Shared.Items[k], 'add')
                        TriggerEvent("bj-log:server:CreateLog", "default", "Crafting", "green", "**"..pData.PlayerData.name .. "** has crafted item(s): "..BJCore.Shared.Items[k]['label'].." amount: "..v..".")
                        TriggerClientEvent("BJCore:Notify", source, "You crafted: "..BJCore.Shared.Items[k]['label'], 'primary')
                    end
                end

                local itemsBySlot = {}

                for r,row in ipairs(items) do
                    for i,item in ipairs(row) do
                        if item and item.slot then
                            itemsBySlot[item.slot] = item
                        end
                    end
                end

                TriggerEvent('inventory:server:SetCraftingItems', id, itemsBySlot)
                if hasItemsLeft then
                    Wait(10)
                    TriggerClientEvent('Crafting:ReopenTable', source)
                end
            else
                TriggerClientEvent("BJCore:Notify", source, "This usb is encrypted, you\'re unable to transfer its data", 'error')
            end
        else
            TriggerClientEvent("BJCore:Notify", source, "You failed the recipe: "..name, 'error')
        end
    end
end)

function MFC:TablePlaced(location, ttype)
    local Player = BJCore.Functions.GetPlayer(source)
    local craftingId = #self.CraftingTables+1
    self.CraftingTables[craftingId] = {
        location = location,
        type = ttype,
        owner = Player.PlayerData.citizenid
    }
    exports['ghmattimysql']:execute('INSERT INTO craftingtables (location, owner) VALUES (@location, @owner)',{['@location'] = json.encode({x=location.x,y=location.y,z=location.z,heading=location.w,type=ttype}), ['@owner'] = Player.PlayerData.citizenid}, function()
        exports['ghmattimysql']:execute('SELECT id FROM craftingtables WHERE location=@location',{['@location'] = json.encode({x=location.x,y=location.y,z=location.z,heading=location.w,type=ttype})}, function(result)
            self.CraftingTables[craftingId].id = result[1].id
            TriggerClientEvent('Crafting:SyncTables', -1, self.CraftingTables)
        end)
    end)
    TriggerEvent("bj-log:server:CreateLog", "default", "Crafting", "green", "**"..Player.PlayerData.name .. "** has placed down a crafting table at pos:"..tostring(location))
end

local tableItems = {
    ["reg"] = "regcrafting",
    ["wep"] = "weapcrafting",
}

function MFC:TableRemoved(source, id)
    local selectedTableKey, selectedTable, _source = nil, nil, source
    local Player = BJCore.Functions.GetPlayer(_source)
    if Player == nil then return; end
    for k,v in pairs(self.CraftingTables) do
        if v.id == id then
            selectedTableKey = k
            selectedTable = v
            break
        end
    end

    if selectedTableKey == nil then
        TriggerClientEvent('BJCore:Notify', _source, 'Table does not exist on server', 'error')
        return
    end

    if self.CraftingTables[selectedTableKey].owner ~= Player.PlayerData.citizenid then
        TriggerClientEvent('BJCore:Notify', _source, 'You don\'t own this table', 'error')
        return
    end
    local item = tableItems[self.CraftingTables[selectedTableKey].type]
    if Player.Functions.AddItem(item, 1) then
        TriggerClientEvent('inventory:client:ItemBox', _source, BJCore.Shared.Items[item], "add")
        self.CraftingTables[selectedTableKey] = nil
        exports['ghmattimysql']:execute('DELETE FROM craftingtables WHERE id=@id',{['@id'] = id })
        TriggerClientEvent('Crafting:SyncTables', -1, self.CraftingTables, id)
        TriggerEvent("bj-log:server:CreateLog", "default", "Crafting", "green", "**"..GetPlayerName(_source) .. "** has removed crafting table ID:"..id)
    else
        TriggerClientEvent('BJCore:Notify', _source, 'You don\'t have enough space to pick this up', 'error')
    end
end

BJCore.Functions.RegisterServerCallback('Crafting:CanCraft', function(source, cb, recipe, tabType)
    source = tonumber(source)
    local Player = BJCore.Functions.GetPlayer(source)
    if Player and Recipes[recipe] then
        local currRecipe = Recipes[recipe]
        if currRecipe.type ~= tabType then
            cb(false)
        end
        local canCraft, err = true, nil
        if currRecipe.requires and #currRecipe.requires > 0 then
            for k,v in pairs(currRecipe.requires) do
                if v.type == 'rep' then
                    local currRep = 0
                    if Player.PlayerData.metadata[v.repType] then
                        currRep = Player.PlayerData.metadata[v.repType]
                    elseif Player.PlayerData.metadata['jobrep'] and Player.PlayerData.metadata['jobrep'][v.repType] then
                        currRep = Player.PlayerData.metadata['jobrep'][v.repType]
                    end

                    if v.minimum then
                        if currRep < v.minimum then
                            canCraft, err = false, 'You look at the items but have no idea what to do with them.'
                            break
                        end
                    end
                end
                if v.type == 'job' then
                    local found = false
                    for k,v in pairs(v.jobs) do
                        if Player.PlayerData.job.name == v then
                            found = true
                        end
                    end
                    if not found then
                        canCraft, err = false, "You don't seem to be in the right line of work to do this"
                        break
                    end
                end
            end
        end
        cb(canCraft, err)
    else
        cb(false)
    end
end)

BJCore.Functions.CreateUseableItem("regcrafting", function(source, item) MFC:UseTable(source, item.name); end)
BJCore.Functions.CreateUseableItem("weapcrafting", function(source, item) MFC:UseTable(source, item.name); end)

RegisterNetEvent('Crafting:TablePlaced')
AddEventHandler('Crafting:TablePlaced', function(...) MFC:TablePlaced(...); end)
RegisterNetEvent('Crafting:TableRemoved')
AddEventHandler('Crafting:TableRemoved', function(...) MFC:TableRemoved(source, ...); end)
RegisterNetEvent('Crafting:UseTable')
AddEventHandler('Crafting:UseTable', function(type) MFC:UseTable(source,type); end)

BJCore.Functions.RegisterServerCallback('Crafting:GetStartData', function(source,cb) cb(MFC.CraftingTables, Recipes); end)

RegisterCommand('delcrafting', function(source, args)
	TriggerClientEvent('Crafting:deleteCraftingTable', source)
end, true)

-- RegisterCommand('givebankitem', function(source, args)
--     local Player = BJCore.Functions.GetPlayer(source)
--     Player.Functions.AddItem('blackusb', 1, nil, {
--         ['bank'] = 'FLC001',
--         ['expires'] = os.time() + (24*60*60)
--     })
-- end, true)

Citizen.CreateThread(function(...) MFC:Awake(...); end)

exports('GetRecipes', function()
    return Recipes
end)