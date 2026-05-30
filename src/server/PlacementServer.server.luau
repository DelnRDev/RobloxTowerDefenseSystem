local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local SharedFolder = ReplicatedStorage:WaitForChild("Shared")

local templateTower = SharedFolder:WaitForChild("TowerTemplate")

local PlacementEvent = SharedFolder:WaitForChild("PlacementEvent")

PlacementEvent.OnServerEvent:Connect(function(player, placementCFrame)
   
    local cloneTemplate = templateTower:Clone()
    cloneTemplate:PivotTo(placementCFrame)
    cloneTemplate.Parent = Workspace

end)