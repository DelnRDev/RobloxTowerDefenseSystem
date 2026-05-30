local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SharedFolder = ReplicatedStorage:WaitForChild("Shared")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local TowerTemplate = SharedFolder:WaitForChild("TowerTemplate")

local TowerClone = TowerTemplate:Clone()

TowerClone.Parent = Workspace

for _, obj in pairs(TowerClone:GetDescendants()) do
    print(typeof(obj))
end
--[[
Mouse.TargetFilter = tower

Mouse.Move:Connect(function()
   
    tower:PivotTo(CFrame.new(Mouse.Hit.Position))   

end)
]]