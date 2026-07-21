-- tests/ServerScriptService/LLMProvider/init_spec.luau
-- NOTE: LLMProvider tests require a published place and cannot run in Studio
-- These tests are skipped in Studio and should be run as integration tests in production
return function(describe, it, expect)
	describe("LLMProvider", function()
		it("should skip DataStore-dependent tests in Studio (requires published place)", function()
			-- This test documents that LLMProvider operations require a published place
			-- Real testing happens in production or with mocked DataStore
			-- Skipping this test intentionally
		end)
	end)
end
