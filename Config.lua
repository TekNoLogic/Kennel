
local NUMROWS, NUMCOLS, ICONSIZE, GAP, EDGEGAP = 5, 8, 32, 8, 16
local rows = {}
local kennel = KENNELFRAME
KENNELFRAME = nil

local frame = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)
frame.name = "Kennel"
frame:SetScript("OnShow", function(frame)
	local title, subtitle = LibStub("tekKonfig-Heading").new(frame, "Kennel", "This panel allows you to select which pets Kennel will put out.")


	local enabled = LibStub("tekKonfig-Checkbox").new(frame, nil, "Enabled", "TOPLEFT", subtitle, "BOTTOMLEFT", -2, -GAP)
	local checksound = enabled:GetScript("OnClick")
	enabled:SetScript("OnClick", function(self) checksound(self); KennelDBPC.disabled = not KennelDBPC.disabled end)
	enabled:SetChecked(not KennelDBPC.disabled)

	local mountdismiss = LibStub("tekKonfig-Checkbox").new(frame, nil, "Dismiss when mounted", "TOPLEFT", enabled, "BOTTOMLEFT", 0, -4)
	mountdismiss:SetScript("OnClick", function(self) checksound(self); KennelDBPC.dismissonmount = not KennelDBPC.dismissonmount end)
	mountdismiss:SetChecked(KennelDBPC.dismissonmount)


	local group = LibStub("tekKonfig-Group").new(frame, "Furry bastards", "TOP", mountdismiss, "BOTTOM", 0, -GAP-14)
	group:SetPoint("LEFT", EDGEGAP, 0)
	group:SetPoint("BOTTOMRIGHT", -EDGEGAP, EDGEGAP)

	local scrollbar = LibStub("tekKonfig-Scroll").new(group, 6, 1)

	group:EnableMouseWheel()
	group:SetScript("OnMouseWheel", function(self, val) scrollbar:SetValue(scrollbar:GetValue() - val) end)


	local grouptext = group:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	grouptext:SetHeight(32)
	grouptext:SetPoint("TOPLEFT", group, "TOPLEFT", EDGEGAP, -EDGEGAP)
	grouptext:SetPoint("RIGHT", group, -EDGEGAP-16, 0)
	grouptext:SetNonSpaceWrap(true)
	grouptext:SetJustifyH("LEFT")
	grouptext:SetJustifyV("TOP")
	grouptext:SetText("These pets will be used at random.  Solid blue highlighted pets will be used more often.")


	local function OnClick(self)
		local v = kennel.randomdb[self.id] + 1
		if v == 3 then v = 0 end
		kennel.randomdb[self.id] = v

		self:GetNormalTexture():SetDesaturated(v == 0)
		self:SetChecked(v > 0)
		self:GetCheckedTexture():SetAlpha(v/2)

		kennel.nlow = 0
		for i=1,GetNumCompanions("CRITTER") do
			local _, name, id = GetCompanionInfo("CRITTER", i)
			if db[id] == 1 then kennel.nlow = kennel.nlow +  1 end
		end
	end
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
		if i == 1 then row:SetPoint("TOPLEFT", group, EDGEGAP, -EDGEGAP-ICONSIZE-6)
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

	local offset = 0
	local function Update()
		scrollbar:SetMinMaxValues(0, math.max(0, math.ceil(GetNumCompanions("CRITTER")/NUMCOLS - NUMROWS)))

		for i=1,NUMROWS do
			for j=1,NUMCOLS do
				local butt, buttoffset = rows[i].buttons[j], (i+offset-1)*NUMCOLS + j
				local _, name, id, tex = GetCompanionInfo("CRITTER", buttoffset)
				if name then
					butt.name, butt.id = name, id
					butt:SetNormalTexture(tex)
					butt:GetNormalTexture():SetDesaturated(kennel.randomdb[id] == 0)
					butt:SetChecked(kennel.randomdb[id] > 0)
					butt:GetCheckedTexture():SetAlpha(kennel.randomdb[id]/2)
					butt:Show()
				else
					butt:Hide()
				end
			end
		end
	end

	local f = scrollbar:GetScript("OnValueChanged")
	scrollbar:SetScript("OnValueChanged", function(self, value, ...)
		offset = math.floor(value)
		Update()
		return f(self, value, ...)
	end)

	Update()
	scrollbar:SetValue(0)
	frame:SetScript("OnShow", nil)
end)


InterfaceOptions_AddCategory(frame)

LibStub("tekKonfig-AboutPanel").new("Kennel", "Kennel")
