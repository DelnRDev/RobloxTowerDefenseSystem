local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local SharedFolder = ReplicatedStorage:WaitForChild("Shared")

local TowersFolder = Workspace:WaitForChild("Towers")
local PathFolder = Workspace:WaitForChild("Path")
local BuildAreaFolder = Workspace:WaitForChild("BuildArea")

local placementEvent = SharedFolder:WaitForChild("PlacementEvent")
local TowerUpgradeEvent = SharedFolder:WaitForChild("TowerUpgradeEvent")
local TowerSellRemote = SharedFolder:WaitForChild("TowerSellRemote")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()


local isPreviewing = false
local previewTower = nil

local towerSelected = nil
local SelectedRangeTower = nil
local highlightedSelectedTower = nil
local highlightedHoverTower = nil

local function setPreviewColor(color)

    for i, obj in pairs(previewTower:GetDescendants()) do

        if obj:IsA("BasePart") then
            obj.BrickColor = color
        end

    end

end

local function inBuildingArea()

  
    local overlapParams = OverlapParams.new()
    overlapParams.FilterDescendantsInstances = {BuildAreaFolder}
    overlapParams.FilterType = Enum.RaycastFilterType.Include
    
    local touch = Workspace:GetPartBoundsInBox(
        previewTower:GetPivot(),
        previewTower:GetExtentsSize(),
        overlapParams
    )
    
    if #touch > 0 then
        return true

    else
        return false
    end

end

local function inPath()

    if not previewTower then
        return
    end

    local overlapParams = OverlapParams.new()
    overlapParams.FilterDescendantsInstances = {PathFolder}
    overlapParams.FilterType = Enum.RaycastFilterType.Include
    
    local touch = Workspace:GetPartBoundsInBox(
        previewTower:GetPivot(),
        previewTower:GetExtentsSize(),
        overlapParams
    )

    if #touch > 0 then
        return true

    else
        return false
    end

end

local function isOverlappingWithTower()

    if not previewTower then
        return
    end

    local overlapParams = OverlapParams.new()
    overlapParams.FilterDescendantsInstances = {TowersFolder}
    overlapParams.FilterType = Enum.RaycastFilterType.Include
    
    local touch = Workspace:GetPartBoundsInBox(
        previewTower:GetPivot(),
        previewTower:GetExtentsSize(),
        overlapParams
    )

    if #touch > 0 then
        return true

    else
        return false
    end

    

end

local function canPlaceTower()
    
    if not previewTower then
        print("nah its not even previewing")
        return
    end

    if inPath() then
         print("nah its in the path")
        return false
    end

    if not inBuildingArea() then
         print("nah its not in the building area")
        return false
    end

    if isOverlappingWithTower() then
         print("nah its overlapping with other tower")
        return false
    end
    

    --print(inPath(),  inBuildingArea(), isOverlappingWithTower())

    return true
end

local function highlightHoverTower(tower)

    if tower:FindFirstChild("Highlight") then
        return
    end

    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(11, 117, 255)
    highlight.Name = "Highlight"
    highlight.Parent = tower

end

local function highlightSelectedTower(tower)

    if tower:FindFirstChild("Highlight") then
        return
    end

    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(251, 255, 26)
    highlight.Name = "Highlight"
    highlight.Parent = tower

end




local function removeTowerHighlight(tower)

    local Hightlight = tower and tower:FindFirstChild("Highlight")
    if Hightlight then
        
        Hightlight:Destroy()
    end

end

local function RemoveRangeCircle(tower)

    SelectedRangeTower = nil

    local rangeCircle = Workspace:FindFirstChild("RangeCircle")
    if rangeCircle then
        rangeCircle:Destroy()
    end

end

local function showRangeCircle(tower)

    if SelectedRangeTower == tower then
        return
    end

   
    RemoveRangeCircle()
    

    SelectedRangeTower = tower

    local TowerRange = tower:GetAttribute("Range")
    local TowerSize = tower:GetExtentsSize()
    local TowerHeight = TowerSize.Y

    local circle = Instance.new("Part")
    circle.Name = "RangeCircle"
    circle.Shape = Enum.PartType.Cylinder
    circle.Size = Vector3.new(0.05, TowerRange * 2, TowerRange * 2)  --range is just the radius, size is the diameter therefore the x2
    circle.BrickColor = BrickColor.new("Bright green")
    circle.CanCollide = false
    circle.CanTouch = false
    circle.CanQuery = false
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

