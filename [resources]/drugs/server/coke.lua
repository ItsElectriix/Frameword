local cokefield = {
	["A"] = {},
	["B"] = {},
	["C"] = {},
	["D"] = {},
}

local cooldown = {}

RegisterNetEvent("coke:server:attemptLeafClip", function(pos, field)
	local src = source
	local found = false
	local dist = 0
	--local closest, closestDist = GetClosestArea(pos, field)
	for k,v in pairs(cokefield[field]) do
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
	-- if cokefield[field][closest].status == "harvested" and closestDist <= 4 then
	-- 	found = closest
	-- elseif cokefield[field][closest].status == "pending" and closestDist <= 2 then
	-- 	found = closest
	-- end
	if not found then
		cokefield[field][pos] = {}
		cokefield[field][pos].group = {}
		table.insert(cokefield[field][pos].group, src)
		cokefield[field][pos].groupStatus = {}
		cokefield[field][pos].status = "pending"
		cokefield[field][pos].pos = pos
		TriggerClientEvent("coke:client:updateFieldData", -1, cokefield)
		TriggerClientEvent("coke:client:pendingGroupHarvest", src, pos)
	else
		if cokefield[field][found].status == "pending" then
			if dist <= 2 then
				if cokefield[field][found].group ~= nil and cokefield[field][found].group[1] ~= nil then
					table.insert(cokefield[field][found].group, src)
					for i = 1, #cokefield[field][found].group, 1 do
						cokefield[field][found].status = "processing"
						TriggerClientEvent("coke:client:startGroupHarvest", cokefield[field][found].group[i], found)
					end
					TriggerClientEvent("coke:client:updateFieldData", -1, cokefield)
				end
			else
				TriggerClientEvent('BJCore:Notify', src, "You can't harvest this close to a pending harvest", 'error')
			end
		elseif cokefield[field][found].status == "harvested" then
			TriggerClientEvent('BJCore:Notify', src, 'This area was recently harvested', 'error')
		elseif cokefield[field][found].status == "processing" then
			TriggerClientEvent('BJCore:Notify', src, 'This area is currently being processed', 'error')
		end
	end
end)

function GetClosestArea(pos, field)
	local closest,closestDist
	for k,v in pairs(cokefield[field]) do
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

RegisterNetEvent("coke:server:leavePendingHarvest", function(field, pos)
	local src = source
	if cokefield[field][pos].status ~= "harvested" then
		cokefield[field][pos] = nil
		TriggerClientEvent('BJCore:Notify', src, "You moved away from pending harvest area", 'error')
		TriggerClientEvent("coke:client:updateFieldData", -1, cokefield)
	end
end)

RegisterNetEvent("coke:server:completeHarvest", function(field, pos)
	local src = source
	local Player = BJCore.Functions.GetPlayer(src)
	table.insert(cokefield[field][pos].groupStatus, true)
	local chance = math.random(100)
	if chance <= Config.CokeRep["field"].chance then Player.Functions.SetMetaData("cokefield", Player.PlayerData.metadata["cokefield"]+Config.CokeRep["field"].adder); end
	if #cokefield[field][pos].groupStatus == 2 then
		for k,v in pairs(cokefield[field][pos].group) do
			local Player = BJCore.Functions.GetPlayer(v)
			if Player ~= nil then
				if Player.Functions.AddItem("cokeleaf", 1) then
					TriggerClientEvent('inventory:client:ItemBox', v, BJCore.Shared.Items["cokeleaf"], "add")
				else
					TriggerClientEvent('BJCore:Notify', v, "You cannot carry this", 'error')
				end
			end
		end
		table.insert(cooldown, {field = field, pos = pos, time = GetGameTimer()})
		cokefield[field][pos].status = "harvested"
		TriggerClientEvent("coke:client:updateFieldData", -1, cokefield)
	end
end)

local resetTime = 45
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(60*1000)
		for k,v in pairs(cooldown) do
			if GetGameTimer() - v.time >= resetTime * 60 *1000 then
				cokefield[v.field][v.pos] = nil
				cooldown[k] = nil
				TriggerClientEvent("coke:client:updateFieldData", -1, cokefield)
			end
		end
	end
end)

BJCore.Functions.CreateUseableItem("plantshears", function(source, item)
	TriggerClientEvent("coke:client:attemptLeafClip", source)
end)

