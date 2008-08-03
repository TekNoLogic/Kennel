
local debugf = tekDebug and tekDebug:GetFrame("Kennel")
local function Debug(...) if debugf then debugf:AddMessage(string.join(", ", ...)) end end


local DELAY = 2

local f = CreateFrame("Frame")
f:SetScript("OnEvent", function(self, event, ...) if self[event] then return self[event](self, event, ...) end end)
f:Hide()


local numpets = 0
local function PutTheCatOut(self, event)
	Debug(event or "nil", HasFullControl() and "In control" or "Not in control", InCombatLockdown() and "In combat" or "Not in combat")

	if InCombatLockdown() then return self:RegisterEvent("PLAYER_REGEN_ENABLED") end
	if not HasFullControl() then return self:RegisterEvent("PLAYER_CONTROL_GAINED") end
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")

	for i=1,GetNumCompanions("CRITTER") do if select(5, GetCompanionInfo("CRITTER", i)) then return end end

	Debug("Queueing pet to be put out")
	self:Show()
end


local ismoving, lx, ly, elapsed = false, 0, 0
f:SetScript("OnShow", function() elapsed = 0 end)
f:SetScript("OnUpdate", function(self, elap)
	local x, y = GetPlayerMapPosition("player")
	if lx == x and ly == y then ismoving = false
	else ismoving, lx, ly = true, x, y end

	elapsed  = elapsed + elap
	if elapsed < DELAY then return end

	if ismoving or IsMounted() or UnitCastingInfo("player") then
		elapsed = 0
		return
	end

	local numpets = GetNumCompanions("CRITTER")
	Debug("Putting out pet", tostring(numpets))
	if numpets > 0 then CallCompanion("CRITTER", math.random(numpets)) end
	self:Hide()
end)


f.PLAYER_REGEN_ENABLED = PutTheCatOut
f.PLAYER_CONTROL_GAINED = PutTheCatOut
f.PLAYER_LOGIN = PutTheCatOut
f.PLAYER_UNGHOST = PutTheCatOut


function f:ZONE_CHANGED_NEW_AREA()
	SetMapToCurrentZone()
	PutTheCatOut(self, "ZONE_CHANGED_NEW_AREA")
end


function f:COMPANION_UPDATE(event, comptype)
	if comptype ~= "CRITTER" then return end
	PutTheCatOut(self, "COMPANION_UPDATE")
end

f:RegisterEvent("COMPANION_UPDATE")
f:RegisterEvent("PLAYER_UNGHOST")
f:RegisterEvent("ZONE_CHANGED_NEW_AREA")

if IsLoggedIn() then PutTheCatOut(f, "PLAYER_LOGIN") else f:RegisterEvent("PLAYER_LOGIN") end
