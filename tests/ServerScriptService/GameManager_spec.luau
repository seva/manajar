-- GameManager_spec: cast-path wiring against real modules in Studio context.
-- The LLM provider is stubbed: external API, the only sanctioned mock target
-- (AGENTS.md test authenticity deviation). Everything else is the real module.

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameManager = require(ServerScriptService:WaitForChild("GameManager"))
local ManaJar = require(ReplicatedStorage:WaitForChild("ManaJar"))
local Targeting = require(ReplicatedStorage:WaitForChild("Targeting"))
local ManaScaling = require(ReplicatedStorage:WaitForChild("ManaScaling"))

local nextUserId = 9000

local function createMockPlayer()
	nextUserId += 1
	return { Name = "Tester" .. nextUserId, UserId = nextUserId }
end

local function baseSpell()
	return {
		spellName = "Test Fireball",
		description = "A test spell",
		effectType = "damage",
		baseValue = 30,
		scaledValue = 999, -- adversarial: must be overridden by ManaScaling, never passed through
	}
end

local function createStubProvider(spellOrNil, errOrNil)
	local calls = {}
	return {
		calls = calls,
		GenerateSpell = function(userId, request)
			table.insert(calls, { userId = userId, request = request })
			if spellOrNil == nil then
				return nil, errOrNil or "stub failure"
			end
			local spell = {}
			for k, v in pairs(spellOrNil) do
				spell[k] = v
			end
			return spell
		end,
	}
end

local function preparedPlayer(mana)
	local player = createMockPlayer()
	local jar = GameManager.GetOrCreateJar(player)
	ManaJar.FillJar(jar, mana)
	local state = GameManager.GetOrCreateTargetingState(player)
	Targeting.SelectTarget(state, "Training Dummy") -- resistance 10
	return player, jar, state
end

return function(describe, it, expect)
	describe("GameManager.GetOrCreateJar", function()
		it("should create a jar for a new player", function()
			local jar = GameManager.GetOrCreateJar(createMockPlayer())
			expect(jar).never.toEqual(nil)
			expect(jar.mana).toEqual(0)
			expect(jar.maxMana).toEqual(100)
		end)

		it("should return the existing jar for a known player", function()
			local player = createMockPlayer()
			local jar1 = GameManager.GetOrCreateJar(player)
			ManaJar.FillJar(jar1, 50)
			local jar2 = GameManager.GetOrCreateJar(player)
			expect(jar2.mana).toEqual(50)
		end)
	end)

	describe("GameManager.OnPlayerCastSpell guards", function()
		it("should fail when no target selected", function()
			local player = createMockPlayer()
			local result, err = GameManager.OnPlayerCastSpell(player, "Fireball", createStubProvider(baseSpell()))
			expect(result).toEqual(nil)
			expect(err).toEqual("No target selected")
		end)

		it("should fail when jar is empty", function()
			local player = createMockPlayer()
			local state = GameManager.GetOrCreateTargetingState(player)
			Targeting.SelectTarget(state, "Training Dummy")
			local result, err = GameManager.OnPlayerCastSpell(player, "Fireball", createStubProvider(baseSpell()))
			expect(result).toEqual(nil)
			expect(err).toEqual("Jar is empty")
		end)

		it("should propagate provider failure", function()
			local player = preparedPlayer(20)
			local result, err = GameManager.OnPlayerCastSpell(player, "Fireball", createStubProvider(nil, "provider down"))
			expect(result).toEqual(nil)
			expect(err).toEqual("provider down")
		end)
	end)

	describe("GameManager.OnPlayerCastSpell scaling", function()
		it("should scale the LLM base value by mana vs resistance, overriding LLM-supplied scaledValue", function()
			local player = preparedPlayer(50)
			local stub = createStubProvider(baseSpell())
			local result, err = GameManager.OnPlayerCastSpell(player, "Fireball", stub)
			expect(err).toEqual(nil)
			expect(result).never.toEqual(nil)

			-- same code path as production: ComputeSpellEffect(baseValue=30, mana=50, resistance=10)
			local expectedFactor, expectedScaled, expectedClass = ManaScaling.ComputeSpellEffect(30, 50, 10)
			expect(result.scaleFactor).toEqual(expectedFactor)
			expect(result.appliedValue).toEqual(math.floor(expectedScaled))
			expect(result.classification).toEqual(expectedClass)
			expect(result.classification).toEqual("very_strong") -- 50/(50+10)*2 = 1.667 > 1.5
			-- the adversarial LLM-supplied 999 must not survive
			expect(result.appliedValue == 999).toEqual(false)
		end)

		it("should pass mana and resistance to the provider request", function()
			local player = preparedPlayer(40)
			local stub = createStubProvider(baseSpell())
			GameManager.OnPlayerCastSpell(player, "Fireball", stub)
			expect(#stub.calls).toEqual(1)
			expect(stub.calls[1].request.manaInvested).toEqual(40)
			expect(stub.calls[1].request.targetResistance).toEqual(10)
		end)

		it("should return a Feedback display built from the classification", function()
			local player = preparedPlayer(50)
			local result = GameManager.OnPlayerCastSpell(player, "Fireball", createStubProvider(baseSpell()))
			expect(result.display).never.toEqual(nil)
			expect(result.display.title).toMatch("Test Fireball")
			expect(result.display.details[1]).toMatch("Scale:")
			expect(result.display.details[2]).toMatch("Power:")
		end)

		it("should drain the jar and clear the selection after a cast", function()
			local player, jar, state = preparedPlayer(50)
			GameManager.OnPlayerCastSpell(player, "Fireball", createStubProvider(baseSpell()))
			expect(jar.mana).toEqual(0)
			expect(Targeting.GetSelectedTarget(state)).toEqual(nil)
		end)
	end)
end
