export type EffectType = "damage" | "heal" | "stun" | "buff" | "debuff"

export type SpellEffect = {
	spellName: string,
	description: string,
	effectType: EffectType,
	baseValue: number,
	scaledValue: number,
	duration: number?,
}

export type CastRequest = {
	prompt: string,
	manaInvested: number,
	targetName: string,
	targetResistance: number,
}

export type LLMProvider = {
	GenerateSpell: (request: CastRequest) -> SpellEffect?,
}
