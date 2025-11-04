-- Winuent UI v5.1 | WindUI-Inspired Hybrid | Complete One-File Library
-- Features: All Elements, Draggable/Resizable, Search, Config, Animations, Mobile, Dark/Light
-- Usage: local Winuent = loadstring(game:HttpGet(".../main.lua"))()

local Winuent = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Mobile Scaling
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local ScaleFactor = IsMobile and 1.2 or 1.0

-- Themes (WindUI-inspired colors)
local Themes = {
    Dark = {
        Background = Color3.fromRGB(32, 32, 37),
        Primary = Color3.fromRGB(48, 48, 52),
        Secondary = Color3.fromRGB(56, 56, 61),
        Accent = Color3.fromRGB(0, 162, 255),
        Text = Color3.fromRGB(255, 255, 255),
        Shadow = Color3.fromRGB(0, 0, 0)
    },
    Light = {
        Background = Color3.fromRGB(249, 249, 249),
        Primary = Color3.fromRGB(255, 255, 255),
        Secondary = Color3.fromRGB(240, 240, 240),
        Accent = Color3.fromRGB(0, 120, 215),
        Text = Color3.fromRGB(0, 0, 0),
        Shadow = Color3.fromRGB(200, 200, 200)
    }
}

-- Unicode Icons (licide.dev style)
local Icons = {
    home = "⌂", settings = "⚙", user = "👤", star = "⭐", trash = "🗑",
    search = "🔍", close = "✕", resize = "↘", down = "▼", up = "▲",
    key = "🔑", palette = "🎨", section = "📁", sun = "☀", moon = "🌙"
}

-- Config System
local ConfigFile = "WinuentConfig.json"
local Config = {Theme = "Dark", Pos = {X = 50, Y = 50}, Size = {W = 600, H = 450}}

local function LoadConfig()
    if isfile and readfile and isfile(ConfigFile) then
        local success, data = pcall(HttpService.JSONDecode, HttpService, readfile(ConfigFile))
        if success then Config = data end
    end
end

local function SaveConfig()
    if writefile then pcall(function() writefile(ConfigFile, HttpService:JSONEncode(Config)) end) end
end

LoadConfig()

-- Notification System
local function Notify(window, opts)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300 * ScaleFactor, 0, 80 * ScaleFactor)
    frame.Position = UDim2.new(1, 20, 0, 20)
    frame.BackgroundColor3 = window.Theme.Secondary
    frame.Parent = window.ScreenGui
    local corner = Instance.new("UICorner", frame); corner.CornerRadius = UDim.new(0, 8)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, -16, 0, 24); title.Position = UDim2.new(0, 8, 0, 8)
    title.Text = opts.Title or "Notification"
    title.TextColor3 = window.Theme.Accent
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left

    local content = Instance.new("TextLabel", frame)
    content.Size = UDim2.new(1, -16, 0, 30); content.Position = UDim2.new(0, 8, 0, 32)
    content.Text = opts.Content or ""
    content.TextColor3 = window.Theme.Text
    content.TextWrapped = true
    content.Font = Enum.Font.Gotham
    content.TextSize = 13

    frame:TweenPosition(UDim2.new(1, -320 * ScaleFactor, 0, 20), "Out", "Quad", 0.3, true)
    delay(opts.Duration or 3, function()
        frame:TweenPosition(UDim2.new(1, 20, 0, 20), "In", "Quad", 0.3, true, function()
            frame:Destroy()
        end)
    end)
end

