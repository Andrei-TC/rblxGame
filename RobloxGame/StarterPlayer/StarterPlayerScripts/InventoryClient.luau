--==============================
-- SERVICES
--==============================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local TextChatService = game:GetService("TextChatService")

local player = Players.LocalPlayer

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local UpdateInventoryUI = Remotes:WaitForChild("UpdateInventoryUI")
local InventoryAction = Remotes:WaitForChild("InventoryAction")
local SystemMessage = Remotes:WaitForChild("SystemMessage")

--==============================
-- CONFIG
--==============================

local SLOT_SIZE = 46
local PADDING = 4
local GRID_COLUMNS = 5
local GRID_ROWS = 6

local MAX_SLOTS = GRID_COLUMNS * GRID_ROWS
local DEFAULT_ICON = "rbxassetid://100914352358203"

--==============================
-- STATE
--==============================

local itemDragging = false
local draggedIndex = nil
local draggedFromEquipment = nil
local draggedUID = nil
local draggedUseAction = nil
local draggedItemWidth = 1
local draggedItemHeight = 1

local ghostLabel = nil

--==============================
-- DATA STRUCTURES (POOL)
--==============================

local slotFrames = {}
local itemFrames = {}
local frameToItemData = {}
local frameToLabel = {}
local frameToIcon = {}

--==============================
-- GUI ROOT
--==============================

local playerGui = player:WaitForChild("PlayerGui")

local existing = playerGui:FindFirstChild("InventoryGUI")
if existing then
	existing:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "InventoryGUI"
gui.ResetOnSpawn = false
gui.Parent = playerGui

--==============================
-- MAIN WINDOW
--==============================

local main = Instance.new("Frame")
main.AnchorPoint = Vector2.new(1,1)
main.Position = UDim2.new(1,-20,1,-20)
main.BackgroundColor3 = Color3.fromRGB(28,18,10)
main.BorderSizePixel = 0
main.Parent = gui

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(120,85,40)
stroke.Thickness = 2
stroke.Parent = main

--==============================
-- HEADER
--==============================

local header = Instance.new("Frame")
header.Size = UDim2.new(1,0,0,30)
header.BackgroundColor3 = Color3.fromRGB(40,25,15)
header.Parent = main

local headerStroke = Instance.new("UIStroke")
headerStroke.Color = Color3.fromRGB(120,85,40)
headerStroke.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,1,0)
title.BackgroundTransparency = 1
title.Text = "Inventory"
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = Color3.fromRGB(230,200,140)
title.Parent = header

--==============================
-- INVENTORY TOGGLE
--==============================

local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input, processed)

	if processed then return end

	if input.KeyCode == Enum.KeyCode.K then

		main.Visible = not main.Visible

	end

end)

--==============================
-- WINDOW DRAG SYSTEM
--==============================

local dragging = false
local dragStart
local startPos

header.InputBegan:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1 then

		dragging = true
		dragStart = input.Position
		startPos = main.Position

	end

end)

header.InputEnded:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end

end)

UserInputService.InputChanged:Connect(function(input)

	if not dragging then return end
	if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end

	local delta = input.Position - dragStart

	main.Position = UDim2.new(
		startPos.X.Scale,
		startPos.X.Offset + delta.X,
		startPos.Y.Scale,
		startPos.Y.Offset + delta.Y
	)

end)

--==============================
-- DRAG GHOST
--==============================

local function startGhost(width,height,input)

	if ghostLabel then
		ghostLabel:Destroy()
	end

	ghostLabel = Instance.new("Frame")

	ghostLabel.Size = UDim2.new(
		0,
		SLOT_SIZE * width + PADDING * (width - 1),
		0,
		SLOT_SIZE * height + PADDING * (height - 1)
	)

	ghostLabel.AnchorPoint = Vector2.new(0.5,0.5)
	ghostLabel.Position = UDim2.new(
		0,
		input.Position.X,
		0,
		input.Position.Y
	)

	ghostLabel.BackgroundTransparency = 1
	ghostLabel.BorderSizePixel = 0
	ghostLabel.ZIndex = 999

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255,230,160)
	stroke.Thickness = 2
	stroke.Parent = ghostLabel

	ghostLabel.Parent = gui

end

--==============================
-- DRAG START
--==============================

local function startDrag(input,width,height)

	if itemDragging then return end
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end

	itemDragging = true

	startGhost(width,height,input)

