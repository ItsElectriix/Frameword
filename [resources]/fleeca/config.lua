fleeca = {}
local MFF = fleeca

MFF.PoliceJobName = "police"
MFF.MinPoliceOnline = 0

MFF.InteractKey = "E"
MFF.ResetTimer = 120 -- minutes
MFF.InteractTimer = 30 -- seconds

MFF.LoadDist = 50.0
MFF.ActionDist = 0.8

MFF.G4SSpawnTimer = 30 -- minutes

MFF.Banks = {
  [1] = vector3(314.62, -277.97, 54.15), -- Pink Cage
  [2] = vector3(149.30, -1040.3, 29.50), -- Legion
  [3] = vector3(-1212.81, -330.15, 37.90), -- Rockford Hills
  [4] = vector3(-2963.64, 482.87, 15.70), -- Great Ocean
  [5] = vector3( 1175.24, 2705.68, 38.10), -- Route 68
  [6] = vector3(-350.83, -48.57, 49.04), -- Hawick Ave
  [7] = vector3(-108.36, 6465.22, 31.63),  -- Blaine County Savings Bank
}

MFF.HackLevelAdjustments = {
  [1] = {
    numberOfHacks = 1,
    min = 6,
    max = 7,
    time = 30
  },
  [2] = {
    numberOfHacks = 1,
    min = 5,
    max = 6,
    time = 25
  },
  [3] = {
    numberOfHacks = 2,
    min = 4,
    max = 7,
    time = 25
  },
  [4] = {
    numberOfHacks = 2,
    min = 3,
    max = 5,
    time = 25
  },
  [5] = {
    numberOfHacks = 3,
    min = 4,
    max = 7,
    time = 30
  },
  [6] = {
    numberOfHacks = 3,
    min = 3,
    max = 5,
    time = 30
  },
  [7] = {
    numberOfHacks = 4,
    min = 3,
    max = 5,
    time = 25
  },
  [8] = {
    numberOfHacks = 4,
    min = 2,
    max = 4,
    time = 25
  },
  [9] = {
    numberOfHacks = 5,
    min = 3,
    max = 5,
    time = 20
  },
  [10] = {
    numberOfHacks = 5,
    min = 2,
    max = 4,
    time = 15
  },
}

MFF.BankReferences = {
  [1] = "FLC001",
  [2] = "FLC002",
  [3] = "FLC003",
  [4] = "FLC004",
  [5] = "FLC005",
  [6] = "FLC006",
  [7] = "BCS001",
  [8] = "PCF001",
}

