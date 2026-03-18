local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local InventorySystem = require(ServerScriptService.Systems.Inventory.InventorySystem)

local commandItems = {

	-- Weapons
	["!rusty"] = "RustySword",
	["!iron"] = "IronSword",
	["!axe"] = "GreatAxe",
	["!staff"] = "MagicStaff",

	-- Armor
	["!leather"] = "LeatherArmor",
	["!ironarmor"] = "IronArmor",

	-- Helmets
	["!helm"] = "LeatherHelmet",
	["!knighthelm"] = "KnightHelmet",

	-- Shields
	["!shield"] = "WoodenShield",
	["!tower"] = "TowerShield",

	-- Boots
	["!boots"] = "LeatherBoots",
	["!swift"] = "SwiftBoots",

	-- Accessories
	["!goldring"] = "GoldRing",
	["!silverring"] = "SilverRing",
	["!necklace"] = "EmeraldNecklace",
	["!bracelet"] = "WarBracelet",
	["!earrings"] = "EarringsOfFocus",

	-- Grid test
	["!big"] = "BigRelic",
	["!long"] = "LongRelic"
}

Players.PlayerAdded:Connect(function(player)

	player.Chatted:Connect(function(message)

		-- mic admin check (optional)
		-- if player.UserId ~= 123456789 then return end -- pune UserId-ul tau aici

		
		local args = string.split(message, " ")
		local command = args[1]

		local itemId = commandItems[command]

		if command == "!give" then

			local itemId = args[2]
			local amount = tonumber(args[3]) or 1

			if not itemId then
				print("Usage: !give ItemId amount")
				return
			end

			local itemData = require(script.Parent.Systems.Items.ItemSystem):GetItemData(itemId)

			if not itemData then
				print("Invalid item:", itemId)
				return
			end

			print("Giving", amount, itemId, "to", player.Name)

			for i = 1, amount do
				InventorySystem:AddItem(player, itemId)
			end

		end

	end)

end)