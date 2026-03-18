local ServerScriptService = game:GetService("ServerScriptService")

local Systems = ServerScriptService:WaitForChild("Systems")

local SystemLoader = {}

SystemLoader.Core = Systems:WaitForChild("Core")
SystemLoader.Combat = Systems:WaitForChild("Combat")
SystemLoader.Enemies = Systems:WaitForChild("Enemies")
SystemLoader.Inventory = Systems:WaitForChild("Inventory")
SystemLoader.Progression = Systems:WaitForChild("Progression")
SystemLoader.Items = Systems:WaitForChild("Items")

return SystemLoader