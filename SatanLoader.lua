local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local lunixGui = Instance.new('ScreenGui')
lunixGui.IgnoreGuiInset = true 
lunixGui.ResetOnSpawn = false 
lunixGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
lunixGui.Parent = LocalPlayer:WaitForChild('PlayerGui')

local lunixBackground = Instance.new('Frame')
lunixBackground.Size = UDim2.new(1, 0, 1, 0)
lunixBackground.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
lunixBackground.BorderSizePixel = 0
lunixBackground.Parent = lunixGui 

local lunixLogo = Instance.new('ImageLabel')
lunixLogo.Size = UDim2.new(0, 240, 0, 240)
lunixLogo.Position = UDim2.fromScale(0.5, 0.35)
lunixLogo.AnchorPoint = Vector2.new(0.5, 0.5)
lunixLogo.BackgroundTransparency = 1 
lunixLogo.Image = 'rbxassetid://96733690666731'
lunixLogo.ZIndex = 2
lunixLogo.Parent = lunixBackground

local lunixGlow = Instance.new("ImageLabel")
lunixGlow.Size = UDim2.new(0, 280, 0, 280)
lunixGlow.Position = UDim2.fromScale(0.5, 0.35)
lunixGlow.AnchorPoint = Vector2.new(0.5, 0.5)
lunixGlow.BackgroundTransparency = 1
lunixGlow.ImageTransparency = 1
lunixGlow.ImageColor3 = Color3.fromRGB(150, 0, 255)
lunixGlow.Image = "rbxassetid://4681617489"
lunixGlow.ZIndex = 1
lunixGlow.Parent = lunixBackground

local textContainer = Instance.new("Frame")
textContainer.AnchorPoint = Vector2.new(0.5, 0)
textContainer.Position = UDim2.fromScale(0.5, 0.55)
textContainer.Size = UDim2.new(0, 500, 0, 80)
textContainer.BackgroundTransparency = 1
textContainer.Parent = lunixBackground

local letters = {'L', 'U', 'N', 'I', 'X'}
local letterLabels = {}
local letterSpacing = 80

for i, letter in ipairs(letters) do
    local letterLabel = Instance.new("TextLabel")
    letterLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    letterLabel.Position = UDim2.new(0.5, (i - 3) * letterSpacing, 0.5, 0)
    letterLabel.Size = UDim2.new(0, 60, 0, 80)
    letterLabel.BackgroundTransparency = 1
    letterLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    letterLabel.Font = Enum.Font.GothamBold
    letterLabel.TextSize = 56
    letterLabel.Text = letter
    letterLabel.TextTransparency = 1
    letterLabel.TextStrokeTransparency = 0.5
    letterLabel.TextStrokeColor3 = Color3.fromRGB(150, 0, 255)
    letterLabel.ZIndex = 3
    letterLabel.Parent = textContainer
    
    table.insert(letterLabels, letterLabel)
end

local function pulseGlow()
    local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
    local glowTween = TweenService:Create(lunixGlow, tweenInfo, {
        ImageTransparency = 0.3,
        Size = UDim2.new(0, 300, 0, 300)
    })
    glowTween:Play()
end

local function glitchEffect()
    lunixGlow.ImageTransparency = 0.2
    lunixLogo.ImageColor3 = Color3.fromRGB(220, 200, 255)
    task.wait(0.05)
    lunixGlow.ImageTransparency = 1
    lunixLogo.ImageColor3 = Color3.fromRGB(255, 255, 255)
end

pulseGlow()

for i, letterLabel in ipairs(letterLabels) do
    task.wait((i - 1) * 0.15)
    local colors = {
        Color3.fromRGB(150, 0, 255),
        Color3.fromRGB(255, 0, 150),
        Color3.fromRGB(0, 200, 255),
        Color3.fromRGB(255, 255, 255)
    }
    letterLabel.TextColor3 = colors[math.random(1, #colors)]
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    TweenService:Create(letterLabel, tweenInfo, {
        TextTransparency = 0,
        Position = letterLabel.Position + UDim2.new(0, 0, 0, -10)
    }):Play()
    if math.random(1, 3) == 1 then
        glitchEffect()
    end
end

task.wait(2)

local fadeTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local fadeBackground = TweenService:Create(lunixBackground, fadeTweenInfo, {BackgroundTransparency = 1})
local fadeLogo = TweenService:Create(lunixLogo, fadeTweenInfo, {ImageTransparency = 1})
local fadeGlow = TweenService:Create(lunixGlow, fadeTweenInfo, {ImageTransparency = 1})

fadeBackground:Play()
fadeLogo:Play()
fadeGlow:Play()

for _, letterLabel in ipairs(letterLabels) do
    TweenService:Create(letterLabel, fadeTweenInfo, {TextTransparency = 1}):Play()
end

task.wait(0.6)

local function log(str)
    pcall(function()
        game.StarterGui:SetCore('SendNotification', {
            Title = 'Lunix Script',
            Text = str,
            Icon = 'rbxassetid://96733690666731',
            Duration = 4
        })
    end)
end

lunixGui:Destroy()

if game.PlaceId == 121864768012064 then 
    log('Successfully Loaded!')
    loadstring(game:HttpGet('https://raw.githubusercontent.com/dravenox/roblox/refs/heads/main/Lunix.lua'))()
elseif game.PlaceId == 101953168527257 then 
    loadstring(game:HttpGet('https://raw.githubusercontent.com/dravenox/roblox/refs/heads/main/spear.lua'))()
else
    log('Game Not Supported!')
end
