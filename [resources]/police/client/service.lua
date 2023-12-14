local TasksRemaining = 0
local InService = false
local ServiceZone = nil

function CreateCommunityServiceZone()
	ServiceZone = PolyZone:Create({
		vector2(-475.23672485352, 1145.31640625),
		vector2(-469.0810546875, 1154.7504882812),
		vector2(-435.15170288086, 1185.3259277344),
		vector2(-427.96990966797, 1183.3480224609),
		vector2(-388.05615234375, 1172.5419921875),
		vector2(-387.80126953125, 1155.2641601562),
		vector2(-389.95758056641, 1146.5869140625),
		vector2(-396.03576660156, 1127.0596923828),
		vector2(-395.51736450195, 1113.6713867188),
		vector2(-398.81942749023, 1101.7227783203),
		vector2(-400.26531982422, 1099.0693359375),
		vector2(-459.70932006836, 1115.4365234375),
		vector2(-465.83334350586, 1120.8896484375),
		vector2(-474.04968261719, 1126.2080078125),
		vector2(-476.03506469727, 1127.5565185547),
		vector2(-472.81973266602, 1138.2850341797),
		vector2(-472.0158996582, 1140.9671630859),
		vector2(-474.93505859375, 1142.2780761719),
		vector2(-474.34698486328, 1144.6048583984)
	}, {
		name="service",
		minZ = 322.98834228516,
		maxZ = 333.72637939453
	})
	ManageComServiceZone()
end

function ManageComServiceZone()
	ServiceZone:onPlayerInOut(function(isPointInside, point)
		if isPointInside then
			print("Entered Zone")
			print("Point: "..BJCore.Common.Dump(point))
		else
			if TasksRemaining > 0 then
				SetEntityCoords(PlayerPedId(), vector3(-414.9485, 1162.186, 325.85449))
			end
			print("Left Zone")
			print("Point: "..BJCore.Common.Dump(point))
		end
	end)
end

RegisterNetEvent("BJCore:Client:OnPlayerLoaded")
AddEventHandler("BJCore:Client:OnPlayerLoaded", function()
	if ServiceZone == nil then
		CreateCommunityServiceZone()
	end
end)

RegisterNetEvent('BJCore:Client:OnPlayerUnload')
AddEventHandler('BJCore:Client:OnPlayerUnload', function()
	TasksRemaining = 0
	InService = false
	Interacting = false
end)

local TaskLocations = {
	[1] = {
		pos = vector3(-413.0185, 1168.8206, 325.85382),
		type = "sweep",
	},
	[2] = {
		pos = vector3(-398.3935, 1170.7307, 325.81246),
		type = "sweep",
	},
	[3] = {
		pos = vector3(-397.988, 1147.4274, 325.85501),
		type = "sweep",
	},
	[4] = {
		pos = vector3(-429.8474, 1116.525, 326.76837),
		type = "sweep",
	},
	[5] = {
		pos = vector3(-446.2737, 1123.1894, 325.86148),
		type = "sweep",
	},
	[6] = {
		pos = vector4(-468.0501, 1130.8645, 325.85995, 127.99842),
		type = "wipe",
	},
	[7] = {
		pos = vector4(-419.2829, 1153.8348, 326.87359, 240.6784),
		type = "wipe",
	},
	[8] = {
		pos = vector3(-441.9204, 1160.5839, 325.9046),
		type = "leaf",
	},
	[9] = {
		pos = vector3(-441.9204, 1160.5839, 325.9046),
		type = "leaf",
	},
	[10] = {
		pos = vector3(-432.5956, 1143.9096, 325.90466),
		type = "leaf",
	},
	[11] = {
		pos = vector3(-406.5002, 1161.4008, 325.91415),
		type = "leaf",
	},
	[12] = {
		pos = vector3(-425.1785, 1167.1711, 325.90438),
		type = "dig",
	},
	[13] = {
		pos = vector3(-426.5844, 1152.6293, 325.90594),
		type = "dig",
	},
	[14] = {
		pos = vector3(-411.5301, 1124.9873, 325.90463),
		type = "dig",
	},
}

