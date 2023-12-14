local offroadVehicles = {
    "bifta",
    "blazer",
    "brawler",
    "dubsta3",
    "dune",
    "rebel2",
    "sandking",
    "trophytruck",
    "sanchez",
    "sanchez2",
    "blazer",
    "enduro",
    "bf400",
    "ramleg" 
}

local offroadbikes = {
    "sanchez",
    "sanchez2"
}

local currentVehicle = nil
local carsEnabled = {}
local airtime = 0
local offroadTimer = 0
local airtimeCoords = GetEntityCoords(PlayerPedId())
local heightPeak = 0
local lasthighPeak = 0
local highestPoint = 0
local zDownForce = 0
local veloc = GetEntityVelocity(veh)
local offroadVehicle = false

BJCore = nil
Citizen.CreateThread(function(...) while BJCore == nil do TriggerEvent("BJCore:GetObject", function(obj) BJCore = obj end); Citizen.Wait(1000); end; end)

local seatbelt = false

function downgrade(veh,power,offroad)
    if carsEnabled["" .. veh .. ""] == nil then 
        return 
    end     
    if offroad then 
        power = power + 0.5
        if IsThisModelABike(GetEntityModel(veh)) then
            power = power + 0.3
        else
            power = power + 0.3
        end

    end
    power = math.ceil(power * 10)

    local factor = math.random(3+power) / 10


    if factor > 0.7 then
        if IsThisModelABike(GetEntityModel(veh)) then
            if not offroad then
                factor = 0.7
            end
        else
            if not offroad then
                factor = 0.7
            else
                factor = 0.8
            end
            
        end
    end

    if factor < 0.4 then
        if not offroad then
            factor = 0.25
        else
            factor = 0.4
        end
    end

    if carsEnabled["" .. veh .. ""] == nil then return end
    SetVehicleHandlingFloat(veh, 'CHandlingData', 'fInitialDriveMaxFlatVel', carsEnabled["" .. veh .. ""]["fInitialDriveMaxFlatVel"] * factor)
    --SetVehicleHandlingFloat(veh, 'CHandlingData', 'fSteeringLock', carsEnabled["" .. veh .. ""]["fSteeringLock"] * factor)
    SetVehicleHandlingFloat(veh, 'CHandlingData', 'fTractionLossMult', carsEnabled["" .. veh .. ""]["fTractionLossMult"] * factor)
    SetVehicleHandlingFloat(veh, 'CHandlingData', 'fLowSpeedTractionLossMult', carsEnabled["" .. veh .. ""]["fLowSpeedTractionLossMult"] * factor)
    SetVehicleEnginePowerMultiplier(veh,factor)
    SetVehicleEngineTorqueMultiplier(veh,factor)

end
function resetdowngrade(veh)
    if carsEnabled["" .. veh .. ""] == nil then 
        return 
    end

    SetVehicleHandlingFloat(veh, 'CHandlingData', 'fInitialDriveMaxFlatVel', carsEnabled["" .. veh .. ""]["fInitialDriveMaxFlatVel"])
    SetVehicleHandlingFloat(veh, 'CHandlingData', 'fSteeringLock', carsEnabled["" .. veh .. ""]["fSteeringLock"])
    SetVehicleHandlingFloat(veh, 'CHandlingData', 'fTractionLossMult', carsEnabled["" .. veh .. ""]["fTractionLossMult"])
    SetVehicleHandlingFloat(veh, 'CHandlingData', 'fLowSpeedTractionLossMult', carsEnabled["" .. veh .. ""]["fLowSpeedTractionLossMult"])
    SetVehicleEnginePowerMultiplier(veh,0.7)
    SetVehicleEngineTorqueMultiplier(veh,0.7)

end

function stallVehicle()
    local veh = GetVehiclePedIsIn(PlayerPedId(),false)
    TriggerEvent("vehiclelock:client:vehicleStall", true)
    SetVehicleEngineOn(veh, false, true, true)
    SetVehicleEngineHealth(veh, GetVehicleEngineHealth(veh)-200.0)
    local stalltime = math.random(3,8)
    BJCore.Functions.PersistentNotify("start", "stallvehicle", "You have stalled the vehicle", "error")
    local lastTime = GetGameTimer()
    Citizen.CreateThread(function()
        while stalltime ~= 0 do
            EnableStallWarningSounds(veh, true)
            if veh and veh ~= -1 then
                if IsVehicleEngineStarting(veh) then
                    Wait(300)
                    SetVehicleEngineOn(veh, false, true, true)
                end
            end
            if GetGameTimer() - lastTime > 1000 then
                lastTime = GetGameTimer()
                stalltime = stalltime - 1
            end
            Citizen.Wait(0)
        end
        TriggerEvent("vehiclelock:client:vehicleStall", false)
        BJCore.Functions.PersistentNotify("end", "stallvehicle")
    end)
