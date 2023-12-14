robbery = {}
Config = {
  -- Lock houses/reset loot tables
  ResetAfterMinutes = 50,

  -- Distance to perform action/draw marker
  ActDist   =  1.0,
  DrawDist  = 10.0,

  -- How long to loot
  InteractTimer = 5.0,

  -- Police stuff
  PoliceJob     = "police",
  AlertTimeout  = 10,
  MinCopsOnline = 2,

  -- Use dog?
  UseDog      = true,

  LockpickItemName = "lockpick",
  NeedLockpick     = true,
  TakeLockpick     = true,
  MinigameForEntry = true,
  TimeForLockpick  = 5,
  UsingProgressBar = true,
  UseDraw3D        = true,

  Entrys = {
    [1] = { pos = vector4(329.38,-1845.92,27.74, 043.0), type = 'low'},
    [2] = { pos = vector4(338.70,-1829.54,28.33, 132.0), type = 'low'},
    [3] = { pos = vector4(320.25,-1854.07,27.51,-132.7), type = 'low'},
    [4] = { pos = vector4(348.64,-1820.98,28.89, 139.5), type = 'low'},
    [5] = { pos = vector4(333.08,-1740.87,29.73,-036.7), type = 'low'},
    [6] = { pos = vector4(320.66,-1759.78,29.63,-052.5), type = 'low'},
    [7] = { pos = vector4(304.46,-1775.43,29.10, 045.9), type = 'low'},
    [8] = { pos = vector4(300.25,-1783.67,28.43,-039.6), type = 'low'},
    [9] = { pos = vector4(288.67,-1792.55,28.08, 141.1), type = 'low'},

	[10] = { pos = vector4(255.10,-1742.60,29.66, 226.0), type = 'low'},
    [11] = { pos = vector4(-64.24,-1449.66,32.52, 072.6), type = 'low'},
    [12] = { pos = vector4(-45.49,-1445.42,32.43, -078.91), type = 'low'},
    [13] = { pos = vector4(-32.33,-1446.34,31.89, -086.29), type = 'low'},
    [14] = { pos = vector4(-2.09,-1442.13,30.96, -010.31), type = 'low'},
    [15] = { pos = vector4(16.73,-1443.86,30.95, -019.99), type = 'low'},
    [16] = { pos = vector4(152.66,-1823.56,27.87, -050.32), type = 'low'},
    [17] = { pos = vector4(130.62,-1853.29,25.23, -027.58), type = 'low'},
	
	[18] = { pos = vector4(840.64, -182.22, 74.39, 59.0), type = 'low'},
    [19] = { pos = vector4(952.63, -252.27, 67.96, 58.65), type = 'low'},
    [20] = { pos = vector4(880.33, -205.44, 71.98, 148.84), type = 'low'},
    [21] = { pos = vector4(808.56, -163.87, 75.88, 149.57), type = 'low'},
    [22] = { pos = vector4(798.57, -158.96, 74.89, 240.29), type = 'low'},
    
	[23] = { pos = vector4(1265.97, -458.09, 70.52, 271.89), type = 'low'},
	[24] = { pos = vector4(1262.59, -429.81, 70.01, 292.84), type = 'low'},
	[25] = { pos = vector4(1259.63, -479.96, 70.19, 308.14), type = 'low'},
	[26] = { pos = vector4(1251.13, -515.56, 69.35, 258.12), type = 'low'},
	[27] = { pos = vector4(1241.60, -566.21, 69.66, 318.31), type = 'low'},
	[28] = { pos = vector4(1240.83, -601.67, 69.78, 274.67), type = 'low'},
	
	[29] = { pos = vector4(1385.18, 3659.73, 34.93, 20.69), type = 'low'},
	[30] = { pos = vector4(1406.83, 3655.91, 34.22, 114.15), type = 'low'},
	[31] = { pos = vector4(1435.64, 3657.15, 34.37, 291.58), type = 'low'},
	[32] = { pos = vector4(1436.20, 3639.31, 34.95, 16.45), type = 'low'},
	[33] = { pos = vector4(1436.20, 3639.31, 34.95, 16.45), type = 'low'},

	[34] = { pos = vector4(-272.57, 6401.04, 31.50, 31.46), type = 'low'},
	[35] = { pos = vector4(-247.52, 6370.20, 31.85, 229.19), type = 'low'},
	[36] = { pos = vector4(-302.13, 6326.95, 32.89, 225.65), type = 'low'},
	[37] = { pos = vector4(-380.06, 6252.71, 31.85, 135.84), type = 'low'},
	[38] = { pos = vector4(-26.66, 6597.10, 31.86, 215.58), type = 'low'},
	[39] = { pos = vector4(-9.60, 6654.22, 31.70, 20.59),    type = 'low'},
  },
}

robbery.lootOffsets = { 
  ['entertainment unit'] = vector3(-8.85,16.70,-0.2),
  ['drawers'] = vector3(4.05,13.99,-0.2),
  ['bookshelf'] = vector3(-1.9,18.99,-0.2),
  ['chest'] = vector3(4.9,14.6,-0.2),
  ['wardrobe'] = vector3(3.6,19.84,-0.2),
  ['bedside table'] = vector3(1.97,18.58,-0.2),
  ['bathroom cabinet'] = vector3(-0.23,19.12,-0.2),
} 

robbery.lowlootTable = {
  ['entertainment unit'] = {
    iphone = {
      max = 1,
      chance = 250,
    },
    fitbit = {
      max = 2,
      chance = 450,
    },
    electronickit = {
      max = 1,
      chance = 200,
    },
    lockpick = {
      max = 1,
      chance = 200,
    },
	blueusb = {
	  max = 1,
	  chance = 100,
	}
  },
  ['drawers'] = {
    rolex = {
      max = 1,
      chance = 175,
    },
    repairkit = {
      max = 1,
      chance = 200,
    },
	  diamond_ring = {
	  max = 1,
	  chance = 120,
	},
    lockpick = {
      max = 1,
      chance = 150,
    },
  },
  ['bookshelf'] = {
    goldchain = {
      max = 1,
      chance = 160,
    },
    cryptostick = {
        max = 1,
        chance = 75
    },
  },
  ['chest'] = {
    diamond_ring = {
      max = 1,
      chance = 250,
    },
    goldchain = {
      max = 1,
      chance = 250,
    },
  },
  ['wardrobe'] = {
    rolex = {
      max = 1,
      chance = 250,
    },
    lockpick = {
      max = 1,
      chance = 150,
    },
    stethoscope = {
      max = 1,
      chance = 80,
    },    
  },
  ['bedside table'] = {
    painkillers = {
      max = 2,
      chance = 450,
    },
    lockpick = {
      max = 1,
      chance = 150,
    },
  },
  ['bathroom cabinet'] = {
    --condom = {
    --  max = 5,
    --  chance = 650,
    --},
    rolex = {
      max = 1,
      chance = 200,
    },
    -- clip = {
    --   max = 1,
    --   chance = 50,
    -- },
    plastic = {
        max = 4,
        chance = 300
    },
    firstaid = {
        max = 3,
        chance = 50
    }
  },
}

robbery.midlootTable = {
}

BJCore = nil
TriggerEvent('BJCore:GetObject', function(obj) BJCore = obj end)
Citizen.CreateThread(function(...) while BJCore == nil do TriggerEvent("BJCore:GetObject", function(obj) BJCore = obj end); Citizen.Wait(1000); end; end)
