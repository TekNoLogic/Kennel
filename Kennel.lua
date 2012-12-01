
local myname, ns = ...


local debugf = tekDebug and tekDebug:GetFrame("Kennel")
local function Debug(...) if debugf then debugf:AddMessage(string.join(", ", ...)) end end


local SOR, FOOD, DRINK = GetSpellInfo(20711), GetSpellInfo(7737), GetSpellInfo(430)

local DELAY = 2
local blistzones = {
	["Throne of Kil'jaeden"] = true,
	["Shallow's End"] = true,
	["\208\162\209\128\208\190\208\189 \208\154\208\184\208\187'\208\180\208\182\208\181\208\180\208\181\208\189\208\176"] = true, -- ruRU
	["Tr\195\180ne de Kil'jaeden"] = true, -- frFR
}

local f = CreateFrame("Frame")
f:SetScript("OnEvent", function(self, event, ...)
	if self[event] then return self[event](self, event, ...) end
end)
f:Hide()


local function PutTheCatOut(self, event)
	Debug(event or "nil", HasFullControl() and "In control" or "Not in control",
		    InCombatLockdown() and "In combat" or "Not in combat")

	if InCombatLockdown() then
		return self:RegisterEvent("PLAYER_REGEN_ENABLED")
	end
	if not HasFullControl() then
		return self:RegisterEvent("PLAYER_CONTROL_GAINED")
	end
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")

	if C_PetJournal.GetSummonedPetGUID() then return end

	Debug("Queueing pet to be put out")
	self:Show()
end
f.PLAYER_REGEN_ENABLED = PutTheCatOut
f.PLAYER_CONTROL_GAINED = PutTheCatOut


local elapsed
f:SetScript("OnShow", function() elapsed = 0 end)
f:SetScript("OnUpdate", function(self, elap)
	if KennelDBPC.disabled then return end

	elapsed = elapsed + elap
	if elapsed < DELAY then return end

	local _, instanceType = IsInInstance()
	local pvpink = instanceType == "pvp" or instanceType == "arena"

	if pvpink or InCombatLockdown() or IsStealthed() or IsMounted() or IsFlying()
		or IsFalling() or UnitCastingInfo("player") or UnitChannelInfo("player")
		or blistzones[GetSubZoneText()] or UnitBuff("player", SOR)
		or UnitBuff("player", FOOD) or UnitBuff("player", DRINK) then

		elapsed = 0
		return
	end

	-- 1 in 3 times, we use all pets
	local use_all = math.random(3) == 1
	Debug("Summoning random pet", use_all and "all" or "favs")
	C_PetJournal.SummonRandomPet(use_all)

	self:Hide()
end)


f:RegisterEvent("ADDON_LOADED")
function f:ADDON_LOADED(event, addon)
	if addon == 'Blizzard_PetJournal' then self:JournalLoaded()
	elseif addon == myname then
		KennelDBPC = KennelDBPC or {}

		if IsLoggedIn() then PutTheCatOut(f, "PLAYER_LOGIN") else
			f:RegisterEvent("PLAYER_LOGIN")
		end

		if IsAddOnLoaded("Blizzard_PetJournal") then self:JournalLoaded() end
	end
end


function f:JournalLoaded()
	ns.makebutt()

	self:UnregisterEvent("ADDON_LOADED")

	self.ADDON_LOADED = nil
	self.JournalLoaded = nil
	ns.makebutt = nil
end


f:RegisterEvent("COMPANION_UPDATE")
function f:COMPANION_UPDATE(event, comptype)
	if comptype == "CRITTER" then PutTheCatOut(self, "COMPANION_UPDATE") end
end
