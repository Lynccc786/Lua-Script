--[[
    Fate Trigger [FPS] - Full Functional Version
    GUI + All Functions Integrated
]]

-- ============================================================
-- SERVICES
-- ============================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ScriptRunning flag
local ScriptRunning = true

-- ============================================================
-- SETTINGS
-- ============================================================
local Settings = {
    -- ESP
    BoxESPEnabled = false,
    SkeletonESPEnabled = false,
    TeamCheck = false,
    ShowDistance = false,
    ShowName = false,
    ShowTracer = false,
    EnemyColor = Color3.fromRGB(255, 50, 50),
    EnemyNameColor = Color3.fromRGB(255, 50, 50),
    EnemyDistanceColor = Color3.fromRGB(255, 50, 50),
    TeamColor = Color3.fromRGB(50, 255, 50),
    TeamNameColor = Color3.fromRGB(50, 255, 50),
    TeamDistanceColor = Color3.fromRGB(50, 255, 50),
    TracerColor = Color3.fromRGB(255, 255, 255),
    TracerThickness = 0.1,
    SkeletonThickness = 1,
    TextSize = 14,
    ChamsESPEnabled = false,
    EnemyChamsColor = Color3.fromRGB(255, 100, 255),
    TeamChamsColor = Color3.fromRGB(100, 255, 100),
    -- AIMBOT
    AimbotEnabled = false,
    AutoAim = false,
    AimbotFOVCircle = false,
    AimbotFOVRadius = 60,
    AimbotTargetPart = "Head",
    AimbotTeamCheck = false,
    AimbotWallCheck = false,
    AutoShoot = false,
    -- TRIGGERBOT
    TriggerBotEnabled = false,
    TriggerBotDelay = 0.1,
    TriggerBotTeamCheck = false,
    -- HITBOX
    HitboxExpanderEnabled = false,
    HitboxSize = 10,
    HitboxColor = Color3.fromRGB(255,255,255), -- warna tidak penting, transparansi penuh
    HitboxTransparency = 1, -- default transparan penuh
}

-- ESP Folder
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "FateTriggerESP"
ESPFolder.Parent = Workspace.CurrentCamera

local characterESP = {}
local scannedCharacters = {}
local enemyCache = {}
local teammateCache = {}

-- ============================================================
-- HELPER FUNCTIONS
-- ============================================================

local function resetHitbox(character)
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local originalSize = hrp:FindFirstChild("OriginalSize")
        local originalCanCollide = hrp:FindFirstChild("OriginalCanCollide")

        if originalSize then
            hrp.Size = originalSize.Value
            hrp.Transparency = 1
            originalSize:Destroy()
        end

        if originalCanCollide then
            hrp.CanCollide = originalCanCollide.Value
            originalCanCollide:Destroy()
        end
    end
end

-- WEAPON BLACKLIST
local weaponBlacklist = {
    ["ak"] = true,
    ["bolt sniper"] = true,
    ["drum gun"] = true,
    ["dual blasters"] = true,
    ["enforcer"] = true,
    ["famas"] = true,
    ["flag"] = true,
    ["honey badger"] = true,
    ["knife"] = true,
    ["m4"] = true,
    ["mp5"] = true,
    ["paintball gun"] = true,
    ["pistol"] = true,
    ["scarh"] = true,
    ["shadow domer"] = true,
    ["tralalero tralala"] = true,
    ["type 100"] = true,
    ["karambit"] = true,
    ["luger"] = true,
    ["rpg"] = true,
    ["tec-9"] = true,
    ["vectorstrike"] = true,
}

local function isCharacter(model)
    if not model:IsA("Model") then
        return false
    end

    local name = model.Name:lower()

    if weaponBlacklist[name] then
        return false
    end

    if name:find("rig") or name:find("dummy") or name:find("mannequin") then
        return false
    end

    if name:find("weapon") or name:find("gun") or name:find("knife") or
       name:find("sword") or name:find("tool") or name:find("item") then
        return false
    end

    local parent = model.Parent
    if parent then
        local parentName = parent.Name:lower()
        if parentName:find("weapon") or parentName:find("gun") or parentName:find("item") or
           parentName:find("tool") or parentName:find("equipment") then
            return false
        end
    end

    local humanoid = model:FindFirstChildOfClass("Humanoid")
    local hrp = model:FindFirstChild("HumanoidRootPart")

    if not humanoid or not hrp then
        return false
    end

    if hrp.Size.Y < 1.8 then
        return false
    end

    local hasBodyParts = model:FindFirstChild("Head") or
                         model:FindFirstChild("UpperTorso") or
                         model:FindFirstChild("Torso")
    if not hasBodyParts then
        return false
    end

    if humanoid.Health <= 0 then
        return false
    end

    return true
end

local function isLocalPlayer(model)
    return LocalPlayer.Character == model
end

local function isEnemy(character)
    if enemyCache[character] and tick() - enemyCache[character].time < 1 then
        return enemyCache[character].isEnemy
    end

    local result = false
    for _, obj in ipairs(character:GetDescendants()) do
        if obj:IsA("Highlight") then
            local r, g, b = obj.FillColor.R * 255, obj.FillColor.G * 255, obj.FillColor.B * 255

            if r > 200 and g < 50 and b < 50 then
                result = true
                break
            end
        end
    end

    enemyCache[character] = {isEnemy = result, time = tick()}
    return result
end