end

function carCrash()
    local wheels = {0,1,4,5}
    for i=1, math.random(4) do
        local wheel = math.random(#wheels)
        SetVehicleTyreBurst(currentVehicle, wheels[wheel], true, 1000)
        table.remove(wheels, wheel)
    end
    SetVehicleEngineHealth(currentVehicle, 0)
    SetVehicleEngineOn(currentVehicle, false, true, true)
    lastCurrentVehicleSpeed = 0.0
    lastCurrentVehicleBodyHealth = 0.0
end

function ejectionLUL()
    local veh = GetVehiclePedIsIn(PlayerPedId(),false)
    local coords = GetOffsetFromEntityInWorldCoords(veh, 1.0, 0.0, 1.0)
    SetEntityCoords(PlayerPedId(),coords)
    Citizen.Wait(1)
    SetPedToRagdoll(PlayerPedId(), 5511, 5511, 0, 0, 0, 0)
    SetEntityVelocity(PlayerPedId(), veloc.x*4,veloc.y*4,veloc.z*4)
    local ejectspeed = math.ceil(GetEntitySpeed(PlayerPedId()) * 8)
    SetEntityHealth(PlayerPedId(), (GetEntityHealth(PlayerPedId()) - ejectspeed) )
end

function sendServerEventForPassengers(event, value, plate)
    local player = PlayerPedId()
    for i=-1, GetVehicleMaxNumberOfPassengers(currentVehicle)-1 do
        local ped = GetPedInVehicleSeat(currentVehicle, i)
        if ped ~= player and ped ~= 0 and ped ~= nil then
            local targetPlayer = NetworkGetPlayerIndexFromPed(ped)
            if targetPlayer and targetPlayer > 0 then
                TriggerServerEvent(event, GetPlayerServerId(targetPlayer), value, plate)
            end
        end
    end
end

RegisterNetEvent("carhud:ejection:client")
AddEventHandler("carhud:ejection:client",function(value, plate)
    if GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId())) == nil then return; end
    if GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId())) ~= plate then return; end
    veloc = value
    if seatbelt then
        if math.random(10) > 8 then
            ejectionLUL()
        end
    else
        if math.random(10) > 4 then
            ejectionLUL()
        end
    end
end)

RegisterNetEvent("carhud:seatbelt:client")
AddEventHandler("carhud:seatbelt:client",function(bool)
    seatbelt = bool
end)

