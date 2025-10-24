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

if game.PlaceId == 121864768012064 then
	    log('SatanScript Loaded!')
	    wait(3)
		loadstring(game:HttpGet('https://raw.githubusercontent.com/dravenox/roblox/refs/heads/main/SatanNotHub.lua'))()
else
		log('Game Not Supported!')
end
