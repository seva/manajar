local TestFramework = {}

local testResults = {
	passed = 0,
	failed = 0,
	errors = {},
}

function TestFramework.describe(name, fn)
	print("  " .. name)
	fn()
end

function TestFramework.it(name, fn)
	local success, err = pcall(fn)
	if success then
		testResults.passed = testResults.passed + 1
		print("    ✓ " .. name)
	else
		testResults.failed = testResults.failed + 1
		table.insert(testResults.errors, name .. ": " .. tostring(err))
		print("    ✗ " .. name .. " - " .. tostring(err))
	end
end

function TestFramework.expect(actual)
	local matcher = {}
	
	function matcher.toEqual(expected)
		if actual ~= expected then
			error(string.format("Expected %s to equal %s", tostring(actual), tostring(expected)), 2)
		end
	end
	
	function matcher.toThrow()
		if typeof(actual) ~= "function" then
			error("Expected a function for toThrow()", 2)
		end
		local success = pcall(actual)
		if success then
			error("Expected function to throw", 2)
		end
	end
	
	function matcher.toContain(expected)
		if typeof(actual) ~= "table" then
			error("Expected a table for toContain()", 2)
		end
		for _, v in actual do
			if v == expected then
				return
			end
		end
		error(string.format("Expected table to contain %s", tostring(expected)), 2)
	end
	
	function matcher.toMatch(pattern)
		if typeof(actual) ~= "string" then
			error("Expected a string for toMatch()", 2)
		end
		if not string.find(actual, pattern) then
			error(string.format("Expected '%s' to match pattern '%s'", actual, pattern), 2)
		end
	end
	
	matcher.never = {
		toEqual = function(expected)
			if actual == expected then
				error(string.format("Expected %s to never equal %s", tostring(actual), tostring(expected)), 2)
			end
		end,
	}
	
	return matcher
end

function TestFramework.getResults()
	return testResults
end

function TestFramework.reset()
	testResults.passed = 0
	testResults.failed = 0
	testResults.errors = {}
end

_G.describe = TestFramework.describe
_G.it = TestFramework.it
_G.expect = TestFramework.expect

return TestFramework
