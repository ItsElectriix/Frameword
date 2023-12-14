local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local PlayerData = {}
local myRoom = {}
local myMotel = {}
local ownsMotel = false
local inmotel = false
local showmenushit = false
local showClothing = false
local roomInfo = {}
local depthZ = 75

Citizen.CreateThread(function()
	while not BJCore do Citizen.Wait(1000); end
	while not BJCore.Functions.IsPlayerLoaded() do Citizen.Wait(1000); end
	PlayerLoaded = true
	PlayerData = BJCore.Functions.GetPlayerData()
end)

RegisterNetEvent('BJCore:Player:SetPlayerData')
AddEventHandler('BJCore:Player:SetPlayerData', function(Player)
	PlayerData = Player
end)

RegisterNetEvent('BJCore:Client:OnJobUpdate')
AddEventHandler('BJCore:Client:OnJobUpdate', function(JobInfo)
	PlayerData.job = JobInfo
end)

RegisterNetEvent("BJCore:Client:OnPlayerLoaded")
AddEventHandler("BJCore:Client:OnPlayerLoaded", function()
	PlayerLoaded = true
	TriggerServerEvent('bj-motels:getRoomData')
end)

RegisterNetEvent('BJCore:Client:OnPlayerUnload')
AddEventHandler('BJCore:Client:OnPlayerUnload', function()
    myMotel = {}
    ownsMotel = false
    roomInfo = {}
end)

RegisterNetEvent('bj-motels:receiveOwners')
AddEventHandler('bj-motels:receiveOwners', function(rooms)
	Config.Rooms = rooms
	myMotel = {}

	ownsMotel = false
    for i=1, #Config.Rooms, 1 do
		roomid = Config.Rooms[i]
		if roomid.identifier == PlayerData.citizenid then
			roomInfo = roomid
		    ownsMotel = true
		    myMotel = {id = roomid.roomno, motel = roomid.motelid}
		end
    end
end)

RegisterNetEvent("bj-motels:cancelRoom")
AddEventHandler("bj-motels:cancelRoom", function(room, motel)
	for k,v in pairs(Config.Rooms) do
		if tostring(room) == tostring(v.roomno) and motel == v.motelid then
		    myMotel = {}
		    ownsMotel = false
		    roomInfo = {}
			v.lock = true
			v.owner = nil
			v.identifier = nil
		end
	end
end)

RegisterNetEvent("bj-motels:rentedRoom")
AddEventHandler("bj-motels:rentedRoom", function(room, motel, id, citizenid)
	for k,v in pairs(Config.Rooms) do
		if tostring(room) == tostring(v.roomno) and motel == v.motelid then
			v.owner = id
			v.identifier = citizenid
		end
	end
end)

RegisterNetEvent("bj-motels:updateLocks")
AddEventHandler("bj-motels:updateLocks", function(room, motel, lock)
	for k,v in pairs(Config.Rooms) do
		if tostring(room) == tostring(v.roomno) and motel == v.motelid then
			v.lock = lock
		end
	end
end)

RegisterNetEvent("police:client:stormram")
AddEventHandler("police:client:stormram", function()
	local plyPed = PlayerPedId()
	local plyPos = GetEntityCoords(plyPed)
	for i=1, #Config.Rooms, 1 do
		entryDist = #(plyPos - Config.Rooms[i].entry)
		if entryDist < 1.0 then
			roomInfo = Config.Rooms[i]
	        exports['mythic_progbar']:Progress({
	            name = "stormram",
	            duration = math.random(15000, 20000),
	            label = "Interacting",
	            useWhileDead = false,
	            canCancel = true,
	            controlDisables = {
	                disableMovement = true,
	                disableCarMovement = true,
	                disableMouse = false,
	                disableCombat = true,
	            },
	        }, function(status)
	            if not status then
					TriggerServerEvent('bj-motels:toggleLock', roomInfo.motelid, roomInfo.roomno, false)
					TriggerServerEvent("motel:setraid", roomInfo.motelid, roomInfo.roomno, true)
	            else
	                BJCore.Functions.Notify("Cancelled", "error")
	            end
	        end)
		end
	end
end)

raidRooms = {}
RegisterNetEvent("motel:setraid")
AddEventHandler("motel:setraid", function(data) raidRooms = data end)

