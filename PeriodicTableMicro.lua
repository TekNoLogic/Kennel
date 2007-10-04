
------------------------------
--      Are you local?      --
------------------------------

local pt, cache, ids, sets = {}, {}, {}, {
	["Minipet"] = "32233,32617,32616,32622,23713,32588,13584,25535,13583,13582,19450,11023,10360,29958,29901,20371,29364,10361,23083,8491,8485,8486,8487,8490,8488,8489,11110,10393,10392,10822,20769,29953,8500,8501,18598,15996,11826,27445,29363,10398,4401,31760,18597,8496,8492,8494,8495,11825,23007,10394,8497,23015,29956,29902,29957,12529,11474,8499,8498,21277,11026,22235,23002,29904,11027,12264,29903",
	["Minipet - Holiday"] = "21301,21305,21308,21309",
}
setmetatable(ids, {__mode = "k"})
PeriodicTableMicro = pt


local function TableStuffer(...)
	local t = {}
	for i=1,select("#", ...) do
		local v = select(i, ...)
		t[tonumber(v)] = 0
	end
	return t
end


local function CacheSet(set)
	if not set or not sets[set] then return end
	if not cache[set] then cache[set] = TableStuffer(string.split(" ,", sets[set])) end
	return true
end


local function GetID(item)
	if item and ids[item] then return ids[item] end

	local t = type(item)
	if t == "number" then return item
	elseif t == "string" then
		local _, _, id = string.find(item, "item:(%d+):")
		if not id then return end
		ids[item] = tonumber(id)
		return ids[item]
	end
end


setmetatable(pt, {__call = function(self, item, set)
	local i, rset = GetID(item), set and sets[set]
	if not i or not rset then return end

	local t = CacheSet(set) and cache[set]
	if t and t[i] then return t[i] end
end})




