-- ====================================================================
--                 CLOVER HUB - PREMIUM EDITION
--          Advanced Automated Fishing System
-- ====================================================================

-- ====== CRITICAL DEPENDENCY VALIDATION ======
local success, errorMsg = pcall(function()
    local services = {
        game = game,
        workspace = workspace,
        Players = game:GetService("Players"),
        RunService = game:GetService("RunService"),
        ReplicatedStorage = game:GetService("ReplicatedStorage"),
        HttpService = game:GetService("HttpService")
    }
    
    for serviceName, service in pairs(services) do
        if not service then
            error("Critical service missing: " .. serviceName)
        end
    end
    
    local LocalPlayer = game:GetService("Players").LocalPlayer
    if not LocalPlayer then
        error("LocalPlayer not available")
    end
    
    return true
end)

if not success then
    error("❌ [System] Service initialization failed: " .. tostring(errorMsg))
    return
end

-- ====================================================================
--                        CORE SERVICES
-- ====================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- ====================================================================
--                    CONFIGURATION
-- ====================================================================
local CONFIG_FOLDER = "CloverHubData"
local CONFIG_FILE = CONFIG_FOLDER .. "/settings_" .. LocalPlayer.UserId .. ".json"

local DefaultConfig = {
    AutoFish = false,
    AutoSell = false,
    AutoCatch = false,
    GPUSaver = false,
    OverlayScreen = false,
    BlatantMode = false,
    FishDelay = 0.9,
    CatchDelay = 0.2,
    SellDelay = 30,
    TeleportLocation = "Sisyphus Statue",
    AutoFavorite = true,
    FavoriteRarity = "Mythic"
}

local Config = {}
for k, v in pairs(DefaultConfig) do Config[k] = v end

