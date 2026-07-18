local Types = require(script.Parent.Parent.ManaJar.Types)

export type Target = {
	id: Types.TargetId,
	name: string,
	resistance: number,
}

export type TargetingState = {
	availableTargets: { [Types.TargetId]: Target },
	selectedTargetId: Types.TargetId?,
}

local Targeting = {}

function Targeting.CreateState(): TargetingState
	return {
		availableTargets = {},
		selectedTargetId = nil,
	}
end

function Targeting.RegisterTarget(state: TargetingState, target: Target): (boolean, string?)
	if state.availableTargets[target.id] ~= nil then
		return false, "Target already registered"
	end
	state.availableTargets[target.id] = target
	return true, nil
end

function Targeting.UnregisterTarget(state: TargetingState, targetId: Types.TargetId): (boolean, string?)
	if state.availableTargets[targetId] == nil then
		return false, "Target not found"
	end
	state.availableTargets[targetId] = nil
	if state.selectedTargetId == targetId then
		state.selectedTargetId = nil
	end
	return true, nil
end

function Targeting.SelectTarget(state: TargetingState, targetId: Types.TargetId): (boolean, string?)
	if state.availableTargets[targetId] == nil then
		return false, "Target not found"
	end
	state.selectedTargetId = targetId
	return true, nil
end

function Targeting.ClearSelection(state: TargetingState): boolean
	state.selectedTargetId = nil
	return true
end

function Targeting.GetSelectedTarget(state: TargetingState): Target?
	if state.selectedTargetId == nil then
		return nil
	end
	return state.availableTargets[state.selectedTargetId]
end

function Targeting.GetAvailableTargets(state: TargetingState): { Target }
	local result: { Target } = {}
	for _, target in state.availableTargets do
		table.insert(result, target)
	end
	return result
end

function Targeting.LinkJarToSelected(state: TargetingState, jar: Types.Jar, jarSystem: { LinkTarget: (Types.Jar, Types.TargetId) -> boolean }): (boolean, string?)
	if state.selectedTargetId == nil then
		return false, "No target selected"
	end
	local ok = jarSystem.LinkTarget(jar, state.selectedTargetId)
	if not ok then
		return false, "Jar is empty, cannot link"
	end
	return true, nil
end

return Targeting
