local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local SharedFolder = ReplicatedStorage:WaitForChild("Shared")

local TowerModelsFolder = SharedFolder:WaitForChild("TowerModels")
local RemotesFolder = SharedFolder:WaitForChild("Remotes")
local ConfigurationsFolder = SharedFolder:WaitForChild("Configurations")

local TowerConfig = require(ConfigurationsFolder:WaitForChild("TowerConfig"))


local PlacementEvent2 = RemotesFolder:WaitForChild("PlacementEvent2")
local TowerUpgradeEvent = RemotesFolder:WaitForChild("TowerUpgradeEvent")
local TowerSellRemote = RemotesFolder:WaitForChild("TowerSellRemote")
local SetTowerTargetMode = RemotesFolder:WaitForChild("SetTowerTargetMode")

local TowersFolder = Workspace:WaitForChild("Towers")
local BuildArea = Workspace:WaitForChild("BuildArea")
local PathFolder = Workspace:WaitForChild("Path")
local EnemyFolder = Workspace:WaitForChild("Enemy")


local KILL_REWARD = 100


local function showBullet(origin, targetPosition)

    local distplacementVector = targetPosition - origin

    if distplacementVector.Magnitude < 0.001 then -- unit vector = vector/|vector| , prevent division by zero
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


local function getTargetEnemy(tower)

    local TargetMode = tower:GetAttribute("TargetMode") or "Closest"
    
    local towerPosition = tower:GetPivot().Position

    local chosenEnemy = nil
    local chosenValue = nil

    for _, enemy in pairs(EnemyFolder:GetChildren()) do 

            
        local enemyHumanoidRootPart = enemy and enemy:FindFirstChild("HumanoidRootPart")

        if not enemyHumanoidRootPart then
            continue
        end

        local displacementVector = enemyHumanoidRootPart.Position - towerPosition

        if displacementVector.Magnitude <= tower:GetAttribute("Range") then
        

            if TargetMode == "Closest" then
                
                --local towerPosition = tower:GetPivot().Position
           
                if chosenValue == nil then
                   -- print("A")
                    chosenValue = displacementVector.Magnitude
                    chosenEnemy = enemy
                else
                    if displacementVector.Magnitude < chosenValue then
                       -- print("B")
                        chosenValue = displacementVector.Magnitude
                        chosenEnemy = enemy
                    end
                end
                

            elseif TargetMode == "Strongest" then

                local enemyHumanoid = enemy:FindFirstChild("Humanoid")

                if not enemyHumanoid then
                    continue
                end

                if chosenValue == nil then

                    chosenValue = enemyHumanoid.Health
                    chosenEnemy = enemy
                else
                    if enemyHumanoid.Health > chosenValue then
                        chosenValue = enemyHumanoid.Health
                        chosenEnemy = enemy
                    end
                end

            elseif TargetMode == "Weakest" then

                local enemyHumanoid = enemy:FindFirstChild("Humanoid")

                if not enemyHumanoid then
                    continue
                end

                if chosenValue == nil then

                    chosenValue = enemyHumanoid.Health
                    chosenEnemy = enemy
                else
                    if enemyHumanoid.Health < chosenValue then
                        chosenValue = enemyHumanoid.Health
                        chosenEnemy = enemy
                    end
                end

            end
        else
            --print("outta range")
        end

    end
    --print(chosenEnemy)
    return chosenEnemy

end


local function startAttackEnemy(tower)

    task.spawn(function()

        while tower.Parent do

            local targetEnemy = getTargetEnemy(tower)

            local enemyHumanoid = targetEnemy and targetEnemy:FindFirstChild("Humanoid")

            if enemyHumanoid and enemyHumanoid.Health > 0 then
                
                task.spawn(function()
                    local GunHead = tower:FindFirstChild("GunHead")
                    local enemyHumanoidRootPart = targetEnemy:FindFirstChild("HumanoidRootPart")

                    if not GunHead or not enemyHumanoidRootPart then 
                        return
                    end

                    showBullet(GunHead.Position, enemyHumanoidRootPart.Position)
                end)
                
                if enemyHumanoid.Health - tower:GetAttribute("Damage") <= 0 then

                    if not targetEnemy:GetAttribute("isRewarded") then

                        targetEnemy:SetAttribute("isRewarded", true)

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
                    
                end
                    enemyHumanoid:TakeDamage(tower:GetAttribute("Damage"))

            end
            
            task.wait(tower:GetAttribute("Cooldown"))

        end

    end)

end

local function isOverlappingWithTower(placementCFrame, towerModel)

    local overlapParams = OverlapParams.new()
    overlapParams.FilterDescendantsInstances = {TowersFolder}
    overlapParams.FilterType = Enum.RaycastFilterType.Include 

     local touching = Workspace:GetPartBoundsInBox(
            placementCFrame,
            towerModel:GetExtentsSize(),
            overlapParams
    )

    if #touching > 0 then
        return true
    else
        return false
    end

end

local function isInBuildArea(placementCFrame, towerModel)

    local overlapParams = OverlapParams.new()
    overlapParams.FilterDescendantsInstances = {BuildArea}
    overlapParams.FilterType = Enum.RaycastFilterType.Include

    local touching = Workspace:GetPartBoundsInBox(
        placementCFrame,
        towerModel:GetExtentsSize(),
        overlapParams
    )

    if #touching > 0 then
        return true
    else
        return false
    end