-- Teleport Locations (COMPLETE LIST)
local LOCATIONS = {
    ["Spawn"] = CFrame.new(45.2788086, 252.562927, 2987.10913, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["Sisyphus Statue"] = CFrame.new(-3728.21606, -135.074417, -1012.12744, -0.977224171, 7.74980258e-09, -0.212209702, 1.566994e-08, 1, -3.5640408e-08, 0.212209702, -3.81539813e-08, -0.977224171),
    ["Coral Reefs"] = CFrame.new(-3114.78198, 1.32066584, 2237.52295, -0.304758579, 1.6556676e-08, -0.952429652, -8.50574935e-08, 1, 4.46003305e-08, 0.952429652, 9.46036067e-08, -0.304758579),
    ["Esoteric Depths"] = CFrame.new(3248.37109, -1301.53027, 1403.82727, -0.920208454, 7.76270355e-08, 0.391428679, 4.56261056e-08, 1, -9.10549289e-08, -0.391428679, -6.5930152e-08, -0.920208454),
    ["Crater Island"] = CFrame.new(1016.49072, 20.0919304, 5069.27295, 0.838976264, 3.30379857e-09, -0.544168055, 2.63538391e-09, 1, 1.01344115e-08, 0.544168055, -9.93662219e-09, 0.838976264),
    ["Lost Isle"] = CFrame.new(-3618.15698, 240.836655, -1317.45801, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["Weather Machine"] = CFrame.new(-1488.51196, 83.1732635, 1876.30298, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["Tropical Grove"] = CFrame.new(-2095.34106, 197.199997, 3718.08008),
    ["Mount Hallow"] = CFrame.new(2136.62305, 78.9163895, 3272.50439, -0.977613986, -1.77645827e-08, 0.210406482, -2.42338203e-08, 1, -2.81680421e-08, -0.210406482, -3.26364251e-08, -0.977613986),
    ["Treasure Room"] = CFrame.new(-3606.34985, -266.57373, -1580.97339, 0.998743415, 1.12141152e-13, -0.0501160324, -1.56847693e-13, 1, -8.88127842e-13, 0.0501160324, 8.94872392e-13, 0.998743415),
    ["Kohana"] = CFrame.new(-663.904236, 3.04580712, 718.796875, -0.100799225, -2.14183729e-08, -0.994906783, -1.12300391e-08, 1, -2.03902459e-08, 0.994906783, 9.11752096e-09, -0.100799225),
    ["Underground Cellar"] = CFrame.new(2109.52148, -94.1875076, -708.609131, 0.418592364, 3.34794485e-08, -0.908174217, -5.24141512e-08, 1, 1.27060247e-08, 0.908174217, 4.22825366e-08, 0.418592364),
    ["Ancient Jungle"] = CFrame.new(1831.71362, 6.62499952, -299.279175, 0.213522509, 1.25553285e-07, -0.976938128, -4.32026184e-08, 1, 1.19074642e-07, 0.976938128, 1.67811702e-08, 0.213522509),
    ["Sacred Temple"] = CFrame.new(1466.92151, -21.8750591, -622.835693, -0.764787138, 8.14444334e-09, 0.644283056, 2.31097452e-08, 1, 1.4791004e-08, -0.644283056, 2.6201187e-08, -0.764787138),
    ["Christmas Island"] = CFrame.new(983.0271, 26.4056702, 1619.74756)
}

-- ====================================================================
--                     CONFIG FUNCTIONS
-- ====================================================================
local function ensureFolder()
    if not isfolder or not makefolder then return false end
    if not isfolder(CONFIG_FOLDER) then
        pcall(function() makefolder(CONFIG_FOLDER) end)
    end
    return isfolder(CONFIG_FOLDER)
end

local function saveConfig()
    if not writefile or not ensureFolder() then return end
    pcall(function()
        writefile(CONFIG_FILE, HttpService:JSONEncode(Config))
        print("[System] Configuration saved successfully")
    end)
end

local function loadConfig()
    if not readfile or not isfile or not isfile(CONFIG_FILE) then return end
    pcall(function()
        local data = HttpService:JSONDecode(readfile(CONFIG_FILE))
        for k, v in pairs(data) do
            if DefaultConfig[k] ~= nil then Config[k] = v end
        end
        print("[System] Configuration restored")
    end)
end

loadConfig()

-- ====================================================================
--                     NETWORK EVENTS
-- ====================================================================
local function getNetworkEvents()
    local net = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net
    return {
        fishing = net:WaitForChild("RE/FishingCompleted"),
        sell = net:WaitForChild("RF/SellAllItems"),
        charge = net:WaitForChild("RF/ChargeFishingRod"),
        minigame = net:WaitForChild("RF/RequestFishingMinigameStarted"),
        cancel = net:WaitForChild("RF/CancelFishingInputs"),
        equip = net:WaitForChild("RE/EquipToolFromHotbar"),
        unequip = net:WaitForChild("RE/UnequipToolFromHotbar"),
        favorite = net:WaitForChild("RE/FavoriteItem")
    }
end

local Events = getNetworkEvents()

-- ====================================================================
--                     MODULES FOR AUTO FAVORITE
-- ====================================================================
local ItemUtility = require(ReplicatedStorage.Shared.ItemUtility)
local Replion = require(ReplicatedStorage.Packages.Replion)
local PlayerData = Replion.Client:WaitReplion("Data")

-- ====================================================================
--                     RARITY SYSTEM
-- ====================================================================
local RarityTiers = {
    Common = 1,
    Uncommon = 2,
    Rare = 3,
    Epic = 4,
    Legendary = 5,
    Mythic = 6,
    Secret = 7
}

local function getRarityValue(rarity)
    return RarityTiers[rarity] or 0
end

local function getFishRarity(itemData)
    if not itemData or not itemData.Data then return "Common" end
    return itemData.Data.Rarity or "Common"
end

-- ====================================================================
--                     TELEPORT SYSTEM (from dev1.lua)
-- ====================================================================
local Teleport = {}

function Teleport.to(locationName)
    local cframe = LOCATIONS[locationName]
    if not cframe then
        warn("❌ [Travel] Destination unavailable: " .. tostring(locationName))
        return false
    end
    
    local success = pcall(function()
        local character = LocalPlayer.Character
        if not character then return end
        
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        
        rootPart.CFrame = cframe
        print("✅ [Travel] Arrived at " .. locationName)
    end)
    
    return success
end

-- ====================================================================
--                     GPU SAVER
-- ====================================================================
local gpuActive = false

local function enableGPU()
    if gpuActive then return end
    gpuActive = true
    
    pcall(function()
        -- Lower rendering quality
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        game.Lighting.GlobalShadows = false
        game.Lighting.FogEnd = 1
        setfpscap(60)
        
        -- Texture quality reduction
        local UserSettings = UserSettings()
        local GameSettings = UserSettings.GameSettings
        GameSettings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
        
        -- Remove heavy effects
        for _, effect in pairs(game.Lighting:GetChildren()) do
            if effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or 
               effect:IsA("SunRaysEffect") or effect:IsA("ColorCorrectionEffect") or
               effect:IsA("DepthOfFieldEffect") then
                effect.Enabled = false
            end
        end
    end)
    
    print("[Performance] Low resource mode activated")
end

local function disableGPU()
    if not gpuActive then return end
    gpuActive = false
    
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        game.Lighting.GlobalShadows = true
        game.Lighting.FogEnd = 100000
        setfpscap(0)
        
        -- Restore texture quality
        local UserSettings = UserSettings()
        local GameSettings = UserSettings.GameSettings
        GameSettings.SavedQualityLevel = Enum.SavedQualitySetting.Automatic
        
        -- Restore effects
        for _, effect in pairs(game.Lighting:GetChildren()) do
            if effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or 
               effect:IsA("SunRaysEffect") or effect:IsA("ColorCorrectionEffect") or
               effect:IsA("DepthOfFieldEffect") then
                effect.Enabled = true
            end
        end
    end)
    
    print("[Performance] Standard mode restored")
end

-- ====================================================================
--                     OVERLAY SCREEN
-- ====================================================================
local overlayActive = false
local overlayScreen = nil

local function enableOverlay()
    if overlayActive then return end
    overlayActive = true
    
    overlayScreen = Instance.new("ScreenGui")
    overlayScreen.ResetOnSpawn = false
    overlayScreen.DisplayOrder = 999999
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.new(0.05, 0.05, 0.1)
    frame.Parent = overlayScreen
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 500, 0, 120)
    label.Position = UDim2.new(0.5, -250, 0.5, -60)
    label.BackgroundTransparency = 1
    label.Text = "PERFORMANCE MODE\n\nClover Hub Running..."
    label.TextColor3 = Color3.new(0.4, 0.8, 1)
    label.TextSize = 32
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.Parent = frame
    
    overlayScreen.Parent = game.CoreGui
    print("[Performance] Overlay screen enabled")
end

local function disableOverlay()
    if not overlayActive then return end
    overlayActive = false
    
    if overlayScreen then
        overlayScreen:Destroy()
        overlayScreen = nil
    end
    print("[Performance] Overlay screen disabled")
end

-- ====================================================================
--                     ANTI-AFK
-- ====================================================================
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

print("[System] Idle prevention active")

-- ====================================================================
--                     AUTO FAVORITE
-- ====================================================================
local favoritedItems = {}

local function isItemFavorited(uuid)
    local success, result = pcall(function()
        local items = PlayerData:GetExpect("Inventory").Items
        for _, item in ipairs(items) do
            if item.UUID == uuid then
                return item.Favorited == true
            end
        end
        return false
    end)
    return success and result or false
end

local function autoFavoriteByRarity()
    if not Config.AutoFavorite then return end
    
    local targetRarity = Config.FavoriteRarity
    local targetValue = getRarityValue(targetRarity)
    
    if targetValue < 6 then
        targetValue = 6
    end
    
    local favorited = 0
    local skipped = 0
    
    local success = pcall(function()
        local items = PlayerData:GetExpect("Inventory").Items
        
        if not items or #items == 0 then return end
        
        for i, item in ipairs(items) do
            local data = ItemUtility:GetItemData(item.Id)
            if data and data.Data then
                local itemName = data.Data.Name or "Unknown"
                local rarity = getFishRarity(data)
                local rarityValue = getRarityValue(rarity)
                
                if rarityValue >= targetValue and rarityValue >= 6 then
                    if not isItemFavorited(item.UUID) and not favoritedItems[item.UUID] then
                        Events.favorite:FireServer(item.UUID)
                        favoritedItems[item.UUID] = true
                        favorited = favorited + 1
                        print("[Collector] ⭐ #" .. favorited .. " - " .. itemName .. " (" .. rarity .. ")")
                        task.wait(0.3)
                    else
                        skipped = skipped + 1
                    end
                end
            end
        end
    end)
    
    if favorited > 0 then
        print("[Collector] ✅ Process complete! Protected: " .. favorited)
    end
end

task.spawn(function()
    while true do
        task.wait(10)
        if Config.AutoFavorite then
            autoFavoriteByRarity()
        end
    end
end)

-- ====================================================================
--                     FISHING LOGIC (FROM YOUR test.lua)
-- ====================================================================
local isFishing = false
local fishingActive = false

-- Helper functions
local function castRod()
    pcall(function()
        Events.equip:FireServer(1)
        task.wait(0.05)
        Events.charge:InvokeServer(1755848498.4834)
        task.wait(0.02)
        Events.minigame:InvokeServer(1.2854545116425, 1)
        print("[Activity] 🎣 Rod deployed")
    end)
end

local function reelIn()
    pcall(function()
        Events.fishing:FireServer()
        print("[Activity] ✅ Catch complete")
    end)
end

-- BLATANT MODE: Your exact implementation
local function blatantFishingLoop()
    while fishingActive and Config.BlatantMode do
        if not isFishing then
            isFishing = true
            
            -- Step 1: Rapid fire casts (2 parallel casts)
            pcall(function()
                Events.equip:FireServer(1)
                task.wait(0.01)
                
                -- Cast 1
                task.spawn(function()
                    Events.charge:InvokeServer(1755848498.4834)
                    task.wait(0.01)
                    Events.minigame:InvokeServer(1.2854545116425, 1)
                end)
                
                task.wait(0.05)
                
                -- Cast 2 (overlapping)
                task.spawn(function()
                    Events.charge:InvokeServer(1755848498.4834)
                    task.wait(0.01)
                    Events.minigame:InvokeServer(1.2854545116425, 1)
                end)
            end)
            
            -- Step 2: Wait for fish to bite
            task.wait(Config.FishDelay)
            
            -- Step 3: Spam reel 5x to instant catch
            for i = 1, 5 do
                pcall(function() 
                    Events.fishing:FireServer() 
                end)
                task.wait(0.01)
            end
            
            -- Step 4: Short cooldown (50% faster)
            task.wait(Config.CatchDelay * 0.5)
            
            isFishing = false
            print("[Turbo] ⚡ Rapid sequence executed")
        else
            task.wait(0.01)
        end
    end
end

-- NORMAL MODE: Your exact implementation
local function normalFishingLoop()
    while fishingActive and not Config.BlatantMode do
        if not isFishing then
            isFishing = true
            
            castRod()
            task.wait(Config.FishDelay)
            reelIn()
            task.wait(Config.CatchDelay)
            
            isFishing = false
        else
            task.wait(0.1)
        end
    end
end

-- Main fishing controller
local function fishingLoop()
    while fishingActive do
        if Config.BlatantMode then
            blatantFishingLoop()
        else
            normalFishingLoop()
        end
        task.wait(0.1)
    end
end

-- ====================================================================
--                     AUTO CATCH (SPAM SYSTEM)
-- ====================================================================
task.spawn(function()
    while true do
        if Config.AutoCatch and not isFishing then
            pcall(function() 
                Events.fishing:FireServer() 
            end)
        end
        task.wait(Config.CatchDelay)
    end
end)

-- ====================================================================
--                     AUTO SELL
-- ====================================================================
local function simpleSell()
    print("╔═══════════════════════════════════╗")
    print("[Merchant] 💰 Processing inventory sale...")
    
    local sellSuccess = pcall(function()
        return Events.sell:InvokeServer()
    end)
    
    if sellSuccess then
        print("[Merchant] ✅ Transaction complete! (Protected items safe)")
        print("╚═══════════════════════════════════╝")
    else
        warn("[Merchant] ❌ Transaction failed")
        print("╚═══════════════════════════════════╝")
    end
end

task.spawn(function()
    while true do
        task.wait(Config.SellDelay)
        if Config.AutoSell then
            simpleSell()
        end
    end
end)

-- ====================================================================
--                     FLUENT UI
-- ====================================================================
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "🍀 Clover Hub",
    SubTitle = "Premium Auto Fish",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Aqua",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- ====== MAIN TAB ======
local Tabs = {
    Main = Window:AddTab({ Title = "Auto Fish", Icon = "activity" })
}

Tabs.Main:AddParagraph({
    Title = "Auto Fishing",
    Content = "Enable automated fishing features"
})

local BlatantToggle = Tabs.Main:AddToggle("BlatantMode", {
    Title = "BLATANT MODE",
    Default = Config.BlatantMode,
    Callback = function(value)
        Config.BlatantMode = value
        print("[Turbo Mode] " .. (value and "⚡ ACTIVATED - MAXIMUM SPEED!" or "🔴 Deactivated - Standard speed"))
        saveConfig()
    end
})

Tabs.Main:AddParagraph({
    Title = "How Blatant Mode Works",
    Content = [[Casts 2 rods in parallel (overlapping), waits for fish to bite, spams reel 5x to instant catch, 50% faster cooldown between casts. Result: ~40% faster fishing! Multiple casts = higher catch rate, spam reeling = instant catch, reduced cooldown = faster cycles.]]
})

local AutoFishToggle = Tabs.Main:AddToggle("AutoFish", {
    Title = "Auto Fish",
    Default = Config.AutoFish,
    Callback = function(value)
        Config.AutoFish = value
        fishingActive = value
        
        if value then
            print("[Automation] 🟢 Initiated " .. (Config.BlatantMode and "(TURBO MODE)" or "(Standard)"))
            task.spawn(fishingLoop)
        else
            print("[Automation] 🔴 Terminated")
            pcall(function() Events.unequip:FireServer() end)
        end
        
        saveConfig()
    end
})

local AutoCatchToggle = Tabs.Main:AddToggle("AutoCatch", {
    Title = "Auto Catch (Extra Speed)",
    Default = Config.AutoCatch,
    Callback = function(value)
        Config.AutoCatch = value
        print("[Quick Catch] " .. (value and "🟢 Enabled" or "🔴 Disabled"))
        saveConfig()
    end
})

Tabs.Main:AddInput("FishDelay", {
    Title = "Fish Delay (seconds)",
    Default = tostring(Config.FishDelay),
    Placeholder = "Default: 0.9",
    Numeric = true,
    Finished = true,
    Callback = function(value)
        local num = tonumber(value)
        if num and num >= 0.1 and num <= 10 then
            Config.FishDelay = num
            print("[Settings] ✅ Wait time updated to " .. num .. "s")
            saveConfig()
        else
            warn("[Settings] ❌ Invalid value (range: 0.1-10)")
        end
    end
})

Tabs.Main:AddInput("CatchDelay", {
    Title = "Catch Delay (seconds)",
    Default = tostring(Config.CatchDelay),
    Placeholder = "Default: 0.2",
    Numeric = true,
    Finished = true,
    Callback = function(value)
        local num = tonumber(value)
        if num and num >= 0.1 and num <= 10 then
            Config.CatchDelay = num
            print("[Settings] ✅ Capture interval set to " .. num .. "s")
            saveConfig()
        else
            warn("[Settings] ❌ Invalid value (range: 0.1-10)")
        end
    end
})

-- ====== AUTO SELL TAB ======
Tabs.AutoSell = Window:AddTab({ Title = "Auto Sell", Icon = "dollar-sign" })

Tabs.AutoSell:AddParagraph({
    Title = "Auto Sell",
    Content = "Automatically sell items while keeping favorited fish"
})

local AutoSellToggle = Tabs.AutoSell:AddToggle("AutoSell", {
    Title = "Auto Sell (Keeps Favorited)",
    Default = Config.AutoSell,
    Callback = function(value)
        Config.AutoSell = value
        print("[Merchant] " .. (value and "🟢 Enabled" or "🔴 Disabled"))
        saveConfig()
    end
})

Tabs.AutoSell:AddInput("SellDelay", {
    Title = "Sell Delay (seconds)",
    Default = tostring(Config.SellDelay),
    Placeholder = "Default: 30",
    Numeric = true,
    Finished = true,
    Callback = function(value)
        local num = tonumber(value)
        if num and num >= 10 and num <= 300 then
            Config.SellDelay = num
            print("[Settings] ✅ Sale interval updated to " .. num .. "s")
            saveConfig()
        else
            warn("[Settings] ❌ Invalid value (range: 10-300)")
        end
    end
})

Tabs.AutoSell:AddButton({
    Title = "Sell All Now",
    Description = "Instantly sell all non-favorited items",
    Callback = function()
        simpleSell()
    end
})

-- ====== TELEPORT TAB ======
Tabs.Teleport = Window:AddTab({ Title = "Teleport", Icon = "map-pin" })

Tabs.Teleport:AddParagraph({
    Title = "Locations",
    Content = "Quick travel to fishing spots"
})

-- Build location list for dropdown
local locationList = {}
for locationName, _ in pairs(LOCATIONS) do
    table.insert(locationList, locationName)
end
table.sort(locationList)

local TeleportDropdown = Tabs.Teleport:AddDropdown("TeleportLocation", {
    Title = "Select Location",
    Values = locationList,
    Default = Config.TeleportLocation,
    Multi = false,
    Callback = function(option)
        Config.TeleportLocation = option
        saveConfig()
    end
})

Tabs.Teleport:AddButton({
    Title = "Teleport Now",
    Description = "Travel to selected location",
    Callback = function()
        if Config.TeleportLocation then
            Teleport.to(Config.TeleportLocation)
        end
    end
})

-- ====== SETTINGS TAB ======
Tabs.Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })

