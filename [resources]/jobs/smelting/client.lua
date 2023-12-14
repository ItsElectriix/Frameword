local openingDoor = false
local SmeltingData = false
local LocalSmeltTimer = {}
local LocalReadyItems = {}
local timerActive = false

function updateSmeltTimer()
    for k,v in pairs(SmeltingData) do
        if next(v.items) ~= nil and not v.ready and not LocalReadyItems[k] then
            timerActive = true
            if not LocalSmeltTimer[k] then
                LocalSmeltTimer[k] = SmeltingData[k].timer
            end
            LocalSmeltTimer[k] = LocalSmeltTimer[k] - 1
            if LocalSmeltTimer[k] <= 0 then
                SmeltingData[k].ready = true
                LocalSmeltTimer[k] = nil
                LocalReadyItems[k] = true
            end
        end
    end
end

RegisterNetEvent("BJCore:Client:OnPlayerLoaded")
AddEventHandler("BJCore:Client:OnPlayerLoaded", function()
    TriggerServerEvent('smelter:server:GetSmeltData')
    while not SmeltingData do Citizen.Wait(250); end
    isLoggedIn = true

    if isSmeltActive() and not timerActive then
        Citizen.CreateThread(function()
            while isSmeltActive() do
                --if isLoggedIn then
                    updateSmeltTimer()
                -- else
                --     break
                -- end
                Citizen.Wait(1000)
            end
            timerActive = false
        end)
    end
end)

Citizen.CreateThread(function()
    TriggerServerEvent('smelter:server:GetSmeltData')
    while not SmeltingData do Citizen.Wait(250); end
    if isSmeltActive() and not timerActive then
        Citizen.CreateThread(function()
            while isSmeltActive() do
                --if isLoggedIn then
                    updateSmeltTimer()
                -- else
                --     break
                -- end
                Citizen.Wait(1000)
            end
            timerActive = false
        end)
    end    
end)

function isSmeltActive()
	local active = false
	for k,v in pairs(SmeltingData) do
		if next(v.items) ~= nil then
	        if (LocalSmeltTimer[k] ~= nil and LocalSmeltTimer[k] ~= 0) or (v.timer > 0 and LocalSmeltTimer[k] == nil and not LocalReadyItems[k]) then
		        active = true
		        break
	        end 
	    end
    end
    print('Is smelt active: '..(active and 'Yes' or 'No'))
	return active
end

RegisterNetEvent("BJCore:Client:OnPlayerUnload")
AddEventHandler("BJCore:Client:OnPlayerUnload", function()
    isLoggedIn = false
end)

local textData = {}
function smelterText()
    local textTa = {}
    for i = 1, #SmeltingData+1 - 1 do
        if next(SmeltingData[i].items) ~= nil then
            local status = LocalSmeltTimer[i] == nil and 'Pending Start' or LocalSmeltTimer[i]..'s'
            if LocalReadyItems[i] then status = "Ready"; end
            textData[i] =  BJCore.Shared.Items[SmeltingData[i].items.name].label.." x"..SmeltingData[i].items.amount.." | "..status
        else
            textData[i] = " - "
        end
    end
end

local isNearSmelter = false
Citizen.CreateThread(function()
	while true do 
		Citizen.Wait(1)
		local inRange = false
		local pos = GetEntityCoords(PlayerPedId())
		if #(pos - Config.SmeltLocation) < 10.0 then
			inRange = true
			if #(pos - Config.SmeltLocation) < 2.0 then
                if not isNearSmelter then 
                    isNearSmelter = true
                    TriggerEvent('isNearSmelter', isNearSmelter)
                end
                smelterText()
                BJCore.Functions.DrawText3D(Config.SmeltLocation.x, Config.SmeltLocation.y, Config.SmeltLocation.z+0.08, "Smelter Orders:")
                DrawText3DMulti(Config.SmeltLocation.x, Config.SmeltLocation.y, Config.SmeltLocation.z, textData, 4)
            else
                if isNearSmelter then
                    isNearSmelter = false
                    TriggerEvent('isNearSmelter', isNearSmelter)
                end
    		end
		end
		if not inRange then
			Citizen.Wait(2500)
		end
	end
end)

