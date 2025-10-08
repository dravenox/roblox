local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local RFCharge = RS.Packages._Index["sleitnick_net@0.2.0"].net["RF/ChargeFishingRod"]
local RFStartMini = RS.Packages._Index["sleitnick_net@0.2.0"].net["RF/RequestFishingMinigameStarted"]
local RECompleted = RS.Packages._Index["sleitnick_net@0.2.0"].net["RE/FishingCompleted"]
local RECaught = RS.Packages._Index["sleitnick_net@0.2.0"].net["RE/FishCaught"]
local RFCancel = RS.Packages._Index["sleitnick_net@0.2.0"].net["RF/CancelFishingInputs"]
local REUnequip = RS.Packages._Index["sleitnick_net@0.2.0"].net["RE/UnequipToolFromHotbar"]
local wind = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local Sell = RS.Packages._Index["sleitnick_net@0.2.0"].net["RF/SellAllItems"]
local BuyWeather = RS.Packages._Index["sleitnick_net@0.2.0"].net["RF/PurchaseWeatherEvent"]
local WebhookURL = "https://discord.com/api/webhooks/1196019779115417660/XvCZavEUJE3J0yqpxf4YNciiqrLj9qBJXui_93ZRd6cZe9rT8IlXYObFlspizzVKaJs7"
local Items = require(RS.Items)
local TierUtility = require(RS.Shared.TierUtility)

local request = http_request or request or syn and syn.request or fluxus and fluxus.request or nil

-- Rate limiting with burst support
local requestQueue = {}
local BURST_SIZE = 5 -- Send 5 requests quickly
local BURST_DELAY = 0.05 -- 0.05s between burst requests
local COOLDOWN_AFTER_BURST = 0.3 -- Wait 0.3s after burst
local lastBurstTime = 0
local lastWebhookTime = 0
local WEBHOOK_COOLDOWN = 2

local function sendWebhookLog(msg)
	if not request then return end
	local now = tick()
	if now - lastWebhookTime < WEBHOOK_COOLDOWN then
		return
	end
	lastWebhookTime = now
	
	local payload = {
		username = "SatanScript Debug",
		embeds = {{
			title = "**Debug Log**",
			description = msg,
			color = 16753920
		}}
	}
	task.spawn(function()
		pcall(function()
			request({Url = WebhookURL, Method = "POST", Headers = {["Content-Type"]="application/json"}, Body = HttpService:JSONEncode(payload)})
		end)
	end)
end

local function sendWebhook(name, size, rarity, price, duration)
	if not request then return end
	local now = tick()
	if now - lastWebhookTime < WEBHOOK_COOLDOWN then
		return
	end
	lastWebhookTime = now
	
	local payload = {
		username = "SatanScript",
		embeds = {{
			title = "**Obtained Iwak**",
			description = string.format("* **%s**\n-# * Size: %s\n-# * Rarity: %s\n-# * Price: %d\n-# * Duration: %.2fs", name, size, rarity, price, duration),
			color = 65280
		}}
	}
	task.spawn(function()
		pcall(function()
			request({Url = WebhookURL, Method = "POST", Headers = {["Content-Type"]="application/json"}, Body = HttpService:JSONEncode(payload)})
		end)
	end)
end

local function getInfo(id)
	for _, x in pairs(Items) do
		if x.Data.Type == "Fishes" then
			if x.Data.Id == id or x.Data.Name == id then
				local chance = x.Probability and x.Probability.Chance or 0
				local rarityData = TierUtility:GetTierFromRarity(chance)
				local rarityName = rarityData and rarityData.Name or "Unknown"
				return {id = x.Data.Id, name = x.Data.Name, price = x.SellPrice or 0, rarity = rarityName}
			end
		end
	end
end

local SelectedWeather = ""
local fishing = false
local fishingEnabled = false
local caughtConnection
local retryCount = 0
local MAX_RETRY = 3
local IDLE_TIMEOUT = 8
local lastActionTime = tick()
local startTime = 0
local completedThread
local burstActive = false

local function cleanup()
	if completedThread then
		task.cancel(completedThread)
		completedThread = nil
	end
	burstActive = false
	retryCount = 0
end

local function getChar()
	return player.Character or player.CharacterAdded:Wait()
end

