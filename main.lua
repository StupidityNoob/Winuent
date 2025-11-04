-- Winuent UI v1.0 | WindUI + Fluent Hybrid | One-File Version
-- Paste this entire script into a GitHub repo as `main.lua`

local Winuent = {}
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

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

-- === ICONS (Material Style) ===
local Icons = {
    home = "Home", settings = "Settings", user = "Person", star = "Star", trash = "Delete"
}

-- === NOTIFICATION QUEUE ===
local NotifyQueue = {}

local function Notify(window, opts)
    table.insert(NotifyQueue, {window = window, opts = opts})
    if #NotifyQueue == 1 then
        local n = NotifyQueue[1]
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 300, 0, 80)
        frame.Position = UDim2.new(1, 20, 1, -100)
        frame.BackgroundColor3 = n.window.Theme.Background
        frame.Parent = n.window.ScreenGui

        local corner = Instance.new("UICorner", frame); corner.CornerRadius = UDim.new(0, 8)
        local title = Instance.new("TextLabel", frame)
        title.Size = UDim2.new(1, -16, 0, 24); title.Position = UDim2.new(0, 8, 0, 8)
        title.Text = opts.Title; title.TextColor3 = n.window.Theme.Accent
        title.Font = Enum.Font.GothamBold

        local content = Instance.new("TextLabel", frame)
        content.Size = UDim2.new(1, -16, 0, 30); content.Position = UDim2.new(0, 8, 0, 32)
        content.Text = opts.Content; content.TextColor3 = n.window.Theme.Text
        content.TextWrapped = true

        frame:TweenPosition(UDim2.new(1, -320, 1, -100), "Out", "Quad", 0.3, true)
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
    self.Size = options.Size or UDim2.fromOffset(560, 420)
    self.Theme = options.Theme and Themes[options.Theme] or Themes.Dark
    self.Acrylic = options.Acrylic ~= false

    -- ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "Winuent_"..tick()
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    -- Main Frame
    self.Frame = Instance.new("Frame")
    self.Frame.Size = self.Size
    self.Frame.Position = UDim2.fromOffset(100, 100)
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
    titleBar.Size = UDim2.new(1,0,0,36)
    titleBar.BackgroundColor3 = self.Theme.Primary
    titleBar.Text = self.Title
    titleBar.TextColor3 = self.Theme.Text
    titleBar.Font = Enum.Font.GothamBold
    titleBar.Parent = self.Frame

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
            local delta = i.Position - (i.Position - self.Frame.AbsolutePosition)
            self.Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                           startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    self.Tabs = {}
    self.TabButtons = {}

    return self
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

    -- === ELEMENT SHORTCUTS ===
    tab.AddToggle = function(o) return self:MakeToggle(tab, o) end
    tab.AddSlider = function(o) return self:MakeSlider(tab, o) end
    tab.AddButton = function(o) return self:MakeButton(tab, o) end
    tab.AddDropdown = function(o) return self:MakeDropdown(tab, o) end
    tab.AddParagraph = function(o) return self:MakeParagraph(tab, o) end
    tab.Notify = function(o) Notify(self, o) end

    return tab
end

-- === ELEMENTS (All in one file!) ===

function Winuent:MakeButton(tab, opts)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -12, 0, 32)
    btn.BackgroundColor3 = tab.Window.Theme.Secondary
    btn.Text = opts.Text or "Button"
    btn.TextColor3 = tab.Window.Theme.Text
    btn.Font = Enum.Font.GothamSemibold
    btn.AutoButtonColor = false
    btn.Parent = tab.Container
    local c = Instance.new("UICorner", btn); c.CornerRadius = UDim.new(0,6)
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = tab.Window.Theme.Accent end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = tab.Window.Theme.Secondary end)
    btn.MouseButton1Click:Connect(function() if opts.Callback then opts.Callback() end end)
    return btn
end

function Winuent:MakeToggle(tab, opts)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -12, 0, 32)
    frame.BackgroundTransparency = 1
    frame.Parent = tab.Container

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Text = opts.Text or "Toggle"
    label.TextColor3 = tab.Window.Theme.Text
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local switch = Instance.new("Frame")
    switch.Size = UDim2.new(0, 44, 0, 22)
    switch.Position = UDim2.new(1, -50, 0.5, -11)
    switch.BackgroundColor3 = tab.Window.Theme.Secondary
    switch.Parent = frame
    local c = Instance.new("UICorner", switch); c.CornerRadius = UDim.new(0,11)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = UDim2.new(0, 2, 0.5, -9)
    knob.BackgroundColor3 = Color3.new(1,1,1)
    knob.Parent = switch
    local kc = Instance.new("UICorner", knob); kc.CornerRadius = UDim.new(0,9)

    local state = opts.Default or false
    local function update()
        switch.BackgroundColor3 = state and tab.Window.Theme.Accent or tab.Window.Theme.Secondary
        knob.Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        if opts.Callback then opts.Callback(state) end
    end
    update()

    switch.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            state = not state
            update()
        end
    end)

    return frame
end

function Winuent:MakeSlider(tab, opts)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -12, 0, 50)
    frame.BackgroundTransparency = 1
    frame.Parent = tab.Container

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -100, 0, 20)
    label.Text = opts.Text or "Slider"
    label.TextColor3 = tab.Window.Theme.Text
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local val = Instance.new("TextLabel")
    val.Size = UDim2.new(0, 80, 0, 20)
    val.Position = UDim2.new(1, -90, 0, 0)
    val.Text = tostring(opts.Default or opts.Min)
    val.TextColor3 = tab.Window.Theme.Accent
    val.Font = Enum.Font.GothamBold
    val.Parent = frame

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -12, 0, 6)
    track.Position = UDim2.new(0, 6, 0, 30)
    track.BackgroundColor3 = tab.Window.Theme.Secondary
    track.Parent = frame
    local tc = Instance.new("UICorner", track); tc.CornerRadius = UDim.new(0,3)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = tab.Window.Theme.Accent
    fill.Parent = track
    local fc = Instance.new("UICorner", fill); fc.CornerRadius = UDim.new(0,3)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.BackgroundColor3 = Color3.new(1,1,1)
    knob.Parent = track
    local kc = Instance.new("UICorner", knob); kc.CornerRadius = UDim.new(0,8)

    local min, max = opts.Min or 0, opts.Max or 100
    local value = opts.Default or min
    local function update(v)
        value = math.clamp(v, min, max)
        local p = (value - min)/(max - min)
        fill.Size = UDim2.new(p, 0, 1, 0)
        knob.Position = UDim2.new(p, -8, 0.5, -8)
        val.Text = tostring(math.floor(value))
        if opts.Callback then opts.Callback(value) end
    end
    update(value)

    local dragging = false
    track.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
    track.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    track.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local p = (i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
            update(min + (max - min) * p)
        end
    end)

    return frame
end

-- (Add Dropdown & Paragraph the same way — or skip if you want minimal)

return Winuent
