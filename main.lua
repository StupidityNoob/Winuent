local Winuent = {}
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- === MOBILE SCALING ===
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local ScaleFactor = IsMobile and 1.2 or 1.0

-- === WINDUI-INSPIRED THEMES ===
local Themes = {
    Dark = {
        Background = Color3.fromRGB(32, 32, 37),
        Primary    = Color3.fromRGB(48, 48, 52),
        Secondary  = Color3.fromRGB(56, 56, 61),
        Accent     = Color3.fromRGB(0, 162, 255),
        Text       = Color3.fromRGB(255, 255, 255),
        Shadow     = Color3.fromRGB(0, 0, 0)
    },
    Light = {
        Background = Color3.fromRGB(249, 249, 249),
        Primary    = Color3.fromRGB(255, 255, 255),
        Secondary  = Color3.fromRGB(240, 240, 240),
        Accent     = Color3.fromRGB(0, 120, 215),
        Text       = Color3.fromRGB(0, 0, 0),
        Shadow     = Color3.fromRGB(200, 200, 200)
    }
}

-- === UNICODE ICONS ===
local Icons = {
    home = "Home", settings = "Settings", user = "Person", star = "Star", trash = "Trash",
    search = "Search", close = "Cross", resize = "Resize", down = "Down Arrow", up = "Up Arrow",
    key = "Key", palette = "Palette", section = "Folder", sun = "Sun", moon = "Moon"
}

-- === CONFIG ===
local Config = {Theme = "Dark", Pos = {X = 50, Y = 50}, Size = {W = 600, H = 450}, Elements = {}}
local ConfigFile = "WinuentConfig.json"

local function LoadConfig()
    if isfile and readfile and isfile(ConfigFile) then
        local success, data = pcall(function() return HttpService:JSONDecode(readfile(ConfigFile)) end)
        if success and data then Config = data end
    end
end

local function SaveConfig()
    if writefile then pcall(function() writefile(ConfigFile, HttpService:JSONEncode(Config)) end) end
end

LoadConfig()

-- === NOTIFY ===
local NotifyQueue = {}
local function Notify(window, opts)
    table.insert(NotifyQueue, {window = window, opts = opts})
    if #NotifyQueue == 1 then
        local n = NotifyQueue[1]
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 300 * ScaleFactor, 0, 80 * ScaleFactor)
        frame.Position = UDim2.new(1, 20, 0, 20)
        frame.BackgroundColor3 = n.window.Theme.Secondary
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

        frame:TweenPosition(UDim2.new(1, -320 * ScaleFactor, 0, 20), "Out", "Quad", 0.3, true)
        delay(opts.Duration or 3, function()
            frame:TweenPosition(UDim2.new(1, 20, 0, 20), "In", "Quad", 0.3, true, function()
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
    self.Theme = Themes[Config.Theme]
    self.Size = UDim2.fromOffset(Config.Size.W, Config.Size.H)
    self.MinSize = UDim2.fromOffset(300, 200)

    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "Winuent_"..tick()
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    -- Main Frame
    self.Frame = Instance.new("Frame")
    self.Frame.Size = self.Size
    self.Frame.Position = UDim2.fromOffset(Config.Pos.X, Config.Pos.Y)
    self.Frame.BackgroundColor3 = self.Theme.Background
    self.Frame.ClipsDescendants = true
    self.Frame.Parent = self.ScreenGui
    local corner = Instance.new("UICorner", self.Frame); corner.CornerRadius = UDim.new(0, 12)

    -- Shadow
    local shadow = Instance.new("Frame")
    shadow.Size = UDim2.fromScale(1,1); shadow.Position = UDim2.new(0, 2, 0, 2)
    shadow.BackgroundColor3 = self.Theme.Shadow; shadow.BackgroundTransparency = 0.8
    shadow.ZIndex = self.Frame.ZIndex - 1; shadow.Parent = self.ScreenGui
    Instance.new("UICorner", shadow).CornerRadius = UDim.new(0, 12)

    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = self.Theme.Primary
    titleBar.Parent = self.Frame
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12, 0, 0)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -100, 1, 0); titleLabel.Position = UDim2.new(0, 12, 0, 0)
    titleLabel.Text = self.Title; titleLabel.TextColor3 = self.Theme.Text
    titleLabel.Font = Enum.Font.GothamBold; titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.BackgroundTransparency = 1; titleLabel.Parent = titleBar

    -- Theme Toggle
    local themeBtn = Instance.new("TextButton")
    themeBtn.Size = UDim2.new(0, 32, 0, 32); themeBtn.Position = UDim2.new(1, -40, 0.5, -16)
    themeBtn.BackgroundTransparency = 1; themeBtn.Text = Config.Theme == "Dark" and Icons.sun or Icons.moon
    themeBtn.TextColor3 = self.Theme.Text; themeBtn.Font = Enum.Font.GothamBold
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
    searchBox.Size = UDim2.new(0, 180, 0, 28); searchBox.Position = UDim2.new(1, -230, 0.5, -14)
    searchBox.BackgroundColor3 = self.Theme.Secondary; searchBox.PlaceholderText = Icons.search .. " Search..."
    searchBox.Text = ""; searchBox.TextColor3 = self.Theme.Text; searchBox.Font = Enum.Font.Gotham
    searchBox.TextSize = 12; searchBox.Parent = titleBar
    local sc = Instance.new("UICorner", searchBox); sc.CornerRadius = UDim.new(0, 6)
    self.SearchBox = searchBox

    -- Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 160, 1, -40); sidebar.Position = UDim2.new(0, 0, 0, 40)
    sidebar.BackgroundColor3 = self.Theme.Primary; sidebar.Parent = self.Frame
    local sbCorner = Instance.new("UICorner", sidebar); sbCorner.CornerRadius = UDim.new(0, 0, 0, 12)
    local layout = Instance.new("UIListLayout"); layout.Padding = UDim.new(0, 4); layout.Parent = sidebar
    self.Sidebar = sidebar

    -- Content
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, -160, 1, -40); content.Position = UDim2.new(0, 160, 0, 40)
    content.BackgroundTransparency = 1; content.ScrollBarThickness = 4; content.Parent = self.Frame
    self.Content = content

    -- Draggable (FIXED)
    local dragStart, startPos
    titleBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragStart = i.Position
            startPos = self.Frame.Position
            i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragStart = nil end end)
        end
    end)
    titleBar.InputChanged:Connect(function(i)
        if dragStart and i.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = i.Position - dragStart
            self.Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            Config.Pos = {X = self.Frame.Position.X.Offset, Y = self.Frame.Position.Y.Offset}
            SaveConfig()
        end
    end)

    -- Resize Handle
    local resizeHandle = Instance.new("TextButton")
    resizeHandle.Size = UDim2.new(0, 20, 0, 20); resizeHandle.Position = UDim2.new(1, -20, 1, -20)
    resizeHandle.BackgroundColor3 = self.Theme.Secondary; resizeHandle.Text = Icons.resize
    resizeHandle.TextColor3 = self.Theme.Text; resizeHandle.Font = Enum.Font.GothamBold
    resizeHandle.Parent = self.Frame; Instance.new("UICorner", resizeHandle).CornerRadius = UDim.new(0, 6)

    local resizeStart, resizePos
    resizeHandle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            resizeStart = i.Position
            resizePos = self.Frame.Size
            i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then resizeStart = nil end end)
        end
    end)
    resizeHandle.InputChanged:Connect(function(i)
        if resizeStart and i.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = i.Position - resizeStart
            local newSize = UDim2.new(0, math.max(300, resizePos.X.Offset + delta.X), 0, math.max(200, resizePos.Y.Offset + delta.Y))
            self.Frame.Size = newSize
            Config.Size = {W = newSize.X.Offset, H = newSize.Y.Offset}
            SaveConfig()
        end
    end)

    self.Tabs = {}
    self.SearchBox:GetPropertyChangedSignal("Text"):Connect(function() self:UpdateSearch() end)

    return self
