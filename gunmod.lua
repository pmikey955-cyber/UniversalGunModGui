local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RunService = game:GetService("RunService")

local modifiers = {
    Damage = 10,
    FireRate = 1,
    Range = 50
}

local screenGui = Instance.new("ScreenGui", Player:WaitForChild("PlayerGui"))
screenGui.Name = "GunModGUI"

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 250)
frame.Position = UDim2.new(0.3,0,0.3,0)
frame.BackgroundColor3 = Color3.fromRGB(35,35,35)
frame.BorderSizePixel = 0
frame.Parent = screenGui


local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.BackgroundColor3 = Color3.fromRGB(25,25,25)
title.Text = "Gun Modifiers ▼"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.Parent = frame

local collapsed = false
title.MouseButton1Click:Connect(function()
    collapsed = not collapsed
    modifiersFrame.Visible = not collapsed
    title.Text = "Gun Modifiers " .. (collapsed and "▲" or "▼")
end)

local modifiersFrame = Instance.new("Frame")
modifiersFrame.Position = UDim2.new(0,0,0,30)
modifiersFrame.Size = UDim2.new(1,0,1, -30)
modifiersFrame.BackgroundTransparency = 1
modifiersFrame.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0,5)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = modifiersFrame

local function createModifierInput(name, default)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 40)
    container.BackgroundTransparency = 0.5
    container.BackgroundColor3 = Color3.fromRGB(45,45,45)
    container.Parent = modifiersFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4,0,1,0)
    label.Text = name
    label.TextColor3 = Color3.new(1,1,1)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.SourceSans
    label.TextSize = 16
    label.Parent = container

    local input = Instance.new("TextBox")
    input.Size = UDim2.new(0.55,0,1,0)
    input.Position = UDim2.new(0.45,0,0,0)
    input.Text = tostring(default)
    input.TextColor3 = Color3.new(1,1,1)
    input.BackgroundColor3 = Color3.fromRGB(30,30,30)
    input.ClearTextOnFocus = false
    input.Font = Enum.Font.SourceSans
    input.TextSize = 16
    input.Parent = container

    input.FocusLost:Connect(function(enterPressed)
        local num = tonumber(input.Text)
        if num then
            modifiers[name] = num
            if Player.Character then
                for _, gun in pairs(Player.Character:GetChildren()) do
                    if gun:IsA("Tool") then
                        if gun:FindFirstChild(name) then
                            gun[name].Value = num
                        end
                    end
                end
            end
        else
            input.Text = tostring(modifiers[name])
        end
    end)
end

for name, value in pairs(modifiers) do
    createModifierInput(name, value)
end

local function applyModifiers(gun)
    for name, value in pairs(modifiers) do
        if gun:FindFirstChild(name) and gun[name]:IsA("NumberValue") then
            gun[name].Value = value
        end
    end
end

local function onGunAdded(gun)
    if gun:IsA("Tool") then
        applyModifiers(gun)
        gun.AncestryChanged:Connect(function(_, parent)
            if not parent then return end
            if parent:IsA("Backpack") or parent:IsA("Model") then
                applyModifiers(gun)
            end
        end)
    end
end

Player.Backpack.ChildAdded:Connect(onGunAdded)
Player.CharacterAdded:Connect(function(char)
    char.ChildAdded:Connect(onGunAdded)
end)

for _, gun in pairs(Player.Backpack:GetChildren()) do
    onGunAdded(gun)
end
if Player.Character then
    for _, gun in pairs(Player.Character:GetChildren()) do
        onGunAdded(gun)
    end
end

local dragging = false
local dragInput, mousePos, framePos

local function update(input)
    local delta = input.Position - mousePos
    frame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
end

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        mousePos = input.Position
        framePos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

RunService.RenderStepped:Connect(function()
    if dragging and dragInput then
        update(dragInput)
    end
end)
