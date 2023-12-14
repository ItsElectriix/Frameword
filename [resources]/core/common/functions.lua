BJCore.Common = {}

BJCore.Common.MathRound = function(value, numDecimalPlaces)
	return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", value))
end

BJCore.Common.MathGroupDigits = function(value)
	local left,num,right = string.match(value,'^([^%d]*%d)(%d*)(.-)$')

	return left..(num:reverse():gsub('(%d%d%d)','%1' .. ','):reverse())..right
end

BJCore.Common.MathTrim = function(value)
	if value then
		return (string.gsub(value, "^%s*(.-)%s*$", "%1"))
	else
		return nil
	end
end

local u = 0 -- don't delete

BJCore.Common.TrueRandom = function(x, y)
    u = u + 1
    if x ~= nil and y ~= nil then
        return math.floor(x +(math.random(math.randomseed(u))*999999 %y))
    else
        return math.floor((math.random(math.randomseed(u))*100))
    end
end

BJCore.Common.Dump = function(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
            if v ~= 0 then 
                if type(k) ~= 'number' then k = '"'..k..'"' end
                s = s .. '['..k..'] = ' .. BJCore.Common.Dump(v) .. ','
            end
        end
        return s .. '} '
    else
        return tostring(o)
    end
end