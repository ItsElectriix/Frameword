local OrderIds = {}
local AIOrders = {}
Citizen.CreateThread(function()
	GlobalState.Restaurants = {}
	GlobalState.RestaurantCooks = {}
	GlobalState.RestaurantOrders = {}
	GlobalState.RestaurantAIStatus = {}
	local data = {}
	local cData = {}
	local oData = {}
	local aiData = {}
	for k,v in pairs(Config.Restaurants) do
		data[k] = {}
		data[k].counters = {}
		for i,_ in pairs(v.counterLocations.staff) do
			data[k].counters[i] = {
				order = {},
				process = false,
				paid = false,
				employee = false
			}
		end
		cData[k] = {}
		for station,_ in pairs(v.cookingLocations) do
			cData[k][station] = {}
			for i = 1, 4, 1 do
				cData[k][station][i] = {
					item = false,
					amount = false,
					start = false,
					status = false,
					clean = false,
				}
			end
		end
		oData[k] = {}
		OrderIds[k] = 1
		aiData[k] = false
		AIOrders[k] = 0
	end
	GlobalState.RestaurantAIStatus = aiData
	GlobalState.RestaurantOrders = oData
	GlobalState.RestaurantCooks = cData
	GlobalState.Restaurants = data
	while true do
		local data = CopyTable(GlobalState.RestaurantCooks)
		local changeMade = false
		local burnStation = false
		for restaurant,_ in pairs(Config.Restaurants) do
			for station,v in pairs(Config.Restaurants[restaurant].cookingLocations) do
				for slot, info in pairs(data[restaurant][station]) do
					if info.item then
						if info.status and info.status ~= 4 then
							local elapsedtime = (GetGameTimer()-info.start)/1000
							local totalCookTime = Config.RestaurantCookItems[restaurant][info.item]
							if info.amount > 1 then
								totalCookTime = Config.RestaurantCookItems[restaurant][info.item]+(Config.RestaurantCookItems[restaurant][info.item]*(info.amount-1)/2)
							end
							if info.status == 1 and elapsedtime >= totalCookTime then
								data[restaurant][station][slot].status = 2
								changeMade = true
							elseif info.status == 2 and elapsedtime >= totalCookTime + (totalCookTime*(Config.OvercookAtPercentage/100)) then
								data[restaurant][station][slot].status = 3
								changeMade = true
							elseif info.status == 3 and elapsedtime >= totalCookTime*(Config.BurnAtPercentage/100) then
								data[restaurant][station][slot].status = 4
								changeMade = true
								for k,v in pairs(data[restaurant][station]) do
									data[restaurant][station][k].status = 4
								end
								--TriggerClientEvent("restaurant:client:burnDownStation", restaurant, station)
							end
						end
					end
				end
			end
		end
		if changeMade then
			GlobalState.RestaurantCooks = data
		end
		Citizen.Wait(250)
	end
end)

RegisterNetEvent("restaurant:server:counterAction", function(action, restaurant, counter, orderData)
	local src = source
	local data = CopyTable(GlobalState.Restaurants)
	if action == "update" then
		data[restaurant].counters[counter].order = orderData
	elseif action == "process" then
		data[restaurant].counters[counter].process = CalculateOrderPrice(restaurant, data[restaurant].counters[counter].order)
		local Player = BJCore.Functions.GetPlayer(src)
		data[restaurant].counters[counter].employee = Player.PlayerData.citizenid
	elseif action == "clear" then
		data[restaurant].counters[counter].order = {}
		data[restaurant].counters[counter].process = false
		data[restaurant].counters[counter].paid = false
		data[restaurant].counters[counter].employee = false
	end
	GlobalState.Restaurants = data
end)

