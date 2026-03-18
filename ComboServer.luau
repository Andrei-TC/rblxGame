local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Systems = ServerScriptService:WaitForChild("Systems")

local CombatSystem = require(Systems.Combat.CombatSystem)

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local AttackHit = Remotes:WaitForChild("AttackHit")

local lastAttack = {}

AttackHit.OnServerEvent:Connect(function(player, combo, weapon)

	local now = os.clock()

	if lastAttack[player] and now - lastAttack[player] < 0.05 then
		return
	end

	lastAttack[player] = now

	CombatSystem:ProcessAttack(player, combo, weapon)

end)