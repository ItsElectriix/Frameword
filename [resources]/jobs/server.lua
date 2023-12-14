RegisterNetEvent('jobs:server:GetJobRep')
AddEventHandler('jobs:server:GetJobRep', function()
	local src = source
	local Player = BJCore.Functions.GetPlayer(src)
	TriggerClientEvent('jobs:client:GetJobRep', src, Player.PlayerData.metadata["jobrep"])
end)

RegisterNetEvent('jobs:server:AddJobRep')
AddEventHandler('jobs:server:AddJobRep', function(job, amount)
	local src = source
	local Player = BJCore.Functions.GetPlayer(src)
	Player.Functions.AddJobReputation(job, amount)
end)

RegisterNetEvent('delivery:reward')
AddEventHandler('delivery:reward', function(loc)
	local src = source
	if not Config.DeliveryDestinations[loc] or loc == nil or Config.DeliveryDestinations[loc] == nil then
		TriggerEvent("animalcrossing:server:banPlayer", "Event abuse detected: delivery:reward", src)
		return
	end
	
	local Player = BJCore.Functions.GetPlayer(src)
	
	local reward = Config.DeliveryDestinations[loc].money

	if Player.PlayerData.metadata["jobrep"]["delivery"] then
		if Player.PlayerData.metadata["jobrep"]["delivery"] > 70 then
			reward = reward * 1.05
		elseif Player.PlayerData.metadata["jobrep"]["delivery"] > 50 then
			reward = reward * 0.95
		elseif Player.PlayerData.metadata["jobrep"]["delivery"] > 30 then
			reward = reward * 0.80
		elseif Player.PlayerData.metadata["jobrep"]["delivery"] > 10 then
			reward = reward * 0.70
		elseif Player.PlayerData.metadata["jobrep"]["delivery"] < 10 then
			reward = reward * 0.60	
		end
	end

	local chance = math.random(100)
	if Player.PlayerData.metadata["jobrep"]["delivery"] < 30 then
		if chance <= 20 then
			reward = false
		end
	end
	if reward then
		Player.Functions.AddMoney("cash", math.floor(reward))
		TriggerClientEvent('BJCore:Notify', src, "You received "..BJCore.Config.Currency.Symbol..math.floor(reward), "success")
		TriggerEvent("bj-log:server:CreateLog", "default", "Jobs: Delivery", "green", "**"..Player.PlayerData.name .. "** has been paid "..BJCore.Config.Currency.Symbol..math.floor(reward).." for completing a delivery.")
		if math.random(1, 100) <= 35 then
			Player.Functions.AddJobReputation('delivery', math.random(1, 2))
		end
	else
		TriggerClientEvent('BJCore:Notify', src, "The client reported something wrong with this package. You won't be paid for this delivery!", "error")
	end
end)

local trash = {
	'casinochips',
	'lighter',
	'painkillers',
	'twix_bar',
	'beer',
	'rolling_paper',
	'empty_evidence_bag',
	'walkstick',
}

