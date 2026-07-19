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
			message = "Spell cast: " .. tostring(result),
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
