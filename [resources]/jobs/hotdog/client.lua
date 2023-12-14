local HotdogBlip = nil
local IsWorking = false
local StandObject = nil
local IsPushing = false
local IsSelling = false
local IsUIActive = false
local PreparingFood = false
local SpatelObject = nil
local SellingData = {
    Enabled = false,
    Target = nil,
    HasTarget = false,
    RecentPeds = {},
    Hotdog = nil,
}
local OffsetData = {
    x = 0.0,
    y = -0.8,
    z = 1.0,
    Distance = 0.5
}
local LastStandPos = nil

local AnimationData = {
    lib = "missfinale_c2ig_11",
    anim = "pushcar_offcliff_f",
}

-- Citizen.CreateThread(function()
--     while BJCore == nil do
--         Citizen.Wait(100)
--     end
--     PlayerLoaded = true
--     PlayerData = BJCore.Functions.GetPlayerData()
--     PlayerJob = PlayerData.job
--     UpdateLevel()
--     UpdateBlip()
-- end)

local HotdogBlip = {}

local function UpdateBlip()
    -- Citizen.CreateThread(function()
    --     for k,v in pairs(Config.Locations["take"].coords) do
    --         local coords = v

    --         if HotdogBlip[v] ~= nil then
    --             RemoveBlip(HotdogBlip[v])
    --         end

    --         HotdogBlip[v] = AddBlipForCoord(v.x, v.y, v.z)
            
    --         SetBlipSprite(HotdogBlip[v], 93)
    --         SetBlipDisplay(HotdogBlip[v], 4)
    --         SetBlipScale(HotdogBlip[v], 0.6)
    --         SetBlipAsShortRange(HotdogBlip[v], true)
    --         SetBlipColour(HotdogBlip[v], 0)
    --         BeginTextCommandSetBlipName("STRING")
    --         AddTextComponentSubstringPlayerName("Chihuahua Hotdogs")
    --         EndTextCommandSetBlipName(HotdogBlip[v])
    --     end
    -- end)
end

local function UpdateLevel()
    local MyRep = PlayerData.metadata["jobrep"]["hotdog"]

    if MyRep ~= nil then
        if MyRep >= 1 and MyRep < 80 then
            Config.MyLevel = 1
        elseif MyRep >= 80 and MyRep < 150 then
            Config.MyLevel = 2
        elseif MyRep >= 150 and MyRep < 250 then
            Config.MyLevel = 3
        elseif MyRep >= 250 and MyRep < 350 then
            Config.MyLevel = 4
        elseif MyRep >= 350 then
            Config.MyLevel = 5
        end
    else
        Config.MyLevel = 1
    end

    local ReturnData = {
        lvl = Config.MyLevel,
        rep = MyRep
    }

    return ReturnData
end

Citizen.CreateThread(function()
    while true do
        local inRange = false
        if PlayerLoaded then
            if Config ~= nil then
                local PlayerPed = PlayerPedId()
                local PlayerPos = GetEntityCoords(PlayerPed)
                for k,v in pairs(Config.Locations["take"].coords) do
                    local v = v
                    local distance = #(PlayerPos.xyz - v.xyz)
                    if distance < 10 then
                        inRange = true
                        DrawMarker(2, v.x, v.y, v.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 252, 98, 3, 150, false, false, false, true, false, false, false)
                        --DrawMarker(2, v.x, v.y, v.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 255, 0, 0, 255, 0, 0, 0, 1, 0, 0, 0)
                        if not IsWorking then
                            if distance < OffsetData.Distance then
                                BJCore.Functions.DrawText3D(v.x, v.y, v.z, "[~g~E~s~] Start Selling Hotdogs")
                                if IsControlJustPressed(0, Keys["E"]) then
                                    StartWorking()
                                end
                            elseif distance < 3 then
                                BJCore.Functions.DrawText3D(v.x, v.y, v.z, "Start Selling Hotdogs")
                            end
                        else
                            if distance < OffsetData.Distance then
                                BJCore.Functions.DrawText3D(v.x, v.y, v.z, "[~r~E~s~] Stop Selling Hotdogs")
                                if IsControlJustPressed(0, Keys["E"]) then
                                    StopWorking()
                                end
                            elseif distance < 3 then
                                BJCore.Functions.DrawText3D(v.x, v.y, v.z, "Stop Selling Hotdogs")
                            end
                        end
                    end
                end
            end
        end
        if not inRange then
            Citizen.Wait(1000)
        end
        Citizen.Wait(3)
    end
end)

