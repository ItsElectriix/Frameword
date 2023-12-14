yardsCreated = false
yards = {
	["A"] = false,
	["B"] = false,
	["C"] = false,
}

local curYard = false
local curYardData = nil

local SpawnedObjects = {}
local treeObjectThread = false

function ManageLumberYardZones()
	for k,v in pairs(yards) do
		yards[k]:onPlayerInOut(function(isPointInside, point)
			if isPointInside then
				curYard = k
				print("Entered Zone: "..k)
				print("Point: "..BJCore.Common.Dump(point))
				TriggerEvent("IsInLumberYard", true)
				LumberYardTick()
			else
				if curYard == k then
					print("Left Zone: "..k)
					print("Point: "..BJCore.Common.Dump(point))
					TriggerEvent("IsInLumberYard", false)
					curYard = false
					curYardData = nil
				end
			end
		end)
	end
end

function DestroyFieldZones()
	TriggerEvent("IsInLumberYard", false)
	for k,v in pairs(yards) do
		if v ~= false then
			yards[k]:destroy()
		end
	end
	print("Destroyed Field Zones")
	curYard = false
	yardsCreated = false
end

local curTree = false
function LumberYardTick()
	Citizen.CreateThread(function()
		TriggerServerEvent("lumberyard:server:getYardData", curYard)
		while curYardData == nil do Citizen.Wait(100); end
		local plyPed = PlayerPedId()
		while curYard do
			local plyPos = GetEntityCoords(plyPed)
			local nearby = false
			for k,v in pairs(curYardData) do
				local dist = #(plyPos - v.data.pos)
				if dist < 4 then
					nearby = true
					curTree = k
					if dist < 3.0 then
						if v.data.health <= 0 then
							BJCore.Functions.DrawText3D(v.data.pos.x, v.data.pos.y, v.data.pos.z-0.12, "Tree has died")
						else
							BJCore.Functions.DrawText3D(v.data.pos.x, v.data.pos.y, v.data.pos.z-0.12, "Stage: "..v.data.stage.."/3")
							BJCore.Functions.DrawText3D(v.data.pos.x, v.data.pos.y, v.data.pos.z-0.22, "Food: ~b~"..v.data.food.."%~w~ | Water: ~b~"..v.data.water.."%")
							BJCore.Functions.DrawText3D(v.data.pos.x, v.data.pos.y, v.data.pos.z-0.32, "Health: ~b~"..v.data.health.."%")
						end
					end
				else
					if curTree and curTree == k then
						curTree = false
					end
				end
			end
			if not nearby then Citizen.Wait(500); end
			Citizen.Wait(0)
		end
	end)
end

function LumberYardProcessTick()
	Citizen.CreateThread(function()
		while PlayerData.job.name == Config.LumberYardJob do
			local plyPos = GetEntityCoords(PlayerPedId())
			local distProcess = #(plyPos - Config.LumberYardProcess)
			if distProcess < 10 then
				if distProcess < 2 then
					BJCore.Functions.DrawText3D(Config.LumberYardProcess.x, Config.LumberYardProcess.y, Config.LumberYardProcess.z, "[~g~E~w~] Convert Tree Logs")
					if IsControlJustPressed(0, 38) then
						ConverTreeLogs()
					end
				end
			else
				Citizen.Wait(500)
			end
			Citizen.Wait(0)
		end
	end)
end

function ConverTreeLogs()
	BJCore.Functions.TriggerServerCallback("lumberyard:server:getLogs", function(logs)
		if logs then
		    exports['mythic_progbar']:Progress({
		        name = "process_grapes",
		        duration = Config.LumberYardProcessTimes["process"]*logs*1000,
		        label = "Converting",
		        useWhileDead = false,
		        canCancel = true,
		        controlDisables = {
		            disableMovement = true,
		            disableCarMovement = true,
		            disableMouse = false,
		            disableCombat = true,
		        },
		        animation = {
		            animDict = "amb@prop_human_bum_bin@idle_b",
		            anim = "idle_d",
		            flags = 16,
		        },        
		    }, function(status)
		        if not status then
		            ClearPedTasks(PlayerPedId())
		            TriggerServerEvent("lumberyard:server:convertToPlanks", logs)
		        else
		            ClearPedTasks(PlayerPedId())
		            BJCore.Functions.Notify("Cancelled", "error")
		        end
		    end)
		else
			BJCore.Functions.Notify("You don't have any tree logs to convert", "error")
		end
	end)
end

AddEventHandler("lumberyard:client:chopTree", function()
	if not curTree then BJCore.Functions.Notify("Tree not found. Move closer to one", "error") return; end
	if curYardData[curTree].data.stage ~= 3 then BJCore.Functions.Notify("This tree isn't ready to be chopped down", "error") return; end
    exports['mythic_progbar']:Progress({
        name = "chop_tree",
        duration = 9500,
        label = "Picking",
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = "amb@world_human_gardener_plant@male@base",
            anim = "base",
            flags = 16,
        },        
    }, function(status)
        if not status then
            ClearPedTasks(PlayerPedId())
            TriggerServerEvent('lumberyard:server:chopTree', curYard, curTree, curYard[curTree].data.type)
        else
            ClearPedTasks(PlayerPedId())
            BJCore.Functions.Notify("Cancelled", "error")
        end
    end)
end)