RegisterNetEvent("restaurant:server:payAtCounter", function(restaurant, counter)
	local src = source
	local data = CopyTable(GlobalState.Restaurants)
	if not data[restaurant].counters[counter].process then return; end
	local Player = BJCore.Functions.GetPlayer(src)
	if Player then
		if Player.Functions.RemoveMoney("cash", data[restaurant].counters[counter].process) then
			data[restaurant].counters[counter].paid = src
			GlobalState.Restaurants = data
			local metadata = {}
			metadata.employee = data[restaurant].counters[counter].employee
			metadata.amount = data[restaurant].counters[counter].process
			metadata.business = restaurant
			exports["inventory"]:AddToStash("restaurant_"..restaurant.."_management", 1, nil, "receipt", 1, metadata)
			exports["inventory"]:SaveStashItems("restaurant_"..restaurant.."_management")
			local orderData = CopyTable(GlobalState.RestaurantOrders)
			orderData[restaurant][OrderIds[restaurant]] = {order = data[restaurant].counters[counter].order, counter = counter, delivery = false, hidden = false}
			OrderIds[restaurant] = OrderIds[restaurant] + 1
			GlobalState.RestaurantOrders = orderData
		end
	end
end)

AddEventHandler("restaurant:manageCookStash", function(id, items, origin)
	if next(items) == nil or items[1] == nil then return; end
	local stringIds = BJCore.Shared.SplitStr(id, "_")
	exports["inventory"]:RemoveFromStash(id, 1, items[1].name, items[1].amount)
	if Config.RestaurantCookItems[stringIds[2]][items[1].name] ~= nil then
		local data = CopyTable(GlobalState.RestaurantCooks)
		data[stringIds[2]][tonumber(stringIds[4])][tonumber(stringIds[5])] = {
			item = items[1].name,
			amount = items[1].amount,
			start = GetGameTimer(),
			status = 1,
			clean = false,
		}
		GlobalState.RestaurantCooks = data
	else
		local Player = BJCore.Functions.GetPlayer(origin)
		Player.Functions.AddItem(items[1].name, items[1].amount, nil, items[1].info)
		TriggerClientEvent('inventory:client:ItemBox', origin, BJCore.Shared.Items[items[1].name], "add")
		TriggerClientEvent('BJCore:Notify', origin, "You cannot cook this item here", 'error', 4000)
	end
end)

RegisterNetEvent("restaurant:server:completeCook", function(restaurant, station, slot)
	local src = source
	local data = CopyTable(GlobalState.RestaurantCooks)
	if data[restaurant][station][slot].status == 2 then
		local Player = BJCore.Functions.GetPlayer(src)
		if Player then
			Player.Functions.AddItem(data[restaurant][station][slot].item, data[restaurant][station][slot].amount, nil, {["cooked"] = true})
			TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items[data[restaurant][station][slot].item], "add")
			data[restaurant][station][slot] = {
				item = false,
				amount = false,
				start = false,
				status = false,
				clean = false,
			}
			GlobalState.RestaurantCooks = data
		end
	end
end)

RegisterNetEvent("restaurant:server:clearCookingSlot", function(restaurant, station, slot, status)
	local src = source
	local data = CopyTable(GlobalState.RestaurantCooks)
	if status == 3 then
		data[restaurant][station][slot] = {
			item = false,
			amount = false,
			start = false,
			status = false,
			clean = false,
		}
		GlobalState.RestaurantCooks = data
	elseif status == 4 then
		for k,v in pairs(data[restaurant][station]) do
			data[restaurant][station][k] = {
				item = false,
				amount = false,
				start = false,
				status = false,
				clean = false,
			}
		end
		GlobalState.RestaurantCooks = data
	end
end)

RegisterNetEvent("restaurant:server:stopToClean", function(restaurant, station, slot)
	local src = source
	local data = CopyTable(GlobalState.RestaurantCooks)
	if data[restaurant][station][slot].status == 4 then
		for k,v in pairs(data[restaurant][station]) do
			data[restaurant][station][k].clean = GetGameTimer()
		end
	end
	data[restaurant][station][slot].clean = GetGameTimer()
	GlobalState.RestaurantCooks = data
end)

RegisterNetEvent("restaurant:server:removeActiveOrder", function(restaurant, id)
	local src = source
	local orderData = CopyTable(GlobalState.RestaurantOrders)
	if orderData[restaurant][id] ~= nil then
		if orderData[restaurant][id].delivery then
			local Player = BJCore.Functions.GetPlayer(src)
			if Player then
				TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items["deliveryreceipt"], "add")
				Player.Functions.AddItem("deliveryreceipt", 1, nil, {
					id = id,
					delivery = GetRandomDeliveryLocation(),
					restaurant = restaurant
				})
				orderData[restaurant][id].hidden = true
			end
		else
			orderData[restaurant][id] = nil
		end
		TriggerClientEvent("restaurant:client:removeActiveOrder", -1, id)
	end
	GlobalState.RestaurantOrders = orderData
