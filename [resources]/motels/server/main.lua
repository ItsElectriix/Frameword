RegisterServerEvent('bj-motels:rentRoom')
AddEventHandler('bj-motels:rentRoom', function(room, motel)
	local src = tonumber(source)
	local Player = BJCore.Functions.GetPlayer(src)
	local identifier = Player.PlayerData.steam
	local citizenid = Player.PlayerData.citizenid
	BJCore.Functions.ExecuteSql(true, "SELECT * FROM player_motels WHERE motelid = '"..motel.."' AND room = '"..room.."'", function(spamCheck)
		BJCore.Functions.ExecuteSql(true, "SELECT * FROM player_motels WHERE identifier = '"..identifier.."' AND citizenid = '"..citizenid.."'", function(motelowner)
			if tonumber(Player.PlayerData.money['bank']) >= tonumber(Config.Complexs[motel].price) then
				if motelowner[1] == nil and spamCheck[1] == nil then
					Player.Functions.RemoveMoney('bank', Config.Complexs[motel].price, 'Rented motel room')
					BJCore.Functions.ExecuteSql(false, "INSERT INTO player_motels (identifier, citizenid, motelid, room, days_left) VALUES ('"..identifier.."', '"..citizenid.."', '"..motel.."', '"..room.."', 7)")
					TriggerClientEvent('BJCore:Notify', src, 'You have rented room '..room..' at '..Config.Complexs[motel].name, 'primary', 10000)
					TriggerClientEvent('bj-motels:sendEmail', src, true, Config.Complexs[motel].name, room, tonumber(Config.Complexs[motel].price))
					--TriggerClientEvent("chatMessage", src, "SYSTEM", "warning", "You have rented a motel room for 7 days. You're able to renew your lease up to 3 days before your end date. Note: Storage is tied to their specifc room. If you fail to renew, you'll lose access to the room storage")
					TriggerClientEvent('bj-motels:rentedRoom', -1, room, motel, Player.PlayerData.source, Player.PlayerData.citizenid)
					TriggerEvent("bj-log:server:CreateLog", "default", "Motels", "green", "**"..Player.PlayerData.name .. "** has rented room "..room.." at "..Config.Complexs[motel].name..".")
					for k,v in pairs(Config.Rooms) do
						if tostring(room) == tostring(v.roomno) and motel == v.motelid then
							Config.Rooms[k].identifier = Player.PlayerData.citizenid
							Config.Rooms[k].owner = src
							break
						end
					end
				elseif motelowner[1] ~= nil then
					if motelowner[1].days_left <= 3 then
						if Config.Complexs[motel].name == Config.Complexs[tonumber(motelowner[1].motelid)].name then
							Player.Functions.RemoveMoney('bank', Config.Complexs[motel].price, 'Renewed motel room')
							TriggerClientEvent('BJCore:Notify', src, 'Motel room '..room..' at '..Config.Complexs[motel].name..' has been renewed for '..BJCore.Config.Currency.Symbol..Config.Complexs[motel].price, "primary")
							TriggerClientEvent('bj-motels:sendEmail', src, false, Config.Complexs[motel].name, room, tonumber(Config.Complexs[motel].price))
							BJCore.Functions.ExecuteSql(false, "UPDATE `player_motels` SET `days_left` = 7 WHERE identifier = '"..identifier.."' AND citizenid = '"..citizenid.."'")
							TriggerEvent("bj-log:server:CreateLog", "default", "Motels", "green", "**"..Player.PlayerData.name .. "** has renewed room "..room.." at "..Config.Complexs[motel].name.." for 7 more days.")
						else
							TriggerClientEvent('BJCore:Notify', src, "You can only renew your motel room at "..Config.Complexs[tonumber(motelowner[1].motelid)].name, "primary")
						end
					else
						TriggerClientEvent('BJCore:Notify', src, 'You can only renew motel rooms 3 days before it runs out', 'error')
					end
				end
			else
				TriggerClientEvent('BJCore:Notify', src, 'You do not have enough money in the bank', 'error')
			end
		end)
	end)
end)

local raidRooms = {}

RegisterServerEvent('bj-motels:cancelRoom')
AddEventHandler('bj-motels:cancelRoom', function(room, motel)
	src = source
	local Player = BJCore.Functions.GetPlayer(src)
	local citizenid = Player.PlayerData.citizenid
	for k,v in pairs(Config.Rooms) do
		if tostring(room) == tostring(v.roomno) and motel == v.motelid then
			v.lock = true
			v.owner = nil
			v.identifier = nil
		end
	end
	BJCore.Functions.ExecuteSql(false, "DELETE FROM player_motels WHERE citizenid = '"..citizenid.."' AND motelid ='"..motel.."' AND room = '"..room.."'")
	TriggerClientEvent("bj-motels:cancelRoom", -1, room, motel)
end)

