-- Winuent UI
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Winuent = {}
Winuent.__index = Winuent

-- Themes
local Themes = {
    Default = {Background=Color3.fromRGB(24,24,24), Secondary=Color3.fromRGB(34,34,34), Accent=Color3.fromRGB(0,170,255), TextColor=Color3.fromRGB(255,255,255)},
    Cyan = {Background=Color3.fromRGB(20,20,20), Secondary=Color3.fromRGB(30,30,30), Accent=Color3.fromRGB(0,255,255), TextColor=Color3.fromRGB(255,255,255)},
    Bloom = {Background=Color3.fromRGB(24,24,24), Secondary=Color3.fromRGB(34,34,34), Accent=Color3.fromRGB(255,0,255), TextColor=Color3.fromRGB(255,255,255)},
    Light = {Background=Color3.fromRGB(245,245,245), Secondary=Color3.fromRGB(225,225,225), Accent=Color3.fromRGB(0,170,255), TextColor=Color3.fromRGB(0,0,0)}
}

-- Create basic instances function
local function Create(inst, parent, properties)
    local obj = Instance.new(inst)
    if parent then obj.Parent = parent end
    if properties then
        for k,v in pairs(properties) do
            obj[k] = v
        end
    end
    return obj
end

function Winuent:CreateWindow(args)
    local Window = {}
    Window.Tabs = {}
    Window.Theme = Themes[args.Theme] or Themes.Default

    -- Main Frame
    local MainFrame = Create("Frame", args.Parent or game.CoreGui, {
        Size = args.Size or UDim2.new(0,400,0,300),
        Position = args.Position or UDim2.new(0.5,-200,0.5,-150),
        BackgroundColor3 = Window.Theme.Background,
        BorderSizePixel = 0
    })
    Window.MainFrame = MainFrame

    -- Drag Bar
    local DragBar = Create("Frame", MainFrame, {
        Size = UDim2.new(1,0,0,30),
        BackgroundColor3 = Window.Theme.Secondary
    })

    local Title = Create("TextLabel", DragBar, {
        Text = args.Title or "Winuent UI",
        BackgroundTransparency = 1,
        TextColor3 = Window.Theme.TextColor,
        Size = UDim2.new(1,-60,1,0),
        Position = UDim2.new(0,5,0,0),
        Font = Enum.Font.SourceSansBold,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Minimize Button
    local MinBtn = Create("TextButton", DragBar, {
        Text = "-",
        TextColor3 = Window.Theme.TextColor,
        BackgroundColor3 = Window.Theme.Accent,
        Size = UDim2.new(0,30,0,30),
        Position = UDim2.new(1,-35,0,0),
        Font = Enum.Font.SourceSansBold,
        TextSize = 20
    })

    local isMinimized = false
    local lastSize = MainFrame.Size
    MinBtn.MouseButton1Click:Connect(function()
        if isMinimized then
            MainFrame:TweenSize(lastSize,"Out","Quad",0.3,true)
            isMinimized = false
        else
            lastSize = MainFrame.Size
            MainFrame:TweenSize(UDim2.new(lastSize.X.Scale, lastSize.X.Offset, 0,30),"Out","Quad",0.3,true)
            isMinimized = true
        end
    end)

    -- Dragging
    local dragging, dragInput, dragStart, startPos
    DragBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
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
    DragBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- Tabs Container
    local TabsFrame = Create("Frame", MainFrame, {
        Size = UDim2.new(1,0,1,-30),
        Position = UDim2.new(0,0,0,30),
        BackgroundTransparency = 1
    })
    Window.TabsFrame = TabsFrame

    function Window:CreateTab(name)
        local Tab = {Sections={}}
        local TabFrame = Create("Frame", TabsFrame, {
            Size = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1,
            Visible = true
        })
        Tab.TabFrame = TabFrame

        function Tab:CreateSection(title)
            local Section = {}
            local SecFrame = Create("Frame", TabFrame, {
                Size = UDim2.new(1,0,0,100),
                BackgroundColor3 = Window.Theme.Secondary,
                BorderSizePixel = 0
            })
            local SecTitle = Create("TextLabel", SecFrame, {
                Text = title,
                BackgroundTransparency = 1,
                TextColor3 = Window.Theme.TextColor,
                Font = Enum.Font.SourceSansBold,
                TextSize = 16,
                Position = UDim2.new(0,5,0,5)
            })
            Section.Frame = SecFrame

            function Section:CreateButton(btnText, callback)
                local Btn = Create("TextButton", SecFrame, {
                    Text = btnText,
                    Size = UDim2.new(1,-10,0,25),
                    Position = UDim2.new(0,5,0,30 + #SecFrame:GetChildren()*30),
                    BackgroundColor3 = Window.Theme.Accent,
                    TextColor3 = Window.Theme.TextColor,
                    Font = Enum.Font.SourceSansBold,
                    TextSize = 16
                })
                Btn.MouseButton1Click:Connect(callback)
            end

            function Section:CreateToggle(toggleText, callback)
                local Tgl = Create("TextButton", SecFrame, {
                    Text = "[OFF] "..toggleText,
                    Size = UDim2.new(1,-10,0,25),
                    Position = UDim2.new(0,5,0,30 + #SecFrame:GetChildren()*30),
                    BackgroundColor3 = Window.Theme.Accent,
                    TextColor3 = Window.Theme.TextColor,
                    Font = Enum.Font.SourceSansBold,
                    TextSize = 16
                })
                local state = false
                Tgl.MouseButton1Click:Connect(function()
                    state = not state
                    Tgl.Text = (state and "[ON] " or "[OFF] ")..toggleText
                    callback(state)
                end)
            end

            table.insert(Tab.Sections, Section)
            return Section
        end

        table.insert(Window.Tabs, Tab)
        return Tab
    end

    return Window
end

return Winuent
