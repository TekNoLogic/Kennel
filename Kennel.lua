
------------------------------
--      Are you local?      --
------------------------------

local pt = PeriodicTableMicro
PeriodicTableMicro = nil
local bankopen, swapped = false, false
local pets = {
	normal = {player = {bag = {}, slot = {}, num = 0}, bank = {bag = {}, slot = {}, num = 0}},
	holiday = {player = {bag = {}, slot = {}, num = 0}, bank = {bag = {}, slot = {}, num = 0}},
}


local function DoSwaps(set)
	local l, g = pets[set].player, pets[set].bank
	if l.num == 0 then return end
	for i=1,l.num do
		local r = math.random(g.num + 1 - i)

		PickupContainerItem(l.bag[i], l.slot[i])
		PickupContainerItem(g.bag[r], g.slot[r])
		table.remove(g.bag, r)
		table.remove(g.slot, r)
	end
end


------------------------------
--			Event handlers			--
------------------------------

local f = CreateFrame("frame")
f:RegisterEvent("BANKFRAME_OPENED")
f:RegisterEvent("BANKFRAME_CLOSED")
f:SetScript("OnEvent", function(self, event, ...)
	if event == "BANKFRAME_CLOSED" then
		if bankopen and swapped and FuBar_CorkFu then FuBar_CorkFu:GetModule("Minipet"):ActivatePet() end
		bankopen = nil
	else
		bankopen, swapped = true, false
		pets.normal.player.num, pets.normal.bank.num, pets.holiday.player.num, pets.holiday.bank.num = 0, 0, 0, 0

		for bag=-1,11 do
			local bagset = (bag <= 4) and (bag >= 0) and "player" or "bank"
			for slot=1,GetContainerNumSlots(bag) do
				local itemLink = GetContainerItemLink(bag, slot)
				if (itemLink and pt(itemLink, "Minipet")) then
					local n = pets.normal[bagset].num + 1
					pets.normal[bagset].num, pets.normal[bagset].bag[n], pets.normal[bagset].slot[n] = n, bag, slot
				elseif (itemLink and pt(itemLink, "Minipet - Holiday")) then
					local n = pets.holiday[bagset].num + 1
					pets.holiday[bagset].num, pets.holiday[bagset].bag[n], pets.holiday[bagset].slot[n] = n, bag, slot
				end
			end
		end

		if pets.normal.player.num > pets.normal.bank.num then pets.normal.player, pets.normal.bank = pets.normal.bank, pets.normal.player end
		if pets.holiday.player.num > pets.holiday.bank.num then pets.holiday.player, pets.holiday.bank = pets.holiday.bank, pets.holiday.player end
		DoSwaps("normal")
		DoSwaps("holiday")

		if (pets.normal.player.num > 0 and pets.normal.bank.num > 0) or (pets.holiday.player.num > 0 and pets.holiday.bank.num > 0) then swapped = true end
	end
end)
