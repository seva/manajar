local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotesFolder = Instance.new("Folder")
remotesFolder.Name = "Remotes"
remotesFolder.Parent = ReplicatedStorage

local fillJarEvent = Instance.new("RemoteEvent")
fillJarEvent.Name = "FillJar"
fillJarEvent.Parent = remotesFolder

local castSpellEvent = Instance.new("RemoteEvent")
castSpellEvent.Name = "CastSpell"
castSpellEvent.Parent = remotesFolder

local selectTargetEvent = Instance.new("RemoteEvent")
selectTargetEvent.Name = "SelectTarget"
selectTargetEvent.Parent = remotesFolder

local updateJarEvent = Instance.new("RemoteEvent")
updateJarEvent.Name = "UpdateJarDisplay"
updateJarEvent.Parent = remotesFolder
