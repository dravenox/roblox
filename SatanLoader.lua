local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SatanScript"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game:GetService('Players').LocalPlayer:WaitForChild("PlayerGui")

local Logo = Instance.new("ImageLabel")
Logo.Size = UDim2.new(0, 120, 0, 120)
Logo.Position = UDim2.new(0.5, 0, 0.3, 0)
Logo.AnchorPoint = Vector2.new(0.5, 0.5)
Logo.BackgroundTransparency = 1
Logo.Image = "rbxassetid://109030636181557"
Logo.ImageColor3 = Color3.fromRGB(255, 255, 255)
Logo.Parent = ScreenGui

local BarBg = Instance.new("Frame")
BarBg.Size = UDim2.new(0, 400, 0, 10)
BarBg.Position = UDim2.new(0.5, 0, 0.55, 0)
BarBg.AnchorPoint = Vector2.new(0.5, 0.5)
BarBg.BackgroundColor3 = Color3.fromRGB(40, 0, 60)
BarBg.BorderSizePixel = 0
BarBg.Parent = ScreenGui

local BarBgCorner = Instance.new("UICorner")
BarBgCorner.CornerRadius = UDim.new(0, 5)
BarBgCorner.Parent = BarBg

local Bar = Instance.new("Frame")
Bar.Size = UDim2.new(0, 0, 1, 0)
Bar.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
Bar.BorderSizePixel = 0
Bar.Parent = BarBg

local BarCorner = Instance.new("UICorner")
BarCorner.CornerRadius = UDim.new(0, 5)
BarCorner.Parent = Bar

local PercentText = Instance.new("TextLabel")
PercentText.Size = UDim2.new(0, 80, 0, 30)
PercentText.Position = UDim2.new(0.5, 0, 0.60, 0)
PercentText.AnchorPoint = Vector2.new(0.5, 0.5)
PercentText.BackgroundTransparency = 1
PercentText.Text = "0%"
PercentText.Font = Enum.Font.GothamBold
PercentText.TextSize = 18
PercentText.TextColor3 = Color3.fromRGB(200, 100, 255)
PercentText.Parent = ScreenGui

function log(str: string)
		pcall(function()
				game.StarterGui:SetCore('SendNotification', {
						Title = 'Satan Script',
						Text = str,
						Icon = 'rbxassetid://109030636181557',
						Duration = 4
				})
		end)
end

spawn(function()
    for i = 0, 100, 1 do
        wait(0.04)
        Bar:TweenSize(UDim2.new(i/100, 0, 1, 0), "Out", "Quad", 0.1, true)
        PercentText.Text = i .. "%"
        if math.random(1, 8) == 1 then
            Bar.BackgroundColor3 = Color3.fromRGB(
                math.random(100, 180),
                math.random(20, 80),
                math.random(180, 255)
            )
        else
            Bar.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
        end
    end
    wait(0.5)
    for i = 0, 1, 0.08 do
        Logo.ImageTransparency = i
        BarBg.BackgroundTransparency = i
        Bar.BackgroundTransparency = i
        PercentText.TextTransparency = i
        wait(0.03)
    end
    ScreenGui:Destroy()
    if game.PlaceId == 121864768012064 then
    		log('SatanScript Loaded!')
    		wait(3)
    		loadstring(game:HttpGet('https://raw.githubusercontent.com/dravenox/roblox/refs/heads/main/SatanNotHub.lua'))()
    else 
    		log('Game Not Supported!')
    end
end)
