local function createMockGame()
	local mockInstances = {}
	local mockServices = {}

	local mockGame = {
		GetService = function(_, serviceName)
			if mockServices[serviceName] == nil then
				local mockService = {
					_childAddedConnections = {},
					_childRemovedConnections = {},
					_children = {},

					GetChildren = function(self)
						return self._children
					,

					FindFirstChild = function(self, name)
						for _, child in self._children do
							if child.Name == name then
								return child
							end
						end
						return nil
					,

					ChildAdded = function(self, cb)
						table.insert(self._childAddedConnections, cb)
					end,

					ChildRemoved = function(self, cb)
						table.insert(self._childRemovedConnections, cb)
					end,
				}
				mockService.Name = serviceName
				mockServices[serviceName] = mockService
			end
			return mockServices[serviceName]
		end,
	}
	return mockGame, mockServices
end

local function createMockPlayer(name)
	return {
		Name = name,
		UserId = tostring(name),
		_events = {},
	}
end

local function createMockInstance()
	local inst = {
		Name = "",
		Parent = nil,
		_events = {},
	}
	return inst
end

local mockGame, mockServices = createMockGame()
local mockReplicatedStorage = Instance.new("Folder")
mockReplicatedStorage.Name = "ReplicatedStorage"
mockReplicatedStorage.Parent = mockGame.GetService(mockGame, "ReplicatedStorage")
_G.game = mockGame

local ReplicatedStorage = mockGame:GetService("ReplicatedStorage")

local ManaJar = {
	CreateJar = function(_, maxMana)
		return { mana = 0, maxMana = maxMana, targetId = nil }
	end,
	FillJar = function(_, jar, amount)
		jar.mana = math.min(jar.mana + amount, jar.maxMana)
		return true, jar.mana
	end,
	DrainJar = function(_, jar)
		local drained = jar.mana
		jar.mana = 0
		return drained
	end,
}

ReplicatedStorage.ManaJar = ManaJar

local Targeting = {
	CreateState = function()
		return { availableTargets = {}, selectedTargetId = nil }
	end,
	RegisterTarget = function(_, state, target)
		state.availableTargets[target.id] = target
		return true
	end,
	SelectTarget = function(_, state, id)
		state.selectedTargetId = id
		return true
	end,
	GetSelectedTarget = function(_, state)
		return state.availableTargets[state.selectedTargetId]
	end,
	ClearSelection = function(_, state)
		state.selectedTargetId = nil
	end,
}

ReplicatedStorage.Targeting = Targeting

local ManaScaling = {
	CalculateScaleFactor = function(_, mana, resistance)
		return 1.0
	end,
	ScaleValue = function(_, base, factor)
		return base * factor
	end,
	ClassifyScale = function(_, factor)
		return "neutral"
	end,
}

ReplicatedStorage.ManaScaling = ManaScaling

local EffectApplier = {
	ApplyEffect = function(_, targetId, effect)
		return {
			targetId = targetId,
			effectType = effect.effectType,
			appliedValue = effect.scaledValue,
			success = true,
			message = effect.spellName .. " applied",
		}
	end,
}

ReplicatedStorage.EffectApplier = EffectApplier

local GameManager = require(script.Parent.Parent.Parent.src.ServerScriptService.GameManager)

return function()
	describe("GameManager.GetOrCreateJar", function()
		it("should create a jar for a new player", function()
			local player = createMockPlayer("TestPlayer1")
			local jar = GameManager.GetOrCreateJar(player)
			expect(jar).never.toEqual(nil)
			expect(jar.mana).toEqual(0)
			expect(jar.maxMana).toEqual(100)
		end)

		it("should return existing jar for known player", function()
			local player = createMockPlayer("TestPlayer2")
			local jar1 = GameManager.GetOrCreateJar(player)
			JarSystem.FillJar(jar1, 50)
			local jar2 = GameManager.GetOrCreateJar(player)
			expect(jar2).toEqual(jar1)
			expect(jar2.mana).toEqual(50)
		end)
	end)

	describe("GameManager.MockLLMProvider", function()
		it("should generate a spell with the given prompt", function()
			local provider = GameManager.MockLLMProvider()
			local spell = provider.GenerateSpell({
				prompt = "Fireball",
				manaInvested = 50,
				targetName = "Dummy",
				targetResistance = 10,
			})
			expect(spell).never.toEqual(nil)
			expect(spell.spellName).toMatch("Fireball")
			expect(spell.effectType).toEqual("damage")
		end)
	end)

	describe("GameManager.OnPlayerCastSpell", function()
		it("should fail when no target selected", function()
			local player = createMockPlayer("Caster1")
			local result, err = GameManager.OnPlayerCastSpell(player, "Fireball")
			expect(result).toEqual(nil)
			expect(err).toEqual("No target selected")
		end)

		end)

		it("should fail when jar is empty and target is selected", function()
			local player = createMockPlayer("Caster2")
			local jar = GameManager.GetOrCreateJar(player)
			local state = GameManager.GetOrCreateTargetingState(player)
			Targeting.SelectTarget(state, "training_dummy")
			local result, err = GameManager.OnPlayerCastSpell(player, "Fireball")
			expect(result).toEqual(nil)
			expect(err).toEqual("Jar is empty")
		end)
	end)
end)
end