-- RegisterCommand('breach', function(source, args)
-- 	local playerPed = PlayerPedId()
-- 	local pCoords = GetEntityCoords(playerPed)
-- 	local found = false
-- 	if PlayerData.job and PlayerData.job.name == 'police' then
-- 		for i=1, #Config.Rooms, 1 do
-- 			entryDist = #(pCoords - Config.Rooms[i].entry)
-- 			if entryDist < 1.0 then
-- 				found = true
-- 				roomInfo = Config.Rooms[i]
-- 				TriggerServerEvent('hotel:createRoom', {motelid = Config.Rooms[i].motelid, id = Config.Rooms[i].roomno, pos = vector3(Config.Rooms[i].entry.x, Config.Rooms[i].entry.y, Config.Rooms[i].entry.z-depthZ), outZ = Config.Rooms[i].outZ, heading = Config.Rooms[i].heading, isUpper = Config.Rooms[i].upperfloor})
-- 			end
-- 		end

-- 		if not found then
-- 			BJCore.Functions.Notify("This room isn't owned", 'error')
-- 		end
-- 	else
-- 		BJCore.Functions.Notify("You are not police", 'error')
-- 	end
-- end)

-- RegisterCommand('raidroom', function(source, args)
-- 	local playerPed = PlayerPedId()
-- 	local pCoords = GetEntityCoords(playerPed)
-- 	local found = false
-- 	if PlayerData.job and PlayerData.job.name == 'police' then
-- 		for i=1, #Config.Rooms, 1 do
-- 			entryDist = #(pCoords - Config.Rooms[i].entry)
-- 			if entryDist < 1.0 and Config.Rooms[i].identifier ~= nil then
-- 				found = true
-- 				roomInfo = Config.Rooms[i]
-- 				TriggerServerEvent('hotel:createRoom', {motelid = Config.Rooms[i].motelid, id = Config.Rooms[i].roomno, pos = vector3(Config.Rooms[i].entry.x, Config.Rooms[i].entry.y, Config.Rooms[i].entry.z-depthZ), outZ = Config.Rooms[i].outZ, heading = Config.Rooms[i].heading, isUpper = Config.Rooms[i].upperfloor})
-- 				showmenushit = true
-- 			end
-- 		end

-- 		if not found then
-- 			TriggerEvent('chatMessage', "This room isn't owned", 'error')
-- 		end
-- 	else
-- 		TriggerEvent('chatMessage', "You are not police", 'error')
-- 	end
-- end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		plyPed = PlayerPedId()
		plyPos = GetEntityCoords(plyPed)
		local nearby = false

		for i=1, #Config.Complexs do
			complex = Config.Complexs[i]
			if #(plyPos.xy - complex.reception.xy) < 15 then
				nearby = true
				if #(plyPos.xy - complex.reception.xy) < 2.5 then
					if ownsMotel then
						BJCore.Functions.DrawText3D(complex.reception.x, complex.reception.y, complex.reception.z+0.25, "[~g~E~w~] Renew your motel ("..BJCore.Config.Currency.Symbol.."~g~"..complex.price.."~w~) [7 days]")
					else
						BJCore.Functions.DrawText3D(complex.reception.x, complex.reception.y, complex.reception.z+0.25, "[~g~E~w~] Rent a motel room ("..BJCore.Config.Currency.Symbol.."~g~"..complex.price.."~w~) [7 days]")
					end
					if IsControlJustPressed(0, 38) then
						local allHotelS = {}
						local totalRooms = 0

						TriggerEvent('dooranim')

						for id,v in pairs(Config.Rooms) do
						    if v.motelid == complex.id then
								allHotelS[totalRooms] = v

								if v.identifier == nil then
									totalRooms = totalRooms + 1
								end
						    end
						end

						if not ownsMotel then
							if totalRooms >= 1 then
								BJCore.Functions.TriggerServerCallback('motels:mycash', function(cash)
									if cash >= complex.price then
										local testHotel = {}
										if totalRooms == 1 then
											testHotel = allHotelS[0]
										else
											testHotel = allHotelS[math.random(1, totalRooms)]
										end

										TriggerServerEvent('bj-motels:rentRoom', testHotel.roomno, testHotel.motelid)
									else
										BJCore.Functions.Notify('You do not have enough money in the bank', 'error')
									end
								end)
							else
								BJCore.Functions.Notify('No rooms available', 'error')
							end
						end

						if ownsMotel then
							if Config.Complexs[i].name == Config.Complexs[myMotel.motel].name then
								TriggerServerEvent('bj-motels:rentRoom', myMotel.id, myMotel.motel)
							else
								BJCore.Functions.Notify("You can only renew your motel room at "..Config.Complexs[tonumber(myMotel.motel)].name, 2 )
							end
						end
					end
				end
			end
		end

		for i=1, #Config.Rooms, 1 do
			roomid = Config.Rooms[i]
			motel = roomid.motelid
			offset = Config.Complexs[motel].offsets

			entryDist = #(plyPos - roomid.entry)

			if entryDist < 25.0 then
				nearby = true
				if roomid.identifier == PlayerData.citizenid then
					DrawMarker(20, roomid.entry.x, roomid.entry.y, roomid.entry.z+0.25, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.15, 43, 196, 253, 100, false, true, 2, false, nil, nil, false)
				end
			end

			if entryDist < 1.2 then
				if roomid.identifier == PlayerData.citizenid or (PlayerData.job.name == "police" and raidRooms[roomid.motelid..roomid.roomno]) then
					if roomid.lock then
						BJCore.Functions.DrawText3D(roomid.entry.x, roomid.entry.y, roomid.entry.z+0.25, "[~g~H~w~] Enter | [~g~G~w~] Unlock room ("..roomid.roomno..')')
						if IsControlJustReleased(0,  Keys['G']) then
							BJCore.Functions.Notify('Unlocked')
							TriggerEvent('dooranim')
							TriggerServerEvent('bj-motels:toggleLock', roomid.motelid, roomid.roomno, false)
							TriggerEvent('InteractSound_CL:PlayOnOne', 'houses_door_unlock', 0.8)
						end
						if IsControlJustReleased(0,  Keys['H']) then
							TriggerServerEvent('hotel:createRoom', {motelid = motel, id = roomid.roomno, pos = vector3(roomid.entry.x, roomid.entry.y, roomid.entry.z-depthZ), outZ = roomid.outZ, heading = roomid.heading, isUpper = Config.Rooms[i].upperfloor})
							showmenushit = true
							roomInfo = roomid
							showClothing = true
						end
					else 
						BJCore.Functions.DrawText3D(roomid.entry.x, roomid.entry.y, roomid.entry.z+0.25, "[~g~H~w~] Enter | [~g~G~w~] Lock room ("..roomid.roomno..')')
						if IsControlJustReleased(0,  Keys['G']) then
							BJCore.Functions.Notify('Locked')
							TriggerEvent('dooranim')
							TriggerServerEvent('bj-motels:toggleLock', roomid.motelid, roomid.roomno, true)
							TriggerEvent('InteractSound_CL:PlayOnOne', 'houses_door_lock', 0.8)
						end
						if IsControlJustReleased(0,  Keys['H']) then
							TriggerServerEvent('hotel:createRoom', {motelid = motel, id = roomid.roomno,  pos = vector3(roomid.entry.x, roomid.entry.y, roomid.entry.z-depthZ), outZ = roomid.outZ, heading = roomid.heading, isUpper = Config.Rooms[i].upperfloor})
							roomInfo = roomid
							showmenushit = true
							showClothing = true
						end
						if IsControlJustReleased(0,  Keys['U']) then
							TriggerServerEvent('bj-motels:cancelRoom', roomid.roomno, roomid.motelid)
						end
					end
				else
					if not roomid.lock then 
						BJCore.Functions.DrawText3D(roomid.entry.x, roomid.entry.y, roomid.entry.z+0.25, "[~g~H~w~] Enter | Room ("..roomid.roomno..')')
						if IsControlJustReleased(0,  Keys['H']) then
							TriggerServerEvent('hotel:createRoom', {motelid = motel, id = roomid.roomno, pos = vector3(roomid.entry.x, roomid.entry.y, roomid.entry.z-depthZ), outZ = roomid.outZ, heading = roomid.heading, isUpper = Config.Rooms[i].upperfloor})
							showmenushit = false
							roomInfo = roomid
							showClothing = true
						end
					end	
				end
			end
		end
		if not nearby then Citizen.Wait(1000); end
	end
end)

