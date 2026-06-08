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


local TowersUnlockedGui = PlayerGui:WaitForChild("TowersUnlockedGui")
local TowersUnlockedMainFrame = TowersUnlockedGui:WaitForChild("MainFrame")
local TowersUnlockedSubFrame = TowersUnlockedMainFrame:WaitForChild("SubFrame")
local TowersUnlockedScrollingFrame = TowersUnlockedSubFrame:WaitForChild("ScrollingFrame")
local TowersUnlockedItemFrameTemplate = TowersUnlockedScrollingFrame:WaitForChild("ItemFrameTemplate")
local TowersUnlockedCloseButton = TowersUnlockedMainFrame:WaitForChild("CloseButton")
local WarningText = TowersUnlockedGui:WaitForChild("WarningText")

local TowerShopConfig = require(ConfigurationsFolder:WaitForChild("TowerShopConfig"))

local towerUnlockedOrder = 0



local function updateUnlockedTowerGui()

    for _, obj in pairs(TowersUnlockedScrollingFrame:GetChildren()) do
        if obj:IsA("Frame") and obj.Name ~= "ItemFrameTemplate" then
            obj:Destroy()
        end
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

        equipButton.MouseButton1Click:Connect(function()
            
            if PlayerUnlockedTowersFolder:FindFirstChild(obj.Name).Value == true then
                
                local result = UnequipTowerRemote:InvokeServer(obj.Name)

                if result == "REACHED MIN EQUIPPED" then

                   WarningText.Text = "YOU MUST EQUIP AT LEAST ONE TOWER"
                   WarningText.Visible = true
                   task.wait(3)
                    WarningText.Visible = false

                elseif result == "UNEQUIPPED" then

                    equipButton.Text = "Equip"
                    equipButton.BackgroundColor3 = Color3.fromRGB(22, 218, 45)

                end

            else

                local result = EquipTowerRemote:InvokeServer(obj.Name)

                if result == "REACHED MAX EQUIPPED" then

                    WarningText.Text = "YOU'VE REACHED THE MAXIMUM EQUIPPED TOWER"
                    WarningText.Visible = true
                    task.wait(3)
                    WarningText.Visible = false

                elseif result == "EQUIPPED" then

                    equipButton.Text = "Equipped"
                    equipButton.BackgroundColor3 = Color3.fromRGB(161, 161, 161)

                end

            end

        end)

        towerUnlockedOrder += 1
    end


end

updateUnlockedTowerGui()

TowersUnlockedButton.MouseButton1Click:Connect(function()

    TowersUnlockedMainFrame.Visible = true
    updateUnlockedTowerGui()

end)


TowersUnlockedCloseButton.MouseButton1Click:Connect(function()

    TowersUnlockedMainFrame.Visible = false

end)

