local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local SharedFolder = ReplicatedStorage:WaitForChild("Shared")

local EnemyConfig = require(SharedFolder:WaitForChild("EnemyConfig"))

local EnemyTemplate = Workspace:WaitForChild("EnemyTemplate")

local waves = {
    {
        EnemyType = "Basic",
        Count = 5,
        spawnDelay = 3
    },

    {
        EnemyType = "Fast",
        Count = 10,
        spawnDelay = 2

    },

    {
        EnemyType = "Tank",
        Count = 7,
        spawnDelay = 5
    }

}


local enemyCount = 0

local function removeEnemy(enemy, delayRemove)


    if enemy:GetAttribute("isRemoved") then
        return
    end

    enemyCount -= 1
    enemy:SetAttribute("isRemoved", true)


    task.delay(delayRemove or 0, function()

        enemy:Destroy()

    end)

end

local function moveEnemy(enemy, WaypointsFolder)

     local enemyHumanoid = enemy:WaitForChild("Humanoid")

    for i = 1, #WaypointsFolder:GetChildren() do

        if enemy:GetAttribute("isRemoved") then
            return
        end

        enemyHumanoid:MoveTo(WaypointsFolder:WaitForChild(tostring(i)).Position)
        enemyHumanoid.MoveToFinished:Wait()

    end
   
    removeEnemy(enemy)
end

local function spawnEnemy(enemyType, WaypointsFolder)

    local cloneEnemy = EnemyTemplate:Clone()
    cloneEnemy.Name = enemyType
    cloneEnemy.Humanoid.MaxHealth = EnemyConfig[enemyType].Health
    cloneEnemy.Humanoid.Health = EnemyConfig[enemyType].Health
    cloneEnemy.Humanoid.WalkSpeed = EnemyConfig[enemyType].Speed
    cloneEnemy:SetAttribute("isRemoved", false)
    cloneEnemy.Parent = Workspace
    cloneEnemy:PivotTo(WaypointsFolder:WaitForChild("1").CFrame)

    return cloneEnemy
end

local function spawnWave(waveInfo)

    local WaypointsFolder = Workspace:WaitForChild("Waypoints")

    for i = 1, waveInfo.Count do

        enemyCount += 1
        task.spawn(function()
            
            local enemy = spawnEnemy(waveInfo.EnemyType, WaypointsFolder)

            local enemyHumanoid = enemy:WaitForChild("Humanoid")

            enemyHumanoid.Died:Connect(function()
            
                removeEnemy(enemy, 1)
            end)
            print("move")
            moveEnemy(enemy, WaypointsFolder)
        end)

        task.wait(waveInfo.spawnDelay)

    end

    while enemyCount ~= 0 do
        task.wait(0.1)
        print(enemyCount)
    end

   
   
end

for i,v in ipairs(waves) do
    
    --spawnWave(waves[i])
    print("wave "..i.." begins")
    spawnWave(waves[i])
    print("wave "..i.." is finished")
    print("waiting before we start next wave")
    task.wait(5)

end

print("game is finished")


--spawnWave(waves[1])