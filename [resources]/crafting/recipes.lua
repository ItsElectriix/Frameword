Recipes = {
    ["blankcard"] = {
        type = "reg",
        slotRecipe = {
            {"plastic",  "plastic",  "plastic"},
            {false,      "iron",  false},
        },
        itemsToKeep = { },
        metadataToCopy = { },
        rewards = {
            ["blankcard"] = 1
        },
        craftTime = 8.0
    },
    ["blanknfccard"] = {
        type = "reg",
        slotRecipe = {
            {"blankcard"},
            {"goldnugget"}
        },
        itemsToKeep = { },
        metadataToCopy = { },
        rewards = {
            ["blanknfccard"] = 1
        },
        craftTime = 10.0
    },
    ["bankcard"] = {
        type = "reg",
        requires = {
            {
                type = "rep",
                repType = "hackerrep",
                minimum = 80,
            }
        },
        slotRecipe = {
            {"laptop", "electronickit"},
            {false, "blackusb"},
            {false,  "blanknfccard"},
        },
        itemsToKeep = { 
          ["laptop"] = true, 
          ["electronickit"] = true
        },
        metadataToCopy = {
            ["bank"] = true,
            ["expires"] = true
        },
        rewards = {
            ["bankcard"] = 1,
            ["rep"] = {
                ["craftingrep"] = 10,
                ["hackerrep"] = 10,
            }
        },
        craftTime = 15.0
    },
	["trojan_usb"] = {
		type = "reg",
        slotRecipe = {
            {false,"electronickit"},
            {false,false},
            {"electronickit","blueusb"}
        },
        itemsToKeep = { },
        metadataToCopy = { },
        rewards = {
            ["trojan_usb"] = 1
        },
        craftTime = 2.0--15.0
	},
	["advancedlockpick"] = {
		type = "reg",
        slotRecipe = {
            {"lockpick"},
            {"screwdriverset"},
        },
        itemsToKeep = { },
        metadataToCopy = { },
        rewards = {
            ["advancedlockpick"] = 1
        },
        craftTime = 3.0
	},
    ["joint_ww"] = {
        type = "reg",
        slotRecipe = {
            {"rolling_paper"},
            {"weed_white-widow"},
        },
        itemsToKeep = { },
        metadataToCopy = { },
        rewards = {
            ["joint"] = 2
        },
        craftTime = 10.0
    },
    ["joint_sk"] = {
        type = "reg",
        slotRecipe = {
            {"rolling_paper"},
            {"weed_skunk"},
        },
        itemsToKeep = { },
        metadataToCopy = { },
        rewards = {
            ["joint"] = 2
        },
        craftTime = 10.0
    },
    ["joint_ph"] = {
        type = "reg",
        slotRecipe = {
            {"rolling_paper"},
            {"weed_purple-haze"},
        },
        itemsToKeep = { },
        metadataToCopy = { },
        rewards = {
            ["joint"] = 2
        },
        craftTime = 10.0
    },
    ["joint_og"] = {
        type = "reg",
        slotRecipe = {
            {"rolling_paper"},
            {"weed_og-kush"},
        },
        itemsToKeep = { },
        metadataToCopy = { },
        rewards = {
            ["joint"] = 2
        },
        craftTime = 10.0
    },
    ["joint_am"] = {
        type = "reg",
        slotRecipe = {
            {"rolling_paper"},
            {"weed_amnesia"},
        },
        itemsToKeep = { },
        metadataToCopy = { },
        rewards = {
            ["joint"] = 2
        },
        craftTime = 10.0
    },
    ["weed_ak47"] = {
        type = "reg",
        slotRecipe = {
            {"rolling_paper"},
            {"weed_ak47"},
        },
        itemsToKeep = { },
        metadataToCopy = { },
        rewards = {
            ["joint"] = 2
        },
        craftTime = 10.0
    },
    ["joint_ww_bag"] = {
        type = "reg",
        slotRecipe = {
            {"rolling_paper"},
            {"weed_white-widow_bag"},
        },
        itemsToKeep = { },
        metadataToCopy = { },
        rewards = {
            ["joint"] = 2
        },
        craftTime = 10.0
    },
    ["joint_sk_bag"] = {
        type = "reg",
        slotRecipe = {
            {"rolling_paper"},
            {"weed_skunk_bag"},
        },
        itemsToKeep = { },
        metadataToCopy = { },
        rewards = {
            ["joint"] = 2
        },
        craftTime = 10.0
    },
    ["joint_ph_bag"] = {
        type = "reg",
        slotRecipe = {
            {"rolling_paper"},
            {"weed_purple-haze_bag"},
        },
        itemsToKeep = { },
        metadataToCopy = { },
        rewards = {
            ["joint"] = 2
        },
        craftTime = 10.0
    },
    ["joint_ogk_bag"] = {
        type = "reg",
        slotRecipe = {
            {"rolling_paper"},
            {"weed_og-kush_bag"},
        },
        itemsToKeep = { },
        metadataToCopy = { },
        rewards = {
            ["joint"] = 2
        },
        craftTime = 10.0
    },
    ["joint_amn_bag"] = {
        type = "reg",
        slotRecipe = {
            {"rolling_paper"},
            {"weed_amnesia_bag"},
        },
        itemsToKeep = { },
        metadataToCopy = { },
        rewards = {
            ["joint"] = 2
        },
        craftTime = 10.0
    },
    ["joint_ak47_bag"] = {
        type = "reg",
        slotRecipe = {
            {"rolling_paper"},
            {"weed_ak47_bag"},
        },
        itemsToKeep = { },
        metadataToCopy = { },
        rewards = {
            ["joint"] = 2
        },
        craftTime = 10.0
    },
    ["white-widow_bag"] = {
        type = "reg",
        slotRecipe = {
            {"empty_weed_bag"},
            {"weed_white-widow"},
        },
        itemsToKeep = { },
        metadataToCopy = { },
        rewards = {
            ["weed_white-widow_bag"] = 1
        },
        craftTime = 5.0
    },
    ["skunk_bag"] = {
        type = "reg",
        slotRecipe = {
            {"empty_weed_bag"},
            {"weed_skunk"},
        },
        itemsToKeep = { },
        metadataToCopy = { },
        rewards = {
            ["weed_skunk_bag"] = 1
        },
        craftTime = 5.0
    },
    ["purple-haze_bag"] = {
        type = "reg",
        slotRecipe = {
            {"empty_weed_bag"},
            {"weed_purple-haze"},
        },
        itemsToKeep = { },
        metadataToCopy = { },
        rewards = {
            ["weed_purple-haze_bag"] = 1
        },
        craftTime = 5.0
    },
    ["og-kush_bag"] = {
        type = "reg",
        slotRecipe = {
            {"empty_weed_bag"},
            {"weed_og-kush"},
        },
        itemsToKeep = { },
        metadataToCopy = { },
        rewards = {
            ["weed_og-kush_bag"] = 1
        },
        craftTime = 5.0
    },
    ["amnesia_bag"] = {
        type = "reg",
        slotRecipe = {
            {"empty_weed_bag"},
            {"weed_amnesia"},
        },
        itemsToKeep = { },
        metadataToCopy = { },
        rewards = {
            ["weed_amnesia_bag"] = 1
        },
        craftTime = 5.0
    },
    ["ak47_bag"] = {
        type = "reg",
        slotRecipe = {
            {"empty_weed_bag"},
            {"weed_ak47"},
        },
        itemsToKeep = { },
        metadataToCopy = { },
        rewards = {
            ["weed_ak47_bag"] = 1
        },
        craftTime = 5.0
    },
    ["sandwich"] = {
        type = "cooking",
        slotRecipe = {
            {"bread"},
        },
        itemsToKeep = { },
        metadataToCopy = { },
        newMetadata = {
            ["sandwich"] = {
                ["cooked"] = false
            }
        },
        rewards = {
            ["sandwich"] = 1
        },
        craftTime = 5.0
    },
}
