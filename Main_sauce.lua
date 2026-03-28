--[[
    ███████╗██╗      █████╗ ██████╗     ██████╗  █████╗ ████████╗████████╗██╗     ███████╗
    ██╔════╝██║     ██╔══██╗██╔══██╗    ██╔══██╗██╔══██╗╚══██╔══╝╚══██╔══╝██║     ██╔════╝
    ███████╗██║     ███████║██████╔╝    ██████╔╝███████║   ██║      ██║   ██║     █████╗  
    ╚════██║██║     ██╔══██║██╔══██╗    ██╔══██╗██╔══██║   ██║      ██║   ██║     ██╔══╝  
    ███████║███████╗██║  ██║██████╔╝    ██████╔╝██║  ██║   ██║      ██║   ███████╗███████╗
    ╚══════╝╚══════╝╚═╝  ╚═╝╚═════╝     ╚═════╝ ╚═╝  ╚═╝   ╚═╝      ╚═╝   ╚══════╝╚══════╝
    
    TERMINAL v5.0 | GUN METAL BLACK + TECHNO RED
    Mobile Compatible | Tab System | 30% Smaller | Full Morph + Replicate System
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local LogService = game:GetService("LogService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- ============================================================================
-- COLOR DEFINITIONS
-- ============================================================================
local Colors = {
    Gunmetal_Dark = Color3.fromRGB(12, 12, 14),
    Gunmetal_Mid = Color3.fromRGB(22, 22, 26),
    Gunmetal_Light = Color3.fromRGB(35, 35, 42),
    Gunmetal_Accent = Color3.fromRGB(45, 45, 52),
    Red_Primary = Color3.fromRGB(255, 20, 30),
    Red_Glow = Color3.fromRGB(255, 40, 50),
    Red_Dim = Color3.fromRGB(180, 20, 25),
    Red_Pulse = Color3.fromRGB(255, 60, 70),
    Red_Deep = Color3.fromRGB(100, 10, 15),
}

-- ============================================================================
-- MORPH LIST
-- ============================================================================
local MorphNames = {
    "Abomination","Barrel","Beans","Bench","Blackhole","Brick",
    "Bush 1","Bush 2","Candy Cane","Candy corn","Car","Cauldron",
    "Cheese","Chicken","Cloud","Crate","Diamond","Duck of Christmas",
    "Duelist Block","El Gato","Frenzy Bot","Gift","Gift Blue",
    "Gift Long","Gift Small","Gifts","Golden Slapple","Golem",
    "Gravestone","Hay","Haybale","Imp","Jerry","Jerry Original",
    "Jet Orb","John Halloween","Juan","Lamp","Lantern","Larry",
    "MATERIALIZE Orb","MEGAROCK","Meowl","Moai Head","Mouse Trap",
    "Obby 1","Obby 2","Obby 3","Obby 4","Obby 5","Orange","Oven",
    "Phase Heart","Phase Orb","Pocket","Poltergeist","Presents",
    "Pumpkin","Pumpkin 2","R/C","Red Chair","Rock 1","Rock 2",
    "Rock 3","Santa's Sleigh","Sbeve","Scarecrow","Scaretrap","Seal",
    "Sentry","Siphon Orb","Slapple","Snow Peep","Snow Peep Giant",
    "Snow Turret","Spider","Squirrel","Table","Tank","Trap",
    "Tycoon","bob","rob"
}
table.sort(MorphNames, function(a, b) return a:lower() < b:lower() end)

-- ============================================================================
-- PERSISTENT STORAGE FOR CUSTOM ABILITIES
-- ============================================================================
local SAVE_KEY = "SlapTerminal_CustomAbilities_v1"
local customAbilities = {}

local function saveCustomAbilities()
    pcall(function()
        if writefile then
            writefile(SAVE_KEY .. ".json", HttpService:JSONEncode(customAbilities))
        end
    end)
end

local function loadCustomAbilities()
    pcall(function()
        if readfile and isfile and isfile(SAVE_KEY .. ".json") then
            customAbilities = HttpService:JSONDecode(readfile(SAVE_KEY .. ".json"))
        end
    end)
end

loadCustomAbilities()

-- ============================================================================
-- REMOTES
-- ============================================================================
local radioRemote, invisOnRemote, invisOffRemote, generalAbilityRemote
local slocRemote, eraseRemote, htSpaceRemote, zeroGSoundRemote
pcall(function() radioRemote = ReplicatedStorage:WaitForChild("RadioPlay", 5) end)
pcall(function() invisOnRemote = ReplicatedStorage:WaitForChild("Ghostinvisibilityactivated", 5) end)
pcall(function() invisOffRemote = ReplicatedStorage:WaitForChild("Ghostinvisibilitydeactivated", 5) end)
pcall(function() generalAbilityRemote = ReplicatedStorage:WaitForChild("GeneralAbility", 5) end)
pcall(function() slocRemote = ReplicatedStorage:WaitForChild("SLOC", 5) end)
pcall(function() eraseRemote = ReplicatedStorage:WaitForChild("Erase", 5) end)
pcall(function() htSpaceRemote = ReplicatedStorage:WaitForChild("HtSpace", 5) end)
pcall(function() zeroGSoundRemote = ReplicatedStorage:WaitForChild("ZeroGSound", 5) end)

local function fireClickDetector(path)
    local cd = path and path:FindFirstChildOfClass("ClickDetector")
    if cd then pcall(function() fireclickdetector(cd) end) end
end

local function fireMorph(morphName)
    pcall(function()
        local propCD = workspace.Lobby.Prop:FindFirstChildOfClass("ClickDetector")
        if propCD then fireclickdetector(propCD) end
    end)
    task.wait(0.15)
    pcall(function()
        if generalAbilityRemote then generalAbilityRemote:FireServer(morphName) end
    end)
end

local function clearMorph()
    pcall(function()
        local propCD = workspace.Lobby.Prop:FindFirstChildOfClass("ClickDetector")
        if propCD then fireclickdetector(propCD) end
    end)
    task.wait(0.15)
    pcall(function()
        if generalAbilityRemote then generalAbilityRemote:FireServer("Clear") end
    end)
end

-- ============================================================================
-- SPACE MODE STATE
-- ============================================================================
local spaceModeActive = false
local spaceHitboxPart = nil
local spaceHitboxConn = nil
local spaceAbilityButtons = {} -- references to the floating buttons

-- ============================================================================
-- SCALE
-- ============================================================================
local SF = 0.7

-- ============================================================================
-- MAIN GUI
-- ============================================================================
local gui = Instance.new("ScreenGui", playerGui)
gui.Name = "SlapBattlesTerminal"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local blurEffect = Instance.new("BlurEffect", Lighting)
blurEffect.Size = 0
blurEffect.Enabled = true

-- ============================================================================
-- TERMINAL FRAME
-- ============================================================================
local termW = math.floor(860 * SF)
local termH = math.floor(620 * SF)

local terminal = Instance.new("Frame", gui)
terminal.Size = UDim2.new(0, termW, 0, termH)
terminal.Position = UDim2.new(0.5, -termW/2, 0.5, -termH/2)
terminal.BackgroundColor3 = Colors.Gunmetal_Dark
terminal.BackgroundTransparency = 0.08
terminal.BorderSizePixel = 0
terminal.ClipsDescendants = true

Instance.new("UICorner", terminal).CornerRadius = UDim.new(0, math.floor(16 * SF))
local primaryBorder = Instance.new("UIStroke", terminal)
primaryBorder.Color = Colors.Red_Primary
primaryBorder.Thickness = 2
primaryBorder.Transparency = 0.3

local innerBorder = Instance.new("Frame", terminal)
innerBorder.Size = UDim2.new(1, -4, 1, -4)
innerBorder.Position = UDim2.new(0, 2, 0, 2)
innerBorder.BackgroundTransparency = 1
innerBorder.BorderSizePixel = 1
innerBorder.BorderColor3 = Colors.Red_Dim
Instance.new("UICorner", innerBorder).CornerRadius = UDim.new(0, math.floor(12 * SF))

-- ============================================================================
-- CIRCUIT OVERLAY
-- ============================================================================
local circuitOverlay = Instance.new("Frame", terminal)
circuitOverlay.Size = UDim2.new(1, 0, 1, 0)
circuitOverlay.BackgroundTransparency = 1

for i = 0, 6 do
    local hLine = Instance.new("Frame", circuitOverlay)
    hLine.Size = UDim2.new(1, 0, 0, 1)
    hLine.Position = UDim2.new(0, 0, 0, i * math.floor(70 * SF) + 10)
    hLine.BackgroundColor3 = Colors.Red_Primary
    hLine.BackgroundTransparency = 0.92
    hLine.BorderSizePixel = 0
    task.spawn(function()
        while true do
            TweenService:Create(hLine, TweenInfo.new(0.5), {BackgroundTransparency = 0.85}):Play()
            task.wait(0.3)
            TweenService:Create(hLine, TweenInfo.new(0.5), {BackgroundTransparency = 0.94}):Play()
            task.wait(1.2)
        end
    end)
end

for i = 0, 4 do
    local vLine = Instance.new("Frame", circuitOverlay)
    vLine.Size = UDim2.new(0, 1, 1, 0)
    vLine.Position = UDim2.new(0, math.floor((120 + i * 140) * SF), 0, 0)
    vLine.BackgroundColor3 = Colors.Red_Dim
    vLine.BackgroundTransparency = 0.96
    vLine.BorderSizePixel = 0
    task.spawn(function()
        while true do
            TweenService:Create(vLine, TweenInfo.new(0.8), {BackgroundTransparency = 0.9}):Play()
            task.wait(0.5)
            TweenService:Create(vLine, TweenInfo.new(0.8), {BackgroundTransparency = 0.97}):Play()
            task.wait(1.5)
        end
    end)
end

local dataParticle = Instance.new("Frame", circuitOverlay)
dataParticle.Size = UDim2.new(0, 3, 0, 3)
dataParticle.BackgroundColor3 = Colors.Red_Primary
dataParticle.BorderSizePixel = 0
Instance.new("UICorner", dataParticle).CornerRadius = UDim.new(1, 0)

task.spawn(function()
    while true do
        for x = 0, 1, 0.02 do
            dataParticle.Position = UDim2.new(x, 0, 0.3, 0)
            task.wait(0.02)
        end
        for x = 1, 0, -0.02 do
            dataParticle.Position = UDim2.new(x, 0, 0.7, 0)
            task.wait(0.02)
        end
    end
end)

-- ============================================================================
-- HEADER
-- ============================================================================
local headerH = math.floor(42 * SF)
local header = Instance.new("Frame", terminal)
header.Size = UDim2.new(1, 0, 0, headerH)
header.BackgroundColor3 = Colors.Gunmetal_Mid
header.BackgroundTransparency = 0.15
header.BorderSizePixel = 0
Instance.new("UICorner", header).CornerRadius = UDim.new(0, math.floor(16 * SF))

local accentBar = Instance.new("Frame", header)
accentBar.Size = UDim2.new(1, 0, 0, 2)
accentBar.Position = UDim2.new(0, 0, 1, -2)
accentBar.BackgroundColor3 = Colors.Red_Primary
accentBar.BorderSizePixel = 0

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(0.65, 0, 1, 0)
title.Position = UDim2.new(0, math.floor(10 * SF), 0, 0)
title.Text = "[[ SLAP BATTLE v5.0 ]]"
title.TextColor3 = Colors.Red_Primary
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = math.floor(14 * SF)
title.TextXAlignment = Enum.TextXAlignment.Left

task.spawn(function()
    while true do
        title.TextTransparency = 0
        task.wait(math.random(2, 5))
        title.TextTransparency = 0.5; task.wait(0.05)
        title.TextTransparency = 0; task.wait(0.05)
        title.TextTransparency = 0.3; task.wait(0.05)
        title.TextTransparency = 0
    end
end)

local btnSz = math.floor(28 * SF)
local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.new(0, btnSz, 0, btnSz)
closeBtn.Position = UDim2.new(1, -(btnSz + math.floor(8 * SF)), 0, math.floor(7 * SF))
closeBtn.Text = "✕"
closeBtn.TextColor3 = Colors.Red_Primary
closeBtn.BackgroundColor3 = Colors.Gunmetal_Light
closeBtn.BackgroundTransparency = 0.5
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = math.floor(14 * SF)
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

local minBtn = Instance.new("TextButton", header)
minBtn.Size = UDim2.new(0, btnSz, 0, btnSz)
minBtn.Position = UDim2.new(1, -(btnSz * 2 + math.floor(16 * SF)), 0, math.floor(7 * SF))
minBtn.Text = "—"
minBtn.TextColor3 = Colors.Red_Dim
minBtn.BackgroundColor3 = Colors.Gunmetal_Light
minBtn.BackgroundTransparency = 0.5
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = math.floor(14 * SF)
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)

-- ============================================================================
-- DRAG (MOBILE + DESKTOP)
-- ============================================================================
local dragging = false
local dragStart, startPos

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = terminal.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        terminal.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ============================================================================
-- TAB BAR
-- ============================================================================
local tabBarH = math.floor(32 * SF)
local tabBar = Instance.new("Frame", terminal)
tabBar.Size = UDim2.new(1, 0, 0, tabBarH)
tabBar.Position = UDim2.new(0, 0, 0, headerH)
tabBar.BackgroundColor3 = Colors.Gunmetal_Mid
tabBar.BackgroundTransparency = 0.3
tabBar.BorderSizePixel = 0

local tabBarLayout = Instance.new("UIListLayout", tabBar)
tabBarLayout.FillDirection = Enum.FillDirection.Horizontal
tabBarLayout.SortOrder = Enum.SortOrder.LayoutOrder

local tabNames = {"Overall", "Morph", "Replicate", "Toggles", "Entities", "Media", "Debug", "Terminal"}
local tabButtons = {}
local tabPages = {}

local contentContainer = Instance.new("Frame", terminal)
contentContainer.Size = UDim2.new(1, -math.floor(16 * SF), 1, -(headerH + tabBarH + math.floor(28 * SF) + math.floor(8 * SF)))
contentContainer.Position = UDim2.new(0, math.floor(8 * SF), 0, headerH + tabBarH + math.floor(4 * SF))
contentContainer.BackgroundTransparency = 1
contentContainer.ClipsDescendants = true

for i, name in ipairs(tabNames) do
    local tabBtn = Instance.new("TextButton", tabBar)
    tabBtn.Size = UDim2.new(1/#tabNames, 0, 1, 0)
    tabBtn.LayoutOrder = i
    tabBtn.Text = name
    tabBtn.TextColor3 = Colors.Red_Dim
    tabBtn.BackgroundColor3 = Colors.Gunmetal_Dark
    tabBtn.BackgroundTransparency = 0.5
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.TextSize = math.floor(isMobile and 10 or 11 * SF)
    tabBtn.BorderSizePixel = 0
    local ind = Instance.new("Frame", tabBtn)
    ind.Name = "Indicator"
    ind.Size = UDim2.new(0.8, 0, 0, 2)
    ind.Position = UDim2.new(0.1, 0, 1, -2)
    ind.BackgroundColor3 = Colors.Red_Primary
    ind.BackgroundTransparency = 1
    ind.BorderSizePixel = 0
    tabButtons[name] = tabBtn
end

for _, name in ipairs(tabNames) do
    local page = Instance.new("ScrollingFrame", contentContainer)
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.Visible = false
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.ScrollBarThickness = isMobile and 6 or 4
    page.ScrollBarImageColor3 = Colors.Red_Primary
    page.ScrollingDirection = Enum.ScrollingDirection.Y
    local pp = Instance.new("UIPadding", page)
    pp.PaddingLeft = UDim.new(0, math.floor(4 * SF))
    pp.PaddingRight = UDim.new(0, math.floor(4 * SF))
    pp.PaddingTop = UDim.new(0, math.floor(4 * SF))
    local pl = Instance.new("UIListLayout", page)
    pl.SortOrder = Enum.SortOrder.LayoutOrder
    pl.Padding = UDim.new(0, math.floor(6 * SF))
    tabPages[name] = page
end

local function switchTab(tabName)
    for name, btn in pairs(tabButtons) do
        local isActive = (name == tabName)
        btn.TextColor3 = isActive and Colors.Red_Primary or Colors.Red_Dim
        btn.BackgroundTransparency = isActive and 0.3 or 0.6
        local ind = btn:FindFirstChild("Indicator")
        if ind then TweenService:Create(ind, TweenInfo.new(0.2), {BackgroundTransparency = isActive and 0 or 1}):Play() end
    end
    for name, page in pairs(tabPages) do
        page.Visible = (name == tabName)
    end
end

for name, btn in pairs(tabButtons) do
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
end

-- ============================================================================
-- HELPERS
-- ============================================================================
local function createButton(parent, text, layoutOrder, callback)
    local minH = isMobile and math.floor(52 * SF) or math.floor(40 * SF)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, minH)
    btn.LayoutOrder = layoutOrder or 1
    btn.Text = text
    btn.TextColor3 = Colors.Red_Primary
    btn.BackgroundColor3 = Colors.Gunmetal_Dark
    btn.BackgroundTransparency = 0.3
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = math.floor((isMobile and 13 or 14) * SF)
    btn.BorderSizePixel = 0
    btn.TextWrapped = true
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, math.floor(8 * SF))
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Colors.Red_Dim
    stroke.Thickness = 1
    if isMobile then
        local pad = Instance.new("UIPadding", btn)
        pad.PaddingLeft = UDim.new(0, 8)
        pad.PaddingRight = UDim.new(0, 8)
    end
    if callback then btn.MouseButton1Click:Connect(callback) end
    local original = btn.BackgroundColor3
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Colors.Gunmetal_Light}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {Thickness = 2, Transparency = 0.2}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = original}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {Thickness = 1, Transparency = 0}):Play()
    end)
    return btn
end

local function createSectionHeader(parent, text, layoutOrder)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size = UDim2.new(1, 0, 0, math.floor(24 * SF))
    lbl.LayoutOrder = layoutOrder or 0
    lbl.Text = "// " .. text .. " //"
    lbl.TextColor3 = Colors.Red_Primary
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = math.floor(12 * SF)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    return lbl
end

local function createToggle(parent, text, layoutOrder, default, callback)
    local toggleH = isMobile and math.floor(48 * SF) or math.floor(36 * SF)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, 0, 0, toggleH)
    frame.LayoutOrder = layoutOrder or 1
    frame.BackgroundColor3 = Colors.Gunmetal_Mid
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, math.floor(8 * SF))
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.7, -10, 1, 0)
    label.Position = UDim2.new(0, math.floor(10 * SF), 0, 0)
    label.Text = text
    label.TextColor3 = Colors.Red_Dim
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = math.floor((isMobile and 12 or 11) * SF)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextWrapped = true
    local switchW = math.floor(40 * SF)
    local switchH = math.floor(20 * SF)
    local knobSize = switchH - 4
    local switchBg = Instance.new("TextButton", frame)
    switchBg.Size = UDim2.new(0, switchW, 0, switchH)
    switchBg.Position = UDim2.new(1, -(switchW + math.floor(10 * SF)), 0.5, -switchH/2)
    switchBg.BackgroundColor3 = default and Colors.Red_Deep or Colors.Gunmetal_Light
    switchBg.Text = ""
    switchBg.BorderSizePixel = 0
    Instance.new("UICorner", switchBg).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", switchBg).Color = Colors.Red_Dim
    local knob = Instance.new("Frame", switchBg)
    knob.Size = UDim2.new(0, knobSize, 0, knobSize)
    knob.Position = default and UDim2.new(1, -(knobSize + 2), 0, 2) or UDim2.new(0, 2, 0, 2)
    knob.BackgroundColor3 = default and Colors.Red_Primary or Colors.Gunmetal_Accent
    knob.BorderSizePixel = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    local state = default or false
    switchBg.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(knob, TweenInfo.new(0.2), {
            Position = state and UDim2.new(1, -(knobSize + 2), 0, 2) or UDim2.new(0, 2, 0, 2),
            BackgroundColor3 = state and Colors.Red_Primary or Colors.Gunmetal_Accent
        }):Play()
        TweenService:Create(switchBg, TweenInfo.new(0.2), {
            BackgroundColor3 = state and Colors.Red_Deep or Colors.Gunmetal_Light
        }):Play()
        if callback then callback(state) end
    end)
    return frame, function() return state end
end

local function createTextInput(parent, placeholder, layoutOrder)
    local inputH = isMobile and math.floor(44 * SF) or math.floor(34 * SF)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, 0, 0, inputH)
    frame.LayoutOrder = layoutOrder or 1
    frame.BackgroundColor3 = Colors.Gunmetal_Mid
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, math.floor(8 * SF))
    Instance.new("UIStroke", frame).Color = Colors.Red_Dim
    local tb = Instance.new("TextBox", frame)
    tb.Size = UDim2.new(1, -math.floor(16 * SF), 1, 0)
    tb.Position = UDim2.new(0, math.floor(8 * SF), 0, 0)
    tb.Text = ""
    tb.PlaceholderText = placeholder
    tb.PlaceholderColor3 = Colors.Gunmetal_Accent
    tb.TextColor3 = Colors.Red_Primary
    tb.BackgroundTransparency = 1
    tb.Font = Enum.Font.Gotham
    tb.TextSize = math.floor((isMobile and 13 or 12) * SF)
    tb.TextXAlignment = Enum.TextXAlignment.Left
    tb.ClearTextOnFocus = false
    return frame, tb
end

-- ============================================================================
-- LOG SYSTEM
-- ============================================================================
local logEntries = {}

local function addLog(text, isError)
    table.insert(logEntries, {text = text, isError = isError, time = os.clock()})
    local debugPage = tabPages["Debug"]
    if debugPage then
        local entry = Instance.new("TextLabel", debugPage)
        local prefix = isError and "[!] " or "[>] "
        local color = isError and Colors.Red_Primary or Colors.Red_Dim
        entry.Size = UDim2.new(1, 0, 0, 0)
        entry.AutomaticSize = Enum.AutomaticSize.Y
        entry.LayoutOrder = #logEntries
        entry.Text = prefix .. text
        entry.TextColor3 = color
        entry.BackgroundTransparency = 1
        entry.Font = Enum.Font.Code
        entry.TextSize = math.floor((isMobile and 10 or 9) * SF)
        entry.TextXAlignment = Enum.TextXAlignment.Left
        entry.TextWrapped = true
    end
end

-- ============================================================================
-- SPACE MODE FLOATING BUTTONS (separate from terminal, right side)
-- ============================================================================
local spaceButtonContainer = Instance.new("Frame", gui)
spaceButtonContainer.Name = "SpaceAbilityButtons"
spaceButtonContainer.Size = UDim2.new(0, math.floor(160 * SF), 0, math.floor(200 * SF))
spaceButtonContainer.Position = UDim2.new(1, -(math.floor(170 * SF)), 0.5, -math.floor(100 * SF))
spaceButtonContainer.BackgroundColor3 = Colors.Gunmetal_Dark
spaceButtonContainer.BackgroundTransparency = 0.15
spaceButtonContainer.BorderSizePixel = 0
spaceButtonContainer.Visible = false
Instance.new("UICorner", spaceButtonContainer).CornerRadius = UDim.new(0, math.floor(12 * SF))
local spaceBorderStroke = Instance.new("UIStroke", spaceButtonContainer)
spaceBorderStroke.Color = Colors.Red_Primary
spaceBorderStroke.Thickness = 2
spaceBorderStroke.Transparency = 0.3

local spaceHeaderLabel = Instance.new("TextLabel", spaceButtonContainer)
spaceHeaderLabel.Size = UDim2.new(1, 0, 0, math.floor(28 * SF))
spaceHeaderLabel.Text = "◈ SPACE MODE ◈"
spaceHeaderLabel.TextColor3 = Colors.Red_Primary
spaceHeaderLabel.BackgroundColor3 = Colors.Gunmetal_Mid
spaceHeaderLabel.BackgroundTransparency = 0.3
spaceHeaderLabel.Font = Enum.Font.GothamBold
spaceHeaderLabel.TextSize = math.floor(11 * SF)
spaceHeaderLabel.BorderSizePixel = 0

local spBtnLayout = Instance.new("UIListLayout", spaceButtonContainer)
spBtnLayout.SortOrder = Enum.SortOrder.LayoutOrder
spBtnLayout.Padding = UDim.new(0, math.floor(4 * SF))

-- Space Grab (Hitbox)
local spaceGrabBtn = Instance.new("TextButton", spaceButtonContainer)
spaceGrabBtn.Size = UDim2.new(1, 0, 0, math.floor((isMobile and 46 or 38) * SF))
spaceGrabBtn.LayoutOrder = 2
spaceGrabBtn.Text = "⟐ SPACE GRAB"
spaceGrabBtn.TextColor3 = Colors.Red_Primary
spaceGrabBtn.BackgroundColor3 = Colors.Gunmetal_Dark
spaceGrabBtn.BackgroundTransparency = 0.3
spaceGrabBtn.Font = Enum.Font.GothamBold
spaceGrabBtn.TextSize = math.floor((isMobile and 12 or 11) * SF)
spaceGrabBtn.BorderSizePixel = 0
Instance.new("UICorner", spaceGrabBtn).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", spaceGrabBtn).Color = Colors.Red_Dim

