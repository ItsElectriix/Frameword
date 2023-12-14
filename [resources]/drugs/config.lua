Keys = {
	['ESC'] = 322, ['F1'] = 288, ['F2'] = 289, ['F3'] = 170, ['F5'] = 166, ['F6'] = 167, ['F7'] = 168, ['F8'] = 169, ['F9'] = 56, ['F10'] = 57,
	['~'] = 243, ['1'] = 157, ['2'] = 158, ['3'] = 160, ['4'] = 164, ['5'] = 165, ['6'] = 159, ['7'] = 161, ['8'] = 162, ['9'] = 163, ['-'] = 84, ['='] = 83, ['BACKSPACE'] = 177,
	['TAB'] = 37, ['Q'] = 44, ['W'] = 32, ['E'] = 38, ['R'] = 45, ['T'] = 245, ['Y'] = 246, ['U'] = 303, ['P'] = 199, ['['] = 39, [']'] = 40, ['ENTER'] = 18,
	['CAPS'] = 137, ['A'] = 34, ['S'] = 8, ['D'] = 9, ['F'] = 23, ['G'] = 47, ['H'] = 74, ['K'] = 311, ['L'] = 182,
	['LEFTSHIFT'] = 21, ['Z'] = 20, ['X'] = 73, ['C'] = 26, ['V'] = 0, ['B'] = 29, ['N'] = 249, ['M'] = 244, [','] = 82, ['.'] = 81,
	['LEFTCTRL'] = 36, ['LEFTALT'] = 19, ['SPACE'] = 22, ['RIGHTCTRL'] = 70,
	['HOME'] = 213, ['PAGEUP'] = 10, ['PAGEDOWN'] = 11, ['DELETE'] = 178,
	['LEFT'] = 174, ['RIGHT'] = 175, ['TOP'] = 27, ['DOWN'] = 173,
}

Config = Config or {}

local StringCharset = {}
local NumberCharset = {}

for i = 48,  57 do table.insert(NumberCharset, string.char(i)) end
for i = 65,  90 do table.insert(StringCharset, string.char(i)) end
for i = 97, 122 do table.insert(StringCharset, string.char(i)) end

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

Config.Products = {
	[1] = {
		name = "weed_white-widow",
		price = 15,
		amount = 150,
		info = {},
		type = "item",
		slot = 1,
		minrep = 0,
	},
	[2] = {
		name = "weed_skunk",
		price = 15,
		amount = 150,
		info = {},
		type = "item",
		slot = 2,
		minrep = 20,
	},
	[3] = {
		name = "weed_purple-haze",
		price = 15,
		amount = 150,
		info = {},
		type = "item",
		slot = 3,
		minrep = 40,
	},
	[4] = {
		name = "weed_og-kush",
		price = 15,
		amount = 150,
		info = {},
		type = "item",
		slot = 4,
		minrep = 60,
	},
	[5] = {
		name = "weed_amnesia",
		price = 15,
		amount = 150,
		info = {},
		type = "item",
		slot = 5,
		minrep = 80,
	},
	[6] = {
		name = "weed_white-widow_seed",
		price = 15,
		amount = 150,
		info = {},
		type = "item",
		slot = 6,
		minrep = 100,
	},
	[7] = {
		name = "weed_skunk_seed",
		price = 15,
		amount = 150,
		info = {},
		type = "item",
		slot = 7,
		minrep = 120,
	},
	[8] = {
		name = "weed_purple-haze_seed",
		price = 15,
		amount = 150,
		info = {},
		type = "item",
		slot = 8,
		minrep = 140,
	},
	[9] = {
		name = "weed_og-kush_seed",
		price = 15,
		amount = 150,
		info = {},
		type = "item",
		slot = 9,
		minrep = 160,
	},
	[10] = {
		name = "weed_amnesia_seed",
		price = 15,
		amount = 150,
		info = {},
		type = "item",
		slot = 10,
		minrep = 180,
	},
}

Config.Dealers = {}

Config.CornerSellingDrugsList = {
	"weed_white-widow_bag",
	"weed_skunk_bag",
	"weed_purple-haze_bag",
	"weed_og-kush_bag",
	"weed_amnesia_bag",
	"weed_ak47_bag",
}

Config.DrugsPrice = {
    ["weed_white-widow_bag"] = {
        min = 1,
        max = 3,
    },
    ["weed_og-kush_bag"] = {
        min = 1,
        max = 3,
    },
    ["weed_skunk_bag"] = {
        min = 1,
        max = 3,
    },
    ["weed_amnesia_bag"] = {
        min = 1,
        max = 4,
    },
    ["weed_purple-haze_bag"] = {
        min = 1,
        max = 4,
    },
    ["weed_ak47_bag"] = {
        min = 1,
        max = 5,
    },
}

