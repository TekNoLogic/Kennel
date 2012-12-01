
local myname, ns = ...


if AddonLoader and AddonLoader.RemoveInterfaceOptions then
	AddonLoader:RemoveInterfaceOptions("Kennel")
end

local frame = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)
frame.name = "Kennel"
frame:Hide()
frame:SetScript("OnShow", function(frame)
	local tektab = LibStub("tekKonfig-TopTab")

	local title, subtitle = LibStub("tekKonfig-Heading").new(frame, "Kennel", "Put the cat out.")


	local enabled = LibStub("tekKonfig-Checkbox").new(frame, nil, "Enabled", "TOPLEFT", subtitle, "BOTTOMLEFT", -2, -8)
	local checksound = enabled:GetScript("OnClick")
	enabled:SetScript("OnClick", function(self)
		checksound(self); KennelDBPC.disabled = not KennelDBPC.disabled
	end)
	enabled:SetChecked(not KennelDBPC.disabled)
end)


InterfaceOptions_AddCategory(frame)

LibStub("tekKonfig-AboutPanel").new("Kennel", "Kennel")


function ns.makebutt()
	local butt = CreateFrame("Button", nil, PetJournal)
	butt:SetWidth(32) butt:SetHeight(32)
	butt:SetPoint("TOPLEFT", 225, -28)
	butt:SetNormalTexture("Interface\\Icons\\INV_Box_PetCarrier_01")
	butt:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
	butt:SetScript("OnClick", function() InterfaceOptionsFrame_OpenToCategory(frame) end)
	butt:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText("Open Kennel config")
		GameTooltip:Show()
	end)
	butt:SetScript("OnLeave", function() GameTooltip:Hide() end)
end
