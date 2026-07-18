local SCALE_DISPLAY = {
	weak = { label = "Weak", color = Color3.fromRGB(200, 50, 50), icon = "⬇" },
	slightly_weak = { label = "Slightly Weak", color = Color3.fromRGB(200, 150, 50), icon = "↘" },
	neutral = { label = "Neutral", color = Color3.fromRGB(200, 200, 200), icon = "➡" },
	strong = { label = "Strong", color = Color3.fromRGB(50, 200, 100), icon = "↗" },
	very_strong = { label = "Very Strong!", color = Color3.fromRGB(50, 255, 150), icon = "⬆" },
}

local Feedback = {}

function Feedback.GetScaleDisplay(classification: string): { label: string, color: Color3, icon: string }?
	return SCALE_DISPLAY[classification :: "weak"]
end

function Feedback.BuildSpellResultDisplay(
	spellName: string,
	classification: string,
	scaleFactor: number,
	scaledValue: number
): { title: string, description: string, color: Color3, details: { string } }
	local display = Feedback.GetScaleDisplay(classification)
	local color = if display then display.color else Color3.fromRGB(200, 200, 200)
	local label = if display then display.label else "Unknown"
	local icon = if display then display.icon else "?"
	local details = {
		string.format("Scale: x%.2f", scaleFactor),
		string.format("Power: %d", scaledValue),
	}
	return {
		title = string.format("%s %s", icon, spellName),
		description = string.format("Spell is %s", label:lower()),
		color = color,
		details = details,
	}
end

function Feedback.BuildJarDisplay(
	fillRatio: number,
	mana: number,
	maxMana: number
): { fillPercent: number, manaText: string, barColor: Color3 }
	local barColor: Color3
	if fillRatio < 0.3 then
		barColor = Color3.fromRGB(100, 100, 255)
	elseif fillRatio < 0.7 then
		barColor = Color3.fromRGB(50, 150, 255)
	else
		barColor = Color3.fromRGB(50, 255, 200)
	end
	return {
		fillPercent = fillRatio * 100,
		manaText = string.format("%d / %d", mana, maxMana),
		barColor = barColor,
	}
end

return Feedback
