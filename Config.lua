
local myname, ns = ...


LibStub("tekKonfig-AboutPanel").new(nil, "Kennel")


function ns.makebutt()
	local enabled = LibStub("tekKonfig-Checkbox").new(PetJournal, 22, "Auto-summon", "BOTTOMLEFT", 168, 2)
	local checksound = enabled:GetScript("OnClick")
	enabled:SetScript("OnClick", function(self)
		checksound(self)
		ns.disabled = not ns.disabled
	end)
	enabled:SetChecked(true)

	ns.UnregisterEvent("ADDON_LOADED")
	ns.ADDON_LOADED = nil
	ns.makebutt = nil
end