-- Zero-G
local spaceZeroGBtn = Instance.new("TextButton", spaceButtonContainer)
spaceZeroGBtn.Size = UDim2.new(1, 0, 0, math.floor((isMobile and 46 or 38) * SF))
spaceZeroGBtn.LayoutOrder = 3
spaceZeroGBtn.Text = "◎ ZERO GRAVITY"
spaceZeroGBtn.TextColor3 = Colors.Red_Primary
spaceZeroGBtn.BackgroundColor3 = Colors.Gunmetal_Dark
spaceZeroGBtn.BackgroundTransparency = 0.3
spaceZeroGBtn.Font = Enum.Font.GothamBold
spaceZeroGBtn.TextSize = math.floor((isMobile and 12 or 11) * SF)
spaceZeroGBtn.BorderSizePixel = 0
Instance.new("UICorner", spaceZeroGBtn).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", spaceZeroGBtn).Color = Colors.Red_Dim

-- General Ability
local spaceAbilityBtn = Instance.new("TextButton", spaceButtonContainer)
spaceAbilityBtn.Size = UDim2.new(1, 0, 0, math.floor((isMobile and 46 or 38) * SF))
spaceAbilityBtn.LayoutOrder = 4
spaceAbilityBtn.Text = "⚡ ABILITY FIRE"
spaceAbilityBtn.TextColor3 = Colors.Red_Primary
spaceAbilityBtn.BackgroundColor3 = Colors.Gunmetal_Dark
spaceAbilityBtn.BackgroundTransparency = 0.3
spaceAbilityBtn.Font = Enum.Font.GothamBold
spaceAbilityBtn.TextSize = math.floor((isMobile and 12 or 11) * SF)
spaceAbilityBtn.BorderSizePixel = 0
Instance.new("UICorner", spaceAbilityBtn).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", spaceAbilityBtn).Color = Colors.Red_Dim

-- Drag for space buttons container
local spaceDragging = false
local spaceDragStart, spaceStartPos

spaceHeaderLabel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        spaceDragging = true
        spaceDragStart = input.Position
        spaceStartPos = spaceButtonContainer.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if spaceDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - spaceDragStart
        spaceButtonContainer.Position = UDim2.new(spaceStartPos.X.Scale, spaceStartPos.X.Offset + delta.X, spaceStartPos.Y.Scale, spaceStartPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        spaceDragging = false
    end
end)

-- Space Grab: 4x4x4 hitbox that captures parts and fires HtSpace on them
spaceGrabBtn.MouseButton1Click:Connect(function()
    addLog("Space Grab: Creating 4x4x4 hitbox...", false)
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        addLog("No character found", true)
        return
    end

    local hrp = char.HumanoidRootPart
    local hitboxSize = Vector3.new(4, 4, 4)
    local region = Region3.new(hrp.Position - hitboxSize / 2, hrp.Position + hitboxSize / 2)

    local partsInRegion = workspace:FindPartsInRegion3WithIgnoreList(region, {char}, 100)

    local hitCount = 0
    for _, part in ipairs(partsInRegion) do
        pcall(function()
            if htSpaceRemote then
                htSpaceRemote:FireServer(part)
                hitCount = hitCount + 1
            end
        end)
    end

    addLog("Space Grab hit " .. hitCount .. " parts", false)
end)

-- Zero-G: Fire sound + 7 seconds no gravity
spaceZeroGBtn.MouseButton1Click:Connect(function()
    addLog("Zero-G: Activating...", false)

    pcall(function()
        if zeroGSoundRemote then zeroGSoundRemote:FireServer() end
    end)

    local char = player.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bodyForce = Instance.new("BodyForce", hrp)
            bodyForce.Name = "ZeroGravity"
            bodyForce.Force = Vector3.new(0, workspace.Gravity * hrp.AssemblyMass, 0)

            addLog("Zero-G: Active for 7 seconds", false)
            spaceZeroGBtn.Text = "◎ ZERO-G ACTIVE (7s)"
            spaceZeroGBtn.BackgroundColor3 = Colors.Red_Deep

            task.spawn(function()
                for i = 7, 1, -1 do
                    spaceZeroGBtn.Text = "◎ ZERO-G (" .. i .. "s)"
                    task.wait(1)
                end
                if bodyForce and bodyForce.Parent then
                    bodyForce:Destroy()
                end
                spaceZeroGBtn.Text = "◎ ZERO GRAVITY"
                spaceZeroGBtn.BackgroundColor3 = Colors.Gunmetal_Dark
                addLog("Zero-G: Deactivated", false)
            end)
        end
    end
end)

-- General Ability fire
spaceAbilityBtn.MouseButton1Click:Connect(function()
    addLog("Space Ability: Firing GeneralAbility", false)
    pcall(function()
        if generalAbilityRemote then generalAbilityRemote:FireServer() end
    end)
end)

