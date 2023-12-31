Config = {}

Config.MinimalDoctors = 2

Config.LoadZoneDist = 35.0
Config.DrawTextDist = 10.0
Config.InteractDist = 2.0
Config.AutoHealTimer = 60 -- seconds
Config.HealingTimer = 10 -- seconds
Config.OnlineEMSTimerMultiplier = 4 -- if ems > MinEMSCount and player in bed, time for auto heal = AutoHealTimer*OnlineEMSTimerMultiplier
Config.MinEMSCount = 1
Config.EMSJobName = "ambulance"

Config.Hospitals = {
  [1] = {
    ["name"] = "Pillbox Hospital",
    ["checkIn"] = vector3(308.72, -592.56, 43.28),
    ["beds"] = {
      [1] = {
        ["pos"] = vector4(322.61, -587.16, 42.84, 160.0),
        ["rot"] = vector3(90.0, 149.85, 0.0),
        ["getUp"] = vector4(321.82, -586.89, 43.28, 66.06),
        ["invert"] = false,      
      },
      [2] = {
        ["pos"] = vector4(317.67, -585.36, 42.84, 160.0),
        ["rot"] = vector3(90.0, 149.85, 0.0),
        ["getUp"] = vector4(318.70, -585.82, 43.28, 289.56),
        ["invert"] = false,      
      },
      [3] = {
        ["pos"] = vector4(314.46, -584.20, 42.84, 160.0),
        ["rot"] = vector3(90.0, 149.85, 0.0),
        ["getUp"] = vector4(315.44, -584.57, 43.28, 268.24),
        ["invert"] = false,      
      },
      [4] = {
        ["pos"] = vector4(311.05, -582.96, 42.84, 160.0),
        ["rot"] = vector3(90.0, 149.85, 0.0),
        ["getUp"] = vector4(312.17, -583.42, 43.28, 270.04),
        ["invert"] = false,      
      },
      [5] = {
        ["pos"] = vector4(307.71, -581.74, 42.84, 160.0),
        ["rot"] = vector3(90.0, 149.85, 0.0),
        ["getUp"] = vector4(308.68, -582.20, 43.28, 287.76),
        ["invert"] = true,
      },
      [6] = {
        ["pos"] = vector4(324.26, -582.80, 42.84, 340.0),
        ["rot"] = vector3(90.0, 329.85, 0.0),
        ["getUp"] = vector4(323.27, -582.40, 43.28, 108.57),
        ["invert"] = true,      
      },
      [7] = {
        ["pos"] = vector4(319.41, -581.03, 42.84, 340.0),
        ["rot"] = vector3(90.0, 329.85, 0.0),
        ["getUp"] = vector4(320.38, -581.40, 43.28, 203.13),
        ["invert"] = false,      
      },
      [8] = {
        ["pos"] = vector4(313.92, -579.04, 42.84, 340.0),
        ["rot"] = vector3(90.0, 329.85, 0.0),
        ["getUp"] = vector4(312.86, -579.21, 43.28, 89.56),
        ["invert"] = false,      
      },
      [9] = {
        ["pos"] = vector4(309.35, -577.37, 42.84, 340.0),
        ["rot"] = vector3(90.0, 329.85, 0.0),
        ["getUp"] = vector4(310.31, -577.60, 43.28, 220.81 ),
        ["invert"] = false,      
      },
    }
  },
  [2] = {
    ["name"] = "Sandy Medical",
    ["checkIn"] = vector3(1832.95, 3683.34, 34.27),
    ["beds"] = {
      [1] = {
        ["pos"] = vector4(1829.673, 3676.108, 33.822, 210.433),
        ["rot"] = vector3(90.0, 205.85, 0.0),
        ["getUp"] = vector4(1828.97, 3675.66, 34.27, 117.51),
        ["invert"] = true,      
      },
      [2] = {
        ["pos"] = vector4(1825.775, 3678.536, 33.83, 120.614),
        ["rot"] = vector3(90.0, 120.85, 0.0),
        ["getUp"] = vector4(1826.48, 3677.88, 34.27, 208.40),
        ["invert"] = true,      
      },
    }    
  },
  -- [3] = {
  -- }
}

Config.ActionText = {
  [1] = "[~g~E~w~] Check in",
  [2] = "[~g~E~w~] Use bed",  
}