-- Create Window
function Winuent:CreateWindow(options)
    local self = setmetatable({}, {__index = Winuent})
    self.Title = options.Title or "Winuent UI"
    self.Theme = Themes[Config.Theme]
    self.Size = UDim2.fromOffset(Config.Size.W, Config.Size.H)
    self.MinSize = UDim2.fromOffset(300, 200)
    self.Acrylic = options.Acrylic or false

    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "Winuent_" .. tick()
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    -- Main Frame
    self.Frame = Instance.new("Frame")
    self.Frame.Size = self.Size
    self.Frame.Position = UDim2.fromOffset(Config.Pos.X, Config.Pos.Y)
    self.Frame.BackgroundColor3 = self.Theme.Background
    self.Frame.ClipsDescendants = true
    self.Frame.Parent = self.ScreenGui
    local frameCorner = Instance.new("UICorner", self.Frame)
    frameCorner.CornerRadius = UDim.new(0, 12)

    -- Shadow
    local shadow = Instance.new("Frame")
    shadow.Size = UDim2.fromScale(1, 1)
    shadow.Position = UDim2.new(0, 2, 0, 2)
    shadow.BackgroundColor3 = self.Theme.Shadow
    shadow.BackgroundTransparency = 0.8
    shadow.ZIndex = self.Frame.ZIndex - 1
    shadow.Parent = self.ScreenGui
    local shadowCorner = Instance.new("UICorner", shadow)
    shadowCorner.CornerRadius = UDim.new(0, 12)

    -- Acrylic Blur (if enabled)
    if self.Acrylic then
        local blur = Instance.new("ImageLabel")
        blur.Size = UDim2.fromScale(1, 1)
        blur.BackgroundTransparency = 1
        blur.Image = "rbxassetid://4996891970"
        blur.ImageColor3 = Color3.fromRGB(255, 255, 255)
        blur.ImageTransparency = 0.6
        blur.ScaleType = Enum.ScaleType.Tile
        blur.TileSize = UDim2.fromOffset(32, 32)
        blur.Parent = self.Frame
    end

    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = self.Theme.Primary
    titleBar.Parent = self.Frame
    local titleCorner = Instance.new("UICorner", titleBar)
    titleCorner.CornerRadius = UDim.new(0, 12, 0, 0)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -100, 1, 0)
    titleLabel.Position = UDim2.new(0, 12, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = self.Title
    titleLabel.TextColor3 = self.Theme.Text
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextSize = 14
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = titleBar

    -- Theme Toggle Button
    local themeBtn = Instance.new("TextButton")
    themeBtn.Size = UDim2.new(0, 32, 0, 32)
    themeBtn.Position = UDim2.new(1, -40, 0.5, -16)
    themeBtn.BackgroundTransparency = 1
    themeBtn.Text = Config.Theme == "Dark" and Icons.sun or Icons.moon
    themeBtn.TextColor3 = self.Theme.Text
    themeBtn.Font = Enum.Font.GothamBold
    themeBtn.TextSize = 16
    themeBtn.Parent = titleBar
    themeBtn.MouseButton1Click:Connect(function()
        Config.Theme = Config.Theme == "Dark" and "Light" or "Dark"
        self.Theme = Themes[Config.Theme]
        self:UpdateTheme()
        themeBtn.Text = Config.Theme == "Dark" and Icons.sun or Icons.moon
        SaveConfig()
    end)

    -- Search Bar
    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(0, 180, 0, 28)
    searchBox.Position = UDim2.new(1, -230, 0.5, -14)
    searchBox.BackgroundColor3 = self.Theme.Secondary
    searchBox.PlaceholderText = Icons.search .. " Search..."
    searchBox.Text = ""
    searchBox.TextColor3 = self.Theme.Text
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextSize = 12
    searchBox.Parent = titleBar
    local searchCorner = Instance.new("UICorner", searchBox)
    searchCorner.CornerRadius = UDim.new(0, 6)
    self.SearchBox = searchBox

    -- Sidebar for Tabs
    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 160, 1, -40)
    sidebar.Position = UDim2.new(0, 0, 0, 40)
    sidebar.BackgroundColor3 = self.Theme.Primary
    sidebar.Parent = self.Frame
    local sidebarCorner = Instance.new("UICorner", sidebar)
    sidebarCorner.CornerRadius = UDim.new(0, 0, 0, 12)
    local sidebarLayout = Instance.new("UIListLayout")
    sidebarLayout.Padding = UDim.new(0, 4)
    sidebarLayout.Parent = sidebar
    self.Sidebar = sidebar

    -- Content Area
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, -160, 1, -40)
    content.Position = UDim2.new(0, 160, 0, 40)
    content.BackgroundTransparency = 1
    content.ScrollBarThickness = 4
    content.Parent = self.Frame
    self.Content = content

    -- Dragging (Fixed)
    local dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragStart = input.Position
            startPos = self.Frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragStart = nil
                end
            end)
        end
    end)
    titleBar.InputChanged:Connect(function(input)
        if dragStart and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            self.Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            Config.Pos = {X = self.Frame.Position.X.Offset, Y = self.Frame.Position.Y.Offset}
            SaveConfig()
        end
    end)

    -- Resizing
    local resizeStart, resizePos
    local resizeHandle = Instance.new("TextButton")
    resizeHandle.Size = UDim2.new(0, 20, 0, 20)
    resizeHandle.Position = UDim2.new(1, -20, 1, -20)
    resizeHandle.BackgroundColor3 = self.Theme.Secondary
    resizeHandle.Text = Icons.resize
    resizeHandle.TextColor3 = self.Theme.Text
    resizeHandle.Font = Enum.Font.GothamBold
    resizeHandle.TextSize = 12
    resizeHandle.Parent = self.Frame
    local resizeCorner = Instance.new("UICorner", resizeHandle)
    resizeCorner.CornerRadius = UDim.new(0, 6)
    resizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizeStart = input.Position
            resizePos = self.Frame.Size
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    resizeStart = nil
                end
            end)
        end
    end)
    resizeHandle.InputChanged:Connect(function(input)
        if resizeStart and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - resizeStart
            local newSize = UDim2.new(0, math.max(self.MinSize.X.Offset, resizePos.X.Offset + delta.X), 0, math.max(self.MinSize.Y.Offset, resizePos.Y.Offset + delta.Y))
            self.Frame.Size = newSize
            content.Size = UDim2.new(1, -160, 1, 0)
            Config.Size = {W = newSize.X.Offset, H = newSize.Y.Offset}
            SaveConfig()
        end
    end)

    self.Tabs = {}
    self.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        self:UpdateSearch()
    end)

    self:UpdateTheme()
    return self