Config.DeliveryLocations = {
	[1] = {
		["label"] = "Stripclub",
		["coords"] = vector3(106.24, -1280.32, 29.24)
	},
	[2] = {
		["label"] = "Vinewood Video",
		["coords"] = vector3(223.98, 121.53, 102.76)
	},
	[3] = {
		["label"] = "Vinewood Video",
		["coords"] = vector3(223.98, 121.53, 102.76)
	},
	[4] = {
		["label"] = "Resort",
		["coords"] = vector3(-1245.63, 376.21, 75.34)
	},
	[5] = {
		["label"] = "Bahama Mamas",
		["coords"] = vector3(-1383.1, -639.99, 28.67)
	},
}

Config.CornerSellingZones = {
	[1] = {
		["coords"] = vector3(-1415.53, -1041.51, 4.62),
		["time"] = {
			["min"] = 12,
			["max"] = 18,
		},
	},
}

Config.DeliveryItems = {
	[1] = {
		["item"] = "weed_brick",
		["minrep"] = 0,
	},
}

Config.WhitelistWeed = {
    ["NYJ30057"] = true,
}

-- Weed Growing
Config.WeedAllowedSurfaces = {
	-- [1333033863] = true ,-- grass
	-- [-1286696947] = true, -- grass short
	-- [-461750719] = true, -- grass long
	[-700658213] = true, -- soil
	[1109728704] = true, -- mud_deep
	[-642658848] = true, -- tarpaulin
	[-1942898710] = true, -- mud_hard
}

Config.WeedPlants = {
	["og-kush"] = {
		["label"] = "OG Kush",
		["item"] = "ogkush",
		["stages"] = {
			["stage-a"] = "bkr_prop_weed_01_small_01c",
			["stage-b"] = "bkr_prop_weed_01_small_01b",
			["stage-c"] = "bkr_prop_weed_01_small_01a",
			["stage-d"] = "bkr_prop_weed_med_01a",
			["stage-e"] = "bkr_prop_weed_med_01b",
			["stage-f"] = "bkr_prop_weed_lrg_01a",
			["stage-g"] = "bkr_prop_weed_lrg_01b",
		},
		["highestStage"] = "stage-g"
	},
	["amnesia"] = {
		["label"] = "Amnesia",
		["item"] = "amnesia",
		["stages"] = {
			["stage-a"] = "bkr_prop_weed_01_small_01c",
			["stage-b"] = "bkr_prop_weed_01_small_01b",
			["stage-c"] = "bkr_prop_weed_01_small_01a",
			["stage-d"] = "bkr_prop_weed_med_01a",
			["stage-e"] = "bkr_prop_weed_med_01b",
			["stage-f"] = "bkr_prop_weed_lrg_01a",
			["stage-g"] = "bkr_prop_weed_lrg_01b",
		},
		["highestStage"] = "stage-g"
	},
	["skunk"] = {
		["label"] = "Skunk",
		["item"] = "skunk",
		["stages"] = {
			["stage-a"] = "bkr_prop_weed_01_small_01c",
			["stage-b"] = "bkr_prop_weed_01_small_01b",
			["stage-c"] = "bkr_prop_weed_01_small_01a",
			["stage-d"] = "bkr_prop_weed_med_01a",
			["stage-e"] = "bkr_prop_weed_med_01b",
			["stage-f"] = "bkr_prop_weed_lrg_01a",
			["stage-g"] = "bkr_prop_weed_lrg_01b",
		},
		["highestStage"] = "stage-g"
	},
	["ak47"] = {
		["label"] = "AK 47",
		["item"] = "ak47",
		["stages"] = {
			["stage-a"] = "bkr_prop_weed_01_small_01c",
			["stage-b"] = "bkr_prop_weed_01_small_01b",
			["stage-c"] = "bkr_prop_weed_01_small_01a",
			["stage-d"] = "bkr_prop_weed_med_01a",
			["stage-e"] = "bkr_prop_weed_med_01b",
			["stage-f"] = "bkr_prop_weed_lrg_01a",
			["stage-g"] = "bkr_prop_weed_lrg_01b",
		},
		["highestStage"] = "stage-g"
	},
	["purple-haze"] = {
		["label"] = "Purple Haze",
		["item"] = "purplehaze",
		["stages"] = {
			["stage-a"] = "bkr_prop_weed_01_small_01c",
			["stage-b"] = "bkr_prop_weed_01_small_01b",
			["stage-c"] = "bkr_prop_weed_01_small_01a",
			["stage-d"] = "bkr_prop_weed_med_01a",
			["stage-e"] = "bkr_prop_weed_med_01b",
			["stage-f"] = "bkr_prop_weed_lrg_01a",
			["stage-g"] = "bkr_prop_weed_lrg_01b",
		},
		["highestStage"] = "stage-g"
	},
	["white-widow"] = {
		["label"] = "White Widow",
		["item"] = "whitewidow",
		["stages"] = {
			["stage-a"] = "bkr_prop_weed_01_small_01c",
			["stage-b"] = "bkr_prop_weed_01_small_01b",
			["stage-c"] = "bkr_prop_weed_01_small_01a",
			["stage-d"] = "bkr_prop_weed_med_01a",
			["stage-e"] = "bkr_prop_weed_med_01b",
			["stage-f"] = "bkr_prop_weed_lrg_01a",
			["stage-g"] = "bkr_prop_weed_lrg_01b",
		},
		["highestStage"] = "stage-g"
	},
}

