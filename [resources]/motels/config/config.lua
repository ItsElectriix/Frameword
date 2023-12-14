Config = {}

Config.RoomMarkers = {
	sizes = {x = 0.5, y = 0.5, z = 0.5},
	color = {r = 0, g = 0, b = 255, a = 100},
	rotate = true,
}

Config.Complexs = {
	[1] = {id = 1,  name = "The Pink Cage Motel", pos = vector3(316.43, -223.52, 54.06), reception = vector3(316.43, -223.52, 54.06), price = 180,
		offsets = {
			stash = { x = 2.94, y = 4.56 },
			menu  = { x = 0.07, y = 4.82 },
			cloth = { x = 0.42, y = 6.62 },
		}
	},

	[2] = {id = 2,  name = "Perrera Beach Motel", pos = vector3(-1477.35, -674.07, 29.04), reception = vector3(-1477.35, -674.07, 29.04), price = 180,
		offsets = {
			stash = { x = 2.94, y = 4.56 },
			menu  = { x = 0.07, y = 4.82 },
			cloth = { x = 0.42, y = 6.62 },
		}
	},

	[3] = {id = 3,  name = "Bilingsgate Motel", pos = vector3(570.23, -1746.63, 29.22), reception = vector3(570.23, -1746.63, 29.22), price = 180,
		offsets = {
			stash = { x = 2.94, y = 4.56 },
			menu  = { x = 0.07, y = 4.82 },
			cloth = { x = 0.42, y = 6.62 },
		}
	},

	[4] = {id = 4,  name = "Crown Jewels Motel", pos = vector3(-1317.17, -939.03, 9.73), reception = vector3(-1317.17, -939.03, 9.73), price = 180,
		offsets = {
			stash = { x = 2.94, y = 4.56 },
			menu  = { x = 0.07, y = 4.82 },
			cloth = { x = 0.42, y = 6.62 },
		}
	},

	[5] = {id = 5,  name = "The Rancho Motel", pos = vector3(361.95, -1798.7, 29.1), reception = vector3(361.95, -1798.7, 29.1), price = 180,
		offsets = {
			stash = { x = 2.94, y = 4.56 },
			menu  = { x = 0.07, y = 4.82 },
			cloth = { x = 0.42, y = 6.62 },
		}
	},

	[6] = {id = 6,  name = "Von Crastenburg Motel", pos = vector3(435.98, 215.37, 103.17), reception = vector3(435.98, 215.37, 103.17), price = 180,
		offsets = {
			stash = { x = 2.94, y = 4.56 },
			menu  = { x = 0.07, y = 4.82 },
			cloth = { x = 0.42, y = 6.62 },
		}
	},

	[7] = {id = 7,  name = "The Motor Motel", pos = vector3(1141.62, 2664.1, 38.16), reception = vector3(1141.62, 2664.1, 38.16), price = 180,
		offsets = {
			stash = { x = 2.94, y = 4.56 },
			menu  = { x = 0.07, y = 4.82 },
			cloth = { x = 0.42, y = 6.62 },
		}
	},

	[8] = {id = 8,  name = "Eastern Motel", pos = vector3(317.33, 2623.21, 44.46), reception = vector3(317.33, 2623.21, 44.46), price = 180,
		offsets = {
			stash = { x = 2.94, y = 4.56 },
			menu  = { x = 0.07, y = 4.82 },
			cloth = { x = 0.42, y = 6.62 },
		}
	},

	[9] = {id = 9,  name = "Bayview Lodge Motel", pos = vector3(-695.99, 5802.4, 17.33), reception = vector3(-695.99, 5802.4, 17.33), price = 180,
		offsets = {
			stash = { x = 2.94, y = 4.56 },
			menu  = { x = 0.07, y = 4.82 },
			cloth = { x = 0.42, y = 6.62 },
		}
	},

	[10] = {id = 10,  name = "Dream View Motel", pos = vector3(-104.86, 6315.9, 31.58), reception = vector3(-104.86, 6315.9, 31.58), price = 180,
		offsets = {
			stash = { x = 2.94, y = 4.56 },
			menu  = { x = 0.07, y = 4.82 },
			cloth = { x = 0.42, y = 6.62 },
		}
	},
}

