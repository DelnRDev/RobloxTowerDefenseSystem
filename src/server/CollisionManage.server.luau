local PhysicsService = game:GetService("PhysicsService")

local PlayersGroupName = "Players"
local EnemiesGroupName = "Enemies"

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

PhysicsService:CollisionGroupSetCollidable(PlayersGroupName, EnemiesGroupName, false)

