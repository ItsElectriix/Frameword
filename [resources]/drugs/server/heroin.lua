local heroinfield = {
	["A"] = {},
}

local cooldown = {}

RegisterNetEvent("heroin:server:attemptLeafClip", function(pos, field)
	local src = source
	local found = false
	local dist = 0
	--local closest, closestDist = GetClosestArea(pos, field)
	for k,v in pairs(heroinfield[field]) do
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
	-- if heroinfield[field][closest].status == "harvested" and closestDist <= 4 then
	-- 	found = closest
	-- elseif heroinfield[field][closest].status == "pending" and closestDist <= 2 then
	-- 	found = closest
	-- end
	if not found then
		heroinfield[field][pos] = {}
		heroinfield[field][pos].group = {}
		table.insert(heroinfield[field][pos].group, src)
		heroinfield[field][pos].groupStatus = {}
		heroinfield[field][pos].status = "pending"
		heroinfield[field][pos].pos = pos
		TriggerClientEvent("heroin:client:updateFieldData", -1, heroinfield)
		TriggerClientEvent("heroin:client:pendingGroupHarvest", src, pos)
	else
		if heroinfield[field][found].status == "pending" then
			if dist <= 2 then
				if heroinfield[field][found].group ~= nil and heroinfield[field][found].group[1] ~= nil then
					table.insert(heroinfield[field][found].group, src)
					for i = 1, #heroinfield[field][found].group, 1 do
						heroinfield[field][found].status = "processing"
						TriggerClientEvent("heroin:client:startGroupHarvest", heroinfield[field][found].group[i], found)
					end
					TriggerClientEvent("heroin:client:updateFieldData", -1, heroinfield)
				end
			else
				TriggerClientEvent('BJCore:Notify', src, "You can't harvest this close to a pending harvest", 'error')
			end
		elseif heroinfield[field][found].status == "harvested" then
			TriggerClientEvent('BJCore:Notify', src, 'This area was recently harvested', 'error')
		elseif heroinfield[field][found].status == "processing" then
			TriggerClientEvent('BJCore:Notify', src, 'This area is currently being processed', 'error')
		end
	end
end)

function GetClosestArea(pos, field)
    local closest,closestDist
    for k,v in pairs(heroinfield[field]) do
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

RegisterNetEvent("heroin:server:leavePendingHarvest", function(field, pos)
	local src = source
	if heroinfield[field][pos].status ~= "harvested" then
		heroinfield[field][pos] = nil
		TriggerClientEvent('BJCore:Notify', src, "You moved away from pending harvest area", 'error')
		TriggerClientEvent("heroin:client:updateFieldData", -1, heroinfield)
	end
end)

RegisterNetEvent("heroin:server:completeHarvest", function(field, pos)
	local src = source
    table.insert(heroinfield[field][pos].groupStatus, true)
    if #heroinfield[field][pos].groupStatus == 2 then
    	for k,v in pairs(heroinfield[field][pos].group) do
    		local Player = BJCore.Functions.GetPlayer(v)
    		if Player ~= nil then
    			if Player.Functions.AddItem("rawmorphine", 2) then
    				Player.Functions.RemoveItem("opiumseed", 1)
    				TriggerClientEvent('inventory:client:ItemBox', v, BJCore.Shared.Items["rawmorphine"], "add")
    			else
    				TriggerClientEvent('BJCore:Notify', v, "You cannot carry this", 'error')
    			end
    		end
    	end
    	table.insert(cooldown, {field = field, pos = pos, time = GetGameTimer()})
    	heroinfield[field][pos].status = "harvested"
    	TriggerClientEvent("heroin:client:updateFieldData", -1, heroinfield)
    end
end)

local resetTime = 45
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(60*1000)
		for k,v in pairs(cooldown) do
            if GetGameTimer() - v.time >= resetTime * 60 *1000 then
            	heroinfield[v.field][v.pos] = nil
            	cooldown[k] = nil
            	TriggerClientEvent("heroin:client:updateFieldData", -1, heroinfield)
            end
		end
	end
end)

BJCore.Functions.CreateUseableItem("opiumseed", function(source, item)
	TriggerClientEvent("heroin:client:attemptLeafClip", source)
end)

local transformPositions = {
	[1] = {
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
	},
}

local transformOrders = {
	[1] = {
		["transform"] = {
			amount = 0,
			src = false
		},
		["purify"] = {
			amount = 0,
			src = false
		},
	}
}