end

--==============================
-- TOOLTIP
--==============================

local tooltip = Instance.new("Frame")
tooltip.Visible = false
tooltip.BackgroundColor3 = Color3.fromRGB(8,8,8)
tooltip.BorderColor3 = Color3.fromRGB(120,85,40)
tooltip.BorderSizePixel = 2
tooltip.ZIndex = 100
tooltip.AutomaticSize = Enum.AutomaticSize.Y
tooltip.Size = UDim2.new(0,200,0,0)
tooltip.Parent = gui

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0,8)
padding.PaddingBottom = UDim.new(0,8)
padding.PaddingLeft = UDim.new(0,10)
padding.PaddingRight = UDim.new(0,10)
padding.Parent = tooltip

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0,2)
layout.Parent = tooltip

--==============================
-- TOOLTIP FUNCTIONS
--==============================

local function formatValue(v)
	if v > 0 then
		return "+"..v
	else
		return tostring(v)
	end
end

local function clearTooltip()

	for _,child in ipairs(tooltip:GetChildren()) do
		if child:IsA("TextLabel") then
			child:Destroy()
		end
	end

end

local function addTooltipLine(text,color,size)

	local label = Instance.new("TextLabel")

	label.BackgroundTransparency = 1
	label.Font = Enum.Font.Gotham
	label.TextSize = size or 14
	label.TextColor3 = color
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.AutomaticSize = Enum.AutomaticSize.X
	label.Size = UDim2.new(0,0,0,18)

	label.ZIndex = tooltip.ZIndex + 1
	label.Text = text
	label.Parent = tooltip

end

local function positionTooltip()

	local mouse = UserInputService:GetMouseLocation()
	local inset = GuiService:GetGuiInset()
	local viewport = workspace.CurrentCamera.ViewportSize

	local x = mouse.X - inset.X - tooltip.AbsoluteSize.X - 12
	local y = mouse.Y - inset.Y - tooltip.AbsoluteSize.Y - 12

	if x < 8 then
		x = mouse.X - inset.X + 18
	end

	if y < 8 then
		y = mouse.Y - inset.Y + 18
	end

	tooltip.Position = UDim2.new(0,x,0,y)

end
--==============================
-- EQUIPMENT PANEL
--==============================

local equipFrame = Instance.new("Frame")
equipFrame.BackgroundTransparency = 1
equipFrame.Parent = main

local BASE = SLOT_SIZE
local GAP = PADDING

local equipSlotsUI = {}

--==============================
-- EQUIP SLOT CREATOR
--==============================

local function createEquipSlot(name,x,y,h,w)

	local slot = Instance.new("Frame")

	slot.Name = name
	slot.BackgroundColor3 = Color3.fromRGB(50,35,20)
	slot.BorderSizePixel = 0

	slot.Size = UDim2.new(
		0,(BASE*w)+(GAP*(w-1)),
		0,(BASE*h)+(GAP*(h-1))
	)

	slot.Position = UDim2.new(0,x,0,y)
	slot.Parent = equipFrame

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(120,85,40)
	stroke.Parent = slot

	local icon = Instance.new("ImageLabel")
	icon.Name = "ItemIcon"
	icon.Size = UDim2.new(1,0,1,0)
	icon.BackgroundTransparency = 1
	icon.Image = ""
	icon.ScaleType = Enum.ScaleType.Fit
	icon.ZIndex = 5
	icon.Parent = slot

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1,0,1,0)
	label.BackgroundTransparency = 1
	label.Text = ""
	label.Font = Enum.Font.GothamBold
	label.TextSize = 12
	label.TextColor3 = Color3.fromRGB(230,200,140)
	label.ZIndex = 6
	label.Parent = slot

	frameToIcon[slot] = icon
	
	--==============================
	-- TOOLTIP
	--==============================

	slot.MouseEnter:Connect(function()

		local data = frameToItemData[slot]
		if not data then return end

		clearTooltip()

		addTooltipLine(data.ItemId,Color3.fromRGB(255,220,120),16)

		if data.AverageDamage then
			addTooltipLine(
				"Paguba medie "..formatValue(data.AverageDamage).."%",
				Color3.fromRGB(150,200,255)
			)
		end

		if data.SkillDamage then
			addTooltipLine(
				"Paguba competenta "..formatValue(data.SkillDamage).."%",
				Color3.fromRGB(150,200,255)
			)
		end

		if data.Bonuses then
			for _,b in ipairs(data.Bonuses) do
				addTooltipLine(
					b.Id.." "..formatValue(b.Value),
					Color3.fromRGB(160,200,255)
				)
			end
		end

		tooltip.Visible = true
		positionTooltip()

	end)

	slot.MouseMoved:Connect(positionTooltip)

	slot.MouseLeave:Connect(function()
		tooltip.Visible = false
	end)

	--==============================
	-- INPUT
	--==============================

	slot.InputBegan:Connect(function(input)

		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			InventoryAction:FireServer("Unequip",slot.Name)
			tooltip.Visible = false
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 then

			if label.Text ~= "" then

				draggedFromEquipment = slot.Name
				draggedIndex = nil

				draggedItemWidth = slot:GetAttribute("ItemWidth") or 1
				draggedItemHeight = slot:GetAttribute("ItemHeight") or 1

			end

			tooltip.Visible = false

		end

	end)

	equipSlotsUI[name] = label

