-- Global Services (Used by the entire script)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")

--------------------------------------------------------------------------------
-- [[DATABASE ]]
--------------------------------------------------------------------------------
local Database = {}

-- [[DUNGEON ID LIST - ORDERED ]]
-- Format: {name, id}
Database.RegionList = {
    -- SEA 1
    {"1 - Starter", 101002},
    {"1 - Medium", 101003},
    {"1 - Hard", 101004},
    {"1 - Extreme", 101005},
    {"1 - Final Boss", 101006},
    {"2 - Starter", 101007},
    {"2 - Medium", 101008},
    {"2 - Hard", 101009},
    {"2 - Extreme", 101010},
    {"2 - Final Boss", 101011},
    {"2 - Secret Boss", 101012},
    {"3 - Starter", 101013},
    {"3 - Medium", 101014},
    {"3 - Hard", 101015},
    {"3 - Extreme", 101016},
    {"3 - Final Boss", 101017},
    {"4 - Secret Boss", 101018},
    {"4 - Starter", 101025},
    {"4 - Medium", 101026},
    {"4 - Hard", 101027},
    {"4 - Extreme", 101028},
    {"4 - Final Boss", 101029},
    {"5 - Starter", 101035},
    {"5 - Medium", 101036},
    {"5 - Hard", 101037},
    {"5 - Extreme", 101038},
    {"5 - Final Boss", 101039},
    {"6 - Starter", 101045},
    {"6 - Medium", 101046},
    {"6 - Hard", 101047},
    {"6 - Extreme", 101048},
    {"6 - Final Boss", 101049},
    -- SEA 2
    {"8 - Starter", 101055},
    {"8 - Medium", 101056},
    {"8 - Hard", 101057},
    {"8 - Extreme", 101058},
    {"8 - Final Boss", 101059},
    {"9 - Chrono Warden", 101071},
    {"9 - Rift Engineer", 101072},
    {"9 - The Chrono Architect", 101073},
    {"9 - Web Matron", 101074},
    {"9 - Shadow Sovereign", 101075},
    {"9 - Nemesia the Veilweaver", 101076},
    {"9 - Ritual Sentinel", 101077},
    {"9 - Serpent Vessel", 101078},
    {"9 - High Priest Alecto", 101079}
}

-- Helper function to get ID from name
function Database.GetRegionID(name)
    for _, entry in ipairs(Database.RegionList) do
        if entry[1] == name then
            return entry[2]
        end
    end
    return nil
end

-- [[ NPC DATA FOR SEA 2 ]]
Database.NPC_Map = {
    [101055] = { Name = "Tideborn Whelp", Pos = CFrame.new(-1687.03, 57.47, 676.58) },
    [101056] = { Name = "Scorchwave", Pos = CFrame.new(-1707.08, 57.94, 603.27) },
    [101057] = { Name = "Gresor", Pos = CFrame.new(-1675.47, 63.66, 851.90) },
    [101058] = { Name = "Yssern", Pos = CFrame.new(-1780.13, 82.88, 778.08) },
    [101059] = { Name = "Daemor", Pos = CFrame.new(-1836.92, 84.37, 810.64) },
    [101071] = { Name = "Chrono Warden", Pos = CFrame.new(-4148.93, 124.71, 1908.71) },
    [101072] = { Name = "Rift Engineer", Pos = CFrame.new(-4398.15, 125.83, 1814.41) },
    [101073] = { Name = "The Chrono Architect", Pos = CFrame.new(-4507.79, 180.85, 1771.81) },
    [101074] = { Name = "Web Matron", Pos = CFrame.new(-3578.77, 220.20, 2283.18) },
    [101075] = { Name = "Shadow Sovereign", Pos = CFrame.new(-3375.35, 238.48, 2360.45) },
    [101076] = { Name = "Nemesia the Veilweaver", Pos = CFrame.new(-3310.57, 244.58, 2384.99) },
    [101077] = { Name = "Ritual Sentinel", Pos = CFrame.new(-4085.25, 388.31, 3346.89) },
    [101078] = { Name = "Serpent Vessel", Pos = CFrame.new(-4355.57, 436.22, 3258.42) },
    [101079] = { Name = "High Priest Alecto", Pos = CFrame.new(-4501.03, 449.12, 3209.14) },
}

-- [[ EVENT DATA - ORDERED ]]
Database.EventData = {
    {"1 Key", CFrame.new(-136.45, 59.24, -67.57, -1, 0, 0.0019, 0, 1, 0, -0.0019, 0, -1), "Match3"},
    {"2 Key", CFrame.new(-123.53, 55.13, -45.37, -0.0033, 0, -1, 0, 1, 0, 1, 0, -0.0033), "Match2"},
    {"10 Key", CFrame.new(-55.57, 59.24, -44.54, 1, 0, -0.0019, 0, 1, 0, 0.0019, 0, 1), "Match1"},
    {"10 Key Cross Server", CFrame.new(-39.08, 59.24, -66.51, -1, 0, 0.0019, 0, 1, 0, -0.0019, 0, -1), "Match4"}
}

-- Helper function to get event data from name
function Database.GetEventData(name)
    for _, entry in ipairs(Database.EventData) do
        if entry[1] == name then
            return {CFrame = entry[2], ObjName = entry[3]}
        end
    end
    return nil
end

-- [[TELEPORT DATA - ORDERED ]]
Database.TeleportCoords = {
    {"World 1", CFrame.new(1.94, 56.35, -32.70)},
    {"World 2", CFrame.new(-692.14, 52.35, 1197.22)},
    {"World 3", CFrame.new(1719.68, 51.58, 2823.56)},
    {"World 4", CFrame.new(3481.07, 52.68, 1739.73)},
    {"World 5", CFrame.new(1297.69, 699.28, 1247.39)},
    {"World 6", CFrame.new(3036.91, 51.08, -616.70)},
    {"Infinity Tower Sea 1", CFrame.new(-1209.22, 156.13, 3599.25)},
    {"Light House", CFrame.new(1684.22, 215.60, 205.90)},
    {"Guild Island", CFrame.new(-774.47, 142.53, -580.21)},
    {"World 7", CFrame.new(-47.72, 86.20, 167.34)},
    {"World 8", CFrame.new(-1383.06, 56.13, 732.22)},
    {"World 9", CFrame.new(-3858.73, 59.74, 1844.70)},
    {"Infinity Tower Sea 2", CFrame.new(-1191.12, 156.56, -954.80)}
}

-- Helper function to get CFrame from name
function Database.GetTeleportCFrame(name)
    for _, entry in ipairs(Database.TeleportCoords) do
        if entry[1] == name then
            return entry[2]
        end
    end
    return nil
end

-- [[ GUILD DATA - ORDERED ]]
Database.GuildMatchList = {
    {"Medium", "Match0", CFrame.new(-792.52, 142.39, -519.69)},
    {"Hard", "Match1", CFrame.new(-820.08, 142.41, -505.79)},
    {"Extreme", "Match2", CFrame.new(-843.00, 142.61, -536.51)},
    {"Impossible", "Match3", CFrame.new(-762.55, 142.65, -681.98)},
    {"Pro Plus Ultra", "Match4", CFrame.new(-787.514526, 142.532928, -704.105164, 0.837312877, 0, 0.546724021, 0, 1, 0, -0.546724021, 0, 0.837312877)}
}

-- Helper function to get guild data from name
function Database.GetGuildData(name)
    for _, entry in ipairs(Database.GuildMatchList) do
        if entry[1] == name then
            return {matchPath = entry[2], teleportCFrame = entry[3]}
        end
    end
    return nil
end

Database.ManualWaypoints = {
    Vector3.new(-16.31, 13.35, -427.16), 
    Vector3.new(-16.31, 28.74, -331.82),
    Vector3.new(-70.43, 28.75, -277.38),
    Vector3.new(-38.31, 28.76, -219.96),
    Vector3.new(-25.11, 28.76, -172.52),
    Vector3.new(-20.89, 43.09, -114.37),
    Vector3.new(-77.09, 43.09, -109.34),
    Vector3.new(-84.30, 57.95, -68.11)
}