local minProcess = {
	["transform"] = 1,
	["purify"] = 1,
}

RegisterNetEvent("heroin:server:attemptProcess", function(type, key, index)
	local src = source
	local item = nil
	if not transformPositions[index][type][key].client then
		if not transformOrders[index][type].src then
			local Player = BJCore.Functions.GetPlayer(src)
			if type == "transform" then item = Player.Functions.GetItemByName("rawmorphine")
			else item = Player.Functions.GetItemByName("heroin"); end
			if item ~= nil and item.amount >= minProcess[type] then
				transformOrders[index][type].src = src
				transformOrders[index][type].amount = math.floor(item.amount/minProcess[type])
			end
		end
		transformPositions[index][type][key].client = src
	else
		TriggerClientEvent('BJCore:Notify', src, "This location is currently occupied", 'error')
	end
	local count = 0
	for k,v in pairs(transformPositions[index][type]) do
		if transformPositions[index][type][k].client then
			count = count + 1
		end
	end
	if count == 2 then
		if transformOrders[index][type].src then
			for k,v in pairs(transformPositions[index][type]) do
				TriggerClientEvent("heroin:client:startProcess", transformPositions[index][type][k].client, type, key, transformOrders[index][type].amount, index)
			end
		else
			for k,v in pairs(transformPositions[index][type]) do
				TriggerClientEvent('BJCore:Notify', transformPositions[index][type][k].client, "Neither person has the required item or amounts to do this", 'error')
			end
		end
	else
		TriggerClientEvent("heroin:client:pendingProcess", src, type, key)
	end
end)

RegisterNetEvent("heroin:server:leaveProcess", function(type, key, index)
	local src = source
	if transformPositions[index][type][key].client == src then
		transformPositions[index][type][key].client = false
		TriggerClientEvent("heroin:client:leaveProcess", src)
	end
	if transformOrders[index][type].src == src then
		transformOrders[index][type].src = false
		transformOrders[index][type].amount = 0
	end
end)

RegisterNetEvent("heroin:server:finishProcess", function(type, index)
	local src = source
	for k,v in pairs(transformPositions[index][type]) do
		if transformPositions[index][type][k].client == src then
			transformPositions[index][type][k].progress = true
		end
	end
	TriggerClientEvent("heroin:client:leaveProcess", src)
	local count = 0
	for k,v in pairs(transformPositions[index][type]) do
		if transformPositions[index][type][k].progress then
			count = count + 1
		end
	end
	if count == 2 then
		TriggerEvent("heroin:server:rewardProcess", transformOrders[index][type].src, type, index)
	end
end)

local processReward = {
	["transform"] = 1, -- per minProcess["transform"]
	["purify"] = 1, -- per minProcess["purify"]
}

AddEventHandler("heroin:server:rewardProcess", function(player, type, index)
	local Player = BJCore.Functions.GetPlayer(player)
	if Player ~= nil then
		local item, reward = "rawmorphine", "heroin"
		if type == "purify" then item = "heroin" reward = "heroinsyringe"; end
		if Player.Functions.RemoveItem(item, transformOrders[index][type].amount*minProcess[type]) then
			TriggerClientEvent('inventory:client:ItemBox', Player.PlayerData.source, BJCore.Shared.Items[item], "remove")
			if Player.Functions.AddItem(reward, transformOrders[index][type].amount*processReward[type]) then
				TriggerClientEvent('inventory:client:ItemBox', Player.PlayerData.source, BJCore.Shared.Items[reward], "add")
			else
				Player.Functions.AddItem(item, item, transformOrders[index][type].amount*minProcess[type])
				TriggerClientEvent('BJCore:Notify', Player.PlayerData.source, "You cannot carry this", 'error')
			end
		end
		for k,v in pairs(transformPositions[index][type]) do
			transformPositions[index][type][k].client = false
			transformPositions[index][type][k].progress = false
		end
		transformOrders[index][type].src = false
		transformOrders[index][type].amount = 0
	end
end)

RegisterNetEvent("heroin:server:forceCancelProcess", function(type, key, index)
	local src = source
	for k,v in pairs(transformPositions[index][type]) do
		TriggerClientEvent("heroin:client:leaveProcess", transformPositions[index][type][k].client)
		transformPositions[index][type][k].client = false
	end
	transformOrders[index][type].src = false
	transformOrders[index][type].amount = 0
end)
