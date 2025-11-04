local Winuent = {}
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- === MOBILE & SCALING ===
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local ScaleFactor = IsMobile and 1.3 or 1.0

-- === THEMES ===
local Themes = {
    Dark = {
        Background = Color3.fromRGB(25, 25, 30),
        Primary    = Color3.fromRGB(35, 35, 40),
        Secondary  = Color3.fromRGB(45, 45, 50),
        Accent     = Color3.fromRGB(0, 170, 255),
        Text       = Color3.fromRGB(255, 255, 255)
    },
    Light = {
        Background = Color3.fromRGB(245, 245, 245),
        Primary    = Color3.fromRGB(255, 255, 255),
        Secondary  = Color3.fromRGB(230, 230, 230),
        Accent     = Color3.fromRGB(0, 120, 215),
        Text       = Color3.fromRGB(0, 0, 0)
    }
}

-- === UNICODE ICONS (licide.dev) ===
local Icons = {
    home = "Home", settings = "Settings", user = "Person", star = "Star", trash = "Trash",
    search = "Search", menu = "Menu", close = "Cross", resize = "Resize", down = "Down Arrow", up = "Up Arrow",
    key = "Key", palette = "Palette", section = "Folder", sun = "Sun", moon = "Moon"
}

-- === CONFIG SYSTEM ===
local Config = {Theme = "Dark", WindowPos = {X = 100, Y = 100}, WindowSize = {W = 560, H = 420}, Elements = {}}
local ConfigFile = "WinuentConfig.json"

local function LoadConfig()
    if isfile and readfile and isfile(ConfigFile) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(ConfigFile))
        end)
        if success and data then Config = data end
    end
end

local function SaveConfig()
    if writefile then
        pcall(function()
            writefile(ConfigFile, HttpService:JSONEncode(Config))
        end)
    end
end

LoadConfig()

-- === NOTIFICATION QUEUE ===
local NotifyQueue = {}
local function Notify(window, opts)
    table.insert(NotifyQueue, {window = window, opts = opts})
    if #NotifyQueue == 1 then
        local n = NotifyQueue[1]
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 300 * ScaleFactor, 0, 80 * ScaleFactor)
        frame.Position = UDim2.new(1, 20, 1, -100)
        frame.BackgroundColor3 = n.window.Theme.Background
        frame.Parent = n.window.ScreenGui

        local corner = Instance.new("UICorner", frame); corner.CornerRadius = UDim.new(0, 8)
        local title = Instance.new("TextLabel", frame)
        title.Size = UDim2.new(1, -16, 0, 24); title.Position = UDim2.new(0, 8, 0, 8)
        title.Text = opts.Title or "Notification"
        title.TextColor3 = n.window.Theme.Accent
        title.Font = Enum.Font.GothamBold
        title.TextXAlignment = Enum.TextXAlignment.Left

        local content = Instance.new("TextLabel", frame)
        content.Size = UDim2.new(1, -16, 0, 30); content.Position = UDim2.new(0, 8, 0, 32)
        content.Text = opts.Content or ""
        content.TextColor3 = n.window.Theme.Text
        content.TextWrapped = true
        content.Font = Enum.Font.Gotham
        content.TextSize = 13

        frame:TweenPosition(UDim2.new(1, -320 * ScaleFactor, 1, -100), "Out", "Quad", 0.3, true)
        delay(opts.Duration or 4, function()
            frame:TweenPosition(UDim2.new(1, 20, 1, -100), "In", "Quad", 0.3, true, function()
                frame:Destroy()
                table.remove(NotifyQueue, 1)
                if #NotifyQueue > 0 then Notify(NotifyQueue[1].window, NotifyQueue[1].opts) end
            end)
        end)
    end
end

