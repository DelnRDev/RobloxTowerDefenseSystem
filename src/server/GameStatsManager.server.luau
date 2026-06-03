local Workspace = game:GetService("Workspace")

local GameStats = Instance.new("Folder")
GameStats.Name = "GameStats"
GameStats.Parent = Workspace

local BaseHealth = Instance.new("IntValue")
BaseHealth.Name = "BaseHealth"
BaseHealth.Value = 100
BaseHealth.Parent = GameStats

local CurrentWave = Instance.new("IntValue")
CurrentWave.Name = "CurrentWave"
CurrentWave.Value = 1
CurrentWave.Parent = GameStats

local GameOver = Instance.new("BoolValue")
GameOver.Name = "GameOver"
GameOver.Value = false
GameOver.Parent = GameStats

local Victory = Instance.new("BoolValue")
Victory.Name = "Victory"
Victory.Value = false
Victory.Parent = GameStats
