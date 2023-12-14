Config = {}

Config.DefaultGarage = {
    ["vehicle"] = "legion",
    ["aircraft"] =  "airportlsa",
    ["boat"] = "vespucci"
}

Config.VehicleShops = {
    ["pdm"] = {
        label = "Premium Deluxe Motorsport",
        pos = vector3(-56.71, -1096.65, 25.44),
    },
    ["handlebar"] = {
        label = "HandleBar Haven",
        pos = vector3(1705.60, 4773.11, 42.03),
    }
}

Config.JobLocations = {
    ["pdm"] = {
        stash = vector3(-26.61642, -1090.335, 26.4221),
        duty = vector3(-56.60459, -1097.712, 26.422349),
        vehicle = vector4(-57.53417, -1106.524, 26.005542, 68.34262),
    },
    ["handlebar"] = {
        stash = false, -- set to false if you don't plan on using this specific job interaction locations
        duty = false,
        vehicle = false,
    }
}

Config.ActionText = {
    ["stash"] = "Inventory",
    ["duty"] = "Duty",
    ["vehicle"] = "Garage"
}

Config.GarageList = {
    ["pdm"]= {
        ["blista"] = "Blista", -- ["spawnname"] = "Model Label"
    },
    ["handlebar"] = {
        ["blista"] = "Blista",
    }
}

Config.TestDriveSpawn = {
    ["pdm"] = vector4(-48.16, -1110.15, 26.0, 75.01),
    ["handlebar"] = vector4(1692.37, 4785.04, 41.44, 86.89)
}

Config.PurchaseVehicleSpawn = {
    ["pdm"] = vector4(-46.08938, -1081.711, 26.04928, 68.905563),
    ["handlebar"] = vector4(1693.6557, 4794.1352, 41.493442, 86.426063)
}

Config.MinEnableAuto = {                    -- min number of on duty employess that'll enable offline/automation mode (set to 9999 if you don't want to use this feature at a delearship)
    ["pdm"] = 0,
    ["handlebar"] = 1
}
Config.OfflinePriceMultiplier   = 4         -- percent multiplier added to vehicle price when purchasing a vehicle in offline/automation mode

Config.MinInterestRate          = 3         -- set minimum interest rate in % that will be added to vehicle price upon financing
Config.MaxInterestRate          = 10        -- set maximum interest rate in % that will be added to vehicle price upon financing
Config.MinDownpayment           = 10        -- set minimum allowed downpayment that car seller can go down to in %
Config.MaxDownpayment           = 90        -- set maximum allowed downpayment that car seller can go down to in %
Config.MinAmountOfRepayments    = 5         -- set minimum amount of repayments in total, where (carPrice-downPayment)/amountOfRepayments will be minimum repay amount
Config.MaxAmountOfRepayments    = 15        -- set maximum amount of repayments in total, where (carPrice-downPayment)/amountOfRepayments will be minimum repay amount

Config.PriceMarkType            = 1         -- types: 1 or 2
                                            -- 1: max mark up/down percent is set using Config.MaxPriceMarkUp/Config.MaxPriceMarkDown
                                            -- 2: max mark up/down percent is set using 'markup'/'markdown' for each individual vehicle is shared.lua
Config.MaxPriceMarkUp           = 10        -- sets maximum amount of percent that a vehicle price can be marked up (applicable if Config.PriceMarkType = 1)
Config.MaxPriceMarkDown         = 10        -- sets maximum amount of percent that a vehicle price can be marked down (applicable if Config.PriceMarkType = 1)

Config.PayDealerCommission      = true      -- pay the individual dealer that completes a sale
Config.DealerCommissionType     = 1         -- applicable if Config.PayDealerCommission is true. types: 1 or 2
                                            -- 1: pay dealer using Config.GlobalDealerCommission' percent
                                            -- 2: pay dealer using 'dealer' percent for individual vehicle in shared.lua
