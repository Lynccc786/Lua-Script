--[[
    CLOVER-HUB UI LIBRARY (ENHANCED VERSION)
    Build: Advanced Release
    New Features: 
    - Multi-Value Dropdown
    - Button
    - TextBox Input
    - Notification System
    - All previous features retained
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- [ THEME CONFIGURATION ]

-- [ THEME SYSTEM ]
local THEMES = {
    Default = {
        Main        = Color3.fromRGB(25, 25, 30),
        Sidebar     = Color3.fromRGB(30, 30, 35),
        Section     = Color3.fromRGB(35, 35, 40),
        Element     = Color3.fromRGB(45, 45, 50),
        Text        = Color3.fromRGB(240, 240, 240),
        TextDim     = Color3.fromRGB(160, 160, 170),
        Accent      = Color3.fromRGB(0, 255, 160),
        Outline     = Color3.fromRGB(60, 60, 65),
        Shadow      = Color3.fromRGB(0, 0, 0),
        Success     = Color3.fromRGB(46, 204, 113),
        Warning     = Color3.fromRGB(241, 196, 15),
        Error       = Color3.fromRGB(231, 76, 60),
        Info        = Color3.fromRGB(52, 152, 219)
    },
    Dark = {
        Main        = Color3.fromRGB(15, 15, 20),
        Sidebar     = Color3.fromRGB(20, 20, 25),
        Section     = Color3.fromRGB(25, 25, 30),
        Element     = Color3.fromRGB(35, 35, 40),
        Text        = Color3.fromRGB(220, 220, 230),
        TextDim     = Color3.fromRGB(120, 120, 130),
        Accent      = Color3.fromRGB(0, 200, 255),
        Outline     = Color3.fromRGB(40, 40, 45),
        Shadow      = Color3.fromRGB(0, 0, 0),
        Success     = Color3.fromRGB(46, 204, 113),
        Warning     = Color3.fromRGB(241, 196, 15),
        Error       = Color3.fromRGB(231, 76, 60),
        Info        = Color3.fromRGB(52, 152, 219)
    },
    Light = {
        Main        = Color3.fromRGB(240, 240, 240),
        Sidebar     = Color3.fromRGB(220, 220, 220),
        Section     = Color3.fromRGB(200, 200, 200),
        Element     = Color3.fromRGB(255, 255, 255),
        Text        = Color3.fromRGB(30, 30, 30),
        TextDim     = Color3.fromRGB(120, 120, 120),
        Accent      = Color3.fromRGB(0, 170, 255),
        Outline     = Color3.fromRGB(180, 180, 180),
        Shadow      = Color3.fromRGB(0, 0, 0),
        Success     = Color3.fromRGB(46, 204, 113),
        Warning     = Color3.fromRGB(241, 196, 15),
        Error       = Color3.fromRGB(231, 76, 60),
        Info        = Color3.fromRGB(52, 152, 219)
    },
    Red = {
        Main        = Color3.fromRGB(40, 10, 10),
        Sidebar     = Color3.fromRGB(60, 20, 20),
        Section     = Color3.fromRGB(80, 30, 30),
        Element     = Color3.fromRGB(100, 40, 40),
        Text        = Color3.fromRGB(255, 200, 200),
        TextDim     = Color3.fromRGB(200, 120, 120),
        Accent      = Color3.fromRGB(255, 60, 60),
        Outline     = Color3.fromRGB(120, 60, 60),
        Shadow      = Color3.fromRGB(0, 0, 0),
        Success     = Color3.fromRGB(46, 204, 113),
        Warning     = Color3.fromRGB(241, 196, 15),
        Error       = Color3.fromRGB(231, 76, 60),
        Info        = Color3.fromRGB(52, 152, 219)
    }
}

local CURRENT_THEME = "Default"
local COLORS = THEMES[CURRENT_THEME]


function LIBRARY:GetTheme()
    return CURRENT_THEME, COLORS
end

function LIBRARY:GetAvailableThemes()
    local t = {}
    for k in pairs(THEMES) do table.insert(t, k) end
    return t
end

local LIBRARY_VERSION = "1.2.0"
local LIBRARY = {}
LIBRARY.__index = LIBRARY

-- [ LOADING SCREEN FEATURE ]
local loadingScreen = nil
function LIBRARY:ShowLoadingScreen(options)
    if loadingScreen then loadingScreen:Destroy() end
    options = options or {}
    local title = options.Title or "Loading..."
    local subtitle = options.Subtitle or "Please wait"

    loadingScreen = Instance.new("ScreenGui")
    loadingScreen.Name = "CloverUILoading"
    loadingScreen.IgnoreGuiInset = true
    loadingScreen.ZIndexBehavior = Enum.ZIndexBehavior.Global
    loadingScreen.Parent = CoreGui

    local bg = Instance.new("Frame")
    bg.BackgroundColor3 = COLORS.Main
    bg.Size = UDim2.new(1,0,1,0)
    bg.BackgroundTransparency = 0
    bg.Parent = loadingScreen
    AddCorner(bg, 0)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = title
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 36
    titleLabel.TextColor3 = COLORS.Accent
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1,0,0,60)
    titleLabel.Position = UDim2.new(0,0,0.45,0)
    titleLabel.Parent = bg

    local subtitleLabel = Instance.new("TextLabel")
    subtitleLabel.Text = subtitle
    subtitleLabel.Font = Enum.Font.Gotham
    subtitleLabel.TextSize = 22
    subtitleLabel.TextColor3 = COLORS.TextDim
    subtitleLabel.BackgroundTransparency = 1
    subtitleLabel.Size = UDim2.new(1,0,0,40)
    subtitleLabel.Position = UDim2.new(0,0,0.52,0)
    subtitleLabel.Parent = bg

    return loadingScreen
end

function LIBRARY:HideLoadingScreen()
    if loadingScreen then
        loadingScreen:Destroy()
        loadingScreen = nil
    end
end

-- [ UTILITY FUNCTIONS ]
local function GetXY(GuiObject)
	local Max, May = GuiObject.AbsoluteSize.X, GuiObject.AbsoluteSize.Y
	local Px, Py = math.clamp(Mouse.X - GuiObject.AbsolutePosition.X, 0, Max), math.clamp(Mouse.Y - GuiObject.AbsolutePosition.Y, 0, May)
	return Px/Max, Py/May
end

local function Tween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function AddCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
    corner.Parent = parent
    return corner
end

local function AddStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or COLORS.Outline
    stroke.Thickness = thickness or 1
    stroke.Parent = parent
    return stroke
end

local function MakeDraggable(frame, trigger)
    local dragging, dragInput, dragStart, startPos
    
    trigger.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    trigger.InputChanged:Connect(function(input)
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

-- [ NOTIFICATION SYSTEM ]
local NotificationContainer

local function CreateNotificationContainer(parent)
    if NotificationContainer then return NotificationContainer end
    
    local container = Instance.new("Frame")
    container.Name = "NotificationContainer"
    container.Size = UDim2.new(0, 300, 1, -20)
    container.Position = UDim2.new(1, -310, 0, 10)
    container.BackgroundTransparency = 1
    container.Parent = parent
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = container
    
    NotificationContainer = container
    return container
end

function LIBRARY:Notify(config)
    local title = config.Title or "Notification"
    local message = config.Message or "No message provided"
    local duration = config.Duration or 5
    local type = config.Type or "Info" -- Success, Warning, Error, Info
    
    local container = NotificationContainer or CreateNotificationContainer(self.Gui)
    
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(1, 0, 0, 80)
    notif.BackgroundColor3 = COLORS.Element
    notif.BorderSizePixel = 0
    notif.Parent = container
    AddCorner(notif, 8)
    
    local colorBar = Instance.new("Frame")
    colorBar.Size = UDim2.new(0, 4, 1, 0)
    colorBar.BackgroundColor3 = COLORS[type] or COLORS.Info
    colorBar.BorderSizePixel = 0
    colorBar.Parent = notif
    AddCorner(colorBar, 2)
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = title
    titleLabel.Size = UDim2.new(1, -50, 0, 25)
    titleLabel.Position = UDim2.new(0, 15, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = COLORS.Text
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notif
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Text = message
    messageLabel.Size = UDim2.new(1, -20, 0, 45)
    messageLabel.Position = UDim2.new(0, 15, 0, 30)
    messageLabel.BackgroundTransparency = 1
    messageLabel.TextColor3 = COLORS.TextDim
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextSize = 12
    messageLabel.TextWrapped = true
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.Parent = notif
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 20, 0, 20)
    closeBtn.Position = UDim2.new(1, -25, 0, 5)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = COLORS.TextDim
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.Parent = notif
    
    -- Slide in animation
    notif.Position = UDim2.new(1, 0, 0, 0)
    Tween(notif, {Position = UDim2.new(0, 0, 0, 0)}, 0.3)
    
    local function Remove()
        Tween(notif, {Position = UDim2.new(1, 0, 0, 0)}, 0.3)
        task.wait(0.3)
        notif:Destroy()
    end
    
    closeBtn.MouseButton1Click:Connect(Remove)
    
    task.delay(duration, Remove)
end

-- [ MAIN LIBRARY LOGIC ]
function LIBRARY:Create(config)
    -- [ VERSION CHECKING / BUILD WARNING ]
    if config and config.RequiredVersion then
        local req = tostring(config.RequiredVersion)
        if req ~= LIBRARY_VERSION then
            LIBRARY:Notify({
                Title = "Library Version Warning",
                Message = "Your UI library version ("..LIBRARY_VERSION..") does not match required ("..req..")!",
                Type = "Warning",
                Duration = 8
            })
        end
    end
    -- [ KEY SYSTEM / AUTHENTICATION ]
    if config and config.KeySystem and config.Key then
        local keyPassed = false
        while not keyPassed do
            local keyPrompt = Instance.new("ScreenGui")
            keyPrompt.Name = "CloverKeyPrompt"
            keyPrompt.IgnoreGuiInset = true
            keyPrompt.ZIndexBehavior = Enum.ZIndexBehavior.Global
            keyPrompt.Parent = CoreGui

            local bg = Instance.new("Frame")
            bg.BackgroundColor3 = Color3.fromRGB(20,20,20)
            bg.Size = UDim2.new(1,0,1,0)
            bg.BackgroundTransparency = 0.1
            bg.Parent = keyPrompt

            local box = Instance.new("Frame")
            box.Size = UDim2.new(0, 340, 0, 180)
            box.Position = UDim2.new(0.5, -170, 0.5, -90)
            box.BackgroundColor3 = Color3.fromRGB(30,30,35)
            box.Parent = bg
            AddCorner(box, 10)

            local title = Instance.new("TextLabel")
            title.Text = "Enter Access Key"
            title.Size = UDim2.new(1,0,0,40)
            title.Position = UDim2.new(0,0,0,10)
            title.BackgroundTransparency = 1
            title.TextColor3 = Color3.fromRGB(0,255,160)
            title.Font = Enum.Font.GothamBold
            title.TextSize = 22
            title.Parent = box

            local input = Instance.new("TextBox")
            input.Size = UDim2.new(1,-40,0,40)
            input.Position = UDim2.new(0,20,0,60)
            input.BackgroundColor3 = Color3.fromRGB(45,45,50)
            input.TextColor3 = Color3.fromRGB(240,240,240)
            input.Font = Enum.Font.Gotham
            input.TextSize = 18
            input.PlaceholderText = "Paste your key here..."
            input.Parent = box
            AddCorner(input, 8)

            local submit = Instance.new("TextButton")
            submit.Size = UDim2.new(1,-40,0,36)
            submit.Position = UDim2.new(0,20,0,110)
            submit.BackgroundColor3 = Color3.fromRGB(0,255,160)
            submit.Text = "Submit"
            submit.TextColor3 = Color3.fromRGB(25,25,30)
            submit.Font = Enum.Font.GothamBold
            submit.TextSize = 18
            submit.Parent = box
            AddCorner(submit, 8)

            local errorLabel = Instance.new("TextLabel")
            errorLabel.Text = ""
            errorLabel.Size = UDim2.new(1,0,0,20)
            errorLabel.Position = UDim2.new(0,0,1,-22)
            errorLabel.BackgroundTransparency = 1
            errorLabel.TextColor3 = Color3.fromRGB(231,76,60)
            errorLabel.Font = Enum.Font.Gotham
            errorLabel.TextSize = 14
            errorLabel.Parent = box

            local function checkKey()
                if input.Text == config.Key then
                    keyPassed = true
                    keyPrompt:Destroy()
                else
                    errorLabel.Text = "Invalid key!"
                end
            end
            submit.MouseButton1Click:Connect(checkKey)
            input.FocusLost:Connect(function(enter)
                if enter then checkKey() end
            end)

            repeat RunService.RenderStepped:Wait() until keyPassed
        end
    end
    local Window = setmetatable({}, LIBRARY)
    Window.Tabs = {}

    if CoreGui:FindFirstChild("CloverHubDual") then
        CoreGui.CloverHubDual:Destroy()
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "CloverHubDual"
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    if RunService:IsStudio() then
        gui.Parent = LocalPlayer.PlayerGui
    else
        gui.Parent = CoreGui
    end
    Window.Gui = gui

    -- [ TOGGLE UI KEYBIND ]
    local toggleKey = Enum.KeyCode.RightControl
    if config and config.ToggleKey then
        toggleKey = config.ToggleKey
    end
    local isVisible = true
    local mobileShowBtn = nil
    local function setVisible(state)
        gui.Enabled = state
        isVisible = state
        if UserInputService.TouchEnabled then
            if not state then
                if not mobileShowBtn then
                    mobileShowBtn = Instance.new("TextButton")
                    mobileShowBtn.Name = "ShowUIBtn"
                    mobileShowBtn.Text = "Show UI"
                    mobileShowBtn.Size = UDim2.new(0, 100, 0, 40)
                    mobileShowBtn.Position = UDim2.new(1, -110, 1, -50)
                    mobileShowBtn.AnchorPoint = Vector2.new(0, 1)
                    mobileShowBtn.BackgroundColor3 = COLORS.Accent
                    mobileShowBtn.TextColor3 = COLORS.Main
                    mobileShowBtn.TextSize = 18
                    mobileShowBtn.Parent = CoreGui
                    AddCorner(mobileShowBtn, 12)
                    mobileShowBtn.MouseButton1Click:Connect(function()
                        setVisible(true)
                    end)
                end
                mobileShowBtn.Visible = true
            else
                if mobileShowBtn then mobileShowBtn.Visible = false end
            end
        end
    end
    setVisible(true)
    Window._toggleKeyConn = UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == toggleKey then
            setVisible(not isVisible)
        end
    end)
    function Window:SetToggleKey(keycode)
        toggleKey = keycode
    end
    function Window:Destroy()
        if self._toggleKeyConn then
            self._toggleKeyConn:Disconnect()
        end
        if mobileShowBtn then mobileShowBtn:Destroy() end
        gui:Destroy()
    end
    
    -- Create Notification Container
    CreateNotificationContainer(gui)
    

    -- [ MOBILE LAYOUT OPTIMIZATION ]
    local isMobile = UserInputService.TouchEnabled
    local main = Instance.new("Frame")
    main.Name = "MainFrame"
    main.Size = isMobile and UDim2.new(0.98, 0, 0.98, 0) or UDim2.new(0, 700, 0, 480)
    main.Position = isMobile and UDim2.new(0.01, 0, 0.01, 0) or UDim2.new(0.5, 0, 0.5, 0)
    main.AnchorPoint = isMobile and Vector2.new(0, 0) or Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = COLORS.Main
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = gui

    AddCorner(main, isMobile and 18 or 10)
    AddStroke(main, COLORS.Outline, isMobile and 2.5 or 1.5)
    if not isMobile then MakeDraggable(main, main) end

    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = isMobile and UDim2.new(0, 220, 1, 0) or UDim2.new(0, 190, 1, 0)
    sidebar.BackgroundColor3 = COLORS.Sidebar
    sidebar.BorderSizePixel = 0
    sidebar.Parent = main

    local sidebarLine = Instance.new("Frame")
    sidebarLine.Size = UDim2.new(0, 1, 1, 0)
    sidebarLine.Position = UDim2.new(1, 0, 0, 0)
    sidebarLine.BackgroundColor3 = COLORS.Outline
    sidebarLine.BorderSizePixel = 0
    sidebarLine.Parent = sidebar

    local profileFrame = Instance.new("Frame")
    profileFrame.Name = "Profile"
    profileFrame.Size = isMobile and UDim2.new(1, 0, 0, 150) or UDim2.new(1, 0, 0, 120)
    profileFrame.BackgroundTransparency = 1
    profileFrame.Parent = sidebar

    local avatar = Instance.new("ImageLabel")
    avatar.Size = isMobile and UDim2.new(0, 70, 0, 70) or UDim2.new(0, 50, 0, 50)
    avatar.Position = isMobile and UDim2.new(0, 25, 0, 45) or UDim2.new(0, 20, 0, 35)
    avatar.BackgroundColor3 = COLORS.Section
    avatar.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    avatar.Parent = profileFrame
    AddCorner(avatar, isMobile and 35 or 25)
    AddStroke(avatar, COLORS.Accent, isMobile and 2 or 1)

    local welcomeLabel = Instance.new("TextLabel")
    welcomeLabel.Text = "Welcome Back,"
    welcomeLabel.Size = isMobile and UDim2.new(0, 140, 0, 28) or UDim2.new(0, 100, 0, 20)
    welcomeLabel.Position = isMobile and UDim2.new(0, 110, 0, 60) or UDim2.new(0, 80, 0, 40)
    welcomeLabel.BackgroundTransparency = 1
    welcomeLabel.TextColor3 = COLORS.TextDim
    welcomeLabel.Font = Enum.Font.Gotham
    welcomeLabel.TextSize = isMobile and 18 or 12
    welcomeLabel.TextXAlignment = Enum.TextXAlignment.Left
    welcomeLabel.Parent = profileFrame

    local userLabel = Instance.new("TextLabel")
    userLabel.Text = LocalPlayer.DisplayName
    userLabel.Size = isMobile and UDim2.new(0, 140, 0, 28) or UDim2.new(0, 100, 0, 20)
    userLabel.Position = isMobile and UDim2.new(0, 110, 0, 85) or UDim2.new(0, 80, 0, 55)
    userLabel.BackgroundTransparency = 1
    userLabel.TextColor3 = COLORS.Text
    userLabel.Font = Enum.Font.GothamBold
    userLabel.TextSize = isMobile and 22 or 14
    userLabel.TextXAlignment = Enum.TextXAlignment.Left
    userLabel.Parent = profileFrame
    
    Window.TabContainer = Instance.new("ScrollingFrame")
    Window.TabContainer.Name = "TabContainer"
    Window.TabContainer.Size = UDim2.new(1, 0, 1, -170)
    Window.TabContainer.Position = UDim2.new(0, 0, 0, 120)
    Window.TabContainer.BackgroundTransparency = 1
    Window.TabContainer.ScrollBarThickness = 2
    Window.TabContainer.ScrollBarImageColor3 = COLORS.Accent
    Window.TabContainer.Parent = sidebar

    -- [ DISCORD BUTTON ]
    local discordBtn = Instance.new("TextButton")
    discordBtn.Name = "DiscordBtn"
    discordBtn.Size = UDim2.new(0.85, 0, 0, 38)
    discordBtn.Position = UDim2.new(0.075, 0, 1, -45)
    discordBtn.AnchorPoint = Vector2.new(0, 1)
    discordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    discordBtn.Text = "Join Discord"
    discordBtn.TextColor3 = Color3.fromRGB(255,255,255)
    discordBtn.Font = Enum.Font.GothamBold
    discordBtn.TextSize = 15
    discordBtn.Parent = sidebar
    AddCorner(discordBtn, 8)
    discordBtn.MouseButton1Click:Connect(function()
        if config and config.DiscordInvite then
            setclipboard(config.DiscordInvite)
            LIBRARY:Notify({Title="Discord", Message="Invite link copied! Paste in browser.", Type="Info", Duration=3})
        else
            setclipboard("https://discord.gg/yourserver")
            LIBRARY:Notify({Title="Discord", Message="Invite link copied! Paste in browser.", Type="Info", Duration=3})
        end
    end)
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabLayout.Parent = Window.TabContainer
    
    Window.ContentContainer = Instance.new("Frame")
    Window.ContentContainer.Name = "Content"
    Window.ContentContainer.Size = UDim2.new(1, -190, 1, -50)
    Window.ContentContainer.Position = UDim2.new(0, 190, 0, 50)
    Window.ContentContainer.BackgroundTransparency = 1
    Window.ContentContainer.Parent = main
    
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, -190, 0, 50)
    topBar.Position = UDim2.new(0, 190, 0, 0)
    topBar.BackgroundTransparency = 1
    topBar.Parent = main
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = config.Title or "Fate Trigger"
    titleLabel.Size = UDim2.new(1, -50, 1, 0)
    titleLabel.Position = UDim2.new(0, 25, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = COLORS.Text
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 18
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = topBar
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -40, 0.5, -15)
    closeBtn.BackgroundColor3 = COLORS.Element
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.Parent = topBar
    AddCorner(closeBtn, 6)
    
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    
    -- [ CONFIGURATION SAVING SYSTEM ]
    function Window:SaveConfig()
        local configData = {
            Theme = CURRENT_THEME,
            Position = main.Position,
        }
        pcall(function()
            if isfile and writefile then
                writefile("cloverui_config.json", game:GetService("HttpService"):JSONEncode(configData))
            elseif LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then
                local guiObj = LocalPlayer.PlayerGui:FindFirstChild("CloverConfig") or Instance.new("StringValue")
                guiObj.Name = "CloverConfig"
                guiObj.Value = game:GetService("HttpService"):JSONEncode(configData)
                guiObj.Parent = LocalPlayer.PlayerGui
            end
        end)
    end

    function Window:LoadConfig()
        local configData = nil
        pcall(function()
            if isfile and readfile and isfile("cloverui_config.json") then
                configData = game:GetService("HttpService"):JSONDecode(readfile("cloverui_config.json"))
            elseif LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then
                local guiObj = LocalPlayer.PlayerGui:FindFirstChild("CloverConfig")
                if guiObj then
                    configData = game:GetService("HttpService"):JSONDecode(guiObj.Value)
                end
            end
        end)
        if configData then
            -- if configData.Theme then self:SetTheme(configData.Theme) end
            if configData.Position then main.Position = configData.Position end
        end
    end

    return Window
