local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DefaultClothes = ReplicatedStorage:WaitForChild("DefaultClothes")
local DefaultFolder = DefaultClothes:WaitForChild("Default")

local function applyDefaultClothes(character)

	local existingShirt = character:FindFirstChildOfClass("Shirt")
	local existingPants = character:FindFirstChildOfClass("Pants")

	if existingShirt then existingShirt:Destroy() end
	if existingPants then existingPants:Destroy() end

	local shirt = DefaultFolder:FindFirstChildOfClass("Shirt")
	local pants = DefaultFolder:FindFirstChildOfClass("Pants")


	if shirt then
		shirt:Clone().Parent = character
	end

	if pants then
		pants:Clone().Parent = character
	end

end

Players.PlayerAdded:Connect(function(player)

	player.CharacterAdded:Connect(function(character)

		task.wait(0.2)
		applyDefaultClothes(character)

	end)

end)