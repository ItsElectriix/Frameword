RegisterNetEvent('thermite:takeThermite') 
AddEventHandler('thermite:takeThermite', function(c)   
    local _source = source
    local c = (c or 1)
    local pData = BJCore.Functions.GetPlayer(_source)
    while not pData do pData = BJCore.Functions.GetPlayer(_source); Wait(0); end
    local item = pData.Functions.GetItemByName(cfg.itemName)
    if item and item.amount then
        if item.amount - c < 0 then c = item.amount; end
        pData.Functions.RemoveItem(cfg.itemName,c)
    end 
end)

BJCore.Functions.RegisterServerCallback("thermite:getThermiteCount", function(source, cb)
    local _source = source    
    local pData = BJCore.Functions.GetPlayer(_source)
    while not pData do pData = BJCore.Functions.GetPlayer(_source); Wait(0); end
    local count = 0 
    local item = pData.Functions.GetItemByName(cfg.itemName)
    if item and item.amount then
        count = item.amount
    end
    cb(count)
end)

BJCore.Functions.CreateUseableItem("thermite", function(source, item)
    local Player = BJCore.Functions.GetPlayer(source)
    TriggerClientEvent("thermite:client:onuse", source)
end)