local function isTeammate(character)
    if teammateCache[character] and tick() - teammateCache[character].time < 1 then
        return teammateCache[character].isTeammate
    end

    local result = false
    for _, obj in ipairs(character:GetDescendants()) do
        if obj:IsA("Highlight") then
            local r, g, b = obj.FillColor.R * 255, obj.FillColor.G * 255, obj.FillColor.B * 255

            if r < 50 and g > 200 and b < 50 then
                result = true
                break
            end
        end
    end

    teammateCache[character] = {isTeammate = result, time = tick()}
    return result
end

-- ============================================================
-- HITBOX EXPANDER
-- ============================================================

local function applyHitboxExpander(character)
    if not Settings.HitboxExpanderEnabled then return end

    if isLocalPlayer(character) or isTeammate(character) then
        return
    end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if not hrp:FindFirstChild("OriginalSize") then
        local originalSize = Instance.new("Vector3Value")
        originalSize.Name = "OriginalSize"
        originalSize.Value = hrp.Size
        originalSize.Parent = hrp

        local originalCanCollide = Instance.new("BoolValue")
        originalCanCollide.Name = "OriginalCanCollide"
        originalCanCollide.Value = hrp.CanCollide
        originalCanCollide.Parent = hrp
    end

    hrp.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
    hrp.Transparency = Settings.HitboxTransparency
    hrp.Color = Settings.HitboxColor
    hrp.CanCollide = false
end

task.spawn(function()
    while task.wait(2) do
        if not ScriptRunning then break end
        if Settings.HitboxExpanderEnabled then
            for char, esp in pairs(characterESP) do
                if char.Parent and not esp.isDead then
                    pcall(function()
                        if isTeammate(char) then
                            resetHitbox(char)
                        else
                            applyHitboxExpander(char)
                        end
                    end)
                end
            end
        end
    end
end)

-- ============================================================
-- ESP SYSTEM
-- ============================================================

local function createSkeletonLine()
    local line = Instance.new("LineHandleAdornment")
    line.Color3 = Color3.fromRGB(255, 255, 255)
    line.Thickness = Settings.SkeletonThickness * 2
    line.Transparency = 0
    line.AlwaysOnTop = true
    line.ZIndex = 10
    line.Visible = false
    line.Length = 0
    line.Adornee = Workspace.Terrain
    line.Parent = ESPFolder

    return {line = line}
end

local function createSkeleton()
    return {
        headToUpperTorso = createSkeletonLine(),
        upperToLowerTorso = createSkeletonLine(),
        leftUpperArmToHand = createSkeletonLine(),
        leftLowerArmToHand = createSkeletonLine(),
        leftHandToTorso = createSkeletonLine(),
        rightUpperArmToHand = createSkeletonLine(),
        rightLowerArmToHand = createSkeletonLine(),
        rightHandToTorso = createSkeletonLine(),
        leftUpperLegToFoot = createSkeletonLine(),
        leftLowerLegToFoot = createSkeletonLine(),
        leftFootToTorso = createSkeletonLine(),
        rightUpperLegToFoot = createSkeletonLine(),
        rightLowerLegToFoot = createSkeletonLine(),
        rightFootToTorso = createSkeletonLine()
    }
end

local function createESP()
    local box = Instance.new("BoxHandleAdornment")
    box.Size = Vector3.new(4, 5, 1)
    box.Color3 = Settings.EnemyColor
    box.Transparency = 0.5
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Parent = ESPFolder

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = ESPFolder

    local text = Instance.new("TextLabel")
    text.Name = "Text"
    text.Size = UDim2.new(1, 0, 1, 0)
    text.Position = UDim2.new(0, 0, 0, 0)
    text.BackgroundTransparency = 1
    text.TextColor3 = Color3.fromRGB(255, 255, 255)
    text.TextSize = Settings.TextSize
    text.Font = Enum.Font.GothamBold
    text.TextStrokeTransparency = 0
    text.Text = ""
    text.Visible = false
    text.Parent = billboard

    local tracer = Instance.new("Beam")
    tracer.Color = ColorSequence.new(Settings.TracerColor)
    tracer.Width0 = Settings.TracerThickness
    tracer.Width1 = Settings.TracerThickness
    tracer.Transparency = NumberSequence.new(0.5)
    tracer.FaceCamera = true
    tracer.Enabled = false
    tracer.Parent = ESPFolder

    local tracerStart = Instance.new("Attachment")
    tracerStart.Name = "TracerStart"
    tracerStart.Parent = ESPFolder

    local tracerEnd = Instance.new("Attachment")
    tracerEnd.Name = "TracerEnd"
    tracerEnd.Parent = ESPFolder

    tracer.Attachment0 = tracerStart
    tracer.Attachment1 = tracerEnd

    local skeleton = createSkeleton()

    local chams = Instance.new("Highlight")
    chams.FillColor = Color3.fromRGB(255, 100, 255)
    chams.FillTransparency = 0.5
    chams.OutlineColor = Color3.fromRGB(255, 100, 255)
    chams.OutlineTransparency = 0
    chams.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    chams.Enabled = false
    chams.Parent = ESPFolder

    return {
        box = box,
        billboard = billboard,
        text = text,
        tracer = tracer,
        tracerStart = tracerStart,
        tracerEnd = tracerEnd,
        skeleton = skeleton,
        chams = chams,
        isDead = false
    }
end

