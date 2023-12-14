local curAngle = -9.0
local isSpinning = false
local curWinningNum = 0
local curWinningKey = 0
local curSpinningPlayer = 0

local carData = {
	id = nil,
	model = nil,
	value = 0,
	current = 0,
	won = 0,
	max = 0
}

-- Config
local allowCarWin = true -- setting to false will never let players win a car at the lucky wheel | setting to true will allow car to be won if below max winnable amount
local reqValueBeforeWin = false -- car can only be won once the 'value' (carData.value) amount is met (requires: allowCarWin = true)
local saveCarToGarage = 'legion' -- set garage where a won car is saved to
local enableDebug = true
--

function LWDebug(data)
	if not enableDebug then return; end
	print(data)
end

BJCore.Commands.Add("testlw", "Debug command for lucky wheel", {{name="number", help="Times to test"}}, true, function(source, args)
	local tab = {}
	if tonumber(args[1]) then
		for i=1,tonumber(args[1]),1 do
			local price = GeneratePrize()
			if tab[curWinningKey] == nil then
				tab[curWinningKey] = 1
			else
				tab[curWinningKey] = tab[curWinningKey] + 1
			end
		end
		print("RESULTS ("..args[1].."): "..BJCore.Common.Dump(tab))
	end
end, "god")

local chancesTbl = {
	[1] = {
		chance = 200,
		type = false,
		segments = {1,4,5,8,9,12,13,16,17,20}
	},
	[2] = {
		chance = 28,
		type = "mystery", -- rnd item
		segments = 11,
	},
	[3] = {
		chance = 15,
		type = "chips",
		amount = 1000,
		segments = {3,7,10,15}
	},
	[4] = {
		chance = 11,
		type = "cash",
		amount = 20000,
		segments = 2
	},
	[5] = {
		chance = 9,
		type = "cash",
		amount = 30000,
		segments = 6
	},
	[6] = {
		chance = 7,
		type = "cash",
		amount = 40000,
		segments = 14
	},
	[7] = {
		chance = 5,
		type = "cash",
		amount = 50000,
		segments = 19
	},
	[8] = {
		chance = 2,
		type = "car",
		segments = 18,
	},
}

local randomMysteryItems = {
	[1] = {
		item = "radio",
		amount = 1,
	},
	[2] = {
		item = "water_bottle",
		amount = {
			min = 1,
			max = 5
		}
	},
	[3] = {
		item = "joint",
		amount = {
			min = 3,
			max = 6
		}
	},
	[4] = {
		item = "casinochips",
		amount = {
			min = 5,
			max = 80
		}
	},
	[5] = {
		item = "armor",
		amount = 1,
	}
}

RegisterNetEvent("luckywheel:server:getCurAngle", function()
	TriggerClientEvent("luckywheel:client:getCurAngle", source, curAngle)
end)

RegisterNetEvent("luckywheel:server:spinWheel", function()
	local src = source
	if isSpinning and curSpinningPlayer == src then
		curWinningNum = GeneratePrize()
		local totalSpin = GenerateSpinData(curWinningNum)
		LWDebug("[LUCKY WHEEL] - Winning Segment Number: "..curWinningNum)
		carData.current = carData.current + Config.LucklyWheelCost
		TriggerClientEvent("luckywheel:client:spinWheel", -1, src, curWinningNum, totalSpin)
	end
end)

RegisterNetEvent("luckywheel:server:attemptWheelSpin", function()
	local src = source
	if curSpinningPlayer == 0 and not isSpinning then
		curSpinningPlayer = src
		local Player = BJCore.Functions.GetPlayer(src)
		if Player ~= nil then
			if Player.Functions.RemoveMoney("cash", Config.LucklyWheelCost) then
				isSpinning = true
				curSpinningPlayer = src
				TriggerClientEvent("luckywheel:client:startSpin", src)
			else
				curSpinningPlayer = 0
				TriggerClientEvent('BJCore:Notify', src, "You cant afford to spin the wheel", "error", 3000)
			end
		end
	else
		TriggerClientEvent('BJCore:Notify', src, "Spinning Wheel is currently busy", "error", 3000)
	end
end)

