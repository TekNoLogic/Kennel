
------------------------------
--      Are you local?      --
------------------------------

local pt, cache, ids, sets = {}, {}, {}, {
	["Minipet"] = "23713,32588,20371,13584,32616,32622,30360,33993,25535,13583,22114,33154,32617,32233,13582,12185,19450,11023,10360,29958,29901,29364,10361,29960,23083,8491,8485,8486,8487,8490,8488,8489,11110,10393,10392,10822,20769,29953,8500,21301,8501,21308,15996,11826,27445,29363,10398,4401,31760,8496,8492,8494,8495,11825,23007,10394,8497,23015,29956,21305,29902,29957,12529,21309,11474,8499,8498,21277,11026,22235,23002,18964,29904,11027,12264,29903,33816,33818,34425,34478,34492,34493,34535,34493,35349,35350,35504",
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




