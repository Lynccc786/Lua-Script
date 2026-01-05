--[[
    CLOVER-HUB UI LIBRARY (FIXED VERSION)
    Theme: Dark Green Transparent
    Features: Sidebar with Profile Avatar, Auto-Scale Mobile/PC
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- CONSTANTS (CLOVER THEME)
-- ==========================================
local COLORS = {
    Background = Color3.fromRGB(15, 30, 15),     -- Hijau sangat gelap
    SecondaryBg = Color3.fromRGB(20, 40, 20),    -- Panel elemen
    SidebarBg = Color3.fromRGB(18, 35, 18),      -- Warna sidebar sedikit beda
    
    -- Warna Interaksi
    TabSelected = Color3.fromRGB(40, 160, 40),   -- Hijau Clover
    TabHover = Color3.fromRGB(30, 60, 30),
    
    -- [FIX] Mengganti Color3.TRANSPARENT (Error) menjadi warna solid gelap
    -- Transparansi akan diatur lewat property BackgroundTransparency nanti
    TabNormal = Color3.fromRGB(20, 40, 20),      
    
    -- Aksen
    Accent = Color3.fromRGB(60, 220, 60),        -- Neon Green Clover
    AccentHover = Color3.fromRGB(80, 240, 80),
    
    -- Garis & Teks
    Border = Color3.fromRGB(40, 90, 40),
    Text = Color3.fromRGB(220, 255, 220),
    TextSecondary = Color3.fromRGB(140, 180, 140),
    
    Error = Color3.fromRGB(220, 70, 70),
}

local SIZES = {
    TopBarHeight = 35,
    SidebarWidth = 160,    -- Sidebar dikembalikan
    CornerRadius = UDim.new(0, 6),
    SmallCornerRadius = UDim.new(0, 4),
}

local MOBILE_SCALE = 0.8 -- Skala UI untuk HP

-- ==========================================
-- UTILITY FUNCTIONS
-- ==========================================
local function CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or SIZES.CornerRadius
    corner.Parent = parent
    return corner
end

local function CreateStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or COLORS.Border
    stroke.Thickness = thickness or 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

-- ==========================================
-- MAIN LIBRARY
-- ==========================================
local CloverHub = {}
CloverHub.__index = CloverHub

function CloverHub:Create(config)
    local self = setmetatable({}, CloverHub)

    self.Title = config.Title or "Clover-Hub"
    self.Tabs = {}
    self.CurrentTab = nil
    self.IsMinimized = false
    self.IsClosed = false

    self:_CreateUI()
    return self
end

function CloverHub:_CreateUI()
    local GuiContainer = gethui and gethui() or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

    if GuiContainer:FindFirstChild("CloverHubUI") then
        GuiContainer.CloverHubUI:Destroy()
    end

    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "CloverHubUI"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.Parent = GuiContainer

    -- MAIN FRAME
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = UDim2.new(0, 550, 0, 350) -- Ukuran pas (tidak terlalu besar)
    self.MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    self.MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    self.MainFrame.BackgroundColor3 = COLORS.Background
    self.MainFrame.BackgroundTransparency = 0.1 -- Transparan
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Parent = self.ScreenGui
    
    CreateCorner(self.MainFrame, SIZES.CornerRadius)
    CreateStroke(self.MainFrame, COLORS.Accent, 1)

    -- MOBILE SCALE
    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    if isMobile or (_G.CloverDevice == "mobile") then
        local scale = Instance.new("UIScale")
        scale.Scale = MOBILE_SCALE
        scale.Parent = self.MainFrame
        self.MainFrame.Size = UDim2.new(0, 500, 0, 320) -- Sedikit lebih kecil di HP
    end

    -- 1. TOP BAR (Judul & Close Button)
    self:_CreateTopBar()

    -- 2. SIDEBAR (Avatar Profile & Tabs) - MODEL BARU
    self:_CreateSidebar()

    -- 3. CONTENT AREA
    self:_CreateContentArea()

    -- Animasi Opening
    self.MainFrame.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(self.MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
        Size = isMobile and UDim2.new(0, 500, 0, 320) or UDim2.new(0, 550, 0, 350)
    }):Play()
    
    self:_MakeDraggable(self.MainFrame)
end

function CloverHub:_CreateTopBar()
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, -SIZES.SidebarWidth, 0, SIZES.TopBarHeight)
    topBar.Position = UDim2.new(0, SIZES.SidebarWidth, 0, 0) -- Mulai setelah sidebar
    topBar.BackgroundColor3 = COLORS.Background
    topBar.BackgroundTransparency = 1
    topBar.BorderSizePixel = 0
    topBar.Parent = self.MainFrame

    -- Judul Hub
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -80, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = self.Title
    titleLabel.TextColor3 = COLORS.Accent
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = topBar

    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Position = UDim2.new(1, -30, 0.5, -12.5)
    closeBtn.BackgroundColor3 = COLORS.Error
    closeBtn.BackgroundTransparency = 0.2
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = topBar
    CreateCorner(closeBtn, SIZES.SmallCornerRadius)

    closeBtn.MouseButton1Click:Connect(function()
        self.ScreenGui:Destroy()
    end)
    
    -- Minimize Button
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 25, 0, 25)
    minBtn.Position = UDim2.new(1, -60, 0.5, -12.5)
    minBtn.BackgroundColor3 = COLORS.SecondaryBg
    minBtn.Text = "-"
    minBtn.TextColor3 = COLORS.Text
    minBtn.Font = Enum.Font.GothamBold
    minBtn.Parent = topBar
    CreateCorner(minBtn, SIZES.SmallCornerRadius)
    
    minBtn.MouseButton1Click:Connect(function()
        self.MainFrame.Visible = false
        -- Logika restore tombol kecil bisa ditambahkan disini
    end)
