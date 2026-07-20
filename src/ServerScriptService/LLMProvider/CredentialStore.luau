local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")

local CredentialStore = {}

local credentialsStore = DataStoreService:GetDataStore("PlayerLLMCredentials")

local CACHE_TTL = 300 -- 5 minutes

local cache = {}

local function getCachedCredentials(userId: number)
	local cached = cache[userId]
	if cached and os.time() - cached.timestamp < CACHE_TTL then
		return cached.data
	end
	return nil
end

local function setCachedCredentials(userId: number, data)
	cache[userId] = {
		data = data,
		timestamp = os.time(),
	}
end

function CredentialStore.GetCredentials(userId: number)
	local cached = getCachedCredentials(userId)
	if cached then
		return cached
	end

	local success, result = pcall(function()
		return credentialsStore:GetAsync("Player_" .. userId)
	end)

	if success and result then
		setCachedCredentials(userId, result)
		return result
	end

	return nil
end

function CredentialStore.SaveCredentials(userId: number, credentials)
	local data = {
		provider = credentials.provider,
		accessToken = credentials.accessToken,
		refreshToken = credentials.refreshToken,
		expiresAt = credentials.expiresAt,
		subscriptionType = credentials.subscriptionType,
		createdAt = credentials.createdAt or os.time(),
		lastUsed = os.time(),
	}

	local success, err = pcall(function()
		credentialsStore:SetAsync("Player_" .. userId, data)
	end)

	if success then
		setCachedCredentials(userId, data)
		return true
	else
		warn("Failed to save credentials for user " .. userId .. ": " .. tostring(err))
		return false
	end
end

function CredentialStore.DeleteCredentials(userId: number)
	local success, err = pcall(function()
		credentialsStore:RemoveAsync("Player_" .. userId)
	end)

	if success then
		cache[userId] = nil
		return true
	else
		warn("Failed to delete credentials for user " .. userId .. ": " .. tostring(err))
		return false
	end
end

function CredentialStore.RefreshCredentials(userId: number)
	local credentials = CredentialStore.GetCredentials(userId)
	if not credentials then
		return false, "No credentials found"
	end

	if credentials.provider == "gemini" then
		if not credentials.refreshToken then
			return false, "No refresh token available"
		end

		local success, result = pcall(function()
			local response = HttpService:PostAsync(
				"https://oauth2.googleapis.com/token",
				HttpService:JSONEncode({
					client_id = "YOUR_GOOGLE_CLIENT_ID",
					client_secret = "YOUR_GOOGLE_CLIENT_SECRET",
					refresh_token = credentials.refreshToken,
					grant_type = "refresh_token",
				}),
				Enum.HttpContentType.ApplicationJson
			)
			return HttpService:JSONDecode(response)
		end)

		if success and result.access_token then
			credentials.accessToken = result.access_token
			credentials.expiresAt = os.time() + (result.expires_in or 3600)
			credentials.lastUsed = os.time()
			CredentialStore.SaveCredentials(userId, credentials)
			return true
		else
			return false, "Failed to refresh Gemini token"
		end

	elseif credentials.provider == "grok" then
		if not credentials.refreshToken then
			return false, "No refresh token available"
		end

		local success, result = pcall(function()
			local response = HttpService:PostAsync(
				"https://accounts.x.ai/oauth/token",
				HttpService:JSONEncode({
					client_id = "YOUR_XAI_CLIENT_ID",
					refresh_token = credentials.refreshToken,
					grant_type = "refresh_token",
				}),
				Enum.HttpContentType.ApplicationJson
			)
			return HttpService:JSONDecode(response)
		end)

		if success and result.access_token then
			credentials.accessToken = result.access_token
			credentials.expiresAt = os.time() + (result.expires_in or 3600)
			credentials.lastUsed = os.time()
			CredentialStore.SaveCredentials(userId, credentials)
			return true
		else
			return false, "Failed to refresh Grok token"
		end
	end

	return false, "Unknown provider: " .. tostring(credentials.provider)
end

function CredentialStore.IsTokenExpired(credentials)
	if not credentials or not credentials.expiresAt then
		return true
	end
	return os.time() >= credentials.expiresAt
end

return CredentialStore
