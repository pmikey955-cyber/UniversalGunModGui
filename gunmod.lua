--// UNIVERSAL GUN MOD GUI //--
local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "GunModGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Draggable frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 200)
frame.Position = UDim2.new(0.5, -125, 0.5, -100)
frame.BackgroundColor3 = Color3.fromRGB(35,35,35)
frame.BorderSizePixel = 0
frame.Parent = gui
frame.Active = true
frame.Draggable = true

-- Collapse button
local collapseBtn = Instance.new("TextButton")
collapseBtn.Size = UDim2.new(0, 25, 0, 25)
collapseBtn.Position = UDim2.new(1, -30, 0, 5)
collapseBtn.Text = "▼"
collapseBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
collapseBtn.BorderSizePixel = 0
collapseBtn.Parent = frame

local collapsed = false
collapseBtn.MouseButton1Click:Connect(function()
    collapsed = not collapsed
    for _, child in ipairs(frame:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") and child ~= collapseBtn then
            child.Visible = not collapsed
        end
    end
    collapseBtn.Text = collapsed and "▲" or "▼"
end)

-- Labels and sliders
local function createSlider(name, y)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 100, 0, 25)
    lbl.Position = UDim2.new(0, 10, 0, y)
    lbl.Text = name..": 0"
    lbl.TextColor3 = Color3.fromRGB(255,255,255)
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local slider = Instance.new("Slider")
    slider.Size = UDim2.new(0, 130, 0, 20)
    slider.Position = UDim2.new(0, 110, 0, y+2)
    slider.Min = 0
    slider.Max = 100
    slider.Value = 0
    slider.Parent = frame

    slider.Changed:Connect(function(val)
        lbl.Text = name..": "..math.floor(val)
    end)

    return slider
end

-- Using simple NumberValues instead of Slider object (roblox doesnt have built-in sliders)  
-- We'll use TextBoxes for numeric input instead for compatibility  
local function createTextBox(name, y)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 100, 0, 25)
    lbl.Position = UDim2.new(0, 10, 0, y)
    lbl.Text = name..":"
    lbl.TextColor3 = Color3.fromRGB(255,255,255)
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0, 130, 0, 25)
    box.Position = UDim2.new(0, 110, 0, y)
    box.BackgroundColor3 = Color3.fromRGB(50,50,50)
    box.TextColor3 = Color3.fromRGB(255,255,255)
    box.Text = "0"
    box.ClearTextOnFocus = false
    box.Parent = frame

    return box
end

-- Create GUI elements
local recoilBox = createTextBox("Recoil", 40)
local spreadBox = createTextBox("Spread", 80)
local fireRateBox = createTextBox("FireRate", 120)

local guiElements = {
    Recoil = recoilBox,
    Spread = spreadBox,
    FireRate = fireRateBox
}

-- Universal modifiers that carry across guns
local universalModifiers = {
    Recoil = 0,
    Spread = 0,
    FireRate = 0
}

local currentGun = nil

-- Apply modifiers to gun
local function applyToGun(gun)
    if not gun then return end
    for stat, val in pairs(universalModifiers) do
        local prop = gun:FindFirstChild(stat)
        if prop and prop:IsA("NumberValue") then
            prop.Value = val
        end
    end
end

-- Update GUI display to show gun values
local function updateGUI(gun)
    if not gun then return end
    for stat, box in pairs(guiElements) do
        local prop = gun:FindFirstChild(stat)
        if prop then
            universalModifiers[stat] = prop.Value
            box.Text = tostring(prop.Value)
        end
    end
end

-- Detect equipped gun
local function detectGun()
    local char = player.Character
    if not char then return end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            currentGun = tool
            updateGUI(currentGun)
            applyToGun(currentGun)
            break
        end
    end
end

-- Listen for gun equip
player.Character.ChildAdded:Connect(function(child)
    if child:IsA("Tool") then
        currentGun = child
        updateGUI(currentGun)
        applyToGun(currentGun)
    end
end)

-- GUI input listeners
for stat, box in pairs(guiElements) do
    box.FocusLost:Connect(function(enterPressed)
        local val = tonumber(box.Text)
        if val then
            universalModifiers[stat] = val
            applyToGun(currentGun)
        else
            box.Text = tostring(universalModifiers[stat])
        end
    end)
end

-- Initial detection
detectGun()
