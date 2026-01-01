local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local ClientMonsters = Workspace:FindFirstChild("ClientMonsters") or Workspace:WaitForChild("ClientMonsters", 5)

local UI_NAME = "VeryFunSHOPCatchaMonster"
local LOGO_ID = "rbxassetid://82270910588453"

local THEMES = {
    Mint = { bg = Color3.fromHex("#0F1720"), accent = Color3.fromHex("#1F2937"), highlight = Color3.fromHex("#66FFCC") },
    Red = { bg = Color3.fromHex("#0F0A0A"), accent = Color3.fromHex("#241111"), highlight = Color3.fromHex("#FF5C5C") },
    Blue = { bg = Color3.fromHex("#071022"), accent = Color3.fromHex("#0E2438"), highlight = Color3.fromHex("#7FB3FF") },
    Pink = { bg = Color3.fromHex("#120812"), accent = Color3.fromHex("#261429"), highlight = Color3.fromHex("#FF8FD8") },
    Purple = { bg = Color3.fromHex("#0B0612"), accent = Color3.fromHex("#221633"), highlight = Color3.fromHex("#B47DFF") },
    Gold = { bg = Color3.fromHex("#0B0B06"), accent = Color3.fromHex("#2A260F"), highlight = Color3.fromHex("#FFC857") },
}
local currentThemeName = "Mint"
local currentTheme = THEMES[currentThemeName]

local defaultPanelSize = UDim2.new(0.50, 0, 0.70, 0)
local shrinkSize = UDim2.new(0, 0, 0, 0)
local tweenOpen = TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local tweenClose = TweenInfo.new(0.20, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

local existing = PlayerGui:FindFirstChild(UI_NAME)
if existing then existing:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = UI_NAME
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local ToggleButton = Instance.new("ImageButton")
ToggleButton.Name = "VeryFunToggle"
ToggleButton.Size = UDim2.new(0, 44, 0, 44)
ToggleButton.AnchorPoint = Vector2.new(0, 0.5)
ToggleButton.Position = UDim2.new(0, 20, 0.5, 0)
ToggleButton.BackgroundColor3 = currentTheme.bg
ToggleButton.Image = LOGO_ID
ToggleButton.ImageColor3 = currentTheme.highlight
ToggleButton.AutoButtonColor = false
ToggleButton.Parent = ScreenGui
local tbCorner = Instance.new("UICorner", ToggleButton)
tbCorner.CornerRadius = UDim.new(0, 8)
local tbStroke = Instance.new("UIStroke", ToggleButton)
tbStroke.Thickness = 1
tbStroke.Transparency = 0.85
tbStroke.Color = currentTheme.accent

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = defaultPanelSize
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = currentTheme.bg
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
MainFrame.Parent = ScreenGui
local mfCorner = Instance.new("UICorner", MainFrame)
mfCorner.CornerRadius = UDim.new(0, 10)
local mfStroke = Instance.new("UIStroke", MainFrame)
mfStroke.Color = currentTheme.accent
mfStroke.Transparency = 0.95
mfStroke.Thickness = 1

local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 42)
TitleBar.Position = UDim2.new(0,0,0,0)
TitleBar.BackgroundColor3 = currentTheme.accent
TitleBar.BorderSizePixel = 0
local tbTitleCorner = Instance.new("UICorner", TitleBar)
tbTitleCorner.CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", TitleBar)
Title.Size = UDim2.new(1, -140, 1, 0)
Title.Position = UDim2.new(0, 16, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "VeryFun SHOP | CatchaMonster"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamSemibold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextYAlignment = Enum.TextYAlignment.Center

local RightTitleArea = Instance.new("Frame", TitleBar)
RightTitleArea.Size = UDim2.new(0, 120, 1, 0)
RightTitleArea.AnchorPoint = Vector2.new(1,0)
RightTitleArea.Position = UDim2.new(1, -8, 0, 0)
RightTitleArea.BackgroundTransparency = 1

local ThemeContainer = Instance.new("Frame", RightTitleArea)
ThemeContainer.Size = UDim2.new(1, -8, 1, 0)
ThemeContainer.Position = UDim2.new(0, 0, 0, 0)
ThemeContainer.BackgroundTransparency = 1
local themeLayout = Instance.new("UIListLayout", ThemeContainer)
themeLayout.FillDirection = Enum.FillDirection.Horizontal
themeLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
themeLayout.Padding = UDim.new(0, 6)

local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0.30, 0, 1, -42)
Sidebar.Position = UDim2.new(0, 0, 0, 50)
Sidebar.BackgroundTransparency = 1
Sidebar.BorderSizePixel = 0

local ContentArea = Instance.new("Frame", MainFrame)
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(0.70, 0, 1, -42)
ContentArea.Position = UDim2.new(0.30, 0, 0, 42)
ContentArea.BackgroundTransparency = 1

local sideLayout = Instance.new("UIListLayout", Sidebar)
sideLayout.Padding = UDim.new(0, 8)
sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
sideLayout.SortOrder = Enum.SortOrder.LayoutOrder

local Pages = {}
local ActivePage = nil
local Toggles = {}
local Options = {}

local function ensureToggle(name, default)
    if Toggles[name] == nil then Toggles[name] = { Value = default or false } end
    return Toggles[name]
end
local function ensureOption(name, default)
    if Options[name] == nil then Options[name] = { Value = default } end
    return Options[name]
end

