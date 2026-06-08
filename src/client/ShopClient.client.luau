local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SharedFolder = ReplicatedStorage:WaitForChild("Shared")
local ConfigurationsFolder = SharedFolder:WaitForChild("Configurations")
local TowerModelsFolder = SharedFolder:WaitForChild("TowerModels")

local Player = Players.LocalPlayer
local PlayerDataFolder = Player:WaitForChild("Data")
local PlayerUnlockedTowersFolder = PlayerDataFolder:WaitForChild("UnlockedTowers")

local PlayerGui = Player:waitForChild("PlayerGui")

local HomeGui = PlayerGui:WaitForChild("HomeGui")
local MenuTabsFrame = HomeGui:WaitForChild("MenuTabsFrame")
local ShopButton = MenuTabsFrame:WaitForChild("ShopButton")
local TowersUnlockedButton = MenuTabsFrame:WaitForChild("TowersUnlockedButton")

local ShopGui = PlayerGui:WaitForChild("ShopGui")
local ShopMainFrame = ShopGui:WaitForChild("MainFrame")
local ShopTowerFrame = ShopMainFrame:WaitForChild("TowersFrame")
local ShopTowerScrollingFrame = ShopTowerFrame:WaitForChild("ScrollingFrame")
local ShopTowerItemFrameTemplate = ShopTowerScrollingFrame:WaitForChild("ItemFrameTemplate")
local ShopCloseButton = ShopMainFrame:WaitForChild("CloseButton")

local TowersUnlockedGui = PlayerGui:WaitForChild("TowersUnlockedGui")
local TowersUnlockedMainFrame = TowersUnlockedGui:WaitForChild("MainFrame")
local TowersUnlockedSubFrame = TowersUnlockedMainFrame:WaitForChild("SubFrame")
local TowersUnlockedScrollingFrame = TowersUnlockedSubFrame:WaitForChild("ScrollingFrame")
local TowersUnlockedItemFrameTemplate = TowersUnlockedScrollingFrame:WaitForChild("ItemFrameTemplate")
local TowersUnlockedCloseButton = TowersUnlockedMainFrame:WaitForChild("CloseButton")


local TowerShopConfig = require(ConfigurationsFolder:WaitForChild("TowerShopConfig"))

local shopTowerOrder = 0
local towerUnlockedOrder = 0


for TowerName, TowerProperties in pairs(TowerShopConfig) do

    local newItemFrame = ShopTowerItemFrameTemplate:Clone()
    newItemFrame.Name = TowerName
    newItemFrame.Visible = true
    newItemFrame.LayoutOrder = shopTowerOrder
    
    local itemNameText = newItemFrame:WaitForChild("TowerName")
    itemNameText.Text = TowerName:gsub("Tower", " Tower")
    newItemFrame.Parent = ShopTowerScrollingFrame

    local viewportFrame = newItemFrame:WaitForChild("ViewportFrame")
    local cloneTowerModel = TowerModelsFolder:WaitForChild(TowerName):Clone()
    cloneTowerModel:PivotTo(CFrame.new(Vector3.zero))
    cloneTowerModel.Parent = viewportFrame

    local TowerSize = cloneTowerModel:GetExtentsSize()


    local cameraPositionVector = Vector3.new(0, TowerSize.Y/2, TowerSize.Z/2) + Vector3.new(5 ,3, -5)
    

    local fHat = (Vector3.new(0,0,0) - cameraPositionVector).Unit
    local rHat = (fHat:Cross(Vector3.yAxis)).Unit
    local uHat = (rHat:Cross(fHat)).Unit

    local rotationMatrix = CFrame.fromMatrix(Vector3.zero, rHat, uHat,-fHat)

    print(CFrame.new(cameraPositionVector) * rotationMatrix)
    print( CFrame.lookAt(cameraPositionVector, Vector3.new(0,0,0)))

    local camera = Instance.new("Camera")
    camera.CFrame = CFrame.new(cameraPositionVector) * rotationMatrix
    camera.Parent = viewportFrame

    viewportFrame.CurrentCamera = camera

    local UnlockButton = newItemFrame:WaitForChild("UnlockButton")

    if PlayerUnlockedTowersFolder:FindFirstChild(TowerName) then
        UnlockButton.Text = "Owned"
        UnlockButton.BackgroundColor3 = Color3.fromRGB(161, 161, 161)
    else
        UnlockButton.Text = "Unlock"
        UnlockButton.BackgroundColor3 = Color3.fromRGB(22, 218, 45)
    end

    shopTowerOrder -= 1
end

for _, obj in pairs(PlayerUnlockedTowersFolder:GetChildren()) do

    local newItemFrame = TowersUnlockedItemFrameTemplate:Clone()
    newItemFrame.Name = obj.Name
    newItemFrame.LayoutOrder = towerUnlockedOrder
    newItemFrame.Parent = TowersUnlockedScrollingFrame
    newItemFrame.Visible = true

    local ItemNameText = newItemFrame:WaitForChild("TowerNameText")
    ItemNameText.Text = (obj.Name):gsub("Tower", " Tower")

    local equipButton = newItemFrame:WaitForChild("EquipButton")
    
    local viewportFrame = newItemFrame:WaitForChild("ViewportFrame")
    local cloneTowerModel = TowerModelsFolder:WaitForChild(obj.Name):Clone()
    cloneTowerModel:PivotTo(CFrame.new(Vector3.zero))
    cloneTowerModel.Parent = viewportFrame

    local TowerSize = cloneTowerModel:GetExtentsSize()


    local cameraPositionVector = Vector3.new(0, TowerSize.Y/2, TowerSize.Z/2) + Vector3.new(5 ,3, -5)
    

    local fHat = (Vector3.new(0,0,0) - cameraPositionVector).Unit
    local rHat = (fHat:Cross(Vector3.yAxis)).Unit
    local uHat = (rHat:Cross(fHat)).Unit

    local rotationMatrix = CFrame.fromMatrix(Vector3.zero, rHat, uHat,-fHat)

    print(CFrame.new(cameraPositionVector) * rotationMatrix)
    print( CFrame.lookAt(cameraPositionVector, Vector3.new(0,0,0)))

    local camera = Instance.new("Camera")
    camera.CFrame = CFrame.new(cameraPositionVector) * rotationMatrix
    camera.Parent = viewportFrame

    viewportFrame.CurrentCamera = camera

    if obj.Value == true then
        equipButton.Text = "Equipped"
        equipButton.BackgroundColor3 = Color3.fromRGB(161, 161, 161)
    else
        equipButton.Text = "Equip"
        equipButton.BackgroundColor3 = Color3.fromRGB(22, 218, 45)
    end

    towerUnlockedOrder -= 1
end

TowersUnlockedButton.MouseButton1Click:Connect(function()

    TowersUnlockedMainFrame.Visible = true

end)

ShopButton.MouseButton1Click:Connect(function()

    ShopMainFrame.Visible = true

end)

TowersUnlockedCloseButton.MouseButton1Click:Connect(function()

    TowersUnlockedMainFrame.Visible = false

end)

ShopCloseButton.MouseButton1Click:Connect(function()

     ShopMainFrame.Visible = false

end)