end

function CloverHub:_CreateSidebar()
    self.Sidebar = Instance.new("Frame")
    self.Sidebar.Name = "Sidebar"
    self.Sidebar.Size = UDim2.new(0, SIZES.SidebarWidth, 1, 0)
    self.Sidebar.BackgroundColor3 = COLORS.SidebarBg
    self.Sidebar.BackgroundTransparency = 0.1
    self.Sidebar.BorderSizePixel = 0
    self.Sidebar.Parent = self.MainFrame
    
    -- Corner hanya di kiri atas dan kiri bawah
    local corner = CreateCorner(self.Sidebar, SIZES.CornerRadius)
    
    -- Garis pembatas kanan
    local div = Instance.new("Frame")
    div.Size = UDim2.new(0, 1, 1, 0)
    div.Position = UDim2.new(1, -1, 0, 0)
    div.BackgroundColor3 = COLORS.Border
    div.BorderSizePixel = 0
    div.Parent = self.Sidebar

    -- === AVATAR SECTION (MODEL BARU) ===
    local profileFrame = Instance.new("Frame")
    profileFrame.Size = UDim2.new(1, 0, 0, 110)
    profileFrame.BackgroundTransparency = 1
    profileFrame.Parent = self.Sidebar

    -- Avatar Circle (Tengah Sidebar)
    local avatarImg = Instance.new("ImageLabel")
    avatarImg.Size = UDim2.new(0, 60, 0, 60)
    avatarImg.Position = UDim2.new(0.5, -30, 0, 15) -- Tengah
    avatarImg.BackgroundTransparency = 1
    avatarImg.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    avatarImg.Parent = profileFrame
    
    local avCorner = Instance.new("UICorner")
    avCorner.CornerRadius = UDim.new(1, 0) -- Bulat sempurna
    avCorner.Parent = avatarImg
    
    -- Stroke Avatar Hijau
    local avStroke = Instance.new("UIStroke")
    avStroke.Color = COLORS.Accent
    avStroke.Thickness = 1.5
    avStroke.Parent = avatarImg

    -- Username
    local userLbl = Instance.new("TextLabel")
    userLbl.Size = UDim2.new(1, 0, 0, 20)
    userLbl.Position = UDim2.new(0, 0, 0, 80)
    userLbl.BackgroundTransparency = 1
    userLbl.Text = LocalPlayer.DisplayName
    userLbl.TextColor3 = COLORS.Accent
    userLbl.Font = Enum.Font.GothamBold
    userLbl.TextSize = 14
    userLbl.Parent = profileFrame

    -- Garis bawah profil
    local line = Instance.new("Frame")
    line.Size = UDim2.new(0.8, 0, 0, 1)
    line.Position = UDim2.new(0.1, 0, 1, -5)
    line.BackgroundColor3 = COLORS.Border
    line.BorderSizePixel = 0
    line.Parent = profileFrame

    -- Container tombol Tab
    self.TabContainer = Instance.new("ScrollingFrame")
    self.TabContainer.Size = UDim2.new(1, 0, 1, -115)
    self.TabContainer.Position = UDim2.new(0, 0, 0, 115)
    self.TabContainer.BackgroundTransparency = 1
    self.TabContainer.BorderSizePixel = 0
    self.TabContainer.ScrollBarThickness = 2
    self.TabContainer.ScrollBarImageColor3 = COLORS.Accent
    self.TabContainer.Parent = self.Sidebar

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabLayout.Parent = self.TabContainer
end