local BarrelLocations = {}

CokeProductionConfig = {
	["prepare"] = {
		reqLeaves = 20, -- required amount to start prep process
		stages = {
			[1] = {
				reqItem = "weapon_petrolcan",
				amount = 3,
			},
			[2] = {
				reqItem = "bleach",
				amount = 10,
			},
			[3] = {
				--
			},
		},
		rewardItem = "cokeleaf_paste",
		rewardAmount = 1
	},
	["extract"] = {
		reqPaste = 3,
		reqAcetone = 5,
		rewardItem = "coke_extract",
		rewardAmount = 1
	},
	["process"] = {
		reqExtract = 2,
		reqScales = 1,
		reqSoda = 10,
		rewardItem = "coke_powder",
		rewardAmount = 1,
	},
	["package"] = {
		reqPowder = 2,
		reqScales = 1,
		reqPlastic = 10,
		rewardItem = "coke_brick",
		rewardAmount = 1,
	},
}

RegisterNetEvent("coke:server:doProcess", function(process, lab, info)
	local src = source
	local Player = BJCore.Functions.GetPlayer(src)
	if Player then
		if process == "prepare" then
			if not BarrelLocations[lab][info].inUse then
				if not BarrelLocations[lab][info].cooking then
					if not BarrelLocations[lab][info].processing then
						local leavesItem = Player.Functions.GetItemAmountByName("cokeleaf")
						if leavesItem >= CokeProductionConfig["prepare"].reqLeaves then
							if Player.Functions.RemoveItem("cokeleaf", CokeProductionConfig["prepare"].reqLeaves) then
								TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items["cokeleaf"], "remove")
								BarrelLocations[lab][info].inUse = true
								BarrelLocations[lab][info].processing = true
								TriggerClientEvent("coke:client:syncBarrelData", -1, BarrelLocations)
								TriggerClientEvent("coke:client:startProcess", src, "prepare", info, 0)
							end
						else
							TriggerClientEvent('BJCore:Notify', src, "You don't have enough "..BJCore.Shared.Items["cokeleaf"].label.." to do this", "error")
						end
					else
						if BarrelLocations[lab][info].stage ~= 3 then
							local reqData = CokeProductionConfig["prepare"].stages[BarrelLocations[lab][info].stage]
							local prepItem = Player.Functions.GetItemAmountByName(reqData.reqItem)
							if prepItem >= reqData.amount then
								if Player.Functions.RemoveItem(reqData.reqItem, reqData.amount) then
									TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items[reqData.reqItem], "remove")
									BarrelLocations[lab][info].inUse = true
									TriggerClientEvent("coke:client:syncBarrelData", -1, BarrelLocations)
									TriggerClientEvent("coke:client:startProcess", src, "prepare", info, BarrelLocations[lab][info].stage)
								end
							else
								TriggerClientEvent('BJCore:Notify', src, "You don't have enough "..BJCore.Shared.Items[reqData.reqItem].label.." to do this", "error")
							end
						else
							BarrelLocations[lab][info].inUse = true
							TriggerClientEvent("coke:client:syncBarrelData", -1, BarrelLocations)
							TriggerClientEvent("coke:client:startProcess", src, "prepare", info, 3)
						end
					end
				else
					TriggerClientEvent('BJCore:Notify', src, "This barrel is currently processing", "error")
				end
			else
				TriggerClientEvent('BJCore:Notify', src, "This barrel is currently in use", "error")
			end
		elseif process == "extract" then
			local req = CokeProductionConfig["extract"]
			local pasteItem = Player.Functions.GetItemAmountByName("cokeleaf_paste")
			if pasteItem >= req.reqPaste then
				local acetoneItem = Player.Functions.GetItemAmountByName("acetone")
				if acetoneItem >= req.reqAcetone then
					if (Player.Functions.RemoveItem("cokeleaf_paste", req.reqPaste) and Player.Functions.RemoveItem("acetone", req.reqAcetone)) then
						TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items["cokeleaf_paste"], "remove")
						TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items["acetone"], "remove")
						TriggerClientEvent("coke:client:startProcess", src, "extract", info)
					end
				else
					TriggerClientEvent('BJCore:Notify', src, "You need a strong acid liquid to extract the drug", "error")
				end
			else
				TriggerClientEvent('BJCore:Notify', src, "You don't have enough "..BJCore.Shared.Items["cokeleaf_paste"].label.." to do this", "error")
			end
		elseif process == "package" then
			local req = CokeProductionConfig["package"]
			local powderItem = Player.Functions.GetItemAmountByName("coke_powder")
			if powderItem >= req.reqPowder then
				local scalesItem = Player.Functions.GetItemAmountByName("digitalscale")
				if scalesItem >= req.reqScales then
					local plasticItem = Player.Functions.GetItemAmountByName("plastic")
					if plasticItem >= req.reqPlastic then
						if (Player.Functions.RemoveItem("coke_powder", req.reqPowder) and Player.Functions.RemoveItem("plastic", req.reqPlastic)) then
							TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items["coke_powder"], "remove")
							TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items["plastic"], "remove")
							TriggerClientEvent("coke:client:startProcess", src, "package", info)
						end
					else
						TriggerClientEvent('BJCore:Notify', src, "You need palstic for packaging", "error")
					end
				else
					TriggerClientEvent('BJCore:Notify', src, "You need scales to do this", "error")
				end
			else
				TriggerClientEvent('BJCore:Notify', src, "You don't have enough "..BJCore.Shared.Items["coke_powder"].label.." to do this", "error")
			end
		end
	end	