local function makeButton(parent, text, sizeY)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -12, 0, sizeY or 32)
    btn.BackgroundColor3 = currentTheme.accent
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Text = text
    btn.Parent = parent
    btn.AutoButtonColor = true
    local uc = Instance.new("UICorner", btn)
    uc.CornerRadius = UDim.new(0,6)
    return btn
end

local function makeLabel(parent, text)
    local lab = Instance.new("TextLabel")
    lab.Size = UDim2.new(1, -12, 0, 20)
    lab.BackgroundTransparency = 1
    lab.Text = text
    lab.TextColor3 = Color3.new(1,1,1)
    lab.Font = Enum.Font.Gotham
    lab.TextSize = 13
    lab.TextXAlignment = Enum.TextXAlignment.Left
    lab.Parent = parent
    return lab
end

local function SelectPage(name)
    local p = Pages[name]
    if not p then return end
    if ActivePage then
        ActivePage.button.BackgroundColor3 = currentTheme.accent
        ActivePage.button.TextColor3 = Color3.new(1,1,1)
        ActivePage.frame.Visible = false
    end
    ActivePage = p
    p.button.BackgroundColor3 = currentTheme.highlight
    p.button.TextColor3 = currentTheme.bg
    p.frame.Visible = true
end

local function CreateCategory(name)
    local btn = makeButton(Sidebar, "  " .. name, 36)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.LayoutOrder = #Pages + 1

    local page = Instance.new("ScrollingFrame", ContentArea)
    page.Name = name
    page.Size = UDim2.new(1, -16, 1, -16)
    page.Position = UDim2.new(0, 8, 0, 8)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 8
    page.Visible = false
    page.CanvasSize = UDim2.new(0,0,0,0)

    local list = Instance.new("UIListLayout", page)
    list.Padding = UDim.new(0, 8)
    list.HorizontalAlignment = Enum.HorizontalAlignment.Left
    list.SortOrder = Enum.SortOrder.LayoutOrder

    Pages[name] = { button = btn, frame = page, layout = list }

    btn.MouseButton1Click:Connect(function()
        SelectPage(name)
    end)
    return page
end

local Widget = {}
local function setPos(obj) obj.Position = UDim2.new(0, 8, 0, 0) end

function Widget:Toggle(parent, text, toggleRef)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -16, 0, 40)
    frame.BackgroundTransparency = 1

    local label = makeLabel(frame, text)
    label.Position = UDim2.new(0, 0, 0, 2)
    label.Font = Enum.Font.Gotham

    local tb = Instance.new("TextButton", frame)
    tb.Size = UDim2.new(0, 56, 0, 26)
    tb.Position = UDim2.new(1, -62, 0, 8)
    tb.Text = toggleRef.Value and "ON" or "OFF"
    tb.Font = Enum.Font.GothamBold
    tb.TextSize = 12
    tb.BackgroundColor3 = toggleRef.Value and currentTheme.highlight or Color3.fromRGB(60,60,60)
    tb.TextColor3 = Color3.new(1,1,1)
    tb.AutoButtonColor = true
    Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 6)

    tb.MouseButton1Click:Connect(function()
        toggleRef.Value = not toggleRef.Value
        tb.Text = toggleRef.Value and "ON" or "OFF"
        tb.BackgroundColor3 = toggleRef.Value and currentTheme.highlight or Color3.fromRGB(60,60,60)
    end)
    return frame
end

function Widget:NumberBox(parent, text, min, max, rounding, optionRef)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -16, 0, 48)
    frame.BackgroundTransparency = 1

    local label = makeLabel(frame, text)
    label.Position = UDim2.new(0, 0, 0, 2)

    local minus = makeButton(frame, "-", 32)
    minus.Size = UDim2.new(0, 40, 0, 32)
    minus.Position = UDim2.new(1, -130, 0, 12)
    minus.Text = "-"

    local plus = makeButton(frame, "+", 32)
    plus.Size = UDim2.new(0, 40, 0, 32)
    plus.Position = UDim2.new(1, -80, 0, 12)
    plus.Text = "+"

    local val = Instance.new("TextBox", frame)
    val.Size = UDim2.new(0, 48, 0, 32)
    val.Position = UDim2.new(1, -192, 0, 12)
    val.BackgroundColor3 = currentTheme.accent
    val.TextColor3 = currentTheme.highlight
    val.Font = Enum.Font.GothamBold
    val.TextSize = 14
    val.Text = tostring(optionRef.Value)
    val.ClearTextOnFocus = false
    Instance.new("UICorner", val).CornerRadius = UDim.new(0, 4)

    val.FocusLost:Connect(function(enterPressed)
    local n = tonumber(val.Text)
    if n then
        n = math.clamp(n, min, max)
        if rounding == 0 then n = math.floor(n) end
        optionRef.Value = n
        val.Text = tostring(n)
    else
        val.Text = tostring(optionRef.Value)
    end
end)

    local step = 1
    if rounding and rounding > 0 then step = 10^-rounding end

    local function update(v)
        v = math.clamp(v, min, max)
        if rounding == 0 then v = math.floor(v) end
        optionRef.Value = v
        val.Text = tostring(v)
    end

    minus.MouseButton1Click:Connect(function() update(optionRef.Value - step) end)
    plus.MouseButton1Click:Connect(function() update(optionRef.Value + step) end)

    return frame
end

