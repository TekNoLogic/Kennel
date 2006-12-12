
------------------------------
--      Are you local?      --
------------------------------

local pt, cache, ids, sets = {}, {}, {}, {
	["Minipet"] = "29958 29901 29363 23083 18597 23007 23015 23002 18598 22235 21277 4401 8485 8486 8487 8488 8489 8490 8491 8492 8494 8495 8496 8497 8498 8499 8500 8501 10360 10361 10392 10393 10394 10398 10822 11023 11026 11110 11474 11825 11826 12264 12529 13582 13583 13584 15996 19450 20371 20769",
	["Minipet - Holiday"]	= "21301 21305 21308 21309",
}
setmetatable(ids, {__mode = "k"})
KennelMicroPeriodicTable = pt


local function CacheSet(set)
	if not set then return end

	local rset = set and sets[set]
	if not rset then return end

	if not cache[set] then
		cache[set] = {}
		for word in string.gmatch(rset, "%S+") do
			local _, _, id, val = string.find(word, "(%d+):(%d+)")
			id, val = tonumber(id) or tonumber(word), tonumber(val) or 0
			cache[set][id] = val
		end
	end

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
	Kennel:Print(i, t[i])
	if t and t[i] then return t[i] end
end})