function StartWorking()
    BJCore.Functions.TriggerServerCallback('hotdogjob:server:HasMoney', function(HasMoney)
        if HasMoney then
            local PlayerPed = PlayerPedId()
            local SpawnCoords = GetClosestSpawnPoint()
            IsWorking = true
            BJCore.Functions.Notify('Note: The more you cook and sell the better rates you\'ll get when selling and the more consistent you get at making hotdogs', 'primary', 15000)
        
            LoadModel("prop_hotdogstand_01")
            StandObject = CreateObject(GetHashKey('prop_hotdogstand_01'), SpawnCoords.x, SpawnCoords.y, SpawnCoords.z, true)
            PlaceObjectOnGroundProperly(StandObject)
            SetEntityHeading(StandObject, SpawnCoords.w - 90)
            FreezeEntityPosition(StandObject, true)
            HotdogLoop()
            UpdateUI()
            CheckLoop()
            BJCore.Functions.Notify('You have paid a '..BJCore.Config.Currency.Symbol..'50 deposit', 'success')
        else
            BJCore.Functions.Notify('You can\'t afford the deposit of '..BJCore.Config.Currency.Symbol..'50', 'error')
        end
    end)
end

function GetClosestSpawnPoint()
    local pos, cdist
    local plyPos = GetEntityCoords(PlayerPedId())
    for k,v in pairs(Config.Locations["spawn"].coords) do
        local dist = #(plyPos - v.xyz)
        if not cdist or dist < cdist then
            pos = v
            cdist = dist
        end
    end
    if not cdist then return vector4(38.15, -1001.65, 29.44, 342.5)
    else return pos
    end
end

function UpdateUI()
    IsUIActive = true
    Citizen.CreateThread(function()
        while true do
            SendNUIMessage({
                action = "UpdateUI",
                IsActive = IsUIActive,
                Stock = Config.Stock,
                Level = UpdateLevel()
            })
            if not IsUIActive then
                break
            end
            Citizen.Wait(1000)
        end
    end)
end

function HotdogLoop()
    Citizen.CreateThread(function()
        while true do
            local PlayerPed = PlayerPedId()
            local PlayerPos = GetEntityCoords(PlayerPed)
            local ClosestObject = GetClosestObjectOfType(PlayerPos.x, PlayerPos.y, PlayerPos.z, 3.0, GetHashKey("prop_hotdogstand_01"), 0, 0, 0)

            if StandObject ~= nil then
                if ClosestObject ~= nil and ClosestObject == StandObject then
                    local ObjectOffset = GetOffsetFromEntityInWorldCoords(ClosestObject, 1.0, 0.0, 1.0)
                    local ObjectDistance = #(PlayerPos - ObjectOffset)

                    if ObjectDistance < 1.0 then
                        if not IsPushing then
                            BJCore.Functions.DrawText3D(ObjectOffset.x, ObjectOffset.y, ObjectOffset.z, '[~g~E~s~] Pick up')
                            if IsControlJustPressed(0, Keys["E"]) then
                                TakeHotdogStand()
                            end
                        else
                            BJCore.Functions.DrawText3D(ObjectOffset.x, ObjectOffset.y, ObjectOffset.z, '[~g~E~s~] Place Down')
                            if IsControlJustPressed(0, Keys["E"]) then
                                LetKraamLose()
                            end
                        end
                    elseif ObjectDistance < 3.0 then
                        BJCore.Functions.DrawText3D(ObjectOffset.x, ObjectOffset.y, ObjectOffset.z, 'Stall')
                    end
                end
            else
                break
            end

            Citizen.Wait(3)
        end
    end)

    Citizen.CreateThread(function()
        while true do
            local PlayerPed = PlayerPedId()
            local PlayerPos = GetEntityCoords(PlayerPed)
            local ClosestObject = GetClosestObjectOfType(PlayerPos.x, PlayerPos.y, PlayerPos.z, 3.0, GetHashKey("prop_hotdogstand_01"), 0, 0, 0)

            if StandObject ~= nil then
                if ClosestObject ~= nil and ClosestObject == StandObject then
                    local ObjectOffset = GetOffsetFromEntityInWorldCoords(StandObject, 0.0, 0.0, 1.0)
                    local ObjectDistance = #(PlayerPos - ObjectOffset)

                    if ObjectDistance < 1.0 then
                        if SellingData.Enabled then
                            BJCore.Functions.DrawText3D(ObjectOffset.x, ObjectOffset.y, ObjectOffset.z, '[~g~E~s~] Prepare hotdog [Sell: ~g~ON~w~]')
                        else
                            BJCore.Functions.DrawText3D(ObjectOffset.x, ObjectOffset.y, ObjectOffset.z, '[~g~E~s~] Prepare hotdog [Sell: ~r~OFF~w~]')
                        end
                        if IsControlJustPressed(0, Keys["E"]) then
                            StartHotdogMinigame()
                        end
                    end
                end
            else
                break
            end

            Citizen.Wait(3)
        end
    end)
