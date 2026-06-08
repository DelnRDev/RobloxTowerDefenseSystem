local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SharedFolder = ReplicatedStorage:WaitForChild("Shared")
local ConfigurationsFolder = SharedFolder:WaitForChild("Configurations")
local RemotesFolder = SharedFolder:WaitForChild("Remotes")

local TowerShopConfig = require(ConfigurationsFolder:WaitForChild("TowerShopConfig"))

local EquipTowerRemote = RemotesFolder:WaitForChild("EquipTowerRemote")
local UnlockTowerRemote = RemotesFolder:WaitForChild("UnlockTowerRemote")
local UnequipTowerRemote = RemotesFolder:WaitForChild("UnequipTowerRemote")

local MAX_TOWER_EQUIPPED = 2
local MIN_TOWER_EQUIPPED = 1

local function getNumberOfTowerEquipped(player)

    local PlayerDataFolder = player:WaitForChild("Data")
    local PlayerUnlockedTowersFolder = PlayerDataFolder:WaitForChild("UnlockedTowers")

    local count = 0

    for _, ItemEquipped in pairs(PlayerUnlockedTowersFolder:GetChildren()) do

        if ItemEquipped.Value == true then
            count += 1
        end

    end
    return count
end

EquipTowerRemote.OnServerInvoke = function(player, TowerName)

    local PlayerDataFolder = player:WaitForChild("Data")
    local PlayerUnlockedTowersFolder = PlayerDataFolder:WaitForChild("UnlockedTowers")

    if PlayerUnlockedTowersFolder:FindFirstChild(TowerName) then
        if not getNumberOfTowerEquipped(player) == MAX_TOWER_EQUIPPED then
            PlayerUnlockedTowersFolder:FindFirstChild(TowerName).Value = true
        else
            return "REACHED MAX EQUIPPED"
        end
        return "EQUIPPED"
    else
        print(TowerName.." not found in "..player.Name)
        return nil
    end

end

UnequipTowerRemote.OnServerInvoke = function(player, TowerName)

    local PlayerDataFolder = player:WaitForChild("Data")
    local PlayerUnlockedTowersFolder = PlayerDataFolder:WaitForChild("UnlockedTowers")

    if PlayerUnlockedTowersFolder:FindFirstChild(TowerName) then
        if not getNumberOfTowerEquipped(player) == MIN_TOWER_EQUIPPED then
            PlayerUnlockedTowersFolder:FindFirstChild(TowerName).Value = false
        else
            return "REACHED MIN EQUIPPED"
        end
        return "UNEQUIPPED"
    else
        print(TowerName.." not found in "..player.Name)
        return nil
    end
    
end

UnlockTowerRemote.OnServerInvoke = function(player, TowerName)

    if not TowerShopConfig[TowerName] then
        return nil
    end

    local PlayerDataFolder = player:WaitForChild("Data")
    local PlayerUnlockedTowersFolder = PlayerDataFolder:WaitForChild("UnlockedTowers")
    local PlayerCoins = PlayerDataFolder:WaitForChild("Coins")

    if PlayerUnlockedTowersFolder:FindFirstChild(TowerName) then
        return "ALREADY OWNED"
    end

    local TowerCost = TowerShopConfig[TowerName].Cost

    if PlayerCoins.Value >= TowerCost then
        PlayerCoins.Value -= TowerCost
        
        local newTower = Instance.new("BoolValue")
        newTower.Name = TowerName
        newTower.Value = false
        newTower.Parent = PlayerUnlockedTowersFolder

        return "UNLOCKED"
    else
        return "NOT ENOUGH COINS"
    end
    

end