Config.Locations = {
    ["duty"] = {
        [1] = vector3(304.27, -600.33, 43.28),
        [2] = vector3(1842.15, 3685.61, 34.27),
    },    
    ["vehicle"] = {
        [1] = vector4(294.578, -574.761, 43.179, 35.792),
        [2] = vector4(1847.516, 3671.811, 33.70094, 214.13),
    },
    ["helicopter"] = {
        [1] = vector4(351.58, -587.45, 74.16, 160.5),
        [2] = vector4(1869.27, 3648.34, 34.29, 30.22),
    },    
    ["armory"] = {
        [1] = vector3(310.15, -568.42, 43.28),
        [2] = vector3(1822.11, 3676.25, 34.27),
    },
    ["hidden"] = {
        [1] = vector3(807.29, -494.69, 30.69),
        [2] = vector3(2436.52, 4959.37, 46.81),        
    }
    -- ["roof"] = {
    --     [1] = {x = 338.5, y = -583.85, z = 74.16, h = 245.5},
    -- },
    -- ["main"] = {
    --     [1] = {x = 332.51, y = -595.74, z = 43.28, h = 76.0},
    -- },        
}

Config.Vehicles = {
    ["medic1"] = "Ambulance",
    ["command1"] = "Ford Explorer",
    ["command2"] = "Chevy Tahoe",    
}

Config.Whitelist = {
    "OHC01182", -- Josh
    "XCS85530", -- Ban
}

Config.Helicopter = "polmav"

Config.Items = {
    label = "Hospital Inventory",
    slots = 30,
    items = {
        [1] = {
            name = "radio",
            price = 1,
            amount = 50,
            info = {},
            type = "item",
            slot = 1,
        },
        [2] = {
            name = "bandage",
            price = 0,
            amount = 50,
            info = {},
            type = "item",
            slot = 2,
        },
        [3] = {
            name = "firstaid",
            price = 0,
            amount = 50,
            info = {},
            type = "item",
            slot = 3,
        },        
        [4] = {
            name = "painkillers",
            price = 0,
            amount = 50,
            info = {},
            type = "item",
            slot = 4,
        },
        [5] = {
            name = "weapon_flashlight",
            price = 0,
            amount = 50,
            info = {},
            type = "item",
            slot = 5,
        },
        [6] = {
            name = "weapon_fireextinguisher",
            price = 0,
            amount = 50,
            info = {},
            type = "item",
            slot = 6,
        },
        [7] = {
            name = "stethoscope",
            price = 0,
            amount = 50,
            info = {},
            type = "item",
            slot = 7,
        },        
    }
}

Config.BillCost = 150
Config.DeathTime = 600
Config.CheckTime = 10

Config.PainkillerInterval = 60 -- seconds

--[[
    GENERAL SETTINGS | THESE WILL AFFECT YOUR ENTIRE SERVER SO BE SURE TO SET THESE CORRECTLY
    MaxHp : Maximum HP Allowed, set to -1 if you want to disable mythic_hospital from setting this
        NOTE: Anything under 100 and you are dead
    RegenRate : 
]]
Config.MaxHp = 250
Config.RegenRate = 0.0

--[[
    HealthDamage : How Much Damage To Direct HP Must Be Applied Before Checks For Damage Happens
    ArmorDamage : How Much Damage To Armor Must Be Applied Before Checks For Damage Happens | NOTE: This will in turn make stagger effect with armor happen only after that damage occurs
]]
Config.HealthDamage = 5
Config.ArmorDamage = 5

--[[
    MaxInjuryChanceMulti : How many times the HealthDamage value above can divide into damage taken before damage is forced to be applied
    ForceInjury : Maximum amount of damage a player can take before limb damage & effects are forced to occur
]]
Config.MaxInjuryChanceMulti = 3
Config.ForceInjury = 35
Config.AlwaysBleedChance = 35

--[[
    Message Timer : How long it will take to display limb/bleed message
]]
Config.MessageTimer = 12

--[[
    AIHealTimer : How long it will take to be healed after checking in, in seconds
]]
Config.AIHealTimer = 20

--[[ 
    BleedTickRate : How much time, in seconds, between bleed ticks
]]
Config.BleedTickRate = 30

