Config = {}

Config.BlacklistEnabled = true

Config.BlacklistedEntityModels = {
    [`rhino`] = true, -- Vehicle (Rhino)
    [`csb_mweather`] = true, -- Ped (Merryweather)
    [`blimp`] = true,
}

--- Car Wash Config ---
Config.CarWashPrice = 10
Config.CarWashParticleDictionary = 'core'
Config.CarWashParticle = 'water_cannon_spray'
Config.CarWashLocations = {
    {
        ["ShowBlip"] = false,
        ["Entrance"] = vector3(-4.90886, -1391.901611, 29.5854),
        ["Exit"] =     vector3(47.30156, -1392.33752, 29.5817),
        ["Jets"] = {
            {x = 0.00000, y = -1394.45000, z = 33.0, xRot = -60.0, yRot = 0.0, zRot = 0.0},
            {x = 5.00000, y = -1394.45000, z = 33.0, xRot = -60.0, yRot = 0.0, zRot = 0.0},
            {x = 10.00000, y = -1394.55000, z = 33.0, xRot = -60.0, yRot = 0.0, zRot = 0.0},
            {x = 15.00000, y = -1394.55000, z = 33.0, xRot = -60.0, yRot = 0.0, zRot = 0.0},
            {x = 20.00000, y = -1394.55000, z = 33.0, xRot = -60.0, yRot = 0.0, zRot = 0.0},
            {x = 25.00000, y = -1394.65000, z = 33.0, xRot = -60.0, yRot = 0.0, zRot = 0.0},
            {x = 30.00000, y = -1394.65000, z = 33.0, xRot = -60.0, yRot = 0.0, zRot = 0.0},
            {x = 35.00000, y = -1394.75000, z = 33.0, xRot = -60.0, yRot = 0.0, zRot = 0.0},
            {x = 40.00000, y = -1394.75000, z = 33.0, xRot = -60.0, yRot = 0.0, zRot = 0.0},
            {x = 46.50000, y = -1394.85000, z = 33.0, xRot = -60.0, yRot = 0.0, zRot = 0.0},
        }
    },
    {
        ["ShowBlip"] = false,
        ["Entrance"] = vector3(164.01007, -1719.99414, 29.4686),
        ["Exit"] =     vector3(172.20321, -1711.12109, 28.4667),
        ["Jets"] = {
            {x = 167.12083, y = -1717.68737, z = 31.0, xRot = -90.0, yRot = 0.0, zRot = 0.0},
            {x = 169.18376, y = -1716.16857, z = 31.0, xRot = -90.0, yRot = 0.0, zRot = 45.0},
            {x = 170.83013, y = -1713.98229, z = 31.0, xRot = -90.0, yRot = 0.0, zRot = 135.0},
        }
    },
    {
        ["ShowBlip"] = false,
        ["Entrance"] = vector3(167.23796, -1722.69775, 29.2916),
        ["Exit"] =     vector3(175.08970, -1713.64282, 29.2916),
        ["Jets"] = {
            {x = 168.07487, y = -1719.04553, z = 31.0, xRot = -90.0, yRot = -50.0, zRot = 200.0},
            {x = 169.18376, y = -1718.16857, z = 31.0, xRot = -90.0, yRot = -50.0, zRot = 200.0},
            {x = 170.83013, y = -1715.10058, z = 31.0, xRot = -90.0, yRot = -50.0, zRot = 180.0},
        }
    },
    {
        ["ShowBlip"] = false,
        ["Entrance"] = vector3(-699.85253, -945.26452, 19.6837),
        ["Exit"] =     vector3(-699.44793, -924.56329, 19.1914),
        ["Jets"] = {
            {x = -702.06225, y = -938.76599, z = 22.0, xRot = -80.0, yRot = 0.0, zRot = -70.0},
            {x = -697.87713, y = -939.29266, z = 22.0, xRot = -80.0, yRot = 0.0, zRot = 70.0},
            {x = -702.23132, y = -935.75354, z = 22.0, xRot = -80.0, yRot = 0.0, zRot = -70.0},
            {x = -697.66198, y = -936.04089, z = 22.0, xRot = -80.0, yRot = 0.0, zRot = 70.0},
            {x = -702.28936, y = -932.37719, z = 22.0, xRot = -80.0, yRot = 0.0, zRot = -70.0},
            {x = -697.67193, y = -932.81652, z = 22.0, xRot = -80.0, yRot = 0.0, zRot = 70.0},
            {x = -702.27752, y = -929.74749, z = 22.0, xRot = -80.0, yRot = 0.0, zRot = -70.0},
            {x = -697.66198, y = -929.55651, z = 22.0, xRot = -80.0, yRot = 0.0, zRot = 70.0},
        }
    }
}
---

