furni.sqlUpdate = function(tab,set,setval,where,whereval)
    BJCore.Functions.ExecuteSql(false, "UPDATE `player_houses` SET `furniture` ='"..setval.."' WHERE `house`='"..whereval.."'")
end

furni.placeFurniture = function(source,houseData,itemData,pos,rot,object)
	local bank,Player
	local id  = houseData.id
	Player = BJCore.Functions.GetPlayer(source)
	while not Player do Player = BJCore.Functions.GetPlayer(source); Citizen.Wait(0); end
	bank = Player.PlayerData.money["bank"]

	local brought = false
	local price = itemData.price
	if bank >= price then
		brought = true
		Player.Functions.RemoveMoney("bank", price, 'Furni purchase')
	end

	local gotData = false
	local hdata

	TriggerEvent("bj-house:server:getHouseData", function(data)
		hdata = data
		gotData = true
	end)

	while not gotData do Wait(0); end

	if brought then
		local foundHouse = false
		local newPos = {x = pos.x, y = pos.y, z = pos.z}
		local newRot = {x = rot.x, y = rot.y, z = rot.z}
		if hdata == nil then
			hdata = {}
		end
		if hdata[id] == nil then
			hdata[id] = {}
		end
		table.insert(hdata[id],{pos = newPos, rot = newRot, model = itemData.object})
		local jTab = {}
		for k,v in pairs(hdata[id]) do
			jTab[k] = {
				pos = {x = v.pos.x, y = v.pos.y, z = v.pos.z},
				rot = {x = v.rot.x, y = v.rot.y, z = v.rot.z},
				model = v.model,
			}
		end
		furni.sqlUpdate("player_houses",'furniture',json.encode(jTab),'house',id)
		TriggerEvent("bj-houses:server:placedFurni",hdata[id],id)
		TriggerClientEvent("bj-houses:client:SetClosestHouse", -1)
	else
		TriggerClientEvent('BJCore:Notify', source, 'Cannot afford this purchase', 'error')
	end
end

furni.replaceFurniture = function(source, houseData,itemData,pos,rot,object,lastData)
	local gotData = false
	local hdata
	TriggerEvent("bj-house:server:getHouseData", function(data)
		hdata = data
		gotData = true
	end)

	while not gotData do Wait(0); end

	local id = houseData.id
	lastData.lastPos = lastData.lastPos - houseData.pos.xyz
	local foundItem = false
	local exactMatch = false
	for k,v in pairs(hdata[id]) do
		if v.pos.x == lastData.lastPos.x and v.pos.y == lastData.pos.y and v.pos.z == lastData.pos.z and v.model == itemData.id then
			exactMatch = k
		elseif v.model == itemData.id then
			foundItem = k
		end
	end
	if exactMatch then foundItem = exactMatch; end
	if foundItem then
		table.remove(hdata[id],foundItem)
		local newPos = {x = pos.x, y = pos.y, z = pos.z}
		local newRot = {x = rot.x, y = rot.y, z = rot.z}
		table.insert(hdata[houseData.id],{pos = newPos, rot = newRot, model = itemData.object})
		local jTab = {}
		for k,v in pairs(hdata[id]) do
			jTab[k] = {
				pos = {x = v.pos.x, y = v.pos.y, z = v.pos.z},
				rot = {x = v.rot.x, y = v.rot.y, z = v.rot.z},
				model = v.model,
			}
		end
		furni.sqlUpdate("player_houses",'furniture',json.encode(jTab),'house',id)
		TriggerEvent("bj-houses:server:placedFurni",hdata[id],id)
		TriggerClientEvent("bj-houses:client:SetClosestHouse", -1)
	end
end

furni.deleteFurniture = function(source,house,data,pos,rot)
	local gotData = false
	local hdata
	TriggerEvent("bj-house:server:getHouseData", function(data)
		hdata = data
		gotData = true
	end)

	while not gotData do Wait(0); end

	local id = house.id
	local doCont = false
	--local owner = hdata[id].citizenid
	local Player = BJCore.Functions.GetPlayer(source)
	--if Player.PlayerData.citizenid == owner then
		local closest,closestDist
		for key,val in pairs(hdata[id]) do
			if val and type(val) == "table" and val.pos then
				local p = vector3(val.pos.x,val.pos.y,val.pos.z)
				local l = vector3(pos.x,pos.y,pos.z)
				local dist = #(p - l)
				if not closestDist or dist < closestDist then
					if data.object == val.model then
						closest = key
						closestDist = dist
					end
				end
			end
		end

		if closest and closestDist then
			table.remove(hdata[house.id],closest)
			local sellMoney = data.price*(Config and Config.ResaleValue and Config.ResaleValue/100.0 or 0.5)
			Player.Functions.AddMoney("bank", sellMoney)
			TriggerClientEvent('BJCore:Notify', source, 'You have sold this item for $'..sellMoney, 'primary')

			local jTab = {}
			for k,v in pairs(hdata[id]) do
				jTab[k] = {
					pos = {x = v.pos.x, y = v.pos.y, z = v.pos.z},
					rot = {x = v.rot.x, y = v.rot.y, z = v.rot.z},
					model = v.model,
				}
			end
			furni.sqlUpdate("player_houses",'furniture',json.encode(jTab),'house',id)
			TriggerEvent("bj-houses:server:placedFurni",hdata[id],id)
			TriggerClientEvent("bj-houses:client:SetClosestHouse", -1)
		end
	--end
end

RegisterNetEvent('furni:PlaceFurniture')
AddEventHandler('furni:PlaceFurniture', function(...) furni.placeFurniture(source,...); end)

RegisterNetEvent('furni:ReplaceFurniture')
AddEventHandler('furni:ReplaceFurniture', function(...) furni.replaceFurniture(source,...); end)

RegisterNetEvent('furni:DeleteFurniture')
AddEventHandler('furni:DeleteFurniture', function(...) furni.deleteFurniture(source,...); end)