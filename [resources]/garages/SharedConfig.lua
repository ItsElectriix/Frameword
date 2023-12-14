Garages = {
    ["vehicles"] = {
        ["motelgarage"] = {
            label = "Motel Parking",
            takeVehicle = {x = 273.43, y = -343.99, z = 44.91},
            spawnPoint = vector4(270.94, -342.96, 43.97, 161.5),
            putVehicle = {x = 276.69, y = -339.85, z = 44.91},
        },
        ["legion"] = {
            label = "Legion Square Parking",
            takeVehicle = {x = 215.800, y = -810.057, z = 30.727},
            spawnPoint = {
                vector4(240.65, -779.41, 30.64, 68.48),
                vector4(245.54238, -772.6592, 30.038272, 67.925498),
                vector4(239.47805, -784.6346, 30.164394, 68.070594)
            },
            putVehicle = {x = 223.797, y = -760.415, z = 30.646},
        },
        ["spanishave"] = {
            label = "Spanish Ave Parking",
            takeVehicle = {x = -1160.86, y = -741.41, z = 19.63},
            spawnPoint = vector4(-1163.88, -749.32, 18.42, 35.5),
            putVehicle = {x = -1147.58, y = -738.11, z = 19.31},
        },
        ["mazebank"] = {
            label = "Maze Bank Parking",
            takeVehicle = {x = -75.55, y = -2003.92, z = 18.05},
            spawnPoint = vector4(-81.55, -2005.18, 18.02, 172.36),
            putVehicle = {x = -70.98, y = -2010.0, z = 18.1},
        },
        ["vinewood"] = {
            label = "Vinewood Parking",
            takeVehicle = {x = -338.96, y = 267.39, z = 85.8},
            spawnPoint = vector4(-347.32, 272.39, 85.24, 268.73),
            putVehicle = {x = -344.96, y = 297.52, z = 85.3},
        },
        ["airportp"] = {
            label = "Airport Parking",
            takeVehicle = {x = -796.86, y = -2024.85, z = 8.88},
            spawnPoint = vector4(-800.41, -2016.53, 9.32, 48.5),
            putVehicle = {x = -804.84, y = -2023.21, z = 9.16},
        },
        ["beachp"] = {
            label = "Vespucci Beach Parking",
            takeVehicle = {x = -2031.84, y = -467.09, z = 11.38},
            spawnPoint = vector4(-2039.06, -472.57, 11.52, 321.66),
            putVehicle = {x = -2029.72, y = -456.15, z = 11.54},
        },
        ["themotorhotel"] = {
            label = "The Motor Hotel Parking",
            takeVehicle = {x = 1137.77, y = 2663.54, z = 37.9},            
            spawnPoint = vector4(1137.69, 2673.61, 37.9, 359.5),      
            putVehicle = {x = 1137.75, y = 2652.95, z = 37.9},
        },
        ["paleto"] = {
            label = "Paleto Parking",
            takeVehicle = {x = 105.359, y = 6613.586, z = 32.3973},
            spawnPoint = vector4(120.02, 6599.39, 32.02, 68.5), 
            putVehicle = {x = 126.3572, y = 6608.4150, z = 32.8565},
        },       
    },
    ["boats"] = {
        ["vespucci"] = {
            label = "Yacht Club",
            garagePoint = vector3(-848.73, -1497.86, 1.63),
            spawnPoint = vector4(-853.95, -1551.18, -0.4, 125.0),
        },
    },
    ["aircraft"] = {
        ["airportgrape"] = {
            label = "Grapeseed Airport",
            garagePoint = vector3(2132.32, 4796.96, 41.14),
            spawnPoint = vector4(2127.64, 4805.36, 41.15, 110.29),
        },
        ["airportsandy"] = {
            label = "Sandy Airport",
            garagePoint = vector3(1723.77, 3272.26, 41.15),
            spawnPoint = vector4(1713.29, 3253.03, 41.08, 103.96),
        },
        ["airportlsa"] = {
            label = "LSA Private",
            garagePoint = vector3(-1408.25, -3242.53, 13.94),
            spawnPoint = vector4(-1378.52, -3239.92, 13.94, 328.0),
        },
    }
}

HouseGarages = {}

Depots = {
    ["hayesdepot"] = {
        label = "Hayes Depot",
        takeVehicle = {x = 491.0, y = -1314.69, z = 29.25, h = 304.5}
    }
}

DepotsEnabled = true

function GetGarageLabel(type, garage)
    local garageType = "aircraft"
    if type == "boat" then
        garageType = "boats"
    elseif type == "vehicle" then
        garageType = "vehicles"
    end
    if Garages[garageType][garage] ~= nil then
        return Garages[garageType][garage]["label"]
    else
        return garage
    end
end
exports('GetGarageLabel', GetGarageLabel)

BJCore = nil
TriggerEvent('BJCore:GetObject', function(obj) BJCore = obj end)
Citizen.CreateThread(function(...) while BJCore == nil do TriggerEvent("BJCore:GetObject", function(obj) BJCore = obj end); Citizen.Wait(1000); end; end)
if DepotsEnabled and Depots ~= nil then
    local noDepots = true
    for k,v in pairs(Depots) do
        noDepots = false
        break
    end
    if noDepots then
        DepotsEnabled = false
    end
end