function inMotel()
	local stash = vector3(myRoom.pos.x-1.8, myRoom.pos.y-0.41, myRoom.pos.z+1.25)
	local clothing = vector3(myRoom.pos.x-2, myRoom.pos.y+ 2.5, myRoom.pos.z+1.25)
	local exit = vector3(myRoom.pos.x - 1.15, myRoom.pos.y - 4.2, myRoom.pos.z+1.20)
	while inmotel do
		local plyPed = PlayerPedId()
		local plyPos = GetEntityCoords(plyPed)
		if #(plyPos - exit) < 1.0 then
			BJCore.Functions.DrawText3D(exit.x, exit.y, exit.z, "[~g~H~w~] Leave")
			if IsControlJustReleased(0, Keys['H']) then
				TriggerServerEvent('hotel:deleteRoom', roomInfo.motelid, roomInfo.roomno, false)
			end			
			if roomid.identifier == PlayerData.citizenid then
				if roomInfo.lock then
					BJCore.Functions.DrawText3D(exit.x, exit.y, exit.z-0.06, "[~g~G~w~] Unlock")
				else
	                BJCore.Functions.DrawText3D(exit.x, exit.y, exit.z-0.06, "[~g~G~w~] Lock")
				end
				if IsControlJustReleased(0,  Keys['G']) then
					TriggerEvent('dooranim')
					if roomInfo.lock then
						BJCore.Functions.Notify('Unlocked')
						TriggerServerEvent('bj-motels:toggleLock', roomInfo.motelid, roomInfo.roomno, false)
						TriggerEvent('InteractSound_CL:PlayOnOne', 'houses_door_unlock', 0.8)
					else
						BJCore.Functions.Notify('Locked')
						TriggerServerEvent('bj-motels:toggleLock', roomInfo.motelid, roomInfo.roomno, true)
						TriggerEvent('InteractSound_CL:PlayOnOne', 'houses_door_lock', 0.8)
					end
				end
			end
		end

        if showmenushit then
			if #(plyPos - stash) < 1.2 then
				num = GetPlayerServerId()
				BJCore.Functions.DrawText3D(stash.x, stash.y, stash.z, "[~g~E~w~] Stash")
				if IsControlJustReleased(0, 38) then
					TriggerServerEvent("inventory:server:OpenInventory", "stash", "motel"..myRoom.motelid.."_room"..myRoom.id, nil, Config.Complexs[myRoom.motelid].name.." - Room "..myRoom.id)
	                TriggerEvent("inventory:client:SetCurrentStash", "motel"..myRoom.motelid.."_room"..myRoom.id)
					TriggerEvent('InteractSound_CL:PlayOnOne', 'StashOpen', 0.8)
				end
			end
		end

		if #(plyPos - clothing) < 1.2 then
			num = GetPlayerServerId()
			BJCore.Functions.DrawText3D(clothing.x, clothing.y, clothing.z, "[~g~E~w~] Wardrobe")
			if IsControlJustReleased(0, 38) then
				TriggerEvent('bj-clothing:client:openOutfitMenu')
				TriggerEvent('InteractSound_CL:PlayOnOne', 'Stash', 0.6)
			end
			BJCore.Functions.DrawText3D(clothing.x, clothing.y, clothing.z-0.06, "[~r~H~w~] Logout")
			if IsControlJustReleased(0, 74) then
				DoScreenFadeOut(2000)
				Wait(1750)
				SetEntityAlpha(PlayerPedId(), 0, false)
				FreezeEntityPosition(PlayerPedId(), true)
				TriggerServerEvent('hotel:deleteRoom', roomInfo.motelid, roomInfo.roomno, true)
			end			
		end
		Citizen.Wait(0)
	end
