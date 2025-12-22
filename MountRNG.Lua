--================= LOAD UI =================--
local UI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/amnad2003/veryfun_autofarm/refs/heads/main/VeryFunSHOPUIHUD.lua"
))()
if not UI then return end

UI:SetLogo(82270910588453)
UI:SetTitle("VeryFun SHOP | Premium Hub (BEST)")

--================= SERVICES =================--
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

--================= STATE =================--
_G.AutoKill = false
_G.AutoLoot = false
_G.AutoQuest = false
_G.HoverHeight = 10
_G.FPS = 60
_G.FPS_LOCK = false

--=====================================================
-- UTILS
--=====================================================
local function GetCharacter()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return end
    return char, hrp, hum
end

local function FindMob()
    local mobsFolder = Workspace:FindFirstChild("Mobs")
    if mobsFolder then
        for _,m in ipairs(mobsFolder:GetChildren()) do
            local h = m:FindFirstChildOfClass("Humanoid")
            local hrp = m:FindFirstChild("HumanoidRootPart")
            if h and hrp and h.Health > 0 then
                return m, h, hrp
            end
        end
    end
end

--=====================================================
-- FARM PAGE
--=====================================================
local Farm = UI:CreatePage("Auto Farm")

UI:CreateToggle(Farm,"Auto Kill (Hover Head)",false,function(v)
    _G.AutoKill = v
end)

UI:CreateSlider(Farm,"Hover Height",3,15,_G.HoverHeight,function(v)
    _G.HoverHeight = v
end)

UI:CreateToggle(Farm,"Auto Loot",false,function(v)
    _G.AutoLoot = v
end)

UI:CreateToggle(Farm,"Auto Quest",false,function(v)
    _G.AutoQuest = v
end)

UI:CreateLabel(Farm,"⚙ FPS")

UI:CreateSlider(Farm,"FPS",1,120,_G.FPS,function(v)
    _G.FPS = v
    if _G.FPS_LOCK and setfpscap then
        setfpscap(v)
    end
end)

UI:CreateToggle(Farm,"Enable FPS Lock",false,function(v)
    _G.FPS_LOCK = v
    if setfpscap then
        setfpscap(v and _G.FPS or 999)
    end
end)

--=====================================================
-- TELEPORT PAGE (SELECT = INSTANT TP)
--=====================================================
local Teleport = UI:CreatePage("Teleport")

local TeleportPoints = {
    ["Armor lce"] = CFrame.new(-462.498, 789.776, -864.203),
    ["Armor 2"] = CFrame.new(-47.604, 29.500, -207.001),
    ["Armor 3"] = CFrame.new(984.033, 30.500, 348.176),
    ["Armor 4"] = CFrame.new(-632.616, 29.500, -587.241),
    ["Armor 5 (Ice)"] = CFrame.new(-369.407, 176.500, -1290.691),
    ["Armor 5 (Lava)"] = CFrame.new(-210.013, 37.267, -1365.733),
}

UI:CreateLabel(Teleport,"🧭 Armor Teleport (เลือกชื่อ = วาปทันที)")

UI:CreateDropdown(
    Teleport,
    "Teleport To",
    (function()
        local t = {}
        for k in pairs(TeleportPoints) do table.insert(t,k) end
        table.sort(t)
        return t
    end)(),
    function(sel)
        task.spawn(function()
            _G.AutoKill = false
            local _, hrp = GetCharacter()
            if hrp and TeleportPoints[sel] then
                hrp.CFrame = TeleportPoints[sel]
            end
        end)
    end
)

--=====================================================
-- AUTO KILL
--=====================================================
task.spawn(function()
    while task.wait(0.2) do
        if not _G.AutoKill then continue end

        local _, hrp = GetCharacter()
        local mob, hum, mobHRP = FindMob()
        if not hrp or not mobHRP then continue end

        while _G.AutoKill and hum.Health > 0 do
            hrp.CFrame = mobHRP.CFrame * CFrame.new(0,_G.HoverHeight,0)
            if RS:FindFirstChild("Combat")
            and RS.Combat:FindFirstChild("RequestSkillUse")
            and RS.Combat:FindFirstChild("Skills") then
                for _,skill in ipairs(RS.Combat.Skills:GetChildren()) do
                    pcall(function()
                        RS.Combat.RequestSkillUse:FireServer(skill.Name)
                    end)
                end
            end
            task.wait(0.12)
        end
    end
end)

--=====================================================
-- AUTO LOOT
--=====================================================
local Looted = {}
Workspace.DescendantAdded:Connect(function(obj)
    if _G.AutoLoot and obj.Name:lower():find("loot") then
        if not Looted[obj] and obj:FindFirstChild("CollectLoot") then
            Looted[obj] = true
            pcall(function()
                obj.CollectLoot:FireServer()
            end)
        end
    end
end)

--=====================================================
-- AUTO QUEST
--=====================================================
task.spawn(function()
    while task.wait(1.5) do
        if not _G.AutoQuest then continue end
        pcall(function()
            local board = Workspace:FindFirstChild("Environment")
            and Workspace.Environment.Interactables.Quests:FindFirstChild("QuestBoard")
            if board and board:FindFirstChild("ProximityPrompt") then
                local _,hrp = GetCharacter()
                if hrp then
                    hrp.CFrame = board.CFrame * CFrame.new(0,2,0)
                    fireproximityprompt(board.ProximityPrompt)
                end
            end
        end)
    end
end)

--=====================================================
-- ANTI AFK
--=====================================================
player.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)

--=====================================================
-- FPS INIT
--=====================================================
if setfpscap then
    setfpscap(_G.FPS_LOCK and _G.FPS or 999)
end
