local player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RespawnRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RespawnRequest")

local gui = Instance.new("ScreenGui")
gui.Name = "DeathUI"
gui.ResetOnSpawn = false
gui.Enabled = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,300,0,150)
frame.Position = UDim2.new(0.5,-150,0.5,-75)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.Parent = gui

local respawnHere = Instance.new("TextButton")
respawnHere.Size = UDim2.new(1,-20,0,40)
respawnHere.Position = UDim2.new(0,10,0,20)
respawnHere.Text = "Respawneaza aici (15)"
respawnHere.Parent = frame

local respawnTown = Instance.new("TextButton")
respawnTown.Size = UDim2.new(1,-20,0,40)
respawnTown.Position = UDim2.new(0,10,0,80)
respawnTown.Text = "Respawneaza in oras"
respawnTown.Parent = frame

local timer = 15

local function startCountdown()

	timer = 15
	respawnHere.Text = "Respawneaza aici ("..timer..")"

	while timer > 0 do

		task.wait(1)

		timer -= 1

		respawnHere.Text = "Respawneaza aici ("..timer..")"

	end

	respawnHere.Text = "Respawneaza aici"

end

player.CharacterAdded:Connect(function(character)

	gui.Enabled = false

	local humanoid = character:WaitForChild("Humanoid")

	humanoid.Died:Connect(function()

		gui.Enabled = true

		local root = character:FindFirstChild("HumanoidRootPart")
		if root then
			RespawnRemote:FireServer("SaveDeathPosition", root.Position)
		end

		startCountdown()

	end)
end)

respawnHere.MouseButton1Click:Connect(function()

	if timer > 0 then return end

	gui.Enabled = false

	RespawnRemote:FireServer("Here")

end)

respawnTown.MouseButton1Click:Connect(function()

	print("Town button clicked")

	RespawnRemote:FireServer("Town")

end)