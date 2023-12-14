local houseowneridentifier = {}
local houseownercid = {}
local housefurniture = {}
local housekeyholders = {}
local HouseGarages = {}

Citizen.CreateThread(function()
	BJCore.Functions.ExecuteSql(false, "SELECT * FROM `houselocations`", function(result)
		if result[1] ~= nil then
			for k, v in pairs(result) do
				local owned = false
				if tonumber(v.owned) == 1 then
					owned = true
				end
				local garage = v.garage ~= nil and json.decode(v.garage) or {}
				local coord = json.decode(v.coords)
				coord.enter = vector4(coord.enter.x, coord.enter.y, coord.enter.z, coord.enter.h)
				Config.Houses[v.name] = {
					coords = coord,
					owned = v.owned,
					price = v.price,
					locked = true,
					address = v.label, 
					tier = v.tier,
					garage = garage,
					furniture = {},
				}
				HouseGarages[v.name] = {
					label = v.label,
					takeVehicle = garage,
				}
			end
		end
		TriggerClientEvent("garages:client:houseGarageConfig", -1, HouseGarages)
		TriggerClientEvent("bj-houses:client:setHouseConfig", -1, Config.Houses)
	end)
end)

RegisterServerEvent('bj-houses:server:setHouses')
AddEventHandler('bj-houses:server:setHouses', function()
	local src = source
	TriggerClientEvent("bj-houses:client:setHouseConfig", src, Config.Houses)
	TriggerClientEvent("garages:client:houseGarageConfig", src, HouseGarages)
end)

RegisterServerEvent('bj-houses:server:addNewHouse')
AddEventHandler('bj-houses:server:addNewHouse', function(street, coords, price, tier)
	local src = source
	local street = street:gsub("%'", "")
	local price = tonumber(price)
	local tier = tonumber(tier)
	local houseCount = GetHouseStreetCount(street)
	local name = street:lower() .. tostring(houseCount)
	local label = street .. " " .. tostring(houseCount)
	BJCore.Functions.ExecuteSql(false, "INSERT INTO `houselocations` (`name`, `label`, `coords`, `owned`, `price`, `tier`) VALUES ('"..name.."', '"..label.."', '"..json.encode(coords).."', 0,"..price..", "..tier..")")
	coords.enter = vector4(coords.enter.x, coords.enter.y, coords.enter.z, coords.enter.h)
	Config.Houses[name] = {
		coords = coords,
		owned = false,
		price = price,
		locked = true,
		address = label, 
		tier = tier,
		garage = {},
		furniture = {},
	}
	TriggerClientEvent("bj-houses:client:setHouseConfig", -1, Config.Houses)
	TriggerClientEvent('BJCore:Notify', src, "You have added a house: "..label)
end)

function GetHouseStreetCount(street)
	local count = 1
	BJCore.Functions.ExecuteSql(true, "SELECT * FROM `houselocations` WHERE `name` LIKE '%"..street.."%'", function(result)
		if result[1] ~= nil then 
			for i = 1, #result, 1 do
				count = count + 1
			end
		end
		return count
	end)
	return count
end

RegisterServerEvent('bj-houses:server:addGarage')
AddEventHandler('bj-houses:server:addGarage', function(house, coords)
	local src = source
	BJCore.Functions.ExecuteSql(false, "UPDATE `houselocations` SET `garage` = '"..json.encode(coords).."' WHERE `name` = '"..house.."'")
	HouseGarages[house] = {
		label = Config.Houses[house].address,
		takeVehicle = coords,
	}
	TriggerClientEvent("garages:client:addHouseGarage", -1, house, HouseGarages[house])
	TriggerClientEvent('BJCore:Notify', src, "You have added a garage: "..HouseGarages[house].label)
end)

RegisterServerEvent('bj-houses:server:setLocation')
AddEventHandler('bj-houses:server:setLocation', function(coords, house, type)
	local src = source

	if type == 1 then
		BJCore.Functions.ExecuteSql(true, "UPDATE `player_houses` SET `stash` = '"..json.encode(coords).."' WHERE `house` = '"..house.."'")
	elseif type == 2 then
		BJCore.Functions.ExecuteSql(true, "UPDATE `player_houses` SET `outfit` = '"..json.encode(coords).."' WHERE `house` = '"..house.."'")
	elseif type == 3 then
		BJCore.Functions.ExecuteSql(true, "UPDATE `player_houses` SET `logout` = '"..json.encode(coords).."' WHERE `house` = '"..house.."'")
	end

	TriggerClientEvent('bj-houses:client:refreshLocations', -1, house, json.encode(coords), type)
end)

