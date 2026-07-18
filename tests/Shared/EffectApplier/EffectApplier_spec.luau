local EffectApplier = require(script.Parent.Parent.Parent.src.ReplicatedStorage.EffectApplier)

return function()
	describe("EffectApplier.ApplyEffect", function()
		it("should apply damage effect to target", function()
			local result = EffectApplier.ApplyEffect("goblin_1", {
				spellName = "Fireball",
				description = "A fireball",
				effectType = "damage",
				baseValue = 50,
				scaledValue = 100,
			})
			expect(result.success).toEqual(true)
			expect(result.targetId).toEqual("goblin_1")
			expect(result.effectType).toEqual("damage")
			expect(result.appliedValue).toEqual(100)
			expect(result.message).toMatch("Fireball")
			expect(result.message).toMatch("goblin_1")
		end)

		it("should apply effect with duration", function()
			local result = EffectApplier.ApplyEffect("orc_1", {
				spellName = "Freeze",
				description = "Freezes target",
				effectType = "stun",
				baseValue = 1,
				scaledValue = 3,
				duration = 2,
			})
			expect(result.success).toEqual(true)
			expect(result.duration).toEqual(2)
			expect(result.appliedValue).toEqual(3)
		end)
	end)

	describe("EffectApplier.GenerateEffectSummary", function()
		it("should generate summary from multiple effects", function()
			local summary = EffectApplier.GenerateEffectSummary({
				{
					targetId = "goblin_1",
					effectType = "damage",
					appliedValue = 50,
					success = true,
					message = "Fireball deals 50 damage to goblin_1",
				},
				{
					targetId = "goblin_1",
					effectType = "stun",
					appliedValue = 1,
					success = true,
					duration = 2,
					message = "Freeze stuns goblin_1 for 2s",
				},
			})
			expect(summary).toMatch("Fireball")
			expect(summary).toMatch("Freeze")
		end)
	end)
end
