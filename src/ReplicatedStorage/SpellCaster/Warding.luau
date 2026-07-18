local Types = require(script.Parent.Types)

local VALID_EFFECT_TYPES: { [string]: boolean } = {
	damage = true,
	heal = true,
	stun = true,
	buff = true,
	debuff = true,
}

local Warding = {}

function Warding.SanitizeSpellEffect(raw: any): Types.SpellEffect?
	if typeof(raw) ~= "table" then
		return nil
	end

	if type(raw.spellName) ~= "string" or #raw.spellName > 100 then
		return nil
	end
	if type(raw.description) ~= "string" or #raw.description > 500 then
		return nil
	end
	if type(raw.effectType) ~= "string" or not VALID_EFFECT_TYPES[raw.effectType] then
		return nil
	end
	if type(raw.baseValue) ~= "number" or raw.baseValue < 0 or raw.baseValue > 1e6 then
		return nil
	end
	if type(raw.scaledValue) ~= "number" or raw.scaledValue < 0 or raw.scaledValue > 1e6 then
		return nil
	end

	local effect: Types.SpellEffect = {
		spellName = raw.spellName,
		description = raw.description,
		effectType = raw.effectType :: Types.EffectType,
		baseValue = raw.baseValue,
		scaledValue = raw.scaledValue,
	}

	if raw.duration ~= nil then
		if type(raw.duration) ~= "number" or raw.duration < 0 or raw.duration > 300 then
			return nil
		end
		effect.duration = raw.duration
	end

	return effect
end

function Warding.SanitizeLLMResponse(responseBody: string, jsonDecode: (string) -> any): Types.SpellEffect?
	local success, parsed = pcall(jsonDecode, responseBody)
	if not success then
		return nil
	end
	return Warding.SanitizeSpellEffect(parsed)
end

return Warding