end)

function GetRandomDeliveryLocation()
	return math.random(#Config.AIDeliveryLocations)
end

RegisterNetEvent("restaurant:server:toggleAIDeliveries", function(restaurant)
	local src = source
	local Player = BJCore.Functions.GetPlayer(src)
	if Player then
		if Player.PlayerData.job.name ~= restaurant then return; end
		local AIStatus = CopyTable(GlobalState.RestaurantAIStatus)
		if AIStatus[restaurant] then
			AIStatus[restaurant] = false
			TriggerClientEvent('BJCore:Notify', src, "Delivery orders now not being accepted", 'primary')
		else
			AIStatus[restaurant] = math.random(Config.AIOrdersFrequency[1], Config.AIOrdersFrequency[2])
			AIOrders[restaurant] = GetGameTimer()
			TriggerClientEvent('BJCore:Notify', src, "Now receiving delivery orders", 'primary')
		end
		GlobalState.RestaurantAIStatus = AIStatus
	end
end)

RegisterNetEvent("restaurant:client:deliverOrder", function(deliveryData)
	local src = source
	local Player = BJCore.Functions.GetPlayer(src)
	local targetDeliveryReceipt = false
	for k,v in pairs(Player.PlayerData.items) do
		if v.name == "deliveryreceipt" then
			if v.info and v.info.id == deliveryData.id then
				targetDeliveryReceipt = Player.PlayerData.items[k]
				break
			end
		end
	end
	if Player then
		if targetDeliveryReceipt then
			local found = false
			local orderData = CopyTable(GlobalState.RestaurantOrders)
			local itemOrder = orderData[deliveryData.restaurant][deliveryData.id].order
			local hasAll = true
			local missingItem = false
			for k,v in pairs(orderData[deliveryData.restaurant][deliveryData.id].order) do
				local amountRequired = v
				for itemIndex,data in pairs(Player.PlayerData.items) do
					if data.name == k then
						if data.info and type(data.info.cooked) == "boolean" then
							if data.info.cooked then
								if amountRequired > 0 and data.amount <= amountRequired then
									amountRequired = amountRequired - data.amount
								end
							end
						else
							if amountRequired > 0 and data.amount <= amountRequired then
								amountRequired = amountRequired - data.amount
							end
						end
					end
				end
				if amountRequired > 0 then
					missingItem = k
					hasAll = false
					break
				end
			end
			if hasAll then
				for k,v in pairs(orderData[deliveryData.restaurant][deliveryData.id].order) do
					Player.Functions.RemoveItem(k, v)
				end
				Player.Functions.RemoveItem("deliveryreceipt", 1, targetDeliveryReceipt.slot)
				TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items["deliveryreceipt"], "remove")
				TriggerClientEvent('BJCore:Notify', src, "Delivery complete", 'success', 4000)
				TriggerClientEvent("restaurant:client:completeDelivery", src, deliveryData)
				local metadata = {}
				metadata.employee = "delivery"
				metadata.amount = CalculateOrderPrice(deliveryData.restaurant, itemOrder)
				metadata.business = deliveryData.restaurant
				exports["inventory"]:AddToStash("restaurant_"..deliveryData.restaurant.."_management", 1, nil, "receipt", 1, metadata)
				exports["inventory"]:SaveStashItems("restaurant_"..deliveryData.restaurant.."_management")
				orderData = CopyTable(GlobalState.RestaurantOrders)
				orderData[deliveryData.restaurant][deliveryData.id] = nil
				GlobalState.RestaurantOrders = orderData
			else
				--TriggerClientEvent('BJCore:Notify', src, "You don't have the required items for this delivery", 'error', 4000)
				TriggerClientEvent('BJCore:Notify', src, "You don't have enough "..BJCore.Shared.Items[missingItem].label.."(s) for this delivery or you have uncooked items", 'error', 8000)
			end
		else
			TriggerClientEvent('BJCore:Notify', src, "You don't have the required delivery receipt", 'error', 4000)
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		for k,v in pairs(GlobalState.RestaurantAIStatus) do
			if v then
				if GetGameTimer() - AIOrders[k] >= (v * 1000) then
					print("adding order for: "..tostring(k))
					AIOrders[k] = GetGameTimer()
					CreateAIOrder(k)
				end
			end
		end
		Citizen.Wait(10000)
	end
end)

