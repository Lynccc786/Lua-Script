-- ==============================================================================
-- 1. GLOBAL SETUP & SERVICES
-- ==============================================================================
local uis = game:GetService("UserInputService")
local players = game:GetService("Players")
local workspace = game:GetService("Workspace")
local replicatedStorage = game:GetService("ReplicatedStorage")
local ts = game:GetService("TweenService")
local rs = game:GetService("RunService")

-- Local Player
local player = players.LocalPlayer
local mouse = player:GetMouse()
local character = player.Character or player.CharacterAdded:Wait()
local HRP = character:WaitForChild("HumanoidRootPart")
local humanoid = character:FindFirstChildOfClass("Humanoid")

player.CharacterAdded:Connect(function(char)
    character = char
    HRP = character:WaitForChild("HumanoidRootPart")
    humanoid = character:FindFirstChildOfClass("Humanoid")
end)

-- Remotes
local toolActivatedRF = replicatedStorage:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("ToolService"):WaitForChild("RF"):WaitForChild("ToolActivated")
local runCommandRF = replicatedStorage:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("DialogueService"):WaitForChild("RF"):WaitForChild("RunCommand")
local dialogueRF = replicatedStorage:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("ProximityService"):WaitForChild("RF"):WaitForChild("Dialogue")
local dialogueRE = replicatedStorage:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("DialogueService"):WaitForChild("RE"):WaitForChild("DialogueEvent")
local startBlockRF = replicatedStorage:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("ToolService"):WaitForChild("RF"):WaitForChild("StartBlock")
local stopBlockRF = replicatedStorage:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("ToolService"):WaitForChild("RF"):WaitForChild("StopBlock")

-- Modules
local knitModule = require(replicatedStorage:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("KnitClient"))
local purchaseModule = require(replicatedStorage:WaitForChild("Controllers"):WaitForChild("ProximityController"):WaitForChild("Purchase"))
local enemiesData = require(replicatedStorage:WaitForChild("Shared"):WaitForChild("Data"):WaitForChild("Enemies"))
local islandData = require(replicatedStorage:WaitForChild("Shared"):WaitForChild("Data"):WaitForChild("Islands"))
local raritiesData = require(replicatedStorage:WaitForChild("Shared"):WaitForChild("Data"):WaitForChild("Rarities"))
local oresData = require(replicatedStorage:WaitForChild("Shared"):WaitForChild("Data"):WaitForChild("Ore"))
local materialData = require(replicatedStorage:WaitForChild("Shared"):WaitForChild("Data"):WaitForChild("Materials"))
local rockData = require(replicatedStorage:WaitForChild("Shared"):WaitForChild("Data"):WaitForChild("Rock"))
local runesModuleDir = replicatedStorage:WaitForChild("Shared"):WaitForChild("Data"):WaitForChild("Runes")

-- Fluent UI Setup
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "CloverHub - The Forge",
    SubTitle = "By Lynccc",
    TabWidth = 160,
    Size = UDim2.fromOffset(650, 500),
    Acrylic = true,
    Theme = "Aqua",
    MinimizeKey = Enum.KeyCode.RightControl
})
local options = Fluent.Options

-- [UI: CREATE TABS FIRST]
local Tabs = {
    oresTab = Window:AddTab({Title = "Auto Mining" , Icon = "hammer"}),
    combatTab = Window:AddTab({Title = "Auto Kill" , Icon = "sword"}),
    autoSellTab = Window:AddTab({Title = "Auto Sell" , Icon = "coins"}),
    moveTab = Window:AddTab({Title = "Auto Move", Icon = "map-pin"}),
    forgingTab = Window:AddTab({Title = "Forge", Icon = "gavel"}),
    serverHopTab = Window:AddTab({Title = "Server Hop", Icon = "globe"}),
    settingsTab = Window:AddTab({Title = "Settings", Icon = "settings"})
}

-- ==============================================================================
-- 2. UTILITY FUNCTIONS (EXPANDED)
-- ==============================================================================
local Utility = {}
local glitchedOres = {}
local LavaCache = {}
local weirdIslandData = { ["Iron Valley"] = "Stonewake's Cross" }

-- [SCAN LAVA ONCE AT START]
task.spawn(function()
    task.wait(1)
    for _, part in pairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and part.Name == "Lava" then
            table.insert(LavaCache, part)
        end
    end
    workspace.DescendantAdded:Connect(function(part)
        if part:IsA("BasePart") and part.Name == "Lava" then
            table.insert(LavaCache, part)
        end
    end)
end)

function Utility.getAveragePosOfParts(parts : table) : Vector3?
    local totalPos = Vector3.zero
    local count = 0
    for _, part in pairs(parts) do
        if not part:IsA("BasePart") then continue end
        totalPos = totalPos + part.Position
        count += 1
    end
    if count == 0 then return Vector3.zero end
    return totalPos / count
