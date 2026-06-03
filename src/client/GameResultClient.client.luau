
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local PlayerGui = Player:WaitForChild("PlayerGui")
local GameResultGui = PlayerGui:WaitForChild("GameResultGui")
local MainFrame = GameResultGui:WaitForChild("MainFrame")
local GameResultText = MainFrame:WaitForChild("GameResultText")

local GameStats = Workspace:WaitForChild("GameStats")
local GameOver = GameStats:WaitForChild("GameOver")
local Victory = GameStats:WaitForChild("Victory")

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
    end
end)

Victory.Changed:Connect(function()
    if Victor.Value == true then
        showGameResultUI(true)
    end
end)