Citizen.CreateThread(function()
    local firstDrop = GetEntityVelocity(PlayerPedId())
    local lastentSpeed = 0
    while true do

        Citizen.Wait(1)

        if IsPedInAnyVehicle(PlayerPedId(), false) then

            local veh = GetVehiclePedIsIn(PlayerPedId(),false)
            if not invehicle and not IsThisModelABike(GetEntityModel(veh)) then
                invehicle = true
            end
            
            local bicycle = IsThisModelABicycle(GetEntityModel(veh))

            if carsEnabled["" .. veh .. ""] == nil and not bicycle then

                local fSteeringLock = GetVehicleHandlingFloat(veh, 'CHandlingData', 'fSteeringLock')

                -- fSteeringLock = math.ceil((fSteeringLock * 0.8)) + 0.1 -- fSteeringLock * 0.6
                -- SetVehicleHandlingFloat(veh, 'CHandlingData', 'fSteeringLock', fSteeringLock)
                -- SetVehicleHandlingField(veh, 'CHandlingData', 'fSteeringLock', fSteeringLock)

                local fInitialDriveMaxFlatVel = GetVehicleHandlingFloat(veh, 'CHandlingData', 'fInitialDriveMaxFlatVel')
                local model = GetEntityModel(veh)
                if not IsThisModelACar(model) and not IsThisModelAQuadbike(model) then

                    local fTractionCurveMin = GetVehicleHandlingFloat(veh, 'CHandlingData', 'fTractionCurveMin')

                    fTractionCurveMin = fTractionCurveMin * 0.7
                    SetVehicleHandlingFloat(veh, 'CHandlingData', 'fTractionCurveMin', fTractionCurveMin)
                    SetVehicleHandlingField(veh, 'CHandlingData', 'fTractionCurveMin', fTractionCurveMin)   

                    local fTractionCurveMax = GetVehicleHandlingFloat(veh, 'CHandlingData', 'fTractionCurveMax')

                    fTractionCurveMax = fTractionCurveMax * 0.6 --0.6
                    SetVehicleHandlingFloat(veh, 'CHandlingData', 'fTractionCurveMax', fTractionCurveMax)
                    SetVehicleHandlingField(veh, 'CHandlingData', 'fTractionCurveMax', fTractionCurveMax)

                    local fInitialDriveForce = GetVehicleHandlingFloat(veh, 'CHandlingData', 'fInitialDriveForce')
                    fInitialDriveForce = fInitialDriveForce * 2.2
                    SetVehicleHandlingFloat(veh, 'CHandlingData', 'fInitialDriveForce', fInitialDriveForce)

                    local fBrakeForce = GetVehicleHandlingFloat(veh, 'CHandlingData', 'fBrakeForce')
                    fBrakeForce = fBrakeForce * 1.0 -- 1.4
                    SetVehicleHandlingFloat(veh, 'CHandlingData', 'fBrakeForce', fBrakeForce)
                    
                    SetVehicleHandlingFloat(veh, 'CHandlingData', 'fSuspensionReboundDamp', 5.000000)
                    SetVehicleHandlingField(veh, 'CHandlingData', 'fSuspensionReboundDamp', 5.000000)

                    SetVehicleHandlingFloat(veh, 'CHandlingData', 'fSuspensionCompDamp', 5.000000)
                    SetVehicleHandlingField(veh, 'CHandlingData', 'fSuspensionCompDamp', 5.000000)

                    SetVehicleHandlingFloat(veh, 'CHandlingData', 'fSuspensionForce', 22.000000)
                    SetVehicleHandlingField(veh, 'CHandlingData', 'fSuspensionForce', 22.000000)

                    SetVehicleHandlingFloat(veh, 'CHandlingData', 'fCollisionDamageMult', 2.500000)
                    SetVehicleHandlingFloat(veh, 'CHandlingData', 'fEngineDamageMult', 0.120000)
                else

                    fSteeringLock = math.ceil((fSteeringLock * 0.6)) + 0.1 -- fSteeringLock * 0.6
                    SetVehicleHandlingFloat(veh, 'CHandlingData', 'fSteeringLock', fSteeringLock)
                    SetVehicleHandlingField(veh, 'CHandlingData', 'fSteeringLock', fSteeringLock)

                    local fBrakeForce = GetVehicleHandlingFloat(veh, 'CHandlingData', 'fBrakeForce')
                    fBrakeForce = fBrakeForce * 1.2 -- 0.5 new 1.5
                    SetVehicleHandlingFloat(veh, 'CHandlingData', 'fBrakeForce', fBrakeForce)

                    local fInitialDriveForce = GetVehicleHandlingFloat(veh, 'CHandlingData', 'fInitialDriveForce')
                    print(fInitialDriveForce)
                    if fInitialDriveForce < 0.289 then
                        print("buff shit vh")
                        fInitialDriveForce = fInitialDriveForce * 1.05
                        SetVehicleHandlingFloat(veh, 'CHandlingData', 'fInitialDriveForce', fInitialDriveForce)
                    else
                        print("nerf good vh")
                        fInitialDriveForce = fInitialDriveForce * 0.7
                        SetVehicleHandlingFloat(veh, 'CHandlingData', 'fInitialDriveForce', fInitialDriveForce)
                    end

                    local fInitialDragCoeff = GetVehicleHandlingFloat(veh, 'CHandlingData', 'fInitialDragCoeff')
                    fInitialDragCoeff = fInitialDragCoeff * 0.3
                    SetVehicleHandlingFloat(veh, 'CHandlingData', 'fInitialDragCoeff', fInitialDragCoeff)                                   

                    --print(fInitialDriveForce .. " " .. GetVehicleHandlingFloat(veh, 'CHandlingData', 'fInitialDriveForce'))
                    SetVehicleHandlingFloat(veh, 'CHandlingData', 'fEngineDamageMult', 0.100000)
                    SetVehicleHandlingFloat(veh, 'CHandlingData', 'fCollisionDamageMult', 2.900000)

                end
            
                SetVehicleHandlingFloat(veh, 'CHandlingData', 'fDeformationDamageMult', 1.000000)

                SetVehicleHasBeenOwnedByPlayer(veh,true)
                carsEnabled["" .. veh .. ""] = { 
                    ["fInitialDriveMaxFlatVel"] = fInitialDriveMaxFlatVel, 
                    ["fSteeringLock"] = GetVehicleHandlingFloat(veh, 'CHandlingData', 'fSteeringLock'), 
                    ["fTractionLossMult"] = GetVehicleHandlingFloat(veh, 'CHandlingData', 'fTractionLossMult'), 
                    ["fLowSpeedTractionLossMult"] = GetVehicleHandlingFloat(veh, 'CHandlingData', 'fLowSpeedTractionLossMult') 
                }
            else
                Wait(1000)
            end


            if GetPedInVehicleSeat(veh, -1) == PlayerPedId() then
                --print("driver")
                local coords = GetEntityCoords(PlayerPedId())
                local roadtest2 = IsPointOnRoad(coords.x, coords.y, coords.z, veh)
              --  roadtest, endResult, outHeading = GetClosestVehicleNode(coords.x, coords.y, coords.z,  1, 0, -1)
             --   endDistance = #(vector3(endResult.x, endResult.y, endResult.z) - GetEntityCoords(PlayerPedId()))   
                local myspeed = GetEntitySpeed(veh) * 3.6
                local xRot = GetEntityUprightValue(veh)
                if not roadtest2 then
                    if (xRot < 0.90) then
                        offroadTimer = offroadTimer + (1 - xRot)
                    elseif xRot > 0.90 then
                        if offroadTimer < 1 then
                            offroadTimer = 0
                        else
                            offroadTimer = offroadTimer - xRot
                            resetdowngrade(veh)
                        end                         
                    end
                elseif offroadTimer > 0 or offroadTimer == 0 then
                    offroadTimer = 0
                    offroadVehicle = false 
                    resetdowngrade(veh)
                end

                if offroadTimer > 5 and not IsPedInAnyHeli(PlayerPedId()) and not IsPedInAnyBoat(PlayerPedId()) then  
           
                    for i = 1, #offroadVehicles do
                        if IsVehicleModel( GetVehiclePedIsUsing(PlayerPedId()), GetHashKey(offroadVehicles[i]) ) then
                            offroadVehicle = true

                        end
                    end

                    if not offroadVehicle then
                        if IsThisModelABike(GetEntityModel(veh)) then
                            downgrade(veh,0.12 - xRot / 10,offroadVehicle)  
                        else
                            downgrade(veh,0.20 - xRot / 10,offroadVehicle)
                        end
                    else
                        downgrade(veh,0.35 - xRot / 10,offroadVehicle)
                    end
                end
            else
                --print("not driver fam")
                Wait(1000)
            end
        else
            --print("not in veh fam")
            if invehicle or seatbelt then
                invehicle = false
                seatbelt = false
            end
            Citizen.Wait(1500)
        end
        --print("airtime: "..airtime)
        --print("seatb? "..tostring(seatbelt))
    end
end)

