local PlayerDataSystem = {}

local Players = game:GetService("Players")

-- In-memory storage (po?i lega ulterior de DataStore)
local PlayerProfiles = {}

function PlayerDataSystem:CreateProfile(player)

	local profile = {}

	-- date simple
	profile.Level = 1
	profile.TotalXP = 0
	profile.TotalXPRequired = 100

	profile.StatPoints = 0
	profile.SkillPoints = 0

	profile.STR = 5
	profile.VIT = 5
	profile.INT = 5
	profile.DEX = 5

	profile.BaseHP = 100
	profile.BaseMana = 50
	profile.BaseDefense = 5

	-- INVENTORY UNIC
	profile.Inventory = {
		SizeX = 5,
		SizeY = 6,
		Slots = {}
	}

	local totalSlots = profile.Inventory.SizeX * profile.Inventory.SizeY
	for i = 1, totalSlots do
		profile.Inventory.Slots[i] = nil
	end

	-- EQUIPMENT UNIC
	profile.Equipment = {
		Weapon = nil,
		Armor = nil,
		Helmet = nil,
		Shield = nil,
		Necklace = nil,
		Earrings = nil,
		Bracelet = nil,
		Shoes = nil,
		Ring1 = nil,
		Ring2 = nil
	}

	PlayerProfiles[player] = profile

	print("PROFILE CREATED:", player.Name)

	return profile
end

function PlayerDataSystem:GetProfile(player)
	return PlayerProfiles[player]
end

function PlayerDataSystem:RemoveProfile(player)
	PlayerProfiles[player] = nil
end

Players.PlayerRemoving:Connect(function(player)
	PlayerDataSystem:RemoveProfile(player)
end)

return PlayerDataSystem