local function CreateDropdown(parent, labelText, initialValuesTable, optionRef)
    local wrap = Instance.new("Frame", parent)
    wrap.Size = UDim2.new(1, -16, 0, 44)
    wrap.BackgroundTransparency = 1

    local label = makeLabel(wrap, labelText)
    label.Position = UDim2.new(0,0,0,2)

    local display = makeButton(wrap, tostring(optionRef.Value), 28)
    display.Size = UDim2.new(1, -16, 0, 28)
    display.Position = UDim2.new(0,8,0,24)

    local values = initialValuesTable or {"None"}
    local idx = 1
    local function refresh()
        idx = 1
        for i,v in ipairs(values) do
            if tostring(v) == tostring(optionRef.Value) then idx = i; break end
        end
        optionRef.Value = values[idx] or values[1]
        display.Text = tostring(optionRef.Value)
    end
    refresh()

    local left = makeButton(wrap, "<", 28)
    left.Size = UDim2.new(0, 40, 0, 28)
    left.Position = UDim2.new(1, -108, 0, 24)
    left.Text = "<"
    left.MouseButton1Click:Connect(function()
        idx = idx - 1
        if idx < 1 then idx = #values end
        optionRef.Value = values[idx]
        display.Text = tostring(optionRef.Value)
    end)

    local right = makeButton(wrap, ">", 28)
    right.Size = UDim2.new(0, 40, 0, 28)
    right.Position = UDim2.new(1, -64, 0, 24)
    right.Text = ">"
    right.MouseButton1Click:Connect(function()
        idx = idx + 1
        if idx > #values then idx = 1 end
        optionRef.Value = values[idx]
        display.Text = tostring(optionRef.Value)
    end)

    return {
        Frame = wrap,
        SetValues = function(newTab)
            values = newTab or {"None"}
            if #values == 0 then values = {"None"} end
            refresh()
        end,
        GetValue = function() return optionRef.Value end
    }
end

function Widget:Button(parent, text, callback)
    local btn = makeButton(parent, text, 34)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Drag logic for TitleBar only (MainFrame draggable)
local dragInfo = { dragging = false, startPos = nil, startMouse = nil }
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragInfo.dragging = true
        dragInfo.startPos = MainFrame.Position
        dragInfo.startMouse = UserInputService:GetMouseLocation()
    end
end)
TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragInfo.dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragInfo.dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = UserInputService:GetMouseLocation() - dragInfo.startMouse
        local newX = dragInfo.startPos.X.Scale + delta.X / ScreenGui.AbsoluteSize.X
        local newY = dragInfo.startPos.Y.Scale + delta.Y / ScreenGui.AbsoluteSize.Y
        MainFrame.Position = UDim2.new(newX, 0, newY, 0)
    end
end)

local savedMainPos = MainFrame.Position
local function ToggleUI()
    if MainFrame.Visible then
        savedMainPos = MainFrame.Position
        TweenService:Create(MainFrame, tweenClose, {Size = shrinkSize}):Play()
        task.wait(0.22)
        MainFrame.Visible = false
    else
        MainFrame.Position = savedMainPos
        MainFrame.Visible = true
        MainFrame.Size = shrinkSize
        TweenService:Create(MainFrame, tweenOpen, {Size = defaultPanelSize}):Play()
    end
end
ToggleButton.MouseButton1Click:Connect(ToggleUI)

local function applyTheme(name)
    local th = THEMES[name]
    if not th then return end
    currentThemeName = name
    currentTheme = th

    MainFrame.BackgroundColor3 = currentTheme.bg
    TitleBar.BackgroundColor3 = currentTheme.accent
    ToggleButton.BackgroundColor3 = currentTheme.bg
    ToggleButton.ImageColor3 = currentTheme.highlight
    mfStroke.Color = currentTheme.accent
    tbStroke.Color = currentTheme.accent

    for _, p in pairs(Pages) do
        if p.button then
            if ActivePage and ActivePage == p then
                p.button.BackgroundColor3 = currentTheme.highlight
                p.button.TextColor3 = currentTheme.bg
            else
                p.button.BackgroundColor3 = currentTheme.accent
                p.button.TextColor3 = Color3.new(1,1,1)
            end
        end
        for _, child in ipairs(p.frame:GetChildren()) do
            if child:IsA("TextButton") then child.BackgroundColor3 = currentTheme.accent end
            if child:IsA("Frame") then
                for _, g in ipairs(child:GetChildren()) do
                    if g:IsA("TextButton") then g.BackgroundColor3 = currentTheme.accent end
                    if g:IsA("TextLabel") then g.TextColor3 = Color3.new(1,1,1) end
                end
            end
        end
    end
end

do
    for _, name in ipairs({"Mint","Red","Blue","Pink","Purple","Gold"}) do
        local b = Instance.new("TextButton", ThemeContainer)
        b.Size = UDim2.new(0, 12, 0, 12)
        b.BackgroundColor3 = THEMES[name].highlight
        b.BorderSizePixel = 0
        b.AutoButtonColor = true
        b.Text = ""
        b.Parent = ThemeContainer
        local c = Instance.new("UICorner", b)
        c.CornerRadius = UDim.new(0, 4)
        b.MouseButton1Click:Connect(function() applyTheme(name) end)
    end
end

local MainPage = CreateCategory("Main")
local EggPage = CreateCategory("Egg")
local TeleportTab = CreateCategory("Island")
local SettingsPage = CreateCategory("Settings")

local BossList = {
    "Flaragon","Glazadon","Flarecrest","Mountusk","ShadeKnight","Frost Floradelle"
}
local BossModes = {'Specific', 'All'}
local SelectedBossMode = ensureOption("BossMode", BossModes[1])
local SelectedBoss = ensureOption("SelectedBoss", BossList[1])