RegisterServerEvent('bj-houses:server:viewHouse')
AddEventHandler('bj-houses:server:viewHouse', function(house)
	local src     		= source
	local pData 		= BJCore.Functions.GetPlayer(src)

	local houseprice   	= Config.Houses[house].price
	local brokerfee 	= (houseprice / 100 * 5)
	local bankfee 		= (houseprice / 100 * 10) 
	local taxes 		= (houseprice / 100 * 6)

	TriggerClientEvent('bj-houses:client:viewHouse', src, houseprice, brokerfee, bankfee, taxes, pData.PlayerData.charinfo.firstname, pData.PlayerData.charinfo.lastname)
end)

RegisterServerEvent('bj-houses:server:buyHouse')
AddEventHandler('bj-houses:server:buyHouse', function(house)
	local src     	= source
	local pData 	= BJCore.Functions.GetPlayer(src)
	local price   	= Config.Houses[house].price
	local HousePrice = math.ceil(price * 1.21)
	local bankBalance = pData.PlayerData.money["bank"]

	if (bankBalance >= HousePrice) then
		BJCore.Functions.ExecuteSql(false, "INSERT INTO `player_houses` (`house`, `identifier`, `citizenid`, `keyholders`, `furniture`) VALUES ('"..house.."', '"..pData.PlayerData.steam.."', '"..pData.PlayerData.citizenid.."', '"..json.encode({}).."', '"..json.encode({}).."')")
		houseowneridentifier[house] = pData.PlayerData.steam
		houseownercid[house] = pData.PlayerData.citizenid
		housekeyholders[house] = {
			[1] = pData.PlayerData.citizenid
		}
		BJCore.Functions.ExecuteSql(true, "UPDATE `houselocations` SET `owned` = 1 WHERE `name` = '"..house.."'")
		TriggerClientEvent('bj-houses:client:SetClosestHouse', src)
		pData.Functions.RemoveMoney('bank', HousePrice, "bought-house") -- 21% Extra house costs
	else
		TriggerClientEvent('BJCore:Notify', source, "You cannot afford this", "error")
	end
end)

local raidHouse = {}
RegisterServerEvent('bj-houses:server:lockHouse')
AddEventHandler('bj-houses:server:lockHouse', function(bool, house)
	if raidHouse[house] == true then
		raidHouse[house] = nil
		TriggerClientEvent("bj-houses:client:setRaid", -1, raidHouse)
	end
	TriggerClientEvent('bj-houses:client:lockHouse', -1, bool, house)
end)

RegisterServerEvent("bj-houses:server:setRaid")
AddEventHandler("bj-houses:server:setRaid", function(house)
	raidHouse[house] = true
	TriggerClientEvent("bj-houses:client:setRaid", -1, raidHouse)
end)

--------------------------------------------------------------

--------------------------------------------------------------

BJCore.Functions.RegisterServerCallback('bj-houses:server:hasKey', function(source, cb, house)
	local src = source
	local pData = BJCore.Functions.GetPlayer(src)

	if pData then
		local identifier = pData.PlayerData.steam
		local CharId = pData.PlayerData.citizenid
		cb(hasKey(identifier, CharId, house))
	end
end)

BJCore.Functions.RegisterServerCallback('bj-houses:server:isOwned', function(source, cb, house)
	if houseowneridentifier[house] ~= nil and houseownercid[house] ~= nil then
		cb(true)
	else
		cb(false)
	end
end)

BJCore.Functions.RegisterServerCallback('bj-houses:server:getFurniture', function(source, cb, house)
	if houseowneridentifier[house] ~= nil and houseownercid[house] ~= nil  and housefurniture[house] ~= nil then
		cb(housefurniture[house])
	else
		cb(false)
	end
end)

BJCore.Functions.RegisterServerCallback('bj-houses:server:getHouseKeyHolders', function(source, cb, house)
	local retval = {}
	local Player = BJCore.Functions.GetPlayer(source)
	if housekeyholders[house] ~= nil then 
		for i = 1, #housekeyholders[house], 1 do
			if Player.PlayerData.citizenid ~= housekeyholders[house][i] then
				BJCore.Functions.ExecuteSql(false, "SELECT `charinfo` FROM `players` WHERE `citizenid` = '"..housekeyholders[house][i].."'", function(result)
					if result[1] ~= nil then 
						local charinfo = json.decode(result[1].charinfo)
						table.insert(retval, {
							firstname = charinfo.firstname,
							lastname = charinfo.lastname,
							citizenid = housekeyholders[house][i],
						})
					end
					cb(retval)
				end)
			end
		end
	else
		cb(nil)
	end
end)

