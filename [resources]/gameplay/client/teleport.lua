local PedAutoTeleporters = {
    
}

local AutoTeleporters = {
    
    ["PrinceClubGarage"] = {
        ["entry"] = vector4(350.98, 266.53, 102.63, 247.52),
        ["exit"] = vector4(405.95, 243.92, 92.07, 73.58),
		["restriction"] = "realestateagent",
		["type"] = "car"
    },
	
	["Apartment"] = {
        ["entry"] = vector4(-785.86, 319.31, 85.66, 247.52),
        ["exit"] = vector4(-785.18, 315.83, 187.91, 73.58),
		["restriction"] = "realestateagent",
		["type"] = "ped"
    },

    ["Moonlight"] = {
        ["entry"] = vector4(960.57, -982.83, 39.50, 358.24),
        ["exit"] = vector4(914.40, -965.30, 59.09, 358.24),
		["restriction"] = "moonlight",
		["type"] = "ped"
    },
    ["VanillaUnicornBar"] = {
        ["entry"] = vector4(132.87, -1293.77, 29.27, 300.69),
        ["exit"] = vector4(131.38, -1285.60, 29.27, 29.08),
		["restriction"] = "crimson",
		["type"] = "ped"
    },
	["StudioLosSantosTicketDesk"] = {
        ["entry"] = vector4(-1581.92, -3018.13, -79.01, 270.53),
		["exit"] = vector4(-1572.82, -3014.46, -74.41, 274.51),
		["restriction"] = "bahamamamas",
		["type"] = "ped"
    },
    ["StudioLosSantosGarage"] = {
        ["entry"] = vector4(-674.90, -2391.99, 13.99, 60.73),
        ["exit"] = vector4(-1636.6, -2990.08, -77.64, 271.3),
		["restriction"] = "bahamamamas",
		["type"] = "car"
    },

    ["Therapist's Office"] = {
		["entry"] = vector4(-1898.212, -572.775, 11.847, 222.0),
		["exit"] = vector4(-1902.402, -572.428, 19.097, 134.0)
	},
	
	["PrinceEstates"] = {
        ["entry"] = vector4(-144.40, -577.55, 32.42, 161.22),
        ["exit"] = vector4(-142.09, -591.00, 167.00, 131.31),
		["restriction"] = "realestateagent",
		["type"] = "car"
	},
	
	["Pillbox Upstairs 1"] = {
	    ["entry"] = vector4(355.70, -596.25, 28.82, 243.77),
        ["exit"] = vector4(329.89, -601.02, 43.32, 63.41),
		["type"] = "ped"
	},
	
	["Pillbox Upstairs 2"] = {
	    ["entry"] = vector4(359.87, -584.92, 28.87, 243.77),
        ["exit"] = vector4(332.14, -595.59, 43.32, 63.41),
		["type"] = "ped"
	},
	
	-- ["SpecialOpsFibTraining1"] = {
    --     ["entry"] = vector4(128.31, -732.93, 234.15, 327.71),
    --     ["exit"] = vector4(139.79, -732.02, 266.85, 95.49),
    --     ["restriction"] = "police",
	-- 	["type"] = "ped"
    -- },

    -- ["SpecialOpsFibTraining2"] = {
    --     ["entry"] = vector4(136.13, -761.73, 234.15, 157.26),
    --     ["exit"] = vector4(138.22, -764.48, 45.75, 161.01),
    --     ["restriction"] = "police",
	-- 	["type"] = "ped"
    -- },
	
	["Triad Car Garage"] = {
        ["entry"] = vector4(-209.71, -2584.31, 6.00, 357.32),
        ["exit"] = vector4(-1516.37, -2978.69, -80.86, 273.43),
		["restriction"] = "triad",
		["type"] = "car"
	},

	["Triad Weed Base"] = {
        ["entry"] = vector4(-297.52, 6391.58, 29.65, 0.0),
        ["exit"] = vector4(1065.83, -3183.65, -39.16, 89.21),
		["restriction"] = "triad",
		["type"] = "ped"
	},

	["Horizon Hanger"] = {
        ["entry"] = vector4(-1266.14, -2973.49, -48.49, 172.17),
        ["exit"] = vector4(-956.07, -3034.68, 13.95, 62.0),
		["restriction"] = "horizon",
		["type"] = "car"
	},
}

