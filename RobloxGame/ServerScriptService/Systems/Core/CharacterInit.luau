local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local Systems = ServerScriptService:WaitForChild("Systems")

local PlayerDataSystem = require(script.Parent.PlayerDataSystem)
local StatSystem = require(ServerScriptService.Systems.Progression.StatSystem)
local EquipmentSystem = require(Systems.Character.EquipmentSystem)

Players.PlayerAdded:Connect(function(player)

	local profile = PlayerDataSystem:CreateProfile(player)

	-- calculeaza stats înainte de spawn
	StatSystem:RecalculateStats(player)

	player.CharacterAdded:Connect(function(character)

		character:WaitForChild("Humanoid")

		StatSystem:RecalculateStats(player)
		EquipmentSystem:ApplyEquipment(player)

	end)

	player:LoadCharacterAsync()

end)