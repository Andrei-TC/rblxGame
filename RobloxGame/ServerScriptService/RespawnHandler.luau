local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RespawnRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RespawnRequest")

local deathPositions = {}

print("RespawnHandler loaded")

RespawnRemote.OnServerEvent:Connect(function(player, option, position)

	-- salvam locul unde a murit
	if option == "SaveDeathPosition" then
		deathPositions[player] = position
		return
	end

	player:LoadCharacterAsync()

	local character = player.Character or player.CharacterAdded:Wait()
	local root = character:WaitForChild("HumanoidRootPart")

	if option == "Here" then

		local deathPos = deathPositions[player]

		if deathPos then
			root.CFrame = CFrame.new(deathPos + Vector3.new(0,3,0))
		end

	elseif option == "Town" then

		local townSpawn = workspace:WaitForChild("TownSpawn")
		root.CFrame = townSpawn.CFrame

	end

end)