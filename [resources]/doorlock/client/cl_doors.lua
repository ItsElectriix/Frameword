Data = {
    Current = {
        Area = nil,
        Doors = {},
        Info = {},
        IsOwner = false
    },
    Player = {
        IsLoaded = false,
        PlayerData = {}
    },
    Utilities = {
        IsNight = false,
        Active = false
    },
    LocationAccessCache = {}
}

local function lockAtNight()
    local time = GetClockHours()
    if time >= 7
        and time <= 19
        then
        if Data.Utilities.IsNight then
            for a = 1, #doorList do
                for b = 1, #doorList[a].doors do
                    if doorList[a].doors[b].lockAtNight
                        and doorList[a].doors[b].isLocked
                        then
                        doorList[a].doors[b].isLocked = false
                    end
                end
            end
            Data.Utilities.IsNight = false
            TriggerServerEvent('doorlock:server:lockAtNight', Data.Utilities.IsNight)
        end
    else
        if not Data.Utilities.IsNight then
            for a = 1, #doorList do
                for b = 1, #doorList[a].doors do
                    if doorList[a].doors[b].lockAtNight
                        and not doorList[a].doors[b].isLocked
                        then
                        doorList[a].doors[b].isLocked = true
                    end
                end
            end
            Data.Utilities.IsNight = true
            TriggerServerEvent('doorlock:server:lockAtNight', Data.Utilities.IsNight)
        end
    end
    SetTimeout(5000, lockAtNight)
end
lockAtNight()

local function locationCheck()
    local plyPed = PlayerPedId()
    local plyPos = GetEntityCoords(plyPed)
    local reset = true
    for i = 1, #doorList do
        local isNear = #(plyPos - doorList[i].centralPos)
        if isNear <= doorList[i].distanceCheck then
            reset = false
            if Data.Current.Area == nil
                or Data.Current.Area ~= doorList[i].location
                then
                Data.Current.Doors = doorList[i].doors
                Data.Current.Area = doorList[i].location
                Data.Current.Info = doorList[i].groupInfo
                
                Utilities.SetIsAreaOwner()
            end
        end
    end
    if reset then
        if Data.Current.Area ~= nil then
            Data.Current.Doors = {}
            Data.Current.Area = nil
            Data.Current.Info = nil
            Data.Current.IsOwner = false
        end
    end
    SetTimeout(250, locationCheck)
end