-- ============================================================================
-- TAB: OVERALL
-- ============================================================================
do
    local page = tabPages["Overall"]
    createSectionHeader(page, "KILLSTREAK MATRIX", 1)

    local gaugeFrame = Instance.new("Frame", page)
    gaugeFrame.Size = UDim2.new(1, 0, 0, math.floor(100 * SF))
    gaugeFrame.LayoutOrder = 2
    gaugeFrame.BackgroundColor3 = Colors.Gunmetal_Mid
    gaugeFrame.BackgroundTransparency = 0.2
    gaugeFrame.BorderSizePixel = 0
    Instance.new("UICorner", gaugeFrame).CornerRadius = UDim.new(0, math.floor(10 * SF))

    local gaugeAccent = Instance.new("Frame", gaugeFrame)
    gaugeAccent.Size = UDim2.new(0, math.floor(30 * SF), 0, 3)
    gaugeAccent.BackgroundColor3 = Colors.Red_Primary
    gaugeAccent.BorderSizePixel = 0

    local ksValue = Instance.new("TextLabel", gaugeFrame)
    ksValue.Size = UDim2.new(1, -math.floor(16 * SF), 0, math.floor(36 * SF))
    ksValue.Position = UDim2.new(0, math.floor(8 * SF), 0, math.floor(10 * SF))
    ksValue.Text = "16 → 532.090"
    ksValue.TextColor3 = Colors.Red_Primary
    ksValue.BackgroundTransparency = 1
    ksValue.Font = Enum.Font.GothamBold
    ksValue.TextSize = math.floor(22 * SF)
    ksValue.TextXAlignment = Enum.TextXAlignment.Left

    local ttlText = Instance.new("TextLabel", gaugeFrame)
    ttlText.Size = UDim2.new(1, -math.floor(16 * SF), 0, math.floor(20 * SF))
    ttlText.Position = UDim2.new(0, math.floor(8 * SF), 0, math.floor(55 * SF))
    ttlText.Text = "● TTL: 512.4/18.2 (4H)"
    ttlText.TextColor3 = Colors.Red_Dim
    ttlText.BackgroundTransparency = 1
    ttlText.Font = Enum.Font.Gotham
    ttlText.TextSize = math.floor(10 * SF)
    ttlText.TextXAlignment = Enum.TextXAlignment.Left

    createSectionHeader(page, "CRASH SEQUENCE", 3)

    local crashActive = false
    local crashButton = createButton(page, "⚠ CRASH SEQUENCE ⚠\n[ SYSTEM OVERRIDE ]", 4, function()
        if crashActive then addLog("CRASH ALREADY IN PROGRESS", true) return end
        crashActive = true
        addLog("!!! CRASH SEQUENCE INITIATED !!!", true)
        local flash = Instance.new("Frame", gui)
        flash.Size = UDim2.new(1, 0, 1, 0)
        flash.BackgroundColor3 = Colors.Red_Primary
        flash.BackgroundTransparency = 0.5
        flash.ZIndex = 100
        TweenService:Create(flash, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
        task.wait(0.1)
        flash:Destroy()
        local origPos = terminal.Position
        for i = 1, 12 do
            terminal.Position = UDim2.new(origPos.X.Scale, origPos.X.Offset + math.random(-6, 6), origPos.Y.Scale, origPos.Y.Offset + math.random(-4, 4))
            task.wait(0.02)
        end
        terminal.Position = origPos
        addLog("CRASH EXECUTED - REBOOTING", true)
        task.wait(2.5)
        crashActive = false
        addLog("SYSTEM REBOOT COMPLETE", false)
    end)
    crashButton.Size = UDim2.new(1, 0, 0, math.floor(70 * SF))

    local cBorder = crashButton:FindFirstChildWhichIsA("UIStroke")
    if cBorder then
        cBorder.Color = Colors.Red_Primary; cBorder.Thickness = 2
        task.spawn(function()
            while true do
                TweenService:Create(cBorder, TweenInfo.new(0.6), {Thickness = 3, Transparency = 0}):Play()
                task.wait(0.5)
                TweenService:Create(cBorder, TweenInfo.new(0.6), {Thickness = 2, Transparency = 0.5}):Play()
                task.wait(0.8)
            end
        end)
    end

    createSectionHeader(page, "SYSTEM STATUS", 6)
    local statusInfo = Instance.new("TextLabel", page)
    statusInfo.Size = UDim2.new(1, 0, 0, math.floor(40 * SF))
    statusInfo.LayoutOrder = 7
    statusInfo.Text = "● SYSTEM READY | ALL MODULES ONLINE"
    statusInfo.TextColor3 = Colors.Red_Dim
    statusInfo.BackgroundColor3 = Colors.Gunmetal_Mid
    statusInfo.BackgroundTransparency = 0.4
    statusInfo.Font = Enum.Font.Gotham
    statusInfo.TextSize = math.floor(9 * SF)
    statusInfo.TextWrapped = true
    statusInfo.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", statusInfo).CornerRadius = UDim.new(0, 6)
    Instance.new("UIPadding", statusInfo).PaddingLeft = UDim.new(0, 8)

    task.spawn(function()
        local streak = 16
        while true do
            task.wait(8)
            streak = streak + math.random(1, 4)
            ksValue.Text = streak .. " → " .. string.format("%.3f", streak * 33.25 + 0.09)
            addLog("Killstreak updated: " .. streak, false)
        end
    end)
end

-- ============================================================================
-- TAB: MORPH
-- ============================================================================
do
    local page = tabPages["Morph"]
    local currentMorph = "None"

    createSectionHeader(page, "MORPH PROTOCOL", 1)

    local morphStatusFrame = Instance.new("Frame", page)
    morphStatusFrame.Size = UDim2.new(1, 0, 0, math.floor(60 * SF))
    morphStatusFrame.LayoutOrder = 2
    morphStatusFrame.BackgroundColor3 = Colors.Gunmetal_Mid
    morphStatusFrame.BackgroundTransparency = 0.2
    morphStatusFrame.BorderSizePixel = 0
    Instance.new("UICorner", morphStatusFrame).CornerRadius = UDim.new(0, math.floor(8 * SF))

    local morphStatusDot = Instance.new("Frame", morphStatusFrame)
    morphStatusDot.Size = UDim2.new(0, math.floor(10 * SF), 0, math.floor(10 * SF))
    morphStatusDot.Position = UDim2.new(0, math.floor(10 * SF), 0, math.floor(10 * SF))
    morphStatusDot.BackgroundColor3 = Colors.Red_Dim
    morphStatusDot.BorderSizePixel = 0
    Instance.new("UICorner", morphStatusDot).CornerRadius = UDim.new(1, 0)

    local morphStatusLabel = Instance.new("TextLabel", morphStatusFrame)
    morphStatusLabel.Size = UDim2.new(1, -math.floor(30 * SF), 0, math.floor(18 * SF))
    morphStatusLabel.Position = UDim2.new(0, math.floor(26 * SF), 0, math.floor(6 * SF))
    morphStatusLabel.Text = "STATUS: STANDBY"
    morphStatusLabel.TextColor3 = Colors.Red_Dim
    morphStatusLabel.BackgroundTransparency = 1
    morphStatusLabel.Font = Enum.Font.GothamBold
    morphStatusLabel.TextSize = math.floor(11 * SF)
    morphStatusLabel.TextXAlignment = Enum.TextXAlignment.Left

    local morphCurrentLabel = Instance.new("TextLabel", morphStatusFrame)
    morphCurrentLabel.Size = UDim2.new(1, -math.floor(16 * SF), 0, math.floor(18 * SF))
    morphCurrentLabel.Position = UDim2.new(0, math.floor(10 * SF), 0, math.floor(30 * SF))
    morphCurrentLabel.Text = "ACTIVE MORPH: None"
    morphCurrentLabel.TextColor3 = Colors.Red_Dim
    morphCurrentLabel.BackgroundTransparency = 1
    morphCurrentLabel.Font = Enum.Font.Gotham
    morphCurrentLabel.TextSize = math.floor(10 * SF)
    morphCurrentLabel.TextXAlignment = Enum.TextXAlignment.Left

    createButton(page, "✕  CLEAR MORPH  ✕", 3, function()
        addLog("Clearing morph...", false)
        clearMorph()
        currentMorph = "None"
        morphCurrentLabel.Text = "ACTIVE MORPH: None"
        morphStatusLabel.Text = "STATUS: STANDBY"
        morphStatusLabel.TextColor3 = Colors.Red_Dim
        morphStatusDot.BackgroundColor3 = Colors.Red_Dim
        addLog("Morph cleared", false)
    end)

    createSectionHeader(page, "GHOST PROTOCOL", 4)

    local ghostActive = false
    createButton(page, "⟡ GHOST INVISIBILITY ⟡", 5, function()
        ghostActive = not ghostActive
        if ghostActive then
            addLog("Ghost invisibility ACTIVATED", true)
            if invisOnRemote then pcall(function() invisOnRemote:FireServer() end) end
            pcall(function() fireClickDetector(workspace.Lobby.Ghost) end)
        else
            addLog("Ghost invisibility DEACTIVATED", false)
            if invisOffRemote then pcall(function() invisOffRemote:FireServer() end) end
        end
    end)

    createSectionHeader(page, "MORPH SELECTOR (" .. #MorphNames .. ")", 6)

    local _, searchBox = createTextInput(page, "Search morphs...", 7)

    local morphGridContainer = Instance.new("Frame", page)
    morphGridContainer.Size = UDim2.new(1, 0, 0, 0)
    morphGridContainer.LayoutOrder = 8
    morphGridContainer.BackgroundTransparency = 1
    morphGridContainer.AutomaticSize = Enum.AutomaticSize.Y

    local gridLayout = Instance.new("UIGridLayout", morphGridContainer)
    local cellHeight = isMobile and math.floor(42 * SF) or math.floor(34 * SF)
    gridLayout.CellSize = UDim2.new(0.48, 0, 0, cellHeight)
    gridLayout.CellPadding = UDim2.new(0.02, 0, 0, math.floor(4 * SF))
    gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    gridLayout.FillDirectionMaxCells = 2

    local morphButtonRefs = {}
    for i, morphName in ipairs(MorphNames) do
        local morphBtn = Instance.new("TextButton", morphGridContainer)
        morphBtn.Name = "Morph_" .. morphName
        morphBtn.LayoutOrder = i
        morphBtn.Text = morphName
        morphBtn.TextColor3 = Colors.Red_Dim
        morphBtn.BackgroundColor3 = Colors.Gunmetal_Dark
        morphBtn.BackgroundTransparency = 0.3
        morphBtn.Font = Enum.Font.GothamBold
        morphBtn.TextSize = math.floor((isMobile and 10 or 9) * SF)
        morphBtn.BorderSizePixel = 0
        morphBtn.TextWrapped = true
        morphBtn.TextTruncate = Enum.TextTruncate.AtEnd
        Instance.new("UICorner", morphBtn).CornerRadius = UDim.new(0, math.floor(6 * SF))
        local mStroke = Instance.new("UIStroke", morphBtn)
        mStroke.Color = Colors.Gunmetal_Light; mStroke.Thickness = 1; mStroke.Transparency = 0.3

        morphBtn.MouseEnter:Connect(function()
            if currentMorph ~= morphName then
                TweenService:Create(morphBtn, TweenInfo.new(0.15), {BackgroundColor3 = Colors.Gunmetal_Light}):Play()
                TweenService:Create(mStroke, TweenInfo.new(0.15), {Color = Colors.Red_Primary, Transparency = 0}):Play()
                morphBtn.TextColor3 = Colors.Red_Primary
            end
        end)
        morphBtn.MouseLeave:Connect(function()
            if currentMorph ~= morphName then
                TweenService:Create(morphBtn, TweenInfo.new(0.15), {BackgroundColor3 = Colors.Gunmetal_Dark}):Play()
                TweenService:Create(mStroke, TweenInfo.new(0.15), {Color = Colors.Gunmetal_Light, Transparency = 0.3}):Play()
                morphBtn.TextColor3 = Colors.Red_Dim
            end
        end)

        morphBtn.MouseButton1Click:Connect(function()
            addLog("Morphing to: " .. morphName, false)
            morphStatusLabel.Text = "STATUS: MORPHING..."
            morphStatusLabel.TextColor3 = Colors.Red_Glow
            morphStatusDot.BackgroundColor3 = Colors.Red_Glow

            if morphButtonRefs[currentMorph] then
                local oldBtn = morphButtonRefs[currentMorph]
                TweenService:Create(oldBtn, TweenInfo.new(0.2), {BackgroundColor3 = Colors.Gunmetal_Dark}):Play()
                oldBtn.TextColor3 = Colors.Red_Dim
                local os2 = oldBtn:FindFirstChildWhichIsA("UIStroke")
                if os2 then TweenService:Create(os2, TweenInfo.new(0.2), {Color = Colors.Gunmetal_Light, Transparency = 0.3}):Play() end
            end

            fireMorph(morphName)
            currentMorph = morphName
            morphCurrentLabel.Text = "ACTIVE MORPH: " .. morphName
            TweenService:Create(morphBtn, TweenInfo.new(0.2), {BackgroundColor3 = Colors.Red_Deep}):Play()
            morphBtn.TextColor3 = Colors.Red_Primary
            TweenService:Create(mStroke, TweenInfo.new(0.2), {Color = Colors.Red_Primary, Transparency = 0}):Play()
            task.wait(0.3)
            morphStatusLabel.Text = "STATUS: ◈ ACTIVE ◈"
            morphStatusLabel.TextColor3 = Colors.Red_Primary
            morphStatusDot.BackgroundColor3 = Colors.Red_Primary
            addLog("Morph complete: " .. morphName, false)
        end)

        morphButtonRefs[morphName] = morphBtn
    end

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = searchBox.Text:lower()
        for morphName, btn in pairs(morphButtonRefs) do
            btn.Visible = query == "" or morphName:lower():find(query, 1, true) ~= nil
        end
    end)

    task.spawn(function()
        while true do
            if currentMorph ~= "None" then
                TweenService:Create(morphStatusDot, TweenInfo.new(0.5), {BackgroundTransparency = 0.3}):Play()
                task.wait(0.4)
                TweenService:Create(morphStatusDot, TweenInfo.new(0.5), {BackgroundTransparency = 0}):Play()
                task.wait(0.6)
            else task.wait(1) end
        end
    end)
end

-- ============================================================================
-- TAB: REPLICATE (v5 — Hit Dropdown + Executor + Full Abilities)
-- ============================================================================
do
    local page = tabPages["Replicate"]

    -- Remotes
    local generalHitRemote
    pcall(function() generalHitRemote = ReplicatedStorage:WaitForChild("GeneralHit", 5) end)

    -- ============================================================================
    -- HELPER: Collapsible Section
    -- ============================================================================
    local function createCollapsibleSection(parent, title, layoutOrder, defaultOpen)
        local container = Instance.new("Frame", parent)
        container.Size = UDim2.new(1, 0, 0, 0)
        container.LayoutOrder = layoutOrder
        container.BackgroundTransparency = 1
        container.AutomaticSize = Enum.AutomaticSize.Y
        container.ClipsDescendants = true

        local secLayout = Instance.new("UIListLayout", container)
        secLayout.SortOrder = Enum.SortOrder.LayoutOrder
        secLayout.Padding = UDim.new(0, math.floor(4 * SF))

        -- Header button
        local headerBtn = Instance.new("TextButton", container)
        headerBtn.Size = UDim2.new(1, 0, 0, math.floor((isMobile and 36 or 30) * SF))
        headerBtn.LayoutOrder = 0
        headerBtn.Text = (defaultOpen and "▼ " or "▶ ") .. title
        headerBtn.TextColor3 = Colors.Red_Primary
        headerBtn.BackgroundColor3 = Colors.Gunmetal_Mid
        headerBtn.BackgroundTransparency = 0.2
        headerBtn.Font = Enum.Font.GothamBold
        headerBtn.TextSize = math.floor((isMobile and 12 or 11) * SF)
        headerBtn.TextXAlignment = Enum.TextXAlignment.Left
        headerBtn.BorderSizePixel = 0
        Instance.new("UICorner", headerBtn).CornerRadius = UDim.new(0, math.floor(6 * SF))
        local hStroke = Instance.new("UIStroke", headerBtn)
        hStroke.Color = Colors.Red_Dim
        hStroke.Thickness = 1
        local hPad = Instance.new("UIPadding", headerBtn)
        hPad.PaddingLeft = UDim.new(0, math.floor(10 * SF))

        -- Content frame
        local content = Instance.new("Frame", container)
        content.Name = "Content"
        content.Size = UDim2.new(1, 0, 0, 0)
        content.LayoutOrder = 1
        content.BackgroundTransparency = 1
        content.AutomaticSize = Enum.AutomaticSize.Y
        content.Visible = defaultOpen or false

        local contentLayout = Instance.new("UIListLayout", content)
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Padding = UDim.new(0, math.floor(4 * SF))

        local isOpen = defaultOpen or false

        headerBtn.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            content.Visible = isOpen
            headerBtn.Text = (isOpen and "▼ " or "▶ ") .. title

            TweenService:Create(hStroke, TweenInfo.new(0.2), {
                Color = isOpen and Colors.Red_Primary or Colors.Red_Dim
            }):Play()
        end)

        headerBtn.MouseEnter:Connect(function()
            TweenService:Create(headerBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.05}):Play()
        end)
        headerBtn.MouseLeave:Connect(function()
            TweenService:Create(headerBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.2}):Play()
        end)

        return content, headerBtn
    end

    -- ============================================================================
    -- HELPER: Dropdown selector
    -- ============================================================================
    local function createDropdown(parent, options, placeholder, layoutOrder, onSelect)
        local dropFrame = Instance.new("Frame", parent)
        dropFrame.Size = UDim2.new(1, 0, 0, 0)
        dropFrame.LayoutOrder = layoutOrder
        dropFrame.BackgroundTransparency = 1
        dropFrame.AutomaticSize = Enum.AutomaticSize.Y
        dropFrame.ClipsDescendants = false

        local dropLayout = Instance.new("UIListLayout", dropFrame)
        dropLayout.SortOrder = Enum.SortOrder.LayoutOrder
        dropLayout.Padding = UDim.new(0, 0)

        local selectedValue = nil
        local isDropOpen = false

        -- Main button
        local mainBtn = Instance.new("TextButton", dropFrame)
        mainBtn.Size = UDim2.new(1, 0, 0, math.floor((isMobile and 44 or 36) * SF))
        mainBtn.LayoutOrder = 0
        mainBtn.Text = "▼ " .. placeholder
        mainBtn.TextColor3 = Colors.Red_Primary
        mainBtn.BackgroundColor3 = Colors.Gunmetal_Mid
        mainBtn.BackgroundTransparency = 0.2
        mainBtn.Font = Enum.Font.GothamBold
        mainBtn.TextSize = math.floor((isMobile and 12 or 11) * SF)
        mainBtn.TextXAlignment = Enum.TextXAlignment.Left
        mainBtn.BorderSizePixel = 0
        Instance.new("UICorner", mainBtn).CornerRadius = UDim.new(0, math.floor(6 * SF))
        Instance.new("UIStroke", mainBtn).Color = Colors.Red_Dim
        local mPad = Instance.new("UIPadding", mainBtn)
        mPad.PaddingLeft = UDim.new(0, math.floor(10 * SF))

        -- Options container
        local optionsFrame = Instance.new("Frame", dropFrame)
        optionsFrame.Name = "Options"
        optionsFrame.Size = UDim2.new(1, 0, 0, 0)
        optionsFrame.LayoutOrder = 1
        optionsFrame.BackgroundColor3 = Colors.Gunmetal_Dark
        optionsFrame.BackgroundTransparency = 0.1
        optionsFrame.BorderSizePixel = 0
        optionsFrame.Visible = false
        optionsFrame.AutomaticSize = Enum.AutomaticSize.Y
        optionsFrame.ZIndex = 50
        Instance.new("UICorner", optionsFrame).CornerRadius = UDim.new(0, math.floor(6 * SF))
        Instance.new("UIStroke", optionsFrame).Color = Colors.Red_Dim

        local optLayout = Instance.new("UIListLayout", optionsFrame)
        optLayout.SortOrder = Enum.SortOrder.LayoutOrder
        optLayout.Padding = UDim.new(0, 1)

        for i, opt in ipairs(options) do
            local optName = type(opt) == "table" and opt.name or opt
            local optBtn = Instance.new("TextButton", optionsFrame)
            optBtn.Size = UDim2.new(1, 0, 0, math.floor((isMobile and 38 or 30) * SF))
            optBtn.LayoutOrder = i
            optBtn.Text = "  " .. optName
            optBtn.TextColor3 = Colors.Red_Dim
            optBtn.BackgroundColor3 = Colors.Gunmetal_Dark
            optBtn.BackgroundTransparency = 0.3
            optBtn.Font = Enum.Font.Gotham
            optBtn.TextSize = math.floor((isMobile and 11 or 10) * SF)
            optBtn.TextXAlignment = Enum.TextXAlignment.Left
            optBtn.BorderSizePixel = 0
            optBtn.ZIndex = 51

            optBtn.MouseEnter:Connect(function()
                TweenService:Create(optBtn, TweenInfo.new(0.1), {BackgroundColor3 = Colors.Red_Deep, BackgroundTransparency = 0.1}):Play()
                optBtn.TextColor3 = Colors.Red_Primary
            end)
            optBtn.MouseLeave:Connect(function()
                TweenService:Create(optBtn, TweenInfo.new(0.1), {BackgroundColor3 = Colors.Gunmetal_Dark, BackgroundTransparency = 0.3}):Play()
                optBtn.TextColor3 = Colors.Red_Dim
            end)

            optBtn.MouseButton1Click:Connect(function()
                selectedValue = opt
                mainBtn.Text = "▼ " .. optName
                isDropOpen = false
                optionsFrame.Visible = false
                if onSelect then onSelect(opt) end
            end)
        end

        mainBtn.MouseButton1Click:Connect(function()
            isDropOpen = not isDropOpen
            optionsFrame.Visible = isDropOpen
        end)

        return dropFrame, function() return selectedValue end
    end

    -- ══════════════════════════════════════════════════════════════
    -- SECTION 1: RADIO
    -- ══════════════════════════════════════════════════════════════
    local radioContent = createCollapsibleSection(page, "RADIO REPLICATION", 1, false)

    local radioStatusLabel = Instance.new("TextLabel", radioContent)
    radioStatusLabel.Size = UDim2.new(1, 0, 0, math.floor(20 * SF))
    radioStatusLabel.LayoutOrder = 1
    radioStatusLabel.Text = "Enter a Roblox Audio ID to play"
    radioStatusLabel.TextColor3 = Colors.Red_Dim
    radioStatusLabel.BackgroundTransparency = 1
    radioStatusLabel.Font = Enum.Font.Gotham
    radioStatusLabel.TextSize = math.floor(9 * SF)
    radioStatusLabel.TextXAlignment = Enum.TextXAlignment.Left

    local _, radioIdBox = createTextInput(radioContent, "Enter Audio ID...", 2)

    createButton(radioContent, "▶  PLAY RADIO", 3, function()
        local id = radioIdBox.Text:gsub("%s+", "")
        if id == "" then
            radioStatusLabel.Text = "⚠ Enter an audio ID"; radioStatusLabel.TextColor3 = Colors.Red_Primary
            return
        end
        addLog("Radio: Playing " .. id, false)
        radioStatusLabel.Text = "▶ Playing: " .. id; radioStatusLabel.TextColor3 = Colors.Red_Primary
        pcall(function() if radioRemote then radioRemote:FireServer(tonumber(id) or id) end end)
    end)

    createButton(radioContent, "⏹  STOP RADIO", 4, function()
        radioStatusLabel.Text = "⏹ Stopped"; radioStatusLabel.TextColor3 = Colors.Red_Dim
        pcall(function() if radioRemote then radioRemote:FireServer(0) end end)
    end)

    -- ══════════════════════════════════════════════════════════════
    -- SECTION 2: GLOVE ABILITIES
    -- ══════════════════════════════════════════════════════════════
    local abilitiesContent = createCollapsibleSection(page, "GLOVE ABILITIES", 2, true)

    local abilityStatusLabel = Instance.new("TextLabel", abilitiesContent)
    abilityStatusLabel.Size = UDim2.new(1, 0, 0, math.floor(20 * SF))
    abilityStatusLabel.LayoutOrder = 1
    abilityStatusLabel.Text = "Replicate abilities from other gloves"
    abilityStatusLabel.TextColor3 = Colors.Red_Dim
    abilityStatusLabel.BackgroundTransparency = 1
    abilityStatusLabel.Font = Enum.Font.Gotham
    abilityStatusLabel.TextSize = math.floor(9 * SF)
    abilityStatusLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- SWAP
    createButton(abilitiesContent, "⇄  SWAP (Swapper Glove)", 2, function()
        abilityStatusLabel.Text = "⇄ Swap..."; abilityStatusLabel.TextColor3 = Colors.Red_Primary
        pcall(function() fireclickdetector(workspace.Lobby.Swapper:FindFirstChildOfClass("ClickDetector")) end)
        task.wait(0.15)
        pcall(function() if slocRemote then slocRemote:FireServer() end end)
        addLog("Swap executed", false)
        abilityStatusLabel.Text = "⇄ Swap Fired!"
        task.delay(2, function() abilityStatusLabel.Text = "Replicate abilities from other gloves"; abilityStatusLabel.TextColor3 = Colors.Red_Dim end)
    end)

    -- BRING
    createButton(abilitiesContent, "✊  BRING (Za Hando)", 3, function()
        abilityStatusLabel.Text = "✊ Bring..."; abilityStatusLabel.TextColor3 = Colors.Red_Primary
        pcall(function() fireclickdetector(workspace.Lobby["Za Hando"]:FindFirstChildOfClass("ClickDetector")) end)
        task.wait(0.15)
        pcall(function() if eraseRemote then eraseRemote:FireServer() end end)
        addLog("Bring executed", false)
        abilityStatusLabel.Text = "✊ Bring Fired!"
        task.delay(2, function() abilityStatusLabel.Text = "Replicate abilities from other gloves"; abilityStatusLabel.TextColor3 = Colors.Red_Dim end)
    end)

    -- SPACE MODE
    createButton(abilitiesContent, "🚀  SPACE MODE (Toggle Panel)", 4, function()
        spaceModeActive = not spaceModeActive
        if spaceModeActive then
            pcall(function() fireclickdetector(workspace.Lobby.Space:FindFirstChildOfClass("ClickDetector")) end)
            task.wait(0.2)
            spaceButtonContainer.Visible = true
            spaceButtonContainer.Position = UDim2.new(1, 20, 0.5, -math.floor(100 * SF))
            TweenService:Create(spaceButtonContainer, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
                Position = UDim2.new(1, -(math.floor(170 * SF)), 0.5, -math.floor(100 * SF))
            }):Play()
            abilityStatusLabel.Text = "🚀 Space Mode ACTIVE →"; abilityStatusLabel.TextColor3 = Colors.Red_Primary
            addLog("Space Mode: Active", false)
        else
            TweenService:Create(spaceButtonContainer, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Position = UDim2.new(1, 20, 0.5, -math.floor(100 * SF))
            }):Play()
            task.wait(0.3)
            spaceButtonContainer.Visible = false
            abilityStatusLabel.Text = "Space Mode OFF"; abilityStatusLabel.TextColor3 = Colors.Red_Dim
            addLog("Space Mode: Off", false)
        end
    end)

    -- ══════════════════════════════════════════════════════════════
    -- SECTION 3: JUMPSCARE (Built-in)
    -- ══════════════════════════════════════════════════════════════
    local jumpscareContent = createCollapsibleSection(page, "👻 JUMPSCARE GLOVE (Stalker)", 3, false)

    local jsStatusFrame = Instance.new("Frame", jumpscareContent)
    jsStatusFrame.Size = UDim2.new(1, 0, 0, math.floor(55 * SF))
    jsStatusFrame.LayoutOrder = 1
    jsStatusFrame.BackgroundColor3 = Colors.Gunmetal_Mid
    jsStatusFrame.BackgroundTransparency = 0.2
    jsStatusFrame.BorderSizePixel = 0
    Instance.new("UICorner", jsStatusFrame).CornerRadius = UDim.new(0, math.floor(8 * SF))

    local jsDot = Instance.new("Frame", jsStatusFrame)
    jsDot.Size = UDim2.new(0, math.floor(8 * SF), 0, math.floor(8 * SF))
    jsDot.Position = UDim2.new(0, math.floor(8 * SF), 0, math.floor(8 * SF))
    jsDot.BackgroundColor3 = Colors.Red_Dim; jsDot.BorderSizePixel = 0
    Instance.new("UICorner", jsDot).CornerRadius = UDim.new(1, 0)

    local jsStatusLabel = Instance.new("TextLabel", jsStatusFrame)
    jsStatusLabel.Size = UDim2.new(1, -math.floor(24 * SF), 0, math.floor(14 * SF))
    jsStatusLabel.Position = UDim2.new(0, math.floor(20 * SF), 0, math.floor(5 * SF))
    jsStatusLabel.Text = "JUMPSCARE: STANDBY"
    jsStatusLabel.TextColor3 = Colors.Red_Dim; jsStatusLabel.BackgroundTransparency = 1
    jsStatusLabel.Font = Enum.Font.GothamBold; jsStatusLabel.TextSize = math.floor(10 * SF)
    jsStatusLabel.TextXAlignment = Enum.TextXAlignment.Left

    local jsInfoLabel = Instance.new("TextLabel", jsStatusFrame)
    jsInfoLabel.Size = UDim2.new(1, -math.floor(12 * SF), 0, math.floor(12 * SF))
    jsInfoLabel.Position = UDim2.new(0, math.floor(8 * SF), 0, math.floor(22 * SF))
    jsInfoLabel.Text = "4×4×4 Hitbox | 65 Speed | 3s | Sound: 112559738033150"
    jsInfoLabel.TextColor3 = Colors.Gunmetal_Accent; jsInfoLabel.BackgroundTransparency = 1
    jsInfoLabel.Font = Enum.Font.Code; jsInfoLabel.TextSize = math.floor(7 * SF)
    jsInfoLabel.TextXAlignment = Enum.TextXAlignment.Left; jsInfoLabel.TextWrapped = true

    local jsHitLabel = Instance.new("TextLabel", jsStatusFrame)
    jsHitLabel.Size = UDim2.new(1, -math.floor(12 * SF), 0, math.floor(12 * SF))
    jsHitLabel.Position = UDim2.new(0, math.floor(8 * SF), 0, math.floor(37 * SF))
    jsHitLabel.Text = "Hits: 0 | Last: None"
    jsHitLabel.TextColor3 = Colors.Gunmetal_Accent; jsHitLabel.BackgroundTransparency = 1
    jsHitLabel.Font = Enum.Font.Gotham; jsHitLabel.TextSize = math.floor(8 * SF)
    jsHitLabel.TextXAlignment = Enum.TextXAlignment.Left

    local jumpscareActive = false
    local jumpscareHitCount = 0
    local jumpscareHitPlayers = {}
    local jumpscareConn = nil

    local function playJumpscareSound()
        pcall(function()
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local old = hrp:FindFirstChild("JumpscareSound")
            if old then old:Destroy() end
            local s = Instance.new("Sound", hrp)
            s.Name = "JumpscareSound"; s.SoundId = "rbxassetid://112559738033150"
            s.Volume = 1; s.Looped = false; s:Play()
            task.spawn(function() s.Ended:Wait(); if s.Parent then s:Destroy() end end)
        end)
    end

    local function createJumpscareHitbox()
        local char = player.Character
        if not char then return nil end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil end
        local old = char:FindFirstChild("JumpscareHitbox")
        if old then old:Destroy() end
        local hb = Instance.new("Part")
        hb.Name = "JumpscareHitbox"; hb.Size = Vector3.new(4, 4, 4)
        hb.Anchored = false; hb.CanCollide = false; hb.Transparency = 0.85
        hb.Color = Colors.Red_Primary; hb.Material = Enum.Material.ForceField; hb.Parent = char
        local w = Instance.new("WeldConstraint", hb); w.Part0 = hrp; w.Part1 = hb; hb.CFrame = hrp.CFrame
        return hb
    end

    local function removeJumpscareHitbox()
        local char = player.Character
        if char then local h = char:FindFirstChild("JumpscareHitbox"); if h then h:Destroy() end end
        if jumpscareConn then jumpscareConn:Disconnect(); jumpscareConn = nil end
    end

    local function startJumpscareScanning(hitbox)
        jumpscareHitPlayers = {}
        jumpscareConn = RunService.Heartbeat:Connect(function()
            if not hitbox or not hitbox.Parent then
                if jumpscareConn then jumpscareConn:Disconnect(); jumpscareConn = nil end; return
            end
            local hPos = hitbox.Position; local hHalf = hitbox.Size / 2
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player and not jumpscareHitPlayers[p.UserId] then
                    local pc = p.Character
                    if pc and pc:FindFirstChild("HumanoidRootPart") then
                        local d = pc.HumanoidRootPart.Position - hPos
                        if math.abs(d.X) <= hHalf.X and math.abs(d.Y) <= hHalf.Y and math.abs(d.Z) <= hHalf.Z then
                            jumpscareHitPlayers[p.UserId] = true
                            jumpscareHitCount = jumpscareHitCount + 1
                            pcall(function()
                                local la = pc:FindFirstChild("Left Arm") or pc:FindFirstChild("LeftHand") or pc:FindFirstChild("LeftUpperArm")
                                if la and generalHitRemote then generalHitRemote:FireServer(la, true, 48.448692321777344) end
                            end)
                            jsHitLabel.Text = "Hits: " .. jumpscareHitCount .. " | Last: " .. p.Name
                            addLog("JUMPSCARE HIT: " .. p.Name, true)
                        end
                    end
                end
            end
        end)
    end

    local jsActivateBtn = createButton(jumpscareContent, "👻  ACTIVATE JUMPSCARE", 2, function()
        if jumpscareActive then addLog("Jumpscare already active!", true); return end
        jumpscareActive = true; jumpscareHitCount = 0
        addLog("═══ JUMPSCARE INITIATED ═══", true)
        jsStatusLabel.Text = "JUMPSCARE: INIT..."; jsStatusLabel.TextColor3 = Colors.Red_Glow
        jsDot.BackgroundColor3 = Colors.Red_Glow

        pcall(function() fireclickdetector(workspace.Lobby.Stalker:FindFirstChildOfClass("ClickDetector")) end)
        task.wait(0.2)

        local char = player.Character; local origSpeed = 16
        if char then local h = char:FindFirstChildOfClass("Humanoid")
            if h then origSpeed = h.WalkSpeed; h.WalkSpeed = 65 end end

        playJumpscareSound()

        local hitbox = createJumpscareHitbox()
        if hitbox then startJumpscareScanning(hitbox) end
        jsStatusLabel.Text = "JUMPSCARE: HUNTING..."; jsStatusLabel.TextColor3 = Colors.Red_Primary
        jsDot.BackgroundColor3 = Colors.Red_Primary

        task.spawn(function()
            for i = 3, 1, -1 do
                if jumpscareActive then jsStatusLabel.Text = "JUMPSCARE: " .. i .. "s"; task.wait(1) end
            end
            jumpscareActive = false; removeJumpscareHitbox()
            local c = player.Character
            if c then local h = c:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed = origSpeed end end
            pcall(function() local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then local s = hrp:FindFirstChild("JumpscareSound"); if s then s:Destroy() end end end)
            jsStatusLabel.Text = "DONE: " .. jumpscareHitCount .. " hits"; jsStatusLabel.TextColor3 = Colors.Red_Dim
            jsDot.BackgroundColor3 = Colors.Red_Dim
            addLog("JUMPSCARE DONE: " .. jumpscareHitCount .. " hits", true)
            task.delay(3, function() jsStatusLabel.Text = "JUMPSCARE: STANDBY" end)
        end)
    end)

    createButton(jumpscareContent, "⛔  EMERGENCY STOP", 3, function()
        if not jumpscareActive then return end
        jumpscareActive = false; removeJumpscareHitbox()
        local c = player.Character; if c then local h = c:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed = 16 end end
        pcall(function() local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then local s = hrp:FindFirstChild("JumpscareSound"); if s then s:Destroy() end end end)
        jsStatusLabel.Text = "ABORTED"; jsStatusLabel.TextColor3 = Colors.Red_Dim; jsDot.BackgroundColor3 = Colors.Red_Dim
        addLog("Jumpscare aborted", true)
    end)

    -- ══════════════════════════════════════════════════════════════
    -- SECTION 4: HIT DROPDOWN (Various Hitbox Abilities)
    -- ══════════════════════════════════════════════════════════════
    local hitContent = createCollapsibleSection(page, "⚔ HIT ABILITIES (Dropdown)", 4, false)

    -- Hit ability definitions
    local hitAbilities = {
        {
            name = "GeneralHit — Left Arm",
            description = "Fires GeneralHit on target's Left Arm",
            remote = "GeneralHit",
            bodyPart = "Left Arm",
            fallbacks = {"LeftHand", "LeftUpperArm"},
            extraArgs = {true, 48.448692321777344},
        },
        {
            name = "GeneralHit — Right Arm",
            description = "Fires GeneralHit on target's Right Arm",
            remote = "GeneralHit",
            bodyPart = "Right Arm",
            fallbacks = {"RightHand", "RightUpperArm"},
            extraArgs = {true, 48.448692321777344},
        },
        {
            name = "GeneralHit — Head",
            description = "Fires GeneralHit on target's Head",
            remote = "GeneralHit",
            bodyPart = "Head",
            fallbacks = {},
            extraArgs = {true, 48.448692321777344},
        },
        {
            name = "GeneralHit — Torso",
            description = "Fires GeneralHit on target's Torso",
            remote = "GeneralHit",
            bodyPart = "Torso",
            fallbacks = {"UpperTorso", "LowerTorso", "HumanoidRootPart"},
            extraArgs = {true, 48.448692321777344},
        },
        {
            name = "GeneralHit — Left Leg",
            description = "Fires GeneralHit on target's Left Leg",
            remote = "GeneralHit",
            bodyPart = "Left Leg",
            fallbacks = {"LeftFoot", "LeftUpperLeg", "LeftLowerLeg"},
            extraArgs = {true, 48.448692321777344},
        },
        {
            name = "GeneralHit — Right Leg",
            description = "Fires GeneralHit on target's Right Leg",
            remote = "GeneralHit",
            bodyPart = "Right Leg",
            fallbacks = {"RightFoot", "RightUpperLeg", "RightLowerLeg"},
            extraArgs = {true, 48.448692321777344},
        },
        {
            name = "HtSpace — Right Arm",
            description = "Fires HtSpace on target's Right Arm (Space glove)",
            remote = "HtSpace",
            bodyPart = "Right Arm",
            fallbacks = {"RightHand", "RightUpperArm"},
            extraArgs = {},
        },
        {
            name = "HtSpace — Left Arm",
            description = "Fires HtSpace on target's Left Arm",
            remote = "HtSpace",
            bodyPart = "Left Arm",
            fallbacks = {"LeftHand", "LeftUpperArm"},
            extraArgs = {},
        },
        {
            name = "HtSpace — Head",
            description = "Fires HtSpace on target's Head",
            remote = "HtSpace",
            bodyPart = "Head",
            fallbacks = {},
            extraArgs = {},
        },
        {
            name = "GeneralHit — Custom Force",
            description = "GeneralHit with custom force value",
            remote = "GeneralHit",
            bodyPart = "Left Arm",
            fallbacks = {"LeftHand"},
            extraArgs = {true}, -- force will be appended from input
            customForce = true,
        },
    }

    -- Current selected hit ability
    local selectedHitAbility = nil

    local hitInfoLabel = Instance.new("TextLabel", hitContent)
    hitInfoLabel.Size = UDim2.new(1, 0, 0, math.floor(20 * SF))
    hitInfoLabel.LayoutOrder = 1
    hitInfoLabel.Text = "Select a hit ability, then choose targeting mode"
    hitInfoLabel.TextColor3 = Colors.Red_Dim; hitInfoLabel.BackgroundTransparency = 1
    hitInfoLabel.Font = Enum.Font.Gotham; hitInfoLabel.TextSize = math.floor(9 * SF)
    hitInfoLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Dropdown
    local _, getSelectedHit = createDropdown(hitContent, hitAbilities, "Select Hit Ability...", 2, function(selected)
        selectedHitAbility = selected
        hitInfoLabel.Text = "Selected: " .. selected.name .. " — " .. selected.description
        hitInfoLabel.TextColor3 = Colors.Red_Primary
        addLog("Hit ability selected: " .. selected.name, false)
    end)

    -- Custom force input (only visible for custom force ability)
    local _, hitForceBox = createTextInput(hitContent, "Custom force (default 48.45)...", 3)

    -- Radius input
    local _, hitRadiusBox = createTextInput(hitContent, "Hitbox radius (default 8 studs)...", 4)

    -- Hit status
    local hitStatusLabel = Instance.new("TextLabel", hitContent)
    hitStatusLabel.Size = UDim2.new(1, 0, 0, math.floor(20 * SF))
    hitStatusLabel.LayoutOrder = 5
    hitStatusLabel.Text = "Ready"
    hitStatusLabel.TextColor3 = Colors.Red_Dim; hitStatusLabel.BackgroundTransparency = 1
    hitStatusLabel.Font = Enum.Font.GothamBold; hitStatusLabel.TextSize = math.floor(10 * SF)
    hitStatusLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Fire function for hit abilities
    local function fireHitAbility(ability, targetPlayer)
        if not ability then addLog("No hit ability selected!", true); return end
        local remote = ReplicatedStorage:FindFirstChild(ability.remote)
        if not remote then addLog("Remote not found: " .. ability.remote, true); return end

        local pChar = targetPlayer.Character
        if not pChar then addLog("Target has no character: " .. targetPlayer.Name, true); return end

        -- Find body part with fallbacks
        local part = pChar:FindFirstChild(ability.bodyPart)
        if not part and ability.fallbacks then
            for _, fb in ipairs(ability.fallbacks) do
                part = pChar:FindFirstChild(fb)
                if part then break end
            end
        end
        if not part then addLog("Body part not found on " .. targetPlayer.Name, true); return end

        -- Build args
        local args = {part}
        if ability.extraArgs then
            for _, ea in ipairs(ability.extraArgs) do
                table.insert(args, ea)
            end
        end

        -- Custom force override
        if ability.customForce then
            local forceStr = hitForceBox.Text:gsub("%s+", "")
            local force = tonumber(forceStr) or 48.448692321777344
            table.insert(args, force)
        end

        pcall(function() remote:FireServer(unpack(args)) end)
        addLog("Hit: " .. ability.name .. " → " .. targetPlayer.Name .. " (" .. part.Name .. ")", false)
    end

    -- ── FIRE NEAREST ──
    createButton(hitContent, "⚔  HIT NEAREST PLAYER", 6, function()
        local ability = getSelectedHit()
        if not ability then hitStatusLabel.Text = "⚠ Select an ability first!"; hitStatusLabel.TextColor3 = Colors.Red_Primary; return end

        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local myPos = char.HumanoidRootPart.Position
        local closest, closestDist = nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local d = (p.Character.HumanoidRootPart.Position - myPos).Magnitude
                if d < closestDist then closest = p; closestDist = d end
            end
        end
        if closest then
            fireHitAbility(ability, closest)
            hitStatusLabel.Text = "⚔ Hit " .. closest.Name .. " (" .. math.floor(closestDist) .. "s)"
            hitStatusLabel.TextColor3 = Colors.Red_Primary
        else
            hitStatusLabel.Text = "No players nearby"; hitStatusLabel.TextColor3 = Colors.Red_Dim
        end
        task.delay(2, function() hitStatusLabel.Text = "Ready"; hitStatusLabel.TextColor3 = Colors.Red_Dim end)
    end)

    -- ── FIRE HITBOX (all in radius) ──
    createButton(hitContent, "⚔  HIT ALL IN RADIUS", 7, function()
        local ability = getSelectedHit()
        if not ability then hitStatusLabel.Text = "⚠ Select an ability first!"; hitStatusLabel.TextColor3 = Colors.Red_Primary; return end

        local radius = tonumber(hitRadiusBox.Text:gsub("%s+", "")) or 8
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local myPos = char.HumanoidRootPart.Position
        local hitCount = 0

        hitStatusLabel.Text = "Scanning " .. radius .. "s..."; hitStatusLabel.TextColor3 = Colors.Red_Glow

        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                if (p.Character.HumanoidRootPart.Position - myPos).Magnitude <= radius then
                    fireHitAbility(ability, p)
                    hitCount = hitCount + 1
                end
            end
        end

        hitStatusLabel.Text = "⚔ Hit " .. hitCount .. " players in " .. radius .. "s"
        hitStatusLabel.TextColor3 = Colors.Red_Primary
        addLog("Hit All: " .. hitCount .. " in " .. radius .. " studs", true)
        task.delay(3, function() hitStatusLabel.Text = "Ready"; hitStatusLabel.TextColor3 = Colors.Red_Dim end)
    end)

    -- ── HIT SPECIFIC PLAYER ──
    local _, hitPlayerBox = createTextInput(hitContent, "Player username...", 8)

    createButton(hitContent, "⚔  HIT SPECIFIC PLAYER", 9, function()
        local ability = getSelectedHit()
        if not ability then hitStatusLabel.Text = "⚠ Select ability!"; hitStatusLabel.TextColor3 = Colors.Red_Primary; return end
        local username = hitPlayerBox.Text:gsub("^%s+", ""):gsub("%s+$", "")
        if username == "" then hitStatusLabel.Text = "⚠ Enter username!"; hitStatusLabel.TextColor3 = Colors.Red_Primary; return end

        local target = Players:FindFirstChild(username)
        if not target then
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Name:lower():find(username:lower(), 1, true) or p.DisplayName:lower():find(username:lower(), 1, true) then
                    target = p; break
                end
            end
        end
        if target then
            fireHitAbility(ability, target)
            hitStatusLabel.Text = "⚔ Hit " .. target.Name; hitStatusLabel.TextColor3 = Colors.Red_Primary
        else
            hitStatusLabel.Text = "⚠ Player not found"; hitStatusLabel.TextColor3 = Colors.Red_Primary
        end
        task.delay(2, function() hitStatusLabel.Text = "Ready"; hitStatusLabel.TextColor3 = Colors.Red_Dim end)
    end)

    -- ── AUTO-HIT LOOP ──
    local autoHitActive = false
    local autoHitConn = nil

    createToggle(hitContent, "Auto-Hit Loop (Nearest, every 0.5s)", 10, false, function(state)
        autoHitActive = state
        local ability = getSelectedHit()
        if state then
            if not ability then addLog("Auto-Hit: Select ability first!", true); return end
            local radius = tonumber(hitRadiusBox.Text:gsub("%s+", "")) or 8
            addLog("Auto-Hit: ON | " .. ability.name .. " | " .. radius .. "s radius", true)
            hitStatusLabel.Text = "AUTO-HIT: ACTIVE"; hitStatusLabel.TextColor3 = Colors.Red_Glow

            autoHitConn = task.spawn(function()
                while autoHitActive do
                    local char = player.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local myPos = char.HumanoidRootPart.Position
                        for _, p in ipairs(Players:GetPlayers()) do
                            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                                if (p.Character.HumanoidRootPart.Position - myPos).Magnitude <= radius then
                                    pcall(function() fireHitAbility(ability, p) end)
                                end
                            end
                        end
                    end
                    task.wait(0.5)
                end
            end)
        else
            addLog("Auto-Hit: OFF", false)
            hitStatusLabel.Text = "AUTO-HIT: OFF"; hitStatusLabel.TextColor3 = Colors.Red_Dim
            task.delay(2, function() hitStatusLabel.Text = "Ready"; hitStatusLabel.TextColor3 = Colors.Red_Dim end)
        end
    end)

    -- ══════════════════════════════════════════════════════════════
    -- SECTION 5: SCRIPT EXECUTOR (100% UNC)
    -- ══════════════════════════════════════════════════════════════
    local execContent = createCollapsibleSection(page, "💻 SCRIPT EXECUTOR (UNC)", 5, false)

    -- Executor status bar
    local execStatusFrame = Instance.new("Frame", execContent)
    execStatusFrame.Size = UDim2.new(1, 0, 0, math.floor(28 * SF))
    execStatusFrame.LayoutOrder = 1
    execStatusFrame.BackgroundColor3 = Colors.Gunmetal_Mid
    execStatusFrame.BackgroundTransparency = 0.2
    execStatusFrame.BorderSizePixel = 0
    Instance.new("UICorner", execStatusFrame).CornerRadius = UDim.new(0, math.floor(6 * SF))

    local execDot = Instance.new("Frame", execStatusFrame)
    execDot.Size = UDim2.new(0, math.floor(8 * SF), 0, math.floor(8 * SF))
    execDot.Position = UDim2.new(0, math.floor(8 * SF), 0.5, -math.floor(4 * SF))
    execDot.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
    execDot.BorderSizePixel = 0
    Instance.new("UICorner", execDot).CornerRadius = UDim.new(1, 0)

    local execStatusText = Instance.new("TextLabel", execStatusFrame)
    execStatusText.Size = UDim2.new(1, -math.floor(24 * SF), 1, 0)
    execStatusText.Position = UDim2.new(0, math.floor(20 * SF), 0, 0)
    execStatusText.Text = "EXECUTOR READY | UNC LEVEL: " .. (identifyexecutor and (select(1, identifyexecutor()) or "Unknown") or "Unknown")
    execStatusText.TextColor3 = Colors.Red_Dim; execStatusText.BackgroundTransparency = 1
    execStatusText.Font = Enum.Font.Code; execStatusText.TextSize = math.floor(8 * SF)
    execStatusText.TextXAlignment = Enum.TextXAlignment.Left

    -- Script input (multi-line)
    local scriptInputFrame = Instance.new("Frame", execContent)
    scriptInputFrame.Size = UDim2.new(1, 0, 0, math.floor(160 * SF))
    scriptInputFrame.LayoutOrder = 2
    scriptInputFrame.BackgroundColor3 = Colors.Gunmetal_Dark
    scriptInputFrame.BackgroundTransparency = 0.05
    scriptInputFrame.BorderSizePixel = 0
    Instance.new("UICorner", scriptInputFrame).CornerRadius = UDim.new(0, math.floor(8 * SF))
    local execStroke = Instance.new("UIStroke", scriptInputFrame)
    execStroke.Color = Colors.Red_Dim; execStroke.Thickness = 1

    -- Line numbers
    local lineNumFrame = Instance.new("Frame", scriptInputFrame)
    lineNumFrame.Size = UDim2.new(0, math.floor(30 * SF), 1, -math.floor(8 * SF))
    lineNumFrame.Position = UDim2.new(0, math.floor(4 * SF), 0, math.floor(4 * SF))
    lineNumFrame.BackgroundColor3 = Colors.Gunmetal_Mid
    lineNumFrame.BackgroundTransparency = 0.5
    lineNumFrame.BorderSizePixel = 0
    Instance.new("UICorner", lineNumFrame).CornerRadius = UDim.new(0, 4)

    local lineNumLabel = Instance.new("TextLabel", lineNumFrame)
    lineNumLabel.Size = UDim2.new(1, 0, 1, 0)
    lineNumLabel.Text = "1\n2\n3\n4\n5\n6\n7\n8\n9\n10"
    lineNumLabel.TextColor3 = Colors.Gunmetal_Accent; lineNumLabel.BackgroundTransparency = 1
    lineNumLabel.Font = Enum.Font.Code; lineNumLabel.TextSize = math.floor((isMobile and 10 or 9) * SF)
    lineNumLabel.TextYAlignment = Enum.TextYAlignment.Top
    lineNumLabel.TextXAlignment = Enum.TextXAlignment.Center

    -- Code input
    local scriptBox = Instance.new("TextBox", scriptInputFrame)
    scriptBox.Size = UDim2.new(1, -(math.floor(42 * SF)), 1, -math.floor(8 * SF))
    scriptBox.Position = UDim2.new(0, math.floor(38 * SF), 0, math.floor(4 * SF))
    scriptBox.Text = ""
    scriptBox.PlaceholderText = "-- Enter Lua script here...\nprint('Hello World')"
    scriptBox.PlaceholderColor3 = Colors.Gunmetal_Accent
    scriptBox.TextColor3 = Colors.Red_Primary
    scriptBox.BackgroundTransparency = 1
    scriptBox.Font = Enum.Font.Code
    scriptBox.TextSize = math.floor((isMobile and 10 or 9) * SF)
    scriptBox.TextXAlignment = Enum.TextXAlignment.Left
    scriptBox.TextYAlignment = Enum.TextYAlignment.Top
    scriptBox.MultiLine = true
    scriptBox.ClearTextOnFocus = false
    scriptBox.TextWrapped = true

    -- Update line numbers when text changes
    scriptBox:GetPropertyChangedSignal("Text"):Connect(function()
        local text = scriptBox.Text
        local lineCount = 1
        for _ in text:gmatch("\n") do lineCount = lineCount + 1 end
        lineCount = math.max(lineCount, 10)
        local nums = {}
        for i = 1, lineCount do table.insert(nums, tostring(i)) end
        lineNumLabel.Text = table.concat(nums, "\n")
    end)

    -- Focus highlight
    scriptBox.Focused:Connect(function()
        TweenService:Create(execStroke, TweenInfo.new(0.2), {Color = Colors.Red_Primary, Thickness = 2}):Play()
    end)
    scriptBox.FocusLost:Connect(function()
        TweenService:Create(execStroke, TweenInfo.new(0.2), {Color = Colors.Red_Dim, Thickness = 1}):Play()
    end)

    -- Output console
    local execOutputFrame = Instance.new("ScrollingFrame", execContent)
    execOutputFrame.Size = UDim2.new(1, 0, 0, math.floor(100 * SF))
    execOutputFrame.LayoutOrder = 3
    execOutputFrame.BackgroundColor3 = Colors.Gunmetal_Dark
    execOutputFrame.BackgroundTransparency = 0.1
    execOutputFrame.BorderSizePixel = 0
    execOutputFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    execOutputFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    execOutputFrame.ScrollBarThickness = isMobile and 5 or 3
    execOutputFrame.ScrollBarImageColor3 = Colors.Red_Primary
    Instance.new("UICorner", execOutputFrame).CornerRadius = UDim.new(0, math.floor(6 * SF))
    Instance.new("UIStroke", execOutputFrame).Color = Colors.Gunmetal_Light

    local execOutputLayout = Instance.new("UIListLayout", execOutputFrame)
    execOutputLayout.SortOrder = Enum.SortOrder.LayoutOrder
    execOutputLayout.Padding = UDim.new(0, 1)
    local eoPad = Instance.new("UIPadding", execOutputFrame)
    eoPad.PaddingLeft = UDim.new(0, 6); eoPad.PaddingTop = UDim.new(0, 4); eoPad.PaddingRight = UDim.new(0, 6)

    local execLineCount = 0

    local function execLog(text, color)
        execLineCount = execLineCount + 1
        local entry = Instance.new("TextLabel", execOutputFrame)
        entry.Size = UDim2.new(1, 0, 0, 0); entry.AutomaticSize = Enum.AutomaticSize.Y
        entry.LayoutOrder = execLineCount; entry.Text = text
        entry.TextColor3 = color or Colors.Red_Dim; entry.BackgroundTransparency = 1
        entry.Font = Enum.Font.Code; entry.TextSize = math.floor((isMobile and 9 or 8) * SF)
        entry.TextXAlignment = Enum.TextXAlignment.Left; entry.TextWrapped = true
        task.defer(function()
            execOutputFrame.CanvasPosition = Vector2.new(0, execOutputFrame.AbsoluteCanvasSize.Y)
        end)
    end

    execLog(">_ Executor ready", Color3.fromRGB(0, 200, 80))
    execLog(">_ UNC functions available", Colors.Red_Dim)

    -- Script history
    local scriptHistory = {}
    local historyIndex = 0

    -- Button row
    local execBtnRow = Instance.new("Frame", execContent)
    execBtnRow.Size = UDim2.new(1, 0, 0, math.floor((isMobile and 44 or 36) * SF))
    execBtnRow.LayoutOrder = 4
    execBtnRow.BackgroundTransparency = 1

    local execBtnLayout = Instance.new("UIListLayout", execBtnRow)
    execBtnLayout.FillDirection = Enum.FillDirection.Horizontal
    execBtnLayout.SortOrder = Enum.SortOrder.LayoutOrder
    execBtnLayout.Padding = UDim.new(0, math.floor(4 * SF))

    -- Execute button
    local execBtn = Instance.new("TextButton", execBtnRow)
    execBtn.Size = UDim2.new(0.32, 0, 1, 0)
    execBtn.LayoutOrder = 1
    execBtn.Text = "▶ EXECUTE"
    execBtn.TextColor3 = Colors.Red_Primary
    execBtn.BackgroundColor3 = Colors.Red_Deep
    execBtn.BackgroundTransparency = 0.3
    execBtn.Font = Enum.Font.GothamBold
    execBtn.TextSize = math.floor((isMobile and 11 or 10) * SF)
    execBtn.BorderSizePixel = 0
    Instance.new("UICorner", execBtn).CornerRadius = UDim.new(0, math.floor(6 * SF))
    local execBtnStroke = Instance.new("UIStroke", execBtn)
    execBtnStroke.Color = Colors.Red_Primary; execBtnStroke.Thickness = 1

    execBtn.MouseEnter:Connect(function()
        TweenService:Create(execBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.1}):Play()
    end)
    execBtn.MouseLeave:Connect(function()
        TweenService:Create(execBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.3}):Play()
    end)

    -- Clear output
    local clearOutputBtn = Instance.new("TextButton", execBtnRow)
    clearOutputBtn.Size = UDim2.new(0.22, 0, 1, 0)
    clearOutputBtn.LayoutOrder = 2
    clearOutputBtn.Text = "🗑 CLEAR"
    clearOutputBtn.TextColor3 = Colors.Red_Dim
    clearOutputBtn.BackgroundColor3 = Colors.Gunmetal_Dark
    clearOutputBtn.BackgroundTransparency = 0.3
    clearOutputBtn.Font = Enum.Font.GothamBold
    clearOutputBtn.TextSize = math.floor((isMobile and 10 or 9) * SF)
    clearOutputBtn.BorderSizePixel = 0
    Instance.new("UICorner", clearOutputBtn).CornerRadius = UDim.new(0, math.floor(6 * SF))

    -- Clear editor
    local clearEditorBtn = Instance.new("TextButton", execBtnRow)
    clearEditorBtn.Size = UDim2.new(0.22, 0, 1, 0)
    clearEditorBtn.LayoutOrder = 3
    clearEditorBtn.Text = "📝 NEW"
    clearEditorBtn.TextColor3 = Colors.Red_Dim
    clearEditorBtn.BackgroundColor3 = Colors.Gunmetal_Dark
    clearEditorBtn.BackgroundTransparency = 0.3
    clearEditorBtn.Font = Enum.Font.GothamBold
    clearEditorBtn.TextSize = math.floor((isMobile and 10 or 9) * SF)
    clearEditorBtn.BorderSizePixel = 0
    Instance.new("UICorner", clearEditorBtn).CornerRadius = UDim.new(0, math.floor(6 * SF))

    -- History button
    local historyBtn = Instance.new("TextButton", execBtnRow)
    historyBtn.Size = UDim2.new(0.2, 0, 1, 0)
    historyBtn.LayoutOrder = 4
    historyBtn.Text = "⏪ HIST"
    historyBtn.TextColor3 = Colors.Red_Dim
    historyBtn.BackgroundColor3 = Colors.Gunmetal_Dark
    historyBtn.BackgroundTransparency = 0.3
    historyBtn.Font = Enum.Font.GothamBold
    historyBtn.TextSize = math.floor((isMobile and 10 or 9) * SF)
    historyBtn.BorderSizePixel = 0
    Instance.new("UICorner", historyBtn).CornerRadius = UDim.new(0, math.floor(6 * SF))

    -- Execute logic
    execBtn.MouseButton1Click:Connect(function()
        local code = scriptBox.Text
        if code:gsub("%s+", "") == "" then
            execLog("[!] Empty script", Colors.Red_Primary)
            return
        end

        -- Save to history
        table.insert(scriptHistory, code)
        historyIndex = #scriptHistory

        execLog(">_ Executing...", Colors.Red_Primary)
        execStatusText.Text = "EXECUTING..."
        execDot.BackgroundColor3 = Colors.Red_Primary

        -- Flash the execute button
        TweenService:Create(execBtn, TweenInfo.new(0.1), {BackgroundColor3 = Colors.Red_Primary}):Play()
        task.wait(0.1)
        TweenService:Create(execBtn, TweenInfo.new(0.2), {BackgroundColor3 = Colors.Red_Deep}):Play()

        -- Capture print output
        local oldPrint = print
        local oldWarn = warn
        local oldError = error
        local outputCapture = {}

        -- Override print temporarily
        local env = setmetatable({
            print = function(...)
                local args = {...}
                local strs = {}
                for _, v in ipairs(args) do table.insert(strs, tostring(v)) end
                local msg = table.concat(strs, " ")
                table.insert(outputCapture, {msg = msg, type = "print"})
                oldPrint(...)
            end,
            warn = function(...)
                local args = {...}
                local strs = {}
                for _, v in ipairs(args) do table.insert(strs, tostring(v)) end
                local msg = table.concat(strs, " ")
                table.insert(outputCapture, {msg = msg, type = "warn"})
                oldWarn(...)
            end,
            game = game,
            workspace = workspace,
            script = script,
            require = require,
            typeof = typeof,
            type = type,
            pcall = pcall,
            xpcall = xpcall,
            spawn = spawn,
            delay = delay,
            wait = wait,
            tick = tick,
            time = time,
            os = os,
            math = math,
            string = string,
            table = table,
            coroutine = coroutine,
            tostring = tostring,
            tonumber = tonumber,
            select = select,
            unpack = unpack,
            pairs = pairs,
            ipairs = ipairs,
            next = next,
            rawset = rawset,
            rawget = rawget,
            rawequal = rawequal,
            setmetatable = setmetatable,
            getmetatable = getmetatable,
            newproxy = newproxy,
            Enum = Enum,
            Instance = Instance,
            Vector3 = Vector3,
            Vector2 = Vector2,
            CFrame = CFrame,
            Color3 = Color3,
            BrickColor = BrickColor,
            UDim2 = UDim2,
            UDim = UDim,
            Ray = Ray,
            Region3 = Region3,
            Rect = Rect,
            TweenInfo = TweenInfo,
            NumberSequence = NumberSequence,
            NumberSequenceKeypoint = NumberSequenceKeypoint,
            ColorSequence = ColorSequence,
            ColorSequenceKeypoint = ColorSequenceKeypoint,
            NumberRange = NumberRange,
            task = task,
        }, {__index = getfenv()})

        local startTime = tick()
        local success, result = pcall(function()
            local fn, err = loadstring(code)
            if not fn then
                error("Syntax Error: " .. tostring(err))
            end
            setfenv(fn, env)
            return fn()
        end)
        local elapsed = math.floor((tick() - startTime) * 1000)

        -- Display captured output
        for _, out in ipairs(outputCapture) do
            if out.type == "print" then
                execLog("[OUT] " .. out.msg, Color3.fromRGB(0, 200, 80))
            elseif out.type == "warn" then
                execLog("[WARN] " .. out.msg, Color3.fromRGB(255, 200, 0))
            end
        end

        if success then
            if result ~= nil then
                execLog("[RETURN] " .. tostring(result), Color3.fromRGB(100, 200, 255))
            end
            execLog("[✓] Executed in " .. elapsed .. "ms", Color3.fromRGB(0, 200, 80))
            execStatusText.Text = "SUCCESS (" .. elapsed .. "ms)"
            execDot.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
            addLog("Executor: Success (" .. elapsed .. "ms)", false)
        else
            execLog("[✗] Error: " .. tostring(result), Colors.Red_Primary)
            execStatusText.Text = "ERROR"
            execDot.BackgroundColor3 = Colors.Red_Primary
            addLog("Executor: Error — " .. tostring(result), true)
        end

        task.delay(3, function()
            execStatusText.Text = "EXECUTOR READY"
            execDot.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
        end)
    end)

    -- Clear output
    clearOutputBtn.MouseButton1Click:Connect(function()
        for _, child in ipairs(execOutputFrame:GetChildren()) do
            if child:IsA("TextLabel") then child:Destroy() end
        end
        execLineCount = 0
        execLog(">_ Output cleared", Color3.fromRGB(0, 200, 80))
    end)

    -- Clear editor
    clearEditorBtn.MouseButton1Click:Connect(function()
        scriptBox.Text = ""
        execLog(">_ Editor cleared", Colors.Red_Dim)
    end)

    -- History navigation
    historyBtn.MouseButton1Click:Connect(function()
        if #scriptHistory == 0 then
            execLog("[!] No history", Colors.Red_Dim)
            return
        end
        historyIndex = historyIndex - 1
        if historyIndex < 1 then historyIndex = #scriptHistory end
        scriptBox.Text = scriptHistory[historyIndex]
        execLog(">_ History [" .. historyIndex .. "/" .. #scriptHistory .. "]", Colors.Red_Dim)
    end)

    -- Quick script templates
    local quickScriptsContent = createCollapsibleSection(execContent, "Quick Scripts", 5, false)

    local quickScripts = {
        {name = "Print All Players", code = 'for _, p in ipairs(game:GetService("Players"):GetPlayers()) do print(p.Name) end'},
        {name = "Get Position", code = 'print(game.Players.LocalPlayer.Character.HumanoidRootPart.Position)'},
        {name = "Speed 50", code = 'game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 50'},
        {name = "Jump 100", code = 'game.Players.LocalPlayer.Character.Humanoid.JumpPower = 100'},
        {name = "Reset Speed/Jump", code = 'local h = game.Players.LocalPlayer.Character.Humanoid; h.WalkSpeed = 16; h.JumpPower = 50'},
        {name = "List Remotes", code = 'for _, v in ipairs(game:GetService("ReplicatedStorage"):GetChildren()) do if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then print(v.ClassName .. ": " .. v.Name) end end'},
        {name = "List Workspace Children", code = 'for _, v in ipairs(workspace:GetChildren()) do print(v.ClassName .. ": " .. v.Name) end'},
        {name = "Get Executor Info", code = 'if identifyexecutor then print(identifyexecutor()) else print("Unknown executor") end'},
        {name = "Rejoin Server", code = 'game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)'},
        {name = "Server Hop", code = [[local TPS = game:GetService("TeleportService")
local Http = game:GetService("HttpService")
local servers = Http:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
for _, s in ipairs(servers.data) do
    if s.playing < s.maxPlayers and s.id ~= game.JobId then
        TPS:TeleportToPlaceInstance(game.PlaceId, s.id, game.Players.LocalPlayer)
        break
    end
end]]},
    }

    for i, qs in ipairs(quickScripts) do
        local qBtn = Instance.new("TextButton", quickScriptsContent)
        qBtn.Size = UDim2.new(1, 0, 0, math.floor((isMobile and 34 or 28) * SF))
        qBtn.LayoutOrder = i
        qBtn.Text = "▶ " .. qs.name
        qBtn.TextColor3 = Colors.Red_Dim
        qBtn.BackgroundColor3 = Colors.Gunmetal_Dark
        qBtn.BackgroundTransparency = 0.4
        qBtn.Font = Enum.Font.Gotham
        qBtn.TextSize = math.floor((isMobile and 10 or 9) * SF)
        qBtn.TextXAlignment = Enum.TextXAlignment.Left
        qBtn.BorderSizePixel = 0
        Instance.new("UICorner", qBtn).CornerRadius = UDim.new(0, 4)
        local qPad = Instance.new("UIPadding", qBtn)
        qPad.PaddingLeft = UDim.new(0, math.floor(8 * SF))

        qBtn.MouseEnter:Connect(function()
            TweenService:Create(qBtn, TweenInfo.new(0.1), {BackgroundTransparency = 0.2}):Play()
            qBtn.TextColor3 = Colors.Red_Primary
        end)
        qBtn.MouseLeave:Connect(function()
            TweenService:Create(qBtn, TweenInfo.new(0.1), {BackgroundTransparency = 0.4}):Play()
            qBtn.TextColor3 = Colors.Red_Dim
        end)

        qBtn.MouseButton1Click:Connect(function()
            scriptBox.Text = qs.code
            execLog(">_ Loaded: " .. qs.name, Colors.Red_Dim)
        end)
    end

    -- Clipboard paste button (mobile friendly)
    if isMobile then
        createButton(execContent, "📋  PASTE FROM CLIPBOARD", 6, function()
            execLog(">_ Use the text box to paste code", Colors.Red_Dim)
            scriptBox:CaptureFocus()
        end)
    end

    -- ══════════════════════════════════════════════════════════════
    -- SECTION 6: CUSTOM ABILITIES
    -- ══════════════════════════════════════════════════════════════
    local customContent = createCollapsibleSection(page, "📦 CUSTOM ABILITIES (Saved)", 6, false)

    local customAbilityContainer = Instance.new("Frame", customContent)
    customAbilityContainer.Size = UDim2.new(1, 0, 0, 0)
    customAbilityContainer.LayoutOrder = 1
    customAbilityContainer.BackgroundTransparency = 1
    customAbilityContainer.AutomaticSize = Enum.AutomaticSize.Y
    local cLayout = Instance.new("UIListLayout", customAbilityContainer)
    cLayout.SortOrder = Enum.SortOrder.LayoutOrder; cLayout.Padding = UDim.new(0, math.floor(4 * SF))

    local function resolveArg(argStr)
        local t = argStr:gsub("^%s+", ""):gsub("%s+$", "")
        if t == "" then return nil end
        if t:lower():sub(1,7) == "player:" then
            local u = t:sub(8); local r = Players:FindFirstChild(u)
            if not r then for _,p in ipairs(Players:GetPlayers()) do if p.Name:lower():find(u:lower(),1,true) then r=p;break end end end
            return r
        end
        if t:lower():sub(1,10) == "character:" then
            local u = t:sub(11); local r = Players:FindFirstChild(u)
            if not r then for _,p in ipairs(Players:GetPlayers()) do if p.Name:lower():find(u:lower(),1,true) then r=p;break end end end
            return r and r.Character
        end
        if t:lower():sub(1,9) == "bodypart:" then
            local rest = t:sub(10); local cp = rest:find(":")
            if cp then
                local u,pn = rest:sub(1,cp-1),rest:sub(cp+1)
                local r = Players:FindFirstChild(u)
                if not r then for _,p in ipairs(Players:GetPlayers()) do if p.Name:lower():find(u:lower(),1,true) then r=p;break end end end
                if r and r.Character then return r.Character:FindFirstChild(pn) end
            end; return nil
        end
        if t:lower():sub(1,10) == "workspace:" then
            local path = t:sub(11); local obj = workspace
            for part in path:gmatch("[^%.]+") do obj = obj:FindFirstChild(part); if not obj then return nil end end
            return obj
        end
        if t:lower():sub(1,7) == "number:" then return tonumber(t:sub(8)) end
        if t:lower() == "true" then return true end
        if t:lower() == "false" then return false end
        if t:lower() == "self" then return player end
        if t:lower() == "self_character" then return player.Character end
        if t:lower() == "nearest" then
            local c = player.Character; if c and c:FindFirstChild("HumanoidRootPart") then
                local mp = c.HumanoidRootPart.Position; local cl,cd = nil,math.huge
                for _,p in ipairs(Players:GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local d = (p.Character.HumanoidRootPart.Position - mp).Magnitude
                        if d < cd then cl=p;cd=d end
                    end
                end; return cl
            end; return nil
        end
        return t
    end

    local function fireCustomAbility(ability)
        addLog("Custom: " .. (ability.name or "?"), false)
        if ability.clickDetectorPath and ability.clickDetectorPath ~= "" then
            pcall(function()
                local obj = workspace
                for part in ability.clickDetectorPath:gmatch("[^%.]+") do
                    if part ~= "workspace" and part ~= "Workspace" then obj = obj:FindFirstChild(part); if not obj then break end end
                end
                if obj then local cd = obj:FindFirstChildOfClass("ClickDetector"); if cd then fireclickdetector(cd) end end
            end); task.wait(0.15)
        end
        if ability.remotes then
            for _, re in ipairs(ability.remotes) do
                local rn = type(re)=="table" and re.name or re
                local args = type(re)=="table" and re.args or {}
                local uh = type(re)=="table" and re.useHitbox or false
                local hr = type(re)=="table" and re.hitboxRadius or 4
                pcall(function()
                    local remote = ReplicatedStorage:FindFirstChild(rn)
                    if not remote then return end
                    if uh then
                        local c = player.Character
                        if c and c:FindFirstChild("HumanoidRootPart") then
                            local mp = c.HumanoidRootPart.Position
                            for _,p in ipairs(Players:GetPlayers()) do
                                if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                                    if (p.Character.HumanoidRootPart.Position - mp).Magnitude <= hr then
                                        local ra = {}
                                        for _,a in ipairs(args) do
                                            if a:lower() == "hitbox_target" then table.insert(ra,p)
                                            else table.insert(ra, resolveArg(a)) end
                                        end
                                        remote:FireServer(unpack(ra))
                                    end
                                end
                            end
                        end
                    else
                        local ra = {}
                        for _,a in ipairs(args) do local r = resolveArg(a); if r ~= nil then table.insert(ra,r) end end
                        if #ra > 0 then remote:FireServer(unpack(ra)) else remote:FireServer() end
                    end
                end); task.wait(0.05)
            end
        end
    end

    local function renderCustomAbilities()
        for _, child in ipairs(customAbilityContainer:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextButton") then child:Destroy() end
        end
        if #customAbilities == 0 then
            local el = Instance.new("TextLabel", customAbilityContainer)
            el.Size = UDim2.new(1,0,0,math.floor(24*SF)); el.LayoutOrder = 1
            el.Text = "No custom abilities saved."; el.TextColor3 = Colors.Gunmetal_Accent
            el.BackgroundTransparency = 1; el.Font = Enum.Font.Gotham
            el.TextSize = math.floor(9*SF); el.TextWrapped = true; return
        end
        for idx, ab in ipairs(customAbilities) do
            local af = Instance.new("Frame", customAbilityContainer)
            af.Size = UDim2.new(1,0,0,math.floor((isMobile and 52 or 44)*SF)); af.LayoutOrder = idx
            af.BackgroundColor3 = Colors.Gunmetal_Mid; af.BackgroundTransparency = 0.3; af.BorderSizePixel = 0
            Instance.new("UICorner", af).CornerRadius = UDim.new(0,math.floor(6*SF))
            Instance.new("UIStroke", af).Color = Colors.Red_Dim
            local an = Instance.new("TextLabel", af)
            an.Size = UDim2.new(0.5,0,0,math.floor(16*SF))
            an.Position = UDim2.new(0,math.floor(8*SF),0,math.floor(4*SF))
            an.Text = "◈ " .. (ab.name or "?"); an.TextColor3 = Colors.Red_Primary
            an.BackgroundTransparency = 1; an.Font = Enum.Font.GothamBold
            an.TextSize = math.floor(10*SF); an.TextXAlignment = Enum.TextXAlignment.Left
            local bH = isMobile and math.floor(26*SF) or math.floor(22*SF)
            local fb = Instance.new("TextButton", af)
            fb.Size = UDim2.new(0,math.floor(50*SF),0,bH)
            fb.Position = UDim2.new(1,-(math.floor(110*SF)),0,math.floor(4*SF))
            fb.Text = "▶"; fb.TextColor3 = Colors.Red_Primary
            fb.BackgroundColor3 = Colors.Gunmetal_Dark; fb.BackgroundTransparency = 0.3
            fb.Font = Enum.Font.GothamBold; fb.TextSize = math.floor(10*SF); fb.BorderSizePixel = 0
            Instance.new("UICorner", fb).CornerRadius = UDim.new(0,4)
            fb.MouseButton1Click:Connect(function() fireCustomAbility(ab) end)
            local db = Instance.new("TextButton", af)
            db.Size = UDim2.new(0,math.floor(40*SF),0,bH)
            db.Position = UDim2.new(1,-(math.floor(55*SF)),0,math.floor(4*SF))
            db.Text = "✕"; db.TextColor3 = Colors.Red_Dim
            db.BackgroundColor3 = Colors.Gunmetal_Dark; db.BackgroundTransparency = 0.3
            db.Font = Enum.Font.GothamBold; db.TextSize = math.floor(9*SF); db.BorderSizePixel = 0
            Instance.new("UICorner", db).CornerRadius = UDim.new(0,4)
            db.MouseButton1Click:Connect(function()
                table.remove(customAbilities, idx); saveCustomAbilities(); renderCustomAbilities()
            end)
        end
    end
    renderCustomAbilities()

    -- ── ADD ABILITY ──
    local addContent = createCollapsibleSection(customContent, "➕ ADD NEW ABILITY", 2, false)

    local function mfl(p,t,o)
        local l = Instance.new("TextLabel",p); l.Size = UDim2.new(1,0,0,math.floor(14*SF))
        l.LayoutOrder = o; l.Text = t; l.TextColor3 = Colors.Red_Dim; l.BackgroundTransparency = 1
        l.Font = Enum.Font.GothamBold; l.TextSize = math.floor(9*SF); l.TextXAlignment = Enum.TextXAlignment.Left
    end

    mfl(addContent, "Name:", 1)
    local _, anb = createTextInput(addContent, "Ability name...", 2)
    mfl(addContent, "ClickDetector Path:", 3)
    local _, acb = createTextInput(addContent, "e.g. Lobby.Swapper", 4)
    mfl(addContent, "Remote Name:", 5)
    local _, arb = createTextInput(addContent, "e.g. SM", 6)
    mfl(addContent, "Args (comma sep):", 7)
    local _, aab = createTextInput(addContent, "e.g. player:name, true, number:48", 8)
    mfl(addContent, "Hitbox?", 9)
    local hts = false
    createToggle(addContent, "Hitbox Mode", 10, false, function(s) hts = s end)
    mfl(addContent, "Radius:", 11)
    local _, ahrb = createTextInput(addContent, "Default: 4", 12)
    mfl(addContent, "Extra Remotes:", 13)
    local _, aerb = createTextInput(addContent, "e.g. SLOC, Erase", 14)

    local sb = Instance.new("TextButton", addContent)
    sb.Size = UDim2.new(1,0,0,math.floor((isMobile and 42 or 34)*SF)); sb.LayoutOrder = 20
    sb.Text = "💾 SAVE"; sb.TextColor3 = Colors.Red_Primary
    sb.BackgroundColor3 = Colors.Red_Deep; sb.BackgroundTransparency = 0.3
    sb.Font = Enum.Font.GothamBold; sb.TextSize = math.floor((isMobile and 13 or 12)*SF)
    sb.BorderSizePixel = 0
    Instance.new("UICorner", sb).CornerRadius = UDim.new(0,math.floor(6*SF))
    Instance.new("UIStroke", sb).Color = Colors.Red_Primary

    sb.MouseButton1Click:Connect(function()
        local nm = anb.Text:gsub("^%s+",""):gsub("%s+$","")
        if nm == "" then addLog("Name required!",true); return end
        local cd = acb.Text:gsub("^%s+",""):gsub("%s+$","")
        local rn = arb.Text:gsub("^%s+",""):gsub("%s+$","")
        local as = aab.Text:gsub("^%s+",""):gsub("%s+$","")
        local rs = ahrb.Text:gsub("^%s+",""):gsub("%s+$","")
        local es = aerb.Text:gsub("^%s+",""):gsub("%s+$","")
        local args = {}
        if as ~= "" then for a in as:gmatch("[^,]+") do local x = a:gsub("^%s+",""):gsub("%s+$",""); if x ~= "" then table.insert(args,x) end end end
        local rad = tonumber(rs) or 4
        local remotes = {}
        if rn ~= "" then table.insert(remotes, {name=rn, args=args, useHitbox=hts, hitboxRadius=rad}) end
        if es ~= "" then for r in es:gmatch("[^,]+") do local x = r:gsub("^%s+",""):gsub("%s+$",""); if x ~= "" then table.insert(remotes, {name=x, args={}, useHitbox=false, hitboxRadius=4}) end end end
        table.insert(customAbilities, {name=nm, clickDetectorPath=cd, remotes=remotes})
        saveCustomAbilities(); renderCustomAbilities()
        anb.Text=""; acb.Text=""; arb.Text=""; aab.Text=""; ahrb.Text=""; aerb.Text=""
        addLog("✓ Saved: " .. nm, false)
    end)
end

-- ============================================================================
-- TAB: ENTITIES (Radar, ESP, Tracking, Alerts, Death Log)
-- ============================================================================
do
    local page = tabPages["Entities"]

    -- ============================================================================
    -- STATE
    -- ============================================================================
    local espEnabled = false
    local espHighlights = {}
    local espLabels = {}
    local lockedTarget = nil
    local entityAlerts = {}
    local deathLog = {}
    local radarEnabled = false
    local alertScanConn = nil
    local espUpdateConn = nil
    local deathLogConn = nil

    -- Known boss/event entities to scan for
    local bossEntities = {
        "Kraken", "Rob", "Bob", "Reaper", "Titan", "Golem", "MEGAROCK",
        "Abomination", "Frenzy Bot", "Spider", "Scaretrap", "Poltergeist",
        "Imp", "Sentry", "Tank", "El Gato", "Juan", "Jerry", "Larry",
        "Sbeve", "Seal", "Squirrel", "Chicken", "Meowl"
    }

    -- ============================================================================
    -- HELPER: Create collapsible section (reuse from Replicate or define here)
    -- ============================================================================
    local function createEntCollapsible(parent, titleText, layoutOrder, defaultOpen)
        local container = Instance.new("Frame", parent)
        container.Size = UDim2.new(1, 0, 0, 0)
        container.LayoutOrder = layoutOrder
        container.BackgroundTransparency = 1
        container.AutomaticSize = Enum.AutomaticSize.Y
        container.ClipsDescendants = true

        local secLayout = Instance.new("UIListLayout", container)
        secLayout.SortOrder = Enum.SortOrder.LayoutOrder
        secLayout.Padding = UDim.new(0, math.floor(4 * SF))

        local headerBtn = Instance.new("TextButton", container)
        headerBtn.Size = UDim2.new(1, 0, 0, math.floor((isMobile and 36 or 30) * SF))
        headerBtn.LayoutOrder = 0
        headerBtn.Text = (defaultOpen and "▼ " or "▶ ") .. titleText
        headerBtn.TextColor3 = Colors.Red_Primary
        headerBtn.BackgroundColor3 = Colors.Gunmetal_Mid
        headerBtn.BackgroundTransparency = 0.2
        headerBtn.Font = Enum.Font.GothamBold
        headerBtn.TextSize = math.floor((isMobile and 12 or 11) * SF)
        headerBtn.TextXAlignment = Enum.TextXAlignment.Left
        headerBtn.BorderSizePixel = 0
        Instance.new("UICorner", headerBtn).CornerRadius = UDim.new(0, math.floor(6 * SF))
        local hStroke = Instance.new("UIStroke", headerBtn)
        hStroke.Color = Colors.Red_Dim; hStroke.Thickness = 1
        local hPad = Instance.new("UIPadding", headerBtn)
        hPad.PaddingLeft = UDim.new(0, math.floor(10 * SF))

        local content = Instance.new("Frame", container)
        content.Name = "Content"
        content.Size = UDim2.new(1, 0, 0, 0)
        content.LayoutOrder = 1
        content.BackgroundTransparency = 1
        content.AutomaticSize = Enum.AutomaticSize.Y
        content.Visible = defaultOpen or false

        local contentLayout = Instance.new("UIListLayout", content)
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Padding = UDim.new(0, math.floor(4 * SF))

        local isOpen = defaultOpen or false
        headerBtn.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            content.Visible = isOpen
            headerBtn.Text = (isOpen and "▼ " or "▶ ") .. titleText
            TweenService:Create(hStroke, TweenInfo.new(0.2), {Color = isOpen and Colors.Red_Primary or Colors.Red_Dim}):Play()
        end)
        headerBtn.MouseEnter:Connect(function() TweenService:Create(headerBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.05}):Play() end)
        headerBtn.MouseLeave:Connect(function() TweenService:Create(headerBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.2}):Play() end)

        return content, headerBtn
    end

    -- ============================================================================
    -- ESP SYSTEM — Red Circuit Fill + Red Outline
    -- ============================================================================
    local function createESPHighlight(targetPlayer)
        if espHighlights[targetPlayer.UserId] then return end

        local char = targetPlayer.Character
        if not char then return end

        -- Highlight with red circuit fill and red outline
        local highlight = Instance.new("Highlight")
        highlight.Name = "TerminalESP_" .. targetPlayer.Name
        highlight.Adornee = char
        highlight.FillColor = Colors.Red_Deep
        highlight.FillTransparency = 0.7
        highlight.OutlineColor = Colors.Red_Primary
        highlight.OutlineTransparency = 0.1
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = char

        -- Circuit line overlay using beams on the character
        -- We create SelectionBox-style circuit lines via multiple small parts
        local circuitFolder = Instance.new("Folder", char)
        circuitFolder.Name = "TerminalCircuitESP"

        -- Create circuit texture overlay using SurfaceGuis on each body part
        local bodyParts = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg",
                           "UpperTorso", "LowerTorso", "LeftUpperArm", "LeftLowerArm", "LeftHand",
                           "RightUpperArm", "RightLowerArm", "RightHand", "LeftUpperLeg", "LeftLowerLeg",
                           "LeftFoot", "RightUpperLeg", "RightLowerLeg", "RightFoot", "HumanoidRootPart"}

        for _, partName in ipairs(bodyParts) do
            local part = char:FindFirstChild(partName)
            if part and part:IsA("BasePart") then
                -- Circuit line effect using SelectionBox
                local selBox = Instance.new("SelectionBox", circuitFolder)
                selBox.Adornee = part
                selBox.Color3 = Colors.Red_Primary
                selBox.LineThickness = 0.02
                selBox.Transparency = 0.4
                selBox.SurfaceTransparency = 0.85
                selBox.SurfaceColor3 = Colors.Red_Dim

                -- Add pulsing circuit effect per part
                task.spawn(function()
                    local offset = math.random() * 2
                    while selBox and selBox.Parent do
                        local pulse = 0.3 + math.sin(tick() * 2 + offset) * 0.15
                        selBox.Transparency = pulse
                        selBox.SurfaceTransparency = 0.75 + math.sin(tick() * 3 + offset) * 0.1
                        task.wait(0.05)
                    end
                end)
            end
        end

        -- Billboard GUI for name/info display
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "TerminalESPLabel"
        billboard.Adornee = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
        billboard.Size = UDim2.new(0, math.floor(200 * SF), 0, math.floor(80 * SF))
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = char

        -- Name label
        local nameFrame = Instance.new("Frame", billboard)
        nameFrame.Size = UDim2.new(1, 0, 0, math.floor(22 * SF))
        nameFrame.BackgroundColor3 = Colors.Gunmetal_Dark
        nameFrame.BackgroundTransparency = 0.3
        nameFrame.BorderSizePixel = 0
        Instance.new("UICorner", nameFrame).CornerRadius = UDim.new(0, 4)
        Instance.new("UIStroke", nameFrame).Color = Colors.Red_Primary

        local nameLabel = Instance.new("TextLabel", nameFrame)
        nameLabel.Size = UDim2.new(1, 0, 1, 0)
        nameLabel.Text = "◈ " .. targetPlayer.Name
        nameLabel.TextColor3 = Colors.Red_Primary
        nameLabel.BackgroundTransparency = 1
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = math.floor(10 * SF)
        nameLabel.TextScaled = true

        -- Info label (distance + health)
        local infoFrame = Instance.new("Frame", billboard)
        infoFrame.Size = UDim2.new(1, 0, 0, math.floor(16 * SF))
        infoFrame.Position = UDim2.new(0, 0, 0, math.floor(24 * SF))
        infoFrame.BackgroundColor3 = Colors.Gunmetal_Dark
        infoFrame.BackgroundTransparency = 0.5
        infoFrame.BorderSizePixel = 0
        Instance.new("UICorner", infoFrame).CornerRadius = UDim.new(0, 3)

        local infoLabel = Instance.new("TextLabel", infoFrame)
        infoLabel.Size = UDim2.new(1, 0, 1, 0)
        infoLabel.Text = "..."
        infoLabel.TextColor3 = Colors.Red_Dim
        infoLabel.BackgroundTransparency = 1
        infoLabel.Font = Enum.Font.Code
        infoLabel.TextSize = math.floor(8 * SF)
        infoLabel.TextScaled = true

        -- Health bar
        local healthBarBg = Instance.new("Frame", billboard)
        healthBarBg.Size = UDim2.new(0.8, 0, 0, math.floor(4 * SF))
        healthBarBg.Position = UDim2.new(0.1, 0, 0, math.floor(42 * SF))
        healthBarBg.BackgroundColor3 = Colors.Gunmetal_Dark
        healthBarBg.BackgroundTransparency = 0.3
        healthBarBg.BorderSizePixel = 0
        Instance.new("UICorner", healthBarBg).CornerRadius = UDim.new(1, 0)

        local healthBarFill = Instance.new("Frame", healthBarBg)
        healthBarFill.Size = UDim2.new(1, 0, 1, 0)
        healthBarFill.BackgroundColor3 = Colors.Red_Primary
        healthBarFill.BorderSizePixel = 0
        Instance.new("UICorner", healthBarFill).CornerRadius = UDim.new(1, 0)

        -- Locked indicator
        local lockIndicator = Instance.new("TextLabel", billboard)
        lockIndicator.Size = UDim2.new(1, 0, 0, math.floor(14 * SF))
        lockIndicator.Position = UDim2.new(0, 0, 0, math.floor(50 * SF))
        lockIndicator.Text = ""
        lockIndicator.TextColor3 = Colors.Red_Glow
        lockIndicator.BackgroundTransparency = 1
        lockIndicator.Font = Enum.Font.GothamBold
        lockIndicator.TextSize = math.floor(9 * SF)
        lockIndicator.TextScaled = true
        lockIndicator.Name = "LockIndicator"

        espHighlights[targetPlayer.UserId] = {
            highlight = highlight,
            circuitFolder = circuitFolder,
            billboard = billboard,
            infoLabel = infoLabel,
            healthBarFill = healthBarFill,
            lockIndicator = lockIndicator,
            nameLabel = nameLabel,
        }
    end

    local function removeESPHighlight(userId)
        local data = espHighlights[userId]
        if data then
            pcall(function() data.highlight:Destroy() end)
            pcall(function() data.circuitFolder:Destroy() end)
            pcall(function() data.billboard:Destroy() end)
            espHighlights[userId] = nil
        end
    end

    local function clearAllESP()
        for userId, _ in pairs(espHighlights) do
            removeESPHighlight(userId)
        end
        espHighlights = {}
    end

    local function updateESPInfo()
        local myChar = player.Character
        local myPos = myChar and myChar:FindFirstChild("HumanoidRootPart") and myChar.HumanoidRootPart.Position

        for userId, data in pairs(espHighlights) do
            local targetPlayer = Players:GetPlayerByUserId(userId)
            if not targetPlayer or not targetPlayer.Character then
                removeESPHighlight(userId)
            else
                local tChar = targetPlayer.Character
                local tHum = tChar:FindFirstChildOfClass("Humanoid")
                local tHRP = tChar:FindFirstChild("HumanoidRootPart")

                -- Update info
                local dist = "?"
                if myPos and tHRP then
                    dist = math.floor((tHRP.Position - myPos).Magnitude)
                end

                local hp = "?"
                local hpPct = 1
                if tHum then
                    hp = math.floor(tHum.Health) .. "/" .. math.floor(tHum.MaxHealth)
                    hpPct = tHum.Health / tHum.MaxHealth
                end

                -- Detect glove (look for tool in character or backpack)
                local glove = "None"
                for _, tool in ipairs(tChar:GetChildren()) do
                    if tool:IsA("Tool") then glove = tool.Name; break end
                end
                if glove == "None" then
                    local bp = targetPlayer:FindFirstChild("Backpack")
                    if bp then
                        for _, tool in ipairs(bp:GetChildren()) do
                            if tool:IsA("Tool") then glove = tool.Name; break end
                        end
                    end
                end

                if data.infoLabel then
                    data.infoLabel.Text = dist .. "s | HP: " .. hp .. " | " .. glove
                end

                if data.healthBarFill then
                    TweenService:Create(data.healthBarFill, TweenInfo.new(0.3), {
                        Size = UDim2.new(math.clamp(hpPct, 0, 1), 0, 1, 0),
                        BackgroundColor3 = hpPct > 0.5 and Colors.Red_Primary or (hpPct > 0.25 and Color3.fromRGB(255, 150, 0) or Color3.fromRGB(255, 50, 50))
                    }):Play()
                end

                -- Lock indicator
                if data.lockIndicator then
                    if lockedTarget and lockedTarget == targetPlayer then
                        data.lockIndicator.Text = "🔒 LOCKED"
                        data.nameLabel.TextColor3 = Colors.Red_Glow

                        -- Pulse the highlight for locked target
                        data.highlight.OutlineColor = Color3.fromRGB(
                            255,
                            math.floor(20 + math.sin(tick() * 4) * 30),
                            math.floor(30 + math.sin(tick() * 4) * 20)
                        )
                        data.highlight.FillTransparency = 0.5 + math.sin(tick() * 3) * 0.15
                    else
                        data.lockIndicator.Text = ""
                        data.nameLabel.TextColor3 = Colors.Red_Primary
                        data.highlight.OutlineColor = Colors.Red_Primary
                        data.highlight.FillTransparency = 0.7
                    end
                end
            end
        end
    end

    -- ============================================================================
    -- SECTION 1: ESP CONTROLS
    -- ============================================================================
    local espContent = createEntCollapsible(page, "👁 ESP / HIGHLIGHTS", 1, true)

    local espStatusFrame = Instance.new("Frame", espContent)
    espStatusFrame.Size = UDim2.new(1, 0, 0, math.floor(40 * SF))
    espStatusFrame.LayoutOrder = 1
    espStatusFrame.BackgroundColor3 = Colors.Gunmetal_Mid
    espStatusFrame.BackgroundTransparency = 0.2
    espStatusFrame.BorderSizePixel = 0
    Instance.new("UICorner", espStatusFrame).CornerRadius = UDim.new(0, math.floor(8 * SF))

    local espDot = Instance.new("Frame", espStatusFrame)
    espDot.Size = UDim2.new(0, math.floor(8 * SF), 0, math.floor(8 * SF))
    espDot.Position = UDim2.new(0, math.floor(8 * SF), 0.5, -math.floor(4 * SF))
    espDot.BackgroundColor3 = Colors.Red_Dim; espDot.BorderSizePixel = 0
    Instance.new("UICorner", espDot).CornerRadius = UDim.new(1, 0)

    local espStatusLabel = Instance.new("TextLabel", espStatusFrame)
    espStatusLabel.Size = UDim2.new(1, -math.floor(24 * SF), 0, math.floor(14 * SF))
    espStatusLabel.Position = UDim2.new(0, math.floor(22 * SF), 0, math.floor(4 * SF))
    espStatusLabel.Text = "ESP: OFF"
    espStatusLabel.TextColor3 = Colors.Red_Dim; espStatusLabel.BackgroundTransparency = 1
    espStatusLabel.Font = Enum.Font.GothamBold; espStatusLabel.TextSize = math.floor(10 * SF)
    espStatusLabel.TextXAlignment = Enum.TextXAlignment.Left

    local espInfoLabel = Instance.new("TextLabel", espStatusFrame)
    espInfoLabel.Size = UDim2.new(1, -math.floor(12 * SF), 0, math.floor(12 * SF))
    espInfoLabel.Position = UDim2.new(0, math.floor(8 * SF), 0, math.floor(22 * SF))
    espInfoLabel.Text = "Red circuit highlighting | Names + HP + Distance + Glove"
    espInfoLabel.TextColor3 = Colors.Gunmetal_Accent; espInfoLabel.BackgroundTransparency = 1
    espInfoLabel.Font = Enum.Font.Code; espInfoLabel.TextSize = math.floor(7 * SF)
    espInfoLabel.TextXAlignment = Enum.TextXAlignment.Left; espInfoLabel.TextWrapped = true

    -- ESP Toggle
    createToggle(espContent, "Enable ESP (Red Circuit Highlights)", 2, false, function(state)
        espEnabled = state
        if state then
            addLog("ESP: ENABLED — Circuit highlights active", true)
            espStatusLabel.Text = "ESP: ACTIVE"; espStatusLabel.TextColor3 = Colors.Red_Primary
            espDot.BackgroundColor3 = Colors.Red_Primary

            -- Create ESP for all current players
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player and p.Character then
                    createESPHighlight(p)
                end
            end

            -- Update loop
            espUpdateConn = RunService.Heartbeat:Connect(function()
                if not espEnabled then return end
                updateESPInfo()
            end)

            -- Listen for new players
            Players.PlayerAdded:Connect(function(p)
                if espEnabled then
                    p.CharacterAdded:Connect(function()
                        task.wait(1)
                        if espEnabled then createESPHighlight(p) end
                    end)
                end
            end)

            -- Listen for character respawns
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player then
                    p.CharacterAdded:Connect(function()
                        task.wait(1)
                        if espEnabled then
                            removeESPHighlight(p.UserId)
                            createESPHighlight(p)
                        end
                    end)
                end
            end
        else
            addLog("ESP: DISABLED", false)
            espStatusLabel.Text = "ESP: OFF"; espStatusLabel.TextColor3 = Colors.Red_Dim
            espDot.BackgroundColor3 = Colors.Red_Dim
            clearAllESP()
            if espUpdateConn then espUpdateConn:Disconnect(); espUpdateConn = nil end
        end
    end)

    -- ============================================================================
    -- SECTION 2: TARGET LOCK-ON
    -- ============================================================================
    local lockContent = createEntCollapsible(page, "🔒 TARGET LOCK-ON", 2, false)

    local lockStatusLabel = Instance.new("TextLabel", lockContent)
    lockStatusLabel.Size = UDim2.new(1, 0, 0, math.floor(24 * SF))
    lockStatusLabel.LayoutOrder = 1
    lockStatusLabel.Text = "LOCKED TARGET: None"
    lockStatusLabel.TextColor3 = Colors.Red_Dim; lockStatusLabel.BackgroundTransparency = 1
    lockStatusLabel.Font = Enum.Font.GothamBold; lockStatusLabel.TextSize = math.floor(10 * SF)
    lockStatusLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Lock nearest
    createButton(lockContent, "🔒 LOCK NEAREST PLAYER", 2, function()
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local myPos = char.HumanoidRootPart.Position
        local closest, closestDist = nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local d = (p.Character.HumanoidRootPart.Position - myPos).Magnitude
                if d < closestDist then closest = p; closestDist = d end
            end
        end
        if closest then
            lockedTarget = closest
            lockStatusLabel.Text = "🔒 LOCKED: " .. closest.Name .. " (" .. math.floor(closestDist) .. "s)"
            lockStatusLabel.TextColor3 = Colors.Red_Primary
            addLog("Target locked: " .. closest.Name, true)
        end
    end)

    -- Lock by name
    local _, lockNameBox = createTextInput(lockContent, "Enter player name to lock...", 3)

    createButton(lockContent, "🔒 LOCK BY NAME", 4, function()
        local username = lockNameBox.Text:gsub("^%s+", ""):gsub("%s+$", "")
        if username == "" then return end
        local target = nil
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and (p.Name:lower():find(username:lower(), 1, true) or p.DisplayName:lower():find(username:lower(), 1, true)) then
                target = p; break
            end
        end
        if target then
            lockedTarget = target
            lockStatusLabel.Text = "🔒 LOCKED: " .. target.Name
            lockStatusLabel.TextColor3 = Colors.Red_Primary
            addLog("Target locked: " .. target.Name, true)
        else
            lockStatusLabel.Text = "⚠ Player not found"; lockStatusLabel.TextColor3 = Colors.Red_Primary
        end
    end)

    -- Unlock
    createButton(lockContent, "🔓 UNLOCK TARGET", 5, function()
        lockedTarget = nil
        lockStatusLabel.Text = "LOCKED TARGET: None"
        lockStatusLabel.TextColor3 = Colors.Red_Dim
        addLog("Target unlocked", false)
    end)

    -- Teleport to locked target
    createButton(lockContent, "📍 TELEPORT TO LOCKED TARGET", 6, function()
        if not lockedTarget then
            lockStatusLabel.Text = "⚠ No target locked"; return
        end
        local tChar = lockedTarget.Character
        if tChar and tChar:FindFirstChild("HumanoidRootPart") then
            local myChar = player.Character
            if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                myChar.HumanoidRootPart.CFrame = tChar.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
                addLog("Teleported to " .. lockedTarget.Name, false)
            end
        end
    end)

    -- Player list with lock buttons
    local lockPlayerContainer = Instance.new("Frame", lockContent)
    lockPlayerContainer.Size = UDim2.new(1, 0, 0, 0)
    lockPlayerContainer.LayoutOrder = 7
    lockPlayerContainer.BackgroundTransparency = 1
    lockPlayerContainer.AutomaticSize = Enum.AutomaticSize.Y

    local lockPlayerGrid = Instance.new("UIGridLayout", lockPlayerContainer)
    local lpCellH = isMobile and math.floor(38 * SF) or math.floor(30 * SF)
    lockPlayerGrid.CellSize = UDim2.new(0.48, 0, 0, lpCellH)
    lockPlayerGrid.CellPadding = UDim2.new(0.02, 0, 0, math.floor(3 * SF))
    lockPlayerGrid.SortOrder = Enum.SortOrder.LayoutOrder
    lockPlayerGrid.FillDirectionMaxCells = 2

    local function refreshLockPlayerList()
        for _, child in ipairs(lockPlayerContainer:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        local idx = 0
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player then
                idx = idx + 1
                local pBtn = Instance.new("TextButton", lockPlayerContainer)
                pBtn.LayoutOrder = idx
                pBtn.Text = (lockedTarget == p and "🔒 " or "○ ") .. p.Name
                pBtn.TextColor3 = lockedTarget == p and Colors.Red_Primary or Colors.Red_Dim
                pBtn.BackgroundColor3 = lockedTarget == p and Colors.Red_Deep or Colors.Gunmetal_Dark
                pBtn.BackgroundTransparency = 0.3
                pBtn.Font = Enum.Font.GothamBold
                pBtn.TextSize = math.floor((isMobile and 9 or 8) * SF)
                pBtn.BorderSizePixel = 0; pBtn.TextWrapped = true; pBtn.TextTruncate = Enum.TextTruncate.AtEnd
                Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0, math.floor(5 * SF))
                Instance.new("UIStroke", pBtn).Color = lockedTarget == p and Colors.Red_Primary or Colors.Gunmetal_Light

                pBtn.MouseButton1Click:Connect(function()
                    if lockedTarget == p then
                        lockedTarget = nil
                        lockStatusLabel.Text = "LOCKED TARGET: None"; lockStatusLabel.TextColor3 = Colors.Red_Dim
                        addLog("Unlocked: " .. p.Name, false)
                    else
                        lockedTarget = p
                        lockStatusLabel.Text = "🔒 LOCKED: " .. p.Name; lockStatusLabel.TextColor3 = Colors.Red_Primary
                        addLog("Locked: " .. p.Name, true)
                    end
                    refreshLockPlayerList()
                end)
            end
        end
    end

    createButton(lockContent, "🔄 REFRESH PLAYER LIST", 8, function()
        refreshLockPlayerList()
    end)
    refreshLockPlayerList()
    Players.PlayerAdded:Connect(function() task.wait(0.5); refreshLockPlayerList() end)
    Players.PlayerRemoving:Connect(function(p)
        if lockedTarget == p then lockedTarget = nil; lockStatusLabel.Text = "LOCKED TARGET: None (left)"; lockStatusLabel.TextColor3 = Colors.Red_Dim end
        task.wait(0.5); refreshLockPlayerList()
    end)

    -- ============================================================================
    -- SECTION 3: ENTITY ALERTS
    -- ============================================================================
    local alertContent = createEntCollapsible(page, "⚠ ENTITY ALERTS", 3, false)

    local alertStatusLabel = Instance.new("TextLabel", alertContent)
    alertStatusLabel.Size = UDim2.new(1, 0, 0, math.floor(20 * SF))
    alertStatusLabel.LayoutOrder = 1
    alertStatusLabel.Text = "Scans workspace for boss/event entities"
    alertStatusLabel.TextColor3 = Colors.Red_Dim; alertStatusLabel.BackgroundTransparency = 1
    alertStatusLabel.Font = Enum.Font.Gotham; alertStatusLabel.TextSize = math.floor(9 * SF)
    alertStatusLabel.TextXAlignment = Enum.TextXAlignment.Left

    local alertLogFrame = Instance.new("ScrollingFrame", alertContent)
    alertLogFrame.Size = UDim2.new(1, 0, 0, math.floor(120 * SF))
    alertLogFrame.LayoutOrder = 2
    alertLogFrame.BackgroundColor3 = Colors.Gunmetal_Dark; alertLogFrame.BackgroundTransparency = 0.1
    alertLogFrame.BorderSizePixel = 0
    alertLogFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    alertLogFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    alertLogFrame.ScrollBarThickness = isMobile and 5 or 3
    alertLogFrame.ScrollBarImageColor3 = Colors.Red_Primary
    Instance.new("UICorner", alertLogFrame).CornerRadius = UDim.new(0, math.floor(6 * SF))
    Instance.new("UIStroke", alertLogFrame).Color = Colors.Red_Dim
    local alLayout = Instance.new("UIListLayout", alertLogFrame)
    alLayout.SortOrder = Enum.SortOrder.LayoutOrder; alLayout.Padding = UDim.new(0, 2)
    local alPad = Instance.new("UIPadding", alertLogFrame)
    alPad.PaddingLeft = UDim.new(0, 6); alPad.PaddingTop = UDim.new(0, 4); alPad.PaddingRight = UDim.new(0, 6)

    local alertLineCount = 0
    local function alertLog(text, color)
        alertLineCount = alertLineCount + 1
        local entry = Instance.new("TextLabel", alertLogFrame)
        entry.Size = UDim2.new(1, 0, 0, 0); entry.AutomaticSize = Enum.AutomaticSize.Y
        entry.LayoutOrder = alertLineCount; entry.Text = text
        entry.TextColor3 = color or Colors.Red_Dim; entry.BackgroundTransparency = 1
        entry.Font = Enum.Font.Code; entry.TextSize = math.floor((isMobile and 9 or 8) * SF)
        entry.TextXAlignment = Enum.TextXAlignment.Left; entry.TextWrapped = true
        task.defer(function() alertLogFrame.CanvasPosition = Vector2.new(0, alertLogFrame.AbsoluteCanvasSize.Y) end)
    end

    alertLog("[SYS] Entity alert system ready", Colors.Red_Dim)

    local knownEntities = {}

    createToggle(alertContent, "Auto-Scan for Entities", 3, false, function(state)
        if state then
            addLog("Entity scanner: ON", false)
            alertLog("[ON] Scanning workspace...", Colors.Red_Primary)

            alertScanConn = RunService.Heartbeat:Connect(function()
                -- Throttle: scan every 2 seconds
                if tick() % 2 > 0.1 then return end

                for _, entityName in ipairs(bossEntities) do
                    local found = workspace:FindFirstChild(entityName, true)
                    if found and not knownEntities[entityName] then
                        knownEntities[entityName] = found
                        alertLog("[!] ENTITY DETECTED: " .. entityName, Colors.Red_Primary)
                        addLog("⚠ Entity spawned: " .. entityName, true)

                        -- Flash notification
                        task.spawn(function()
                            local flash = Instance.new("Frame", gui)
                            flash.Size = UDim2.new(1, 0, 0, math.floor(40 * SF))
                            flash.Position = UDim2.new(0, 0, 0, 0)
                            flash.BackgroundColor3 = Colors.Red_Deep
                            flash.BackgroundTransparency = 0.3
                            flash.ZIndex = 90
                            Instance.new("UICorner", flash).CornerRadius = UDim.new(0, 0)

                            local flashText = Instance.new("TextLabel", flash)
                            flashText.Size = UDim2.new(1, 0, 1, 0)
                            flashText.Text = "⚠ ENTITY ALERT: " .. entityName .. " DETECTED!"
                            flashText.TextColor3 = Colors.Red_Primary
                            flashText.BackgroundTransparency = 1
                            flashText.Font = Enum.Font.GothamBold
                            flashText.TextSize = math.floor(14 * SF)

                            task.wait(3)
                            TweenService:Create(flash, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
                            TweenService:Create(flashText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
                            task.wait(0.5)
                            flash:Destroy()
                        end)
                    elseif not found and knownEntities[entityName] then
                        knownEntities[entityName] = nil
                        alertLog("[−] Entity despawned: " .. entityName, Colors.Red_Dim)
                    end
                end
            end)
        else
            if alertScanConn then alertScanConn:Disconnect(); alertScanConn = nil end
            knownEntities = {}
            alertLog("[OFF] Scanner stopped", Colors.Red_Dim)
            addLog("Entity scanner: OFF", false)
        end
    end)

    -- Manual scan
    createButton(alertContent, "🔍 MANUAL SCAN NOW", 4, function()
        alertLog("[SCAN] Scanning workspace...", Colors.Red_Primary)
        local foundCount = 0
        for _, entityName in ipairs(bossEntities) do
            local found = workspace:FindFirstChild(entityName, true)
            if found then
                alertLog("  ✓ Found: " .. entityName .. " at " .. tostring(found:GetFullName()), Colors.Red_Dim)
                foundCount = foundCount + 1
            end
        end
        alertLog("[SCAN] Complete: " .. foundCount .. " entities found", Colors.Red_Primary)
    end)

    -- Teleport to entity
    local _, tpEntityBox = createTextInput(alertContent, "Entity name to teleport to...", 5)

    createButton(alertContent, "📍 TELEPORT TO ENTITY", 6, function()
        local name = tpEntityBox.Text:gsub("^%s+", ""):gsub("%s+$", "")
        if name == "" then alertLog("[!] Enter entity name", Colors.Red_Primary); return end
        local found = workspace:FindFirstChild(name, true)
        if found then
            local targetPart = found:IsA("BasePart") and found or found:FindFirstChildWhichIsA("BasePart")
            if targetPart then
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = targetPart.CFrame * CFrame.new(0, 5, 0)
                    alertLog("[TP] Teleported to " .. name, Colors.Red_Primary)
                    addLog("TP to entity: " .. name, false)
                end
            else
                alertLog("[!] Entity has no parts", Colors.Red_Primary)
            end
        else
            alertLog("[!] Entity not found: " .. name, Colors.Red_Primary)
        end
    end)

    -- ============================================================================
    -- SECTION 4: DEATH LOG
    -- ============================================================================
    local deathContent = createEntCollapsible(page, "💀 DEATH / KILL LOG", 4, false)

    local deathLogFrame = Instance.new("ScrollingFrame", deathContent)
    deathLogFrame.Size = UDim2.new(1, 0, 0, math.floor(150 * SF))
    deathLogFrame.LayoutOrder = 1
    deathLogFrame.BackgroundColor3 = Colors.Gunmetal_Dark; deathLogFrame.BackgroundTransparency = 0.1
    deathLogFrame.BorderSizePixel = 0
    deathLogFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    deathLogFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    deathLogFrame.ScrollBarThickness = isMobile and 5 or 3
    deathLogFrame.ScrollBarImageColor3 = Colors.Red_Primary
    Instance.new("UICorner", deathLogFrame).CornerRadius = UDim.new(0, math.floor(6 * SF))
    Instance.new("UIStroke", deathLogFrame).Color = Colors.Red_Dim
    local dlLayout = Instance.new("UIListLayout", deathLogFrame)
    dlLayout.SortOrder = Enum.SortOrder.LayoutOrder; dlLayout.Padding = UDim.new(0, 1)
    local dlPad = Instance.new("UIPadding", deathLogFrame)
    dlPad.PaddingLeft = UDim.new(0, 6); dlPad.PaddingTop = UDim.new(0, 4); dlPad.PaddingRight = UDim.new(0, 6)

    local deathLineCount = 0
    local function deathLogEntry(text, color)
        deathLineCount = deathLineCount + 1
        local entry = Instance.new("TextLabel", deathLogFrame)
        entry.Size = UDim2.new(1, 0, 0, 0); entry.AutomaticSize = Enum.AutomaticSize.Y
        entry.LayoutOrder = deathLineCount; entry.Text = text
        entry.TextColor3 = color or Colors.Red_Dim; entry.BackgroundTransparency = 1
        entry.Font = Enum.Font.Code; entry.TextSize = math.floor((isMobile and 9 or 8) * SF)
        entry.TextXAlignment = Enum.TextXAlignment.Left; entry.TextWrapped = true
        task.defer(function() deathLogFrame.CanvasPosition = Vector2.new(0, deathLogFrame.AbsoluteCanvasSize.Y) end)
    end

    deathLogEntry("[SYS] Death log monitoring active", Colors.Red_Dim)

    -- Monitor all player deaths
    local function monitorPlayerDeaths(p)
        if p == player then return end
        p.CharacterAdded:Connect(function(char)
            local hum = char:WaitForChild("Humanoid", 10)
            if hum then
                hum.Died:Connect(function()
                    local killer = "Unknown"
                    -- Try to detect who killed them by checking ObjectValue tags
                    local tag = hum:FindFirstChild("creator") or hum:FindFirstChild("Creator")
                    if tag and tag:IsA("ObjectValue") and tag.Value then
                        killer = tag.Value.Name
                    end

                    local glove = "?"
                    for _, tool in ipairs(char:GetChildren()) do
                        if tool:IsA("Tool") then glove = tool.Name; break end
                    end

                    local timestamp = os.date("%H:%M:%S")
                    local logText = "[" .. timestamp .. "] 💀 " .. p.Name .. " died"
                    if killer ~= "Unknown" then
                        logText = "[" .. timestamp .. "] ⚔ " .. killer .. " → " .. p.Name
                        if glove ~= "?" then logText = logText .. " (" .. glove .. ")" end
                    end

                    deathLogEntry(logText, killer == player.Name and Colors.Red_Primary or Colors.Red_Dim)
                    addLog("Death: " .. p.Name .. (killer ~= "Unknown" and (" by " .. killer) or ""), false)
                end)
            end
        end)
    end

    -- Monitor self
    player.CharacterAdded:Connect(function(char)
        local hum = char:WaitForChild("Humanoid", 10)
        if hum then
            hum.Died:Connect(function()
                deathLogEntry("[" .. os.date("%H:%M:%S") .. "] 💀 YOU DIED", Colors.Red_Primary)
            end)
        end
    end)

    for _, p in ipairs(Players:GetPlayers()) do monitorPlayerDeaths(p) end
    Players.PlayerAdded:Connect(function(p) monitorPlayerDeaths(p) end)

    createButton(deathContent, "🗑 CLEAR DEATH LOG", 2, function()
        for _, child in ipairs(deathLogFrame:GetChildren()) do
            if child:IsA("TextLabel") then child:Destroy() end
        end
        deathLineCount = 0
        deathLogEntry("[SYS] Log cleared", Colors.Red_Dim)
    end)

    -- ============================================================================
    -- SECTION 5: QUICK ACTIONS
    -- ============================================================================
    local quickContent = createEntCollapsible(page, "⚡ QUICK ACTIONS", 5, false)

    createButton(quickContent, "📍 TP TO NEAREST PLAYER", 1, function()
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local myPos = char.HumanoidRootPart.Position
        local closest, closestDist = nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local d = (p.Character.HumanoidRootPart.Position - myPos).Magnitude
                if d < closestDist then closest = p; closestDist = d end
            end
        end
        if closest then
            char.HumanoidRootPart.CFrame = closest.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
            addLog("TP to " .. closest.Name .. " (" .. math.floor(closestDist) .. "s)", false)
        end
    end)

    createButton(quickContent, "📍 TP TO SPAWN", 2, function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local spawn = workspace:FindFirstChild("SpawnLocation") or workspace:FindFirstChildWhichIsA("SpawnLocation", true)
            if spawn then
                char.HumanoidRootPart.CFrame = spawn.CFrame * CFrame.new(0, 5, 0)
            else
                char.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
            end
            addLog("TP to spawn", false)
        end
    end)

    createButton(quickContent, "👥 LIST ALL PLAYERS + GLOVES", 3, function()
        addLog("=== PLAYER LIST ===", true)
        for _, p in ipairs(Players:GetPlayers()) do
            local glove = "None"
            if p.Character then
                for _, t in ipairs(p.Character:GetChildren()) do
                    if t:IsA("Tool") then glove = t.Name; break end
                end
            end
            if glove == "None" then
                local bp = p:FindFirstChild("Backpack")
                if bp then
                    for _, t in ipairs(bp:GetChildren()) do
                        if t:IsA("Tool") then glove = t.Name; break end
                    end
                end
            end
            addLog("  " .. p.Name .. " — " .. glove, false)
        end
        addLog("==================", true)
    end)

    createButton(quickContent, "🔄 REFRESH ALL SYSTEMS", 4, function()
        refreshLockPlayerList()
        if espEnabled then
            clearAllESP()
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player and p.Character then createESPHighlight(p) end
            end
        end
        addLog("All entity systems refreshed", false)
    end)
end

-- ============================================================================
-- TAB: MEDIA (Music/Video Player with Custom Files)
-- ============================================================================
do
    local page = tabPages["Media"]

    -- ============================================================================
    -- STATE
    -- ============================================================================
    local mediaFolder = "TerminalMedia"
    local currentlyPlaying = nil
    local currentSound = nil
    local discSpinning = false
    local discRotation = 0

    -- Ensure media folder exists
    pcall(function()
        if makefolder and not isfolder(mediaFolder) then
            makefolder(mediaFolder)
        end
    end)

    -- ============================================================================
    -- HELPER: Collapsible section
    -- ============================================================================
    local function createMediaCollapsible(parent, titleText, layoutOrder, defaultOpen)
        local container = Instance.new("Frame", parent)
        container.Size = UDim2.new(1, 0, 0, 0)
        container.LayoutOrder = layoutOrder
        container.BackgroundTransparency = 1
        container.AutomaticSize = Enum.AutomaticSize.Y
        container.ClipsDescendants = true
        local secLayout = Instance.new("UIListLayout", container)
        secLayout.SortOrder = Enum.SortOrder.LayoutOrder
        secLayout.Padding = UDim.new(0, math.floor(4 * SF))
        local headerBtn = Instance.new("TextButton", container)
        headerBtn.Size = UDim2.new(1, 0, 0, math.floor((isMobile and 36 or 30) * SF))
        headerBtn.LayoutOrder = 0
        headerBtn.Text = (defaultOpen and "▼ " or "▶ ") .. titleText
        headerBtn.TextColor3 = Colors.Red_Primary
        headerBtn.BackgroundColor3 = Colors.Gunmetal_Mid
        headerBtn.BackgroundTransparency = 0.2
        headerBtn.Font = Enum.Font.GothamBold
        headerBtn.TextSize = math.floor((isMobile and 12 or 11) * SF)
        headerBtn.TextXAlignment = Enum.TextXAlignment.Left
        headerBtn.BorderSizePixel = 0
        Instance.new("UICorner", headerBtn).CornerRadius = UDim.new(0, math.floor(6 * SF))
        local hStroke = Instance.new("UIStroke", headerBtn)
        hStroke.Color = Colors.Red_Dim; hStroke.Thickness = 1
        Instance.new("UIPadding", headerBtn).PaddingLeft = UDim.new(0, math.floor(10 * SF))
        local content = Instance.new("Frame", container)
        content.Name = "Content"; content.Size = UDim2.new(1, 0, 0, 0)
        content.LayoutOrder = 1; content.BackgroundTransparency = 1
        content.AutomaticSize = Enum.AutomaticSize.Y
        content.Visible = defaultOpen or false
        local contentLayout = Instance.new("UIListLayout", content)
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Padding = UDim.new(0, math.floor(4 * SF))
        local isOpen = defaultOpen or false
        headerBtn.MouseButton1Click:Connect(function()
            isOpen = not isOpen; content.Visible = isOpen
            headerBtn.Text = (isOpen and "▼ " or "▶ ") .. titleText
        end)
        headerBtn.MouseEnter:Connect(function() TweenService:Create(headerBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.05}):Play() end)
        headerBtn.MouseLeave:Connect(function() TweenService:Create(headerBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.2}):Play() end)
        return content
    end

    -- ============================================================================
    -- DISC VISUALIZER (Floating overlay)
    -- ============================================================================
    local discOverlay = Instance.new("Frame", gui)
    discOverlay.Name = "DiscVisualizer"
    discOverlay.Size = UDim2.new(0, math.floor(200 * SF), 0, math.floor(240 * SF))
    discOverlay.Position = UDim2.new(1, -(math.floor(220 * SF)), 1, -(math.floor(260 * SF)))
    discOverlay.BackgroundColor3 = Colors.Gunmetal_Dark
    discOverlay.BackgroundTransparency = 0.15
    discOverlay.BorderSizePixel = 0
    discOverlay.Visible = false
    discOverlay.ZIndex = 20
    Instance.new("UICorner", discOverlay).CornerRadius = UDim.new(0, math.floor(12 * SF))
    local discStroke = Instance.new("UIStroke", discOverlay)
    discStroke.Color = Colors.Red_Primary; discStroke.Thickness = 2; discStroke.Transparency = 0.3

    -- Disc header (draggable)
    local discHeader = Instance.new("TextLabel", discOverlay)
    discHeader.Size = UDim2.new(1, 0, 0, math.floor(20 * SF))
    discHeader.Text = "♫ NOW PLAYING"
    discHeader.TextColor3 = Colors.Red_Primary; discHeader.BackgroundColor3 = Colors.Gunmetal_Mid
    discHeader.BackgroundTransparency = 0.3; discHeader.Font = Enum.Font.GothamBold
    discHeader.TextSize = math.floor(9 * SF); discHeader.BorderSizePixel = 0

    -- Drag disc overlay
    local discDragging = false
    local discDragStart, discStartPos
    discHeader.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            discDragging = true; discDragStart = input.Position; discStartPos = discOverlay.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if discDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - discDragStart
            discOverlay.Position = UDim2.new(discStartPos.X.Scale, discStartPos.X.Offset + delta.X, discStartPos.Y.Scale, discStartPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then discDragging = false end
    end)

    -- Disc circle
    local discSize = math.floor(140 * SF)
    local discFrame = Instance.new("Frame", discOverlay)
    discFrame.Size = UDim2.new(0, discSize, 0, discSize)
    discFrame.Position = UDim2.new(0.5, -discSize/2, 0, math.floor(28 * SF))
    discFrame.BackgroundColor3 = Colors.Gunmetal_Dark
    discFrame.BorderSizePixel = 0
    Instance.new("UICorner", discFrame).CornerRadius = UDim.new(1, 0)
    local discBorderStroke = Instance.new("UIStroke", discFrame)
    discBorderStroke.Color = Colors.Red_Primary; discBorderStroke.Thickness = 3

    -- Inner disc ring 1
    local innerRing1 = Instance.new("Frame", discFrame)
    local ir1Size = math.floor(100 * SF)
    innerRing1.Size = UDim2.new(0, ir1Size, 0, ir1Size)
    innerRing1.Position = UDim2.new(0.5, -ir1Size/2, 0.5, -ir1Size/2)
    innerRing1.BackgroundColor3 = Colors.Gunmetal_Mid
    innerRing1.BorderSizePixel = 0
    Instance.new("UICorner", innerRing1).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", innerRing1).Color = Colors.Red_Dim

    -- Inner disc ring 2
    local innerRing2 = Instance.new("Frame", discFrame)
    local ir2Size = math.floor(60 * SF)
    innerRing2.Size = UDim2.new(0, ir2Size, 0, ir2Size)
    innerRing2.Position = UDim2.new(0.5, -ir2Size/2, 0.5, -ir2Size/2)
    innerRing2.BackgroundColor3 = Colors.Red_Deep
    innerRing2.BorderSizePixel = 0
    Instance.new("UICorner", innerRing2).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", innerRing2).Color = Colors.Red_Primary

    -- Center hole
    local centerHole = Instance.new("Frame", discFrame)
    local chSize = math.floor(16 * SF)
    centerHole.Size = UDim2.new(0, chSize, 0, chSize)
    centerHole.Position = UDim2.new(0.5, -chSize/2, 0.5, -chSize/2)
    centerHole.BackgroundColor3 = Colors.Gunmetal_Dark
    centerHole.BorderSizePixel = 0
    Instance.new("UICorner", centerHole).CornerRadius = UDim.new(1, 0)

    -- Disc label (center)
    local discLabel = Instance.new("TextLabel", innerRing2)
    discLabel.Size = UDim2.new(0.9, 0, 0.4, 0)
    discLabel.Position = UDim2.new(0.05, 0, 0.15, 0)
    discLabel.Text = "♫"
    discLabel.TextColor3 = Colors.Red_Primary; discLabel.BackgroundTransparency = 1
    discLabel.Font = Enum.Font.GothamBold; discLabel.TextSize = math.floor(14 * SF)
    discLabel.TextScaled = true

    -- Song name label
    local songNameLabel = Instance.new("TextLabel", discOverlay)
    songNameLabel.Size = UDim2.new(1, -math.floor(12 * SF), 0, math.floor(16 * SF))
    songNameLabel.Position = UDim2.new(0, math.floor(6 * SF), 1, -(math.floor(38 * SF)))
    songNameLabel.Text = "No track loaded"
    songNameLabel.TextColor3 = Colors.Red_Dim; songNameLabel.BackgroundTransparency = 1
    songNameLabel.Font = Enum.Font.GothamBold; songNameLabel.TextSize = math.floor(9 * SF)
    songNameLabel.TextWrapped = true; songNameLabel.TextTruncate = Enum.TextTruncate.AtEnd

    -- Progress label
    local progressLabel = Instance.new("TextLabel", discOverlay)
    progressLabel.Size = UDim2.new(1, -math.floor(12 * SF), 0, math.floor(14 * SF))
    progressLabel.Position = UDim2.new(0, math.floor(6 * SF), 1, -(math.floor(20 * SF)))
    progressLabel.Text = "0:00 / 0:00"
    progressLabel.TextColor3 = Colors.Gunmetal_Accent; progressLabel.BackgroundTransparency = 1
    progressLabel.Font = Enum.Font.Code; progressLabel.TextSize = math.floor(8 * SF)

    -- Spinning animation
    local discSpinConn = nil
    local function startDiscSpin()
        if discSpinConn then return end
        discSpinning = true
        discSpinConn = RunService.Heartbeat:Connect(function(dt)
            if not discSpinning then return end
            discRotation = discRotation + dt * 60 -- degrees per second
            if discRotation > 360 then discRotation = discRotation - 360 end
            discFrame.Rotation = discRotation

            -- Pulse the border
            discBorderStroke.Color = Color3.fromRGB(
                255,
                math.floor(20 + math.sin(tick() * 2) * 20),
                math.floor(30 + math.sin(tick() * 2) * 15)
            )

            -- Update progress
            if currentSound and currentSound.Parent then
                local pos = currentSound.TimePosition
                local dur = currentSound.TimeLength
                local posMin = math.floor(pos / 60)
                local posSec = math.floor(pos % 60)
                local durMin = math.floor(dur / 60)
                local durSec = math.floor(dur % 60)
                progressLabel.Text = string.format("%d:%02d / %d:%02d", posMin, posSec, durMin, durSec)
            end
        end)
    end

    local function stopDiscSpin()
        discSpinning = false
        if discSpinConn then discSpinConn:Disconnect(); discSpinConn = nil end
    end

    -- ============================================================================
    -- VIDEO OVERLAY (Full screen)
    -- ============================================================================
    local videoOverlay = Instance.new("Frame", gui)
    videoOverlay.Name = "VideoPlayer"
    videoOverlay.Size = UDim2.new(0, math.floor(400 * SF), 0, math.floor(260 * SF))
    videoOverlay.Position = UDim2.new(0.5, -math.floor(200 * SF), 0.5, -math.floor(130 * SF))
    videoOverlay.BackgroundColor3 = Colors.Gunmetal_Dark
    videoOverlay.BackgroundTransparency = 0.05
    videoOverlay.BorderSizePixel = 0
    videoOverlay.Visible = false
    videoOverlay.ZIndex = 25
    Instance.new("UICorner", videoOverlay).CornerRadius = UDim.new(0, math.floor(12 * SF))
    local videoStroke = Instance.new("UIStroke", videoOverlay)
    videoStroke.Color = Colors.Red_Primary; videoStroke.Thickness = 2

    -- Video header
    local videoHeader = Instance.new("Frame", videoOverlay)
    videoHeader.Size = UDim2.new(1, 0, 0, math.floor(24 * SF))
    videoHeader.BackgroundColor3 = Colors.Gunmetal_Mid; videoHeader.BackgroundTransparency = 0.2
    videoHeader.BorderSizePixel = 0

    local videoTitle = Instance.new("TextLabel", videoHeader)
    videoTitle.Size = UDim2.new(0.8, 0, 1, 0); videoTitle.Position = UDim2.new(0, math.floor(8 * SF), 0, 0)
    videoTitle.Text = "▶ VIDEO PLAYER"; videoTitle.TextColor3 = Colors.Red_Primary
    videoTitle.BackgroundTransparency = 1; videoTitle.Font = Enum.Font.GothamBold
    videoTitle.TextSize = math.floor(10 * SF); videoTitle.TextXAlignment = Enum.TextXAlignment.Left

    local videoCloseBtn = Instance.new("TextButton", videoHeader)
    videoCloseBtn.Size = UDim2.new(0, math.floor(24 * SF), 0, math.floor(24 * SF))
    videoCloseBtn.Position = UDim2.new(1, -(math.floor(28 * SF)), 0, 0)
    videoCloseBtn.Text = "✕"; videoCloseBtn.TextColor3 = Colors.Red_Primary
    videoCloseBtn.BackgroundColor3 = Colors.Gunmetal_Light; videoCloseBtn.BackgroundTransparency = 0.5
    videoCloseBtn.Font = Enum.Font.GothamBold; videoCloseBtn.TextSize = math.floor(12 * SF)
    videoCloseBtn.BorderSizePixel = 0
    Instance.new("UICorner", videoCloseBtn).CornerRadius = UDim.new(0, 4)

    videoCloseBtn.MouseButton1Click:Connect(function()
        videoOverlay.Visible = false
    end)

    -- Video frame area
    local videoFrame = Instance.new("VideoFrame", videoOverlay)
    videoFrame.Size = UDim2.new(1, -math.floor(8 * SF), 1, -(math.floor(32 * SF)))
    videoFrame.Position = UDim2.new(0, math.floor(4 * SF), 0, math.floor(28 * SF))
    videoFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    videoFrame.BorderSizePixel = 0
    videoFrame.Looped = false
    videoFrame.Playing = false
    Instance.new("UICorner", videoFrame).CornerRadius = UDim.new(0, math.floor(8 * SF))

    -- Drag video overlay
    local videoDragging = false
    local videoDragStart, videoStartPos
    videoHeader.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            videoDragging = true; videoDragStart = input.Position; videoStartPos = videoOverlay.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if videoDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - videoDragStart
            videoOverlay.Position = UDim2.new(videoStartPos.X.Scale, videoStartPos.X.Offset + delta.X, videoStartPos.Y.Scale, videoStartPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then videoDragging = false end
    end)

    -- ============================================================================
    -- SECTION 1: ROBLOX AUDIO PLAYER
    -- ============================================================================
    local audioContent = createMediaCollapsible(page, "🎵 ROBLOX AUDIO PLAYER", 1, true)

    local nowPlayingFrame = Instance.new("Frame", audioContent)
    nowPlayingFrame.Size = UDim2.new(1, 0, 0, math.floor(50 * SF))
    nowPlayingFrame.LayoutOrder = 1
    nowPlayingFrame.BackgroundColor3 = Colors.Gunmetal_Mid; nowPlayingFrame.BackgroundTransparency = 0.2
    nowPlayingFrame.BorderSizePixel = 0
    Instance.new("UICorner", nowPlayingFrame).CornerRadius = UDim.new(0, math.floor(8 * SF))

    local npDot = Instance.new("Frame", nowPlayingFrame)
    npDot.Size = UDim2.new(0, math.floor(8 * SF), 0, math.floor(8 * SF))
    npDot.Position = UDim2.new(0, math.floor(8 * SF), 0, math.floor(8 * SF))
    npDot.BackgroundColor3 = Colors.Red_Dim; npDot.BorderSizePixel = 0
    Instance.new("UICorner", npDot).CornerRadius = UDim.new(1, 0)

    local npLabel = Instance.new("TextLabel", nowPlayingFrame)
    npLabel.Size = UDim2.new(1, -math.floor(24 * SF), 0, math.floor(14 * SF))
    npLabel.Position = UDim2.new(0, math.floor(22 * SF), 0, math.floor(4 * SF))
    npLabel.Text = "NOW PLAYING: Nothing"
    npLabel.TextColor3 = Colors.Red_Dim; npLabel.BackgroundTransparency = 1
    npLabel.Font = Enum.Font.GothamBold; npLabel.TextSize = math.floor(10 * SF)
    npLabel.TextXAlignment = Enum.TextXAlignment.Left

    local npInfoLabel = Instance.new("TextLabel", nowPlayingFrame)
    npInfoLabel.Size = UDim2.new(1, -math.floor(12 * SF), 0, math.floor(12 * SF))
    npInfoLabel.Position = UDim2.new(0, math.floor(8 * SF), 0, math.floor(24 * SF))
    npInfoLabel.Text = "Enter audio ID or browse local files"
    npInfoLabel.TextColor3 = Colors.Gunmetal_Accent; npInfoLabel.BackgroundTransparency = 1
    npInfoLabel.Font = Enum.Font.Code; npInfoLabel.TextSize = math.floor(7 * SF)
    npInfoLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Volume slider
    local volumeFrame = Instance.new("Frame", nowPlayingFrame)
    volumeFrame.Size = UDim2.new(0.4, 0, 0, math.floor(10 * SF))
    volumeFrame.Position = UDim2.new(0.55, 0, 0, math.floor(38 * SF))
    volumeFrame.BackgroundColor3 = Colors.Gunmetal_Light; volumeFrame.BackgroundTransparency = 0.3
    volumeFrame.BorderSizePixel = 0
    Instance.new("UICorner", volumeFrame).CornerRadius = UDim.new(1, 0)

    local volumeFill = Instance.new("Frame", volumeFrame)
    volumeFill.Size = UDim2.new(0.7, 0, 1, 0)
    volumeFill.BackgroundColor3 = Colors.Red_Primary; volumeFill.BorderSizePixel = 0
    Instance.new("UICorner", volumeFill).CornerRadius = UDim.new(1, 0)

    local volumeLabel = Instance.new("TextLabel", nowPlayingFrame)
    volumeLabel.Size = UDim2.new(0, math.floor(50 * SF), 0, math.floor(10 * SF))
    volumeLabel.Position = UDim2.new(0.55, -(math.floor(55 * SF)), 0, math.floor(38 * SF))
    volumeLabel.Text = "VOL: 70%"
    volumeLabel.TextColor3 = Colors.Red_Dim; volumeLabel.BackgroundTransparency = 1
    volumeLabel.Font = Enum.Font.Code; volumeLabel.TextSize = math.floor(7 * SF)
    volumeLabel.TextXAlignment = Enum.TextXAlignment.Right

    local currentVolume = 0.7

    -- Audio ID input
    local _, audioIdBox = createTextInput(audioContent, "Enter Roblox Audio ID...", 2)

    -- Play/Stop/Controls
    local controlRow = Instance.new("Frame", audioContent)
    controlRow.Size = UDim2.new(1, 0, 0, math.floor((isMobile and 44 or 36) * SF))
    controlRow.LayoutOrder = 3; controlRow.BackgroundTransparency = 1
    local crLayout = Instance.new("UIListLayout", controlRow)
    crLayout.FillDirection = Enum.FillDirection.Horizontal
    crLayout.SortOrder = Enum.SortOrder.LayoutOrder
    crLayout.Padding = UDim.new(0, math.floor(4 * SF))

    local function createMediaBtn(parent, text, order, callback)
        local btn = Instance.new("TextButton", parent)
        btn.Size = UDim2.new(0.24, 0, 1, 0); btn.LayoutOrder = order
        btn.Text = text; btn.TextColor3 = Colors.Red_Primary
        btn.BackgroundColor3 = Colors.Gunmetal_Dark; btn.BackgroundTransparency = 0.3
        btn.Font = Enum.Font.GothamBold; btn.TextSize = math.floor((isMobile and 11 or 10) * SF)
        btn.BorderSizePixel = 0
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, math.floor(6 * SF))
        Instance.new("UIStroke", btn).Color = Colors.Red_Dim
        if callback then btn.MouseButton1Click:Connect(callback) end
        btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundTransparency = 0.1}):Play() end)
        btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundTransparency = 0.3}):Play() end)
        return btn
    end

    -- Play
    createMediaBtn(controlRow, "▶ PLAY", 1, function()
        local id = audioIdBox.Text:gsub("%s+", "")
        if id == "" then
            npLabel.Text = "⚠ Enter audio ID"; npLabel.TextColor3 = Colors.Red_Primary
            return
        end

        -- Stop current
        if currentSound and currentSound.Parent then currentSound:Destroy() end
        stopDiscSpin()

        -- Create new sound
        local char = player.Character
        local parent = char and char:FindFirstChild("HumanoidRootPart") or workspace
        currentSound = Instance.new("Sound", parent)
        currentSound.Name = "TerminalMedia"
        currentSound.SoundId = "rbxassetid://" .. id
        currentSound.Volume = currentVolume
        currentSound.Looped = false
        currentSound:Play()

        currentlyPlaying = id
        npLabel.Text = "▶ PLAYING: " .. id; npLabel.TextColor3 = Colors.Red_Primary
        npDot.BackgroundColor3 = Colors.Red_Primary
        songNameLabel.Text = "Track: " .. id

        -- Show disc
        discOverlay.Visible = true
        startDiscSpin()

        addLog("Media: Playing " .. id, false)

        -- Handle end
        currentSound.Ended:Connect(function()
            npLabel.Text = "⏹ Finished: " .. id; npLabel.TextColor3 = Colors.Red_Dim
            npDot.BackgroundColor3 = Colors.Red_Dim
            stopDiscSpin()
            progressLabel.Text = "Finished"
        end)
    end)

    -- Pause
    createMediaBtn(controlRow, "⏸", 2, function()
        if currentSound and currentSound.Parent then
            if currentSound.Playing then
                currentSound:Pause()
                npLabel.Text = "⏸ PAUSED"; npLabel.TextColor3 = Colors.Red_Dim
                stopDiscSpin()
            else
                currentSound:Resume()
                npLabel.Text = "▶ PLAYING: " .. (currentlyPlaying or "?")
                npLabel.TextColor3 = Colors.Red_Primary
                startDiscSpin()
            end
        end
    end)

    -- Stop
    createMediaBtn(controlRow, "⏹", 3, function()
        if currentSound and currentSound.Parent then
            currentSound:Destroy(); currentSound = nil
        end
        currentlyPlaying = nil
        npLabel.Text = "⏹ Stopped"; npLabel.TextColor3 = Colors.Red_Dim
        npDot.BackgroundColor3 = Colors.Red_Dim
        stopDiscSpin()
        discOverlay.Visible = false
        songNameLabel.Text = "No track loaded"
        progressLabel.Text = "0:00 / 0:00"
    end)

    -- Loop toggle
    local loopEnabled = false
    createMediaBtn(controlRow, "🔁", 4, function()
        loopEnabled = not loopEnabled
        if currentSound then currentSound.Looped = loopEnabled end
        npInfoLabel.Text = "Loop: " .. (loopEnabled and "ON" or "OFF")
        addLog("Loop: " .. (loopEnabled and "ON" or "OFF"), false)
    end)

    -- Volume controls
    local volRow = Instance.new("Frame", audioContent)
    volRow.Size = UDim2.new(1, 0, 0, math.floor((isMobile and 36 or 28) * SF))
    volRow.LayoutOrder = 4; volRow.BackgroundTransparency = 1
    local vrLayout = Instance.new("UIListLayout", volRow)
    vrLayout.FillDirection = Enum.FillDirection.Horizontal
    vrLayout.SortOrder = Enum.SortOrder.LayoutOrder
    vrLayout.Padding = UDim.new(0, math.floor(4 * SF))

    local function updateVolume(vol)
        currentVolume = math.clamp(vol, 0, 1)
        if currentSound then currentSound.Volume = currentVolume end
        volumeFill.Size = UDim2.new(currentVolume, 0, 1, 0)
        volumeLabel.Text = "VOL: " .. math.floor(currentVolume * 100) .. "%"
    end

    createMediaBtn(volRow, "🔉 −", 1, function() updateVolume(currentVolume - 0.1) end)
    createMediaBtn(volRow, "🔊 +", 2, function() updateVolume(currentVolume + 0.1) end)
    createMediaBtn(volRow, "🔇 MUTE", 3, function() updateVolume(0) end)
    createMediaBtn(volRow, "MAX", 4, function() updateVolume(1) end)

    -- ============================================================================
    -- SECTION 2: LOCAL FILE BROWSER
    -- ============================================================================
    local fileContent = createMediaCollapsible(page, "📁 LOCAL FILES (workspace/" .. mediaFolder .. ")", 2, false)

    local fileStatusLabel = Instance.new("TextLabel", fileContent)
    fileStatusLabel.Size = UDim2.new(1, 0, 0, math.floor(20 * SF))
    fileStatusLabel.LayoutOrder = 1
    fileStatusLabel.Text = "Place .mp3 / .mp4 files in: workspace/" .. mediaFolder
    fileStatusLabel.TextColor3 = Colors.Red_Dim; fileStatusLabel.BackgroundTransparency = 1
    fileStatusLabel.Font = Enum.Font.Code; fileStatusLabel.TextSize = math.floor(8 * SF)
    fileStatusLabel.TextXAlignment = Enum.TextXAlignment.Left; fileStatusLabel.TextWrapped = true

    local fileListContainer = Instance.new("Frame", fileContent)
    fileListContainer.Size = UDim2.new(1, 0, 0, 0)
    fileListContainer.LayoutOrder = 2
    fileListContainer.BackgroundTransparency = 1
    fileListContainer.AutomaticSize = Enum.AutomaticSize.Y
    local flLayout = Instance.new("UIListLayout", fileListContainer)
    flLayout.SortOrder = Enum.SortOrder.LayoutOrder
    flLayout.Padding = UDim.new(0, math.floor(3 * SF))

    local function getFileExtension(filename)
        return filename:match("^.+(%..+)$") or ""
    end

    local function refreshFileList()
        for _, child in ipairs(fileListContainer:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end

        local files = {}
        pcall(function()
            if listfiles then
                files = listfiles(mediaFolder)
            end
        end)

        if #files == 0 then
            local noFiles = Instance.new("TextLabel", fileListContainer)
            noFiles.Size = UDim2.new(1, 0, 0, math.floor(30 * SF))
            noFiles.LayoutOrder = 1
            noFiles.Text = "No files found. Place .mp3/.mp4 in workspace/" .. mediaFolder
            noFiles.TextColor3 = Colors.Gunmetal_Accent; noFiles.BackgroundTransparency = 1
            noFiles.Font = Enum.Font.Gotham; noFiles.TextSize = math.floor(9 * SF)
            noFiles.TextWrapped = true
            -- Wrap in frame for cleanup
            local wrapper = Instance.new("Frame", fileListContainer)
            wrapper.Size = UDim2.new(1, 0, 0, math.floor(30 * SF))
            wrapper.LayoutOrder = 1; wrapper.BackgroundTransparency = 1
            noFiles.Parent = wrapper
            return
        end

        for i, filePath in ipairs(files) do
            local fileName = filePath:match("[^/\\]+$") or filePath
            local ext = getFileExtension(fileName):lower()
            local isAudio = ext == ".mp3" or ext == ".wav" or ext == ".ogg"
            local isVideo = ext == ".mp4" or ext == ".webm"

            if isAudio or isVideo then
                local fileFrame = Instance.new("Frame", fileListContainer)
                fileFrame.Size = UDim2.new(1, 0, 0, math.floor((isMobile and 44 or 36) * SF))
                fileFrame.LayoutOrder = i
                fileFrame.BackgroundColor3 = Colors.Gunmetal_Mid; fileFrame.BackgroundTransparency = 0.3
                fileFrame.BorderSizePixel = 0
                Instance.new("UICorner", fileFrame).CornerRadius = UDim.new(0, math.floor(6 * SF))
                Instance.new("UIStroke", fileFrame).Color = Colors.Gunmetal_Light

                local icon = isAudio and "🎵" or "🎬"
                local fileLabel = Instance.new("TextLabel", fileFrame)
                fileLabel.Size = UDim2.new(0.65, 0, 1, 0)
                fileLabel.Position = UDim2.new(0, math.floor(8 * SF), 0, 0)
                fileLabel.Text = icon .. " " .. fileName
                fileLabel.TextColor3 = Colors.Red_Dim; fileLabel.BackgroundTransparency = 1
                fileLabel.Font = Enum.Font.Gotham; fileLabel.TextSize = math.floor((isMobile and 10 or 9) * SF)
                fileLabel.TextXAlignment = Enum.TextXAlignment.Left
                fileLabel.TextWrapped = true; fileLabel.TextTruncate = Enum.TextTruncate.AtEnd

                local playBtn = Instance.new("TextButton", fileFrame)
                local pbH = math.floor((isMobile and 32 or 26) * SF)
                playBtn.Size = UDim2.new(0, math.floor(50 * SF), 0, pbH)
                playBtn.Position = UDim2.new(1, -(math.floor(58 * SF)), 0.5, -pbH/2)
                playBtn.Text = "▶"
                playBtn.TextColor3 = Colors.Red_Primary
                playBtn.BackgroundColor3 = Colors.Gunmetal_Dark; playBtn.BackgroundTransparency = 0.3
                playBtn.Font = Enum.Font.GothamBold; playBtn.TextSize = math.floor(12 * SF)
                playBtn.BorderSizePixel = 0
                Instance.new("UICorner", playBtn).CornerRadius = UDim.new(0, 4)

                playBtn.MouseButton1Click:Connect(function()
                    if isAudio then
                        -- For audio: try to read file and create sound
                        addLog("Media: Loading " .. fileName, false)
                        npLabel.Text = "▶ PLAYING: " .. fileName; npLabel.TextColor3 = Colors.Red_Primary
                        npDot.BackgroundColor3 = Colors.Red_Primary
                        songNameLabel.Text = fileName

                        -- Note: Roblox doesn't natively support local MP3 playback
                        -- This would require the executor to support getsynasset or equivalent
                        pcall(function()
                            if currentSound and currentSound.Parent then currentSound:Destroy() end
                            stopDiscSpin()

                            local asset = nil
                            if getsynasset then
                                asset = getsynasset(filePath)
                            elseif getcustomasset then
                                asset = getcustomasset(filePath)
                            end

                            if asset then
                                local char = player.Character
                                local parent = char and char:FindFirstChild("HumanoidRootPart") or workspace
                                currentSound = Instance.new("Sound", parent)
                                currentSound.Name = "TerminalMedia"
                                currentSound.SoundId = asset
                                currentSound.Volume = currentVolume
                                currentSound.Looped = loopEnabled
                                currentSound:Play()

                                discOverlay.Visible = true
                                startDiscSpin()

                                currentSound.Ended:Connect(function()
                                    npLabel.Text = "⏹ Finished: " .. fileName
                                    npLabel.TextColor3 = Colors.Red_Dim
                                    stopDiscSpin()
                                end)
                            else
                                npLabel.Text = "⚠ No asset loader (getsynasset/getcustomasset)"
                                npLabel.TextColor3 = Colors.Red_Primary
                                addLog("Media: Asset loader not available", true)
                            end
                        end)
                    elseif isVideo then
                        -- For video: use VideoFrame
                        addLog("Media: Loading video " .. fileName, false)

                        pcall(function()
                            local asset = nil
                            if getsynasset then
                                asset = getsynasset(filePath)
                            elseif getcustomasset then
                                asset = getcustomasset(filePath)
                            end

                            if asset then
                                videoFrame.Video = asset
                                videoFrame.Playing = true
                                videoFrame.Looped = false
                                videoOverlay.Visible = true
                                videoTitle.Text = "▶ " .. fileName

                                -- Hide disc for video
                                discOverlay.Visible = false
                                stopDiscSpin()
                            else
                                addLog("Media: Asset loader not available for video", true)
                            end
                        end)
                    end
                end)
            end
        end

        fileStatusLabel.Text = #files .. " files found in workspace/" .. mediaFolder
    end

    createButton(fileContent, "🔄 REFRESH FILE LIST", 3, function()
        refreshFileList()
        addLog("Media: File list refreshed", false)
    end)

    -- Initial load
    refreshFileList()

    -- ============================================================================
    -- SECTION 3: AUDIO PRESETS (Popular Roblox Audio IDs)
    -- ============================================================================
    local presetsContent = createMediaCollapsible(page, "🎶 AUDIO PRESETS", 3, false)

    local presets = {
        {name = "Megalovania", id = "2858004684"},
        {name = "Never Gonna Give You Up", id = "5765298081"},
        {name = "Phonk Drift", id = "9125251382"},
        {name = "Attack on Titan", id = "5937000291"},
        {name = "Jojo Golden Wind", id = "3460064547"},
        {name = "Doom E1M1", id = "5765298605"},
        {name = "Moonlight Sonata", id = "519489677"},
        {name = "Crab Rave", id = "2631050065"},
        {name = "Spooky Scary Skeletons", id = "160442087"},
        {name = "Thomas the Tank Engine", id = "6556703819"},
        {name = "Curb Your Enthusiasm", id = "2304526874"},
        {name = "All Star - Smash Mouth", id = "2516262689"},
    }

    for i, preset in ipairs(presets) do
        local presetFrame = Instance.new("Frame", presetsContent)
        presetFrame.Size = UDim2.new(1, 0, 0, math.floor((isMobile and 38 or 30) * SF))
        presetFrame.LayoutOrder = i
        presetFrame.BackgroundColor3 = Colors.Gunmetal_Dark; presetFrame.BackgroundTransparency = 0.4
        presetFrame.BorderSizePixel = 0
        Instance.new("UICorner", presetFrame).CornerRadius = UDim.new(0, math.floor(5 * SF))

        local presetLabel = Instance.new("TextLabel", presetFrame)
        presetLabel.Size = UDim2.new(0.65, 0, 1, 0)
        presetLabel.Position = UDim2.new(0, math.floor(8 * SF), 0, 0)
        presetLabel.Text = "🎵 " .. preset.name
        presetLabel.TextColor3 = Colors.Red_Dim; presetLabel.BackgroundTransparency = 1
        presetLabel.Font = Enum.Font.Gotham; presetLabel.TextSize = math.floor((isMobile and 10 or 9) * SF)
        presetLabel.TextXAlignment = Enum.TextXAlignment.Left

        local presetPlayBtn = Instance.new("TextButton", presetFrame)
        presetPlayBtn.Size = UDim2.new(0, math.floor(44 * SF), 0, math.floor((isMobile and 28 or 22) * SF))
        presetPlayBtn.Position = UDim2.new(1, -(math.floor(52 * SF)), 0.5, -math.floor((isMobile and 14 or 11) * SF))
        presetPlayBtn.Text = "▶"; presetPlayBtn.TextColor3 = Colors.Red_Primary
        presetPlayBtn.BackgroundColor3 = Colors.Gunmetal_Dark; presetPlayBtn.BackgroundTransparency = 0.3
        presetPlayBtn.Font = Enum.Font.GothamBold; presetPlayBtn.TextSize = math.floor(11 * SF)
        presetPlayBtn.BorderSizePixel = 0
        Instance.new("UICorner", presetPlayBtn).CornerRadius = UDim.new(0, 4)

        presetPlayBtn.MouseButton1Click:Connect(function()
            audioIdBox.Text = preset.id

            -- Auto-play
            if currentSound and currentSound.Parent then currentSound:Destroy() end
            stopDiscSpin()

            local char = player.Character
            local parent = char and char:FindFirstChild("HumanoidRootPart") or workspace
            currentSound = Instance.new("Sound", parent)
            currentSound.Name = "TerminalMedia"
            currentSound.SoundId = "rbxassetid://" .. preset.id
            currentSound.Volume = currentVolume
            currentSound.Looped = loopEnabled
            currentSound:Play()

            currentlyPlaying = preset.id
            npLabel.Text = "▶ " .. preset.name; npLabel.TextColor3 = Colors.Red_Primary
            npDot.BackgroundColor3 = Colors.Red_Primary
            songNameLabel.Text = preset.name

            discOverlay.Visible = true
            startDiscSpin()
            addLog("Media: Playing preset — " .. preset.name, false)

            currentSound.Ended:Connect(function()
                npLabel.Text = "⏹ " .. preset.name; npLabel.TextColor3 = Colors.Red_Dim
                stopDiscSpin()
            end)
        end)

        presetFrame.MouseEnter:Connect(function()
            TweenService:Create(presetFrame, TweenInfo.new(0.1), {BackgroundTransparency = 0.2}):Play()
            presetLabel.TextColor3 = Colors.Red_Primary
        end)
        presetFrame.MouseLeave:Connect(function()
            TweenService:Create(presetFrame, TweenInfo.new(0.1), {BackgroundTransparency = 0.4}):Play()
            presetLabel.TextColor3 = Colors.Red_Dim
        end)
    end

    -- ============================================================================
    -- SECTION 4: RADIO REMOTE (Fire to server)
    -- ============================================================================
    local radioRemoteContent = createMediaCollapsible(page, "📡 SERVER RADIO (Remote)", 4, false)

    local _, serverRadioBox = createTextInput(radioRemoteContent, "Audio ID to broadcast...", 1)

    createButton(radioRemoteContent, "📡 BROADCAST TO SERVER", 2, function()
        local id = serverRadioBox.Text:gsub("%s+", "")
        if id == "" then return end
        pcall(function()
            if radioRemote then radioRemote:FireServer(tonumber(id) or id) end
        end)
        addLog("Radio broadcast: " .. id, false)
    end)

    createButton(radioRemoteContent, "📡 STOP SERVER RADIO", 3, function()
        pcall(function()
            if radioRemote then radioRemote:FireServer(0) end
        end)
        addLog("Radio broadcast: Stopped", false)
    end)
end

-- ============================================================================
-- TAB: TERMINAL
-- ============================================================================
do
    local page = tabPages["Terminal"]
    createSectionHeader(page, "SECRET TERMINAL", 1)

    local termOutput = Instance.new("ScrollingFrame", page)
    termOutput.Size = UDim2.new(1, 0, 0, math.floor(200 * SF))
    termOutput.LayoutOrder = 2
    termOutput.BackgroundColor3 = Colors.Gunmetal_Dark
    termOutput.BackgroundTransparency = 0.1
    termOutput.BorderSizePixel = 0
    termOutput.CanvasSize = UDim2.new(0, 0, 0, 0)
    termOutput.AutomaticCanvasSize = Enum.AutomaticSize.Y
    termOutput.ScrollBarThickness = isMobile and 6 or 3
    termOutput.ScrollBarImageColor3 = Colors.Red_Primary
    Instance.new("UICorner", termOutput).CornerRadius = UDim.new(0, math.floor(8 * SF))
    Instance.new("UIStroke", termOutput).Color = Colors.Red_Dim
    local tl = Instance.new("UIListLayout", termOutput)
    tl.SortOrder = Enum.SortOrder.LayoutOrder
    tl.Padding = UDim.new(0, 2)
    local tp = Instance.new("UIPadding", termOutput)
    tp.PaddingLeft = UDim.new(0, 6); tp.PaddingTop = UDim.new(0, 4); tp.PaddingRight = UDim.new(0, 6)

    local termLineCount = 0
    local function termLog(text, color)
        termLineCount = termLineCount + 1
        local entry = Instance.new("TextLabel", termOutput)
        entry.Size = UDim2.new(1, 0, 0, 0)
        entry.AutomaticSize = Enum.AutomaticSize.Y
        entry.LayoutOrder = termLineCount
        entry.Text = text
        entry.TextColor3 = color or Colors.Red_Dim
        entry.BackgroundTransparency = 1
        entry.Font = Enum.Font.Code
        entry.TextSize = math.floor((isMobile and 11 or 10) * SF)
        entry.TextXAlignment = Enum.TextXAlignment.Left
        entry.TextWrapped = true
        task.wait()
        termOutput.CanvasPosition = Vector2.new(0, termOutput.CanvasSize.Y.Offset)
    end

    termLog(">_ TERMINAL v5.0 READY", Colors.Red_Primary)
    termLog(">_ Type 'help' for commands", Colors.Red_Dim)

    local inputFrame = Instance.new("Frame", page)
    inputFrame.Size = UDim2.new(1, 0, 0, math.floor((isMobile and 44 or 36) * SF))
    inputFrame.LayoutOrder = 3
    inputFrame.BackgroundColor3 = Colors.Gunmetal_Mid
    inputFrame.BackgroundTransparency = 0.2
    inputFrame.BorderSizePixel = 0
    Instance.new("UICorner", inputFrame).CornerRadius = UDim.new(0, math.floor(8 * SF))
    Instance.new("UIStroke", inputFrame).Color = Colors.Red_Dim

    local cmdPrefix = Instance.new("TextLabel", inputFrame)
    cmdPrefix.Size = UDim2.new(0, math.floor(24 * SF), 1, 0)
    cmdPrefix.Position = UDim2.new(0, math.floor(6 * SF), 0, 0)
    cmdPrefix.Text = ">_"
    cmdPrefix.TextColor3 = Colors.Red_Primary
    cmdPrefix.BackgroundTransparency = 1
    cmdPrefix.Font = Enum.Font.Code
    cmdPrefix.TextSize = math.floor(12 * SF)
    cmdPrefix.TextXAlignment = Enum.TextXAlignment.Left

    local cmdInput = Instance.new("TextBox", inputFrame)
    cmdInput.Size = UDim2.new(1, -math.floor(80 * SF), 1, 0)
    cmdInput.Position = UDim2.new(0, math.floor(30 * SF), 0, 0)
    cmdInput.Text = ""
    cmdInput.PlaceholderText = "Enter command..."
    cmdInput.PlaceholderColor3 = Colors.Gunmetal_Accent
    cmdInput.TextColor3 = Colors.Red_Primary
    cmdInput.BackgroundTransparency = 1
    cmdInput.Font = Enum.Font.Code
    cmdInput.TextSize = math.floor((isMobile and 12 or 11) * SF)
    cmdInput.TextXAlignment = Enum.TextXAlignment.Left
    cmdInput.ClearTextOnFocus = false

    local sendBtn = Instance.new("TextButton", inputFrame)
    sendBtn.Size = UDim2.new(0, math.floor(44 * SF), 0, math.floor((isMobile and 34 or 28) * SF))
    sendBtn.Position = UDim2.new(1, -math.floor(48 * SF), 0.5, -math.floor((isMobile and 17 or 14) * SF))
    sendBtn.Text = "►"
    sendBtn.TextColor3 = Colors.Red_Primary
    sendBtn.BackgroundColor3 = Colors.Gunmetal_Light
    sendBtn.BackgroundTransparency = 0.3
    sendBtn.Font = Enum.Font.GothamBold
    sendBtn.TextSize = math.floor(14 * SF)
    sendBtn.BorderSizePixel = 0
    Instance.new("UICorner", sendBtn).CornerRadius = UDim.new(0, 6)

    local secretCommands = {}
    secretCommands["help"] = function()
        termLog("=== COMMANDS ===", Colors.Red_Primary)
        termLog("  help, status, ghost, morph [name]", Colors.Red_Dim)
        termLog("  unmorph, morphlist, swap, bring", Colors.Red_Dim)
        termLog("  space, speed [n], jump [n]", Colors.Red_Dim)
        termLog("  tp [x y z], noclip, god", Colors.Red_Dim)
        termLog("  reset, clear, matrix, ping, crash", Colors.Red_Dim)
        termLog("  radio [id], radiostop", Colors.Red_Dim)
        termLog("================", Colors.Red_Primary)
    end
    secretCommands["status"] = function()
        termLog("SYSTEM: ONLINE | v5.0", Colors.Red_Primary)
        termLog("PLAYER: " .. player.Name, Colors.Red_Dim)
        termLog("PLATFORM: " .. (isMobile and "MOBILE" or "DESKTOP"), Colors.Red_Dim)
        termLog("CUSTOM ABILITIES: " .. #customAbilities, Colors.Red_Dim)
        termLog("SPACE MODE: " .. (spaceModeActive and "ACTIVE" or "OFF"), Colors.Red_Dim)
        local char = player.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            local hum = char:FindFirstChildOfClass("Humanoid")
            termLog("HP: " .. math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth) .. " | SPD: " .. hum.WalkSpeed .. " | JMP: " .. hum.JumpPower, Colors.Red_Dim)
        end
    end
    secretCommands["ghost"] = function()
        termLog("Ghost toggled", Colors.Red_Primary)
        if invisOnRemote then pcall(function() invisOnRemote:FireServer() end) end
        pcall(function() fireClickDetector(workspace.Lobby.Ghost) end)
    end
    secretCommands["unmorph"] = function()
        termLog("Clearing morph...", Colors.Red_Primary)
        clearMorph()
        termLog("Morph cleared", Colors.Red_Dim)
    end
    secretCommands["morphlist"] = function()
        termLog("=== MORPHS (" .. #MorphNames .. ") ===", Colors.Red_Primary)
        local line = ""
        for i, name in ipairs(MorphNames) do
            line = line .. name
            if i < #MorphNames then line = line .. ", " end
            if #line > 50 then termLog("  " .. line, Colors.Red_Dim); line = "" end
        end
        if #line > 0 then termLog("  " .. line, Colors.Red_Dim) end
    end
    secretCommands["swap"] = function()
        termLog("Firing Swap...", Colors.Red_Primary)
        pcall(function() fireclickdetector(workspace.Lobby.Swapper:FindFirstChildOfClass("ClickDetector")) end)
        task.wait(0.15)
        pcall(function() if slocRemote then slocRemote:FireServer() end end)
        termLog("Swap fired", Colors.Red_Dim)
    end
    secretCommands["bring"] = function()
        termLog("Firing Bring...", Colors.Red_Primary)
        pcall(function() fireclickdetector(workspace.Lobby["Za Hando"]:FindFirstChildOfClass("ClickDetector")) end)
        task.wait(0.15)
        pcall(function() if eraseRemote then eraseRemote:FireServer() end end)
        termLog("Bring fired", Colors.Red_Dim)
    end
    secretCommands["space"] = function()
        termLog("Toggling Space Mode...", Colors.Red_Primary)
        spaceModeActive = not spaceModeActive
        if spaceModeActive then
            pcall(function() fireclickdetector(workspace.Lobby.Space:FindFirstChildOfClass("ClickDetector")) end)
            spaceButtonContainer.Visible = true
            termLog("Space Mode ACTIVE — Panel visible", Colors.Red_Dim)
        else
            spaceButtonContainer.Visible = false
            termLog("Space Mode OFF", Colors.Red_Dim)
        end
    end
    secretCommands["radiostop"] = function()
        pcall(function() if radioRemote then radioRemote:FireServer(0) end end)
        termLog("Radio stopped", Colors.Red_Dim)
    end
    secretCommands["clear"] = function()
        for _, child in ipairs(termOutput:GetChildren()) do
            if child:IsA("TextLabel") then child:Destroy() end
        end
        termLineCount = 0
        termLog(">_ Cleared", Colors.Red_Primary)
    end
    secretCommands["reset"] = function()
        termLog("Resetting...", Colors.Red_Primary)
        local char = player.Character
        if char then local hum = char:FindFirstChildOfClass("Humanoid"); if hum then hum.Health = 0 end end
    end
    secretCommands["ping"] = function()
        local s = tick(); task.wait()
        termLog("PING: " .. math.floor((tick() - s) * 1000) .. "ms", Colors.Red_Primary)
    end
    secretCommands["matrix"] = function()
        for i = 1, 5 do
            local l = ""
            for j = 1, 40 do l = l .. string.char(math.random(33, 126)) end
            termLog(l, Color3.fromRGB(255, math.random(10, 60), math.random(10, 40)))
            task.wait(0.1)
        end
    end
    secretCommands["crash"] = function()
        termLog("!!! CRASH !!!", Colors.Red_Primary)
        local flash = Instance.new("Frame", gui)
        flash.Size = UDim2.new(1, 0, 1, 0)
        flash.BackgroundColor3 = Colors.Red_Primary
        flash.BackgroundTransparency = 0.5
        flash.ZIndex = 100
        TweenService:Create(flash, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
        task.wait(0.1); flash:Destroy()
    end

    local noclipEnabled = false
    local noclipConn = nil
    secretCommands["noclip"] = function()
        noclipEnabled = not noclipEnabled
        termLog("NOCLIP: " .. (noclipEnabled and "ON" or "OFF"), Colors.Red_Primary)
        if noclipEnabled then
            noclipConn = RunService.Stepped:Connect(function()
                local char = player.Character
                if char then for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end
            end)
        else if noclipConn then noclipConn:Disconnect(); noclipConn = nil end end
    end

    local godEnabled = false
    local godConn = nil
    secretCommands["god"] = function()
        godEnabled = not godEnabled
        termLog("GOD: " .. (godEnabled and "ON" or "OFF"), Colors.Red_Primary)
        if godEnabled then
            godConn = RunService.Heartbeat:Connect(function()
                local char = player.Character
                if char then local hum = char:FindFirstChildOfClass("Humanoid"); if hum then hum.Health = hum.MaxHealth end end
            end)
        else if godConn then godConn:Disconnect(); godConn = nil end end
    end

    local function executeCommand(input)
        local cmd = input:lower():gsub("^%s+", ""):gsub("%s+$", "")
        if cmd == "" then return end
        termLog(">_ " .. cmd, Colors.Red_Primary)
        local parts = {}
        for word in cmd:gmatch("%S+") do table.insert(parts, word) end
        local command = parts[1]

        if command == "morph" then
            if not parts[2] then
                termLog("Usage: morph [name]", Colors.Red_Primary)
            else
                local morphNameInput = table.concat(parts, " ", 2)
                local found = nil
                for _, name in ipairs(MorphNames) do
                    if name:lower() == morphNameInput:lower() then found = name; break end
                end
                if not found then
                    for _, name in ipairs(MorphNames) do
                        if name:lower():find(morphNameInput:lower(), 1, true) then found = name; break end
                    end
                end
                if found then
                    termLog("Morphing: " .. found, Colors.Red_Primary)
                    fireMorph(found)
                    termLog("Done: " .. found, Colors.Red_Dim)
                else
                    termLog("Not found: " .. morphNameInput, Colors.Red_Primary)
                end
            end
        elseif command == "radio" and parts[2] then
            local id = parts[2]
            termLog("Playing radio: " .. id, Colors.Red_Primary)
            pcall(function() if radioRemote then radioRemote:FireServer(tonumber(id) or id) end end)
        elseif command == "speed" and parts[2] then
            local spd = tonumber(parts[2])
            if spd then
                local char = player.Character
                if char then local hum = char:FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed = spd end end
                termLog("Speed: " .. spd, Colors.Red_Dim)
            end
        elseif command == "jump" and parts[2] then
            local jp = tonumber(parts[2])
            if jp then
                local char = player.Character
                if char then local hum = char:FindFirstChildOfClass("Humanoid"); if hum then hum.JumpPower = jp end end
                termLog("Jump: " .. jp, Colors.Red_Dim)
            end
        elseif command == "tp" and parts[2] and parts[3] and parts[4] then
            local x, y, z = tonumber(parts[2]), tonumber(parts[3]), tonumber(parts[4])
            if x and y and z then
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = CFrame.new(x, y, z)
                    termLog("TP: " .. x .. "," .. y .. "," .. z, Colors.Red_Dim)
                end
            end
        elseif secretCommands[command] then
            secretCommands[command]()
        else
            termLog("Unknown: " .. command .. " — type 'help'", Colors.Red_Primary)
        end
        cmdInput.Text = ""
    end

    cmdInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then executeCommand(cmdInput.Text) end
    end)
    sendBtn.MouseButton1Click:Connect(function() executeCommand(cmdInput.Text) end)

    if isMobile then
        createSectionHeader(page, "QUICK COMMANDS", 10)
        for i, cmd in ipairs({"help","status","ghost","swap","bring","space","morphlist","unmorph","noclip","god","matrix","ping","clear"}) do
            createButton(page, cmd:upper(), 10 + i, function() executeCommand(cmd) end)
        end
    end
end

-- ============================================================================
-- STATUS BAR
-- ============================================================================
local statusBarH = math.floor(22 * SF)
local statusBar = Instance.new("Frame", terminal)
statusBar.Size = UDim2.new(1, 0, 0, statusBarH)
statusBar.Position = UDim2.new(0, 0, 1, -statusBarH)
statusBar.BackgroundColor3 = Colors.Gunmetal_Mid
statusBar.BackgroundTransparency = 0.2
statusBar.BorderSizePixel = 0

local statusText = Instance.new("TextLabel", statusBar)
statusText.Size = UDim2.new(1, -math.floor(12 * SF), 1, 0)
statusText.Position = UDim2.new(0, math.floor(6 * SF), 0, 0)
statusText.Text = "● READY | " .. (isMobile and "MOBILE" or "DESKTOP") .. " | v5.0 | " .. #MorphNames .. " MORPHS | " .. #customAbilities .. " CUSTOM"
statusText.TextColor3 = Colors.Red_Dim
statusText.BackgroundTransparency = 1
statusText.Font = Enum.Font.Gotham
statusText.TextSize = math.floor(8 * SF)
statusText.TextXAlignment = Enum.TextXAlignment.Left

-- ============================================================================
-- HEADER BUTTON EFFECTS
-- ============================================================================
local function addHoverEffect(btn, hoverColor)
    local original = btn.BackgroundColor3
    btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = original}):Play() end)
