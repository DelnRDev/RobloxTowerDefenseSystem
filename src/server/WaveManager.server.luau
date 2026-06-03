local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local GameStats = Workspace:WaitForChild("GameStats")
local CurrentWave = GameStats:WaitForChild("CurrentWave")
local BaseHealth = GameStats:WaitForChild("BaseHealth")

local EnemyFolder = Workspace:WaitForChild("Enemy")

local SharedFolder = ReplicatedStorage:WaitForChild("Shared")

local EnemyConfig = require(SharedFolder:WaitForChild("EnemyConfig"))

local EnemyTemplate = SharedFolder:WaitForChild("EnemyTemplate")

local ENEMY_DAMAGE = 20

local GAMEOVER = false

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

local function clearAllEnemies()

    for _,enemy in pairs(EnemyFolder:GetChildren()) do
        removeEnemy(enemy)
    end

end

local function moveEnemy(enemy, WaypointsFolder)

     local enemyHumanoid = enemy:WaitForChild("Humanoid")

    for i = 1, #WaypointsFolder:GetChildren() do

        if GAMEOVER then
           -- removeEnemy(enemy)
            return
        end

        if enemy:GetAttribute("isRemoved") then
            return
        end

        enemyHumanoid:MoveTo(WaypointsFolder:WaitForChild(tostring(i)).Position)
        
        enemyHumanoid.MoveToFinished:Wait()

    end
    BaseHealth.Value -= ENEMY_DAMAGE
    BaseHealth.Value = math.max(0,BaseHealth.Value)
    if BaseHealth.Value <= 0 then
        GAMEOVER = true
        clearAllEnemies()
        return
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
    cloneEnemy:SetAttribute("isRewarded", false)
    

     for _, obj in pairs(cloneEnemy:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.CollisionGroup = "Enemies"
            
        end
    end

    cloneEnemy.DescendantAdded:Connect(function(obj)
        if obj:IsA("BasePart") then
            obj.CollisionGroup = "Enemies"
        end
    end)

    cloneEnemy.Parent = EnemyFolder
    cloneEnemy:PivotTo(WaypointsFolder:WaitForChild("1").CFrame)

    return cloneEnemy
end

local function spawnWave(waveInfo)

    CurrentWave.Value += 1
    local WaypointsFolder = Workspace:WaitForChild("Waypoints")

    for i = 1, waveInfo.Count do

        if GAMEOVER then
            return
        end

        enemyCount += 1
        task.spawn(function()
            
            local enemy = spawnEnemy(waveInfo.EnemyType, WaypointsFolder)

            local enemyHumanoid = enemy:WaitForChild("Humanoid")

            enemyHumanoid.Died:Connect(function()
            
                removeEnemy(enemy, 1)
            end)
            --print("move")
            moveEnemy(enemy, WaypointsFolder)
        end)

        task.wait(waveInfo.spawnDelay)

    end

    while enemyCount ~= 0 do
        if GAMEOVER then
            return
        end
        task.wait()
        --print(enemyCount)
    end

   task.wait(5) 
   
end

for i,v in ipairs(waves) do
    
    if GAMEOVER then
        break
    end
    
   -- print("wave "..i.." begins")
    spawnWave(waves[i])
   -- print("wave "..i.." is finished")
    --print("waiting before we start next wave")
    

end

if GAMEOVER then
    print("game over")
else
    print("victory")
end