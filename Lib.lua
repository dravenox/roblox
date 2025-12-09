local satan_tween = game:GetService("TweenService")
local satan_input = game:GetService("UserInputService")
local satan_render = game:GetService("RunService")

local satan_lib = {}

local satan_defaults = {
ImageId = 96733690666731,
Size = UDim2.new(0, 50, 0, 50),
Position = UDim2.new(0, 15, 0.5, -25),
BackgroundColor = Color3.fromRGB(30, 30, 30),
BackgroundTransparency = 0.15,
CornerRadius = 12,
KeepInBounds = true,
ZIndex = 10
}

local function satan_animate(satan_obj, satan_info, satan_props)
local satan_anim = satan_tween:Create(satan_obj, satan_info, satan_props)
satan_anim:Play()
return satan_anim
end

local function satan_dark_colors()
    local satan_palette = {
        Color3.fromRGB(0, 255, 255),
        Color3.fromRGB(0, 230, 255),
        Color3.fromRGB(50, 255, 255),
        Color3.fromRGB(0, 0, 0),
        Color3.fromRGB(255, 0, 255),
        Color3.fromRGB(200, 0, 255),
        Color3.fromRGB(120, 0, 180),
        Color3.fromRGB(90, 0, 150),
        Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
    }
    return satan_palette[math.random(1, #satan_palette)]
end

function satan_lib.CreateDragButton(satan_config)
local satan_data = {}
for satan_key, satan_value in pairs(satan_defaults) do
satan_data[satan_key] = satan_config[satan_key] or satan_value
end
local satan_player = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local satan_screen = Instance.new("ScreenGui")
satan_screen.Name = "SatanButtonUI"
satan_screen.ResetOnSpawn = false
satan_screen.IgnoreGuiInset = true
satan_screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
satan_screen.Parent = satan_player
local satan_button = Instance.new("ImageButton")
satan_button.Size = satan_data.Size
satan_button.Position = satan_data.Position
satan_button.BackgroundColor3 = satan_data.BackgroundColor
satan_button.BackgroundTransparency = satan_data.BackgroundTransparency
satan_button.Image = "rbxassetid://" .. tostring(satan_data.ImageId)
satan_button.ZIndex = satan_data.ZIndex
satan_button.Parent = satan_screen
satan_button.Active = true
satan_button.Draggable = false
satan_button.AutoButtonColor = false
local satan_corner = Instance.new("UICorner", satan_button)
satan_corner.CornerRadius = UDim.new(0, satan_data.CornerRadius)
local satan_stroke = Instance.new("UIStroke", satan_button)
satan_stroke.Thickness = 2.5
satan_stroke.Color = satan_dark_colors()
satan_stroke.Transparency = 0.1
task.spawn(function()
while satan_button.Parent do
satan_animate(
satan_stroke,
TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
{ Color = satan_dark_colors() }
)
task.wait(2)
end
end)
local satan_dragging = false
local satan_drag_input = nil
local satan_drag_start = Vector2.new(0, 0)
local satan_start_pos = UDim2.new(0, 0, 0, 0)
satan_button.InputBegan:Connect(function(satan_input_event)
if satan_input_event.UserInputType == Enum.UserInputType.MouseButton1 or
satan_input_event.UserInputType == Enum.UserInputType.Touch then
satan_dragging = true
satan_drag_input = satan_input_event
satan_drag_start = satan_input_event.Position
satan_start_pos = satan_button.Position
satan_input_event.Changed:Connect(function()
if satan_input_event.UserInputState == Enum.UserInputState.End then
satan_dragging = false
satan_drag_input = nil
end
end)
end
end)
satan_input.InputChanged:Connect(function(satan_move_input)
if not satan_dragging or not satan_drag_input then
return
end
if satan_move_input ~= satan_drag_input then
return
end
if satan_move_input.UserInputType == Enum.UserInputType.MouseMovement or
satan_move_input.UserInputType == Enum.UserInputType.Touch then
local satan_delta = satan_move_input.Position - satan_drag_start
local satan_viewport = workspace.CurrentCamera.ViewportSize
local satan_start_x = satan_start_pos.X.Scale * satan_viewport.X + satan_start_pos.X.Offset
local satan_start_y = satan_start_pos.Y.Scale * satan_viewport.Y + satan_start_pos.Y.Offset
local satan_new_x = satan_start_x + satan_delta.X
local satan_new_y = satan_start_y + satan_delta.Y
if satan_data.KeepInBounds then
local satan_size = satan_button.AbsoluteSize
satan_new_x = math.clamp(satan_new_x, 0, satan_viewport.X - satan_size.X)
satan_new_y = math.clamp(satan_new_y, 0, satan_viewport.Y - satan_size.Y)
end
satan_button.Position = UDim2.fromOffset(
math.floor(satan_new_x),
math.floor(satan_new_y)
)
end
end)
function satan_data:show()
satan_button.Visible = true
satan_animate(
satan_button,
TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
{
Size = satan_data.Size,
ImageTransparency = 0
}
)
end
function satan_data:hide()
satan_animate(
satan_button,
TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
{
Size = UDim2.new(0, 0, 0, 0),
ImageTransparency = 1
}
)
task.wait(0.2)
satan_button.Visible = false
end
function satan_data:setImage(satan_id)
satan_button.Image = "rbxassetid://109030636181557"
end
function satan_data:setPos(satan_pos)
satan_button.Position = satan_pos
end
function satan_data:setColor(satan_color)
satan_button.BackgroundColor3 = satan_color
end
function satan_data:destroy()
satan_screen:Destroy()
end
function satan_data:pulse()
local satan_og_size = satan_button.Size
local satan_scale_x = math.floor(satan_og_size.X.Offset * 1.12)
local satan_scale_y = math.floor(satan_og_size.Y.Offset * 1.12)
satan_animate(
satan_button,
TweenInfo.new(0.09, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
{
Size = UDim2.new(
satan_og_size.X.Scale,
satan_scale_x,
satan_og_size.Y.Scale,
satan_scale_y
)
}
).Completed:Connect(function()
satan_animate(
satan_button,
TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
{ Size = satan_og_size }
)
end)
end
satan_data.Button = satan_button
satan_data.Gui = satan_screen
return satan_data
end

return satan_lib
