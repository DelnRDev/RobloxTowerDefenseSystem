
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer


local GameStats = Workspace:WaitForChild("GameStats")
local GameOver = GameStats:WaitForChild("GameOver")
local Victory = GameStats:WaitForChild("Victory")

local function showGameResultUI(victory)

    local PlayerGui = Player:FindFirstChild("PlayerGui")
    local GameResultGui = PlayerGui and PlayerGui:FindFirstChild("GameResultGui")
    local MainFrame = GameResultGui and GameResultGui:FindFirstChild("MainFrame")
    local GameResultText = MainFrame and MainFrame:FindFirstChild("GameResultText")


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