function CreateHotel(spawn)
    local objects = {}

    local POIOffsets = {}
    POIOffsets.exit = json.decode('{"z":2.5,"y":-15.901171875,"x":4.251012802124,"h":2.2633972168}')
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do
        Citizen.Wait(10)
    end
    RequestModel(`playerhouse_hotel`)
	while not HasModelLoaded(`playerhouse_hotel`) do
	    Citizen.Wait(1000)
	end
    local shell = CreateObject(`playerhouse_hotel`, spawn.x, spawn.y, spawn.z, false, false, false)
    FreezeEntityPosition(shell, true)
    table.insert(objects, shell)

    local curtains = CreateObject(`V_49_MotelMP_Curtains`, spawn.x + 1.55156000, spawn.y + (-3.83100100), spawn.z + 2.23457500)
    table.insert(objects, curtains)
    local window = CreateObject(`V_49_MotelMP_Curtains`, spawn.x + 1.43190000, spawn.y + (-3.92315100), spawn.z + 2.29329600)
    table.insert(objects, window)

    TeleportToInterior(spawn.x + POIOffsets.exit.x, spawn.y + POIOffsets.exit.y, spawn.z + 1.5, POIOffsets.exit.h)

    return { objects, POIOffsets }
end

function CreateTier1House(spawn, isBackdoor)
    local objects = {}

    local POIOffsets = {}
    POIOffsets.exit = json.decode('{"z":2.5,"y":-15.901171875,"x":4.251012802124,"h":2.2633972168}')
	POIOffsets.clothes = json.decode('{"z":2.5,"y":-3.9233189,"x":-7.84363671,"h":2.2633972168}')
	POIOffsets.stash = json.decode('{"z":2.5,"y":1.33868212,"x":-9.084908691,"h":2.2633972168}')
	POIOffsets.logout = json.decode('{"z":2.0,"y":-1.1463337,"x":-6.69117089,"h":2.2633972168}')
    POIOffsets.backdoor = json.decode('{"z":2.5,"y":4.3798828125,"x":0.88999176025391,"h":182.2633972168}')
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do
        Citizen.Wait(10)
    end
    RequestModel(`playerhouse_tier1`)
	while not HasModelLoaded(`playerhouse_tier1`) do
	    Citizen.Wait(1000)
	end
    local shell = CreateObject(`playerhouse_tier1`, spawn.x, spawn.y, spawn.z, false, false, false)
    FreezeEntityPosition(shell, true)
    table.insert(objects, shell)

    local dt = CreateObject(`V_16_DT`, spawn.x-1.21854400, spawn.y-1.04389600, spawn.z + 1.39068600, false, false, false)
    table.insert(objects, dt)

    if not isBackdoor then
        TeleportToInterior(spawn.x + POIOffsets.exit.x, spawn.y + POIOffsets.exit.y, spawn.z + 1.5, POIOffsets.exit.h)
        Citizen.Wait(100)
        TeleportToInterior(spawn.x + POIOffsets.exit.x, spawn.y + POIOffsets.exit.y, spawn.z + 1.5, POIOffsets.exit.h)
        Citizen.Wait(100)
        TeleportToInterior(spawn.x + POIOffsets.exit.x, spawn.y + POIOffsets.exit.y, spawn.z + 1.5, POIOffsets.exit.h)
    else
        TeleportToInterior(spawn.x + POIOffsets.backdoor.x, spawn.y + POIOffsets.backdoor.y, spawn.z + 1.5, POIOffsets.backdoor.h + 180)
    end

    return { objects, POIOffsets }
end

function CreateTier2House(spawn, isBackdoor)
    local objects = {}

    local POIOffsets = {}
    POIOffsets.exit = json.decode('{"z":1.5,"y":-15.080020100,"x":3.69693000}')
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do
        Citizen.Wait(10)
    end
    RequestModel(`playerhouse_tier2`)
	while not HasModelLoaded(`playerhouse_tier2`) do
	    Citizen.Wait(1000)
	end
    local shell = CreateObject(`playerhouse_tier2`, spawn.x, spawn.y, spawn.z, false, false, false)
    FreezeEntityPosition(shell, true)

    table.insert(objects, shell)

    local dt = CreateObject(`V_16_DT`, spawn.x-1.21854400, spawn.y-1.04389600, spawn.z + 1.39068600, false, false, false)
    table.insert(objects, dt)


    if not isBackdoor then
        TeleportToInterior(spawn.x + 3.69693000, spawn.y - 15.080020100, spawn.z + 1.5, spawn.h)
    else
        TeleportToInterior(spawn.x + 0.88999176025391, spawn.y + 4.3798828125, spawn.z + 1.5, spawn.h)
    end

    return { objects, POIOffsets }