--------------------------------------------------------------------------------
-- [[ CONTROLLER]]
--------------------------------------------------------------------------------
local Controller = {}

-- Variables
Controller.IsMoving = false
Controller.CurrentMoveConnection = nil
Controller.IsLooping = false
Controller.AutoKillEnabled = false
Controller.AutoSkillEnabled = false
Controller.MagnetActive = false
Controller.AutoReplayEnabled = false
Controller.AutoGuildEnabled = false
Controller.StuckDetectorEnabled = false
Controller.NoclipEnabled = false
Controller.FlyEnabled = false
Controller.ServerHopEnabled = false
Controller.ServerHopPlayerLimit = 5
Controller.CurrentSkillIndex = 1
Controller.MagnetStats = {Opened = 0, Collected = 0}
Controller.Debounce = {}
Controller.FlySpeed = 50

-- Config Storage
Controller.ConfigFile = "LootifyConfig.json"
Controller.Config = {
    SelectedDungeon = "1 - Starter",
    SelectedEvent = "1 Key",
    SelectedGuild = "Medium",
    SkillPattern = "1234",
    AutoFarm = false,
    AutoKill = false,
    AutoSkill = false,
    AutoReplay = false,
    LoopEvent = false,
    Magnet = false,
    ServerHop = false,
    ServerHopLimit = 5,
    AutoGuild = false,
    Noclip = false,
    Fly = false,
    StuckDetector = false
}

local AUTO_PATHFIND_THRESHOLD = 80
local NoclipConnection, FlyConnection, ReplayConnection, GuildReplayConnection, StuckLoop
local DEBUG = true
local function log(category, message, ...)
    if DEBUG then print(string.format("[%s] %s", category, string.format(message, ...))) end
end

--------------------------------------------------------------------------------
-- Helper Functions
--------------------------------------------------------------------------------
local function getRoot() 
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end

local function getHum() 
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
end

local function findLobbyObject(targetName)
    if not targetName then return nil end
    local matchFolder = workspace:FindFirstChild("Match")
    if not matchFolder then return nil end
    return matchFolder:FindFirstChild(targetName, true)
end

-- FIX: Add missing findClosestMatchObject function
local function findClosestMatchObject(maxDist)
    local root = getRoot()
    if not root then return nil end
    
    local matchFolder = workspace:FindFirstChild("Match")
    if not matchFolder then return nil end
    
    local closest = nil
    local minDist = maxDist or 20
    
    for _, obj in pairs(matchFolder:GetDescendants()) do
        if obj:FindFirstChild("Match") and obj:FindFirstChildWhichIsA("ProximityPrompt", true) then
            local dist = (obj:GetPivot().Position - root.Position).Magnitude
            if dist < minDist then
                minDist = dist
                closest = obj
            end
        end
    end
    
    return closest
end

function Controller.GetCurrentSea()
    for i = 1, 6 do if workspace:FindFirstChild("World"..i) then return 1 end end
    if workspace:FindFirstChild("World7") or workspace:FindFirstChild("World8") or workspace:FindFirstChild("World9") then return 2 end
    return 0 
end

local function isInMatch()
    local enemyFolder = workspace:FindFirstChild("EnemyFolder")
    if not enemyFolder then return false end
    local aliveCount = 0
    for _, enemy in pairs(enemyFolder:GetChildren()) do
        if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then 
            aliveCount = aliveCount + 1 
        end
    end
    return aliveCount > 0
end

--------------------------------------------------------------------------------
-- [[ MOVEMENT & PATHFINDING LOGIC ]]
--------------------------------------------------------------------------------

-- 1. Stop Walking
function Controller.StopWalk()
    Controller.IsMoving = false
    
    if Controller.CurrentMoveConnection then
        Controller.CurrentMoveConnection:Disconnect()
        Controller.CurrentMoveConnection = nil
    end
    
    local hum = getHum()
    local root = getRoot()
    if hum then hum:Move(Vector3.zero) end
    if root then root.AssemblyLinearVelocity = Vector3.zero end
    
    log("CTRL", "Movement stopped")
end

-- 2. Walk Point-to-Point
local function walkToPoint(targetVec)
    local root = getRoot()
    local hum = getHum()
    if not root or not hum then return false end

    local reached = false
    local startTime = tick()
    local timeout = 15 -- 15 seconds timeout per waypoint
    
    Controller.CurrentMoveConnection = RunService.RenderStepped:Connect(function()
        if not Controller.IsMoving or tick() - startTime > timeout then 
            if Controller.CurrentMoveConnection then 
                Controller.CurrentMoveConnection:Disconnect() 
            end
            return 
        end

        local myPos = Vector3.new(root.Position.X, 0, root.Position.Z)
        local targetPos = Vector3.new(targetVec.X, 0, targetVec.Z)
        local dist = (myPos - targetPos).Magnitude
        
        if dist < 5 then -- Tolerance 5 studs
            reached = true
            if Controller.CurrentMoveConnection then 
                Controller.CurrentMoveConnection:Disconnect() 
            end
        else
            hum:Move((targetPos - myPos).Unit)
        end
    end)
    
    repeat 
        task.wait(0.1) 
    until reached or not Controller.IsMoving or (hum and hum.Health <= 0) or tick() - startTime > timeout
    
    return reached
end

-- Auto Pathfinding (Short Distance)
function Controller.RunAutoPathfinding(targetCFrame)
    log("CTRL", "Running Auto Pathfinding")
    local root = getRoot()
    local hum = getHum()
    
    if not root or not hum then return end
    
    local path = PathfindingService:CreatePath({ 
        AgentRadius = 2, 
        AgentCanJump = true,
        AgentHeight = 5,
        AgentCanClimb = false
    })
    
    local success, errorMessage = pcall(function()
        path:ComputeAsync(root.Position, targetCFrame.Position)
    end)
    
    if success and path.Status == Enum.PathStatus.Success then
        local waypoints = path:GetWaypoints()
        
        for i, wp in ipairs(waypoints) do
            if not Controller.IsMoving then break end
            
            if wp.Action == Enum.PathWaypointAction.Jump then 
                hum.Jump = true 
                task.wait(0.3)
            end
            
            walkToPoint(wp.Position)
        end
    else
        warn("Pathfinding Failed: ", errorMessage)
        -- Fallback: Direct movement
        if Controller.IsMoving and hum then 
            hum:MoveTo(targetCFrame.Position)
            task.wait(2)
        end
    end
end

