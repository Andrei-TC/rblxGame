local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local UpdateExpHUD = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("UpdateExpHUD")

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MainHUD"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- MAIN BAR
local bottomBar = Instance.new("Frame")
bottomBar.Size = UDim2.new(1, 0, 0, 35)
bottomBar.Position = UDim2.new(0, 0, 1, -35)
bottomBar.BackgroundColor3 = Color3.fromRGB(28, 18, 10)
bottomBar.BorderSizePixel = 0
bottomBar.Parent = screenGui

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(120, 85, 40)
stroke.Thickness = 2
stroke.Parent = bottomBar

-- LEFT SECTION
local leftSection = Instance.new("Frame")
leftSection.Size = UDim2.new(0, 220, 1, 0)
leftSection.Position = UDim2.new(0, 10, 0, 0)
leftSection.BackgroundTransparency = 1
leftSection.Parent = bottomBar

-- HP BAR
local function createBar(colorBg, colorFill, yScale)

	local container = Instance.new("Frame")
	container.Size = UDim2.new(0, 80, 0, 6)
	container.Position = UDim2.new(0, 0, yScale, 0)
	container.BackgroundColor3 = colorBg
	container.BorderSizePixel = 0
	container.Parent = leftSection

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(120, 85, 40)
	stroke.Thickness = 1
	stroke.Parent = container

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(1, 0, 1, 0)
	fill.BackgroundColor3 = colorFill
	fill.BorderSizePixel = 0
	fill.Parent = container

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 2)
	corner.Parent = container

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(0, 2)
	fillCorner.Parent = fill

	return fill
end

local hpFill = createBar(Color3.fromRGB(45,20,20), Color3.fromRGB(150,30,30), 0.35)
local mpFill = createBar(Color3.fromRGB(20,30,55), Color3.fromRGB(30,80,180), 0.65)

-- EXP CONTAINER
local expContainer = Instance.new("Frame")
expContainer.Size = UDim2.new(0, 120, 1, 0)
expContainer.Position = UDim2.new(0, 95, 0, 0)
expContainer.BackgroundTransparency = 1
expContainer.Parent = leftSection

-- HOTBAR CENTER
local centerSection = Instance.new("Frame")
centerSection.Size = UDim2.new(0, 240, 1, 0)
centerSection.AnchorPoint = Vector2.new(0.5, 0.5)
centerSection.Position = UDim2.new(0.5, 0, 0.5, 0)
centerSection.BackgroundTransparency = 1
centerSection.Parent = bottomBar

for i = 1, 6 do
	local slot = Instance.new("Frame")
	slot.Size = UDim2.new(0, 32, 0, 32)
	slot.Position = UDim2.new(0, (i - 1) * 36, 0.5, -16)
	slot.BackgroundColor3 = Color3.fromRGB(50, 35, 20)
	slot.BorderSizePixel = 0
	slot.Parent = centerSection

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(130, 95, 45)
	stroke.Thickness = 1.5
	stroke.Parent = slot
end

-- TOOLTIP
local tooltip = Instance.new("TextLabel")
tooltip.Size = UDim2.new(0, 120, 0, 18)
tooltip.BackgroundTransparency = 1
tooltip.TextColor3 = Color3.fromRGB(230, 200, 140)
tooltip.TextSize = 13
tooltip.Font = Enum.Font.GothamBold
tooltip.TextXAlignment = Enum.TextXAlignment.Center
tooltip.Visible = false
tooltip.Parent = screenGui

local tooltipStroke = Instance.new("UIStroke")
tooltipStroke.Color = Color3.fromRGB(120, 85, 40)
tooltipStroke.Thickness = 1
tooltipStroke.Parent = tooltip

-- EXP BALLS
local ballFills = {}

for i = 1, 4 do
	local ball = Instance.new("Frame")
	ball.Size = UDim2.new(0, 18, 0, 18)
	ball.Position = UDim2.new(0, (i - 1) * 24, 0.5, -9)
	ball.BackgroundColor3 = Color3.fromRGB(60, 45, 25)
	ball.BorderSizePixel = 0
	ball.Parent = expContainer

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = ball

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(150, 110, 50)
	stroke.Thickness = 1
	stroke.Parent = ball

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(210, 160, 60)
	fill.BorderSizePixel = 0
	fill.Parent = ball

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(1, 0)
	fillCorner.Parent = fill

	ballFills[i] = fill
end

-- TOOLTIP POSITION
expContainer.MouseEnter:Connect(function()
	tooltip.Visible = true
	local pos = expContainer.AbsolutePosition
	local size = expContainer.AbsoluteSize
	tooltip.Position = UDim2.new(0, pos.X + size.X/2 - 60, 0, pos.Y - 23)
end)

expContainer.MouseLeave:Connect(function()
	tooltip.Visible = false
end)

-- UPDATE EXP
UpdateExpHUD.OnClientEvent:Connect(function(data)

	local totalXP = data.TotalXP or 0
	local totalRequired = data.TotalXPRequired or 1

	local percent = math.clamp(totalXP / totalRequired, 0, 1)
	local xpPerBall = totalRequired / 4

	for i = 1, 4 do
		local startXP = (i - 1) * xpPerBall
		local endXP = i * xpPerBall

		if totalXP >= endXP then
			ballFills[i].Size = UDim2.new(1, 0, 1, 0)
		elseif totalXP > startXP then
			local progress = (totalXP - startXP) / xpPerBall
			ballFills[i].Size = UDim2.new(progress, 0, 1, 0)
		else
			ballFills[i].Size = UDim2.new(0, 0, 1, 0)
		end
	end

	tooltip.Text = "Exp: " .. math.floor(percent * 100) .. "%"
end)

-- LIVE HP / MP
local function connectCharacter(character)

	local humanoid = character:WaitForChild("Humanoid")

	local function updateHP()
		local percent = humanoid.Health / humanoid.MaxHealth
		hpFill.Size = UDim2.new(percent, 0, 1, 0)
	end

	updateHP()
	humanoid.HealthChanged:Connect(updateHP)

	local function updateMP()
		local mana = character:GetAttribute("Mana") or 0
		local maxMana = character:GetAttribute("MaxMana") or 1
		mpFill.Size = UDim2.new(mana / maxMana, 0, 1, 0)
	end

	updateMP()
	character:GetAttributeChangedSignal("Mana"):Connect(updateMP)
	character:GetAttributeChangedSignal("MaxMana"):Connect(updateMP)
end

if player.Character then
	connectCharacter(player.Character)
end

player.CharacterAdded:Connect(connectCharacter)