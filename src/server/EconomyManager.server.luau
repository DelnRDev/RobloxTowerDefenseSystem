local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SharedFolder = ReplicatedStorage:WaitForChild("Shared")
local ConfigurationsFolder = SharedFolder:WaitForChild("Configurations")

local TowerShopConfig = require(ConfigurationsFolder:WaitForChild("TowerShopConfig"))

local START_MONEY = 1000

Players.PlayerAdded:Connect(function(Player)

    local LeaderstatsFolder = Instance.new("Folder")
    LeaderstatsFolder.Name = "leaderstats"
    LeaderstatsFolder.Parent = Player

    local Money = Instance.new("IntValue")
    Money.Name = "Money"
    Money.Value = START_MONEY
    Money.Parent = LeaderstatsFolder

    local DataFolder = Instance.new("Folder")
    DataFolder.Name = "Data"
    DataFolder.Parent = Player

    local Coins = Instance.new("IntValue")
    Coins.Name = "Coins"
    Coins.Value = 0
    Coins.Parent = DataFolder

    local UnlockedTowersFolder = Instance.new("Folder")
    UnlockedTowersFolder.Name = "UnlockedTowers"
    UnlockedTowersFolder.Parent = DataFolder

   local BasicTower = Instance.new("BoolValue")
   BasicTower.Name = "BasicTower"
   BasicTower.Value = true
   BasicTower.Parent = UnlockedTowersFolder

    
end)