local function disableFuccBoisFromShootingLockedDoorsOpen()
    if Data.Current.Area ~= nil then
        for i = 1, #Data.Current.Doors do
            local doorSingle = nil
            local door1 = nil
            local door2 = nil
            if Data.Current.Doors[i].doubleDoor then
                if Data.Current.Doors[i].multiModel then
                    local model1 = nil
                    local model2 = nil
                    for k, v in pairs(Data.Current.Doors[i].doorModel) do
                        if k == 1 then
                            model1 = v
                        elseif k == 2 then
                            model2 = v
                        end
                    end
                    for m, n in pairs(Data.Current.Doors[i].doorPos) do
                        if m == 1 then
                            if door1 == nil then
                                door1 = GetClosestObjectOfType(n, Data.Current.Doors[i].unlockDistance + 0.0, model1, false, false, false)
                            end
                            local currentHeading1 = GetEntityHeading(door1)
                            if currentHeading1 ~= Data.Current.Doors[i].heading1 then
                                if Data.Current.Doors[i].isLocked then
                                    SetEntityRotation(door1, 0, 0, Data.Current.Doors[i].heading1)
                                end
                            end
                            FreezeEntityPosition(door1, Data.Current.Doors[i].isLocked)
                        elseif m == 2 then
                            if door2 == nil then
                                door2 = GetClosestObjectOfType(n, Data.Current.Doors[i].unlockDistance + 0.0, model2, false, false, false)
                            end
                            local currentHeading2 = GetEntityHeading(door2)
                            if currentHeading2 ~= Data.Current.Doors[i].heading2 then
                                if Data.Current.Doors[i].isLocked then
                                    SetEntityRotation(door2, 0, 0, Data.Current.Doors[i].heading2)
                                end
                            end
                            FreezeEntityPosition(door2, Data.Current.Doors[i].isLocked)
                        end
                    end
                else
                    for k, v in pairs(Data.Current.Doors[i].doorPos) do
                        if k == 1 then
                            if door1 == nil then
                                door1 = GetClosestObjectOfType(v, Data.Current.Doors[i].unlockDistance + 0.0, Data.Current.Doors[i].doorModel, false, false, false)
                            end
                            local currentHeading1 = GetEntityHeading(door1)
                            if currentHeading1 ~= Data.Current.Doors[i].heading1 then
                                if Data.Current.Doors[i].isLocked then
                                    SetEntityRotation(door1, 0, 0, Data.Current.Doors[i].heading1)
                                end
                            end
                            FreezeEntityPosition(door1, Data.Current.Doors[i].isLocked)
                        elseif k == 2 then
                            if door2 == nil then
                                print("v: "..tostring(v))
                                print("unlock: "..tostring(Data.Current.Doors[i].unlockDistance))
                                print("model: "..tostring(Data.Current.Doors[i].doorModel))
                                door2 = GetClosestObjectOfType(v, Data.Current.Doors[i].unlockDistance + 0.0, Data.Current.Doors[i].doorModel, false, false, false)
                            end
                            local currentHeading2 = GetEntityHeading(door2)
                            if currentHeading2 ~= Data.Current.Doors[i].heading2 then
                                if Data.Current.Doors[i].isLocked then
                                    SetEntityRotation(door2, 0, 0, Data.Current.Doors[i].heading2)
                                end
                            end
                            FreezeEntityPosition(door2, Data.Current.Doors[i].isLocked)
                        end
                    end
                end
            else
                if doorSingle == nil then
                    doorSingle = GetClosestObjectOfType(Data.Current.Doors[i].doorPos, Data.Current.Doors[i].unlockDistance + 0.0, Data.Current.Doors[i].doorModel, false, false, false)
                end
                local currentHeading = GetEntityHeading(doorSingle)
                if currentHeading ~= Data.Current.Doors[i].heading then
                    if Data.Current.Doors[i].isLocked then
                        SetEntityRotation(doorSingle, 0, 0, Data.Current.Doors[i].heading)
                    end
                end
                FreezeEntityPosition(doorSingle, Data.Current.Doors[i].isLocked)
            end
        end
    end
    SetTimeout(500, disableFuccBoisFromShootingLockedDoorsOpen)
end
disableFuccBoisFromShootingLockedDoorsOpen()

Citizen.CreateThread(function()
    locationCheck()
    while not BJCore do Citizen.Wait(1000); end
    while not BJCore.Functions.IsPlayerLoaded() do Citizen.Wait(100); end
    Data.Player.PlayerData = BJCore.Functions.GetPlayerData()
    TriggerServerEvent('doorlock:server:syncDoors')
    Utilities.SetIsAreaOwner()
    Update()
end)

