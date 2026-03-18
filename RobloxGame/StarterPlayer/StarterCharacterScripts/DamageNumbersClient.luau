local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local DamageRemote = ReplicatedStorage.Remotes:WaitForChild("DamageNumber")

DamageRemote.OnClientEvent:Connect(function(enemy, damage)

	local root = enemy:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0,80,0,40)
	billboard.StudsOffset = Vector3.new(0,0.5,0)
	billboard.AlwaysOnTop = true
	billboard.Adornee = root
	billboard.Parent = root

	local text = Instance.new("TextLabel")
	text.Size = UDim2.new(1,0,1,0)
	text.BackgroundTransparency = 1
	text.Text = tostring(damage)
	text.TextColor3 = Color3.fromRGB(255,70,70)
	text.TextStrokeTransparency = 0
	text.Font = Enum.Font.SourceSansBold
	text.TextScaled = true
	text.Parent = billboard

	-- începe mic
	text.TextSize = 10

	-- FAZA 1 (sus-dreapta + cre?te)
	local tween1 = TweenService:Create(
		billboard,
		TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{StudsOffset = Vector3.new(1,3,0)}
	)

	local sizeTween1 = TweenService:Create(
		text,
		TweenInfo.new(0.25),
		{TextSize = 32}
	)

	tween1:Play()
	sizeTween1:Play()

	tween1.Completed:Connect(function()

		-- FAZA 2 (dreapta-jos + mic)
		local tween2 = TweenService:Create(
			billboard,
			TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{StudsOffset = Vector3.new(2,2,0)}
		)

		local sizeTween2 = TweenService:Create(
			text,
			TweenInfo.new(0.35),
			{TextSize = 14}
		)

		tween2:Play()
		sizeTween2:Play()

		tween2.Completed:Connect(function()
			billboard:Destroy()
		end)

	end)

end)