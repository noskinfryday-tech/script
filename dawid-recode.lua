-- Main Aimbot Loop
local function StartAimbot()
    if AimbotConnection then
        AimbotConnection:Disconnect()
    end
    
    AimbotConnection = RunService.Heartbeat:Connect(function()
        if not AimbotConfig.Enabled then
            return
        end
        
        AimbotTarget = GetClosestPlayer()
        if AimbotTarget then
            AimAt(AimbotTarget)
        end
    end)
end

local function StopAimbot()
    if AimbotConnection then
        AimbotConnection:Disconnect()
        AimbotConnection = nil
    end
    AimbotTarget = nil
end

-- Toggle Function
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == AimbotConfig.ToggleKey then
        AimbotConfig.Enabled = not AimbotConfig.Enabled
        
        if AimbotConfig.Enabled then
            StartAimbot()
            print("Aimbot Enabled")
        else
            StopAimbot()
            print("Aimbot Disabled")
        end
    end
end)

-- Auto-start
if AimbotConfig.Enabled then
    StartAimbot()
end

-- GUI (Optional)
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local StatusLabel = Instance.new("TextLabel")

ScreenGui.Name = "AimbotGUI"
ScreenGui.Parent = gethui and gethui() or game.CoreGui

Frame.Name = "MainFrame"
Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.BorderSizePixel = 0
Frame.Position = UDim2.new(0, 10, 0, 10)
Frame.Size = UDim2.new(0, 200, 0, 80)

Title.Name = "Title"
Title.Parent = Frame
Title.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
Title.BorderSizePixel = 0
Title.Size = UDim2.new(1, 0, 0, 25)
Title.Font = Enum.Font.SourceSansBold
Title.Text = "Aimbot"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14

StatusLabel.Name = "Status"
StatusLabel.Parent = Frame
StatusLabel.BackgroundTransparency = 1
StatusLabel.Position = UDim2.new(0, 5, 0, 30)
StatusLabel.Size = UDim2.new(1, -10, 0, 45)
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.Text = "Status: " .. (AimbotConfig.Enabled and "Enabled" or "Disabled") .. "\nToggle Key: " .. AimbotConfig.ToggleKey.Name
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.TextSize = 12
StatusLabel.TextYAlignment = Enum.TextYAlignment.Top

-- Update status
RunService.Heartbeat:Connect(function()
    StatusLabel.Text = "Status: " .. (AimbotConfig.Enabled and "Enabled" or "Disabled") .. "\nToggle Key: " .. AimbotConfig.ToggleKey.Name .. "\nTarget: " .. (AimbotTarget and AimbotTarget.Name or "None")
end)