end

-- function CreateTier3House(spawn, isBackdoor)
--     local objects = {}

--     local POIOffsets = {}
--     POIOffsets.exit = json.decode('{"y":7.7457427978516,"z":7.2074546813965,"x":-17.097534179688}')
--     POIOffsets.backdoor = json.decode('{"z":5.8048210144043,"y":12.009414672852,"x":12.690063476563}')
--     DoScreenFadeOut(500)
--     while not IsScreenFadedOut() do
--         Citizen.Wait(10)
--     end
--     RequestModel(`playerhouse_tier3`)
-- 	while not HasModelLoaded(`playerhouse_tier3`) do
-- 	    Citizen.Wait(1000)
-- 	end
--     local shell = CreateObject(`playerhouse_tier3`, spawn.x, spawn.y, spawn.z, false, false, false)
--     table.insert(objects, shell)
--     RequestModel(`v_16_high_lng_over_shadow`)
-- 	while not HasModelLoaded(`v_16_high_lng_over_shadow`) do
-- 	    Citizen.Wait(1000)
-- 	end
--     local windows1 = CreateObject(`v_16_high_lng_over_shadow`, spawn.x + 10.16043000, spawn.y + -4.83294600, spawn.z + 4.99192700, false, false, false)
--     table.insert(objects, windows1)

--     FreezeEntityPosition(shell, true)
--     FreezeEntityPosition(windows1, true)

--     if not isBackdoor then
--         TeleportToInterior(spawn.x + POIOffsets.exit.x, spawn.y + POIOffsets.exit.y, spawn.z + POIOffsets.exit.z, spawn.h)
--     else
--         TeleportToInterior(spawn.x + POIOffsets.backdoor.x, spawn.y + POIOffsets.backdoor.y, spawn.z + POIOffsets.backdoor.z, spawn.h)
--     end

--     return { objects, POIOffsets }
-- end

function CreateCaravanShell(spawn, isBackdoor)
    local objects = {}

    local POIOffsets = {}
    POIOffsets.exit = json.decode('{"x":-1.31,"y":-2.02,"z":2.166,"h":3.3}')

    RequestModel(`caravan_shell`) 
    while not HasModelLoaded(`caravan_shell`) do Citizen.Wait(0); end 
    local shell = CreateObject(`caravan_shell`, spawn.x, spawn.y, spawn.z, false, false, false)
    FreezeEntityPosition(shell, true)
    table.insert(objects, shell)
    TeleportToInterior(spawn.x + POIOffsets.exit.x, spawn.y + POIOffsets.exit.y, spawn.z + 1.5, POIOffsets.exit.h)
    return { objects, POIOffsets }
end

function CreateLowTierApartment(spawn)
    local objects = {}

    local POIOffsets = {}
    POIOffsets.exit = json.decode('{"x":4.766,"y":-6.66,"z":1.00,"h":358.50}')

    RequestModel(`apartment`) 
    while not HasModelLoaded(`apartment`) do Citizen.Wait(0); end 
    local shell = CreateObject(`apartment`, spawn.x, spawn.y, spawn.z, false, false, false)
    FreezeEntityPosition(shell, true)
    table.insert(objects, shell)

    TeleportToInterior(spawn.x + POIOffsets.exit.x, spawn.y + POIOffsets.exit.y, spawn.z + 1.5, POIOffsets.exit.h)

    return { objects, POIOffsets }
end
exports("CreateLowTierApartment", CreateLowTierApartment)

function CreateHighEndApartment(spawn)
    local objects = {}

    local POIOffsets = {}
    POIOffsets.exit = json.decode('{"x":10.78,"y":8.124,"z":6.41,"h":128.92}')

    RequestModel(`barbers_shell`) 
    while not HasModelLoaded(`barbers_shell`) do Citizen.Wait(0); end 
    local shell = CreateObject(`barbers_shell`, spawn.x, spawn.y, spawn.z, false, false, false)
    FreezeEntityPosition(shell, true)
    table.insert(objects, shell)

    TeleportToInterior(spawn.x + POIOffsets.exit.x, spawn.y + POIOffsets.exit.y, spawn.z + 1.5, POIOffsets.exit.h)

    return { objects, POIOffsets }
end
exports("CreateHighEndApartment", CreateHighEndApartment)

