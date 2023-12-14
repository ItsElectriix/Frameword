local dbType, dbVersion = 'default', nil

BJCore = nil
TriggerEvent('BJCore:GetObject', function(obj) BJCore = obj end)

function getLicensesFromObject(licenses)
    local newLicenses = {}
    if licenses then
        if type(licenses) == 'string' then
            licenses = json.decode(licenses)
        end
        for k,v in pairs(licenses) do
            if v then
                table.insert(newLicenses, k)
            end
        end
    end
    return newLicenses
end

function getCastString(inner)
    if dbType == 'mariadb' then
        return ('JSON_COMPACT(%s)'):format(inner)
    else
        return ('CAST(%s AS JSON)'):format(inner)
    end
end

Citizen.CreateThread(function()
    exports['ghmattimysql']:execute("SELECT VERSION() AS 'version';", { }, function(results)
        if results and #results > 0 then
            dbVersion = results[1].version
            if not dbVersion then
                dbVersion = 'Unknown'
            else
                if string.match(dbVersion, 'MariaDB') then
                    dbType = 'mariadb'
                elseif string.match(dbVersion, 'mariadb') then
                    dbType = 'mariadb'
                end
            end
            print(('[MDT] Found database type "%s" from version: %ss'):format(dbType, dbVersion))
        end
    end)
end)

