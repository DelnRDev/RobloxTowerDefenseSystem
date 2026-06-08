local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SharedFolder = ReplicatedStorage:WaitForChild("Shared")
local ConfigurationsFolder = SharedFolder:WaitForChild("Configurations")
local TowerModelsFolder = SharedFolder:WaitForChild("TowerModels")

local Player = Players.LocalPlayer
local PlayerDataFolder = Player:WaitForChild("Data")
local PlayerLeaderstatsFolder = Player:WaitForChild("leaderstats")
local PlayerCoins = PlayerDataFolder:WaitForChild("Coins")
local PlayerGems = PlayerDataFolder:WaitForChild("Gems")
local PlayerUnlockedTowersFolder = PlayerDataFolder:WaitForChild("UnlockedTowers")

local PlayerGui = Player:waitForChild("PlayerGui")

local HomeGui = PlayerGui:WaitForChild("HomeGui")
local MenuTabsFrame = HomeGui:WaitForChild("MenuTabsFrame")
local CurrencyFrame = HomeGui:WaitForChild("CurrencyFrame")
local GemsText = CurrencyFrame:WaitForChild("GemsText")
local CoinsText = CurrencyFrame:WaitForChild("CoinsText")

local ShopButton = MenuTabsFrame:WaitForChild("ShopButton")
local TowersUnlockedButton = MenuTabsFrame:WaitForChild("TowersUnlockedButton")

local ShopGui = PlayerGui:WaitForChild("ShopGui")
local ShopMainFrame = ShopGui:WaitForChild("MainFrame")
local ShopTowerFrame = ShopMainFrame:WaitForChild("TowersFrame")
local ShopTowerScrollingFrame = ShopTowerFrame:WaitForChild("ScrollingFrame")
local ShopTowerItemFrameTemplate = ShopTowerScrollingFrame:WaitForChild("ItemFrameTemplate")
local ShopCloseButton = ShopMainFrame:WaitForChild("CloseButton")

local function updateCoinsText(playerCoins)

    CoinsText.Text = "Coins: "..playerCoins

end

local function updateGemsText(playerGems)

    GemsText.Text = "Gems: "..playerGems

end

updateCoinsText(PlayerCoins.Value)
updateGemsText(PlayerGems.Value)

PlayerCoins.Changed:Connect(function(newVal)

    updateCoinsText(newVal)

end)

PlayerGems.Changed:Connect(function(newVal)

    updateGemsText(newVal)

end)
