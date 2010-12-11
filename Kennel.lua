
local debugf = tekDebug and tekDebug:GetFrame("Kennel")
local function Debug(...) if debugf then debugf:AddMessage(string.join(", ", ...)) end end


local SOR, FOOD, DRINK = GetSpellInfo(20711), GetSpellInfo(7737), GetSpellInfo(430)

local DELAY = 2
local blistzones, db = {
	["Throne of Kil'jaeden"] = true,
	["Shallow's End"] = true,
	["\208\162\209\128\208\190\208\189 \208\154\208\184\208\187'\208\180\208\182\208\181\208\180\208\181\208\189\208\176"] = true, -- ruRU
	["Tr\195\180ne de Kil'jaeden"] = true, -- frFR
}

local f = CreateFrame("Frame")
f:SetScript("OnEvent", function(self, event, ...) if self[event] then return self[event](self, event, ...) end end)
f:Hide()


local function GetZonePet()
	local z, sz = GetZoneText(), GetSubZoneText()
	local name = sz and sz ~= "" and KennelDBPC.zone[z .." - "..sz] or KennelDBPC.zone[z]
	if not name then return end
	for i=1,GetNumCompanions("CRITTER") do
		local _, pname, id = GetCompanionInfo("CRITTER", i)
		if pname == name then return i, pname end
	end
end


local function GetRandomPet()
	local numpets = GetNumCompanions("CRITTER")
	if not f.nlow then
		f.nlow = 0
		for i=1,numpets do
			local _, name, id = GetCompanionInfo("CRITTER", i)
			if db[id] == 1 then f.nlow = f.nlow +  1 end
		end
	end
	if numpets > 0 then
		local i = math.random(numpets)
		local _, name, id = GetCompanionInfo("CRITTER", i)
		if db[id] == 2 or db[id] == 1 and math.random(f.nlow) == 1 then return i, name end
	end
end


local function SummonedPet()
	for i=1,GetNumCompanions("CRITTER") do
		local _, name, _, _, summoned = GetCompanionInfo("CRITTER", i)
		if summoned then return name end
	end
end


local numpets = 0
local function PutTheCatOut(self, event)
	Debug(event or "nil", HasFullControl() and "In control" or "Not in control", InCombatLockdown() and "In combat" or "Not in combat")

	if InCombatLockdown() then return self:RegisterEvent("PLAYER_REGEN_ENABLED") end
	if not HasFullControl() then return self:RegisterEvent("PLAYER_CONTROL_GAINED") end
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")

	local summ, _, zonepet = SummonedPet(), GetZonePet()
	if (not zonepet and summ) or (zonepet and zonepet == summ) then return end

	Debug("Queueing pet to be put out")
	self:Show()
end


local elapsed
f:SetScript("OnShow", function() elapsed = 0 end)
f:SetScript("OnUpdate", function(self, elap)
	if KennelDBPC.disabled then return end

	elapsed  = elapsed + elap
	if elapsed < DELAY then return end

	local _, instanceType = IsInInstance()
	local pvpink = instanceType == "pvp" or instanceType == "arena"

	if pvpink or InCombatLockdown() or IsStealthed() or IsMounted() or IsFlying() or IsFalling() or UnitCastingInfo("player") or UnitChannelInfo("player") or blistzones[GetSubZoneText()]
		or UnitBuff("player", SOR) or UnitBuff("player", FOOD) or UnitBuff("player", DRINK) then
		elapsed = 0
		return
	end

	local peti, name = GetZonePet()
	if not peti then peti, name = GetRandomPet() end
	if peti then
	local numpets = GetNumCompanions("CRITTER")
		Debug("Putting out pet", name)
		CallCompanion("CRITTER", peti)
		self:Hide()
	end
end)


f:RegisterEvent("ADDON_LOADED")


function f:ADDON_LOADED(event, addon)
	if addon:lower() ~= "kennel" then return end

	KennelDBPC = KennelDBPC or {random = {}, zone = {}}
	if not KennelDBPC.random then
		for i,v in pairs(KennelDBPC) do KennelDBPC[i] = 0 end
		KennelDBPC = {random = KennelDBPC}
		KennelDBPC.disabled, KennelDBPC.random.disabled = KennelDBPC.random.disabled
	end
	if not KennelDBPC.zone then KennelDBPC.zone = {} end

	db = setmetatable(KennelDBPC.random, {__index = function() return 2 end})
	self.randomdb = db

	self:UnregisterEvent("ADDON_LOADED")
	self.ADDON_LOADED = nil

	if IsLoggedIn() then PutTheCatOut(f, "PLAYER_LOGIN") else f:RegisterEvent("PLAYER_LOGIN") end
	self:RegisterEvent("PLAYER_LOGOUT")
end


function f:PLAYER_LOGOUT()
	for i,v in pairs(db) do if v == 2 then db[i] = nil end end
end


f.PLAYER_REGEN_ENABLED = PutTheCatOut
f.PLAYER_CONTROL_GAINED = PutTheCatOut
f.PLAYER_LOGIN = PutTheCatOut
f.PLAYER_UNGHOST = PutTheCatOut
f.ZONE_CHANGED = PutTheCatOut
f.ZONE_CHANGED_INDOORS = PutTheCatOut
f.ZONE_CHANGED_NEW_AREA = PutTheCatOut


function f:COMPANION_UPDATE(event, comptype)
local wasmounted
	if comptype == "CRITTER" then return PutTheCatOut(self, "COMPANION_UPDATE") end
	if comptype == "MOUNT" then
		local found
		for i=1,GetNumCompanions("CRITTER") do found = found or select(5, GetCompanionInfo("MOUNT", i)) end
		if KennelDBPC.dismissonmount and found and not wasmounted then DismissCompanion("CRITTER") end
		wasmounted = found
		return
	end
end

f:RegisterEvent("COMPANION_UPDATE")
f:RegisterEvent("PLAYER_UNGHOST")
f:RegisterEvent("ZONE_CHANGED")
f:RegisterEvent("ZONE_CHANGED_INDOORS")
f:RegisterEvent("ZONE_CHANGED_NEW_AREA")


KENNELFRAME = f