BJCore.Functions.RegisterServerCallback('bj-mdt:civilianSearch', function(source, cb, data)
    exports['ghmattimysql']:execute("SELECT citizenid FROM weapon_records WHERE JSON_UNQUOTE(JSON_EXTRACT(data, '$.serial')) = @serial;", {
        ['@serial'] = data.search
    }, function(results)
        local wrCid = ''
        if results and results[1] then
            wrCid = results[1].citizenid
        end

        exports['ghmattimysql']:execute("SELECT p.citizenid, CONCAT(JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.firstname')), ' ', JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.lastname'))) AS `name`, JSON_EXTRACT(metadata, '$.licences') AS `licenses`, mc.markers, mc.digitalInfo FROM players AS p LEFT JOIN mdt_civilians mc ON p.citizenid = mc.citizenid WHERE LOWER(CONCAT(JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.firstname')), ' ', JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.lastname')))) LIKE @search OR p.citizenid = @citizenid OR p.citizenid = @wrcitizenid OR JSON_CONTAINS(mc.digitalInfo, @digref, '$.fingerprintReferences') OR JSON_CONTAINS(mc.digitalInfo, @digref, '$.dnaReferences') LIMIT 20;", {        
            ['@search'] = string.lower('%'..data.search..'%'),
            ['@citizenid'] = data.search,
            ['@wrcitizenid'] = wrCid,
            ['@digref'] = '"'..data.search..'"'
        }, function(results)
            if results and #results > 0 then
                print('Found: '..tostring(#results))
                for _,v in ipairs(results) do
                    v.licenses = getLicensesFromObject(v.licenses)
    
                    if v.markers then
                        v.markers = json.decode(v.markers)
                    else
                        v.markers = {}
                    end
                end
            end
            cb(results)
        end)
    end)
end)

BJCore.Functions.RegisterServerCallback('bj-mdt:markerSearch', function(source, cb, data)
    queryBase = "SELECT mc.citizenid, CONCAT(JSON_UNQUOTE(JSON_EXTRACT(p.charinfo, '$.firstname')), ' ', JSON_UNQUOTE(JSON_EXTRACT(p.charinfo, '$.lastname'))) AS `name`, mc.markers FROM mdt_civilians AS mc INNER JOIN players AS p ON mc.citizenid = p.citizenid WHERE "    
        query = ""
    if data.bolo and data.arrest then
        query = "JSON_SEARCH(mc.markers, 'one', 'bolo', NULL, '$[*].type') IS NOT NULL OR JSON_SEARCH(mc.markers, 'one', 'arrest', NULL, '$[*].type') IS NOT NULL"
    elseif data.bolo then
        query = "JSON_SEARCH(mc.markers, 'one', 'bolo', NULL, '$[*].type') IS NOT NULL"
    elseif data.arrest then
        query = "JSON_SEARCH(mc.markers, 'one', 'arrest', NULL, '$[*].type') IS NOT NULL"
    end
    
    if query ~= "" then
        exports['ghmattimysql']:execute(queryBase..query, { }, function(results)
            if results and #results > 0 then
                for _,v in ipairs(results) do
                    if v.markers then
                        v.markers = json.decode(v.markers)
                    else
                        v.markers = {}
                    end
                end
            end
            cb(results)
        end)
    else
        cb({})
    end
end)

BJCore.Functions.RegisterServerCallback('bj-mdt:vehicleSearch', function(source, cb, data)
    exports['ghmattimysql']:execute("SELECT p.plate, p.vehicle, u.citizenid, CONCAT(JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.firstname')), ' ', JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.lastname'))) AS `owner` FROM player_vehicles p JOIN players u on u.citizenid = p.citizenid WHERE lower(plate) LIKE lower(@plate)", {        
        ['@plate'] = '%' .. data.search .. '%'
    }, function(vehicles)
        cb(vehicles)
    end)
end)

BJCore.Functions.RegisterServerCallback('bj-mdt:civilianLoad', function(source, cb, data)
    local Target = BJCore.Functions.GetPlayerByCitizenId(data.citizenid)
    if Target ~= nil then
        local genderOverride = Target.PlayerData.metadata['genderoverride']
        if genderOverride ~= nil then
            if genderOverride == "0" then genderOverride = "Male"
            elseif genderOverride == "1" then genderOverride = "Female"
            elseif genderOverride == "2" then genderOverride = "Other" end
        end
        populateCivilianData({
            citizenid = data.citizenid,
            name = Target.PlayerData.charinfo and Target.PlayerData.charinfo.firstname..' '..Target.PlayerData.charinfo.lastname or '',
            sex = genderOverride or (Target.PlayerData.charinfo and (Target.PlayerData.charinfo.gender == '0' and 'Male' or 'Female') or 'Male'),
            nationality = Target.PlayerData.charinfo and Target.PlayerData.charinfo.nationality or 'American',
            dob = Target.PlayerData.charinfo and Target.PlayerData.charinfo.birthdate or 'Unknown',
            phone = Target.PlayerData.charinfo and Target.PlayerData.charinfo.phone or '',
            jail = Target.PlayerData.metadata and Target.PlayerData.metadata.injail or 0,
            licenses = Target.PlayerData.metadata and getLicensesFromObject(Target.PlayerData.metadata.licenses) or {}
        }, cb)
    else
        exports['ghmattimysql']:execute("SELECT * FROM players WHERE citizenid = @citizenid;", {
            ['@citizenid'] = data.citizenid
        }, function(results)
            if results and #results > 0 then
                local charinfo = type(results[1].charinfo) == 'table' and results[1].charinfo or json.decode(results[1].charinfo)
                local metadata = type(results[1].charinfo) == 'table' and results[1].charinfo or json.decode(results[1].charinfo)
                populateCivilianData({
                    citizenid = data.citizenid,
                    name = charinfo.firstname..' '..charinfo.lastname,
                    sex = charinfo.gender == '0' and 'Male' or 'Female',
                    nationality = charinfo.nationality,
                    dob = charinfo.birthdate,
                    phone = charinfo.phone,
                    jail = metadata.injail,
                    licenses = getLicensesFromObject(metadata.licenses)
                }, cb)
            else
                cb(nil)
            end
        end)
    end
end)

function populateCivilianData(civilian, cb)
    if civilian and civilian.citizenid then
        exports['ghmattimysql']:execute("SELECT markers, notes, pictures, digitalInfo FROM mdt_civilians WHERE citizenid = @citizenid;", {
            ['@citizenid'] = civilian.citizenid
        }, function(results)
            if results and #results > 0 then
                for k,v in pairs(results[1]) do
                    civilian[k] = type(v) == 'table' and v or json.decode(v)
                end
            end
            exports['ghmattimysql']:execute("SELECT p.plate, p.vehicle, u.citizenid, CONCAT(JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.firstname')), ' ', JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.lastname'))) AS `owner` FROM player_vehicles p JOIN players u on u.citizenid = p.citizenid WHERE p.citizenid = @citizenid", {
                ['@citizenid'] = civilian.citizenid
            }, function(vehicles)
                if vehicles then
                    civilian.vehicles = vehicles
                end
                exports['ghmattimysql']:execute("SELECT * FROM weapon_records WHERE citizenid = @citizenid", {
                    ['@citizenid'] = civilian.citizenid
                }, function(weaponRecords)
                    if weaponRecords then
                        local weapons = {}
                        for _,v in ipairs(weaponRecords) do
                            local weaponData = json.decode(v.data)
                            table.insert(weapons, {
                                weaponName = weaponData.weapon,
                                serial = weaponData.serial,
                                purchaseDate = v.date
                            })
                        end
                        civilian.weaponPurchases = weapons
                    end
                    exports['ghmattimysql']:execute("SELECT id, citizenid, officerName, isCitation, crimeSummary, submitted FROM mdt_records WHERE citizenid = @citizenid", {
                        ['@citizenid'] = civilian.citizenid
                    }, function(records)
                        local rec = {}
                        if records and #records > 0 then
                            for _,v in ipairs(records) do
                                v.crimeSummary = json.decode(v.crimeSummary)
                                table.insert(rec, v)
                            end
                        end
                        civilian.recordSummaries = rec
                        cb(civilian)
                    end)
                end)
            end)
        end)
    else
        cb(nil)
    end
end

BJCore.Functions.RegisterServerCallback('bj-mdt:recordLoad', function(source, cb, data)
    exports['ghmattimysql']:execute("SELECT id, citizenid, officerName, isCitation, crimeSummary, info, submitted FROM mdt_records WHERE id = @id", {
        ['@id'] = data.id
    }, function(records)
        local rec = {}
        if records and #records > 0 then
            records[1].crimeSummary = json.decode(records[1].crimeSummary)
            records[1].info = json.decode(records[1].info)
            cb(records[1])
        else
            cb({})
        end
    end)
end)

BJCore.Functions.RegisterServerCallback('bj-mdt:getCrimes', function(source, cb, data)
    exports['ghmattimysql']:execute('SELECT * FROM mdt_crimes', {}, function(results)
        cb(results)
    end)
end)

BJCore.Functions.RegisterServerCallback('bj-mdt:addRecord', function(source, cb, data)
    if data.citizenid then
        if data.id then
            exports['ghmattimysql']:execute('UPDATE mdt_records SET isCitation = @isCitation, crimeSummary = @crimeSummary, info = @info WHERE citizenid = @citizenid AND id = @id', {
                ['@citizenid'] = data.citizenid,
                ['@officerName'] = data.officerName,
                ['@isCitation'] = data.isCitation,
                ['@crimeSummary'] = json.encode(data.crimeSummary),
                ['@info'] = json.encode(data.info),
                ['@id'] = data.id
            }, function()
                cb()
            end)
            local src = source
            local Player = BJCore.Functions.GetPlayer(src)
            TriggerEvent("bj-log:server:CreateLog", "mdt", "Record Edited", "orange", "**"..GetPlayerName(src) .. "** ("..Player.PlayerData.citizenid..") has updated the report: "..data.id.." on profile: "..Player.PlayerData.charinfo.firstname..' '..Player.PlayerData.charinfo.lastname)
        else
            exports['ghmattimysql']:execute('INSERT INTO mdt_records (citizenid, officerName, isCitation, crimeSummary, info) VALUES (@citizenid, @officerName, @isCitation, @crimeSummary, @info)', {
                ['@citizenid'] = data.citizenid,
                ['@officerName'] = data.officerName,
                ['@isCitation'] = data.isCitation,
                ['@crimeSummary'] = json.encode(data.crimeSummary),
                ['@info'] = json.encode(data.info)
            }, function()
                cb()
            end)
        end
    else
        cb()
    end
end)

BJCore.Functions.RegisterServerCallback('bj-mdt:addPhoto', function(source, cb, data)
    if data.citizenid then
        exports['ghmattimysql']:execute('INSERT INTO mdt_civilians (citizenid, pictures) VALUES (@citizenid, @pictures) ON DUPLICATE KEY UPDATE pictures = JSON_ARRAY_APPEND(pictures, "$", @picture)', {
            ['@citizenid'] = data.citizenid,
            ['@pictures'] = json.encode({data.photo}),
            ['@picture'] = data.photo
        }, function()
            cb()
        end)
    else
        cb()
    end
end)

BJCore.Functions.RegisterServerCallback('bj-mdt:addNote', function(source, cb, data)
    if data.citizenid then
        if data.noteIndex ~= nil then
            exports['ghmattimysql']:execute('UPDATE mdt_civilians SET notes = JSON_REPLACE(notes, @index, '..getCastString('@note')..') WHERE citizenid = @citizenid', {
                ['@citizenid'] = data.citizenid,
                ['@index'] = '$['..tostring(data.noteIndex)..']',
                ['@note'] = json.encode(data.note)
            }, function()
                cb()
            end)
            local src = source
            local Player = BJCore.Functions.GetPlayer(src)
            TriggerEvent("bj-log:server:CreateLog", "mdt", "Information/Note Edited", "orange", "**"..GetPlayerName(src) .. "** ("..Player.PlayerData.citizenid..") has updated an information/note on profile: "..Player.PlayerData.charinfo.firstname..' '..Player.PlayerData.charinfo.lastname)
        else
            exports['ghmattimysql']:execute('INSERT INTO mdt_civilians (citizenid, notes) VALUES (@citizenid, @notes) ON DUPLICATE KEY UPDATE notes = JSON_ARRAY_APPEND(notes, "$", '..getCastString('@note')..')', {
                ['@citizenid'] = data.citizenid,
                ['@notes'] = json.encode({data.note}),
                ['@note'] = json.encode(data.note)
            }, function()
                cb()
            end)
        end
    else
        cb()
    end
end)

BJCore.Functions.RegisterServerCallback('bj-mdt:addMarker', function(source, cb, data)
    if data.citizenid then
        exports['ghmattimysql']:execute('INSERT INTO mdt_civilians (citizenid, markers) VALUES (@citizenid, @markers) ON DUPLICATE KEY UPDATE markers = JSON_ARRAY_APPEND(markers, "$", '..getCastString('@marker')..')', {
            ['@citizenid'] = data.citizenid,
            ['@markers'] = json.encode({data.marker}),
            ['@marker'] = json.encode(data.marker)
        }, function()
            cb()
        end)
    else
        cb()
    end
end)

BJCore.Functions.RegisterServerCallback('bj-mdt:addDigRef', function(source, cb, data)
    if data.citizenid then
        if data.digitalReference then
            local target, fullObj
            if data.digitalReference.type == 'fingerprint' then
                target = '$.fingerprintReferences'
                fullObj = {
                    dnaReferences = {},
                    fingerprintReferences = {
                        data.digitalReference.ref
                    }
                }
            elseif data.digitalReference.type == 'dna' then
                target = '$.dnaReferences'
                fullObj = {
                    dnaReferences = {
                        data.digitalReference.ref
                    },
                    fingerprintReferences = {}
                }
            end

            if target and fullObj then
                if type(data.digitalReference.ref) == 'string' then
                    exports['ghmattimysql']:execute('INSERT INTO mdt_civilians (citizenid, digitalInfo) VALUES (@citizenid, @digrefs) ON DUPLICATE KEY UPDATE digitalInfo = IF(NOT JSON_CONTAINS_PATH(digitalInfo, "one", @target), JSON_SET(digitalInfo, @target, JSON_ARRAY(@digref)), JSON_ARRAY_APPEND(digitalInfo, @target, @digref))', {
                        ['@citizenid'] = data.citizenid,
                        ['@target'] = target,
                        ['@digrefs'] = json.encode(fullObj),
                        ['@digref'] = data.digitalReference.ref
                    }, function()
                        cb()
                    end)
                else
                    exports['ghmattimysql']:execute('INSERT INTO mdt_civilians (citizenid, digitalInfo) VALUES (@citizenid, @digrefs) ON DUPLICATE KEY UPDATE digitalInfo = IF(NOT JSON_CONTAINS_PATH(digitalInfo, "one", @target), JSON_SET(digitalInfo, @target, JSON_ARRAY('..getCastString('@digref')..')), JSON_ARRAY_APPEND(digitalInfo, @target, '..getCastString('@digref')..'))', {
                        ['@citizenid'] = data.citizenid,
                        ['@target'] = target,
                        ['@digrefs'] = json.encode(fullObj),
                        ['@digref'] = json.encode(data.digitalReference.ref)
                    }, function()
                        cb()
                    end)
                end
            end
        end
        return
    end
    cb()
end)

BJCore.Functions.RegisterServerCallback('bj-mdt:setMarkers', function(source, cb, data)
    if data.citizenid then
        exports['ghmattimysql']:execute('INSERT INTO mdt_civilians (citizenid, markers) VALUES (@citizenid, @markers) ON DUPLICATE KEY UPDATE markers = @markers', {
            ['@citizenid'] = data.citizenid,
            ['@markers'] = json.encode(data.markers)
        }, function()
            cb()
        end)
    else
        cb()
    end
end)