--- /ping command ---
Config.PingTimeout = 30 -- NOTE: Notification For Accepting Will Break With This Set To 0
Config.PingDeleteDistance = 10 -- 0 to disable
Config.PingRouteToPing = false
Config.PingBlipDuration = 60 -- 0 to disable
Config.PingBlipColor = 4
Config.PingBlipIcon = 280
Config.PingBlipScale = 0.75
---

--- Street Racing ---
Config.SRFlagMarkerOffsetZ 	=   10.0
Config.SRGroundMarkerOffsetZ = -  1.0
Config.SRWaitForPlayersTimer =   10
Config.SRJoinTimeout			=	 9
Config.SRJoinDistLimit 		=   50.0
Config.SRStartTimer			=   10
Config.SRCountdownTimer      =    5
Config.SRDrawMarkerDist		=  300.0
Config.SRLeaveDist 			=	10.0
Config.SRLeaveWarnDist		=    5.0
Config.SRTimeoutTimer		=   30.0
Config.SRFinishRaceDist		=   20.0
---
Config.Stations = {
    [1] = {
        ["Name"] = "Mission Row",
        ["Location"] = vector3(425.1, -979.5, 30.7),
    },
    [2] = {
        ["Name"] = "Vinewood",
        ["Location"] = vector3(638.27, 1.67, 82.79),        
    },
    [3] = {
        ["Name"] = "Rockford Hills",
        ["Location"] = vector3(-564.91, -124.44, 37.89),        
    }    
}
--- Blip Manager --
Config.BlipSettings = {
    ["pd"] = {
        ["sprite"] = 60,
        ["colour"] = 29,
        ["text"] = "Police Station",
        ["pos"] = {
            vector3(425.1, -979.5, 30.7),
            vector3(-564.91, -124.44, 37.89),
            vector3(1853.48, 3686.13, 34.27)
        }
    },
    ["hospital"] = {
        ["sprite"] = 61,
        ["colour"] = 2,
        ["text"] = "Hospital",
        ["pos"] = {
            vector3(306.98, -587.69, 43.28),
            vector3(1836.37, 3677.56, 34.27)
        }        
    },
    ["ammunation"] = {
        ["sprite"] = 110,
        ["colour"] = 81,
        ["text"] = "Ammu-Nation",
        ["pos"] = {
            vector3( -662.1,  -935.3,  20.8),
            vector3(  810.2, -2157.3,  28.6),
            vector3( 1693.4,  3759.5,  33.7),
            vector3( -330.2,  6083.8,  30.4),
            vector3(  252.3,   -50.0,  68.9),
            vector3(   22.0, -1107.2,  28.8),
            vector3( 2567.6,   294.3, 107.7),
            vector3(-1117.5,  2698.6,  17.5),
            vector3(  842.4, -1033.4,  27.1),
            vector3(-1306.2,  -394.0,  35.6)
        }        
    },
    ["shop"] = {
        ["sprite"] = 52,
        ["colour"] = 2,
        ["text"] = "Shop",
        ["pos"] = {
        -- TwentyFourSeven            
            vector3(  373.875,   325.896,  103.566),
            vector3( 2557.458,   382.282,  108.622),
            vector3(-3038.939,   585.954,    7.908),
            vector3(-3241.927,  1001.462,   12.830),
            vector3(  547.431,  2671.710,   42.156),
            vector3( 1961.464,  3740.672,   32.343),
            vector3( 2678.916,  3280.671,   55.241),
            vector3( 1729.216,  6414.131,   35.037),
            -- LTD Gasoline
            vector3(  -48.519, -1757.514,   29.421),
            vector3( 1163.373,  -323.801,   69.205),
            vector3( -707.501,  -914.260,   19.215),
            vector3(-1820.523,   792.518,  138.118),
            vector3( 1698.388,  4924.404,   42.063), 
        }        
    },
    ["slaughterhouse"] = {
        ["sprite"] = 52,
        ["colour"] = 3,
        ["text"] = "Slaughterhouse",
        ["pos"] = {
            vector3(   961.85,  -2105.67,    31.69),
            vector3(    70.74,   6253.73,    31.09),
        }        
    },
    ["fishmonger"] = {
        ["sprite"] = 52,
        ["colour"] = 3,
        ["text"] = "Fishmonger",
        ["pos"] = {
            vector3( -1816.56,  -1193.48,    14.30),
        }        
    },
    ["hotdog"] = {
        ["sprite"] = 570,
        ["colour"] = 3,
        ["text"] = "Chihuahua Hotdogs",
        ["pos"] = {
            vector3(38.74, -1005.49, 29.47),
            vector3(-1535.43, -422.68, 35.59),
        }        
    },
    ["recycle"] = {
        ["sprite"] = 365,
        ["colour"] = 2,
        ["text"] = "Recycling Center",
        ["pos"] = {
            vector3(55.576,6472.12,31.42),
        }        
    },
    ["deliverydepot"] = {
        ["sprite"] = 477,
        ["colour"] = 55,
        ["text"] = "Delivery Depot",
        ["pos"] = {
            vector3(72.14, 121.96, 78.22),
        }        
    },
    ["tool"] = {
        ["sprite"] = 566,
        ["colour"] = 0,
        ["text"] = "Tool Shop",        
        ["pos"] = {
            vector3(2748.55, 3472.62, 55.68),
        }        
    },
    ["bank"] = {
        ["sprite"] = 108,
        ["colour"] = 77,
        ["text"] = "Bank",
        ["pos"] = {
            vector3(150.266, -1040.203, 29.374),
            vector3(-1212.980, -330.841, 37.787),
            vector3(-2962.582, 482.627, 15.703),
            vector3(-112.19, 6469.42, 31.63),
            vector3(314.187, -278.621, 54.170),
            vector3(-351.534, -49.529, 49.042),
            vector3(247.18, 222.77, 106.29),
            vector3(1175.06, 2706.64, 38.09),
        }        
    },
    ["garage"] = {
        ["sprite"] = 290,
        ["colour"] = 3,
        ["text"] = "Garage",
        ["pos"] = {
            vector3(273.43, -343.99, 44.91), -- pink cage/motel
            vector3(215.800, -810.057, 29.727), -- legion square
            vector3(-338.96, 267.39, 84.8), -- vinewood
            vector3(-75.55, -2003.92, 17.05), -- maze bank
            vector3(105.359, 6613.586, 31.3973), -- paleto
            vector3(-796.86, -2024.85, 8.88), -- airport
            vector3(1137.77, 2663.54, 37.9), -- sandy
            vector3(-1160.86, -741.41, 19.63), -- spanish ave
            vector3(-2031.84, -467.09, 10.38) -- vespucci beach
        }        
    },
    ["impound"] = {
        ["sprite"] = 290,
        ["colour"] = 17,
        ["text"] = "Hayes Depot",
        ["pos"] = {
            vector3(491.0, -1314.69, 29.25),
            -- vector3(1503.12, 3763.54, 32.5),
            -- vector3(-234.82, 6198.65, 30.94)
        }        
    },
    ["paint"] = {
        ["sprite"] = 72,
        ["colour"] = false,
        ["text"] = "Los Santos Customs",
        ["pos"] = {
            vector3(-1155.53, -2007.18, 12.74),
            vector3(731.81, -1088.82, 21.73),
            vector3(1175.04, 2640.21, 37.32),
            vector3(110.99, 6626.39, 30.89),
            vector3(-2141.19, 3251.54, 32.81)
        }        
    },
    ["benny"] = {
        ["sprite"] = 446,
        ["colour"] = 5,
        ["text"] = "Bennys Mechanics",
        ["pos"] = {
            vector3(-212.12, -1324.39, 31.00),
        }        
    },
    ["vangelico"] = {
        ["sprite"] = 439,
        ["colour"] = 32,
        ["text"] = "Vangelico Store",
        ["pos"] = {
            vector3(-623.94, -232.37, 38.06)
        }        
    },
    ["grovecustom"] = {
        ["sprite"] = 488,
        ["colour"] = 26,
        ["text"] = "Grove Street Customs",
        ["pos"] = {
            vector3(-92.33, -1807.94, 26.81)
        }        
    },
    ["cityhall"] = {
        ["sprite"] = 487,
        ["colour"] = 0,
        ["text"] = "City Hall",
        ["pos"] = {
            vector3(-552.0, -191.68, 38.22)
        }        
    },
    ["drivingschool"] = {
        ["sprite"] = 498,
        ["colour"] = 0,
        ["text"] = "Driving School",
        ["pos"] = {
            vector3(214.56, -1400.21, 30.58)
        }        
    },
    ["motel"] = {
        ["sprite"] = 475,
        ["colour"] = 23,
        ["text"] = "Motel",
        ["pos"] = {
            vector3(316.43, -223.52, 54.06),
            vector3(-1477.35, -674.07, 29.04),
            vector3(570.23, -1746.63, 29.22),
            vector3(-1317.17, -939.03, 9.73),
            vector3(361.95, -1798.7, 29.1),
            vector3(435.98, 215.37, 103.17),
            vector3(1141.62, 2664.1, 38.16),
            vector3(317.33, 2623.21, 44.46),
            vector3(-695.99, 5802.4, 17.33),
            vector3(-104.86, 6315.9, 31.58),
        }        
    },
    ["carwash"] = {
        ["sprite"] = 100,
        ["colour"] = 0,
        ["text"] = "Car Wash",
        ["pos"] = {
            vector3(-4.90886, -1391.901611, 29.5854),
            vector3(164.01007, -1719.99414, 29.4686),
            vector3(167.23796, -1722.69775, 29.2916),
            vector3(-699.85253, -945.26452, 19.6837)
        }
    },
    ["clothes"] = {
        ["sprite"] = 73,
        ["colour"] = 47,
        ["text"] = "Clothes Shop",
        ["pos"] = {
            vector3(1693.32, 4823.48, 41.06),
            vector3(-712.215881, -155.352982, 37.4151268),
            vector3(-1192.94495, -772.688965, 17.3255997),
            vector3(425.236, -806.008, 28.491),
            vector3(-162.658, -303.397, 38.733),
            vector3(75.950, -1392.891, 28.376),
            vector3(-822.194,-1074.134, 10.328),
            vector3(-1450.711, -236.83, 48.809),
            vector3(4.254, 6512.813, 30.877),
            vector3(615.180, 2762.933, 41.088),
            vector3(1196.785, 2709.558, 37.222),
            vector3(-3171.453, 1043.857, 19.863),
            vector3(-1100.959, 2710.211, 18.107),
            vector3(-1207.65, -1456.88, 4.3784737586975),
            vector3(121.76, -224.6, 53.56),
        }
    },
    ["tattoo"] = {
        ["sprite"] = 75,
        ["colour"] = 1,
        ["text"] = "Tattoo Shop",
        ["pos"] = {
            vector3(1322.6, -1651.9, 51.2),
            vector3(-1153.6, -1425.6, 4.9),
            vector3(322.1, 180.4, 103.5),
            vector3(-3170.0, 1075.0, 20.8),
            vector3(1864.6, 3747.7, 33.0),
            vector3(-293.7, 6200.0, 31.4),
        }
    },
    ["barbers"] = {
        ["sprite"] = 71,
        ["colour"] = 0,
        ["text"] = "Barbers",
        ["pos"] = {
            vector3(-814.3, -183.8, 36.6),
            vector3(136.8, -1708.4, 28.3),
            vector3(-1282.6, -1116.8, 6.0),
            vector3(1931.5, 3729.7, 31.8),
            vector3(1212.8, -472.9, 65.2),
            vector3(-32.9, -152.3, 56.1),
            vector3(-278.1, 6228.5, 30.7),
        }
    },                             
    ["gas"] = {
        ["sprite"] = 361,
        ["colour"] = 1,
        ["text"] = "Gas Station",
        ["pos"] = {
            vector3(49.4187, 2778.793, 58.043),
            vector3(263.894, 2606.463, 44.983),
            vector3(1207.260, 2660.175, 37.899),
            vector3(2539.685, 2594.192, 37.944),
            vector3(2679.858, 3263.946, 55.240),
            vector3(2005.055, 3773.887, 32.403),
            vector3(1701.314, 6416.028, 32.763),
            vector3(179.857, 6602.839, 31.868),
            vector3(-94.4619, 6419.594, 31.489),
            vector3(-2554.996, 2334.40, 33.078),
            vector3(-1800.375, 803.661, 138.651),
            vector3(-1437.622, -276.747, 46.207),
            vector3(-2096.243, -320.286, 13.168),
            vector3(-724.619, -935.1631, 19.213),
            vector3(-526.019, -1211.003, 18.184),
            vector3(-70.2148, -1761.792, 29.534),
            vector3(265.648, -1261.309, 29.292),
            vector3(819.653, -1028.846, 26.403),
            vector3(1208.951, -1402.567, 35.224),
            vector3(1181.381, -330.847, 69.316),
            vector3(620.843, 269.100, 103.089),
            vector3(2581.321, 362.039, 108.468),
            vector3(176.631, -1562.025, 29.263),
            vector3(-319.292, -1471.715, 30.549),
            vector3(1784.324, 3330.55, 41.253)
        }        
    },
    ["barbers"] = {
        ["sprite"] = 71,
        ["colour"] = 0,
        ["text"] = "Barbers",
        ["pos"] = {
            vector3(-814.3, -183.8, 36.6),
            vector3(136.8, -1708.4, 28.3),
            vector3(-1282.6, -1116.8, 6.0),
            vector3(1931.5, 3729.7, 31.8),
            vector3(1212.8, -472.9, 65.2),
            vector3(-32.9, -152.3, 56.1),
            vector3(-278.1, 6228.5, 30.7),
        }
    },
    ["casino"] = {
        ["sprite"] = 617,
        ["colour"] = 26,
        ["text"] = "Diamond Casino",
        ["pos"] = {
            vector3(925.08, 46.44, 81.11),
        }
    },
    ["pdm"] = {
        ["sprite"] = 227,
        ["colour"] = 30,
        ["text"] = "PDM Vehicle Shop",
        ["pos"] = {
            vector3(-34.47, -1101.51, 26.42),
        }
    },
    ["craftsman"] = {
        ["sprite"] = 66,
        ["colour"] = 12,
        ["text"] = "Craftsman",
        ["pos"] = {
            vector3(-495.28, 5286.39, 79.63),
        }
    },
    ["airport"] = {
        ["sprite"] = 90,
        ["colour"] = 9,
        ["text"] = "Airport",
        ["pos"] = {
            vector3(-1037.87, -2737.914, 20.1692),
            vector3(4494.08, -4525.847, 4.41236)
        }
    },
    ["apartments"] = {
        ["sprite"] = 475,
        ["colour"] = 4,
        ["text"] = "Apartments",
        ["pos"] = {
            vector3(-776.9959, 319.74215, 85.662658),
            vector3(-43.4213, -584.7264, 38.161083),
            vector3(-933.4, -383.97, 38.96),
            vector3(-621.02, 46.19, 43.59),
            vector3(-1447.55, -537.8, 34.74),
        }
    },
    ["offices"] = {
        ["sprite"] = 475,
        ["colour"] = 28,
        ["text"] = "Offices",
        ["pos"] = {
            vector3(-67.10777, -802.4338, 44.227275),
            vector3(-116.74, -604.78, 36.28),
            vector3(-1581.86, -557.62, 34.95),
            vector3(-1371.43, -503.88, 33.16),
        }
    },
}

