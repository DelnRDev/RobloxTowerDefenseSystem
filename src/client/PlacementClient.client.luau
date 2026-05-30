local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SharedFolder = ReplicatedStorage:WaitForChild("Shared")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local TowerTemplate = SharedFolder:WaitForChild("TowerTemplate")

local TowerClone = TowerTemplate:Clone()

for _, obj in pairs(TowerClone:GetDescendants()) do
    print(obj.ClassName)
    if obj:IsA("Part") or obj:IsA("WedgePart") then

        obj.Transparency = 0.5
        obj.Anchored = true
        obj.CanCollide = false

    end

end

TowerClone.Parent = Workspace


Mouse.TargetFilter = TowerClone

Mouse.Move:Connect(function()

    local towerSize = TowerClone:GetExtentsSize()
    local towerHeight = towerSize.Y
   
    TowerClone:PivotTo(CFrame.new(Mouse.Hit.Position + Vector3.new(0,towerHeight/2,0)))    

end)
