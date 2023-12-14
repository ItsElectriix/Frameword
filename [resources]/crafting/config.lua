Crafting = {}
local MFC = Crafting

-- Self explanatory
MFC.DrawTextDist = 2.0
MFC.InteractDist = 1.5

MFC.LoadTableDist = 30.0
MFC.CraftText = {
    ["reg"] = "[~g~E~s~] Crafting",
    --["adv"] = "[~g~E~s~] Advanced Crafting",
    ["wep"] = "[~r~E~s~] Weapon Crafting",
}
MFC.BenchModel = {
    ["reg"] = 'prop_tool_bench02_ld',
    --["adv"] = 'gr_prop_gr_bench_04a',
    ["wep"] = 'gr_prop_gr_bench_02b',
}

MFC.CraftingLocations = {
    {
        pos = vector4(-1257.814, -282.5865, 37.479027, 116.1),
        type = "cooking",
        label = "Cooking"
    }
}

BJCore = nil
TriggerEvent('BJCore:GetObject', function(obj) BJCore = obj end)
Citizen.CreateThread(function(...) while BJCore == nil do TriggerEvent("BJCore:GetObject", function(obj) BJCore = obj end); Citizen.Wait(1000); end; end)