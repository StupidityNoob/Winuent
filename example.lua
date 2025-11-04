local Winuent = loadstring(game:HttpGet("https://raw.githubusercontent.com/StupidityNoob/Winuent/main/main.lua"))()

-- === CREATE WINDOW ===
local win = Winuent:CreateWindow{
    Title = "Winuent UI v4.1 - Full Example",
    Size = UDim2.fromOffset(620, 480),
    Acrylic = true,
    Theme = "Dark"
}

-- === MAIN TAB ===
local main = win:AddTab{Title = "Main", Icon = "home"}

-- Toggle
main:AddToggle{
    Text = "God Mode",
    Default = false,
    Callback = function(state)
        print("God Mode:", state)
        main:Notify{Title = "Toggle", Content = "God Mode is now " .. (state and "ON" or "OFF"), Duration = 2}
    end
}

-- Slider
main:AddSlider{
    Text = "Walk Speed",
    Min = 16, Max = 300, Default = 16,
    Callback = function(value)
        if game.Players.LocalPlayer.Character then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
        end
    end
}

-- Button
main:AddButton{
    Text = "Heal Player",
    Callback = function()
        if game.Players.LocalPlayer.Character then
            local hum = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum then hum.Health = hum.MaxHealth end
        end
        main:Notify{Title = "Healed", Content = "Full health restored!", Duration = 2}
    end
}

-- Dropdown
main:AddDropdown{
    Text = "Teleport To",
    Options = {"Spawn", "Safe Zone", "Roof", "Random"},
    Default = "Spawn",
    Callback = function(choice)
        local pos = Vector3.new(0, 5, 0)
        if choice == "Safe Zone" then pos = Vector3.new(100, 50, 100)
        elseif choice == "Roof" then pos = Vector3.new(0, 200, 0)
        elseif choice == "Random" then pos = Vector3.new(math.random(-200,200), 50, math.random(-200,200)) end
        
        if game.Players.LocalPlayer.Character then
            game.Players.LocalPlayer.Character:MoveTo(pos)
        end
    end
}

-- Keybind
main:AddKeybind{
    Text = "Fly Toggle",
    Default = Enum.KeyCode.F,
    Callback = function(key)
        print("Fly key pressed:", key.Name)
        main:Notify{Title = "Keybind", Content = "Fly activated with " .. key.Name, Duration = 2}
    end
}

-- ColorPicker
main:AddColorPicker{
    Text = "ESP Color",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(color)
        print("ESP Color:", color)
    end
}

-- Paragraph
main:AddParagraph{
    Text = "Welcome to Winuent UI v4.1! This is a hybrid of WindUI & Fluent. Fully open-source, mobile-ready, and packed with features."
}

-- === SECTION TAB ===
local player = win:AddTab{Title = "Player", Icon = "user"}

local section = player:AddSection{Title = "Advanced Controls", Icon = "settings", Open = true}

section:Add("Toggle", {
    Text = "Noclip",
    Default = false,
    Callback = function(state)
        print("Noclip:", state)
    end
})

section:Add("Slider", {
    Text = "Jump Power",
    Min = 50, Max = 200, Default = 50,
    Callback = function(value)
        if game.Players.LocalPlayer.Character then
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = value
        end
    end
})

section:Add("Button", {
    Text = "Reset Character",
    Callback = function()
        if game.Players.LocalPlayer.Character then
            game.Players.LocalPlayer.Character:BreakJoints()
        end
    end
})

-- === NOTIFICATION TEST ===
delay(1, function()
    win:Notify{
        Title = "Winuent UI Loaded!",
        Content = "All features are working. Resize, search, toggle theme!",
        Duration = 4
    }
end)

-- === THEME TOGGLE DEMO ===
-- (Already in title bar — click sun/moon)

print("Winuent UI Example Loaded!")
