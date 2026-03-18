local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local RequestStatUpgrade = Remotes:WaitForChild("RequestStatUpgrade")
local UpdateStatsUI = Remotes:WaitForChild("UpdateStatsUI")

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "StatusWindow"
gui.ResetOnSpawn = false
gui.Enabled = false
gui.Parent = player:WaitForChild("PlayerGui")

-- MAIN FRAME
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 300, 0, 420)
main.Position = UDim2.new(0.08, 0, 0.2, 0)
main.BackgroundColor3 = Color3.fromRGB(28,18,10)
main.BorderSizePixel = 0
main.Parent = gui

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(120,85,40)
stroke.Thickness = 2
stroke.Parent = main

-- HEADER
local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, 0, 0, 30)
header.BackgroundTransparency = 1
header.Text = "Character"
header.Font = Enum.Font.GothamBold
header.TextSize = 16
header.TextColor3 = Color3.fromRGB(230,200,140)
header.Parent = main

-- LEVEL / EXP
local function createInfoLabel(y)
	local lbl = Instance.new("TextLabel")
	lbl.Position = UDim2.new(0, 10, 0, y)
	lbl.Size = UDim2.new(1, -20, 0, 20)
	lbl.BackgroundTransparency = 1
	lbl.TextColor3 = Color3.fromRGB(230,200,140)
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 14
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = main
	return lbl
end

local levelLabel = createInfoLabel(40)
local expLabel = createInfoLabel(65)
local expNeededLabel = createInfoLabel(90)

-- Separator
local sep = Instance.new("Frame")
sep.Position = UDim2.new(0, 10, 0, 120)
sep.Size = UDim2.new(1, -20, 0, 1)
sep.BackgroundColor3 = Color3.fromRGB(120,85,40)
sep.BorderSizePixel = 0
sep.Parent = main

-- STATS
local stats = {}
local plusButtons = {}

local function createStatRow(name, yPos)

	local label = Instance.new("TextLabel")
	label.Position = UDim2.new(0, 10, 0, yPos)
	label.Size = UDim2.new(0, 120, 0, 24)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(230,200,140)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = name .. ": 0"
	label.Parent = main

	local plus = Instance.new("TextButton")
	plus.Size = UDim2.new(0, 24, 0, 24)
	plus.Position = UDim2.new(0, 140, 0, yPos)
	plus.Text = "+"
	plus.BackgroundColor3 = Color3.fromRGB(60,40,20)
	plus.TextColor3 = Color3.fromRGB(230,200,140)
	plus.Visible = false
	plus.Parent = main

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(120,85,40)
	stroke.Parent = plus

	plus.MouseButton1Click:Connect(function()
		RequestStatUpgrade:FireServer(name)
	end)

	stats[name] = label
	plusButtons[name] = plus
end

createStatRow("VIT", 135)
createStatRow("INT", 165)
createStatRow("STR", 195)
createStatRow("DEX", 225)

-- DERIVED STATS
local hpLabel = createInfoLabel(135)
hpLabel.Position = UDim2.new(0, 180, 0, 135)

local mpLabel = createInfoLabel(165)
mpLabel.Position = UDim2.new(0, 180, 0, 165)

local dmgLabel = createInfoLabel(195)
dmgLabel.Position = UDim2.new(0, 180, 0, 195)

local defLabel = createInfoLabel(225)
defLabel.Position = UDim2.new(0, 180, 0, 225)

local statPointsLabel = createInfoLabel(270)

-- Toggle C
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.C then
		gui.Enabled = not gui.Enabled
		if gui.Enabled then
			RequestStatUpgrade:FireServer("Refresh")
		end
	end
end)

-- Update UI from server
UpdateStatsUI.OnClientEvent:Connect(function(data)

	levelLabel.Text = "Nivel: " .. (data.Level or 1)
	expLabel.Text = "EXP: " .. (data.TotalXP or 0)
	expNeededLabel.Text = "EXP Necesara: " .. (data.TotalXPRequired or 0)

	statPointsLabel.Text = "Stat Points: " .. (data.StatPoints or 0)

	stats["VIT"].Text = "VIT: " .. (data.VIT or 0)
	stats["INT"].Text = "INT: " .. (data.INT or 0)
	stats["STR"].Text = "STR: " .. (data.STR or 0)
	stats["DEX"].Text = "DEX: " .. (data.DEX or 0)

	for _, btn in pairs(plusButtons) do
		btn.Visible = (data.StatPoints or 0) > 0
	end

	hpLabel.Text = "PV: " .. (data.CurrentHP or 0) .. " / " .. (data.MaxHP or 0)
	mpLabel.Text = "PM: " .. (data.CurrentMana or 0) .. " / " .. (data.MaxMana or 0)

	dmgLabel.Text = "Atac: " .. (data.Attack or 0)
	defLabel.Text = "Aparare: " .. (data.Defense or 0)
end)

-- Live HP / Mana updates
local function connectCharacter(character)

	local humanoid = character:WaitForChild("Humanoid")

	local function updateHP()
		hpLabel.Text = "PV: " .. math.floor(humanoid.Health) .. " / " .. humanoid.MaxHealth
	end

	updateHP()
	humanoid.HealthChanged:Connect(updateHP)

	local function updateMana()
		local currentMana = character:GetAttribute("Mana") or 0
		local maxMana = character:GetAttribute("MaxMana") or 0
		mpLabel.Text = "PM: " .. currentMana .. " / " .. maxMana
	end

	updateMana()
	character:GetAttributeChangedSignal("Mana"):Connect(updateMana)
	character:GetAttributeChangedSignal("MaxMana"):Connect(updateMana)
end

if player.Character then
	connectCharacter(player.Character)
end

player.CharacterAdded:Connect(connectCharacter)