end)

RegisterNetEvent("coke:server:finishProcess", function(lab, type, index, stage)
	local src = source
	local Player = BJCore.Functions.GetPlayer(src)
	if Player then
		if type == "prepare" then
			if stage ~= 3 then
				BarrelLocations[lab][index].stage = BarrelLocations[lab][index].stage + 1
				BarrelLocations[lab][index].inUse = false
				BarrelLocations[lab][index].cooking = true
				TriggerClientEvent("coke:client:syncBarrelData", -1, BarrelLocations)
				SetTimeout(Config.CokeLeafCookTime*60*1000, function()
					BarrelLocations[lab][index].cooking = false
					TriggerClientEvent("coke:client:syncBarrelData", -1, BarrelLocations)
				end)
			else
				local chance = math.random(100)
				if chance <= Config.CokeRep["lab"].chance then Player.Functions.SetMetaData("cokelab", Player.PlayerData.metadata["cokelab"]+Config.CokeRep["lab"].adder); end
				if Player.Functions.AddItem(CokeProductionConfig[type].rewardItem, CokeProductionConfig[type].rewardAmount) then
					TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items[CokeProductionConfig[type].rewardItem], "add")
					BarrelLocations[lab][index].stage = 0
					BarrelLocations[lab][index].inUse = false
					BarrelLocations[lab][index].processing = false
					BarrelLocations[lab][index].cooking = false
					TriggerClientEvent("coke:client:syncBarrelData", -1, BarrelLocations)
				else
					TriggerClientEvent('BJCore:Notify', src, "You don't have enough space to carry this", "error")
				end
			end
		else
			local chance = math.random(100)
			if chance <= Config.CokeRep["lab"].chance then Player.Functions.SetMetaData("cokelab", Player.PlayerData.metadata["cokelab"]+Config.CokeRep["lab"].adder); end
			if Player.Functions.AddItem(CokeProductionConfig[type].rewardItem, CokeProductionConfig[type].rewardAmount) then
				TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items[CokeProductionConfig[type].rewardItem], "add")
			else
				TriggerClientEvent('BJCore:Notify', src, "You don't have enough space to carry this", "error")
			end
		end
	end
end)

