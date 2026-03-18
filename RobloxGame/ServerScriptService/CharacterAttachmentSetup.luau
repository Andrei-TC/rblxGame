local Players = game:GetService("Players")

local function setupCharacter(character)

	local hand =
		character:FindFirstChild("RightHand") or
		character:FindFirstChild("Right Arm")

	if not hand then
		warn("No hand found for character")
		return
	end

	-- verificam daca attachment exista deja
	local existing = hand:FindFirstChild("WeaponAttachment")
	if existing then
		return
	end

	local attachment = Instance.new("Attachment")
	attachment.Name = "WeaponAttachment"

	-- pozi?ia ini?iala (po?i ajusta ulterior)
	attachment.Position = Vector3.new(0,-1,0)

	attachment.Parent = hand

end

Players.PlayerAdded:Connect(function(player)

	player.CharacterAdded:Connect(function(character)

		task.wait(0.5)

		setupCharacter(character)

	end)

end)