local Types = require(script.Parent.SpellCaster.Types)

export type EffectResult = {
	targetId: string,
	effectType: Types.EffectType,
	appliedValue: number,
	duration: number?,
	success: boolean,
	message: string,
}

local EffectApplier = {}

function EffectApplier.ApplyEffect(
	targetId: string,
	effect: Types.SpellEffect
): EffectResult
	local appliedValue = math.floor(effect.scaledValue)
	local result: EffectResult = {
		targetId = targetId,
		effectType = effect.effectType,
		appliedValue = appliedValue,
		duration = effect.duration,
		success = true,
		message = string.format(
			"%s deals %d %s to %s",
			effect.spellName,
			appliedValue,
			effect.effectType,
			targetId
		),
	}
	return result
end

function EffectApplier.GenerateEffectSummary(effects: { EffectResult }): string
	local parts: { string } = {}
	for _, result in effects do
		table.insert(parts, result.message)
	end
	return table.concat(parts, "\n")
end

return EffectApplier
