local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local SharedFolder = ReplicatedStorage:WaitForChild("Shared")

local templateTower = SharedFolder:WaitForChild("TowerTemplate")

local PlacementEvent = SharedFolder:WaitForChild("PlacementEvent")

local TowersFolder = Workspace:WaitForChild("Towers")

local TOWER_DAMAGE = 10
local TOWER_COOLDOWN = 1
local TOWER_RANGE = 30

local TOWER_PRICE = 200

local KILL_REWARD = 100


local function showBullet(origin, targetPosition)

    local distplacementVector = targetPosition - origin

    if targetPosition == origin then -- unit vector = vector/|vector| , prevent division by zero
        return
    end

    local part = Instance.new("Part")
    part.BrickColor = BrickColor.new("Bright red")
    part.Anchored = true
    part.Transparency = 0.5
    part.CanCollide = false
    part.Size = Vector3.new(0.1,0.1, distplacementVector.Magnitude)
    part.Parent = Workspace

    local fHat = distplacementVector.Unit
    local rHat = fHat:Cross(Vector3.yAxis).Unit
    local uHat = rHat:Cross(fHat).Unit  

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
        
        local enemyHumanoidRootPart = enemy:FindFirstChild("HumanoidRootPart")

        if not enemyHumanoidRootPart then
            continue
        end

        local enemyPosition = enemyHumanoidRootPart.Position

        local enemyDistance = (enemyPosition - towerPosition).Magnitude
        --print(enemy:GetPivot())

       
        if enemyDistance <= TOWER_RANGE then 

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
                    local GunHead = tower:FindFirstChild("GunHead")
                    local enemyHumanoidRootPart = closestEnemy:FindFirstChild("HumanoidRootPart")

                    if not GunHead or not enemyHumanoidRootPart then 
                        return
                    end

                    showBullet(GunHead.Position, enemyHumanoidRootPart.Position)
                end)
                
                if enemyHumanoid.Health - TOWER_DAMAGE <= 0 then
                    
                    local towerOwnerUserId = tower:GetAttribute("Owner")
                    local rewardOwner = Players:GetPlayerByUserId(towerOwnerUserId)
                    local leaderstats = rewardOwner and rewardOwner:FindFirstChild("leaderstats")
                    local playerMoney = leaderstats and leaderstats:FindFirstChild("Money")
                    
                    if rewardOwner and leaderstats and playerMoney then
                        playerMoney.Value += KILL_REWARD
                    else
                        print(rewardOwner, leaderstats, playerMoney)
                    end
                    
                end
                    enemyHumanoid:TakeDamage(TOWER_DAMAGE)

            end
            
            task.wait(TOWER_COOLDOWN)

        end

    end)

end

PlacementEvent.OnServerEvent:Connect(function(player, placementCFrame)
   
    local leaderstats = player:FindFirstChild("leaderstats")
    local playerMoney = leaderstats:FindFirstChild("Money")

    if not leaderstats or not playerMoney then
        print(player.Name.." leaderstats not found or player money not found")
        return
    end
    
    if playerMoney.Value < TOWER_PRICE then
        print(player.Name.." does not have enough money")
        return
    end

    print(playerMoney.Value)

    playerMoney.Value -= TOWER_PRICE

    local cloneTemplate = templateTower:Clone()
    cloneTemplate:PivotTo(placementCFrame)
    cloneTemplate:SetAttribute("Owner", player.UserId)
    cloneTemplate.Parent = TowersFolder

    startAttackEnemy(cloneTemplate)

end)