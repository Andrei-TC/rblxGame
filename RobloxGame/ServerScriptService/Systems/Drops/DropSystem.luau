local DropSystem = {}

local ServerScriptService = game:GetService("ServerScriptService")
local Systems = ServerScriptService:WaitForChild("Systems")

local InventorySystem = require(Systems.Inventory.InventorySystem)
local EnemyData = require(game:GetService("ReplicatedStorage").Config.Enemies.EnemyData)
local PickupSystem = require(Systems.Drops.PickupSystem)
local Workspace = game:GetService("Workspace")
local ItemDrops = Workspace:WaitForChild("ItemDrops")
local ItemFactory = require(Systems.Items.ItemFactory)

local DEBUG_DROPS = false

function DropSystem:HandleDrop(enemy, killer)

	if not killer then return end

	local data = EnemyData.List[enemy.Name]
	if not data then
		if DEBUG_DROPS then
			warn("No EnemyData for:", enemy.Name)
		end
		return
	end

	local dropTable = data.DropTable
	if not dropTable then
		if DEBUG_DROPS then
			warn(enemy.Name .. " has no DropTable")
		end
		return
	end

	if DEBUG_DROPS then
		print("Enemy killed:", enemy.Name)
	end

 
	for _, drop in ipairs(dropTable) do

		local chance = drop.Chance or 0

		local roll = math.random()

		if DEBUG_DROPS then
			print("Rolling for:", drop.Item, "Chance:", chance, "Roll:", roll)
		end

		if roll <= chance then

			local amount = 1

			if typeof(drop.Amount) == "table" then
				local min = drop.Amount[1] or 1
				local max = drop.Amount[2] or min
				amount = math.random(min, max)
			end

			local itemInstance = ItemFactory:CreateItem(drop.Item)

			self:SpawnGroundDrop(enemy, itemInstance, amount, killer)

		end

	end

end
function DropSystem:SpawnGroundDrop(enemy, itemInstance, amount, killer)

	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local DropBagTemplate = ReplicatedStorage.Assets.Drops.DropBag
	local ItemDrops = workspace:WaitForChild("ItemDrops")

	local root = enemy:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local drop = DropBagTemplate:Clone()

	if killer then
		drop:SetAttribute("Owner", killer.UserId)
	end
	
	drop.Parent = ItemDrops
	self:CreateBillboard(drop, itemInstance, amount, killer)
	PickupSystem:RegisterDrop(drop)
	
	local uidValue = Instance.new("StringValue")
	uidValue.Name = "ItemUID"
	uidValue.Value = itemInstance.UID
	uidValue.Parent = drop

	local randomOffset = Vector3.new(
		math.random(-3,3),
		0,
		math.random(-3,3)
	)

	local origin = root.Position + randomOffset + Vector3.new(0,10,0)

	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = {enemy}
	rayParams.FilterType = Enum.RaycastFilterType.Exclude

	local ray = workspace:Raycast(origin, Vector3.new(0,-50,0), rayParams)

	local position

	if ray then
		local sizeY = drop:GetExtentsSize().Y
		position = ray.Position + Vector3.new(0, sizeY/2, 0)
	else
		position = root.Position + randomOffset
	end

	local angle = math.rad(math.random(0,360))

	drop:PivotTo(
		CFrame.new(position) * CFrame.Angles(0, angle, 0)
	)

	local itemValue = Instance.new("StringValue")
	itemValue.Name = "ItemId"
	itemValue.Value = itemInstance.ItemId
	itemValue.Parent = drop

	local amountValue = Instance.new("IntValue")
	amountValue.Name = "Amount"
	amountValue.Value = amount
	amountValue.Parent = drop

	game:GetService("Debris"):AddItem(drop, 60)
	

end

function DropSystem:CreateBillboard(drop, itemInstance, amount, killer)

	local part = drop.PrimaryPart or drop:FindFirstChildWhichIsA("BasePart")
	if not part then return end

	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0,140,0,36)
	billboard.StudsOffset = Vector3.new(0,1.2,0)
	billboard.AlwaysOnTop = true
	billboard.Adornee = part
	billboard.Parent = drop

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1,0,1,0)
	frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
	frame.BackgroundTransparency = 0.35
	frame.BorderSizePixel = 0
	frame.Parent = billboard

	local ownerLabel = Instance.new("TextLabel")
	ownerLabel.Size = UDim2.new(1,0,0.45,0)
	ownerLabel.BackgroundTransparency = 1
	ownerLabel.Font = Enum.Font.SourceSansBold
	ownerLabel.TextColor3 = Color3.fromRGB(255,220,0)
	ownerLabel.TextStrokeTransparency = 0
	ownerLabel.TextScaled = true
	ownerLabel.Parent = frame

	if killer then
		ownerLabel.Text = killer.Name
	else
		ownerLabel.Text = ""
	end

	local itemLabel = Instance.new("TextLabel")
	itemLabel.Size = UDim2.new(1,0,0.55,0)
	itemLabel.Position = UDim2.new(0,0,0.45,0)
	itemLabel.BackgroundTransparency = 1
	itemLabel.Font = Enum.Font.SourceSansBold
	itemLabel.TextColor3 = Color3.fromRGB(255,255,255)
	itemLabel.TextStrokeTransparency = 0
	itemLabel.TextScaled = true
	itemLabel.Parent = frame

	local ItemSystem = require(
		game:GetService("ServerScriptService").Systems.Items.ItemSystem
	)

	local itemData = ItemSystem:GetItemData(itemInstance.ItemId)

	local text = itemData.Name or itemInstance.ItemId

	-- daca sunt mai multe iteme
	if amount and amount > 1 then
		text = amount .. "x " .. text
	end

	-- doar pentru echipament aratam +level
	if itemData.EquipSlot then
		local plus = itemInstance.Plus or 0
		text = text .. " +" .. plus
	end

	itemLabel.Text = text

end

return DropSystem