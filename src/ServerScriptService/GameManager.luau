local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local JarSystem = require(ReplicatedStorage.ManaJar)
local Targeting = require(ReplicatedStorage.Targeting)
local ManaScaling = require(ReplicatedStorage.ManaScaling)
local EffectApplier = require(ReplicatedStorage.EffectApplier)
local LLMProvider = require(script.Parent.LLMProvider)

local playerJars = {}
local targetingStates = {}

local function GetOrCreateJar(player)
	if playerJars[player] == nil then
		playerJars[player] = JarSystem.CreateJar(100)
	end
	return playerJars[player]
end

local function GetOrCreateTargetingState(player)
	if targetingStates[player] == nil then
		local state = Targeting.CreateState()
		Targeting.RegisterTarget(state, { id = "Training Dummy", name = "Training Dummy", resistance = 10 })
		Targeting.RegisterTarget(state, { id = "Stone Golem", name = "Stone Golem", resistance = 30 })
		Targeting.RegisterTarget(state, { id = "Fire Imp", name = "Fire Imp", resistance = 5 })
		targetingStates[player] = state
	end
	return targetingStates[player]
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
	local request = {
		prompt = spellIntent,
		manaInvested = mana,
		targetName = target.name,
		targetResistance = target.resistance,
	}
	local spell, err = LLMProvider.GenerateSpell(player.UserId, request)
	if spell == nil then
		return nil, err or "Spell generation failed"
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

local API = {
	GetOrCreateJar = GetOrCreateJar,
	GetOrCreateTargetingState = GetOrCreateTargetingState,
	OnPlayerCastSpell = OnPlayerCastSpell,
	GetProviderInfo = LLMProvider.GetProviderInfo,
	DisconnectProvider = LLMProvider.DisconnectProvider,
}

return API