Config.WeedProps = {
	["stage-a"] = "bkr_prop_weed_01_small_01c",
	["stage-b"] = "bkr_prop_weed_01_small_01b",
	["stage-c"] = "bkr_prop_weed_01_small_01a",
	["stage-d"] = "bkr_prop_weed_med_01a",
	["stage-e"] = "bkr_prop_weed_med_01b",
	["stage-f"] = "bkr_prop_weed_lrg_01a",
	["stage-g"] = "bkr_prop_weed_lrg_01b",
}

--

Config.CokeStartPos = {
	[1] = vector4(-1565.499, -231.0715, 48.468002, 130.54431),
	[2] = vector4(-1519.57, -894.0059, 12.684654, 321.60308),
}

Config.ReqDealerRep = 100 -- required dealerrep to pay for coke field access

Config.RequiredItemsForAccess = {
	[1] = {
		rep = 25,
		cost = {
			[1] = {
				item = "cashroll",
				amount = 150
			},
			[2] = {
				item = "cashband",
				amount = 60
			}
		}
	},
	[2] = {
		rep = 50,
		cost = {
			[1] = {
				item = "cashroll",
				amount = 125
			},
			[2] = {
				item = "cashband",
				amount = 50
			}
		}
	},
	[3] = {
		rep = 75,
		cost = {
			[1] = {
				item = "cashroll",
				amount = 100
			},
			[2] = {
				item = "cashband",
				amount = 40
			}
		}
	},
	[4] = {
		rep = 150,
		cost = {
			[1] = {
				item = "cashroll",
				amount = 75
			},
			[2] = {
				item = "cashband",
				amount = 30
			}
		}
	},
}

Config.DropOffLocations = {
	[1] = vector4(-339.6113, -97.42204, 46.08267, 159.683),
	[2] = vector4(833.8826, -1180.356, 24.66853, 273.000),
	[3] = vector4(6.676902, 6499.249, 30.49041, 310.000),
	[4] = vector4(2566.903, 4645.646, 33.08878, 27.312),
	[5] = vector4(2381.696, 3099.372, 47.14771, 73.733),
	[6] = vector4(1129.776, 2130.802, 54.55114, 90.595),
	[7] = vector4(995.1973, -1528.035, 29.87523, 357.983),
	[8] = vector4(490.2199, -991.1679, 26.68316, 78.052),
}

Config.CokeFieldNPC = vector4(5341.8613, -5223.918, 30.578598, 215.5442)

Config.CokeLabLocations = {
	[1] = vector4(5002.0458, -5192.6, 2.5153212, 298.73724),
	[2] = vector4(5103.7543, -4679.745, 3.329137, 345.71234),
}

Config.CokeLabProductionPos = {
	["prepare"] = {
		[1] = vector3(1091.259, -3187.956, -39.55095),
		[2] =  vector3(1091.245, -3189.491, -39.55095),
		[3] = vector3(1091.198, -3190.975, -39.55095),
		[4] =  vector3(1086.143, -3191.02, -39.55095),
		[5] =  vector3(1086.113, -3189.699, -39.55095),
	},
	["extract"] = {
		[1] = vector3(1086.6784, -3197.81, -38.94921),
	},
	["process"] = {
		[1] = {
			[1] = vector3(1095.4251, -3195.351, -38.97051),
			[2] = vector3(1095.426, -3196.291, -38.97072)
		},
		[2] = {
			[1] = vector3(1092.9764, -3195.38, -38.97072),
			[2] = vector3(1092.9307, -3196.189, -38.96579)
		},
		[3] = {
			[1] = vector3(1090.372, -3195.343, -39.09344),
			[2] = vector3(1090.3803, -3196.144, -38.97072)
		},	
	},
	["package"] = {
		[1] = vector3(1101.7882, -3193.062, -38.97072),
		[2] = vector3(1100.6131, -3199.393, -38.95233)
	},
}

Config.CokeLeafCookTime = 3 -- minutes

Config.ProductionFailureChance = {
	[1] = {
		rep = 25,
		chance = 8, -- percent
	},
	[2] = {
		rep = 50,
		chance = 7,
	},
	[3] = {
		rep = 75,
		chance = 6,
	},
	[4] = {
		rep = 100,
		chance = 2,
	},
}

Config.CokeRep = {
	["field"] = {
		chance = 10,
		adder = 1,
	},
	["lab"] ={
		chance = 10,
		adder = 1,
	}
}

Config.ProductionScaleTime = {
	[1] = {
		rep = 25,
		scale = 5, -- scale down
	},
	[2] = {
		rep = 50,
		scale = 10,
	},
	[3] = {
		rep = 75,
		scale = 15,
	},
	[4] = {
		rep = 150,
		scale = 20,
	},
}

Config.CokeLabStash = vector3(1096.8835, -3192.455, -38.99342)

BJCore = nil
TriggerEvent('BJCore:GetObject', function(obj) BJCore = obj end)
Citizen.CreateThread(function(...) while BJCore == nil do TriggerEvent("BJCore:GetObject", function(obj) BJCore = obj end); Citizen.Wait(1000); end; end)