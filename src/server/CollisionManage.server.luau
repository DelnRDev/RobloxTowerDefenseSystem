local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")

local PlayersGroupName = "Players"
local EnemiesGroupName = "Enemies"
local TowersGroupName = "Towers"

local function createCollisionGroup(name)

    local success, result = pcall(function()
        PhysicsService:RegisterCollisionGroup(name)
    end)

    if success then
        print("Collision group "..name.." is created")
        return true
    else
        warn("Theres an error while creating collision group "..name)
        warn(result)
        return false
    end

end

if not PhysicsService:IsCollisionGroupRegistered(PlayersGroupName) then
    createCollisionGroup(PlayersGroupName) 
end

if not PhysicsService:IsCollisionGroupRegistered(EnemiesGroupName) then
    createCollisionGroup(EnemiesGroupName)
end

if not PhysicsService:IsCollisionGroupRegistered(TowersGroupName) then
    createCollisionGroup(TowersGroupName)
end

PhysicsService:CollisionGroupSetCollidable(PlayersGroupName, EnemiesGroupName, false)
PhysicsService:CollisionGroupSetCollidable(PlayersGroupName, TowersGroupName, false)
PhysicsService:CollisionGroupSetCollidable(EnemiesGroupName, TowersGroupName, false)



Players.PlayerAdded:Connect(function(Player)
    Player.CharacterAdded:Connect(function(char)
        
        for _, obj in pairs(char:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.CollisionGroup = PlayersGroupName
                
            end
        end

        char.DescendantAdded:Connect(function(obj)
            if obj:IsA("BasePart") then
                obj.CollisionGroup = PlayersGroupName
            end
        end)

    end)
end)