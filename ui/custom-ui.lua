--[[
    CLOVER-HUB UI LIBRARY (MODERN REMASTERED)
    Style: Modern Flat, Dark Grey & Neon Green
    Features: Universal, Mobile Support, Smooth Animations
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- [CONSTANTS] Modern Palette
local COLORS = {
    MainBg = Color3.fromRGB(25, 25, 30),         -- Background Utama Gelap
    Sidebar = Color3.fromRGB(30, 30, 35),        -- Sidebar sedikit lebih terang
    ElementBg = Color3.fromRGB(40, 40, 45),      -- Background item (tombol/input)
    
    Accent = Color3.fromRGB(0, 255, 160),        -- Neon Green Modern
    AccentDim = Color3.fromRGB(0, 180, 110),     -- Versi gelap accent
    
    Text = Color3.fromRGB(240, 240, 240),        -- Putih bersih
    TextDim = Color3.fromRGB(150, 150, 160),     -- Teks abu-abu
    
    Separator = Color3.fromRGB(50, 50, 55),      -- Garis pemisah halus
}

local Library = {}
Library.__index = Library

-- [HELPER] Tween
local function Tween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

-- [HELPER] Rounded Corner
local function AddCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 6)
    c.Parent = parent
    return c
end

-- [HELPER] Dragging
local function MakeDraggable(frame, dragHandle)
    local dragging, dragInput, dragStart, startPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Tween(frame, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.05)
        end
    end)
end

-- [MAIN] Create Window
function Library:Create(config)
    local self = setmetatable({}, Library)
    self.Tabs = {}
    
    -- Cleanup Old UI
    if CoreGui:FindFirstChild("CloverHubModern") then CoreGui.CloverHubModern:Destroy() end

    -- ScreenGui
    local gui = Instance.new("ScreenGui")
    gui.Name = "CloverHubModern"
    gui.IgnoreGuiInset = true
    if RunService:IsStudio() then gui.Parent = LocalPlayer.PlayerGui else gui.Parent = CoreGui end
    self.Gui = gui

    -- Main Shadow (Glow Effect)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.Size = UDim2.new(0, 620, 0, 420)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.Parent = gui

    -- Main Frame
    local main = Instance.new("Frame")
    main.Name = "MainFrame"
    main.Size = UDim2.new(0, 600, 0, 400)
    main.Position = UDim2.new(0.5, 0, 0.5, 0) -- Centered inside shadow
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = COLORS.MainBg
    main.BorderSizePixel = 0
    main.Parent = shadow
    AddCorner(main, 10)
    
    MakeDraggable(shadow, main) -- Drag using main frame

    -- Sidebar Area
    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 180, 1, 0)
    sidebar.BackgroundColor3 = COLORS.Sidebar
    sidebar.BorderSizePixel = 0
    sidebar.Parent = main
    AddCorner(sidebar, 10)
    
    -- Fix Sidebar Corner (Squaring off the right side so it blends)
    local sideFix = Instance.new("Frame")
    sideFix.Size = UDim2.new(0, 10, 1, 0)
    sideFix.Position = UDim2.new(1, -10, 0, 0)
    sideFix.BackgroundColor3 = COLORS.Sidebar
    sideFix.BorderSizePixel = 0
    sideFix.Parent = sidebar

    -- Separator Line
    local sep = Instance.new("Frame")
    sep.Size = UDim2.new(0, 1, 1, 0)
    sep.Position = UDim2.new(1, 0, 0, 0)
    sep.BackgroundColor3 = COLORS.Separator
    sep.BorderSizePixel = 0
    sep.Parent = sidebar

    -- [PROFILE SECTION]
    local profile = Instance.new("Frame")
    profile.Size = UDim2.new(1, 0, 0, 80)
    profile.BackgroundTransparency = 1
    profile.Parent = sidebar

    local avatar = Instance.new("ImageLabel")
    avatar.Size = UDim2.new(0, 45, 0, 45)
    avatar.Position = UDim2.new(0, 15, 0, 20)
    avatar.BackgroundTransparency = 1
    avatar.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    avatar.Parent = profile
    AddCorner(avatar, 25) -- Circle
    
    -- Status Dot
    local status = Instance.new("Frame")
    status.Size = UDim2.new(0, 12, 0, 12)
    status.Position = UDim2.new(1, -12, 1, -12)
    status.BackgroundColor3 = COLORS.Accent
    status.BorderSizePixel = 0
    status.Parent = avatar
    AddCorner(status, 6)
    local statusStroke = Instance.new("UIStroke")
    statusStroke.Color = COLORS.Sidebar
    statusStroke.Thickness = 2
    statusStroke.Parent = status

    local welcome = Instance.new("TextLabel")
    welcome.Size = UDim2.new(0, 100, 0, 20)
    welcome.Position = UDim2.new(0, 70, 0, 22)
    welcome.BackgroundTransparency = 1
    welcome.Text = "Welcome,"
    welcome.TextColor3 = COLORS.TextDim
    welcome.Font = Enum.Font.Gotham
    welcome.TextSize = 12
    welcome.TextXAlignment = Enum.TextXAlignment.Left
    welcome.Parent = profile

    local username = Instance.new("TextLabel")
    username.Size = UDim2.new(0, 100, 0, 20)
    username.Position = UDim2.new(0, 70, 0, 40)
    username.BackgroundTransparency = 1
    username.Text = LocalPlayer.DisplayName
    username.TextColor3 = COLORS.Text
    username.Font = Enum.Font.GothamBold
    username.TextSize = 14
    username.TextXAlignment = Enum.TextXAlignment.Left
    username.Parent = profile

    -- Tab Container
    local tabContainer = Instance.new("ScrollingFrame")
    tabContainer.Size = UDim2.new(1, 0, 1, -90)
    tabContainer.Position = UDim2.new(0, 0, 0, 90)
    tabContainer.BackgroundTransparency = 1
    tabContainer.ScrollBarThickness = 2
    tabContainer.Parent = sidebar
    self.TabContainer = tabContainer

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabLayout.Parent = tabContainer

    -- Content Area
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -180, 1, -50)
    content.Position = UDim2.new(0, 180, 0, 50)
    content.BackgroundTransparency = 1
    content.Parent = main
    self.ContentContainer = content

    -- Top Header (Title)
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, -180, 0, 50)
    header.Position = UDim2.new(0, 180, 0, 0)
    header.BackgroundTransparency = 1
    header.Parent = main

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -50, 1, 0)
    titleLbl.Position = UDim2.new(0, 20, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = config.Title or "Clover Hub"
    titleLbl.TextColor3 = COLORS.Text
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 18
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = header

    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -40, 0.5, -15)
    closeBtn.BackgroundColor3 = COLORS.ElementBg
    closeBtn.Text = "X"
    closeBtn.TextColor3 = COLORS.Text
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = header
    AddCorner(closeBtn, 6)

    closeBtn.MouseEnter:Connect(function() Tween(closeBtn, {BackgroundColor3 = Color3.fromRGB(200, 60, 60)}) end)
    closeBtn.MouseLeave:Connect(function() Tween(closeBtn, {BackgroundColor3 = COLORS.ElementBg}) end)
    closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

    -- Opening Animation
    main.Position = UDim2.new(0.5, 0, 0.6, 0)
    main.BackgroundTransparency = 1
    Tween(main, {Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundTransparency = 0}, 0.5)

    return self
