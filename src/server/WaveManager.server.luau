local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local GameStats = Workspace:WaitForChild("GameStats")
local CurrentWave = GameStats:WaitForChild("CurrentWave")
local BaseHealth = GameStats:WaitForChild("BaseHealth")
local GAMEOVER = GameStats:WaitForChild("GameOver")
local Victory = GameStats:WaitForChild("Victory")

local EnemyFolder = Workspace:WaitForChild("Enemy")

local SharedFolder = ReplicatedStorage:WaitForChild("Shared")

local ConfigurationsFolder = SharedFolder:WaitForChild("Configurations")

local EnemyConfig = require(ConfigurationsFolder:WaitForChild("EnemyConfig"))

local EnemyModelsFolder = SharedFolder:WaitForChild("EnemyModels")

local EnemyTemplate = EnemyModelsFolder:WaitForChild("EnemyTemplate")

local ENEMY_DAMAGE = 20



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

        if GAMEOVER.Value then
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
        GAMEOVER.Value = true
        clearAllEnemies()
        return
    end


    removeEnemy(enemy)
    
    
end

local function spawnEnemy(enemyType, WaypointsFolder)

    local cloneEnemy = EnemyTemplate:Clone()
    local Humanoid = cloneEnemy:WaitForChild("Humanoid")

    cloneEnemy.Name = enemyType
    Humanoid.MaxHealth = EnemyConfig[enemyType].Health
    Humanoid.Health = EnemyConfig[enemyType].Health
    Humanoid.WalkSpeed = EnemyConfig[enemyType].Speed
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
    
    local walkAnimation = Instance.new("Animation")
    walkAnimation.AnimationId = "rbxassetid://125749145"
    local animator = Humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator")
    animator.Parent = Humanoid
    local walkTrack = animator:LoadAnimation(walkAnimation)
    walkTrack.Looped = true
    walkTrack:Play()
    
    cloneEnemy:PivotTo(WaypointsFolder:WaitForChild("1").CFrame)

    return cloneEnemy
end

local function spawnWave(waveInfo)

    CurrentWave.Value += 1
    local WaypointsFolder = Workspace:WaitForChild("Waypoints")

    for i = 1, waveInfo.Count do

        if GAMEOVER.Value then
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
        if GAMEOVER.Value then
            return
        end
        task.wait()
        --print(enemyCount)
    end

   
   
end

for i,v in ipairs(waves) do
    
    if GAMEOVER.Value then
        break
    end
    
   -- print("wave "..i.." begins")
    spawnWave(waves[i])
   -- print("wave "..i.." is finished")
    --print("waiting before we start next wave")
    
    if GAMEOVER.Value then
        break
    end
    task.wait(5) 
end

if GAMEOVER.Value == true then
   -- print(GAMEOVER.Value)
    print("game over")
else
    Victory.Value = true
    print("victory")
end