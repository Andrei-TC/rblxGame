local EquipmentSystem = {}
local ServerScriptService = game:GetService("ServerScriptService")
local Systems = ServerScriptService:WaitForChild("Systems")
local PlayerDataSystem = require(Systems.Core.PlayerDataSystem)
local ItemSystem = require(Systems.Items.ItemSystem)
local StatSystem = require(Systems.Progression.StatSystem)
local InventorySystem = require(Systems.Inventory.InventorySystem)
local VisualEquipmentSystem = require(Systems.Visual.VisualEquipmentSystem)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local UpdateInventoryUI = Remotes:WaitForChild("UpdateInventoryUI")

local function getTotalSlots(profile)
	return profile.Inventory.SizeX * profile.Inventory.SizeY
end

function EquipmentSystem:EquipItem(player, inventorySlotIndex)
	
	local profile = PlayerDataSystem:GetProfile(player)
	if not profile then return end

	local slotData = profile.Inventory.Slots[inventorySlotIndex]

	if not slotData or not slotData.IsRoot then
		print("No root item in slot")
		return
	end

	local itemInstance = slotData.Item

	if not itemInstance then
		warn("No root item in slot")
		return
	end
	local itemData = ItemSystem:GetItemData(itemInstance.ItemId)
	if not itemData then
		print("Invalid item data")
		return
	end

	local equipSlotName = itemData.EquipSlot
	if equipSlotName == "Ring" then

		if not profile.Equipment["Ring1"] then
			equipSlotName = "Ring1"
		elseif not profile.Equipment["Ring2"] then
			equipSlotName = "Ring2"
		else
			--print("Both ring slots occupied")
			return
		end
	end
	if not equipSlotName then
		--print("Item cannot be equipped")
		return
	end
	
	-- ?? VALIDARE CRITICA: verificam daca slotul exista în Equipment
	if profile.Equipment[equipSlotName] == nil and profile.Equipment[equipSlotName] ~= false then
		-- daca cheia nu exista deloc
		if profile.Equipment[equipSlotName] == nil then
			-- verificam daca slotul chiar exista în structura default
			if not profile.Equipment[equipSlotName] and not table.find({
				"Weapon","Helmet","Armor","Shield",
				"Bracelet","Earrings","Necklace",
				"Shoes","Ring1","Ring2"
				}, equipSlotName) then

				warn("Invalid equip slot attempt:", equipSlotName)
				return
			end
		end
	end

	-- Daca exista deja item în slot ? swap în inventory
	local alreadyEquipped = profile.Equipment[equipSlotName]

	if alreadyEquipped then

		-- cauta pozi?ie valida 2D pentru itemul echipat
		local freeIndex = InventorySystem:FindFreeSlotForItem(profile, alreadyEquipped)

		if not freeIndex then
			--print("Inventory full, cannot swap equip")
			return
		end

		InventorySystem:PlaceItemAt(profile, alreadyEquipped, freeIndex, 1)
	end

	-- ?? ?tergem complet itemul din inventory (2D corect)
	InventorySystem:RemoveItem(profile, inventorySlotIndex)

	-- ?? Punem în equipment
	profile.Equipment[equipSlotName] = itemInstance
	-- Visualizeaza itemul nou echipat
	

	VisualEquipmentSystem:Update(player,profile)

	--print("Equipped:", itemInstance.ItemId, "->", equipSlotName)

	InventorySystem:SendInventoryToClient(player)
	StatSystem:RecalculateStats(player)
end

function EquipmentSystem:UnequipToSpecificSlot(player, equipSlotName, targetIndex)

	local profile = PlayerDataSystem:GetProfile(player)
	if not profile then return end

	local equipped = profile.Equipment[equipSlotName]
	if not equipped then return end

	local sizeX = profile.Inventory.SizeX
	local sizeY = profile.Inventory.SizeY
	local totalSlots = sizeX * sizeY

	if targetIndex < 1 or targetIndex > totalSlots then return end

	local row = math.ceil(targetIndex / sizeX)
	if row + 1 > sizeY then
		return
	end

	local secondIndex = targetIndex + sizeX

	if profile.Inventory.Slots[targetIndex] ~= nil then return end
	if profile.Inventory.Slots[secondIndex] ~= nil then return end

	profile.Inventory.Slots[targetIndex] = {
		Item = equipped,
		IsRoot = true
	}

	profile.Inventory.Slots[secondIndex] = {
		Item = equipped,
		IsRoot = false
	}

	profile.Equipment[equipSlotName] = nil
	VisualEquipmentSystem:Update(player,profile)

	InventorySystem:SendInventoryToClient(player)
	StatSystem:RecalculateStats(player)
end

function EquipmentSystem:UnequipItem(player, equipSlotName)

	local profile = PlayerDataSystem:GetProfile(player)
	if not profile then return end

	local equipped = profile.Equipment[equipSlotName]
	if not equipped then
		--print("Nothing equipped in", equipSlotName)
		return
	end

	local itemData = ItemSystem:GetItemData(equipped.ItemId)
	if not itemData then
		warn("Invalid item data on unequip")
		return
	end

	local totalSlots = getTotalSlots(profile)

	-- ?? Cautam pozi?ie valida exact ca AddItem
	for i = 1, totalSlots do
		if InventorySystem:CanPlaceItem(profile, i, itemData.Width, itemData.Height) then

			-- ?? plasam root
			profile.Inventory.Slots[i] = {
				IsRoot = true,
				Item = equipped
			}

			-- ?? plasam children corect 2D
			for y = 0, itemData.Height - 1 do
				for x = 0, itemData.Width - 1 do
					if not (x == 0 and y == 0) then
						local childIndex = i + x + (y * profile.Inventory.SizeX)

						profile.Inventory.Slots[childIndex] = {
							IsRoot = false,
							Item = equipped
						}
					end
				end
			end

			profile.Equipment[equipSlotName] = nil
			VisualEquipmentSystem:Update(player,profile)
			--print("Unequipped:", equipped.ItemId, "to slot", i)

			InventorySystem:SendInventoryToClient(player)
			StatSystem:RecalculateStats(player)
			return
		end
	end

	--print("No space in inventory to unequip item")
end

function EquipmentSystem:ApplyEquipment(player)

	local profile = PlayerDataSystem:GetProfile(player)
	if not profile then return end

	local character = player.Character
	if not character then return end

	-- refacem vizual echipamentul
	VisualEquipmentSystem:Update(player, profile)

	-- recalculam stats
	StatSystem:RecalculateStats(player)

end

return EquipmentSystem