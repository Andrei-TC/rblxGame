local XPSystem = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Systems = ServerScriptService:WaitForChild("Systems")

local LevelSystem = require(Systems.Progression.LevelSystem)
local EnemyData = require(ReplicatedStorage.Config.Enemies.EnemyData)

function XPSystem.HandleEnemyDeath(enemy, damageLog)

	if not enemy or not damageLog then
		return
	end

	local enemyType = enemy:GetAttribute("EnemyType")
	if not enemyType then
		return
	end

	local config = EnemyData.List[enemyType]
	if not config then
		return
	end

	local baseXP = config.XP or 0
	if baseXP <= 0 then
		return
	end

	local modifier = enemy:GetAttribute("XPModifier") or 1

	-- Calculate total damage
	local totalDamage = 0
	for _, damage in pairs(damageLog) do
		totalDamage += damage
	end

	if totalDamage <= 0 then
		return
	end

	-- Distribute XP proportionally
	for userId, damage in pairs(damageLog) do

		local player = Players:GetPlayerByUserId(userId)

		if player and damage > 0 then

			local share = damage / totalDamage
			local xpAward = math.floor(baseXP * modifier * share)

			if xpAward > 0 then
				LevelSystem.AddXP(player, xpAward)
			end
		end
	end
end

return XPSystem