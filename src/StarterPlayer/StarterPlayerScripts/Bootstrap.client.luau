-- in-playtest: covered manually in Studio; no automated test infra for play mode
warn("[BOOTSTRAP-CLIENT] Starting client initialization")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local ClientHandler = require(script.Parent:WaitForChild("ClientHandler"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ManaJarHUD"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 400, 0, 100)
statusLabel.Position = UDim2.new(0.5, -200, 0, 50)
statusLabel.BackgroundTransparency = 0.5
statusLabel.BackgroundColor3 = Color3.new(0, 0, 0)
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.TextScaled = true
statusLabel.Text = "Hold LMB: fill | 1/2/3: target | F: cast | G: connect | H: disconnect"
statusLabel.Font = Enum.Font.SourceSansBold
statusLabel.Parent = screenGui

local messageLabel = Instance.new("TextLabel")
messageLabel.Size = UDim2.new(0, 400, 0, 50)
messageLabel.Position = UDim2.new(0.5, -200, 0, 160)
messageLabel.BackgroundTransparency = 1
messageLabel.TextColor3 = Color3.new(1, 1, 0)
messageLabel.TextScaled = true
messageLabel.Text = ""
messageLabel.Font = Enum.Font.SourceSansBold
messageLabel.Parent = screenGui

local manaBar = Instance.new("Frame")
manaBar.Size = UDim2.new(0, 400, 0, 30)
manaBar.Position = UDim2.new(0.5, -200, 0, 220)
manaBar.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
manaBar.BorderSizePixel = 2
manaBar.BorderColor3 = Color3.new(0.5, 0.5, 0.5)
manaBar.Parent = screenGui

local manaFill = Instance.new("Frame")
manaFill.Size = UDim2.new(0, 0, 1, 0)
manaFill.BackgroundColor3 = Color3.new(0, 0.5, 1)
manaFill.BorderSizePixel = 0
manaFill.Parent = manaBar

local manaText = Instance.new("TextLabel")
manaText.Size = UDim2.new(1, 0, 1, 0)
manaText.BackgroundTransparency = 1
manaText.TextColor3 = Color3.new(1, 1, 1)
manaText.TextScaled = true
manaText.Text = "0 / 100"
manaText.Font = Enum.Font.SourceSansBold
manaText.Parent = manaBar
warn("[BOOTSTRAP-CLIENT] HUD created")

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local remoteEvents = {
	FillJar = remotes:WaitForChild("FillJar"),
	CastSpell = remotes:WaitForChild("CastSpell"),
	SelectTarget = remotes:WaitForChild("SelectTarget"),
	UpdateJarDisplay = remotes:WaitForChild("UpdateJarDisplay"),
	ConnectProvider = remotes:WaitForChild("ConnectProvider"),
	DisconnectProvider = remotes:WaitForChild("DisconnectProvider"),
	CheckProvider = remotes:WaitForChild("CheckProvider"),
}

local handler = ClientHandler.Create({
	FillJar = { FireServer = function(self, amount) remoteEvents.FillJar:FireServer(amount) end },
	CastSpell = { FireServer = function(self, intent) remoteEvents.CastSpell:FireServer(intent) end },
	SelectTarget = { FireServer = function(self, targetId) remoteEvents.SelectTarget:FireServer(targetId) end },
	UpdateJarDisplay = { FireServer = function(self, data) remoteEvents.UpdateJarDisplay:FireServer(data) end },
})

remoteEvents.UpdateJarDisplay.OnClientEvent:Connect(function(data)
	if data.manaText then
		manaText.Text = data.manaText
	end
	if data.fillPercent then
		manaFill.Size = UDim2.new(data.fillPercent, 0, 1, 0)
	end
	if data.message then
		messageLabel.Text = data.message
		task.delay(3, function()
			if messageLabel.Text == data.message then
				messageLabel.Text = ""
			end
		end)
	end
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		ClientHandler.StartFill(handler)
	elseif input.KeyCode == Enum.KeyCode.F then
		ClientHandler.CastSpell(handler, "Fire")
	elseif input.KeyCode == Enum.KeyCode.One then
		ClientHandler.SelectTarget(handler, "Training Dummy")
	elseif input.KeyCode == Enum.KeyCode.Two then
		ClientHandler.SelectTarget(handler, "Stone Golem")
	elseif input.KeyCode == Enum.KeyCode.Three then
		ClientHandler.SelectTarget(handler, "Fire Imp")
	elseif input.KeyCode == Enum.KeyCode.G then
		-- Connect provider - for now, default to Gemini
		-- In a full implementation, you'd show a UI to choose provider
		remoteEvents.ConnectProvider:FireServer("gemini")
	elseif input.KeyCode == Enum.KeyCode.H then
		-- Disconnect provider
		remoteEvents.DisconnectProvider:FireServer()
	end
end)

UserInputService.InputEnded:Connect(function(input, processed)
	if processed then
		return
	end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		ClientHandler.StopFill(handler)
	end
end)

RunService.RenderStepped:Connect(function(dt)
	ClientHandler.ProcessFillTick(handler, dt)
end)

-- Check provider status on join
remoteEvents.CheckProvider:FireServer()

warn("[BOOTSTRAP-CLIENT] Client initialization complete")