local function updateSkeleton(character, skeleton, skeletonColor)
    if not Settings.SkeletonESPEnabled then
        for _, lineData in pairs(skeleton) do
            lineData.line.Length = 0
            lineData.line.Visible = false
        end
        return
    end

    local isR15 = character:FindFirstChild("UpperTorso") ~= nil
    
    local head = character:FindFirstChild("Head")
    local torso, lowerTorso
    local leftArm, leftForearm, leftHand
    local rightArm, rightForearm, rightHand
    local leftLeg, leftCalf, leftFoot
    local rightLeg, rightCalf, rightFoot

    if isR15 then
        torso = character:FindFirstChild("UpperTorso")
        lowerTorso = character:FindFirstChild("LowerTorso")
        
        leftArm = character:FindFirstChild("LeftUpperArm")
        leftForearm = character:FindFirstChild("LeftLowerArm")
        leftHand = character:FindFirstChild("LeftHand")
        
        rightArm = character:FindFirstChild("RightUpperArm")
        rightForearm = character:FindFirstChild("RightLowerArm")
        rightHand = character:FindFirstChild("RightHand")
        
        leftLeg = character:FindFirstChild("LeftUpperLeg")
        leftCalf = character:FindFirstChild("LeftLowerLeg")
        leftFoot = character:FindFirstChild("LeftFoot")
        
        rightLeg = character:FindFirstChild("RightUpperLeg")
        rightCalf = character:FindFirstChild("RightLowerLeg")
        rightFoot = character:FindFirstChild("RightFoot")
    else
        torso = character:FindFirstChild("Torso")
        lowerTorso = torso
        
        leftArm = character:FindFirstChild("Left Arm")
        leftForearm = leftArm
        leftHand = leftArm
        
        rightArm = character:FindFirstChild("Right Arm")
        rightForearm = rightArm
        rightHand = rightArm
        
        leftLeg = character:FindFirstChild("Left Leg")
        leftCalf = leftLeg
        leftFoot = leftLeg
        
        rightLeg = character:FindFirstChild("Right Leg")
        rightCalf = rightLeg
        rightFoot = rightLeg
    end

    local function connectParts(lineData, part1, part2, name, color)
        if part1 and part2 then
            lineData.line.CFrame = CFrame.new(part1.Position)
            lineData.line.Length = (part2.Position - part1.Position).Magnitude
            lineData.line.CFrame = CFrame.lookAt(part1.Position, part2.Position)
            lineData.line.Color3 = color
            lineData.line.Thickness = Settings.SkeletonThickness * 2
            lineData.line.Visible = true
        else
            lineData.line.Length = 0
            lineData.line.Visible = false
        end
    end

    connectParts(skeleton.headToUpperTorso, head, torso, "Head->Torso", skeletonColor)
    
    if isR15 then
        connectParts(skeleton.upperToLowerTorso, torso, lowerTorso, "Upper->LowerTorso", skeletonColor)
    else
        skeleton.upperToLowerTorso.line.Visible = false
    end

    connectParts(skeleton.leftHandToTorso, torso, leftArm, "Torso->LeftArm", skeletonColor)
    if isR15 then
        connectParts(skeleton.leftUpperArmToHand, leftArm, leftForearm, "LeftUpperArm->LeftLowerArm", skeletonColor)
        connectParts(skeleton.leftLowerArmToHand, leftForearm, leftHand, "LeftLowerArm->LeftHand", skeletonColor)
    else
        skeleton.leftUpperArmToHand.line.Visible = false
        skeleton.leftLowerArmToHand.line.Visible = false
    end

    connectParts(skeleton.rightHandToTorso, torso, rightArm, "Torso->RightArm", skeletonColor)
    if isR15 then
        connectParts(skeleton.rightUpperArmToHand, rightArm, rightForearm, "RightUpperArm->RightLowerArm", skeletonColor)
        connectParts(skeleton.rightLowerArmToHand, rightForearm, rightHand, "RightLowerArm->RightHand", skeletonColor)
    else
        skeleton.rightUpperArmToHand.line.Visible = false
        skeleton.rightLowerArmToHand.line.Visible = false
    end

    connectParts(skeleton.leftFootToTorso, lowerTorso, leftLeg, "Torso->LeftLeg", skeletonColor)
    if isR15 then
        connectParts(skeleton.leftUpperLegToFoot, leftLeg, leftCalf, "LeftUpperLeg->LeftLowerLeg", skeletonColor)
        connectParts(skeleton.leftLowerLegToFoot, leftCalf, leftFoot, "LeftLowerLeg->LeftFoot", skeletonColor)
    else
        skeleton.leftUpperLegToFoot.line.Visible = false
        skeleton.leftLowerLegToFoot.line.Visible = false
    end

    connectParts(skeleton.rightFootToTorso, lowerTorso, rightLeg, "Torso->RightLeg", skeletonColor)
    if isR15 then
        connectParts(skeleton.rightUpperLegToFoot, rightLeg, rightCalf, "RightUpperLeg->RightLowerLeg", skeletonColor)
        connectParts(skeleton.rightLowerLegToFoot, rightCalf, rightFoot, "RightLowerLeg->RightFoot", skeletonColor)
    else
        skeleton.rightUpperLegToFoot.line.Visible = false
        skeleton.rightLowerLegToFoot.line.Visible = false
    end
end

