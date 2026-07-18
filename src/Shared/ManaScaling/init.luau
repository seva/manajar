local ManaScaling = {}

function ManaScaling.CalculateScaleFactor(manaInvested: number, targetResistance: number): number
	if manaInvested <= 0 then
		return 0
	end
	if targetResistance <= 0 then
		return 2
	end
	local ratio = manaInvested / (manaInvested + targetResistance)
	return ratio * 2
end

function ManaScaling.ScaleValue(baseValue: number, scaleFactor: number): number
	return baseValue * scaleFactor
end

function ManaScaling.ClassifyScale(scaleFactor: number): string
	if scaleFactor < 0.5 then
		return "weak"
	elseif scaleFactor < 0.9 then
		return "slightly_weak"
	elseif scaleFactor <= 1.1 then
		return "neutral"
	elseif scaleFactor <= 1.5 then
		return "strong"
	else
		return "very_strong"
	end
end

function ManaScaling.ComputeSpellEffect(
	baseValue: number,
	manaInvested: number,
	targetResistance: number
): (number, number, string)
	local scaleFactor = ManaScaling.CalculateScaleFactor(manaInvested, targetResistance)
	local scaledValue = ManaScaling.ScaleValue(baseValue, scaleFactor)
	local classification = ManaScaling.ClassifyScale(scaleFactor)
	return scaleFactor, scaledValue, classification
end

return ManaScaling
