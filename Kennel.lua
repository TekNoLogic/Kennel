
local myname, ns = ...


local SOR, FOOD, DRINK = GetSpellInfo(20711), GetSpellInfo(7737), GetSpellInfo(430)

local DELAY = 2
local blistzones = {
	["Throne of Kil'jaeden"] = true,
	["Shallow's End"] = true,
	["\208\162\209\128\208\190\208\189 \208\154\208\184\208\187'\208\180\208\182\208\181\208\180\208\181\208\189\208\176"] = true, -- ruRU
	["Tr\195\180ne de Kil'jaeden"] = true, -- frFR
}

local f = CreateFrame("Frame")
f:Hide()


local function PutTheCatOut()
	ns.Debug(HasFullControl() and "In control" or "Not in control",
		       InCombatLockdown() and "In combat" or "Not in combat")

	if InCombatLockdown() then
		return ns.RegisterEvent("PLAYER_REGEN_ENABLED", PutTheCatOut)
	end
	if not HasFullControl() then
		return ns.RegisterEvent("PLAYER_CONTROL_GAINED", PutTheCatOut)
	end
	ns.UnregisterEvent("PLAYER_REGEN_ENABLED")

	if C_PetJournal.GetSummonedPetGUID() then return end

	ns.Debug("Queueing pet to be put out")
	f:Show()
end


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
	ns.Debug("Summoning random pet", use_all and "all" or "favs")
	C_PetJournal.SummonRandomPet(use_all)

	self:Hide()
end)


ns.RegisterEvent("ADDON_LOADED", function(event, addon)
	if addon == 'Blizzard_PetJournal' then ns.makebutt()
	elseif addon == myname then
		KennelDBPC = KennelDBPC or {}

		if IsLoggedIn() then PutTheCatOut()
		else ns.RegisterEvent("PLAYER_LOGIN", PutTheCatOut) end

		if IsAddOnLoaded("Blizzard_PetJournal") then ns.makebutt() end
	end
end)


ns.RegisterEvent("COMPANION_UPDATE", function(event, comptype)
	if comptype == "CRITTER" then PutTheCatOut() end
end)