-- Manual Path (Long Distance)
function Controller.RunManualPath(targetCFrame, waypoints)
    if not waypoints or #waypoints == 0 then return end
    log("CTRL", "Running Manual Path (%d waypoints)", #waypoints)
    
    local root = getRoot()
    if not root then return end
    
    -- Find closest waypoint
    local closestIndex = 1
    local minDist = math.huge
    
    for i, wp in ipairs(waypoints) do
        local d = (root.Position - wp).Magnitude
        if d < minDist then
            minDist = d
            closestIndex = i
        end
    end
    
    log("CTRL", "Starting from waypoint %d (distance: %.1f)", closestIndex, minDist)
    
    -- Skip if very close
    if minDist < 10 and closestIndex < #waypoints then
        closestIndex = closestIndex + 1
    end

    -- Loop Waypoints
    for i = closestIndex, #waypoints do
        if not Controller.IsMoving then break end
        log("CTRL", "Moving to waypoint %d/%d", i, #waypoints)
        walkToPoint(waypoints[i])
        task.wait(0.1)
    end
    
    -- Proceed to Auto Pathfinding
    if Controller.IsMoving then
        local distToFinal = (getRoot().Position - targetCFrame.Position).Magnitude
        if distToFinal > 5 then
            log("CTRL", "Switching to Auto Pathfinding (%.1f studs remaining)", distToFinal)
            Controller.RunAutoPathfinding(targetCFrame)
        end
    end
end

-- Main Start Trip Function
function Controller.StartTrip(targetCFrame, manualWaypoints)
    Controller.StopWalk()
    task.wait(0.1)
    
    Controller.IsMoving = true
    local root = getRoot()
    local hum = getHum()
    
    if not root or not hum then return end

    task.spawn(function()
        local distToFinal = (root.Position - targetCFrame.Position).Magnitude
        log("CTRL", "Starting trip. Distance: %.1f studs", distToFinal)

        if distToFinal <= AUTO_PATHFIND_THRESHOLD then
            Controller.RunAutoPathfinding(targetCFrame)
        else
            Controller.RunManualPath(targetCFrame, manualWaypoints)
        end
        
        -- Finish - Teleport to final position
        if Controller.IsMoving then
            if hum then hum:Move(Vector3.zero) end
            if root then 
                root.AssemblyLinearVelocity = Vector3.zero 
                root.CFrame = targetCFrame 
            end
            Controller.IsMoving = false
            log("CTRL", "Reached destination!")
        end
    end)
end

--------------------------------------------------------------------------------
-- [[ EVENT LOOP LOGIC ]]
--------------------------------------------------------------------------------

function Controller.StartEventLoop(targetCFrame, manualWaypoints)
    Controller.IsLooping = true
    
    task.spawn(function()
        log("LOOP", "Auto Loop Event Started")
        
        while Controller.IsLooping do
            task.wait(1)
            
            local root = getRoot()
            local hum = getHum()
            if not root or not hum or hum.Health <= 0 then 
                task.wait(2) 
                continue 
            end
            
            if isInMatch() then
                task.wait(2)
                continue
            end

            local dist = (root.Position - targetCFrame.Position).Magnitude
            
            -- CONDITION A: Far -> Walk
            if dist > 15 then
                if not Controller.IsMoving then
                    log("LOOP", "Far from target (%.1f studs). Walking...", dist)
                    Controller.StartTrip(targetCFrame, manualWaypoints)
                    
                    repeat 
                        task.wait(0.5) 
                    until not Controller.IsMoving or not Controller.IsLooping or (getHum() and getHum().Health <= 0)
                end
                
            -- CONDITION B: Close -> Find Object
            else
                if Controller.IsMoving then Controller.StopWalk() end
                
                local targetObj = findClosestMatchObject(20)
                
                if targetObj then
                    -- Trigger Prompt
                    local prompt = targetObj:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if prompt then 
                        fireproximityprompt(prompt)
                        task.wait(0.5)
                    end
                    
                    -- Enter Match
                    if targetObj:FindFirstChild("Match") then
                        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                        if remotes and remotes:FindFirstChild("Region") then
                            local regionFolder = remotes.Region
                            if regionFolder:FindFirstChild("Match") then
                                local matchFolder = regionFolder.Match
                                if matchFolder:FindFirstChild("Enter") then
                                    matchFolder.Enter:FireServer(targetObj.Match)
                                    log("LOOP", "Entering Match: %s", targetObj.Name)
                                end
                            end
                        end
                    end
                    
                    task.wait(5)
                else
                    log("LOOP", "No Match object found nearby")
                    task.wait(2)
                end
            end
        end
    end)
end

function Controller.StopEventLoop()
    Controller.IsLooping = false
    Controller.StopWalk()
    log("LOOP", "Auto Loop Stopped")
end

--------------------------------------------------------------------------------
-- [[ DUNGEON LOGIC ]]
--------------------------------------------------------------------------------

local function EnterSea1(id)
    local sea = Controller.GetCurrentSea()
    if sea == 2 then return end
    
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if remotes and remotes:FindFirstChild("Region") then
        local region = remotes.Region
        if region:FindFirstChild("EnterRegion") then
            region.EnterRegion:FireServer(id)
            task.wait(2)
        end
    end
end

local function EnterSea2(id, npcData)
    local sea = Controller.GetCurrentSea()
    if sea == 1 then return end
    
    local root = getRoot()
    if not root then return end
    
    local npc = workspace.NPCs:FindFirstChild(npcData.Name)
    if not npc then 
        root.CFrame = npcData.Pos
        task.wait(1)
        npc = workspace.NPCs:FindFirstChild(npcData.Name)
    end
    
    if npc and npc:FindFirstChild("HumanoidRootPart") then
        root.CFrame = npc.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4)
        task.wait(0.5)
        
        local prompt = npc:FindFirstChildWhichIsA("ProximityPrompt", true)
        if prompt then 
            fireproximityprompt(prompt)
            task.wait(0.5)
        end
    end
    
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if remotes and remotes:FindFirstChild("Region") then
        local region = remotes.Region
        if region:FindFirstChild("EnterRegion") then
            region.EnterRegion:FireServer(id)
            task.wait(2)
        end
    end
end

function Controller.EnterRegion(id, npcData)
    if npcData == nil then 
        EnterSea1(id) 
    else 
        EnterSea2(id, npcData) 
    end
end

function Controller.ToggleAutoReplay(state, regionID, npcData)
    Controller.AutoReplayEnabled = state
    
    if ReplayConnection then 
        ReplayConnection:Disconnect() 
        ReplayConnection = nil
    end
    
    local function tryEnter()
        if Controller.AutoReplayEnabled and not isInMatch() then
            if npcData == nil then 
                EnterSea1(regionID) 
            else 
                EnterSea2(regionID, npcData) 
            end
        end
    end
    
    if state then
        ReplayConnection = LocalPlayer.CharacterAdded:Connect(function() 
            task.wait(6)
            tryEnter() 
        end)
        
        task.spawn(function() 
            while Controller.AutoReplayEnabled do 
                task.wait(5)
                if getRoot() then 
                    tryEnter() 
                end 
            end 
        end)
        
        tryEnter()
    end
end

--------------------------------------------------------------------------------
-- [[ GUILD LOGIC ]]
--------------------------------------------------------------------------------

function Controller.JoinGuildOnce(matchData)
    if isInMatch() then return end
    
    task.spawn(function()
        local targetObj = findLobbyObject(matchData.matchPath)
        if not targetObj then return end 
        
        local root = getRoot()
        if root then
            root.CFrame = matchData.teleportCFrame
            task.wait(1)
            
            if targetObj and targetObj:FindFirstChild("Match") then 
                local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                if remotes and remotes:FindFirstChild("Region") then
                    local region = remotes.Region
                    if region:FindFirstChild("Match") then
                        local matchFolder = region.Match
                        if matchFolder:FindFirstChild("Enter") then
                            matchFolder.Enter:FireServer(targetObj.Match)
                        end
                    end
                end
            end
        end
    end)
end

function Controller.ToggleAutoGuild(state, matchData, lobbyCFrame)
    Controller.AutoGuildEnabled = state
    
    if GuildReplayConnection then 
        GuildReplayConnection:Disconnect()
        GuildReplayConnection = nil
    end
    
    local function tryJoin()
        local targetObj = findLobbyObject(matchData.matchPath)
        if not targetObj then return end 
        
        if getRoot() then
            getRoot().CFrame = matchData.teleportCFrame
            task.wait(18)
            
            if targetObj and targetObj:FindFirstChild("Match") then 
                local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                if remotes and remotes:FindFirstChild("Region") then
                    local region = remotes.Region
                    if region:FindFirstChild("Match") then
                        local matchFolder = region.Match
                        if matchFolder:FindFirstChild("Enter") then
                            matchFolder.Enter:FireServer(targetObj.Match)
                            task.wait(5)
                        end
                    end
                end
            end
        end
    end
    
    if state then
        Controller.AutoReplayEnabled = false
        task.spawn(function() 
            while Controller.AutoGuildEnabled do 
                task.wait(2)
                tryJoin() 
            end 
        end)
    end
end

--------------------------------------------------------------------------------
-- [[ OTHER FEATURES ]]
--------------------------------------------------------------------------------

function Controller.RunAutoKill(whitelistFunc)
    task.spawn(function() 
        while Controller.AutoKillEnabled do 
            task.wait(0.1)
            
            if isInMatch() then 
                pcall(function()
                    local root = getRoot()
                    local char = LocalPlayer.Character
                    if not root or not char then return end
                    
                    local tool = char:FindFirstChildOfClass('Tool') or LocalPlayer.Backpack:FindFirstChildOfClass('Tool')
                    
                    if tool and tool.Parent ~= char then 
                        tool.Parent = char
                        task.wait(0.2) 
                    end
                    
                    if not tool then return end
                    
                    local closest, enemy = math.huge, nil
                    local folder = workspace:FindFirstChild('EnemyFolder')
                    
                    if folder then 
                        for _, v in pairs(folder:GetChildren()) do
                            if v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and not whitelistFunc(v) then
                                local d = (v.HumanoidRootPart.Position - root.Position).Magnitude
                                if d < closest then 
                                    closest = d
                                    enemy = v 
                                end
                            end
                        end 
                    end
                    
                    if enemy then 
                        TweenService:Create(root, TweenInfo.new(0.1), {
                            CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
                        }):Play()
                        
                        tool:Activate()
                    end
                end) 
            end
        end 
    end)
end

function Controller.RunAutoSkill(delay, whitelistFunc)
    Controller.AutoSkillEnabled = true
    
    task.spawn(function() 
        while Controller.AutoSkillEnabled do 
            task.wait(delay or 0.3)
            
            if isInMatch() then 
                pcall(function()
                    local root = getRoot()
                    if not root then return end
                    
                    local closest, enemy = math.huge, nil
                    local folder = workspace:FindFirstChild('EnemyFolder')
                    
                    if folder then 
                        for _, v in pairs(folder:GetChildren()) do
                            if v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and not whitelistFunc(v) then
                                local d = (v.HumanoidRootPart.Position - root.Position).Magnitude
                                if d < closest then 
                                    closest = d
                                    enemy = v 
                                end
                            end
                        end 
                    end
                    
                    if enemy then
                        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                        if remotes and remotes:FindFirstChild("Skill") then
                            local skillFolder = remotes.Skill
                            if skillFolder:FindFirstChild("ReleaseCmd") then
                                skillFolder.ReleaseCmd:FireServer(
                                    Controller.CurrentSkillIndex,
                                    {
                                        fireDir = (enemy.HumanoidRootPart.Position - root.Position).Unit,
                                        targetPos = enemy.HumanoidRootPart.Position,
                                        firePos = root.Position
                                    }
                                )
                                
                                Controller.CurrentSkillIndex = (Controller.CurrentSkillIndex % 4) + 1
                            end
                        end
                    end
                end) 
            end
        end 
    end)
end

function Controller.SetSkillPatternFromString(str)
    str = tostring(str or "")
    
    -- Check for SMART mode
    if str:match("^%s*smart%s*$") then
        Controller.SkillPattern = function(enemy)
            local root = getRoot()
            if not root or not enemy or not enemy:FindFirstChild("Humanoid") then 
                return Controller.CurrentSkillIndex 
            end
            local hp = (enemy.Humanoid.Health or 1) / (enemy.Humanoid.MaxHealth or 1)
            local ok, pos = pcall(function() return enemy.HumanoidRootPart.Position end)
            local d = ok and (pos - root.Position).Magnitude or 0
            if hp > 0.9 then return 3 end
            if d > 20 then return 2 end
            return 1
        end
        Controller.SkillPatternIndex = 1
        Controller.SkillPatternString = "SMART"
        return true
    else
        local pattern = {}
        
        -- Prioritas: Parse contiguous digits dulu (e.g. "13423241232")
        for c in str:gmatch("%d") do
            local n = tonumber(c)
            if n and n >= 1 and n <= 4 then 
                table.insert(pattern, n) 
            end
        end
        
        -- Apply pattern if valid
        if #pattern > 0 then
            Controller.SkillPattern = pattern
            Controller.SkillPatternIndex = 1
            Controller.SkillPatternString = table.concat(pattern, "")
            log("CTRL", "Skill pattern set to: %s", Controller.SkillPatternString)
            return true
        end
    end
    
    log("CTRL", "Invalid skill pattern: %s", str)
    return false
end

-- Tambahkan fungsi untuk mendapatkan pattern saat ini
function Controller.GetCurrentSkillPattern()
    if type(Controller.SkillPattern) == "function" then
        return "SMART"
    elseif type(Controller.SkillPattern) == "table" then
        return Controller.SkillPatternString or table.concat(Controller.SkillPattern, ",")
    end
    return "Unknown"
end

function Controller.StartMagnet(config)
    task.spawn(function() 
        while Controller.MagnetActive do 
            task.wait(config.Delay)
            
            local root = getRoot()
            if not root then continue end
            
            local function bring(obj) 
                local cf = root.CFrame * CFrame.new(0, -2, -4)
                if obj:IsA("Model") then 
                    obj:PivotTo(cf) 
                else 
                    obj.CFrame = cf 
                end 
            end
            
            local function interact(obj) 
                local p = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                if p then 
                    fireproximityprompt(p)
                    return true 
                end 
            end
            
            -- Chest
            local cf = workspace:FindFirstChild("HalloweenChestFolder")
            if cf then 
                for _, v in pairs(cf:GetChildren()) do
                    if v.Name == config.ChestName and (not Controller.Debounce[v] or tick() - Controller.Debounce[v] > 5) then
                        Controller.Debounce[v] = tick()
                        bring(v)
                        task.wait(0.05)
                        if interact(v) then 
                            Controller.MagnetStats.Opened = Controller.MagnetStats.Opened + 1 
                        end
                    end
                end 
            end
            
            -- Items
            local ifolder = workspace:FindFirstChild(config.ItemFolder)
            if ifolder then 
                for _, v in pairs(ifolder:GetChildren()) do
                    if (not Controller.Debounce[v] or tick() - Controller.Debounce[v] > 5) then
                        Controller.Debounce[v] = tick()
                        bring(v)
                        task.wait(0.05)
                        if interact(v) then 
                            Controller.MagnetStats.Collected = Controller.MagnetStats.Collected + 1 
                        end
                    end
                end 
            end
        end 
    end)
end

function Controller.ToggleNoclip(state) 
    Controller.NoclipEnabled = state
    
    if NoclipConnection then 
        NoclipConnection:Disconnect()
        NoclipConnection = nil
    end
    
    if state then 
        NoclipConnection = RunService.Stepped:Connect(function() 
            if LocalPlayer.Character then 
                for _, v in pairs(LocalPlayer.Character:GetDescendants()) do 
                    if v:IsA("BasePart") then 
                        v.CanCollide = false 
                    end 
                end 
            end 
        end) 
    end 
end

function Controller.ToggleFly(state, speed) 
    Controller.FlyEnabled = state
    
    if FlyConnection then 
        FlyConnection:Disconnect()
        FlyConnection = nil
    end
    
    local root = getRoot()
    
    if state and root then 
        local bv = Instance.new("BodyVelocity", root)
        bv.Name = "FlyVelocity"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        
        FlyConnection = RunService.Heartbeat:Connect(function() 
            local hum = getHum()
            if hum then 
                local move = hum.MoveDirection
                bv.Velocity = (move * speed) + (UserInputService:IsKeyDown(Enum.KeyCode.Space) and Vector3.new(0, speed / 2, 0) or Vector3.new(0, 0, 0))
                hum.PlatformStand = true 
            end 
        end) 
    else 
        if getHum() then 
            getHum().PlatformStand = false 
        end
        
        if root then
            for _, v in pairs(root:GetChildren()) do 
                if v.Name == "FlyVelocity" then 
                    v:Destroy() 
                end 
            end 
        end
    end 
end

function Controller.ToggleStuckDetector(state, interval, resetCFrame) 
    Controller.StuckDetectorEnabled = state
    
    if StuckLoop then 
        task.cancel(StuckLoop)
        StuckLoop = nil
    end
    
    if state then 
        local lastPos, t = nil, 0
        
        StuckLoop = task.spawn(function() 
            while Controller.StuckDetectorEnabled do 
                task.wait(1)
                
                local root = getRoot()
                if root then 
                    local c = root.Position
                    
                    if lastPos and (c - lastPos).Magnitude < 1.5 then 
                        t = t + 1
                        
                        if t >= interval then 
                            root.CFrame = resetCFrame
                            task.wait(1)
                            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) 
                        end 
                    else 
                        t = 0 
                    end
                    
                    lastPos = c 
                end 
            end 
        end) 
    end 