end

RegisterNetEvent('hotel:sendToRoom')
AddEventHandler('hotel:sendToRoom', function(data)
	buildHotel(data)
end)

RegisterNetEvent('hotel:deleteRoom')
AddEventHandler('hotel:deleteRoom', function(data, logout)
	print("delete room: "..BJCore.Common.Dump(data))
	removeHotel(data, logout)
end)

local builtRooms = {}
function buildHotel(generator)
	if generator.isUpper then generator.pos = vector3(generator.pos.x, generator.pos.y, generator.pos.z - 10.0); end
	TriggerEvent('outfit:canUse', true)
	myRoom = generator
	inmotel = true
	TriggerEvent('InteractSound_CL:PlayOnOne', 'houses_door_open', 0.4)
	TriggerEvent('dooranim')
	builtRooms = exports["interior"]:CreateHotelFurnished(generator.pos)
    SetRainFxIntensity(0.0)
    TriggerEvent('bj-weathersync:client:DisableSync')	
    SetWeatherTypePersist('EXTRASUNNY')
    SetWeatherTypeNow('EXTRASUNNY')
    SetWeatherTypeNowPersist('EXTRASUNNY')
    NetworkOverrideClockTime(23, 0, 0)
    TriggerEvent('weed:client:getHousePlants', generator.motelid..generator.id)
    inMotel()
