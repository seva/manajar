export type ClientConfig = {
	fillRate: number,
	maxMana: number,
}

export type RemoteEvents = {
	FillJar: { FireServer: (any) -> () },
	CastSpell: { FireServer: (any) -> () },
	SelectTarget: { FireServer: (any) -> () },
}

export type ClientHandler = {
	remoteEvents: RemoteEvents,
	config: ClientConfig,
	accumulatedInput: number,
	isFilling: boolean,
	latestDisplay: { fillPercent: number, manaText: string, barColor: Color3 }?,
}

local DEFAULT_CONFIG: ClientConfig = {
	fillRate = 10,
	maxMana = 100,
}

local ClientHandler = {}

function ClientHandler.Create(remoteEvents: RemoteEvents, config: ClientConfig?): ClientHandler
	local cfg = if config then config else DEFAULT_CONFIG
	return {
		remoteEvents = remoteEvents,
		config = cfg,
		accumulatedInput = 0,
		isFilling = false,
		latestDisplay = nil,
	}
end

function ClientHandler.StartFill(handler: ClientHandler)
	handler.isFilling = true
end

function ClientHandler.ProcessFillTick(handler: ClientHandler, deltaTime: number)
	if not handler.isFilling then
		return
	end
	handler.accumulatedInput = math.min(
		handler.accumulatedInput + deltaTime * handler.config.fillRate,
		handler.config.maxMana
	)
end

function ClientHandler.StopFill(handler: ClientHandler)
	handler.isFilling = false
	if handler.accumulatedInput > 0 then
		handler.remoteEvents.FillJar:FireServer(handler.accumulatedInput)
		handler.accumulatedInput = 0
	end
end

function ClientHandler.CastSpell(handler: ClientHandler, spellIntent: string)
	handler.remoteEvents.CastSpell:FireServer(spellIntent)
end

function ClientHandler.SelectTarget(handler: ClientHandler, targetId: string)
	handler.remoteEvents.SelectTarget:FireServer(targetId)
end

function ClientHandler.OnUpdateJar(handler: ClientHandler, display: { fillPercent: number, manaText: string, barColor: Color3 }): { fillPercent: number, manaText: string, barColor: Color3 }
	handler.latestDisplay = display
	return display
end

function ClientHandler.GetLatestDisplay(handler: ClientHandler): { fillPercent: number, manaText: string, barColor: Color3 }?
	return handler.latestDisplay
end

return ClientHandler