Consumeables = {
    ["sandwich"] = math.random(35, 54),
    ["water_bottle"] = math.random(35, 54),
    ["toastie"] = math.random(40, 50),
    ["cola"] = math.random(35, 54),
    ["twix_bar"] = math.random(35, 54),
    ["snickers_bar"] = math.random(40, 50),
    ["coffee"] = math.random(40, 50),
    ["whiskey"] = math.random(20, 30),
    ["beer"] = math.random(30, 40),
    ["vodka"] = math.random(20, 40),
}

Config.JointEffectTime = 60

Config.IllegalItems = {
    ['weed_skunk'] = true,
    ['weed_purple-haze'] = true,
    ['weed_og-kush'] = true,
    ['weed_amniesia'] = true,
    ['weed_ak47'] = true,
    ['joint'] = true,

    ['coke_brick'] = true,
    ['coke_small_brick'] = true,
    ['cokebaggy'] = true,
    
    ['weapon_knife'] = true,
    ['weapon_pistol'] = true,
    ['weapon_snspistol'] = true,
    ['weapon_machete'] = true,
    ['weapon_pistol_mk2'] = true,
    ['weapon_combatpistol'] = true
}

StartPoints = {
	{ coords = vector3(-1037.87, -2737.914, 20.1692), desc="Cayo Perico", dest="SANAND", start="AIRP" },
	{ coords = vector3(4494.08, -4525.847, 4.41236), desc="Los Santos International", dest="AIRP", start="SANAND" }
}

