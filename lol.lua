-- Custom ImGui API for Growtopia
-- Made with ❤️ by Claude
-- Version 2.0 - Real ImGui Structure

local ImGuiAPI = {}
ImGuiAPI.__index = ImGuiAPI

-- State storage
local states = {}
local hooks = {}

-- Helper functions
local function getState(key, default)
    if states[key] == nil then
        states[key] = default
    end
    return states[key]
end

local function setState(key, value)
    states[key] = value
end

-- Main API Constructor
function ImGuiAPI:new()
    local obj = setmetatable({}, ImGuiAPI)
    obj.windows = {}
    obj.currentWindow = nil
    obj.hookLabel = "IMGUI_" .. tostring(math.random(1000, 9999))
    return obj
end

-- Create new window/GUI
function ImGuiAPI:createWindow(config)
    local window = {
        title = config.title or "ImGui Window",
        width = config.width or 400,
        height = config.height or 300,
        flags = config.flags or 0,
        visible = config.visible ~= false,
        tabs = {},
        elements = {},
        onRenderCallback = config.onRender or nil
    }
    
    table.insert(self.windows, window)
    return #self.windows
end

-- Begin building window content
function ImGuiAPI:window(windowId)
    self.currentWindow = self.windows[windowId]
    return self
end

-- Add tab bar
function ImGuiAPI:beginTabBar(label)
    if not self.currentWindow then return self end
    
    local tab = {
        type = "tabbar",
        label = label or "TabBar",
        tabs = {}
    }
    
    table.insert(self.currentWindow.elements, tab)
    self.currentTab = tab
    return self
end

-- Add tab item
function ImGuiAPI:tabItem(label, icon, elements)
    if not self.currentTab then return self end
    
    table.insert(self.currentTab.tabs, {
        label = label,
        icon = icon or "",
        elements = elements or {}
    })
    return self
end

