-- RegisterCommand('testlivery', function()
--     local txd = CreateRuntimeTxd('duiTxd')
--     local duiObj = CreateDui('http://i.imgur.com/bvhD7sq.gif', 640, 360)
--     _G.duiObj = duiObj
--     local dui = GetDuiHandle(duiObj)
--     local tx = CreateRuntimeTextureFromDuiHandle(txd, 'duiTex', dui)
--     AddReplaceTexture('ramleg', 'chr2_sign_2', 'duiTxd', 'duiTex')
-- end)

local customReplaces = {
    {
        duiUrl = 'https://i.imgur.com/izDi5NA.gif',
        height = 300,
        width = 400,
        replaceTxd = 'mp_m_freemode_01_mpsum\\berd_diff_003_m_uni',
        replaceTxn = 'berd_diff_003_m_uni'
    }
}

Citizen.CreateThread(function()
    while BJCore == nil do Wait(500); end

    for k,v in ipairs(customReplaces) do
        if not v.createdObj then
            while not HasStreamedTextureDictLoaded(v.replaceTxd) do
                RequestStreamedTextureDict(v.replaceTxd)
                Wait(250)
            end
            local ref = 'duiTxt'..tostring(k)
            local txd = CreateRuntimeTxd(ref)
            local duiObj = CreateDui(v.duiUrl, v.height, v.width)
            local dui = GetDuiHandle(duiObj)
            local tx = CreateRuntimeTextureFromDuiHandle(txd, 'duiTex', dui)
            AddReplaceTexture(v.replaceTxd, v.replaceTxn, ref, 'duiTex')
            customReplaces[k].createdObj = duiObj
        end
    end
    print('[DUI] Created texture overrides')
end)

AddEventHandler('onResourceStop', function(resName)
    if resName == GetCurrentResourceName() then
        for k,v in ipairs(customReplaces) do
            if v.createdObj then
                RemoveReplaceTexture(v.replaceTxd, v.replaceTxn)
                DestroyDui(v.createdObj)
            end
        end
        print('[DUI] Cleaned up texture overrides')
    end
end)