local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AttackRequest = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("AttackHit")

UserInputService.InputBegan:Connect(function(input, gameProcessed)

	if gameProcessed then return end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		AttackRequest:FireServer()
	end

end)