RegisterNetEvent("luckywheel:server:completeWheel", function(angle)
	local src = source
	curAngle = angle
	isSpinning = false
	TriggerClientEvent("luckywheel:client:getCurAngle", -1, curAngle)
	TriggerClientEvent("luckywheel:client:handleWheelWin", -1, GetWinType(curWinningKey))
	if curSpinningPlayer == src then
		HandleWheelReward(src, curWinningKey)
	end
	curWinningNum = 0
	curSpinningPlayer = 0
	curWinningKey = 0
	Wait(1000)
	TriggerClientEvent("luckywheel:client:spinWheel", -1, false)
end)

function HandleWheelReward(src, winKey)
	local Player = BJCore.Functions.GetPlayer(src)
	if Player ~= nil then
		if chancesTbl[winKey].type == "mystery" then
			local rndItem = randomMysteryItems[math.random(#randomMysteryItems)]
			local amount = rndItem.amount
			if type(amount) == "table" then amount = math.random(amount.min, amount.max); end
			if Player.Functions.AddItem(rndItem.item, amount) then
				TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items[rndItem.item], "add")
				TriggerClientEvent('BJCore:Notify', src, "You have won x"..amount.." "..BJCore.Shared.Items[rndItem.item].label.."(s)", "primary", 3000)
			end
		elseif chancesTbl[winKey].type == "chips" then
			local amount = chancesTbl[winKey].amount
			if type(amount) == "table" then amount = math.random(amount.min, amount.max); end
			if Player.Functions.AddItem("casinochips", amount) then
				TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items["casinochips"], "add")
				TriggerClientEvent('BJCore:Notify', src, "You have won x"..amount.." Casino Chips", "primary", 3000)
			end
		elseif chancesTbl[winKey].type == "cash" then
			local amount = chancesTbl[winKey].amount
			if type(amount) == "table" then amount = math.random(amount.min, amount.max); end
			Player.Functions.AddMoney("cash", amount, "luckywheel winnings")
		elseif chancesTbl[winKey].type == "car" then
            BJCore.Functions.ExecuteSql(false, "INSERT INTO `player_vehicles` (`steam`, `citizenid`, `vehicle`, `hash`, `mods`, `plate`, `garage`) VALUES (@steam, @citizenid, @vehicle, @hash, @mods, @plate, @garage)", nil, {
                ['@steam'] = Player.PlayerData.steam,
                ['@citizenid'] = Player.PlayerData.citizenid,
                ['@vehicle'] = BJCore.Shared.VehicleModels[carData.model].model,
                ['@hash'] = carData.model,
                ['@mods'] = '{}',
                ['@plate'] = exports["vehicleshop"]:GeneratePlate(),
                ['@garage'] = saveCarToGarage
            })
            TriggerClientEvent('BJCore:Notify', src, "The car you've won has been delivered to garage: "..exports["garages"]:GetGarageLabel("vehicle", saveCarToGarage), "primary", 10000)
            carData.won = carData.won + 1
            BJCore.Functions.ExecuteSql(false, "UPDATE `luckywheel` SET `won` = @won WHERE `id` = @id", nil, {
				["@id"] = carData.id,
				["@won"] = carData.won
			})
		end
	end
end