end

--==============================
-- EQUIPMENT LAYOUT
--==============================

local col2 = BASE + 12
local col1 = col2 - BASE - 18
local col3 = col2 + BASE + GAP
local col4 = col3 + BASE + GAP

local R1 = 0
local R2 = BASE + GAP
local R3 = R2 + BASE + GAP
local R4 = R3 + BASE + GAP

createEquipSlot("Weapon", col1, R1, 3, 1)
createEquipSlot("Helmet", col2, R1, 1, 1)
createEquipSlot("Armor", col2, R2, 2, 1)
createEquipSlot("Shield", col3, R2, 1, 1)
createEquipSlot("Earrings", col4, R2, 1, 1)
createEquipSlot("Bracelet", col3, R3, 1, 1)
createEquipSlot("Necklace", col4, R3, 1, 1)
createEquipSlot("Shoes", col2, R4, 1, 1)
createEquipSlot("Ring1", col1, R4, 1, 1)
createEquipSlot("Ring2", col3, R4, 1, 1)

local equipHeight = R4 + BASE

equipFrame.Size = UDim2.new(1,-20,0,equipHeight)
equipFrame.Position = UDim2.new(0,10,0,40)

--==============================
-- INVENTORY GRID (POOL)
--==============================

local gridContainer = Instance.new("Frame")

gridContainer.BackgroundTransparency = 1
gridContainer.Position = UDim2.new(
	0,
	10,
	0,
	equipFrame.Position.Y.Offset + equipHeight + 25
)

gridContainer.Size = UDim2.new(
	0,
	(SLOT_SIZE*GRID_COLUMNS)+(PADDING*(GRID_COLUMNS-1)),
	0,
	(SLOT_SIZE*GRID_ROWS)+(PADDING*(GRID_ROWS-1))
)

gridContainer.Parent = main

local gridBackground = Instance.new("Frame")
gridBackground.BackgroundTransparency = 1
gridBackground.Size = UDim2.new(1,0,1,0)
gridBackground.Parent = gridContainer

local layout = Instance.new("UIGridLayout")

layout.CellSize = UDim2.new(0,SLOT_SIZE,0,SLOT_SIZE)
layout.CellPadding = UDim2.new(0,PADDING,0,PADDING)

layout.Parent = gridBackground

--==============================
-- SLOT POOL
--==============================

for i = 1, MAX_SLOTS do

	local cell = Instance.new("Frame")

	cell.BackgroundColor3 = Color3.fromRGB(50,35,20)
	cell.BorderSizePixel = 0
	cell.LayoutOrder = i
	cell.Parent = gridBackground

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(120,85,40)
	stroke.Parent = cell

	slotFrames[i] = cell

end

--==============================
-- ITEMS LAYER
--==============================

local itemsLayer = Instance.new("Frame")

itemsLayer.BackgroundTransparency = 1
itemsLayer.Size = UDim2.new(1,0,1,0)
itemsLayer.ZIndex = 5

itemsLayer.Parent = gridContainer

--==============================
-- MAIN WINDOW SIZE
--==============================

main.Size = UDim2.new(
	0,
	gridContainer.Size.X.Offset + 20,
	0,
	gridContainer.Position.Y.Offset + gridContainer.Size.Y.Offset + 20
)
--==============================
-- ITEM FRAME POOL
--==============================