end

RegisterNetEvent('hotdogjob:client:UpdateReputation')
AddEventHandler('hotdogjob:client:UpdateReputation', function(JobRep)
    PlayerData.metadata["jobrep"] = JobRep
    UpdateLevel()
end)

local toggleworking = false
RegisterNetEvent('hotdogjob:client:ToggleSell')
AddEventHandler('hotdogjob:client:ToggleSell', function(data)
    if not StandObject or StandObject == nil then BJCore.Functions.Notify("You need to hotdog cart to do this. Go to a Chihuahua Hotdog Store to get started", "primary", 10000) return end
    if not SellingData.Enabled then
        BJCore.Functions.PersistentNotify('start', 'hotdoggy', 'Currently selling to locals..', 'primary')
        SellingData.Enabled = true
        toggleworking = true
        ToggleSell()
    else
        BJCore.Functions.PersistentNotify('end', 'hotdoggy')
        BJCore.Functions.Notify('Stopped selling to locals', 'primary')
        if SellingData.Target ~= nil then
            SetPedKeepTask(SellingData.Target, false)
            SetEntityAsNoLongerNeeded(SellingData.Target)
            ClearPedTasksImmediately(SellingData.Target)
        end
        SellingData.Enabled = false
        SellingData.Target = nil
        SellingData.HasTarget = false
        toggleworking = false
    end
end)

function ToggleSell()
    local pos = GetEntityCoords(PlayerPedId())
    local objpos = GetEntityCoords(StandObject)
    local dist = #(pos - objpos)

    if StandObject ~= nil then
        if dist < 5.0 then
            Citizen.CreateThread(function()
                while true do
                    if SellingData.Enabled then
                        --print("looking for ped")
                        local player = PlayerPedId()
                        local coords = GetOffsetFromEntityInWorldCoords(StandObject, OffsetData.x, OffsetData.y, OffsetData.z)

                        if not SellingData.HasTarget then
                            local PlayerPeds = {}
                            if next(PlayerPeds) == nil then
                                for _, player in ipairs(GetActivePlayers()) do
                                    local ped = GetPlayerPed(player)
                                    table.insert(PlayerPeds, ped)
                                end
                            end
                            
                            local closestPed, closestDistance = BJCore.Functions.GetClosestPed(coords, PlayerPeds)

                            if closestDistance < 15.0 and closestPed ~= 0 then
                                print("selling fam")
                                SellToPed(closestPed)
                                Citizen.Wait(math.random(7000,10000))
                            end
                        end
                    else
                        print("with customer waiting")
                        Citizen.Wait(2000)
                    end
                    if not toggleworking then break; end
                    Citizen.Wait(100)
                end
            end)
        else
            BJCore.Functions.Notify('You are too far from your hotdog stall', 'error')
        end
    else
        BJCore.Functions.Notify('You have no hotdog stall', 'error')
    end
end