BJCore.Functions.RegisterServerCallback('bj-houses:server:getHouseLocations', function(source, cb, house)
	local retval = nil
	BJCore.Functions.ExecuteSql(false, "SELECT * FROM `player_houses` WHERE `house` = '"..house.."'", function(result)
		if result[1] ~= nil then
			retval = result[1]
		end
		cb(retval)
	end)
end)

function hasKey(identifier, cid, house)
	if houseowneridentifier[house] ~= nil and houseownercid[house] ~= nil then
		if houseowneridentifier[house] == identifier and houseownercid[house] == cid then
			return true
		else
			if housekeyholders[house] ~= nil then 
				for i = 1, #housekeyholders[house], 1 do
					if housekeyholders[house][i] == cid then
						return true
					end
				end
			end
		end
	end
	return false
end
exports("hasKey", hasKey)

BJCore.Functions.RegisterServerCallback('bj-houses:server:getHouseOwner', function(source, cb, house)
	cb(houseownercid[house])
end)

RegisterServerEvent('bj-houses:server:giveKey')
AddEventHandler('bj-houses:server:giveKey', function(house, target)
	local pData = BJCore.Functions.GetPlayer(target)
	table.insert(housekeyholders[house], pData.PlayerData.citizenid)
	BJCore.Functions.ExecuteSql(false, "UPDATE `player_houses` SET `keyholders` = '"..json.encode(housekeyholders[house]).."' WHERE `house` = '"..house.."'")
end)

RegisterServerEvent('bj-houses:server:removeHouseKey')
AddEventHandler('bj-houses:server:removeHouseKey', function(house, citizenData)
	local src = source
	local newHolders = {}
	if housekeyholders[house] ~= nil then 
		for k, v in pairs(housekeyholders[house]) do
			if housekeyholders[house][k] ~= citizenData.citizenid then
				table.insert(newHolders, housekeyholders[house][k])
			end
		end
	end
	housekeyholders[house] = newHolders
	local tData = BJCore.Functions.GetPlayerByCitizenId(citizenData.citizenid)
	if tData ~= nil then
		TriggerClientEvent('bj-houses:client:SetClosestHouse', tData.PlayerData.source)
	end
	TriggerClientEvent('BJCore:Notify', src, citizenData.firstname .. " " .. citizenData.lastname .. "'s keys have been removed", 'primary', 3500)
	BJCore.Functions.ExecuteSql(false, "UPDATE `player_houses` SET `keyholders` = '"..json.encode(housekeyholders[house]).."' WHERE `house` = '"..house.."'")
end)

RegisterServerEvent('bj-houses:server:giveHouseKey')
AddEventHandler('bj-houses:server:giveHouseKey', function(target, house)
	local src = source
	local tPlayer = BJCore.Functions.GetPlayer(target)
	
	if tPlayer ~= nil then
		if housekeyholders[house] ~= nil then
			for _, cid in pairs(housekeyholders[house]) do
				if cid == tPlayer.PlayerData.citizenid then
					TriggerClientEvent('BJCore:Notify', src, 'This person already has keys to this house', 'error', 3500)
					return
				end
			end		
			table.insert(housekeyholders[house], tPlayer.PlayerData.citizenid)
			BJCore.Functions.ExecuteSql(true, "UPDATE `player_houses` SET `keyholders` = '"..json.encode(housekeyholders[house]).."' WHERE `house` = '"..house.."'")
			TriggerClientEvent('bj-houses:client:SetClosestHouse', tPlayer.PlayerData.source)
			TriggerClientEvent('BJCore:Notify', tPlayer.PlayerData.source, 'You recieved keys to '..Config.Houses[house].address, 'success', 2500)
			TriggerClientEvent('BJCore:Notify', src, "You have given "..tPlayer.PlayerData.charinfo.firstname.." "..tPlayer.PlayerData.charinfo.lastname.." house keys", 'success', 3500)
		else
			local sourceTarget = BJCore.Functions.GetPlayer(src)
			housekeyholders[house] = {
				[1] = sourceTarget.PlayerData.citizenid
			}
			table.insert(housekeyholders[house], tPlayer.PlayerData.citizenid)
			BJCore.Functions.ExecuteSql(true, "UPDATE `player_houses` SET `keyholders` = '"..json.encode(housekeyholders[house]).."' WHERE `house` = '"..house.."'")
			TriggerClientEvent('bj-houses:client:SetClosestHouse', tPlayer.PlayerData.source)
			TriggerClientEvent('BJCore:Notify', tPlayer.PlayerData.source, 'You recieved keys to '..Config.Houses[house].address, 'success', 2500)
			TriggerClientEvent('BJCore:Notify', src, "You have given "..tPlayer.PlayerData.charinfo.firstname.." "..tPlayer.PlayerData.charinfo.lastname.." house keys", 'success', 3500)
		end
	else
		TriggerClientEvent('BJCore:Notify', src, 'Target player not found', 'error', 2500)
	end
end)