local function resetCharacter()
	sendWebhookLog("🔄 Resetting character...")
	local char = getChar()
	local root = char:FindFirstChild("HumanoidRootPart")
	local pos = root and root.CFrame
	player.Character:BreakJoints()
	player.CharacterAdded:Wait()
	task.wait(0.5)
	if pos then
		local newChar = getChar()
		local newRoot = newChar:WaitForChild("HumanoidRootPart")
		newRoot.CFrame = pos
	end
	task.wait(1)
end

local function startFishing()
	if fishing or not fishingEnabled then return end
	fishing = true
	startTime = tick()
	lastActionTime = tick()
	
	sendWebhookLog("🎣 Starting fishing sequence...")
	
	task.spawn(function()
		local success, err = pcall(function()
			sendWebhookLog("⚡ Charging Rod...")
			RFCharge:InvokeServer(tick())
			task.wait(0.2)
			
			sendWebhookLog("🎮 Invoking RFStartMini...")
			RFStartMini:InvokeServer(-0.5, 1)
			sendWebhookLog("✅ Invoke success!")
		end)
		
		if not success then
			sendWebhookLog("❌ Invoke failed: " .. tostring(err))
			retryCount = retryCount + 1
			if retryCount < MAX_RETRY then
				fishing = false
				task.wait(1)
				if fishingEnabled then
					startFishing()
				end
			else
				fishing = false
				cleanup()
				sendWebhookLog("🧨 Max retry reached. Resetting...")
				resetCharacter()
				retryCount = 0
				task.wait(2)
				if fishingEnabled then
					startFishing()
				end
			end
		else
			retryCount = 0
			burstActive = true
			
			-- BURST SENDING: Send multiple RECompleted quickly, then cooldown
			completedThread = task.spawn(function()
				local totalSent = 0
				while fishing and fishingEnabled and burstActive do
					-- Send burst of requests
					for i = 1, BURST_SIZE do
						if not fishing or not fishingEnabled then break end
						
						local ok, errMsg = pcall(function()
							RECompleted:FireServer()
						end)
						
						if ok then 
							lastActionTime = tick()
							totalSent = totalSent + 1
						else
							-- If error contains "request", slow down
							if errMsg and string.find(string.lower(tostring(errMsg)), "request") then
								sendWebhookLog("⚠️ Rate limit detected, slowing down...")
								task.wait(1)
							end
						end
						
						task.wait(BURST_DELAY) -- Very short delay between burst
					end
					
					-- Cooldown after burst
					task.wait(COOLDOWN_AFTER_BURST)
				end
				sendWebhookLog("📊 Total RECompleted sent: " .. totalSent)
			end)
			
			-- Timeout watcher with auto-reset
			task.spawn(function()
				local lastCheck = tick()
				while fishing and fishingEnabled do
					task.wait(1)
					local now = tick()
					local timeSinceFishing = now - startTime
					local timeSinceAction = now - lastActionTime
					
					-- If stuck for too long, reset
					if timeSinceAction > IDLE_TIMEOUT then
						sendWebhookLog(string.format("⏰ Stuck detected (%.1fs idle, %.1fs total). Resetting...", timeSinceAction, timeSinceFishing))
						cleanup()
						fishing = false
						burstActive = false
						resetCharacter()
						task.wait(1)
						if fishingEnabled then 
							startFishing() 
						end
						break
					end
					
					-- Safety: If fishing takes more than 30 seconds, something is wrong
					if timeSinceFishing > 30 then
						sendWebhookLog("🚨 Fishing timeout (30s+). Force reset...")
						cleanup()
						fishing = false
						burstActive = false
						resetCharacter()
						task.wait(1)
						if fishingEnabled then
							startFishing()
						end
						break
					end
				end
			end)
		end
	end)
end

function setFishing(enabled)
	fishingEnabled = enabled
	if enabled then
		if caughtConnection then caughtConnection:Disconnect() end
		caughtConnection = RECaught.OnClientEvent:Connect(function(name, data)
			if not fishing then return end
			
			burstActive = false -- Stop burst sending
			
			local info = getInfo(name)
			local rarity = info and info.rarity or "Unknown"
			local price = info and info.price or 0
			local size = (data and data.Weight) or "Unknown"
			local duration = tick() - startTime
			
			task.spawn(function()
				sendWebhook(name, size, rarity, price, duration)
				sendWebhookLog(string.format("🐟 Fish caught: %s [%s] | Duration: %.2fs", name, rarity, duration))
			end)
			
			task.delay(0.5, function()
				fishing = false
				cleanup()
				if fishingEnabled then
					task.wait(0.3)
					startFishing()
				end
			end)
		end)
		startFishing()
	else
		fishing = false
		burstActive = false
		cleanup()
		if caughtConnection then 
			caughtConnection:Disconnect() 
			caughtConnection = nil 
		end
	end