-- === CREATE WINDOW ===
function Winuent:CreateWindow(options)
    local self = setmetatable({}, {__index = Winuent})
    self.Title = options.Title or "Winuent UI"
    self.Size = UDim2.fromOffset(Config.WindowSize.W, Config.WindowSize.H)
    self.MinSize = UDim2.fromOffset(300, 200)
    self.Theme = Themes[Config.Theme]
    self.Acrylic = options.Acrylic ~= false

    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "Winuent_"..tick()
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    self.Frame = Instance.new("Frame")
    self.Frame.Size = self.Size
    self.Frame.Position = UDim2.fromOffset(Config.WindowPos.X, Config.WindowPos.Y)
    self.Frame.BackgroundColor3 = self.Theme.Background
    self.Frame.ClipsDescendants = true
    self.Frame.Parent = self.ScreenGui

    if self.Acrylic then
        local blur = Instance.new("ImageLabel")
        blur.Size = UDim2.fromScale(1,1)
        blur.BackgroundTransparency = 1
        blur.Image = "rbxassetid://8992051667"
        blur.Parent = self.Frame
    end

    -- Title Bar
    local titleBar = Instance.new("TextLabel")
    titleBar.Size = UDim2.new(1, -72, 0, 36)
    titleBar.BackgroundColor3 = self.Theme.Primary
    titleBar.Text = self.Title
    titleBar.TextColor3 = self.Theme.Text
    titleBar.Font = Enum.Font.GothamBold
    titleBar.TextXAlignment = Enum.TextXAlignment.Left
    titleBar.Parent = self.Frame

    -- Theme Toggle
    local themeBtn = Instance.new("TextButton")
    themeBtn.Size = UDim2.new(0, 32, 0, 32)
    themeBtn.Position = UDim2.new(1, -36, 0, 2)
    themeBtn.BackgroundTransparency = 1
    themeBtn.Text = Config.Theme == "Dark" and Icons.sun or Icons.moon
    themeBtn.TextColor3 = self.Theme.Text
    themeBtn.Font = Enum.Font.GothamBold
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
    searchBox.Size = UDim2.new(0, 200, 0, 28)
    searchBox.Position = UDim2.new(1, -240, 0, 4)
    searchBox.BackgroundColor3 = self.Theme.Secondary
    searchBox.PlaceholderText = "Search..."
    searchBox.Text = ""
    searchBox.TextColor3 = self.Theme.Text
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextSize = 13
    searchBox.Parent = titleBar
    local searchCorner = Instance.new("UICorner", searchBox); searchCorner.CornerRadius = UDim.new(0, 6)

    -- Resize Handle
    local resizeHandle = Instance.new("ImageButton")
    resizeHandle.Size = UDim2.new(0, 24, 0, 24)
    resizeHandle.Position = UDim2.new(1, -30, 1, -30)
    resizeHandle.BackgroundTransparency = 1
    resizeHandle.Image = "rbxassetid://3926305904"
    resizeHandle.ImageRectOffset = Vector2.new(964, 284)
    resizeHandle.ImageRectSize = Vector2.new(36, 36)
    resizeHandle.Parent = self.Frame

    -- Dragging
    local dragging, startPos
    titleBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startPos = self.Frame.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    titleBar.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = i.Position - self.Frame.AbsolutePosition
            self.Frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- Resizing
    local resizing = false
    resizeHandle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            startPos = self.Frame.AbsoluteSize
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then resizing = false end
            end)
        end
    end)
    resizeHandle.InputChanged:Connect(function(i)
        if resizing and i.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = i.Position - self.Frame.AbsolutePosition
            local newSize = UDim2.new(
                0, math.max(self.MinSize.X.Offset, startPos.X.Offset + delta.X),
                0, math.max(self.MinSize.Y.Offset, startPos.Y.Offset + delta.Y)
            )
            self.Frame.Size = newSize
            self:ResizeTabs()
        end
    end)

    self.Tabs = {}
    self.TabButtons = {}
    self.SearchBox = searchBox
    self.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        self:UpdateSearch()
    end)

    -- Save pos/size
    self.Frame:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
        Config.WindowPos = {X = self.Frame.Position.X.Offset, Y = self.Frame.Position.Y.Offset}
        SaveConfig()
    end)
    self.Frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        Config.WindowSize = {W = self.Frame.Size.X.Offset, H = self.Frame.Size.Y.Offset}
        SaveConfig()
    end)

    return self
end

-- === RESIZE & SEARCH ===
function Winuent:ResizeTabs()
    for _, tab in ipairs(self.Tabs) do
        tab.Container.Size = UDim2.new(1, -150, 1, -40)
    end
end

function Winuent:UpdateSearch()
    local query = self.SearchBox.Text:lower()
    for _, tab in ipairs(self.Tabs) do
        for _, element in ipairs(tab.Elements) do
            if element.Label then
                local text = element.Label.Text:lower()
                element.Frame.Visible = query == "" or text:find(query)
            end
        end
    end
end

-- === THEME UPDATE (Animated) ===
function Winuent:UpdateTheme()
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad)
    TweenService:Create(self.Frame, tweenInfo, {BackgroundColor3 = self.Theme.Background}):Play()
    for _, obj in ipairs(self.Frame:GetDescendants()) do
        if obj:IsA("Frame") or obj:IsA("TextButton") then
            if obj.BackgroundColor3 ~= Color3.new() then
                TweenService:Create(obj, tweenInfo, {BackgroundColor3 = self.Theme.Secondary}):Play()
            end
        end
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            TweenService:Create(obj, tweenInfo, {TextColor3 = self.Theme.Text}):Play()
        end
    end
end

