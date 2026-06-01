local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local SharedFolder = ReplicatedStorage:WaitForChild("Shared")

local TowersFolder = Workspace:WaitForChild("Towers")

local placementEvent = SharedFolder:WaitForChild("PlacementEvent")
local TowerUpgradeEvent = SharedFolder:WaitForChild("TowerUpgradeEvent")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()


local isPreviewing = false
local previewTower = nil

local towerSelected = nil
local rangeCircleOn = nil

local function RemoveRangeCircle(tower)

    rangeCircle = nil

    local rangeCircle = Workspace:FindFirstChild("RangeCircle")
    if rangeCircle then
        rangeCircle:Destroy()
    end

    

end

local function showRangeCircle(tower)

    if rangeCircleOn and rangeCircle == towerSelected then
        return
    end

    if rangeCircle then
       RemoveRangeCircle()
    end

    rangeCircle = tower

    local TowerRange = tower:GetAttribute("Range")
    local TowerSize = tower:GetExtentsSize()
    local TowerHeight = TowerSize.Y

    local circle = Instance.new("Part")
    circle.Name = "RangeCircle"
    circle.Shape = Enum.PartType.Cylinder
    circle.Size = Vector3.new(0.05, TowerRange * 2, TowerRange * 2)  --range is just the radius, size is the diameter therefore the x2
    circle.BrickColor = BrickColor.new("Bright green")
    circle.CanCollide = false
    circle.Anchored = true
    circle.Transparency = 0.4
    circle.Parent = Workspace

    local transformedXHat = Vector3.new(0,1,0)
    local transformedYHat = Vector3.new(-1,0,0)
    local transformedZHat = Vector3.new(0,0,1)
    local RotationMatrix = CFrame.fromMatrix(Vector3.zero, transformedXHat, transformedYHat, transformedZHat) --techniquely not just rotational matrix

    local towerPivotPosition = tower:GetPivot().Position - Vector3.new(0,TowerHeight/2, 0)
    local TranslationMatrix = CFrame.new(towerPivotPosition)

    circle.CFrame = TranslationMatrix * RotationMatrix

end



local function createPreviewTower()
    --print("created")
    local TowerTemplate = SharedFolder:WaitForChild("TowerTemplate")

    local TowerClone = TowerTemplate:Clone()

    for _, obj in pairs(TowerClone:GetDescendants()) do
        --print(obj.ClassName)
        if obj:IsA("BasePart") then

            obj.Transparency = 0.5
            obj.Anchored = true
            obj.CanCollide = false

        end

    end

    local towerSize = TowerClone:GetExtentsSize()
    local towerHeight = towerSize.Y
    TowerClone:PivotTo(CFrame.new(Mouse.Hit.Position + Vector3.new(0,towerHeight/2,0))) 

    TowerClone.Parent = Workspace


    Mouse.TargetFilter = TowerClone
    
    return TowerClone

end


local function updateTowerInfoGui(tower)

    local PlayerGui = Player:FindFirstChild("PlayerGui")
    local TowerInfoGui = PlayerGui and PlayerGui:FindFirstChild("TowerInfoGui")
    local MainFrame = TowerInfoGui and TowerInfoGui:FindFirstChild("MainFrame")
    local StatsFrame = MainFrame and MainFrame:FindFirstChild("StatsFrame")
    local TowerFrame = MainFrame and MainFrame:FindFirstChild("TowerFrame")
    local CooldownText = StatsFrame and StatsFrame:FindFirstChild("CoolDownText")
    local DamageText = StatsFrame and StatsFrame:FindFirstChild("DamageText")
    local RangeText = StatsFrame and StatsFrame:FindFirstChild("RangeText")
    local UpgradeButton = MainFrame and MainFrame:FindFirstChild("UpgradeButton")

    print(tower:GetAttribute("Cooldown"), tower:GetAttribute("Damage"), tower:GetAttribute("Range"),tostring(tower:GetAttribute("UpgradeCost")))

    if CooldownText then
        CooldownText.Text = "Cooldown: "..tostring(tower:GetAttribute("Cooldown"))
    end

    if DamageText then
        DamageText.Text = "Damage: "..tostring(tower:GetAttribute("Damage"))
    end

    if RangeText then
        RangeText.Text = "Range: "..tostring(tower:GetAttribute("Range"))
    end

    if UpgradeButton then

        UpgradeButton.BackgroundColor3 = Color3.fromRGB(24,255,32)
        
        UpgradeButton.Text = "Upgrade: $"..tostring(tower:GetAttribute("UpgradeCost"))
    end

end

local function ShowTowerInViewportFrame(TowerModel, ViewportFrame)

    for _,obj in pairs(ViewportFrame:GetChildren()) do
        obj:Destroy()
    end

    local cloneTower = TowerModel:Clone()
    cloneTower:PivotTo(CFrame.new(0,0,0))
    cloneTower.Parent = ViewportFrame

    local towerSize = cloneTower:GetExtentsSize()

    local cameraPositionVector = Vector3.new(0, towerSize.Y/2 ,towerSize.Z/2) + Vector3.new(-3, 3, 2)

    -- forming the basis for the rotational matrix
    local fHat = -cameraPositionVector.Unit
    local rHat = fHat:Cross(Vector3.yAxis).Unit
    local uHat = rHat:Cross(fHat).Unit

    -- translation * rotation , i.e rotation -> translation

    local CompositionOfTransform = CFrame.new(cameraPositionVector) * CFrame.fromMatrix(Vector3.zero, rHat, uHat, -fHat) 

    local finalMatrix = CFrame.lookAt(cameraPositionVector, Vector3.new(0,0,0))

    print(CompositionOfTransform)
    print(finalMatrix)

    local Camera = Instance.new("Camera")
    Camera.CFrame = CompositionOfTransform
    Camera.Parent = ViewportFrame

    ViewportFrame.CurrentCamera = Camera