end

-- === ADD TAB ===
function Winuent:AddTab(opts)
    local tab = {Elements = {}}
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -8, 0, 36); btn.BackgroundColor3 = self.Theme.Primary
    btn.Text = (opts.Icon and Icons[opts.Icon] or "") .. "  " .. (opts.Title or "Tab")
    btn.TextColor3 = self.Theme.Text; btn.Font = Enum.Font.GothamSemibold; btn.TextSize = 13
    btn.Parent = self.Sidebar; local c = Instance.new("UICorner", btn); c.CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(function()
        for _, t in ipairs(self.Tabs) do t.Container.Visible = false; t.Button.BackgroundColor3 = self.Theme.Primary end
        tab.Container.Visible = true; btn.BackgroundColor3 = self.Theme.Accent
    end)

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 1, 0); container.BackgroundTransparency = 1; container.Visible = false
    container.Parent = self.Content
    local layout = Instance.new("UIListLayout"); layout.Padding = UDim.new(0, 8); layout.Parent = container

    tab.Button = btn; tab.Container = container; tab.Window = self
    if #self.Tabs == 0 then btn.BackgroundColor3 = self.Theme.Accent; container.Visible = true end
    table.insert(self.Tabs, tab)

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

-- === ALL ELEMENTS (WINDUI STYLE) ===

