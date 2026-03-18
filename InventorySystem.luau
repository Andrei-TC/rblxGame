local InventorySystem = {}
local ServerScriptService = game:GetService("ServerScriptService")
local HttpService = game:GetService("HttpService")
local PlayerDataSystem = require(ServerScriptService.Systems.Core.PlayerDataSystem)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local UpdateInventoryUI = Remotes:WaitForChild("UpdateInventoryUI")
local ItemSystem = require(ServerScriptService.Systems.Items.ItemSystem)
local ItemFactory = require(ServerScriptService.Systems.Items.ItemFactory)

local function getTotalSlots(profile)
	return profile.Inventory.SizeX * profile.Inventory.SizeY
end
function InventorySystem:SendInventoryToClient(player)

	local profile = PlayerDataSystem:GetProfile(player)
	if not profile then return end
	local cleanSlots = {}
	local totalSlots = profile.Inventory.SizeX * profile.Inventory.SizeY

	for i = 1, totalSlots do

		local slotData = profile.Inventory.Slots[i]

		if slotData and slotData.IsRoot then

			local itemInstance = slotData.Item
			local itemData = require(ServerScriptService.Systems.Items.ItemSystem):GetItemData(itemInstance.ItemId)

			if itemData then
				table.insert(cleanSlots, {
					Index = i,
					IsRoot = true,
					Item = {
						ItemId = itemInstance.ItemId,
						UID = itemInstance.UID,
						Width = itemData.Width or 1,
						Height = itemData.Height or 1,
						EquipSlot = itemData.EquipSlot,
						Amount = slotData.Amount or 1,
						UseAction = itemData.UseAction,
						Bonuses = itemInstance.Bonuses,
						Plus = itemInstance.Plus,
						AverageDamage = itemInstance.AverageDamage,
						SkillDamage = itemInstance.SkillDamage,
						Icon = itemData.Icon
					}
				})
			end
		end
	end

	local cleanEquipment = {}

	for slotName, item in pairs(profile.Equipment) do
		if item then

			local itemData = require(ServerScriptService.Systems.Items.ItemSystem):GetItemData(item.ItemId)

			cleanEquipment[slotName] = {
				UID = item.UID,
				ItemId = item.ItemId,
				Plus = item.Plus,
				Bonuses = item.Bonuses,
				AverageDamage = item.AverageDamage,
				SkillDamage = item.SkillDamage,
				Width = itemData and itemData.Width or 1,
				Height = itemData and itemData.Height or 1,
				Icon = itemData.Icon
			}
		else
			cleanEquipment[slotName] = false
		end
	end

	UpdateInventoryUI:FireClient(player, {
		Slots = cleanSlots,
		Equipment = cleanEquipment
	})
end

function InventorySystem:InitializeInventory(player)
	local profile = PlayerDataSystem:GetProfile(player)
	if not profile then return end
	local totalSlots = profile.Inventory.SizeX * profile.Inventory.SizeY

	for i = 1, totalSlots do
		profile.Inventory.Slots[i] = nil
	end
end



local function canPlaceItem(profile, startIndex, width, height, ignoreItem)

	local columns = profile.Inventory.SizeX
	local rows = profile.Inventory.SizeY

	local startRow = math.ceil(startIndex / columns)
	local startCol = ((startIndex - 1) % columns) + 1

	if startCol + width - 1 > columns then
		return false
	end

	if startRow + height - 1 > rows then
		return false
	end

	for y = 0, height - 1 do
		for x = 0, width - 1 do

			local checkIndex = startIndex + x + (y * columns)
			local slot = profile.Inventory.Slots[checkIndex]

			if slot ~= nil then
				if not ignoreItem or slot.Item ~= ignoreItem then
					return false
				end
			end
		end
	end

	return true
end

function InventorySystem:CanPlaceItem(profile, startIndex, width, height, ignoreItem)
	return canPlaceItem(profile, startIndex, width, height, ignoreItem)
end

function InventorySystem:AddItem(player, itemId)

	local profile = PlayerDataSystem:GetProfile(player)
	if not profile then return false end

	local itemData = ItemSystem:GetItemData(itemId)
	if not itemData then
		warn("Invalid itemId:", itemId)
		return false
	end

	local totalSlots = profile.Inventory.SizeX * profile.Inventory.SizeY
	
	if itemData.Stackable then
		for i = 1, totalSlots do
			local slot = profile.Inventory.Slots[i]
			if slot and slot.IsRoot and slot.Item.ItemId == itemId then
				local currentAmount = slot.Amount or 1
				if currentAmount < itemData.MaxStack then
					slot.Amount = currentAmount + 1
					self:SendInventoryToClient(player)
					return
				end
			end
		end
	end
	-- ?? cautam pozi?ie valida
	for i = 1, totalSlots do
		if canPlaceItem(profile, i, itemData.Width, itemData.Height) then

			-- plasam root
			local newItemInstance = ItemFactory:CreateItem(itemId)

			profile.Inventory.Slots[i] = {
				IsRoot = true,
				Item = newItemInstance,
				Amount = itemData.Stackable and 1 or nil
			}

			-- plasam children
			for y = 0, itemData.Height - 1 do
				for x = 0, itemData.Width - 1 do
					if not (x == 0 and y == 0) then
						local childIndex = i + x + (y * profile.Inventory.SizeX)
						profile.Inventory.Slots[childIndex] = {
							IsRoot = false,
							Item = profile.Inventory.Slots[i].Item
						}
					end
				end
			end


			self:SendInventoryToClient(player)
			return true
		end
	end

	-- ? daca ajungem aici ? NU exista loc
	warn("Inventory full or no space for item:", itemId)
	return false
