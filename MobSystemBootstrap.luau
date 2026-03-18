local ServerScriptService = game:GetService("ServerScriptService")
local Systems = ServerScriptService:WaitForChild("Systems")
local MobZoneSystem = require(Systems.Enemies.MobZoneSystem)

MobZoneSystem.Init()