end

function Utility.getStringsOfTable(t : table) : table
    local result = {}
    for _, v in pairs(t) do
        table.insert(result, tostring(v))
    end
    return result
end

function Utility.getHeadersOfTable(t : table) : table
    local result = {}
    for i, _ in pairs(t) do
        table.insert(result, tostring(i))
    end
    return result
end

function Utility.getAllTableChildrenKeys(t : table , k : string) : table
    local result = {}
    for _,v in pairs(t) do
        table.insert(result, v[k])
    end
    return result
end

function Utility.mergeTables(t1 : table, t2:table) : table
    local result = table.clone(t1)
    for i,v in pairs(t2) do
        table.insert(result, v )
    end
    return result
end

function Utility.getCurrentIsland() : string
    local placeID = game.PlaceId
    for _,island in pairs(islandData.Data) do
        if island.PlaceId == placeID then
            return island.Name
        end
    end
    return "NOT FOUND"
end

-- [AREA SAFETY CHECK (LAVA + ENEMY + PLAYER)]
function Utility.isAreaSafe(position: Vector3)
    local enemySafeDist = 40 
    local playerSafeDist = 15 
    
    -- Check Enemies
    for _, enemy in pairs(workspace.Living:GetChildren()) do
        if enemy:FindFirstChild("HumanoidRootPart") and enemy:GetAttribute("IsNpc") then
            if (enemy.HumanoidRootPart.Position - position).Magnitude < enemySafeDist then
                return false
            end
        end
    end
    
    -- Check Players
    for _, p in pairs(players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if (p.Character.HumanoidRootPart.Position - position).Magnitude < playerSafeDist then
                return false
            end
        end
    end

    -- Check Lava
    for _, lava in pairs(LavaCache) do
        if lava and lava.Parent then
            local lavaSize = math.max(lava.Size.X, lava.Size.Z) / 2
            local safetyBuffer = 8 
            if (lava.Position - position).Magnitude < (lavaSize + safetyBuffer) then
                return false
            end
        end
    end

    return true
end

local function setCharacterTransparency(transparency, disableCollision)
    if not character then return end
    for _, v in pairs(character:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Decal") then
            if v.Name ~= "HumanoidRootPart" then
                v.Transparency = transparency
                if disableCollision and v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        end
    end
end

-- ==============================================================================
-- 4. MOVEMENT CONTROLLER (CONFIGURABLE SPEED)
-- ==============================================================================
local MovementController = {}
local proxy = Instance.new("CFrameValue")
proxy.Value = CFrame.new(0,0,0)

-- [SAFE TELEPORT: USES SLIDER SPEED]
function MovementController.teleport(position : CFrame , useCFrame : boolean) : ()
    if not HRP or not character then return end
    
    HRP.Anchored = false 
    
    proxy.Value = character:GetPivot()
    local dist = (HRP.Position - position.Position).Magnitude
    
    -- [NEW: READ SPEED FROM SLIDER]
    local speed = options.TravelSpeed.Value 
    local length = dist / speed 
    
    local tweenInfo = TweenInfo.new(length, Enum.EasingStyle.Linear)
    local tbl = useCFrame and {Value = position} or {Value = CFrame.new(position.Position)}
    local tween = ts:Create(proxy, tweenInfo, tbl)
    
    -- Noclip Loop (Prevent getting stuck)
    local noclipConn = rs.Stepped:Connect(function()
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end)

    local con
    con = rs.Heartbeat:Connect(function()
        if character and character.Parent then
            character:PivotTo(useCFrame and proxy.Value or CFrame.new(proxy.Value.Position) * (HRP.CFrame - HRP.Position))
        else
            con:Disconnect()
            if noclipConn then noclipConn:Disconnect() end
        end
    end)
    
    tween:Play()
    tween.Completed:Wait()
    
    if con then con:Disconnect() end
    if noclipConn then noclipConn:Disconnect() end
    
    task.wait(0.05)
end

-- [FAST SNAP: INSTANT MOVE (SHORT RANGE)]
function MovementController.fastSnap(position: Vector3)
    if not HRP then return end
    HRP.Anchored = false
    HRP.CFrame = CFrame.new(position)
end

-- ==============================================================================
-- 5. MINING CONTROLLER (EXPANDED LOGIC)
-- ==============================================================================
local MiningController = {}
local cavesFolder = workspace:WaitForChild("Rocks")

function MiningController.breakOre(hitbox : BasePart, toggle : any, forceMode: boolean) : ()
    if not hitbox then return end

    local yOffset = 4
    if options.StealthMiningToggle.Value then
        yOffset = 7 
        setCharacterTransparency(1, true) 
    end

    -- [HYBRID MOVEMENT]
    local targetPos = (hitbox.CFrame - Vector3.new(0,yOffset,0)) * CFrame.Angles(math.rad(90), 0, 0)
    local dist = (HRP.Position - targetPos.Position).Magnitude
    
    if dist > 20 then
        MovementController.teleport(targetPos, true)
    else
        MovementController.fastSnap(targetPos.Position)
        HRP.CFrame = targetPos -- Apply rotation too
    end
    
    -- Stabilization
    HRP.Velocity = Vector3.new(0,0,0) 
    HRP.RotVelocity = Vector3.new(0,0,0)
    task.wait(0.1) 
    HRP.Anchored = true

    local timeUnchanged = 0
    local lastChange = tick()
    local hpGUI = hitbox.Parent
    and hitbox.Parent:FindFirstChild("infoFrame")
    and hitbox.Parent.infoFrame:FindFirstChild("Frame")
    and hitbox.Parent.infoFrame.Frame:FindFirstChild("rockHP")

    if not hpGUI then 
        HRP.Anchored = false 
        return 
    end

    local lastValue = hpGUI.Text
    repeat
        -- Smart Safe Check (Low HP)
        if humanoid.Health <= (humanoid.MaxHealth * (options.EvasionHealthSlider.Value / 100)) then
            HRP.Anchored = false
            Fluent:Notify({Title = "MOVING", Content = "Unsafe! Finding new spot...", Duration = 2})
            break -- Break loop to find new rock
        end

        toolActivatedRF:InvokeServer("Pickaxe")
        task.wait()

        if hpGUI.Text ~= lastValue then
            lastChange = tick()
            lastValue = hpGUI.Text
        else
            timeUnchanged = tick() - lastChange
        end

        local lastPlayer = hitbox.Parent:GetAttribute("LastHitPlayer")
        local lastTime = hitbox.Parent:GetAttribute("LastHitTime")

        if lastPlayer and lastPlayer ~= player.Name and lastTime and (tick()  - lastTime < 10) then break end

        if not forceMode then
            if typeof(toggle) == "table" and not toggle.Value then break end
            if typeof(toggle) == "boolean" and not toggle then break end
        end

    until
    not hitbox.Parent 
    or ((hitbox.Parent:FindFirstChild("infoFrame") and hitbox.Parent.infoFrame:FindFirstChild("Frame") and hitbox.Parent.infoFrame.Frame:FindFirstChild("rockHP")) and hitbox.Parent.infoFrame.Frame.rockHP.Text == "0 HP")
    or timeUnchanged > 4 

    if timeUnchanged > 4 then
        glitchedOres[hitbox.Parent.Parent] = tick()
    end

    HRP.Anchored = false
end

function MiningController.getRockTypes() : table
    return Utility.getHeadersOfTable(rockData)
end

function MiningController.getClosestOreInCave(cave : Folder) : BasePart?
    if not HRP then return end
    local closestOre = nil
    local closestDist = math.huge

    for _, ore in pairs(cave and cave:GetChildren() or cavesFolder:GetDescendants()) do
        local children = ore:GetChildren()
        if #children == 0 then continue end

        local lastPlayer = children[1]:GetAttribute("LastHitPlayer")
        local lastTime = children[1]:GetAttribute("LastHitTime")
        if lastPlayer and lastPlayer ~= player.Name and lastTime and (tick()  - lastTime < 10) then continue end

        if glitchedOres[ore] then
            if tick() - glitchedOres[ore] > 1000 then
                glitchedOres[ore] = nil
            else
                continue
            end
        end

        if ore:GetAttribute("IsOccupied") == false then continue end

        local hitbox = children[1]:FindFirstChild("Hitbox")
        local gui = children[1]:FindFirstChild("infoFrame")
        if not gui then continue end
        if (gui.Frame:FindFirstChild("rockHP") and gui.Frame.rockHP.Text == "0 HP") or false then continue end

        if hitbox then
            -- Safe Area Check
            if Utility.isAreaSafe(hitbox.Position) then
                local dist = (HRP.Position - hitbox.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closestOre = hitbox
                end
            end
        end
    end
    return closestOre
end

function MiningController.getClosestOreWithNames() : BasePart?
    if not HRP then return end
    local closestOre = nil
    local closestDist = math.huge

    for _, cave in pairs(cavesFolder:GetChildren()) do
        for _,ore in pairs(cave:GetChildren()) do
            local children = ore:GetChildren()
            if #children == 0 then continue end

            local lastPlayer = children[1]:GetAttribute("LastHitPlayer")
            local lastTime = children[1]:GetAttribute("LastHitTime")
            if lastPlayer and lastPlayer ~= player.Name and lastTime and (tick()  - lastTime < 10) then continue end

            if glitchedOres[ore] then
                if tick() - glitchedOres[ore] > 1000 then
                    glitchedOres[ore] = nil
                else
                    continue
                end
            end

            if ore:GetAttribute("IsOccupied") == false then continue end
            if not (options.wantedRocksDropdown.Value[children[1].Name]) then continue end

            local hitbox = children[1]:FindFirstChild("Hitbox")
            local gui = children[1]:FindFirstChild("infoFrame")
            if not gui then continue end
            if (gui.Frame:FindFirstChild("rockHP") and gui.Frame.rockHP.Text == "0 HP") or false then continue end

            if hitbox then
                -- Safe Area Check
                if Utility.isAreaSafe(hitbox.Position) then
                    local dist = (HRP.Position - hitbox.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closestOre = hitbox
                    end
                end
            end
        end
    end
    return closestOre
end

-- ==============================================================================
-- 6. SELL CONTROLLER (EXPANDED)
-- ==============================================================================
local SellController = {}

function SellController.getInventory() : table
    return knitModule.GetController("PlayerController").Replica.Data.Inventory
end

function SellController.getSellable() : (table,table)
    local oreTable = {}
    local miscTable = {}
    for name, value in pairs(knitModule.GetController("PlayerController").Replica.Data.Inventory) do 
        if typeof(value) == "number" then
            oreTable[name] = value
        end
    end
    for name,value in pairs(knitModule.GetController("PlayerController").Replica.Data.Inventory.Misc) do 
        if value then
            miscTable[name] = value
        end
    end
    return oreTable, miscTable
end

function SellController.formatSellable(oreTable : table, miscTable : table) : table
    local tbl = {}
    for i , v in pairs(oreTable) do
        if i then
            if not options.DONTAutoSellOres.Value[i] and not options.DONTAutoSellRarities.Value[SellController.getOreRarity(i)] then
                tbl[i] = v
            end
        end
    end
    for _,v in pairs(miscTable) do
        if v.Name or v.GUID then
            if not options.DONTAutoSellMisc.Value[v.Name or v.Id] and not options.DONTAutoSellRarities.Value[SellController.getMiscRarity(v.Name or v.Id)] then
                tbl[v.Name or v.GUID] = v.Quantity or 1
            end
        end
    end
    return {"SellConfirm" , {["Basket"] = tbl}}
end

function SellController.getSeller() : Model?
    return workspace.Proximity["Greedy Cey"]
end

function SellController.sellInventory() : ()
    MovementController.teleport(SellController.getSeller():GetPivot() , false)
    local oreTable, miscTable = SellController.getSellable()
    local sellRequest = SellController.formatSellable(oreTable, miscTable)
    dialogueRF:InvokeServer(workspace.Proximity:FindFirstChild("Greedy Cey"))
    task.wait()
    dialogueRE:FireServer("Opened")
    task.wait(0.1)
    dialogueRE:FireServer("Closed")
    task.wait(0.5)
    runCommandRF:InvokeServer(unpack(sellRequest))
end

function SellController.isInventoryFull() : boolean
    return purchaseModule:GetRemainingStashCapacity() == 0
end

function SellController.getRarities() : table
    return Utility.getHeadersOfTable(raritiesData)
end

function SellController.getOreRarity(ore : string) : string
    for _, oreChild in pairs(oresData) do
        if oreChild.Name == ore then
            return oreChild.Rarity
        end
    end
    return "RARITY NOT FOUND"
end

function SellController.getMiscRarity(misc : string) : string
    for _, miscChild in pairs(materialData.Items) do
        if miscChild.Name == misc then
            return miscChild.Rarity
        end
    end
    for _, runeChild in pairs(runesModuleDir:GetDescendants()) do
        if runeChild.Name == misc then
            return require(runeChild).Rarity
        end
    end
    return "RARITY NOT FOUND"
end

function SellController.getOres() : table
    return Utility.getAllTableChildrenKeys(oresData , "Name")
end

function SellController.getRunes() : table
    local result = {}
    for _,v in pairs(runesModuleDir:WaitForChild("Runes"):GetDescendants()) do
        if v:IsA("ModuleScript") then
            table.insert(result, v.Name)
        end
    end
    return result
end

function SellController.getMisc() : table
    return Utility.mergeTables(Utility.getAllTableChildrenKeys(materialData.Items , "Name") , SellController.getRunes())
end

-- ==============================================================================
-- 7. COMBAT CONTROLLER (HYBRID: TRAVEL + FAST KILL)
-- ==============================================================================
local CombatController = {}
local enemiesFolder = workspace:WaitForChild("Living")

function CombatController.killEnemy(enemy : Model, forceMode : boolean) : ()
    if not HRP or not character then return end
    if not enemy then return end

    local hpText =
        enemy
        and enemy:FindFirstChild("HumanoidRootPart")
        and enemy:FindFirstChild("HumanoidRootPart"):FindFirstChild("infoFrame")
        and enemy:FindFirstChild("HumanoidRootPart"):FindFirstChild("infoFrame"):FindFirstChild("Frame")
        and enemy:FindFirstChild("HumanoidRootPart"):FindFirstChild("infoFrame"):FindFirstChild("Frame"):FindFirstChild("rockHP")
        and enemy:FindFirstChild("HumanoidRootPart"):FindFirstChild("infoFrame"):FindFirstChild("Frame"):FindFirstChild("rockHP") or {Text = "0 HP"}

    -- [PHASE 1: TRAVEL]
    local targetPos = enemy:GetPivot().Position
    local dist = (HRP.Position - targetPos).Magnitude
    
    if dist > 20 then
        MovementController.teleport(CFrame.new(targetPos - Vector3.new(5,0,0)), false)
    end

    local attackDistance = 5 
    local lastAttackTime = 0
    local attackCooldown = 0.15
    local isBlocking = false
    
    repeat
        task.wait(0.05)
        
        if not forceMode and not options.AutoKillMobsToggle.Value then break end
        if not character or not character.Parent then continue end
        if not enemy.Parent then break end
        
        local enemyHRP = enemy:FindFirstChild("HumanoidRootPart")
        if not enemyHRP then break end
        
        local enemyPos = enemyHRP.Position
        local enemyLookVector = enemyHRP.CFrame.LookVector  
        
        local backPosition = enemyPos - (enemyLookVector * attackDistance)
        
        local currentDist = (HRP.Position - backPosition).Magnitude
        
        if currentDist > 2 then
            MovementController.fastSnap(backPosition)
        end
        
        local currentTime = tick()
        if currentTime - lastAttackTime >= attackCooldown then
            if (HRP.Position - enemyPos).Magnitude <= 12 then
                -- Stop blocking before attack (if auto block enabled)
                if isBlocking and options.AutoBlockToggle and options.AutoBlockToggle.Value then
                    pcall(function() stopBlockRF:InvokeServer() end)
                    isBlocking = false
                    task.wait(0.05)
                end
                
                -- Face enemy only when attacking (quick rotation)
                HRP.CFrame = CFrame.new(HRP.Position, Vector3.new(enemyPos.X, HRP.Position.Y, enemyPos.Z))
                
                task.spawn(function() toolActivatedRF:InvokeServer("Weapon") end)
                lastAttackTime = currentTime
                
                -- Start blocking after attack (if auto block enabled)
                if options.AutoBlockToggle and options.AutoBlockToggle.Value then
                    task.wait(0.1)
                    pcall(function() startBlockRF:InvokeServer() end)
                    isBlocking = true
                end
            end
        end
        
    until not enemy.Parent or hpText.Text == "0 HP" or not HRP.Parent or not character.Parent
    
    -- Stop blocking when done
    if isBlocking then
        pcall(function() stopBlockRF:InvokeServer() end)
    end
    
    if HRP and HRP.Parent then HRP.Anchored = false end
end

function CombatController.getEnemyTypesAtIsland(islandName : string) : table
    if islandName == "NOT FOUND" then print("Island Name Not Found") return {"ISLAND NOT FOUND"} end
    local tbl = {}
    for _,v in pairs(enemiesData) do
        if (v.Island == islandName) or (weirdIslandData[v.Island] == islandName) then
            table.insert(tbl,v.Name)
        end
    end
    return tbl
end

function CombatController.getEnemyName(enemy : Model) : string
    local hrp = enemy and enemy:FindFirstChild("HumanoidRootPart")
    local textLabel = hrp and hrp:FindFirstChild("infoFrame") and hrp.infoFrame:FindFirstChild("Frame") and hrp.infoFrame.Frame:FindFirstChild("rockName")
    return (textLabel and textLabel.Text) or ""
end

function CombatController.getEnemyByName() : Model?
    local closestEnemy = nil
    local closestDist = math.huge
    for _,enemy in pairs(enemiesFolder:GetChildren()) do
        if not enemy:FindFirstChild("HumanoidRootPart") then continue end
        if not enemy:GetAttribute("IsNpc") == true then continue end
        local hpText = enemy.HumanoidRootPart:FindFirstChild("infoFrame") and enemy.HumanoidRootPart.infoFrame.Frame:FindFirstChild("rockHP").Text or "0 HP"

        if hpText == "0 HP" then continue end
        if options.AutoKilledMobs.Value[CombatController.getEnemyName(enemy)] then
            local dist = (HRP.Position - enemy.HumanoidRootPart.Position).Magnitude
            if dist < closestDist then
                closestDist = dist
                closestEnemy = enemy
            end
        end
    end
    return closestEnemy
end

-- ==============================================================================
-- 8. FORGE CONTROLLER (EXPANDED)
-- ==============================================================================
local ForgeController = {}

function ForgeController.getMeltMinigameMainFunc() : () -> nil
    for _, con in pairs(getconnections(rs.RenderStepped)) do
        if con.Function then
            local success, isNumber = pcall(function() return typeof(getupvalue(con.Function, 22)) == "number" end)
            if success and isNumber then return con.Function end
        end
    end
    return nil
end

function ForgeController.getPourMinigameMainFunc() : () -> nil
    for _, con in pairs(getconnections(rs.RenderStepped)) do
        if con.Function then
            local success, isNumber = pcall(function() return typeof(getupvalue(con.Function, 23)) == "boolean" end)
            if success and isNumber then return con.Function end
        end
    end
    return nil
end

function ForgeController.getHammerMinigameMainFunc() : () -> nil
    for _,desc in pairs(workspace.Debris:GetDescendants()) do
        if not desc:IsA("ClickDetector") then continue end
        for _, con in pairs(getconnections(desc.MouseClick)) do
            if con.Function then
                local success, isNumber = pcall(function() return typeof(getupvalue(con.Function, 1)) == "number" end)
                if success and isNumber then return con.Function end
            end
        end
    end
    return nil
end

function ForgeController.completeHammerMinigameSecond()
    local mainMinigameGUI = player.PlayerGui.Forge.HammerMinigame
    local con
    con = mainMinigameGUI.ChildAdded:Connect(function(child)
        if child.Name == "Frame" and child:IsA("TextButton") then
            local circle = child:FindFirstChild("Frame"):WaitForChild("Circle")
            task.spawn(function()
                repeat task.wait(0.01) until circle.Size.X.Scale <= 1.2
                firesignal(child.MouseButton1Click)
            end)
        end
    end)
    repeat task.wait() until not mainMinigameGUI.Visible
    con:Disconnect()
end

function ForgeController.completeForge() : ()
        local meltMinigameFunction = nil
        repeat meltMinigameFunction = ForgeController.getMeltMinigameMainFunc() task.wait() until meltMinigameFunction
        setupvalue(meltMinigameFunction, 19 , true)

        local pourMinigameFunction = nil
        repeat pourMinigameFunction = ForgeController.getPourMinigameMainFunc() task.wait() until pourMinigameFunction
        setupvalue(pourMinigameFunction , 23 , true)

        local hammerMinigameFunction = nil
        repeat hammerMinigameFunction = ForgeController.getHammerMinigameMainFunc() task.wait() until hammerMinigameFunction
        setupvalue(hammerMinigameFunction , 1 , 69420)

        ForgeController.completeHammerMinigameSecond()
end

-- ==============================================================================
-- 9. SERVER HOP CONTROLLER
-- ==============================================================================
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local ServerHopController = {}

function ServerHopController.getCurrentPlayerCount()
    return #players:GetPlayers()
end

function ServerHopController.findLessPopulatedServer(maxPlayers)
    local success, servers = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)
    
    if not success then
        Fluent:Notify({
            Title = "Server Hop",
            Content = "Failed to fetch servers",
            Duration = 5
        })
        return nil
    end
    
    local validServers = {}
    for _, server in pairs(servers.data) do
        if server.playing and server.playing <= maxPlayers and server.id ~= game.JobId then
            table.insert(validServers, server)
        end
    end
    
    table.sort(validServers, function(a, b)
        return a.playing < b.playing
    end)
    
    return validServers[1]
end

function ServerHopController.hopToLessPopulated(maxPlayers)
    Fluent:Notify({
        Title = "Server Hop",
        Content = "Searching for quieter server...",
        Duration = 3
    })
    
    local targetServer = ServerHopController.findLessPopulatedServer(maxPlayers)
    
    if targetServer then
        -- Save config before hopping
        if SaveManager then
            SaveManager:Save()
        end
        
        -- Set flag to re-execute script after hop
        local queueData = {
            ScriptURL = "https://raw.githubusercontent.com/YourRepo/scriptForge2.lua", -- Replace with your script URL
            AutoLoad = true,
            Timestamp = os.time()
        }
        
        -- Store in TeleportData so it persists across servers
        pcall(function()
            game:GetService("TeleportService"):SetTeleportGui(Instance.new("ScreenGui"))
        end)
        
        -- Use queue_on_teleport to re-execute
        if syn and syn.queue_on_teleport then
            syn.queue_on_teleport([[loadstring(game:HttpGet("https://raw.githubusercontent.com/YourRepo/scriptForge2.lua"))()]]) -- Replace URL
        elseif queue_on_teleport then
            queue_on_teleport([[loadstring(game:HttpGet("https://raw.githubusercontent.com/YourRepo/scriptForge2.lua"))()]]) -- Replace URL
        end
        
        Fluent:Notify({
            Title = "Server Hop",
            Content = string.format("Found server with %d players. Hopping...", targetServer.playing),
            Duration = 5
        })
        
        task.wait(1)
        TeleportService:TeleportToPlaceInstance(game.PlaceId, targetServer.id, player)
    else
        Fluent:Notify({
            Title = "Server Hop",
            Content = "No suitable server found",
            Duration = 5
        })
    end
end

-- ==============================================================================
-- 10. UI CONTENT POPULATION
-- ==============================================================================
Tabs.settingsTab:AddSlider("TravelSpeed", {
    Title = "Travel Speed",
    Description = "Speed for walking to targets",
    Default = 50,
    Min = 16,
    Max = 300,
    Rounding = 0,
})

-- Mining UI
local caveSelectDropdown = Tabs.oresTab:AddDropdown("CaveDropdown", {Title = "Select Cave", Values = Utility.getStringsOfTable(cavesFolder:GetChildren()), Multi = false, Default = 1})
Tabs.oresTab:AddDropdown("wantedRocksDropdown", {Title = "Select Wanted Rocks", Values = MiningController.getRockTypes(), Multi = true, Default = {}})
Tabs.oresTab:AddToggle("AutoFarmOresFromCaveToggle", {Title = "Auto Farm Rocks From Selected Cave", Default = false})
Tabs.oresTab:AddToggle("AutoFarmOresWithNameToggle" , {Title = "Auto Farm Rocks With Selected Names", Default = false})

Tabs.oresTab:AddToggle("StealthMiningToggle", {
    Title = "Ghost Mode (Stealth)", 
    Description = "Invisible + 7 Studs Underground", 
    Default = false,
    Callback = function(v)
        if v then setCharacterTransparency(1, true) else setCharacterTransparency(0) end
    end
})

Tabs.oresTab:AddToggle("AutoEvasionToggle", {Title = "Smart Safe-Mining", Description = "Skip unsafe rocks if HP low", Default = false})
Tabs.oresTab:AddSlider("EvasionHealthSlider", {Title = "Unsafe HP %", Default = 30, Min = 10, Max = 90, Rounding = 0})

-- Combat UI
Tabs.combatTab:AddDropdown("AutoKilledMobs", {Title = "Select Mobs To Auto Kill", Values = CombatController.getEnemyTypesAtIsland(Utility.getCurrentIsland()), Multi = true, Default = {}})
Tabs.combatTab:AddToggle("AutoKillMobsToggle", {Title = "Auto Kill Selected Mobs Toggle", Default = false})
Tabs.combatTab:AddToggle("AutoBlockToggle", {Title = "Auto Block When Attacking", Description = "Automatically block between attacks (F)", Default = true})

-- Sell UI
Tabs.autoSellTab:AddDropdown("DONTAutoSellOres", {Title = "Dont Sell Ores", Values = SellController.getOres(), Multi = true, Default = {}})
Tabs.autoSellTab:AddDropdown("DONTAutoSellMisc", {Title = "Dont Sell Misc", Values = SellController.getMisc(), Multi = true, Default = {}})
Tabs.autoSellTab:AddDropdown("DONTAutoSellRarities", {Title = "Dont Sell by Rarities", Values = SellController.getRarities(), Multi = true, Default = {}})
Tabs.autoSellTab:AddToggle("AutoSellToggle" , {Title = "Auto Sell On Full Inventory", Default = false})
Tabs.autoSellTab:AddButton({Title = "Sell", Description = "Manual Sell", Callback = function() SellController.sellInventory() end})

-- Move UI
local moveDropdown = Tabs.moveTab:AddDropdown("MoveTo", {Title = "Destination", Values = Utility.getStringsOfTable(workspace.Proximity:GetChildren()), Multi = false, Default = 1})
Tabs.moveTab:AddButton({Title = "Teleport", Callback = function() 
    local target = workspace.Proximity:FindFirstChild(moveDropdown.Value)
    if target then MovementController.teleport(target:GetPivot(), false) end
end})

-- Forge UI
Tabs.forgingTab:AddButton({Title = "Start Forging", Callback = function() ForgeController.completeForge() end})

Tabs.forgingTab:AddParagraph({
    Title = "📋 Auto-Forge Guide", 
    Content = "Step 1: Open the forge and choose your desired ores & weapon type\n\nStep 2: Click the 'Start Forging' button below\n\nStep 3: Begin the forge minigame manually\n\nStep 4: Sit back and watch the magic happen! ✨"
})

-- Server Hop UI
Tabs.serverHopTab:AddParagraph({
    Title = "Current Server Info",
    Content = "Players: " .. ServerHopController.getCurrentPlayerCount() .. "\nServer ID: " .. game.JobId:sub(1, 8) .. "..."
})

Tabs.serverHopTab:AddSlider("MaxPlayersSlider", {
    Title = "Max Players in Target Server",
    Description = "Find servers with fewer players than this",
    Default = 10,
    Min = 1,
    Max = 50,
    Rounding = 0,
})

Tabs.serverHopTab:AddButton({
    Title = "Hop to Quieter Server",
    Description = "Find and join a less populated server",
    Callback = function()
        local maxPlayers = options.MaxPlayersSlider.Value
        ServerHopController.hopToLessPopulated(maxPlayers)
    end
})

Tabs.serverHopTab:AddToggle("AutoServerHopToggle", {
    Title = "Auto Server Hop",
    Description = "Automatically hop when server is too crowded",
    Default = false
})

Tabs.serverHopTab:AddSlider("AutoHopThresholdSlider", {
    Title = "Auto Hop Threshold",
    Description = "Hop when players exceed this number",
    Default = 15,
    Min = 5,
    Max = 50,
    Rounding = 0,
})

Tabs.serverHopTab:AddToggle("AutoReExecuteToggle", {
    Title = "Auto Re-Execute Script",
    Description = "Automatically run script after server hop",
    Default = true
})

Tabs.serverHopTab:AddParagraph({
    Title = "⚠️ Important Note",
    Content = "Make sure to replace the script URL in the code with your actual script link for auto re-execute to work!"
})

-- [AUTO STEALTH ON RESPAWN]
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    HRP = character:WaitForChild("HumanoidRootPart")
    humanoid = character:FindFirstChildOfClass("Humanoid")
    
    if options.StealthMiningToggle.Value then
        task.wait(1.5) 
        setCharacterTransparency(1, true)
    end
end)

-- ==============================================================================
-- 11. MAIN LOGIC LOOP
-- ==============================================================================
local function determineState()
    if options.AutoSellToggle.Value and SellController.isInventoryFull() then return "Selling"
    elseif options.AutoKillMobsToggle.Value and CombatController.getEnemyByName() then return "Killing"
    elseif (options.AutoFarmOresFromCaveToggle.Value or options.AutoFarmOresWithNameToggle.Value) and (MiningController.getClosestOreInCave(cavesFolder:FindFirstChild(caveSelectDropdown.Value)) or MiningController.getClosestOreWithNames()) then return "Mining"
    else return "Idle" end
end

local HZ = 20
local interval = 1 / HZ

task.spawn(function()
    while true do
        task.wait(interval)
        
        local state = determineState()

        if state == "Mining" then
            local caveName = caveSelectDropdown.Value
            local cave = cavesFolder:FindFirstChild(caveName)
            if not cave then
                task.wait(1)
                continue
            end
            local ore = options.AutoFarmOresFromCaveToggle.Value and MiningController.getClosestOreInCave(cave) or MiningController.getClosestOreWithNames()
            if ore then
                MiningController.breakOre(ore, options.AutoFarmOresFromCaveToggle, false)
            else
                task.wait(1)
            end

        elseif state == "Selling" then
            SellController.sellInventory()

        elseif state == "Killing" then
            local enemy = CombatController.getEnemyByName()
            if enemy then
                CombatController.killEnemy(enemy, false)
            end
        end
    end
end)

-- Auto Server Hop Logic
task.spawn(function()
    while true do
        task.wait(60) -- Check every 60 seconds
        
        if options.AutoServerHopToggle and options.AutoServerHopToggle.Value then
            local currentPlayers = ServerHopController.getCurrentPlayerCount()
            local threshold = options.AutoHopThresholdSlider.Value
            
            if currentPlayers >= threshold then
                -- Auto-save config before hopping
                if SaveManager then
                    SaveManager:Save()
                    Fluent:Notify({
                        Title = "Auto Save",
                        Content = "Config saved successfully!",
                        Duration = 2
                    })
                end
                
                Fluent:Notify({
                    Title = "Auto Server Hop",
                    Content = string.format("Server too crowded (%d/%d). Hopping...", currentPlayers, threshold),
                    Duration = 5
                })
                
                ServerHopController.hopToLessPopulated(threshold - 5)
                break
            end
        end
    end
end)

local isMobile = uis.TouchEnabled and not uis.KeyboardEnabled
if isMobile then
    local gui = Instance.new("ScreenGui")
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.Parent = game:GetService("CoreGui")

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 80, 0, 80)
    btn.Position = UDim2.new(1, -80, 0.5, -40)
    btn.BackgroundColor3 = Color3.fromRGB(50, 120, 255)
    btn.Text = "Toggle GUI"
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Active = true
    btn.Parent = gui

    btn.MouseButton1Click:Connect(function()
        Window:Minimize()
    end)
end

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("ProjectForge")
SaveManager:SetFolder("ProjectForge/Expanded")

-- Add manual save button
Tabs.settingsTab:AddButton({
    Title = "💾 Save Config Now",
    Description = "Manually save current settings",
    Callback = function()
        SaveManager:Save()
        Fluent:Notify({
            Title = "Config Saved",
            Content = "All settings saved successfully!",
            Duration = 3
        })
    end
})

InterfaceManager:BuildInterfaceSection(Tabs.settingsTab)
SaveManager:BuildConfigSection(Tabs.settingsTab)

Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()

while task.wait(300) do
    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.Tilde, false, nil)
    task.wait(0.1)
    game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.Tilde, false, nil)
end

