local HttpService = game:GetService("HttpService")

local CredentialStore = require(script.Parent.CredentialStore)
local SpellCaster = require(game.ReplicatedStorage.SpellCaster)
local Warding = require(game.ReplicatedStorage.SpellCaster.Warding)

local LLMProvider = {}

local RATE_LIMIT_SECONDS = 5
local lastCallTime = {}

local function checkRateLimit(userId: number)
	local now = os.time()
	local lastTime = lastCallTime[userId] or 0

	if now - lastTime < RATE_LIMIT_SECONDS then
		return false, "Rate limit: please wait " .. (RATE_LIMIT_SECONDS - (now - lastTime)) .. " seconds"
	end

	lastCallTime[userId] = now
	return true
end

local function callGeminiAPI(accessToken: string, prompt: string, systemPrompt: string)
	local url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent"

	local body = {
		contents = {
			{
				role = "user",
				parts = {
					{ text = prompt }
				}
			}
		},
		systemInstruction = {
			parts = {
				{ text = systemPrompt }
			}
		}
	}

	local headers = {
		["Authorization"] = "Bearer " .. accessToken,
		["Content-Type"] = "application/json"
	}

	local success, response = pcall(function()
		return HttpService:PostAsync(
			url,
			HttpService:JSONEncode(body),
			Enum.HttpContentType.ApplicationJson,
			false,
			headers
		)
	end)

	if not success then
		return nil, "Gemini API error: " .. tostring(response)
	end

	local decoded = HttpService:JSONDecode(response)

	if decoded.candidates and decoded.candidates[1] and decoded.candidates[1].content then
		local text = decoded.candidates[1].content.parts[1].text
		return text
	else
		return nil, "No response from Gemini"
	end
end

local function callGrokAPI(accessToken: string, prompt: string, systemPrompt: string)
	local url = "https://api.x.ai/v1/chat/completions"

	local body = {
		model = "grok-2-latest",
		messages = {
			{
				role = "system",
				content = systemPrompt
			},
			{
				role = "user",
				content = prompt
			}
		},
		temperature = 0.7,
		max_tokens = 1000
	}

	local headers = {
		["Authorization"] = "Bearer " .. accessToken,
		["Content-Type"] = "application/json"
	}

	local success, response = pcall(function()
		return HttpService:PostAsync(
			url,
			HttpService:JSONEncode(body),
			Enum.HttpContentType.ApplicationJson,
			false,
			headers
		)
	end)

	if not success then
		return nil, "Grok API error: " .. tostring(response)
	end

	local decoded = HttpService:JSONDecode(response)

	if decoded.choices and decoded.choices[1] and decoded.choices[1].message then
		return decoded.choices[1].message.content
	else
		return nil, "No response from Grok"
	end
end

function LLMProvider.GenerateSpell(userId: number, request)
	local rateLimitOk, rateLimitErr = checkRateLimit(userId)
	if not rateLimitOk then
		return nil, rateLimitErr
	end

	local credentials = CredentialStore.GetCredentials(userId)
	if not credentials then
		return nil, "No LLM provider connected. Please connect a provider first."
	end

	if CredentialStore.IsTokenExpired(credentials) then
		local refreshSuccess, refreshErr = CredentialStore.RefreshCredentials(userId)
		if not refreshSuccess then
			return nil, "Authentication expired: " .. tostring(refreshErr) .. ". Please reconnect your provider."
		end
		credentials = CredentialStore.GetCredentials(userId)
	end

	local prompt = SpellCaster.BuildPrompt(request)
	local systemPrompt = SpellCaster.GetSystemPrompt()

	local responseText
	local apiSuccess, apiResult

	if credentials.provider == "gemini" then
		responseText, apiResult = callGeminiAPI(credentials.accessToken, prompt, systemPrompt)
	elseif credentials.provider == "grok" then
		responseText, apiResult = callGrokAPI(credentials.accessToken, prompt, systemPrompt)
	else
		return nil, "Unknown provider: " .. tostring(credentials.provider)
	end

	if not responseText then
		return nil, apiResult
	end

	local spellEffect = Warding.SanitizeLLMResponse(responseText, HttpService.JSONDecode)
	if not spellEffect then
		return nil, "Invalid spell response from LLM"
	end

	return spellEffect
end

function LLMProvider.GetProviderInfo(userId: number)
	local credentials = CredentialStore.GetCredentials(userId)
	if not credentials then
		return nil
	end

	return {
		provider = credentials.provider,
		subscriptionType = credentials.subscriptionType,
		connectedAt = credentials.createdAt,
		lastUsed = credentials.lastUsed,
	}
end

function LLMProvider.DisconnectProvider(userId: number)
	return CredentialStore.DeleteCredentials(userId)
end

return LLMProvider