local housesLoaded = false

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		if not housesLoaded then
			exports['ghmattimysql']:execute('SELECT * FROM player_houses', function(houses)
				if houses ~= nil then
					for _,house in pairs(houses) do
						houseowneridentifier[house.house] = house.identifier
						houseownercid[house.house] = house.citizenid
						housekeyholders[house.house] = json.decode(house.keyholders)
						local furniture = {}
						local f = json.decode((house.furniture or {}))
                        if f and type(f) == 'table' then
                        	for k,v in pairs(f) do
                                local p = v.pos
                                local r = v.rot
                                if r.x then
                                	table.insert(furniture,{pos = vector3(p.x,p.y,p.z), rot = vector3(r.x,r.y,r.z), model = v.model})
                                end
                        	end
                        end
						housefurniture[house.house] = furniture
					end
				end
			end)
			housesLoaded = true
		end
	end
end)

BJCore.Functions.RegisterServerCallback('bj-houses:server:getHouseInventory', function(source, cb)
	local pData = BJCore.Functions.GetPlayer(target)

	if pData ~= nil then
		cb({inventory = pData.inventory, weapons = pData.weapons})
	else
		cb(nil)
	end
end)

BJCore.Functions.RegisterServerCallback('bj-houses:server:getOwnedHouses', function(source, cb)
	local pData = BJCore.Functions.GetPlayer(source)

	if pData then
		local id = pData.PlayerData.steam
		local cid = pData.PlayerData.citizenid

		exports['ghmattimysql']:execute('SELECT * FROM player_houses WHERE identifier = @identifier AND citizenid = @citizenid', {['@identifier'] = id, ['@citizenid'] = cid}, function(houses)
			local ownedHouses = {}

			for i=1, #houses, 1 do
				table.insert(ownedHouses, houses[i].house)
			end

			if houses ~= nil then
				cb(ownedHouses)
			else
				cb(nil)
			end
		end)
	end
end)

BJCore.Commands.Add("shellDebug", "Dev tool for shell offets/spawning", {{name="object name", help="Shell object name .ydr"}}, true, function(source, args)
    TriggerClientEvent("utils:spawnShell", source, args[1])
end, "god")

RegisterServerEvent('bj-houses:server:getFurniData')
AddEventHandler('bj-houses:server:getFurniData', function(cb)
	cb(housefurniture)
end)

RegisterServerEvent('bj-houses:server:placedFurni')
AddEventHandler('bj-houses:server:placedFurni', function(data, id)
	housefurniture[id] = data
end)

AddEventHandler("bj-house:server:getHouseData", function(cb)
	cb(housefurniture)
end)

BJCore.Commands.Add("delhouse", "Delete closest house", {}, true, function(source, args)
    TriggerClientEvent("bj-houses:client:doAdminDelete", source, false)
end, "god")

BJCore.Commands.Add("delhouseperm", "Delete closest houselocation and owner", {}, true, function(source, args)
    TriggerClientEvent("bj-houses:client:doAdminDelete", source, true)
end, "god")

RegisterServerEvent('bj-houses:server:doAdminDelete')
AddEventHandler('bj-houses:server:doAdminDelete', function(house, full)
	local src = tonumber(source)
    if BJCore.Functions.HasPermission(src, "god") then
        BJCore.Functions.ExecuteSql(true, "DELETE FROM `player_houses` WHERE `house` = @house", nil, {['@house'] = house})
        if full then
        	Config.Houses[house] = nil
        	HouseGarages[house] = nil
        	TriggerClientEvent("garages:client:houseGarageConfig", -1, HouseGarages)
        	BJCore.Functions.ExecuteSql(true, "DELETE FROM `houselocations` WHERE `name` = @house", nil, {['@house'] = house})
        else
        	Config.Houses[house].owned = false
        	BJCore.Functions.ExecuteSql(true, "UPDATE `houselocations` SET `owned` = 0 WHERE `name` = @house", nil, {['@house'] = house})
        end  
        houseowneridentifier[house] = nil
		houseownercid[house] = nil
		housekeyholders[house] = nil
		TriggerClientEvent("bj-houses:client:setHouseConfig", -1, Config.Houses)
    else
        TriggerClientEvent('BJCore:Notify', src, 'You don\'t have permission to do that.', 'error')
    end
end)