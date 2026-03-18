local CombatSystem = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Systems = ServerScriptService:WaitForChild("Systems")
local Modules = ServerScriptService:WaitForChild("Modules")

local EnemyRegistry = require(Modules.EnemyRegistry)
local DamageSystem = require(Systems.Damage.DamageSystem)

local HITBOX_SIZE = Vector3.new(8,10,5)
local HITBOX_OFFSET = CFrame.new(0,-1.5,-4)
local DEBUG_HITBOX = false
local lastAttack = {}

function CombatSystem:ProcessAttack(player, combo, weapon)
	local now = os.clock()

	if lastAttack[player] and now - lastAttack[player] < 0.2 then
		return
	end

	lastAttack[player] = now

	local character = player.Character
	if not character then return end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local cf = root.CFrame * HITBOX_OFFSET

	local params = OverlapParams.new()
	params.FilterDescendantsInstances = {character}
	params.FilterType = Enum.RaycastFilterType.Exclude

	local parts = workspace:GetPartBoundsInBox(cf, HITBOX_SIZE, params)

	local hitEnemies = {}
	-- Debug
	if DEBUG_HITBOX then
		local debugPart = Instance.new("Part")
		debugPart.Size = HITBOX_SIZE
		debugPart.CFrame = cf
		debugPart.Anchored = true
		debugPart.CanCollide = false
		debugPart.Transparency = 0.6
		debugPart.Color = Color3.fromRGB(255,0,0)
		if #parts > 0 then
			debugPart.Color = Color3.fromRGB(0,255,0)
		end
		debugPart.Parent = workspace

		game.Debris:AddItem(debugPart, 0.2)	
	end
	
	for _,part in ipairs(parts) do

		local model = part:FindFirstAncestorWhichIsA("Model")

		if model and not hitEnemies[model] then

			if EnemyRegistry.Enemies[model] then

				local enemyRoot = model:FindFirstChild("HumanoidRootPart")
				if not enemyRoot then continue end

				hitEnemies[model] = true

				DamageSystem:ApplyDamage(player, model)

				self:ApplyKnockback(root, enemyRoot, combo)

			end

		end

	end

end

function CombatSystem:ApplyKnockback(attackerRoot, enemyRoot, combo)

	local direction = (enemyRoot.Position - attackerRoot.Position).Unit

	local force = 20
	local vertical = 0

	if combo == 4 then
		force = 90
		vertical = 45
	end

	local impulse = (direction * force + Vector3.new(0, vertical, 0)) * enemyRoot.AssemblyMass

	enemyRoot:ApplyImpulse(impulse)

end

return CombatSystem