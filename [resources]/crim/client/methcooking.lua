function MethAwake(...)
    while not BJCore do Citizen.Wait(1000); end
    while not BJCore.Functions.IsPlayerLoaded() do Citizen.Wait(1000); end
    RequestStreamedTextureDict("commonmenu",true)
    PlayerData = BJCore.Functions.GetPlayerData()
    MethStart()
end

function MethStart(...)
    while not BJCore do Citizen.Wait(1000); end
    while not BJCore.Functions.IsPlayerLoaded() do Citizen.Wait(1000); end
    MethUpdate()
end

local randomDelay = 0 
local MissionStarted, TruckSpawned, WaypointSet, MethCook, DidNotify, SmokeActive, CookFinished, RequestCook = false, false, false, false, false, false, false, false
function MethUpdate(...)
    local noteTemplate = DrawTextTemplate()
    noteTemplate.x = 0.5
    noteTemplate.y = 0.5
    local timer = 0
    while true do
        Citizen.Wait(0)
        local plyPed = PlayerPedId()
        local plyPos = GetEntityCoords(plyPed)
        if not MissionStarted then
            local v3 = vector3(Config.MethHintLocation.x, Config.MethHintLocation.y, Config.MethHintLocation.z)
            local dist = #(plyPos - v3)
            if dist < Config.MethDrawTextDist then
                local p = Config.MethHintLocation 
                BJCore.Functions.DrawText3D(p.x,p.y,p.z, "[~r~E~s~] Knock")
                if IsControlJustPressed(0, 38) and GetGameTimer() - timer > 350 and randomDelay == 0 then
                    timer = GetGameTimer()
                    BJCore.Functions.TriggerServerCallback('MobileMeth:GetMeth', function(data)
                        if data.hasMeth and data.hasTray then 
                            TaskGoStraightToCoord(plyPed, p.x, p.y, p.z, 10.0, 10, p.w, 0.5)
                            Wait(3000)
                            ClearPedTasksImmediately(plyPed)

                            while not HasAnimDictLoaded("timetable@jimmy@doorknock@") do RequestAnimDict("timetable@jimmy@doorknock@"); Citizen.Wait(0); end
                            TaskPlayAnim( plyPed, "timetable@jimmy@doorknock@", "knockdoor_idle", 8.0, 8.0, -1, 4, 0, 0, 0, 0 )     
                            Citizen.Wait(0)
                            while IsEntityPlayingAnim(plyPed, "timetable@jimmy@doorknock@", "knockdoor_idle", 3) do Citizen.Wait(0); end          

                            Citizen.Wait(1000)
                            
                            TriggerEvent("chatMessage", "System", "warning", "You notice a small piece of paper slide under the door. It reads - We'll be in touch")
                            ClearPedTasksImmediately(plyPed)
                            RemoveAnimDict("timetable@jimmy@doorknock@")

                            local randNum = math.random(1,#Config.MethTruckLocations)
                            local spawnLoc = Config.MethTruckLocations[randNum]
                            local nearStreet = GetStreetNameFromHashKey(GetStreetNameAtCoord(spawnLoc.x,spawnLoc.y,spawnLoc.z))

                            randomDelay = math.random(20000, 45000) 
                            SetTimeout(randomDelay, function()
                                TriggerServerEvent("bj-log:server:CreateLog", "crim", "Money Wash", "green", "**"..PlayerData.name .. "** has requested money wash hint.")
                                TriggerServerEvent('phone:server:sendNewMail', {
                                    sender = "Unknown",
                                    subject = "Re: Breaking Bad",
                                    message = "Find the truck near "..nearStreet..".\nDon't be late",
                                })
                                randomDelay = 0
                                MissionStarted = {
                                    TruckLoc = spawnLoc,
                                    Dropoff  = Config.MethDropoffLocations[math.random(1,#Config.MethDropoffLocations)],
                                    Count    = 0,
                                }

                                SetNewWaypoint(spawnLoc.x,spawnLoc.y)                                
                            end)
                        end
                    end)
                end
            else
                if dist > 20 then Citizen.Wait(1000); end     
            end
        else
            if not TruckSpawned and MissionStarted then
                local dist = #(plyPos.xyz - MissionStarted.TruckLoc.xyz)
                if dist < Config.MethTruckSpawnDist then
                    local randNum = math.random(1,#Config.MethTruckModels)
                    local vehModel = Config.MethTruckModels[randNum]

                    local hash = GetHashKey(vehModel)
                    while not HasModelLoaded(hash) do RequestModel(hash); Citizen.Wait(0); end

                    local pos = MissionStarted.TruckLoc
                    BJCore.Functions.SpawnVehicle(hash, function(cbVeh)
                        exports['legacyfuel']:SetFuel(cbVeh,100)
                        SetEntityAsMissionEntity(cbVeh, true, true)
                        SetNetworkIdCanMigrate(VehToNet(cbVeh), true)	      
                        local plate = "BRBA " .. math.random(111,999)
                        SetVehicleNumberPlateText(cbVeh, plate)
                        TriggerEvent('keys:addNew', cbVeh, GetVehicleNumberPlateText(cbVeh))
                        TruckSpawned = cbVeh
                    end, pos, true)
                end
            else
                if IsPedInAnyVehicle(plyPed) then
                    local veh = GetVehiclePedIsIn(plyPed,false)
                    if veh == TruckSpawned then
                        if not RequestCook then
                            RequestCook = true
                            BJCore.Functions.Notify('Find a passenger to cook the meth in the back','primary')
                            TriggerServerEvent("bj-log:server:CreateLog", "crim", "Meth cooking", "black", "**"..PlayerData.name.."** has located meth cooking vehicle and is awaiting cook.")
                        end

                        if not MethCook then
                            local foundCook = false
                            for k=1,4,1 do
                                if not foundCook and not IsVehicleSeatFree(TruckSpawned,k) then 
                                    local passenger = GetPedInVehicleSeat(TruckSpawned,k)
                                    if passenger ~= -1 and passenger ~= PlayerPedId() and DoesEntityExist(passenger) then foundCook = passenger; end
                                end
                            end
                            if foundCook and foundCook ~= PlayerPedId() then
                                if GetEntitySpeed(TruckSpawned) * 2.236936 > Config.MethMinSpeedForCook then 
                                    BJCore.Functions.Notify('Your passenger has started cooking the meth','primary')
                                    MethCook = NetworkGetPlayerIndexFromPed(foundCook)
                                    TriggerServerEvent('MobileMeth:BeginCooking', GetPlayerServerId(MethCook))
                                    TriggerServerEvent("bj-log:server:CreateLog", "crim", "Meth cooking", "black", "**"..PlayerData.name.."** has found a cook ("..GetPlayerName(GetPlayerServerId(MethCook))..") and meth cook run has started.")
                                else
                                    if not DidNotify then BJCore.Functions.Notify('Drive above 15MPH to begin the cook','error'); DidNotify = true; end
                                end
                            end
                        else
                            if not SmokeActive then
                                TriggerServerEvent('MobileMeth:SyncSmoke', NetworkGetNetworkIdFromEntity(TruckSpawned))
                                SmokeActive = true
                            end

                            if CookFinished then
                                if not WaypointSet then
                                    DeleteWaypoint()
                                    Wait(10)
                                    WaypointSet = true
                                    SetNewWaypoint(MissionStarted.Dropoff.x, MissionStarted.Dropoff.y)
                                end                                
                                local dist = #(plyPos - MissionStarted.Dropoff)
                                if dist < Config.MethDrawTextDist *2 then
                                    local pos = MissionStarted.Dropoff
                                    BJCore.Functions.DrawText3D(pos.x,pos.y,pos.z, "[~r~E~s~] Complete cook")
                                    if dist < Config.MethDrawTextDist and IsControlJustPressed(0, 38) and GetGameTimer() - timer > 150 then
                                        timer = GetGameTimer()
                                        local vehicle = TruckSpawned
                                        local maxPassengers = GetVehicleMaxNumberOfPassengers(vehicle)
                                        for seat = -1,maxPassengers-1,1 do
                                            local ped = GetPedInVehicleSeat(vehicle,seat)
                                            if ped and ped ~= 0 then TaskLeaveVehicle(ped,vehicle,16); end
                                        end
                                        TriggerServerEvent('MobileMeth:RewardPlayers', GetPlayerServerId(MethCook))
                                        TriggerServerEvent('MobileMeth:RemoveTruck',  NetworkGetNetworkIdFromEntity(TruckSpawned))
                                        Citizen.Wait(0)                    
                                        DeleteVehicle(vehicle)
                                        CookFinished = false
                                        MissionStarted = false
                                        TruckSpawned = false
                                        WaypointSet = false
                                        MethCook = false
                                        SmokeActive = false
                                        DidNotify = false
                                        RequestCook = false
                                        BJCore.Functions.Notify('You have completed the cooking proccess','primary')
                                    end              
                                else
                                    local veh = false
                                    if IsPedInAnyVehicle(PlayerPedId()) then veh = GetVehiclePedIsIn(PlayerPedId(),false); end
                                    if not veh or veh ~= TruckSpawned then
                                        TriggerServerEvent('MobileMeth:RemoveTruck',  NetworkGetNetworkIdFromEntity(TruckSpawned))
                                        Citizen.Wait(0)                    
                                        DeleteVehicle(vehicle)
                                        MissionStarted = false
                                        TruckSpawned = false
                                        WaypointSet = false
                                        MethCook = false
                                        SmokeActive = false
                                        DidNotify = false
                                        RequestCook = false
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

local Driver, Truck, CurrentlyStopped, CanCont = false, false, false, false
function MethBeginCooking(driver)
    if MissionStarted or Driver then BJCore.Functions.Notify('You already have a mission active','error'); return; end
    BJCore.Functions.Notify('You started cooking the meth','primary')
    Driver = driver
    Truck = GetVehiclePedIsIn(PlayerPedId())
    local doCont = true
    Citizen.CreateThread(function(...)
        while Driver do
            Citizen.Wait(0)
            local doBreak,driverMsg
            local plyPed = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(plyPed,false)
            if not IsPedInAnyVehicle(plyPed) then 
                doBreak = "You bailed on the driver" 
                driverMsg = "The cook bailed on you"
            else
                if GetEntitySpeed(vehicle) * 2.236936 < Config.MethMinSpeedForCook then
                    if not CurrentlyStopped then
                        CanCont = false
                        CurrentlyStopped = true
                        Citizen.CreateThread(function(...)
                            local timer = GetGameTimer()
                            while (GetGameTimer() - timer) < Config.MethMaxVehicleStopTime * 1000 do Citizen.Wait(0); end
                            if GetEntitySpeed(vehicle) * 2.236936 < Config.MethMinSpeedForCook then 
                                CanCont = true
                                --doBreak = "The vehicle was driving too slow to continue." 
                                --driverMsg = "The vehicle was driving too slow to continue." 
                                --BJCore.Functions.Notify('Somebody reported you! Better get moving','primary')
                                Citizen.Wait(1000)
                                TriggerServerEvent('MF_Trackables:Notify','Suspicous vehicle reported', GetEntityCoords(PlayerPedId()),'police','civreport')
                                TriggerServerEvent('MobileMeth:NotifyPolice', GetEntityCoords(PlayerPedId()))
                            else
                                CanCont = true
                                CurrentlyStopped = false
                            end
                        end)
                    end
                else          
                    if CanCont then CurrentlyStopped = false; end
                end
            end
            if doBreak then
                TriggerServerEvent("bj-log:server:CreateLog", "crim", "Meth cooking", "black", "**"..PlayerData.name.."** (cook) bailed on driver during meth cooking process. Mission reset")
                BJCore.Functions.Notify(doBreak,'error')
                TriggerServerEvent('MobileMeth:RemoveTruck', NetworkGetNetworkIdFromEntity(Truck))
                TriggerServerEvent('MobileMeth:FinishCook', Driver, false, driverMsg)

                Driver = false   
                Truck = false
                doCont = false
                CurrentlyStopped = false
                TriggerEvent("mythic_progbar:client:cancel")
            end
        end
    end)
    
    exports['mythic_progbar']:Progress({
        name = "meth_prep",
        duration = math.floor(Config.MethCookTimerA * 60 * 1000),
        label = "Preparing ingredients",
        useWhileDead = false,
        canCancel = false,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
    })
    Citizen.Wait(math.floor(Config.MethCookTimerA * 60 * 1000))

    if doCont then
        exports['mythic_progbar']:Progress({
            name = "meth_cook",
            duration = math.floor(Config.MethCookTimerB * 60 * 1000),
            label = "Cooking meth",
            useWhileDead = false,
            canCancel = false,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            },
        })
        Citizen.Wait(math.floor(Config.MethCookTimerB * 60 * 1000))
    else return; end

    if doCont then
        exports['mythic_progbar']:Progress({
            name = "meth_set",
            duration = math.floor(Config.MethCookTimerC * 60 * 1000),
            label = "Allowing meth to set",
            useWhileDead = false,
            canCancel = false,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            },
        })
        Citizen.Wait(math.floor(Config.MethCookTimerC * 60 * 1000))
    else return; end

    if doCont then
        exports['mythic_progbar']:Progress({
            name = "meth_pack",
            duration = math.floor(Config.MethCookTimerD * 60 * 1000),
            label = "Packaging meth",
            useWhileDead = false,
            canCancel = false,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            },
        })
        Citizen.Wait(math.floor(Config.MethCookTimerD * 60 * 1000))
    else return; end

    if doCont then
        BJCore.Functions.Notify('You finished the cook','primary')
        TriggerServerEvent('MobileMeth:FinishCook', Driver, true, "The cook has finished. Go to marked location to complete run")
        TriggerServerEvent("bj-log:server:CreateLog", "crim", "Meth cooking", "black", "**"..PlayerData.name.."** (cook) has completed meth cooking proccess. Awaiting run completion from driver")
        Driver = false
    end
end

SmokingTrucks = {}
function MethSyncSmoke(netId)
    SmokingTrucks[netId] = false
end

SmokeSpawnDist = 50.0
function MethSmokeTracker(...)
    while true do
        Citizen.Wait(1000)
        local plyPed = PlayerPedId()
        local plyPos = GetEntityCoords(plyPed)
        local removeList = {}
        for k,v in pairs(SmokingTrucks) do
            local doesExist = NetworkDoesEntityExistWithNetworkId(k)
            local ent
            if doesExist then ent = NetworkGetEntityFromNetworkId(k); end
            if not v then
                if DoesEntityExist(ent) then
                    local pos = GetEntityCoords(ent)
                    local dist = #(pos - plyPos)
                    if dist < SmokeSpawnDist then
                        print("[ MobileMeth ] Added smoking truck to the list (in range, should begin smoking).")
                        if not HasNamedPtfxAssetLoaded("core") then RequestNamedPtfxAsset("core"); end
                        while not HasNamedPtfxAssetLoaded("core") do Citizen.Wait(0); end    
                        SetPtfxAssetNextCall("core")
                        StartNetworkedParticleFxLoopedOnEntity("exp_grd_grenade_smoke", ent, 0.0,0.0,0.5, 0.0,0.0,0.0, 1.0, false,false,false)
                        SmokingTrucks[k] = true
                    end
                end
            else
                if (not ent and SmokingTrucks[k]) or (ent and not DoesEntityExist(ent)) then 
                    print("[ MobileMeth ] Removed smoking truck from list (out of range).")
                    SmokingTrucks[k] = false
                end
            end
        end
    end
end

Citizen.CreateThread(function(...) MethSmokeTracker(...); end)

function MethFinishCooking(result,msg)
    if result then
        BJCore.Functions.Notify(msg,'primary')
        CookFinished = true
    else
        BJCore.Functions.Notify(msg,'primary')
        MethCook = false
        DidNotify = false
    end
end

function MethNotifyPolice(pos,msg)
    local blip = AddBlipForRadius(pos.x, pos.y, pos.z, 50.0)
    SetBlipHighDetail(blip, true)
    SetBlipColour(blip, 1)
    SetBlipAlpha (blip, 80)
    RemoveBlip(blip)
end

function MethRemoveTruck(netId)
    if not netId then return; end
    SmokingTrucks[netId] = nil
    Citizen.CreateThread(function()
        local doesExist = NetworkDoesEntityExistWithNetworkId(netId)
        local ent
        if doesExist then
            Citizen.Wait(60000)
            ent = NetworkGetEntityFromNetworkId(netId)
            DeleteVehicle(ent)
            DeleteEntity(ent)
        end
    end)
end

function DrawTextTemplate(text,x,y,font,scale1,scale2,colour1,colour2,colour3,colour4,wrap1,wrap2,centre,outline,dropshadow1,dropshadow2,dropshadow3,dropshadow4,dropshadow5,edge1,edge2,edge3,edge4,edge5)
    return {
        text         =                    "",
        x            =                    -1,
        y            =                    -1,
        font         =  font         or    6,
        scale1       =  scale1       or  0.5,
        scale2       =  scale2       or  0.5,
        colour1      =  colour1      or  255,
        colour2      =  colour2      or  255,
        colour3      =  colour3      or  255,
        colour4      =  colour4      or  255,
        wrap1        =  wrap1        or  0.0,
        wrap2        =  wrap2        or  1.0,
        centre       =  ( type(centre) ~= "boolean" and true or centre ),
        outline      =  outline      or    1,
        dropshadow1  =  dropshadow1  or    2,
        dropshadow2  =  dropshadow2  or    0,
        dropshadow3  =  dropshadow3  or    0,
        dropshadow4  =  dropshadow4  or    0,
        dropshadow5  =  dropshadow5  or    0,
        edge1        =  edge1        or  255,
        edge2        =  edge2        or  255,
        edge3        =  edge3        or  255,
        edge4        =  edge4        or  255,
        edge5        =  edge5        or  255,
    }
end
RegisterNetEvent('MobileMeth:BeginCooking')
AddEventHandler('MobileMeth:BeginCooking', function(...) MethBeginCooking(...); end)
RegisterNetEvent('MobileMeth:FinishCook')
AddEventHandler('MobileMeth:FinishCook', function(...) MethFinishCooking(...); end)
RegisterNetEvent('MobileMeth:SyncSmoke')
AddEventHandler('MobileMeth:SyncSmoke', function(...) MethSyncSmoke(...); end)
RegisterNetEvent('MobileMeth:NotifyCops')
AddEventHandler('MobileMeth:NotifyCops', function(pos,msg) Citizen.CreateThread(function() MethNotifyPolice(pos,msg); end); end)
RegisterNetEvent('MobileMeth:RemoveSmoke')
AddEventHandler('MobileMeth:RemoveSmoke', function(netId) MethRemoveTruck(netId); end)
Citizen.CreateThread(function(...) MethAwake(...); end)