end

local function inPath(placementCFrame, towerModel)

    local overlapParams = OverlapParams.new()
    overlapParams.FilterDescendantsInstances = {PathFolder}
    overlapParams.FilterType = Enum.RaycastFilterType.Include

    local touching = Workspace:GetPartBoundsInBox(
        placementCFrame,
        towerModel:GetExtentsSize(),
        overlapParams
    )

    if #touching > 0 then
        return true
    else
        return false
    end

end

TowerUpgradeEvent.OnServerInvoke = function(player, tower)

    local leaderstats = player:FindFirstChild("leaderstats")
    local playerMoney = leaderstats and leaderstats:FindFirstChild("Money")

    if not tower or not tower:IsDescendantOf(TowersFolder) then
        return
    end

    if tower:GetAttribute("Owner") ~= player.UserId then
        return
    end

    if not leaderstats or not playerMoney then
        print(player.Name.." leaderstats or money not found")
        return 
    end

    if playerMoney.Value < tower:GetAttribute("UpgradeCost") then
        print(player.Name.." does not have enough money to upgrade")
        return "NOT ENOUGH MONEY"
    end

    playerMoney.Value -= tower:GetAttribute("UpgradeCost")
    tower:SetAttribute("Level", tower:GetAttribute("Level") + 1)
    tower:SetAttribute("Range", tower:GetAttribute("Range") + 5)
    tower:SetAttribute("Damage", tower:GetAttribute("Damage") + 10)
    tower:SetAttribute("TotalValue", tower:GetAttribute("TotalValue") + tower:GetAttribute("UpgradeCost"))
    tower:SetAttribute("UpgradeCost", math.floor(tower:GetAttribute("UpgradeCost") * 1.5))

    return "UPGRADED"
end

local SELL_PENALTY_RATE = 0.5

TowerSellRemote.OnServerInvoke = function(player, tower)

    if not tower or not tower:IsDescendantOf(TowersFolder) then
        return
    end

    if tower:GetAttribute("Owner") ~= player.UserId then
        print("its not yours")
        return
    end

    local TotalValue = tower:GetAttribute("TotalValue")

    local leaderstats = player:FindFirstChild("leaderstats")
    local playerMoney = leaderstats and leaderstats:FindFirstChild("Money")

    if playerMoney then
        tower:Destroy()

        playerMoney.Value += TotalValue * (1- SELL_PENALTY_RATE)

        return "SOLD"
    else
        print(player.Name.." money not found while trying to sell tower")
        return "ERROR"
    end

    
end

SetTowerTargetMode.OnServerInvoke = function(player, tower, targetMode)

     if not tower or not tower:IsDescendantOf(TowersFolder) then
        return false
    end

    if tower:GetAttribute("Owner") ~= player.UserId then
        print("its not yours")
        return false
    end

    if targetMode == "Closest" or targetMode == "Strongest" or targetMode == "Weakest" then

        tower:SetAttribute("TargetMode", targetMode)
        return true
    else
        print(targetMode.." is not a valid mode")
        return false
    end

end

PlacementEvent2.OnServerEvent:Connect(function(player, placementCFrame, towerName)

    --print(towerName)
    local desireTower = TowerModelsFolder:FindFirstChild(towerName)

    if not desireTower then
        return
    end

    if isOverlappingWithTower(placementCFrame, desireTower) then
        print("overlapping")
        return
    end

    if inPath(placementCFrame, desireTower) then
        print("is in path")
        return
    end

    if not isInBuildArea(placementCFrame, desireTower) then
        print("is not in build area")
        return
    end
    --[[
    if isOverlappingWithTower(placementCFrame) or not isInBuildArea(placementCFrame) or inPath(placementCFrame) then
        return 
    end
    ]]
    

    local leaderstats = player:FindFirstChild("leaderstats")
    local playerMoney = leaderstats and leaderstats:FindFirstChild("Money")

    if not leaderstats or not playerMoney then
        print(player.Name.." leaderstats not found or player money not found")
        return
    end
    
    if playerMoney.Value < TowerConfig[towerName].Cost then
        print(player.Name.." does not have enough money")
        return
    end

    --print(playerMoney.Value)

    playerMoney.Value -= TowerConfig[towerName].Cost
    
    local cloneTemplate = desireTower:Clone()
    cloneTemplate:PivotTo(placementCFrame)
    cloneTemplate:SetAttribute("Owner", player.UserId)
    cloneTemplate:SetAttribute("Cooldown", TowerConfig[towerName].Cooldown)
    cloneTemplate:SetAttribute("Damage", TowerConfig[towerName].Damage)
    cloneTemplate:SetAttribute("Range", TowerConfig[towerName].Range)
    cloneTemplate:SetAttribute("Level", 1)
    cloneTemplate:SetAttribute("UpgradeCost", TowerConfig[towerName].UpgradeCost)
    cloneTemplate:SetAttribute("TotalValue", TowerConfig[towerName].Cost)
    cloneTemplate:SetAttribute("TargetMode", "Closest")
    cloneTemplate.Parent = TowersFolder

    startAttackEnemy(cloneTemplate)


end)