end

function InventorySystem:MoveItem(player, fromIndex, toIndex)

	local profile = PlayerDataSystem:GetProfile(player)
	if not profile then return end

	local slotData = profile.Inventory.Slots[fromIndex]
	if not slotData or not slotData.IsRoot then return end
	local originalAmount = slotData.Amount
	
	local itemInstance = slotData.Item
	local itemData = ItemSystem:GetItemData(itemInstance.ItemId)

	local width = itemData.Width
	local height = itemData.Height
	local sizeX = profile.Inventory.SizeX

	-- ?? VALIDAM ÎNAINTE SA ?TERGEM
	if not canPlaceItem(profile, toIndex, width, height, itemInstance) then
		self:SendInventoryToClient(player)
		return
	end

	-- ?? ?TERGEM VECHILE SLOTURI
	for y = 0, height - 1 do
		for x = 0, width - 1 do
			local index = fromIndex + x + (y * sizeX)
			profile.Inventory.Slots[index] = nil
		end
	end

	-- ?? PLASAM NOUA POZI?IE
	for y = 0, height - 1 do
		for x = 0, width - 1 do
			local index = toIndex + x + (y * sizeX)
			profile.Inventory.Slots[index] = {
				Item = itemInstance,
				IsRoot = (x == 0 and y == 0),
				Amount = (x == 0 and y == 0) and originalAmount or nil
			}
		end
	end

	self:SendInventoryToClient(player)
end


function InventorySystem:PrintInventory(player)
	local profile = PlayerDataSystem:GetProfile(player)
	if not profile then return end

	local totalSlots = profile.Inventory.SizeX * profile.Inventory.SizeY

	--print("=== INVENTORY ===")
	--for i = 1, totalSlots do
		--local slotData = profile.Inventory.Slots[i]

		--if slotData and slotData.Item then
			--print("SERVER SLOT", i, slotData.Item.ItemId, "Root:", slotData.IsRoot)
		--end
	--end
end

function InventorySystem:FindFreeSlotForItem(profile, itemInstance)

	local itemData = ItemSystem:GetItemData(itemInstance.ItemId)

	local total = profile.Inventory.SizeX * profile.Inventory.SizeY

	for i = 1, total do
		if canPlaceItem(profile, i, itemData.Width, itemData.Height) then
			return i
		end
	end

	return nil
end
function InventorySystem:PlaceItemAt(profile, itemInstance, toIndex, amount)

	local itemData = ItemSystem:GetItemData(itemInstance.ItemId)

	for y = 0, itemData.Height - 1 do
		for x = 0, itemData.Width - 1 do
			local index = toIndex + x + (y * profile.Inventory.SizeX)
			profile.Inventory.Slots[index] = {
				Item = itemInstance,
				IsRoot = (x == 0 and y == 0),
				Amount = (x == 0 and y == 0) and amount or nil
			}
		end
	end
end
function InventorySystem:RemoveItem(profile, fromIndex)
	local slotData = profile.Inventory.Slots[fromIndex]
	if not slotData or not slotData.IsRoot then return end

	local itemInstance = slotData.Item
	local itemData = ItemSystem:GetItemData(itemInstance.ItemId)

	for y = 0, itemData.Height - 1 do
		for x = 0, itemData.Width - 1 do
			local index = fromIndex + x + (y * profile.Inventory.SizeX)
			profile.Inventory.Slots[index] = nil
		end
	end
end

function InventorySystem:FindItemByUID(profile, uid)

	local totalSlots = profile.Inventory.SizeX * profile.Inventory.SizeY

	for i = 1, totalSlots do

		local slot = profile.Inventory.Slots[i]

		if slot and slot.IsRoot and slot.Item then
			if slot.Item.UID == uid then
				return i, slot
			end
		end

	end

	return nil
end

function InventorySystem:GetItemByUID(player, uid)

	local profile = PlayerDataSystem:GetProfile(player)
	if not profile then return nil end

	local index, slot = self:FindItemByUID(profile, uid)

	if not index then
		return nil
	end

	return index, slot, profile
end

return InventorySystem