CreateDropdown(MainPage, "Boss Mode", BossModes, SelectedBossMode)
CreateDropdown(MainPage, "Selected Boss", BossList, SelectedBoss)
Widget:Toggle(MainPage, "Auto Farm Boss", ensureToggle("FarmBoss", false))

_G.listMonster = _G.listMonster or {}
local SelectedMonster = ensureOption("SelectedMonster", "None")
local monsterDrop = CreateDropdown(MainPage, "Selected Monster", _G.listMonster, SelectedMonster)
Widget:Toggle(MainPage, "Auto Farm Monster", ensureToggle("FarmMonster", false))
Widget:Toggle(MainPage, "Mob Aura (Auto Click Nearby)", ensureToggle("MobAura", false))
Widget:Toggle(MainPage, "Auto Dungeon", ensureToggle("DungeonFarm", false))
Widget:Toggle(MainPage, "Fly", ensureToggle("Fly", false))

local aaa = { 'SwampEgg','Ice Egg','FireEgg','Turkey Egg','Pyroclasm Egg','Glacier Egg','Sprout Egg','Abuse Egg' }
local SelectedEgg = ensureOption("SelectedEgg", aaa[1])
CreateDropdown(EggPage, "Selected Egg", aaa, SelectedEgg)
local SelectedMachine = ensureOption("SelectedMachine", 1)
Widget:NumberBox(EggPage, "Selected Machine (1-4)", 1, 4, 0, SelectedMachine)
Widget:Toggle(EggPage, "Auto Hatch Egg", ensureToggle("AutoHatch", false))
Widget:Toggle(EggPage, "Keep Egg Bosses", ensureToggle("AutoOpenBoss", false))
Widget:Toggle(EggPage, "Keep Egg Monster", ensureToggle("AutoOpen", false))
local Island = {'First Land','Ice Land','Volcano Land','Neverland'}
local SelectedIsLand = ensureOption("SelectedIsLand", Island[1])
CreateDropdown(EggPage, "Selected IsLand", Island, SelectedIsLand)
Widget:Toggle(EggPage, "Auto Find Egg", ensureToggle("AutoFindEgg", false))


Widget:Button(TeleportTab, 'Duneveil Isle', function() Collection:Teleport(Vector3.new(790.170, -39.027, -3452.533)) end)
Widget:Button(TeleportTab, 'First IsLand', function() Collection:Teleport(Vector3.new( 85, -60, 669 )) end)
Widget:Button(TeleportTab, 'Sky IsLand', function() Collection:Teleport(Vector3.new( 573, 3477, -228 )) end)
Widget:Button(TeleportTab, 'Ice IsLand', function() Collection:Teleport(Vector3.new( -2211, -117, -979 )) end)
Widget:Button(TeleportTab, 'Volcano IsLand', function() Collection:Teleport(Vector3.new( 167, -118, -1150 )) end)
Widget:Button(TeleportTab, 'Neverland', function() Collection:Teleport(Vector3.new(3525.178, -124.396, 2046.970)) end)


local FPSCAP = ensureOption("FPSCAP", 120)
Widget:NumberBox(SettingsPage, "Set Fps Cap", 5, 240, 0, FPSCAP)
local Wave = ensureOption("Wave", 10)
Widget:NumberBox(SettingsPage, "Set Layer", 1, 50, 0, Wave)
local MonsterCount = ensureOption("MonsterCount", 1)
Widget:NumberBox(SettingsPage, "Monster Count", 0, 10, 0, MonsterCount)
Widget:Toggle(SettingsPage, "Auto Exit Door", ensureToggle("ExitDoor", false))

local CodeList = {
    'coin','cam','xp','thanksgiving','feather200','thanks300','friday','feather','rankA','endless','eandy','delay','patch'
}
Widget:Button(SettingsPage, 'Redeem All Code', function()
    for _,v in pairs(CodeList) do
        local args = { "GetGiftChannel", tostring(v) }
        pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("CommonLibrary"):WaitForChild("Tool"):WaitForChild("RemoteManager"):WaitForChild("Funcs"):WaitForChild("DataPullFunc"):InvokeServer(unpack(args))
        end)
        task.wait(0.3)
    end
    game.StarterGui:SetCore("SendNotification", { Title = "!! Completed !!", Text = "Redeem All Code", Duration = 5 })
end)

Widget:Button(SettingsPage, "Destroy Ui", function() pcall(function() ScreenGui:Destroy() end) end)

task.spawn(function()
    task.wait(0.25)
    pcall(function() SelectPage("Main") end)
end)

local fireclickdetector = (getfenv and getfenv().fireclickdetector) or (fireclickdetector) or function(det)
    pcall(function()
        if det and det:IsA("ClickDetector") then
            det:FireClick()
        end
    end)
end

local MgrMonsterClient
pcall(function() MgrMonsterClient = require(ReplicatedStorage.ClientLogic.Monster.MgrMonsterClient) end)