RegisterNetEvent("police:client:setInService", function(tasks)
	DoScreenFadeOut(500)
	Wait(500)
	StartPlayerTeleport(PlayerId(), vector4(-414.9485, 1162.186, 325.85449, 345.84359), false, true, true)
	Wait(500)
	DoScreenFadeIn()
	TasksRemaining = tasks
	BJCore.Functions.Notify("Complete the tasks to be set free", "primary", 5000)
	BJCore.Functions.PersistentNotify("start", "service", "Tasks remaining: "..TasksRemaining, "primary")
	InService = true
	CommunityService()
end)

local CurTask = false
local Interacting = false
function CommunityService()
	Citizen.CreateThread(function()
		while TasksRemaining > 0 do
			if not CurTask then
				CurTask = TaskLocations[math.random(#TaskLocations)]
				print(BJCore.Common.Dump(CurTask))
			end
			local plyPos = GetEntityCoords(PlayerPedId())
			local dist = #(plyPos - CurTask.pos.xyz)
			if not Interacting then
				DrawMarker(21, CurTask.pos.x, CurTask.pos.y, CurTask.pos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.4, 0.3, 250, 0, 0, 222, true, false, false, true, false, false, false)
				if dist < 1.8 then
					BJCore.Functions.DrawText3D(CurTask.pos.x, CurTask.pos.y, CurTask.pos.z, "[~g~E~w~] Task")
					if IsControlJustPressed(0, 38) then
						HandleServiceTask(CurTask)
					end
				end
			end
			Citizen.Wait(0)
		end
		CurTask = false
		Interacting = false
		TasksRemaining = 0
		BJCore.Functions.PersistentNotify("end", "service")
		BJCore.Functions.Notify("Community Service completed", "primary")
		DoScreenFadeOut(500)
		Wait(500)
		StartPlayerTeleport(PlayerId(), vector4(432.85955, -985.7852, 30.710165, 90.237045), false, true, true)
		Wait(500)
		DoScreenFadeIn()
	end)
end

local TasksAnimData = {
	["sweep"] = {
		animDict = "anim@amb@drug_field_workers@rake@male_a@base",
		anim = "base",
		propModel = "prop_tool_broom",
		propBone = 28422,
		propCoords = {-0.0100, 0.0400, -0.0300},
		flags = 1,
	},
	["wipe"] = {
		task = "WORLD_HUMAN_MAID_CLEAN",
	},
	["leaf"] = {
		task = "WORLD_HUMAN_GARDENER_LEAF_BLOWER",
	},
	["dig"] = {
	    animDict = "amb@world_human_gardener_plant@male@base",
	    anim = "base",
	}
}

function HandleServiceTask(data)
	local animData = {
		animDict = TasksAnimData[data.type].animDict ~= nil and TasksAnimData[data.type].animDict or nil,
		anim = TasksAnimData[data.type].anim ~= nil and TasksAnimData[data.type].anim or nil,
		flags = TasksAnimData[data.type].flags ~= nil and TasksAnimData[data.type].flags or 16,
		task = TasksAnimData[data.type].task ~= nil and TasksAnimData[data.type].task or nil,
	}
	local propData = {
		model = TasksAnimData[data.type].propModel ~= nil and TasksAnimData[data.type].propModel or nil,
		bone = TasksAnimData[data.type].propBone ~= nil and TasksAnimData[data.type].propBone or nil,
		coords = TasksAnimData[data.type].propCoords ~= nil and TasksAnimData[data.type].propCoords or nil,
	}
	if data.type == "wipe" then
		TaskAchieveHeading(PlayerPedId(), data.pos.w, 1000)
		Wait(1000)
	end
	Interacting = true
    exports['mythic_progbar']:Progress({
        name = "community_service",
        duration = math.random(15000, 25000),
        label = "Tasking",
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = animData,
        prop = propData
    }, function(status)
    	Interacting = false
        if not status then
        	TasksRemaining = TasksRemaining - 1
        	BJCore.Functions.PersistentNotify("start", "service", "Tasks remaining: "..TasksRemaining, "primary")
            BJCore.Functions.Notify("Task Complete", "success")
            CurTask = false
        else
            BJCore.Functions.Notify("Cancelled", "error")
        end
    end)
end

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return; end
    BJCore.Functions.PersistentNotify("end", "service")
    ServiceZone:destroy()
    ServiceZone = nil
end)