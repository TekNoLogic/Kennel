
local NUMROWS, NUMCOLS, ICONSIZE, GAP, EDGEGAP = 7, 9, 32, 8, 16
local rows = {}


local frame = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)
frame.name = "Kennel"
frame:SetScript("OnShow", function(frame)
	local title, subtitle = LibStub("tekKonfig-Heading").new(frame, "Kennel", "This panel allows you to select which pets Kennel will put out.")


	local enabled = LibStub("tekKonfig-Checkbox").new(frame, nil, "Enabled", "TOPLEFT", subtitle, "BOTTOMLEFT", -2, -GAP)
	local checksound = enabled:GetScript("OnClick")
	enabled:SetScript("OnClick", function(self) checksound(self); KennelDBPC.disabled = not KennelDBPC.disabled end)
	enabled:SetChecked(not KennelDBPC.disabled)


	local group = LibStub("tekKonfig-Group").new(frame, "Furry bastards", "TOP", enabled, "BOTTOM", 0, -GAP-4)
	group:SetPoint("LEFT", EDGEGAP, 0)
	group:SetPoint("BOTTOMRIGHT", -EDGEGAP, EDGEGAP)

	local function OnClick(self) KennelDBPC[self.id] = not KennelDBPC[self.id] end
	local function ShowTooltip(self)
		if not self.name then return end
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText("|cffffffff"..self.name)
		GameTooltip:Show()
	end
	local function HideTooltip() GameTooltip:Hide() end

	for i=1,NUMROWS do
		local row = CreateFrame("Frame", nil, group)
		row:SetHeight(ICONSIZE)
		if i == 1 then row:SetPoint("TOPLEFT", group, EDGEGAP, -EDGEGAP)
		else row:SetPoint("TOPLEFT", rows[i-1], "BOTTOMLEFT", 0, -6) end
		row:SetPoint("RIGHT", -EDGEGAP, 0)
		row.buttons = {}
		rows[i] = row

		for j=1,NUMCOLS do
			local iconbutton = CreateFrame("CheckButton", nil, row)
			if j == 1 then iconbutton:SetPoint("TOPLEFT", row, "TOPLEFT")
			else iconbutton:SetPoint("LEFT", row.buttons[j-1], "RIGHT", GAP, 0) end
			iconbutton:SetWidth(ICONSIZE)
			iconbutton:SetHeight(ICONSIZE)

			iconbutton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
			iconbutton:SetCheckedTexture("Interface\\Buttons\\UI-Button-Outline")
			local tex = iconbutton:GetCheckedTexture()
			tex:ClearAllPoints()
			tex:SetPoint("CENTER")
			tex:SetWidth(ICONSIZE/37*66) tex:SetHeight(ICONSIZE/37*66)

			iconbutton:SetScript("OnEnter", ShowTooltip)
			iconbutton:SetScript("OnLeave", HideTooltip)
			iconbutton:SetScript("OnClick", OnClick)

			row.buttons[j] = iconbutton
		end
	end

	local function Update()
		for i=1,NUMROWS do
			for j=1,NUMCOLS do
				local butt, offset = rows[i].buttons[j], (i-1)*NUMCOLS + j
				local _, name, id, tex = GetCompanionInfo("CRITTER", offset)
				if name then
					butt.name, butt.id = name, id
					butt:SetNormalTexture(tex)
					butt:SetChecked(not KennelDBPC[id])
					butt:Show()
				else
					butt:Hide()
				end
			end
		end
	end

	Update()
	frame:SetScript("OnShow", Update)
end)


InterfaceOptions_AddCategory(frame)

LibStub("tekKonfig-AboutPanel").new("Kennel", "Kennel")
