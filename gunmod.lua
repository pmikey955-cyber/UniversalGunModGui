-- Universal Gun Mod GUI (Recoil, Spread, FireRate)
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Table to store your chosen values
local ModValues = {
    Recoil = 0,
    Spread = 0,
    FireRate = 0
}

-- Simple GUI creation
local ScreenGui = Instance.new("ScreenGui", Player:WaitForChild("PlayerGui"))
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 220, 0, 150)
Frame.Position = UDim2.new(0.05,0,0.3,0)
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.Active = true
Frame.Draggable = true

local function makeSlider(name, default, yPos)
    local lbl = Instance.new("TextLabel", Frame)
    lbl.Text = name..": "..default
    lbl.Position = UDim2.new(0,10,0, yPos)
    lbl.Size = UDim2.new(0,200,0,20)
    lbl.TextColor3 = Color3.fromRGB(255,255,255)
    lbl.BackgroundTransparency = 1

    local txt = Instance.new("TextBox", Frame)
    txt.Text = tostring(default)
    txt.Position = UDim2.new(0,10,0,yPos+20)
    txt.Size = UDim2.new(0,200,0,25)
    txt.BackgroundColor3 = Color3.fromRGB(60,60,60)
    txt.TextColor3 = Color3.fromRGB(255,255,255)

    txt.FocusLost:Connect(function(enterPressed)
        local val = tonumber(txt.Text)
        if val then
            ModValues[name] = val
            lbl.Text = name..": "..val
        else
            txt.Text = tostring(ModValues[name])
        end
    end)
end

makeSlider("Recoil", 0, 10)
makeSlider("Spread", 0, 60)
makeSlider("FireRate", 0, 110)

-- Function to patch guns
local function PatchGun(gun)
    if not gun then return end
    for _, field in pairs({"Recoil","Spread","FireRate"}) do
        if gun[field] ~= nil then
            gun[field] = ModValues[field]
        end
    end
end

-- Check all current and future guns
local function MonitorGuns(container)
    container.ChildAdded:Connect(function(tool)
        RunService.Heartbeat:Wait()
        PatchGun(tool)
    end)
    for _, tool in pairs(container:GetChildren()) do
        PatchGun(tool)
    end
end

MonitorGuns(Player.Backpack)
MonitorGuns(Player.Character or Player.CharacterAdded:Wait())
Player.CharacterAdded:Connect(function(char)
    MonitorGuns(char)
end)

-- Continuously apply values in case guns change
RunService.Heartbeat:Connect(function()
    for _, tool in pairs(Player.Backpack:GetChildren()) do
        PatchGun(tool)
    end
    if Player.Character then
        for _, tool in pairs(Player.Character:GetChildren()) do
            PatchGun(tool)
        end
    end
end)
