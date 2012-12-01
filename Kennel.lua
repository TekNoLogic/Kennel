
local myname, ns = ...


local SOR, FOOD = GetSpellInfo(20711), GetSpellInfo(7737)
local DRINK = GetSpellInfo(430)

local blistzones = {
	["Throne of Kil'jaeden"] = true,
	["Shallow's End"] = true,
	["\208\162\209\128\208\190\208\189 \208\154\208\184\208\187'\208\180\208\182\208\181\208\180\208\181\208\189\208\176"] = true, -- ruRU
	["Tr\195\180ne de Kil'jaeden"] = true, -- frFR
}


local function CannotDoIt()
	if ns.disabled then return true end

	local _, instanceType = IsInInstance()
	local pvpink = instanceType == "pvp" or instanceType == "arena"

	return pvpink or InCombatLockdown() or IsStealthed() or IsMounted()
		or IsFlying() or IsFalling() or UnitCastingInfo("player")
		or UnitChannelInfo("player") or blistzones[GetSubZoneText()]
		or UnitBuff("player", SOR) or UnitBuff("player", FOOD)
		or UnitBuff("player", DRINK)
end


local function DoIt()
	if CannotDoIt() then return end
	if C_PetJournal.GetSummonedPetGUID() then return true end

	-- 1 in 3 times, we use all pets
	local use_all = math.random(3) == 1
	ns.Debug("Summoning random pet", use_all and "all" or "favs")
	C_PetJournal.SummonRandomPet(use_all)

	return true
end


local function PutTheCatOut()
	if C_PetJournal.GetSummonedPetGUID() then return end

	if InCombatLockdown() then
		ns.Debug("In combat")
		return ns.RegisterEvent("PLAYER_REGEN_ENABLED", PutTheCatOut)
	end
	if not HasFullControl() then
		ns.Debug("Not in control")
		return ns.RegisterEvent("PLAYER_CONTROL_GAINED", PutTheCatOut)
	end
	ns.UnregisterEvent("PLAYER_REGEN_ENABLED")
	ns.UnregisterEvent("PLAYER_CONTROL_GAINED")

	ns.Debug("Queueing pet to be put out")
	ns.StartRepeatingTimer(10, DoIt)
end


local function MakeButt()
	local check = ns.NewCheckBox(PetJournal, 22, "BOTTOMLEFT", 168, 2)
	check:SetScript("OnClick", function(self) ns.disabled = not ns.disabled end)
	check:SetChecked(true)

	ns.NewCheckLabel(check, 'Auto-summon')

	ns.UnregisterEvent("ADDON_LOADED")
	ns.ADDON_LOADED = nil
	MakeButt = nil
end


ns.RegisterEvent("ADDON_LOADED", function(event, addon)
	if addon == 'Blizzard_PetJournal' then MakeButt()
	elseif addon == myname then
		if IsLoggedIn() then PutTheCatOut()
		else ns.RegisterEvent("PLAYER_LOGIN", PutTheCatOut) end

		if IsAddOnLoaded("Blizzard_PetJournal") then MakeButt() end
	end
end)


ns.RegisterEvent("COMPANION_UPDATE", function(event, comptype)
	if comptype == "CRITTER" then PutTheCatOut() end
end)
