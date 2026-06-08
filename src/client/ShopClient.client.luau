local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SharedFolder = ReplicatedStorage:WaitForChild("Shared")
local ConfigurationsFolder = SharedFolder:WaitForChild("Configurations")
local TowerModelsFolder = SharedFolder:WaitForChild("TowerModels")
local RemotesFolder = SharedFolder:WaitForChild("Remotes")

local EquipTowerRemote = RemotesFolder:WaitForChild("EquipTowerRemote")
local UnlockTowerRemote = RemotesFolder:WaitForChild("UnlockTowerRemote")
local UnequipTowerRemote = RemotesFolder:WaitForChild("UnequipTowerRemote")

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


local TowerShopConfig = require(ConfigurationsFolder:WaitForChild("TowerShopConfig"))

local shopTowerOrder = 0


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

        local itemCostText = newItemFrame:WaitForChild("TowerCostText")
        itemCostText.Visible = false
    else
        UnlockButton.Text = "Unlock"
        UnlockButton.BackgroundColor3 = Color3.fromRGB(22, 218, 45)

        local itemCostText = newItemFrame:WaitForChild("TowerCostText")
        itemCostText.Text = TowerProperties.Cost.." Coins"
    end

    UnlockButton.MouseButton1Click:Connect(function()
        
        local result = UnlockTowerRemote:InvokeServer(TowerName)
        print(result)
        if result == "UNLOCKED" then

            UnlockButton.Text = "Owned"
            UnlockButton.BackgroundColor3 = Color3.fromRGB(161, 161, 161)

            local itemCostText = newItemFrame:WaitForChild("TowerCostText")
            itemCostText.Visible = false

        elseif result == "NOT ENOUGH COINS" then
            
            UnlockButton.Text = "not enough coins"
            UnlockButton.BackgroundColor3 = Color3.fromRGB(255,0 ,0)
            task.wait(2)
            UnlockButton.Text = "Unlock"
            UnlockButton.BackgroundColor3 = Color3.fromRGB(22, 218, 45)

        end

    end)

    shopTowerOrder -= 1
end




ShopButton.MouseButton1Click:Connect(function()

    ShopMainFrame.Visible = true

end)


ShopCloseButton.MouseButton1Click:Connect(function()

     ShopMainFrame.Visible = false

end)