--[[
    BleedMovementTick : How many seconds is taken away from the bleed tick rate if the player is walking, jogging, or sprinting
    BleedMovementAdvance : How Much Time Moving While Bleeding Adds (This Adds This Value To The Tick Count, Meaing The Above BleedTickRate Will Be Reached Faster)
]]
Config.BleedMovementTick = 5
Config.BleedMovementAdvance = 2

--[[
    The Base Damage That Is Multiplied By Bleed Level Every Time A Bleed Tick Occurs
]]
Config.BleedTickDamage = 8

--[[
    FadeOutTimer : How many bleed ticks occur before fadeout happens
    BlackoutTimer : How many bleed ticks occur before blacking out
    AdvanceBleedTimer : How many bleed ticks occur before bleed level increases
]]
Config.FadeOutTimer = 2
Config.BlackoutTimer = 10
Config.AdvanceBleedTimer = 10

--[[
    HeadInjuryTimer : How much time, in seconds, do head injury effects chance occur
    ArmInjuryTimer : How much time, in seconds, do arm injury effects chance occur
    LegInjuryTimer : How much time, in seconds, do leg injury effects chance occur
]]
Config.HeadInjuryTimer = 30
Config.ArmInjuryTimer = 30
Config.LegInjuryTimer = 15

--[[
    The Chance, In Percent, That Certain Injury Side-Effects Get Applied
]]
Config.HeadInjuryChance = 25
Config.ArmInjuryChance = 25
Config.LegInjuryChance = {
    Running = 50,
    Walking = 15
}

--[[
    MajorArmoredBleedChance : The % Chance Someone Gets A Bleed Effect Applied When Taking Major Damage With Armor
    MajorDoubleBleed : % Chance You Have To Receive Double Bleed Effect From Major Damage, This % is halved if the player has armor
]]
Config.MajorArmoredBleedChance = 30

--[[
    DamgeMinorToMajor : How much damage would have to be applied for a minor weapon to be considered a major damage event. Put this at 100 if you want to disable it
]]
Config.DamageMinorToMajor = 30

--[[
    AlertShowInfo : 
]]
Config.AlertShowInfo = 2

--[[
    These following lists uses tables defined in definitions.lua, you can technically use the hardcoded values but for sake
    of ensuring future updates doesn't break it I'd highly suggest you check that file for the index you're wanting to use.

    MinorInjurWeapons : Damage From These Weapons Will Apply Only Minor Injuries
    MajorInjurWeapons : Damage From These Weapons Will Apply Only Major Injuries
    AlwaysBleedChanceWeapons : Weapons that're in the included weapon classes will roll for a chance to apply a bleed effect if the damage wasn't enough to trigger an injury chance
    CriticalAreas : 
    StaggerAreas : These are the body areas that would cause a stagger is hit by firearms,
        Table Values: Armored = Can This Cause Stagger If Wearing Armor, Major = % Chance You Get Staggered By Major Damage, Minor = % Chance You Get Staggered By Minor Damage
]]

Config.WeaponClasses = {
    ['SMALL_CALIBER'] = 1,
    ['MEDIUM_CALIBER'] = 2,
    ['HIGH_CALIBER'] = 3,
    ['SHOTGUN'] = 4,
    ['CUTTING'] = 5,
    ['LIGHT_IMPACT'] = 6,
    ['HEAVY_IMPACT'] = 7,
    ['EXPLOSIVE'] = 8,
    ['FIRE'] = 9,
    ['SUFFOCATING'] = 10,
    ['OTHER'] = 11,
    ['WILDLIFE'] = 12,
    ['NOTHING'] = 13
}

Config.MinorInjurWeapons = {
    [Config.WeaponClasses['SMALL_CALIBER']] = true,
    [Config.WeaponClasses['MEDIUM_CALIBER']] = true,
    [Config.WeaponClasses['CUTTING']] = true,
    [Config.WeaponClasses['WILDLIFE']] = true,
    [Config.WeaponClasses['OTHER']] = true,
    [Config.WeaponClasses['LIGHT_IMPACT']] = true,
}

Config.MajorInjurWeapons = {
    [Config.WeaponClasses['HIGH_CALIBER']] = true,
    [Config.WeaponClasses['HEAVY_IMPACT']] = true,
    [Config.WeaponClasses['SHOTGUN']] = true,
    [Config.WeaponClasses['EXPLOSIVE']] = true,
}