end

-- Add Tab
function Winuent:AddTab(opts)
    local tab = {Elements = {}}
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -8, 0, 36)
    btn.BackgroundColor3 = self.Theme.Primary
    btn.Text = (opts.Icon and Icons[opts.Icon] or "") .. "  " .. (opts.Title or "Tab")
    btn.TextColor3 = self.Theme.Text
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.Parent = self.Sidebar
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(function()
        for _, t in ipairs(self.Tabs) do
            t.Container.Visible = false
            t.Button.BackgroundColor3 = self.Theme.Primary
        end
        tab.Container.Visible = true
        btn.BackgroundColor3 = self.Theme.Accent
    end)

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.Visible = false
    container.Parent = self.Content
    local containerLayout = Instance.new("UIListLayout")
    containerLayout.Padding = UDim.new(0, 8)
    containerLayout.Parent = container

    tab.Button = btn
    tab.Container = container
    tab.Window = self
    if #self.Tabs == 0 then
        btn.BackgroundColor3 = self.Theme.Accent
        container.Visible = true
    end
    table.insert(self.Tabs, tab)

    -- Element Shortcuts
    tab.AddToggle = function(o) return self:MakeToggle(tab, o) end
    tab.AddButton = function(o) return self:MakeButton(tab, o) end
    tab.AddSlider = function(o) return self:MakeSlider(tab, o) end
    tab.AddDropdown = function(o) return self:MakeDropdown(tab, o) end
    tab.AddParagraph = function(o) return self:MakeParagraph(tab, o) end
    tab.AddKeybind = function(o) return self:MakeKeybind(tab, o) end
    tab.AddColorPicker = function(o) return self:MakeColorPicker(tab, o) end
    tab.AddSection = function(o) return self:MakeSection(tab, o) end
    tab.Notify = function(o) Notify(self, o) end

    return tab
end

-- Elements (WindUI-Style)
local ElementCorner = UDim.new(0, 8)

function Winuent:MakeToggle(tab, opts)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 32 * ScaleFactor)
    frame.BackgroundTransparency = 1
    frame.Parent = tab.Container

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50 * ScaleFactor, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = opts.Text or "Toggle"
    label.TextColor3 = self.Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextSize = 13 * ScaleFactor
    label.Font = Enum.Font.Gotham
    label.Parent = frame

    local switch = Instance.new("Frame")
    switch.Size = UDim2.new(0, 44 * ScaleFactor, 0, 22 * ScaleFactor)
    switch.Position = UDim2.new(1, -50 * ScaleFactor, 0.5, -11 * ScaleFactor)
    switch.BackgroundColor3 = self.Theme.Secondary
    switch.Parent = frame
    local switchCorner = Instance.new("UICorner", switch)
    switchCorner.CornerRadius = UDim.new(0, 11)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18 * ScaleFactor, 0, 18 * ScaleFactor)
    knob.Position = UDim2.new(0, 2 * ScaleFactor, 0.5, -9 * ScaleFactor)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.Parent = switch
    local knobCorner = Instance.new("UICorner", knob)
    knobCorner.CornerRadius = UDim.new(0, 9)

    local state = opts.Default or false
    local function update()
        TweenService:Create(switch, TweenInfo.new(0.2), {BackgroundColor3 = state and self.Theme.Accent or self.Theme.Secondary}):Play()
        TweenService:Create(knob, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -20 * ScaleFactor, 0.5, -9 * ScaleFactor) or UDim2.new(0, 2 * ScaleFactor, 0.5, -9 * ScaleFactor)}):Play()
        if opts.Callback then opts.Callback(state) end
    end
    update()

    switch.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            state = not state
            update()
        end
    end)

    table.insert(tab.Elements, {Frame = frame, Label = label})
    return frame
