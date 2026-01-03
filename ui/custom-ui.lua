-- Custom UI Library dengan nuansa hijau transparan
-- Dibuat khusus untuk Clover Hub - Modern Design

local CustomUI = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- Modern Theme colors (Hijau Transparan dengan gradients)
local Theme = {
    Background = Color3.fromRGB(10, 15, 10),
    BackgroundTransparency = 0.15,
    Accent = Color3.fromRGB(76, 255, 150), -- Bright neon green
    AccentDark = Color3.fromRGB(45, 200, 110),
    Secondary = Color3.fromRGB(20, 35, 25),
    SecondaryLight = Color3.fromRGB(30, 50, 35),
    Text = Color3.fromRGB(240, 255, 245),
    TextDim = Color3.fromRGB(180, 200, 185),
    Border = Color3.fromRGB(76, 255, 150),
    Shadow = Color3.fromRGB(0, 0, 0),
}

function CustomUI:CreateWindow(config)
    local Window = {}
    Window.Tabs = {}
    Window.CurrentTab = nil
    
    -- Create main ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CloverHub_" .. math.random(1000, 9999)
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = CoreGui
    
    -- Main Frame with modern styling
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 650, 0, 450)
    MainFrame.Position = UDim2.new(0.5, -325, 0.5, -225)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BackgroundTransparency = Theme.BackgroundTransparency
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame
    
    -- Modern border with glow effect
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Theme.Accent
    MainStroke.Thickness = 1
    MainStroke.Transparency = 0.3
    MainStroke.Parent = MainFrame
    
    -- Shadow effect
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Size = UDim2.new(1, 30, 1, 30)
    Shadow.Position = UDim2.new(0, -15, 0, -15)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    Shadow.ImageColor3 = Theme.Shadow
    Shadow.ImageTransparency = 0.7
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    Shadow.ZIndex = 0
    Shadow.Parent = MainFrame
    
    -- Modern Title Bar with gradient
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = Theme.Secondary
    TitleBar.BackgroundTransparency = 0.1
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 12)
    TitleCorner.Parent = TitleBar
    
    -- Gradient overlay for modern look
    local TitleGradient = Instance.new("UIGradient")
    TitleGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Theme.SecondaryLight),
        ColorSequenceKeypoint.new(1, Theme.Secondary)
    }
    TitleGradient.Rotation = 90
    TitleGradient.Parent = TitleBar
    
    -- Title with modern font
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -120, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "🍀 " .. (config.Title or "Clover Hub")
    Title.TextColor3 = Theme.Accent
    Title.TextSize = 20
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar
    
    -- Animated glow effect
    local TitleGlow = Instance.new("UIStroke")
    TitleGlow.Color = Theme.Accent
    TitleGlow.Thickness = 0
    TitleGlow.Transparency = 0.5
    TitleGlow.Parent = Title
    
    task.spawn(function()
        while TitleBar and TitleBar.Parent do
            TweenService:Create(TitleGlow, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Thickness = 1}):Play()
            task.wait(2)
            TweenService:Create(TitleGlow, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Thickness = 0}):Play()
            task.wait(2)
        end
    end)
    
    -- Modern Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 35, 0, 35)
    CloseButton.Position = UDim2.new(1, -40, 0, 2.5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
    CloseButton.BackgroundTransparency = 0.2
    CloseButton.Text = "✕"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 18
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.BorderSizePixel = 0
    CloseButton.Parent = TitleBar
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 8)
    CloseCorner.Parent = CloseButton
    
    -- Hover effect
    CloseButton.MouseEnter:Connect(function()
        TweenService:Create(CloseButton, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
    end)
    
    CloseButton.MouseLeave:Connect(function()
        TweenService:Create(CloseButton, TweenInfo.new(0.2), {BackgroundTransparency = 0.2}):Play()
    end)
    
    CloseButton.MouseButton1Click:Connect(function()
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }):Play()
        task.wait(0.3)
        ScreenGui:Destroy()
    end)
    
    -- Modern Tab Container with better styling
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(0, 160, 1, -50)
    TabContainer.Position = UDim2.new(0, 8, 0, 48)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = MainFrame
    
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0, 6)
    TabLayout.Parent = TabContainer
    
    -- Modern Content Container
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, -180, 1, -55)
    ContentContainer.Position = UDim2.new(0, 175, 0, 48)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = MainFrame
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseButton
    
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Tab Container
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(0, 150, 1, -40)
    TabContainer.Position = UDim2.new(0, 5, 0, 40)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = MainFrame
    
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0, 5)
    TabLayout.Parent = TabContainer
    
    -- Content Container
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, -165, 1, -45)
    ContentContainer.Position = UDim2.new(0, 160, 0, 40)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = MainFrame
    
    -- Dragging functionality
    local dragging, dragInput, dragStart, startPos
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- Add Tab function
    function Window:AddTab(config)
        local Tab = {}
        Tab.Elements = {}
        
        -- Modern Tab Button with gradient and hover effects
        local TabButton = Instance.new("TextButton")
        TabButton.Name = config.Title
        TabButton.Size = UDim2.new(1, -5, 0, 38)
        TabButton.BackgroundColor3 = Theme.Secondary
        TabButton.BackgroundTransparency = 0.4
        TabButton.Text = config.Title
        TabButton.TextColor3 = Theme.TextDim
        TabButton.TextSize = 14
        TabButton.Font = Enum.Font.GothamSemibold
        TabButton.BorderSizePixel = 0
        TabButton.Parent = TabContainer
        
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 8)
        TabCorner.Parent = TabButton
        
        local TabStroke = Instance.new("UIStroke")
        TabStroke.Color = Theme.Border
        TabStroke.Thickness = 0
        TabStroke.Transparency = 0.8
        TabStroke.Parent = TabButton
        
        -- Hover animation
        TabButton.MouseEnter:Connect(function()
            if not TabContent.Visible then
                TweenService:Create(TabButton, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0.2
                }):Play()
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if not TabContent.Visible then
                TweenService:Create(TabButton, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0.4
                }):Play()
            end
        end)
        
        -- Tab Content
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = config.Title .. "Content"
        TabContent.Size = UDim2.new(1, -10, 1, -10)
        TabContent.Position = UDim2.new(0, 5, 0, 5)
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.ScrollBarThickness = 4
        TabContent.ScrollBarImageColor3 = Theme.Accent
        TabContent.Visible = false
        TabContent.Parent = ContentContainer
        
        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.Padding = UDim.new(0, 8)
        ContentLayout.Parent = TabContent
        
        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 10)
        end)
        
        TabButton.MouseButton1Click:Connect(function()
            -- Hide all tabs with animation
            for _, tab in pairs(Window.Tabs) do
                tab.Content.Visible = false
                TweenService:Create(tab.Button, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0.4,
                    TextColor3 = Theme.TextDim
                }):Play()
                if tab.Stroke then
                    TweenService:Create(tab.Stroke, TweenInfo.new(0.2), {Thickness = 0}):Play()
                end
            end
            
            -- Show this tab with animation
            TabContent.Visible = true
            TweenService:Create(TabButton, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.1,
                TextColor3 = Theme.Accent
            }):Play()
            TweenService:Create(TabStroke, TweenInfo.new(0.2), {Thickness = 1.5}):Play()
            Window.CurrentTab = Tab
        end)
        
        -- Auto-select first tab with animation
        if #Window.Tabs == 0 then
            TabContent.Visible = true
            TabButton.BackgroundTransparency = 0.1
            TabButton.TextColor3 = Theme.Accent
            TabStroke.Thickness = 1.5
            Window.CurrentTab = Tab
        end
        
        Tab.Content = TabContent
        Tab.Button = TabButton
        Tab.Stroke = TabStroke
        
        -- Add Toggle
        function Tab:AddToggle(id, config)
            local Toggle = {}
            local toggled = config.Default or false
            
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Name = id
            ToggleFrame.Size = UDim2.new(1, -10, 0, 35)
            ToggleFrame.BackgroundColor3 = Theme.Secondary
            ToggleFrame.BackgroundTransparency = 0.6
            ToggleFrame.BorderSizePixel = 0
            ToggleFrame.Parent = TabContent
            
            local ToggleCorner = Instance.new("UICorner")
            ToggleCorner.CornerRadius = UDim.new(0, 6)
            ToggleCorner.Parent = ToggleFrame
            
            local ToggleLabel = Instance.new("TextLabel")
            ToggleLabel.Size = UDim2.new(1, -50, 1, 0)
            ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
            ToggleLabel.BackgroundTransparency = 1
            ToggleLabel.Text = config.Title
            ToggleLabel.TextColor3 = Theme.Text
            ToggleLabel.TextSize = 13
            ToggleLabel.Font = Enum.Font.Gotham
            ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            ToggleLabel.Parent = ToggleFrame
            
            local ToggleButton = Instance.new("TextButton")
            ToggleButton.Size = UDim2.new(0, 40, 0, 20)
            ToggleButton.Position = UDim2.new(1, -45, 0.5, -10)
            ToggleButton.BackgroundColor3 = toggled and Theme.Accent or Color3.fromRGB(60, 60, 60)
            ToggleButton.Text = ""
            ToggleButton.BorderSizePixel = 0
            ToggleButton.Parent = ToggleFrame
            
            local ToggleBtnCorner = Instance.new("UICorner")
            ToggleBtnCorner.CornerRadius = UDim.new(1, 0)
            ToggleBtnCorner.Parent = ToggleButton
            
            local ToggleIndicator = Instance.new("Frame")
            ToggleIndicator.Size = UDim2.new(0, 16, 0, 16)
            ToggleIndicator.Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            ToggleIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ToggleIndicator.BorderSizePixel = 0
            ToggleIndicator.Parent = ToggleButton
            
            local IndicatorCorner = Instance.new("UICorner")
            IndicatorCorner.CornerRadius = UDim.new(1, 0)
            IndicatorCorner.Parent = ToggleIndicator
            
            ToggleButton.MouseButton1Click:Connect(function()
                toggled = not toggled
                
                TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
                    BackgroundColor3 = toggled and Theme.Accent or Color3.fromRGB(60, 60, 60)
                }):Play()
                
                TweenService:Create(ToggleIndicator, TweenInfo.new(0.2), {
                    Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                }):Play()
                
                if config.Callback then
                    task.spawn(config.Callback, toggled)
                end
            end)
            
            function Toggle:SetValue(value)
                toggled = value
                ToggleButton.BackgroundColor3 = toggled and Theme.Accent or Color3.fromRGB(60, 60, 60)
                ToggleIndicator.Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            end
            
            -- AddColorPicker method untuk toggle
            function Toggle:AddColorPicker(id, colorConfig)
                local ColorPicker = {}
                local currentColor = colorConfig.Default or Color3.fromRGB(255, 255, 255)
                
                -- Color preview button
                local ColorButton = Instance.new("TextButton")
                ColorButton.Size = UDim2.new(0, 25, 0, 20)
                ColorButton.Position = UDim2.new(1, -75, 0.5, -10)
                ColorButton.BackgroundColor3 = currentColor
                ColorButton.Text = ""
                ColorButton.BorderSizePixel = 1
                ColorButton.BorderColor3 = Theme.Border
                ColorButton.Parent = ToggleFrame
                
                local ColorCorner = Instance.new("UICorner")
                ColorCorner.CornerRadius = UDim.new(0, 4)
                ColorCorner.Parent = ColorButton
                
                ColorButton.MouseButton1Click:Connect(function()
                    -- Simple color randomizer for now (in real implementation, use color picker GUI)
                    currentColor = Color3.fromHSV(math.random(), 1, 1)
                    ColorButton.BackgroundColor3 = currentColor
                    if colorConfig.Callback then
                        task.spawn(colorConfig.Callback, currentColor)
                    end
                end)
                
                function ColorPicker:SetColor(color)
                    currentColor = color
                    ColorButton.BackgroundColor3 = color
                end
                
                return ColorPicker
            end
            
            return Toggle
        end
        
        -- Add Slider
        function Tab:AddSlider(id, config)
            local Slider = {}
            local value = config.Default or config.Min or 0
            
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Name = id
            SliderFrame.Size = UDim2.new(1, -10, 0, 50)
            SliderFrame.BackgroundColor3 = Theme.Secondary
            SliderFrame.BackgroundTransparency = 0.6
            SliderFrame.BorderSizePixel = 0
            SliderFrame.Parent = TabContent
            
            local SliderCorner = Instance.new("UICorner")
            SliderCorner.CornerRadius = UDim.new(0, 6)
            SliderCorner.Parent = SliderFrame
            
            local SliderLabel = Instance.new("TextLabel")
            SliderLabel.Size = UDim2.new(1, -20, 0, 20)
            SliderLabel.Position = UDim2.new(0, 10, 0, 5)
            SliderLabel.BackgroundTransparency = 1
            SliderLabel.Text = config.Title
            SliderLabel.TextColor3 = Theme.Text
            SliderLabel.TextSize = 13
            SliderLabel.Font = Enum.Font.Gotham
            SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
            SliderLabel.Parent = SliderFrame
            
            local SliderValue = Instance.new("TextLabel")
            SliderValue.Size = UDim2.new(0, 60, 0, 20)
            SliderValue.Position = UDim2.new(1, -70, 0, 5)
            SliderValue.BackgroundTransparency = 1
            SliderValue.Text = tostring(value)
            SliderValue.TextColor3 = Theme.Accent
            SliderValue.TextSize = 13
            SliderValue.Font = Enum.Font.GothamBold
            SliderValue.TextXAlignment = Enum.TextXAlignment.Right
            SliderValue.Parent = SliderFrame
            
            local SliderBar = Instance.new("Frame")
            SliderBar.Size = UDim2.new(1, -20, 0, 6)
            SliderBar.Position = UDim2.new(0, 10, 1, -15)
            SliderBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            SliderBar.BorderSizePixel = 0
            SliderBar.Parent = SliderFrame
            
            local SliderBarCorner = Instance.new("UICorner")
            SliderBarCorner.CornerRadius = UDim.new(1, 0)
            SliderBarCorner.Parent = SliderBar
            
            local SliderFill = Instance.new("Frame")
            SliderFill.Size = UDim2.new((value - config.Min) / (config.Max - config.Min), 0, 1, 0)
            SliderFill.BackgroundColor3 = Theme.Accent
            SliderFill.BorderSizePixel = 0
            SliderFill.Parent = SliderBar
            
            local SliderFillCorner = Instance.new("UICorner")
            SliderFillCorner.CornerRadius = UDim.new(1, 0)
            SliderFillCorner.Parent = SliderFill
            
            local dragging = false
            
            SliderBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                end
            end)
            
            SliderBar.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local mousePos = UserInputService:GetMouseLocation()
                    local relativePos = (mousePos.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X
                    relativePos = math.clamp(relativePos, 0, 1)
                    
                    value = config.Min + (config.Max - config.Min) * relativePos
                    if config.Rounding then
                        value = math.floor(value * (10 ^ config.Rounding) + 0.5) / (10 ^ config.Rounding)
                    end
                    
                    SliderValue.Text = tostring(value)
                    SliderFill.Size = UDim2.new(relativePos, 0, 1, 0)
                    
                    if config.Callback then
                        task.spawn(config.Callback, value)
                    end
                end
            end)
            
            function Slider:SetValue(newValue)
                value = math.clamp(newValue, config.Min, config.Max)
                SliderValue.Text = tostring(value)
                SliderFill.Size = UDim2.new((value - config.Min) / (config.Max - config.Min), 0, 1, 0)
            end
            
            return Slider
        end
        
        -- Add Button
        function Tab:AddButton(config)
            local ButtonFrame = Instance.new("TextButton")
            ButtonFrame.Size = UDim2.new(1, -10, 0, 35)
            ButtonFrame.BackgroundColor3 = Theme.Secondary
            ButtonFrame.BackgroundTransparency = 0.6
            ButtonFrame.BorderSizePixel = 0
            ButtonFrame.Text = ""
            ButtonFrame.Parent = TabContent
            
            local ButtonCorner = Instance.new("UICorner")
            ButtonCorner.CornerRadius = UDim.new(0, 6)
            ButtonCorner.Parent = ButtonFrame
            
            local ButtonLabel = Instance.new("TextLabel")
            ButtonLabel.Size = UDim2.new(1, -20, 1, 0)
            ButtonLabel.Position = UDim2.new(0, 10, 0, 0)
            ButtonLabel.BackgroundTransparency = 1
            ButtonLabel.Text = config.Title
            ButtonLabel.TextColor3 = Theme.Text
            ButtonLabel.TextSize = 13
            ButtonLabel.Font = Enum.Font.Gotham
            ButtonLabel.Parent = ButtonFrame
            
            ButtonFrame.MouseButton1Click:Connect(function()
                TweenService:Create(ButtonFrame, TweenInfo.new(0.1), {BackgroundTransparency = 0.3}):Play()
                task.wait(0.1)
                TweenService:Create(ButtonFrame, TweenInfo.new(0.1), {BackgroundTransparency = 0.6}):Play()
                
                if config.Callback then
                    task.spawn(config.Callback)
                end
            end)
        end
        
        -- Add Dropdown
        function Tab:AddDropdown(id, config)
            local Dropdown = {}
            local selected = config.Values[config.Default] or config.Values[1]
            local opened = false
            
            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Name = id
            DropdownFrame.Size = UDim2.new(1, -10, 0, 35)
            DropdownFrame.BackgroundColor3 = Theme.Secondary
            DropdownFrame.BackgroundTransparency = 0.6
            DropdownFrame.BorderSizePixel = 0
            DropdownFrame.Parent = TabContent
            DropdownFrame.ClipsDescendants = true
            
            local DropdownCorner = Instance.new("UICorner")
            DropdownCorner.CornerRadius = UDim.new(0, 6)
            DropdownCorner.Parent = DropdownFrame
            
            local DropdownButton = Instance.new("TextButton")
            DropdownButton.Size = UDim2.new(1, 0, 0, 35)
            DropdownButton.BackgroundTransparency = 1
            DropdownButton.Text = ""
            DropdownButton.Parent = DropdownFrame
            
            local DropdownLabel = Instance.new("TextLabel")
            DropdownLabel.Size = UDim2.new(1, -50, 0, 35)
            DropdownLabel.Position = UDim2.new(0, 10, 0, 0)
            DropdownLabel.BackgroundTransparency = 1
            DropdownLabel.Text = config.Title .. ": " .. tostring(selected)
            DropdownLabel.TextColor3 = Theme.Text
            DropdownLabel.TextSize = 13
            DropdownLabel.Font = Enum.Font.Gotham
            DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
            DropdownLabel.Parent = DropdownFrame
            
            local DropdownIcon = Instance.new("TextLabel")
            DropdownIcon.Size = UDim2.new(0, 20, 0, 35)
            DropdownIcon.Position = UDim2.new(1, -30, 0, 0)
            DropdownIcon.BackgroundTransparency = 1
            DropdownIcon.Text = "▼"
            DropdownIcon.TextColor3 = Theme.Accent
            DropdownIcon.TextSize = 12
            DropdownIcon.Font = Enum.Font.Gotham
            DropdownIcon.Parent = DropdownFrame
            
            local DropdownList = Instance.new("ScrollingFrame")
            DropdownList.Size = UDim2.new(1, 0, 0, 0)
            DropdownList.Position = UDim2.new(0, 0, 0, 35)
            DropdownList.BackgroundTransparency = 1
            DropdownList.BorderSizePixel = 0
            DropdownList.ScrollBarThickness = 3
            DropdownList.Parent = DropdownFrame
            
            local ListLayout = Instance.new("UIListLayout")
            ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ListLayout.Parent = DropdownList
            
            for _, v in ipairs(config.Values) do
                local OptionButton = Instance.new("TextButton")
                OptionButton.Size = UDim2.new(1, 0, 0, 30)
                OptionButton.BackgroundColor3 = Theme.Background
                OptionButton.BackgroundTransparency = 0.5
                OptionButton.BorderSizePixel = 0
                OptionButton.Text = tostring(v)
                OptionButton.TextColor3 = Theme.Text
                OptionButton.TextSize = 12
                OptionButton.Font = Enum.Font.Gotham
                OptionButton.Parent = DropdownList
                
                OptionButton.MouseButton1Click:Connect(function()
                    selected = v
                    DropdownLabel.Text = config.Title .. ": " .. tostring(selected)
                    
                    opened = false
                    TweenService:Create(DropdownFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, -10, 0, 35)}):Play()
                    TweenService:Create(DropdownIcon, TweenInfo.new(0.2), {Rotation = 0}):Play()
                    
                    if config.Callback then
                        task.spawn(config.Callback, v)
                    end
                end)
            end
            
            ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                DropdownList.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y)
            end)
            
            DropdownButton.MouseButton1Click:Connect(function()
                opened = not opened
                local targetSize = opened and math.min(#config.Values * 30 + 35, 150) or 35
                
                TweenService:Create(DropdownFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, -10, 0, targetSize)}):Play()
                TweenService:Create(DropdownIcon, TweenInfo.new(0.2), {Rotation = opened and 180 or 0}):Play()
            end)
            
            return Dropdown
        end
        
        -- Add Paragraph
        function Tab:AddParagraph(config)
            local ParagraphFrame = Instance.new("Frame")
            ParagraphFrame.Size = UDim2.new(1, -10, 0, 60)
            ParagraphFrame.BackgroundColor3 = Theme.Secondary
            ParagraphFrame.BackgroundTransparency = 0.7
            ParagraphFrame.BorderSizePixel = 0
            ParagraphFrame.Parent = TabContent
            
            local ParagraphCorner = Instance.new("UICorner")
            ParagraphCorner.CornerRadius = UDim.new(0, 6)
            ParagraphCorner.Parent = ParagraphFrame
            
            local ParagraphTitle = Instance.new("TextLabel")
            ParagraphTitle.Size = UDim2.new(1, -20, 0, 20)
            ParagraphTitle.Position = UDim2.new(0, 10, 0, 5)
            ParagraphTitle.BackgroundTransparency = 1
            ParagraphTitle.Text = config.Title
            ParagraphTitle.TextColor3 = Theme.Accent
            ParagraphTitle.TextSize = 14
            ParagraphTitle.Font = Enum.Font.GothamBold
            ParagraphTitle.TextXAlignment = Enum.TextXAlignment.Left
            ParagraphTitle.Parent = ParagraphFrame
            
            local ParagraphContent = Instance.new("TextLabel")
            ParagraphContent.Size = UDim2.new(1, -20, 1, -30)
            ParagraphContent.Position = UDim2.new(0, 10, 0, 25)
            ParagraphContent.BackgroundTransparency = 1
            ParagraphContent.Text = config.Content
            ParagraphContent.TextColor3 = Theme.Text
            ParagraphContent.TextSize = 12
            ParagraphContent.Font = Enum.Font.Gotham
            ParagraphContent.TextXAlignment = Enum.TextXAlignment.Left
            ParagraphContent.TextYAlignment = Enum.TextYAlignment.Top
            ParagraphContent.TextWrapped = true
            ParagraphContent.Parent = ParagraphFrame
            
            local Paragraph = {}
            function Paragraph:SetDesc(text)
                ParagraphContent.Text = text
            end
            
            return Paragraph
        end
        
        table.insert(Window.Tabs, Tab)
        return Tab
    end
    
    -- Notification system
    function Window:Notify(config)
        local NotifFrame = Instance.new("Frame")
        NotifFrame.Size = UDim2.new(0, 300, 0, 0)
        NotifFrame.Position = UDim2.new(1, -310, 1, -10)
        NotifFrame.BackgroundColor3 = Theme.Background
        NotifFrame.BackgroundTransparency = 0.2
        NotifFrame.BorderSizePixel = 0
        NotifFrame.Parent = ScreenGui
        NotifFrame.ClipsDescendants = true
        
        local NotifCorner = Instance.new("UICorner")
        NotifCorner.CornerRadius = UDim.new(0, 8)
        NotifCorner.Parent = NotifFrame
        
        local NotifStroke = Instance.new("UIStroke")
        NotifStroke.Color = Theme.Accent
        NotifStroke.Thickness = 2
        NotifStroke.Parent = NotifFrame
        
        local NotifTitle = Instance.new("TextLabel")
        NotifTitle.Size = UDim2.new(1, -20, 0, 25)
        NotifTitle.Position = UDim2.new(0, 10, 0, 5)
        NotifTitle.BackgroundTransparency = 1
        NotifTitle.Text = config.Title or "Notification"
        NotifTitle.TextColor3 = Theme.Accent
        NotifTitle.TextSize = 14
        NotifTitle.Font = Enum.Font.GothamBold
        NotifTitle.TextXAlignment = Enum.TextXAlignment.Left
        NotifTitle.Parent = NotifFrame
        
        local NotifContent = Instance.new("TextLabel")
        NotifContent.Size = UDim2.new(1, -20, 1, -35)
        NotifContent.Position = UDim2.new(0, 10, 0, 30)
        NotifContent.BackgroundTransparency = 1
        NotifContent.Text = config.Content or ""
        NotifContent.TextColor3 = Theme.Text
        NotifContent.TextSize = 12
        NotifContent.Font = Enum.Font.Gotham
        NotifContent.TextXAlignment = Enum.TextXAlignment.Left
        NotifContent.TextYAlignment = Enum.TextYAlignment.Top
        NotifContent.TextWrapped = true
        NotifContent.Parent = NotifFrame
        
        -- Calculate height based on text
        local textHeight = game:GetService("TextService"):GetTextSize(
            config.Content or "",
            12,
            Enum.Font.Gotham,
            Vector2.new(280, math.huge)
        ).Y
        
        local finalHeight = math.max(60, textHeight + 40)
        
        -- Slide in animation
        TweenService:Create(NotifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 300, 0, finalHeight)
        }):Play()
        
        -- Auto dismiss
        task.delay(config.Duration or 3, function()
            TweenService:Create(NotifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(1, 10, 1, -10),
                Size = UDim2.new(0, 300, 0, 0)
            }):Play()
            
            task.wait(0.3)
            NotifFrame:Destroy()
        end)
    end
    
    Window.ScreenGui = ScreenGui
    Window.MainFrame = MainFrame
    
    return Window
end

return CustomUI
