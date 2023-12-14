-- function SRStart()

-- 	while not BJCore do Citizen.Wait(1000); end
-- 	while not BJCore.Functions.IsPlayerLoaded() do Citizen.Wait(1000); end

-- 	SRUpdate()
-- end

-- local RaceFinish, RaceJoinPos, RaceID, RaceWager, FaceFinish = false, false, false, false, false
-- function SRUpdate()
--     local warn = false
-- 	while true do
-- 		Citizen.Wait(0)
-- 		if RaceFinish then
-- 			local plyId = PlayerId()
-- 			local plyPed = GetPlayerPed(plyId)
-- 			local plyPos = GetEntityCoords(plyPed)
-- 			local grounded,groundZ = GetGroundZFor_3dCoord(RaceFinish.x, RaceFinish.y, RaceFinish.z, groundZ, 0)
-- 			if grounded then 
-- 				local raceFin = vector3(RaceFinish.x, RaceFinish.y, groundZ)
-- 				local dist = #(plyPos - raceFin)

-- 				if dist < Config.SRFinishRaceDist then
-- 					SRFinishRace()
-- 				end

-- 				if dist < Config.SRDrawMarkerDist then
-- 					local pos = raceFin
-- 					DrawMarker(5, pos.x, pos.y, pos.z + Config.SRFlagMarkerOffsetZ, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 20.0, 20.0, 20.0, 255, 255, 255, 100, false, true, 2, false, false, false, false)
-- 					DrawMarker(1, pos.x, pos.y, pos.z + Config.SRGroundMarkerOffsetZ, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 20.0, 20.0, 20.0, 255, 255, 255, 100, false, true, 2, false, false, false, false)
-- 				end
-- 			end			
-- 		end

-- 		if RaceJoinPos then			
-- 			local plyId = PlayerId()
-- 			local plyPed = GetPlayerPed(plyId)
-- 			local plyPos = GetEntityCoords(plyPed)

-- 			if #(plyPos - RaceJoinPos) > Config.SRLeaveDist then

-- 				TriggerServerEvent('JAM_RaceMod:LeaveRace', RaceID)
-- 				TriggerServerEvent('JAM_RaceMod:SetMoney', RaceWager)

-- 				RaceID = false
-- 				RaceJoinPos = false
-- 				RaceFinish = false		
-- 				RaceWager = false
--                 BJCore.Functions.Notify("You left the race",'primary')
-- 			elseif #(plyPos - RaceJoinPos) > Config.SRLeaveWarnDist then
--                 if not warn then BJCore.Functions.Notify("Don't move so far from your start point!",'error'); warn = true; end
-- 			end
--         end
--         if not RaceFinish and RaceJoinPos then; Citizen.Wait(700); end
-- 	end
-- end

-- function SRSetupRace(wager)

-- 	if wager and wager[1] and type(wager[1]) == "string" then wager = tonumber(wager[1])
-- 	else wager = 0; end

-- 	local plyId = PlayerId()
-- 	local plyPed = GetPlayerPed(plyId)	

-- 	if not IsPedInAnyVehicle(plyPed) then
--         BJCore.Functions.Notify('You need to be in a vehicle first','error')
-- 		return
-- 	end

-- 	local plyPos = GetEntityCoords(plyPed)	
-- 	local plyVeh = GetVehiclePedIsIn(plyPed, true)
-- 	local raceID = math.random(999999, 10000000)

-- 	local blip = GetFirstBlipInfoId(8)
-- 	local blipCoord
-- 	if DoesBlipExist(blip) then
-- 		blipCoord = GetBlipInfoIdCoord(blip)		
-- 	else
--         BJCore.Functions.Notify('You need to set a waypoint first','error')
-- 		return
-- 	end	

-- 	if wager > 0 then
-- 		local plyData = BJCore.Functions.GetPlayerData()
-- 		if plydata.money.cash >= wager then 
-- 			TriggerServerEvent('JAM_RaceMod:SetMoney', -wager)
-- 		else 
--             BJCore.Functions.Notify('You don\'t have enough cash to wager this amount','error')
-- 			return
-- 		end
-- 	end

