Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
}

Config = Config or {}

Config.Throwables = {
    ["weapon_stickybomb"] = true,
    ["weapon_grenade"] = true,
    ["weapon_molotov"] = true
}

Config.DurabilityBlockedWeapons = {
    "weapon_combatpistol",
    "weapon_stungun",
    "weapon_pumpshotgun",
    "weapon_smg",
    "weapon_carbinerifle",
    "weapon_nightstick",
    "weapon_flashlight",
    "weapon_unarmed",
}

Config.DurabilityMultiplier = {
    ["weapon_unarmed"] 				 = 0.075,
    ["weapon_knife"] 				 = 0.075,
    ["weapon_nightstick"] 			 = 0.075,
    ["weapon_hammer"] 				 = 0.075,
    ["weapon_bat"] 					 = 0.075,
    ["weapon_golfclub"] 			 = 0.075,
    ["weapon_crowbar"] 				 = 0.075,
    ["weapon_pistol"] 				 = 0.075,
    ["weapon_pistol_mk2"] 			 = 0.075,
    ["weapon_combatpistol"] 		 = 0.075,
    ["weapon_appistol"] 			 = 0.075,
    ["weapon_pistol50"] 			 = 0.075,
    ["weapon_microsmg"] 			 = 0.075,
    ["weapon_smg"] 				 	 = 0.075,
    ["weapon_assaultsmg"] 			 = 0.075,
    ["weapon_assaultrifle"] 		 = 0.075,
    ["weapon_carbinerifle"] 		 = 0.075,
    ["weapon_advancedrifle"] 		 = 0.075,
    ["weapon_mg"] 					 = 0.075,
    ["weapon_combatmg"] 			 = 0.075,
    ["weapon_pumpshotgun"] 			 = 0.075,
    ["weapon_sawnoffshotgun"] 		 = 0.075,
    ["weapon_assaultshotgun"] 		 = 0.075,
    ["weapon_bullpupshotgun"] 		 = 0.075,
    ["weapon_stungun"] 				 = 0.075,
    ["weapon_sniperrifle"] 			 = 0.075,
    ["weapon_heavysniper"] 			 = 0.075,
    ["weapon_remotesniper"] 		 = 0.075,
    ["weapon_grenadelauncher"] 		 = 0.075,
    ["weapon_grenadelauncher_smoke"] = 0.075,
    ["weapon_rpg"] 					 = 0.075,
    ["weapon_minigun"] 				 = 0.075,
    ["weapon_grenade"] 				 = 0.075,
    ["weapon_stickybomb"] 			 = 0.075,
    ["weapon_smokegrenade"] 		 = 0.075,
    ["weapon_bzgas"] 				 = 0.075,
    ["weapon_molotov"] 				 = 0.075,
    ["weapon_fireextinguisher"] 	 = 0.075,
    ["weapon_petrolcan"] 			 = 0.075,
    ["weapon_briefcase"] 			 = 0.075,
    ["weapon_briefcase_02"] 		 = 0.075,
    ["weapon_ball"] 				 = 0.075,
    ["weapon_flare"] 				 = 0.075,
    ["weapon_snspistol"] 			 = 0.075,
    ["weapon_bottle"] 				 = 0.075,
    ["weapon_gusenberg"] 			 = 0.075,
    ["weapon_specialcarbine"] 		 = 0.075,
    ["weapon_heavypistol"] 			 = 0.075,
    ["weapon_bullpuprifle"] 		 = 0.075,
    ["weapon_dagger"] 				 = 0.075,
    ["weapon_vintagepistol"] 		 = 0.075,
    ["weapon_firework"] 			 = 0.075,
    ["weapon_musket"] 			     = 0.075,
    ["weapon_heavyshotgun"] 		 = 0.075,
    ["weapon_marksmanrifle"] 		 = 0.075,
    ["weapon_hominglauncher"] 		 = 0.075,
    ["weapon_proxmine"] 			 = 0.075,
    ["weapon_snowball"] 		     = 0.075,
    ["weapon_flaregun"] 			 = 0.075,
    ["weapon_garbagebag"] 			 = 0.075,
    ["weapon_handcuffs"] 			 = 0.075,
    ["weapon_combatpdw"] 			 = 0.075,
    ["weapon_marksmanpistol"] 		 = 0.075,
    ["weapon_knuckle"] 				 = 0.075,
    ["weapon_hatchet"] 				 = 0.075,
    ["weapon_railgun"] 				 = 0.075,
    ["weapon_machete"] 				 = 0.075,
    ["weapon_machinepistol"] 		 = 0.075,
    ["weapon_switchblade"] 			 = 0.075,
    ["weapon_revolver"] 			 = 0.075,
    ["weapon_dbshotgun"] 			 = 0.075,
    ["weapon_compactrifle"] 		 = 0.075,
    ["weapon_autoshotgun"] 			 = 0.075,
    ["weapon_battleaxe"] 			 = 0.075,
    ["weapon_compactlauncher"] 		 = 0.075,
    ["weapon_minismg"] 				 = 0.075,
    ["weapon_pipebomb"] 			 = 0.075,
    ["weapon_poolcue"] 				 = 0.075,
    ["weapon_wrench"] 				 = 0.075,
    ["weapon_autoshotgun"] 		 	 = 0.075,
    ["weapon_bread"] 				 = 0.075,
}

