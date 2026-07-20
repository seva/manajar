-- in-playtest: covered manually in Studio; no automated test infra for play mode
warn("[BOOTSTRAP-SERVER] Starting server initialization")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local platform = Instance.new("Part")
platform.Name = "Platform"
platform.Anchored = true
platform.Size = Vector3.new(100, 1, 100)
platform.Position = Vector3.new(0, -0.5, 0)
platform.BrickColor = BrickColor.new("Dark stone grey")
platform.TopSurface = Enum.SurfaceType.Smooth
platform.BottomSurface = Enum.SurfaceType.Smooth
platform.Parent = Workspace

local spawnLocation = Instance.new("SpawnLocation")
spawnLocation.Name = "SpawnLocation"
spawnLocation.Size = Vector3.new(4, 1, 4)
spawnLocation.Position = Vector3.new(0, 1, 0)
spawnLocation.BrickColor = BrickColor.new("Bright green")
spawnLocation.Anchored = true
spawnLocation.Duration = 0
spawnLocation.Neutral = true
spawnLocation.Parent = Workspace
warn("[BOOTSTRAP-SERVER] Platform and spawn created")

-- Create visible targets in the workspace
local function createTarget(name, position, color, resistance, maxHealth)
	local target = Instance.new("Part")
	target.Name = name
	target.Size = Vector3.new(3, 3, 3)
	target.Position = position
	target.Anchored = true
	target.BrickColor = BrickColor.new(color)
	target.Material = Enum.Material.SmoothPlastic
	target.Parent = Workspace
	
	-- Add health bar
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "HealthBar"
	billboard.Size = UDim2.new(4, 0, 0.5, 0)
	billboard.StudsOffset = Vector3.new(0, 2, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = target
	
	local barBg = Instance.new("Frame")
	barBg.Name = "Background"
	barBg.Size = UDim2.new(1, 0, 1, 0)
	barBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	barBg.BorderSizePixel = 0
	barBg.Parent = billboard
	
	local barFill = Instance.new("Frame")
	barFill.Name = "Fill"
	barFill.Size = UDim2.new(1, 0, 1, 0)
	barFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	barFill.BorderSizePixel = 0
	barFill.Parent = barBg
	
	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = name .. "\n" .. maxHealth .. " HP"
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextScaled = true
	label.Font = Enum.Font.SourceSansBold
	label.Parent = barBg
	
	return target
end

local trainingDummy = createTarget("Training Dummy", Vector3.new(10, 2, 0), "Bright yellow", 10, 100)
local stoneGolem = createTarget("Stone Golem", Vector3.new(-10, 2, 10), "Medium stone grey", 30, 200)
local fireImp = createTarget("Fire Imp", Vector3.new(0, 2, -15), "Bright red", 5, 50)
warn("[BOOTSTRAP-SERVER] Targets created")

require(script.Parent.SetupRemotes)
warn("[BOOTSTRAP-SERVER] Remotes initialized")

local GameManager = require(script.Parent.GameManager)
local JarSystem = require(ReplicatedStorage.ManaJar)
local Targeting = require(ReplicatedStorage.Targeting)

local remotes = ReplicatedStorage:WaitForChild("Remotes")

for _, player in Players:GetPlayers() do
	GameManager.GetOrCreateJar(player)
	GameManager.GetOrCreateTargetingState(player)
end

remotes.CastSpell.OnServerEvent:Connect(function(player, spellIntent)
	if typeof(spellIntent) ~= "string" then
		return
	end
	local result, err = GameManager.OnPlayerCastSpell(player, spellIntent)
	if result then
		remotes.UpdateJarDisplay:FireClient(player, {
			message = "Spell cast: " .. tostring(result.effectType or "unknown") .. " (" .. tostring(result.scaledValue or 0) .. ")",
			manaText = "0 / 100",
			fillPercent = 0,
		})
	else
		warn("Spell failed:", err)
		remotes.UpdateJarDisplay:FireClient(player, {
			message = "Failed: " .. tostring(err),
		})
	end
end)

remotes.FillJar.OnServerEvent:Connect(function(player, amount)
	if typeof(amount) ~= "number" then
		return
	end
	local jar = GameManager.GetOrCreateJar(player)
	JarSystem.FillJar(jar, amount)
	local fillRatio = JarSystem.GetFillRatio(jar)
	local mana = JarSystem.GetMana(jar)
	remotes.UpdateJarDisplay:FireClient(player, {
		fillPercent = fillRatio,
		manaText = string.format("%d / %d", mana, jar.maxMana),
		message = "Filled!",
	})
end)

remotes.SelectTarget.OnServerEvent:Connect(function(player, targetId)
	if typeof(targetId) ~= "string" then
		return
	end
	local state = GameManager.GetOrCreateTargetingState(player)
	local success, err = Targeting.SelectTarget(state, targetId)
	if not success then
		warn("Target selection failed:", err)
		remotes.UpdateJarDisplay:FireClient(player, {
			message = "Target failed: " .. tostring(err),
		})
	else
		remotes.UpdateJarDisplay:FireClient(player, {
			message = "Target selected: " .. targetId,
		})
	end
end)

warn("[BOOTSTRAP-SERVER] Server initialization complete")
