local ImGui = {}
ImGui.__index = ImGui

local activeWindows = {}

-- Create Window
function ImGui:CreateWindow(config)
    local window = setmetatable({}, ImGui)
    
    window.title = config.title or "Window"
    window.size = config.size or ImVec2(600, 500)
    window.tabs = {}
    window.currentTabIndex = 1
    window.hookName = window.title:gsub(" ", "_") .. "_Hook"
    window.values = {}
    
    activeWindows[window.title] = window
    
    -- Auto start render
    window:_StartRender()
    
    return window
end

-- Create Tab
function ImGui:CreateTab(config)
    local tab = {
        Title = config.Title or "Tab",
        Icon = config.Icon or "",
        content = {},
        window = self
    }
    
    table.insert(self.tabs, tab)
    
    return tab
end

-- Paragraph
function ImGui.CreateTab:Paragraph(config)
    table.insert(self.content, {
        type = "paragraph",
        Title = config.Title or "Title",
        Desc = config.Desc or ""
    })
    return self
end

-- Button
function ImGui.CreateTab:Button(config)
    table.insert(self.content, {
        type = "button",
        Title = config.Title or "Button",
        Desc = config.Desc or "",
        Callback = config.Callback or function() end
    })
    return self
end

-- Toggle
function ImGui.CreateTab:Toggle(config)
    local valueKey = config.Title or "Toggle_" .. #self.content
    
    if not self.window.values[valueKey] then
        self.window.values[valueKey] = config.Default or false
    end
    
    table.insert(self.content, {
        type = "toggle",
        Title = config.Title or "Toggle",
        Desc = config.Desc or "",
        Callback = config.Callback or function() end,
        valueKey = valueKey
    })
    return self
end

-- Slider
function ImGui.CreateTab:Slider(config)
    local valueKey = config.Title or "Slider_" .. #self.content
    
    if not self.window.values[valueKey] then
        self.window.values[valueKey] = config.Default or config.Min or 0
    end
    
    table.insert(self.content, {
        type = "slider",
        Title = config.Title or "Slider",
        Desc = config.Desc or "",
        Min = config.Min or 0,
        Max = config.Max or 100,
        Callback = config.Callback or function() end,
        valueKey = valueKey
    })
    return self
end

-- Dropdown
function ImGui.CreateTab:Dropdown(config)
    local valueKey = config.Title or "Dropdown_" .. #self.content
    
    if not self.window.values[valueKey] then
        self.window.values[valueKey] = config.Default or 0
    end
    
    table.insert(self.content, {
        type = "dropdown",
        Title = config.Title or "Dropdown",
        Desc = config.Desc or "",
        List = config.List or {"Option 1"},
        Callback = config.Callback or function() end,
        valueKey = valueKey
    })
    return self
end

-- Input
function ImGui.CreateTab:Input(config)
    local valueKey = config.Title or "Input_" .. #self.content
    
    if not self.window.values[valueKey] then
        self.window.values[valueKey] = config.Default or ""
    end
    
    table.insert(self.content, {
        type = "input",
        Title = config.Title or "Input",
        Desc = config.Desc or "",
        Placeholder = config.Placeholder or "Type here...",
        Callback = config.Callback or function() end,
        valueKey = valueKey
    })
    return self
end

-- Colorpicker
function ImGui.CreateTab:Colorpicker(config)
    local valueKey = config.Title or "Color_" .. #self.content
    
    if not self.window.values[valueKey] then
        self.window.values[valueKey] = config.Default or ImVec4(1, 1, 1, 1)
    end
    
    table.insert(self.content, {
        type = "colorpicker",
        Title = config.Title or "Color",
        Desc = config.Desc or "",
        Callback = config.Callback or function() end,
        valueKey = valueKey
    })
    return self
end

-- Separator
function ImGui.CreateTab:Separator(config)
    table.insert(self.content, {
        type = "separator",
        Title = config and config.Title or ""
    })
    return self
end

