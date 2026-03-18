local VisualEquipmentSystem = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local ServerScriptService = game:GetService("ServerScriptService")

	local Systems = ServerScriptService:WaitForChild("Systems")
	local Modules = ServerScriptService:WaitForChild("Modules")

local Models = ReplicatedStorage:WaitForChild("EquipmentModels")

local equippedModels = {}

--==============================
-- CLEAR
--==============================

function VisualEquipmentSystem:Clear(player)

	local character = player.Character
	if not character then return end
	character:SetAttribute("WeaponType","Fists")

	if equippedModels[player] then
		for _,model in pairs(equippedModels[player]) do
			model:Destroy()
		end
	end

	equippedModels[player] = {}

end

--==============================
-- ATTACH WEAPON
--==============================

function VisualEquipmentSystem:AttachWeapon(player,itemData)

	local character = player.Character
	if not character then return end
	
	character:SetAttribute("WeaponType","Sword")

	local hand =
		character:FindFirstChild("RightHand") or
		character:FindFirstChild("Right Arm")

	if not hand then return end

	local model = Models.Weapons:FindFirstChild(itemData.Model)
	if not model then return end

	if not equippedModels[player] then
		equippedModels[player] = {}
	end

	if equippedModels[player].Weapon then
		equippedModels[player].Weapon:Destroy()
	end

	local clone = model:Clone()
	clone.Parent = character

	local handle = clone:FindFirstChild("Handle")
	if not handle then return end

	local handAttachment = hand:FindFirstChild("WeaponAttachment")
	local weaponAttachment = handle:FindFirstChild("WeaponAttachment")

	if not handAttachment or not weaponAttachment then
		warn("Weapon attachment missing")
		return
	end

	local motor = Instance.new("Motor6D")

	motor.Name = "WeaponMotor"
	motor.Part0 = hand
	motor.Part1 = handle

	motor.C0 = handAttachment.CFrame
	motor.C1 = weaponAttachment.CFrame

	motor.Parent = hand

	handle.Anchored = false
	handle.CanCollide = false
	handle.Massless = true

	equippedModels[player].Weapon = clone

end

--==============================
-- APPLY ARMOR
--==============================

function VisualEquipmentSystem:ApplyArmor(player,itemData)

	local character = player.Character
	if not character then return end

	local model = Models.Armors:FindFirstChild(itemData.Model)
	if not model then return end

	local shirt = character:FindFirstChildOfClass("Shirt")
	local pants = character:FindFirstChildOfClass("Pants")

	if shirt then shirt:Destroy() end
	if pants then pants:Destroy() end

	local newShirt = model:FindFirstChildOfClass("Shirt")
	local newPants = model:FindFirstChildOfClass("Pants")

	if newShirt then
		newShirt:Clone().Parent = character
	end

	if newPants then
		newPants:Clone().Parent = character
	end

end

--==============================
-- UPDATE
--==============================

function VisualEquipmentSystem:ApplyDefaultClothes(player)

	local character = player.Character
	if not character then return end

	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	
	local defaultFolder = ReplicatedStorage:WaitForChild("DefaultClothes"):WaitForChild("Default")

	local existingShirt = character:FindFirstChildOfClass("Shirt")
	local existingPants = character:FindFirstChildOfClass("Pants")

	if existingShirt then existingShirt:Destroy() end
	if existingPants then existingPants:Destroy() end

	local shirt = defaultFolder:FindFirstChildOfClass("Shirt")
	local pants = defaultFolder:FindFirstChildOfClass("Pants")

	if shirt then
		shirt:Clone().Parent = character
	end

	if pants then
		pants:Clone().Parent = character
	end

end

function VisualEquipmentSystem:Update(player,profile)

	self:Clear(player)

	local ItemSystem = require(Systems.Items.ItemSystem)

	if profile.Equipment.Weapon then

		local item = profile.Equipment.Weapon
		local itemData = ItemSystem:GetItemData(item.ItemId)

		if itemData and itemData.Model then
			self:AttachWeapon(player,itemData)
		end

	end

	if profile.Equipment.Armor then

		local item = profile.Equipment.Armor
		local itemData = ItemSystem:GetItemData(item.ItemId)

		if itemData and itemData.Model then
			self:ApplyArmor(player,itemData)
		end

	else

		self:ApplyDefaultClothes(player)

	end

end

return VisualEquipmentSystem