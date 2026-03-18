local ItemSystem = {}

ItemSystem.ItemData = {

	-- =========================
	-- WEAPONS
	-- =========================

	Sword = {
		Name = "Sword",
		Icon = "rbxassetid://77495853558428",
		Model = "Sword_01",
		Type = "Weapon",
		EquipSlot = "Weapon",
		AttackMin = 14,
		AttackMax = 18,
		Width = 1,
		Height = 2
	},

	PoisonSword = {
		Type = "Weapon",
		EquipSlot = "Weapon",
		AttackMin = 30,
		AttackMax = 44,
		LevelRequirement = 30,
		Width = 1,
		Height = 2,
		HasAverageSkillDamage = true
	},

	-- =========================
	-- ARMOR
	-- =========================

	LeatherArmor = {
		Type = "Armor",
		EquipSlot = "Armor",
		Defense = 15,
		Width = 1,
		Height = 2
	},

	arm = {
		Name = "Tiger Armor",
		Icon = "",
		Model = "Armor_01",
		Type = "Armor",
		EquipSlot = "Armor",
		Defense = 35,
		Width = 1,
		Height = 2
	},

	-- =========================
	-- HELMETS
	-- =========================

	LeatherHelmet = {
		Type = "Helmet",
		EquipSlot = "Helmet",
		Defense = 8,
		Width = 1,
		Height = 1
	},

	helm = {
		Type = "Helmet",
		EquipSlot = "Helmet",
		Defense = 20,
		Width = 1, 
		Height = 1
	},

	-- =========================
	-- SHIELDS
	-- =========================

	shield = {
		Type = "Shield",
		EquipSlot = "Shield",
		Defense = 12,
		Width = 1,
		Height = 1
	},

	TowerShield = {
		Type = "Shield",
		EquipSlot = "Shield",
		Defense = 30,
		Width = 1,
		Height = 1
	},

	-- =========================
	-- BOOTS
	-- =========================

	LeatherBoots = {
		Type = "Shoes",
		EquipSlot = "Shoes",
		Defense = 6,
		Width = 1,
		Height = 1
	},

	ppuci = {
		Type = "Shoes",
		EquipSlot = "Shoes",
		Defense = 10,
		MoveSpeed = 5,
		Width = 1,
		Height = 1
	},

	-- =========================
	-- ACCESSORIES
	-- =========================

	dmgring = {
		Type = "Ring",
		EquipSlot = "Ring", -- sau Ring2 (server decide)
		BonusHP = 50,
		Width = 1,
		Height = 1
	},

	expring = {
		Type = "Ring",
		EquipSlot = "Ring",
		BonusAttack = 5,
		Width = 1,
		Height = 1
	},

	coli = {
		Type = "Necklace",
		EquipSlot = "Necklace",
		BonusMana = 40,
		Width = 1,
		Height = 1
	},

	brt = {
		Type = "Bracelet",
		EquipSlot = "Bracelet",
		BonusAttack = 8,
		Width = 1,
		Height = 1
	},

	cci = {
		Type = "Earrings",
		EquipSlot = "Earrings",
		BonusCrit = 3,
		Width = 1,
		Height = 1
	},

	-- =========================
	-- TEST ITEMS (FOR GRID)
	-- =========================

	BigRelic = {
		Type = "Misc",
		EquipSlot = nil,
		Width = 2,
		Height = 1
	},

	LongRelic = {
		Type = "Misc",
		EquipSlot = nil,
		Width = 1,
		Height = 2
	},
	HealthPotion = {
		Type = "Consumable",
		Width = 1,
		Height = 1,
		MaxStack = 20,
		Stackable = true
	},
	ChangeBonus = {
		Name = "Change Bonus",
		Icon = "rbxassetid://86781761951906",
		Type = "Consumable",
		Width = 1,
		Height = 1,
		Stackable = true,
		MaxStack = 200,

		UseAction = "ChangeBonus"
	},

	AddBonus = {
		Name = "Add Bonus",
		Icon = "rbxassetid://110735415508622",
		Type = "Consumable",
		Width = 1,
		Height = 1,
		Stackable = true,
		MaxStack = 200,

		UseAction = "AddBonus"
	},

	Marble = {
		Name = "Marble",
		Icon = "rbxassetid://127400706288186",
		Type = "Consumable",
		Width = 1,
		Height = 1,
		Stackable = true,
		MaxStack = 200,

		UseAction = "Marmura"
	},

}

ItemSystem.TypeToBonusPool = {

	Weapon = "Weapon",
	Armor = "Armor",
	Helmet = "Helmet",
	Shield = "Shield",
	Shoes = "Shoes",

	Ring = "Special",
	Necklace = "Necklace",
	Bracelet = "Bracelet",
	Earrings = "Earrings"

}

function ItemSystem:GetItemData(itemId)

	local data = self.ItemData[itemId]
	if not data then return nil end

	data = table.clone(data)

	if not data.BonusPool then
		data.BonusPool = self.TypeToBonusPool[data.Type]
	end

	if data.Stackable == nil then
		data.Stackable = false
	end

	if data.MaxStack == nil then
		data.MaxStack = 1
	end

	return data

end

return ItemSystem