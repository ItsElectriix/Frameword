BulkSalePrices = {
    ["weed_white-widow"] = { -- items that can be sold in bulk. if the player has any of these items it'll add it to an active order
    	reward = {
    		["cashroll"] = 1, -- ["item name"] = amount
    	}
    },
	["skunkbag"] = { -- items that can be sold in bulk. if the player has any of these items it'll add it to an active order
    	reward = {
    		["cashroll"] = 2, -- ["item name"] = amount
    	}
    },
	["hazebag"] = { -- items that can be sold in bulk. if the player has any of these items it'll add it to an active order
    	reward = {
    		["cashroll"] = 3, -- ["item name"] = amount
    	}
    },
	["cokebaggy"] = { -- items that can be sold in bulk. if the player has any of these items it'll add it to an active order
    	reward = {
    		["cashroll"] = 10, -- ["item name"] = amount
    	}
    },
	["methbag"] = { -- items that can be sold in bulk. if the player has any of these items it'll add it to an active order
    	reward = {
    		["cashroll"] = 6, -- ["item name"] = amount
    	}
    },
	["heroinsyringe"] = { -- items that can be sold in bulk. if the player has any of these items it'll add it to an active order
    	reward = {
    		["cashroll"] = 8, -- ["item name"] = amount
    	}
    },
}

local activeSales = {}

BJCore.Functions.RegisterServerCallback("bulksale:server:getitems", function(source, cb)
	local Player = BJCore.Functions.GetPlayer(source)
	if Player ~= nil then
		activeSales[source] = {}
		for k,v in pairs(BulkSalePrices) do
			print("item: "..k)
			local item = Player.Functions.GetItemByName(k)
			if item ~= nil then
				activeSales[source][item.name] = item.amount
			end
		end
	end
	if next(activeSales[source]) == nil then
		cb(false)
	else
		cb(activeSales[source])
	end
end)

RegisterNetEvent("bulksale:server:deliver")
AddEventHandler("bulksale:server:deliver", function()
	local src = source
	local Player = BJCore.Functions.GetPlayer(src)
	local foundall = true
	if Player ~= nil then
		if activeSales[src] ~= nil then
			for k,v in pairs(activeSales[src]) do
				local item = Player.Functions.GetItemByName(k)
				if item ~= nil then
					if item.amount < v then
						foundall = false
						break
					end
				end
			end
			if foundall then
				for k,v in pairs(activeSales[src]) do
					if Player.Functions.RemoveItem(k, v) then
			            TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items[k], "remove")
			            for item,amount in pairs(BulkSalePrices[k].reward) do
				            Player.Functions.AddItem(item, amount*v)
				            TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items[item], "add")
			            end
					end
				end
			else
				TriggerClientEvent('BJCore:Notify',src, "You don't have what was initially agreed. Sale cancelled",'error')
			end
		else
			TriggerClientEvent('BJCore:Notify',src, "You have no active order",'error')
		end
	end
end)