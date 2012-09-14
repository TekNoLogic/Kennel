﻿
local debugf = tekDebug and tekDebug:GetFrame("Kennel")
local function Debug(...) if debugf then debugf:AddMessage(string.join(", ", ...)) end end


local SOR, FOOD, DRINK = GetSpellInfo(20711), GetSpellInfo(7737), GetSpellInfo(430)

local DELAY = 2
local blistzones, blistpets, db = {
	["Throne of Kil'jaeden"] = true,
	["Shallow's End"] = true,
	["\208\162\209\128\208\190\208\189 \208\154\208\184\208\187'\208\180\208\182\208\181\208\180\208\181\208\189\208\176"] = true, -- ruRU
	["Tr\195\180ne de Kil'jaeden"] = true, -- frFR
}, {
	[92395] = true, -- Guild Page
	[92396] = true, -- Guild Page
	[92397] = true, -- Guild Herald
	[92398] = true, -- Guild Herald
}

local f = CreateFrame("Frame")
f:SetScript("OnEvent", function(self, event, ...) if self[event] then return self[event](self, event, ...) end end)
f:Hide()


local function GetZonePet()
	local z, sz = GetZoneText(), GetSubZoneText()
	local zonepetname = sz and sz ~= "" and KennelDBPC.zone[z .." - "..sz] or KennelDBPC.zone[z]
	if not zonepetname then return end

	local _, numpets = C_PetJournal.GetNumPets(false)

	for i=1,numpets do
		local petID, _, _, customname, _, favorite, _, name, _, _, creatureID =
			C_PetJournal.GetPetInfoByIndex(i, false)

		if (customname or name) == zonepetname then
			return petID, customname or name
		end
	end
end


local favs, allpets = {}, {}
local function GetRandomPet()
	local _, numpets = C_PetJournal.GetNumPets(false)
	for i in pairs(favs) do favs[i] = nil end
	for i in pairs(allpets) do allpets[i] = nil end

	for i=1,numpets do
		local petID, _, _, customname, _, favorite, _, name, _, _, creatureID =
			C_PetJournal.GetPetInfoByIndex(i, false)

		if favorite then table.insert(favs, petID) end
		if not blistpets[creatureID] then table.insert(allpets, petID) end
	end

	if not next(allpets) then return end

	-- Two out of three times, use a fav
	local t = next(favs) and math.random(3) ~= 1 and favs or allpets
	local i = math.random(#t)
	local petID = t[i]
	local _, customname, _, _, _, _, name = C_PetJournal.GetPetInfoByPetID(petID)

	return petID, customname or name
end


local function SummonedPet()
	local petID = C_PetJournal.GetSummonedPetID()
	if not petID then return end

	local _, customname, _, _, _, _, name = C_PetJournal.GetPetInfoByPetID(petID)
	return customname or name
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

	local petID, name = GetZonePet()
	if not petID then petID, name = GetRandomPet() end
	if petID then
		Debug("Putting out pet", name, petID)
		C_PetJournal.SummonPetByID(petID)
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


local function IsMounted()
	for i=1,GetNumCompanions("MOUNT") do
		local _, _, _, _, mounted = GetCompanionInfo("MOUNT", i)
		if mounted then return true end
	end
end


local wasmounted
function f:COMPANION_UPDATE(event, comptype)

	if comptype == "CRITTER" then
		return PutTheCatOut(self, "COMPANION_UPDATE")
	end

	if comptype == "MOUNT" then
		local mounted = IsMounted()

		if KennelDBPC.dismissonmount and mounted and not wasmounted then
			DismissCompanion("CRITTER")
		end

		wasmounted = mounted

		return
	end
end

f:RegisterEvent("COMPANION_UPDATE")
f:RegisterEvent("PLAYER_UNGHOST")
f:RegisterEvent("ZONE_CHANGED")
f:RegisterEvent("ZONE_CHANGED_INDOORS")
f:RegisterEvent("ZONE_CHANGED_NEW_AREA")


KENNELFRAME = f