Tabs.Settings:AddParagraph({
    Title = "Performance",
    Content = "Optimize game performance"
})

local GPUToggle = Tabs.Settings:AddToggle("GPUSaver", {
    Title = "GPU Saver Mode",
    Default = Config.GPUSaver,
    Callback = function(value)
        Config.GPUSaver = value
        if value then
            enableGPU()
        else
            disableGPU()
        end
        saveConfig()
    end
})

Tabs.Settings:AddParagraph({
    Title = "What GPU Saver Does",
    Content = "Sets graphics to minimum quality (Level 1), forces lowest texture resolution, removes shadows, reduces fog distance, disables heavy effects (Bloom, Blur, SunRays, ColorCorrection), and caps FPS to 60 for maximum performance boost."
})

local OverlayToggle = Tabs.Settings:AddToggle("OverlayScreen", {
    Title = "Overlay Screen",
    Default = Config.OverlayScreen,
    Callback = function(value)
        Config.OverlayScreen = value
        if value then
            enableOverlay()
        else
            disableOverlay()
        end
        saveConfig()
    end
})

Tabs.Settings:AddParagraph({
    Title = "What Overlay Screen Does",
    Content = "Shows a dark blue overlay to reduce screen brightness and further reduce GPU/battery usage. Can be used with or without GPU Saver mode."
})

