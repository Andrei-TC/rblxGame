local DamageSystem = {}

local ServerScriptService = game:GetService("ServerScriptService")

local Systems = ServerScriptService:WaitForChild("Systems")

local EnemySystem = require(Systems.Enemies.EnemySystem)
local PlayerDataSystem = require(Systems.Core.PlayerDataSystem)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DamageRemote = ReplicatedStorage.Remotes:WaitForChild("DamageNumber")

--------------------------------------------------
-- DAMAGE CALCULATION
--------------------------------------------------

function DamageSystem:CalculateDamage(player, enemy)

	local profile = PlayerDataSystem:GetProfile(player)
	if not profile then return 0 end

	--------------------------------------------------
	-- BASE DAMAGE
	--------------------------------------------------

	local attackMin = profile.AttackMin or 1
	local attackMax = profile.AttackMax or 2

	local damage = math.random(attackMin, attackMax)

	--------------------------------------------------
	-- ENEMY DEFENSE
	--------------------------------------------------

	local enemyDefense = enemy:GetAttribute("Defense") or 0

	local penetration = profile.PenetrationChance or 0

	if math.random(1,100) <= penetration then
		enemyDefense = enemyDefense * 0.5
	end

	damage = damage - enemyDefense

	if damage < 1 then
		damage = 1
	end

	--------------------------------------------------
	-- RACE BONUS
	--------------------------------------------------

	local race = enemy:GetAttribute("Race")

	if race then

		local bonus = 0

		if race == "Orc" then
			bonus = profile.StrongVsOrc or 0

		elseif race == "Animal" then
			bonus = profile.StrongVsAnimal or 0

		elseif race == "Devil" then
			bonus = profile.StrongVsDevil or 0

		elseif race == "Esoteric" then
			bonus = profile.StrongVsEsoteric or 0

		elseif race == "SemiHuman" then
			bonus = profile.StrongVsSemiHuman or 0

		elseif race == "Vampire" then
			bonus = profile.StrongVsVampire or 0
		end

		damage = damage * (1 + bonus / 100)

	end

	--------------------------------------------------
	-- CRITICAL
	--------------------------------------------------

	local critChance = profile.CriticalChance or 0
	local crit = false

	if math.random(1,100) <= critChance then
		damage = damage * 2
		crit = true
	end

	return math.floor(damage), crit

end

--------------------------------------------------
-- APPLY DAMAGE
--------------------------------------------------

function DamageSystem:ApplyDamage(player, enemy)

	local damage, crit = self:CalculateDamage(player, enemy)

	if damage <= 0 then return end

	EnemySystem:Damage(enemy, damage, player)

	-- DAMAGE NUMBER
	DamageRemote:FireAllClients(enemy, damage, crit)

end

return DamageSystem