local function updateESPVisibility(character, esp)
    if not character.Parent or esp.isDead then
        esp.box.Adornee = nil
        esp.billboard.Adornee = nil
        esp.text.Visible = false
        esp.tracer.Enabled = false

        for _, lineData in pairs(esp.skeleton) do
            lineData.line.Length = 0
            lineData.line.Visible = false
        end
        return
    end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if not hrp or not humanoid or humanoid.Health <= 0 then
        esp.isDead = true
        esp.box.Adornee = nil
        esp.billboard.Adornee = nil
        esp.text.Visible = false
        esp.tracer.Enabled = false

        for _, lineData in pairs(esp.skeleton) do
            lineData.line.Length = 0
            lineData.line.Visible = false
        end
        return
    end

    local isEnemyChar = isEnemy(character)
    local isTeammateChar = isTeammate(character)

    local espColor = Color3.fromRGB(255, 255, 255)
    if isEnemyChar then
        espColor = Settings.EnemyColor
    elseif isTeammateChar then
        espColor = Settings.TeamColor
    end

    local shouldShowBox = Settings.BoxESPEnabled
    if Settings.TeamCheck and Settings.BoxESPEnabled then
        shouldShowBox = isEnemyChar
    end

    if shouldShowBox then
        esp.box.Adornee = hrp
        esp.box.Color3 = espColor
    else
        esp.box.Adornee = nil
    end

    local shouldShowText = Settings.ShowName or Settings.ShowDistance
    if Settings.TeamCheck then
        shouldShowText = shouldShowText and isEnemyChar
    end

    if shouldShowText then
        esp.billboard.Adornee = hrp
        esp.text.TextSize = Settings.TextSize

        local textParts = {}

        if Settings.ShowName then
            table.insert(textParts, tostring(character.Name))
        end

        if Settings.ShowDistance then
            local myChar = LocalPlayer.Character
            if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                local dist = (myChar.HumanoidRootPart.Position - hrp.Position).Magnitude
                table.insert(textParts, tostring(math.floor(dist)) .. " studs")
            end
        end

        esp.text.Text = table.concat(textParts, " | ")

        if isEnemyChar then
            esp.text.TextColor3 = Settings.ShowName and Settings.EnemyNameColor or Settings.EnemyDistanceColor
        elseif isTeammateChar then
            esp.text.TextColor3 = Settings.ShowName and Settings.TeamNameColor or Settings.TeamDistanceColor
        else
            esp.text.TextColor3 = Color3.fromRGB(255, 255, 255)
        end

        esp.text.Visible = true
    else
        esp.billboard.Adornee = nil
        esp.text.Visible = false
    end

    local shouldShowTracer = Settings.ShowTracer
    if Settings.TeamCheck then
        shouldShowTracer = shouldShowTracer and isEnemyChar
    end

    if shouldShowTracer then
        local myChar = LocalPlayer.Character
        if myChar and myChar:FindFirstChild("HumanoidRootPart") then
            local myHRP = myChar.HumanoidRootPart
            local bottomOffset = Vector3.new(0, -2.5, 0)
            esp.tracerStart.WorldPosition = myHRP.Position + bottomOffset
            esp.tracerEnd.WorldPosition = hrp.Position
            esp.tracer.Color = ColorSequence.new(Settings.TracerColor)
            esp.tracer.Width0 = Settings.TracerThickness
            esp.tracer.Width1 = Settings.TracerThickness
            esp.tracer.Enabled = true
        else
            esp.tracer.Enabled = false
        end
    else
        esp.tracer.Enabled = false
    end

    local shouldShowSkeleton = Settings.SkeletonESPEnabled
    if Settings.TeamCheck then
        shouldShowSkeleton = shouldShowSkeleton and isEnemyChar
    end

    if shouldShowSkeleton then
        updateSkeleton(character, esp.skeleton, espColor)
    else
        for _, lineData in pairs(esp.skeleton) do
            lineData.line.Length = 0
            lineData.line.Visible = false
        end
    end
end

-- ============================================================
-- WORKSPACE SCANNING
-- ============================================================

local function scanWorkspace()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and isCharacter(obj) and not isLocalPlayer(obj) then
            if not scannedCharacters[obj] then
                scannedCharacters[obj] = true
            end

            if not characterESP[obj] then
                enemyCache[obj] = nil
                teammateCache[obj] = nil

                characterESP[obj] = createESP()

                pcall(function()
                    updateESPVisibility(obj, characterESP[obj])

                    if Settings.HitboxExpanderEnabled then
                        applyHitboxExpander(obj)
                    end
                end)

                task.delay(0.5, function()
                    if characterESP[obj] then
                        enemyCache[obj] = nil
                        teammateCache[obj] = nil
                        pcall(function()
                            updateESPVisibility(obj, characterESP[obj])
                        end)
                    end
                end)
            end
        end
    end

    for char, esp in pairs(characterESP) do
        if not char.Parent then
            if esp.box then esp.box:Destroy() end
            if esp.billboard then esp.billboard:Destroy() end
            if esp.text then esp.text:Destroy() end
            if esp.tracer then esp.tracer:Destroy() end
            if esp.tracerStart then esp.tracerStart:Destroy() end
            if esp.tracerEnd then esp.tracerEnd:Destroy() end
            if esp.chams then esp.chams:Destroy() end

            for _, lineData in pairs(esp.skeleton) do
                if lineData.line then
                    lineData.line:Destroy()
                end
            end

            characterESP[char] = nil
            scannedCharacters[char] = nil
            enemyCache[char] = nil
            teammateCache[char] = nil
        end
    end
end