end

local function showTowerInfoGui(tower)

    local PlayerGui = Player:FindFirstChild("PlayerGui")
    local TowerInfoGui = PlayerGui and PlayerGui:FindFirstChild("TowerInfoGui")
    local MainFrame = TowerInfoGui and TowerInfoGui:FindFirstChild("MainFrame")
    local StatsFrame = MainFrame and MainFrame:FindFirstChild("StatsFrame")
    local TowerFrame = MainFrame and MainFrame:FindFirstChild("TowerFrame")
    local ViewportFrame = TowerFrame and TowerFrame:FindFirstChild("ViewportFrame")
    local CooldownText = StatsFrame and StatsFrame:FindFirstChild("CoolDownText")
    local DamageText = StatsFrame and StatsFrame:FindFirstChild("DamageText")
    local RangeText = StatsFrame and StatsFrame:FindFirstChild("RangeText")

    local TowerTemplate = SharedFolder:WaitForChild("TowerTemplate")

    --local TowerFrame = script.Parent.MainFrame.TowerFrame


    ShowTowerInViewportFrame(TowerTemplate,ViewportFrame)
    updateTowerInfoGui(tower)
    MainFrame.Visible = true
    
end

UserInputService.InputBegan:Connect(function(inputObj, gameProccessed)

    if gameProccessed then

        return
    end
    
    if inputObj.KeyCode == Enum.KeyCode.P then
        if isPreviewing then
            isPreviewing = false
            previewTower:Destroy()
            previewTower = nil
        else
            isPreviewing = true
            previewTower = createPreviewTower()
        end
       
    end

    if inputObj.KeyCode == Enum.KeyCode.U and towerSelected ~= nil then
        
        local upgradeResult = TowerUpgradeEvent:InvokeServer(towerSelected)

        if not upgradeResult then
            return
        end

        local PlayerGui = Player:FindFirstChild("PlayerGui")
        local TowerInfoGui = PlayerGui and PlayerGui:FindFirstChild("TowerInfoGui")
        local MainFrame = TowerInfoGui and TowerInfoGui:FindFirstChild("MainFrame")
        local StatsFrame = MainFrame and MainFrame:FindFirstChild("StatsFrame")
        local TowerFrame = MainFrame and MainFrame:FindFirstChild("TowerFrame")
        local CooldownText = StatsFrame and StatsFrame:FindFirstChild("CoolDownText")
        local DamageText = StatsFrame and StatsFrame:FindFirstChild("DamageText")
        local RangeText = StatsFrame and StatsFrame:FindFirstChild("RangeText")
        local UpgradeButton = MainFrame and MainFrame:FindFirstChild("UpgradeButton")
        
        if upgradeResult == "NOT ENOUGH MONEY" then
            local tempTow = towerSelected
            UpgradeButton.BackgroundColor3 = Color3.fromRGB(255,0,0)
            UpgradeButton.Text = "You're broke ;("
            task.wait(1)
            if not towerSelected or towerSelected ~= tempTow then
                return -- just too check if the player already clicked something else
            end
            UpgradeButton.BackgroundColor3 = Color3.fromRGB(24,255,32)
            UpgradeButton.Text = "Upgrade: $"..tostring(towerSelected:GetAttribute("UpgradeCost"))
            print(UpgradeButton.BackgroundColor3)
        elseif upgradeResult == "UPGRADED" then
            updateTowerInfoGui(towerSelected)
        end
        
        print("requesting ugrade")
    end



end)

Mouse.Button1Down:Connect(function()

    if Mouse.Target and Mouse.Target:IsDescendantOf(TowersFolder) then
       -- print("Yes")
        towerSelected = Mouse.Target:FindFirstAncestorWhichIsA("Model")
        
        print(Mouse.Target:FindFirstAncestorWhichIsA("Model"))
        
        showTowerInfoGui(towerSelected)

        showRangeCircle(towerSelected)
        --code here what happens after selected
    else
        local PlayerGui = Player:FindFirstChild("PlayerGui")
        local TowerInfoGui = PlayerGui and PlayerGui:FindFirstChild("TowerInfoGui")
        local MainFrame = TowerInfoGui and TowerInfoGui:FindFirstChild("MainFrame")

        RemoveRangeCircle()
        towerSelected = nil

        if MainFrame then
            MainFrame.Visible = false
        end

        if isPreviewing and previewTower then
            placementEvent:FireServer(previewTower:GetPivot())
            isPreviewing = false
            previewTower:Destroy()
            previewTower = nil
            --placeTower(previewTower)
        

        end
    end

end)

Mouse.Move:Connect(function()

    --print(previewTower)

    

    if Mouse.Target and Mouse.Target:IsDescendantOf(TowersFolder) then
        --show tower hover effect
        
    else
        if not isPreviewing or previewTower == nil then
            if previewTower then
                previewTower:Destroy()
                previewTower = nil
            end
            return
        end

        local towerSize = previewTower:GetExtentsSize()
        local towerHeight = towerSize.Y
        
        previewTower:PivotTo(CFrame.new(Mouse.Hit.Position + Vector3.new(0,towerHeight/2,0))) 

    end
end)




