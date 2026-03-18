local EnemyAnimationController = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AnimationConfig = require(
	ReplicatedStorage.Config.Enemies.EnemyAnimationConfig
)

EnemyAnimationController.Tracks = {}
EnemyAnimationController.State = {}

--------------------------------------------------

function EnemyAnimationController:Init(enemy)

	local humanoid = enemy:WaitForChild("Humanoid")

	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end

	local config = AnimationConfig[enemy.Name]
	if not config then
		warn("No animation config for",enemy.Name)
		return
	end

	local tracks = {}

	local function loadAnim(id)

		local anim = Instance.new("Animation")
		anim.AnimationId = id

		return animator:LoadAnimation(anim)

	end

	tracks.Idle = loadAnim(config.Idle)
	tracks.Walk = loadAnim(config.Walk)
	tracks.Attack = loadAnim(config.Attack)
	tracks.Hit = loadAnim(config.Hit)
	tracks.Death = loadAnim(config.Death)

	tracks.Attack:GetMarkerReachedSignal("HIT"):Connect(function()

		local targetUserId = enemy:GetAttribute("AggroTarget")
		if not targetUserId then return end

		local player = game.Players:GetPlayerByUserId(targetUserId)
		if not player then return end

		local character = player.Character
		if not character then return end

		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid then

			local damage = enemy:GetAttribute("Attack") or 5
			humanoid:TakeDamage(damage)

		end

	end)

	tracks.Idle.Looped = true
	tracks.Walk.Looped = true

	EnemyAnimationController.Tracks[enemy] = tracks
	EnemyAnimationController.State[enemy] = nil

	self:SetState(enemy,"Idle")

end

--------------------------------------------------

function EnemyAnimationController:SetState(enemy,newState)

	local tracks = self.Tracks[enemy]
	if not tracks then return end

	if self.State[enemy] == newState then

		-- permite replay pentru attack si hit
		if newState == "Attack" or newState == "Hit" then

			local track = self.Tracks[enemy][newState]

			if track then
				track:Play()
			end

		end

		return
	end

	self.State[enemy] = newState

	for _,track in pairs(tracks) do
		track:Stop()
	end

	local track = tracks[newState]

	if track then
		track:Play()
	end

end

--------------------------------------------------

function EnemyAnimationController:Remove(enemy)

	self.Tracks[enemy] = nil
	self.State[enemy] = nil

end

return EnemyAnimationController