Workspace.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("Model") then
        if not isCharacter(descendant) then
            return
        end

        if isLocalPlayer(descendant) then
            return
        end

        for i = 1, 5 do
            task.wait(0.3 * i)

            if isCharacter(descendant) and not isLocalPlayer(descendant) then
                if not characterESP[descendant] then
                    enemyCache[descendant] = nil
                    teammateCache[descendant] = nil

                    characterESP[descendant] = createESP()
                    scannedCharacters[descendant] = true

                    if Settings.HitboxExpanderEnabled then
                        applyHitboxExpander(descendant)
                    end

                    task.delay(0.5, function()
                        if characterESP[descendant] then
                            pcall(function()
                                updateESPVisibility(descendant, characterESP[descendant])
                            end)
                        end
                    end)

                    break
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(5) do
        if not ScriptRunning then break end

        local currentTime = tick()
        for char, cache in pairs(enemyCache) do
            if currentTime - cache.time > 5 then
                enemyCache[char] = nil
            end
        end
        for char, cache in pairs(teammateCache) do
            if currentTime - cache.time > 5 then
                teammateCache[char] = nil
            end
        end

        pcall(scanWorkspace)

        for char, esp in pairs(characterESP) do
            if char.Parent then
                pcall(function()
                    updateESPVisibility(char, esp)
                end)
            end
        end
    end
end)

-- CHAMS UPDATE
task.spawn(function()
    while task.wait(2) do
        if not ScriptRunning then break end
        if Settings.ChamsESPEnabled then
            for char, esp in pairs(characterESP) do
                if char.Parent and not esp.isDead then
                    pcall(function()
                        enemyCache[char] = nil
                        teammateCache[char] = nil

                        local isEnemyChar = isEnemy(char)
                        local isTeammateChar = isTeammate(char)

                        local chamsColor
                        if isEnemyChar then
                            chamsColor = Settings.EnemyChamsColor or Color3.fromRGB(255, 100, 255)
                        elseif isTeammateChar then
                            chamsColor = Settings.TeamChamsColor or Color3.fromRGB(100, 255, 100)
                        else
                            chamsColor = Color3.fromRGB(255, 255, 255)
                        end

                        local shouldShowChams = Settings.ChamsESPEnabled
                        if Settings.TeamCheck then
                            shouldShowChams = shouldShowChams and isEnemyChar
                        end

                        if shouldShowChams then
                            esp.chams.Adornee = char
                            esp.chams.FillColor = chamsColor
                            esp.chams.OutlineColor = chamsColor
                            esp.chams.Enabled = true
                        elseif isTeammateChar and not Settings.TeamCheck then
                            esp.chams.Adornee = char
                            esp.chams.FillColor = chamsColor
                            esp.chams.OutlineColor = chamsColor
                            esp.chams.Enabled = true
                        else
                            esp.chams.Adornee = nil
                            esp.chams.Enabled = false
                        end
                    end)
                end
            end
        else
            for char, esp in pairs(characterESP) do
                if esp.chams then
                    pcall(function()
                        esp.chams.Adornee = nil
                        esp.chams.Enabled = false
                    end)
                end
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if not ScriptRunning then return end

    for char, esp in pairs(characterESP) do
        if char.Parent then
            pcall(function()
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                updateESPVisibility(char, esp)
            end)
        end
    end
end)

-- ============================================================
-- AUTO SHOOT
-- ============================================================

local isAutoShooting = false

local function startAutoShoot()
    if isAutoShooting then return end
    isAutoShooting = true
    
    task.spawn(function()
        while isAutoShooting and Settings.AutoShoot do
            mouse1click()
            task.wait(0.01)
        end
        isAutoShooting = false
    end)
end

local function stopAutoShoot()
    isAutoShooting = false
end

-- ============================================================
-- AIMBOT
-- ============================================================

local Camera = Workspace.CurrentCamera

local AimbotFOVCircle = Drawing.new("Circle")
AimbotFOVCircle.Thickness = 2
AimbotFOVCircle.NumSides = 64
AimbotFOVCircle.Radius = Settings.AimbotFOVRadius
AimbotFOVCircle.Filled = false
AimbotFOVCircle.Visible = false
AimbotFOVCircle.Color = Color3.fromRGB(255, 255, 255)
AimbotFOVCircle.Transparency = 1

local rightMouseDown = false
local currentAimTarget = nil

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        rightMouseDown = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        rightMouseDown = false
        currentAimTarget = nil
    end
end)

local function getTargetPart(character)
    local targetPart = Settings.AimbotTargetPart

    if targetPart == "Head" then
        return character:FindFirstChild("Head")
    elseif targetPart == "Torso" then
        return character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    elseif targetPart == "RootPart" then
        return character:FindFirstChild("HumanoidRootPart")
    end

    return character:FindFirstChild("HumanoidRootPart")
end

local function getScreenPosition(part)
    local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
    return Vector2.new(pos.X, pos.Y), onScreen
end

local function getDistanceFromCenter(screenPos)
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    return (screenPos - screenCenter).Magnitude
end

local function isInFOV(screenPos)
    local distance = getDistanceFromCenter(screenPos)
    
    if Settings.AimbotFOVRadius >= 180 then
        return true
    end
    
    return distance <= Settings.AimbotFOVRadius
end

local function isVisible(targetPart)
    if not Settings.AimbotWallCheck then return true end

    local myChar = LocalPlayer.Character
    if not myChar then return false end

    local myHead = myChar:FindFirstChild("Head")
    if not myHead then return false end

    local origin = myHead.Position
    local direction = (targetPart.Position - origin)

    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {myChar}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

    local result = Workspace:Raycast(origin, direction, raycastParams)

    if result then
        if result.Instance == targetPart then
            return true
        end
        
        if result.Instance.Parent == targetPart.Parent then
            return true
        end
        
        if result.Instance:IsDescendantOf(targetPart.Parent) then
            return true
        end
        
        return false
    end

    return true