end

function Winuent:MakeButton(tab, opts)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32 * ScaleFactor)
    btn.BackgroundColor3 = self.Theme.Secondary
    btn.Text = opts.Text or "Button"
    btn.TextColor3 = self.Theme.Text
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13 * ScaleFactor
    btn.Parent = tab.Container
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = ElementCorner
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = self.Theme.Accent}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = self.Theme.Secondary}):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        if opts.Callback then opts.Callback() end
    end)

    table.insert(tab.Elements, {Frame = btn, Label = btn})
    return btn
end

function Winuent:MakeSlider(tab, opts)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50 * ScaleFactor)
    frame.BackgroundTransparency = 1
    frame.Parent = tab.Container

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -100 * ScaleFactor, 0, 20 * ScaleFactor)
    label.BackgroundTransparency = 1
    label.Text = opts.Text or "Slider"
    label.TextColor3 = self.Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextSize = 13 * ScaleFactor
    label.Font = Enum.Font.Gotham
    label.Parent = frame

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 80 * ScaleFactor, 0, 20 * ScaleFactor)
    valueLabel.Position = UDim2.new(1, -90 * ScaleFactor, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(opts.Default or opts.Min)
    valueLabel.TextColor3 = self.Theme.Accent
    valueLabel.TextSize = 13 * ScaleFactor
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.Parent = frame

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, 0, 0, 6 * ScaleFactor)
    track.Position = UDim2.new(0, 0, 0, 30 * ScaleFactor)
    track.BackgroundColor3 = self.Theme.Secondary
    track.Parent = frame
    local trackCorner = Instance.new("UICorner", track)
    trackCorner.CornerRadius = UDim.new(0, 3)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = self.Theme.Accent
    fill.Parent = track
    local fillCorner = Instance.new("UICorner", fill)
    fillCorner.CornerRadius = UDim.new(0, 3)

    local min = opts.Min or 0
    local max = opts.Max or 100
    local value = opts.Default or min
    local function update(v)
        value = math.clamp(v, min, max)
        local percent = (value - min) / (max - min)
        TweenService:Create(fill, TweenInfo.new(0.1), {Size = UDim2.new(percent, 0, 1, 0)}):Play()
        valueLabel.Text = tostring(math.floor(value))
        if opts.Callback then opts.Callback(value) end
    end
    update(value)

    local dragging = false
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    track.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    track.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local percent = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            update(min + (max - min) * percent)
        end
    end)

    table.insert(tab.Elements, {Frame = frame, Label = label})
    return frame
end