end

function Controller.Cleanup()
    Controller.IsLooping = false
    Controller.StopWalk()
    Controller.AutoKillEnabled = false
    Controller.AutoSkillEnabled = false
    Controller.MagnetActive = false
    Controller.ToggleAutoReplay(false)
    Controller.ToggleAutoGuild(false)
    Controller.ToggleNoclip(false)
    Controller.ToggleFly(false)
    Controller.ToggleStuckDetector(false)
end

-- [[ SERVER HOP FUNCTION ]]
function Controller.ServerHop()
    log("CTRL", "Attempting to server hop...")
    
    -- Ensure script reloads on teleport
    pcall(function()
        local SCRIPT_URL = "https://raw.githubusercontent.com/Lynccc786/Lua-Script/refs/heads/main/Lootify/test.lua"
        local reloadScript = string.format([[
            task.wait(1)
            loadstring(game:HttpGet("%s"))()
        ]], SCRIPT_URL)
        
        if syn and syn.queue_on_teleport then
            syn.queue_on_teleport(reloadScript)
        elseif queue_on_teleport then
            queue_on_teleport(reloadScript)
        elseif queueonteleport then
            queueonteleport(reloadScript)
        end
    end)
    
    local success, result = pcall(function()
        local HttpService = game:GetService("HttpService")
        local TeleportService = game:GetService("TeleportService")
        local PlaceId = game.PlaceId
        
        local url = string.format(
            "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100",
            PlaceId
        )
        
        local servers = HttpService:JSONDecode(game:HttpGet(url)).data
        
        for _, server in pairs(servers) do
            if server.playing < Controller.ServerHopPlayerLimit and server.id ~= game.JobId then
                log("CTRL", "Found server with %d players, joining...", server.playing)
                TeleportService:TeleportToPlaceInstance(PlaceId, server.id, LocalPlayer)
                return
            end
        end
        
        log("CTRL", "No suitable server found, trying random...")
        TeleportService:Teleport(PlaceId, LocalPlayer)
    end)
    
    if not success then
        warn("[CTRL] Server hop failed:", result)
    end