end

local function isTargetValid(character)
    if not character or not character.Parent then return false end
    
    local esp = characterESP[character]
    if esp and esp.isDead then return false end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    
    if Settings.AimbotTeamCheck and not isEnemy(character) then
        return false
    end
    
    local targetPart = getTargetPart(character)
    if not targetPart then return false end
    
    local screenPos, onScreen = getScreenPosition(targetPart)
    if not onScreen then return false end
    
    local myChar = LocalPlayer.Character
    if myChar and myChar:FindFirstChild("HumanoidRootPart") then
        local distance = (myChar.HumanoidRootPart.Position - targetPart.Position).Magnitude
        
        if distance > 10 then
            if not isInFOV(screenPos) then return false end
        end
    else
        if not isInFOV(screenPos) then return false end
    end
    
    if not isVisible(targetPart) then return false end
    
    return true
end

local function getClosestEnemy()
    if not Settings.AimbotEnabled then return nil end
    if not Settings.AutoAim and not rightMouseDown then return nil end

    if currentAimTarget and isTargetValid(currentAimTarget) then
        return currentAimTarget
    end

    local closestTarget = nil
    local closestDistance = math.huge

    for char, esp in pairs(characterESP) do
        if char.Parent and not esp.isDead then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                if Settings.AimbotTeamCheck and not isEnemy(char) then
                    continue
                end

                local targetPart = getTargetPart(char)
                if targetPart then
                    if not isVisible(targetPart) then
                        continue
                    end

                    local screenPos, onScreen = getScreenPosition(targetPart)

                    if onScreen then
                        if not isInFOV(screenPos) then
                            continue
                        end
                        
                        local distance = getDistanceFromCenter(screenPos)

                        if distance < closestDistance then
                            closestDistance = distance
                            closestTarget = char
                        end
                    end
                end
            end
        end
    end

    return closestTarget
end

local function snapAim(targetPosition)
    local cameraCFrame = Camera.CFrame
    local lookVector = (targetPosition - cameraCFrame.Position).Unit
    
    Camera.CFrame = CFrame.new(cameraCFrame.Position, cameraCFrame.Position + lookVector)
end

RunService.RenderStepped:Connect(function()
    if not ScriptRunning then return end

    if Settings.AimbotFOVCircle and Settings.AimbotEnabled then
        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        AimbotFOVCircle.Position = screenCenter
        AimbotFOVCircle.Radius = Settings.AimbotFOVRadius
        AimbotFOVCircle.Visible = true
    else
        AimbotFOVCircle.Visible = false
    end

    if not Settings.AimbotEnabled then 
        currentAimTarget = nil
        stopAutoShoot()
        return 
    end
    
    if not Settings.AutoAim and not rightMouseDown then 
        currentAimTarget = nil
        stopAutoShoot()
        return 
    end

    local previousTarget = currentAimTarget
    currentAimTarget = getClosestEnemy()

    if currentAimTarget then
        local targetPart = getTargetPart(currentAimTarget)
        
        if targetPart then
            snapAim(targetPart.Position)
            
            if Settings.AutoShoot then
                if previousTarget == currentAimTarget or not previousTarget then
                    if not isAutoShooting then
                        startAutoShoot()
                    end
                else
                    stopAutoShoot()
                    task.delay(0.05, function()
                        if currentAimTarget and Settings.AutoShoot then
                            startAutoShoot()
                        end
                    end)
                end
            else
                stopAutoShoot()
            end
        else
            stopAutoShoot()
        end
    else
        stopAutoShoot()
    end
end)

-- ============================================================
-- TRIGGERBOT
-- ============================================================

local lastShotTime = 0

local function isMouseOnEnemy()
    if not Settings.TriggerBotEnabled then return false end
    
    local mouse = LocalPlayer:GetMouse()
    local target = mouse.Target
    
    if not target then return false end
    
    local character = target.Parent
    if not character or not character:IsA("Model") then
        character = target.Parent and target.Parent.Parent
    end
    
    if not character or not isCharacter(character) then return false end
    if isLocalPlayer(character) then return false end
    
    if Settings.TriggerBotTeamCheck then
        if not isEnemy(character) then
            return false
        end
    else
        if isTeammate(character) then
            return false
        end
    end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    
    return true
end

local function shootGun()
    local currentTime = tick()
    if currentTime - lastShotTime < Settings.TriggerBotDelay then
        return
    end
    
    lastShotTime = currentTime
    
    mouse1press()
    task.wait(0.05)
    mouse1release()
end

RunService.RenderStepped:Connect(function()
    if not ScriptRunning then return end
    if not Settings.TriggerBotEnabled then return end
    
    if isMouseOnEnemy() then
        pcall(shootGun)
    end
end)

-- ============================================================
-- CLEANUP
-- ============================================================