local SELL_PENALTY_RATE = 0.5

local function updateTowerInfoGui(tower)

    local PlayerGui = Player:FindFirstChild("PlayerGui")
    local TowerInfoGui = PlayerGui and PlayerGui:FindFirstChild("TowerInfoGui")
    local MainFrame = TowerInfoGui and TowerInfoGui:FindFirstChild("MainFrame")
    local StatsFrame = MainFrame and MainFrame:FindFirstChild("StatsFrame")
    local TowerFrame = MainFrame and MainFrame:FindFirstChild("TowerFrame")
    local CooldownText = StatsFrame and StatsFrame:FindFirstChild("CoolDownText")
    local DamageText = StatsFrame and StatsFrame:FindFirstChild("DamageText")
    local RangeText = StatsFrame and StatsFrame:FindFirstChild("RangeText")
    local ButtonsFrame = MainFrame and MainFrame:FindFirstChild("ButtonsFrame")
    local SellButton = ButtonsFrame and ButtonsFrame:FindFirstChild("SellButton")
    local UpgradeButton = ButtonsFrame and ButtonsFrame:FindFirstChild("UpgradeButton")

    --print(tower:GetAttribute("Cooldown"), tower:GetAttribute("Damage"), tower:GetAttribute("Range"),tostring(tower:GetAttribute("UpgradeCost")))

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

    if SellButton then
        --print("Ye sellbuutton")
       SellButton.Text = "Sell: $"..tostring(tower:GetAttribute("TotalValue") * (1 - SELL_PENALTY_RATE))

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

    --print(CompositionOfTransform)
    --print(finalMatrix)

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

    --local TowerTemplate = SharedFolder:WaitForChild("TowerTemplate")

    --local TowerFrame = script.Parent.MainFrame.TowerFrame


    ShowTowerInViewportFrame(tower,ViewportFrame)
    updateTowerInfoGui(tower)
    MainFrame.Visible = true
    
end

UserInputService.InputBegan:Connect(function(inputObj, gameProccessed)

    local PlayerGui = Player:FindFirstChild("PlayerGui")
    local TowerInfoGui = PlayerGui and PlayerGui:FindFirstChild("TowerInfoGui")
    local MainFrame = TowerInfoGui and TowerInfoGui:FindFirstChild("MainFrame")
    local StatsFrame = MainFrame and MainFrame:FindFirstChild("StatsFrame")
    local TowerFrame = MainFrame and MainFrame:FindFirstChild("TowerFrame")
    local CooldownText = StatsFrame and StatsFrame:FindFirstChild("CoolDownText")
    local DamageText = StatsFrame and StatsFrame:FindFirstChild("DamageText")
    local RangeText = StatsFrame and StatsFrame:FindFirstChild("RangeText")
    local ButtonsFrame = MainFrame and MainFrame:FindFirstChild("ButtonsFrame")
    local SellButton = ButtonsFrame and ButtonsFrame:FindFirstChild("SellButton")
    local UpgradeButton = ButtonsFrame and ButtonsFrame:FindFirstChild("UpgradeButton")

    if gameProccessed then

        return
    end
    
    if inputObj.KeyCode == Enum.KeyCode.P then

        local PlayerGui = Player:FindFirstChild("PlayerGui")
        local TowerInfoGui = PlayerGui and PlayerGui:FindFirstChild("TowerInfoGui")
        local MainFrame = TowerInfoGui and TowerInfoGui:FindFirstChild("MainFrame")


        RemoveRangeCircle()
        removeTowerHighlight(towerSelected)

        towerSelected = nil

        if MainFrame then
            MainFrame.Visible = false
        end

        if isPreviewing then
            isPreviewing = false
            previewTower:Destroy()
            previewTower = nil
        else
            isPreviewing = true
            previewTower = createPreviewTower()
            if canPlaceTower() then
                setPreviewColor(BrickColor.new("Bright green"))
            else
                setPreviewColor(BrickColor.new("Bright red"))
            end
        end
       
    end

    if inputObj.KeyCode == Enum.KeyCode.U and towerSelected ~= nil then
        
        local upgradeResult = TowerUpgradeEvent:InvokeServer(towerSelected)

        if not upgradeResult then
            return
        end

      
        
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
            --print(UpgradeButton.BackgroundColor3)
        elseif upgradeResult == "UPGRADED" then
            updateTowerInfoGui(towerSelected)
        end
        
        --print("requesting ugrade")
    end

    if inputObj.KeyCode == Enum.KeyCode.X and towerSelected ~= nil then

        local sellResult = TowerSellRemote:InvokeServer(towerSelected)

        if sellResult then
            
            RemoveRangeCircle(towerSelected)
            towerSelected = nil
            MainFrame.Visible = false
        end

    end

end)