Config.Rooms = {
	-- The Pink Cage Motel
	{ motelid = 1, roomno = 1, lock = true, owner = nil, entry = vector3(312.88, -218.81, 54.22), outZ = 54.22, heading = 348.17, upperfloor = false },
	{ motelid = 1, roomno = 2, lock = true, owner = nil, entry = vector3(310.81, -218.07, 54.22), outZ = 54.22, heading = 345.83, upperfloor = false },
	{ motelid = 1, roomno = 3, lock = true, owner = nil, entry = vector3(307.26, -216.68, 54.22), outZ = 54.22, heading = 333.74, upperfloor = false },
	{ motelid = 1, roomno = 4, lock = true, owner = nil, entry = vector3(307.47, -213.26, 54.22), outZ = 54.22, heading = 251.15, upperfloor = false },
	{ motelid = 1, roomno = '5a', lock = true, owner = nil, entry = vector3(309.57, -207.96, 54.22), outZ = 54.22, heading = 251.02, upperfloor = false },
	{ motelid = 1, roomno = '5b', lock = true, owner = nil, entry = vector3(311.24, -203.41, 54.22), outZ = 54.22, heading = 76.46, upperfloor = false },
	{ motelid = 1, roomno = 6, lock = true, owner = nil, entry = vector3(313.31, -198.2, 54.22), outZ = 54.22, heading = 244.91, upperfloor = false },
	{ motelid = 1, roomno = 7, lock = true, owner = nil, entry = vector3(315.79, -194.85, 54.23), outZ = 54.23, heading = 171.34, upperfloor = false },
	{ motelid = 1, roomno = 8, lock = true, owner = nil, entry = vector3(319.37, -196.28, 54.23), outZ = 54.23, heading = 158.02, upperfloor = false },
	{ motelid = 1, roomno = 9, lock = true, owner = nil, entry = vector3(321.35, -197.02, 54.23), outZ = 54.23, heading = 155.05, upperfloor = false },
	{ motelid = 1, roomno = 11, lock = true, owner = nil, entry = vector3(312.85, -218.86, 58.02), outZ = 58.02, heading = 338.37, upperfloor = true },
	{ motelid = 1, roomno = 12, lock = true, owner = nil, entry = vector3(310.83, -218.09, 58.02), outZ = 58.02, heading = 338.19, upperfloor = true },
	{ motelid = 1, roomno = 13, lock = true, owner = nil, entry = vector3(307.31, -216.67, 58.02), outZ = 58.02, heading = 336.53, upperfloor = true },
	{ motelid = 1, roomno = 14, lock = true, owner = nil, entry = vector3(307.5, -213.32, 58.02), outZ = 58.02, heading = 247.63, upperfloor = true },
	{ motelid = 1, roomno = 15, lock = true, owner = nil, entry = vector3(309.53, -208.04, 58.02), outZ = 58.02, heading = 252.21, upperfloor = true },
	{ motelid = 1, roomno = 16, lock = true, owner = nil, entry = vector3(311.25, -203.42, 58.02), outZ = 58.02, heading = 247.83, upperfloor = true },
	{ motelid = 1, roomno = 17, lock = true, owner = nil, entry = vector3(313.28, -198.11, 58.02), outZ = 58.02, heading = 246.54, upperfloor = true },
	{ motelid = 1, roomno = 18, lock = true, owner = nil, entry = vector3(315.77, -194.74, 58.02), outZ = 58.02, heading = 158.77, upperfloor = true },
	{ motelid = 1, roomno = 19, lock = true, owner = nil, entry = vector3(319.38, -196.14, 58.02), outZ = 58.02, heading = 168.84, upperfloor = true },
	{ motelid = 1, roomno = 20, lock = true, owner = nil, entry = vector3(321.36, -196.93, 58.02), outZ = 58.02, heading = 343.89, upperfloor = true },
	{ motelid = 1, roomno = 21, lock = true, owner = nil, entry = vector3(329.38, -225.24, 54.22), outZ = 54.22, heading = 335.13, upperfloor = false },
	{ motelid = 1, roomno = 22, lock = true, owner = nil, entry = vector3(331.34, -225.96, 54.22), outZ = 54.22, heading = 162.75, upperfloor = false },
	{ motelid = 1, roomno = 23, lock = true, owner = nil, entry = vector3(334.98, -227.32, 54.22), outZ = 54.22, heading = 335.69, upperfloor = false },
	{ motelid = 1, roomno = 24, lock = true, owner = nil, entry = vector3(337.15, -224.82, 54.22), outZ = 54.22, heading = 248.43, upperfloor = false },
	{ motelid = 1, roomno = 25, lock = true, owner = nil, entry = vector3(339.14, -219.46, 54.22), outZ = 54.22, heading = 73.07, upperfloor = false },
	{ motelid = 1, roomno = 26, lock = true, owner = nil, entry = vector3(340.88, -214.92, 54.22), outZ = 54.22, heading = 70.45, upperfloor = false },
	{ motelid = 1, roomno = 27, lock = true, owner = nil, entry = vector3(343.0, -209.55, 54.22), outZ = 54.22, heading = 62.04, upperfloor = false },
	{ motelid = 1, roomno = 28, lock = true, owner = nil, entry = vector3(344.77, -205.0, 54.22), outZ = 54.22, heading = 243.72, upperfloor = false },
	{ motelid = 1, roomno = 29, lock = true, owner = nil, entry = vector3(346.79, -199.76, 54.22), outZ = 54.22, heading = 258.18, upperfloor = false },
	{ motelid = 1, roomno = 30, lock = true, owner = nil, entry = vector3(329.38, -225.19, 58.02), outZ = 58.02, heading = 347.42, upperfloor = true },
	{ motelid = 1, roomno = 31, lock = true, owner = nil, entry = vector3(331.43, -225.96, 58.02), outZ = 58.02, heading = 154.27, upperfloor = true },
	{ motelid = 1, roomno = 32, lock = true, owner = nil, entry = vector3(335.03, -227.25, 58.02), outZ = 58.02, heading = 159.38, upperfloor = true },
	{ motelid = 1, roomno = 33, lock = true, owner = nil, entry = vector3(337.16, -224.79, 58.02), outZ = 58.02, heading = 69.11, upperfloor = true },
	{ motelid = 1, roomno = 34, lock = true, owner = nil, entry = vector3(339.16, -219.47, 58.02), outZ = 58.02, heading = 67.49, upperfloor = true },
	{ motelid = 1, roomno = 35, lock = true, owner = nil, entry = vector3(340.97, -214.97, 58.02), outZ = 58.02, heading = 76.25, upperfloor = true },
	{ motelid = 1, roomno = 36, lock = true, owner = nil, entry = vector3(342.88, -209.61, 58.02), outZ = 58.02, heading = 69.15, upperfloor = true },
	{ motelid = 1, roomno = 37, lock = true, owner = nil, entry = vector3(344.68, -205.0, 58.02), outZ = 58.02, heading = 69.12, upperfloor = true },
	{ motelid = 1, roomno = 39, lock = true, owner = nil, entry = vector3(346.81, -199.73, 58.02), outZ = 58.02, heading = 68.25, upperfloor = true },

	-- Perrera Beach Motel
	{ motelid = 2, roomno = 1, lock = true, owner = nil, entry = vector3(-1493.66, -668.32, 29.03), outZ = 29.03, heading = 145.36, upperfloor = false },
	{ motelid = 2, roomno = 2, lock = true, owner = nil, entry = vector3(-1498.15, -664.73, 29.03), outZ = 29.03, heading = 137.62, upperfloor = false },
	{ motelid = 2, roomno = 3, lock = true, owner = nil, entry = vector3(-1495.38, -661.63, 29.03), outZ = 29.03, heading = 31.39, upperfloor = false },
	{ motelid = 2, roomno = 4, lock = true, owner = nil, entry = vector3(-1490.76, -658.25, 29.03), outZ = 29.03, heading = 39.95, upperfloor = false },
	{ motelid = 2, roomno = 5, lock = true, owner = nil, entry = vector3(-1486.81, -655.4, 29.58), outZ = 29.58, heading = 215.67, upperfloor = false },
	{ motelid = 2, roomno = 6, lock = true, owner = nil, entry = vector3(-1482.17, -652.0, 29.58), outZ = 29.58, heading = 212.03, upperfloor = false },
	{ motelid = 2, roomno = 7, lock = true, owner = nil, entry = vector3(-1478.2, -649.13, 29.58), outZ = 29.58, heading = 214.74, upperfloor = false },
	{ motelid = 2, roomno = 8, lock = true, owner = nil, entry = vector3(-1473.63, -645.79, 29.58), outZ = 29.58, heading = 214.07, upperfloor = false },
	{ motelid = 2, roomno = 9, lock = true, owner = nil, entry = vector3(-1469.66, -642.96, 29.58), outZ = 29.58, heading = 216.91, upperfloor = false },
	{ motelid = 2, roomno = 10, lock = true, owner = nil, entry = vector3(-1465.03, -639.56, 29.58), outZ = 29.58, heading = 210.24, upperfloor = false },
	{ motelid = 2, roomno = 11, lock = true, owner = nil, entry = vector3(-1461.2, -640.9, 29.58), outZ = 29.58, heading = 218.15, upperfloor = false },
	{ motelid = 2, roomno = 12, lock = true, owner = nil, entry = vector3(-1452.34, -653.26, 29.58), outZ = 29.58, heading = 315.68, upperfloor = false },
	{ motelid = 2, roomno = 13, lock = true, owner = nil, entry = vector3(-1454.35, -655.95, 29.58), outZ = 29.58, heading = 124.09, upperfloor = false },
	{ motelid = 2, roomno = 14, lock = true, owner = nil, entry = vector3(-1458.96, -659.32, 29.58), outZ = 29.58, heading = 212.48, upperfloor = false },
	{ motelid = 2, roomno = 15, lock = true, owner = nil, entry = vector3(-1462.91, -662.19, 29.58), outZ = 29.58, heading = 215.87, upperfloor = false },
	{ motelid = 2, roomno = 16, lock = true, owner = nil, entry = vector3(-1467.54, -665.51, 29.58), outZ = 29.58, heading = 30.8, upperfloor = false },
	{ motelid = 2, roomno = 17, lock = true, owner = nil, entry = vector3(-1471.49, -668.41, 29.58), outZ = 29.58, heading = 33.57, upperfloor = false },
	{ motelid = 2, roomno = 18, lock = true, owner = nil, entry = vector3(-1461.25, -640.85, 33.38), outZ = 33.38, heading = 124.23, upperfloor = true },
	{ motelid = 2, roomno = 19, lock = true, owner = nil, entry = vector3(-1457.91, -645.53, 33.38), outZ = 33.38, heading = 119.43, upperfloor = true },
	{ motelid = 2, roomno = 20, lock = true, owner = nil, entry = vector3(-1455.65, -648.56, 33.38), outZ = 33.38, heading = 129.4, upperfloor = true },
	{ motelid = 2, roomno = 21, lock = true, owner = nil, entry = vector3(-1452.34, -653.21, 33.38), outZ = 33.38, heading = 135.49, upperfloor = true },
	{ motelid = 2, roomno = 22, lock = true, owner = nil, entry = vector3(-1454.36, -655.97, 33.38), outZ = 33.38, heading = 222.92, upperfloor = true },
	{ motelid = 2, roomno = 23, lock = true, owner = nil, entry = vector3(-1458.97, -659.33, 33.38), outZ = 33.38, heading = 33.75, upperfloor = true },
	{ motelid = 2, roomno = 24, lock = true, owner = nil, entry = vector3(-1463.0, -662.15, 33.38), outZ = 33.38, heading = 32.62, upperfloor = true },
	{ motelid = 2, roomno = 25, lock = true, owner = nil, entry = vector3(-1467.53, -665.55, 33.38), outZ = 33.38, heading = 39.16, upperfloor = true },
	{ motelid = 2, roomno = 26, lock = true, owner = nil, entry = vector3(-1471.49, -668.42, 33.38), outZ = 33.38, heading = 36.77, upperfloor = true },
	{ motelid = 2, roomno = 27, lock = true, owner = nil, entry = vector3(-1476.06, -671.73, 33.38), outZ = 33.38, heading = 29.33, upperfloor = true },
	{ motelid = 2, roomno = 28, lock = true, owner = nil, entry = vector3(-1465.06, -639.59, 33.38), outZ = 33.38, heading = 219.85, upperfloor = true },
	{ motelid = 2, roomno = 29, lock = true, owner = nil, entry = vector3(-1469.65, -642.94, 33.38), outZ = 33.38, heading = 213.01, upperfloor = true },
	{ motelid = 2, roomno = 30, lock = true, owner = nil, entry = vector3(-1473.62, -645.82, 33.38), outZ = 33.38, heading = 229.07, upperfloor = true },
	{ motelid = 2, roomno = 31, lock = true, owner = nil, entry = vector3(-1478.21, -649.12, 33.38), outZ = 33.38, heading = 216.66, upperfloor = true },
	{ motelid = 2, roomno = 32, lock = true, owner = nil, entry = vector3(-1482.15, -652.01, 33.38), outZ = 33.38, heading = 213.8, upperfloor = true },
	{ motelid = 2, roomno = 33, lock = true, owner = nil, entry = vector3(-1486.81, -655.38, 33.38), outZ = 33.38, heading = 217.72, upperfloor = true },
	{ motelid = 2, roomno = 34, lock = true, owner = nil, entry = vector3(-1490.74, -658.26, 33.38), outZ = 33.38, heading = 220.04, upperfloor = true },
	{ motelid = 2, roomno = 35, lock = true, owner = nil, entry = vector3(-1495.37, -661.58, 33.38), outZ = 33.38, heading = 216.85, upperfloor = true },
	{ motelid = 2, roomno = 36, lock = true, owner = nil, entry = vector3(-1498.08, -664.67, 33.38), outZ = 33.38, heading = 321.85, upperfloor = true },
	{ motelid = 2, roomno = 37, lock = true, owner = nil, entry = vector3(-1493.73, -668.3, 33.38), outZ = 33.38, heading = 312.82, upperfloor = true },
	{ motelid = 2, roomno = 38, lock = true, owner = nil, entry = vector3(-1489.91, -671.34, 33.38), outZ = 33.38, heading = 315.93, upperfloor = true },

	-- Bilingsgate Motel
	{ motelid = 3, roomno = 1, lock = true, owner = nil, entry = vector3(566.2, -1778.22, 29.35), outZ = 29.35, heading = 337.54, upperfloor = false },
	{ motelid = 3, roomno = 2, lock = true, owner = nil, entry = vector3(550.32, -1775.49, 29.89), outZ = 29.89, heading = 246.13, upperfloor = false },
	{ motelid = 3, roomno = 3, lock = true, owner = nil, entry = vector3(552.2, -1771.52, 29.31), outZ = 29.31, heading = 238.11, upperfloor = false },
	{ motelid = 3, roomno = 4, lock = true, owner = nil, entry = vector3(554.61, -1766.3, 29.31), outZ = 29.31, heading = 244.04, upperfloor = false },
	{ motelid = 3, roomno = 5, lock = true, owner = nil, entry = vector3(557.81, -1759.65, 29.31), outZ = 29.31, heading = 244.06, upperfloor = false },
	{ motelid = 3, roomno = 6, lock = true, owner = nil, entry = vector3(561.37, -1751.8, 29.28), outZ = 29.28, heading = 245.09, upperfloor = false },
	{ motelid = 3, roomno = 7, lock = true, owner = nil, entry = vector3(560.17, -1777.12, 33.44), outZ = 33.44, heading = 67.12, upperfloor = true },
	{ motelid = 3, roomno = 8, lock = true, owner = nil, entry = vector3(559.11, -1777.37, 33.44), outZ = 33.44, heading = 329.39, upperfloor = true },
	{ motelid = 3, roomno = 10, lock = true, owner = nil, entry = vector3(550.17, -1770.52, 33.44), outZ = 33.44, heading = 236.99, upperfloor = true },
	{ motelid = 3, roomno = 11, lock = true, owner = nil, entry = vector3(552.54, -1765.27, 33.44), outZ = 33.44, heading = 239.03, upperfloor = true },
	{ motelid = 3, roomno = 12, lock = true, owner = nil, entry = vector3(555.6, -1758.65, 33.44), outZ = 33.44, heading = 245.97, upperfloor = true },
	{ motelid = 3, roomno = 14, lock = true, owner = nil, entry = vector3(559.32, -1750.81, 33.44), outZ = 33.44, heading = 244.8, upperfloor = true },
	{ motelid = 3, roomno = 15, lock = true, owner = nil, entry = vector3(561.79, -1747.31, 33.44), outZ = 33.44, heading = 154.99, upperfloor = true },

	-- Crown Jewels Motel
	{ motelid = 4, roomno = 1, lock = true, owner = nil, entry = vector3(-1339.2, -941.4, 12.35), outZ = 12.35, heading = 101.41, upperfloor = false },
	{ motelid = 4, roomno = 2, lock = true, owner = nil, entry = vector3(-1338.3, -941.45, 12.35), outZ = 12.35, heading = 16.43, upperfloor = false },
	{ motelid = 4, roomno = 3, lock = true, owner = nil, entry = vector3(-1331.24, -939.33, 12.36), outZ = 12.36, heading = 199.42, upperfloor = false },
	{ motelid = 4, roomno = 4, lock = true, owner = nil, entry = vector3(-1329.37, -938.63, 12.36), outZ = 12.36, heading = 203.38, upperfloor = false },
	{ motelid = 4, roomno = 5, lock = true, owner = nil, entry = vector3(-1309.0, -931.23, 13.36), outZ = 13.36, heading = 192.03, upperfloor = false },
	{ motelid = 4, roomno = 6, lock = true, owner = nil, entry = vector3(-1310.91, -931.95, 13.36), outZ = 13.36, heading = 200.61, upperfloor = false },
	{ motelid = 4, roomno = 7, lock = true, owner = nil, entry = vector3(-1318.01, -934.53, 13.36), outZ = 13.36, heading = 199.41, upperfloor = false },
	{ motelid = 4, roomno = 8, lock = true, owner = nil, entry = vector3(-1319.81, -935.18, 13.36), outZ = 13.36, heading = 198.88, upperfloor = false },
	{ motelid = 4, roomno = 9, lock = true, owner = nil, entry = vector3(-1339.16, -941.41, 15.36), outZ = 15.36, heading = 289.13, upperfloor = true },
	{ motelid = 4, roomno = 10, lock = true, owner = nil, entry = vector3(-1338.25, -941.88, 15.36), outZ = 15.36, heading = 190.56, upperfloor = true },
	{ motelid = 4, roomno = 11, lock = true, owner = nil, entry = vector3(-1331.19, -939.3, 15.36), outZ = 15.36, heading = 194.77, upperfloor = true },
	{ motelid = 4, roomno = 12, lock = true, owner = nil, entry = vector3(-1329.41, -938.58, 15.36), outZ = 15.36, heading = 201.68, upperfloor = true },
	{ motelid = 4, roomno = 13, lock = true, owner = nil, entry = vector3(-1319.78, -935.12, 16.36), outZ = 16.36, heading = 195.97, upperfloor = true },
	{ motelid = 4, roomno = 14, lock = true, owner = nil, entry = vector3(-1318.03, -934.51, 16.36), outZ = 16.36, heading = 200.19, upperfloor = true },
	{ motelid = 4, roomno = 15, lock = true, owner = nil, entry = vector3(-1310.97, -931.9, 16.36), outZ = 16.36, heading = 202.03, upperfloor = true },
	{ motelid = 4, roomno = 16, lock = true, owner = nil, entry = vector3(-1309.04, -931.26, 16.36), outZ = 16.36, heading = 205.2, upperfloor = true },
	{ motelid = 4, roomno = 17, lock = true, owner = nil, entry = vector3(-1309.0, -931.23, 13.36), outZ = 13.36, heading = 195.52, upperfloor = true },

	-- The Rancho Motel
	{ motelid = 5, roomno = 13, lock = true, owner = nil, entry = vector3(372.3, -1791.44, 29.1), outZ = 29.1, heading = 52.8, upperfloor = false },
	{ motelid = 5, roomno = 14, lock = true, owner = nil, entry = vector3(367.49, -1802.21, 29.07), outZ = 29.07, heading = 138.35, upperfloor = false },
	{ motelid = 5, roomno = '15a', lock = true, owner = nil, entry = vector3(379.24, -1811.95, 29.05), outZ = 29.05, heading = 138.1, upperfloor = false },
	{ motelid = 5, roomno = '15b', lock = true, owner = nil, entry = vector3(398.29, -1789.68, 29.17), outZ = 29.17, heading = 320.21, upperfloor = false },
	{ motelid = 5, roomno = 16, lock = true, owner = nil, entry = vector3(380.63, -1813.25, 29.05), outZ = 29.05, heading = 139.71, upperfloor = false },
	{ motelid = 5, roomno = 17, lock = true, owner = nil, entry = vector3(405.37, -1795.74, 29.01), outZ = 29.01, heading = 320.61, upperfloor = false },

	-- Von Crastenburg Motel
	{ motelid = 6, roomno = 1, lock = true, owner = nil, entry = vector3(484.2, 212.3, 104.74), outZ = 104.74, heading = 246.74, upperfloor = false },
	{ motelid = 6, roomno = 2, lock = true, owner = nil, entry = vector3(482.34, 207.18, 104.74), outZ = 104.74, heading = 243.99, upperfloor = false },
	{ motelid = 6, roomno = 3, lock = true, owner = nil, entry = vector3(486.67, 201.17, 104.74), outZ = 104.74, heading = 336.93, upperfloor = false },
	{ motelid = 6, roomno = 4, lock = true, owner = nil, entry = vector3(507.41, 193.61, 104.75), outZ = 104.75, heading = 342.35, upperfloor = false },
	{ motelid = 6, roomno = 5, lock = true, owner = nil, entry = vector3(513.81, 191.29, 104.75), outZ = 104.75, heading = 333.12, upperfloor = false },
	{ motelid = 6, roomno = 6, lock = true, owner = nil, entry = vector3(520.98, 192.95, 104.74), outZ = 104.74, heading = 65.31, upperfloor = false },
	{ motelid = 6, roomno = 7, lock = true, owner = nil, entry = vector3(522.87, 198.14, 104.74), outZ = 104.74, heading = 65.41, upperfloor = false },
	{ motelid = 6, roomno = 8, lock = true, owner = nil, entry = vector3(526.34, 207.7, 104.74), outZ = 104.74, heading = 66.18, upperfloor = false },
	{ motelid = 6, roomno = 9, lock = true, owner = nil, entry = vector3(528.67, 214.06, 104.74), outZ = 104.74, heading = 63.98, upperfloor = false },
	{ motelid = 6, roomno = 10, lock = true, owner = nil, entry = vector3(526.72, 226.56, 104.74), outZ = 104.74, heading = 157.79, upperfloor = false },
	{ motelid = 6, roomno = 11, lock = true, owner = nil, entry = vector3(520.16, 229.01, 104.74), outZ = 104.74, heading = 156.43, upperfloor = false },
	{ motelid = 6, roomno = 12, lock = true, owner = nil, entry = vector3(510.59, 232.5, 104.74), outZ = 104.74, heading = 155.57, upperfloor = false },
	{ motelid = 6, roomno = 13, lock = true, owner = nil, entry = vector3(504.2, 234.8, 104.74), outZ = 104.74, heading = 154.31, upperfloor = false },
	{ motelid = 6, roomno = 14, lock = true, owner = nil, entry = vector3(497.65, 237.19, 104.74), outZ = 104.74, heading = 156.32, upperfloor = false },
	{ motelid = 6, roomno = 15, lock = true, owner = nil, entry = vector3(489.99, 228.17, 104.74), outZ = 104.74, heading = 243.29, upperfloor = false },
	{ motelid = 6, roomno = 16, lock = true, owner = nil, entry = vector3(487.76, 221.79, 104.74), outZ = 104.74, heading = 245.92, upperfloor = false },
	{ motelid = 6, roomno = 17, lock = true, owner = nil, entry = vector3(484.29, 212.32, 108.31), outZ = 108.31, heading = 334.59, upperfloor = true },
	{ motelid = 6, roomno = 18, lock = true, owner = nil, entry = vector3(482.39, 207.08, 108.31), outZ = 108.31, heading = 241.81, upperfloor = true },
	{ motelid = 6, roomno = 19, lock = true, owner = nil, entry = vector3(486.61, 201.25, 108.31), outZ = 108.31, heading = 240.76, upperfloor = true },
	{ motelid = 6, roomno = 20, lock = true, owner = nil, entry = vector3(507.44, 193.63, 108.31), outZ = 108.31, heading = 334.96, upperfloor = true },
	{ motelid = 6, roomno = 21, lock = true, owner = nil, entry = vector3(513.8, 191.31, 108.31), outZ = 108.31, heading = 335.46, upperfloor = true },
	{ motelid = 6, roomno = 22, lock = true, owner = nil, entry = vector3(520.91, 193.0, 108.31), outZ = 108.31, heading = 63.99, upperfloor = true },
	{ motelid = 6, roomno = 23, lock = true, owner = nil, entry = vector3(522.88, 198.15, 108.31), outZ = 108.31, heading = 66.17, upperfloor = true },

	-- The Motor Motel
	{ motelid = 7, roomno = 1, lock = true, owner = nil, entry = vector3(1142.33, 2654.59, 38.15), outZ = 38.15, heading = 88.67, upperfloor = false },
	{ motelid = 7, roomno = 2, lock = true, owner = nil, entry = vector3(1142.42, 2651.09, 38.14), outZ = 38.14, heading = 96.3, upperfloor = false },
	{ motelid = 7, roomno = 3, lock = true, owner = nil, entry = vector3(1142.41, 2643.57, 38.14), outZ = 38.14, heading = 88.57, upperfloor = false },
	{ motelid = 7, roomno = 4, lock = true, owner = nil, entry = vector3(1141.11, 2641.64, 38.14), outZ = 38.14, heading = 355.87, upperfloor = false },
	{ motelid = 7, roomno = 5, lock = true, owner = nil, entry = vector3(1136.29, 2641.74, 38.14), outZ = 38.14, heading = 357.86, upperfloor = false },
	{ motelid = 7, roomno = 6, lock = true, owner = nil, entry = vector3(1132.69, 2641.68, 38.14), outZ = 38.14, heading = 358.56, upperfloor = false },
	{ motelid = 7, roomno = 7, lock = true, owner = nil, entry = vector3(1125.17, 2641.65, 38.14), outZ = 38.14, heading = 4.45, upperfloor = false },
	{ motelid = 7, roomno = 8, lock = true, owner = nil, entry = vector3(1121.33, 2641.65, 38.14), outZ = 38.14, heading = 3.3, upperfloor = false },
	{ motelid = 7, roomno = 9, lock = true, owner = nil, entry = vector3(1114.67, 2641.73, 38.14), outZ = 38.14, heading = 353.31, upperfloor = false },
	{ motelid = 7, roomno = 10, lock = true, owner = nil, entry = vector3(1107.24, 2641.74, 38.14), outZ = 38.14, heading = 5.6, upperfloor = false },
	{ motelid = 7, roomno = 11, lock = true, owner = nil, entry = vector3(1106.1, 2649.12, 38.14), outZ = 38.14, heading = 277.57, upperfloor = false },
	{ motelid = 7, roomno = 12, lock = true, owner = nil, entry = vector3(1106.11, 2652.89, 38.14), outZ = 38.14, heading = 278.68, upperfloor = false },

	-- Eastern Motel
	{ motelid = 8, roomno = 1, lock = true, owner = nil, entry = vector3(341.65, 2614.96, 44.67), outZ = 44.67, heading = 23.35, upperfloor = false },
	{ motelid = 8, roomno = 2, lock = true, owner = nil, entry = vector3(347.09, 2618.03, 44.67), outZ = 44.67, heading = 27.34, upperfloor = false },
	{ motelid = 8, roomno = 3, lock = true, owner = nil, entry = vector3(354.44, 2619.71, 44.67), outZ = 44.67, heading = 24.63, upperfloor = false },
	{ motelid = 8, roomno = 4, lock = true, owner = nil, entry = vector3(359.76, 2622.87, 44.67), outZ = 44.67, heading = 21.57, upperfloor = false },
	{ motelid = 8, roomno = 5, lock = true, owner = nil, entry = vector3(367.1, 2624.54, 44.67), outZ = 44.67, heading = 23.82, upperfloor = false },
	{ motelid = 8, roomno = 6, lock = true, owner = nil, entry = vector3(372.58, 2627.6, 44.67), outZ = 44.67, heading = 30.03, upperfloor = false },
	{ motelid = 8, roomno = 7, lock = true, owner = nil, entry = vector3(379.87, 2629.24, 44.67), outZ = 44.67, heading = 29.74, upperfloor = false },
	{ motelid = 8, roomno = 8, lock = true, owner = nil, entry = vector3(385.27, 2632.36, 44.67), outZ = 44.67, heading = 22.79, upperfloor = false },
	{ motelid = 8, roomno = 9, lock = true, owner = nil, entry = vector3(392.58, 2634.09, 44.67), outZ = 44.67, heading = 37.75, upperfloor = false },
	{ motelid = 8, roomno = 10, lock = true, owner = nil, entry = vector3(398.01, 2637.01, 44.67), outZ = 44.67, heading = 33.42, upperfloor = false },

	-- Bayview Lodge Motel
	{ motelid = 9, roomno = 1, lock = true, owner = nil, entry = vector3(-681.93, 5770.73, 17.51), outZ = 17.51, heading = 61.64, upperfloor = false },
	{ motelid = 9, roomno = 2, lock = true, owner = nil, entry = vector3(-683.74, 5766.74, 17.51), outZ = 17.51, heading = 58.03, upperfloor = false },
	{ motelid = 9, roomno = 3, lock = true, owner = nil, entry = vector3(-685.59, 5762.73, 17.51), outZ = 17.51, heading = 62.5, upperfloor = false },
	{ motelid = 9, roomno = 4, lock = true, owner = nil, entry = vector3(-687.43, 5758.96, 17.51), outZ = 17.51, heading = 60.26, upperfloor = false },
	{ motelid = 9, roomno = 5, lock = true, owner = nil, entry = vector3(-694.23, 5761.31, 17.51), outZ = 17.51, heading = 327.58, upperfloor = false },
	{ motelid = 9, roomno = 6, lock = true, owner = nil, entry = vector3(-681.93, 5770.73, 17.51), outZ = 17.51, heading = 331.36, upperfloor = false },
	{ motelid = 9, roomno = 7, lock = true, owner = nil, entry = vector3(-698.17, 5763.12, 17.51), outZ = 17.51, heading = 328.17, upperfloor = false },
	{ motelid = 9, roomno = 8, lock = true, owner = nil, entry = vector3(-702.1, 5764.96, 17.51), outZ = 17.51, heading = 335.04, upperfloor = false },
	{ motelid = 9, roomno = 9, lock = true, owner = nil, entry = vector3(-706.01, 5766.77, 17.51), outZ = 17.51, heading = 333.22, upperfloor = false },
	{ motelid = 9, roomno = 10, lock = true, owner = nil, entry = vector3(-709.94, 5768.59, 17.51), outZ = 17.51, heading = 332.44, upperfloor = false },

	-- Dream View Motel
	{ motelid = 10, roomno = 1, lock = true, owner = nil, entry = vector3(-111.11, 6322.87, 31.58), outZ = 31.58, heading = 134.49, upperfloor = false },
	{ motelid = 10, roomno = 2, lock = true, owner = nil, entry = vector3(-114.34, 6326.08, 31.58), outZ = 31.58, heading = 130.33, upperfloor = false },
	{ motelid = 10, roomno = 3, lock = true, owner = nil, entry = vector3(-120.19, 6327.31, 31.58), outZ = 31.58, heading = 223.62, upperfloor = false },
	{ motelid = 10, roomno = 4, lock = true, owner = nil, entry = vector3(-111.04, 6322.79, 35.5), outZ = 35.5, heading = 136.5, upperfloor = true },
	{ motelid = 10, roomno = 5, lock = true, owner = nil, entry = vector3(-114.3, 6326.06, 35.5), outZ = 35.5, heading = 134.59, upperfloor = true },
	{ motelid = 10, roomno = 6, lock = true, owner = nil, entry = vector3(-120.23, 6327.27, 35.5), outZ = 35.5, heading = 229.85, upperfloor = true },
	{ motelid = 10, roomno = 7, lock = true, owner = nil, entry = vector3(-103.47, 6330.71, 31.58), outZ = 31.58, heading = 314.67, upperfloor = false },
	{ motelid = 10, roomno = 8, lock = true, owner = nil, entry = vector3(-106.75, 6333.98, 31.58), outZ = 31.58, heading = 313.69, upperfloor = false },
	{ motelid = 10, roomno = 9, lock = true, owner = nil, entry = vector3(-107.59, 6339.88, 31.58), outZ = 31.58, heading = 229.77, upperfloor = false },
	{ motelid = 10, roomno = 11, lock = true, owner = nil, entry = vector3(-98.91, 6348.57, 31.58), outZ = 31.58, heading = 224.45, upperfloor = false },
	{ motelid = 10, roomno = 12, lock = true, owner = nil, entry = vector3(-93.5, 6353.99, 31.58), outZ = 31.58, heading = 225.76, upperfloor = false },
	{ motelid = 10, roomno = 13, lock = true, owner = nil, entry = vector3(-90.23, 6357.25, 31.58), outZ = 31.58, heading = 222.64, upperfloor = false },
	{ motelid = 10, roomno = 14, lock = true, owner = nil, entry = vector3(-84.85, 6362.64, 31.58), outZ = 31.58, heading = 221.99, upperfloor = false },
	{ motelid = 10, roomno = 15, lock = true, owner = nil, entry = vector3(-103.49, 6330.74, 35.5), outZ = 35.5, heading = 314.67, upperfloor = true },
	{ motelid = 10, roomno = 16, lock = true, owner = nil, entry = vector3(-106.73, 6333.99, 35.5), outZ = 35.5, heading = 313.4, upperfloor = true },
	{ motelid = 10, roomno = 17, lock = true, owner = nil, entry = vector3(-107.61, 6339.87, 35.5), outZ = 35.5, heading = 227.06, upperfloor = true },
	{ motelid = 10, roomno = 18, lock = true, owner = nil, entry = vector3(-102.21, 6345.27, 35.5), outZ = 35.5, heading = 222.78, upperfloor = true },
	{ motelid = 10, roomno = 19, lock = true, owner = nil, entry = vector3(-98.99, 6348.48, 35.5), outZ = 35.5, heading = 220.79, upperfloor = true },
	{ motelid = 10, roomno = 20, lock = true, owner = nil, entry = vector3(-93.52, 6353.94, 35.5), outZ = 35.5, heading = 221.76, upperfloor = true },
	{ motelid = 10, roomno = 21, lock = true, owner = nil, entry = vector3(-90.21, 6357.16, 35.5), outZ = 35.5, heading = 219.24, upperfloor = true },
	{ motelid = 10, roomno = 22, lock = true, owner = nil, entry = vector3(-84.89, 6362.6, 35.5), outZ = 35.5, heading = 219.4, upperfloor = true },
}

BJCore = nil
TriggerEvent('BJCore:GetObject', function(obj) BJCore = obj end)
Citizen.CreateThread(function(...) while BJCore == nil do TriggerEvent("BJCore:GetObject", function(obj) BJCore = obj end); Citizen.Wait(1000); end; end)