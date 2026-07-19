local TestService = game:GetService("TestService")

local framework = game:GetService("ReplicatedStorage"):FindFirstChild("test-framework")
local TestFramework
if framework then
	TestFramework = require(framework)
else
	warn("test-framework not found")
	return
end

local SKIP_TESTS = {
	["SetupRemotes_spec"] = "monkey-patches Instance.new (read-only in Studio)",
	["GameManager_spec"] = "syntax errors + _G.game mock incompatible with Studio",
}

local function runTestFile(testModule)
	local testFn = require(testModule)
	if typeof(testFn) == "function" then
		testFn(TestFramework.describe, TestFramework.it, TestFramework.expect)
	else
		warn("Test module did not return a function:", testModule:GetFullName())
	end
end

local function findTests(parent, results)
	results = results or {}
	for _, child in parent:GetChildren() do
		if child:IsA("ModuleScript") and child.Name:match("_spec$") then
			table.insert(results, child)
		end
		if #child:GetChildren() > 0 then
			findTests(child, results)
		end
	end
	return results
end

local testsFolder = game:GetService("ReplicatedStorage"):FindFirstChild("tests")
if not testsFolder then
	warn("No tests folder found in ReplicatedStorage")
	return
end

local tests = findTests(testsFolder)
print(string.format("Found %d test files", #tests))

local passed = 0
local failed = 0
local skipped = 0

for _, test in tests do
	if SKIP_TESTS[test.Name] then
		skipped = skipped + 1
		print("SKIP:", test.Name, "-", SKIP_TESTS[test.Name])
	else
		local success, err = pcall(runTestFile, test)
		if success then
			passed = passed + 1
			print("PASS:", test.Name)
		else
			failed = failed + 1
			warn("FAIL:", test.Name, "-", err)
		end
	end
end

print(string.format("\nResults: %d passed, %d failed, %d skipped", passed, failed, skipped))
return { passed = passed, failed = failed, skipped = skipped }