end

function Controller.StartServerHopMonitor()
    Controller.ServerHopEnabled = true
    log("CTRL", "Server hop monitor started (limit: %d players)", Controller.ServerHopPlayerLimit)
    
    task.spawn(function()
        while Controller.ServerHopEnabled do
            if Controller.ServerHopEnabled then
                local playerCount = #Players:GetPlayers()
                log("CTRL", "Current players: %d / Limit: %d", playerCount, Controller.ServerHopPlayerLimit)
                
                if playerCount >= Controller.ServerHopPlayerLimit then
                    log("CTRL", "Player limit reached! Hopping server...")
                    Controller.ServerHop()
                    break
                end
            end
            
            wait(30) -- Check every 30 seconds
        end
    end)
end

function Controller.StopServerHopMonitor()
    Controller.ServerHopEnabled = false
    log("CTRL", "Server hop monitor stopped")
end

-- [[ CONFIG MANAGEMENT ]]
function Controller.SaveConfig()
    local success, result = pcall(function()
        if not writefile then
            warn("[CONFIG] writefile not supported by executor")
            return false
        end
        
        local HttpService = game:GetService("HttpService")
        local json = HttpService:JSONEncode(Controller.Config)
        
        writefile(Controller.ConfigFile, json)
        log("CONFIG", "Config saved to: %s", Controller.ConfigFile)
        log("CONFIG", "Saved data: %s", json)
        return true
    end)
    
    if not success then
        warn("[CONFIG] Failed to save config:", result)
        return false
    end
    
    return result
end

function Controller.LoadConfig()
    local success, result = pcall(function()
        -- Check if functions exist
        if not readfile then
            warn("[CONFIG] readfile not available in executor")
            return false
        end
        
        if not isfile then
            warn("[CONFIG] isfile not available in executor")
            return false
        end
        
        if not isfile(Controller.ConfigFile) then
            log("CONFIG", "No config file found at: %s", Controller.ConfigFile)
            log("CONFIG", "Using default config")
            return false
        end
        
        log("CONFIG", "Config file found! Reading...")
        local HttpService = game:GetService("HttpService")
        local json = readfile(Controller.ConfigFile)
        log("CONFIG", "JSON content: %s", json)
        
        local loaded = HttpService:JSONDecode(json)
        
        -- Merge loaded config with defaults
        for key, value in pairs(loaded) do
            Controller.Config[key] = value
            log("CONFIG", "Loaded: %s = %s", key, tostring(value))
        end
        
        log("CONFIG", "Config loaded successfully!")
        return true
    end)
    
    if not success then
        warn("[CONFIG] Failed to load config:", result)
        return false
    end
    
    return result
end

function Controller.ResetConfig()
    local success = pcall(function()
        -- Reset to defaults
        Controller.Config = {
            SelectedDungeon = "1 - Starter",
            SelectedEvent = "1 Key",
            SelectedGuild = "Medium",
            SkillPattern = "1234",
            AutoFarm = false,
            AutoKill = false,
            AutoSkill = false,
            AutoReplay = false,
            LoopEvent = false,
            Magnet = false,
            ServerHop = false,
            ServerHopLimit = 5,
            AutoGuild = false,
            Noclip = false,
            Fly = false,
            StuckDetector = false
        }
        
        -- Delete file
        if delfile and isfile and isfile(Controller.ConfigFile) then
            delfile(Controller.ConfigFile)
        end
        
        log("CONFIG", "Config reset to defaults")
    end)
    
    return success
end

function Controller.UpdateConfig(key, value)
    Controller.Config[key] = value
    Controller.SaveConfig()
end

log("CONTROLLER", "Controller module loaded (Fixed)")

--------------------------------------------------------------------------------
-- [[ MAIN  ]]
--------------------------------------------------------------------------------

-- DEBUG FLAG
local DEBUG = true
local function log(category, message, ...)
    if DEBUG then
        print(string.format("[MAIN-%s] %s", category, string.format(message, ...)))
    end
end

log("INIT", "==========================================")
log("INIT", "Starting Lootify script...")
log("INIT", "==========================================")

-- [[ AUTO-RELOAD SCRIPT ON TELEPORT ]]
log("INIT", "Setting up auto-reload on teleport...")

-- Cara 1: Jika script dari URL (Ganti dengan URL script Anda)
local SCRIPT_URL = "https://raw.githubusercontent.com/YourUsername/YourRepo/main/lootify.lua"

-- Cara 2: Atau gunakan script source langsung (simpan script ke variable)
local function setupAutoReload()
    local reloadCode = string.format([[
        task.wait(1)
        loadstring(game:HttpGet("%s"))()
    ]], SCRIPT_URL)
    
    local success = pcall(function()
        if syn and syn.queue_on_teleport then
            syn.queue_on_teleport(reloadCode)
            log("INIT", "Auto-reload: syn.queue_on_teleport ✓")
        elseif queue_on_teleport then
            queue_on_teleport(reloadCode)
            log("INIT", "Auto-reload: queue_on_teleport ✓")
        elseif queueonteleport then
            queueonteleport(reloadCode)
            log("INIT", "Auto-reload: queueonteleport ✓")
        else
            warn("[INIT] ⚠ Executor tidak support queue_on_teleport")
            warn("[INIT] Script akan hilang saat server hop!")
            return false
        end
    end)
    
    return success
end

setupAutoReload()

log("INIT", "Loading Fluent UI library...")
local success, Fluent = pcall(function()
    return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
end)

if not success then
    warn("[MAIN-INIT] CRITICAL: Failed to load Fluent UI!")
    warn("[MAIN-INIT] Error:", Fluent)
    return
end
log("INIT", "Fluent UI loaded successfully")

-- MANUAL PATCH ( for backward compatibility)
Database.EventData = Database.EventData or {
    {"1 Key", CFrame.new(-136.45, 59.24, -67.57, -1, 0, 0.0019, 0, 1, 0, -0.0019, 0, -1)},
    {"2 Key", CFrame.new(-123.53, 55.13, -45.37, -0.0033, 0, -1, 0, 1, 0, 1, 0, -0.0033)},
    {"10 Key", CFrame.new(-55.57, 59.24, -44.54, 1, 0, -0.0019, 0, 1, 0, 0.0019, 0, 1)},
    {"10 Key Cross Server", CFrame.new(-39.08, 59.24, -66.51, -1, 0, 0.0019, 0, 1, 0, -0.0019, 0, -1)}
}

