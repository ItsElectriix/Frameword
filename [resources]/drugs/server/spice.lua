local spicefield = {
	["A"] = {},
	["B"] = {},
	["C"] = {},
	["D"] = {},
}

local cooldown = {}

RegisterNetEvent("spice:server:attemptLeafClip", function(pos, field)
	local src = source
	local found = false
	local dist = 0
	--local closest, closestDist = GetClosestArea(pos, field)
	for k,v in pairs(spicefield[field]) do
		dist = #(pos - v.pos)
		if v.status == "harvested" then
			if dist <= 4 then
				found = k
				break
			end
		elseif v.status == "pending" or "processing" then
			if dist <= 4 then
				found = k
				break
			end
		end
	end
	-- if spicefield[field][closest].status == "harvested" and closestDist <= 4 then
	-- 	found = closest
	-- elseif spicefield[field][closest].status == "pending" and closestDist <= 2 then
	-- 	found = closest
	-- end
	if not found then
		spicefield[field][pos] = {}
		spicefield[field][pos].group = {}
		table.insert(spicefield[field][pos].group, src)
		spicefield[field][pos].groupStatus = {}
		spicefield[field][pos].status = "pending"
		spicefield[field][pos].pos = pos
		TriggerClientEvent("spice:client:updateFieldData", -1, spicefield)
		TriggerClientEvent("spice:client:pendingGroupHarvest", src, pos)
	else
		if spicefield[field][found].status == "pending" then
			if dist <= 2 then
				if spicefield[field][found].group ~= nil and spicefield[field][found].group[1] ~= nil then
					table.insert(spicefield[field][found].group, src)
					for i = 1, #spicefield[field][found].group, 1 do
						spicefield[field][found].status = "processing"
						TriggerClientEvent("spice:client:startGroupHarvest", spicefield[field][found].group[i], found)
					end
					TriggerClientEvent("spice:client:updateFieldData", -1, spicefield)
				end
			else
				TriggerClientEvent('BJCore:Notify', src, "You can't harvest this close to a pending harvest", 'error')
			end
		elseif spicefield[field][found].status == "harvested" then
			TriggerClientEvent('BJCore:Notify', src, 'This area was recently harvested', 'error')
		elseif spicefield[field][found].status == "processing" then
			TriggerClientEvent('BJCore:Notify', src, 'This area is currently being processed', 'error')
		end
	end
end)

function GetClosestArea(pos, field)
    local closest,closestDist
    for k,v in pairs(spicefield[field]) do
	    local dist =  #(pos - v.pos)
	    if not closestDist or dist < closestDist then
		    closestDist = dist
		    closest = k
		end
	end
    if closest and closestDist then return closest,closestDist
    else return false,99999
    end
end

RegisterNetEvent("spice:server:leavePendingHarvest", function(field, pos)
	local src = source
	if spicefield[field][pos].status ~= "harvested" then
		spicefield[field][pos] = nil
		TriggerClientEvent('BJCore:Notify', src, "You moved away from pending harvest area", 'error')
		TriggerClientEvent("spice:client:updateFieldData", -1, spicefield)
	end
end)

RegisterNetEvent("spice:server:completeHarvest", function(field, pos)
	local src = source
    table.insert(spicefield[field][pos].groupStatus, true)
    if #spicefield[field][pos].groupStatus == 2 then
    	for k,v in pairs(spicefield[field][pos].group) do
    		local Player = BJCore.Functions.GetPlayer(v)
    		if Player ~= nil then
    			if Player.Functions.AddItem("tealeafs", 2) then
    				Player.Functions.RemoveItem("treeknife", 1)
    				TriggerClientEvent('inventory:client:ItemBox', v, BJCore.Shared.Items["tealeafs"], "add")
    			else
    				TriggerClientEvent('BJCore:Notify', v, "You cannot carry this", 'error')
    			end
    		end
    	end
    	table.insert(cooldown, {field = field, pos = pos, time = GetGameTimer()})
    	spicefield[field][pos].status = "harvested"
    	TriggerClientEvent("spice:client:updateFieldData", -1, spicefield)
    end
end)

local resetTime = 45
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(60*1000)
		for k,v in pairs(cooldown) do
            if GetGameTimer() - v.time >= resetTime * 60 *1000 then
            	spicefield[v.field][v.pos] = nil
            	cooldown[k] = nil
            	TriggerClientEvent("spice:client:updateFieldData", -1, spicefield)
            end
		end
	end
end)

BJCore.Functions.CreateUseableItem("treeknife", function(source, item)
	TriggerClientEvent("spice:client:attemptLeafClip", source)
end)

local transformPositions = {
	["transform"] = {
		[1] = {
			client = false,
			progress = false,
		},
		[2] =  {
			client = false,
			progress = false,
		},
	},
	["purify"] = {
		[1] = {
			client = false,
			progress = false,
		},
		[2] =  {
			client = false,
			progress = false,
		},
	},
}