MFF.Actions = {
  [1] = {
    [vector3(309.58,-279.52,54.50)] = "FrontDoor",
    [vector3(315.31,-280.82,54.16)] = "DeskCash",
    [vector3(313.69,-280.24,54.16)] = "DeskCash",
    [vector3(311.80,-279.43,54.16)] = "DeskCash",
    --[vector3(313.33,-281.85,54.50)] = "LootID",

    [vector3(311.66,-284.66,54.50)] = "OpenVault",

    [vector3(315.74,-285.08,54.50)] = "LootVault",
    [vector3(314.14,-283.09,54.50)] = "LootVault",

    [vector3(313.86,-285.24,54.14)] = "LockpickDoor",
    
    [vector3(315.33,-287.69,54.50)] = "LootVault",
    [vector3(314.89,-289.01,54.50)] = "LootVault",
    
    [vector3(313.49,-289.68,54.50)] = "LootVault",
    [vector3(312.47,-289.25,54.50)] = "LootVault",
    [vector3(311.48,-288.89,54.50)] = "LootVault",

    [vector3(310.66,-287.38,54.50)] = "LootVault",
    [vector3(311.14,-286.38,54.50)] = "LootVault",

    [vector3(292.09,-294.03,53.98)] = "HackAlarm",    
  },

  [2] = {
    [vector3(145.30,-1041.18,29.50)] = "FrontDoor",
    [vector3(151.06,-1042.33,29.37)] = "DeskCash",
    [vector3(149.64,-1041.67,29.37)] = "DeskCash",
    [vector3(147.76,-1041.14,29.37)] = "DeskCash",
    --[vector3(149.09,-1043.58,29.50)] = "LootID",

    [vector3(147.01,-1046.15,29.50)] = "OpenVault",

    [vector3(149.80,-1044.77,29.50)] = "LootVault",
    [vector3(151.30,-1046.61,29.50)] = "LootVault",

    [vector3(149.52,-1047.25,29.35)] = "LockpickDoor",

    [vector3(146.79,-1047.79,29.50)] = "LootVault",
    [vector3(146.42,-1048.87,29.50)] = "LootVault",
    
    [vector3(146.95,-1050.61,29.50)] = "LootVault",
    [vector3(149.26,-1051.46,29.50)] = "LootVault",
    [vector3(148.02,-1051.01,29.50)] = "LootVault",

    [vector3(150.98,-1049.15,29.50)] = "LootVault",
    [vector3(150.29,-1050.81,29.50)] = "LootVault",

    [vector3(135.72,-1046.33,29.20)] = "HackAlarm",    
  },

  [3] = {
    [vector3(-1215.41,-334.39,38.00)] = "FrontDoor",
    [vector3(-1210.58,-330.75,37.78)] = "DeskCash",
    [vector3(-1211.99,-331.45,37.78)] = "DeskCash",
    [vector3(-1213.63,-332.28,37.78)] = "DeskCash",
    --[vector3(-1211.40,-333.39,38.00)] = "LootID",

    [vector3(-1210.56,-336.66,38.00)] = "OpenVault",

    [vector3(-1209.73,-333.37,38.00)] = "LootVault",
    [vector3(-1207.36,-333.71,38.00)] = "LootVault",

    [vector3(-1208.28,-335.12,37.76)] = "LockpickDoor",
    
    [vector3(-1209.54,-337.83,38.00)] = "LootVault",
    [vector3(-1208.99,-338.90,38.00)] = "LootVault",
    
    [vector3(-1207.45,-339.60,38.00)] = "LootVault",
    [vector3(-1206.35,-339.05,38.00)] = "LootVault",
    [vector3(-1205.57,-338.61,38.00)] = "LootVault",

    [vector3(-1205.65,-335.63,38.00)] = "LootVault",
    [vector3(-1205.00,-336.98,38.00)] = "LootVault",

    [vector3(-1211.23,-335.51,42.12)] = "HackAlarm",    
  },

  [4] = {
    [vector3(-2960.67,478.73,16.00)] = "FrontDoor",
    [vector3(-2961.67,484.62,15.7)] = "DeskCash",
    [vector3(-2961.76,482.99,15.7)] = "DeskCash",
    [vector3(-2961.83,481.25,15.7)] = "DeskCash",    
    --[vector3(-2959.60,482.84,16.00)] = "LootID",

    [vector3(-2956.43,482.08,16.00)] = "OpenVault",

    [vector3(-2958.71,484.00,16.00)] = "LootVault",
    [vector3(-2957.36,486.27,16.00)] = "LootVault",

    [vector3(-2956.61,484.46,15.68)] = "LockpickDoor",
    
    [vector3(-2954.84,482.17,16.00)] = "LootVault",
    [vector3(-2953.57,482.12,16.00)] = "LootVault",
    
    [vector3(-2952.22,485.17,16.00)] = "LootVault",
    [vector3(-2952.23,484.27,16.00)] = "LootVault",
    [vector3(-2952.30,483.00,16.00)] = "LootVault",

    [vector3(-2954.75,486.64,16.00)] = "LootVault",
    [vector3(-2953.26,486.65,16.00)] = "LootVault",

    [vector3(-2948.14,481.22,15.44)] = "HackAlarm",    
  },

  [5] = {
    [vector3( 1179.16,2708.89,38.10)] = "FrontDoor",
    [vector3( 1173.16,2707.75,38.09)] = "DeskCash",
    [vector3( 1174.90,2707.76,38.09)] = "DeskCash",
    [vector3( 1176.59,2707.73,38.09)] = "DeskCash",    
    --[vector3( 1175.00,2709.56,38.10)] = "LootID",

    [vector3( 1175.77,2712.96,38.10)] = "OpenVault",

    [vector3( 1173.71,2710.71,38.10)] = "LootVault",
    [vector3( 1171.84,2711.85,38.10)] = "LootVault",

    [vector3( 1173.25,2712.72,38.07)] = "LockpickDoor",
    
    [vector3( 1171.20,2714.62,38.10)] = "LootVault",
    [vector3( 1171.20,2715.72,38.10)] = "LootVault",
    
    [vector3( 1172.16,2716.86,38.10)] = "LootVault",
    [vector3( 1173.36,2616.86,38.10)] = "LootVault",
    [vector3( 1174.46,2716.86,38.10)] = "LootVault",

    [vector3( 1175.28,2715.89,38.10)] = "LootVault",
    [vector3( 1175.28,2714.58,38.10)] = "LootVault",

    [vector3( 1158.24,2708.98,37.98)] = "HackAlarm",
  },

  [6] = {
    [vector3( -355.50,-50.48,49.04)] = "FrontDoor",
    [vector3( -349.85,-51.77,49.04)] = "DeskCash",
    [vector3( -351.60,-51.15,49.04)] = "DeskCash",
    [vector3( -353.34,-50.45,49.04)] = "DeskCash",    
    --[vector3( -350.70,-52.79,49.04)] = "LootID",

    [vector3( -353.78,-55.35,49.04)] = "OpenVault",

    [vector3( -349.49,-55.69,49.01)] = "LootVault",
    [vector3( -350.74,-54.31,49.01)] = "LootVault",

    [vector3( -351.05,-56.01,49.04)] = "LockpickDoor",
    [vector3( -353.61,-57.02,49.01)] = "LootVault",
    [vector3( -354.13,-58.44,49.01)] = "LootVault",
    
    [vector3( -353.56,-59.62,49.01)] = "LootVault",
    [vector3( -352.54,-59.95,49.01)] = "LootVault",
    [vector3( -351.24,-60.34,49.01)] = "LootVault",

    [vector3( -350.33,-59.75,49.01)] = "LootVault",
    [vector3( -349.85,-58.40,49.01)] = "LootVault",

    [vector3( -355.61,-50.19,54.42)] = "HackAlarm",    
  },

  [7] = {
    [vector3( -109.02,6468.38,31.63)] = "FrontDoor",
    [vector3( -113.64,6471.79,31.63)] = "DeskCash",
    [vector3( -112.32,6470.43,31.63)] = "DeskCash",
    [vector3( -111.27,6469.37,31.63)] = "DeskCash",    
    --[vector3( -113.36,6473.40,31.63)] = "LootID",

    [vector3( -105.58,6471.56,31.63)] = "HackVault",
    [vector3( -105.50,6473.23,31.63)] = "ThermiteDoor",


    [vector3( -107.64,6475.65,31.63)] = "LootVault",
    [vector3( -107.39,6473.94,31.63)] = "LootVault",

    [vector3( -106.13,6475.31,31.63)] = "ThermiteDoor",
    
    [vector3( -103.54,6474.96,31.67)] = "LootVault",
    [vector3( -102.38,6476.01,31.63)] = "LootVault",
    
    [vector3( -102.27,6477.29,31.63)] = "LootVault",
    [vector3( -103.17,6478.14,31.63)] = "LootVault",
    [vector3( -104.13,6479.12,31.63)] = "LootVault",

    [vector3( -105.38,6478.92,31.65)] = "LootVault",
    [vector3( -106.61,6477.97,31.63)] = "LootVault",

    [vector3( -109.36,6483.23,31.47)] = "HackAlarm",    
  },  
}

