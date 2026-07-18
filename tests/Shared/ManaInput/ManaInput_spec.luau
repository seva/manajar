local ManaInput = require(script.Parent.Parent.Parent.src.ReplicatedStorage.ManaInput)

return function()
	describe("ManaInput.CreateInputHandler", function()
		it("should create handler with default config", function()
			local handler = ManaInput.CreateInputHandler()
			expect(handler.fillRate).toEqual(10)
			expect(handler.maxMana).toEqual(100)
			expect(handler.accumulatedInput).toEqual(0)
		end)

		it("should create handler with custom config", function()
			local handler = ManaInput.CreateInputHandler({ fillRate = 25, maxMana = 200 })
			expect(handler.fillRate).toEqual(25)
			expect(handler.maxMana).toEqual(200)
		end)
	end)

	describe("ManaInput.ProcessInput", function()
		it("should accumulate input based on delta and fill rate", function()
			local handler = ManaInput.CreateInputHandler({ fillRate = 10, maxMana = 100 })
			local ok, acc = ManaInput.ProcessInput(handler, 1)
			expect(ok).toEqual(true)
			expect(acc).toEqual(10)
		end)

		it("should accumulate over multiple ticks", function()
			local handler = ManaInput.CreateInputHandler({ fillRate = 10, maxMana = 100 })
			ManaInput.ProcessInput(handler, 1)
			ManaInput.ProcessInput(handler, 2)
			expect(ManaInput.GetAccumulated(handler)).toEqual(30)
		end)

		it("should not exceed maxMana", function()
			local handler = ManaInput.CreateInputHandler({ fillRate = 10, maxMana = 50 })
			ManaInput.ProcessInput(handler, 10)
			expect(ManaInput.GetAccumulated(handler)).toEqual(50)
		end)

		it("should reject non-positive inputDelta", function()
			local handler = ManaInput.CreateInputHandler()
			local ok, _ = ManaInput.ProcessInput(handler, 0)
			expect(ok).toEqual(false)
			local ok2, _ = ManaInput.ProcessInput(handler, -1)
			expect(ok2).toEqual(false)
		end)
	end)

	describe("ManaInput.ResetInput", function()
		it("should reset accumulated input and return previous value", function()
			local handler = ManaInput.CreateInputHandler({ fillRate = 10, maxMana = 100 })
			ManaInput.ProcessInput(handler, 3)
			local value = ManaInput.ResetInput(handler)
			expect(value).toEqual(30)
			expect(ManaInput.GetAccumulated(handler)).toEqual(0)
		end)
	end)

	describe("ManaInput.FillJarFromInput", function()
		it("should fill jar from accumulated input", function()
			local jarSystem = {
				FillJar = function(_, jar, amount)
					jar.mana = jar.mana + amount
					return true, jar.mana
				end,
			}
			local jar = { mana = 0, maxMana = 100, targetId = nil }
			local handler = ManaInput.CreateInputHandler({ fillRate = 10, maxMana = 100 })
			ManaInput.ProcessInput(handler, 5)
			local ok, mana = ManaInput.FillJarFromInput(handler, jar, jarSystem)
			expect(ok).toEqual(true)
			expect(mana).toEqual(50)
			expect(ManaInput.GetAccumulated(handler)).toEqual(0)
		end)

		it("should return false when no input accumulated", function()
			local handler = ManaInput.CreateInputHandler()
			local ok, mana = ManaInput.FillJarFromInput(handler, {}, { FillJar = function() return true, 0 end })
			expect(ok).toEqual(false)
			expect(mana).toEqual(0)
		end)
	end)
end
