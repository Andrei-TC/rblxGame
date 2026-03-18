local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DefaultCharacters = ReplicatedStorage:WaitForChild("DefaultCharacters")

local function applyDefaultClothes(character)

	local folder = DefaultCharacters:FindFirstChild("Male")

	if not folder then return end

	local shirt = folder:FindFirstChildOfClass("Shirt")
	local pants = folder:FindFirstChildOfClass("Pants")

	if shirt then
		shirt:Clone().Parent = character
	end

	if pants then
		pants:Clone().Parent = character
	end

end

Players.PlayerAdded:Connect(function(player)

	player.CharacterAdded:Connect(function(character)

		task.wait(0.3)

		applyDefaultClothes(character)

	end)

end)