end

function removeHotel(data, logout)
	TriggerEvent('outfit:canUse', false)
	showClothing = false
	inmotel = false
	showmenushit = false
	TriggerEvent('dooranim')
	TriggerEvent('InteractSound_CL:PlayOnOne', 'houses_door_close', 0.4)
	DoScreenFadeOut(250)
	Citizen.Wait(250)
	for id,v in pairs(builtRooms[1]) do
		DeleteObject(v)
	end
	TriggerEvent("weed:client:leaveHouse")
    TriggerEvent('bj-weathersync:client:EnableSync')
	SetEntityCoords(PlayerPedId(), data.pos.x, data.pos.y, data.outZ)
	SetEntityHeading(PlayerPedId(), data.heading+180.0)
	if logout then
		TriggerServerEvent('bj-core:multichar:server:logout')
	else
		DoScreenFadeIn(250)
	end
end

RegisterNetEvent('bj-motels:sendEmail')
AddEventHandler('bj-motels:sendEmail', function(new, motel, room, price)
    SetTimeout(math.random(2500, 4000), function()
        local gender = "Mr."
        if BJCore.Functions.GetPlayerData().charinfo.gender == "1" then
            gender = "Mrs."
        end
        local charinfo = BJCore.Functions.GetPlayerData().charinfo
        if new then
	        TriggerServerEvent('phone:server:sendNewMail', {
	            sender = motel,
	            subject = "New Room Rental",
	            message = "Dear " .. gender .. " " .. charinfo.lastname .. ",<br /><br />Regarding your new motel room rental.<br />The 7 day rental cost for room "..room.." totals: <strong>"..BJCore.Config.Currency.Symbol..price..".</strong> You're able to renew your rental up to 3 days before your end date. Note: Storage is tied to their specifc room. If you fail to renew, you'll lose access to the room storage <br /><br />We hope you enjoy your stay!",
	            button = {}
	        })
	    else
	    	TriggerServerEvent('phone:server:sendNewMail', {
	            sender = motel,
	            subject = "Room: "..room.." Renewal",
	            message = "Dear " .. gender .. " " .. charinfo.lastname .. ",<br /><br />Regarding your motel room renewal.<br />You have renewed your room for another 7 days at the cost of: <strong>"..BJCore.Config.Currency.Symbol..price..".</strong> You're able to renew your rental up to 3 days before your next end date. Note: Storage is tied to their specifc room. If you fail to renew, you'll lose access to the room storage <br /><br />We hope you enjoy your stay!",
	            button = {}
	        })
	    end
    end)
end)

RegisterNetEvent('bj-motels:sendOtherEmail')
AddEventHandler('bj-motels:sendOtherEmail', function(renew, data)
    SetTimeout(math.random(2500, 4000), function()
        if renew then
	        TriggerServerEvent('phone:server:sendNewMail', data)
	    else -- terminate    	
	    	TriggerServerEvent('phone:server:sendNewMail', data)
	    end
    end)
end)

RegisterNetEvent('dooranim')
AddEventHandler('dooranim', function()
	ClearPedSecondaryTask(PlayerPedId())
	loadAnimDict("anim@heists@keycard@")
	TaskPlayAnim( PlayerPedId(), "anim@heists@keycard@", "exit", 8.0, 1.0, -1, 16, 0, 0, 0, 0 )
	Citizen.Wait(850)
	ClearPedTasks(PlayerPedId())
end)

function loadAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		RequestAnimDict(dict)
		Citizen.Wait(5)
	end
end