end
addHoverEffect(closeBtn, Colors.Red_Deep)
addHoverEffect(minBtn, Colors.Gunmetal_Light)

closeBtn.MouseButton1Click:Connect(function()
    terminal.Visible = false; blurEffect.Size = 0; addLog("Terminal closed", false)
end)
minBtn.MouseButton1Click:Connect(function()
    terminal.Visible = false; blurEffect.Size = 0; addLog("Terminal minimized", false)
end)

-- ============================================================================
-- REOPEN BUTTON
-- ============================================================================
local reopenSize = isMobile and 56 or math.floor(50 * SF)
local reopenBtn = Instance.new("TextButton", gui)
reopenBtn.Size = UDim2.new(0, reopenSize, 0, reopenSize)
reopenBtn.Position = UDim2.new(0, isMobile and 14 or 20, 0.5, -reopenSize/2)
reopenBtn.Text = "⧉"
reopenBtn.TextScaled = true
reopenBtn.Font = Enum.Font.GothamBold
reopenBtn.BackgroundColor3 = Colors.Gunmetal_Mid
reopenBtn.TextColor3 = Colors.Red_Primary
reopenBtn.BorderSizePixel = 0
Instance.new("UICorner", reopenBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", reopenBtn).Color = Colors.Red_Primary

reopenBtn.MouseButton1Click:Connect(function()
    terminal.Visible = true; blurEffect.Size = 12; addLog("Terminal restored", false)
end)

-- ============================================================================
-- DIVIDER PULSE
-- ============================================================================
local dividerLine = Instance.new("Frame", terminal)
dividerLine.Size = UDim2.new(0.9, 0, 0, 1)
dividerLine.Position = UDim2.new(0.05, 0, 0, headerH + tabBarH - 1)
dividerLine.BackgroundColor3 = Colors.Red_Primary
dividerLine.BackgroundTransparency = 0.5
dividerLine.BorderSizePixel = 0

task.spawn(function()
    while true do
        TweenService:Create(dividerLine, TweenInfo.new(1), {BackgroundTransparency = 0.3}):Play()
        task.wait(0.8)
        TweenService:Create(dividerLine, TweenInfo.new(1), {BackgroundTransparency = 0.7}):Play()
        task.wait(1)
    end
end)

-- ============================================================================
-- SYSTEM MESSAGES
-- ============================================================================
task.spawn(function()
    local msgs = {
        "Scanning registers...", "Kernel verified", "Firewall: PENETRATED",
        "Data stream stable", "Override granted", "Integrity: 97.4%",
        "Red protocol active", "Morph engine: STANDBY",
        "Props: " .. #MorphNames .. " loaded", "Custom abilities: " .. #customAbilities,
    }
    while true do
        task.wait(12)
        addLog(msgs[math.random(1, #msgs)], false)
    end
end)

-- ============================================================================
-- INIT
-- ============================================================================
switchTab("Overall")
terminal.Visible = true
blurEffect.Size = 12

addLog("SYSTEM v5.0 BOOT", false)
addLog("PLATFORM: " .. (isMobile and "MOBILE" or "DESKTOP"), false)
addLog("MORPHS: " .. #MorphNames .. " | CUSTOM: " .. #customAbilities, false)
addLog("ABILITIES: Swap, Bring, Space Mode", false)
addLog("ALL MODULES ONLINE", false)

print("Slap Battles Terminal v5.0 — Full Replicate System Loaded")
