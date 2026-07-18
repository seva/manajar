local SpellCaster = require(script.Parent.Parent.Parent.src.ReplicatedStorage.SpellCaster)

return function()
	describe("SpellCaster.BuildPrompt", function()
		it("should include player intent, mana, target name, and resistance", function()
			local prompt = SpellCaster.BuildPrompt({
				prompt = "Fireball",
				manaInvested = 50,
				targetName = "Goblin",
				targetResistance = 20,
			})
			expect(prompt).toMatch("Fireball")
			expect(prompt).toMatch("50")
			expect(prompt).toMatch("Goblin")
			expect(prompt).toMatch("20")
		end)
	end)

	describe("SpellCaster.CastSpell", function()
		it("should return spell effect from provider", function()
			local mockProvider = {
				GenerateSpell = function(_request)
					return {
						spellName = "Test Spell",
						description = "A test spell",
						effectType = "damage",
						baseValue = 10,
						scaledValue = 25,
					}
				end,
			}
			local effect = SpellCaster.CastSpell(mockProvider, {
				prompt = "Test",
				manaInvested = 50,
				targetName = "Target",
				targetResistance = 10,
			})
			expect(effect).never.toEqual(nil)
			expect(effect.spellName).toEqual("Test Spell")
			expect(effect.effectType).toEqual("damage")
			expect(effect.scaledValue).toEqual(25)
		end)

		it("should return nil when provider fails", function()
			local mockProvider = {
				GenerateSpell = function(_request)
					return nil
				end,
			}
			local effect = SpellCaster.CastSpell(mockProvider, {
				prompt = "Test",
				manaInvested = 50,
				targetName = "Target",
				targetResistance = 10,
			})
			expect(effect).toEqual(nil)
		end)
	end)

	describe("SpellCaster.GetSystemPrompt", function()
		it("should return a non-empty system prompt", function()
			local prompt = SpellCaster.GetSystemPrompt()
			expect(type(prompt)).toEqual("string")
			expect(#prompt).never.toEqual(0)
		end)
	end)
end
