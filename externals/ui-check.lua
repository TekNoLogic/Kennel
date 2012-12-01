
local myname, ns = ...


local function CheckSound(self)
	local sound = self:GetChecked() and 'On' or 'Off'
	PlaySound('igMainMenuOptionCheckBox'.. sound)
end


-- Creates a checkbox.
-- All args optional but parent is highly recommended
function ns.NewCheckBox(parent, size, ...)
	local check = CreateFrame("CheckButton", nil, parent)
	check:SetWidth(size or 26)
	check:SetHeight(size or 26)
	if select(1, ...) then check:SetPoint(...) end

	check:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
	check:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
	check:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight")
	check:SetDisabledCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
	check:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")

	check:SetScript("PreClick", CheckSound)

	return check
end


-- Creates a label next to a checkbox
function ns.NewCheckLabel(check, text)
	local fs = check:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	fs:SetPoint("LEFT", check, "RIGHT", 0, 1)
	fs:SetText(text)
end
