local StatSystem = {}
local ServerScriptService = game:GetService("ServerScriptService")
local Systems = ServerScriptService:WaitForChild("Systems")
local PlayerDataSystem = require(Systems.Core.PlayerDataSystem)
local ItemSystem = require(Systems.Items.ItemSystem)

local STR_COEFFICIENT = 2
local VIT_HP_SCALING = 40
local INT_MANA_SCALING = 20
local VIT_DEF_SCALING = 1

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local UpdateStatsUI = Remotes:WaitForChild("UpdateStatsUI")

function StatSystem:RecalculateStats(player)

	local profile = PlayerDataSystem:GetProfile(player)
	if not profile then return end

	-------------------------------------------------
	-- RESET BONUS VALUES
	-------------------------------------------------

	local bonusSTR = 0
	local bonusDEX = 0
	local bonusINT = 0
	local bonusVIT = 0

	local bonusAttackValue = 0
	local bonusMaxHP = 0
	local bonusMaxMP = 0

	local CriticalChance = 0
	local PenetrationChance = 0
	local BlockChance = 0

	local StrongVsOrc = 0
	local StrongVsAnimal = 0
	local StrongVsDevil = 0
	local StrongVsEsoteric = 0
	local StrongVsSemiHuman = 0
	local StrongVsVampire = 0

	local AttackSpeed = 0
	local CastingSpeed = 0

	-------------------------------------------------
	-- READ EQUIPPED ITEM BONUSES
	-------------------------------------------------

	for _, item in pairs(profile.Equipment) do

		if item and item.Bonuses then

			for _, bonus in ipairs(item.Bonuses) do

				local id = bonus.Id
				local value = bonus.Value

				if id == "STR" then
					bonusSTR += value

				elseif id == "DEX" then
					bonusDEX += value

				elseif id == "INT" then
					bonusINT += value

				elseif id == "VIT" then
					bonusVIT += value

				elseif id == "AttackValue" then
					bonusAttackValue += value

				elseif id == "MaxHP" then
					bonusMaxHP += value

				elseif id == "MaxMP" then
					bonusMaxMP += value

				elseif id == "CriticalChance" then
					CriticalChance += value

				elseif id == "PenetrationChance" then
					PenetrationChance += value

				elseif id == "BlockChance" then
					BlockChance += value

				elseif id == "StrongVsOrc" then
					StrongVsOrc += value

				elseif id == "StrongVsAnimal" then
					StrongVsAnimal += value

				elseif id == "StrongVsDevil" then
					StrongVsDevil += value

				elseif id == "StrongVsEsoteric" then
					StrongVsEsoteric += value

				elseif id == "StrongVsSemiHuman" then
					StrongVsSemiHuman += value

				elseif id == "StrongVsVampire" then
					StrongVsVampire += value

				elseif id == "AttackSpeed" then
					AttackSpeed += value

				elseif id == "CastingSpeed" then
					CastingSpeed += value

				end

			end

		end

	end

	-------------------------------------------------
	-- FINAL BASE STATS
	-------------------------------------------------

	local finalSTR = profile.STR + bonusSTR
	local finalDEX = profile.DEX + bonusDEX
	local finalINT = profile.INT + bonusINT
	local finalVIT = profile.VIT + bonusVIT

	-------------------------------------------------
	-- HP / MANA
	-------------------------------------------------

	local maxHP = profile.BaseHP + (finalVIT * VIT_HP_SCALING) + bonusMaxHP
	local maxMana = profile.BaseMana + (finalINT * INT_MANA_SCALING) + bonusMaxMP

	-------------------------------------------------
	-- DEFENSE
	-------------------------------------------------

	local defense = profile.BaseDefense + (finalVIT * VIT_DEF_SCALING)

	if profile.Equipment.Armor then
		local armorData = ItemSystem:GetItemData(profile.Equipment.Armor.ItemId)

		if armorData and armorData.Defense then
			defense += armorData.Defense
		end
	end

	-------------------------------------------------
	-- WEAPON DAMAGE
	-------------------------------------------------

	local weaponMin = 5
	local weaponMax = 10

	if profile.Equipment.Weapon then
		local weaponData = ItemSystem:GetItemData(profile.Equipment.Weapon.ItemId)

		if weaponData then
			weaponMin = weaponData.AttackMin or weaponMin
			weaponMax = weaponData.AttackMax or weaponMax
		end
	end

	local attackMin = weaponMin + (finalSTR * STR_COEFFICIENT) + bonusAttackValue
	local attackMax = weaponMax + (finalSTR * STR_COEFFICIENT) + bonusAttackValue

	-------------------------------------------------
	-- SAVE FINAL VALUES
	-------------------------------------------------

	profile.AttackMin = attackMin
	profile.AttackMax = attackMax
	profile.Defense = defense
	profile.MaxHP = maxHP
	profile.MaxMana = maxMana

	profile.CriticalChance = CriticalChance
	profile.PenetrationChance = PenetrationChance
	profile.BlockChance = BlockChance

	profile.StrongVsOrc = StrongVsOrc
	profile.StrongVsAnimal = StrongVsAnimal
	profile.StrongVsDevil = StrongVsDevil
	profile.StrongVsEsoteric = StrongVsEsoteric
	profile.StrongVsSemiHuman = StrongVsSemiHuman
	profile.StrongVsVampire = StrongVsVampire

	profile.AttackSpeed = AttackSpeed
	profile.CastingSpeed = CastingSpeed

	-------------------------------------------------
	-- SYNC CHARACTER
	-------------------------------------------------

	local character = player.Character

	if character and character:FindFirstChild("Humanoid") then

		local humanoid = character.Humanoid

		humanoid.MaxHealth = maxHP
		humanoid.Health = math.clamp(humanoid.Health, 0, maxHP)

		character:SetAttribute("MaxMana", maxMana)
		character:SetAttribute("Mana", maxMana)

	end

	-------------------------------------------------
	-- SEND STATS TO UI
	-------------------------------------------------

	UpdateStatsUI:FireClient(player, {

		Level = profile.Level,
		TotalXP = profile.TotalXP,
		TotalXPRequired = profile.TotalXPRequired,
		StatPoints = profile.StatPoints,

		STR = finalSTR,
		DEX = finalDEX,
		INT = finalINT,
		VIT = finalVIT,

		CurrentHP = maxHP,
		MaxHP = maxHP,

		CurrentMana = maxMana,
		MaxMana = maxMana,

		Attack = attackMin .. " - " .. attackMax,
		Defense = defense,

		CriticalChance = CriticalChance,
		BlockChance = BlockChance

	})

end

return StatSystem