function GetAvailableHotdog()
    local retval = nil
    local AvailableHotdogs = {}
    for k, v in pairs(Config.Stock) do
        if v.Current > 0 then
            table.insert(AvailableHotdogs, {
                key = k,
                value = v,
            })
        end
    end
    if next(AvailableHotdogs) ~= nil then
        local Random = math.random(1, #AvailableHotdogs)
        retval = AvailableHotdogs[Random].key
    end
    return retval
end

function SellToPed(ped)
    SellingData.HasTarget = true
    for i = 1, #SellingData.RecentPeds, 1 do
        if SellingData.RecentPeds[i] == ped then
            SellingData.HasTarget = false
            return
        end
    end

    SetEntityAsNoLongerNeeded(ped)
    ClearPedTasks(ped)

    local SellingPrice = 0
    local HotdogsForSale = 0

    local Selling = false
    local HotdogObject = nil
    local HotdogObject2 = nil
    local AnimPlayed = false

    SellingData.Hotdog = GetAvailableHotdog()

    if SellingData.Hotdog ~= nil then
        if Config.Stock[SellingData.Hotdog].Current > 1 then
            if Config.Stock[SellingData.Hotdog].Current >= 3 then
                HotdogsForSale = math.random(1, 3)
            else
                HotdogsForSale = math.random(1, Config.Stock[SellingData.Hotdog].Current)
            end
        elseif Config.Stock[SellingData.Hotdog].Current == 1 then
            HotdogsForSale = 1
        end

        if SellingData.Hotdog ~= nil then
            SellingPrice = math.random(Config.Stock[SellingData.Hotdog].Price[Config.MyLevel].min, Config.Stock[SellingData.Hotdog].Price[Config.MyLevel].max)
        end
    end

    local coords = GetOffsetFromEntityInWorldCoords(StandObject, OffsetData.x, OffsetData.y, OffsetData.z)
    local pedCoords = GetEntityCoords(ped)
    local pedDist = #(coords - pedCoords)
    local PlayerDist = #(GetEntityCoords(PlayerPedId()) - coords.x)

    local startTimer = GetGameTimer()
    TaskGoStraightToCoord(ped, coords, 1.2, -1, 0.0, 2.0)
    while pedDist > OffsetData.Distance do
        coords = GetOffsetFromEntityInWorldCoords(StandObject, OffsetData.x, OffsetData.y, OffsetData.z)
        PlayerDist = #(GetEntityCoords(PlayerPedId()) - coords)
        pedCoords = GetEntityCoords(ped)    
        TaskGoStraightToCoord(ped, coords, 1.2, -1, 0.0, 0.0)
        pedDist = #(coords - pedCoords)
        print("ped dist: "..pedDist)
        if PlayerDist > 15.0 then
            SellingData.HasTarget = false
            SetPedKeepTask(ped, false)
            SetEntityAsNoLongerNeeded(ped)
            ClearPedTasksImmediately(ped)
            table.insert(SellingData.RecentPeds, ped)
            SellingData = {
                Enabled = false,
                Target = nil,
                HasTarget = false,
                Hotdog = nil,
            }
            BJCore.Functions.Notify('You\'re too far from your stall', 'error')
            break
        end
        if GetGameTimer() - startTimer > 10000 and pedDist <= 2 then
            SetEntityCoords(ped, coords.x,coords.y+0.04,coords.z-1.0)
        end
        Citizen.Wait(100)
    end

    FreezeEntityPosition(ped, true)
    TaskLookAtEntity(ped, PlayerPedId(), 5500.0, 2048, 3)
    TaskTurnPedToFaceEntity(ped, PlayerPedId(), 5500)
    local heading = (GetEntityHeading(PlayerPedId()) + 180)
    SetEntityHeading(ped, heading)
    TaskStartScenarioInPlace(ped, "WORLD_HUMAN_STAND_IMPATIENT_UPRIGHT", 0, false)
    SellingData.Target = ped
    
    local lastPress = 0
    while pedDist < OffsetData.Distance and SellingData.HasTarget do
        coords = GetOffsetFromEntityInWorldCoords(StandObject, OffsetData.x, OffsetData.y, OffsetData.z)
        PlayerDist = #(GetEntityCoords(PlayerPedId()) - coords)
        pedCoords = GetEntityCoords(ped)
        pedDist = #(coords - pedCoords)

        if PlayerDist < 7.5 then
            if SellingData.Hotdog ~= nil then
                if HotdogsForSale == 0 and SellingPrice == 0 then
                    if Config.Stock[SellingData.Hotdog].Current > 1 then
                        if Config.Stock[SellingData.Hotdog].Current >= 3 then
                            HotdogsForSale = math.random(1, 3)
                        else
                            HotdogsForSale = math.random(1, Config.Stock[SellingData.Hotdog].Current)
                        end
                    elseif Config.Stock[SellingData.Hotdog].Current == 1 then
                        HotdogsForSale = 1
                    end
            
                    if SellingData.Hotdog ~= nil then
                        SellingPrice = math.random(Config.Stock[SellingData.Hotdog].Price.min, Config.Stock[SellingData.Hotdog].Price.max)
                    end
                end
                BJCore.Functions.DrawText3D(pedCoords.x, pedCoords.y, pedCoords.z, '[~g~7~s~] Sell '..HotdogsForSale..'x for '..BJCore.Config.Currency.Symbol..(HotdogsForSale * SellingPrice)..' | [~r~8~s~] Refuse')
                if IsControlJustPressed(0, Keys["7"]) or IsDisabledControlJustPressed(0, Keys["7"]) and GetGameTimer() - lastPress > 500 then
                    lastPress = GetGameTimer()
                    BJCore.Functions.Notify(HotdogsForSale..'x Hotdog(s) sold for '..BJCore.Config.Currency.Symbol..(HotdogsForSale * SellingPrice), 'success')
                    TriggerServerEvent('hotdogjob:server:Sell', HotdogsForSale, SellingPrice)
                    SellingData.HasTarget = false
                    local Myped = PlayerPedId()

                    Selling = true

                    while Selling do
                        if not IsEntityPlayingAnim(Myped, 'mp_common', 'givetake1_b', 3) then
                            LoadAnim('mp_common')
                            if not AnimPlayed then
                                TaskPlayAnim(Myped, 'mp_common', 'givetake1_b', 8.0, 8.0, 1100, 48, 0.0, 0, 0, 0)
                                AnimPlayed = true
                            end
                            if HotdogObject == nil then
                                HotdogObject = CreateObject(GetHashKey("prop_cs_hotdog_01"), 0, 0, 0, true, true, true)
                            end
                            AttachEntityToEntity(HotdogObject, Myped, GetPedBoneIndex(Myped, 57005), 0.12, 0.0, -0.05, 220.0, 120.0, 0.0, true, true, false, true, 1, true)
                            SetTimeout(1250, function()
                                Selling = false
                            end)
                        end

                        Citizen.Wait(0)
                    end

                    if HotdogObject ~= nil then
                        DetachEntity(HotdogObject, 1, 1)
                        DeleteEntity(HotdogObject)
                        AnimPlayed = false
                        HotdogObject = nil
                    end

                    FreezeEntityPosition(ped, false)
                    SetPedKeepTask(ped, false)
                    SetEntityAsNoLongerNeeded(ped)
                    ClearPedTasksImmediately(ped)
                    table.insert(SellingData.RecentPeds, ped)
                    Config.Stock[SellingData.Hotdog].Current = Config.Stock[SellingData.Hotdog].Current - HotdogsForSale
                    SellingData.Hotdog = nil
                    SellingPrice = 0
                    HotdogsForSale = 0
                    Citizen.Wait(5000,9000)
                    break
                end

                if IsControlJustPressed(0, Keys["8"]) or IsDisabledControlJustPressed(0, Keys["8"]) and GetGameTimer() - lastPress > 500 then
                    lastPress = GetGameTimer()
                    BJCore.Functions.Notify('Denied Customer', 'error')
                    SellingData.HasTarget = false

                    FreezeEntityPosition(ped, false)
                    SetPedKeepTask(ped, false)
                    SetEntityAsNoLongerNeeded(ped)
                    ClearPedTasksImmediately(ped)
                    table.insert(SellingData.RecentPeds, ped)
                    SellingData.Hotdog = nil
                    SellingPrice = 0
                    HotdogsForSale = 0
                    Citizen.Wait(5000,9000)
                    break
                end
            else
                SellingData.Hotdog = GetAvailableHotdog()
                BJCore.Functions.DrawText3D(pedCoords.x, pedCoords.y, pedCoords.z, 'No hotdogs to sell | [~r~8~s~] Deny customer')

                if IsControlJustPressed(0, Keys["8"]) or IsDisabledControlJustPressed(0, Keys["8"]) and GetGameTimer() - lastPress > 500 then
                    lastPress = GetGameTimer()
                    BJCore.Functions.Notify('Denied Customer', 'error')
                    SellingData.HasTarget = false

                    FreezeEntityPosition(ped, false)
                    SetPedKeepTask(ped, false)
                    SetEntityAsNoLongerNeeded(ped)
                    ClearPedTasksImmediately(ped)
                    table.insert(SellingData.RecentPeds, ped)
                    SellingData.Hotdog = nil
                    Citizen.Wait(5000,9000)
                    break
                end
            end
        else
            SellingData.HasTarget = false
            FreezeEntityPosition(ped, false)
            SetPedKeepTask(ped, false)
            SetEntityAsNoLongerNeeded(ped)
            ClearPedTasksImmediately(ped)
            table.insert(SellingData.RecentPeds, ped)
            SellingData = {
                Enabled = false,
                Target = nil,
                HasTarget = false,
                Hotdog = nil,
            }
            BJCore.Functions.Notify('You\'re too far from your stall', 'error')
            break
        end
        
        Citizen.Wait(3)
    end
end

function StartHotdogMinigame()
    PrepareAnim()
    TriggerEvent('keyminigame:show')
    TriggerEvent('keyminigame:start', FinishMinigame)
end

function PrepareAnim()
    local ped = PlayerPedId()
    LoadAnim('amb@prop_human_bbq@male@idle_a')
    TaskPlayAnim(ped, 'amb@prop_human_bbq@male@idle_a', 'idle_b', 6.0, -6.0, -1, 47, 0, 0, 0, 0)
    SpatelObject = CreateObject(GetHashKey("prop_fish_slice_01"), 0, 0, 0, true, true, true)
    AttachEntityToEntity(SpatelObject, ped, GetPedBoneIndex(ped, 57005), 0.08, 0.0, -0.02, 0.0, -25.0, 130.0, true, true, false, true, 1, true)
    PreparingAnimCheck()
end

function PreparingAnimCheck()
    PreparingFood = true
    Citizen.CreateThread(function()
        while true do
            local ped = PlayerPedId()

            if PreparingFood then
                if not IsEntityPlayingAnim(ped, 'amb@prop_human_bbq@male@idle_a', 'idle_b', 3) then
                    LoadAnim('amb@prop_human_bbq@male@idle_a')
                    TaskPlayAnim(ped, 'amb@prop_human_bbq@male@idle_a', 'idle_b', 6.0, -6.0, -1, 49, 0, 0, 0, 0)
                end
            else
                DetachEntity(SpatelObject)
                DeleteEntity(SpatelObject)
                ClearPedTasksImmediately(ped)
                break
            end

            Citizen.Wait(200)
        end
    end)
end

function FinishMinigame(faults)
    Citizen.CreateThread(function()
        if faults < 8 then
            local success = false
            -- local myRep = PlayerData.metadata["jobrep"]["hotdog"]
            -- if myRep <= 30 then
            --     local chance = math.random(100)
            --     if chance <= 35 then
            --         success = true
            --     end
            -- elseif myRep <= 50 then
            --     local chance = math.random(100)
            --     if chance <= 40 then
            --         success = true
            --     end
            -- elseif myRep  <= 80 then
            --     local chance = math.random(100)
            --     if chance <= 45 then
            --         success = true
            --     end
            -- elseif myRep <= 100 then
            --     local chance = math.random(100)
            --     if chance <= 50 then
            --         success = true
            --     end
            -- elseif myRep <= 120 then
            --     local chance = math.random(100)
            --     if chance <= 55 then
            --         success = true
            --     end
            -- elseif myRep <= 140 then
            --     local chance = math.random(100)
            --     if chance <= 60 then
            --         success = true
            --     end
            -- elseif myRep <= 160 then
            --     local chance = math.random(100)
            --     if chance <= 65 then
            --         success = true
            --     end 
            -- elseif myRep <= 180 then
            --     local chance = math.random(100)
            --     if chance <= 70 then
            --         success = true
            --     end
            -- elseif myRep >= 200 then
            --     local chance = math.random(100)
            --     if chance <= 75 then
            --         success = true
            --     end                                                                   
            -- end
            local intRewardCeiling = 35 --=// Default Chance for success is 35%
            local myRep = PlayerData.metadata["jobrep"]["hotdog"]
            
             if myRep > 30 and myRep < 51 then
                intRewardCeiling = 40 --=// Rep 31-50 = 40% Chance
            elseif myRep > 50 and myRep < 81 then
                intRewardCeiling = 45 --=// Rep 51-80 = 45% Chance
            elseif myRep > 80 and myRep < 101 then
                intRewardCeiling = 50 --=// Rep 81-100 = 50% Chance
            elseif myRep > 100 and myRep < 121 then
                intRewardCeiling = 55 --=// Rep 101-120 = 55% Chance
            elseif myRep > 120 and myRep < 141 then
                intRewardCeiling = 60 --=// Rep 121-140 = 60% Chance
            elseif myRep > 140 and myRep < 161 then
                intRewardCeiling = 65 --=// Rep 141-160 = 65% Chance
            elseif myRep > 160 and myRep < 181 then
                intRewardCeiling = 70 --=// Rep 161-180 = 70% Chance
            elseif myRep > 180 and myRep < 201 then
                intRewardCeiling = 73 --=// Rep 181-200 = 73% Chance
            elseif myRep > 200 then
                intRewardCeiling = 75 --=// Rep 201+ = 75% Chance
            end
            
            local intChance = math.random(100)
            
            if intChance <= intRewardCeiling then
                success = true
            end  
            BJCore.Functions.Notify('Checking hotdog...',"primary",2000)
            Wait(2000)
            if success then
                local Quality = "common"
                local roll = math.random(100)
                if Config.MyLevel == 1 then
                    if roll <= 70 then
                        Quality = "common"
                    elseif roll <= 90 then
                        Quality = "exotic"
                    else
                        Quality = "rare"
                    end
                elseif Config.MyLevel == 2 then
                    if roll <= 65 then
                        Quality = "common"
                    elseif roll <= 85 then
                        Quality = "exotic"
                    else
                        Quality = "rare"
                    end
                elseif Config.MyLevel == 3 then
                    if roll <= 55 then
                        Quality = "common"
                    elseif roll <= 75 then
                        Quality = "exotic"
                    else
                        Quality = "rare"
                    end
                elseif Config.MyLevel == 4 then
                    if roll <= 50 then
                        Quality = "common"
                    elseif roll <= 70 then
                        Quality = "exotic"
                    else
                        Quality = "rare"
                    end
                elseif Config.MyLevel == 5 then
                    if roll <= 45 then
                        Quality = "common"
                    elseif roll <= 65 then
                        Quality = "exotic"
                    else
                        Quality = "rare"
                    end
                end
                
                if Config.Stock[Quality].Current + 1 <= Config.Stock[Quality].Max[Config.MyLevel] then
                    TriggerServerEvent('hotdogjob:server:UpdateReputation', Quality)
                    if Config.MyLevel == 1 then
                        BJCore.Functions.Notify('You made a '..Config.Stock[Quality].Label..' Hotdog')
                        Config.Stock[Quality].Current = Config.Stock[Quality].Current + 1
                    else
                        local Luck = math.random(1, 2)
                        local LuckyNumber = math.random(1, 2)
                        local LuckyAmount = math.random(1, Config.MyLevel)
                        if Luck == LuckyNumber then
                            BJCore.Functions.Notify('You have '..LuckyAmount..' '..Config.Stock[Quality].Label..' Hotdog(s)')
                            Config.Stock[Quality].Current = Config.Stock[Quality].Current + LuckyAmount
                        else
                            BJCore.Functions.Notify('You made a '..Config.Stock[Quality].Label..' Hotdog')
                            Config.Stock[Quality].Current = Config.Stock[Quality].Current + 1
                        end
                    end
                else
                    BJCore.Functions.Notify('You have no ('..Config.Stock[Quality].Label..') hotdogs')
                end
            else
                local chancefail = math.random(100)
                if chancefail <= 25 then
                    BJCore.Functions.Notify("You messed that one up but you're learning. Keep going", "primary", 6000)
                    TriggerServerEvent('jobs:server:AddJobRep', 'hotdog', 1)
                else
                    local c = math.random(1,3)
                    if c == 1 then
                        BJCore.Functions.Notify("This weiner looks a bit wonky. You can't sell this", "error", 6000)
                    elseif c == 2 then
                        BJCore.Functions.Notify("Have you ever heard of condiments?! You can't sell this tasteless thing", "error", 6000)
                    else
                        BJCore.Functions.Notify("It's f***ing RAW. You can't sell this!", "error", 6000)
                    end                
                end
            end
            PreparingFood = false
        else
            BJCore.Functions.Notify("You ruined this hotdog", "error")
            PreparingFood = false
        end
    end)
end

function TakeHotdogStand()
    local PlayerPed = PlayerPedId()
    IsPushing = true
    NetworkRequestControlOfEntity(StandObject)
    LoadAnim(AnimationData.lib)
    TaskPlayAnim(PlayerPed, AnimationData.lib, AnimationData.anim, 8.0, 8.0, -1, 50, 0, false, false, false)
    SetTimeout(150, function()
        AttachEntityToEntity(StandObject, PlayerPed, GetPedBoneIndex(PlayerPed, 28422), -0.45, -1.2, -0.82, 180.0, 180.0, 270.0, false, false, false, false, 1, true)
    end)
    FreezeEntityPosition(StandObject, false)
    AnimLoop()
end

function LetKraamLose()
    local PlayerPed = PlayerPedId()
    DetachEntity(StandObject)
    SetEntityCollision(StandObject, true, true)
    ClearPedTasks(PlayerPed)
    IsPushing = false
end

function AnimLoop()
    Citizen.CreateThread(function()
        while true do
            if IsPushing then
                local PlayerPed = PlayerPedId()
                if not IsEntityPlayingAnim(PlayerPed, AnimationData.lib, AnimationData.anim, 3) then
                    LoadAnim(AnimationData.lib)
                    TaskPlayAnim(PlayerPed, AnimationData.lib, AnimationData.anim, 8.0, 8.0, -1, 50, 0, false, false, false)
                end
            else
                break
            end
            Citizen.Wait(1000)
        end
    end)
end

function StopWorking()
    if DoesEntityExist(StandObject) then
        BJCore.Functions.TriggerServerCallback('hotdogjob:server:BringBack', function(DidBail)
            if DidBail then
                DeleteObject(StandObject)
                ClearPedTasksImmediately(PlayerPedId())
                IsWorking = false
                StandObject = nil
                IsPushing = false
                IsSelling = false
                IsUIActive = false
        
                for _, v in pairs(Config.Stock) do
                    v.Current = 0
                end
                BJCore.Functions.Notify('You recieved your '..BJCore.Config.Currency.Symbol..'50 deposit', 'success')
            else
                BJCore.Functions.Notify('Something has gone wrong. RIP', 'error')
            end
        end)
    else
        BJCore.Functions.Notify('You\'ve lost your stall or it has been destroyed. We\'re keeping your deposit!', 'error')
        IsWorking = false
        StandObject = nil
        IsPushing = false
        IsSelling = false
        IsUIActive = false

        for _, v in pairs(Config.Stock) do
            v.Current = 0
        end
    end
    BJCore.Functions.PersistentNotify('end', 'hotdoggy')
    if SellingData.Target ~= nil then
        SetPedKeepTask(SellingData.Target, false)
        SetEntityAsNoLongerNeeded(SellingData.Target)
        ClearPedTasksImmediately(SellingData.Target)
    end
    SellingData.Enabled = false
    SellingData.Target = nil
    SellingData.HasTarget = false
    toggleworking = false
end

local DetachKeys = {157, 158, 160, 164, 165, 73, 36, 44}
function CheckLoop()
    Citizen.CreateThread(function()
        while true do
            if IsWorking then
                if IsPushing then
                    for _, PressedKey in pairs(DetachKeys) do
                        if IsControlJustPressed(0, PressedKey) or IsDisabledControlJustPressed(0, PressedKey) then
                            LetKraamLose()
                        end
                    end

                    if IsPedShooting(PlayerPedId()) or IsPlayerFreeAiming(PlayerId()) or IsPedInMeleeCombat(PlayerPedId()) then
                        LetKraamLose()
                    end

                    if IsPedDeadOrDying(PlayerPedId(), false) then
                        LetKraamLose()
                    end

                    if IsPedRagdoll(PlayerPedId()) then
                        LetKraamLose()
                    end
                else
                    Citizen.Wait(1000)
                end
            else
                break
            end
            Citizen.Wait(5)
        end
    end)
end

RegisterNetEvent('hotdogjob:staff:DeletStand')
AddEventHandler('hotdogjob:staff:DeletStand', function()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local Object = GetClosestObjectOfType(pos.x, pos.y, pos.z, 10.0, GetHashKey('prop_hotdogstand_01'), true, false, false)
    
    if Object ~= nil then
        local ObjectCoords = GetEntityCoords(Object)
        local ObjectDistance = #(pos - ObjectCoords)

        if ObjectDistance <= 5 then
            NetworkRegisterEntityAsNetworked(Object)
            Citizen.Wait(100)           
            NetworkRequestControlOfEntity(Object)            
            if not IsEntityAMissionEntity(Object) then
                SetEntityAsMissionEntity(Object)        
            end
            Citizen.Wait(100)            
            DeleteEntity(Object)
            BJCore.Functions.Notify('Hotdog stall returned')
        end
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        if StandObject ~= nil then
            DeleteObject(StandObject)
            ClearPedTasksImmediately(PlayerPedId())
        end
    end
end)

function LoadAnim(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Citizen.Wait(1)
    end
end

function LoadModel(model)
    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(1)
    end
end

RegisterNetEvent('BJCore:Client:OnPlayerLoaded')
AddEventHandler('BJCore:Client:OnPlayerLoaded', function()
    UpdateLevel()
    --UpdateBlip()
end)

RegisterNetEvent('BJCore:Client:OnJobUpdate')
AddEventHandler('BJCore:Client:OnJobUpdate', function(JobInfo)
    --UpdateBlip()
end)