local function createItemFrame()

	local frame = Instance.new("Frame")

	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.ZIndex = 10
	frame.Visible = false
	frame.Parent = itemsLayer

	local icon = Instance.new("ImageLabel")

	icon.Name = "ItemIcon"
	icon.Size = UDim2.new(1,0,1,0)
	icon.BackgroundTransparency = 1
	icon.Image = ""
	icon.ZIndex = 11
	icon.ScaleType = Enum.ScaleType.Fit
	icon.Parent = frame

	local label = Instance.new("TextLabel")

	label.Name = "ItemLabel"
	label.AnchorPoint = Vector2.new(1,1)
	label.Position = UDim2.new(1,-2,1,-2)
	label.Size = UDim2.new(0,50,0,16)

	label.BackgroundTransparency = 1
	label.TextXAlignment = Enum.TextXAlignment.Right
	label.TextYAlignment = Enum.TextYAlignment.Bottom

	label.Font = Enum.Font.GothamBold
	label.TextSize = 12
	label.TextColor3 = Color3.fromRGB(255,230,160)

	label.ZIndex = 12
	label.Parent = frame

	frameToLabel[frame] = label
	frameToIcon[frame] = icon

	--==============================
	-- INPUT
	--==============================

	frame.InputBegan:Connect(function(input)

		if input.UserInputType == Enum.UserInputType.MouseButton1 then

			tooltip.Visible = false

			if itemDragging then return end

			local data = frameToItemData[frame]
			if not data then return end

			draggedIndex = data.Index
			draggedUID = data.UID
			draggedUseAction = data.UseAction

			draggedFromEquipment = nil
			draggedItemWidth = data.Width or 1
			draggedItemHeight = data.Height or 1

			startGhost(draggedItemWidth, draggedItemHeight, input)
			itemDragging = true

		end

		if input.UserInputType == Enum.UserInputType.MouseButton2 then

			tooltip.Visible = false

			local data = frameToItemData[frame]
			if not data then return end

			InventoryAction:FireServer("Equip",data.Index)

		end

	end)

	--==============================
	-- TOOLTIP
	--==============================

	frame.MouseEnter:Connect(function()

		local data = frameToItemData[frame]
		if not data then return end

		clearTooltip()

		addTooltipLine("=== ITEM DEBUG ===",Color3.fromRGB(255,200,120),16)

		addTooltipLine("ItemId: "..tostring(data.ItemId),Color3.fromRGB(200,200,200))
		addTooltipLine("UID: "..tostring(data.UID),Color3.fromRGB(200,200,200))
		addTooltipLine("Plus: "..tostring(data.Plus),Color3.fromRGB(200,200,200))

		addTooltipLine("Width: "..tostring(data.Width),Color3.fromRGB(200,200,200))
		addTooltipLine("Height: "..tostring(data.Height),Color3.fromRGB(200,200,200))

		if data.AverageDamage then
			addTooltipLine("PM: "..tostring(data.AverageDamage),Color3.fromRGB(150,200,255))
		end

		if data.SkillDamage then
			addTooltipLine("PC: "..tostring(data.SkillDamage),Color3.fromRGB(150,200,255))
		end

		addTooltipLine("Bonuses:",Color3.fromRGB(255,200,120))

		if data.Bonuses then
			for i,b in ipairs(data.Bonuses) do
				addTooltipLine(
					i.." ? "..tostring(b.Id).." = "..tostring(b.Value),
					Color3.fromRGB(160,200,255)
				)
			end
		end

		tooltip.Visible = true
		positionTooltip()

	end)

	frame.MouseMoved:Connect(positionTooltip)

	frame.MouseLeave:Connect(function()
		tooltip.Visible = false
	end)

	return frame

end

--==============================
-- PRECREATE ITEM FRAMES
--==============================

for i = 1, MAX_SLOTS do

	local frame = createItemFrame()
	itemFrames[i] = frame

end

--==============================
-- UPDATE ITEM FRAME
--==============================

