
local myname, ns = ...


LibStub("tekKonfig-AboutPanel").new(nil, "Kennel")


function ns.makebutt()
	local check = ns.NewCheckBox(PetJournal, 22, "BOTTOMLEFT", 168, 2)
	check:SetScript("OnClick", function(self) ns.disabled = not ns.disabled end)
	check:SetChecked(true)

	ns.NewCheckLabel(check, 'Auto-summon')

	ns.UnregisterEvent("ADDON_LOADED")
	ns.ADDON_LOADED = nil
	ns.makebutt = nil
end