function Update()
    Citizen.CreateThread(function()
        while true do
            local plyPed = PlayerPedId()
            local sleep = 250
            if Data.Current.Area ~= nil then
                sleep = 25
                local plyPos = GetEntityCoords(plyPed)
                local doors = Data.Current.Doors
                local area = Data.Current.Area
                for i = 1, #doors do
                    if Utilities.DistanceCheck(plyPos, doors[i].textPos, doors[i].unlockDistance) then
                        sleep = 4
                        if doors[i].doubleDoor then
                            if doors[i].isLocked then
                                if Utilities.CheckAccess(Data.Player.PlayerData.job, doors[i].jobs) then
                                    BJCore.Functions.DrawText3D(doors[i].textPos.x, doors[i].textPos.y, doors[i].textPos.z, Config.JobLocked, 0.7)
                                else
                                    BJCore.Functions.DrawText3D(doors[i].textPos.x, doors[i].textPos.y, doors[i].textPos.z, Config.Locked, 0.7)
                                end
                            else
                                if Utilities.CheckAccess(Data.Player.PlayerData.job, doors[i].jobs) then
                                    BJCore.Functions.DrawText3D(doors[i].textPos.x, doors[i].textPos.y, doors[i].textPos.z, Config.JobUnlocked, 0.7)
                                else
                                    BJCore.Functions.DrawText3D(doors[i].textPos.x, doors[i].textPos.y, doors[i].textPos.z, Config.Unlocked, 0.7)
                                end
                            end
                            if IsControlJustReleased(1, 38) then
                                if Utilities.CheckAccess(Data.Player.PlayerData.job, doors[i].jobs) then
                                    Utilities.Anim.Start(Config.RemoteAnim, plyPed, false)
                                    if not doors[i].isLocked then
                                        local info = {pos = doors[i].doorPos, dist = doors[i].unlockDistance, model = doors[i].doorModel}
                                        local door1 = nil
                                        local door2 = nil
                                        if type(doors[i].doorModel) == 'table' then
                                            door1 = Utilities.AssignDoors(info, true, 1)
                                            door2 = Utilities.AssignDoors(info, true, 2)
                                        else
                                            door1 = Utilities.AssignDoors(info, false, 1)
                                            door2 = Utilities.AssignDoors(info, false, 2)
                                        end
                                        Data.Utilities.Active = true
                                        local lockCount = 0
                                        while Data.Utilities.Active do
                                            Citizen.Wait(1)
                                            lockCount = lockCount + 1
                                            local currentHeading1 = GetEntityHeading(door1)
                                            local rounded1 = Utilities.RoundNumber(currentHeading1, 0)
                                            local currentHeading2 = GetEntityHeading(door2)
                                            local rounded2 = Utilities.RoundNumber(currentHeading2, 0)
                                            BJCore.Functions.DrawText3D(doors[i].textPos.x, doors[i].textPos.y, doors[i].textPos.z, Config.LockingDoor, 0.7)
                                            if lockCount >= 500 then
                                                Data.Utilities.Active = false
                                                SetEntityRotation(door1, 0, 0, doors[i].heading1)
                                                SetEntityRotation(door2, 0, 0, doors[i].heading2)
                                            end
                                            if Utilities.HeadingCheck(rounded1, doors[i].heading1)
                                                and Utilities.HeadingCheck(rounded2, doors[i].heading2)
                                                then
                                                Data.Utilities.Active = false
                                                SetEntityRotation(door1, 0, 0, doors[i].heading1)
                                                SetEntityRotation(door2, 0, 0, doors[i].heading2)
                                            end
                                        end
                                    else
                                        local timer = 20
                                        while timer ~= 0 do
                                            Citizen.Wait(1)
                                            timer = timer - 1
                                            BJCore.Functions.DrawText3D(doors[i].textPos.x, doors[i].textPos.y, doors[i].textPos.z, Config.UnlockingDoor, 0.7)
                                        end
                                    end
                                    local cDoorPos = doors[i].textPos
                                    for a = 1, #doorList do
                                        if doorList[a].location == area then
                                            for b = 1, #doorList[a].doors do
                                                if doorList[a].doors[b].textPos == cDoorPos then
                                                    doorList[a].doors[b].isLocked = not doorList[a].doors[b].isLocked
                                                    TriggerServerEvent('doorlock:server:setState', area, cDoorPos, doorList[a].doors[b].isLocked, true)
                                                    break
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        else
                            if doors[i].isLocked then
                                if Utilities.CheckAccess(Data.Player.PlayerData.job, doors[i].jobs) then
                                    BJCore.Functions.DrawText3D(doors[i].textPos.x, doors[i].textPos.y, doors[i].textPos.z, Config.JobLocked, 0.7)
                                else
                                    BJCore.Functions.DrawText3D(doors[i].textPos.x, doors[i].textPos.y, doors[i].textPos.z, Config.Locked, 0.7)
                                end
                            else
                                if Utilities.CheckAccess(Data.Player.PlayerData.job, doors[i].jobs) then
                                    BJCore.Functions.DrawText3D(doors[i].textPos.x, doors[i].textPos.y, doors[i].textPos.z, Config.JobUnlocked, 0.7)
                                else
                                    BJCore.Functions.DrawText3D(doors[i].textPos.x, doors[i].textPos.y, doors[i].textPos.z, Config.Unlocked, 0.7)
                                end
                            end
                            if IsControlJustReleased(1, 38) then
                                if Utilities.CheckAccess(Data.Player.PlayerData.job, doors[i].jobs) then
                                    Utilities.Anim.Start(Config.RemoteAnim, plyPed, false)
                                    if not doors[i].isLocked then
                                        local doorSingle = GetClosestObjectOfType(doors[i].doorPos, doors[i].unlockDistance + 0.0, doors[i].doorModel, false, false, false)
                                        if not doors[i].isGate then
                                            Data.Utilities.Active = true
                                            local lockCount = 0
                                            while Data.Utilities.Active do
                                                Citizen.Wait(1)
                                                lockCount = lockCount + 1
                                                local currentHeading = GetEntityHeading(doorSingle)
                                                local rounded = Utilities.RoundNumber(currentHeading, 0)
                                                BJCore.Functions.DrawText3D(doors[i].textPos.x, doors[i].textPos.y, doors[i].textPos.z, Config.LockingDoor, 0.7)
                                                if lockCount >= 500 then
                                                    Data.Utilities.Active = false
                                                    SetEntityRotation(doorSingle, 0, 0, doors[i].heading)
                                                end
                                                if Utilities.HeadingCheck(rounded, doors[i].heading) then
                                                    Data.Utilities.Active = false
                                                end
                                            end
                                        end
                                    else
                                        local timer = 20
                                        while timer ~= 0 do
                                            Citizen.Wait(1)
                                            timer = timer - 1
                                            BJCore.Functions.DrawText3D(doors[i].textPos.x, doors[i].textPos.y, doors[i].textPos.z, Config.UnlockingDoor, 0.7)
                                        end
                                    end
                                    local cDoorPos = doors[i].doorPos
                                    for a = 1, #doorList do
                                        if doorList[a].location == area then
                                            for b = 1, #doorList[a].doors do
                                                if doorList[a].doors[b].doorPos == cDoorPos then
                                                    doorList[a].doors[b].isLocked = not doorList[a].doors[b].isLocked
                                                    TriggerServerEvent('doorlock:server:setState', area, cDoorPos, doorList[a].doors[b].isLocked, false)
                                                    break
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end

                if Data.Current.Info and Utilities.CheckAccess('', {}) then
                    if Data.Current.Info.storageLocations and #Data.Current.Info.storageLocations > 0 then
                        for _,v in ipairs(Data.Current.Info.storageLocations) do
                            if Utilities.DistanceCheck(plyPos, v, 1.0) then
                                sleep = 4
                                BJCore.Functions.DrawText3D(v.x, v.y, v.z, '[E] ~g~Storage', 0.7)
                                if IsControlJustReleased(1, 38) then
                                    local key = "doorgroupstash_"..tostring(v.x):gsub('-', '_')..'_'..tostring(v.y):gsub('-', '_')
                                    TriggerServerEvent("inventory:server:OpenInventory", "stash", key, nil, "Storage for: "..Data.Current.Area)
                                    TriggerEvent("inventory:client:SetCurrentStash", key)
                                end
                            end
                        end
                    end
                    if Data.Current.Info.wardrobeLocations and #Data.Current.Info.wardrobeLocations > 0 then
                        for _,v in ipairs(Data.Current.Info.wardrobeLocations) do
                            if Utilities.DistanceCheck(plyPos, v, 1.0) then
                                sleep = 4
                                BJCore.Functions.DrawText3D(v.x, v.y, v.z, '[E] ~g~Wardrobe', 0.7)
                                if IsControlJustReleased(1, 38) then
                                    TriggerEvent('bj-clothing:client:openOutfitMenu')
                                    TriggerEvent('InteractSound_CL:PlayOnOne', 'Stash', 0.6)
                                end
                            end
                        end
                    end
                end
            end
            Citizen.Wait(sleep)
        end
    end)
