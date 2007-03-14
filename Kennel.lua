
------------------------------
--      Are you local?      --
------------------------------

local pt = KennelMicroPeriodicTable
KennelMicroPeriodicTable = nil
local bankopen, swapped = false, false
local pets = {
	normal = {player = {bag = {}, slot = {}, num = 0}, bank = {bag = {}, slot = {}, num = 0}},
	holiday = {player = {bag = {}, slot = {}, num = 0}, bank = {bag = {}, slot = {}, num = 0}},
}


Kennel = DongleStub("Dongle-Beta1"):New("Kennel")


function Kennel:Enable()
	self:RegisterEvent("BANKFRAME_OPENED")
	self:RegisterEvent("BANKFRAME_CLOSED")
end


------------------------------
--			Event handlers			--
------------------------------

function Kennel:BANKFRAME_CLOSED()
	if bankopen and swapped and FuBar_CorkFu then FuBar_CorkFu:GetModule("Minipet"):ActivatePet() end
	bankopen = nil
end


function Kennel:BANKFRAME_OPENED()
	bankopen = true
	swapped = false

	pets.normal.player.num = 0
	pets.normal.bank.num = 0
	pets.holiday.player.num = 0
	pets.holiday.bank.num = 0

	for bag=-1,11 do
		local bagset = (bag <= 4) and (bag >= 0) and "player" or "bank"
		for slot=1,GetContainerNumSlots(bag) do
			local itemLink = GetContainerItemLink(bag, slot)
			if (itemLink and pt(itemLink, "Minipet")) then
				local n = pets.normal[bagset].num + 1
				pets.normal[bagset].num = n
				pets.normal[bagset].bag[n] = bag
				pets.normal[bagset].slot[n] = slot
			elseif (itemLink and pt(itemLink, "Minipet - Holiday")) then
				local n = pets.holiday[bagset].num + 1
				pets.holiday[bagset].num = n
				pets.holiday[bagset].bag[n] = bag
				pets.holiday[bagset].slot[n] = slot
			end
		end
	end

	if pets.normal.player.num > pets.normal.bank.num then
		pets.normal.player, pets.normal.bank = pets.normal.bank, pets.normal.player
	end
	if pets.holiday.player.num > pets.holiday.bank.num then
		pets.holiday.player, pets.holiday.bank = pets.holiday.bank, pets.holiday.player
	end
	self:DoSwaps("normal")
	self:DoSwaps("holiday")

	if (pets.normal.player.num > 0 and pets.normal.bank.num > 0)
		or (pets.holiday.player.num > 0 and pets.holiday.bank.num > 0) then
		swapped = true
	end
end


function Kennel:DoSwaps(set)
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

