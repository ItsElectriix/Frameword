Config = {}

--- Drilling minigame ---
Config.Controls = {
    Accelerate = 77, -- W
    Decelerate = 78, -- S
    Forward = 172, -- UP Arrorw
    Back = 173, -- Down ArrowS
}

Config.DrillAccel = 0.005
Config.DrillDecel = 0.010
Config.MoveAccel = 0.0005
Config.MoveDecel = 0.0010
Config.TempAccel = 0.008
Config.TempDecel = 0.005
---

--- Store robbing ---
Config.StoreRobMinCops = 0
Config.StoreRobResetTimer = 50
Config.ClerkData = {
    ["model"] = GetHashKey("mp_m_shopkeep_01"), -- this is the model of the clerk that you rob.
    ["cash"] = { -- random reward between value 1 -> value 2
        2,
        5
    },
    ["cashregister"] = { -- random reward between value 1 -> value 2, 2x lootable cash registers
        2,
        6
    }
}
Config.StoreClerks = { -- this is where you want all store clerks. if you want to add more = vector4(x, y, z, heading)
    [1] = { ['pos'] = vector4(372.29217529297, 326.39370727539, 103.56636047363, 246.00857543945), ['store'] = "247 Clinton", ['robbed'] = false },
    [2] = { ['pos'] = vector4(24.215274810791, -1347.2624511719, 29.497016906738, 248.67747497559), ['store'] = "247 Strawberry", ['robbed'] = false },
    [3] = { ['pos'] = vector4(2557.1748046875, 380.64489746094, 108.62294006348, 340.8776550293), ['store'] = "247 Palomino", ['robbed'] = false },
    [4] = { ['pos'] = vector4(-3038.2673339844, 584.47491455078, 7.908935546875, 23.610481262207), ['store'] = "247 Ineseno", ['robbed'] = false },
    [5] = { ['pos'] = vector4(-3242.2670898438, 999.76306152344, 12.830704689026, 345.36389160156), ['store'] = "247 Barbareno", ['robbed'] = false},
    [6] = { ['pos'] = vector4(549.44256591797, 2671.2185058594, 42.156513214111, 75.037734985352), ['store'] = "247 Route 68", ['robbed'] = false},
    [7] = { ['pos'] = vector4(1959.9187011719, 3740.0014648438, 32.343738555908, 293.646484375), ['store'] = "247 Alhambra", ['robbed'] = false},
    [8] = { ['pos'] = vector4(1727.7840576172, 6415.3408203125, 35.037250518799, 226.98921203613), ['store'] = "247 Senora", ['robbed'] = false},
    [9] = { ['pos'] = vector4(2677.9306640625, 3279.3017578125, 55.241123199463, 317.35440063477), ['store'] = "247 Route 13", ['robbed'] = false},
    [10] = { ['pos'] = vector4(-2966.3012695313, 391.58193969727, 15.043300628662, 86.15234375), ['store'] = "RobsLiquor Great Ocean", ['robbed'] = false},
    [11] = { ['pos'] = vector4(-1487.2850341797, -376.92288208008, 40.163436889648, 153.55458068848), ['store'] = "RobsLiquor Prosperity", ['robbed'] = false},
    [12] = { ['pos'] = vector4(-1221.3229980469, -908.12780761719, 12.326356887817, 37.299858093262), ['store'] = "RobsLiquor San Andreas", ['robbed'] = false},
    [13] = { ['pos'] = vector4(1134.0545654297, -983.3251953125, 46.415802001953, 282.5920715332), ['store'] = "RobsLiquor El Rancho", ['robbed'] = false},
    [14] = { ['pos'] = vector4(1165.2305908203, 2710.9692382813, 38.157665252686, 188.72573852539), ['store'] = "RobsLiquor Route 68", ['robbed'] = false, ['playerOwnedShopId'] = 1},
    [15] = { ['pos'] = vector4(-705.91625976563, -913.41326904297, 19.215585708618, 89.320465087891), ['store'] = "LTD Vespucci", ['robbed'] = false},
    [16] = { ['pos'] = vector4(-46.958980560303, -1758.9643554688, 29.420999526978, 48.277374267578), ['store'] = "LTD Davis", ['robbed'] = false},
    [17] = { ['pos'] = vector4(1165.1630859375, -323.87414550781, 69.205047607422, 101.4720993042), ['store'] = "LTD Mirror Park", ['robbed'] = false},
    [18] = { ['pos'] = vector4(-1819.5125732422, 793.64141845703, 138.08486938477, 132.9716796875), ['store'] = "LTD Banham Canyon", ['robbed'] = false},
    [19] = { ['pos'] = vector4(1697.1395263672, 4923.4130859375, 42.063632965088, 325.30218505859), ['store'] = "LTD Grapeseed", ['robbed'] = false},
}