local transformOrders = {
	["transform"] = {
		amount = 0,
		src = false
	},
	["purify"] = {
		amount = 0,
		src = false
	},
}

local minProcess = {
	["transform"] = 1,
	["purify"] = 1,
}

RegisterNetEvent("spice:server:attemptProcess", function(type, key)
	local src = source
	local item = nil
	if not transformPositions[type][key].client then
		if not transformOrders[type].src then
			local Player = BJCore.Functions.GetPlayer(src)
			if type == "transform" then item = Player.Functions.GetItemByName("tealeafs")
			else item = Player.Functions.GetItemByName("spiceleaf"); end
			if item ~= nil and item.amount >= minProcess[type] then
				transformOrders[type].src = src
				transformOrders[type].amount = math.floor(item.amount/minProcess[type])
			end
		end
		transformPositions[type][key].client = src
	else
		TriggerClientEvent('BJCore:Notify', src, "This location is currently occupied", 'error')
	end
	local count = 0
	for k,v in pairs(transformPositions[type]) do
		if transformPositions[type][k].client then
			count = count + 1
		end
	end
	if count == 2 then
		if transformOrders[type].src then
			for k,v in pairs(transformPositions[type]) do
				TriggerClientEvent("spice:client:startProcess", transformPositions[type][k].client, type, key, transformOrders[type].amount)
			end
		else
			for k,v in pairs(transformPositions[type]) do
				TriggerClientEvent('BJCore:Notify', transformPositions[type][k].client, "Neither person has the required item or amounts to do this", 'error')
			end
		end
	else
		TriggerClientEvent("spice:client:pendingProcess", src, type, key)
	end
end)

RegisterNetEvent("spice:server:leaveProcess", function(type, key)
	local src = source
	if transformPositions[type][key].client == src then
		transformPositions[type][key].client = false
		TriggerClientEvent("spice:client:leaveProcess", src)
	end
	if transformOrders[type].src == src then
		transformOrders[type].src = false
		transformOrders[type].amount = 0
	end
end)

RegisterNetEvent("spice:server:finishProcess", function(type)
	local src = source
	for k,v in pairs(transformPositions[type]) do
		if transformPositions[type][k].client == src then
			transformPositions[type][k].progress = true
		end
	end
	TriggerClientEvent("spice:client:leaveProcess", src)
	local count = 0
	for k,v in pairs(transformPositions[type]) do
		if transformPositions[type][k].progress then
			count = count + 1
		end
	end
	if count == 2 then
		TriggerEvent("spice:server:rewardProcess", transformOrders[type].src, type)
	end
end)

local processReward = {
	["transform"] = 1, -- per minProcess["transform"]
	["purify"] = 1, -- per minProcess["purify"]
}

AddEventHandler("spice:server:rewardProcess", function(player, type)
	local Player = BJCore.Functions.GetPlayer(player)
	if Player ~= nil then
		local item, reward = "tealeafs", "spiceleafs"
		if type == "purify" then item = "spiceleafs" reward = "spice"; end
		if Player.Functions.RemoveItem(item, transformOrders[type].amount*minProcess[type]) then
			TriggerClientEvent('inventory:client:ItemBox', Player.PlayerData.source, BJCore.Shared.Items[item], "remove")
			if Player.Functions.AddItem(reward, transformOrders[type].amount*processReward[type]) then
				TriggerClientEvent('inventory:client:ItemBox', Player.PlayerData.source, BJCore.Shared.Items[reward], "add")
			else
				Player.Functions.AddItem(item, item, transformOrders[type].amount*minProcess[type])
				TriggerClientEvent('BJCore:Notify', Player.PlayerData.source, "You cannot carry this", 'error')
			end
		end
		for k,v in pairs(transformPositions[type]) do
			transformPositions[type][k].client = false
			transformPositions[type][k].progress = false
		end
		transformOrders[type].src = false
		transformOrders[type].amount = 0
	end
end)

RegisterNetEvent("spice:server:forceCancelProcess", function(type, key)
	local src = source
	for k,v in pairs(transformPositions[type]) do
		TriggerClientEvent("spice:client:leaveProcess", transformPositions[type][k].client)
		transformPositions[type][k].client = false
	end
	transformOrders[type].src = false
	transformOrders[type].amount = 0
end)

RegisterNetEvent("spice:server:leaveProcess", function(type, key)
	local src = source
	if transformPositions[type][key].client == src then
		transformPositions[type][key].client = false
		TriggerClientEvent("spice:client:leaveProcess", src)
	end
	if transformOrders[type].src == src then
		transformOrders[type].src = false
		transformOrders[type].amount = 0
	end
end)