Config.WeaponRepairPoints = {
    [1] = {
        coords = {x = 964.02, y = -1267.41, z = 34.97, h = 35.5, r = 1.0},
        IsRepairing = false,
        RepairingData = {},
    }
}

Config.WeaponRepairCotsts = {
    ["pistol"] = 1000,
    ["smg"] = 3000,
    ["rifle"] = 5000,
}

Config.WeaponAttachments = {
    ["WEAPON_SNSPISTOL"] = {
        ["extendedclip"] = {
            component = "COMPONENT_SNSPISTOL_CLIP_02",
            label = "Extended Clip",
            item = "pistol_extendedclip",
        },
    },
    ["WEAPON_COMBATPISTOL"] = {
        ["extendedclip"] = {
            component = "COMPONENT_COMBATPISTOL_CLIP_02",
            label = "Extended Clip",
            item = "pistol_extendedclip",
        },
        ["suppressor"] = {
            component = "COMPONENT_AT_PI_SUPP",
            label = "Suppressor",
            item = "pistol_suppressor",
        },
        ["flashlight"] = {
            component = "COMPONENT_AT_PI_FLSH",
            label = "Flashlight",
            item = "smg_flashlight",
        },
    },
    ["WEAPON_VINTAGEPISTOL"] = {
        ["suppressor"] = {
            component = "COMPONENT_AT_PI_SUPP",
            label = "Suppressor",
            item = "pistol_suppressor",
        },
        ["extendedclip"] = {
            component = "COMPONENT_VINTAGEPISTOL_CLIP_02",
            label = "Extended Clip",
            item = "pistol_extendedclip",
        },
    },
    ["WEAPON_MICROSMG"] = {
        ["suppressor"] = {
            component = "COMPONENT_AT_AR_SUPP_02",
            label = "Suppressor",
            item = "smg_suppressor",
        },
        ["extendedclip"] = {
            component = "COMPONENT_MICROSMG_CLIP_02",
            label = "Extended Clip",
            item = "smg_extendedclip",
        },
        ["flashlight"] = {
            component = "COMPONENT_AT_PI_FLSH",
            label = "Flashlight",
            item = "smg_flashlight",
        },
        ["scope"] = {
            component = "COMPONENT_AT_SCOPE_MACRO",
            label = "Scope",
            item = "smg_scope",
        },
    },
    ["WEAPON_SMG"] = {
        ["suppressor"] = {
            component = "COMPONENT_AT_PI_SUPP",
            label = "Suppressor",
            item = "smg_suppressor",
        },
        ["extendedclip"] = {
            component = "COMPONENT_SMG_CLIP_02",
            label = "Extended Clip",
            item = "smg_extendedclip",
        },
        ["drummag"] = {
            component = "COMPONENT_SMG_CLIP_03",
            label = "Drum Mag",
            item = "rifle_drummag",
        },
        ["flashlight"] = {
            component = "COMPONENT_AT_AR_FLSH",
            label = "Flashlight",
            item = "smg_flashlight",
        },
        ["scope"] = {
            component = "COMPONENT_AT_SCOPE_MACRO_02",
            label = "Scope",
            item = "smg_scope",
        },
    },
    ["WEAPON_MINISMG"] = {
        ["extendedclip"] = {
            component = "COMPONENT_MINISMG_CLIP_02",
            label = "Extended Clip",
            item = "smg_extendedclip",
        },
    },
    ["WEAPON_COMPACTRIFLE"] = {
        ["extendedclip"] = {
            component = "COMPONENT_COMPACTRIFLE_CLIP_02",
            label = "Extended Clip",
            item = "rifle_extendedclip",
        },
        ["drummag"] = {
            component = "COMPONENT_COMPACTRIFLE_CLIP_03",
            label = "Drum Mag",
            item = "rifle_drummag",
        },
    },
	["WEAPON_CARBINERIFLE"] = {
		["suppressor"] = {
            component = "COMPONENT_AT_AR_SUPP",
            label = "Suppressor",
            item = "rifle_suppressor",
        },
        ["extendedclip"] = {
            component = "COMPONENT_CARBINERIFLE_CLIP_02",
            label = "Extended Clip",
            item = "rifle_extendedclip",
        },
        ["drummag"] = {
            component = "COMPONENT_CARBINERIFLE_CLIP_03",
            label = "Drum Mag",
            item = "rifle_drummag",
        },
        ["flashlight"] = {
            component = "COMPONENT_AT_AR_SUPP",
            label = "Flashlight",
            item = "smg_flashlight",
        },
        ["scope"] = {
            component = "COMPONENT_AT_SCOPE_MEDIUM",
            label = "Scope",
            item = "smg_scope",
        },
    },
    ["WEAPON_PUMPSHOTGUN"] = {
        ["suppressor"] = {
            component = "COMPONENT_AT_SR_SUPP",
            label = "Suppressor",
            item = "rifle_suppressor",
        },
        ["flashlight"] = {
            component = "COMPONENT_AT_AR_FLSH",
            label = "Flashlight",
            item = "smg_flashlight",
        },
    },
}