Citizen.CreateThread(function()
    local firstDrop = GetEntityVelocity(PlayerPedId())
    local lastentSpeed = 0    
    while true do
        Citizen.Wait(0)
        if IsPedInAnyVehicle(PlayerPedId(), false) then
            local veh = GetVehiclePedIsIn(PlayerPedId(),false)        
            if GetPedInVehicleSeat(veh, -1) == PlayerPedId() then
                if IsEntityInAir(veh) then
                    --print("in air fam")
                    firstDrop = GetEntityVelocity(veh)
                    lastentSpeed = math.ceil(GetEntitySpeed(GetVehiclePedIsUsing(PlayerPedId())))
                    if airtime == 1 then
                        heightPeak = 0
                        lasthighPeak = 0                        
                        airtimeCoords = GetEntityCoords(veh)
                        lasthighPeak = airtimeCoords.z
                    else
                        local AirCurCoords = GetEntityCoords(veh)
                        heightPeak = AirCurCoords.z
                        if tonumber(heightPeak) > tonumber(lasthighPeak) and airtime ~= 0 then
                            lasthighPeak = heightPeak
                            highestPoint = heightPeak - airtimeCoords.z
                        end
                    end
                    --print("airtime: "..airtime)
                    airtime = airtime + 1
                elseif airtime > 0 then
                    --print("airtime: "..airtime)
                    if airtime > 110 then
                        Citizen.Wait(333)
                        local landingCoords = GetEntityCoords(veh)  
                        local landingfactor = landingCoords.z - airtimeCoords.z     
                        local momentum = GetEntityVelocity(veh)
                        highestPoint = highestPoint - landingfactor

                        highestPoint = highestPoint * 0.55

                        airtime = math.ceil(airtime * highestPoint)

                        local xdf = 0
                        local ydf = 0
                        if momentum.x < 0 then
                            xdf = momentum.x
                            xdf = math.ceil(xdf - (xdf * 2))
                        else
                            xdf = momentum.x
                        end

                        if momentum.y < 0 then
                            ydf = momentum.y
                            ydf = math.ceil(ydf - (ydf * 2))
                        else
                            ydf = momentum.y
                        end

                        zdf = momentum.z 
                        lastzvel = firstDrop.z
                        --print("IMPACT Z" .. zdf)
                        --print("LAST DROP Z" .. lastzvel)

                        zdf = zdf - lastzvel
                        local dirtBike = false
                        for i = 1, #offroadbikes do
                            if IsVehicleModel(GetVehiclePedIsUsing(PlayerPedId()), GetHashKey(offroadbikes[i], _r)) then
                                dirtBike = true
                            end
                        end
                        if dirtBike then
                            airtime = airtime - 200
                        end

                        if IsThisModelABicycle(GetEntityModel(GetVehiclePedIsUsing(PlayerPedId()))) then
                            --print(airtime .. " what " .. zdf)
                            local ohshit = math.ceil((zdf * 200))
                            local entSpeed = math.ceil( GetEntitySpeed(GetVehiclePedIsUsing(PlayerPedId())) * 1.35 )
                            --print("speed - " .. entSpeed)

                            if airtime > 550 then
                                if airtime > 550 and ohshit > airtime and ( entSpeed < lastentSpeed or entSpeed < 2.0 ) then
                                    ejectionLUL()
                                    --print("eject : " .. ohshit .. " vs " .. airtime .. " " .. entSpeed .. " vs " .. lastentSpeed)
                                elseif airtime > 1500 and entSpeed < lastentSpeed then
                                    ejectionLUL()
                                    --print("eject 2 : " .. ohshit .. " vs " .. airtime .. " " .. entSpeed .. " vs " .. lastentSpeed)
                                else
                                --  print("Good Landing" .. ohshit .. " vs " .. airtime .. " " .. entSpeed .. " vs " .. lastentSpeed)
                                end
                            end

                        elseif airtime > 950 and IsThisModelABike(GetEntityModel(GetVehiclePedIsUsing(PlayerPedId()))) then
                            --print(airtime .. " what " .. zdf)
                            local ohshit = math.ceil((zdf * 200))
                            local entSpeed = math.ceil( GetEntitySpeed(GetVehiclePedIsUsing(PlayerPedId())) * 1.15 )
                            --print("speed - " .. entSpeed)

                            if airtime > 950 then
                                if airtime > 950 and ohshit > airtime and ( entSpeed < lastentSpeed or entSpeed < 2.0 ) then
                                    ejectionLUL()
                                elseif airtime > 2500 and entSpeed < lastentSpeed then
                                    ejectionLUL()
                                end
                            end
                                 
                        end
                    end
                    airtimeCoords = GetEntityCoords(PlayerPedId())
                    heightPeak = 0
                    airtime = 0
                    lasthighPeak = 0
                    zDownForce = 0
                end

                --GetVehicleClass(vehicle)
                local ped = PlayerPedId()
                local roll = GetEntityRoll(veh)

                if IsEntityInAir(veh) and not IsThisModelABike(GetEntityModel(veh)) then
                    --print("stop air control")
                    DisableControlAction(0, 59)
                    DisableControlAction(0, 60)
                end
                if ((roll > 75.0 or roll < -75.0) or not IsVehicleEngineOn(veh)) and not IsThisModelABike(GetEntityModel(veh)) then 
                    --print("stop roll bro")        
                    DisableControlAction(2,59,true)
                    DisableControlAction(2,60,true)
                end
            else
                Citizen.Wait(1000)
            end
        else
            Citizen.Wait(1000)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        playerPed = PlayerPedId()
        local tempVehicle = GetVehiclePedIsIn(playerPed, false)
        local tempDriver = GetPedInVehicleSeat(tempVehicle, -1)
        if tempVehicle ~= currentVehicle then
            currentVehicle = tempVehicle
            if currentVehicle == nil or currentVehicle == 0 or currentVehicle == false then
                --
            else
                driverPed = GetPedInVehicleSeat(currentVehicle, -1)
            end
        elseif (tempDriver ~= driverPed and tempDriver ~= 0) or (tempDriver == 0 and driverPed == playerPed) then
            driverPed = tempDriver
            if driverPed == playerPed then
                -- Switched seat to driver
            else
                --
            end
        end
    end
end)