-- Internal Render Function
function ImGui:_StartRender()
    local window = self
    
    AddHook('draw', window.hookName, function()
        ImGui.SetNextWindowSize(window.size, ImGui.Cond.Once)
        
        if ImGui.Begin(window.title) then
            
            -- Tab Bar
            if ImGui.BeginTabBar('MainTabBar_' .. window.title) then
                
                for tabIndex, tab in ipairs(window.tabs) do
                    -- Format: Icon + Title
                    local tabLabel = tab.Icon ~= "" and (tab.Icon .. " " .. tab.Title) or tab.Title
                    
                    if ImGui.BeginTabItem(tabLabel) then
                        
                        -- Sidebar
                        ImGui.BeginChild('_sidebar_' .. tabIndex, ImVec2(180, 0), true)
                        ImGui.Dummy(ImVec2(0, 5))
                        
                        -- Show tab content sections (optional sidebar items)
                        ImGui.Text("Sections:")
                        ImGui.Separator()
                        
                        ImGui.EndChild()
                        ImGui.SameLine()
                        
                        -- Content Area
                        ImGui.BeginChild('_content_' .. tabIndex, ImVec2(0, 0), true)
                        ImGui.Dummy(ImVec2(0, 10))
                        
                        for _, item in ipairs(tab.content) do
                            
                            -- PARAGRAPH
                            if item.type == "paragraph" then
                                ImGui.PushStyleColor(ImGui.Col.Text, ImGui.ColorConvertFloat4ToU32(ImVec4(0.4, 0.8, 1, 1)))
                                ImGui.Text(item.Title)
                                ImGui.PopStyleColor()
                                
                                if item.Desc ~= "" then
                                    ImGui.PushStyleColor(ImGui.Col.Text, ImGui.ColorConvertFloat4ToU32(ImVec4(0.7, 0.7, 0.7, 1)))
                                    ImGui.TextWrapped(item.Desc)
                                    ImGui.PopStyleColor()
                                end
                                ImGui.Dummy(ImVec2(0, 5))
                                ImGui.Separator()
                                ImGui.Dummy(ImVec2(0, 10))
                            
                            -- BUTTON
                            elseif item.type == "button" then
                                if ImGui.Button(item.Title, ImVec2(-1, 35)) then
                                    item.Callback()
                                end
                                
                                if item.Desc ~= "" then
                                    ImGui.PushStyleColor(ImGui.Col.Text, ImGui.ColorConvertFloat4ToU32(ImVec4(0.6, 0.6, 0.6, 1)))
                                    ImGui.Text("  " .. item.Desc)
                                    ImGui.PopStyleColor()
                                end
                                ImGui.Dummy(ImVec2(0, 5))
                            
                            -- TOGGLE
                            elseif item.type == "toggle" then
                                local changed, value = ImGui.Checkbox(item.Title, window.values[item.valueKey])
                                
                                if changed then
                                    window.values[item.valueKey] = value
                                    item.Callback(value)
                                end
                                
                                if item.Desc ~= "" then
                                    ImGui.PushStyleColor(ImGui.Col.Text, ImGui.ColorConvertFloat4ToU32(ImVec4(0.6, 0.6, 0.6, 1)))
                                    ImGui.Text("  " .. item.Desc)
                                    ImGui.PopStyleColor()
                                end
                                ImGui.Dummy(ImVec2(0, 5))
                            
                            -- SLIDER
                            elseif item.type == "slider" then
                                ImGui.Text(item.Title)
                                if item.Desc ~= "" then
                                    ImGui.SameLine()
                                    ImGui.PushStyleColor(ImGui.Col.Text, ImGui.ColorConvertFloat4ToU32(ImVec4(0.6, 0.6, 0.6, 1)))
                                    ImGui.Text("- " .. item.Desc)
                                    ImGui.PopStyleColor()
                                end
                                
                                ImGui.PushItemWidth(-1)
                                local changed, value = ImGui.SliderInt("##" .. item.valueKey, window.values[item.valueKey], item.Min, item.Max)
                                ImGui.PopItemWidth()
                                
                                if changed then
                                    window.values[item.valueKey] = value
                                    item.Callback(value)
                                end
                                ImGui.Dummy(ImVec2(0, 5))
                            
                            -- DROPDOWN
                            elseif item.type == "dropdown" then
                                ImGui.Text(item.Title)
                                if item.Desc ~= "" then
                                    ImGui.PushStyleColor(ImGui.Col.Text, ImGui.ColorConvertFloat4ToU32(ImVec4(0.6, 0.6, 0.6, 1)))
                                    ImGui.Text("  " .. item.Desc)
                                    ImGui.PopStyleColor()
                                end
                                
                                ImGui.PushItemWidth(-1)
                                if ImGui.BeginCombo("##" .. item.valueKey, item.List[window.values[item.valueKey] + 1]) then
                                    for i = 0, #item.List - 1 do
                                        if ImGui.Selectable(item.List[i + 1], window.values[item.valueKey] == i) then
                                            window.values[item.valueKey] = i
                                            item.Callback(item.List[i + 1])
                                        end
                                    end
                                    ImGui.EndCombo()
                                end
                                ImGui.PopItemWidth()
                                ImGui.Dummy(ImVec2(0, 5))
                            
                            -- INPUT
                            elseif item.type == "input" then
                                ImGui.Text(item.Title)
                                if item.Desc ~= "" then
                                    ImGui.PushStyleColor(ImGui.Col.Text, ImGui.ColorConvertFloat4ToU32(ImVec4(0.6, 0.6, 0.6, 1)))
                                    ImGui.Text("  " .. item.Desc)
                                    ImGui.PopStyleColor()
                                end
                                
                                ImGui.PushItemWidth(-1)
                                local changed, value = ImGui.InputTextWithHint("##" .. item.valueKey, item.Placeholder, window.values[item.valueKey], 256)
                                ImGui.PopItemWidth()
                                
                                if changed then
                                    window.values[item.valueKey] = value
                                    item.Callback(value)
                                end
                                ImGui.Dummy(ImVec2(0, 5))
                            
                            -- COLORPICKER
                            elseif item.type == "colorpicker" then
                                ImGui.Text(item.Title)
                                if item.Desc ~= "" then
                                    ImGui.PushStyleColor(ImGui.Col.Text, ImGui.ColorConvertFloat4ToU32(ImVec4(0.6, 0.6, 0.6, 1)))
                                    ImGui.Text("  " .. item.Desc)
                                    ImGui.PopStyleColor()
                                end
                                
                                local changed, value = ImGui.ColorEdit4("##" .. item.valueKey, window.values[item.valueKey])
                                if changed then
                                    window.values[item.valueKey] = value
                                    item.Callback(value)
                                end
                                ImGui.Dummy(ImVec2(0, 5))
                            
                            -- SEPARATOR
                            elseif item.type == "separator" then
                                ImGui.Dummy(ImVec2(0, 5))
                                if item.Title ~= "" then
                                    ImGui.Text(item.Title)
                                end
                                ImGui.Separator()
                                ImGui.Dummy(ImVec2(0, 5))
                            
                            end
                        end
                        
                        ImGui.EndChild()
                        ImGui.EndTabItem()
                    end
                end
                
                ImGui.EndTabBar()
            end
            
            ImGui.End()
        end
        
        collectgarbage("collect")
    end)
end

return ImGui