function Winuent:MakeDropdown(tab, opts)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 32 * ScaleFactor)
    frame.BackgroundTransparency = 1
    frame.Parent = tab.Container

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -120 * ScaleFactor, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = opts.Text or "Dropdown"
    label.TextColor3 = self.Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextSize = 13 * ScaleFactor
    label.Font = Enum.Font.Gotham
    label.Parent = frame

    local dropdownBtn = Instance.new("TextButton")
    dropdownBtn.Size = UDim2.new(0, 110 * ScaleFactor, 0, 28 * ScaleFactor)
    dropdownBtn.Position = UDim2.new(1, -116 * ScaleFactor, 0.5, -14 * ScaleFactor)
    dropdownBtn.BackgroundColor3 = self.Theme.Secondary
    dropdownBtn.Text = opts.Default or opts.Options[1] or "Select"
    dropdownBtn.TextColor3 = self.Theme.Text
    dropdownBtn.Font = Enum.Font.Gotham
    dropdownBtn.TextSize = 12 * ScaleFactor
    dropdownBtn.Parent = frame
    local dropdownCorner = Instance.new("UICorner", dropdownBtn)
    dropdownCorner.CornerRadius = UDim.new(0, 6)

    local list = Instance.new("Frame")
    list.Size = UDim2.new(0, 110 * ScaleFactor, 0, (#opts.Options or 0) * 28 * ScaleFactor)
    list.Position = UDim2.new(0, 0, 1, 2 * ScaleFactor)
    list.BackgroundColor3 = self.Theme.Primary
    list.Visible = false
    list.Parent = dropdownBtn
    local listCorner = Instance.new("UICorner", list)
    listCorner.CornerRadius = UDim.new(0, 6)

    for i, option in ipairs(opts.Options or {}) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, 0, 0, 28 * ScaleFactor)
        optBtn.Position = UDim2.new(0, 0, 0, (i - 1) * 28 * ScaleFactor)
        optBtn.BackgroundColor3 = self.Theme.Secondary
        optBtn.Text = option
        optBtn.TextColor3 = self.Theme.Text
        optBtn.Font = Enum.Font.Gotham
        optBtn.TextSize = 12 * ScaleFactor
        optBtn.Parent = list
        optBtn.MouseButton1Click:Connect(function()
            dropdownBtn.Text = option
            list.Visible = false
            if opts.Callback then opts.Callback(option) end
        end)
    end

    dropdownBtn.MouseButton1Click:Connect(function()
        list.Visible = not list.Visible
    end)

    table.insert(tab.Elements, {Frame = frame, Label = label})
    return frame
end

function Winuent:MakeParagraph(tab, opts)
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 0, 0)
    text.BackgroundTransparency = 1
    text.Text = opts.Text or "Paragraph"
    text.TextColor3 = self.Theme.Text
    text.TextSize = 12 * ScaleFactor
    text.TextWrapped = true
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.Font = Enum.Font.Gotham
    text.AutomaticSize = Enum.AutomaticSize.Y
    text.Parent = tab.Container

    table.insert(tab.Elements, {Frame = text, Label = text})
    return text
end

function Winuent:MakeKeybind(tab, opts)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 32 * ScaleFactor)
    frame.BackgroundTransparency = 1
    frame.Parent = tab.Container

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -80 * ScaleFactor, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = opts.Text or "Keybind"
    label.TextColor3 = self.Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextSize = 13 * ScaleFactor
    label.Font = Enum.Font.Gotham
    label.Parent = frame

    local keyBtn = Instance.new("TextButton")
    keyBtn.Size = UDim2.new(0, 70 * ScaleFactor, 0, 26 * ScaleFactor)
    keyBtn.Position = UDim2.new(1, -76 * ScaleFactor, 0.5, -13 * ScaleFactor)
    keyBtn.BackgroundColor3 = self.Theme.Secondary
    keyBtn.Text = opts.Default and opts.Default.Name or "None"
    keyBtn.TextColor3 = self.Theme.Text
    keyBtn.Font = Enum.Font.Gotham
    keyBtn.TextSize = 11 * ScaleFactor
    keyBtn.Parent = frame
    local keyCorner = Instance.new("UICorner", keyBtn)
    keyCorner.CornerRadius = UDim.new(0, 6)

    local binding = false
    keyBtn.MouseButton1Click:Connect(function()
        binding = true
        keyBtn.Text = "..."
    end)

    local connection
    connection = UserInputService.InputBegan:Connect(function(input)
        if binding and input.KeyCode ~= Enum.KeyCode.Unknown then
            binding = false
            keyBtn.Text = input.KeyCode.Name
            if opts.Callback then opts.Callback(input.KeyCode) end
            connection:Disconnect()
        end
    end)

    table.insert(tab.Elements, {Frame = frame, Label = label})
    return frame
end

