-- // Enhanced Loader Library
-- // Improvements: Better UI, Discord ID input, Auto-save/load, Better fonts

local Loader = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

function dragify(Frame)
	local dragToggle = nil
	local dragInput = nil
	local dragStart = nil
	local startPos = nil
	
	function updateInput(input)
		local Delta = input.Position - dragStart
		local Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + Delta.X, startPos.Y.Scale, startPos.Y.Offset + Delta.Y)
		TweenService:Create(Frame, TweenInfo.new(0.25), {Position = Position}):Play()
	end
	
	Frame.InputBegan:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and UserInputService:GetFocusedTextBox() == nil then
			dragToggle = true
			dragStart = input.Position
			startPos = Frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragToggle = false
				end
			end)
		end
	end)
	
	Frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragToggle then
			updateInput(input)
		end
	end)
end

function Loader:Create(info)
	local name = info.Name or "Evolution"
	local image = info.ImageID or "rbxassetid://14222444137"
	local savekey = info.SaveKey or false
	local callback = info.Callback or function() end
	
	-- Delete existing instance
	if game.CoreGui:FindFirstChild(name) then
		game.CoreGui:FindFirstChild(name):Destroy()
	end
	
	-- Initialize save file if doesn't exist
	if savekey and not isfile(name..".key") then
		writefile(name..".key", "")
	end
	
	if savekey and not isfile(name..".discord") then
		writefile(name..".discord", "")
	end
	
	-- // Create UI
	local Login = Instance.new("ScreenGui")
	local Main = Instance.new("Frame")
	local UICorner = Instance.new("UICorner")
	local UIGradient = Instance.new("UIGradient")
	local TopBar = Instance.new("Frame")
	local TopBarCorner = Instance.new("UICorner")
	local Image = Instance.new("ImageLabel")
	local ImageCorner = Instance.new("UICorner")
	local Title = Instance.new("TextLabel")
	local Subtitle = Instance.new("TextLabel")
	
	-- Discord ID Input
	local DiscordFrame = Instance.new("Frame")
	local DiscordCorner = Instance.new("UICorner")
	local DiscordIcon = Instance.new("TextLabel")
	local DiscordTextBox = Instance.new("TextBox")
	local DiscordPlaceholder = Instance.new("TextLabel")
	
	-- Key Input
	local KeyFrame = Instance.new("Frame")
	local KeyCorner = Instance.new("UICorner")
	local KeyIcon = Instance.new("ImageButton")
	local KeyTextBox = Instance.new("TextBox")
	local KeyHidden = Instance.new("TextLabel")
	
	-- Login Button
	local LoginButton = Instance.new("TextButton")
	local LoginCorner = Instance.new("UICorner")
	local LoginGradient = Instance.new("UIGradient")
	
	-- Status Label
	local StatusLabel = Instance.new("TextLabel")
	
	-- Configure ScreenGui
	Login.Name = name
	Login.Parent = game.CoreGui
	Login.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	Login.ResetOnSpawn = false
	
	-- Main Frame
	Main.Name = "Main"
	Main.Parent = Login
	Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	Main.BorderSizePixel = 0
	Main.Position = UDim2.new(0.5, -225, 0.5, -150)
	Main.Size = UDim2.new(0, 450, 0, 300)
	Main.ClipsDescendants = true
	
	UICorner.CornerRadius = UDim.new(0, 12)
	UICorner.Parent = Main
	
	-- Top Bar
	TopBar.Name = "TopBar"
	TopBar.Parent = Main
	TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	TopBar.BorderSizePixel = 0
	TopBar.Size = UDim2.new(1, 0, 0, 70)
	
	TopBarCorner.CornerRadius = UDim.new(0, 12)
	TopBarCorner.Parent = TopBar
	
	-- Image/Logo
	Image.Name = "Image"
	Image.Parent = TopBar
	Image.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
	Image.BorderSizePixel = 0
	Image.Position = UDim2.new(0, 20, 0.5, -20)
	Image.Size = UDim2.new(0, 40, 0, 40)
	Image.Image = image
	Image.ScaleType = Enum.ScaleType.Fit
	
	ImageCorner.CornerRadius = UDim.new(0, 8)
	ImageCorner.Parent = Image
	
	-- Title
	Title.Name = "Title"
	Title.Parent = TopBar
	Title.BackgroundTransparency = 1
	Title.Position = UDim2.new(0, 75, 0, 15)
	Title.Size = UDim2.new(0, 300, 0, 25)
	Title.Font = Enum.Font.GothamBold
	Title.Text = name.." Login"
	Title.TextColor3 = Color3.fromRGB(255, 255, 255)
	Title.TextSize = 20
	Title.TextXAlignment = Enum.TextXAlignment.Left
	
	-- Subtitle
	Subtitle.Name = "Subtitle"
	Subtitle.Parent = TopBar
	Subtitle.BackgroundTransparency = 1
	Subtitle.Position = UDim2.new(0, 75, 0, 38)
	Subtitle.Size = UDim2.new(0, 300, 0, 20)
	Subtitle.Font = Enum.Font.Gotham
	Subtitle.Text = "Enter your credentials to continue"
	Subtitle.TextColor3 = Color3.fromRGB(180, 180, 185)
	Subtitle.TextSize = 12
	Subtitle.TextXAlignment = Enum.TextXAlignment.Left
	
	-- Discord ID Frame
	DiscordFrame.Name = "DiscordFrame"
	DiscordFrame.Parent = Main
	DiscordFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	DiscordFrame.BorderSizePixel = 0
	DiscordFrame.Position = UDim2.new(0, 30, 0, 95)
	DiscordFrame.Size = UDim2.new(0, 390, 0, 45)
	
	DiscordCorner.CornerRadius = UDim.new(0, 8)
	DiscordCorner.Parent = DiscordFrame
	
	-- Discord Icon
	DiscordIcon.Name = "DiscordIcon"
	DiscordIcon.Parent = DiscordFrame
	DiscordIcon.BackgroundTransparency = 1
	DiscordIcon.Position = UDim2.new(0, 12, 0.5, -10)
	DiscordIcon.Size = UDim2.new(0, 20, 0, 20)
	DiscordIcon.Font = Enum.Font.GothamBold
	DiscordIcon.Text = "🎮"
	DiscordIcon.TextColor3 = Color3.fromRGB(88, 101, 242)
	DiscordIcon.TextSize = 18
	
	-- Discord TextBox
	DiscordTextBox.Name = "DiscordTextBox"
	DiscordTextBox.Parent = DiscordFrame
	DiscordTextBox.BackgroundTransparency = 1
	DiscordTextBox.Position = UDim2.new(0, 45, 0, 0)
	DiscordTextBox.Size = UDim2.new(1, -55, 1, 0)
	DiscordTextBox.Font = Enum.Font.GothamMedium
	DiscordTextBox.PlaceholderText = "Discord ID"
	DiscordTextBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 125)
	DiscordTextBox.Text = ""
	DiscordTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	DiscordTextBox.TextSize = 14
	DiscordTextBox.TextXAlignment = Enum.TextXAlignment.Left
	DiscordTextBox.ClearTextOnFocus = false
	
	-- Key Frame
	KeyFrame.Name = "KeyFrame"
	KeyFrame.Parent = Main
	KeyFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	KeyFrame.BorderSizePixel = 0
	KeyFrame.Position = UDim2.new(0, 30, 0, 155)
	KeyFrame.Size = UDim2.new(0, 390, 0, 45)
	
	KeyCorner.CornerRadius = UDim.new(0, 8)
	KeyCorner.Parent = KeyFrame
	
	-- Key Icon (Eye button)
	KeyIcon.Name = "KeyIcon"
	KeyIcon.Parent = KeyFrame
	KeyIcon.BackgroundTransparency = 1
	KeyIcon.Position = UDim2.new(0, 12, 0.5, -10)
	KeyIcon.Size = UDim2.new(0, 20, 0, 20)
	KeyIcon.Image = "rbxassetid://10723416652"
	KeyIcon.ImageColor3 = Color3.fromRGB(180, 180, 185)
	
	-- Key TextBox
	KeyTextBox.Name = "KeyTextBox"
	KeyTextBox.Parent = KeyFrame
	KeyTextBox.BackgroundTransparency = 1
	KeyTextBox.Position = UDim2.new(0, 45, 0, 0)
	KeyTextBox.Size = UDim2.new(1, -55, 1, 0)
	KeyTextBox.Font = Enum.Font.GothamMedium
	KeyTextBox.Text = ""
	KeyTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	KeyTextBox.TextSize = 14
	KeyTextBox.TextTransparency = 1
	KeyTextBox.TextXAlignment = Enum.TextXAlignment.Left
	KeyTextBox.ClearTextOnFocus = false
	
	-- Key Hidden Label
	KeyHidden.Name = "KeyHidden"
	KeyHidden.Parent = KeyFrame
	KeyHidden.BackgroundTransparency = 1
	KeyHidden.Position = UDim2.new(0, 45, 0, 0)
	KeyHidden.Size = UDim2.new(1, -55, 1, 0)
	KeyHidden.Font = Enum.Font.GothamMedium
	KeyHidden.Text = ""
	KeyHidden.TextColor3 = Color3.fromRGB(255, 255, 255)
	KeyHidden.TextSize = 14
	KeyHidden.TextXAlignment = Enum.TextXAlignment.Left
	
	-- Login Button
	LoginButton.Name = "LoginButton"
	LoginButton.Parent = Main
	LoginButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
	LoginButton.BorderSizePixel = 0
	LoginButton.Position = UDim2.new(0, 30, 0, 220)
	LoginButton.Size = UDim2.new(0, 390, 0, 45)
	LoginButton.Font = Enum.Font.GothamBold
	LoginButton.Text = "Login"
	LoginButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	LoginButton.TextSize = 16
	LoginButton.AutoButtonColor = false
	
	LoginCorner.CornerRadius = UDim.new(0, 8)
	LoginCorner.Parent = LoginButton
	
	-- Status Label
	StatusLabel.Name = "StatusLabel"
	StatusLabel.Parent = Main
	StatusLabel.BackgroundTransparency = 1
	StatusLabel.Position = UDim2.new(0, 30, 0, 272)
	StatusLabel.Size = UDim2.new(0, 390, 0, 20)
	StatusLabel.Font = Enum.Font.Gotham
	StatusLabel.Text = ""
	StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
	StatusLabel.TextSize = 11
	StatusLabel.TextXAlignment = Enum.TextXAlignment.Center
	
	-- Drag functionality
	dragify(Main)
	
	-- Load saved data
	if savekey then
		local success, savedKey = pcall(function()
			return readfile(name..".key")
		end)
		if success and savedKey and savedKey ~= "" then
			KeyTextBox.Text = savedKey
		end
		
		local success2, savedDiscord = pcall(function()
			return readfile(name..".discord")
		end)
		if success2 and savedDiscord and savedDiscord ~= "" then
			DiscordTextBox.Text = savedDiscord
		end
	end
	
	-- Key masking
	KeyTextBox:GetPropertyChangedSignal("Text"):Connect(function()
		if #KeyTextBox.Text > 0 then
			KeyHidden.Text = string.rep('•', #KeyTextBox.Text)
		else
			KeyHidden.Text = ""
		end
	end)
	
	-- Eye icon toggle
	local keyVisible = false
	KeyIcon.MouseButton1Click:Connect(function()
		keyVisible = not keyVisible
		KeyTextBox.TextTransparency = keyVisible and 0 or 1
		KeyHidden.Visible = not keyVisible
		KeyIcon.ImageColor3 = keyVisible and Color3.fromRGB(88, 101, 242) or Color3.fromRGB(180, 180, 185)
	end)
	
	-- Login button hover effect
	LoginButton.MouseEnter:Connect(function()
		TweenService:Create(LoginButton, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(100, 113, 255)
		}):Play()
	end)
	
	LoginButton.MouseLeave:Connect(function()
		TweenService:Create(LoginButton, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(88, 101, 242)
		}):Play()
	end)
	
	-- Login button click
	LoginButton.MouseButton1Click:Connect(function()
		local discordId = DiscordTextBox.Text
		local key = KeyTextBox.Text
		
		if discordId == "" then
			StatusLabel.Text = "❌ Please enter your Discord ID"
			StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
			return
		end
		
		if key == "" then
			StatusLabel.Text = "❌ Please enter your key"
			StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
			return
		end
		
		-- Save credentials
		if savekey then
			pcall(function()
				writefile(name..".key", key)
				writefile(name..".discord", discordId)
			end)
		end
		
		StatusLabel.Text = "✓ Authenticating..."
		StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
		
		-- Call the callback
		task.spawn(function()
			pcall(callback, key, discordId)
		end)
	end)
	
	-- Entrance animation
	Main.Size = UDim2.new(0, 0, 0, 0)
	Main.Position = UDim2.new(0.5, 0, 0.5, 0)
	
	TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 450, 0, 300),
		Position = UDim2.new(0.5, -225, 0.5, -150)
	}):Play()
end

function Loader:Destroy(name)
	if game.CoreGui:FindFirstChild(name) then
		local gui = game.CoreGui:FindFirstChild(name)
		local main = gui:FindFirstChild("Main")
		
		if main then
			TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
				Size = UDim2.new(0, 0, 0, 0),
				Position = UDim2.new(0.5, 0, 0.5, 0)
			}):Play()
			
			task.wait(0.3)
		end
		
		gui:Destroy()
	else
		warn("[Loader]: GUI '"..name.."' not found.")
	end
end

return Loader
