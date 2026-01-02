local Players = game:GetService("Players")
local player = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Modifier storage
local modifiers = {
    recoil = 1,
    spread = 1,
    fireRate = 1,
    damage = 1
}

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GunModGUI"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 180)
mainFrame.Position = UDim2.new(0, 50, 0, 50)
mainFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Title bar
local titleBar = Instance.new("TextLabel")
titleBar.Size = UDim2.new(1,0,0,25)
titleBar.BackgroundColor3 = Color3.fromRGB(35,35,35)
titleBar.Text = "Gun Modifiers ▼"
titleBar.TextColor3 = Color3.new(1,1,1)
titleBar.TextScaled = true
titleBar.Parent = mainFrame

-- Drag functionality
local dragging, dragInput, dragStart, startPos

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Collapse/expand functionality
local collapsed = false
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1,0,1,-25)
contentFrame.Position = UDim2.new(0,0,0,25)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

titleBar.MouseButton1Click:Connect(function()
    collapsed = not collapsed
    contentFrame.Visible = not collapsed
    titleBar.Text = collapsed and "Gun Modifiers ▲" or "Gun Modifiers ▼"
end)

-- Function to create modifier textboxes
local function createTextbox(name, default, posY)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 30)
    frame.Position = UDim2.new(0, 5, 0, posY)
    frame.BackgroundColor3 = Color3.fromRGB(60,60,60)
    frame.Parent = contentFrame

    local label = Instance.new("TextLabel")
    label.Text = name..": "..default
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,1,1)
    label.TextScaled = true
    label.Parent = frame

    local textbox = Instance.new("TextBox")
    textbox.Size = UDim2.new(0.35, 0, 1, 0)
    textbox.Position = UDim2.new(0.62, 0, 0, 0)
    textbox.Text = tostring(default)
    textbox.ClearTextOnFocus = false
    textbox.Parent = frame

    textbox.FocusLost:Connect(function()
        local num = tonumber(textbox.Text)
        if num then
            modifiers[name:lower()] = num
            label.Text = name..": "..num
        else
            textbox.Text = tostring(modifiers[name:lower()])
        end
    end)
end

createTextbox("Recoil", 1, 10)
createTextbox("Spread", 1, 50)
createTextbox("FireRate", 1, 90)
createTextbox("Damage", 1, 130)

-- Apply modifiers to tools
local function applyMods(tool)
    if not tool:IsA("Tool") then return end
    for stat, value in pairs(modifiers) do
        if tool:FindFirstChild(stat) then
            tool[stat].Value = value
        end
    end
end

-- Watch character for new tools
local function watchCharacter(char)
    char.ChildAdded:Connect(applyMods)
    for _, tool in ipairs(char:GetChildren()) do
        applyMods(tool)
    end
end

-- Backpack monitoring
player.Backpack.ChildAdded:Connect(applyMods)

-- Track respawn
player.CharacterAdded:Connect(function(char)
    wait(1)
    watchCharacter(char)
end)

-- Initial run
if player.Character then
    watchCharacter(player.Character)
end

-- Constantly re-apply
RunService.RenderStepped:Connect(function()
    if player.Character then
        for _, tool in ipairs(player.Character:GetChildren()) do
            applyMods(tool)
        end
    end
end)