-- 	RaceID = raceID
-- 	RaceWager = wager
-- 	RaceJoinPos = plyPos
--     BJCore.Functions.Notify('You have started a race. Challenging nearby players','primary',Config.SRWaitForPlayersTimer * 1000)

-- 	Citizen.CreateThread(function()
-- 		BJCore.Functions.TriggerServerCallback('JAM_RaceMod:SetupRace', function(playersJoined)
-- 			if not RaceJoinPos then return; end
-- 			if playersJoined > 1 then
-- 				TriggerServerEvent('JAM_RaceMod:StartRace', RaceID)
-- 			else
--                 BJCore.Functions.Notify('Nobody joined your race','error')
-- 				TriggerServerEvent('JAM_RaceMod:SetMoney', wager)
-- 				RaceID = false
-- 				RaceWager = false
-- 				RaceJoinPos = false
-- 				RaceFinish = false
-- 			end
-- 		end, plyPos, blipCoord, RaceID, wager)
-- 	end)
-- end

-- RegisterNetEvent('JAM_RaceMod:ChallengeNearbyPlayers')
-- AddEventHandler('JAM_RaceMod:ChallengeNearbyPlayers', function(racePos, raceID, wager)
-- 	if RaceID then return; end

-- 	local canJoin = true
-- 	if wager and wager > 0 then
-- 		local plyData = BJCore.Functions.GetPlayerData()
-- 		if plydata.money.cash < wager then canJoin = false; end
-- 	end

-- 	local plyId = PlayerId()
-- 	local plyPed = GetPlayerPed(plyId)	
-- 	local plyVeh = GetVehiclePedIsIn(plyPed)
-- 	local vehPed = GetPedInVehicleSeat(plyVeh, -1)
-- 	if plyPed ~= vehPed then return; end

-- 	local plyPos = GetEntityCoords(plyPed)	
-- 	local dist = #(racePos - plyPos) 

-- 	if dist < Config.SRJoinDistLimit  then
-- 		Citizen.CreateThread(function(...) 
-- 			local timer = GetGameTimer()
-- 			local tick = 0
-- 			local str = ""
-- 			if wager and wager > 0 then str = "Line up your vehicle and press [E] to join the race. Wager: "..BJCore.Config.Currency.Symbol .. wager
--             else str = "Line up your vehicle and press [E] to join the race"; end
--             BJCore.Functions.Notify(str,'primary', Config.SRJoinTimeout * 1000)
-- 			while (GetGameTimer() - timer) < (Config.SRJoinTimeout * 1000) and not RaceID do
-- 				Citizen.Wait(0)

-- 				if (IsControlJustPressed(1, Keys["E"]) or IsDisabledControlJustPressed(1, Keys["E"])) then
-- 					if canJoin then
-- 						RaceID = raceID
-- 						RaceWager = wager
-- 						RaceJoinPos = plyPos
-- 						TriggerServerEvent('JAM_RaceMod:SetMoney', -RaceWager)
-- 						TriggerServerEvent('JAM_RaceMod:JoinRace', RaceID)
-- 					else timer = 0; end
-- 				end
-- 				tick = tick + 1
-- 			end

-- 			if not RaceID then 
-- 				if wager > 0 and not canJoin then
--                     BJCore.Functions.Notify("You don't have enough cash to join this race",'error')
-- 				else
--                     BJCore.Functions.Notify("You didn't join the race",'primary')
-- 				end
-- 			else 
--                 BJCore.Functions.Notify("You joined the race",'success')
-- 			end
-- 		end)
-- 	end
-- end)