end

RegisterNetEvent('doorlock:client:listAccessCommand')
AddEventHandler('doorlock:client:listAccessCommand', function()
    if Data.Current.Area and Data.Current.IsOwner then
        local accessMessage = 'The current list of users who can access '..Data.Current.Area..':'
        if Data.LocationAccessCache[Data.Current.Area] then
            for _,v in ipairs(Data.LocationAccessCache[Data.Current.Area]) do
                accessMessage = accessMessage..'\n'..v
            end
        end
        TriggerEvent('chatMessage', "SYSTEM", "warning", accessMessage)
    else
        BJCore.Functions.Notify("You do not have access to view or edit this location", "error")
    end
end)

RegisterNetEvent('doorlock:client:grantAccessCommand')
AddEventHandler('doorlock:client:grantAccessCommand', function(args)
    if Data.Current.Area and Data.Current.IsOwner then
        if #args > 0 then
            TriggerServerEvent('doorlock:server:grantLocationAccess', Data.Current.Area, args[1])
        else
            BJCore.Functions.Notify("You must specify a citizen id", "error")
        end
    else
        BJCore.Functions.Notify("You do not have access to view or edit this location", "error")
    end
end)

RegisterNetEvent('doorlock:client:revokeAccessCommand')
AddEventHandler('doorlock:client:revokeAccessCommand', function(args)
    if Data.Current.Area and Data.Current.IsOwner then
        if #args > 0 then
            TriggerServerEvent('doorlock:server:revokeLocationAccess', Data.Current.Area, args[1])
        else
            BJCore.Functions.Notify("You must specify a citizen id", "error")
        end
    else
        BJCore.Functions.Notify("You do not have access to view or edit this location", "error")
    end
end)

