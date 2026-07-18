local createdInstances = {}
local mockGame = {
	GetService = function(_, name)
		local svc = { Name = name, _children = {} }
		return svc
	end,
}

local origNew = Instance.new
Instance.new = function(className)
	local inst = {
		Name = "",
		ClassName = className,
		Parent = nil,
	}
	table.insert(createdInstances, inst)
	return inst
end

_G.game = mockGame

require(script.Parent.Parent.Parent.src.ServerScriptService.SetupRemotes)

Instance.new = origNew

return function()
	describe("SetupRemotes", function()
		it("should create RemoteEvents in ReplicatedStorage", function()
			local remoteEvents = {}
			for _, inst in createdInstances do
				if inst.ClassName == "RemoteEvent" then
					table.insert(remoteEvents, inst.Name)
				end
			end
			expect(#remoteEvents).toEqual(4)
			expect(remoteEvents).toContain("FillJar")
			expect(remoteEvents).toContain("CastSpell")
			expect(remoteEvents).toContain("SelectTarget")
			expect(remoteEvents).toContain("UpdateJarDisplay")
		end)
	end)
end