end

local function findPath(position)
	local character = player.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then return false, "Character not found" end
	local humanoidRootPart = character.HumanoidRootPart
	local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = CFrame.new(position)})
	tween:Play()
	return true, 'Teleport Success'
end

local function log(state, str_t, str_c)
	wind:Notify({ Title = str_t, Content = str_c, Icon = state and 'check' or 'x', Duration = 3 })
end

local window = wind:CreateWindow({
	Title = "S A T A N",
	Icon = "code-xml",
	Author = "v0.3 - Anti Stuck",
	Folder = "SatanHub",
	Size = UDim2.fromOffset(350, 350),
	Transparent = true,
	Theme = "Dark",
	Resizable = true,
	SideBarWidth = 200,
	BackgroundImageTransparency = 0.42,
	HideSearchBar = true,
	ScrollBarEnabled = false
})

local x = {
	['01'] = window:Tab({ Title = 'Main', Icon = 'settings', Locked = false }),
	['02'] = window:Tab({ Title = 'Map', Icon = 'tree-palm', Locked = false }),
	['03'] = window:Tab({ Title = 'Backpack', Icon = 'backpack', Locked = false }),
	['04'] = window:Tab({ Title = 'Weather', Icon = 'cloud', Locked = false })
}

window:SelectTab(1)
x['01']:Paragraph({ Title = 'Main Panel', Desc = 'Anti-Stuck System for Legendary Fish' })

x['01']:Toggle({
	Title = 'Legit Fishing',
	Icon = 'check',
	type = 'Checkbox',
	Callback = function(state)
		if state then
			setFishing(true)
		else
			setFishing(false)
		end
	end
})

local islands = {
['Fisherman'] = Vector3.new(-32.00, 4.29, 2773.00),
['Kohana'] = Vector3.new(-658.00, 3.05, 719.00),
['Kohana Volcano'] = Vector3.new(-519.00, 24.00, 189.00),
['Sisyphus Statue'] = Vector3.new(-3745, -137, -1048),
['Treasure Room'] = Vector3.new(-3600.00, -266.57, -1558.00),
['Winter Fest'] = Vector3.new(1611.00, 4.28, 3280.00),
['Esoteric Island'] = Vector3.new(1987.00, 4.13, 1400.00),
['Crater'] = Vector3.new(968.00, 0.73, 4854.00),
['Coral Reefs'] = Vector3.new(-3095.00, 1.13, 2177.00),
['Esoteric Depths'] = Vector3.new(3157.00, -1302.73, 1439.00),
['Tropical Grove'] = Vector3.new(-2028.00, 3.22, 3650.00),
['Weather Machine'] = Vector3.new(-1496.93, 3.50, 1900.60)
}

for name, pos in pairs(islands) do
	x['02']:Button({
		Title = name,
		Desc = 'Teleport To ' .. name,
		Locked = false,
		Callback = function()
			local success, message = findPath(pos)
			if success then
				log(true, 'Teleport Status', 'Teleported To : ' .. name)
			else
				log(false, 'Teleport Status', 'Teleported Failed!')
			end
		end
	})
end

x['03']:Paragraph({ Title = 'Backpack Value', Desc = 'Not Yet...' })
x['03']:Button({
	Title = 'Sell All Fish',
	Locked = false,
	Callback = function()
		Sell:InvokeServer()
		log(true, 'Sell Status', 'Sold all fish!')
	end
})

x['04']:Paragraph({ Title = 'Click Button For Purchase Weather', Desc = 'Dont Forget To Select Weather' })
x['04']:Dropdown({
	Title = 'Select Weather',
	Values = { 'Wind', 'Cloudy', 'Snow', 'Storm', 'Radiant', 'Shark Hunt' },
	Value = "",
	Multi = false,
	AllowNone = true,
	Callback = function(choice)
		SelectedWeather = choice
		log(true, 'SatanScript', 'Weather Selected: ' .. choice)
	end
})
x['04']:Button({
	Title = 'Buy Selected Weather',
	Locked = false,
	Callback = function()
		BuyWeather:InvokeServer(SelectedWeather)
		log(true, 'Weather', 'Purchased: ' .. SelectedWeather)
	end
})
