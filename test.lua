
local WindUI = {}
WindUI.__index = WindUI

local activeWindows = {}
local selectedTabIndex = {}

-- Main Constructor
function WindUI:CreateWindow(config)
    local window = setmetatable({}, WindUI)
    
    window.Title = config.Title or "Window"
    window.Author = config.Author or "Unknown"
    window.Folder = config.Folder or "Default"
    window.Size = config.Size or ImVec2(600, 500)
    window.Transparent = config.Transparent or false
    window.Theme = config.Theme or "Dark"
    window.Resizable = config.Resizable or false
    window.SideBarWidth = config.SideBarWidth or 180
    
    window.tabs = {}
    window.currentTab = nil
    window.hookName = window.Title:gsub(" ", "_") .. "_Hook"
    window.values = {}
    
    activeWindows[window.Title] = window
    selectedTabIndex[window.Title] = 1
    
    -- Auto start render
    window:_StartRender()
    
    return window
end

-- Create Tab
function WindUI:Tab(config)
    local tab = {
        Title = config.Title or "Tab",
        Locked = config.Locked or false,
        content = {},
        window = self
    }
    
    table.insert(self.tabs, tab)
    
    if #self.tabs == 1 then
        self.currentTab = tab
    end
    
    return tab
end

-- Select Tab by Index
function WindUI:SelectTab(index)
    selectedTabIndex[self.Title] = index
    if self.tabs[index] then
        self.currentTab = self.tabs[index]
    end
    return self
end

-- Paragraph (Header Text)
function WindUI.Tab:Paragraph(config)
    table.insert(self.content, {
        type = "paragraph",
        Title = config.Title or "Title",
        Desc = config.Desc or ""
    })
    return self
end

-- Button
function WindUI.Tab:Button(config)
    table.insert(self.content, {
        type = "button",
        Title = config.Title or "Button",
        Desc = config.Desc or "",
        Locked = config.Locked or false,
        Callback = config.Callback or function() end
    })
    return self
end

-- Toggle (Checkbox)
function WindUI.Tab:Toggle(config)
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
function WindUI.Tab:Slider(config)
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
function WindUI.Tab:Dropdown(config)
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
function WindUI.Tab:Input(config)
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

-- Color Picker
function WindUI.Tab:Colorpicker(config)
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
function WindUI.Tab:Separator(config)
    table.insert(self.content, {
        type = "separator",
        Title = config and config.Title or ""
    })
    return self
end

-- Section (Collapsible Header)
function WindUI.Tab:Section(config)
    table.insert(self.content, {
        type = "section",
        Title = config.Title or "Section"
    })
    return self
end

-- Internal Render Function
function WindUI:_StartRender()
    local window = self
    
    AddHook('draw', window.hookName, function()
        ImGui.SetNextWindowSize(window.Size, ImGui.Cond.Once)
        
        local windowFlags = 0
        if not window.Resizable then
            windowFlags = ImGui.WindowFlags.NoResize
        end
        
        if ImGui.Begin(window.Title .. " - " .. window.Author, true, windowFlags) then
            
            if ImGui.BeginTable("MainLayout", 2, ImGui.TableFlags.BordersInnerV) then
                ImGui.TableSetupColumn("Sidebar", ImGui.TableColumnFlags.WidthFixed, window.SideBarWidth)
                ImGui.TableSetupColumn("Content", ImGui.TableColumnFlags.WidthStretch)
                
                ImGui.TableNextRow()
                
                -- SIDEBAR
                ImGui.TableSetColumnIndex(0)
                ImGui.BeginChild("Sidebar", ImVec2(0, 0), false)
                
                for i, tab in ipairs(window.tabs) do
                    local isSelected = (selectedTabIndex[window.Title] == i)
                    
                    if tab.Locked then
                        ImGui.BeginDisabled(true)
                    end
                    
                    if isSelected then
                        ImGui.PushStyleColor(ImGui.Col.Header, ImGui.ColorConvertFloat4ToU32(ImVec4(0.26, 0.59, 0.98, 0.8)))
                    end
                    
                    if ImGui.Selectable(tab.Title, isSelected, 0, ImVec2(0, 35)) then
                        selectedTabIndex[window.Title] = i
                        window.currentTab = tab
                    end
                    
                    if isSelected then
                        ImGui.PopStyleColor()
                    end
                    
                    if tab.Locked then
                        ImGui.EndDisabled()
                    end
                end
                
                ImGui.EndChild()
                
                -- CONTENT
                ImGui.TableSetColumnIndex(1)
                ImGui.BeginChild("Content", ImVec2(0, 0), true)
                ImGui.Dummy(ImVec2(0, 10))
                
                if window.currentTab then
                    for _, item in ipairs(window.currentTab.content) do
                        
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
                        
                        elseif item.type == "button" then
                            if item.Locked then
                                ImGui.BeginDisabled(true)
                            end
                            
                            if ImGui.Button(item.Title, ImVec2(-1, 35)) then
                                item.Callback()
                            end
                            
                            if item.Desc ~= "" then
                                ImGui.PushStyleColor(ImGui.Col.Text, ImGui.ColorConvertFloat4ToU32(ImVec4(0.6, 0.6, 0.6, 1)))
                                ImGui.Text("  " .. item.Desc)
                                ImGui.PopStyleColor()
                            end
                            
                            if item.Locked then
                                ImGui.EndDisabled()
                            end
                            ImGui.Dummy(ImVec2(0, 5))
                        
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
                        
                        elseif item.type == "separator" then
                            ImGui.Dummy(ImVec2(0, 5))
                            if item.Title ~= "" then
                                ImGui.Text(item.Title)
                            end
                            ImGui.Separator()
                            ImGui.Dummy(ImVec2(0, 5))
                        
                        elseif item.type == "section" then
                            ImGui.Dummy(ImVec2(0, 5))
                            if ImGui.CollapsingHeader(item.Title) then
                                ImGui.Text("  Section content")
                            end
                        
                        end
                    end
                end
                
                ImGui.EndChild()
                
                ImGui.EndTable()
            end
            
            ImGui.End()
        end
        
        collectgarbage("collect")
    end)
end

return WindUI
