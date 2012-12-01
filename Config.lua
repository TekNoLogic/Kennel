
local myname, ns = ...


local NUMROWS, NUMCOLS, ICONSIZE, GAP, EDGEGAP = 8, 4, 32, 8, 16
local rows = {}
local kennel = KENNELFRAME
KENNELFRAME = nil

if AddonLoader and AddonLoader.RemoveInterfaceOptions then AddonLoader:RemoveInterfaceOptions("Kennel") end

local frame = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)
frame.name = "Kennel"
frame:Hide()
frame:SetScript("OnShow", function(frame)
	local tektab = LibStub("tekKonfig-TopTab")

	local title, subtitle = LibStub("tekKonfig-Heading").new(frame, "Kennel", "This panel allows you to select which pets Kennel will put out.")


	local enabled = LibStub("tekKonfig-Checkbox").new(frame, nil, "Enabled", "TOPLEFT", subtitle, "BOTTOMLEFT", -2, -GAP)
	local checksound = enabled:GetScript("OnClick")
	enabled:SetScript("OnClick", function(self) checksound(self); KennelDBPC.disabled = not KennelDBPC.disabled end)
	enabled:SetChecked(not KennelDBPC.disabled)

	local mountdismiss = LibStub("tekKonfig-Checkbox").new(frame, nil, "Dismiss when mounted", "TOPLEFT", enabled, "BOTTOMLEFT", 0, -4)
	mountdismiss:SetScript("OnClick", function(self) checksound(self); KennelDBPC.dismissonmount = not KennelDBPC.dismissonmount end)
	mountdismiss:SetChecked(KennelDBPC.dismissonmount)


	local group = LibStub("tekKonfig-Group").new(frame, nil, "TOP", mountdismiss, "BOTTOM", 0, -GAP-14)
	group:SetPoint("LEFT", EDGEGAP, 0)
	group:SetPoint("BOTTOMRIGHT", -EDGEGAP, EDGEGAP)


	--------------------------
	--      Zone panel      --
	--------------------------

	local zones = CreateFrame("Frame", nil, group)
	zones:SetAllPoints()

	local scrollbar = LibStub("tekKonfig-Scroll").new(zones, 6, 1)

	zones:EnableMouseWheel()
	zones:SetScript("OnMouseWheel", function(self, val) scrollbar:SetValue(scrollbar:GetValue() - val) end)

	local zonestext = zones:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	zonestext:SetHeight(34)
	zonestext:SetPoint("TOPLEFT", zones, "TOPLEFT", EDGEGAP, -EDGEGAP)
	zonestext:SetPoint("RIGHT", zones, -EDGEGAP-16, 0)
	zonestext:SetNonSpaceWrap(true)
	zonestext:SetJustifyH("LEFT")
	zonestext:SetJustifyV("TOP")
	zonestext:SetText("These pets will be used when you are in the corresponding zone or subzone.  Summon the desired pet and click an 'add' button to set that pet for the current zone or subzone.")


	local NUMROWS = 10
	local ROWHEIGHT = 15
	local rows, Update, selectedzone = {}
	local function OnClick(self)
		selectedzone = self.zone:GetText()
		Update()
	end
	for i=1,NUMROWS do
		local row = CreateFrame("CheckButton", nil, zones)
		row:SetHeight(ROWHEIGHT)
		if i == 1 then row:SetPoint("TOP", zonestext, "BOTTOM", 0, -8)
		else row:SetPoint("TOP", rows[i-1], "BOTTOM") end
		row:SetPoint("LEFT", 4, 0)
		row:SetPoint("RIGHT", scrollbar, "LEFT", -4, 0)

		local highlight = row:CreateTexture()
		highlight:SetTexture("Interface\\HelpFrame\\HelpFrameButton-Highlight")
		highlight:SetTexCoord(0, 1, 0, 0.578125)
		highlight:SetAllPoints()
		row:SetHighlightTexture(highlight)
		row:SetCheckedTexture(highlight)

		local textzone = row:CreateFontString(nil, nil, "GameFontNormalSmall")
		textzone:SetPoint("LEFT", EDGEGAP + GAP, 0)
		local textpet = row:CreateFontString(nil, nil, "GameFontHighlightSmall")
		textpet:SetPoint("LEFT", textzone, "RIGHT", GAP, 0)
		textpet:SetPoint("RIGHT", -GAP, 0)
		textpet:SetJustifyH("RIGHT")

		row:SetScript("OnClick", OnClick)

		row.zone = textzone
		row.pet = textpet
		textzone:SetText("Testing zone")
		textpet:SetText("Test pet")
		rows[i] = row
	end

	local offset, deletebutt, sortedzones = 0
	function Update()
		if not sortedzones then
			sortedzones = {}
			for i in pairs(KennelDBPC.zone) do table.insert(sortedzones, i) end
			table.sort(sortedzones)
		end

		scrollbar:SetMinMaxValues(0, math.max(0, #sortedzones - NUMROWS))

		local selectedvisible
		for i,row in pairs(rows) do
			local zone = sortedzones[i + offset]
			local pet = zone and KennelDBPC.zone[zone]
			if pet then
				row.zone:SetText(zone)
				row.pet:SetText(pet)
				row:SetChecked(zone == selectedzone)
				selectedvisible = selectedvisible or zone == selectedzone
				row:Show()
			else
				row:Hide()
			end
		end

		if selectedvisible then deletebutt:Enable() else deletebutt:Disable() end
	end

	local function GetCurrentPet()
		for i=1,GetNumCompanions("CRITTER") do
			local _, name, _, _, summoned = GetCompanionInfo("CRITTER", i)
			if summoned then return name end
		end
	end

	local addzone = LibStub("tekKonfig-Button").new(zones, "BOTTOMLEFT", zones, "BOTTOMLEFT", EDGEGAP, EDGEGAP):MakeSmall()
	addzone.tiptext = "Click to set the currently summoned pet to be used in the current zone."
	addzone:SetText("Add zone")
	addzone:SetScript("OnClick", function()
		KennelDBPC.zone[GetZoneText()] = GetCurrentPet()
		sortedzones, selectedzone = nil
		Update()
	end)

	local addsubzone = LibStub("tekKonfig-Button").new(zones, "LEFT", addzone, "RIGHT", GAP/2, 0):MakeSmall()
	addsubzone.tiptext = "Click to set the currently summoned pet to be used in the current subzone."
	addsubzone:SetText("Add subzone")
	addsubzone:SetScript("OnShow", function(self) if GetSubZoneText() == "" then self:Disable() else self:Enable() end end)
	addsubzone:SetScript("OnClick", function()
		KennelDBPC.zone[GetZoneText() .." - "..GetSubZoneText()] = GetCurrentPet()
		sortedzones, selectedzone = nil
		Update()
	end)

	deletebutt = LibStub("tekKonfig-Button").new(zones, "BOTTOM", zones, "BOTTOM", 0, EDGEGAP):MakeSmall():MakeGrey()
	deletebutt:SetPoint("RIGHT", scrollbar, "LEFT", -EDGEGAP, 0)
	deletebutt.tiptext = "Remove the currently selected zone-pet setting."
	deletebutt:SetText("Delete")
	deletebutt:SetScript("OnClick", function()
		KennelDBPC.zone[selectedzone], sortedzones, selectedzone = nil
		Update()
	end)

	local f = scrollbar:GetScript("OnValueChanged")
	scrollbar:SetScript("OnValueChanged", function(self, value, ...)
		offset = math.floor(value)
		Update()
		return f(self, value, ...)
	end)

	Update()
	scrollbar:SetValue(0)
	zones:SetScript("OnShow", Update)


	frame:SetScript("OnShow", nil)
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