local monsterData = {}
_G.listMonster = _G.listMonster or {}
local function updateMonsterList()
    for k in pairs(_G.listMonster) do _G.listMonster[k] = nil end
    for k in pairs(monsterData) do monsterData[k] = nil end

    if type(MgrMonsterClient) == "table" and MgrMonsterClient.IterMonster then
        pcall(function() MgrMonsterClient.IterMonster(function(monsterInfo)
            local monsterName = monsterInfo.Config and monsterInfo.Config.Name or "Unknown"
            local monsterId = monsterInfo.MonsterId

            if not table.find(_G.listMonster, monsterName) then table.insert(_G.listMonster, monsterName) end

            if not monsterData[monsterName] then
                monsterData[monsterName] = {
                    Name = monsterName,
                    Config = monsterInfo.Config,
                    Instances = {}
                }
            end
            table.insert(monsterData[monsterName].Instances, { MonsterId = monsterId, Info = monsterInfo })
            return true
        end) end)
    else
        if ClientMonsters then
            for _, v in ipairs(ClientMonsters:GetChildren()) do
                if not table.find(_G.listMonster, v.Name) then table.insert(_G.listMonster, v.Name) end
            end
        end
    end
end

task.spawn(function()
    while true do
        pcall(updateMonsterList)
        if type(_G.listMonster) == "table" and #_G.listMonster > 0 then
            monsterDrop.SetValues(_G.listMonster)
        end
        task.wait(2)
    end
end)

Collection = Collection or {}
Collection.__index = Collection

function Collection:UseEvent(Key)
    local vum = game:GetService("VirtualInputManager")
    vum:SendKeyEvent(true, Key, false, game)
    vum:SendKeyEvent(false, Key, false, game)
end

function Collection:getRoot(Character)
    Character = Character or (LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait())
    return Character:WaitForChild("HumanoidRootPart", 5) or Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChild("Root") or Character:FindFirstChild("Torso")
end

function Collection:Teleport(Position)
    local Root = Collection:getRoot(LocalPlayer.Character)
    if not Root then return end
    if typeof(Position) == "CFrame" then Root.CFrame = Position
    elseif typeof(Position) == "Vector3" then Root.CFrame = CFrame.new(Position)
    end
end

function Collection:getClosesetMonster()
    local Enemies = {}
    local EnemiesPositions = {}
    local Root = Collection:getRoot(LocalPlayer.Character)
    if not ClientMonsters then return nil end
    for _, v in ipairs(ClientMonsters:GetChildren()) do
        if v:FindFirstChild("Root") then
            local Distance = math.floor((v.Root.Position - Root.Position).Magnitude)
            table.insert(EnemiesPositions, Distance)
            Enemies[tostring(Distance)] = v
        end
    end
    if #EnemiesPositions == 0 then return nil end
    return Enemies[tostring(math.min(unpack(EnemiesPositions)))]
end

function Collection:getClosesetMonster2(limit)
    local Enemies = {}
    local EnemiesPositions = {}
    local Root = Collection:getRoot(LocalPlayer.Character)
    if not ClientMonsters then return nil end
    local monsterList = ClientMonsters:GetChildren()
    local monsterCount = #monsterList
    if limit and monsterCount ~= nil and monsterCount <= limit then return "LIMIT MONSTER" end
    for _, v in ipairs(monsterList) do
        if v:FindFirstChild("Root") then
            local Distance = math.floor((v.Root.Position - Root.Position).Magnitude)
            table.insert(EnemiesPositions, Distance)
            Enemies[tostring(Distance)] = v
        end
    end
    if #EnemiesPositions == 0 then return nil end
    return Enemies[tostring(math.min(unpack(EnemiesPositions)))]
end

function Collection:getBoss(EnterHealth)
    if not Workspace:FindFirstChild("Monsters") then return false end
    for i, v in pairs(Workspace.Monsters:GetChildren()) do
        local healthObj = v:FindFirstChild("Health")
        if healthObj and healthObj:GetAttribute("MaxHealth") == EnterHealth then return v end
    end
    return false
end

function Collection:getBossByName(boss_n)
    if not ClientMonsters then return false end
    for i, v in pairs(ClientMonsters:GetChildren()) do
        if v.Name == tostring(boss_n) then return v end
    end
    return false
end

function Collection:getAllMonsterIdsByName(monsterName)
    local data = monsterData[monsterName]
    if not data or #data.Instances == 0 then
        return {}
    end
    local aliveIds = {}
    for _, instance in ipairs(data.Instances) do
        if instance.Info and instance.Info:IsAlive() then
            table.insert(aliveIds, "Monster_" .. tostring(instance.MonsterId))
        end
    end
    return aliveIds
end

function Collection:targetEgg(NameEgg)
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return end
    local EggSelect = playerGui:FindFirstChild("MainGui") and playerGui.MainGui:FindFirstChild("ScreenGui") and playerGui.MainGui.ScreenGui:FindFirstChild("EggSelectView")
    if not EggSelect then return nil end
    local FmList = EggSelect:FindFirstChild("FmList")
    if not FmList then return nil end
    for _, fmItem in pairs(FmList:GetChildren()) do
        if fmItem:IsA("Frame") or fmItem:IsA("GuiObject") then
            for _, child in pairs(fmItem:GetChildren()) do
                local labName = child:FindFirstChild("LabName")
                if labName and labName:IsA("TextLabel") then
                    if labName.Text == NameEgg then return child end
                end
            end
        end
    end
end

function Collection:fireclickbutton(button)
    if not button then return end
    xpcall(function()
        local VisibleGui = LocalPlayer.PlayerGui:FindFirstChild("_") or Instance.new("Frame")
        VisibleGui.Name = "_"
        VisibleGui.BackgroundTransparency = 0
        VisibleGui.Parent = LocalPlayer.PlayerGui
        LocalPlayer.PlayerGui.SelectionImageObject = VisibleGui
        GuiService.SelectedObject = button
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
    end, warn)