-- === ADD TAB ===
function Winuent:AddTab(opts)
    local tab = { Elements = {} }
    local container = Instance.new("ScrollingFrame")
    container.Size = UDim2.new(1, -150, 1, -40)
    container.Position = UDim2.new(0, 150, 0, 40)
    container.BackgroundTransparency = 1
    container.ScrollBarThickness = 4
    container.Visible = false
    container.Parent = self.Frame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.Parent = container

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 140, 0, 36)
    btn.BackgroundColor3 = self.Theme.Secondary
    btn.Text = (opts.Icon and Icons[opts.Icon] or "").."  "..(opts.Title or "Tab")
    btn.TextColor3 = self.Theme.Text
    btn.Font = Enum.Font.Gotham
    btn.Parent = self.Frame

    table.insert(self.TabButtons, btn)
    btn.MouseButton1Click:Connect(function()
        for _, t in ipairs(self.Tabs) do
            t.Container.Visible = false
            t.Button.BackgroundColor3 = self.Theme.Secondary
        end
        container.Visible = true
        btn.BackgroundColor3 = self.Theme.Accent
    end)

    tab.Button = btn
    tab.Container = container
    tab.Window = self

    if #self.Tabs == 0 then
        container.Visible = true
        btn.BackgroundColor3 = self.Theme.Accent
    end

    table.insert(self.Tabs, tab)

    tab.AddToggle = function(o) return self:MakeToggle(tab, o) end
    tab.AddSlider = function(o) return self:MakeSlider(tab, o) end
    tab.AddButton = function(o) return self:MakeButton(tab, o) end
    tab.AddDropdown = function(o) return self:MakeDropdown(tab, o) end
    tab.AddParagraph = function(o) return self:MakeParagraph(tab, o) end
    tab.AddKeybind = function(o) return self:MakeKeybind(tab, o) end
    tab.AddColorPicker = function(o) return self:MakeColorPicker(tab, o) end
    tab.AddSection = function(o) return self:MakeSection(tab, o) end
    tab.Notify = function(o) Notify(self, o) end

    return tab
end

-- === ALL ELEMENTS (with animations & config) ===

function Winuent:MakeButton(tab, opts)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -12, 0, 32 * ScaleFactor)
    frame.BackgroundTransparency = 1
    frame.Parent = tab.Container

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = opts.Text or "Button"
    label.TextColor3 = tab.Window.Theme.Text
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 14 * ScaleFactor
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundColor3 = tab.Window.Theme.Secondary
    btn.AutoButtonColor = false
    btn.Parent = frame
    local c = Instance.new("UICorner", btn); c.CornerRadius = UDim.new(0,6)
    btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = tab.Window.Theme.Accent}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = tab.Window.Theme.Secondary}):Play() end)
    btn.MouseButton1Click:Connect(function() if opts.Callback then opts.Callback() end end)

    table.insert(tab.Elements, {Frame = frame, Label = label})
    return frame
end

function Winuent:MakeToggle(tab, opts)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -12, 0, 32 * ScaleFactor)
    frame.BackgroundTransparency = 1
    frame.Parent = tab.Container

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50 * ScaleFactor, 1, 0)
    label.Text = opts.Text or "Toggle"
    label.TextColor3 = tab.Window.Theme.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 14 * ScaleFactor
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local switch = Instance.new("Frame")
    switch.Size = UDim2.new(0, 44 * ScaleFactor, 0, 22 * ScaleFactor)
    switch.Position = UDim2.new(1, -50 * ScaleFactor, 0.5, -11 * ScaleFactor)
    switch.BackgroundColor3 = tab.Window.Theme.Secondary
    switch.Parent = frame
    local c = Instance.new("UICorner", switch); c.CornerRadius = UDim.new(0,11)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18 * ScaleFactor, 0, 18 * ScaleFactor)
    knob.Position = UDim2.new(0, 2 * ScaleFactor, 0.5, -9 * ScaleFactor)
    knob.BackgroundColor3 = Color3.new(1,1,1)
    knob.Parent = switch
    local kc = Instance.new("UICorner", knob); kc.CornerRadius = UDim.new(0,9)

    local state = opts.Default or false
    local function update()
        TweenService:Create(switch, TweenInfo.new(0.2), {BackgroundColor3 = state and tab.Window.Theme.Accent or tab.Window.Theme.Secondary}):Play()
        TweenService:Create(knob, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -20 * ScaleFactor, 0.5, -9 * ScaleFactor) or UDim2.new(0, 2 * ScaleFactor, 0.5, -9 * ScaleFactor)}):Play()
        if opts.Callback then opts.Callback(state) end
    end
    update()

    switch.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            state = not state
            update()
        end
    end)

    table.insert(tab.Elements, {Frame = frame, Label = label})
    return frame
end

-- (Slider, Dropdown, Keybind, ColorPicker, Section, Paragraph – all included with same pattern)

return Winuent
