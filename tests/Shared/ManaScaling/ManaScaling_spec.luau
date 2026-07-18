local ManaScaling = require(script.Parent.Parent.Parent.src.ReplicatedStorage.ManaScaling)

return function()
	describe("ManaScaling.CalculateScaleFactor", function()
		it("should return 1.0 when mana equals resistance", function()
			local scale = ManaScaling.CalculateScaleFactor(50, 50)
			expect(scale).toEqual(1)
		end)

		it("should return >1 when mana exceeds resistance", function()
			local scale = ManaScaling.CalculateScaleFactor(100, 50)
			expect(scale).never.toEqual(nil)
			expect(scale > 1).toEqual(true)
		end)

		it("should return <1 when mana is less than resistance", function()
			local scale = ManaScaling.CalculateScaleFactor(50, 100)
			expect(scale < 1).toEqual(true)
		end)

		it("should return 0 when no mana invested", function()
			local scale = ManaScaling.CalculateScaleFactor(0, 50)
			expect(scale).toEqual(0)
		end)

		it("should return 2 when target has no resistance", function()
			local scale = ManaScaling.CalculateScaleFactor(50, 0)
			expect(scale).toEqual(2)
		end)
	end)

	describe("ManaScaling.ClassifyScale", function()
		it("should classify weak", function()
			expect(ManaScaling.ClassifyScale(0.3)).toEqual("weak")
		end)

		it("should classify slightly_weak", function()
			expect(ManaScaling.ClassifyScale(0.7)).toEqual("slightly_weak")
		end)

		it("should classify neutral", function()
			expect(ManaScaling.ClassifyScale(1.0)).toEqual("neutral")
		end)

		it("should classify strong", function()
			expect(ManaScaling.ClassifyScale(1.3)).toEqual("strong")
		end)

		it("should classify very_strong", function()
			expect(ManaScaling.ClassifyScale(2.0)).toEqual("very_strong")
		end)
	end)

	describe("ManaScaling.ComputeSpellEffect", function()
		it("should compute scale factor, scaled value, and classification", function()
			local scaleFactor, scaledValue, classification = ManaScaling.ComputeSpellEffect(100, 50, 50)
			expect(scaleFactor).toEqual(1)
			expect(scaledValue).toEqual(100)
			expect(classification).toEqual("neutral")
		end)

		it("should compute stronger effect with more mana", function()
			local _, scaledValue, classification = ManaScaling.ComputeSpellEffect(100, 100, 50)
			expect(scaledValue > 100).toEqual(true)
			expect(classification).toEqual("strong")
		end)
	end)
end
