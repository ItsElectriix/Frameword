Config = {}

local StringCharset = {}
local NumberCharset = {}

for i = 48,  57 do table.insert(NumberCharset, string.char(i)) end
for i = 65,  90 do table.insert(StringCharset, string.char(i)) end
for i = 97, 122 do table.insert(StringCharset, string.char(i)) end

Config.RadioChannels = { '1', '2', '3', '4', '5' }

Config.UseHandcuffSkillcheck = true
Config.HandcuffSkillcheckCooldown = 30 * 1000

Config.HandcuffSkillcheck = {
    difficulty = {
        min = 3,
        max = 5
    },
    speed = {
        min = 5,
        max = 7
    },
    stages = {
        min = 1,
        max = 2
    },
    stageTimeout = 2500
}

Config.RandomStr = function(length)
	if length > 0 then
		return Config.RandomStr(length-1) .. StringCharset[math.random(1, #StringCharset)]
	else
		return ''
	end
end

Config.RandomInt = function(length)
	if length > 0 then
		return Config.RandomInt(length-1) .. NumberCharset[math.random(1, #NumberCharset)]
	else
		return ''
	end
end

Config.Objects = {
    ["cone"] = {model = `prop_roadcone02a`, freeze = false},
    ["barier"] = {model = `prop_barrier_work06a`, freeze = true},
    ["schotten"] = {model = `prop_snow_sign_road_06g`, freeze = true},
    ["tent"] = {model = `prop_gazebo_03`, freeze = true},
    ["light"] = {model = `prop_worklight_03b`, freeze = true},
}

Config.GPSItem = "radio"

Config.Locations = {
    ["duty"] = {
        [1] = vector3(443.52, -986.39, 30.69), -- MRPD
        [2] = vector3(-565.20, -112.16, 33.88), -- Rockford
        [3] = vector3(1853.25, 3689.90, 34.27), -- Sandy 
	    [4] = vector3(-449.4675, 6012.421, 31.71637), -- Paleto
    },    
    ["vehicle"] = {
        [1] = vector4(448.159, -1017.41, 28.562, 90.654), -- MRPD Front
        [2] = vector4(471.13, -1024.05, 28.17, 274.5), -- MRPD Back
        [3] = vector4(-589.44, -111.66, 33.71, 202.26), -- Rockford
        [4] = vector4(1854.07, 3675.59, 33.74, 209.72), -- Sandy
        [5] = vector4(457.98, -978.26, 25.73, 88.39), -- MRPD Garage    
	    [6] = vector4(-455.6963, 6001.905, 31.34055, 83.09), -- Paleto
    },    
    ["stash"] = {
        [1] = vector3(484.39, -1002.052, 25.73), -- MRPD
        [2] = vector3(-570.10, -110.04, 33.88), -- Rockford
        [3] = vector3(1845.76, 3692.47, 34.27), -- Sandy  
	    [4] = vector3(-439.976, 5991.949, 31.71616), -- Paleto
    },     
    ["impound"] = {
        [1] = vector4(426.76, -976.54, 25.30, 269.13), -- MRPD
	    [2] = vector4(-475.2777, 6031.419, 31.34051, 223.68), -- Paleto
    }, 
    ["helicopter"] = {
        [1] = vector4(449.168, -981.325, 43.691, 87.234), -- MRPD
        [2] = vector4(-475.43, 5988.353, 31.716, 31.34), -- Paleto
        [3] = vector4(1868.96, 3648.35, 33.91, 34.21), -- Sandy        
    }, 
    ["boat"] = {
        [1]  = {
            ["garage"] = vector3(-788.3789, -1490.228, 1.5952168),
            ["spawn"] = vector4(-798.5255, -1498.62, 0.6390879, 108.3442)
        },
    },
    ["armory"] = {
        [1] = vector3(485.38, -1006.48, 25.73), -- MRPD
        [2] = vector3(-578.82, -114.64, 33.88), -- Rockford
        [3] = vector3(1841.89, 3690.39, 34.27), -- Sandy      
	    [4] = vector3(-437.7839, 5988.309, 31.71616), -- Paleto
    },   
    ["trash"] = {
        [1] = vector3(471.62, -1008.45, 34.22), -- MRPD
        [2] = vector3(-549.79, -106.44, 33.87), -- Rockford
        [3] = vector3(1855.49, 3698.41, 34.27), -- Sandy      
    },      
    ["fingerprint"] = {
        [1] = vector3(442.35, -975.55, 34.19), -- MRPD
        [2] = vector3(-442.38, 6011.90, 27.98), -- Rockford
        [3] = vector3(1848.59, 3680.68, 30.26), -- Sandy       
	    [4] = vector3(-432.8408, 5997.833, 31.7162), -- Paleto
    },
    ["evidence"] = {
        [1] = vector3(475.19, -1007.43, 34.22), -- MRPD
        [2] = vector3(-550.53, -98.10, 33.87), -- Rockford
        [3] = vector3(1856.39, 3700.14, 34.27), -- Sandy      
	    [4] = vector3(-441.1817, 5986.616, 31.7162), -- Paleto
    },           
    ["stations"] = {
        [1] = {label = "Police Station", coords = {x = 428.23, y = -984.28, z = 29.76, h = 3.5}},
        [2] = {label = "Prison", coords = {x = 1845.903, y = 2585.873, z = 45.672, h = 272.249}},
        [3] = {label = "Police Station Paleto", coords = {x = -451.55, y = 6014.25, z = 31.716, h = 223.81}},
    },
    ["ids"] = {
        [1] = vector3(471.3578, -1005.4, 30.70545), -- MRPD
   }
}

Config.ArmoryWhitelist = {
    "OHC01182", -- Josh
    "DDU55020", -- Goldster
    "IDO32853" -- Dawed
}

Config.UCWhitelist = {
    "DDU55020", -- Goldster
    "IDO32853", -- Dawed
    "OHC01182", -- Josh
    "NPA95703", -- CMF
    "KXN27245", -- CMF
    "MLP02971", -- Zowogh
    "CNV67019", -- Zowogh?   
    "XCS85530", -- BanHammer
    "KTT00465", -- Stamina
    "QPS41182", -- Vinr
    "ENR90853", -- Coxy
    "KCQ48960", -- Bally
    "AJB07962" -- Andromeda
}

Config.SwatWhitelist = {
    "DDU55020", -- Goldster 
    "OHC01182", -- Josh
    "XCS85530", -- BanHammer
    "KTT00465", -- Stamina
    "QPS41182", -- Vinr
    "ENR90853", -- Coxy
    "KCQ48960", -- Bally
}

Config.Helicopter = "polmav"

Config.Boat = "predator"

Config.SecurityCameras = {
    hideradar = false,
    cameras = {
        [1] = {label = "Pacific Bank CAM#1", x = 257.45, y = 210.07, z = 109.08, r = {x = -25.0, y = 0.0, z = 28.05}, canRotate = false, isOnline = true},
        [2] = {label = "Pacific Bank CAM#2", x = 232.86, y = 221.46, z = 107.83, r = {x = -25.0, y = 0.0, z = -140.91}, canRotate = false, isOnline = true},
        [3] = {label = "Pacific Bank CAM#3", x = 252.27, y = 225.52, z = 103.99, r = {x = -35.0, y = 0.0, z = -74.87}, canRotate = false, isOnline = true},
        [4] = {label = "Limited Ltd Grove St. CAM#1", x = -53.1433, y = -1746.714, z = 31.546, r = {x = -35.0, y = 0.0, z = -168.9182}, canRotate = false, isOnline = true},
        [5] = {label = "Rob's Liqour Prosperity St. CAM#1", x = -1482.9, y = -380.463, z = 42.363, r = {x = -35.0, y = 0.0, z = 79.53281}, canRotate = false, isOnline = true},
        [6] = {label = "Rob's Liqour San Andreas Ave. CAM#1", x = -1224.874, y = -911.094, z = 14.401, r = {x = -35.0, y = 0.0, z = -6.778894}, canRotate = false, isOnline = true},
        [7] = {label = "Limited Ltd Ginger St. CAM#1", x = -718.153, y = -909.211, z = 21.49, r = {x = -35.0, y = 0.0, z = -137.1431}, canRotate = false, isOnline = true},
        [8] = {label = "24/7 Supermarkt Innocence Blvd. CAM#1", x = 23.885, y = -1342.441, z = 31.672, r = {x = -35.0, y = 0.0, z = -142.9191}, canRotate = false, isOnline = true},
        [9] = {label = "Rob's Liqour El Rancho Blvd. CAM#1", x = 1133.024, y = -978.712, z = 48.515, r = {x = -35.0, y = 0.0, z = -137.302}, canRotate = false, isOnline = true},
        [10] = {label = "Limited Ltd West Mirror Drive CAM#1", x = 1151.93, y = -320.389, z = 71.33, r = {x = -35.0, y = 0.0, z = -119.4468}, canRotate = false, isOnline = true},
        [11] = {label = "24/7 Supermarkt Clinton Ave CAM#1", x = 383.402, y = 328.915, z = 105.541, r = {x = -35.0, y = 0.0, z = 118.585}, canRotate = false, isOnline = true},
        [12] = {label = "Limited Ltd Banham Canyon Dr CAM#1", x = -1832.057, y = 789.389, z = 140.436, r = {x = -35.0, y = 0.0, z = -91.481}, canRotate = false, isOnline = true},
        [13] = {label = "Rob's Liqour Great Ocean Hwy CAM#1", x = -2966.15, y = 387.067, z = 17.393, r = {x = -35.0, y = 0.0, z = 32.92229}, canRotate = false, isOnline = true},
        [14] = {label = "24/7 Supermarkt Ineseno Road CAM#1", x = -3046.749, y = 592.491, z = 9.808, r = {x = -35.0, y = 0.0, z = -116.673}, canRotate = false, isOnline = true},
        [15] = {label = "24/7 Supermarkt Barbareno Rd. CAM#1", x = -3246.489, y = 1010.408, z = 14.705, r = {x = -35.0, y = 0.0, z = -135.2151}, canRotate = false, isOnline = true},
        [16] = {label = "24/7 Supermarkt Route 68 CAM#1", x = 539.773, y = 2664.904, z = 44.056, r = {x = -35.0, y = 0.0, z = -42.947}, canRotate = false, isOnline = true},
        [17] = {label = "Rob's Liqour Route 68 CAM#1", x = 1169.855, y = 2711.493, z = 40.432, r = {x = -35.0, y = 0.0, z = 127.17}, canRotate = false, isOnline = true},
        [18] = {label = "24/7 Supermarkt Senora Fwy CAM#1", x = 2673.579, y = 3281.265, z = 57.541, r = {x = -35.0, y = 0.0, z = -80.242}, canRotate = false, isOnline = true},
        [19] = {label = "24/7 Supermarkt Alhambra Dr. CAM#1", x = 1966.24, y = 3749.545, z = 34.143, r = {x = -35.0, y = 0.0, z = 163.065}, canRotate = false, isOnline = true},
        [20] = {label = "24/7 Supermarkt Senora Fwy CAM#2", x = 1729.522, y = 6419.87, z = 37.262, r = {x = -35.0, y = 0.0, z = -160.089}, canRotate = false, isOnline = true},
        [21] = {label = "Fleeca Bank Hawick Ave CAM#1", x = 309.341, y = -281.439, z = 55.88, r = {x = -35.0, y = 0.0, z = -146.1595}, canRotate = false, isOnline = true},
        [22] = {label = "Fleeca Bank Legion Square CAM#1", x = 144.871, y = -1043.044, z = 31.017, r = {x = -35.0, y = 0.0, z = -143.9796}, canRotate = false, isOnline = true},
        [23] = {label = "Fleeca Bank Hawick Ave CAM#2", x = -355.7643, y = -52.506, z = 50.746, r = {x = -35.0, y = 0.0, z = -143.8711}, canRotate = false, isOnline = true},
        [24] = {label = "Fleeca Bank Del Perro Blvd CAM#1", x = -1214.226, y = -335.86, z = 39.515, r = {x = -35.0, y = 0.0, z = -97.862}, canRotate = false, isOnline = true},
        [25] = {label = "Fleeca Bank Great Ocean Hwy CAM#1", x = -2958.885, y = 478.983, z = 17.406, r = {x = -35.0, y = 0.0, z = -34.69595}, canRotate = false, isOnline = true},
        [26] = {label = "Paleto Bank CAM#1", x = -102.939, y = 6467.668, z = 33.424, r = {x = -35.0, y = 0.0, z = 24.66}, canRotate = false, isOnline = true},
        [27] = {label = "Del Vecchio Liquor Paleto Bay", x = -163.75, y = 6323.45, z = 33.424, r = {x = -35.0, y = 0.0, z = 260.00}, canRotate = false, isOnline = true},
        [28] = {label = "Don's Country Store Paleto Bay CAM#1", x = 166.42, y = 6634.4, z = 33.69, r = {x = -35.0, y = 0.0, z = 32.00}, canRotate = false, isOnline = true},
        [29] = {label = "Don's Country Store Paleto Bay CAM#2", x = 163.74, y = 6644.34, z = 33.69, r = {x = -35.0, y = 0.0, z = 168.00}, canRotate = false, isOnline = true},
        [30] = {label = "Don's Country Store Paleto Bay CAM#3", x = 169.54, y = 6640.89, z = 33.69, r = {x = -35.0, y = 0.0, z = 5.78}, canRotate = false, isOnline = true},
        [31] = {label = "Vangelico Juwelier CAM#1", x = -627.54, y = -239.74, z = 40.33, r = {x = -35.0, y = 0.0, z = 5.78}, canRotate = true, isOnline = true},
        [32] = {label = "Vangelico Juwelier CAM#2", x = -627.51, y = -229.51, z = 40.24, r = {x = -35.0, y = 0.0, z = -95.78}, canRotate = true, isOnline = true},
        [33] = {label = "Vangelico Juwelier CAM#3", x = -620.3, y = -224.31, z = 40.23, r = {x = -35.0, y = 0.0, z = 165.78}, canRotate = true, isOnline = true},
        [34] = {label = "Vangelico Juwelier CAM#4", x = -622.57, y = -236.3, z = 40.31, r = {x = -35.0, y = 0.0, z = 5.78}, canRotate = true, isOnline = true},
    },
}

Config.Vehicles = {
    ["fpiuleg2"] = "Ford Explorer",
    ["tarleg"] = "Ford Taurus",
    ["bikeleg2"] = "Motorbike",
    ["mustang19"] = "Mustang",
    ["charger"] = "Dodge Charger",
    ["tahoe13"] = "Chevy Tahoe",
    ["crownvic"] = "Crown Victoria",
    ["ramleg"] = "Dodge Ram"
}

Config.WhitelistedVehicles = {
    --["pcharger"] = "Dodge Charger (UC)",
}

Config.UCVehicles = {
    ["fibc"] = "Unmarked 4x4",
    ["fibd"] = "Unmarked Dominatorr",
    ["fibn2"] = "Unmarked Minicat",
    ["fibs"] = "Unmarked Speedo",
    ["fibg2"] = "Unmarked Landstalker",
    ["fibd2"] = "Unmarked Drafter",
    ["fibj"] = "Unmarked Ocelot",
    ["fibn3"] = "Unmarked Lampadanti",
    ["fibr"] = "Unmarked Rumpo",
}

Config.SwatVehicles = {
    ["bear01"] = "BearCat",
    ["sub"] = "Suburban",
}

Config.AmmoLabels = {
    ["AMMO_PISTOL"] = "9x19mm bullet",
    ["AMMO_SMG"] = "9x19mm bullet",
    ["AMMO_RIFLE"] = "7.62x39mm bullet",
    ["AMMO_MG"] = "7.92x57mm bullet",
    ["AMMO_SHOTGUN"] = "12-Gauge shell",
    ["AMMO_SNIPER"] = "Large caliber bullet",
}

Config.Radars = {
	vector4(-623.44421386719, -823.08361816406, 25.25704574585, 145.0),
	vector4(-652.44421386719, -854.08361816406, 24.55704574585, 325.0),
	vector4(1623.0114746094, 1068.9924316406, 80.903594970703, 84.0),
	vector4(-2604.8994140625, 2996.3391113281, 27.528566360474, 175.0),
	vector4(2136.65234375, -591.81469726563, 94.272926330566, 318.0),
	vector4(2117.5764160156, -558.51013183594, 95.683128356934, 158.0),
	vector4(406.89505004883, -969.06286621094, 29.436267852783, 33.0),
	vector4(657.315, -218.819, 44.06, 320.0),
	vector4(2118.287, 6040.027, 50.928, 172.0),
	vector4(-106.304, -1127.5530, 30.778, 230.0),
	vector4(-823.3688, -1146.980, 8.0, 300.0),
}

Config.CarItems = {
    [1] = {
        name = "heavyarmor",
        amount = 2,
        info = {},
        type = "item",
        slot = 1,
    },
    [2] = {
        name = "empty_evidence_bag",
        amount = 10,
        info = {},
        type = "item",
        slot = 2,
    },
    [3] = {
        name = "police_stormram",
        amount = 1,
        info = {},
        type = "item",
        slot = 3,
    },
}

Config.Items = {
    label = "Police Armory",
    slots = 30,
    items = {
        [1] = {
            name = "weapon_combatpistol",
            price = 70,
            amount = 1,
            info = {
                serial = "",                
                attachments = {
                    {component = "COMPONENT_AT_PI_FLSH", label = "Flashlight"},
                }
            },
            type = "weapon",
            slot = 1,
        },
        [2] = {
            name = "weapon_stungun",
            price = 50,
            amount = 1,
            info = {
                serial = "",            
            },
            type = "weapon",
            slot = 2,
        },
        [3] = {
            name = "weapon_pumpshotgun",
            price = 100,
            amount = 1,
            info = {
                serial = "",
                attachments = {
                    {component = "COMPONENT_AT_AR_FLSH", label = "Flashlight"},
                }
            },
            type = "weapon",
            slot = 3,
        },
        [4] = {
            name = "weapon_smg",
            price = 100,
            amount = 1,
            info = {
                serial = "",                
                attachments = {
                    {component = "COMPONENT_AT_SCOPE_MACRO_02", label = "1x Scope"},
                    {component = "COMPONENT_AT_AR_FLSH", label = "Flashlight"},
                }
            },
            type = "weapon",
            slot = 4,
        },
        [5] = {
            name = "weapon_carbinerifle",
            price = 100,
            amount = 1,
            info = {
                serial = "",
                attachments = {
                    {component = "COMPONENT_AT_AR_FLSH", label = "Flashlight"},
                    {component = "COMPONENT_AT_SCOPE_MEDIUM", label = "3x Scope"},
                }
            },
            type = "weapon",
            slot = 5,
        },
        [6] = {
            name = "weapon_nightstick",
            price = 25,
            amount = 1,
            info = {},
            type = "weapon",
            slot = 6,
        },
        [7] = {
            name = "pistol_ammo",
            price = 12,
            amount = 10,
            info = {},
            type = "item",
            slot = 7,
        },
        [8] = {
            name = "smg_ammo",
            price = 12,
            amount = 10,
            info = {},
            type = "item",
            slot = 8,
        },
        [9] = {
            name = "shotgun_ammo",
            price = 12,
            amount = 10,
            info = {},
            type = "item",
            slot = 9,
        },
        [10] = {
            name = "rifle_ammo",
            price = 12,
            amount = 10,
            info = {},
            type = "item",
            slot = 10,
        },
        [11] = {
            name = "handcuffs",
            price = 10,
            amount = 1,
            info = {},
            type = "item",
            slot = 11,
        },
        [12] = {
            name = "weapon_flashlight",
            price = 20,
            amount = 1,
            info = {},
            type = "weapon",
            slot = 12,
        },
        [13] = {
            name = "empty_evidence_bag",
            price = 5,
            amount = 50,
            info = {},
            type = "item",
            slot = 13,
        },
        -- [14] = {
        --     name = "police_stormram",
        --     price = 0,
        --     amount = 50,
        --     info = {},
        --     type = "item",
        --     slot = 14,
        -- },
        [14] = {
            name = "armor",
            price = 50,
            amount = 50,
            info = {},
            type = "item",
            slot = 14,
        },
        [15] = {
            name = "radio",
            price = 25,
            amount = 50,
            info = {},
            type = "item",
            slot = 15,
        },
		[16] = {
            name = "pistol_extendedclip",
            price = 450,
            amount = 50,
            info = {},
            type = "item",
            slot = 16,
        },
		[17] = {
            name = "pistol_suppressor",
            price = 250,
            amount = 50,
            info = {},
            type = "item",
            slot = 17,
        },
		[18] = {
            name = "smg_flashlight",
            price = 75,
            amount = 50,
            info = {},
            type = "item",
            slot = 18,
        },
		[19] = {
            name = "smg_suppressor",
            price = 300,
            amount = 50,
            info = {},
            type = "item",
            slot = 19,
        },
		[20] = {
            name = "smg_extendedclip",
            price = 450,
            amount = 50,
            info = {},
            type = "item",
            slot = 20,
        },
		[21] = {
            name = "smg_scope",
            price = 175,
            amount = 50,
            info = {},
            type = "item",
            slot = 21,
        },
		[22] = {
            name = "rifle_suppressor",
            price = 350,
            amount = 50,
            info = {},
            type = "item",
            slot = 22,
        },
		[23] = {
            name = "rifle_extendedclip",
            price = 550,
            amount = 50,
            info = {},
            type = "item",
            slot = 23,
        },
		[24] = {
            name = "rifle_drummag",
            price = 750,
            amount = 50,
            info = {},
            type = "item",
            slot = 24,
        },
        -- [16] = {
        --     name = "heavyarmor",
        --     price = 0,
        --     amount = 50,
        --     info = {},
        --     type = "item",
        --     slot = 17,
        -- },
    }
}

-- Prison
Config.JailJobs = {
    ["electrician"] = "electrician",
}

Config.JailLocations = {
    jobs = {
        ["electrician"] = {
            [1] = {
                coords = vector4(1761.46, 2540.41, 45.56,272.249),
            },
            [2] = {
                coords = vector4(1718.54,2527.802, 45.56, 272.249),
            },
            [3] = {
                coords = vector4(1700.199, 2474.811, 45.56, 272.249),
            },
            [4] = {
                coords = vector4(1664.827, 2501.58, 45.56, 272.249),
            },
            [5] = {
                coords = vector4(1621.622, 2509.302, 45.56, 272.249),
            },
            [6] = {
                coords = vector4(1627.936, 2538.393, 45.56, 272.249),
            },
            [7] = {
                coords = vector4(1625.1, 2575.988, 45.56, 272.249),
            },
        },
    },
    ["freedom"] = {
        coords = vector4(1788.59, 2595.35, 45.79, 3.5), 
    },
    ["outside"] = {
        coords = {x = 1848.13, y = 2586.05, z = 45.67, h = 269.5, r = 1.0}, 
    },
    ["yard"] = {
        coords = {x = 1765.67, y = 2565.91, z = 45.56, h = 1.5, r = 1.0}, 
    },
    ["middle"] = {
        coords = {x = 1693.33, y = 2569.51, z = 45.55, h = 123.5},
    },
    ["shop"] = {
        coords = vector4(1779.6, 2589.82, 45.79, 0.5)
    },
    spawns = {
        [1] = {
            animation = "bumsleep",
            coords = {x = 1661.046, y = 2524.681, z = 45.564, h = 260.545},
        },
        [2] = {
            animation = "lean",
            coords = {x = 1650.812, y = 2540.582, z = 45.564, h = 230.436},
        },
        [3] = {
            animation = "lean",
            coords = {x = 1654.959, y = 2545.535, z = 45.564, h = 230.436},
        },
        [4] = {
            animation = "lean",
            coords = {x = 1697.106, y = 2525.558, z = 45.564, h = 187.208},
        },
        [5] = {
            animation = "sitchair4",
            coords = {x = 1673.084, y = 2519.823, z = 45.564, h = 229.542},
        },
        [6] = {
            animation = "sitchair",
            coords = {x = 1666.029, y = 2511.367, z = 45.564, h = 233.888},
        },
        [7] = {
            animation = "sitchair4",
            coords = {x = 1691.229, y = 2509.635, z = 45.564, h = 52.432},
        },
        [8] = {
            animation = "finger2",
            coords = {x = 1770.59, y = 2536.064, z = 45.564, h = 258.113},
        },
        [9] = {
            animation = "smoke",
            coords = {x = 1789.62, y = 2585.79, z = 45.79, h = 88.5, r = 1.0}, 
        },
        [10] = {
            animation = "smoke",
            coords = {x = 1769.29, y = 2577.96, z = 50.54, h = 270.5, r = 1.0}, 
        },
        [11] = {
            animation = "smoke",
            coords = {x = 1769.36, y = 2589.7, z = 50.54, h = 278.5, r = 1.0}, 
        },
    }
}

Config.CanteenItems = {
    [1] = {
        name = "sandwich",
        price = 4,
        amount = 50,
        info = {},
        type = "item",
        slot = 1,
    },
    [2] = {
        name = "water_bottle",
        price = 4,
        amount = 50,
        info = {},
        type = "item",
        slot = 2,
    },
}

Config.Colors = {
    [1] = "Metallic Graphite Black",
    [2] = "Metallic Black Steel",
    [3] = "Metallic Dark Silver",
    [4] = "Metallic Silver",
    [5] = "Metallic Blue Silver",
    [6] = "Metallic Steel Gray",
    [7] = "Metallic Shadow Silver",
    [8] = "Metallic Stone Silver",
    [9] = "Metallic Midnight Silver",
    [10] = "Metallic Gun Metal",
    [11] = "Metallic Anthracite Grey",
    [12] = "Matte Black",
    [13] = "Matte Gray",
    [14] = "Matte Light Grey",
    [15] = "Util Black",
    [16] = "Util Black Poly",
    [17] = "Util Dark silver",
    [18] = "Util Silver",
    [19] = "Util Gun Metal",
    [20] = "Util Shadow Silver",
    [21] = "Worn Black",
    [22] = "Worn Graphite",
    [23] = "Worn Silver Grey",
    [24] = "Worn Silver",
    [25] = "Worn Blue Silver",
    [26] = "Worn Shadow Silver",
    [27] = "Metallic Red",
    [28] = "Metallic Torino Red",
    [29] = "Metallic Formula Red",
    [30] = "Metallic Blaze Red",
    [31] = "Metallic Graceful Red",
    [32] = "Metallic Garnet Red",
    [33] = "Metallic Desert Red",
    [34] = "Metallic Cabernet Red",
    [35] = "Metallic Candy Red",
    [36] = "Metallic Sunrise Orange",
    [37] = "Metallic Classic Gold",
    [38] = "Metallic Orange",
    [39] = "Matte Red",
    [40] = "Matte Dark Red",
    [41] = "Matte Orange",
    [42] = "Matte Yellow",
    [43] = "Util Red",
    [44] = "Util Bright Red",
    [45] = "Util Garnet Red",
    [46] = "Worn Red",
    [47] = "Worn Golden Red",
    [48] = "Worn Dark Red",
    [49] = "Metallic Dark Green",
    [50] = "Metallic Racing Green",
    [51] = "Metallic Sea Green",
    [52] = "Metallic Olive Green",
    [53] = "Metallic Green",
    [54] = "Metallic Gasoline Blue Green",
    [55] = "Matte Lime Green",
    [56] = "Util Dark Green",
    [57] = "Util Green",
    [58] = "Worn Dark Green",
    [59] = "Worn Green",
    [60] = "Worn Sea Wash",
    [61] = "Metallic Midnight Blue",
    [62] = "Metallic Dark Blue",
    [63] = "Metallic Saxony Blue",
    [64] = "Metallic Blue",
    [65] = "Metallic Mariner Blue",
    [66] = "Metallic Harbor Blue",
    [67] = "Metallic Diamond Blue",
    [68] = "Metallic Surf Blue",
    [69] = "Metallic Nautical Blue",
    [70] = "Metallic Bright Blue",
    [71] = "Metallic Purple Blue",
    [72] = "Metallic Spinnaker Blue",
    [73] = "Metallic Ultra Blue",
    [74] = "Metallic Bright Blue",
    [75] = "Util Dark Blue",
    [76] = "Util Midnight Blue",
    [77] = "Util Blue",
    [78] = "Util Sea Foam Blue",
    [79] = "Uil Lightning blue",
    [80] = "Util Maui Blue Poly",
    [81] = "Util Bright Blue",
    [82] = "Matte Dark Blue",
    [83] = "Matte Blue",
    [84] = "Matte Midnight Blue",
    [85] = "Worn Dark blue",
    [86] = "Worn Blue",
    [87] = "Worn Light blue",
    [88] = "Metallic Taxi Yellow",
    [89] = "Metallic Race Yellow",
    [90] = "Metallic Bronze",
    [91] = "Metallic Yellow Bird",
    [92] = "Metallic Lime",
    [93] = "Metallic Champagne",
    [94] = "Metallic Pueblo Beige",
    [95] = "Metallic Dark Ivory",
    [96] = "Metallic Choco Brown",
    [97] = "Metallic Golden Brown",
    [98] = "Metallic Light Brown",
    [99] = "Metallic Straw Beige",
    [100] = "Metallic Moss Brown",
    [101] = "Metallic Biston Brown",
    [102] = "Metallic Beechwood",
    [103] = "Metallic Dark Beechwood",
    [104] = "Metallic Choco Orange",
    [105] = "Metallic Beach Sand",
    [106] = "Metallic Sun Bleeched Sand",
    [107] = "Metallic Cream",
    [108] = "Util Brown",
    [109] = "Util Medium Brown",
    [110] = "Util Light Brown",
    [111] = "Metallic White",
    [112] = "Metallic Frost White",
    [113] = "Worn Honey Beige",
    [114] = "Worn Brown",
    [115] = "Worn Dark Brown",
    [116] = "Worn straw beige",
    [117] = "Brushed Steel",
    [118] = "Brushed Black steel",
    [119] = "Brushed Aluminium",
    [120] = "Chrome",
    [121] = "Worn Off White",
    [122] = "Util Off White",
    [123] = "Worn Orange",
    [124] = "Worn Light Orange",
    [125] = "Metallic Securicor Green",
    [126] = "Worn Taxi Yellow",
    [127] = "police car blue",
    [128] = "Matte Green",
    [129] = "Matte Brown",
    [130] = "Worn Orange",
    [131] = "Matte White",
    [132] = "Worn White",
    [133] = "Worn Olive Army Green",
    [134] = "Pure White",
    [135] = "Hot Pink",
    [136] = "Salmon pink",
    [137] = "Metallic Vermillion Pink",
    [138] = "Orange",
    [139] = "Green",
    [140] = "Blue",
    [141] = "Mettalic Black Blue",
    [142] = "Metallic Black Purple",
    [143] = "Metallic Black Red",
    [144] = "hunter green",
    [145] = "Metallic Purple",
    [146] = "Metaillic V Dark Blue",
    [147] = "MODSHOP BLACK1",
    [148] = "Matte Purple",
    [149] = "Matte Dark Purple",
    [150] = "Metallic Lava Red",
    [151] = "Matte Forest Green",
    [152] = "Matte Olive Drab",
    [153] = "Matte Desert Brown",
    [154] = "Matte Desert Tan",
    [155] = "Matte Foilage Green",
    [156] = "DEFAULT ALLOY COLOR",
    [157] = "Epsilon Blue",
    [158] = "Unknown",
}

Config.JailOutfits = {
    ["male"] = {
        outfitData = {
            ["pants"]       = { item = 31,texture = 0},  -- Pants
            ["arms"]        = { item = 52, texture = 0},  -- Arms
            ["t-shirt"]     = { item = 15, texture = 0},  -- T Shirt
            ["vest"]        = { item = 25, texture = 2},  -- Body Vest
            ["torso2"]      = { item = 71, texture = 0},  -- Jacket / Vests
            ["shoes"]       = { item = 27, texture = 0},  -- Shoes
            ["decals"]      = { item = 0, texture = 0},  -- Decals
            ["accessory"]   = { item = 1, texture = 0},  -- Neck
            ["bag"]         = { item = 33, texture = 0},  -- Bag
            ["hat"]         = { item = -1, texture = -1},  -- Hat
            ["glass"]       = { item = 5, texture = 0},  -- Glasses
            ["ear"]         = { item = 0, texture = 0},  -- Ear Accessories
            ["mask"]        = { item = 41, texture = 0},  -- Masks
        },
    },
    ["female"] = {
        outfitData = {
            ["pants"]       = { item = 3,texture = 1},  -- Pants
            ["arms"]        = { item = 14, texture = 0},  -- Arms
            ["t-shirt"]     = { item = 3, texture = 0},  -- T Shirt
            ["vest"]        = { item = 0, texture = 0},  -- Body Vest
            ["torso2"]      = { item = 14, texture = 1},  -- Jacket / Vests
            ["shoes"]       = { item = 25, texture = 0},  -- Shoes
            ["decals"]      = { item = 0, texture = 0},  -- Decals
            ["accessory"]   = { item = 0, texture = 0},  -- Neck
            ["bag"]         = { item = 0, texture = 0},  -- Bag
            ["hat"]         = { item = -1, texture = 0},  -- Hat
            ["glass"]       = { item = 0, texture = 0},  -- Glasses
            ["ear"]         = { item = 0, texture = 0},  -- Ear Accessories
            ["mask"]        = { item = 121, texture = 0},  -- Masks
        },
    },
}