function Winuent:MakeColorPicker(tab, opts)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 32 * ScaleFactor)
    frame.BackgroundTransparency = 1
    frame.Parent = tab.Container

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60 * ScaleFactor, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = opts.Text or "ColorPicker"
    label.TextColor3 = self.Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextSize = 13 * ScaleFactor
    label.Font = Enum.Font.Gotham
    label.Parent = frame

    local colorBtn = Instance.new("Frame")
    colorBtn.Size = UDim2.new(0, 50 * ScaleFactor, 0, 26 * ScaleFactor)
    colorBtn.Position = UDim2.new(1, -56 * ScaleFactor, 0.5, -13 * ScaleFactor)
    colorBtn.BackgroundColor3 = opts.Default or Color3.fromRGB(255, 255, 255)
    colorBtn.Parent = frame
    local colorCorner = Instance.new("UICorner", colorBtn)
    colorCorner.CornerRadius = UDim.new(0, 6)

    colorBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            -- Simple color picker popup (HSV slider)
            local picker = Instance.new("Frame")
            picker.Size = UDim2.new(0, 200 * ScaleFactor, 0, 150 * ScaleFactor)
            picker.Position = UDim2.new(0, colorBtn.AbsolutePosition.X, 0, colorBtn.AbsolutePosition.Y + 40 * ScaleFactor)
            picker.BackgroundColor3 = self.Theme.Primary
            picker.Parent = self.ScreenGui
            local pickerCorner = Instance.new("UICorner", picker)
            pickerCorner.CornerRadius = UDim.new(0, 8)

            -- HSV Sliders (simplified)
            local hSlider = Instance.new("Frame")
            hSlider.Size = UDim2.new(1, -16, 0, 20 * ScaleFactor)
            hSlider.Position = UDim2.new(0, 8, 0, 8)
            hSlider.BackgroundColor3 = self.Theme.Secondary
            hSlider.Parent = picker
            local hFill = Instance.new("Frame")
            hFill.Size = UDim2.new(0.5, 0, 1, 0)
            hFill.BackgroundColor3 = Color3.fromHSV(0.5, 1, 1)
            hFill.Parent = hSlider

            -- Drag for hue
            local hDragging = false
            hSlider.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then hDragging = true end end)
            hSlider.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then hDragging = false end end)
            hSlider.InputChanged:Connect(function(i)
                if hDragging then
                    local percent = math.clamp((i.Position.X - hSlider.AbsolutePosition.X) / hSlider.AbsoluteSize.X, 0, 1)
                    hFill.Size = UDim2.new(percent, 0, 1, 0)
                    local color = Color3.fromHSV(percent, 1, 1)
                    colorBtn.BackgroundColor3 = color
                    if opts.Callback then opts.Callback(color) end
                end
            end)

            picker.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 and not hSlider:IsAncestorOf(i.Target) then
                    picker:Destroy()
                end
            end)
        end
    end)

    table.insert(tab.Elements, {Frame = frame, Label = label})
    return frame
end

function Winuent:MakeSection(tab, opts)
    local header = Instance.new("TextButton")
    header.Size = UDim2.new(1, 0, 0, 28 * ScaleFactor)
    header.BackgroundColor3 = self.Theme.Primary
    header.Text = (opts.Icon and Icons[opts.Icon] or "") .. "  " .. (opts.Title or "Section")
    header.TextColor3 = self.Theme.Accent
    header.Font = Enum.Font.GothamBold
    header.TextSize = 13 * ScaleFactor
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Parent = tab.Container
    local headerCorner = Instance.new("UICorner", header)
    headerCorner.CornerRadius = ElementCorner

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 0, 0)
    content.BackgroundTransparency = 1
    content.Visible = opts.Open or false
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.Parent = tab.Container
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 6)
    contentLayout.Parent = content

    header.MouseButton1Click:Connect(function()
        content.Visible = not content.Visible
        header.Text = content.Visible and Icons.up .. "  " .. opts.Title or Icons.down .. "  " .. opts.Title
    end)

    return {
        Content = content,
        Add = function(_, type, o)
            local fn = tab["Add" .. type]
            if fn then return fn(o) end
        end
    }
end

-- Update Search
function Winuent:UpdateSearch()
    local query = self.SearchBox.Text:lower()
    for _, tab in ipairs(self.Tabs) do
        for _, element in ipairs(tab.Elements) do
            if element.Label then
                element.Frame.Visible = query == "" or element.Label.Text:lower():find(query)
            end
        end
    end
end

-- Update Theme (Animated)
function Winuent:UpdateTheme()
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad)
    TweenService:Create(self.Frame, tweenInfo, {BackgroundColor3 = self.Theme.Background}):Play()
    -- Update tabs, elements, etc. (recursive update for colors)
    for _, obj in ipairs(self.Frame:GetDescendants()) do
        if obj:IsA("Frame") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            if obj.BackgroundColor3 ~= Color3.new(1, 1, 1) then
                TweenService:Create(obj, tweenInfo, {BackgroundColor3 = self.Theme.Secondary}):Play()
            end
        end
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            TweenService:Create(obj, tweenInfo, {TextColor3 = self.Theme.Text}):Play()
        end
    end
end

return Winuent
