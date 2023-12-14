local flight = nil

local _print = print

function print(...)
    if Config.Debug then
        _print(...)
    end
end

function AirportHasQueue(airport)
    if Config.AirportConfig[airport] then
        if #Config.AirportConfig[airport].Queue > 0 then
            return true
        end
    end
    return false
end

function RemoveNextFromQueue(airport)
    if AirportHasQueue(airport) then
        local rem = table.remove(Config.AirportConfig[airport].Queue, 1)

        local Player = BJCore.Functions.GetPlayer(rem)
        if Player then
            if Config.AirportConfig[airport].CheckContraband and math.random(1, 100) / 100 <= Config.ContrabandNotifyPercentage then
                local hasIllegals = false
                for k,v in pairs(Config.IllegalItems) do
                    local item = Player.Functions.GetItemByName(k)
                    if item == nil or item.amount < 1 then
                        hasIllegals = true
                        break
                    end
                end

                if hasIllegals and (Config.ContrabandNotifyForPolice or Player.PlayerData.job.name ~= 'police') then
                    Citizen.CreateThread(function()
                        local random = math.random(15000, 35000)
                        print('Waiting: '..tostring(random))
                        Wait(random)
                        for _,v in ipairs(StartPoints) do
                            if v.dest == airport then
                                TriggerEvent('MF_Trackables:Notify', "Airport Security are reporting illegal items on an inbound flight.", v.coords, 'police', 'civreport')
                            end
                        end
                    end)
                end

                return rem
            else
                return rem
            end
        else
            return RemoveNextFromQueue(airport)
        end
    end

    return nil
end

AddEventHandler('playerDropped', function (reason)
    local _source = tonumber(source)

    for k,v in pairs(Config.AirportConfig) do
        if v.InFlight and v.FlightController == _source then
            -- do something about dc's?
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        if flight == nil then
            for k,airport in pairs(Config.AirportConfig) do
                if AirportHasQueue(k) then
                    print('Queue found, initiating: '..k)
                    flight = k
                    
                    if airport.FlightStartTime == nil then
                        airport.FlightStartTime = os.time() + Config.PlaneQueueWait
                    end
                end
            end
        else
            if Config.AirportConfig[flight] then
                local airport = Config.AirportConfig[flight]
                if airport.InFlight and airport.FlightStartTime ~= nil then
                    if airport.FlightStartTime + 300 < os.time() then
                        print('Flight timed out. Clearing data to prepare next flight.')
                        airport.InFlight = false
                        airport.PreparingFlight = false
                        airport.FlightController = nil
                        airport.FlightStartTime = nil
                        flight = nil
                    end
                elseif not airport.PreparingFlight and AirportHasQueue(flight) then
                    if airport.FlightStartTime < os.time() then
                        print('Flight Prep Start')
                        -- start flight prep
                        airport.FlightController = RemoveNextFromQueue(flight)
                        TriggerClientEvent('bj_gameplay:airport:doFlightPrep', airport.FlightController, flight, airport.Destination)
                        airport.PreparingFlight = true
                    end
                elseif not airport.PreparingFlight and not AirportHasQueue(flight) then
                    flight = nil
                    print('Flight cancelled')
                end
            end
        end
        Wait(1000)
    end
end)

BJCore.Functions.RegisterServerCallback('bj_gameplay:airport:buyTicket', function(source, cb, start)
    local _source = tonumber(source)
    local Player = BJCore.Functions.GetPlayer(_source)

    local airport = Config.AirportConfig[start]

    if airport then

        if airport.RequiredItems then
            local canFly = true
            local missingItem = ''

            for k,v in pairs(airport.RequiredItems) do
                local item = Player.Functions.GetItemByName(k)
                if item == nil or item.amount < 1 then
                    canFly = false
                    missingItem = BJCore.Shared.Items[k] and BJCore.Shared.Items[k].label or 'Missing Item Config'
                    break
                end
            end

            if not canFly then
                TriggerClientEvent('BJCore:Notify', _source, "You must have a "..missingItem.." to take a flight from this airport", "error")
                cb(false)
                return
            end
        end
        
        if airport.Price > 0 then
            if Player.PlayerData.money.cash >= airport.Price then
                Player.Functions.RemoveMoney("cash", airport.Price, "Plane ticket")
            else
                TriggerClientEvent('BJCore:Notify', _source, "You don't have enough cash to purcahse a ticket", "error")
                cb(false)
                return
            end
        end
        table.insert(airport.Queue, _source)
        print('Added to queue: '..start..', Queue Length: '..tostring(#airport.Queue))
        TriggerClientEvent('BJCore:Notify', _source, "You purchased a ticket, please wait for the next flight", "primary")
        cb(true)
    else
        cb(false)
    end
end)

RegisterNetEvent('bj_gameplay:airport:leaveQueue')
AddEventHandler('bj_gameplay:airport:leaveQueue', function(start)
    local _source = tonumber(source)

    if Config.AirportConfig[start] then
        local index = 0
        for k,v in ipairs(Config.AirportConfig[start].Queue) do
            if v == _source then
                index = k
            end
        end

        if index > 0 then
            print('Force left queue: '..tostring(_source))
            table.remove(Config.AirportConfig[start].Queue, index)
            print(#Config.AirportConfig[start].Queue)
            TriggerClientEvent('BJCore:Notify', _source, "You have left the queue for your flight, no refunds are issued for missed flights", "error")
        end
    end
end)

RegisterNetEvent('bj_gameplay:airport:populateFlight')
AddEventHandler('bj_gameplay:airport:populateFlight', function(airport, netVehId, totalAvailableSeats)
    local _source = tonumber(source)

    print('Populating flight: '..airport..' VehId: '..tostring(netVehId)..' Remaining Seats: '..tostring(totalAvailableSeats))

    for i=1, totalAvailableSeats do
        if AirportHasQueue(airport) then
            local player = RemoveNextFromQueue(airport)
            if player then
                TriggerClientEvent('bj_gameplay:airport:joinFlight', player, airport, netVehId, i + 2)
            end
        end
    end
end)

RegisterNetEvent('bj_gameplay:airport:flightStarted')
AddEventHandler('bj_gameplay:airport:flightStarted', function(airport)
    local _source = tonumber(source)

    print('Flight started: '..airport)

    if Config.AirportConfig[airport] and Config.AirportConfig[airport].FlightController == _source then
        Config.AirportConfig[airport].InFlight = true
        Config.AirportConfig[airport].PreparingFlight = false
    end
end)

RegisterNetEvent('bj_gameplay:airport:flightEnded')
AddEventHandler('bj_gameplay:airport:flightEnded', function(airport)
    local _source = tonumber(source)

    print('Flight ended: '..airport)

    if Config.AirportConfig[airport] and Config.AirportConfig[airport].FlightController == _source then
        Config.AirportConfig[airport].InFlight = false
        Config.AirportConfig[airport].PreparingFlight = false
        Config.AirportConfig[airport].FlightController = nil
        Config.AirportConfig[airport].FlightStartTime = nil
        flight = nil
    end
end)