RegisterNetEvent('fishing:reward')
AddEventHandler('fishing:reward', function(item, amount)
	local src = source
	if item == nil or amount == nil then TriggerEvent("animalcrossing:server:banPlayer", "Event abuse detected: fishing:reward", src) return; end
	if not (item == "trash" or item == "fish") then TriggerEvent("animalcrossing:server:banPlayer", "Event abuse detected: fishing:reward - item = "..tostring(item), src) return; end
	local Player = BJCore.Functions.GetPlayer(src)
	local itemtorward = nil
	if item == 'trash' then
		itemtorward = trash[math.random(1,#trash)]
        TriggerClientEvent('BJCore:Notify', src, "You reeled in some random trash. What is this, the Thames?", "error")
        TriggerEvent("bj-log:server:CreateLog", "default", "Jobs: Fishing", "green", "**"..Player.PlayerData.name .. "** has found (trash item) "..BJCore.Shared.Items[itemtorward]['label'].." amount: "..amount.." while fishing.")
	elseif item == 'fish' then
        itemtorward = 'fish'
        TriggerClientEvent('BJCore:Notify', src, "You caught a fish! Well done!", "success")
        TriggerEvent("bj-log:server:CreateLog", "default", "Jobs: Fishing", "green", "**"..Player.PlayerData.name .. "** has caught x"..amount.." fish(s)")
	end
	Player.Functions.AddItem(itemtorward, amount)
    for i = 1, amount, 1 do
    	TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items[itemtorward], "add")
    end	
end)

local pedList = {
    [`a_c_coyote`] = 2,
    [`a_c_chimp`] = 1,
    [`a_c_chickenhawk`] = 1,
    [`a_c_hen`] = 1,
    [`a_c_boar`] = 2,
    [`a_c_chop`] = 1,
    [`a_c_cormorant`] = 1,
    --[`a_c_cow`] = 3,
    [`a_c_crow`] = 1,
    [`a_c_deer`] = 2,
    [`a_c_fish`] = 1,
    [`a_c_husky`] = 1,
    [`a_c_mtlion`] = 2,
    [`a_c_pig`] = 2,
    [`a_c_pigeon`] = 1,
    [`a_c_rat`] = 1,
    [`a_c_retriever`] = 1,
    [`a_c_rhesus`] = 1,
    [`a_c_rottweiler`] = 1,
    [`a_c_seagull`] = 1,
    [`a_c_sharktiger`] = 1,
    [`a_c_shepherd`] = 1,
    [`a_c_sharkhammer`] = 1,
    [`a_c_rabbit_01`] = 1,
    [`a_c_cat_01`] = 1,
    [`a_c_killerwhale`] = 2
}

local pelts = {
	[1] = 'cougar_pelt',
	[2] = 'rabbit_pelt',
	[3] = 'deer_pelt'
}

RegisterNetEvent('hunting:reward')
AddEventHandler('hunting:reward', function(animal, hide)
	local src = source
	if animal == nil or pedList[animal] == nil then TriggerEvent("animalcrossing:server:banPlayer", "Event abuse detected: hunting:reward", src) return; end
	local Player = BJCore.Functions.GetPlayer(src)
	local amount = 1
	if pedList[animal] ~= 1 then
		amount = math.random(1,pedList[animal])
	end
	if hide then
		local peltitem = pelts[math.random(1, #pelts)]
		Player.Functions.AddItem(pelts[math.random(1, #pelts)], 1)
		TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items[peltitem], "add")
		TriggerEvent("bj-log:server:CreateLog", "default", "Jobs: Hunting", "green", "**"..Player.PlayerData.name .. "** has looted (rare) x1 "..BJCore.Shared.Items[peltitem]['label'].." while hunting.")
    end
    if amount > 0 then
		Player.Functions.AddItem('rawmeat', amount)
		TriggerClientEvent('BJCore:Notify', src, "Meat recovered successfully!", "success")
		TriggerEvent("bj-log:server:CreateLog", "default", "Jobs: Hunting", "green", "**"..Player.PlayerData.name .. "** has looted x"..amount.." Raw Meat while hunting.")
	    for i = 1, amount, 1 do
	    	TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items["rawmeat"], "add")
	    end
	end
end)


local Deposits = {}

BJCore.Functions.RegisterServerCallback('hotdogjob:server:HasMoney', function(source, cb)
    local Player = BJCore.Functions.GetPlayer(source)

    if Player.PlayerData.money.cash >= Config.Deposit then
        Player.Functions.RemoveMoney('cash', Config.Deposit)
        Deposits[Player.PlayerData.citizenid] = true
        TriggerEvent("bj-log:server:CreateLog", "default", "Jobs: Hotdog", "green", "**"..Player.PlayerData.name .. "** has paid "..BJCore.Config.Currency.Symbol..Config.Deposit.." deposit for a hotdog stand from their **cash**.")
        cb(true)
    elseif Player.PlayerData.money.bank >= Config.Deposit then
        Player.Functions.RemoveMoney('bank', Config.Deposit)
        Deposits[Player.PlayerData.citizenid] = true
        TriggerEvent("bj-log:server:CreateLog", "default", "Jobs: Hotdog", "green", "**"..Player.PlayerData.name .. "** has paid "..BJCore.Config.Currency.Symbol..Config.Deposit.." deposit for a hotdog stand from their **bank**.")
        cb(true)
    else
        Deposits[Player.PlayerData.citizenid] = false
        cb(false)
    end
end)

BJCore.Functions.RegisterServerCallback('hotdogjob:server:BringBack', function(source, cb)
    local Player = BJCore.Functions.GetPlayer(source)

    if Deposits[Player.PlayerData.citizenid] then
        Player.Functions.AddMoney('cash', Config.Deposit)
        TriggerEvent("bj-log:server:CreateLog", "default", "Jobs: Hotdog", "green", "**"..Player.PlayerData.name .. "**'s Deposit of "..BJCore.Config.Currency.Symbol..Config.Deposit.." has been returned to their **cash** balance.")
        cb(true)
    else
        cb(false)
    end
end)

RegisterServerEvent('hotdogjob:server:Sell')
AddEventHandler('hotdogjob:server:Sell', function(Amount, Price)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local rewardAmount = tonumber(Amount * Price)
    Player.Functions.AddMoney('cash', rewardAmount)
    TriggerEvent("bj-log:server:CreateLog", "default", "Jobs: Hotdog", "green", "**"..Player.PlayerData.name .. "** has sold x"..Amount.." hotdogs for "..BJCore.Config.Currency.Symbol..rewardAmount..".")
end)

local Reset = false

RegisterServerEvent('hotdogjob:server:UpdateReputation')
AddEventHandler('hotdogjob:server:UpdateReputation', function(quality)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local JobReputation = Player.PlayerData.metadata["jobrep"]
    
    if Reset then
        JobReputation["hotdog"] = 0
        Player.Functions.SetMetaData("jobrep", JobReputation)
        TriggerClientEvent('hotdogjob:client:UpdateReputation', src, JobReputation)
        return
    end

    local chance = math.random(100)
    if chance < 25 then 
	    if quality == "exotic" then
	        if JobReputation["hotdog"] ~= nil and JobReputation["hotdog"] + 3 > Config.MaxReputation then
	            JobReputation["hotdog"] = Config.MaxReputation
	            Player.Functions.SetMetaData("jobrep", JobReputation)
	            TriggerClientEvent('hotdogjob:client:UpdateReputation', src, JobReputation)
	            return
	        end
	        if JobReputation["hotdog"] == nil then
	            JobReputation["hotdog"] = 3
	        else
	            JobReputation["hotdog"] = JobReputation["hotdog"] + 3
	        end
	    elseif quality == "rare" then
	        if JobReputation["hotdog"] ~= nil and JobReputation["hotdog"] + 2 > Config.MaxReputation then
	            JobReputation["hotdog"] = Config.MaxReputation
	            Player.Functions.SetMetaData("jobrep", JobReputation)
	            TriggerClientEvent('hotdogjob:client:UpdateReputation', src, JobReputation)
	            return
	        end
	        if JobReputation["hotdog"] == nil then
	            JobReputation["hotdog"] = 2
	        else
	            JobReputation["hotdog"] = JobReputation["hotdog"] + 2
	        end
	    elseif quality == "common" then
	        if JobReputation["hotdog"] ~= nil and JobReputation["hotdog"] + 1 > Config.MaxReputation then
	            JobReputation["hotdog"] = Config.MaxReputation
	            Player.Functions.SetMetaData("jobrep", JobReputation)
	            TriggerClientEvent('hotdogjob:client:UpdateReputation', src, JobReputation)
	            return
	        end
	        if JobReputation["hotdog"] == nil then
	            JobReputation["hotdog"] = 1
	        else
	            JobReputation["hotdog"] = JobReputation["hotdog"] + 1
	        end
	    end
	    Player.Functions.SetMetaData("jobrep", JobReputation)
	    TriggerClientEvent('hotdogjob:client:UpdateReputation', src, JobReputation)
	    local c = math.random(1,3)
	    if c == 1 then
		    TriggerClientEvent('BJCore:Notify', src, "You're becoming one with the hotdog", "primary")
		elseif c == 2 then
			TriggerClientEvent('BJCore:Notify', src, "That weiner is looking pretty tasty", "primary")
		else
            TriggerClientEvent('BJCore:Notify', src, "Keep it going! Those hot dogs are looking great!", "primary")
		end
	end
end)

BJCore.Commands.Add("removestand", "", {}, false, function(source, args)
    TriggerClientEvent('hotdogjob:staff:DeletStand', source)
end, 'mod')

BJCore.Commands.Add("setjobrep", "ID of target player", {{name="id", help="ID of target player"}}, true, function(source, args)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local Target = BJCore.Functions.GetPlayer(tonumber(args[1]))
    if Target ~= nil then
    	local jobRep = Target.PlayerData.metadata["jobrep"]
		if jobRep[args[2]] ~= nil then
			jobRep[args[2]] = tonumber(args[3])
			Target.Functions.SetMetaData("jobrep", jobRep)
		end
    end
end, 'god')

local RecycleTracker = {}

Citizen.CreateThread(function( ... )
	while BJCore == nil do Citizen.Wait(250); end
	while true do
		Citizen.Wait(60 * 60 * 1000 * 2) -- refresh every 2 hours
		resetTasks()
	end
end)

function resetTasks()
	for k,v in pairs(RecycleTracker) do
		RecycleTracker[k] = 10
	end
end
RegisterNetEvent('recycle:server:AddCitizen')
AddEventHandler('recycle:server:AddCitizen', function()
	local src = source
	local Player = BJCore.Functions.GetPlayer(src)
	if not RecycleTracker[Player.PlayerData.citizenid] then
		RecycleTracker[Player.PlayerData.citizenid] = 1
	end
end)

BJCore.Functions.RegisterServerCallback('recycle:server:CheckAvailableTasks', function(source, cb)
	local src = source
	local Player = BJCore.Functions.GetPlayer(src)
	if RecycleTracker[Player.PlayerData.citizenid] and RecycleTracker[Player.PlayerData.citizenid] > 0 then
		cb(RecycleTracker[Player.PlayerData.citizenid])
	else
		cb(false)
	end
end)

RegisterNetEvent('recycle:server:RemoveTask')
AddEventHandler('recycle:server:RemoveTask', function()
	local src = source
	local Player = BJCore.Functions.GetPlayer(src)
	RecycleTracker[Player.PlayerData.citizenid] = RecycleTracker[Player.PlayerData.citizenid] - 1
end)

local ItemTable = {
    "metalscrap",
    "plastic",
    "copper",
    "iron",
    "aluminum",
    "steel",
    "glass",
}

RegisterServerEvent("recycle:server:getItem")
AddEventHandler("recycle:server:getItem", function()
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local rewards = {}
    for i = 1, math.random(1, 3), 1 do
        local randItem = ItemTable[math.random(1, #ItemTable)]
        local amount = math.random(0,1)
        if amount > 0 then
	        Player.Functions.AddItem(randItem, amount)
	        TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items[randItem], 'add')
            table.insert(rewards, {item = BJCore.Shared.Items[randItem].label, amount = amount})
	        Citizen.Wait(500)
	    end
    end

    local Luck = math.random(1, 10)
    local Odd = math.random(1, 10)
    if Luck == Odd then
        local random = math.random(1, 3)
        Player.Functions.AddItem("rubber", random)
        TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items["rubber"], 'add')
        table.insert(rewards, {item = BJCore.Shared.Items["rubber"].label, amount = random})
    end
    TriggerEvent("bj-log:server:CreateLog", "default", "Jobs: Recycling", "green", "**"..Player.PlayerData.name .. "** has been rewarded "..BJCore.Common.Dump(rewards).." | Tasks remaining: "..RecycleTracker[Player.PlayerData.citizenid])
end)

local SmelterJobs = {}

Citizen.CreateThread(function( ... )
	while BJCore == nil do Citizen.Wait(250); end
    SmelterJobs = Config.DefaultSmelter
end)

RegisterNetEvent('smelter:server:DoOrder')
AddEventHandler('smelter:server:DoOrder', function(player, items, id)
	local Player = BJCore.Functions.GetPlayer(player)
	if next(SmelterJobs[id].items) ~= nil then
		TriggerClientEvent('BJCore:Notify', player, "Someone has already placed an order in slot "..id..". Order cancelled", "error")
		for k,v in pairs(items) do
	        Player.Functions.AddItem(v.name, v.amount, v.slot, v.info or nil)
		end
	elseif canSmeltItem(items[1]) then
		local itemData = {name = items[1].name, amount = items[1].amount, info = items[1].info or nil}
        SmelterJobs[id].items = itemData
        local name = items[1].name
        if items[1].name == "washedstone" then
            name = items[1].info.item
        end
        local timer = Config.SmeltConfig[name].time * items[1].amount
        SmelterJobs[id].timer = math.floor(timer * math.pow(0.98, itemData.amount))
        SmelterJobs[id].ready = false
        TriggerClientEvent('smelter:client:SyncSmeltData', -1, SmelterJobs)
		TriggerClientEvent('BJCore:Notify', player, "Smelt order successfully placed in slot "..id.." ("..BJCore.Shared.Items[items[1].name].label.." x"..items[1].amount..")", "success")
		TriggerEvent("bj-log:server:CreateLog", "default", "Jobs: Smelter Started (Slot: "..tostring(id)..")", "green", "**".. GetPlayerName(player) .. " started a smelting order ("..BJCore.Shared.Items[items[1].name].label.." x"..items[1].amount..")")
	else
		TriggerClientEvent('BJCore:Notify', player, "You can't smelt this item. Order cancelled", "error")
        Player.Functions.AddItem(items[1].name, items[1].amount, items[1].slot, items[1].info or nil)
	end
end)

BJCore.Functions.RegisterServerCallback('smelter:server:CanPay', function(source, cb)
	-- can player afford to smelt
end)

BJCore.Functions.RegisterServerCallback('smelter:server:CollectOrder', function(source, cb, id)
	local toExchange = {}
	local data = {
		canCollect = false,
		items = {}
	}

	if next(SmelterJobs[id].items) ~= nil then
		toExchange = SmelterJobs[id].items
		SmelterJobs[id].items = {}
		SmelterJobs[id].timer = 0
		SmelterJobs[id].ready = false
		TriggerClientEvent('smelter:client:SyncSmeltData', -1, SmelterJobs, id)
		local totalRewards = 0
		if Config.SmeltConfig[toExchange.name] ~= nil and Config.SmeltConfig[toExchange.name].trade then
			for i = 0, #Config.SmeltConfig[toExchange.name].trade - 1 do
				local am = Config.SmeltConfig[toExchange.name].trade[i+1].amount * toExchange.amount
				totalRewards = totalRewards + am
				table.insert(data.items, {
					name = Config.SmeltConfig[toExchange.name].trade[i+1].item,
					amount = am,
					info = {},
					type = "item",
	                slot = i+1
				})
			end
			data.canCollect = true
		elseif toExchange.name == "washedstone" then
			totalRewards = toExchange.info.amount
			table.insert(data.items, {
				name = toExchange.info.item,
				amount = totalRewards,
				info = {},
				type = "item",
                slot = 1,
			})
			data.canCollect = true
		end
		cb(data)
		TriggerEvent("bj-log:server:CreateLog", "default", "Jobs: Smelter Collected (Slot: "..tostring(id)..")", "orange", "**".. GetPlayerName(source) .. " collected a smelting order ("..totalRewards.." total items rewarded)")
	else
		cb(data)
	end
end)

function canSmeltItem(item)
	local can = false
	if Config.SmeltConfig[item.name] and Config.SmeltConfig[item.name] ~= nil then; can = true; end
	if item.name == "washedstone" then
		if item.info and item.info.item ~= nil then
			if Config.SmeltConfig[item.info.item] and Config.SmeltConfig[item.info.item] ~= nil then
				can = true
			end
		end
	end
	return can
end

exports('canSmeltItem', canSmeltItem);

RegisterNetEvent('smelter:server:GetSmeltData')
AddEventHandler('smelter:server:GetSmeltData', function() TriggerClientEvent('smelter:client:SyncSmeltData', source, SmelterJobs); end)

-- Craftsman
local orders, ready = {}, false

function Awake(update)
	BJCore.Functions.ExecuteSql(true, "SELECT * FROM `craftsman_orders`", function(data)
	    if data and data[1] then
	        for k,v in pairs(data) do
	            orders[v.id] = {id = v.id, cid = v.citizenid, item = v.item, time = v.ordered_on, ready = v.ready, buildTime = v.build_time}
	        end
	        ready = true
	    end
	    if update then Update(); end		
	end)
end

function Update(...)
    while not ready do Citizen.Wait(0); end
    CheckOrders()
    while true do Wait(60 * 1000); CheckOrders() end 
end

function CheckOrders(...)
    local curTime = os.time()
    for k,v in pairs(orders) do
        local diff = curTime - v.time
        if diff >= v.buildTime * 60 and v.ready == 0 then
        	BJCore.Functions.ExecuteSql(false, "UPDATE `craftsman_orders` SET `ready` ='1' WHERE `id` = '"..k.."'")
            orders[k].ready = 1
            local maildata = {
				sender = "Craftsman",
				subject = "Re: Order No. "..v.id,
				message = "Your order: "..v.id.." is ready for collection. <br />Please make sure you have enough space to carry your "..BJCore.Shared.Items[v.item].label.." <br /><br />See you soon!",

            }
            TriggerEvent("phone:server:sendNewMailToOffline", v.cid, maildata)
        end
    end
end

RegisterNetEvent("carpenter:server:getPlayerOrders")
AddEventHandler("carpenter:server:getPlayerOrders", function()
    local _source = source
    local Player = BJCore.Functions.GetPlayer(_source)
    local clientOrders = {}
    local curTime = os.time()
    for k,v in pairs(orders) do
        if v.cid == Player.PlayerData.citizenid then
            local completeAt = v.time + v.buildTime * 60
            local diff = completeAt - curTime
            clientOrders[k] = {item = v.item, ready = v.ready, id = v.id, timeLeft = diff}
        end
    end
    if next(clientOrders) == nil then TriggerClientEvent('BJCore:Notify', _source, "You have no current orders", "primary")
    else 
    	for k,v in pairs(clientOrders) do
    		local rdyText = "Ready for collection"
    		if v.ready == 0 then rdyText = "Not ready"; end
    		TriggerClientEvent('BJCore:Notify', _source, "Order #: "..v.id.." | Item: "..BJCore.Shared.Items[v.item].label.." | "..rdyText, "primary", 6000)
    	end 
        TriggerClientEvent('BJCore:Notify', _source, "Use /craftcollect to collect orders", "primary")
    end
end)

RegisterNetEvent("carpenter:server:giveOrder")
AddEventHandler("carpenter:server:giveOrder", function(orderKey)
    local _source = source
    local Player = BJCore.Functions.GetPlayer(_source)
    if orders[orderKey] then
    	if orders[orderKey].cid == Player.PlayerData.citizenid then
    		if orders[orderKey].ready == 1 then
			    if Player.Functions.AddItem(orders[orderKey].item, 1) then
			    	TriggerClientEvent('inventory:client:ItemBox', _source, BJCore.Shared.Items[orders[orderKey].item], "add")
			        TriggerClientEvent('BJCore:Notify', _source, "Order #: "..orderKey.." has been collected", "primary")
					TriggerEvent("bj-log:server:CreateLog", "default", "Craftsman", "green", "**"..Player.PlayerData.name .. "** has collected order #"..orderKey.." item: "..BJCore.Shared.Items[orders[orderKey].item].label)
			        orders[orderKey] = nil
			        BJCore.Functions.ExecuteSql(false, "DELETE FROM `craftsman_orders` WHERE `id` = '"..orderKey.."'")
			    else
			    	TriggerClientEvent('BJCore:Notify', _source, "You don't have enough space to collect this item", "error")
			    end
			else
				TriggerClientEvent('BJCore:Notify', _source, "This order isn't ready for collection", "error")
			end
		else
			TriggerClientEvent('BJCore:Notify', _source, "This order isn't yours", "error")
		end
	else
		TriggerClientEvent('BJCore:Notify', _source, "Order not found", "error")
	end
end)

RegisterServerEvent('carpenter:server:orderItem')
AddEventHandler('carpenter:server:orderItem', function(cKey)
    local _source = tonumber(source)
    local Player = BJCore.Functions.GetPlayer(_source)
    local hasAll = true
    local hasCash = true
    for k,v in pairs(Config.CraftsManItmes[cKey]["items"]) do
        if v then 
            if Player.Functions.GetItemByName(k) == nil then
            	hasAll = false
            else
            	local count = Player.Functions.GetItemByName(k).amount
	            if count == nil or count < v then
	                hasAll = false
	            end
	        end
        end
    end
    if Config.CraftsManItmes[cKey]["cash"] then
        local cash = Player.PlayerData.money["cash"]
        if cash < Config.CraftsManItmes[cKey]["cash"] then
            hasCash = false
        end
    end
    if not hasAll then 
    	TriggerClientEvent('BJCore:Notify', _source, "You don't have enough materials to order this item", "error")
    	local text = Config.CraftsManItmes[cKey]["name"].." Required Materials:"
    	for k,v in pairs(Config.CraftsManItmes[cKey]["items"]) do
    		local item = k
            text = text.." | Item: "..BJCore.Shared.Items[item].label.." x"..v
    	end
    	TriggerClientEvent("chatMessage", _source, "SYSTEM", "warning", text)
    	if Config.CraftsManItmes[cKey]["cash"] then
	    	TriggerClientEvent("chatMessage", _source, "SYSTEM", "warning", Config.CraftsManItmes[cKey]["name"].." Required Cash: "..BJCore.Config.Currency.Symbol..Config.CraftsManItmes[cKey]["cash"])
	    end
    elseif not hasCash then
    	TriggerClientEvent('BJCore:Notify', _source, "You don't have enough cash to pay for this order", "error")
    	TriggerClientEvent("chatMessage", _source, "SYSTEM", "warning", Config.CraftsManItmes[cKey]["name"].." Required Cash: "..BJCore.Config.Currency.Symbol..Config.CraftsManItmes[cKey]["cash"])
    else
        if Config.CraftsManItmes[cKey]["cash"] then Player.Functions.RemoveMoney('cash', Config.CraftsManItmes[cKey]["cash"], 'Craftsman-order'); end
        for k,v in pairs(Config.CraftsManItmes[cKey]["items"]) do if v then Player.Functions.RemoveItem(k, v); end; end
        local curTime = os.time()
        BJCore.Functions.ExecuteSql(true, "INSERT INTO `craftsman_orders` (`citizenid`, `item`, `ordered_on`, `build_time`) VALUES ('"..Player.PlayerData.citizenid.."', '"..Config.CraftsManItmes[cKey]["reward"].."', '"..curTime.."', '"..Config.CraftsManItmes[cKey]["time"].."')", function()
	        TriggerClientEvent('BJCore:Notify', _source, "Order successfully placed", "success")
	        TriggerClientEvent('BJCore:Notify', _source, "You'll be emailed when the order is ready to collect", "primary")
	        TriggerEvent("bj-log:server:CreateLog", "default", "Craftsman", "green", "**"..Player.PlayerData.name .. "** has placed an order for "..BJCore.Shared.Items[Config.CraftsManItmes[cKey]["reward"]].label)
	        Wait(10)
	        Awake(false)
        end)
    end
end)

BJCore.Commands.Add("craftcollect", "Collect Craftsman order", {{name="Order ID", help="ID"}}, true, function(source, args)
    local src = source
    if args[1] ~= nil then
    	local orderId = tonumber(args[1])
    	TriggerClientEvent("carpenter:client:collectOrder", src, orderId)
    else
        TriggerClientEvent('BJCore:Notify', src, "Missing order number", "error")
    end
end)

Citizen.CreateThread(function(...) Awake(true); end)

BJCore.Functions.CreateUseableItem("washpan", function(source, item)
    local Player = BJCore.Functions.GetPlayer(source)
    if Player ~= nil then
    	if Player.Functions.GetItemByName("stone") ~= nil then
		    TriggerClientEvent("mining:client:washStone", source)
		end
	end
end)

local miningReward = {
	[1] = {
		chance = 40,
	    item = false, -- 40% chance of no ore found in washed stone
	},
	[2] = {
		chance = 55,
	    item = "ironore",
	    amount = {
	    	[1] = 1,
	    	[2] = 3,
	    }
	},
	[3] = {
		chance = 70,
	    item = "silverore",
	    amount = {
	    	[1] = 1,
	    	[2] = 3,
	    }
	},
	[4] = {
		chance = 100,
	    item = "goldore",
	    amount = 1
	},
}

RegisterNetEvent("mining:server:manageItems")
AddEventHandler("mining:server:manageItems", function(action)
	if action == nil then return; end
	local src = source
	local Player = BJCore.Functions.GetPlayer(src)
	if Player ~= nil then
        if action == "mine" then
        	if Player.Functions.AddItem("stone", 1) then
                TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items["stone"], "add")
        	else
        		TriggerClientEvent("mining:client:cancelAction", src)
        	end
        elseif action == "wash" then
        	if Player.Functions.GetItemByName("stone") ~= nil then
        		if Player.Functions.RemoveItem("stone", 1) then
	        		TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items["stone"], "remove")
			        local chance = math.random(100)
			        local reward = false
			        for i = 1, #miningReward, 1 do
			        	if chance < miningReward[i].chance then
			        		reward = i
			        		break
			        	end
			        end
			        if reward and miningReward[reward].item then
			        	local amount = 0
			        	if type(miningReward[reward].amount) == "table" then
			        		amount = math.random(miningReward[reward].amount[1], miningReward[reward].amount[2])
			        	else
			        		amount = miningReward[reward].amount
			        	end
			        	if amount > 0 then
			        		local info = {
				        		["item"] = miningReward[reward].item,
				        		["label"] = BJCore.Shared.Items[miningReward[reward].item].label,
				        		["amount"] = amount
			        		}
				        	if Player.Functions.AddItem("washedstone", 1, nil, info) then
				                TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items["washedstone"], "add")
				        	else
				        		TriggerClientEvent("mining:client:cancelAction", src)
				        	end
				        end
				    else
				    	TriggerClientEvent('BJCore:Notify', src, "This stone appears to have nothing in it", "error")
			        end
		        else
		        	TriggerClientEvent("mining:client:cancelAction", src)
		        end
	        else
	        	TriggerClientEvent("mining:client:cancelAction", src)
	        end
        end
	end
end)

-- Fueler
local jobItems = {
	["fueler"] = {
		["raw"] = "rawfuel",
		["transformed"] = "refinedfuel",
	},
}

BJCore.Functions.RegisterServerCallback("jobs:server:transformRaw", function(source, cb, job)
    local Player = BJCore.Functions.GetPlayer(source)
    local rawItem = Player.Functions.GetItemByName(jobItems[job]["raw"])
    if rawItem ~= nil then
    	cb(rawItem.amount)
    else
    	cb(0)
    end
end)

RegisterNetEvent("jobs:server:convertFinal")
AddEventHandler("jobs:server:convertFinal", function(amount, job)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local rawItem = Player.Functions.GetItemByName(jobItems[job]["raw"])
    if rawItem ~= nil then
    	if rawItem.amount >= amount then
    		Player.Functions.RemoveItem(jobItems[job]["raw"], amount)
    		Player.Functions.AddItem(jobItems[job]["transformed"], amount)
    		TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items[jobItems[job]["raw"]], "remove")
    		TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items[jobItems[job]["transformed"]], "add")
    	end
    end
end)

local rawJobRewards = {
	["fueler"] = {
		item = "rawfuel",
		amount = {
			[1] = 1,
			[2] = 3,
		}
	},
}

RegisterNetEvent("jobs:server:collect")
AddEventHandler("jobs:server:collect", function(job)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    Player.Functions.AddItem(rawJobRewards[job].item, math.random(rawJobRewards[job].amount[1], rawJobRewards[job].amount[2]))
    TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items[rawJobRewards[job].item], "add")
end)