function GeneratePrize()
	local sum = 0
	for _, data in pairs(chancesTbl) do
		sum = sum + data.chance
	end
	local selectedValidPrize = false
	local winningKey, segmentResult
	while not selectedValidPrize do
		local rand = BJCore.Common.TrueRandom(0, sum)
		for key, data in pairs(chancesTbl) do
			winningKey = key
			rand = rand - data.chance
			if rand <= 0 then break; end
		end
		if chancesTbl[winningKey].type == "car" then
			if allowCarWin then
				selectedValidPrize = true
				if (reqValueBeforeWin and carData.current <= carData.value) then
					selectedValidPrize = false
				end
				if carData.won + 1 > carData.max then
					selectedValidPrize = false
				end
			end
		else
			selectedValidPrize = true
		end
		if selectedValidPrize then
			curWinningKey = winningKey
		end
		Citizen.Wait(0)
	end
	LWDebug("[LUCKY WHEEL] - Winning Type: "..tostring(chancesTbl[winningKey].type))
	if type(chancesTbl[winningKey].segments) == "table" then
		segmentResult = chancesTbl[winningKey].segments[math.random(#chancesTbl[winningKey].segments)]
	else
		segmentResult = chancesTbl[winningKey].segments
	end
	return segmentResult
end

function GenerateSpinData(prize)
    local offset = curAngle+9.0
    local winAngle = math.random((18*prize)-18+1, (18*prize)-1)
    local totalSpin = winAngle + (360 * 2) + offset
    return totalSpin
end

function GetWinType(num)
	return chancesTbl[num].type
end

-- Citizen.CreateThread(function()
-- 	local idTab = {}
-- 	BJCore.Functions.ExecuteSql(true, "SELECT * FROM `luckywheel`", function(data)
-- 		for k,v in pairs(data) do
-- 			table.insert(idTab, v.id)
-- 		end
-- 		table.sort(idTab)
-- 		local highest = idTab[#idTab]
-- 		carData.id = data[highest].id
-- 		carData.model = GetHashKey(data[highest].model)
-- 		carData.value = tonumber(data[highest].value)
-- 		carData.current = tonumber(data[highest].current)
-- 		carData.won = tonumber(data[highest].won)
-- 		carData.max = tonumber(data[highest].max)
-- 		LWDebug("[LUCKY WHEEL] - Current Winnable Vehicle Model: "..data[highest].model.." | Set Value: "..carData.value.." | Currently Spent: "..carData.current.." | ID: "..carData.id)
-- 		LWDebug("[LUCKY WHEEL] - Currently Won: "..carData.won.." | Max Winnable: "..carData.max)
-- 	end)
-- 	local lastAmount = carData.current
-- 	while true do
-- 		Citizen.Wait(60000)
-- 		if carData.current ~= lastAmount then
-- 			BJCore.Functions.ExecuteSql(true, "UPDATE `luckywheel` SET `current` = @current WHERE `model` = @oldmodel", nil, {
-- 				["@oldmodel"] = BJCore.Shared.VehicleModels[carData.model].model,
-- 				["@current"] = carData.current
-- 			})
-- 		end
-- 	end
-- end)

RegisterNetEvent("luckywheel:server:getVehicleModel", function()
	TriggerClientEvent("luckywheel:client:updateVehicleModel", source, carData.model)
end)

BJCore.Commands.Add("luckyvehicle", "Set Lucky Wheel vehicle model", {{name="model", help="Vehicle model name"}, {name="number", help="amount"}, {name='number', help='Max Winnable'}}, true, function(source, args)
	local Player = BJCore.Functions.GetPlayer(source)
	if BJCore.Shared.VehicleModels[GetHashKey(args[1])] ~= nil then
		if tonumber(args[2]) and tonumber(args[3]) then
			BJCore.Functions.ExecuteSql(true, "INSERT INTO `luckywheel` (`model`, `value`, `current`, `won`) VALUES (@model, @value, @current, @won)", function(data)
				carData.id = data.insertId
				carData.model = GetHashKey(args[1])
				carData.value = tonumber(args[2])
				carData.current = 0
				carData.won = 0
				carData.max = tonumber(args[3])
			end, {
				["@model"] = args[1],
				["@value"] = tonumber(args[2]),
				["@current"] = 0,
				["@won"] = 0,
			})
		else
			TriggerClientEvent('BJCore:Notify', source, "Enter a numerical value only", "error", 5000)
		end
	else
		TriggerClientEvent('BJCore:Notify', source, "This vehicle model is missing from shared", "error", 5000)
	end
end, "god")