local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local InventoryAction = Remotes:WaitForChild("InventoryAction")
local ServerScriptService = game:GetService("ServerScriptService")
local Systems = ServerScriptService:WaitForChild("Systems")
local InventorySystem = require(Systems.Inventory.InventorySystem)
local EquipmentSystem = require(Systems.Character.EquipmentSystem)
local BonusSystem = require(Systems.Items.BonusSystem)
local ItemSystem = require(Systems.Items.ItemSystem)
local PlayerDataSystem = require(Systems.Core.PlayerDataSystem)

InventoryAction.OnServerEvent:Connect(function(player, actionType, value1, value2)

	-- ?? Validare tip action
	if type(actionType) ~= "string" then
		warn("Invalid action type")
		return
	end

	if actionType == "Equip" then

		if type(value1) ~= "number" then
			warn("Invalid equip slot index")
			return
		end

		EquipmentSystem:EquipItem(player, value1)

	elseif actionType == "Unequip" then

		if type(value1) ~= "string" then
			warn("Invalid unequip slot name")
			return
		end

		EquipmentSystem:UnequipItem(player, value1)

	elseif actionType == "Move" then

		if typeof(value1) ~= "number" or typeof(value2) ~= "number" then
			warn("Invalid swap values TYPE")
			return
		end
		print("ABOUT TO CALL MOVEITEM")
		InventorySystem:MoveItem(player, value1, value2)
	elseif actionType == "UnequipToSlot" then

		if type(value1) ~= "string" or type(value2) ~= "number" then
			return
		end
		
		EquipmentSystem:UnequipToSpecificSlot(player, value1, value2)
	
	elseif actionType == "UseChangeBonus" then

		if type(value1) ~= "string" then
			return
		end

		BonusSystem:UseChangeBonus(player, value1)

	elseif actionType == "UseAddBonus" then

		if type(value1) ~= "string" then
			return
		end

		BonusSystem:UseAddBonus(player, value1)

	elseif actionType == "UseMarmura" then

		if type(value1) ~= "string" then
			return
		end

		BonusSystem:UseMarmura(player, value1)
		
	elseif actionType == "UseItem" then

		if type(value1) ~= "string" then return end
		if type(value2) ~= "string" then return end

		local scrollUID = value1
		local targetUID = value2

		local index, slot = InventorySystem:GetItemByUID(player, scrollUID)

		if not index then return end

		local itemData = ItemSystem:GetItemData(slot.Item.ItemId)

		if not itemData then return end

		local success = false

		if itemData.UseAction == "ChangeBonus" then
			success = BonusSystem:UseChangeBonus(player, targetUID)

		elseif itemData.UseAction == "AddBonus" then
			success = BonusSystem:UseAddBonus(player, targetUID)

		elseif itemData.UseAction == "Marmura" then
			success = BonusSystem:UseMarmura(player, targetUID)

		end
		
		if success then
			slot.Amount -= 1

			local profile = PlayerDataSystem:GetProfile(player)

			if slot.Amount <= 0 then
				InventorySystem:RemoveItem(profile, index)
			end

			InventorySystem:SendInventoryToClient(player)
		end
		
	end
end)