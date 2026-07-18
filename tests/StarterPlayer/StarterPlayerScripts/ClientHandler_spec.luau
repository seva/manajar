local mockR = 0; local mockG = 0; local mockB = 0
_G.Color3 = {
	fromRGB = function(r, g, b)
		mockR = r; mockG = g; mockB = b
		return { R = r, G = g, B = b }
	end,
}

local function makeMockRemoteEvents()
	return {
		FillJar = { fireCount = 0, lastArgs = nil, FireServer = function(self, ...) self.fireCount += 1; self.lastArgs = {...} end },
		CastSpell = { fireCount = 0, lastArgs = nil, FireServer = function(self, ...) self.fireCount += 1; self.lastArgs = {...} end },
		SelectTarget = { fireCount = 0, lastArgs = nil, FireServer = function(self, ...) self.fireCount += 1; self.lastArgs = {...} end },
		UpdateJarDisplay = { fireCount = 0, lastArgs = nil, OnServerEvent = { Connect = function() end } },
	}
end

local ClientHandler = require(script.Parent.Parent.Parent.src.StarterPlayer.StarterPlayerScripts.ClientHandler)

return function()
	describe("ClientHandler.Create", function()
		it("should create a handler with default values", function()
			local handler = ClientHandler.Create(makeMockRemoteEvents())
			expect(handler).never.toEqual(nil)
			expect(handler.config.fillRate).toEqual(10)
			expect(handler.config.maxMana).toEqual(100)
		end)

		it("should create a handler with custom config", function()
			local handler = ClientHandler.Create(makeMockRemoteEvents(), { fillRate = 25, maxMana = 200 })
			expect(handler.config.fillRate).toEqual(25)
			expect(handler.config.maxMana).toEqual(200)
		end)
	end)

	describe("ClientHandler.StartFill / StopFill", function()
		it("should start accumulating mana and stop without firing if no accumulation", function()
			local remotes = makeMockRemoteEvents()
			local handler = ClientHandler.Create(remotes)
			ClientHandler.StartFill(handler)
			ClientHandler.StopFill(handler)
			expect(remotes.FillJar.fireCount).toEqual(0)
		end)
	end)

	describe("ClientHandler.CastSpell", function()
		it("should fire CastSpell RemoteEvent with spell intent", function()
			local remotes = makeMockRemoteEvents()
			local handler = ClientHandler.Create(remotes)
			ClientHandler.CastSpell(handler, "Fireball")
			expect(remotes.CastSpell.fireCount).toEqual(1)
			expect(remotes.CastSpell.lastArgs[1]).toEqual("Fireball")
		end)
	end)

	describe("ClientHandler.SelectTarget", function()
		it("should fire SelectTarget RemoteEvent with target ID", function()
			local remotes = makeMockRemoteEvents()
			local handler = ClientHandler.Create(remotes)
			ClientHandler.SelectTarget(handler, "training_dummy")
			expect(remotes.SelectTarget.fireCount).toEqual(1)
			expect(remotes.SelectTarget.lastArgs[1]).toEqual("training_dummy")
		end)
	end)

	describe("ClientHandler.OnUpdateJar", function()
		it("should update jar state and return latest display", function()
			local remotes = makeMockRemoteEvents()
			local handler = ClientHandler.Create(remotes)
			local display = ClientHandler.OnUpdateJar(handler, { fillPercent = 50, manaText = "50 / 100", barColor = Color3.fromRGB(50, 150, 255) })
			expect(display.fillPercent).toEqual(50)
			expect(display.manaText).toEqual("50 / 100")
			expect(handler.latestDisplay).toEqual(display)
		end)
	end)

	describe("ClientHandler.GetLatestDisplay", function()
		it("should return nil before any update", function()
			local remotes = makeMockRemoteEvents()
			local handler = ClientHandler.Create(remotes)
			expect(ClientHandler.GetLatestDisplay(handler)).toEqual(nil)
		end)

		it("should return the latest display after update", function()
			local remotes = makeMockRemoteEvents()
			local handler = ClientHandler.Create(remotes)
			local display = { fillPercent = 75, manaText = "75 / 100", barColor = Color3.fromRGB(50, 255, 100) }
			ClientHandler.OnUpdateJar(handler, display)
			expect(ClientHandler.GetLatestDisplay(handler)).toEqual(display)
		end)
	end)
end
