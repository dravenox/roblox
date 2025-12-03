local nightmareGui = Instance.new('ScreenGui')
nightmareGui.IgnoreGuiInset = true 
nightmareGui.ResetOnSpawn = false 
nightmareGui.Parent = game:GetService('Players').LocalPlayer:WaitForChild('PlayerGui')

local nightmareBackground = Instance.new('Frame')
nightmareBackground.Size = UDim2.new(1, 0, 1, 0)
nightmareBackground.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
nightmareBackground.Parent = nightmareGui 

local nightmareLogo = Instance.new('ImageLabel')
nightmareLogo.Size = UDim2.new(0, 240, 0, 240)
nightmareLogo.Position = UDim2.fromScale(0.5, 0.40)
nightmareLogo.AnchorPoint = Vector2.new(0.5, 0.5)
nightmareLogo.BackgroundTransparency = 1 
nightmareLogo.Image = 'rbxassetid://126665990172213'
nightmareLogo.Parent = nightmareBackground

local nightmareGlow = Instance.new("ImageLabel")
nightmareGlow.Size = UDim2.new(0,260,0,260)
nightmareGlow.Position = UDim2.fromScale(0.5,0.40)
nightmareGlow.AnchorPoint = Vector2.new(0.5,0.5)
nightmareGlow.BackgroundTransparency = 1
nightmareGlow.ImageTransparency = 1
nightmareGlow.ImageColor3 = Color3.fromRGB(150,0,255)
nightmareGlow.Image = "rbxassetid://4681617489"
nightmareGlow.ZIndex = 5
nightmareGlow.Parent = nightmareBackground

local nightmareText = Instance.new("TextLabel")
nightmareText.AnchorPoint = Vector2.new(0.5, 0)
nightmareText.Position = UDim2.fromScale(0.5, 0.64)
nightmareText.Size = UDim2.new(0, 400, 0, 40)
nightmareText.BackgroundTransparency = 1
nightmareText.TextColor3 = Color3.fromRGB(255,255,255)
nightmareText.Font = Enum.Font.RobotoMono
nightmareText.TextSize = 32
nightmareText.Text = ""
nightmareText.Parent = nightmareBackground

local function setGlitch()
		nightmareGlow.ImageTransparency = 0.3 
		nightmareLogo.ImageColor3 = Color3.fromRGB(220, 200, 255)
		wait(0.03)
		nightmareGlow.ImageTransparency = 1 
		nightmareLogo.ImageColor3 = Color3.fromRGB(255, 255, 255)
end 

local function randColor()
		return Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
end 
	
local text = { 
		'N',
		'I',
		'G',
		'H',
		'T',
		'M',
		'A',
		'R',
		'E',
}

for _, obj in ipairs(text) do 
		nightmareText.Text = obj 
		nightmareText.TextColor3 = randColor()
		if math.random(1, 2) == 1 then 
				setGlitch()
		end 
		wait(0.45)
end 

wait(0.4)

for i = 1, 20 do 
		local attempt = i / 20 
		nightmareBackground.BackgroundTransparency = attempt 
		nightmareLogo.ImageTransparency = attempt 
		nightmareText.TextTransparency = attempt
		wait(0.02)
end

local function log(str: string)
		pcall(function()
				game.StarterGui:SetCore('SendNotification', {
						Title = 'NightmareNotHub',
						Text = str,
						Icon = 'rbxassetid://126665990172213',
						Duration = 4
				})
		end)
end
nightmareGui:Destroy()
if game.PlaceId == 121864768012064 then 
		log('Nightmare Successfully Loaded!')
		loadstring(game:HttpGet('https://raw.githubusercontent.com/dravenox/roblox/refs/heads/main/nmv9.lua'))()
else
    log('Game Not Supported!')
end