local function cleanupScript()
    ScriptRunning = false
    
    Settings.BoxESPEnabled = false
    Settings.SkeletonESPEnabled = false
    Settings.ChamsESPEnabled = false
    Settings.ShowName = false
    Settings.ShowDistance = false
    Settings.ShowTracer = false
    Settings.AimbotEnabled = false
    Settings.AutoAim = false
    Settings.HitboxExpanderEnabled = false
    Settings.TriggerBotEnabled = false
    Settings.AutoShoot = false
    stopAutoShoot()

    for char, esp in pairs(characterESP) do
        if char.Parent then
            pcall(function()
                resetHitbox(char)
            end)
        end
    end

    for char, esp in pairs(characterESP) do
        if esp.box then esp.box:Destroy() end
        if esp.billboard then esp.billboard:Destroy() end
        if esp.text then esp.text:Destroy() end
        if esp.tracer then esp.tracer:Destroy() end
        if esp.tracerStart then esp.tracerStart:Destroy() end
        if esp.tracerEnd then esp.tracerEnd:Destroy() end
        if esp.chams then esp.chams:Destroy() end

        for _, lineData in pairs(esp.skeleton) do
            if lineData.line then
                lineData.line:Destroy()
            end
        end
    end

    if AimbotFOVCircle then
        AimbotFOVCircle:Remove()
    end

    if ESPFolder then
        ESPFolder:Destroy()
    end

    characterESP = {}
    scannedCharacters = {}
    enemyCache = {}
    teammateCache = {}
end

-- ============================================================
-- GUI CREATION
-- ============================================================

local CloverUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Lynccc786/Lua-Script/refs/heads/main/ui/custom-ui.lua"))()

local window = CloverUI:Create({
    Title = "Fate Trigger - Clover Hub 🍀",
    DiscordInvite = "https://discord.com/invite/JRBUZhTZ6E",
    ToggleKey = Enum.KeyCode.RightControl
})

-- ===================== TAB ESP =====================
local tabESP = window:AddTab("ESP")

-- Kolom kiri: ESP utama
local groupESPMain = tabESP:AddGroup("Main ESP", "left")

groupESPMain:AddToggle("Outline Box", {
    Default = Settings.BoxESPEnabled, 
    Callback = function(val)
        Settings.BoxESPEnabled = val
        for char, esp in pairs(characterESP) do
            if char.Parent then
                pcall(function() updateESPVisibility(char, esp) end)
            end
        end
    end
})

groupESPMain:AddToggle("Bone Overlay", {
    Default = Settings.SkeletonESPEnabled, 
    Callback = function(val)
        Settings.SkeletonESPEnabled = val
        for char, esp in pairs(characterESP) do
            if char.Parent then
                pcall(function() updateESPVisibility(char, esp) end)
            end
        end
    end
})

groupESPMain:AddToggle("Enemy Only", {
    Default = Settings.TeamCheck, 
    Callback = function(val)
        Settings.TeamCheck = val
        for char, esp in pairs(characterESP) do
            if char.Parent then
                pcall(function() updateESPVisibility(char, esp) end)
            end
        end
    end
})

groupESPMain:AddToggle("Show Range", {
    Default = Settings.ShowDistance, 
    Callback = function(val)
        Settings.ShowDistance = val
        for char, esp in pairs(characterESP) do
            if char.Parent then
                pcall(function() updateESPVisibility(char, esp) end)
            end
        end
    end
})

groupESPMain:AddToggle("Show Username", {
    Default = Settings.ShowName, 
    Callback = function(val)
        Settings.ShowName = val
        for char, esp in pairs(characterESP) do
            if char.Parent then
                pcall(function() updateESPVisibility(char, esp) end)
            end
        end
    end
})

groupESPMain:AddToggle("Draw Tracer Line", {
    Default = Settings.ShowTracer, 
    Callback = function(val)
        Settings.ShowTracer = val
        for char, esp in pairs(characterESP) do
            if char.Parent then
                pcall(function() updateESPVisibility(char, esp) end)
            end
        end
    end
})

groupESPMain:AddToggle("Glow Overlay", {
    Default = Settings.ChamsESPEnabled, 
    Callback = function(val)
        Settings.ChamsESPEnabled = val
    end
})

-- Kolom kanan: Warna, style, chams
local groupESPColor = tabESP:AddGroup("ESP Style", "right")

groupESPColor:AddColorPicker("Hostile Color", {
    Default = Settings.EnemyColor, 
    Callback = function(val)
        Settings.EnemyColor = val
        for char, esp in pairs(characterESP) do
            if char.Parent then
                pcall(function() updateESPVisibility(char, esp) end)
            end
        end
    end
})

groupESPColor:AddColorPicker("Ally Color", {
    Default = Settings.TeamColor, 
    Callback = function(val)
        Settings.TeamColor = val
        for char, esp in pairs(characterESP) do
            if char.Parent then
                pcall(function() updateESPVisibility(char, esp) end)
            end
        end
    end
})

groupESPColor:AddSlider("Line Thickness", {
    Min = 0.1, 
    Max = 5, 
    Default = Settings.TracerThickness, 
    Callback = function(val)
        Settings.TracerThickness = val
        for char, esp in pairs(characterESP) do
            if char.Parent then
                pcall(function() updateESPVisibility(char, esp) end)
            end
        end
    end
})

groupESPColor:AddSlider("Bone Thickness", {
    Min = 1, 
    Max = 10, 
    Default = Settings.SkeletonThickness, 
    Callback = function(val)
        Settings.SkeletonThickness = val
        for char, esp in pairs(characterESP) do
            if char.Parent then
                pcall(function() updateESPVisibility(char, esp) end)
            end
        end
    end
})

groupESPColor:AddSlider("Label Size", {
    Min = 10, 
    Max = 30, 
    Default = Settings.TextSize, 
    Callback = function(val)
        Settings.TextSize = val
        for char, esp in pairs(characterESP) do
            if char.Parent then
                pcall(function() updateESPVisibility(char, esp) end)
            end
        end
    end
})

