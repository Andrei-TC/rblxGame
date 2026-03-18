local ItemFactory = {}

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerScriptService = game:GetService("ServerScriptService")

local Systems = ServerScriptService:WaitForChild("Systems")
local Modules = ServerScriptService:WaitForChild("Modules")

local BonusRegistry = require(Modules.BonusRegistry)
local BonusPools = require(ReplicatedStorage.Config.Items.BonusPools)
local ItemSystem = require(Systems.Items.ItemSystem)

--============================
-- BONUS VALIDATION
--============================

for poolName,pool in pairs(BonusPools) do
	for _,bonus in ipairs(pool) do
		if not BonusRegistry[bonus.Id] then
			warn("Bonus missing from registry:", bonus.Id, "in pool:", poolName)
		end
	end
end

local BONUS_DROP_CHANCE = 1
local MIN_DROP_BONUSES = 1
local MAX_DROP_BONUSES = 2

-- cache itemData
local ItemDataCache = {}

local function getItemData(itemId)

	local cached = ItemDataCache[itemId]
	if cached then
		return cached
	end

	local data = ItemSystem:GetItemData(itemId)
	ItemDataCache[itemId] = data

	return data
end

-- =============================
-- CREATE BASE ITEM
-- =============================

function ItemFactory:CreateItem(itemId)
	
	local itemData = getItemData(itemId)
	if not itemData then
		warn("Invalid itemId:", itemId)
		return nil
	end

	local itemInstance = {

		UID = HttpService:GenerateGUID(false),

		ItemId = itemId,

		Plus = 0,

		MaxBonusCount = 4,

		Bonuses = {},

		Sockets = {nil,nil,nil},

		AverageDamage = nil,
		SkillDamage = nil,

		ItemLocked = false
	}

	if itemData.HasAverageSkillDamage then

		local pm = self:RollAverageDamage()

		local pc = math.floor(-(pm/2))

		if pc > 30 then pc = 30 end
		if pc < -30 then pc = -30 end

		if pm == 0 then
			pm = (math.random(1,2) == 1) and 1 or -1
		end

		if pc == 0 then
			pc = (math.random(1,2) == 1) and 1 or -1
		end

		itemInstance.Bonuses[1] = {
			Id = "AverageDamage",
			Value = pm,
			Fixed = true
		}

		itemInstance.Bonuses[2] = {
			Id = "SkillDamage",
			Value = pc,
			Fixed = true
		}

	end

	return itemInstance

end

-- =============================
-- CREATE DROP ITEM
-- =============================

function ItemFactory:CreateDropItem(itemId)

	local itemInstance = self:CreateItem(itemId)
	if not itemInstance then return nil end

	if math.random(1,100) <= BONUS_DROP_CHANCE then

		local bonusCount = math.random(MIN_DROP_BONUSES, MAX_DROP_BONUSES)

		self:GenerateBonuses(itemInstance, bonusCount)

	end

	return itemInstance

end

-- =============================
-- GENERATE BONUSES
-- =============================

function ItemFactory:GenerateBonuses(itemInstance, amount)

	local itemData = getItemData(itemInstance.ItemId)
	if not itemData then return end

	local pool = BonusPools[itemData.Type]
	if not pool then return end

	local max = itemInstance.MaxBonusCount or 4
	local current = #itemInstance.Bonuses

	local freeSlots = max - current
	if freeSlots <= 0 then return end

	amount = math.min(amount, freeSlots)

	-- set pentru bonusuri existente
	local existing = {}

	for _,b in ipairs(itemInstance.Bonuses) do
		existing[b.Id] = true
	end

	-- lista bonusuri disponibile
	local available = {}

	for _,bonus in ipairs(pool) do

		-- validare registry
		if not BonusRegistry[bonus.Id] then
			warn("Bonus not registered:", bonus.Id)
			continue
		end

		if not existing[bonus.Id] then
			available[#available+1] = bonus
		end

	end
	if #available == 0 then return end

	for i = 1, amount do

		if #available == 0 then break end

		local index = math.random(#available)
		local bonus = available[index]

		local value = bonus.Values[math.random(#bonus.Values)]

		itemInstance.Bonuses[#itemInstance.Bonuses+1] = {
			Id = bonus.Id,
			Value = value
		}

		available[index] = available[#available]
		available[#available] = nil

	end

end

-- =============================
-- ROLL PM
-- =============================

function ItemFactory:RollAverageDamage()

	local sign = (math.random() < 0.5) and -1 or 1

	local value = math.random(1,60)

	value = math.floor(value * math.random())

	if value < 1 then
		value = 1
	end

	return value * sign

end

-- =============================
-- CLONE ITEM
-- =============================

function ItemFactory:CloneItem(itemInstance)

	local clone = {}

	for k,v in pairs(itemInstance) do

		if type(v) == "table" then
			clone[k] = table.clone(v)
		else
			clone[k] = v
		end

	end

	clone.UID = HttpService:GenerateGUID(false)

	return clone

end

return ItemFactory