-- Ensure other tables exist
Database.RegionList = Database.RegionList or {}
Database.NPC_Map = Database.NPC_Map or {}
Database.TeleportCoords = Database.TeleportCoords or {}
Database.GuildMatchList = Database.GuildMatchList or {}
Database.ManualWaypoints = Database.ManualWaypoints or {
    Vector3.new(-16.31, 13.35, -427.16), Vector3.new(-16.31, 28.74, -331.82), 
    Vector3.new(-70.43, 28.75, -277.38), Vector3.new(-38.31, 28.76, -219.96), 
    Vector3.new(-25.11, 28.76, -172.52), Vector3.new(-20.89, 43.09, -114.37),
    Vector3.new(-77.09, 43.09, -109.34), Vector3.new(-84.30, 57.95, -68.11)
}

-- Helper functions
Database.GetRegionID = Database.GetRegionID or function(name)
    for _, entry in ipairs(Database.RegionList) do
        if entry[1] == name then return entry[2] end
    end
    return nil
end

Database.GetEventData = Database.GetEventData or function(name)
    for _, entry in ipairs(Database.EventData) do
        if entry[1] == name then
            return {CFrame = entry[2], ObjName = entry[3]}
        end
    end
    return nil
end

Database.GetTeleportCFrame = Database.GetTeleportCFrame or function(name)
    for _, entry in ipairs(Database.TeleportCoords) do
        if entry[1] == name then return entry[2] end
    end
    return nil
end

Database.GetGuildData = Database.GetGuildData or function(name)
    for _, entry in ipairs(Database.GuildMatchList) do
        if entry[1] == name then
            return {matchPath = entry[2], teleportCFrame = entry[3]}
        end
    end
    return nil
end

log("DB", "Database Patched Successfully")

-- Validate Database
log("DB", "Validating database structure...")
if not Database.RegionList then
    warn("[MAIN-DB] Database.RegionList is missing!")
    return