MFF.DeskLootTable = {
  ["cash"] = {
    min = 1,
    max = 5
  },
}

MFF.LootTable = {
  ["watch"]   = 3,
  ["gold"]    = 2,
  ["diamond"] = 2,
  ["diamondring"] = 1,
  ["crystalbrace"] = 1,
  ["cash"] = {
    min = 2,
    max = 5
  },
}

MFF.BlaineLootTable = {
  ["sapphire"] = 4,
  ["diamondring"] = 4,
  ["diamond"] = 3,
  ["sapphireneck"] = 2,
  ["crystalbrace"] = 2,
  ["cash"] = {
    min = 4,
    max = 6
  },
}

MFF.TextAddons = {
  ["LockpickDoor"] = "Lockpick Door",
  ["ThermiteDoor"] = " Use Thermite",
  ["LootID"] = "Search",
  ["OpenVault"] = "Request access to vault",
  ["HackVault"] = "Hack vault security",
  ["LootVault"] = "Drill Box",
  ["FrontDoor"] = "Open Door",
  ["DeskCash"] = "Search",
  ["HackAlarm"] = "Disable Alarm",
}

MFF.DoorHashes = {
  --[2121050683] = "2121050683",
  --[4163212883] = "4163212883",
  --[4231427725] = "4231427725",
  [-131754413] = "-131754413",
  --[-63539571] = "-63539571",
  [-1184592117] = "-1184592117",
  --[-1185205679] = "-1185205679",
  [1309269072] = "1309269072",
  [1622278560] = "1622278560",
  [-1591004109] = "-1591004109",
}

MFF.VaultHashes = {
  [2121050683] = "2121050683",
  [-63539571] = "-63539571", 
  [-1185205679] = "-1185205679",  
}

MFF.G4SSpawnLocs = {
  [1] = vector4(-10.18, -726.76, 31.92, 161.70), -- legion under power street
  [2] = vector4(-1192.95, -319.19, 37.30, 25.74), -- hawick/life invnader
  [3] = vector4(-278.77, -1092.14, 23.43, 253.34), -- job center
  [4] = vector4(231.76, 249.23, 105.04, 160.43), -- pacific
  [5] = vector4(-334.38, -33.12, 47.32, 252.97), -- hawick middle
  [6] = vector4(97.94, -1053.86, 28.84, 335.35), -- behind legion bank
  [7] = vector4(-112.23, 6413.36, 30.94, 314.52), -- paleto
  [8] = vector4(-415.17, -35.53, 45.89, 244.46) -- hawwick left middle
}

BJCore = nil
TriggerEvent('BJCore:GetObject', function(obj) BJCore = obj end)
Citizen.CreateThread(function(...) while BJCore == nil do TriggerEvent("BJCore:GetObject", function(obj) BJCore = obj end); Citizen.Wait(1000); end; end)