groupESPColor:AddColorPicker("Glow Hostile Color", {
    Default = Settings.EnemyChamsColor, 
    Callback = function(val)
        Settings.EnemyChamsColor = val
    end
})

groupESPColor:AddColorPicker("Glow Ally Color", {
    Default = Settings.TeamChamsColor, 
    Callback = function(val)
        Settings.TeamChamsColor = val
    end
})

-- ===================== TAB AIMBOT =====================
local tabAimbot = window:AddTab("Aimbot")

-- Kolom kiri: Aim
local groupAim = tabAimbot:AddGroup("Aim", "left")

groupAim:AddToggle("Enable Aimbot", {
    Default = Settings.AimbotEnabled, 
    Callback = function(val)
        Settings.AimbotEnabled = val
    end
})

groupAim:AddToggle("Auto Aim", {
    Default = Settings.AutoAim, 
    Callback = function(val)
        Settings.AutoAim = val
    end
})

groupAim:AddToggle("Auto Shot", {
    Default = Settings.AutoShoot, 
    Callback = function(val)
        Settings.AutoShoot = val
        if not val then
            stopAutoShoot()
        end
    end
})

-- Kolom kiri: FOV
local groupFov = tabAimbot:AddGroup("FOV", "left")

groupFov:AddToggle("FOV Circle", {
    Default = Settings.AimbotFOVCircle, 
    Callback = function(val)
        Settings.AimbotFOVCircle = val
    end
})

groupFov:AddSlider("FOV Radius", {
    Min = 10, 
    Max = 300, 
    Default = Settings.AimbotFOVRadius, 
    Callback = function(val)
        Settings.AimbotFOVRadius = val
    end
})

groupFov:AddDropdown("Target Part", {
    Values = {"Head", "Torso", "RootPart"}, 
    Default = Settings.AimbotTargetPart, 
    Callback = function(val)
        Settings.AimbotTargetPart = val
    end
})

groupFov:AddToggle("Team Check", {
    Default = Settings.AimbotTeamCheck, 
    Callback = function(val)
        Settings.AimbotTeamCheck = val
    end
})

groupFov:AddToggle("Wall Check", {
    Default = Settings.AimbotWallCheck, 
    Callback = function(val)
        Settings.AimbotWallCheck = val
    end
})

-- Kolom kanan: Utility
local groupUtility = tabAimbot:AddGroup("Utility", "right")
groupUtility:AddToggle("Hitbox Booster", {
    Default = Settings.HitboxExpanderEnabled, 
    Callback = function(val)
        Settings.HitboxExpanderEnabled = val
        if val then
            for char, esp in pairs(characterESP) do
                if char.Parent and not esp.isDead then
                    pcall(function() applyHitboxExpander(char) end)
                end
            end
        else
            for char, esp in pairs(characterESP) do
                if char.Parent then
                    pcall(function() resetHitbox(char) end)
                end
            end
        end
    end
})

groupUtility:AddSlider("Booster Size", {
    Min = 5, 
    Max = 30, 
    Default = Settings.HitboxSize, 
    Callback = function(val)
        Settings.HitboxSize = val
        if Settings.HitboxExpanderEnabled then
            for char, esp in pairs(characterESP) do
                if char.Parent and not esp.isDead then
                    pcall(function() applyHitboxExpander(char) end)
                end
            end
        end
    end
})

groupUtility:AddColorPicker("Booster Color", {
    Default = Settings.HitboxColor,
    Callback = function(val)
        Settings.HitboxColor = val
        if Settings.HitboxExpanderEnabled then
            for char, esp in pairs(characterESP) do
                if char.Parent and not esp.isDead then
                    pcall(function() applyHitboxExpander(char) end)
                end
            end
        end
    end
})

groupUtility:AddSlider("Booster Transparency", {
    Min = 0,
    Max = 1,
    Default = Settings.HitboxTransparency,
    Callback = function(val)
        Settings.HitboxTransparency = val
        if Settings.HitboxExpanderEnabled then
            for char, esp in pairs(characterESP) do
                if char.Parent and not esp.isDead then
                    pcall(function() applyHitboxExpander(char) end)
                end
            end
        end
    end
})

groupUtility:AddToggle("Enable Trigger Bot", {
    Default = Settings.TriggerBotEnabled, 
    Callback = function(val)
        Settings.TriggerBotEnabled = val
    end
})

groupUtility:AddSlider("Trigger Delay", {
    Min = 0, 
    Max = 1, 
    Default = Settings.TriggerBotDelay, 
    Callback = function(val)
        Settings.TriggerBotDelay = val
    end
})

groupUtility:AddToggle("Team Check", {
    Default = Settings.TriggerBotTeamCheck, 
    Callback = function(val)
        Settings.TriggerBotTeamCheck = val
    end
})

-- =============================
-- Setting Tab Section (setelah ESP & Aimbot)
local tabSetting = window:AddTab("Setting")
local groupKeybind = tabSetting:AddGroup("Keybind", "left")

groupKeybind:AddKeybind("Minimize/Toggle GUI", {
    Default = Enum.KeyCode.RightControl,
    Callback = function(val)
        Settings.MinimizeKey = val
        window:SetToggleKey(val)
    end
})
local groupUtility = tabAimbot:AddGroup("Utility", "right")


print("✅ Fate Trigger - Full Functional GUI Loaded!")
print("🎮 Press Right Control to toggle GUI")
print("🔫 Features: ESP, Aimbot, Hitbox Expander, Trigger Bot")