end

function Collection:getHatchEgg()
    local WorkspaceArea = Workspace:FindFirstChild("Area")
    if not WorkspaceArea then return false end
    local machineList = Options.SelectedMachine and Options.SelectedMachine.Value or 1

    local EggHatch = Workspace.Area.center.Area:FindFirstChild("EggHatch")
    if not EggHatch then return false end

    local hatch = EggHatch:FindFirstChild("Hatch_" .. machineList)
    if not hatch then return false end
    local TopGUI = hatch:FindFirstChild("TopGUI")
    if not TopGUI then return false end
    local HatchInfo = TopGUI:FindFirstChild("HatchInfoGui")
    if not HatchInfo then return false end
    local CompleteFrame = HatchInfo:FindFirstChild("FmComplete")
    if not CompleteFrame then return false end
    local LabDesc = CompleteFrame:FindFirstChild("LabDesc")
    if not LabDesc or not LabDesc.Text then return false end
    if LabDesc.Text:lower():find("ready to hatch!") then return hatch end

    return false
end

function Collection:getNotRoot()
    local machineList = Options.SelectedMachine and Options.SelectedMachine.Value or 1
    local EggHatch = Workspace.Area.center.Area:FindFirstChild("EggHatch")
    if not EggHatch then return false end

    local v = EggHatch:FindFirstChild("Hatch_"..machineList)
    if v then
        local EggAth = v:FindFirstChild("EggAth")
        if EggAth then
            local root = EggAth:FindFirstChild("Root", true) or EggAth:FindFirstChild("HumanoidRootPart", true)
            if not root then return v end
        end
    end
    return false
end

task.spawn(function()
    local lastBossTeleport = 0
    while true do 
        task.wait(0.5)
        if Toggles.FarmBoss.Value then
            local success, err = pcall(function()
                local BossNames = {"Flaragon","Glazadon","Flarecrest","Mountusk","ShadeKnight","Frost Floradelle"}
                local targets = {}
                
                if Options.BossMode.Value == "All" then
                    targets = BossNames
                else
                    table.insert(targets, Options.SelectedBoss.Value)
                end

                local activeBosses = {}
                local character = LocalPlayer.Character
                local pPos = (character and character:FindFirstChild("HumanoidRootPart")) and character.HumanoidRootPart.Position or Vector3.zero

                for _, bName in ipairs(targets) do
                    -- Use monsterData to find instances (More reliable than Health Key)
                    if monsterData[bName] and monsterData[bName].Instances then
                        for _, instData in ipairs(monsterData[bName].Instances) do
                            if instData.Info and instData.Info:IsAlive() then
                                local mId = instData.MonsterId
                                local realName = "Monster_" .. tostring(mId)
                                local mInstance = ClientMonsters:FindFirstChild(realName)
                                if mInstance and mInstance:FindFirstChild("Root") then
                                    local dist = (mInstance.Root.Position - pPos).Magnitude
                                    table.insert(activeBosses, {Instance = mInstance, Dist = dist})
                                end
                            end
                        end
                    end
                end

                if #activeBosses > 0 then
                    _G.TargetingBoss = true
                    table.sort(activeBosses, function(a,b) return a.Dist < b.Dist end)
                    local targetBoss = activeBosses[1].Instance

                    if targetBoss and targetBoss:FindFirstChild("Root") then
                         -- Pet Logic (Optimized)
                        if Workspace:FindFirstChild("ClientPets") then
                            for i,v in pairs(Workspace.ClientPets:GetChildren()) do
                                if string.find(v.Name, 'Pet') and v:FindFirstChild('Root') then
                                    local root = Collection:getRoot(LocalPlayer.Character)
                                    if root and (v.Root.Position - root.Position).magnitude > 20 then
                                        v.Root.CFrame = root.CFrame
                                    end
                                end
                            end
                        end

                        local targetPos = targetBoss.Root.Position
                        local dist = LocalPlayer:DistanceFromCharacter(targetPos)
                        
                        -- Added cooldown (0.5s) and Distance Offset (10 studs above)
                        if dist > 15 and (tick() - lastBossTeleport > 0.5) then
                             Collection:Teleport(targetBoss.Root.CFrame * CFrame.new(0, 10, 0))
                             lastBossTeleport = tick()
                        end

                        local clickDetector = targetBoss.Root:FindFirstChild("ClickDetector")
                        if clickDetector then
                            clickDetector.MaxActivationDistance = 2000
                            fireclickdetector(clickDetector)
                        end
                    end
                else
                    _G.TargetingBoss = false
                end
            end)
            if err then warn("Boss Farm Error: "..tostring(err)) end
        else
             if _G.TargetingBoss then _G.TargetingBoss = false end
        end
    end
end)

