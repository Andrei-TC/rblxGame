local LevelSystem = {}
local ServerScriptService = game:GetService("ServerScriptService")
local Systems = ServerScriptService:WaitForChild("Systems")

local PlayerDataSystem = require(Systems.Core.PlayerDataSystem)
local StatSystem = require(Systems.Progression.StatSystem)

local BASE_XP = 100
local XP_GROWTH = 1.25

local HP_PER_LEVEL = 40
local MANA_PER_LEVEL = 10
local DEF_PER_LEVEL = 2
local STAT_POINTS_PER_LEVEL = 3

local function calculateXPRequired(level)
	return math.floor(BASE_XP * (XP_GROWTH ^ (level - 1)))
end

function LevelSystem:AddXP(player, amount)
	local profile = PlayerDataSystem:GetProfile(player)
	if not profile then return end

	profile.TotalXP += amount

	while profile.TotalXP >= profile.TotalXPRequired do
		profile.TotalXP -= profile.TotalXPRequired
		profile.Level += 1

		profile.StatPoints += STAT_POINTS_PER_LEVEL

		-- Cre?teri automate la level
		profile.BaseHP += HP_PER_LEVEL
		profile.BaseMana += MANA_PER_LEVEL
		profile.BaseDefense += DEF_PER_LEVEL

		profile.TotalXPRequired = calculateXPRequired(profile.Level)
	end

	StatSystem:RecalculateStats(player)
	
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Remotes = ReplicatedStorage:WaitForChild("Remotes")
	local UpdateExpHUD = Remotes:WaitForChild("UpdateExpHUD")

	UpdateExpHUD:FireClient(player, {
		Level = profile.Level,
		TotalXP = profile.TotalXP,
		TotalXPRequired = profile.TotalXPRequired
	})
end

return LevelSystem