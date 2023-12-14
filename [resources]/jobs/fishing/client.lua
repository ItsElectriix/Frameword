local isFishing = false

RegisterNetEvent('fishing:startFish')
AddEventHandler('fishing:startFish', function() 
    if IsPedInAnyVehicle(PlayerPedId(), true) then return BJCore.Functions.Notify("You cannot do this from a vehicle", "error"); end 
    if isFishing then 
        isFishing = false 
        ClearPedTasks(PlayerPedId())
        BJCore.Functions.Notify("Finished fishing", "primary") 
        return 
    end
    BJCore.Functions.PersistentNotify('end', 'Fishing')
    local ped = PlayerPedId()
     
    local hash = GetHashKey('a_c_rat')
    RequestModel(hash)
    while not HasModelLoaded(hash) do Citizen.Wait(50) print('Request Model') end
    local foundWater = false
    for i=1, 10 do
        for j=1, 10 do
            local coords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, i*1.01, j*-1.01)
            local fish = CreatePed(4, hash, coords, 0.0, false, false)
            SetEntityAsMissionEntity(fish, 1, 1)
            Wait(5) -- < this
            if IsEntityInWater(fish) then
                DeleteEntity(fish)
                foundWater = true
                StartFishing()
                print("found")
                break
            end
            if not fish then break end
            DeleteEntity(fish)
        end
        if foundWater then break end
    end
    if not foundWater then
        BJCore.Functions.Notify("You\'re not near a body of water", "error")
        return
    end
end)

local difficulty = 2
local speed = 4
local timeout = 3500

function StartFishing()
    BJCore.Functions.Notify("Started Fishing. Good Luck!", "success")
    isFishing = true
    TaskStartScenarioInPlace(PlayerPedId(), 'WORLD_HUMAN_STAND_FISHING', 0, true)
    BJCore.Functions.PersistentNotify('start', 'Fishing', "Fishing... Pay attention!", "primary")
    BJCore.Functions.Notify('Note: The more you catch fish the better you get at fishing/catching the right things', 'primary', 10000)
    local nextInterval = 0
    local maxCount = 0
    local curCount = 0
    local StartTime = GetGameTimer()
    local interacting = false
    Wait(math.random(250, 6250))
    while isFishing do
        local rep = FishingRep
        --print("rep: "..rep)
        if maxCount == 0 then
            maxCount = math.random(2,4)
            print("max: "..maxCount)
        end
        if nextInterval == 0 then
            nextInterval = math.random(5000, 30000)
            print("cur interval: "..nextInterval)
        end
        while GetGameTimer() - StartTime <= nextInterval do
            if not isFishing then break; end
            Wait(0)
        end
        StartTime = GetGameTimer()
        nextInterval = 0
        
        if isFishing and IsPedUsingScenario(PlayerPedId(), 'WORLD_HUMAN_STAND_FISHING') and not interacting then
            interacting = true
            TriggerEvent('bj_minigames:start', 'Lockbox', { difficulty = math.random(2,4), speed = math.random(3,5), attempts = 2, stages = math.random(1,4), stageTimeout = timeout }, function(data)
                if curCount == maxCount then
                    print("reward")
                    local success = false
                    local amount = 1
                    -- if rep <= 30 then
                    --     local chance = math.random(100)
                    --     if chance <= 35 then
                    --         success = true
                    --     end
                    -- elseif rep <= 50 then
                    --     local chance = math.random(100)
                    --     if chance <= 40 then
                    --         success = true
                    --     end
                    -- elseif rep  <= 70 then
                    --     local chance = math.random(100)
                    --     if chance <= 50 then
                    --         success = true
                    --     end
                    -- elseif rep <= 90 then
                    --     local chance = math.random(100)
                    --     if chance <= 60 then
                    --         success = true
                    --     end
                    -- elseif rep >= 100 then
                    --     local chance = math.random(100)
                    --     if chance <= 70 then
                    --         success = true
                    --     end
                    -- end
                    local intRewardCeiling = 35 --=// Default Chance for success is 35%
                    
                    if rep > 30 and rep < 51 then
                        intRewardCeiling = 40 --=// Rep 31-50 = 40% Chance
                    elseif rep > 50 and rep < 71 then
                        intRewardCeiling = 50 --=// Rep 51-70 = 50% Chance
                    elseif rep > 70 and rep < 91 then
                        intRewardCeiling = 60 --=// Rep 71-90 = 60% Chance
                    elseif rep > 90 and rep < 100 then
                        intRewardCeiling = 65 --=// Rep 91-99 = 65% Chance
                    elseif rep > 99 then
                        intRewardCeiling = 70 --=// Rep 100+ = 70% Chance
                    end
                    
                    local intChance = math.random(100)
                    
                    if intChance <= intRewardCeiling then
                        success = true
                    end  

                    if success then
                        if rep >= 70 then
                            if math.random(100) <= 40 then
                                amount = 2
                            end
                        end
                        TriggerServerEvent('fishing:reward', 'fish', amount)
                        BJCore.Functions.Notify("You caught something!", "success")
                        success = false
                        local chance = math.random(100)
                        if chance <= 45 then
                            TriggerServerEvent('jobs:server:AddJobRep', 'fishing', 1)
                            BJCore.Functions.Notify("Gained fishing experience", "success")
                        end
                    else
                        local chance = math.random(100)
                        if chance <= 25 then
                            TriggerServerEvent('fishing:reward', 'trash', amount)
                            BJCore.Functions.Notify("You didn't catch a fish but you did reel something random", "primary", 5000)
                        else
                            BJCore.Functions.Notify("You failed to catch this fish. Keep trying..", "error")
                        end
                        local chance = math.random(100)
                        if chance <= 30 then
                            TriggerServerEvent('jobs:server:AddJobRep', 'fishing', 1)
                            BJCore.Functions.Notify("Gained fishing experience", "success")
                        end                                           
                    end
                    maxCount = 0
                    curCount = 0
                    Wait(math.random(4000, 9000))
                else
                    curCount = curCount + 1                      
                end
                Wait(math.random(3000, 6000))
                StartTime = GetGameTimer()
                interacting = false
            end, function(data)
                maxCount = 0
                curCount = 0
                Wait(math.random(4000, 9000))
                StartTime = GetGameTimer()
                interacting = false                
            end)
        end
        Citizen.Wait(0)
    end
    BJCore.Functions.PersistentNotify('end', 'Fishing')
end