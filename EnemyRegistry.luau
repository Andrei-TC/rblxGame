local EnemyRegistry = {}

EnemyRegistry.Enemies = {}

function EnemyRegistry:Register(enemy)
	EnemyRegistry.Enemies[enemy] = true
end

function EnemyRegistry:Unregister(enemy)
	EnemyRegistry.Enemies[enemy] = nil
end

function EnemyRegistry:GetEnemies()
	return EnemyRegistry.Enemies
end

return EnemyRegistry