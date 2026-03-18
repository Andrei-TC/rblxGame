local MobZoneSystem = {}

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EnemySystem = require(script.Parent.EnemySystem)

local ZonesFolder = Workspace:WaitForChild("MobZones")

MobZoneSystem.Zones = {}

local function getRandomPositionInPart(part)
	local size = part.Size
	local cf = part.CFrame

	local randomX = (math.random() - 0.5) * size.X
	local randomZ = (math.random() - 0.5) * size.Z

	local position = cf.Position + Vector3.new(randomX, 0, randomZ)

	return position
end

function MobZoneSystem.Init()

	for _, zonePart in ipairs(ZonesFolder:GetChildren()) do

		local zone = {
			Part = zonePart,
			ActiveMobs = {},
			MaxMobs = zonePart:GetAttribute("MaxMobs") or 10,
			RespawnDelay = zonePart:GetAttribute("RespawnDelay") or 5,
			SpawnInterval = zonePart:GetAttribute("SpawnInterval") or 2,
			EnemyTypes = {}
		}

		local enemyString = zonePart:GetAttribute("EnemyTypes")
		if enemyString then
			for enemyType in string.gmatch(enemyString, '([^,]+)') do
				table.insert(zone.EnemyTypes, enemyType)
			end
		end

		table.insert(MobZoneSystem.Zones, zone)

		task.spawn(function()
			while true do
				task.wait(zone.SpawnInterval)

				if #zone.ActiveMobs < zone.MaxMobs then

					if #zone.EnemyTypes == 0 then
						warn("Zone has no EnemyTypes set:", zone.Part.Name)
						continue
					end

					local enemyType = zone.EnemyTypes[math.random(1, #zone.EnemyTypes)]
					local spawnPos = getRandomPositionInPart(zone.Part)

					local enemy = EnemySystem.Spawn(enemyType, spawnPos)

					if enemy then
						table.insert(zone.ActiveMobs, enemy)

						enemy.AncestryChanged:Connect(function(_, parent)
							if not parent then
								for i, mob in ipairs(zone.ActiveMobs) do
									if mob == enemy then
										table.remove(zone.ActiveMobs, i)
										break
									end
								end
							end
						end)
					end
				end
			end
		end)

	end
end

return MobZoneSystem