local function updateItemFrame(index,itemData)

	local frame = itemFrames[index]
	local icon = frameToIcon[frame]
	local label = frameToLabel[frame]

	if not frame then return end

	-- SLOT GOL
	if not itemData then
		frame.Visible = false
		frameToItemData[frame] = nil

		if icon then
			icon.Image = ""
		end

		if label then
			label.Text = ""
		end

		return
	end

	-- SET ICON
	if icon then
		icon.Image = itemData.Icon or DEFAULT_ICON
	end

	-- DIMENSIUNE ITEM
	local width = itemData.Width or 1
	local height = itemData.Height or 1

	local row = math.floor((index - 1) / GRID_COLUMNS)
	local col = (index - 1) % GRID_COLUMNS

	local posX = col * (SLOT_SIZE + PADDING)
	local posY = row * (SLOT_SIZE + PADDING)

	frame.Size = UDim2.new(
		0,
		SLOT_SIZE * width + PADDING * (width - 1),
		0,
		SLOT_SIZE * height + PADDING * (height - 1)
	)

	frame.Position = UDim2.new(0,posX,0,posY)

	-- ATTRIBUTES
	frame:SetAttribute("UID",itemData.UID)
	frame:SetAttribute("EquipSlot",itemData.EquipSlot)
	frame:SetAttribute("UseAction",itemData.UseAction)

	-- STACK TEXT
	if itemData.Amount and itemData.Amount > 1 then
		label.Text = "x"..itemData.Amount
	else
		label.Text = ""
	end

	frame.Visible = true
	frameToItemData[frame] = itemData

end
--==============================
-- INVENTORY DATA CACHE
--==============================

local inventoryCache = {}

--==============================
-- CLEAR INVENTORY
--==============================

local function clearInventory()

	for i = 1, MAX_SLOTS do

		inventoryCache[i] = nil
		updateItemFrame(i,nil)

	end

end

--==============================
-- APPLY INVENTORY DATA
--==============================

local function applyInventoryData(data)

	-- reset cache
	for i = 1, MAX_SLOTS do
		inventoryCache[i] = nil
	end

	-- fill cache
	for _,slotData in ipairs(data.Slots) do

		if slotData and slotData.IsRoot then

			local index = slotData.Index
			local item = slotData.Item

			item.Index = index
			inventoryCache[index] = item

		end

	end

	-- update UI
	for i = 1, MAX_SLOTS do

		updateItemFrame(i,inventoryCache[i])

	end

end

--==============================
-- EQUIPMENT UPDATE
--==============================

	local function updateEquipment(data)

		for slotName,label in pairs(equipSlotsUI) do

			local slotFrame = label.Parent
			local icon = frameToIcon[slotFrame]
			local equipData = data.Equipment[slotName]

			if equipData then

				if icon then
					icon.Image = equipData.Icon or DEFAULT_ICON
					icon.Visible = true
				end

				label.Text = ""

				slotFrame:SetAttribute("UID",equipData.UID)
				slotFrame:SetAttribute("ItemWidth",equipData.Width or 1)
				slotFrame:SetAttribute("ItemHeight",equipData.Height or 1)

				frameToItemData[slotFrame] = equipData

			else

				if icon then
					icon.Image = ""
					icon.Visible = false
				end

				label.Text = ""

				slotFrame:SetAttribute("ItemWidth",nil)
				slotFrame:SetAttribute("ItemHeight",nil)

				frameToItemData[slotFrame] = nil

			end

		end

	end

--==============================
-- UPDATE INVENTORY EVENT
--==============================

UpdateInventoryUI.OnClientEvent:Connect(function(data)

	-- reset drag state
	itemDragging = false
	draggedIndex = nil
	draggedFromEquipment = nil

	if ghostLabel then
		ghostLabel:Destroy()
		ghostLabel = nil
	end

	-- apply inventory
	applyInventoryData(data)

	-- apply equipment
	updateEquipment(data)

end)
--==============================
-- DRAG FOLLOW
--==============================

UserInputService.InputChanged:Connect(function(input)

	if not itemDragging then return end
	if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end

	local mousePos = UserInputService:GetMouseLocation()
	local inset = GuiService:GetGuiInset()

	mousePos = mousePos - inset

	if ghostLabel then

		ghostLabel.Position = UDim2.new(
			0,
			mousePos.X,
			0,
			mousePos.Y
		)

	end

end)

--==============================
-- FIND INVENTORY SLOT
--==============================