end

-- [TAB SYSTEM]
function Library:AddTab(name)
    local tab = {}
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.85, 0, 0, 36)
    btn.BackgroundColor3 = COLORS.Sidebar
    btn.BackgroundTransparency = 1
    btn.Text = "      " .. name
    btn.TextColor3 = COLORS.TextDim
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = self.TabContainer
    AddCorner(btn, 8)
    
    -- Active Indicator (Garis di kiri)
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 3, 0.6, 0)
    indicator.Position = UDim2.new(0, 0, 0.2, 0)
    indicator.BackgroundColor3 = COLORS.Accent
    indicator.BackgroundTransparency = 1 -- Hidden by default
    indicator.Parent = btn
    AddCorner(indicator, 2)

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.ScrollBarThickness = 2
    page.Parent = self.ContentContainer
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Parent = page
    
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 10)
    pad.PaddingBottom = UDim.new(0, 10)
    pad.Parent = page
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Tab Logic
    local function Activate()
        for _, t in pairs(self.Tabs) do
            t.Page.Visible = false
            Tween(t.Btn, {BackgroundColor3 = COLORS.Sidebar})
            Tween(t.Btn, {TextColor3 = COLORS.TextDim})
            Tween(t.Ind, {BackgroundTransparency = 1})
        end
        page.Visible = true
        Tween(btn, {BackgroundColor3 = COLORS.ElementBg})
        Tween(btn, {TextColor3 = COLORS.Accent})
        Tween(indicator, {BackgroundTransparency = 0})
    end

    btn.MouseButton1Click:Connect(Activate)
    if #self.Tabs == 0 then Activate() end -- Auto select first

    tab.Btn = btn
    tab.Ind = indicator
    tab.Page = page

    -- [COMPONENTS]
    
    function tab:AddLabel(text)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.95, 0, 0, 30)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = COLORS.Text
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 14
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = page
        return lbl
    end

    function tab:AddButton(text, callback)
        callback = callback or function() end
        local btnFrame = Instance.new("TextButton")
        btnFrame.Size = UDim2.new(0.95, 0, 0, 40)
        btnFrame.BackgroundColor3 = COLORS.ElementBg
        btnFrame.Text = text
        btnFrame.TextColor3 = COLORS.Text
        btnFrame.Font = Enum.Font.GothamMedium
        btnFrame.TextSize = 13
        btnFrame.Parent = page
        AddCorner(btnFrame, 8)
        
        btnFrame.MouseEnter:Connect(function() Tween(btnFrame, {BackgroundColor3 = Color3.fromRGB(50, 50, 55)}) end)
        btnFrame.MouseLeave:Connect(function() Tween(btnFrame, {BackgroundColor3 = COLORS.ElementBg}) end)
        btnFrame.MouseButton1Click:Connect(function()
            Tween(btnFrame, {TextSize = 11}, 0.1)
            wait(0.1)
            Tween(btnFrame, {TextSize = 13}, 0.1)
            pcall(callback)
        end)
    end

    function tab:AddToggle(text, config)
        config = config or {}
        local state = config.Default or false
        local callback = config.Callback or function() end
        
        local frame = Instance.new("TextButton")
        frame.Size = UDim2.new(0.95, 0, 0, 40)
        frame.BackgroundColor3 = COLORS.ElementBg
        frame.Text = ""
        frame.Parent = page
        AddCorner(frame, 8)
        
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.7, 0, 1, 0)
        lbl.Position = UDim2.new(0, 15, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = COLORS.Text
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextSize = 13
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = frame
        
        local toggler = Instance.new("Frame")
        toggler.Size = UDim2.new(0, 44, 0, 22)
        toggler.Position = UDim2.new(1, -55, 0.5, -11)
        toggler.BackgroundColor3 = state and COLORS.Accent or COLORS.Sidebar
        toggler.Parent = frame
        AddCorner(toggler, 12)
        
        local circle = Instance.new("Frame")
        circle.Size = UDim2.new(0, 18, 0, 18)
        circle.Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        circle.BackgroundColor3 = COLORS.Text
        circle.Parent = toggler
        AddCorner(circle, 10)
        
        frame.MouseButton1Click:Connect(function()
            state = not state
            pcall(callback, state)
            local targetPos = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
            local targetColor = state and COLORS.Accent or COLORS.Sidebar
            Tween(circle, {Position = targetPos})
            Tween(toggler, {BackgroundColor3 = targetColor})
        end)
    end

    function tab:AddSlider(text, config)
        local min, max = config.Min or 0, config.Max or 100
        local default = config.Default or min
        local callback = config.Callback or function() end
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0.95, 0, 0, 55)
        frame.BackgroundColor3 = COLORS.ElementBg
        frame.Parent = page
        AddCorner(frame, 8)
        
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -20, 0, 20)
        lbl.Position = UDim2.new(0, 15, 0, 8)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = COLORS.Text
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextSize = 13
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = frame
        
        local valLabel = Instance.new("TextLabel")
        valLabel.Size = UDim2.new(0, 50, 0, 20)
        valLabel.Position = UDim2.new(1, -65, 0, 8)
        valLabel.BackgroundTransparency = 1
        valLabel.Text = tostring(default)
        valLabel.TextColor3 = COLORS.Accent
        valLabel.Font = Enum.Font.GothamBold
        valLabel.TextSize = 13
        valLabel.Parent = frame
        
        local bg = Instance.new("Frame")
        bg.Size = UDim2.new(1, -30, 0, 6)
        bg.Position = UDim2.new(0, 15, 0, 35)
        bg.BackgroundColor3 = COLORS.Sidebar
        bg.Parent = frame
        AddCorner(bg, 4)
        
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
        fill.BackgroundColor3 = COLORS.Accent
        fill.Parent = bg
        AddCorner(fill, 4)
        
        local trigger = Instance.new("TextButton")
        trigger.Size = UDim2.new(1, 0, 1, 0)
        trigger.BackgroundTransparency = 1
        trigger.Text = ""
        trigger.Parent = bg
        
        local dragging = false
        local function update(input)
            local pos = math.clamp((input.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
            Tween(fill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.1)
            local val = math.floor(min + ((max - min) * pos))
            valLabel.Text = tostring(val)
            pcall(callback, val)
        end
        
        trigger.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true; update(input)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                update(input)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
        end)
    end
    
    function tab:AddDropdown(text, config)
        config = config or {}
        local options = config.Values or {}
        local default = config.Default or "Select..."
        local callback = config.Callback or function() end
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0.95, 0, 0, 40)
        frame.BackgroundColor3 = COLORS.ElementBg
        frame.Parent = page
        frame.ClipsDescendants = true
        AddCorner(frame, 8)
        
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.5, 0, 0, 40)
        lbl.Position = UDim2.new(0, 15, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = COLORS.Text
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextSize = 13
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = frame
        
        local sel = Instance.new("TextLabel")
        sel.Size = UDim2.new(0.5, -50, 0, 40)
        sel.Position = UDim2.new(0.5, 0, 0, 0)
        sel.BackgroundTransparency = 1
        sel.Text = default
        sel.TextColor3 = COLORS.Accent
        sel.Font = Enum.Font.GothamBold
        sel.TextSize = 13
        sel.TextXAlignment = Enum.TextXAlignment.Right
        sel.Parent = frame
        
        local arrow = Instance.new("TextLabel")
        arrow.Size = UDim2.new(0, 30, 0, 40)
        arrow.Position = UDim2.new(1, -30, 0, 0)
        arrow.BackgroundTransparency = 1
        arrow.Text = ">"
        arrow.TextColor3 = COLORS.TextDim
        arrow.Font = Enum.Font.GothamBold
        arrow.TextSize = 14
        arrow.Parent = frame
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 40)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.Parent = frame
        
        local holder = Instance.new("Frame")
        holder.Size = UDim2.new(1, -10, 0, 0)
        holder.Position = UDim2.new(0, 5, 0, 40)
        holder.BackgroundTransparency = 1
        holder.Parent = frame
        
        local list = Instance.new("UIListLayout")
        list.Padding = UDim.new(0, 2)
        list.Parent = holder
        
        for _, opt in ipairs(options) do
            local oBtn = Instance.new("TextButton")
            oBtn.Size = UDim2.new(1, 0, 0, 30)
            oBtn.BackgroundColor3 = COLORS.Sidebar
            oBtn.Text = opt
            oBtn.TextColor3 = COLORS.Text
            oBtn.Font = Enum.Font.Gotham
            oBtn.TextSize = 12
            oBtn.Parent = holder
            AddCorner(oBtn, 6)
            
            oBtn.MouseButton1Click:Connect(function()
                sel.Text = opt
                pcall(callback, opt)
                Tween(frame, {Size = UDim2.new(0.95, 0, 0, 40)})
                Tween(arrow, {Rotation = 0})
            end)
        end
        
        local open = false
        btn.MouseButton1Click:Connect(function()
            open = not open
            local h = open and (40 + (#options * 32) + 5) or 40
            Tween(frame, {Size = UDim2.new(0.95, 0, 0, h)})
            Tween(arrow, {Rotation = open and 90 or 0})
        end)
    end
    
    function tab:AddColorPicker(text, config)
        -- Simplified version of Color Picker for modern look
        local default = config.Default or Color3.new(1,1,1)
        local callback = config.Callback or function() end
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0.95, 0, 0, 40)
        frame.BackgroundColor3 = COLORS.ElementBg
        frame.Parent = page
        AddCorner(frame, 8)
        
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.6, 0, 1, 0)
        lbl.Position = UDim2.new(0, 15, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = COLORS.Text
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextSize = 13
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = frame
        
        local preview = Instance.new("Frame")
        preview.Size = UDim2.new(0, 50, 0, 24)
        preview.Position = UDim2.new(1, -60, 0.5, -12)
        preview.BackgroundColor3 = default
        preview.Parent = frame
        AddCorner(preview, 6)
        
        -- Placeholder for full color picker logic (kept simple for aesthetics)
        -- In full version, this would expand similarly to dropdown
    end

    function tab:AddGroup(title)
        tab:AddLabel("   " .. title:upper()) -- Indent slightly for group header
        return tab
    end

    table.insert(self.Tabs, tab)
    return tab
end

return Library
