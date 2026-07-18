local Types = require(script.Parent.Parent.ManaJar.Types)

export type ManaInputConfig = {
	fillRate: number,
	maxMana: number,
}

local DEFAULT_CONFIG: ManaInputConfig = {
	fillRate = 10,
	maxMana = 100,
}

local ManaInput = {}

function ManaInput.CreateInputHandler(config: ManaInputConfig?): ManaInputConfig & { accumulatedInput: number }
	local cfg = if config then config else DEFAULT_CONFIG
	return {
		fillRate = cfg.fillRate,
		maxMana = cfg.maxMana,
		accumulatedInput = 0,
	}
end

function ManaInput.ProcessInput(handler: { accumulatedInput: number, fillRate: number, maxMana: number }, inputDelta: number): (boolean, number)
	if inputDelta <= 0 then
		return false, handler.accumulatedInput
	end
	handler.accumulatedInput = math.min(handler.accumulatedInput + inputDelta * handler.fillRate, handler.maxMana)
	return true, handler.accumulatedInput
end

function ManaInput.ResetInput(handler: { accumulatedInput: number }): number
	local value = handler.accumulatedInput
	handler.accumulatedInput = 0
	return value
end

function ManaInput.GetAccumulated(handler: { accumulatedInput: number }): number
	return handler.accumulatedInput
end

function ManaInput.FillJarFromInput(handler: { accumulatedInput: number }, jar: Types.Jar, jarSystem: { FillJar: (Types.Jar, number) -> (boolean, number) }): (boolean, number)
	if handler.accumulatedInput <= 0 then
		return false, 0
	end
	local ok, mana = jarSystem.FillJar(jar, handler.accumulatedInput)
	if ok then
		handler.accumulatedInput = 0
	end
	return ok, mana
end

return ManaInput