Config.GlobalDealerCommission   = 5         -- global percent of the vehicle price value paid directly to dealer when a sale is completed (applicable if Config.DealerCommissionType = 1)
Config.AllowDealerEarnOwnCom    = false     -- enables/disables if a salesperson can earn dealer commission if they sell a vehicle to themselves
Config.AllowDealerSellOwn       = true      -- enables/disables if a salesperson can sell a vehicle to themselves at all

Config.PayDealershipCommission  = true     -- enable or disable dealership commission payment
Config.DearlershipCommissionType = 1        -- types: 1 or 2
                                            -- 1: pays dealership job moneysafe using Config.GlobalDealershipCommission perfect value
                                            -- 2: pays dealership job moneysafe using 'dealership' percent value for each individual vehicle is shared.lua
                                            -- note: if Config.PayDealerCommission is true then both Dealer and Dealership commission total percentage cannot exceed 100%
Config.GlobalDealershipCommission = 20      -- global percent of vehicle price value paid to dealership job moneysafe (applicable if Config.DearlershipCommissionType = 1)

Config.ShowroomVehicles = {
    ["pdm"] = {
        [1] = {
            coords = vector4(-45.65, -1093.66, 25.44, 69.5),
            defaultVehicle = "cavalcade2",
            chosenVehicle = "cavalcade2",
            inUse = false,
        },
        [2] = {
            coords = vector4(-48.27, -1101.86, 25.44, 294.5),
            defaultVehicle = "tailgater",
            chosenVehicle = "tailgater",
            inUse = false,
        },
        [3] = {
            coords = vector4(-39.6, -1096.01, 25.44, 66.5),
            defaultVehicle = "revolter",
            chosenVehicle = "revolter",
            inUse = false,
        },
        [4] = {
            coords = vector4(-51.21, -1096.77, 25.44, 254.5),
            defaultVehicle = "vigero",
            chosenVehicle = "vigero",
            inUse = false,
        },
        [5] = {
            coords = vector4(-40.18, -1104.13, 25.44, 338.5),
            defaultVehicle = "felon",
            chosenVehicle = "felon",
            inUse = false,
        },
        [6] = {
            coords = vector4(-43.31, -1099.02, 25.44, 52.5),
            defaultVehicle = "washington",
            chosenVehicle = "washington",
            inUse = false,
        },
        [7] = {
            coords = vector4(-50.66, -1093.05, 25.44, 222.5),
            defaultVehicle = "feltzer3",
            chosenVehicle = "feltzer3",
            inUse = false,
        },
        [8] = {
            coords = vector4(-44.28, -1102.47, 25.44, 298.5),
            defaultVehicle = "exemplar",
            chosenVehicle = "exemplar",
            inUse = false,
        }
    },
    ["handlebar"] = {
        [1] = {
            coords = vector4(1698.01, 4763.01, 41.55, 330.40),
            defaultVehicle = "akuma",
            chosenVehicle = "akuma",
            inUse = false,
        },
        [2] = {
            coords = vector4(1700.27, 4762.67, 41.52, 334.13),
            defaultVehicle = "vader",
            chosenVehicle = "vader",
            inUse = false,
        },
        [3] = {
            coords = vector4(1702.82, 4762.46, 41.50, 337.00),
            defaultVehicle = "vindicator",
            chosenVehicle = "vindicator",
            inUse = false,
        },
        [4] = {
            coords = vector4(1705.84, 4762.48, 41.50, 326.69),
            defaultVehicle = "vortex",
            chosenVehicle = "vortex",
            inUse = false,
        },
        [5] = {
            coords = vector4(1708.69, 4762.18, 41.50, 331.42),
            defaultVehicle = "wolfsbane",
            chosenVehicle = "wolfsbane",
            inUse = false,
        },
        [6] = {
            coords = vector4(1698.36, 4768.63, 41.49, 209.23),
            defaultVehicle = "akuma",
            chosenVehicle = "akuma",
            inUse = false,
        },
        [7] = {
            coords = vector4(1701.61, 4769.64, 41.49, 207.74),
            defaultVehicle = "vader",
            chosenVehicle = "vader",
            inUse = false,
        },
        [8] = {
            coords = vector4(1704.99, 4770.18, 41.50, 198.12),
            defaultVehicle = "vindicator",
            chosenVehicle = "vindicator",
            inUse = false,
        },
        [9] = {
            coords = vector4(1708.18, 4770.88, 41.50, 197.65),
            defaultVehicle = "vortex",
            chosenVehicle = "vortex",
            inUse = false,
        },
        [10] = {
            coords = vector4(1697.99, 4781.49, 41.56, 319.57),
            defaultVehicle = "wolfsbane",
            chosenVehicle = "wolfsbane",
            inUse = false,
        }, 
        [11] = {
            coords = vector4(1700.01, 4780.39, 41.37, 315.07),
            defaultVehicle = "akuma",
            chosenVehicle = "akuma",
            inUse = false,
        },
        [12] = {
            coords = vector4(1702.29, 4779.50, 41.53, 318.74),
            defaultVehicle = "vader",
            chosenVehicle = "vader",
            inUse = false,
        },
        [13] = {
            coords = vector4(1705.91, 4779.36, 41.54, 36.50),
            defaultVehicle = "vindicator",
            chosenVehicle = "vindicator",
            inUse = false,
        },
        [14] = {
            coords = vector4(1708.43, 4779.74, 41.51, 26.65),
            defaultVehicle = "vortex",
            chosenVehicle = "vortex",
            inUse = false,
        },
        [15] = {
            coords = vector4(1710.51, 4780.46, 41.44, 33.77),
            defaultVehicle = "wolfsbane",
            chosenVehicle = "wolfsbane",
            inUse = false,
        },
        [16] = {
            coords = vector4(1698.25, 4787.73, 41.37, 214.93),
            defaultVehicle = "akuma",
            chosenVehicle = "akuma",
            inUse = false,
        },
        [17] = {
            coords = vector4(1700.21, 4788.27, 41.51, 201.86),
            defaultVehicle = "vader",
            chosenVehicle = "vader",
            inUse = false,
        },
        [18] = {
            coords = vector4(1702.34, 4788.50, 41.54, 205.67),
            defaultVehicle = "vindicator",
            chosenVehicle = "vindicator",
            inUse = false,
        },
        [19] = {
            coords = vector4(1706.11, 4788.54, 41.54, 145.71),
            defaultVehicle = "vortex",
            chosenVehicle = "vortex",
            inUse = false,
        },
        [20] = {
            coords = vector4(1708.85, 4788.45, 41.54, 143.60),
            defaultVehicle = "wolfsbane",
            chosenVehicle = "wolfsbane",
            inUse = false,
        },
        [21] = {
            coords = vector4(1711.01, 4787.85, 41.37, 146.51),
            defaultVehicle = "wolfsbane",
            chosenVehicle = "wolfsbane",
            inUse = false,
        },
    }
}

Config.SalePoints = {
    ["pdm"] = {
        [1] = {
            pos = vector3(-33.13, -1114.31, 26.42),
            isUse = false,
            enabled = false,
            data = {}
        },
        [2] = {
            pos = vector3(-30.47436, -1105.919, 26.422349),
            isUse = false,
            enabled = false,
            data = {}
        }
    },
    ["handlebar"] = {
        [1] = {
            pos = vector3(1716.08, 4787.43, 42.12),  
            isUse = false,
            enabled = false,
            data = {}
        }
    }
}

function splitIndex(string, sep)
    local ret = {}
    for str in string.gmatch(string, "([^"..sep.."]+)") do
        table.insert(ret, str)
    end
    return ret
end

BJCore = nil
TriggerEvent('BJCore:GetObject', function(obj) BJCore = obj end)
Citizen.CreateThread(function(...) while BJCore == nil do TriggerEvent("BJCore:GetObject", function(obj) BJCore = obj end); Citizen.Wait(1000); end; end)