local startLocation = nil
local CokeFieldAccess = {}
local ProcessPositions = {}
local ProcessOrders = {}
Citizen.CreateThread(function()
	startLocation = Config.CokeStartPos[math.random(#Config.CokeStartPos)]
	for lab in pairs(Config.CokeLabLocations) do
		BarrelLocations[lab] = {}
		for k,v in pairs(Config.CokeLabProductionPos["prepare"]) do
			BarrelLocations[lab][k] = {
				inUse = false,
				stage = 0,
				processing = false,
				cooking = false,
			}
		end
	end
	for lab in pairs(Config.CokeLabLocations) do
		ProcessPositions[lab] = {}
		ProcessOrders[lab] = {}
		for k,v in pairs(Config.CokeLabProductionPos["process"]) do
			ProcessPositions[lab][k] = {}
			ProcessOrders[lab][k] = {
				paidFor = false,
			}
			for i in pairs(v) do
				ProcessPositions[lab][k][i] = {
					client = false,
					progress = false,
				}
			end
		end
	end
end)

RegisterNetEvent("coke:server:getStartPosition", function()
	local src = source
	while startLocation == nil do Citizen.Wait(10); end
	TriggerClientEvent("coke:client:getStartPosition", src, startLocation, CokeFieldAccess, BarrelLocations, ProcessPositions)
end)

RegisterNetEvent("coke:server:dropOffPrice", function()
	local src = source
	local Player = BJCore.Functions.GetPlayer(src)
	if Player then
		local hasAll = true
		for i = 1, #Config.RequiredItemsForAccess, 1 do
			if Player.PlayerData.metadata["cokefield"] <= Config.RequiredItemsForAccess[i].rep then
				for i,data in pairs(Config.RequiredItemsForAccess[i].cost) do
					local item = Player.Functions.GetItemByName(data.item)
					if (item == nil or item.amount < data.amount) then
						hasAll = false
						break
					end
				end
				break
			end
		end
		if hasAll then
			for i = 1, #Config.RequiredItemsForAccess, 1 do
				if Player.PlayerData.metadata["cokefield"] <= Config.RequiredItemsForAccess[i].rep then
					for i,data in pairs(Config.RequiredItemsForAccess[i].cost) do
						if Player.Functions.RemoveItem(data.item, data.amount) then
							TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items[data.item], "remove")
						end
					end
				end
				break
			end
			CokeFieldAccess[Player.PlayerData.citizenid] = true
			TriggerClientEvent("coke:client:syncAccessData", -1, CokeFieldAccess)
			TriggerClientEvent("coke:client:completeDropOff", src, true)
		else
			TriggerClientEvent('BJCore:Notify', src, "You haven't dropped off the required items", "error", 5000)
			Player.Functions.SetMetaData("dealerrep", Player.PlayerData.metadata["dealerrep"] - 20)
			TriggerClientEvent("coke:client:completeDropOff", src, false)
		end
	end
end)

RegisterNetEvent("coke:server:setLabBucket", function(index, enter, object)
	local src = source
	if enter then
		SetPlayerRoutingBucket(src, index+100)
		if object ~= nil then
			SetEntityRoutingBucket(NetworkGetEntityFromNetworkId(object), index+100)
		end
	else
		SetPlayerRoutingBucket(src, 0)
		if object ~= nil then
			SetEntityRoutingBucket(NetworkGetEntityFromNetworkId(object), 0)
		end
	end
end)

RegisterNetEvent("coke:server:attemptProcess", function(lab, type, key)
	local src = source
	local item = nil
	if not ProcessPositions[lab][type][key].client then
		if not ProcessOrders[lab][type].paidFor then
			local Player = BJCore.Functions.GetPlayer(src)
			local req = CokeProductionConfig["process"]
			local extractItem = Player.Functions.GetItemAmountByName("coke_extract")
			if extractItem >= req.reqExtract then
				local scalesItem = Player.Functions.GetItemAmountByName("digitalscale")
				if scalesItem >= req.reqScales then
					local sodaItem = Player.Functions.GetItemAmountByName("bakingsoda")
					if sodaItem >= req.reqSoda then
						if (Player.Functions.RemoveItem("coke_extract", req.reqExtract) and Player.Functions.RemoveItem("bakingsoda", req.reqSoda)) then
							TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items["coke_extract"], "remove")
							TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items["bakingsoda"], "remove")
							ProcessOrders[lab][type].paidFor = src
						end
					else
						TriggerClientEvent('BJCore:Notify', src, "You need a cutting agent for this", "error")
						return
					end
				else
					TriggerClientEvent('BJCore:Notify', src, "You need scales to do this", "error")
					return
				end
			else
				TriggerClientEvent('BJCore:Notify', src, "You don't have enough "..BJCore.Shared.Items["coke_extract"].label.." to do this", "error")
				return
			end
		end
		ProcessPositions[lab][type][key].client = src
		TriggerClientEvent("coke:client:syncProcessLocations", -1, ProcessPositions)
	else
		TriggerClientEvent('BJCore:Notify', src, "This location is currently occupied", 'error')
	end
	local count = 0
	for k,v in pairs(ProcessPositions[lab][type]) do
		if ProcessPositions[lab][type][k].client then
			count = count + 1
		end
	end
	if count == 2 then
		if ProcessOrders[lab][type].paidFor then
			for k,v in pairs(ProcessPositions[lab][type]) do
				TriggerClientEvent("coke:client:startProcess", ProcessPositions[lab][type][k].client, "process", type, k)
			end
		end
	else
		TriggerClientEvent("coke:client:pendingProcess", src, type, key)
	end
