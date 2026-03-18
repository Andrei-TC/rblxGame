local BonusSystem = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Systems = ServerScriptService:WaitForChild("Systems")
local Modules = ServerScriptService:WaitForChild("Modules")

local InventorySystem = require(Systems.Inventory.InventorySystem)
local ItemFactory = require(Systems.Items.ItemFactory)
local ItemSystem = require(Systems.Items.ItemSystem)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SystemMessage = ReplicatedStorage.Remotes:WaitForChild("SystemMessage")

local BonusPools = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("Items"):WaitForChild("BonusPools"))

function BonusSystem:UseChangeBonus(player, itemUID)

	local index, slot, profile = InventorySystem:GetItemByUID(player, itemUID)
	if not index then return end

	local item = slot.Item
	if item.ItemLocked then return end

	item.ItemLocked = true

	local itemData = ItemSystem:GetItemData(item.ItemId)

	-- ======================
	-- numar bonusuri existente
	-- ======================

	local totalBonusCount = #item.Bonuses
	if totalBonusCount == 0 then
		SystemMessage:FireClient(player, "Itemul nu are bonusuri.")
		return false
	end

	local fixed = {}
	local fixedCount = 0

	for _,b in ipairs(item.Bonuses) do
		if b.Fixed then
			table.insert(fixed, b)
			fixedCount += 1
		end
	end

	local randomCount = totalBonusCount - fixedCount

	-- ======================
	-- reroll PM / PC
	-- ======================

	if itemData.HasAverageSkillDamage then

		local pm = ItemFactory:RollAverageDamage()

		local pc = math.floor(-(pm/2))

		if pc > 30 then pc = 30 end
		if pc < -30 then pc = -30 end

		fixed = {
			{
				Id = "AverageDamage",
				Value = pm,
				Fixed = true
			},
			{
				Id = "SkillDamage",
				Value = pc,
				Fixed = true
			}
		}

	end

	-- ======================
	-- reconstruire lista bonusuri
	-- ======================

	item.Bonuses = fixed

	if randomCount > 0 then
		ItemFactory:GenerateBonuses(item, randomCount)
	end

	SystemMessage:FireClient(player, "Bonusurile au fost schimbate!")

	item.ItemLocked = false

	InventorySystem:SendInventoryToClient(player)

	return true
end
function BonusSystem:UseAddBonus(player, itemUID)

	local index, slot, profile = InventorySystem:GetItemByUID(player, itemUID)
	if not index then return false end

	local item = slot.Item
	if not item then return false end

	local itemData = ItemSystem:GetItemData(item.ItemId)
	if not itemData then
		SystemMessage:FireClient(player, "Item invalid.")
		return false
	end

	-- itemele fara BonusPool nu pot primi bonusuri
	if not BonusPools[itemData.Type] then
		SystemMessage:FireClient(player, "Acest item nu poate primi bonusuri.")
		return false
	end

	if item.ItemLocked then
		return false
	end

	local max = item.MaxBonusCount or 4
	local current = item.Bonuses and #item.Bonuses or 0

	if current >= max then
		SystemMessage:FireClient(player, "Itemul are deja numarul maxim de bonusuri.")
		return false
	end

	item.ItemLocked = true

	ItemFactory:GenerateBonuses(item, 1)

	item.ItemLocked = false

	SystemMessage:FireClient(player, "Adaugarea bonusului a reu?it!")

	InventorySystem:SendInventoryToClient(player)

	return true
end

function BonusSystem:UseMarmura(player, itemUID)

	local index, slot, profile = InventorySystem:GetItemByUID(player, itemUID)
	if not index then return false end

	local item = slot.Item
	if item.ItemLocked then return false end

	item.ItemLocked = true

	local currentBonusCount = #item.Bonuses

	if currentBonusCount ~= 4 then
		item.ItemLocked = false
		SystemMessage:FireClient(player, "Itemul trebuie sa aiba 4 bonusuri.")
		return false
	end

	if item.MaxBonusCount >= 5 then
		item.ItemLocked = false
		SystemMessage:FireClient(player, "Itemul are deja 5 bonusuri.")
		return false
	end

	if math.random(1,100) <= 33 then

		item.MaxBonusCount = 5

		-- adauga automat bonusul 5
		ItemFactory:GenerateBonuses(item, 1)

		SystemMessage:FireClient(player, "Marmura a reusit! Bonusul 5 a fost adaugat.")

	else

		SystemMessage:FireClient(player, "Marmura a esuat!")

	end

	item.ItemLocked = false

	InventorySystem:SendInventoryToClient(player)

	return true
end

return BonusSystem