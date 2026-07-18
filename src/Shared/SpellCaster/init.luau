local Types = require(script.Parent.Types)

local DEFAULT_SYSTEM_PROMPT = [[You are a spell generation engine for a kid-friendly Roblox game.
Given a player's spell intent, the amount of mana invested, and the target's name and resistance,
generate a spell effect in JSON format with these fields:
- spellName: a fun, creative name (max 100 chars)
- description: what the spell does (max 500 chars)
- effectType: one of "damage", "heal", "stun", "buff", "debuff"
- baseValue: the base effect magnitude (positive number, max 1,000,000)
- scaledValue: the effect magnitude after scaling by mana vs resistance (positive number, max 1,000,000)
- duration: optional duration in seconds (0-300), only for stun/buff/debuff

The scaledValue should reflect: more mana invested relative to target resistance = stronger effect.]]

local SpellCaster = {}

function SpellCaster.BuildPrompt(request: Types.CastRequest): string
	return string.format(
		[[Player spell intent: "%s"
Mana invested: %d
Target: %s
Target resistance: %d

Generate a spell JSON that reflects this mana/resistance balance.]],
		request.prompt,
		request.manaInvested,
		request.targetName,
		request.targetResistance
	)
end

function SpellCaster.CastSpell(provider: Types.LLMProvider, request: Types.CastRequest): Types.SpellEffect?
	local effect = provider.GenerateSpell(request)
	if effect == nil then
		return nil
	end
	return effect
end

function SpellCaster.GetSystemPrompt(): string
	return DEFAULT_SYSTEM_PROMPT
end

return SpellCaster
