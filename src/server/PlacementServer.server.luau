local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local SharedFolder = ReplicatedStorage:WaitForChild("Shared")

local templateTower = SharedFolder:WaitForChild("TowerTemplate")

local PlacementEvent = SharedFolder:WaitForChild("PlacementEvent")

local TOWER_DAMAGE = 10
local TOWER_COOLDOWN = 1

local function showBullet(origin, targetPosition)

    local distplacementVector = targetPosition - origin

    local part = Instance.new("Part")
    part.BrickColor = BrickColor.new("Bright red")
    part.Anchored = true
    part.Transparency = 0.5
    part.CanCollide = false
    part.Size = Vector3.new(0.1,0.1, distplacementVector.Magnitude)
    part.Parent = Workspace

    local fHat = distplacementVector.Unit
    local rHat = fHat:Cross(Vector3.yAxis)
    local uHat = rHat:Cross(fHat)

    part.CFrame = CFrame.new(origin) * CFrame.fromMatrix(Vector3.zero,rHat, uHat, -fHat) * CFrame.new(0, 0, -0.5 * distplacementVector.Magnitude)

    task.wait(1)

    part:Destroy()

end

local function getClosestEnemy(tower)
    print("getting closest")
    local towerPosition = tower.GunHead.Position

    --get closest enemy
    -- take damage

    local closestEnemy = nil
    local closestDistance = nil

    local EnemyFolder = Workspace:WaitForChild("Enemy")

    
    for _, enemy in pairs(EnemyFolder:GetChildren()) do
        
        local enemyPosition = enemy.HumanoidRootPart.Position

        local enemyDistance = (enemyPosition - towerPosition).Magnitude
        --print(enemy:GetPivot())

        if closestDistance == nil then

            closestDistance = enemyDistance
            closestEnemy = enemy

        else
        
            if enemyDistance < closestDistance then

                closestDistance = enemyDistance
                closestEnemy = enemy

            end

        end

    end

    return closestEnemy

end

local function startAttackEnemy(tower)

    task.spawn(function()

        while true do

            local closestEnemy = getClosestEnemy(tower)

            local enemyHumanoid = closestEnemy and closestEnemy:FindFirstChild("Humanoid")

            if enemyHumanoid and enemyHumanoid.Health > 0 then
                
                task.spawn(function()
                    showBullet(tower.GunHead.Position, closestEnemy.HumanoidRootPart.Position)
                end)
                
                enemyHumanoid:TakeDamage(TOWER_DAMAGE)

            end
            
            task.wait(TOWER_COOLDOWN)

        end

    end)

end

PlacementEvent.OnServerEvent:Connect(function(player, placementCFrame)
   
    local cloneTemplate = templateTower:Clone()
    cloneTemplate:PivotTo(placementCFrame)
    cloneTemplate.Parent = Workspace

    startAttackEnemy(cloneTemplate)

end)