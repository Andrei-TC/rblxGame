-- SERVICES
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local AttackHit = Remotes:WaitForChild("AttackHit")

-- CONFIG
local AnimationConfig = require(ReplicatedStorage.Config.Combat.AnimationConfig)

-- CHARACTER
local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")
local animator = humanoid:WaitForChild("Animator")
local animateScript = character:WaitForChild("Animate")

-- VARIABLES
local currentWeapon = "Fists"

local idleTrack
local attackTracks = {}

local combo = 1
local attacking = false
local holdingAttack = false

local normalSpeed = 16
local combatSpeed = 7

local canQueueNext = false
local queuedNext = false


--------------------------------------------------
-- LOAD ANIMATIONS
--------------------------------------------------

local function loadAnimations()

	if idleTrack then
		idleTrack:Stop()
	end

	for _,track in pairs(attackTracks) do
		track:Stop()
	end

	attackTracks = {}

	local config = AnimationConfig[currentWeapon]

	-- IDLE
	local idleAnim = Instance.new("Animation")
	idleAnim.AnimationId = config.Idle

	idleTrack = animator:LoadAnimation(idleAnim)
	idleTrack.Priority = Enum.AnimationPriority.Movement
	idleTrack.Looped = true
	idleTrack:Play()

	-- ATTACKS
	for _,id in ipairs(config.Attacks) do

		local anim = Instance.new("Animation")
		anim.AnimationId = id

		local track = animator:LoadAnimation(anim)
		track.Priority = Enum.AnimationPriority.Action

		table.insert(attackTracks, track)
	end
	

end


--------------------------------------------------
-- ATTACK SYSTEM
--------------------------------------------------

local function playAttack()
	--print("Playing combo:", combo)
	attacking = true
	canQueueNext = false
	queuedNext = false

	local track = attackTracks[combo]

	if not track then
		return
	end
	track.TimePosition = 0
	track:Play()
	
	
	-- HIT MARKER
	track:GetMarkerReachedSignal("HIT"):Once(function()

		-- HITSTOP
		local oldSpeed = track.Speed
		track:AdjustSpeed(0)

		task.delay(0.03, function()
			track:AdjustSpeed(oldSpeed)
		end)

		-- FORWARD DASH
		local root = character:FindFirstChild("HumanoidRootPart")
		if root then

			root:ApplyImpulse(root.CFrame.LookVector * 200)

		end

		-- DAMAGE
		AttackHit:FireServer(combo, currentWeapon)

	end)

	-- COMBO WINDOW
	track:GetMarkerReachedSignal("ComboWindow"):Once(function()

		canQueueNext = true

		if holdingAttack then
			queuedNext = true
		end

	end)

	-- WHEN ANIMATION STOPS
	track.Stopped:Once(function()

		if queuedNext then

			combo += 1
			if combo > #attackTracks then
				combo = 1
			end

			playAttack()

		else

			attacking = false
			combo = 1
			humanoid.WalkSpeed = normalSpeed

		end

	end)

end

-- Update
local function updateAnimate()

	local animate = character:FindFirstChild("Animate")
	if not animate then return end

	if currentWeapon == "Sword" then

		animate.idle.Animation1.AnimationId = AnimationConfig.Sword.Idle
		animate.idle.Animation2.AnimationId = AnimationConfig.Sword.Idle

	else

		animate.idle.Animation1.AnimationId = AnimationConfig.Fists.Idle
		animate.idle.Animation2.AnimationId = AnimationConfig.Fists.Idle

	end

end
--------------------------------------------------
-- INPUT
--------------------------------------------------

UIS.InputBegan:Connect(function(input, processed)

	if processed then return end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then

		holdingAttack = true

		if not attacking then

			humanoid.WalkSpeed = combatSpeed
			playAttack()

		end

	end

end)


UIS.InputEnded:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		holdingAttack = false
	end

end)


--------------------------------------------------
-- WEAPON CHANGE
--------------------------------------------------

character:GetAttributeChangedSignal("WeaponType"):Connect(function()

	currentWeapon = character:GetAttribute("WeaponType") or "Fists"

	combo = 1
	attacking = false
	holdingAttack = false

	updateAnimate()
	loadAnimations()

end)


--------------------------------------------------
-- START
--------------------------------------------------

updateAnimate()
loadAnimations()