Config.AlwaysBleedChanceWeapons = {
    [Config.WeaponClasses['SMALL_CALIBER']] = true,
    [Config.WeaponClasses['MEDIUM_CALIBER']] = true,
    [Config.WeaponClasses['CUTTING']] = true,
    [Config.WeaponClasses['WILDLIFE']] = false,
}

Config.ForceInjuryWeapons = {
    [Config.WeaponClasses['HIGH_CALIBER']] = true,
    [Config.WeaponClasses['HEAVY_IMPACT']] = true,
    [Config.WeaponClasses['EXPLOSIVE']] = true,
}

Config.CriticalAreas = {
    ['UPPER_BODY'] = { armored = false },
    ['LOWER_BODY'] = { armored = true },
    ['SPINE'] = { armored = true },
}

Config.StaggerAreas = {
    ['SPINE'] = { armored = true, major = 60, minor = 30 },
    ['UPPER_BODY'] = { armored = false, major = 60, minor = 30 },
    ['LLEG'] = { armored = true, major = 100, minor = 85 },
    ['RLEG'] = { armored = true, major = 100, minor = 85 },
    ['LFOOT'] = { armored = true, major = 100, minor = 100 },
    ['RFOOT'] = { armored = true, major = 100, minor = 100 },
}

Config.WoundStates = {
    'irritated',
    'painful',
    'extremely painful',
    'unbearably painful',
}

Config.BleedingStates = {
    [1] = {label = 'minor bleeding', damage = 10, chance = 50},
    [2] = {label = 'significant bleeding', damage = 15, chance = 65},
    [3] = {label = 'major bleeding', damage = 20, chance = 65},
    [4] = {label = 'extreme bleeding', damage = 25, chance = 75},
}

Config.MovementRate = {
    0.98,
    0.96,
    0.94,
    0.92,
}

Config.Bones = {
    [0]     = 'NONE',
    [31085] = 'HEAD',
    [31086] = 'HEAD',
    [39317] = 'NECK',
    [57597] = 'SPINE',
    [23553] = 'SPINE',
    [24816] = 'SPINE',
    [24817] = 'SPINE',
    [24818] = 'SPINE',
    [10706] = 'UPPER_BODY',
    [64729] = 'UPPER_BODY',
    [11816] = 'LOWER_BODY',
    [45509] = 'LARM',
    [61163] = 'LARM',
    [18905] = 'LHAND',
    [4089] = 'LFINGER',
    [4090] = 'LFINGER',
    [4137] = 'LFINGER',
    [4138] = 'LFINGER',
    [4153] = 'LFINGER',
    [4154] = 'LFINGER',
    [4169] = 'LFINGER',
    [4170] = 'LFINGER',
    [4185] = 'LFINGER',
    [4186] = 'LFINGER',
    [26610] = 'LFINGER',
    [26611] = 'LFINGER',
    [26612] = 'LFINGER',
    [26613] = 'LFINGER',
    [26614] = 'LFINGER',
    [58271] = 'LLEG',
    [63931] = 'LLEG',
    [2108] = 'LFOOT',
    [14201] = 'LFOOT',
    [40269] = 'RARM',
    [28252] = 'RARM',
    [57005] = 'RHAND',
    [58866] = 'RFINGER',
    [58867] = 'RFINGER',
    [58868] = 'RFINGER',
    [58869] = 'RFINGER',
    [58870] = 'RFINGER',
    [64016] = 'RFINGER',
    [64017] = 'RFINGER',
    [64064] = 'RFINGER',
    [64065] = 'RFINGER',
    [64080] = 'RFINGER',
    [64081] = 'RFINGER',
    [64096] = 'RFINGER',
    [64097] = 'RFINGER',
    [64112] = 'RFINGER',
    [64113] = 'RFINGER',
    [36864] = 'RLEG',
    [51826] = 'RLEG',
    [20781] = 'RFOOT',
    [52301] = 'RFOOT',
}