function CreateGunshopShell(spawn)
    local objects = {}

    local POIOffsets = {}
    POIOffsets.exit = json.decode('{"x":-1.09,"y":-5.37,"z":6.04,"h":0.317}')

    RequestModel(`gunshop_shell`) 
    while not HasModelLoaded(`gunshop_shell`) do Citizen.Wait(0); end 
    local shell = CreateObject(`gunshop_shell`, spawn.x, spawn.y, spawn.z, false, false, false)
    FreezeEntityPosition(shell, true)
    table.insert(objects, shell)

    TeleportToInterior(spawn.x + POIOffsets.exit.x, spawn.y + POIOffsets.exit.y, spawn.z + 1.5, POIOffsets.exit.h)

    return { objects, POIOffsets }
end
exports("CreateGunshopShell", CreateGunshopShell)

function CreateMichealShell(spawn)
    local objects = {}

    local POIOffsets = {}
    POIOffsets.exit = json.decode('{"x":-10.43,"y":2.53,"z":1.159,"h":270.372}')

    RequestModel(`micheal_shell`) 
    while not HasModelLoaded(`micheal_shell`) do Citizen.Wait(0); end 
    local shell = CreateObject(`micheal_shell`, spawn.x, spawn.y, spawn.z, false, false, false)
    FreezeEntityPosition(shell, true)
    table.insert(objects, shell)

    TeleportToInterior(spawn.x + POIOffsets.exit.x, spawn.y + POIOffsets.exit.y, spawn.z + 1.5, POIOffsets.exit.h)

    return { objects, POIOffsets }
end
exports("CreateMichealShell", CreateMichealShell)

function CreateMotelShell(spawn)
    local objects = {}

    local POIOffsets = {}
    POIOffsets.exit = json.decode('{"x":-1.468,"y":-4.005,"z":1.150,"h":6.908}')

    RequestModel(`playerhouse_appartment_motel`) 
    while not HasModelLoaded(`playerhouse_appartment_motel`) do Citizen.Wait(0); end 
    local shell = CreateObject(`playerhouse_appartment_motel`, spawn.x, spawn.y, spawn.z, false, false, false)
    FreezeEntityPosition(shell, true)
    table.insert(objects, shell)

    TeleportToInterior(spawn.x + POIOffsets.exit.x, spawn.y + POIOffsets.exit.y, spawn.z + 1.5, POIOffsets.exit.h)

    return { objects, POIOffsets }
end
exports("CreateMotelShell", CreateMotelShell)

function CreateRegularHouse(spawn)
    local objects = {}

    local POIOffsets = {}
    POIOffsets.exit = json.decode('{"x":-0.309,"y":-5.747,"z":2.160,"h":0.359}')

    RequestModel(`tante_shell`) 
    while not HasModelLoaded(`tante_shell`) do Citizen.Wait(0); end 
    local shell = CreateObject(`tante_shell`, spawn.x, spawn.y, spawn.z, false, false, false)
    FreezeEntityPosition(shell, true)
    table.insert(objects, shell)

    TeleportToInterior(spawn.x + POIOffsets.exit.x, spawn.y + POIOffsets.exit.y, spawn.z + 1.5, POIOffsets.exit.h)

    return { objects, POIOffsets }
end
exports("CreateRegularHouse", CreateRegularHouse)

function CreateTrapHouse(spawn)
    local objects = {}

    local POIOffsets = {}
    POIOffsets.exit = json.decode('{"x":-0.43,"y":-6.401,"z":3.247,"h":0.921}')

    RequestModel(`traphouse_shell`) 
    while not HasModelLoaded(`traphouse_shell`) do Citizen.Wait(0); end 
    local shell = CreateObject(`traphouse_shell`, spawn.x, spawn.y, spawn.z, false, false, false)
    FreezeEntityPosition(shell, true)
    table.insert(objects, shell)

    TeleportToInterior(spawn.x + POIOffsets.exit.x, spawn.y + POIOffsets.exit.y, spawn.z + 1.5, POIOffsets.exit.h)

    return { objects, POIOffsets }
end
exports("CreateTrapHouse", CreateTrapHouse)

function CreateTrevorsShell(spawn)
    local objects = {}

    local POIOffsets = {}
    POIOffsets.exit = json.decode('{"x":0.187,"y":-3.750,"z":7.450,"h":2.020}')

    RequestModel(`trevors_shell`) 
    while not HasModelLoaded(`trevors_shell`) do Citizen.Wait(0); end 
    local shell = CreateObject(`trevors_shell`, spawn.x, spawn.y, spawn.z, false, false, false)
    FreezeEntityPosition(shell, true)
    table.insert(objects, shell)

    TeleportToInterior(spawn.x + POIOffsets.exit.x, spawn.y + POIOffsets.exit.y, spawn.z + 1.5, POIOffsets.exit.h)

    return { objects, POIOffsets }