end)

RegisterNetEvent("coke:server:leaveProcess", function(lab, tabKey, key)
	local src = source
	if ProcessPositions[lab][tabKey][key].client == src then
		ProcessPositions[lab][tabKey][key].client = false
		TriggerClientEvent("coke:client:leaveProcess", src)
		TriggerClientEvent("coke:client:syncProcessLocations", -1, ProcessPositions)
	end
	if ProcessOrders[lab][tabKey].paidFor == src then
		ProcessOrders[lab][tabKey].paidFor = false
		local Player = BJCore.Functions.GetPlayer(src)
		local req = CokeProductionConfig["process"]
		Player.Functions.AddItem("coke_extract", req.reqExtract)
		Player.Functions.AddItem("bakingsoda", req.reqSoda)
		TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items["coke_extract"], "add")
		TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items["bakingsoda"], "add")
	end
end)

RegisterNetEvent("coke:server:finishProcessStage", function(tabKey, type, i)
	local src = source
	local Player = BJCore.Functions.GetPlayer(src)
	for k,v in pairs(ProcessPositions[tabKey][type]) do
		if ProcessPositions[tabKey][type][k].client == src then
			ProcessPositions[tabKey][type][k].progress = true
		end
	end
	TriggerClientEvent("coke:client:leaveProcess", src)
	local count = 0
	for k,v in pairs(ProcessPositions[tabKey][type]) do
		if ProcessPositions[tabKey][type][k].progress then
			count = count + 1
		end
	end
	local chance = math.random(100)
	if chance <= Config.CokeRep["lab"].chance then Player.Functions.SetMetaData("cokelab", Player.PlayerData.metadata["cokelab"]+Config.CokeRep["lab"].adder); end
	if count == 2 then
		local Target = BJCore.Functions.GetPlayer(ProcessOrders[tabKey][type].paidFor)
		if Target.Functions.AddItem(CokeProductionConfig["process"].rewardItem, CokeProductionConfig["process"].rewardAmount) then
			TriggerClientEvent('inventory:client:ItemBox', Target.PlayerData.source, BJCore.Shared.Items[CokeProductionConfig["process"].rewardItem], "add")
		else
			TriggerClientEvent('BJCore:Notify', Target.PlayerData.source, "You don't have enough space to carry this", "error")
		end
		for k,v in pairs(ProcessPositions[tabKey][type]) do
			ProcessPositions[tabKey][type][k].client = false
			ProcessPositions[tabKey][type][k].progress = false
		end
		ProcessOrders[tabKey][type].paidFor = false
		TriggerClientEvent("coke:client:syncProcessLocations", -1, ProcessPositions)
	end
end)

RegisterNetEvent("coke:server:forceCancelProcess", function(lab, type, key)
	local src = source
	for k,v in pairs(ProcessPositions[lab][type]) do
		TriggerClientEvent("coke:client:leaveProcess", ProcessPositions[lab][type][k].client)
		ProcessPositions[lab][type][k].client = false
		TriggerClientEvent("mythic_progbar:client:cancel", ProcessPositions[lab][type][k].client)
		TriggerClientEvent("coke:client:syncProcessLocations", -1, ProcessPositions)
	end
	ProcessOrders[lab][type].paidFor = false
end)

RegisterNetEvent("coke:server:forceCancelPrepare", function(lab, type, data)
    if BarrelLocations[lab][type].inUse then
        BarrelLocations[lab][type].inUse = false
        if data == 0 then
            BarrelLocations[lab][type].processing = false
            TriggerClientEvent("coke:client:syncBarrelData", -1, BarrelLocations)
        end
    end
end)