function CreateAIOrder(restaurant)
	local orderAmount = math.random(1, 3)
	local menuList = {}
	for k,v in pairs(Config.RestaurantMenu[restaurant]) do
		table.insert(menuList, k)
	end
	local totalIndex = #menuList
	local itemsSelected = 0
	local createdOrder = {}
	while itemsSelected ~= orderAmount do
		local selected = math.random(1, totalIndex)
		if not createdOrder[menuList[selected]] then
			createdOrder[menuList[selected]] = true
			itemsSelected = itemsSelected + 1
		end
		Wait(1)
	end
	for k,v in pairs(createdOrder) do
		local chance = math.random(100)
		local amount = 1
		if chance >= 85 then
			amount = 2
		end
		createdOrder[k] = amount
	end
	local orderData = CopyTable(GlobalState.RestaurantOrders)
	orderData[restaurant][OrderIds[restaurant]] = {order = createdOrder, counter = false, delivery = OrderIds[restaurant]}
	OrderIds[restaurant] = OrderIds[restaurant] + 1
	GlobalState.RestaurantOrders = orderData
end

BJCore.Functions.CreateUseableItem("deliveryreceipt", function(source, item)
    local Player = BJCore.Functions.GetPlayer(source)
    TriggerClientEvent("restaurant:client:markForDelivery", source, item.info)
end)

RegisterNetEvent("restaurant:server:processReceipts", function(restaurant)
	local src = source
	local Player = BJCore.Functions.GetPlayer(src)
	if Player then
		if Player.PlayerData.job.name ~= restaurant then return; end
		if Player.Functions.GetItemAmountByName("receipt") > 0 then
			local totalAmount = 0
			for k,v in pairs(Player.PlayerData.items) do
				if v.name == "receipt" and v.info then
					if v.info and v.info.business == restaurant then
						if Player.Functions.RemoveItem(v.name, 1, v.slot) then
							totalAmount = totalAmount + v.info.amount
							TriggerEvent('moneysafe:server:DepositMoneyDirect', restaurant, totalAmount, "bills")
						end
					end
				end
			end
			if totalAmount > 0 then
				TriggerClientEvent('BJCore:Notify', src, "You have processed "..BJCore.Config.Currency.Symbol..totalAmount, 'primary', 10000)
			end
		else
			TriggerClientEvent('BJCore:Notify', src, "No receipt items found on you", 'error')
		end
	end
end)

BJCore.Commands.Add("givecashcarrycard", "Give cash and carry card to target player", {{name="id", help="ID of player"}, {name="job", help="Job linked to card"}}, true, function(source, args)
    local Target = BJCore.Functions.GetPlayer(tonumber(args[1]))
    if Target then
    	args[2] = args[2]:lower()
    	if BJCore.Shared.Jobs[args[2]] ~= nil then
	    	if Target.Functions.AddItem("cashcarrycard", 1, nil, {job = args[2]}) then
		    	TriggerClientEvent('inventory:client:ItemBox', tonumber(args[1]), BJCore.Shared.Items["cashcarrycard"], 'add')
		    	TriggerClientEvent("BJCore:Notify", source, "Cash & Card successfully given to "..GetPlayerName(tonumber(args[1])).." ("..args[1]..")", "success", 5000)
		    end
	    else
	    	TriggerClientEvent("BJCore:Notify", source, args[2].." job not found", "error")
	    end
    else
    	TriggerClientEvent("BJCore:Notify", source, "Player not found", "error")
    end
end, "god")

BJCore.Functions.RegisterServerCallback("restaurant:server:getCashCarryItem", function(source, cb)
	local Player = BJCore.Functions.GetPlayer(source)
	if Player then
		local item = Player.Functions.GetItemByName("cashcarrycard")
		if item ~= nil then
			cb(item.info.job and item.info.job or false)
		else
			cb(false)
		end
	end
end)