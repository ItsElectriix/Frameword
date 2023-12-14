local E_KEY = 38
Animation = {}
Animation.jets = {}
local CurLocation = false

local function checkWashLopp()
    Citizen.CreateThread(function () 
        while true do
            local sleep = 10
            if IsPedInAnyVehicle(PlayerPedId(), true) then
                local plyPed = PlayerPedId()
                local plyPos = GetEntityCoords(plyPed)
                local closestKey, closestVal, closestDist = BJCore.Functions.GetClosestAction(plyPos, Config.CarWashLocations, "Entrance")
                if closestDist < 25 then
                    sleep = 0
                    DrawMarker(2, closestVal["Entrance"], 0, 0, 0, 0, 0, 0, 0.8, 0.8, 0.8, 0, 0, 200, 50, 0, 1, 2, 0, 0, 0, 0)
                    if closestDist < 2 then
                    
                        BJCore.Functions.DisplayHelpText('~INPUT_PICKUP~ to wash your car for '..BJCore.Config.Currency.Symbol..Config.CarWashPrice)
                        if IsControlJustPressed(1, E_KEY) then
                            purchaseWash(closestKey, GetVehiclePedIsUsing(plyPed))
                        end                    
                    end
                else
                    if closestDist > 50 then sleep = 1000; end
                end
            else
                sleep = 1000
            end
            Citizen.Wait(sleep)
        end
    end)
end


Citizen.CreateThread(function() while not BJCore do Wait(1000); end while not BJCore.Functions.IsPlayerLoaded() do Wait(1000); end checkWashLopp()  end)

function purchaseWash(locationIndex, vehicle)
    BJCore.Functions.TriggerServerCallback('bj_gameplay:purchaseWash', function(canPay)
        if canPay then
            BJCore.Functions.Notify('You paid '..BJCore.Config.Currency.Symbol..Config.CarWashPrice..'. Pull ahead to wash your car','primary',4000)

            makeCarReadyForWash(vehicle)
            StartSpray(locationIndex, vehicle)
        else
            BJCore.Functions.Notify('You do not have enough cash to wash your car','error')
        end

        Citizen.Wait(5000)
    end)
end

function makeCarReadyForWash(vehicle)
    rollWindowsUp(vehicle)
    putConvertibleTopUpIfNeeded(vehicle)
end

function rollWindowsUp(vehicle)
    for i = 0, 3 do
        RollUpWindow(vehicle, i)
    end
end

function putConvertibleTopUpIfNeeded(vehicle)
    if IsVehicleAConvertible(vehicle, true) then
        RaiseConvertibleRoof(vehicle, false)
    end
end

function StartSpray(locationIndex, vehicle)
    local jetCoords, effects = Config.CarWashLocations[locationIndex]["Jets"], {}
    while not HasNamedPtfxAssetLoaded(Config.CarWashParticleDictionary) do RequestNamedPtfxAsset(Config.CarWashParticleDictionary) Citizen.Wait(0); end
    for index, jet in pairs(jetCoords) do
        UseParticleFxAssetNextCall(Config.CarWashParticleDictionary)
        effects[index] = StartParticleFxLoopedAtCoord(Config.CarWashParticle, jet.x, jet.y, jet.z, jet.xRot, jet.yRot, jet.zRot, 1.0, false, false, false, false)
    end

    Animation.jets[locationIndex] = effects
    local start = true
    while start do 
        if #(GetEntityCoords(PlayerPedId()) - Config.CarWashLocations[locationIndex]["Exit"]) < 2.0 then
            TriggerServerEvent("bj_gameplay:requestClean", VehToNet(vehicle))
            BJCore.Functions.Notify('Wash completed','success')
            start = false
        end
        Citizen.Wait(1)
    end

    for _, jet in pairs(Animation.jets[locationIndex]) do
        StopParticleFxLooped(jet, 0)
    end
    RemoveNamedPtfxAsset(Config.CarWashParticleDictionary)
end

RegisterNetEvent("bj_gameplay:doClean")
AddEventHandler("bj_gameplay:doClean", function(veh)
    local vehicle = NetToVeh(veh)
    WashDecalsFromVehicle(vehicle, 1.0)
    SetVehicleDirtLevel(vehicle)
end)