RegisterNetEvent('doorlock:client:syncLocationAccess')
AddEventHandler('doorlock:client:syncLocationAccess', function(location, access)
    Data.LocationAccessCache[location] = access
end)

RegisterNetEvent('doorlock:client:syncDoors')
AddEventHandler('doorlock:client:syncDoors', function(table, locationAccess)
    for k, v in pairs(table) do
        for m, n in pairs(v.doors) do
            doorList[k].doors[m].isLocked = n.isLocked
        end
    end
    Data.LocationAccessCache = locationAccess and locationAccess or {}
end)

RegisterNetEvent('doorlock:client:setState')
AddEventHandler('doorlock:client:setState', function(area, pos, status, doubleDoor)
    local cArea = area
    local cPos = pos
    local cStatus = status
    if doubleDoor then
        for a = 1, #doorList do
            if doorList[a].location == cArea then
                for b = 1, #doorList[a].doors do
                    if doorList[a].doors[b].textPos == cPos then
                        doorList[a].doors[b].isLocked = cStatus
                    end
                end
            end
        end
    else
        for a = 1, #doorList do
            if doorList[a].location == cArea then
                for b = 1, #doorList[a].doors do
                    if doorList[a].doors[b].doorPos == cPos then
                        doorList[a].doors[b].isLocked = cStatus
                    end
                end
            end
        end
    end
end)

