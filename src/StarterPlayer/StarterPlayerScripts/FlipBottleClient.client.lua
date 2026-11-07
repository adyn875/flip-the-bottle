local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local remotesFolder = ReplicatedStorage:WaitForChild("BottleFlipRemotes")
local flipEvent = remotesFolder:WaitForChild("BottleFlipEvent")
local scoreEvent = remotesFolder:WaitForChild("BottleFlipScoreEvent")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BottleFlipGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(320, 110)
panel.Position = UDim2.new(0.5, -160, 1, -140)
panel.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
panel.BackgroundTransparency = 0.15
panel.BorderSizePixel = 0
panel.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0.3, 0)
title.Position = UDim2.new(0, 10, 0, 8)
title.Text = "Flip the Bottle"
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextAlignment = Enum.TextXAlignment.Center
title.BackgroundTransparency = 1
title.Parent = panel

local scoreLabel = Instance.new("TextLabel")
scoreLabel.Size = UDim2.new(1, -20, 0.3, 0)
scoreLabel.Position = UDim2.new(0, 10, 0.32, 0)
scoreLabel.Text = "Score: 0"
scoreLabel.TextScaled = true
scoreLabel.Font = Enum.Font.GothamMedium
scoreLabel.TextColor3 = Color3.fromRGB(255, 220, 120)
scoreLabel.TextAlignment = Enum.TextXAlignment.Center
scoreLabel.BackgroundTransparency = 1
scoreLabel.Parent = panel

local prompt = Instance.new("TextLabel")
prompt.Size = UDim2.new(1, -20, 0.3, 0)
prompt.Position = UDim2.new(0, 10, 0.62, 0)
prompt.Text = "Press F or click to flip"
prompt.TextScaled = true
prompt.Font = Enum.Font.Gotham
prompt.TextColor3 = Color3.fromRGB(220, 220, 220)
prompt.TextAlignment = Enum.TextXAlignment.Center
prompt.BackgroundTransparency = 1
prompt.Parent = panel

scoreEvent.OnClientEvent:Connect(function(score)
    scoreLabel.Text = "Score: " .. tostring(score)
end)

local function flipBottle()
    flipEvent:FireServer()
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then
        return
    end

    if input.KeyCode == Enum.KeyCode.F or input.UserInputType == Enum.UserInputType.MouseButton1 then
        flipBottle()
    end
end)