local function getInventoryIndexFromMouse(mousePos)

	local gridPos = gridContainer.AbsolutePosition

	local localX = mousePos.X - gridPos.X
	local localY = mousePos.Y - gridPos.Y

	local col = math.floor(localX / (SLOT_SIZE + PADDING)) + 1
	local row = math.floor(localY / (SLOT_SIZE + PADDING)) + 1

	if col >= 1 and col <= GRID_COLUMNS
		and row >= 1 and row <= GRID_ROWS then

		return (row - 1) * GRID_COLUMNS + col

	end

	return nil

end

--==============================
-- FIND EQUIP SLOT
--==============================

local function getEquipSlotFromMouse(mousePos)

	for slotName,label in pairs(equipSlotsUI) do

		local parent = label.Parent

		local pos = parent.AbsolutePosition
		local size = parent.AbsoluteSize

		if mousePos.X >= pos.X
			and mousePos.X <= pos.X + size.X
			and mousePos.Y >= pos.Y
			and mousePos.Y <= pos.Y + size.Y then

			return slotName

		end

	end

	return nil

end

--==============================
-- RESET DRAG
--==============================

local function resetDrag()

	itemDragging = false
	draggedIndex = nil
	draggedFromEquipment = nil
	draggedUID = nil
	draggedUseAction = nil

	if ghostLabel then
		ghostLabel:Destroy()
		ghostLabel = nil
	end

end
--==============================
-- DRAG END
--==============================

UserInputService.InputEnded:Connect(function(input)

	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
	if not itemDragging then return end

	local mousePos = UserInputService:GetMouseLocation()
	local inset = GuiService:GetGuiInset()

	mousePos = mousePos - inset

	local targetIndex = getInventoryIndexFromMouse(mousePos)
	local targetEquipSlot = getEquipSlotFromMouse(mousePos)

	--==============================
	-- SCROLL ? ITEM
	--==============================

	if draggedUseAction then

		local targetFrame = nil

		for frame,data in pairs(frameToItemData) do

			local pos = frame.AbsolutePosition
			local size = frame.AbsoluteSize

			if mousePos.X >= pos.X and mousePos.X <= pos.X + size.X
				and mousePos.Y >= pos.Y and mousePos.Y <= pos.Y + size.Y then
				targetFrame = frame
				break
			end

		end

		if targetFrame then

			local targetData = frameToItemData[targetFrame]

			if targetData then

				InventoryAction:FireServer(
					"UseItem",
					draggedUID,
					targetData.UID
				)

				resetDrag()
				return

			end

		end

	end

	--==============================
	-- INVENTORY ? INVENTORY
	--==============================

	if draggedIndex ~= nil and targetIndex ~= nil then

		if targetIndex ~= draggedIndex then

			InventoryAction:FireServer(
				"Move",
				draggedIndex,
				targetIndex
			)

		end

		resetDrag()
		return

	end

	--==============================
	-- INVENTORY ? EQUIPMENT
	--==============================

	if draggedIndex ~= nil and targetEquipSlot ~= nil then

		local frame = itemFrames[draggedIndex]

		if frame then

			local requiredSlot = frame:GetAttribute("EquipSlot")

			local valid = false

			if requiredSlot == targetEquipSlot then
				valid = true
			end

			if requiredSlot == "Ring"
				and (targetEquipSlot == "Ring1"
					or targetEquipSlot == "Ring2") then
				valid = true
			end

			if valid then

				InventoryAction:FireServer(
					"Equip",
					draggedIndex
				)

			end

		end

		resetDrag()
		return

	end

	--==============================
	-- EQUIPMENT ? INVENTORY
	--==============================

	if draggedFromEquipment ~= nil and targetIndex ~= nil then

		InventoryAction:FireServer(
			"UnequipToSlot",
			draggedFromEquipment,
			targetIndex
		)

		resetDrag()
		return

	end

	resetDrag()

end)
--==============================
-- WINDOW DRAG
--==============================

-- de facut

--==============================
-- CHAT SYSTEM MESSAGE
--==============================

local TextChatService = game:GetService("TextChatService")

SystemMessage.OnClientEvent:Connect(function(text)

	local channel = TextChatService.TextChannels.RBXGeneral

	if channel then
		channel:DisplaySystemMessage(text)
	end

end)

--==============================
-- SAFETY CLEANUP
--==============================

player.CharacterAdded:Connect(function()

	resetDrag()

	if ghostLabel then
		ghostLabel:Destroy()
		ghostLabel = nil
	end

end)

--==============================
-- DEBUG
--==============================

print("InventoryClient V3 loaded")