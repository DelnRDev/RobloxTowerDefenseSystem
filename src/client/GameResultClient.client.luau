
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer


local GameStats = Workspace:WaitForChild("GameStats")
local GameOver = GameStats:WaitForChild("GameOver")
local Victory = GameStats:WaitForChild("Victory")

local PlayerGui = Player:FindFirstChild("PlayerGui")
local GameResultGui =  PlayerGui:WaitForChild("GameResultGui")
local TowerInfoGui = PlayerGui:WaitForChild("TowerInfoGui")
local MainFrame =  GameResultGui:WaitForChild("MainFrame")
local GameResultText =  MainFrame:WaitForChild("GameResultText")

local function showGameResultUI(victory)

    MainFrame.Visible = true

    if victory then
        GameResultText.Text = "VICTORY"
        GameResultText.TextColor3 = Color3.fromRGB(251, 255, 28)
    else
        GameResultText.Text = "GAME OVER"
        GameResultText.TextColor3 = Color3.fromRGB(255, 17, 61)
    end

end

GameOver.Changed:Connect(function()
    if GameOver.Value == true then
        showGameResultUI(false)
        TowerInfoGui.Enabled = false
    end
end)

Victory.Changed:Connect(function()
    if Victory.Value == true then
        showGameResultUI(true)
        TowerInfoGui.Enabled = false
    end
end)