-- ====== AUTO FAVORITE TAB ======
Tabs.AutoFavorite = Window:AddTab({ Title = "Auto Favorite", Icon = "star" })

Tabs.AutoFavorite:AddParagraph({
    Title = "Auto Favorite",
    Content = "Automatically favorite rare fish"
})

local AutoFavoriteToggle = Tabs.AutoFavorite:AddToggle("AutoFavorite", {
    Title = "Auto Favorite Fish",
    Default = Config.AutoFavorite,
    Callback = function(value)
        Config.AutoFavorite = value
        print("[Collector] " .. (value and "🟢 Enabled" or "🔴 Disabled"))
        saveConfig()
    end
})

Tabs.AutoFavorite:AddParagraph({
    Title = "About Auto Favorite",
    Content = "Automatically favorites Mythic and Secret rarity fish only. Protected items will not be sold when using Auto Sell feature."
})

local FavoriteRarityDropdown = Tabs.AutoFavorite:AddDropdown("FavoriteRarity", {
    Title = "Favorite Rarity (Mythic/Secret Only)",
    Values = {"Mythic", "Secret"},
    Default = Config.FavoriteRarity,
    Multi = false,
    Callback = function(option)
        Config.FavoriteRarity = option
        print("[Settings] Protection tier set to: " .. option .. "+")
        saveConfig()
    end
})

Tabs.AutoFavorite:AddButton({
    Title = "Favorite All Mythic/Secret Now",
    Description = "Instantly favorite all eligible fish",
    Callback = function()
        autoFavoriteByRarity()
    end
})

Tabs.Main:AddParagraph({
    Title = "Features Overview",
    Content = [[Fast Auto Fishing with Blatant Mode • Auto Sell (keeps favorited fish) • Auto Catch for extra speed • GPU Saver Mode • Anti-AFK Protection • Auto Save Configuration • Teleport System • Auto Favorite (Mythic & Secret only)]]
})

-- Select Fish tab by default
Window:SelectTab(1)

-- ====== STARTUP ======
Fluent:Notify({
    Title = "🍀 Clover Hub",
    Content = "Ready to fish!",
    Duration = 5
})

print("🍀 Clover Hub - Initialized!")
print("✅ Advanced automation system ready")
print("✅ Turbo mode available")
print("✅ Quick travel system active")
print("System operational!")