local TeleportFromTo = {
	
	-- ["LS Mafia"] = {
	-- 	positionFrom = { ['x'] = -1798.22, ['y'] = 436.01, ['z'] = 137.6, nom = "Enter"},
	-- 	positionTo = { ['x'] = -1798.24, ['y'] = 439.49, ['z'] = 141.69, nom = "Enter"},
	-- },
	
	-- ["Prince Estates"] = {
	-- 	positionFrom = { ['x'] = -142.87, ['y'] = -624.84, ['z'] = 168.82, nom = "Enter"},
	-- 	positionTo = { ['x'] = -146.26, ['y'] = -604.13, ['z'] = 167.00, nom = "Enter"},
	-- 	restriction = "realestateagent"
	-- },
	
	-- ["Studio Los Santos"] = {
	-- 	positionFrom = { ['x'] = -676.90, ['y'] = -2458.95, ['z'] = 13.99, nom = "Enter"},
	-- 	positionTo = { ['x'] = -1569.3, ['y'] = -3017.26, ['z'] = -74.41, nom = "Enter"},
	-- },
	
	-- ["Orange's House"] = {
	-- 	positionFrom = { ['x'] = -97.27, ['y'] = 831.74, ['z'] = 239.99, nom = "Enter"},
	-- 	positionTo = { ['x'] = -101.24, ['y'] = 824.42, ['z'] = 235.77, nom = "Enter"},
	-- },
	
	-- ["Penthouse Apartment"] = {
	-- 	positionFrom = { ['x'] = -1537.59, ['y'] = -577.59, ['z'] = 25.71, nom = "Enter"},
	-- 	positionTo = { ['x'] = -1555.91, ['y'] = -574.78, ['z'] = 100.15, nom = "Enter"},
	-- },
	
	-- ["Weed Collect"] = {
	--     visDistance = 10.0,
	-- 	positionFrom = { ['x'] = -2221.29, ['y'] = 4227.57, ['z'] = 47.19, nom = "Enter at your own risk"},
	-- 	positionTo = { ['x'] = 1104.90, ['y'] = -3099.71, ['z'] = -39.04, nom = "Enter at your own risk"},
	-- },
	
--	["Meth Process"] = {
--	    visDistance = 10.0,
--		positionFrom = { ['x'] = 2998.39, ['y'] = 4099.53, ['z'] = 57.03, nom = "Enter at your own risk"},
--		positionTo = { ['x'] = 997.52, ['y'] = -3200.60, ['z'] = -36.44, nom = "Enter at your own risk"},
--	},
	
--	["City Apartment"] = {
--		positionFrom = { ['x'] = -271.47, ['y'] = -693.27, ['z'] = 34.32, nom = "Enter - 2Keshed"},
--		positionTo = { ['x'] = -262.59, ['y'] = -713.56, ['z'] = 71.07, nom = "Exit - 2Keshed"},
--	},
	
	-- ["Reporter Job 1"] = {
	-- 	positionFrom = { ['x'] = -1057.82, ['y'] = -235.68, ['z'] = 43.06, nom = "Exit - Office"},
	-- 	positionTo = { ['x'] = -1056.32, ['y'] = -238.19, ['z'] = 43.06, nom = "Enter - Office"},
	-- },
	
	-- ["Reporter Job 2"] = {
	-- 	positionFrom = { ['x'] = -1048.72, ['y'] = -238.45, ['z'] = 43.06, nom = "Enter - Meeting Room"},
	-- 	positionTo = { ['x'] = -1046.88, ['y'] = -237.54, ['z'] = 43.06, nom = "Exit - Meeting Room"},
	-- },
	
	-- ["Elevator1"] = {
	-- 	positionFrom = { ['x'] = -1078.33, ['y'] = -254.15, ['z'] = 44.07, nom = "Go Down"},
	-- 	positionTo = { ['x'] = -1078.13, ['y'] = -254.28, ['z'] = 37.81, nom = "Go Up"},
	-- },
	
	-- ["Elevator2"] = {
	-- 	positionFrom = { ['x'] = -1075.61, ['y'] = -253.10, ['z'] = 44.07, nom = "Go Down"},
	-- 	positionTo = { ['x'] = -1075.64, ['y'] = -253.05, ['z'] = 37.81, nom = "Go Up"},
	-- },
	
	-- ["Real Estate - Roof"] = {
	-- 	positionFrom = { ['x'] = -135.29, ['y'] = -637.06, ['z'] = 168.87, nom = "Enter - Roof"},
	-- 	positionTo = { ['x'] = -144.62, ['y'] = -599.17, ['z'] = 206.97, nom = "Enter - Office"},
	-- },
	
	-- ["Hospital1"] = {
	-- 	positionFrom = { ['x'] = 1151.224, ['y'] = -1527.549, ['z'] = 35.03, nom = "Enter"},
	-- 	positionTo = { ['x'] = 275.125, ['y'] = -1360.797, ['z'] = 24.57, nom = "Exit"},
	-- },
	
	-- ["Real Estate Helipad"] = {
	-- 	positionFrom = { ['x'] = -1565.64587402344, ['y'] = -575.688049316406, ['z'] = 108.522987365723, nom = "Enter"},
	-- 	positionTo = { ['x'] = -1570.009765625, ['y'] = -576.172729492188, ['z'] = 114.449279785156, nom = "Exit"},
	-- },
	
--	["NHS Helipad"] = {
--		positionFrom = { ['x'] = 333.03, ['y'] = -591.29, ['z'] = 43.28, nom = "Exit"},
--		positionTo = { ['x'] =  338.57, ['y'] = -583.92, ['z'] = 74.17, nom = "Enter"},
--	},
	
	-- ["Grange City Center"] = {
	-- 	positionFrom = { ['x'] = 837.951599121094, ['y'] = -1375.06799316406, ['z'] = 26.3081645965576, nom = "Enter"},
	-- 	positionTo = { ['x'] = 833.578125, ['y'] = -1379.69384765625, ['z'] = 26.3136196136475, nom = "Exit"},
	-- },
	
	-- ["Union Depository"] = {
	-- 	positionFrom = { ['x'] = 10.609, ['y'] = -666.063, ['z'] = 33.449, nom = "Enter"},
	-- 	positionTo = { ['x'] = 1.087, ['y'] = -703.070, ['z'] = 16.131, nom = "Exit"},
	-- },
	
	-- ["FIB Building Ground Floor Elevator"] = {
	-- 	positionFrom = { pos = vector3(136.187, -761.419, 45.752), nom = "Ground Floor"},
	-- 	positionTo = { pos = vector3(136.338, -761.085, 242.152), nom = "49th Floor"},
	-- },

	-- ["FIB Building Lvl 49 Stairs"] = {
	-- 	positionFrom = { pos = vector3(128.40, -732.01, 242.15), nom = "Enter"},
	-- 	positionTo = { pos = vector3(139.35, -747.60, 242.15), nom = "Exit"},
	-- },	
	
	-- ["FIB Building Police"] = {
	-- 	positionFrom = { pos = vector3(141.15, -735.04, 262.85), nom = "Go Down"},
	-- 	positionTo = { pos = vector3(124.42, -757.06, 242.152), nom = "Go Up"},
	-- 	restriction = "police"
	-- },
	
	-- ["Manor Hotel"] = {
	-- 	positionFrom = { ['x'] = -60.36, ['y'] = 360.09, ['z'] = 113.06, nom = "Enter"},
	-- 	positionTo = { ['x'] = -98.32, ['y'] = 367.37, ['z'] = 113.27, nom = "Enter"},
	-- },
	
	-- -- ["Motel"] = {
	-- 	-- positionFrom = { ['x'] = 1121.545, ['y'] = 2641.795, ['z'] = 38.144, nom = "Enter"},
	-- 	-- positionTo = { ['x'] = 151.50, ['y'] = -1007.944, ['z'] = -99.018, nom = "Exit"},
	-- -- },

	-- ["Police Training"] = {
	-- 	positionFrom = { ['x'] = -1839.88, ['y'] = 3006.91, ['z'] = 32.81, nom = "Exit"},
	-- 	positionTo = { ['x'] =  -1571.98, ['y'] = 2776.20, ['z'] = 17.21, nom = "Enter"},
	-- 	restriction = 'police'
	-- },
	-- --["Bahama Mamas"] = {
	-- 	--positionFrom = { ['x'] = -1388.41, ['y'] = -586.87, ['z'] = 30.22, nom = "Enter"},
	-- 	--positionTo = { ['x'] = -1386.82, ['y'] = -589.46, ['z'] = 30.32, nom = "Exit"},
	-- --},

	-- ["Horizon Door"] = {
	-- 	positionFrom = { ['x'] = -941.58, ['y'] = -2955.03, ['z'] = 13.95, nom = "Enter"},
	-- 	positionTo = { ['x'] =  -1311.54, ['y'] = -2992.72, ['z'] = -48.49, nom = "Exit"},
	-- },

	

}

