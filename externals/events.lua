
local myname, ns = ...


local frame = CreateFrame("Frame")


function ns.RegisterEvent(event, func)
	frame:RegisterEvent(event)
	if func then ns[event] = func end
end


function ns.UnregisterEvent(event)
	frame:UnregisterEvent(event)
end


-- Handle special OnLoad code when our addon has loaded, if present
-- If ns.ADDON_LOADED is defined, the ADDON_LOADED event is not unregistered
local function ProcessOnLoad(arg1)
	if not ns.OnLoad then ProcessOnLoad = nil end
	if arg1 == myname and ns.OnLoad then
		ns.OnLoad()
		ns.OnLoad = nil
		ProcessOnLoad = nil
		if not ns.ADDON_LOADED then frame:UnregisterEvent("ADDON_LOADED") end
	end
end


frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, arg1, ...)
	if ProcessOnLoad and event == "ADDON_LOADED" then ProcessOnLoad(arg1) end
	if ns[event] then ns[event](event, arg1, ...) end
end)