Config.StoreSafes = {
    [1] = vector3(378.27, 333.99, 102.87),
    [2] = vector3(28.24, -1338.68, 28.80),
    [3] = vector3(2548.73, 384.88, 108.92),
    [4] = vector3(-3048.31, 585.48, 9.71),
    [5] = vector3(-3250.61, 1004.44, 12.43),
    [6] = vector3(546.51, 2662.25, 41.56),
    [7] = vector3(1959.00, 3749.39, 31.84),
    [8] = vector3(1735.08, 6421.38, 34.54),
    [9] = vector3(2672.27, 3286.87, 54.24),
    [10] = vector3(-2959.61, 386.54, 14.04),
    [11] = vector3(-1478.47, -375.88, 39.16),
    [12] = vector3(-1221.40, -916.38, 11.33),
    [13] = vector3(1126.66, -979.56, 45.42),
    [14] = vector3(1169.87, 2717.89, 37.16),
    [15] = vector3(-710.27, -904.24, 18.82),
    [16] = vector3(-43.88, -1748.07, 28.92),
    [17] = vector3(1158.98, -314.18, 68.71),
    [18] = vector3(-1829.57, 798.37, 137.66),
    [19] = vector3(1708.19, 4920.90, 41.56),
}
---

--- Meth Cooking ---
Config.MethShowBlip = false
Config.MethPoliceJobName = "police"
Config.MethRequiredItem = 'repairkit'
Config.TrayRequiredItem = 'radio'
Config.MethRequiredMeth = 10
Config.MethRequiredTray = 10
Config.MethCookTimerA = 2 -- prepare ingredients
Config.MethCookTimerB = 3 -- cook meth
Config.MethCookTimerC = 2 -- cool meth
Config.MethCookTimerD = 2 -- package meth
Config.MethMinMethReward = 8
Config.MethMaxMethReward = 16
Config.MethItemRewardName = 'casinochips'
Config.MethHintLocation      =   vector4(1211.20, 1857.75, 78.97, 222.18)
Config.MethTruckLocations    =   {
    [1] = vector4(1060.25,-2409.26,29.96,82.70),
    [2] = vector4(-1102.33,-2039.85,13.29,309.93),
    [3] = vector4(123.30,-2580.88,6.0,177.79),
}
Config.MethDropoffLocations  =   {
    [1] = vector3(1372.69,3617.62,34.89),
    [2] = vector3(2343.59,2612.63,46.66),
    [3] = vector3(-1889.90,2045.38,140.87),
}
Config.MethTruckModels = {
    [1] = 'journey',
    --[2] = 'camper'
}
Config.MethDrawTextDist          =   2.0
Config.MethNotificationTime      =   10 -- How long the note hangs around for (when knocking on door).
Config.MethTruckSpawnDist        =   50.0
Config.MethMinSpeedForCook       =   30.0
Config.MethMaxVehicleStopTime    =   7 -- Vehicle can stop for x amount of seconds before police get notified.
---

--- Safe Cracker ---
Config.SCConfig = {
	LockTolerance	= 2, -- How many clicks past the pin can the player go before the lock fails							

	AudioBankName 	= "SAFE_CRACK",						
	TextureDict 	= "MFSCTextureDict",

	SafeSoundset 	= "SAFE_CRACK_SOUNDSET",
	SafeTurnSound	= "tumbler_turn",
	SafePinSound	= "tumbler_pin_fall",
	SafeFinalSound	= "tumbler_pin_fall_final",
	SafeResetSound	= "tumbler_reset",
	SafeOpenSound	= "safe_door_open",
}

Config.SCSafeModels = {
	Safe  	= "bkr_prop_biker_safebody_01a",
	Door  	= "bkr_prop_biker_safedoor_01a",
}