Drawing = setmetatable({}, Drawing)
Drawing.__index = Drawing


function Drawing.draw3DText(x,y,z,textInput,fontId,scaleX,scaleY,r, g, b, a)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)

    local scale = (1/dist)*20
    local fov = (1/GetGameplayCamFov())*100
    local scale = scale*fov

    SetTextScale(scaleX*scale, scaleY*scale)
    SetTextFont(fontId)
    SetTextProportional(1)
    SetTextColour(r, g, b, a)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(textInput)
    SetDrawOrigin(x,y,z+2, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

function Drawing.drawMissionText(m_text, showtime)
    ClearPrints()
    SetTextEntry_2("STRING")
    AddTextComponentString(m_text)
    DrawSubtitleTimed(showtime, 1)
end

function msginf(msg, duree)
    duree = duree or 500
    ClearPrints()
    SetTextEntry_2("STRING")
    AddTextComponentString(msg)
    DrawSubtitleTimed(duree, 1)
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(2)
		local pos = GetEntityCoords(PlayerPedId(), true)
		local nearby = false

		for k, j in pairs(TeleportFromTo) do

			--msginf(k .. " " .. tostring(j.positionFrom.x), 15000)
			local vDistance = 20.0
			local tDistance = 5.0
			if j.visDistance ~= nil then
			    vDistance = j.visDistance
			    tDistance = j.visDistance
			end
			if j.restriction == nil or (j.restriction ~= nil and PlayerData ~= nil and PlayerData.job ~= nil and j.restriction == PlayerData.job) then
				if(#(pos - j.positionFrom.pos) < vDistance)then
					nearby = true
					DrawMarker(27, j.positionFrom.pos.x, j.positionFrom.pos.y, j.positionFrom.pos.z - 0.97, 0, 0, 0, 0, 0, 0, 1.0001, 1.0001, .801, 255, 255, 255,255, 0, 0, 0,0)
					if(#(pos - j.positionFrom.pos) < 1.0)then
						BJCore.Functions.DisplayHelpText("Press ~INPUT_PICKUP~ to ".. j.positionFrom.nom)
						if IsControlJustPressed(1, 38) then
							DoScreenFadeOut(1000)
							Citizen.Wait(2000)
							SetEntityCoords(PlayerPedId(), j.positionTo.pos.x, j.positionTo.pos.y, j.positionTo.pos.z - 1)
							DoScreenFadeIn(1000)
						end
					end
				end
	
				if(#(pos - j.positionTo.pos) < vDistance)then
					nearby = true
					DrawMarker(27, j.positionTo.pos.x, j.positionTo.pos.y, j.positionTo.pos.z - 0.97, 0, 0, 0, 0, 0, 0, 1.0001, 1.0001, .801, 255, 255, 255,255, 0, 0, 0,0)
					if(#(pos - j.positionTo.pos) < 1.0)then
						BJCore.Functions.DisplayHelpText("Press ~INPUT_PICKUP~ to ".. j.positionTo.nom)						
						if IsControlJustPressed(1, 38) then
							DoScreenFadeOut(1000)
							Citizen.Wait(2000)
							SetEntityCoords(PlayerPedId(), j.positionFrom.pos.x, j.positionFrom.pos.y, j.positionFrom.pos.z - 1)
							DoScreenFadeIn(1000)
						end
					end
				end
			end
		end
		if not nearby then Wait(500); end
	end
end)

function FadeScreen(fadeIn,waitTime,doWait)
  waitTime = waitTime or 1000
  if fadeIn then
    DoScreenFadeIn(waitTime)
    if doWait then Citizen.Wait(waitTime + 100); end
  else
    DoScreenFadeOut(waitTime)
    if doWait then Citizen.Wait(waitTime + 100); end
  end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local nearby = false
        local key,act,pos,dist,rest = GetClosestTp()
        if dist < 20 then nearby = true; end
		if dist and dist < 10 and (rest == nil or (PlayerData ~= nil and PlayerData.job ~= nil and rest == PlayerData.job)) then
			local scale = 1.5
			if AutoTeleporters[key].type == "car" then
				scale = 3.5
			end
            if not justTeleported then
                DrawMarker(27, pos.x, pos.y, pos.z-0.97, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, scale, scale, 0.5, 52, 171, 235, 100, false, false, 2, false, nil, nil, false)
                if dist < scale then
                    --BJCore.Functions.DisplayHelpText("Press ~INPUT_PICKUP~ to "..act.." the "..key..".")
                    --if IsControlJustPressed(0, 38) then
                    justTeleported = true
                    Teleport(key,act)
                    --end
                end
			elseif dist > (scale + 0.3) then
				justTeleported = false
            end
        else
            justTeleported = false
        end
        if not nearby then Wait(500); end
    end
end)

function GetClosestTp()
    local plyPos = GetEntityCoords(PlayerPedId())
    local key,act,pos,dist,rest
    for k,v in pairs(AutoTeleporters) do
        local entryDist = #(plyPos - v.entry.xyz)
        local exitDist  = #(plyPos - v.exit.xyz)

        if not dist or entryDist < dist then
          dist = entryDist
          key = k
          act = "exit"
          pos = v.entry
		  rest = v.restriction
        end

        if exitDist < dist then
          dist = exitDist
          key = k
          act = "enter"
          pos = v.exit
		  rest = v.restriction
        end
    end

    if not dist then
        return false,false,false,999999
    else
    return key,act,pos,dist,rest
    end
end

RegisterNetEvent('Teleport:SyncVehicleTeleport')
AddEventHandler('Teleport:SyncVehicleTeleport', function(netVeh, seat)
	local veh = NetworkGetEntityFromNetworkId(netVeh)
	print('Event Received '..veh..' - '..netVeh)
	if DoesEntityExist(veh) then
		print('Vehicle Found: '..veh)
		local ped = PlayerPedId()
		local otherCoords = nil
		while GetVehiclePedIsIn(ped) ~= veh do
			otherCoords = GetEntityCoords(veh)
			SetEntityCoords(ped, otherCoords)
			Wait(10)
			print('Setting to seat: '..seat)
			SetPedIntoVehicle(PlayerPedId(), veh, seat)
		end
	end
end)

function Teleport(key,act)
    local pos
    local zone = AutoTeleporters[key]
    local plyPed = PlayerPedId()
	local veh = GetVehiclePedIsIn(plyPed, false)
    if act == "exit" then pos = zone.exit
    else pos = zone.entry; end
	if veh ~= nil and veh ~= 0 then
		if GetPedInVehicleSeat(veh, -1) == plyPed then
			local passengers = {}
			local maxPassengers = GetVehicleMaxNumberOfPassengers(veh)
	    	for i = -1, maxPassengers - 1, 1 do
		        local seatPed = GetPedInVehicleSeat(veh, i)
	    	    if seatPed ~= nil and seatPed ~= -1 and IsPedAPlayer(seatPed) and seatPed ~= plyPed then
					for _,p in ipairs(GetActivePlayers()) do
						local playerPed = GetPlayerPed(p)
						if playerPed == seatPed and DoesEntityExist(playerPed) then
							passengers[p] = i
						end
					end
	        	end
	    	end
		
			FadeScreen(false,1000,true)
			
			SetEntityCollision(veh, false, false)
			FreezeEntityPosition(veh, true)
			SetEntityInvincible(veh, true)
			
			Wait(10)
			
			SetEntityVelocity(veh, 0.0, 0.0, 0.0)
            SetEntityRotation(veh, 0.0, 0.0, 0.0, 0, false)
			SetEntityCoordsNoOffset(veh, pos.x, pos.y, pos.z, 0, 0, 1)
			SetEntityHeading(veh, pos.w)
			SetGameplayCamRelativeHeading(0)
			
			Wait(100)
			
			--for k,v in pairs(passengers) do
			--	TriggerServerEvent('TBH:SyncToPlayer', 'Teleport:SyncVehicleTeleport', GetPlayerServerId(k), {VehToNet(veh), v})
			--end
			
			SetEntityCollision(veh, true, true)
			FreezeEntityPosition(veh, false)
			SetEntityInvincible(veh, false)
			
			FadeScreen(true,1000,true)
		end
	else
		FadeScreen(false,1000,true)
		SetPedCoordsKeepVehicle(plyPed, pos.x, pos.y, pos.z)
		SetEntityHeading(plyPed, pos.w)
		SetGameplayCamRelativeHeading(0)
		FadeScreen(true,1000,true)
	end
end