end

-- [ TAB CREATION ]
function LIBRARY:AddTab(name)
    local Tab = {}
    Tab.Groups = {}
    
    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = name
    tabBtn.Size = UDim2.new(0.85, 0, 0, 35)
    tabBtn.BackgroundColor3 = COLORS.Sidebar
    tabBtn.BackgroundTransparency = 1
    tabBtn.Text = "      " .. name
    tabBtn.TextColor3 = COLORS.TextDim
    tabBtn.Font = Enum.Font.GothamMedium
    tabBtn.TextSize = 13
    tabBtn.TextXAlignment = Enum.TextXAlignment.Left
    tabBtn.Parent = self.TabContainer
    AddCorner(tabBtn, 6)
    
    local tabIndicator = Instance.new("Frame")
    tabIndicator.Size = UDim2.new(0, 3, 0.6, 0)
    tabIndicator.Position = UDim2.new(0, 0, 0.2, 0)
    tabIndicator.BackgroundColor3 = COLORS.Accent
    tabIndicator.BackgroundTransparency = 1
    tabIndicator.Parent = tabBtn
    AddCorner(tabIndicator, 2)
    
    local page = Instance.new("Frame")
    page.Name = name .. "_Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = self.ContentContainer
    
    local leftColumn = Instance.new("ScrollingFrame")
    leftColumn.Name = "Left"
    leftColumn.Size = UDim2.new(0.48, 0, 1, -10)
    leftColumn.Position = UDim2.new(0, 10, 0, 0)
    leftColumn.BackgroundTransparency = 1
    leftColumn.ScrollBarThickness = 0
    leftColumn.Parent = page
    
    local leftLayout = Instance.new("UIListLayout")
    leftLayout.Padding = UDim.new(0, 12)
    leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
    leftLayout.Parent = leftColumn
    
    local rightColumn = Instance.new("ScrollingFrame")
    rightColumn.Name = "Right"
    rightColumn.Size = UDim2.new(0.48, 0, 1, -10)
    rightColumn.Position = UDim2.new(0.51, 0, 0, 0)
    rightColumn.BackgroundTransparency = 1
    rightColumn.ScrollBarThickness = 0
    rightColumn.Parent = page
    
    local rightLayout = Instance.new("UIListLayout")
    rightLayout.Padding = UDim.new(0, 12)
    rightLayout.SortOrder = Enum.SortOrder.LayoutOrder
    rightLayout.Parent = rightColumn
    
    leftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        leftColumn.CanvasSize = UDim2.new(0, 0, 0, leftLayout.AbsoluteContentSize.Y + 20)
    end)
    rightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        rightColumn.CanvasSize = UDim2.new(0, 0, 0, rightLayout.AbsoluteContentSize.Y + 20)
    end)
    
    local function Activate()
        for _, t in pairs(self.Tabs) do
            t.Page.Visible = false
            Tween(t.Btn, {TextColor3 = COLORS.TextDim, BackgroundTransparency = 1})
            Tween(t.Indicator, {BackgroundTransparency = 1})
        end
        page.Visible = true
        Tween(tabBtn, {TextColor3 = COLORS.Accent, BackgroundTransparency = 0.95})
        Tween(tabIndicator, {BackgroundTransparency = 0})
    end
    
    tabBtn.MouseButton1Click:Connect(Activate)
    
    if #self.Tabs == 0 then
        Activate()
    end
    
    Tab.Btn = tabBtn
    Tab.Indicator = tabIndicator
    Tab.Page = page
    Tab.Left = leftColumn
    Tab.Right = rightColumn
    
    function Tab:AddGroup(title, side)
        local Group = {}
        local parentColumn = (side and side:lower() == "right") and rightColumn or leftColumn
        
        local groupLabel = Instance.new("TextLabel")
        groupLabel.Text = title:upper()
        groupLabel.Size = UDim2.new(1, 0, 0, 20)
        groupLabel.BackgroundTransparency = 1
        groupLabel.TextColor3 = COLORS.Accent
        groupLabel.Font = Enum.Font.GothamBold
        groupLabel.TextSize = 12
        groupLabel.TextXAlignment = Enum.TextXAlignment.Left
        groupLabel.Parent = parentColumn
        
        local groupContainer = Instance.new("Frame")
        groupContainer.Size = UDim2.new(1, 0, 0, 0)
        groupContainer.BackgroundTransparency = 1
        groupContainer.Parent = parentColumn
        
        local groupLayout = Instance.new("UIListLayout")
        groupLayout.Padding = UDim.new(0, 8)
        groupLayout.SortOrder = Enum.SortOrder.LayoutOrder
        groupLayout.Parent = groupContainer
        
        groupLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            groupContainer.Size = UDim2.new(1, 0, 0, groupLayout.AbsoluteContentSize.Y)
        end)
        
        -- [ BUTTON ]
        function Group:AddButton(text, callback)
            callback = callback or function() end
            
            local button = Instance.new("TextButton")
            button.Size = UDim2.new(1, 0, 0, 35)
            button.BackgroundColor3 = COLORS.Element
            button.Text = text
            button.TextColor3 = COLORS.Text
            button.Font = Enum.Font.GothamMedium
            button.TextSize = 13
            button.Parent = groupContainer
            AddCorner(button, 6)
            
            button.MouseEnter:Connect(function()
                Tween(button, {BackgroundColor3 = COLORS.Accent})
            end)
            
            button.MouseLeave:Connect(function()
                Tween(button, {BackgroundColor3 = COLORS.Element})
            end)
            
            button.MouseButton1Click:Connect(function()
                callback()
                button.TextSize = 11
                task.wait(0.1)
                button.TextSize = 13
            end)
        end
        
        -- [ TOGGLE ]
        function Group:AddToggle(text, config)
            local state = config.Default or false
            local callback = config.Callback or function() end
            
            local toggleFrame = Instance.new("TextButton")
            toggleFrame.Size = UDim2.new(1, 0, 0, 35)
            toggleFrame.BackgroundColor3 = COLORS.Element
            toggleFrame.Text = ""
            toggleFrame.AutoButtonColor = false
            toggleFrame.Parent = groupContainer
            AddCorner(toggleFrame, 6)
            
            local label = Instance.new("TextLabel")
            label.Text = text
            label.Size = UDim2.new(0.7, 0, 1, 0)
            label.Position = UDim2.new(0, 10, 0, 0)
            label.BackgroundTransparency = 1
            label.TextColor3 = COLORS.Text
            label.Font = Enum.Font.GothamMedium
            label.TextSize = 13
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = toggleFrame
            
            local switchBg = Instance.new("Frame")
            switchBg.Size = UDim2.new(0, 36, 0, 18)
            switchBg.Position = UDim2.new(1, -46, 0.5, -9)
            switchBg.BackgroundColor3 = state and COLORS.Accent or COLORS.Section
            switchBg.Parent = toggleFrame
            AddCorner(switchBg, 9)
            
            local switchDot = Instance.new("Frame")
            switchDot.Size = UDim2.new(0, 14, 0, 14)
            switchDot.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
            switchDot.BackgroundColor3 = COLORS.Text
            switchDot.Parent = switchBg
            AddCorner(switchDot, 7)
            
            toggleFrame.MouseButton1Click:Connect(function()
                state = not state
                callback(state)
                
                Tween(switchBg, {BackgroundColor3 = state and COLORS.Accent or COLORS.Section})
                Tween(switchDot, {Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)})
            end)
        end
        
        -- [ SLIDER ]
        function Group:AddSlider(text, config)
            local min, max = config.Min or 0, config.Max or 100
            local default = config.Default or min
            local callback = config.Callback or function() end
            
            local sliderFrame = Instance.new("Frame")
            sliderFrame.Size = UDim2.new(1, 0, 0, 50)
            sliderFrame.BackgroundColor3 = COLORS.Element
            sliderFrame.Parent = groupContainer
            AddCorner(sliderFrame, 6)
            
            local label = Instance.new("TextLabel")
            label.Text = text
            label.Size = UDim2.new(1, -10, 0, 20)
            label.Position = UDim2.new(0, 10, 0, 5)
            label.BackgroundTransparency = 1
            label.TextColor3 = COLORS.Text
            label.Font = Enum.Font.GothamMedium
            label.TextSize = 13
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = sliderFrame
            
            local valueLabel = Instance.new("TextLabel")
            valueLabel.Text = tostring(default)
            valueLabel.Size = UDim2.new(0, 40, 0, 20)
            valueLabel.Position = UDim2.new(1, -50, 0, 5)
            valueLabel.BackgroundTransparency = 1
            valueLabel.TextColor3 = COLORS.TextDim
            valueLabel.Font = Enum.Font.GothamBold
            valueLabel.TextSize = 12
            valueLabel.TextXAlignment = Enum.TextXAlignment.Right
            valueLabel.Parent = sliderFrame
            
            local sliderBg = Instance.new("Frame")
            sliderBg.Size = UDim2.new(1, -20, 0, 4)
            sliderBg.Position = UDim2.new(0, 10, 0, 35)
            sliderBg.BackgroundColor3 = COLORS.Section
            sliderBg.Parent = sliderFrame
            AddCorner(sliderBg, 2)
            
            local sliderFill = Instance.new("Frame")
            sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            sliderFill.BackgroundColor3 = COLORS.Accent
            sliderFill.Parent = sliderBg
            AddCorner(sliderFill, 2)
            
            local trigger = Instance.new("TextButton")
            trigger.Size = UDim2.new(1, 0, 1, 0)
            trigger.BackgroundTransparency = 1
            trigger.Text = ""
            trigger.Parent = sliderBg
            
            local dragging = false
            local function update(input)
                local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                local value = math.floor(min + ((max - min) * pos))
                
                Tween(sliderFill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.05)
                valueLabel.Text = tostring(value)
                callback(value)
            end
            
            trigger.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    update(input)
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    update(input)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
        end
        
        -- [ TEXTBOX INPUT ]
        function Group:AddTextBox(text, config)
            local default = config.Default or ""
            local placeholder = config.Placeholder or "Enter text..."
            local callback = config.Callback or function() end
            
            local textboxFrame = Instance.new("Frame")
            textboxFrame.Size = UDim2.new(1, 0, 0, 35)
            textboxFrame.BackgroundColor3 = COLORS.Element
            textboxFrame.Parent = groupContainer
            AddCorner(textboxFrame, 6)
            
            local label = Instance.new("TextLabel")
            label.Text = text
            label.Size = UDim2.new(0.35, 0, 1, 0)
            label.Position = UDim2.new(0, 10, 0, 0)
            label.BackgroundTransparency = 1
            label.TextColor3 = COLORS.Text
            label.Font = Enum.Font.GothamMedium
            label.TextSize = 13
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = textboxFrame
            
            local inputBox = Instance.new("TextBox")
            inputBox.Size = UDim2.new(0.6, -20, 0, 25)
            inputBox.Position = UDim2.new(0.37, 0, 0.5, -12.5)
            inputBox.BackgroundColor3 = COLORS.Section
            inputBox.Text = default
            inputBox.PlaceholderText = placeholder
            inputBox.TextColor3 = COLORS.Text
            inputBox.PlaceholderColor3 = COLORS.TextDim
            inputBox.Font = Enum.Font.Gotham
            inputBox.TextSize = 12
            inputBox.ClearButtonMode = Enum.ClearButtonMode.WhileEditing
            inputBox.Parent = textboxFrame
            AddCorner(inputBox, 4)
            
            inputBox.FocusLost:Connect(function(enterPressed)
                if enterPressed then
                    callback(inputBox.Text)
                end
            end)
        end
        
        -- [ DROPDOWN (Single Select) ]
        function Group:AddDropdown(text, config)
            local options = config.Values or {}
            local default = config.Default or "Select..."
            local callback = config.Callback or function() end
            
            local dropFrame = Instance.new("Frame")
            dropFrame.Size = UDim2.new(1, 0, 0, 35)
            dropFrame.BackgroundColor3 = COLORS.Element
            dropFrame.ClipsDescendants = true
            dropFrame.Parent = groupContainer
            AddCorner(dropFrame, 6)
            
            local label = Instance.new("TextLabel")
            label.Text = text
            label.Size = UDim2.new(0.5, 0, 0, 35)
            label.Position = UDim2.new(0, 10, 0, 0)
            label.BackgroundTransparency = 1
            label.TextColor3 = COLORS.Text
            label.Font = Enum.Font.GothamMedium
            label.TextSize = 13
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = dropFrame
            
            local selected = Instance.new("TextLabel")
            selected.Text = default
            selected.Size = UDim2.new(0.5, -40, 0, 35)
            selected.Position = UDim2.new(0.5, 0, 0, 0)
            selected.BackgroundTransparency = 1
            selected.TextColor3 = COLORS.Accent
            selected.Font = Enum.Font.GothamBold
            selected.TextSize = 12
            selected.TextXAlignment = Enum.TextXAlignment.Right
            selected.Parent = dropFrame
            
            local icon = Instance.new("TextLabel")
            icon.Text = ">"
            icon.Size = UDim2.new(0, 30, 0, 35)
            icon.Position = UDim2.new(1, -30, 0, 0)
            icon.BackgroundTransparency = 1
            icon.TextColor3 = COLORS.TextDim
            icon.Font = Enum.Font.GothamBold
            icon.TextSize = 14
            icon.Parent = dropFrame
            
            local dropBtn = Instance.new("TextButton")
            dropBtn.Size = UDim2.new(1, 0, 0, 35)
            dropBtn.BackgroundTransparency = 1
            dropBtn.Text = ""
            dropBtn.Parent = dropFrame
            
            local listFrame = Instance.new("Frame")
            listFrame.Size = UDim2.new(1, -10, 0, 0)
            listFrame.Position = UDim2.new(0, 5, 0, 40)
            listFrame.BackgroundTransparency = 1
            listFrame.Parent = dropFrame
            
            local listLayout = Instance.new("UIListLayout")
            listLayout.Padding = UDim.new(0, 2)
            listLayout.Parent = listFrame
            
            for _, opt in ipairs(options) do
                local optBtn = Instance.new("TextButton")
                optBtn.Size = UDim2.new(1, 0, 0, 25)
                optBtn.BackgroundColor3 = COLORS.Section
                optBtn.Text = opt
                optBtn.TextColor3 = COLORS.Text
                optBtn.Font = Enum.Font.Gotham
                optBtn.TextSize = 12
                optBtn.Parent = listFrame
                AddCorner(optBtn, 4)
                
                optBtn.MouseButton1Click:Connect(function()
                    selected.Text = opt
                    callback(opt)
                    Tween(dropFrame, {Size = UDim2.new(1, 0, 0, 35)})
                    Tween(icon, {Rotation = 0})
                end)
            end
            
            local opened = false
            dropBtn.MouseButton1Click:Connect(function()
                opened = not opened
                local count = #options
                local height = opened and (40 + (count * 27) + 5) or 35
                Tween(dropFrame, {Size = UDim2.new(1, 0, 0, height)})
                Tween(icon, {Rotation = opened and 90 or 0})
            end)
        end
        
        -- [ MULTI-VALUE DROPDOWN ]
        function Group:AddMultiDropdown(text, config)
            local options = config.Values or {}
            local default = config.Default or {}
            local callback = config.Callback or function() end
            
            local selected = {}
            for _, val in ipairs(default) do
                selected[val] = true
            end
            
            local dropFrame = Instance.new("Frame")
            dropFrame.Size = UDim2.new(1, 0, 0, 35)
            dropFrame.BackgroundColor3 = COLORS.Element
            dropFrame.ClipsDescendants = true
            dropFrame.Parent = groupContainer
            AddCorner(dropFrame, 6)
            
            local label = Instance.new("TextLabel")
            label.Text = text
            label.Size = UDim2.new(0.5, 0, 0, 35)
            label.Position = UDim2.new(0, 10, 0, 0)
            label.BackgroundTransparency = 1
            label.TextColor3 = COLORS.Text
            label.Font = Enum.Font.GothamMedium
            label.TextSize = 13
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = dropFrame
            
            local function GetSelectedText()
                local count = 0
                for _ in pairs(selected) do count = count + 1 end
                return count > 0 and count .. " Selected" or "None"
            end
            
            local selectedLabel = Instance.new("TextLabel")
            selectedLabel.Text = GetSelectedText()
            selectedLabel.Size = UDim2.new(0.5, -40, 0, 35)
            selectedLabel.Position = UDim2.new(0.5, 0, 0, 0)
            selectedLabel.BackgroundTransparency = 1
            selectedLabel.TextColor3 = COLORS.Accent
            selectedLabel.Font = Enum.Font.GothamBold
            selectedLabel.TextSize = 12
            selectedLabel.TextXAlignment = Enum.TextXAlignment.Right
            selectedLabel.Parent = dropFrame
            
            local icon = Instance.new("TextLabel")
            icon.Text = ">"
            icon.Size = UDim2.new(0, 30, 0, 35)
            icon.Position = UDim2.new(1, -30, 0, 0)
            icon.BackgroundTransparency = 1
            icon.TextColor3 = COLORS.TextDim
            icon.Font = Enum.Font.GothamBold
            icon.TextSize = 14
            icon.Parent = dropFrame
            
            local dropBtn = Instance.new("TextButton")
            dropBtn.Size = UDim2.new(1, 0, 0, 35)
            dropBtn.BackgroundTransparency = 1
            dropBtn.Text = ""
            dropBtn.Parent = dropFrame
            
            local listFrame = Instance.new("ScrollingFrame")
            listFrame.Size = UDim2.new(1, -10, 0, 0)
            listFrame.Position = UDim2.new(0, 5, 0, 40)
            listFrame.BackgroundTransparency = 1
            listFrame.ScrollBarThickness = 2
            listFrame.ScrollBarImageColor3 = COLORS.Accent
            listFrame.Parent = dropFrame
            
            local listLayout = Instance.new("UIListLayout")
            listLayout.Padding = UDim.new(0, 2)
            listLayout.Parent = listFrame
            
            for _, opt in ipairs(options) do
                local optFrame = Instance.new("TextButton")
                optFrame.Size = UDim2.new(1, 0, 0, 25)
                optFrame.BackgroundColor3 = selected[opt] and COLORS.Accent or COLORS.Section
                optFrame.Text = ""
                optFrame.Parent = listFrame
                AddCorner(optFrame, 4)
                
                local optLabel = Instance.new("TextLabel")
                optLabel.Text = opt
                optLabel.Size = UDim2.new(1, -30, 1, 0)
                optLabel.Position = UDim2.new(0, 5, 0, 0)
                optLabel.BackgroundTransparency = 1
                optLabel.TextColor3 = COLORS.Text
                optLabel.Font = Enum.Font.Gotham
                optLabel.TextSize = 12
                optLabel.TextXAlignment = Enum.TextXAlignment.Left
                optLabel.Parent = optFrame
                
                local checkmark = Instance.new("TextLabel")
                checkmark.Text = selected[opt] and "✓" or ""
                checkmark.Size = UDim2.new(0, 20, 1, 0)
                checkmark.Position = UDim2.new(1, -25, 0, 0)
                checkmark.BackgroundTransparency = 1
                checkmark.TextColor3 = COLORS.Text
                checkmark.Font = Enum.Font.GothamBold
                checkmark.TextSize = 14
                checkmark.Parent = optFrame
                
                optFrame.MouseButton1Click:Connect(function()
                    selected[opt] = not selected[opt]
                    
                    Tween(optFrame, {BackgroundColor3 = selected[opt] and COLORS.Accent or COLORS.Section})
                    checkmark.Text = selected[opt] and "✓" or ""
                    selectedLabel.Text = GetSelectedText()
                    
                    local selectedList = {}
                    for k, v in pairs(selected) do
                        if v then table.insert(selectedList, k) end
                    end
                    callback(selectedList)
                end)
            end
            
            listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                listFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
            end)
            
            local opened = false
            dropBtn.MouseButton1Click:Connect(function()
                opened = not opened
                local height = opened and math.min(200, 40 + listLayout.AbsoluteContentSize.Y + 10) or 35
                Tween(dropFrame, {Size = UDim2.new(1, 0, 0, height)})
                Tween(icon, {Rotation = opened and 90 or 0})
                
                if opened then
                    listFrame.Size = UDim2.new(1, -10, 0, height - 45)
                end
            end)
        end
        
        -- [ ADVANCED COLOR PICKER ]
        function Group:AddColorPicker(text, config)
            local default = config.Default or Color3.fromRGB(255, 255, 255)
            local callback = config.Callback or function() end
            
            local pickerFrame = Instance.new("Frame")
            pickerFrame.Size = UDim2.new(1, 0, 0, 35)
            pickerFrame.BackgroundColor3 = COLORS.Element
            pickerFrame.ClipsDescendants = true
            pickerFrame.Parent = groupContainer
            AddCorner(pickerFrame, 6)
            
            local label = Instance.new("TextLabel")
            label.Text = text
            label.Size = UDim2.new(0.6, 0, 0, 35)
            label.Position = UDim2.new(0, 10, 0, 0)
            label.BackgroundTransparency = 1
            label.TextColor3 = COLORS.Text
            label.Font = Enum.Font.GothamMedium
            label.TextSize = 13
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = pickerFrame
            
            local preview = Instance.new("Frame")
            preview.Size = UDim2.new(0, 40, 0, 20)
            preview.Position = UDim2.new(1, -50, 0.5, -10)
            preview.BackgroundColor3 = default
            preview.Parent = pickerFrame
            AddCorner(preview, 4)
            AddStroke(preview, COLORS.Text, 1)
            
            local trigger = Instance.new("TextButton")
            trigger.Size = UDim2.new(1, 0, 0, 35)
            trigger.BackgroundTransparency = 1
            trigger.Text = ""
            trigger.Parent = pickerFrame
            
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, -20, 0, 120)
            container.Position = UDim2.new(0, 10, 0, 40)
            container.BackgroundTransparency = 1
            container.Parent = pickerFrame
            
            local svMap = Instance.new("ImageButton")
            svMap.Size = UDim2.new(0, 100, 0, 100)
            svMap.Position = UDim2.new(0, 0, 0, 0)
            svMap.Image = "rbxassetid://4155801252"
            svMap.BackgroundColor3 = default
            svMap.Parent = container
            AddCorner(svMap, 4)
            
            local cursor = Instance.new("Frame")
            cursor.Size = UDim2.new(0, 6, 0, 6)
            cursor.AnchorPoint = Vector2.new(0.5, 0.5)
            cursor.Position = UDim2.new(0, 0, 0, 0)
            cursor.BackgroundColor3 = Color3.new(1,1,1)
            cursor.Parent = svMap
            AddCorner(cursor, 100)
            AddStroke(cursor, Color3.new(0,0,0), 1)
            
            local hueMap = Instance.new("ImageButton")
            hueMap.Size = UDim2.new(0, 20, 0, 100)
            hueMap.Position = UDim2.new(0, 110, 0, 0)
            hueMap.BackgroundColor3 = Color3.new(1,1,1)
            hueMap.Image = ""
            hueMap.Parent = container
            AddCorner(hueMap, 4)
            
            local hueGrad = Instance.new("UIGradient")
            hueGrad.Rotation = 90
            hueGrad.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,0,0)),
                ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255,0,255)),
                ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,0,255)),
                ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0,255,255)),
                ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0,255,0)),
                ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,255,0)),
                ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255,0,0))
            }
            hueGrad.Parent = hueMap
            
            local hueCursor = Instance.new("Frame")
            hueCursor.Size = UDim2.new(1, 0, 0, 4)
            hueCursor.BackgroundColor3 = Color3.new(1,1,1)
            hueCursor.BorderColor3 = Color3.new(0,0,0)
            hueCursor.BorderSizePixel = 1
            hueCursor.Parent = hueMap
            
            local h, s, v = default:ToHSV()
            local draggingSV, draggingHue = false, false
            
            local function UpdateColor()
                local color = Color3.fromHSV(h, s, v)
                preview.BackgroundColor3 = color
                svMap.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                callback(color)
            end
            
            svMap.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingSV = true
                end
            end)
            
            hueMap.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingHue = true
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingSV = false
                    draggingHue = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    if draggingSV then
                        local mouseX = math.clamp(input.Position.X - svMap.AbsolutePosition.X, 0, svMap.AbsoluteSize.X)
                        local mouseY = math.clamp(input.Position.Y - svMap.AbsolutePosition.Y, 0, svMap.AbsoluteSize.Y)
                        s = mouseX / svMap.AbsoluteSize.X
                        v = 1 - (mouseY / svMap.AbsoluteSize.Y)
                        cursor.Position = UDim2.new(s, 0, 1-v, 0)
                        UpdateColor()
                    elseif draggingHue then
                        local mouseY = math.clamp(input.Position.Y - hueMap.AbsolutePosition.Y, 0, hueMap.AbsoluteSize.Y)
                        h = 1 - (mouseY / hueMap.AbsoluteSize.Y)
                        hueCursor.Position = UDim2.new(0, 0, 1-h, 0)
                        UpdateColor()
                    end
                end
            end)
            
            local opened = false
            trigger.MouseButton1Click:Connect(function()
                opened = not opened
                Tween(pickerFrame, {Size = UDim2.new(1, 0, 0, opened and 170 or 35)})
            end)
        end

        return Group
    end
    
    table.insert(self.Tabs, Tab)
    return Tab
end

return LIBRARY