RegisterServerEvent('bj-motels:toggleLock')
AddEventHandler('bj-motels:toggleLock', function(motel, room, lock)
	for k,v in pairs(Config.Rooms) do
		if tostring(room) == tostring(v.roomno) and motel == v.motelid then
			v.lock = lock
		end
	end
	if raidRooms[motel..room] == true then
		raidRooms[motel..room] = nil
		TriggerClientEvent("motel:setraid", -1, raidRooms)
	end
	TriggerClientEvent('bj-motels:updateLocks', -1, room, motel, lock)
end)

BJCore.Functions.RegisterServerCallback('bj-motels:myIdent', function(source, cb)
	src = source
	local Player = BJCore.Functions.GetPlayer(src)
	local citizenid = Player.PlayerData.citizenid
	cb(citizenid)
end)

BJCore.Functions.RegisterServerCallback('motels:mycash', function(source, cb)
	src = source
	local Player = BJCore.Functions.GetPlayer(src)
	local bank = Player.PlayerData.money['bank']
	cb(bank)
end)

RegisterServerEvent('bj-motels:updateRooms')
AddEventHandler('bj-motels:updateRooms', function(source)
	BJCore.Functions.ExecuteSql(true, "SELECT * FROM player_motels", function(owners)
		if owners and owners ~= nil then
			for i=1, #owners, 1 do
				local motel = owners[i].motelid
				local room = owners[i].room
				local owner = owners[i].citizenid
				for k,v in pairs(Config.Rooms) do  
					if owners[i].room == tostring(v.roomno) and owners[i].motelid == v.motelid then
						local Player = BJCore.Functions.GetPlayerByCitizenId(owner)
						if Player then
							-- Set as Rented, and allocate the users ServerID so they can access it.
							Config.Rooms[k].owner = Player.PlayerData.source
							Config.Rooms[k].identifier = owner
						else
							-- Set as identifier so the Motel Room Appears as Rented to Other Players
							Config.Rooms[k].owner = owner
							Config.Rooms[k].identifier = owner
						end
					end
				end
			end
			TriggerClientEvent('bj-motels:receiveOwners', -1, Config.Rooms)
		end
	end)
end)

local initialLoad = false
RegisterNetEvent("bj-motels:getRoomData")
AddEventHandler("bj-motels:getRoomData", function()
	local src = source
	local Player = BJCore.Functions.GetPlayer(src)
	while not initialLoad do Citizen.Wait(500); end
	for k,v in pairs(Config.Rooms) do
		if Config.Rooms[k].identifier ~= nil then
			if Config.Rooms[k].identifier == Player.PlayerData.citizenid then
				Config.Rooms[k].owner = Player.PlayerData.source
				break
			end
		end
	end
	TriggerClientEvent("bj-motels:receiveOwners", src, Config.Rooms)
end)


Citizen.CreateThread(function()
	BJCore.Functions.ExecuteSql(true, "SELECT * FROM player_motels", function(owners)
		for i=1, #owners, 1 do
			local motel = owners[i].motelid
			local room = owners[i].room
			local owner = owners[i].citizenid
			for k,v in pairs(Config.Rooms) do
				if owners[i].room == tostring(v.roomno) and owners[i].motelid == v.motelid then
					local Player = BJCore.Functions.GetPlayerByCitizenId(owner)
					if Player then
						-- Set as Rented, and allocate the users ServerID so they can access it.
						Config.Rooms[k].owner = Player.PlayerData.source
						Config.Rooms[k].identifier = owner
					else
						-- Set as identifier so the Motel Room Appears as Rented to Other Players
						Config.Rooms[k].owner = owner
						Config.Rooms[k].identifier = owner
					end
				end
			end
		end
		initialLoad = true
	end)
end)

BJCore.Functions.RegisterServerCallback('bj-motels:checkUserOnline', function(source, cb, motel, room)
	for k,v in pairs(Config.Rooms) do
		if motel == v.motelid and room == v.roomno then
			if v.identifier == nil then
				cb(true)
			else
				local Player = BJCore.Functions.GetPlayerByCitizenId(v.identifier)
				if Player then
					cb(true)
				else
					cb(false)
				end
			end
		end
	end
end)

function forcePush()
	TriggerEvent('bj-motels:updateRooms')
	SetTimeout(60000, forcePush)
end

AddEventHandler('hotel:check', function(source)
	Wait(1000)
	local src = tonumber(source)
	local Player = BJCore.Functions.GetPlayer(src)
	local citizenid = Player.PlayerData.citizenid
	BJCore.Functions.ExecuteSql(true, "SELECT * FROM player_motels WHERE citizenid = '"..citizenid.."'", function(motelowner)
		if motelowner[1] ~= nil then
			if motelowner[1].days_left <= 3 then
				if motelowner[1].days_left ~= 1 then
					TriggerClientEvent('BJCore:Notify', src, 'Motel room '..motelowner[1].room..' at '..Config.Complexs[tonumber(motelowner[1].motelid)].name..' runs out in '..motelowner[1].days_left..' days. Renew it at on-site reception', 'primary')
				else
					TriggerClientEvent('BJCore:Notify', src, 'Motel room '..motelowner[1].room..' at '..Config.Complexs[tonumber(motelowner[1].motelid)].name..' runs out in '..motelowner[1].days_left..' day. Renew it at on-site reception', 'primary')
				end
			end
		end
	end)
end)