Citizen.CreateThread(function()
    Citizen.Wait(1000)
    local lastCurrentVehicleBodyHealth = 0
    local lastCurrentVehicleSpeed = 0

    local function eject(percent, speed)
        if math.random(math.ceil(speed)) > percent then
            ejectionLUL()
        end
    end

    while true do
        Citizen.Wait(1)
        if currentVehicle ~= nil and currentVehicle ~= false and currentVehicle ~= 0 then
            SetPedHelmet(playerPed, false)
            if driverPed == playerPed then
                local currentEngineHealth = GetVehicleEngineHealth(currentVehicle)
                if currentEngineHealth < 0.0 then
                    -- Dont blow up
                    SetVehicleEngineHealth(currentVehicle,0.0)
                end

                local collision = HasEntityCollidedWithAnything(currentVehicle)
                if collision == false then
                    lastCurrentVehicleSpeed = GetEntitySpeed(currentVehicle)
                    lastCurrentVehicleBodyHealth = GetVehicleBodyHealth(currentVehicle)
                    veloc = GetEntityVelocity(currentVehicle)
                    if currentEngineHealth > 10.0 and (currentEngineHealth < 175.0 or lastCurrentVehicleBodyHealth < 50.0) then
                        carCrash()
                        Citizen.Wait(1000)
                    end             
                else
                    Citizen.Wait(100)
                    local currentVehicleBodyHealth = GetVehicleBodyHealth(currentVehicle)
                    local currentVehicleSpeed = GetEntitySpeed(currentVehicle)
                    if currentEngineHealth > 0.0 and lastCurrentVehicleBodyHealth - currentVehicleBodyHealth > 15 then
                        if lastCurrentVehicleSpeed > 30.5 and currentVehicleSpeed < (lastCurrentVehicleSpeed * 0.75) then
                            if not IsThisModelABike(GetEntityModel(currentVehicle)) then
                                stallVehicle()
                                sendServerEventForPassengers("carhud:ejection:server", veloc, GetVehicleNumberPlateText(currentVehicle))
                                if not seatbelt then
                                    eject(30.5, lastCurrentVehicleSpeed)
                                elseif seatbelt and lastCurrentVehicleSpeed > 41.6 then
                                    eject(33.0, lastCurrentVehicleSpeed)
                                end
                                -- Buffer after crash
                                Citizen.Wait(1000)
                                lastCurrentVehicleSpeed = 0.0
                                lastCurrentVehicleBodyHealth = currentVehicleBodyHealth
                            else
                                -- IsBike
                                stallVehicle()
                                Citizen.Wait(1000)
                                lastCurrentVehicleSpeed = 0.0
                                lastCurrentVehicleBodyHealth = currentVehicleBodyHealth
                            end
                        end
                    else
                        if currentEngineHealth > 10.0 and (currentEngineHealth < 195.0 or currentVehicleBodyHealth < 50.0) then
                            carCrash()
                            Citizen.Wait(1000)
                        end                        
                        lastCurrentVehicleSpeed = currentVehicleSpeed
                        lastCurrentVehicleBodyHealth = currentVehicleBodyHealth
                    end
                end
            else
                -- Not driver
                Citizen.Wait(1000)
            end
        else
            -- Not in veh
            currentVehicleSpeed = 0
            lastCurrentVehicleSpeed = 0
            lastCurrentVehicleBodyHealth = 0
            Citizen.Wait(4000)
        end
    end
end)