task.spawn(function()
    while true do task.wait()
        if Toggles.FarmMonster.Value then
            local succes, err = pcall(function()
                if not ClientMonsters then ClientMonsters = Workspace:FindFirstChild("ClientMonsters") end
                if not ClientMonsters then return end

                local MonsterNames = Collection:getAllMonsterIdsByName(Options.SelectedMonster.Value)

                for _, v in pairs(ClientMonsters:GetChildren()) do
                    if not Toggles.FarmMonster.Value then break end
                    if _G.TargetingBoss then break end

                    if table.find(MonsterNames, v.Name) then
                        local health = v:FindFirstChild("Health")
                        repeat task.wait()
                            if _G.TargetingBoss then break end
                            local root = v:FindFirstChild("Root")

                            if root then
                                if LocalPlayer:DistanceFromCharacter(root.Position) > 5 then
                                    Collection:Teleport(root.Position)
                                end

                                local clickDetector = root:FindFirstChild("ClickDetector")
                                if clickDetector then
                                    clickDetector.MaxActivationDistance = 1000
                                    fireclickdetector(clickDetector)
                                    task.wait(0.25)
                                end
                            end
                        until not (v and v.Parent) or not Toggles.FarmMonster.Value or (health and (health.Value or 0) <= 0)
                    end
                end
            end)
          if err then print('!! ERROR !!'.. tostring(err)) end
        end
    end
end)

task.spawn(function()
    while task.wait() do
        if Toggles.MobAura.Value then
            local success, err = pcall(function()
                local Enemies = Collection:getClosesetMonster()
                if Enemies then
                    repeat 
                        task.wait(0.1)
                        if not (Enemies and Enemies.Parent and Enemies:FindFirstChild("Root")) then
                            Enemies = Collection:getClosesetMonster()
                        end
                        if Enemies and Enemies ~= "LIMIT MONSTER" then
                            local root = Enemies.Root
                            if root then
                                if LocalPlayer:DistanceFromCharacter(root.Position) > 5 then
                                    Collection:Teleport(root.Position)
                                end
                                local cd = root:FindFirstChild("ClickDetector")
                                if cd then
                                    cd.MaxActivationDistance = 1000
                                    fireclickdetector(cd)
                                    task.wait(0.3)
                                end
                            end
                        end
                    until not Toggles.MobAura.Value
                end
            end)
            if err then warn("!! Error !! " .. tostring(err)) end
        end
    end
end)

task.spawn(function()
    while task.wait() do
        if Toggles.DungeonFarm.Value then
            local success, err = pcall(function()

                local Enemies = Collection:getClosesetMonster2(Options.MonsterCount.Value)

                if LocalPlayer:DistanceFromCharacter(Vector3.new(49999, -35, 9)) <= 1500 then
                    if Enemies and Enemies ~= "LIMIT MONSTER" then
                        repeat 
                            task.wait(0.1)
                            if not (Enemies and Enemies.Parent and Enemies:FindFirstChild("Root")) then
                                Enemies = Collection:getClosesetMonster2(Options.MonsterCount.Value)
                            end
                            if Enemies == "LIMIT MONSTER" then break end

                            if Enemies and Enemies ~= "LIMIT MONSTER" then
                                local root = Enemies.Root
                                if root then
                                    if LocalPlayer:DistanceFromCharacter(root.Position) > 5 then
                                        Collection:Teleport(root.Position)
                                    end

                                    local cd = root:FindFirstChild("ClickDetector")
                                    if cd then
                                        cd.MaxActivationDistance = 1000
                                        fireclickdetector(cd)
                                        task.wait(0.3)
                                    end
                                end
                            end
                        until not Toggles.DungeonFarm.Value
                    end

                    if Enemies == "LIMIT MONSTER" then
                        ReplicatedStorage.CommonLibrary.Tool.RemoteManager.Funcs.DataPullFunc:InvokeServer("TowerLeaveChannel")
                    end
                    local TowerResultView = Player.PlayerGui.MainGui.ScreenGui:FindFirstChild('TowerResultView')
                    if TowerResultView then
                        Collection:fireclickbutton(TowerResultView.FmContent.BtClose)
                    end
                else
                    Collection:Teleport(Vector3.new(814, 3485, -354))
                    task.wait(1.5)
                    local TowerEnter = Workspace.Area.center.Area.CommonZone:FindFirstChild("TowerEnter")
                    if TowerEnter then
                        Collection:Teleport(TowerEnter.Position)
                        task.wait(1.5)
                    end
                end
            end)
            if err then warn("!! Error !!".. tostring(err)) end
        end
    end
end)