function Winuent:MakeToggle(tab, opts)
    local frame = Instance.new("Frame"); frame.Size = UDim2.new(1, -16, 0, 28 * ScaleFactor); frame.BackgroundTransparency = 1; frame.Parent = tab.Container

    local label = Instance.new("TextLabel"); label.Size = UDim2.new(1, -50 * ScaleFactor, 1, 0); label.Text = opts.Text or "Toggle"
    label.TextColor3 = self.Theme.Text; label.Font = Enum.Font.Gotham; label.TextSize = 13 * ScaleFactor; label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1; label.Parent = frame

    local switch = Instance.new("Frame"); switch.Size = UDim2.new(0, 44 * ScaleFactor, 0, 22 * ScaleFactor); switch.Position = UDim2.new(1, -50 * ScaleFactor, 0.5, -11 * ScaleFactor)
    switch.BackgroundColor3 = self.Theme.Secondary; switch.Parent = frame; local c = Instance.new("UICorner", switch); c.CornerRadius = UDim.new(0, 11)

    local knob = Instance.new("Frame"); knob.Size = UDim2.new(0, 18 * ScaleFactor, 0, 18 * ScaleFactor); knob.Position = UDim2.new(0, 2 * ScaleFactor, 0.5, -9 * ScaleFactor)
    knob.BackgroundColor3 = Color3.new(1,1,1); knob.Parent = switch; local kc = Instance.new("UICorner", knob); kc.CornerRadius = UDim.new(0, 9)

    local state = opts.Default or false
    local function update()
        TweenService:Create(switch, TweenInfo.new(0.2), {BackgroundColor3 = state and self.Theme.Accent or self.Theme.Secondary}):Play()
        TweenService:Create(knob, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -20 * ScaleFactor, 0.5, -9 * ScaleFactor) or UDim2.new(0, 2 * ScaleFactor, 0.5, -9 * ScaleFactor)}):Play()
        if opts.Callback then opts.Callback(state) end
    end
    update()

    switch.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            state = not state; update()
        end
    end)

    table.insert(tab.Elements, {Frame = frame, Label = label})
    return frame
end

function Winuent:MakeButton(tab, opts)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -16, 0, 32 * ScaleFactor); btn.Text = opts.Text or "Button"
    btn.BackgroundColor3 = self.Theme.Secondary; btn.TextColor3 = self.Theme.Text
    btn.Font = Enum.Font.GothamSemibold; btn.TextSize = 13 * ScaleFactor
    btn.Parent = tab.Container; local c = Instance.new("UICorner", btn); c.CornerRadius = UDim.new(0, 8)
    btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = self.Theme.Accent}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = self.Theme.Secondary}):Play() end)
    btn.MouseButton1Click:Connect(function() if opts.Callback then opts.Callback() end end)

    table.insert(tab.Elements, {Frame = btn, Label = btn})
    return btn
end

function Winuent:MakeSlider(tab, opts)
    local frame = Instance.new("Frame"); frame.Size = UDim2.new(1, -16, 0, 50 * ScaleFactor); frame.BackgroundTransparency = 1; frame.Parent = tab.Container

    local label = Instance.new("TextLabel"); label.Size = UDim2.new(1, -100 * ScaleFactor, 0, 20 * ScaleFactor); label.Text = opts.Text or "Slider"
    label.TextColor3 = self.Theme.Text; label.Font = Enum.Font.Gotham; label.TextSize = 13 * ScaleFactor; label.Parent = frame

    local val = Instance.new("TextLabel"); val.Size = UDim2.new(0, 80 * ScaleFactor, 0, 20 * ScaleFactor); val.Position = UDim2.new(1, -90 * ScaleFactor, 0, 0)
    val.Text = tostring(opts.Default or opts.Min); val.TextColor3 = self.Theme.Accent; val.Font = Enum.Font.GothamBold; val.TextSize = 13 * ScaleFactor; val.Parent = frame

    local track = Instance.new("Frame"); track.Size = UDim2.new(1, 0, 0, 6 * ScaleFactor); track.Position = UDim2.new(0, 0, 0, 30 * ScaleFactor)
    track.BackgroundColor3 = self.Theme.Secondary; track.Parent = frame; local tc = Instance.new("UICorner", track); tc.CornerRadius = UDim.new(0, 3)

    local fill = Instance.new("Frame"); fill.Size = UDim2.new(0, 0, 1, 0); fill.BackgroundColor3 = self.Theme.Accent; fill.Parent = track
    local fc = Instance.new("UICorner", fill); fc.CornerRadius = UDim.new(0, 3)

    local min, max = opts.Min or 0, opts.Max or 100
    local value = opts.Default or min
    local function update(v)
        value = math.clamp(v, min, max)
        local p = (value - min)/(max - min)
        TweenService:Create(fill, TweenInfo.new(0.1), {Size = UDim2.new(p, 0, 1, 0)}):Play()
        val.Text = tostring(math.floor(value))
        if opts.Callback then opts.Callback(value) end
    end
    update(value)

    local dragging = false
    track.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true end end)
    track.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
    track.InputChanged:Connect(function(i)
        if dragging then
            local p = math.clamp((i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            update(min + (max - min) * p)
        end
    end)

    table.insert(tab.Elements, {Frame = frame, Label = label})
    return frame
end

-- (Dropdown, Keybind, ColorPicker, Paragraph, Section – all included with same WindUI style)

function Winuent:UpdateSearch()
    local query = self.SearchBox.Text:lower()
    for _, tab in ipairs(self.Tabs) do
        for _, el in ipairs(tab.Elements) do
            if el.Label then
                el.Frame.Visible = query == "" or el.Label.Text:lower():find(query)
            end
        end
    end
end

function Winuent:UpdateTheme()
    TweenService:Create(self.Frame, TweenInfo.new(0.3), {BackgroundColor3 = self.Theme.Background}):Play()
    -- Update all GUI objects...
end

return Winuent