Config.BoneIndexes = {
    ['NONE'] = 0,
    ['HEAD'] = 31085,
    ['HEAD'] = 31086,
    ['NECK'] = 39317, 
    ['SPINE'] = 57597,
    ['SPINE'] = 23553,
    ['SPINE'] = 24816,
    ['SPINE'] = 24817,
    ['SPINE'] = 24818,
    ['UPPER_BODY'] = 10706,
    ['UPPER_BODY'] = 64729,
    ['LOWER_BODY'] = 11816,
    ['LARM'] = 45509,
    ['LARM'] = 61163,
    ['LHAND'] = 18905,
    ['LFINGER'] = 4089,
    ['LFINGER'] = 4090,
    ['LFINGER'] = 4137,
    ['LFINGER'] = 4138,
    ['LFINGER'] = 4153,
    ['LFINGER'] = 4154,
    ['LFINGER'] = 4169,
    ['LFINGER'] = 4170,
    ['LFINGER'] = 4185,
    ['LFINGER'] = 4186,
    ['LFINGER'] = 26610,
    ['LFINGER'] = 26611,
    ['LFINGER'] = 26612,
    ['LFINGER'] = 26613,
    ['LFINGER'] = 26614,
    ['LLEG'] = 58271,
    ['LLEG'] = 63931,
    ['LFOOT'] = 2108,
    ['LFOOT'] = 14201,
    ['RARM'] = 40269,
    ['RARM'] = 28252,
    ['RHAND'] = 57005,
    ['RFINGER'] = 58866,
    ['RFINGER'] = 58867,
    ['RFINGER'] = 58868,
    ['RFINGER'] = 58869,
    ['RFINGER'] = 58870,
    ['RFINGER'] = 64016,
    ['RFINGER'] = 64017,
    ['RFINGER'] = 64064,
    ['RFINGER'] = 64065,
    ['RFINGER'] = 64080,
    ['RFINGER'] = 64081,
    ['RFINGER'] = 64096,
    ['RFINGER'] = 64097,
    ['RFINGER'] = 64112,
    ['RFINGER'] = 64113,
    ['RLEG'] = 36864,
    ['RLEG'] = 51826,
    ['RFOOT'] = 20781,
    ['RFOOT'] = 52301,
}

