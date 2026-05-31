local Players = game:GetService("Players")

local START_MONEY = 500

Players.PlayerAdded:Connect(function(Player)

    local LeaderstatsFolder = Instance.new("Folder")
    LeaderstatsFolder.Name = "leaderstats"
    LeaderstatsFolder.Parent = Player

    local Money = Instance.new("IntValue")
    Money.Name = "Money"
    Money.Value = START_MONEY
    Money.Parent = LeaderstatsFolder

end)

