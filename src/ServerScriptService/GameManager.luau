local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local JarSystem = require(ReplicatedStorage.ManaJar)
local Targeting = require(ReplicatedStorage.Targeting)
local ManaScaling = require(ReplicatedStorage.ManaScaling)
local EffectApplier = require(ReplicatedStorage.EffectApplier)

local playerJars = {}
local targetingStates = {}

local function GetOrCreateJar(player)
	if playerJars[player] == nil then
		playerJars[player] = JarSystem.CreateJar(100)
	end
	return playerJars[player]
end

local function GetOrCreateTargetingState(_player)
	local state = Targeting.CreateState()
	Targeting.RegisterTarget(state, { id = "training_dummy", name = "Training Dummy", resistance = 10 })
	return state
end

local function MockLLMProvider()
	return {
		GenerateSpell = function(request)
			local scaleFactor, _ = ManaScaling.CalculateScaleFactor(request.manaInvested, request.targetResistance)
			local baseValue = 50
			local scaledValue = ManaScaling.ScaleValue(baseValue, scaleFactor)
			local classification = ManaScaling.ClassifyScale(scaleFactor)
			return {
				spellName = string.format("%s Blast", request.prompt),
				description = string.format("A %s spell targeting %s", classification, request.targetName),
				effectType = "damage",
				baseValue = baseValue,
				scaledValue = scaledValue,
			}
		end,
	}
end

local function OnPlayerCastSpell(player, spellIntent)
	local jar = GetOrCreateJar(player)
	local targetingState = GetOrCreateTargetingState(player)
	local target = Targeting.GetSelectedTarget(targetingState)
	if target == nil then
		return nil, "No target selected"
	end
	local mana = JarSystem.DrainJar(jar)
	if mana <= 0 then
		return nil, "Jar is empty"
	end
	local provider = MockLLMProvider()
	local request = {
		prompt = spellIntent,
		manaInvested = mana,
		targetName = target.name,
		targetResistance = target.resistance,
	}
	local spell = provider.GenerateSpell(request)
	if spell == nil then
		return nil, "Spell generation failed"
	end
	local result = EffectApplier.ApplyEffect(target.id, spell)
	Targeting.ClearSelection(targetingState)
	return result, nil
end

Players.PlayerAdded:Connect(function(player)
	playerJars[player] = JarSystem.CreateJar(100)
	targetingStates[player] = GetOrCreateTargetingState(player)
end)

Players.PlayerRemoving:Connect(function(player)
	playerJars[player] = nil
	targetingStates[player] = nil
end)

local MockAPI = {
	GetOrCreateJar = GetOrCreateJar,
	GetOrCreateTargetingState = GetOrCreateTargetingState,
	OnPlayerCastSpell = OnPlayerCastSpell,
	MockLLMProvider = MockLLMProvider,
}

return MockAPI
