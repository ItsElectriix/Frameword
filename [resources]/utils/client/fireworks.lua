local fireworkTime = 0
local fireworkLoc = nil
local FireworkList = {
    ["proj_xmas_firework"] = {
        "scr_firework_xmas_ring_burst_rgw",
        "scr_firework_xmas_burst_rgw",
        "scr_firework_xmas_repeat_burst_rgw",
        "scr_firework_xmas_spiral_burst_rgw",
        "scr_xmas_firework_sparkle_spawn",
    },
    ["scr_indep_fireworks"] = {
        "scr_indep_firework_sparkle_spawn",
        "scr_indep_firework_starburst",
        "scr_indep_firework_shotburst",
        "scr_indep_firework_trailburst",
        "scr_indep_firework_trailburst_spawn",
        "scr_indep_firework_burst_spawn",
        "scr_indep_firework_trail_spawn",
        "scr_indep_firework_fountain",
    },
    ["proj_indep_firework"] = {
        "scr_indep_firework_grd_burst",
        "scr_indep_launcher_sparkle_spawn",
        "scr_indep_firework_air_burst",
        "proj_indep_flare_trail",
    },
    ["proj_indep_firework_v2"] = {
        "scr_firework_indep_burst_rwb",
        "scr_firework_indep_spiral_burst_rwb",
        "scr_xmas_firework_sparkle_spawn",
        "scr_firework_indep_ring_burst_rwb",
        "scr_xmas_firework_burst_fizzle",
        "scr_firework_indep_repeat_burst_rwb",
    },
}

Citizen.CreateThread(function()
    local asset = "scr_indep_fireworks"
    if not HasNamedPtfxAssetLoaded(asset) then
        RequestNamedPtfxAsset(asset)
        while not HasNamedPtfxAssetLoaded(asset) do
            Citizen.Wait(1)
        end
    end
    local asset2 = "proj_xmas_firework"
    if not HasNamedPtfxAssetLoaded(asset2) then
        RequestNamedPtfxAsset(asset2)
        while not HasNamedPtfxAssetLoaded(asset2) do
            Citizen.Wait(1)
        end
    end
    local asset3 = "proj_indep_firework_v2"
    if not HasNamedPtfxAssetLoaded(asset3) then
        RequestNamedPtfxAsset(asset3)
        while not HasNamedPtfxAssetLoaded(asset3) do
            Citizen.Wait(1)
        end
    end
    local asset4 = "proj_indep_firework"
    if not HasNamedPtfxAssetLoaded(asset4) then
        RequestNamedPtfxAsset(asset4)
        while not HasNamedPtfxAssetLoaded(asset4) do
            Citizen.Wait(1)
        end
    end
    -- while true do
    --     Citizen.Wait(1)
    --     if fireworkTime > 0 and fireworkLoc ~= nil then
    --         BJCore.Functions.DrawText3D(fireworkLoc.x, fireworkLoc.y, fireworkLoc.z, "Firework starts ~r~"..fireworkTime)
    --     end
    -- end
end)

RegisterNetEvent("fireworks:client:UseFirework")
AddEventHandler("fireworks:client:UseFirework", function(itemName, assetName)
    exports['mythic_progbar']:Progress({
        name = "do_firework",
        duration = 3000,
        label = "Placing firework",
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = "anim@narcotics@trash",
            anim = "drop_front",
            flags = 16,
        },
    }, function(status)
        if not status then
            StopAnimTask(PlayerPedId(), "anim@narcotics@trash", "drop_front", 1.0)
            TriggerServerEvent("BJCore:Server:RemoveItem", itemName, 1)
            TriggerEvent("inventory:client:ItemBox", BJCore.Shared.Items[itemName], "remove")
            local pos = GetEntityCoords(PlayerPedId())
            DoFireWork(assetName, pos)
        else
            StopAnimTask(PlayerPedId(), "anim@narcotics@trash", "drop_front", 1.0)
            BJCore.Functions.Notify("Cancelled", "error")
        end
    end)
end)

function DoFireWork(asset, coords)
    fireworkTime = 5
    fireworkLoc = {x = coords.x, y = coords.y, z = coords.z}
    Citizen.CreateThread(function()
        while fireworkTime > 0 do
            Citizen.Wait(1000)
            fireworkTime = fireworkTime - 1
            BJCore.Functions.DrawText3D(fireworkLoc.x, fireworkLoc.y, fireworkLoc.z, "Firework starts ~r~"..fireworkTime)
        end
        UseParticleFxAssetNextCall("scr_indep_fireworks")
        local part = StartNetworkedParticleFxNonLoopedAtCoord("scr_indep_firework_shotburst", fireworkLoc.x, fireworkLoc.y, fireworkLoc.z + 42.5, 0.0, 0.0, 0.0, math.random() * 0.3 + 0.5, false, false, false, false)    
        for i = 1, math.random(5, 10), 1 do
            local firework = FireworkList[asset][math.random(1, #FireworkList[asset])]
            UseParticleFxAssetNextCall(asset)
            local part = StartNetworkedParticleFxNonLoopedAtCoord(firework, fireworkLoc.x, fireworkLoc.y, fireworkLoc.z + 42.5, 0.0, 0.0, 0.0, math.random() * 0.3 + 0.5, false, false, false, false)
            Citizen.Wait(math.random()*500)
        end
        fireworkLoc = nil
    end)

    Citizen.CreateThread(function()
        while fireworkTime > 0 do
            BJCore.Functions.DrawText3D(fireworkLoc.x, fireworkLoc.y, fireworkLoc.z, "Firework starts ~r~"..fireworkTime)
            Citizen.Wait(1)
        end
    end)
end