Config.ContrabandNotifyPercentage = 0.20
Config.ContrabandNotifyForPolice = false

Config.PlaneQueueWait = 30 -- 30 Seconds

Config.AirportConfig = {
    ['SANAND'] = {
        Price = 0,
        CheckContraband = true,
        RequiredItems = {},
        -- DO NOT CHANGE BELOW THIS
        Destination = 'AIRP',
        Queue = {},
        InFlight = false,
        PreparingFlight = false,
        FlightController = nil,
        FlightStartTime = nil
    },
    ['AIRP'] = {
        Price = 500,
        CheckContraband = false,
        RequiredItems = {
            ['id_card'] = true
        },
        -- DO NOT CHANGE BELOW THIS
        Destination = 'SANAND',
        Queue = {},
        InFlight = false,
        PreparingFlight = false,
        FlightController = nil,
        FlightStartTime = nil
    }
}

Config.WaitingPlaneAreaLimit = 20.0

Config.Debug = false

Config.RPHintLocations = {
    [1] = {
        pos = vector3(304.06756, -739.9937, 29.316717),
        hint = "You notice the nail bar is on sale",
        range = 10, -- range player has to be to trigger notification
        notifyTime = 3, -- how long notifications shows for in seconds
        cooldown = 30, -- seconds
    },
}
---
Keys = {
    ["ESC"]       = 322,  ["F1"]        = 288,  ["F2"]        = 289,  ["F3"]        = 170,  ["F5"]  = 166,  ["F6"]  = 167,  ["F7"]  = 168,  ["F8"]  = 169,  ["F9"]  = 56,   ["F10"]   = 57, 
    ["~"]         = 243,  ["1"]         = 157,  ["2"]         = 158,  ["3"]         = 160,  ["4"]   = 164,  ["5"]   = 165,  ["6"]   = 159,  ["7"]   = 161,  ["8"]   = 162,  ["9"]     = 163,  ["-"]   = 84,   ["="]     = 83,   ["BACKSPACE"]   = 177, 
    ["TAB"]       = 37,   ["Q"]         = 44,   ["W"]         = 32,   ["E"]         = 38,   ["R"]   = 45,   ["T"]   = 245,  ["Y"]   = 246,  ["U"]   = 303,  ["P"]   = 199,  ["["]     = 116,  ["]"]   = 40,   ["ENTER"]   = 18,
    ["CAPS"]      = 137,  ["A"]         = 34,   ["S"]         = 8,    ["D"]         = 9,    ["F"]   = 23,   ["G"]   = 47,   ["H"]   = 74,   ["K"]   = 311,  ["L"]   = 182,
    ["LEFTSHIFT"] = 21,   ["Z"]         = 20,   ["X"]         = 73,   ["C"]         = 26,   ["V"]   = 0,    ["B"]   = 29,   ["N"]   = 249,  ["M"]   = 244,  [","]   = 82,   ["."]     = 81,
    ["LEFTCTRL"]  = 36,   ["LEFTALT"]   = 19,   ["SPACE"]     = 22,   ["RIGHTCTRL"] = 70, 
    ["HOME"]      = 213,  ["PAGEUP"]    = 10,   ["PAGEDOWN"]  = 11,   ["DELETE"]    = 178,
    ["LEFT"]      = 174,  ["RIGHT"]     = 175,  ["UP"]        = 27,   ["DOWN"]      = 173,
    ["NENTER"]    = 201,  ["N4"]        = 108,  ["N5"]        = 60,   ["N6"]        = 107,  ["N+"]  = 96,   ["N-"]  = 97,   ["N7"]  = 117,  ["N8"]  = 61,   ["N9"]  = 118
}
BJCore = nil
TriggerEvent('BJCore:GetObject', function(obj) BJCore = obj end)
Citizen.CreateThread(function(...) while BJCore == nil do TriggerEvent("BJCore:GetObject", function(obj) BJCore = obj end); Citizen.Wait(1000); end; end)