end
exports("CreateTrevorsShell", CreateTrevorsShell)

function CreateWarehouse1(spawn)
    local objects = {}

    local POIOffsets = {}
    POIOffsets.exit = json.decode('{"x":-8.9503,"y":0.1713,"z":1.0361,"h":271.3039}')

    RequestModel(`shell_warehouse1`) 
    while not HasModelLoaded(`shell_warehouse1`) do Citizen.Wait(0); end 
    local shell = CreateObject(`shell_warehouse1`, spawn.x, spawn.y, spawn.z, false, false, false)
    FreezeEntityPosition(shell, true)
    table.insert(objects, shell)

    TeleportToInterior(spawn.x + POIOffsets.exit.x, spawn.y + POIOffsets.exit.y, spawn.z + 1.5, POIOffsets.exit.h)

    return { objects, POIOffsets }
end
exports("CreateWarehouse1", CreateWarehouse1)

function CreateWarehouse2(spawn)
    local objects = {}

    local POIOffsets = {}
    POIOffsets.exit = json.decode('{"x":-12.626,"y":5.466,"z":1.038,"h":270.357}')

    RequestModel(`shell_warehouse2`) 
    while not HasModelLoaded(`shell_warehouse2`) do Citizen.Wait(0); end 
    local shell = CreateObject(`shell_warehouse2`, spawn.x, spawn.y, spawn.z, false, false, false)
    FreezeEntityPosition(shell, true)
    table.insert(objects, shell)

    TeleportToInterior(spawn.x + POIOffsets.exit.x, spawn.y + POIOffsets.exit.y, spawn.z + 1.5, POIOffsets.exit.h)

    return { objects, POIOffsets }
end
exports("CreateWarehouse2", CreateWarehouse2)

function CreateWarehouse3(spawn)
    local objects = {}

    local POIOffsets = {}
    POIOffsets.exit = json.decode('{"x":2.609,"y":-1.583,"z":1.003,"h":93.679}')

    RequestModel(`shell_warehouse3`) 
    while not HasModelLoaded(`shell_warehouse3`) do Citizen.Wait(0); end 
    local shell = CreateObject(`shell_warehouse3`, spawn.x, spawn.y, spawn.z, false, false, false)
    FreezeEntityPosition(shell, true)
    table.insert(objects, shell)

    TeleportToInterior(spawn.x + POIOffsets.exit.x, spawn.y + POIOffsets.exit.y, spawn.z + 1.5, POIOffsets.exit.h)

    return { objects, POIOffsets }
end
exports("CreateWarehouse3", CreateWarehouse3)

function CreateWeed(spawn)
    local objects = {}

    local POIOffsets = {}
    POIOffsets.exit = json.decode('{"x":5.581799,"y":-13.2085,"z":1.023383,"h":7.11617517}')

    RequestModel(`shell_weed2`) 
    while not HasModelLoaded(`shell_weed2`) do Citizen.Wait(0); end 
    local shell = CreateObject(`shell_weed2`, spawn.x, spawn.y, spawn.z, false, false, false)
    FreezeEntityPosition(shell, true)
    table.insert(objects, shell)

    TeleportToInterior(spawn.x + POIOffsets.exit.x, spawn.y + POIOffsets.exit.y, spawn.z + 1.5, POIOffsets.exit.h)

    return { objects, POIOffsets }
end
exports("CreateWeed", CreateWeed)

function CreateCoke(spawn)
    local objects = {}

    local POIOffsets = {}
    POIOffsets.exit = json.decode('{"x":-6.292843,"y":8.654297,"z":1.038114,"h":186.563095}')

    RequestModel(`shell_coke2`) 
    while not HasModelLoaded(`shell_coke2`) do Citizen.Wait(0); end 
    local shell = CreateObject(`shell_coke2`, spawn.x, spawn.y, spawn.z, false, false, false)
    FreezeEntityPosition(shell, true)
    table.insert(objects, shell)

    TeleportToInterior(spawn.x + POIOffsets.exit.x, spawn.y + POIOffsets.exit.y, spawn.z + 1.5, POIOffsets.exit.h)

    return { objects, POIOffsets }
end
exports("CreateCoke", CreateCoke)