local builtRooms = {}

RegisterServerEvent('hotel:createRoom')
AddEventHandler('hotel:createRoom', function(data)
	local source = tonumber(source)
	local motelnroom = data.motelid..data.id
	if builtRooms[motelnroom] ~= nil and builtRooms[motelnroom].id ~= nil then
		builtRooms[motelnroom].people = builtRooms[motelnroom].people + 1
		TriggerClientEvent('hotel:sendToRoom', source, builtRooms[motelnroom])
	else
		builtRooms[motelnroom] = data
		builtRooms[motelnroom].people = 1
		TriggerClientEvent('hotel:sendToRoom', source, data)
	end
end)

RegisterServerEvent('hotel:deleteRoom')
AddEventHandler('hotel:deleteRoom', function(motelid, id, logout)
	logout = logout or false
	local source = tonumber(source)
	local motelnroom = motelid..id
	if builtRooms[motelnroom] and builtRooms[motelnroom].people == 1 then
		TriggerClientEvent('hotel:deleteRoom', source, builtRooms[motelnroom], logout)
		builtRooms[motelnroom] = nil
	elseif builtRooms[motelnroom] then
		TriggerClientEvent('hotel:deleteRoom', source, builtRooms[motelnroom], logout)
		builtRooms[motelnroom].people = builtRooms[motelnroom].people - 1
	end
end)

RegisterNetEvent("motel:setraid")
AddEventHandler("motel:setraid", function(motel, room)
	local motelnroom = motel..room
	raidRooms[motelnroom] = true
	TriggerClientEvent("motel:setraid", -1, raidRooms)
end)

-- RegisterNetEvent('hotel:testywesty')
-- AddEventHandler('hotel:testywesty', function()
-- CronTask()
-- end)

function CronTask(d, h, m)
	if GetConvar("server_type", "DEV") == "LIVE" then
		local reqUpdate = false
		BJCore.Functions.ExecuteSql(true, "SELECT * FROM player_motels", function(res)
			for id,v in pairs(res) do
				if v.days_left == 2 then
					local Player = BJCore.Functions.GetPlayerByCitizenId(v.citizenid)
		            local mailData = {
		                sender = Config.Complexs[tonumber(v.motelid)].name,
		                subject = "Room "..v.room.." has not been renewed",
		                message = "Your lease for Room "..v.room.." at our motel has not been renewed. Please visit our reception to renew your lease for another 7 days or we\'ll terminate your lease as scheduled in 3 days.<br/>Kind regards,<br />"..Config.Complexs[tonumber(v.motelid)].name,
		                button = {}
		            }				
					if Player ~= nil then
	                    TriggerClientEvent('bj-motels:sendOtherEmail', Player.PlayerData.source, true, mailData)
					else
			            TriggerEvent("phone:server:sendNewMailToOffline", v.citizenid, mailData)
			        end		
			        BJCore.Functions.ExecuteSql(false, "UPDATE `player_motels` SET `days_left` = days_left-1 WHERE citizenid = '"..v.citizenid.."'")			
				elseif v.days_left > 0 then
					BJCore.Functions.ExecuteSql(false, "UPDATE `player_motels` SET `days_left` = days_left-1 WHERE citizenid = '"..v.citizenid.."'")		
				else
					reqUpdate = true
					local Player = BJCore.Functions.GetPlayerByCitizenId(v.citizenid)
		            local mailData = {
		                sender = Config.Complexs[tonumber(v.motelid)].name,
		                subject = "Room "..v.room.." lease terminated",
		                message = "We\'ve terminated your lease for Room "..v.room.." at our motel because you\'ve not renewed your lease.<br/>Kind regards,<br />"..Config.Complexs[tonumber(v.motelid)].name,
		                button = {}
		            }				
					if Player ~= nil then
						TriggerClientEvent('bj-motels:sendOtherEmail', Player.PlayerData.source, false, mailData)
					else				
			            TriggerEvent("phone:server:sendNewMailToOffline", v.citizenid, mailData)
			        end			
					BJCore.Functions.ExecuteSql(false, "DELETE FROM player_motels WHERE citizenid = '"..v.citizenid.."' AND motelid = '"..v.motelid.."' AND room = '"..v.room.."'")
					TriggerEvent("bj-log:server:CreateLog", "default", "Motels", "green", "**"..v.citizenid .. "**'s room "..v.room.." at "..Config.Complexs[tonumber(v.motelid)].name.." has been terminated (lease lapsed)")
				end
			end
			if reqUpdate then
				TriggerEvent('bj-motels:updateRooms')
			end
		end)
	end
end

TriggerEvent('cron:runAt', 22, 00, CronTask)