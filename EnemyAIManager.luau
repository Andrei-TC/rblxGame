local EnemyAIManager = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local EnemyRegistry = require(game.ServerScriptService.Modules.EnemyRegistry)
local EnemyAnimationController = require(game.ServerScriptService.Systems.Enemies.EnemyAnimationController)

local enemies = {}

local UPDATE_RATE = 0.25
local accumulator = 0

--------------------------------------------------

function EnemyAIManager:Register(enemy, data)

	local root = enemy:WaitForChild("HumanoidRootPart")

	enemies[enemy] = {

		Data = data,
		LastAttack = 0,
		LastMove = 0,
		SpawnPosition = root.Position

	}

end

--------------------------------------------------

function EnemyAIManager:Unregister(enemy)

	enemies[enemy] = nil

end

--------------------------------------------------

RunService.Heartbeat:Connect(function(dt)

	accumulator += dt
	if accumulator < UPDATE_RATE then return end
	accumulator = 0

	for enemy, info in pairs(enemies) do

		if not enemy.Parent then
			enemies[enemy] = nil
			continue
		end

		local humanoid = enemy:FindFirstChild("Humanoid")
		local root = enemy:FindFirstChild("HumanoidRootPart")

		if not humanoid or humanoid.Health <= 0 then
			enemies[enemy] = nil
			continue
		end

		local data = info.Data
		local spawnPosition = info.SpawnPosition

		local aggroUserId = enemy:GetAttribute("AggroTarget")

		--------------------------------------------------
		-- FIND TARGET
		--------------------------------------------------

		if data.AggroType == "Aggressive" and not aggroUserId then

			for _, player in ipairs(Players:GetPlayers()) do

				local character = player.Character
				if not character then continue end

				local targetRoot = character:FindFirstChild("HumanoidRootPart")
				if not targetRoot then continue end

				local targetHumanoid = character:FindFirstChild("Humanoid")
				if not targetHumanoid or targetHumanoid.Health <= 0 then continue end

				local distance = (root.Position - targetRoot.Position).Magnitude

				if distance <= data.ActivationRadius then
					enemy:SetAttribute("AggroTarget", player.UserId)
					aggroUserId = player.UserId
					break
				end

			end

		end

		--------------------------------------------------
		-- IDLE
		--------------------------------------------------

		if not aggroUserId then

			EnemyAnimationController:SetState(enemy,"Idle")

			if (root.Position - spawnPosition).Magnitude > 2 then
				humanoid:MoveTo(spawnPosition)
			end

			continue
		end

		--------------------------------------------------
		-- VALIDATE TARGET
		--------------------------------------------------

		local player = Players:GetPlayerByUserId(aggroUserId)

		if not player then
			enemy:SetAttribute("AggroTarget", nil)
			continue
		end

		local character = player.Character
		if not character then
			enemy:SetAttribute("AggroTarget", nil)
			continue
		end

		local targetRoot = character:FindFirstChild("HumanoidRootPart")
		if not targetRoot then continue end

		local distance = (root.Position - targetRoot.Position).Magnitude

		local leashDistance = data.ActivationRadius * 1.5

		if distance > leashDistance then

			enemy:SetAttribute("AggroTarget", nil)

			EnemyAnimationController:SetState(enemy,"Walk")
			humanoid:MoveTo(spawnPosition)

			continue
		end

		--------------------------------------------------
		-- SEPARATION (avoid stacking mobs)
		--------------------------------------------------

		local separationForce = Vector3.zero

		for otherEnemy,_ in pairs(EnemyRegistry.Enemies) do

			if otherEnemy ~= enemy then

				local otherRoot = otherEnemy:FindFirstChild("HumanoidRootPart")

				if otherRoot then

					local dist = (root.Position - otherRoot.Position).Magnitude

					if dist < data.SeparationDistance then
						separationForce += (root.Position - otherRoot.Position).Unit
					end

				end
			end

		end

		local targetPosition = targetRoot.Position + separationForce * 3

		--------------------------------------------------
		-- MOVE
		--------------------------------------------------

		if distance > data.AttackRange then

			EnemyAnimationController:SetState(enemy,"Walk")

			if os.clock() - info.LastMove > 0.2 then
				humanoid:MoveTo(targetPosition)
				info.LastMove = os.clock()
			end

		else

			--------------------------------------------------
			-- ATTACK
			--------------------------------------------------

			local currentTime = os.clock()

			if currentTime - info.LastAttack >= data.AttackCooldown then

				EnemyAnimationController:SetState(enemy,"Attack")

				info.LastAttack = currentTime

			end

		end

	end

end)

--------------------------------------------------

return EnemyAIManager