Mouse.Button1Down:Connect(function()

    --print(canPlaceTower())

    if Mouse.Target and Mouse.Target:IsDescendantOf(TowersFolder) then

        --print(Mouse.Target:FindFirstAncestorWhichIsA("Model"):GetAttribute("Owner") , Player.UserId )
        
        if isPreviewing and previewTower then
            isPreviewing = false
            previewTower:Destroy()
            previewTower = nil
        end
        

        if Mouse.Target:FindFirstAncestorWhichIsA("Model"):GetAttribute("Owner") ~= Player.UserId then
            return
        end
       -- print("Yes")
        
        removeTowerHighlight(towerSelected) --remove highlight on previously selected tower
        removeTowerHighlight(highlightedHoverTower)
        highlightedHoverTower = nil
        towerSelected = Mouse.Target:FindFirstAncestorWhichIsA("Model")
        
        --print(Mouse.Target:FindFirstAncestorWhichIsA("Model"))
        
        showTowerInfoGui(towerSelected)

        showRangeCircle(towerSelected)

        highlightSelectedTower(towerSelected)
        --code here what happens after selected
    else
        local PlayerGui = Player:FindFirstChild("PlayerGui")
        local TowerInfoGui = PlayerGui and PlayerGui:FindFirstChild("TowerInfoGui")
        local MainFrame = TowerInfoGui and TowerInfoGui:FindFirstChild("MainFrame")

        RemoveRangeCircle()
        removeTowerHighlight(towerSelected)

        towerSelected = nil

        
        
        if MainFrame then
            MainFrame.Visible = false
        end

        if isPreviewing and previewTower then

            if canPlaceTower() then
                placementEvent:FireServer(previewTower:GetPivot())
                isPreviewing = false
                previewTower:Destroy()
                previewTower = nil
            else
                print("you cannot place here")
            end
            
            --placeTower(previewTower)
        

        end
    end

end)

Mouse.Move:Connect(function()
    
    if Mouse.Target and Mouse.Target:IsDescendantOf(TowersFolder) then

        local tower = Mouse.Target:FindFirstAncestorWhichIsA("Model")
        --removeTowerHighlight(highlightedHoverTower)
        if tower ~= towerSelected then
            --print(tower, towerSelected)
            --removeTowerHighlight
            removeTowerHighlight(highlightedHoverTower)
            highlightHoverTower(tower)
            highlightedHoverTower = tower
        else
            removeTowerHighlight(highlightedHoverTower)
        end

    else
       -- if highlightedHoverTower ~= towerSelected then
            
            removeTowerHighlight(highlightedHoverTower)
            highlightedHoverTower = nil
       -- end
        if not isPreviewing or previewTower == nil then
            if previewTower then
                previewTower:Destroy()
                previewTower = nil
            end
            return
        end

       

        local towerSize = previewTower:GetExtentsSize()
        local towerHeight = towerSize.Y

        if canPlaceTower() then
            print("can place")
            setPreviewColor(BrickColor.new("Bright green"))
        else
            setPreviewColor(BrickColor.new("Bright red"))
            print("you cannot place here")
        end
        
        previewTower:PivotTo(CFrame.new(Mouse.Hit.Position + Vector3.new(0,towerHeight/2,0))) 

    end
end)