Config.Weapons = {
    [`WEAPON_STUNGUN`] = Config.WeaponClasses['NONE'],
    --[[ Small Caliber ]]--
    [`WEAPON_PISTOL`] = Config.WeaponClasses['SMALL_CALIBER'],
    [`WEAPON_COMBATPISTOL`] = Config.WeaponClasses['SMALL_CALIBER'],
    [`WEAPON_APPISTOL`] = Config.WeaponClasses['SMALL_CALIBER'],
    [`WEAPON_COMBATPDW`] = Config.WeaponClasses['SMALL_CALIBER'],
    [`WEAPON_MACHINEPISTOL`] = Config.WeaponClasses['SMALL_CALIBER'],
    [`WEAPON_MICROSMG`] = Config.WeaponClasses['SMALL_CALIBER'],
    [`WEAPON_MINISMG`] = Config.WeaponClasses['SMALL_CALIBER'],
    [`WEAPON_PISTOL_MK2`] = Config.WeaponClasses['SMALL_CALIBER'],
    [`WEAPON_SNSPISTOL`] = Config.WeaponClasses['SMALL_CALIBER'],
    [`WEAPON_SNSPISTOL_MK2`] = Config.WeaponClasses['SMALL_CALIBER'],
    [`WEAPON_VINTAGEPISTOL`] = Config.WeaponClasses['SMALL_CALIBER'],

    --[[ Medium Caliber ]]--
    [`WEAPON_ADVANCEDRIFLE`] = Config.WeaponClasses['MEDIUM_CALIBER'],
    [`WEAPON_ASSAULTSMG`] = Config.WeaponClasses['MEDIUM_CALIBER'],
    [`WEAPON_BULLPUPRIFLE`] = Config.WeaponClasses['MEDIUM_CALIBER'],
    [`WEAPON_BULLPUPRIFLE_MK2`] = Config.WeaponClasses['MEDIUM_CALIBER'],
    [`WEAPON_CARBINERIFLE`] = Config.WeaponClasses['MEDIUM_CALIBER'],
    [`WEAPON_CARBINERIFLE_MK2`] = Config.WeaponClasses['MEDIUM_CALIBER'],
    [`WEAPON_COMPACTRIFLE`] = Config.WeaponClasses['MEDIUM_CALIBER'],
    [`WEAPON_DOUBLEACTION`] = Config.WeaponClasses['MEDIUM_CALIBER'],
    [`WEAPON_GUSENBERG`] = Config.WeaponClasses['MEDIUM_CALIBER'],
    [`WEAPON_HEAVYPISTOL`] = Config.WeaponClasses['MEDIUM_CALIBER'],
    [`WEAPON_MARKSMANPISTOL`] = Config.WeaponClasses['MEDIUM_CALIBER'],
    [`WEAPON_PISTOL50`] = Config.WeaponClasses['MEDIUM_CALIBER'],
    [`WEAPON_REVOLVER`] = Config.WeaponClasses['MEDIUM_CALIBER'],
    [`WEAPON_REVOLVER_MK2`] = Config.WeaponClasses['MEDIUM_CALIBER'],
    [`WEAPON_SMG`] = Config.WeaponClasses['MEDIUM_CALIBER'],
    [`WEAPON_SMG_MK2`] = Config.WeaponClasses['MEDIUM_CALIBER'],
    [`WEAPON_SPECIALCARBINE`] = Config.WeaponClasses['MEDIUM_CALIBER'],
    [`WEAPON_SPECIALCARBINE_MK2`] = Config.WeaponClasses['MEDIUM_CALIBER'],

    --[[ High Caliber ]]--
    [`WEAPON_ASSAULTRIFLE`] = Config.WeaponClasses['HIGH_CALIBER'],
    [`WEAPON_ASSAULTRIFLE_MK2`] = Config.WeaponClasses['HIGH_CALIBER'],
    [`WEAPON_COMBATMG`] = Config.WeaponClasses['HIGH_CALIBER'],
    [`WEAPON_COMBATMG_MK2`] = Config.WeaponClasses['HIGH_CALIBER'],
    [`WEAPON_HEAVYSNIPER`] = Config.WeaponClasses['HIGH_CALIBER'],
    [`WEAPON_HEAVYSNIPER_MK2`] = Config.WeaponClasses['HIGH_CALIBER'],
    [`WEAPON_MARKSMANRIFLE`] = Config.WeaponClasses['HIGH_CALIBER'],
    [`WEAPON_MARKSMANRIFLE_MK2`] = Config.WeaponClasses['HIGH_CALIBER'],
    [`WEAPON_MG`] = Config.WeaponClasses['HIGH_CALIBER'],
    [`WEAPON_MINIGUN`] = Config.WeaponClasses['HIGH_CALIBER'],
    [`WEAPON_MUSKET`] = Config.WeaponClasses['HIGH_CALIBER'],
    [`WEAPON_RAILGUN`] = Config.WeaponClasses['HIGH_CALIBER'],

    --[[ Shotguns ]]--
    [`WEAPON_ASSAULTSHOTGUN`] = Config.WeaponClasses['SHOTGUN'],
    [`WEAPON_BULLUPSHOTGUN`] = Config.WeaponClasses['SHOTGUN'],
    [`WEAPON_DBSHOTGUN`] = Config.WeaponClasses['SHOTGUN'],
    [`WEAPON_HEAVYSHOTGUN`] = Config.WeaponClasses['SHOTGUN'],
    [`WEAPON_PUMPSHOTGUN`] = Config.WeaponClasses['SHOTGUN'],
    [`WEAPON_PUMPSHOTGUN_MK2`] = Config.WeaponClasses['SHOTGUN'],
    [`WEAPON_SAWNOFFSHOTGUN`] = Config.WeaponClasses['SHOTGUN'],
    [`WEAPON_SWEEPERSHOTGUN`] = Config.WeaponClasses['SHOTGUN'],

    --[[ Animals ]]--
    [`WEAPON_ANIMAL`] = Config.WeaponClasses['WILDLIFE'], -- Animal
    [`WEAPON_COUGAR`] = Config.WeaponClasses['WILDLIFE'], -- Cougar
    [`WEAPON_BARBED_WIRE`] = Config.WeaponClasses['WILDLIFE'], -- Barbed Wire
    
    --[[ Cutting Weapons ]]--
    [`WEAPON_BATTLEAXE`] = Config.WeaponClasses['CUTTING'],
    [`WEAPON_BOTTLE`] = Config.WeaponClasses['CUTTING'],
    [`WEAPON_DAGGER`] = Config.WeaponClasses['CUTTING'],
    [`WEAPON_HATCHET`] = Config.WeaponClasses['CUTTING'],
    [`WEAPON_KNIFE`] = Config.WeaponClasses['CUTTING'],
    [`WEAPON_MACHETE`] = Config.WeaponClasses['CUTTING'],
    [`WEAPON_SWITCHBLADE`] = Config.WeaponClasses['CUTTING'],

    --[[ Light Impact ]]--
    [`WEAPON_KNUCKLE`] = Config.WeaponClasses['LIGHT_IMPACT'],
    [`WEAPON_BAT`] = Config.WeaponClasses['LIGHT_IMPACT'],
    [`WEAPON_CROWBAR`] = Config.WeaponClasses['LIGHT_IMPACT'],
    [`WEAPON_FIREEXTINGUISHER`] = Config.WeaponClasses['LIGHT_IMPACT'],
    [`WEAPON_FIRWORK`] = Config.WeaponClasses['LIGHT_IMPACT'],
    [`WEAPON_GOLFLCUB`] = Config.WeaponClasses['LIGHT_IMPACT'],
    [`WEAPON_HAMMER`] = Config.WeaponClasses['LIGHT_IMPACT'],
    [`WEAPON_PETROLCAN`] = Config.WeaponClasses['LIGHT_IMPACT'],
    [`WEAPON_POOLCUE`] = Config.WeaponClasses['LIGHT_IMPACT'],
    [`WEAPON_WRENCH`] = Config.WeaponClasses['LIGHT_IMPACT'],

    
    --[[ Heavy Impact ]]--
    [`WEAPON_BAT`] = Config.WeaponClasses['HEAVY_IMPACT'],
    [`WEAPON_RAMMED_BY_CAR`] = Config.WeaponClasses['HEAVY_IMPACT'],
    [`WEAPON_RUN_OVER_BY_CAR`] = Config.WeaponClasses['HEAVY_IMPACT'],
    
    --[[ Explosives ]]--
    [`WEAPON_EXPLOSION`] = Config.WeaponClasses['EXPLOSIVE'],
    [`WEAPON_GRENADE`] = Config.WeaponClasses['EXPLOSIVE'],
    [`WEAPON_COMPACTLAUNCHER`] = Config.WeaponClasses['EXPLOSIVE'],
    [`WEAPON_HOMINGLAUNCHER`] = Config.WeaponClasses['EXPLOSIVE'],
    [`WEAPON_PIPEBOMB`] = Config.WeaponClasses['EXPLOSIVE'],
    [`WEAPON_PROXMINE`] = Config.WeaponClasses['EXPLOSIVE'],
    [`WEAPON_RPG`] = Config.WeaponClasses['EXPLOSIVE'],
    [`WEAPON_STICKYBOMB`] = Config.WeaponClasses['EXPLOSIVE'],
    [`WEAPON_HELI_CRASH`] = Config.WeaponClasses['EXPLOSIVE'],
    
    --[[ Other ]]--
    [`WEAPON_FALL`] = Config.WeaponClasses['OTHER'], -- Fall
    [`WEAPON_HIT_BY_WATER_CANNON`] = Config.WeaponClasses['OTHER'], -- Water Cannon
    
    --[[ Fire ]]--
    [`WEAPON_ELECTRIC_FENCE`] = Config.WeaponClasses['FIRE'],
    [`WEAPON_FIRE`] = Config.WeaponClasses['FIRE'],
    [`WEAPON_MOLOTOV`] = Config.WeaponClasses['FIRE'],
    [`WEAPON_FLARE`] = Config.WeaponClasses['FIRE'],
    [`WEAPON_FLAREGUN`] = Config.WeaponClasses['FIRE'],

    --[[ Suffocate ]]--
    [`WEAPON_DROWNING`] = Config.WeaponClasses['SUFFOCATING'], -- Drowning
    [`WEAPON_DROWNING_IN_VEHICLE`] = Config.WeaponClasses['SUFFOCATING'], -- Drowning Veh
    [`WEAPON_EXHAUSTION`] = Config.WeaponClasses['SUFFOCATING'], -- Exhaust
    [`WEAPON_BZGAS`] = Config.WeaponClasses['SUFFOCATING'],
    [`WEAPON_SMOKEGRENADE`] = Config.WeaponClasses['SUFFOCATING'],
}