local isHunting = false
DecorRegister("Animal.Looted", 3)
local pedList = {
    [`a_c_coyote`] = true,
    [`a_c_chimp`] = true,
    [`a_c_chickenhawk`] = true,
    [`a_c_hen`] = true,
    [`a_c_boar`] = true,
    [`a_c_chop`] = true,
    [`a_c_cormorant`] = true,
    --[`a_c_cow`] = true,
    [`a_c_crow`] = true,
    [`a_c_deer`] = true,
    [`a_c_fish`] = true,
    [`a_c_husky`] = true,
    [`a_c_mtlion`] = true,
    [`a_c_pig`] = true,
    [`a_c_pigeon`] = true,
    [`a_c_rat`] = true,
    [`a_c_retriever`] = true,
    [`a_c_rhesus`] = true,
    [`a_c_rottweiler`] = true,
    [`a_c_seagull`] = true,
    [`a_c_sharktiger`] = true,
    [`a_c_shepherd`] = true,
    [`a_c_sharkhammer`] = true,
    [`a_c_rabbit_01`] = true,
    [`a_c_cat_01`] = true,
    [`a_c_killerwhale`] = true
}

local deadPeds = {}
RegisterNetEvent('hunting:toggle')
AddEventHandler('hunting:toggle', function()
    if isHunting then 
        BJCore.Functions.PersistentNotify('end', 'Hunting')
        isHunting = false 
        ClearPedTasks(PlayerPedId())
        deadPeds = {}
        BJCore.Functions.Notify("Finished hunting", "primary") 

        return 
    end
    isHunting = true
    BJCore.Functions.PersistentNotify('start', 'Hunting', 'Currently hunting... Keep your eyes peeled', "primary")
    BJCore.Functions.Notify('Note: The more you successfully earn meat from hunting the better you get at not ruining animal meat. Once you\'re more experienced you\'ll also be able to loot hides', 'primary', 10000)
    scanDeadAnimals()
    startHunting()
end)

function startHunting()
    print("started hunting")
	local lastPress = 0
	while isHunting do
        local rep = HuntingRep
        if deadPeds ~= nil then
            for k,v in pairs(deadPeds) do
            	local plyPos = GetEntityCoords(PlayerPedId())
            	local pedPos = GetEntityCoords(k)
            	if #(plyPos - pedPos) < 30 and not DecorExistOn(k, "Animal.Looted") and #(plyPos - pedPos) > 2  then
                    DrawMarker(2, pedPos.x, pedPos.y, pedPos.z+1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.4, 0.3, 0.25, 255, 0, 0, 222, false, false, false, true, false, false, false)
            	end
                if #(plyPos - pedPos) < 2 then
                    if not DecorExistOn(k, "Animal.Looted") then
                        BJCore.Functions.DrawText3D(pedPos.x, pedPos.y, pedPos.z+.2, "[~g~E~s~]")
                        if IsControlJustReleased(0, 38) and not DecorExistOn(k, "Animal.Looted") and GetGameTimer() - lastPress >= 500 then
                            lastPress = GetGameTimer()
                            DecorSetInt(k, "Animal.Looted", 1)                            
                            exports['mythic_progbar']:Progress({
                                name = "loot_hunting",
                                duration = math.random(4000, 7000),
                                label = "Looting",
                                useWhileDead = false,
                                canCancel = true,
                                controlDisables = {
                                    disableMovement = true,
                                    disableCarMovement = true,
                                    disableMouse = false,
                                    disableCombat = true,
                                },
                                animation = {
                                    animDict = "amb@world_human_bum_wash@male@low@idle_a",
                                    anim = "idle_a",
                                    flags = 14,
                                },
                            }, function(status)
                                if not status then
                                    local rewardMeat = false
                                    if rep <= 30 then
                                        local chance = math.random(100)
                                        if chance <= 25 then
                                            rewardMeat = true
                                        end
                                    elseif rep <= 50 then
                                        local chance = math.random(100)
                                        if chance <= 35 then
                                            rewardMeat = true
                                        end
                                    elseif rep  <= 70 then
                                        local chance = math.random(100)
                                        if chance <= 45 then
                                            rewardMeat = true
                                        end
                                    elseif rep <= 90 then
                                        local chance = math.random(100)
                                        if chance <= 55 then
                                            rewardMeat = true
                                        end
                                    elseif rep >= 100 then
                                        local chance = math.random(100)
                                        if chance <= 65 then
                                            rewardMeat = true
                                        end
                                    end
                                    if rewardMeat then
                                        local hide = false
                                        if rep >= 70 then
                                            if math.random(100) <= 10 then
                                                hide = true
                                            end
                                        end                             
                                        TriggerServerEvent('hunting:reward', GetEntityModel(k), hide)
                                        rewardMeat = false
                                        local chance = math.random(100)
                                        if chance <= 25 then
                                            TriggerServerEvent('jobs:server:AddJobRep', 'hunting', 1)
                                            BJCore.Functions.Notify("You're getting better at hunting", 'primary', 2000)
                                        end
                                    else
                                        local chance = math.random(100)
                                        if chance <= 25 then
                                            TriggerServerEvent('jobs:server:AddJobRep', 'hunting', 1)
                                            BJCore.Functions.Notify("Experienced gained", 'primary', 2000)
                                        end                                
                                        BJCore.Functions.Notify("You've ruined this kill. Cannot loot meat", 'error', 2000)
                                    end
                                else
                                    BJCore.Functions.Notify("Cancelled", "error")
                                end
                            end)                             
                        end
                    end
                end                
            end
        else
        	Citizen.Wait(250)
        end
		Citizen.Wait(0)
	end
end

function scanDeadAnimals()
    print("started scanning")
	Citizen.CreateThread(function()
		while isHunting do
			local peds = BJCore.Functions.GetPeds()
			for k,v in pairs(peds) do
				if pedList[GetEntityModel(v)] and IsEntityDead(v) and not DecorExistOn(v, "Animal.Looted") then
					if not deadPeds[v] then
						print("found dead animal fam")
		                deadPeds[v] = true
		            end
	            end
			end
			Citizen.Wait(2500)
		end
	end)
end