AddEventHandler("lumberyard:client:removeTree", function()
	if not curTree then BJCore.Functions.Notify("Tree not found. Move closer to one", "error") return; end
    exports['mythic_progbar']:Progress({
        name = "remove_tree",
        duration = 9500,
        label = "Removing",
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = "amb@world_human_gardener_plant@male@base",
            anim = "base",
            flags = 16,
        },        
    }, function(status)
        if not status then
            ClearPedTasks(PlayerPedId())
            TriggerServerEvent('lumberyard:server:removeTree', curYard, curTree)
        else
            ClearPedTasks(PlayerPedId())
            BJCore.Functions.Notify("Cancelled", "error")
        end
    end)
end)

RegisterNetEvent("lumberyard:client:feedPlant", function(item, type)
	if not curTree then return; end
	local text = "Watering"
	if type == "food" then text = "Feeding"; end
    exports['mythic_progbar']:Progress({
        name = "feed_tree",
        duration = 9500,
        label = text,
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = "amb@world_human_gardener_plant@male@base",
            anim = "base",
            flags = 16,
        },        
    }, function(status)
        if not status then
            ClearPedTasks(PlayerPedId())
            TriggerServerEvent('lumberyard:server:feedPlant', item, type, curYard, curTree)
        else
            ClearPedTasks(PlayerPedId())
            BJCore.Functions.Notify("Cancelled", "error")
        end
    end)
end)

RegisterNetEvent("lumberyard:client:getYardData", function(data) curYardData = data end)

RegisterNetEvent("lumberyard:client:syncYardData", function(yard, data)
	if curYard ~= yard then return; end
	curTree = false
	curYardData = data
end)

RegisterNetEvent("BJCore:Client:OnPlayerLoaded")
AddEventHandler("BJCore:Client:OnPlayerLoaded", function()
    if not yardsCreated and PlayerData.job.name == Config.LumberYardJob then
    	LumberYardProcessTick()
    	CreateLumberyardsPolyZone()
    end
    TreeObjectSync()
    TriggerServerEvent("lumberyard:server:syncTreeObjects")
end)

RegisterNetEvent('BJCore:Client:OnPlayerUnload')
AddEventHandler('BJCore:Client:OnPlayerUnload', function()
    DestroyFieldZones()
end)

RegisterNetEvent('BJCore:Client:OnJobUpdate')
AddEventHandler('BJCore:Client:OnJobUpdate', function(JobInfo)
    if yardsCreated and JobInfo.name ~= Config.LumberYardJob then
    	DestroyFieldZones()
	elseif not yardsCreated and JobInfo.name == Config.LumberYardJob then
		LumberYardProcessTick()
        CreateLumberyardsPolyZone()
    end
end)

RegisterNetEvent("lumberyard:client:plantSeed", function(item)
	if not curYard then BJCore.Functions.Notify("You must be in one of the designated lumbar yards to plant this", "error") return; end
	if curTree then BJCore.Functions.Notify("You can't plant this close to another tree", "error") return; end
    exports['mythic_progbar']:Progress({
        name = "plant_tree",
        duration = 9500,
        label = "Planting",
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = "amb@world_human_gardener_plant@male@base",
            anim = "base",
            flags = 16,
        },        
    }, function(status)
        if not status then
            ClearPedTasks(PlayerPedId())
            local plantPos = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0, 0.75, 0)
            TriggerServerEvent('lumberyard:server:placeTree', curYard, {x=plantPos.x, y=plantPos.y, z=plantPos.z})
            TriggerServerEvent('lumberyard:server:removeSeed', item)
        else
            ClearPedTasks(PlayerPedId())
            BJCore.Functions.Notify("Cancelled", "error")
        end
    end)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return; end
    DestroyFieldZones()
    for k,v in pairs(SpawnedObjects) do
    	DeleteObject(v.obj)
    end
end)

local TreeObjs = {}
RegisterNetEvent("lumberyard:client:syncTreeObjects", function(data)
    TreeObjs = data
end)

function TreeObjectSync()
    if treeObjectThread then return; end
    Citizen.CreateThread(function()
        treeObjectThread = true
        while true do
            local plyPed = PlayerPedId()
            local plyPos = GetEntityCoords(plyPed)
            for k,v in pairs(TreeObjs) do
                local dist = #(plyPos.xyz - v)
                if dist <= 75 and not SpawnedObjects[k] then
                    local obj = CreateObject(GetHashKey("prop_tree_cypress_01"), v.x, v.y, v.z-2.0, false, false, false)
                    --PlaceObjectOnGroundProperly(obj)
                    FreezeEntityPosition(obj, true)
                    SpawnedObjects[k] = { obj = obj, pos = v } 
                elseif dist > 75 and SpawnedObjects[k] then
                    DeleteObject(SpawnedObjects[k].obj)
                    SpawnedObjects[k] = false
                end
            end
            Citizen.Wait(500)
        end
        treeObjectThread = false
    end)
end

RegisterNetEvent("lumberyard:client:addTreeObject", function(id, pos)
	TreeObjs[id] = pos
end)

RegisterNetEvent("lumberyard:client:removeTreeObject", function(id)
    if SpawnedObjects[id] ~= nil then
        if SpawnedObjects[id].obj ~= nil then
            if DoesEntityExist(SpawnedObjects[id].obj) then
                DeleteObject(SpawnedObjects[id].obj)
            end
            SpawnedObjects[id] = nil
            TreeObjs[id] = nil
        end
    end
end)