function CloverHub:_CreateContentArea()
    self.ContentArea = Instance.new("Frame")
    self.ContentArea.Size = UDim2.new(1, -SIZES.SidebarWidth, 1, -SIZES.TopBarHeight)
    self.ContentArea.Position = UDim2.new(0, SIZES.SidebarWidth, 0, SIZES.TopBarHeight)
    self.ContentArea.BackgroundTransparency = 1
    self.ContentArea.Parent = self.MainFrame
    
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 10)
    pad.PaddingLeft = UDim.new(0, 15)
    pad.PaddingRight = UDim.new(0, 15)
    pad.PaddingBottom = UDim.new(0, 10)
    pad.Parent = self.ContentArea
end

function CloverHub:_MakeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- ==========================================
-- TAB LOGIC
-- ==========================================
local Tab = {}
Tab.__index = Tab

function CloverHub:AddTab(name)
    local tab = setmetatable({}, Tab)
    tab.Hub = self
    
    -- Tombol Tab (Di Sidebar)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    
    -- [FIX] Menggunakan warna valid yang sudah diperbaiki di COLORS
    btn.BackgroundColor3 = COLORS.TabNormal 
    
    btn.BackgroundTransparency = 1
    btn.Text = name
    btn.TextColor3 = COLORS.TextSecondary
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.Parent = self.TabContainer
    CreateCorner(btn, SIZES.SmallCornerRadius)
    
    -- Indikator Kiri (Garis kecil saat aktif)
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 3, 0.6, 0)
    indicator.Position = UDim2.new(0, 0, 0.2, 0)
    indicator.BackgroundColor3 = COLORS.Accent
    indicator.Visible = false
    indicator.Parent = btn
    CreateCorner(indicator, UDim.new(1,0))

    -- Content Scroll
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.Visible = false
    content.ScrollBarThickness = 2
    content.ScrollBarImageColor3 = COLORS.Accent
    content.Parent = self.ContentArea
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = content
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        content.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 20)
    end)

    -- Logic Click
    btn.MouseButton1Click:Connect(function()
        -- Reset semua tab
        for _, t in ipairs(self.Tabs) do
            t.Btn.BackgroundColor3 = COLORS.TabNormal
            t.Btn.BackgroundTransparency = 1
            t.Btn.TextColor3 = COLORS.TextSecondary
            t.Btn.Font = Enum.Font.Gotham
            t.Content.Visible = false
            t.Indicator.Visible = false
        end
        -- Aktifkan ini
        btn.BackgroundColor3 = COLORS.TabSelected
        btn.BackgroundTransparency = 0.2
        btn.TextColor3 = COLORS.Text
        btn.Font = Enum.Font.GothamBold
        content.Visible = true
        indicator.Visible = true
    end)

    tab.Btn = btn
    tab.Indicator = indicator
    tab.Content = content
    
    table.insert(self.Tabs, tab)
    
    -- Auto select first tab
    if #self.Tabs == 1 then
        btn.BackgroundColor3 = COLORS.TabSelected
        btn.BackgroundTransparency = 0.2
        btn.TextColor3 = COLORS.Text
        btn.Font = Enum.Font.GothamBold
        content.Visible = true
        indicator.Visible = true
    end

    return tab
end

