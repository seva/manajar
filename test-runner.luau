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

local filesPassed = 0
local filesFailed = 0
local skipped = 0

for _, test in tests do
	if SKIP_TESTS[test.Name] then
		skipped = skipped + 1
		print("SKIP:", test.Name, "-", SKIP_TESTS[test.Name])
	else
		local success, err = pcall(runTestFile, test)
		if success then
			filesPassed = filesPassed + 1
			print("PASS:", test.Name)
		else
			filesFailed = filesFailed + 1
			warn("FAIL:", test.Name, "-", err)
		end
	end
end

-- Assertion-level results: it() catches failures internally; a file "PASS"
-- above only proves it loaded. The suite fails if ANY assertion failed.
local results = TestFramework.getResults()
for _, e in ipairs(results.errors) do
	warn("FAILED ASSERTION:", e)
end

print(string.format("\nFiles: %d loaded, %d failed to load, %d skipped", filesPassed, filesFailed, skipped))
print(string.format("Tests: %d passed, %d failed", results.passed, results.failed))

local totalFailed = filesFailed + results.failed
print(string.format("Results: %d passed, %d failed, %d skipped", filesPassed, totalFailed, skipped))
return {
	passed = filesPassed,
	failed = totalFailed,
	skipped = skipped,
	testsPassed = results.passed,
	testsFailed = results.failed,
}
