BJCore = nil
TriggerEvent('BJCore:GetObject', function(obj) BJCore = obj end)

BJCore.Commands.Add("rep", "Show information about your rep levels", {}, true, function(source, args)
    TriggerClientEvent('bj_rpgrep:showUI', source)
end)