Config.SCSafeObjects = {
	safeObj  = { ModelName = Config.SCSafeModels.Safe,  Pos 	= vector3(   0.0,   0.0,   -0.1 ), Heading =  3.7,   Rot = vector3(   0.0,   0.0,    0.0), 			Frozen = false },
	doorObj  = { ModelName = Config.SCSafeModels.Door,  Pos 	= vector3(   0.0,   0.0,    0.0 ), Heading =  3.7,   Rot = vector3(   0.0,   0.0,    0.0), 			Frozen = true  },
}
---

-- Mug config ---
Config.MugCopsNeeded = 2
---

--- Chopshop Config ---

Config.CSLocations = {
    [1] = {
        ["main"] = vector3(2397.42, 3089.44, 49.92),
        ["deliver"] = vector3(2351.5, 3132.96, 48.2),
        ["list"] = vector3(2403.51, 3127.95, 48.15),
    }
}

Config.CSItems = {
    "metalscrap",
    "plastic",
    "copper",
    "iron",
    "aluminum",
    "steel",
    "glass",
}

Config.CSCurrentVehicles = {}

Config.CSVehicles = {
    [1] = "ninef",
    [2] = "ninef2",
    [3] = "banshee",
    [4] = "alpha",
    [5] = "baller", 
    [6] = "bison", 
    [7] = "huntley", 
    [8] = "f620", 
    [9] = "asea", 
    [10] = "pigalle",
    [11] = "bullet", 
    [12] = "turismor", 
    [13] = "zentorno", 
    [14] = "dominator",
    [15] = "blade",
    [16] = "chino",
    [17] = "sabregt",
    [18] = "bati",
    [19] = "carbonrs",
    [20] = "akuma",
    [21] = "thrust",
    [22] = "exemplar",
    [23] = "felon",
    [24] = "sentinel",
    [25] = "blista",
    [26] = "fusilade",
    [27] = "jackal",
    [28] = "blista2",
    [29] = "rocoto", 
    [30] = "seminole", 
    [31] = "landstalker",
    [32] = "picador",
    [33] = "prairie", 
    [34] = "bobcatxl", 
    [35] = "gauntlet",
    [36] = "virgo",
    [37] = "fq2",
    [38] = "jester",
    [39] = "rhapsody",
    [40] = "feltzer2",
}

Config.MaleNoGloves = {
    [0] = true,
    [1] = true,
    [2] = true,
    [3] = true,
    [4] = true,
    [5] = true,
    [6] = true,
    [7] = true,
    [8] = true,
    [9] = true,
    [10] = true,
    [11] = true,
    [12] = true,
    [13] = true,
    [14] = true,
    [15] = true,
    [18] = true,
    [26] = true,
    [52] = true,
    [53] = true,
    [54] = true,
    [55] = true,
    [56] = true,
    [57] = true,
    [58] = true,
    [59] = true,
    [60] = true,
    [61] = true,
    [62] = true,
    [112] = true,
    [113] = true,
    [114] = true,
    [118] = true,
    [125] = true,
    [132] = true,
}

Config.FemaleNoGloves = {
    [0] = true,
    [1] = true,
    [2] = true,
    [3] = true,
    [4] = true,
    [5] = true,
    [6] = true,
    [7] = true,
    [8] = true,
    [9] = true,
    [10] = true,
    [11] = true,
    [12] = true,
    [13] = true,
    [14] = true,
    [15] = true,
    [19] = true,
    [59] = true,
    [60] = true,
    [61] = true,
    [62] = true,
    [63] = true,
    [64] = true,
    [65] = true,
    [66] = true,
    [67] = true,
    [68] = true,
    [69] = true,
    [70] = true,
    [71] = true,
    [129] = true,
    [130] = true,
    [131] = true,
    [135] = true,
    [142] = true,
    [149] = true,
    [153] = true,
    [157] = true,
    [161] = true,
    [165] = true,
}

Config.MaleNoMask = {

}

Config.FemaleNoMask = {
    
}

--- Money Wash Config
Config.MWHintLocations = {
    [1] = vector4(211.26, -1855.32, 27.19, 141.48),
    -- [2] = vector4(),
    -- [3] = vector4()
}

