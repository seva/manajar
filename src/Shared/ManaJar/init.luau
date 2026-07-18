local Types = require(script.Parent.Types)

local JarSystem = {}

function JarSystem.CreateJar(maxMana: number): Types.Jar
	assert(maxMana > 0, "maxMana must be positive")
	return {
		mana = 0,
		maxMana = maxMana,
		targetId = nil,
	}
end

function JarSystem.FillJar(jar: Types.Jar, amount: number): (boolean, number)
	if amount <= 0 then
		return false, jar.mana
	end
	local filled = math.min(jar.mana + amount, jar.maxMana)
	jar.mana = filled
	return true, filled
end

function JarSystem.LinkTarget(jar: Types.Jar, targetId: Types.TargetId): boolean
	if jar.mana <= 0 then
		return false
	end
	jar.targetId = targetId
	return true
end

function JarSystem.ClearTarget(jar: Types.Jar): boolean
	jar.targetId = nil
	return true
end

function JarSystem.GetMana(jar: Types.Jar): number
	return jar.mana
end

function JarSystem.GetFillRatio(jar: Types.Jar): number
	if jar.maxMana == 0 then
		return 0
	end
	return jar.mana / jar.maxMana
end

function JarSystem.GetTarget(jar: Types.Jar): Types.TargetId?
	return jar.targetId
end

function JarSystem.DrainJar(jar: Types.Jar): number
	local drained = jar.mana
	jar.mana = 0
	return drained
end

return JarSystem