-- function ScrapAnim(time)
--     local time = time / 1000
--     loadAnimDict("mp_car_bomb")
--     TaskPlayAnim(PlayerPedId(), "mp_car_bomb", "car_bomb_mechanic" ,3.0, 3.0, -1, 16, 0, false, false, false)
--     openingDoor = true
--     Citizen.CreateThread(function()
--         while openingDoor do
--             TaskPlayAnim(PlayerPedId(), "mp_car_bomb", "car_bomb_mechanic", 3.0, 3.0, -1, 16, 0, 0, 0, 0)
--             Citizen.Wait(2000)
--             time = time - 2
--             if time <= 0 then
--                 openingDoor = false
--                 StopAnimTask(PlayerPedId(), "mp_car_bomb", "car_bomb_mechanic", 1.0)
--             end
--         end
--     end)
-- end

RegisterNetEvent('smelter:client:interact')
AddEventHandler('smelter:client:interact', function(option)
    local option = option[1]
    if SmeltingData[option].ready or LocalReadyItems[option] then
        BJCore.Functions.Notify("This order is ready for collection", "success")
        BJCore.Functions.TriggerServerCallback("smelter:server:CollectOrder", function(data)
            if data.canCollect then
                BJCore.Functions.Notify("Please collect all items. Anything left over will be destroyed", "primary")
                TriggerServerEvent("inventory:server:OpenInventory", "smelter", option, data, "Smelter - "..option)
                TriggerEvent('inventory:client:SetCurrentSmelter', option)
            else
                BJCore.Functions.Notify("Someone is already collecting this order", "error")
            end
        end, option)
    elseif next(SmeltingData[option].items) == nil then
        BJCore.Functions.Notify("Available")
        local smelting = {
            items = false
        }
        TriggerServerEvent("inventory:server:OpenInventory", "smelter", option, smelting, "Smelter - "..option)
        TriggerEvent('inventory:client:SetCurrentSmelter', option)
        --TriggerServerEvent("smelter:server:MakeOrder", option)
    elseif not SmeltingData[option].ready and not LocalReadyItems[option] then
        BJCore.Functions.Notify("This order isn't ready for collection", "error")
    end 
end)

AddTextEntry("smeltersummary", " [~g~ 1 ~w~] ~a~ \n [~g~ 2 ~w~] ~a~ \n [~g~ 3 ~w~] ~a~ \n [~g~ 4 ~w~] ~a~")

DrawText3DMulti = function(x, y, z, text, linecount)
    if not linecount or linecount == nil or linecount == 0 then
        linecount = 0.7
    end
    SetTextScale(0.325, 0.325)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("smeltersummary")
    SetTextCentre(true)
    local longestText = 6
    for i=1, linecount do
        if text[i] ~= nil then
            AddTextComponentString(text[i])
            if longestText < string.len(text[i]) then
                longestText = string.len(text[i])
            end
        else
            AddTextComponentString(" - ")
        end
    end
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = longestText / 275
    DrawRect(0.0, 0.0+0.0405, 0.002 - factor, 0.02 * linecount, 0, 0, 0, 68)
    ClearDrawOrigin()
end

function runningTimer()
    if isSmeltActive() and not timerActive then
        Citizen.CreateThread(function()
            while isSmeltActive() do
                --if isLoggedIn then
                    updateSmeltTimer()
                -- else
                --     break
                -- end
                Citizen.Wait(1000)
            end
            timerActive = false
        end)
    end
end

RegisterNetEvent("smelter:client:SyncSmeltData")
AddEventHandler("smelter:client:SyncSmeltData", function(data, toReset)
    SmeltingData = data
    if toReset then
        LocalReadyItems[toReset] = false
        LocalSmeltTimer[toReset] = nil
    end
    runningTimer()
end)