Config.MWStartLocations = {
    [1] = {
        ["pos"] = vector4(-2949.83, 455.34, 15.32, 272.26),
        ["hint"] = "near one of his businesses near Vespucci beach, north of the pier. Very noticiable, dressed smart and usually wearing some sort of tie. Don\'t. Get. Caught.",
        ["ped"] = 'a_m_y_business_02',
        ["veh"] = vector4(-2964.70, 443.74, 14.82, 87.68)
    },
    [2] = {
        ["pos"] = vector4(145.57, -240.95, 51.50, 155.28),
        ["ped"] = -1289578670,
        ["hint"] = "near one of his businesses on Hawick Avenue, usually on the east side. You'll probably find him wearing some blue/greyish suit vest. He never takes that thing off! Don't mention that though.",
        ["veh"] = vector4(143.99, -253.07, 50.98, 70.54),
    },
    [3] = {
        ["pos"] = vector4(231.25, -1752.61, 28.99, 227.0),
        ["ped"] = -573920724,
        ["hint"] = "near one of his businesses in the south side. Around Carson Avenue/Brogue Avenue. I've seen him around the barber shop there. He usually wears some ugly ass sweater vests. Also, don't piss off the locals around there..",
        ["veh"] = vector4(240.13, -1741.24, 28.53, 55.53),
    },
    [4] = {
        ["pos"] = vector4(1152.69, -432.00, 67.01, 71.91),
        ["ped"] = -264140789,
        ["hint"] = "near one of his businesses in the Mirror Park area. He's probably high off his own products, crazy looking fella. Peace and love and all that. Don't stare at his hair too long. ",
        ["veh"] = vector4(1131.67, -433.49, 66.06, 164.39),
    }, 
    -- [5] = {
    --     ["pos"] = vector4(-1250.86, -271.90, 38.99, 25.98),
    --     ["ped"] = 365775923,
    --     ["hint"] = "near one of his businesses in the Mirror Park area. He's probably high off his own products, crazy looking fella. Peace and love and all that. Don't stare at his hair too long. ",
    --     ["veh"] = vector4(-1258.18, -262.24, 38.71, 116.38),
    -- },            
}

-- Config.MWDropOffs = {
--     [1] = vector4(),
--     -- [2] = vector4(),
--     -- [3] = vector4(),
-- }
---

--- Hacking Locations
Config.StartHackLoc = vector4(387.54, 3584.62, 32.29, 346.47)
Config.HackLocations = {
    [1] = {
        text = '24/7 Stores | ~g~Intel', -- text used for draw text
        pos = vector3(758.07, -1912.05, 29.46),
        type = 'store', -- type of intel requested
        reqLvl = 60, -- required level to start request
        reqItem = false, -- false if not required to start (can 'cost' item/cash/crypto after initial request)
        reqItemAmount = false,
        reqCrypto = false, -- false if not required to start (can 'cost' item/cash/crypto after initial request)
    },
    [2] = {
        text = "Crypto Stick Decryption",
        pos = vector3(753.94, -1903.61, 29.46),
        type = 'decryptcrypto',
        reqLvl = 40,
        reqItem = 'cryptostick',
        reqItemAmount = 1,
        reqCrypto = false
    },
    [3] = {
        text = "Decrypt",
        pos = vector3(759.49, -1911.92, 29.46),
        type = 'decrypt',
        reqLvl = 70,
        reqItem = false,
        reqItemAmount = false,
        reqCrypto = false
    },    
}

--- Missions

Config.MissionDifficulty = {
    ["easy"] = {
        NPCAmount = 3,
        weapons = {
            [1] = "weapon_machete",
            [2] = "weapon_knife",
        },
        accuracy = 40
    },
    ["medium"] = {
        NPCAmount = 6,
        weapons = {
            [1] = "weapon_pistol",
            [2] = "weapon_combatpistol",
        },
        accuracy = 70
    },
    ["hard"] = {
        NPCAmount = 9,
        weapons = {
            [1] = "weapon_minismg",
            [2] = "weapon_smg",
        },
        accuracy = 100,
    },
}

Config.MissionTypes = {
    [1] = "car",
    [2] = "arms",
    [3] = "deliver"
}

