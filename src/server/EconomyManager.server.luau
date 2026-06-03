local Players = game:GetService("Players")

local START_MONEY = 1000

Players.PlayerAdded:Connect(function(Player)

    local LeaderstatsFolder = Instance.new("Folder")
    LeaderstatsFolder.Name = "leaderstats"
    LeaderstatsFolder.Parent = Player

    local Money = Instance.new("IntValue")
    Money.Name = "Money"
    Money.Value = START_MONEY
    Money.Parent = LeaderstatsFolder

    Player.CharacterAdded:Connect(function(char)
        
        for _, obj in pairs(char:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.CollisionGroup = "Players"
                
            end
        end

        char.DescendantAdded:Connect(function(obj)
            if obj:IsA("BasePart") then
                obj.CollisionGroup = "Players"
            end
        end)

    end)
end)


