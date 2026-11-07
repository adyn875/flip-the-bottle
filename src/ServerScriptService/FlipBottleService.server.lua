local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local sharedFolder = ReplicatedStorage:WaitForChild("Shared")
local config = require(sharedFolder:WaitForChild("BottleFlipConfig"))

local remotesFolder = ReplicatedStorage:FindFirstChild("BottleFlipRemotes")
if not remotesFolder then
    remotesFolder = Instance.new("Folder")
    remotesFolder.Name = "BottleFlipRemotes"
    remotesFolder.Parent = ReplicatedStorage
end

local flipEvent = remotesFolder:FindFirstChild("BottleFlipEvent")
if not flipEvent then
    flipEvent = Instance.new("RemoteEvent")
    flipEvent.Name = "BottleFlipEvent"
    flipEvent.Parent = remotesFolder
end

local scoreEvent = remotesFolder:FindFirstChild("BottleFlipScoreEvent")
if not scoreEvent then
    scoreEvent = Instance.new("RemoteEvent")
    scoreEvent.Name = "BottleFlipScoreEvent"
    scoreEvent.Parent = remotesFolder
end

local arenaFolder = workspace:FindFirstChild("BottleArena")
if not arenaFolder then
    arenaFolder = Instance.new("Folder")
    arenaFolder.Name = "BottleArena"
    arenaFolder.Parent = workspace
end

local activeBottles = {}

local function buildArena()
    if arenaFolder:FindFirstChild("Ground") then
        return
    end

    local ground = Instance.new("Part")
    ground.Name = "Ground"
    ground.Size = config.ArenaSize
    ground.Position = Vector3.new(0, 0, 0)
    ground.Anchored = true
    ground.Material = Enum.Material.SmoothPlastic
    ground.Color = Color3.fromRGB(64, 162, 110)
    ground.Parent = arenaFolder

    local pad = Instance.new("Part")
    pad.Name = "LandingPad"
    pad.Size = Vector3.new(18, 1, 18)
    pad.Position = Vector3.new(0, 1, 0)
    pad.Anchored = true
    pad.Material = Enum.Material.Neon
    pad.Color = Color3.fromRGB(120, 190, 255)
    pad.Parent = arenaFolder
end

local function getPlayerBottlePosition(player)
    local playerNumber = #Players:GetPlayers()
    local row = math.floor((playerNumber - 1) / 4)
    local column = (playerNumber - 1) % 4
    local x = (column - 1.5) * 12
    local z = (row - 1.5) * 12
    return Vector3.new(x, config.SpawnHeight, z)
end

local function setPlayerSpawnPosition(character)
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local playerCount = #Players:GetPlayers()
    local index = 0
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character == character then
            index = table.find(Players:GetPlayers(), player) or 0
        end
    end

    local row = math.floor((index - 1) / 4)
    local column = (index - 1) % 4
    local x = (column - 1.5) * 12
    local z = (row - 1.5) * 12
    humanoidRootPart.CFrame = CFrame.new(x, 5, z)
end

local function createBottleForPlayer(player)
    local character = player.Character or player.CharacterAdded:Wait()
    local root = character:WaitForChild("HumanoidRootPart")

    local existingBottle = activeBottles[player]
    if existingBottle and existingBottle.Parent then
        existingBottle:Destroy()
    end

    local bottle = Instance.new("Part")
    bottle.Name = player.Name .. "_Bottle"
    bottle.Shape = Enum.PartType.Cylinder
    bottle.Size = Vector3.new(config.BottleRadius * 2, config.BottleHeight, config.BottleRadius * 2)
    bottle.Material = Enum.Material.SmoothPlastic
    bottle.Color = config.BottleColor
    bottle.Anchored = true
    bottle.CFrame = CFrame.new(root.Position + config.BottleOffset)
    bottle.Parent = arenaFolder

    activeBottles[player] = bottle
end

local function setScore(player, value)
    player:SetAttribute("BottleScore", value)
    scoreEvent:FireClient(player, value)
end

local function evaluateBottleLanding(player, bottle)
    local upVector = bottle.CFrame.UpVector
    local angle = math.deg(math.acos(math.clamp(upVector:Dot(Vector3.new(0, 1, 0)), -1, 1)))

    if angle <= config.LandingTolerance then
        local score = (player:GetAttribute("BottleScore") or 0) + config.ScorePerLanding
        setScore(player, score)
    else
        local score = math.max(0, (player:GetAttribute("BottleScore") or 0) - config.MissPenalty)
        setScore(player, score)
    end
end

local function flipBottle(player)
    local bottle = activeBottles[player]
    if not bottle then
        return
    end

    if bottle:GetAttribute("CoolingDown") then
        return
    end

    bottle:SetAttribute("CoolingDown", true)
    task.delay(config.FlipCooldown, function()
        bottle:SetAttribute("CoolingDown", false)
    end)

    local startCFrame = bottle.CFrame
    local endCFrame = startCFrame * CFrame.Angles(math.rad(1280), 0, 0)

    local tween = TweenService:Create(bottle, TweenInfo.new(config.FlipDuration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
        CFrame = endCFrame,
    })

    tween:Play()
    tween.Completed:Wait()
    evaluateBottleLanding(player, bottle)
    bottle.CFrame = startCFrame
end

local function onPlayerAdded(player)
    player:SetAttribute("BottleScore", 0)
    scoreEvent:FireClient(player, 0)

    player.CharacterAdded:Connect(function(character)
        task.wait(0.25)
        setPlayerSpawnPosition(character)
        createBottleForPlayer(player)
    end)

    if player.Character then
        createBottleForPlayer(player)
    end
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in ipairs(Players:GetPlayers()) do
    onPlayerAdded(player)
end

flipEvent.OnServerEvent:Connect(function(player)
    flipBottle(player)
end)

buildArena()