-- ==========================================
-- GROUP LOGIC (Tambahan untuk support script Fate Trigger)
-- ==========================================
-- Fate Trigger menggunakan :AddGroup, jadi kita perlu menambahkannya ke library
function Tab:AddGroup(text)
    local group = {}
    group.Tab = self
    
    -- Label Group
    local label = self:AddLabel(text)
    label.TextColor3 = COLORS.Accent
    label.TextSize = 13
    
    -- Container Group (Opsional, di sini kita langsung bind ke tab content)
    
    -- Mapping fungsi group ke fungsi tab yang sudah ada
    function group:AddToggle(text, config)
        self.Tab:AddToggle(text, config.Callback)
        -- Set default state jika ada di config (perlu modifikasi fungsi AddToggle sedikit untuk support set default value, tapi untuk sekarang callback cukup)
        if config.Default then
            config.Callback(config.Default)
        end
    end
    
    function group:AddSlider(text, config)
        -- Kita belum punya fungsi slider asli di library simple ini, kita buat text box sederhana sebagai pengganti sementara
        self.Tab:AddTextBox(text .. " (Min:"..config.Min.."-Max:"..config.Max..")", function(val)
            local num = tonumber(val)
            if num then config.Callback(num) end
        end)
    end
    
    function group:AddDropdown(text, config)
        -- Belum ada dropdown asli, ganti dengan Toggle cycle atau textbox
        self.Tab:AddLabel("[Dropdown] " .. text .. ": " .. table.concat(config.Values, ", "))
        self.Tab:AddTextBox("Type selection here", function(val)
             config.Callback(val)
        end)
    end
    
    function group:AddColorpicker(text, config)
         -- Belum ada colorpicker asli
         self.Tab:AddLabel("[Color] " .. text .. " (Not implemented in UI)")
    end

    return group
end

-- ==========================================
-- ELEMENTS
-- ==========================================
function Tab:AddButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = COLORS.SecondaryBg
    btn.BackgroundTransparency = 0.3
    btn.Text = text
    btn.TextColor3 = COLORS.Text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.Parent = self.Content
    CreateCorner(btn, SIZES.SmallCornerRadius)
    CreateStroke(btn, COLORS.Border, 1)
    
    btn.MouseButton1Click:Connect(function() pcall(callback) end)
    return btn
end

function Tab:AddToggle(text, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 35)
    frame.BackgroundColor3 = COLORS.SecondaryBg
    frame.BackgroundTransparency = 0.3
    frame.Parent = self.Content
    CreateCorner(frame, SIZES.SmallCornerRadius)
    CreateStroke(frame, COLORS.Border, 1)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.7, 0, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = COLORS.Text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame
    
    local togBtn = Instance.new("TextButton")
    togBtn.Size = UDim2.new(0, 40, 0, 20)
    togBtn.Position = UDim2.new(1, -50, 0.5, -10)
    togBtn.BackgroundColor3 = COLORS.Background
    togBtn.Text = ""
    togBtn.Parent = frame
    CreateCorner(togBtn, UDim.new(1,0))
    
    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 16, 0, 16)
    circle.Position = UDim2.new(0, 2, 0.5, -8)
    circle.BackgroundColor3 = COLORS.TextSecondary
    circle.Parent = togBtn
    CreateCorner(circle, UDim.new(1,0))
    
    local on = false
    togBtn.MouseButton1Click:Connect(function()
        on = not on
        if on then
            TweenService:Create(circle, TweenInfo.new(0.2), {Position = UDim2.new(1, -18, 0.5, -8), BackgroundColor3 = COLORS.Accent}):Play()
        else
            TweenService:Create(circle, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = COLORS.TextSecondary}):Play()
        end
        pcall(callback, on)
    end)
end

function Tab:AddTextBox(placeholder, callback)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, 0, 0, 35)
    box.BackgroundColor3 = COLORS.SecondaryBg
    box.BackgroundTransparency = 0.3
    box.PlaceholderText = placeholder
    box.Text = ""
    box.TextColor3 = COLORS.Accent
    box.Font = Enum.Font.Gotham
    box.TextSize = 13
    box.Parent = self.Content
    CreateCorner(box, SIZES.SmallCornerRadius)
    CreateStroke(box, COLORS.Border, 1)
    
    box.FocusLost:Connect(function()
        pcall(callback, box.Text)
    end)
end

function Tab:AddLabel(text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 25)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = COLORS.TextSecondary
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = self.Content
    return lbl
end

return CloverHub