Config.MissionGivers = {
    ["car"] = {
        pos = vector4(-546.0974, -873.4445, 27.198963, 177.98167),
        model = "a_m_y_stbla_01",
    },
    ["arms"] = {
        pos = vector4(728.50189, -238.152, 66.12928, 297.16268),
        model = "a_m_y_latino_01",
    },
    ["deliver"] = {
        pos = vector4(-1277.596, -1301.912, 4.0228118, 133.33929),
        model = "a_m_y_cyclist_01",
    },
}

Config.MissionTypeTitles = {
    ["car"] = "Car Delivery",
    ["arms"] = "Arms Dealing",
    ["deliver"] = "Package Delivery"
}

Config.CarMissionDelivery = {
    [1] = vector3(968.44561, -2207.698, 30.125053),
    [2] = vector3(-582.6219, -1777.222, 22.173171),
    [3] = vector3(-611.6448, 346.47805, 84.686027),
}

Config.Missions = {
    [1] = {
        name = "Test Car Mission",
        type = "car", -- car | arms | deliver
        policeReq = 0,
        cooldown = 180, -- minutes
        timer = 20, -- minutes to complete mission or set to false for no time
        start = vector4(1869.6674, 2702.4106, 45.834201, 116.43103),
        startPed = "a_f_y_vinewood_03",
        difficulties = {
            [1] = "easy",
            [2] = "medium",
            [3] = "hard"
        },
        require = {
            ["easy"] = {
                [1] = {
                    type = "item", -- item | cash | bank | rep
                    itemName = "phone",
                    amount = 2,
                },
                [2] = {
                    type = "rep",
                    repName = "dealerrep",
                    amount = 10
                }
            },
            ["medium"] = {
                [1] = {
                    type = "item", -- item | cash | bank | rep
                    itemName = "phone",
                    amount = 2,
                },
                [2] = {
                    type = "rep",
                    repName = "dealerrep",
                    amount = 10
                }
            },
            ["hard"] = {
                [1] = {
                    type = "item", -- item | cash | bank | rep
                    itemName = "phone",
                    amount = 2,
                },
                [2] = {
                    type = "rep",
                    repName = "dealerrep",
                    amount = 10
                }
            },
        },
        mission = {
            location = vector4(-1532.168, -405.948, 41.321182, 228.94583),
            model = "tempesta",
            NPCSpawns = { -- false for no hostile AI | car = spawns at car location | arms = spawns at arms dealing loaction | deliver = spawns at delivery location
                [1] = vector4(-1566.874, -406.3395, 42.387882, 311.20059),
                [2] = vector4(-1564.966, -404.2142, 42.388, 137.92205),
                [3] = vector4(-1559.691, -422.8243, 39.635879, 211.82279),
                [4] = vector4(-1552.338, -432.8387, 42.152896, 41.668247),
                [5] = vector4(-1505.485, -367.9636, 42.400596, 40.524665),
                [6] = vector4(-1510.323, -363.3494, 42.635654, 246.72534),
            }
        },
        rewards = { -- once all is complete
            ["easy"] = {
                [1] = {
                    chance = 100, -- percentage chance out of 100
                    type = "item", -- item | cash | bank | rep
                    itemName = "repairkit",
                    amount = 1, -- amount to reward
                },
                [2] = {
                    chance = 50,
                    type = "item",
                    itemName = "radio",
                    amount = {
                        min =  1,
                        max = 3,
                    }
                },
                [3] = {
                    chance = 25,
                    type = "rep",
                    repName = "hackerrep",
                    amount = {
                        min =  1,
                        max = 3,
                    }
                },
                [4] = {
                    chance = 100,
                    type = "cash",
                    amount = 250
                } 
            },
            ["medium"] = {
                [1] = {
                    chance = 100, -- percentage chance out of 100
                    type = "item", -- item | cash | bank | rep
                    itemName = "repairkit",
                    amount = 1, -- amount to reward
                },
                [2] = {
                    chance = 50,
                    type = "item",
                    itemName = "radio",
                    amount = {
                        min =  1,
                        max = 3,
                    }
                },
                [3] = {
                    chance = 25,
                    type = "rep",
                    repName = "hackerrep",
                    amount = {
                        min =  1,
                        max = 3,
                    }
                },
                [4] = {
                    chance = 100,
                    type = "cash",
                    amount = 250
                } 
            },
            ["hard"] = {
                [1] = {
                    chance = 100, -- percentage chance out of 100
                    type = "item", -- item | cash | bank | rep
                    itemName = "repairkit",
                    amount = 1, -- amount to reward
                },
                [2] = {
                    chance = 50,
                    type = "item",
                    itemName = "radio",
                    amount = {
                        min =  1,
                        max = 3,
                    }
                },
                [3] = {
                    chance = 25,
                    type = "rep",
                    repName = "hackerrep",
                    amount = {
                        min =  1,
                        max = 3,
                    }
                },
                [4] = {
                    chance = 100,
                    type = "cash",
                    amount = 250
                } 
            },
        },
    },
    [2] = {
        name = "Test Arms Mission",
        type = "arms", -- car | arms | deliver
        policeReq = 0,
        cooldown = 180, -- minutes
        timer = false, -- minutes to complete mission or set to false for no time
        start = vector4(159.49916, -253.6598, 51.399631, 158.01167),
        startPed = "a_m_y_stwhi_02",
        difficulties = {
            [1] = "medium",
            [2] = "hard"
        },
        require = {
            ["medium"] = {
                [1] = {
                    type = "item", -- item | cash | bank | rep
                    itemName = "phone",
                    amount = 2,
                },
                [2] = {
                    type = "rep",
                    repName = "dealerrep",
                    amount = 10
                } 
            },
            ["hard"] = {
                [1] = {
                    type = "item", -- item | cash | bank | rep
                    itemName = "phone",
                    amount = 2,
                },
                [2] = {
                    type = "rep",
                    repName = "dealerrep",
                    amount = 10
                } 
            },
        },
        mission = {
            location = vector4(323.10241, -2089.549, 17.742692, 41.672828),
            lootPos = vector3(323.93261, -2089.523, 17.754457),
            lootTime = 45, -- seconds
            scene = {
                vehicles = {
                    [1] = {
                        pos = vector4(326.26705, -2087.22, 17.3435, 50.846473),
                        model = "tampa"
                    },
                    [2] = {
                        pos = vector4(319.15039, -2092.072, 17.244911, 359.34365),
                        model = "moonbeam"
                    }
                },
                objects = {
                    [1] = {
                        pos = vector4(324.8237, -2090.25, 16.74891, 137.433),
                        model = -490398359,
                    },
                    [2] = {
                        pos = vector4(321.8001, -2091.917, 16.784, 123.258),
                        model = 539422188,
                    },
                },
                peds = {
                    [1] = {
                        pos = vector4(325.41275, -2088.644, 17.81282, 60.073348),
                        model = "a_m_y_soucent_02",
                        weapon = false,
                    },
                    [2] = {
                        pos = vector4(323.03277, -2090.932, 17.705623, 25.606142),
                        model = "a_m_m_og_boss_01",
                        weapon = "weapon_snspistol",
                    },
                    [3] = {
                        pos = vector4(317.27108, -2090.886, 17.573163, 346.59671),
                        model = "a_m_m_beach_01",
                        weapon = "weapon_bat",
                    },
                    [4] = {
                        pos = vector4(325.92526, -2084.91, 17.92984, 68.873283),
                        model = "a_m_m_mexlabor_01",
                        weapon = "weapon_snspistol",
                    },
                    [5] = {
                        pos = vector4(321.13739, -2088.899, 17.73862, 17.907087),
                        model = "a_m_m_soucent_01",
                        weapon = false,
                    },
                    [6] = {
                        pos = vector4(323.07205, -2087.747, 17.810878, 44.117881),
                        model = "a_m_y_cyclist_01",
                        weapon = false,
                    },
                }
            },
            NPCSpawns = {
                [1] = vector4(347.09902, -2075.276, 20.857231, 138.80325),
                [2] = vector4(342.43795, -2099.401, 18.217498, 280.10913),
                [3] = vector4(315.99639, -2108.415, 17.79441, 26.365018),
                [4] = vector4(300.55532, -2102.947, 17.346387, 303.28585),
                [5] = vector4(306.30996, -2044.914, 20.913593, 154.73992),
                [6] = vector4(286.27597, -2068.755, 17.667535, 257.68591),
            }
        },
        rewards = { -- once all is complete
            ["medium"] = {
                [1] = {
                    chance = 100, -- percentage chance out of 100
                    type = "item", -- item | cash | bank | rep
                    itemName = "repairkit",
                    amount = 1, -- amount to reward
                },
                [2] = {
                    chance = 50,
                    type = "item",
                    itemName = "radio",
                    amount = {
                        min =  1,
                        max = 3,
                    }
                },
                [3] = {
                    chance = 25,
                    type = "rep",
                    repName = "hackerrep",
                    amount = {
                        min =  1,
                        max = 3,
                    }
                },
                [4] = {
                    chance = 100,
                    type = "cash",
                    amount = 250
                } 
            },
            ["hard"] = {
                [1] = {
                    chance = 100, -- percentage chance out of 100
                    type = "item", -- item | cash | bank | rep
                    itemName = "repairkit",
                    amount = 1, -- amount to reward
                },
                [2] = {
                    chance = 50,
                    type = "item",
                    itemName = "radio",
                    amount = {
                        min =  1,
                        max = 3,
                    }
                },
                [3] = {
                    chance = 25,
                    type = "rep",
                    repName = "hackerrep",
                    amount = {
                        min =  1,
                        max = 3,
                    }
                },
                [4] = {
                    chance = 100,
                    type = "cash",
                    amount = 250
                } 
            },
        },
    },
    [3] = {
        name = "Test Deliver Mission",
        type = "deliver", -- car | arms | deliver
        policeReq = 0,
        cooldown = 180, -- minutes
        timer = 25, -- minutes to complete mission or set to false for no time
        start = vector4(945.76336, -1138.267, 26.500993, 0.203192),
        startPed = "a_m_y_skater_01",
        difficulties = {
            [1] = "easy",
            [2] = "medium",
        },
        require = {
            ["easy"] = {
                [1] = {
                    type = "item", -- item | cash | bank | rep
                    itemName = "phone",
                    amount = 2,
                },
                [2] = {
                    type = "rep",
                    repName = "dealerrep",
                    amount = 10
                } 
            },
            ["medium"] = {
                [1] = {
                    type = "item", -- item | cash | bank | rep
                    itemName = "phone",
                    amount = 2,
                },
                [2] = {
                    type = "rep",
                    repName = "dealerrep",
                    amount = 10
                } 
            },
        },
        mission = {
            location = vector4(1165.1871, -1347.252, 36.187583, 269.20071), -- drop off location
            pedModel = "a_m_y_eastsa_02", -- drop off ped model
            deliverTime = 45, -- seconds
            NPCSpawns = { -- possible AI spawns
                [1] = vector4(1155.8477, -1356.641, 34.698715, 271.99987),
                [2] = vector4(1163.8201, -1334.795, 34.738895, 257.40509),
                [3] = vector4(1192.1534, -1364.438, 35.207004, 292.42083),
                [4] = vector4(1186.5811, -1381.993, 35.011554, 4.6515316),
            }
        },
        rewards = { -- once all is complete
            ["easy"] = {
                [1] = {
                    chance = 100, -- percentage chance out of 100
                    type = "item", -- item | cash | bank | rep
                    itemName = "repairkit",
                    amount = 1, -- amount to reward
                },
                [2] = {
                    chance = 50,
                    type = "item",
                    itemName = "radio",
                    amount = {
                        min =  1,
                        max = 3,
                    }
                },
                [3] = {
                    chance = 25,
                    type = "rep",
                    repName = "hackerrep",
                    amount = {
                        min =  1,
                        max = 3,
                    }
                },
                [4] = {
                    chance = 100,
                    type = "cash",
                    amount = 250
                } 
            },
            ["medium"] = {
                [1] = {
                    chance = 100, -- percentage chance out of 100
                    type = "item", -- item | cash | bank | rep
                    itemName = "repairkit",
                    amount = 1, -- amount to reward
                },
                [2] = {
                    chance = 50,
                    type = "item",
                    itemName = "radio",
                    amount = {
                        min =  1,
                        max = 3,
                    }
                },
                [3] = {
                    chance = 25,
                    type = "rep",
                    repName = "hackerrep",
                    amount = {
                        min =  1,
                        max = 3,
                    }
                },
                [4] = {
                    chance = 100,
                    type = "cash",
                    amount = 250
                } 
            },
        },
    },
}

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