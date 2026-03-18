local PickupSystem = {}

local ServerScriptService = game:GetService("ServerScriptService")
local Systems = ServerScriptService:WaitForChild("Systems")

local InventorySystem = require(Systems.Inventory.InventorySystem)
local ItemFactory = require(Systems.Items.ItemFactory)

function PickupSystem:RegisterDrop(drop)

	local prompt = drop:FindFirstChildWhichIsA("ProximityPrompt", true)
	if not prompt then return end

	local picked = false

	prompt.Triggered:Connect(function(player)

		if picked then return end
		picked = true

		local owner = drop:GetAttribute("Owner")
		if owner and owner ~= player.UserId then
			picked = false
			return
		end

		local itemIdValue = drop:FindFirstChild("ItemId")
		local amountValue = drop:FindFirstChild("Amount")

		if not itemIdValue then
			picked = false
			return
		end

		local itemId = itemIdValue.Value

		local amount = 1
		if amountValue then
			amount = amountValue.Value
		end

		for i = 1, amount do

			local itemInstance = ItemFactory:CreateItem(itemId)

			InventorySystem:AddItem(player, itemInstance.ItemId)

		end

		drop:Destroy()

	end)

end

return PickupSystem