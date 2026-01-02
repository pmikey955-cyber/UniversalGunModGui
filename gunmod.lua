local player = game.Players.LocalPlayer
local currentGun = nil

-- Default universal modifiers (cross-over to any gun)
local universalModifiers = {
    Recoil = 0,
    Spread = 0,
    FireRate = 0
}

-- Apply universal modifiers to a gun
local function applyToGun(gun)
    if not gun then return end
    for stat, val in pairs(universalModifiers) do
        local prop = gun:FindFirstChild(stat)
        if prop and prop:IsA("NumberValue") then
            prop.Value = val
        end
    end
end

-- Update GUI when a new gun is equipped
local function updateGUI(gun)
    if not gun then return end
    for stat, _ in pairs(universalModifiers) do
        local prop = gun:FindFirstChild(stat)
        if prop then
            universalModifiers[stat] = prop.Value  -- read gun stats
            guiElements[stat].Value = prop.Value   -- update sliders/textboxes
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

-- Listen for gun equip/unequip
player.Character.ChildAdded:Connect(function(child)
    if child:IsA("Tool") then
        currentGun = child
        updateGUI(currentGun)
        applyToGun(currentGun)
    end
end)

-- Listen for GUI changes
for stat, slider in pairs(guiElements) do
    slider.Changed:Connect(function(val)
        universalModifiers[stat] = val
        applyToGun(currentGun)
    end)
end

-- Initial detection
detectGun()
