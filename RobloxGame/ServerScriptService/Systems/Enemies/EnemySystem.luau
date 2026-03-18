local EnemySystem = {}
local ServerScriptService = game:GetService("ServerScriptService")
local Systems = ServerScriptService:WaitForChild("Systems")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EnemyData = require(ReplicatedStorage.Config.Enemies.EnemyData)
local EnemyRegistry = require(ServerScriptService.Modules.EnemyRegistry)
local EnemyAIManager = require(Systems.Enemies.EnemyAIManager)
local EnemyTemplates = ReplicatedStorage:WaitForChild("EnemyTemplates")
local EnemyAnimationController = require(Systems.Enemies.EnemyAnimationController)


function EnemySystem:Init(enemy)


	
	EnemyRegistry:Register(enemy)

	enemy.Destroying:Connect(function()
		EnemyRegistry:Unregister(enemy)
	end)

	local config = EnemyData.List[enemy.Name]
	if not config then return end

	local humanoid = enemy:FindFirstChild("Humanoid")
	enemy.PrimaryPart = enemy:FindFirstChild("HumanoidRootPart")

	humanoid.MaxHealth = config.MaxHealth
	humanoid.Health = config.MaxHealth
	humanoid.WalkSpeed = config.WalkSpeed

	enemy:SetAttribute("Attack", config.Damage)
	enemy:SetAttribute("Defense", config.Defense)
	enemy:SetAttribute("Race", config.Race)
	enemy:SetAttribute("Exp", config.XP)

	-- START AI
	EnemyAnimationController:Init(enemy)
	EnemyAIManager:Register(enemy, config)

end

function EnemySystem.Spawn(enemyType, position)

	local template = EnemyTemplates:FindFirstChild(enemyType)

	if not template then
		warn("Enemy template not found:", enemyType)
		return nil
	end

	local enemy = template:Clone()
	enemy.Parent = workspace

	if enemy.PrimaryPart then
		enemy:SetPrimaryPartCFrame(CFrame.new(position))
	else
		local root = enemy:FindFirstChild("HumanoidRootPart")
		if root then
			root.CFrame = CFrame.new(position)
		end
	end

	EnemySystem:Init(enemy)

	return enemy

end
function EnemySystem:HandleDeath(enemy, killer)

	local humanoid = enemy:FindFirstChild("Humanoid")
	if not humanoid then return end

	if enemy:GetAttribute("Dead") then return end
	enemy:SetAttribute("Dead", true)

	local EnemyAIManager = require(Systems.Enemies.EnemyAIManager)
	EnemyAIManager:Unregister(enemy)

	--------------------------------------------------
	-- EXP
	--------------------------------------------------

	local exp = enemy:GetAttribute("Exp") or 0

	if killer then
		local XpSystem = require(Systems.Progression.XPSystem)

		--XpSystem:GiveXP(killer, exp)
	end

	--------------------------------------------------
	-- DROPS
	--------------------------------------------------

	local DropSystem = require(Systems.Drops.DropSystem)

	DropSystem:HandleDrop(enemy, killer)

	--------------------------------------------------
	-- REMOVE ENEMY
	--------------------------------------------------

	task.delay(2, function()
		if enemy and enemy.Parent then
			enemy:Destroy()
			EnemyAnimationController:Remove(enemy)
		end
	end)

end

function EnemySystem:Damage(enemy, amount, attacker)

	local humanoid = enemy:FindFirstChild("Humanoid")
	if not humanoid then return end

	humanoid.Health -= amount

	-- AGGRO
	if attacker then
		EnemyAnimationController:SetState(enemy,"Hit")
		enemy:SetAttribute("AggroTarget", attacker.UserId)
	end

	if humanoid.Health <= 0 then
		EnemyAnimationController:SetState(enemy,"Death")
		self:HandleDeath(enemy, attacker)
	end

end

return EnemySystem