task.spawn(function()
    while true do task.wait()
        if Toggles.ExitDoor.Value then
            pcall(function()
                local MainGui = Player.PlayerGui:FindFirstChild("MainGui")
                if MainGui and MainGui.ScreenGui:FindFirstChild('TowerMainLeftTopView') then
                    local currentText = MainGui.ScreenGui.TowerMainLeftTopView.FmLayer.LabLayer.Text
                    local currentLayer = tonumber(currentText:match("%d+"))
                    local targetLayer = Options.Wave.Value

                    if Workspace:FindFirstChild('TowerToNextZone') then
                        Collection:Teleport(Workspace:FindFirstChild('TowerToNextZone').Position)
                    elseif currentLayer and targetLayer and currentLayer >= targetLayer then
                        ReplicatedStorage.CommonLibrary.Tool.RemoteManager.Funcs.DataPullFunc:InvokeServer("TowerLeaveChannel")
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while true do task.wait()
        if Toggles.AutoHatch.Value then
            local succes, err = pcall(function()
                if LocalPlayer:DistanceFromCharacter(Vector3.new(572, 3487, -297)) <= 1000 then
                    local Root_C = Collection:getNotRoot()
                    local Machine_C = Collection:getHatchEgg()

                    local playerGui = Player.PlayerGui
                    local EggSelectView = playerGui:FindFirstChild("MainGui") and playerGui.MainGui.ScreenGui:FindFirstChild('EggSelectView')

                    if Root_C and not Machine_C then
                        Collection:Teleport(Root_C.Position)
                        if LocalPlayer:DistanceFromCharacter(Root_C.Position) <= 10 then
                            Collection:UseEvent('E')
                            task.wait()

                            if EggSelectView then
                                Collection:fireclickbutton(Collection:targetEgg(Options.SelectedEgg.Value))
                            end
                            if EggSelectView
                                and EggSelectView:FindFirstChild('RightFrame')
                                and EggSelectView.RightFrame:FindFirstChild("CommonBg")
                                and EggSelectView.RightFrame.CommonBg.Visible
                            then
                                Collection:fireclickbutton(EggSelectView.RightFrame.CommonBg.BottomFrame.Select)
                            end
                        end
                    end
                    if Machine_C then
                        Collection:Teleport(Machine_C.Position)
                        task.wait(0.5)
                        Collection:UseEvent('E')
                        task.wait()
                    end
                else
                    Collection:Teleport(Vector3.new(572, 3487, -297))
                end
            end)

            if err then print('!! ERROR !!'.. tostring(err)) end
        end
    end
end)

task.spawn(function()
    while true do task.wait()
        if Toggles.AutoFindEgg.Value then
            local succes, err = pcall(function()
                local TargetPos, MaxDistance = nil, nil

                if Options.SelectedIsLand.Value == "First Land" then
                    TargetPos = Vector3.new(84, -60, 645)
                    MaxDistance = 1000
                elseif Options.SelectedIsLand.Value == "Ice Land" then
                    TargetPos = Vector3.new(-2304, 42, -1420)
                    MaxDistance = 1500
                elseif Options.SelectedIsLand.Value == "Volcano Land" then
                    TargetPos = Vector3.new(-9, -116, -1539)
                    MaxDistance = 1500
                elseif Options.SelectedIsLand.Value == "Neverland" then
                    TargetPos = Vector3.new(3651.029, -44.811, 2231.164)
                    MaxDistance = 1500
                end
                elseif Options.SelectedIsLand.Value == "Duneveil Isle" then
                    TargetPos = Vector3.new(730.523, -119.168, -3161.539)
                    MaxDistance = 1500
                end

                if TargetPos and LocalPlayer:DistanceFromCharacter(TargetPos) >= MaxDistance then
                    Collection:Teleport(TargetPos)
                else
                    for i,v in pairs(Workspace:FindFirstChild("AreaEgg"):GetChildren() or {}) do
                        if v:IsA('Part') then
                            if (v.Position - TargetPos).magnitude <= MaxDistance then
                                Collection:Teleport(v.Position)
                                task.wait()
                                Collection:UseEvent('E')
                            end
                        end
                    end
                end
            end)

            if err then print('!! ERROR !!'.. tostring(err)) end
        end
    end
end)

task.spawn(function()
    while true do task.wait()
        if Toggles.AutoOpen.Value then
            if LocalPlayer:FindFirstChild('PlayerGui') and LocalPlayer.PlayerGui:FindFirstChild("CatchDoGui") then
                Collection:UseEvent("E")
            end
        end
    end
end)
task.spawn(function()
    while true do task.wait()
        if Toggles.AutoOpenBoss.Value then
            if LocalPlayer:FindFirstChild('PlayerGui') and LocalPlayer.PlayerGui:FindFirstChild("PickUpDoGui") then
                Collection:UseEvent("E")
            end
        end
    end
end)

task.spawn(function()
    while true do wait()
        pcall(function()
            if setfpscap then 
                setfpscap(Options.FPSCAP.Value)
            end
            task.wait(1)
        end)
    end
end)

local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    vu:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
    task.wait(1)
    vu:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
end)

game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
    if child.Name == 'ErrorPrompt' and child:FindFirstChild('MessageArea') and child.MessageArea:FindFirstChild("ErrorFrame") then
        game:GetService("TeleportService"):Teleport(game.PlaceId)
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if Pages then
            for _, pageData in pairs(Pages) do
                local page = pageData.frame
                local layout = pageData.layout

                if layout and page then
                    page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
                end
            end
        end
    end
end)

-- Fly Logic
task.spawn(function()
    local bodyGyro = Instance.new("BodyGyro")
    local bodyVel = Instance.new("BodyVelocity")
    bodyGyro.P = 9e4
    bodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.cframe = CFrame.new()
    bodyVel.velocity = Vector3.new(0, 0, 0)
    bodyVel.maxForce = Vector3.new(9e9, 9e9, 9e9)
    
    while true do
        task.wait()
        if Toggles.Fly and Toggles.Fly.Value then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
                local hum = char.Humanoid
                local root = char.HumanoidRootPart
                
                if not root:FindFirstChild("BodyGyro") then
                    bodyGyro.Parent = root
                    bodyVel.Parent = root
                end
                
                hum.PlatformStand = true
                
                local cam = Workspace.CurrentCamera
                local speed = 300 
                
                local newVel = Vector3.new(0,0,0)
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    newVel = newVel + cam.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    newVel = newVel - cam.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    newVel = newVel - cam.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    newVel = newVel + cam.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    newVel = newVel + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    newVel = newVel - Vector3.new(0, 1, 0)
                end
                
                bodyGyro.CFrame = cam.CFrame
                bodyVel.Velocity = newVel * speed
            else
                bodyGyro.Parent = nil
                bodyVel.Parent = nil
            end
        else
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.PlatformStand = false
            end
            bodyGyro.Parent = nil
            bodyVel.Parent = nil
        end
    end
end)