end
log("DB", "RegionList found with %d entries", #Database.RegionList)

if not Database.EventData then
    warn("[MAIN-DB] Database.EventData is missing!")
    return
end
log("DB", "EventData found with %d entries", #Database.EventData)


if not Controller then
    warn("[MAIN-CTRL] CRITICAL: Controller is nil!")
    return
end

log("CTRL", "Controller loaded (Local)")

-- SETUP UI
log("UI", "Creating window...")
local Window = Fluent:CreateWindow({
    Title = "Lootify Script | Underperfom Hub",
    SubTitle = "By Lynccc",
    TabWidth = 160, 
    Size = UDim2.fromOffset(580, 460), 
    Theme = "Dark", 
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Options untuk akses toggles nanti
local Options = Fluent.Options or {}

log("UI", "Window created")

log("UI", "Creating tabs...")
local HomeTab = Window:AddTab({ Title = "Dungeons", Icon = "swords" })
local EventTab = Window:AddTab({ Title = "Event", Icon = "gift" })
local GuildTab = Window:AddTab({ Title = "Guild War", Icon = "shield" })
local MiscTab = Window:AddTab({ Title = "Misc", Icon = "box" })
local SettingsTab = Window:AddTab({ Title = "Settings", Icon = "settings" })    
log("UI", "All tabs created")

--------------------------------------------------------------------------------
-- HOME TAB
--------------------------------------------------------------------------------
log("HOME", "Setting up Home tab...")
local SelectedRegion = 101002

-- Toggle References untuk restore state
local Toggles = {}

local function GetSortedDungeonNames()
    local names = {}
    for _, entry in ipairs(Database.RegionList) do
        table.insert(names, entry[1])
    end
    return names
end

HomeTab:AddDropdown("SelectDungeon", {
    Title = "Select Dungeon",
    Values = GetSortedDungeonNames(),
    Default = 1,
    Callback = function(Val) 
        SelectedRegion = Database.GetRegionID(Val)
        log("HOME", "Selected: %s (ID: %d)", Val, SelectedRegion or 0)
        Controller.UpdateConfig("SelectedDungeon", Val)
    end
})

HomeTab:AddButton({
    Title = "Enter Dungeon (Once)",
    Description = "Enter selected dungeon immediately",
    Callback = function()
        log("HOME", "Enter Dungeon clicked (ID: %d)", SelectedRegion)
        local data = Database.NPC_Map[SelectedRegion]
        Controller.EnterRegion(SelectedRegion, data)
        Fluent:Notify({
            Title = "Action", 
            Content = "Entering dungeon ID: " .. tostring(SelectedRegion), 
            Duration = 2
        })
    end
})

Toggles.AutoReplay = HomeTab:AddToggle("StartFarm", {
    Title = "Auto Replay (Loop)",
    Description = "Re-enter dungeon after finish/death",
    Default = Controller.Config.AutoReplay or false,
    Callback = function(Val)
        log("HOME", "Auto Replay: %s", Val and "ON" or "OFF")
        local data = Database.NPC_Map[SelectedRegion]
        Controller.ToggleAutoReplay(Val, SelectedRegion, data)
        Controller.UpdateConfig("AutoReplay", Val)
        
        Fluent:Notify({
            Title = "System", 
            Content = Val and ("Auto Replay Enabled for ID: " .. tostring(SelectedRegion)) or "Auto Replay Disabled", 
            Duration = 2
        })
    end
})

Toggles.AutoKill = HomeTab:AddToggle("AutoKill", {
    Title = "Auto Kill Aura",
    Default = Controller.Config.AutoKill or false,
    Callback = function(Val)
        log("HOME", "Auto Kill: %s", Val and "ON" or "OFF")
        Controller.AutoKillEnabled = Val
        Controller.UpdateConfig("AutoKill", Val)
        if Val then
            Controller.RunAutoKill(function(enemy)
                local n = enemy:GetAttribute("name")
                local t = enemy:GetAttribute("enemyTitle")
                if n == "The Krampus" and t ~= "Final Boss" then return true end
                return false
            end)
        end
    end
})

Toggles.AutoSkill = HomeTab:AddToggle("AutoSkill", {
    Title = "Auto Skill",
    Default = Controller.Config.AutoSkill or false,
    Callback = function(Val)
        log("HOME", "Auto Skill: %s", Val and "ON" or "OFF")
        Controller.UpdateConfig("AutoSkill", Val)
        if Val then 
            Controller.RunAutoSkill(0.3, function() return false end)
        else 
            Controller.AutoSkillEnabled = false 
        end
    end
})

local SkillPatternInput = HomeTab:AddInput("SkillPattern", {
    Title = "Custom Skill Pattern",
    Description = "Masukkan urutan skill 1-4 (angka langsung tanpa koma)",
    Default = Controller.Config.SkillPattern or "1234",
    Placeholder = "contoh: 13423241232",
    Numeric = false,
    Finished = true,
    Callback = function(Val)
        log("HOME", "Skill Pattern input: %s", Val)
        local ok = Controller.SetSkillPatternFromString(Val)
        Controller.UpdateConfig("SkillPattern", Val)
        
        if ok then
            local displayPattern = Controller.GetCurrentSkillPattern()
            Fluent:Notify({
                Title = "Skill Pattern",
                Content = "Pattern berhasil diset: " .. displayPattern,
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Error",
                Content = "Pattern tidak valid! Gunakan angka 1-4 saja",
                Duration = 4
            })
        end
    end
})

-- Update paragraph info
HomeTab:AddParagraph({
    Title = "Skill Pattern Guide",
    Content = "• Contiguous: 132132134 = skill 1,3,2,1,3,2,1,3,4\n• Separated: 1,3,2,1,3,2,1,3,4\n• Smart Mode: Type 'smart' for AI decision\n• Only use digits 1-4 (skill slots)"
})

HomeTab:AddParagraph({
    Title = "Info",
    Content = "• Click 'Enter Dungeon' to join immediately\n• Turn ON 'Auto Replay' to farm AFK\n• Auto Kill will attack nearest enemy\n• Auto Skill will cycle through skills 1-4"
})

--------------------------------------------------------------------------------
-- EVENT TAB
--------------------------------------------------------------------------------
log("EVENT", "Setting up Event tab...")
local SelectedEventData = nil

local function GetSortedEventNames()
    local names = {}
    for _, entry in ipairs(Database.EventData) do
        table.insert(names, entry[1])
    end
    return names
end

EventTab:AddDropdown("EventDest", {
    Title = "Select Key Destination",
    Values = GetSortedEventNames(),
    Default = 1,
    Callback = function(Val) 
        SelectedEventData = Database.GetEventData(Val)
        log("EVENT", "Selected: %s", Val)
        Controller.UpdateConfig("SelectedEvent", Val)
    end
})

Toggles.LoopEvent = EventTab:AddToggle("LoopEvent", {
    Title = "Auto Loop Event (Walk + Replay)",
    Description = "Auto walk again after death/finish",
    Default = Controller.Config.LoopEvent or false,
    Callback = function(Val)
        Controller.UpdateConfig("LoopEvent", Val)
        if Val then
            if SelectedEventData then
                Fluent:Notify({
                    Title = "System", 
                    Content = "Loop Started", 
                    Duration = 3
                })
                
                Controller.StartEventLoop(
                    SelectedEventData.CFrame, 
                    Database.ManualWaypoints
                )
            else
                Fluent:Notify({
                    Title = "Error", 
                    Content = "Select destination first", 
                    Duration = 2
                })
            end
        else
            Controller.StopEventLoop()
            Fluent:Notify({
                Title = "System", 
                Content = "Loop Stopped", 
                Duration = 2
            })
        end
    end
})

EventTab:AddButton({
    Title = "STOP Movement",
    Description = "Cancel current pathfinding",
    Callback = function()
        Controller.StopWalk()
        Fluent:Notify({
            Title = "System", 
            Content = "Movement Stopped", 
            Duration = 2
        })
    end
})

Toggles.Magnet = EventTab:AddToggle("Magnet", {
    Title = "Auto Collect (Magnet)",
    Default = Controller.Config.Magnet or false,
    Callback = function(Val)
        log("EVENT", "Magnet: %s", Val and "ON" or "OFF")
        Controller.MagnetActive = Val
        Controller.UpdateConfig("Magnet", Val)
        if Val then 
            Controller.StartMagnet({
                Delay = 0.1, 
                ChestName = "HalloweenChestPrefab", 
                ItemFolder = "SugarFolder"
            }) 
        end
    end
})

Toggles.ServerHop = EventTab:AddToggle("ServerHop", {
    Title = "Auto Server Hop",
    Description = "Pindah server jika ada 5+ pemain",
    Default = Controller.Config.ServerHop or false,
    Callback = function(Val)
        log("EVENT", "Server Hop: %s", Val and "ON" or "OFF")
        Controller.UpdateConfig("ServerHop", Val)
        if Val then
            Controller.StartServerHopMonitor()
            Fluent:Notify({
                Title = "Server Hop",
                Content = "Monitoring aktif - akan pindah jika ≥" .. Controller.ServerHopPlayerLimit .. " pemain",
                Duration = 4
            })
        else
            Controller.StopServerHopMonitor()
            Fluent:Notify({
                Title = "Server Hop",
                Content = "Monitoring dihentikan",
                Duration = 2
            })
        end
    end
})

EventTab:AddButton({
    Title = "Hop Server Sekarang",
    Description = "Pindah ke server lain langsung",
    Callback = function()
        Fluent:Notify({
            Title = "Server Hop",
            Content = "Mencari server...",
            Duration = 2
        })
        Controller.ServerHop()
    end
})

EventTab:AddParagraph({
    Title = "Info",
    Content = "• Select event destination from dropdown\n• Toggle 'Auto Loop Event' to start\n• Use STOP button to cancel movement\n• Magnet will auto-collect items\n• Server Hop akan otomatis pindah jika ada ≥5 pemain"
})

--------------------------------------------------------------------------------
-- GUILD TAB
--------------------------------------------------------------------------------
log("GUILD", "Setting up Guild tab...")
local SelectedGuild = "Medium"

local function GetGuildNames()
    local names = {}
    for _, entry in ipairs(Database.GuildMatchList) do
        table.insert(names, entry[1])
    end
    return names
end

GuildTab:AddDropdown("GDiff", {
    Title = "Difficulty",
    Values = GetGuildNames(),
    Default = 1,
    Callback = function(Val) 
        SelectedGuild = Val
        log("GUILD", "Selected: %s", Val)
        Controller.UpdateConfig("SelectedGuild", Val)
    end
})

GuildTab:AddButton({
    Title = "Enter Guild War (Once)",
    Callback = function()
        log("GUILD", "Guild button clicked")
        local matchData = Database.GetGuildData(SelectedGuild)
        if matchData then
            Controller.JoinGuildOnce(matchData)
            Fluent:Notify({
                Title = "Action", 
                Content = "Joining Guild War: " .. SelectedGuild, 
                Duration = 2
            })
        end
    end
})

GuildTab:AddToggle("AutoGuild", {
    Title = "Auto Guild Loop",
    Description = "Auto join and replay matches",
    Default = Controller.Config.AutoGuild or false,
    Callback = function(Val)
        log("GUILD", "Guild Loop: %s", Val and "ON" or "OFF")
        Controller.UpdateConfig("AutoGuild", Val)
        local matchData = Database.GetGuildData(SelectedGuild)
        local lobbyCFrame = Database.GetTeleportCFrame("Guild Island")
        
        if matchData then
            Controller.ToggleAutoGuild(Val, matchData, lobbyCFrame)
            Fluent:Notify({
                Title = "System", 
                Content = Val and ("Guild Loop Started: " .. SelectedGuild) or "Guild Loop Stopped", 
                Duration = 2
            })
        end
    end
})

GuildTab:AddParagraph({
    Title = "Info",
    Content = "• Select difficulty from dropdown\n• Click 'Enter Guild War' for one-time entry\n• Toggle 'Auto Guild Loop' for continuous farming"
})

--------------------------------------------------------------------------------
-- MISC TAB
--------------------------------------------------------------------------------
log("MISC", "Setting up Misc tab...")
local SelectedTPName = nil 
local SelectedTPCFrame = nil 

local function GetSortedTPNames()
    local names = {}
    for _, entry in ipairs(Database.TeleportCoords) do
        table.insert(names, entry[1])
    end
    return names
end

MiscTab:AddDropdown("TPDest", {
    Title = "Teleport Destination",
    Values = GetSortedTPNames(),
    Default = 1,
    Callback = function(Val) 
        SelectedTPName = Val
        SelectedTPCFrame = Database.GetTeleportCFrame(Val)
        log("MISC", "TP Selected: %s", Val)
    end
})

MiscTab:AddButton({
    Title = "Teleport Now (Safe)",
    Callback = function()
        log("MISC", "Teleport button clicked")
        
        if not SelectedTPCFrame or not SelectedTPName then 
            Fluent:Notify({
                Title = "Error", 
                Content = "Select destination first", 
                Duration = 2
            })
            return 
        end
        
        if not LocalPlayer.Character then 
            Fluent:Notify({
                Title = "Error", 
                Content = "Character not loaded", 
                Duration = 2
            })
            return 
        end
        
        local mySea = Controller.GetCurrentSea()
        local isDestSea2 = string.find(SelectedTPName, "World 7") or 
                          string.find(SelectedTPName, "World 8") or 
                          string.find(SelectedTPName, "World 9") or 
                          string.find(SelectedTPName, "Sea 2")
        
        if mySea == 1 and isDestSea2 then
            Fluent:Notify({
                Title = "Blocked", 
                Content = "Cannot TP to Sea 2 from Sea 1!", 
                Duration = 3
            })
            return
        elseif mySea == 2 and not isDestSea2 then
            Fluent:Notify({
                Title = "Blocked", 
                Content = "Cannot TP to Sea 1 from Sea 2!", 
                Duration = 3
            })
            return
        end
        
        LocalPlayer.Character.HumanoidRootPart.CFrame = SelectedTPCFrame
        Fluent:Notify({
            Title = "Teleporting", 
            Content = "Going to " .. SelectedTPName, 
            Duration = 2
        })
    end
})

MiscTab:AddToggle("Fly", { 
    Title = "Fly Mode", 
    Default = Controller.Config.Fly or false, 
    Callback = function(V) 
        log("MISC", "Fly: %s", V and "ON" or "OFF")
        Controller.UpdateConfig("Fly", V)
        Controller.ToggleFly(V, 50) 
    end 
})

MiscTab:AddToggle("Noclip", { 
    Title = "Noclip", 
    Default = Controller.Config.Noclip or false, 
    Callback = function(V) 
        log("MISC", "Noclip: %s", V and "ON" or "OFF")
        Controller.UpdateConfig("Noclip", V)
        Controller.ToggleNoclip(V) 
    end 
})

MiscTab:AddParagraph({
    Title = "Movement Info",
    Content = "Fly: WASD + Space to move\nNoclip: Walk through walls\n\nTeleport Safety: Cannot TP between seas"
})

--------------------------------------------------------------------------------
-- SETTINGS TAB
--------------------------------------------------------------------------------
log("SETTINGS", "Setting up Settings tab...")

SettingsTab:AddButton({
    Title = "💾 Save Config",
    Description = "Simpan semua settingan saat ini",
    Callback = function()
        log("SETTINGS", "Save config clicked")
        local success = Controller.SaveConfig()
        if success then
            Fluent:Notify({
                Title = "Config Saved",
                Content = "Settingan berhasil disimpan!",
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Error",
                Content = "Gagal menyimpan config. Executor mungkin tidak support writefile.",
                Duration = 4
            })
        end
    end
})

SettingsTab:AddButton({
    Title = "🔄 Reset Config",
    Description = "Reset semua settingan ke default",
    Callback = function()
        log("SETTINGS", "Reset config clicked")
        Controller.ResetConfig()
        Fluent:Notify({
            Title = "Config Reset",
            Content = "Settingan direset ke default! Reload script untuk apply.",
            Duration = 4
        })
    end
})

SettingsTab:AddParagraph({
    Title = "Auto-Save Info",
    Content = "✓ Config otomatis tersimpan setiap kali toggle/setting berubah\n✓ Config akan auto-load saat script dimulai\n✓ Config tersimpan bahkan setelah server hop\n\nFile: " .. Controller.ConfigFile
})

SettingsTab:AddButton({
    Title = "Unload Script",
    Description = "Stop all features and close UI",
    Callback = function()
        log("SETTINGS", "Unload button clicked")
        Controller.Cleanup()
        Fluent:Destroy()
        log("SETTINGS", "Script unloaded")
    end
})

SettingsTab:AddParagraph({
    Title = "Version Info",
    Content = "Lootify Script | Underperfom\nVersion: 1.0.1\nAuthor: Lynccc\n\nChangelog:\n- Initial Release"
})

SettingsTab:AddParagraph({
    Title = "Debug Info",
    Content = "Press F9 to open Developer Console\nAll actions are logged with [MAIN-XXX] prefix\n\nIf issues occur, check console for errors"
})

log("INIT", "==========================================")
log("INIT", "Script loaded successfully!")
log("INIT", "==========================================")

-- Load saved config
log("CONFIG", "Loading saved configuration...")
local configLoaded = Controller.LoadConfig()

-- Apply loaded config to skill pattern if exists
if Controller.Config.SkillPattern then
    Controller.SetSkillPatternFromString(Controller.Config.SkillPattern)
end

-- Restore toggle states dari saved config (fungsi + UI)
log("CONFIG", "Config loaded status: %s", tostring(configLoaded))
log("CONFIG", "AutoKill in config: %s", tostring(Controller.Config.AutoKill))
log("CONFIG", "AutoSkill in config: %s", tostring(Controller.Config.AutoSkill))

if configLoaded then
    log("CONFIG", "Restoring toggle states...")
    
    Fluent:Notify({
        Title = "Debug",
        Content = "Config loaded! Waiting 3s to restore...",
        Duration = 3
    })
    
    task.spawn(function()
        task.wait(3) -- Wait lebih lama untuk UI fully loaded
        
        -- Restore Auto Kill (fungsi + toggle via Options)
        if Controller.Config.AutoKill then
            log("CONFIG", "Restoring Auto Kill...")
            Controller.AutoKillEnabled = true
            Controller.RunAutoKill(function(enemy)
                local n = enemy:GetAttribute("name")
                local t = enemy:GetAttribute("enemyTitle")
                if n == "The Krampus" and t ~= "Final Boss" then return true end
                return false
            end)
            
            -- Coba berbagai cara akses toggle
            pcall(function()
                if Options and Options.AutoKill then
                    Options.AutoKill:SetValue(true)
                elseif Toggles.AutoKill then
                    Toggles.AutoKill:SetValue(true)
                end
            end)
        end
        
        -- Restore Auto Skill (fungsi + toggle via Options)
        if Controller.Config.AutoSkill then
            log("CONFIG", "Restoring Auto Skill...")
            Controller.RunAutoSkill(0.3, function() return false end)
            
            pcall(function()
                if Options and Options.AutoSkill then
                    Options.AutoSkill:SetValue(true)
                elseif Toggles.AutoSkill then
                    Toggles.AutoSkill:SetValue(true)
                end
            end)
        end
        
        -- Restore Auto Replay (fungsi + toggle via Options)
        if Controller.Config.AutoReplay and Controller.Config.SelectedDungeon then
            log("CONFIG", "Restoring Auto Replay...")
            local regionID = Database.GetRegionID(Controller.Config.SelectedDungeon)
            if regionID then
                local data = Database.NPC_Map[regionID]
                Controller.ToggleAutoReplay(true, regionID, data)
                
                pcall(function()
                    if Options and Options.StartFarm then
                        Options.StartFarm:SetValue(true)
                    elseif Toggles.AutoReplay then
                        Toggles.AutoReplay:SetValue(true)
                    end
                end)
            end
        end
        
        -- Restore Magnet (fungsi + toggle via Options)
        if Controller.Config.Magnet then
            log("CONFIG", "Restoring Magnet...")
            Controller.MagnetActive = true
            Controller.StartMagnet({
                Delay = 0.1, 
                ChestName = "HalloweenChestPrefab", 
                ItemFolder = "SugarFolder"
            })
            
            pcall(function()
                if Options and Options.Magnet then
                    Options.Magnet:SetValue(true)
                elseif Toggles.Magnet then
                    Toggles.Magnet:SetValue(true)
                end
            end)
        end
        
        -- Restore Server Hop (fungsi + toggle via Options)
        if Controller.Config.ServerHop then
            log("CONFIG", "Restoring Server Hop...")
            Controller.StartServerHopMonitor()
            
            pcall(function()
                if Options and Options.ServerHop then
                    Options.ServerHop:SetValue(true)
                elseif Toggles.ServerHop then
                    Toggles.ServerHop:SetValue(true)
                end
            end)
        end
        
        -- Restore Loop Event (fungsi + toggle via Options)
        if Controller.Config.LoopEvent and Controller.Config.SelectedEvent then
            log("CONFIG", "Restoring Loop Event...")
            local eventData = Database.GetEventData(Controller.Config.SelectedEvent)
            if eventData then
                Controller.StartEventLoop(eventData.CFrame, Database.ManualWaypoints)
                
                pcall(function()
                    if Options and Options.LoopEvent then
                        Options.LoopEvent:SetValue(true)
                    elseif Toggles.LoopEvent then
                        Toggles.LoopEvent:SetValue(true)
                    end
                end)
            end
        end
        
        log("CONFIG", "All features restored successfully!")
        
        Fluent:Notify({
            Title = "Config Restored",
            Content = "Settingan Anda telah diaktifkan kembali!",
            Duration = 4
        })
    end)
end

Window:SelectTab(HomeTab)

Fluent:Notify({
    Title = "Welcome", 
    Content = configLoaded and "Config loaded! Settingan Anda sudah diaktifkan." or "Lootify script loaded!", 
    Duration = 5
})