-- RegisterNetEvent('JAM_RaceMod:BeginRace')
-- AddEventHandler('JAM_RaceMod:BeginRace', function(raceID, blipCoord)
-- 	if not RaceID or RaceID ~= raceID then return; end
-- 	Citizen.CreateThread(function() 		
-- 		local timer = GetGameTimer()		
-- 		local plyId = PlayerId()
-- 		local plyPed = GetPlayerPed(plyId)
-- 		local plyPos = GetEntityCoords(plyPed)	
-- 		local plyVeh = GetVehiclePedIsIn(plyPed, true)

--         BJCore.Functions.Notify("You will be frozen in place in 10 seconds",'primary',10000)
--         Citizen.Wait(10000)

-- 		if not RaceJoinPos then return; end

-- 		FreezeEntityPosition(plyVeh, true)
-- 		SetNewWaypoint(blipCoord.x, blipCoord.y)
-- 		RaceJoinPos = false

-- 		local timer = GetGameTimer()
-- 		while (GetGameTimer() - timer) < ((Config.SRCountdownTimer) * 1000) do
-- 			Citizen.Wait(0)
-- 			local counter = math.floor(((math.floor((Config.SRCountdownTimer + 1) * 1000)) - (GetGameTimer() - timer)) / 1000)
-- 			local str
-- 			if counter <= 2.0 then str = "~y~"..counter
-- 			else str = counter; end
--             TriggerEvent('JAM_Notify:ShowNotification', "Countdown : "..str, 0.1)
-- 		end	
-- 		Citizen.Wait(0)
--         TriggerEvent('JAM_Notify:ShowNotification', "~g~Go!", 1)
-- 		FreezeEntityPosition(plyVeh, false)
-- 		SetNewWaypoint(blipCoord.x, blipCoord.y)
-- 		RaceFinish = vector3(blipCoord.x, blipCoord.y, 1000.0)
-- 	end)
-- end)

-- function SRFinishRace()
-- 	local id = RaceID

-- 	RaceID = false
-- 	RaceJoinPos = false
-- 	RaceFinish = false		
-- 	RaceWager = false

-- 	BJCore.Functions.TriggerServerCallback('JAM_RaceMod:FinishStreetRace', function(position, wager, players)
-- 		local str = "You finished in position : "
-- 		if position == 1 then
-- 			if wager > 0 then
-- 				local plyData = BJCore.Functions.GetPlayerData()
-- 				local prize = wager * players
-- 				TriggerServerEvent('JAM_RaceMod:SetMoney', prize)
-- 				str = str .. "[" ..position.. "] : You won: "..BJCore.Config.Currency.Symbol ..prize
-- 			else str = str .. "[" ..position.. "]"
-- 			end

-- 			Citizen.CreateThread(function(...)
-- 				local timer = GetGameTimer()
-- 				while (GetGameTimer() - timer) < (Config.SRTimeoutTimer * 1000) do
-- 					Citizen.Wait(0)
-- 				end
-- 				TriggerServerEvent('JAM_RaceMod:RaceTimeout', id)
-- 			end)
-- 		else str = str .. "[" ..position.. "]"
-- 		end

--         BJCore.Functions.Notify(str,'primary')
-- 	end, id)
-- end

-- RegisterNetEvent('JAM_RaceMod:Timeout')
-- AddEventHandler('JAM_RaceMod:Timeout', function() 
-- 	if not RaceID then
--         BJCore.Functions.Notify('You didn\'t finish the race','error')
-- 		RaceID = false
-- 		RaceWager = false
-- 		RaceJoinPos = false
-- 		RaceFinish = false
-- 	end
-- end)

-- RegisterCommand('startrace', function(source, args) SRSetupRace(args); end)
-- Citizen.CreateThread(function(...) SRStart(...); end)

-- JNSpriteYSize	= 0.038      	-- can touch if u want? changes the background sprite height
-- JNSpriteYOffset = -0.017   	-- can touch if u want? changes how the sprite is positioned behind the text

-- JNStdMsgTimeout = 10			-- can touch. default timeout if not specified
-- JNTemplateXPos = 0.5    		-- can touch. x pos
-- JNTemplateYPos = 0.02   		-- can touch. y pos
-- JNTemplateFont = 4      		-- can touch. font type

-- local Started = false
-- function JNStart()
-- 	while not BJCore do Citizen.Wait(100); end
-- 	while not BJCore.Functions.IsPlayerLoaded() do Citizen.Wait(100); end
-- 	--print("SoLRP_Notify:Start() - Successful")
-- 	Started = 1
-- end