RegisterNetEvent('doorlock:client:startLockpick')
AddEventHandler('doorlock:client:startLockpick', function()
    local plyPed = PlayerPedId()
	local plyPos = GetEntityCoords(plyPed)
    for a = 1, #doorList do
        if doorList[a].location == Data.Current.Area then
            for b = 1, #doorList[a].doors do
                if Utilities.DistanceCheck(plyPos, doorList[a].doors[b].textPos, Config.LockpickDistance) then
                    if doorList[a].doors[b].isLocked and doorList[a].doors[b].canPlyLockpick then
                        Data.Player.Lockpicking = true
                        TriggerEvent('bj_minigames:start', 'Lockpick', { pins = 4, timeout = 6000 }, function(data)
                            failed = false
                            TriggerServerEvent('fibheist:ChanceRemove', 'lockpick')
                            if not failed then
                                if doorList[a].doors[b].autoLock then
                                    Data.Player.Lockpicking = false
                                    local cDoorPos = doorList[a].doors[b].textPos
                                    TriggerServerEvent('doorlock:server:autoLock', Data.Current.Area, cDoorPos, doorList[a].doors[b].doubleDoor)
                                else
                                    Data.Player.Lockpicking = false
                                    local cDoorPos = doorList[a].doors[b].textPos
                                    TriggerServerEvent('doorlock:server:setState', Data.Current.Area, cDoorPos, doorList[a].doors[b].doubleDoor)
                                end
                            end
                        end, function(data)
                            TriggerServerEvent('fibheist:ChanceRemove', 'lockpick')
                        end)
                    end
                end
            end
        end
    end
end)

RegisterNetEvent('doorlock:client:disableDoor')
AddEventHandler('doorlock:client:disableDoor', function(area, door, double)
    if doorList[area].doors[door].isLocked then
        if doorList[area].doors[door].autoLock then
            local cDoorPos = doorList[area].doors[door].doorPos
            if double then cDoorPos = doorList[area].doors[door].textPos; end
            TriggerServerEvent('doorlock:server:autoLock', doorList[area].location, cDoorPos, double)
        else
            local cDoorPos = doorList[area].doors[door].doorPos
            TriggerServerEvent('doorlock:server:setState', doorList[area].location, cDoorPos, false)
        end
    end
end)

RegisterNetEvent('doorlock:client:disableDoorByName')
AddEventHandler('doorlock:client:disableDoorByName', function(area, door)
    area = FindConfigIndex(area, true, nil)
    door = FindConfigIndex(door, false, area)
    if doorList[area].doors[door].isLocked then
        if doorList[area].doors[door].autoLock then
            local cDoorPos = doorList[area].doors[door].doorPos
            if doorList[area].doors[door].doubleDoor then cDoorPos = doorList[area].doors[door].textPos; end
            TriggerServerEvent('doorlock:server:autoLock', doorList[area].location, cDoorPos, doorList[area].doors[door].doubleDoor)
        else
            local cDoorPos = doorList[area].doors[door].doorPos
            if doorList[area].doors[door].doubleDoor then cDoorPos = doorList[area].doors[door].textPos; end
            TriggerServerEvent('doorlock:server:setState', doorList[area].location, cDoorPos, false, doorList[area].doors[door].doubleDoor)
        end
    end
end)

function FindConfigIndex(name, location, key)
    local retIndex = false
    if location then
        for k,v in pairs(doorList) do
            if v.location == name then
                retIndex = k
                break
            end
        end
    else
        if key and key ~= nil then
            for k,v in pairs(doorList[key].doors) do
                if v.name == name then
                    retIndex = k
                    break
                end
            end
        end
    end
    return retIndex
end

RegisterNetEvent('BJCore:Player:SetPlayerData')
AddEventHandler('BJCore:Player:SetPlayerData', function(Player)
    Data.Player.PlayerData = Player
    Utilities.SetIsAreaOwner()
end)

RegisterNetEvent('BJCore:Client:OnJobUpdate')
AddEventHandler('BJCore:Client:OnJobUpdate', function(JobInfo)
    Data.Player.PlayerData.job = JobInfo
end)

-- RegisterCommand('devlockpick', function(source, args, raw)
--     if doorCheck() then
--         TriggerEvent('doorlock:client:startLockpick')
--     end
-- end)

function tablematch(a, b)
    return table.concat(a) == table.concat(b)
end