-- Add checkbox
function ImGuiAPI:checkbox(label, stateKey, defaultValue, callback)
    if getState(stateKey) == nil then
        setState(stateKey, defaultValue or false)
    end
    
    local element = {
        type = "checkbox",
        label = label,
        stateKey = stateKey,
        callback = callback
    }
    
    if self.currentTab and #self.currentTab.tabs > 0 then
        table.insert(self.currentTab.tabs[#self.currentTab.tabs].elements, element)
    else
        table.insert(self.currentWindow.elements, element)
    end
    
    return self
end

-- Add button
function ImGuiAPI:button(label, callback, width, height)
    local element = {
        type = "button",
        label = label,
        callback = callback,
        width = width or 0,
        height = height or 0
    }
    
    if self.currentTab and #self.currentTab.tabs > 0 then
        table.insert(self.currentTab.tabs[#self.currentTab.tabs].elements, element)
    else
        table.insert(self.currentWindow.elements, element)
    end
    
    return self
end

-- Add slider int
function ImGuiAPI:sliderInt(label, stateKey, defaultValue, min, max, format, callback)
    if getState(stateKey) == nil then
        setState(stateKey, defaultValue or 0)
    end
    
    local element = {
        type = "sliderInt",
        label = label,
        stateKey = stateKey,
        min = min or 0,
        max = max or 100,
        format = format or "%d",
        callback = callback
    }
    
    if self.currentTab and #self.currentTab.tabs > 0 then
        table.insert(self.currentTab.tabs[#self.currentTab.tabs].elements, element)
    else
        table.insert(self.currentWindow.elements, element)
    end
    
    return self
end

-- Add slider float
function ImGuiAPI:sliderFloat(label, stateKey, defaultValue, min, max, format, callback)
    if getState(stateKey) == nil then
        setState(stateKey, defaultValue or 0.0)
    end
    
    local element = {
        type = "sliderFloat",
        label = label,
        stateKey = stateKey,
        min = min or 0.0,
        max = max or 1.0,
        format = format or "%.2f",
        callback = callback
    }
    
    if self.currentTab and #self.currentTab.tabs > 0 then
        table.insert(self.currentTab.tabs[#self.currentTab.tabs].elements, element)
    else
        table.insert(self.currentWindow.elements, element)
    end
    
    return self
end

-- Add input text
function ImGuiAPI:inputText(label, stateKey, defaultValue, maxLength, callback)
    if getState(stateKey) == nil then
        setState(stateKey, defaultValue or "")
    end
    
    local element = {
        type = "inputText",
        label = label,
        stateKey = stateKey,
        maxLength = maxLength or 255,
        callback = callback
    }
    
    if self.currentTab and #self.currentTab.tabs > 0 then
        table.insert(self.currentTab.tabs[#self.currentTab.tabs].elements, element)
    else
        table.insert(self.currentWindow.elements, element)
    end
    
    return self
end

-- Add combo box
function ImGuiAPI:comboBox(label, stateKey, items, defaultIndex, callback)
    if getState(stateKey) == nil then
        setState(stateKey, defaultIndex or 1)
    end
    
    local element = {
        type = "comboBox",
        label = label,
        stateKey = stateKey,
        items = items,
        callback = callback
    }
    
    if self.currentTab and #self.currentTab.tabs > 0 then
        table.insert(self.currentTab.tabs[#self.currentTab.tabs].elements, element)
    else
        table.insert(self.currentWindow.elements, element)
    end
    
    return self
end

-- Add text
function ImGuiAPI:text(text, color)
    local element = {
        type = "text",
        text = text,
        color = color
    }
    
    if self.currentTab and #self.currentTab.tabs > 0 then
        table.insert(self.currentTab.tabs[#self.currentTab.tabs].elements, element)
    else
        table.insert(self.currentWindow.elements, element)
    end
    
    return self
end

-- Add separator
function ImGuiAPI:separator()
    local element = { type = "separator" }
    
    if self.currentTab and #self.currentTab.tabs > 0 then
        table.insert(self.currentTab.tabs[#self.currentTab.tabs].elements, element)
    else
        table.insert(self.currentWindow.elements, element)
    end
    
    return self
end

-- Add spacing
function ImGuiAPI:spacing(count)
    local element = { 
        type = "spacing",
        count = count or 1
    }
    
    if self.currentTab and #self.currentTab.tabs > 0 then
        table.insert(self.currentTab.tabs[#self.currentTab.tabs].elements, element)
    else
        table.insert(self.currentWindow.elements, element)
    end
    
    return self
end

-- Render element helper
local function renderElement(element)
    if element.type == "checkbox" then
        local changed, value = ImGui.Checkbox(element.label, getState(element.stateKey))
        if changed then
            setState(element.stateKey, value)
            if element.callback then
                element.callback(value)
            end
        end
        
    elseif element.type == "button" then
        if ImGui.Button(element.label, element.width, element.height) then
            if element.callback then
                element.callback()
            end
        end
        
    elseif element.type == "sliderInt" then
        local changed, value = ImGui.SliderInt(
            element.label,
            getState(element.stateKey),
            element.min,
            element.max,
            element.format
        )
        if changed then
            setState(element.stateKey, value)
            if element.callback then
                element.callback(value)
            end
        end
        
    elseif element.type == "sliderFloat" then
        local changed, value = ImGui.SliderFloat(
            element.label,
            getState(element.stateKey),
            element.min,
            element.max,
            element.format
        )
        if changed then
            setState(element.stateKey, value)
            if element.callback then
                element.callback(value)
            end
        end
        
    elseif element.type == "inputText" then
        local changed, value = ImGui.InputText(
            element.label,
            getState(element.stateKey),
            element.maxLength
        )
        if changed then
            setState(element.stateKey, value)
            if element.callback then
                element.callback(value)
            end
        end
        
    elseif element.type == "comboBox" then
        local currentIndex = getState(element.stateKey)
        local currentItem = element.items[currentIndex] or ""
        
        if ImGui.BeginCombo(element.label, currentItem) then
            for i, item in ipairs(element.items) do
                if ImGui.Selectable(item, currentIndex == i) then
                    setState(element.stateKey, i)
                    if element.callback then
                        element.callback(i, item)
                    end
                end
            end
            ImGui.EndCombo()
        end
        
    elseif element.type == "text" then
        if element.color then
            ImGui.PushStyleColor(ImGui.Col.Text, element.color)
            ImGui.TextUnformatted(element.text)
            ImGui.PopStyleColor()
        else
            ImGui.TextUnformatted(element.text)
        end
        
    elseif element.type == "separator" then
        ImGui.Separator()
        
    elseif element.type == "spacing" then
        for i = 1, element.count do
            ImGui.Spacing()
        end
        
    elseif element.type == "tabbar" then
        if ImGui.BeginTabBar(element.label) then
            for _, tab in ipairs(element.tabs) do
                local tabLabel = tab.icon .. " " .. tab.label
                if ImGui.BeginTabItem(tabLabel) then
                    for _, elem in ipairs(tab.elements) do
                        renderElement(elem)
                    end
                    ImGui.EndTabItem()
                end
            end
            ImGui.EndTabBar()
        end
    end
end

-- Start rendering (call this to activate)
function ImGuiAPI:render()
    AddHook('draw', self.hookLabel, function()
        for _, window in ipairs(self.windows) do
            if window.visible then
                if ImGui.Begin(window.title, window.flags) then
                    ImGui.SetNextWindowSize(ImVec2(window.width, window.height))
                    
                    -- Render all elements
                    for _, element in ipairs(window.elements) do
                        renderElement(element)
                    end
                    
                    -- Custom render callback
                    if window.onRenderCallback then
                        window.onRenderCallback()
                    end
                    
                    ImGui.End()
                end
            end
        end
    end)
    
    return self
end

-- Get state value
function ImGuiAPI:getState(key)
    return getState(key)
end

-- Set state value
function ImGuiAPI:setState(key, value)
    setState(key, value)
    return self
end

-- Toggle window visibility
function ImGuiAPI:toggleWindow(windowId)
    if self.windows[windowId] then
        self.windows[windowId].visible = not self.windows[windowId].visible
    end
    return self
end

-- Show window
function ImGuiAPI:showWindow(windowId)
    if self.windows[windowId] then
        self.windows[windowId].visible = true
    end
    return self
end

-- Hide window
function ImGuiAPI:hideWindow(windowId)
    if self.windows[windowId] then
        self.windows[windowId].visible = false
    end
    return self
end

-- Destroy/cleanup
function ImGuiAPI:destroy()
    RemoveHook(self.hookLabel)
    self.windows = {}
    states = {}
    return self
end

-- Return API directly
return ImGuiAPI