-- local DrawnTemplate, SpriteXSize, ShowingMsg, Timer = false, false, false, 0
-- function JNDoNotify(msg, timer)
-- 	if not Started then return; end
-- 	Citizen.CreateThread(function(...)
-- 		if not msg then return; end
-- 		if type(msg) ~= "string" then msg = tostring(msg); end
-- 		if string.len(msg) < 1 then return; end
-- 		if timer and type(timer) ~= "number" then timer = tonumber(timer); end
-- 		if not timer then timer = JNStdMsgTimeout; end

-- 		if not DrawnTemplate then DrawnTemplate = JNDrawTextTemplate(); end
--     	DrawnTemplate.font = JNTemplateFont
--     	DrawnTemplate.x = JNTemplateXPos
--     	DrawnTemplate.y = JNTemplateYPos
-- 	    DrawnTemplate.text = msg
--     	SpriteXSize = string.len(msg) / 200

--         if ShowingMsg then	
--             Timer = (GetGameTimer() + (timer * 1000))
-- 		else 
-- 			ShowingMsg = true
-- 			Timer = GetGameTimer() 
-- 			while (GetGameTimer() - (timer * 1000)) < Timer do
-- 				Citizen.Wait(0)
-- 			    JNDrawText(DrawnTemplate)
-- 			    DrawSprite("commonmenu", "gradient_nav", DrawnTemplate.x, DrawnTemplate.y - JNSpriteYOffset, SpriteXSize, JNSpriteYSize, 0.0, 0, 0, 0, 225) 
-- 			end
-- 			ShowingMsg = false
-- 		end		
-- 	end)
-- end

-- function JNDrawTextTemplate(text,x,y,font,scale1,scale2,colour1,colour2,colour3,colour4,wrap1,wrap2,centre,outline,dropshadow1,dropshadow2,dropshadow3,dropshadow4,dropshadow5,edge1,edge2,edge3,edge4,edge5)
--     return {
--       text         =                    "",
--       x            =                    -1,
--       y            =                    -1,
--       font         =  font         or    6,
--       scale1       =  scale1       or  0.5,
--       scale2       =  scale2       or  0.5,
--       colour1      =  colour1      or  255,
--       colour2      =  colour2      or  255,
--       colour3      =  colour3      or  255,
--       colour4      =  colour4      or  255,
--       wrap1        =  wrap1        or  0.0,
--       wrap2        =  wrap2        or  1.0,
--       centre       =  ( type(centre) ~= "boolean" and true or centre ),
--       outline      =  outline      or    1,
--       dropshadow1  =  dropshadow1  or    2,
--       dropshadow2  =  dropshadow2  or    0,
--       dropshadow3  =  dropshadow3  or    0,
--       dropshadow4  =  dropshadow4  or    0,
--       dropshadow5  =  dropshadow5  or    0,
--       edge1        =  edge1        or  255,
--       edge2        =  edge2        or  255,
--       edge3        =  edge3        or  255,
--       edge4        =  edge4        or  255,
--       edge5        =  edge5        or  255,
--     }
-- end

-- function JNDrawText( t )
--   if   not t or not t.text  or  t.text == ""  or  t.x == -1   or  t.y == -1
--   then return false
--   end

--   -- Setup Text
--   SetTextFont (t.font)
--   SetTextScale (t.scale1, t.scale2)
--   SetTextColour (t.colour1,t.colour2,t.colour3,t.colour4)
--   SetTextWrap (t.wrap1,t.wrap2)
--   SetTextCentre (t.centre)
--   SetTextOutline (t.outline)
--   SetTextDropshadow (t.dropshadow1,t.dropshadow2,t.dropshadow3,t.dropshadow4,t.dropshadow5)
--   SetTextEdge (t.edge1,t.edge2,t.edge3,t.edge4,t.edge5)
--   SetTextEntry ("STRING")

--   -- Draw Text
--   AddTextComponentSubstringPlayerName (t.text)
--   DrawText (t.x,t.y)

--   return true
-- end

-- RegisterNetEvent('JAM_Notify:ShowNotification')
-- AddEventHandler('JAM_Notify:ShowNotification', function(msg, timer) JNDoNotify(msg, timer); end)

-- Citizen.CreateThread(function(...) JNStart(...); end)