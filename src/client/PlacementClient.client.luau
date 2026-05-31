local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local SharedFolder = ReplicatedStorage:WaitForChild("Shared")

local placementEvent = SharedFolder:WaitForChild("PlacementEvent")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local isPreviewing = false
local previewTower = nil

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



end)

Mouse.Button1Down:Connect(function()

    if isPreviewing and previewTower then
        placementEvent:FireServer(previewTower:GetPivot())
        isPreviewing = false
        previewTower:Destroy()
        previewTower = nil
        --placeTower(previewTower)
       

    end

end)

Mouse.Move:Connect(function()

    --print(previewTower)

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
   
end)


