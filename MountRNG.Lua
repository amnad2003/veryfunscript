loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/amnad2003/veryfunscript/refs/heads/main/ScriptLockHWID.Lua"
))()
local UI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/amnad2003/veryfun_autofarm/refs/heads/main/VeryFunSHOPUIHUD.lua"
))()
if not UI then return end

UI:SetLogo(82270910588453)
UI:SetTitle("VeryFun SHOP | Premium Hub (BEST)")

local Players = game:GetService("Players")
local RS      = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

_G.AutoKill    = false
_G.AutoLoot    = false
_G.AutoQuest   = false
_G.HoverHeight = 10
_G.FPS         = 60
_G.FPS_LOCK    = false

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

task.spawn(function()
    while task.wait(18) do
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end

        hum:Move(Vector3.new(0,0,0.00005), true)

        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
        task.wait(0.01)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)

        local cam = workspace.CurrentCamera
        if cam then
            cam.CFrame = cam.CFrame * CFrame.Angles(0, math.rad(0.1), 0)
        end

        RunService.Heartbeat:Wait()
    end
end)

local function GetCharacter()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return end
    return char, hrp, hum
end

local function FindMob()
    local bestMob, bestHum, bestHRP
    local highestHP = 0

    local mobsFolder = Workspace:FindFirstChild("Mobs")

    local function scan(folder)
        for _,m in ipairs(folder:GetChildren()) do
            if m:IsA("Model") and m ~= player.Character then
                local h = m:FindFirstChildOfClass("Humanoid")
                local hrp = m:FindFirstChild("HumanoidRootPart")
                if h and hrp and h.Health > 0 then
                    if h.MaxHealth > highestHP then
                        highestHP = h.MaxHealth
                        bestMob, bestHum, bestHRP = m, h, hrp
                    end
                end
            end
        end
    end

    if mobsFolder then
        scan(mobsFolder)
    else
        scan(Workspace)
    end

    return bestMob, bestHum, bestHRP
end

local function UseAllSkills()
    if not RS:FindFirstChild("Combat") then return end
    if not RS.Combat:FindFirstChild("Skills") then return end
    if not RS.Combat:FindFirstChild("RequestSkillUse") then return end

    for _,skill in ipairs(RS.Combat.Skills:GetChildren()) do
        pcall(function()
            RS.Combat.RequestSkillUse:FireServer(skill.Name)
        end)
    end
end

task.spawn(function()
    while task.wait(0.2) do
        if not _G.AutoKill then continue end

        local char, hrp = GetCharacter()
        if not char then continue end

        local mob, hum, mobHRP = FindMob()
        if not mob then continue end

        local startTime = tick()

        while _G.AutoKill
        and mob.Parent
        and hum.Health > 0 do

            -- เปลี่ยนตัวถ้าตีเกิน 20 วิ
            if tick() - startTime >= 20 then
                break
            end

            local _, p = GetCharacter()
            if not p or not mobHRP or not mobHRP.Parent then break end

            p.CFrame = mobHRP.CFrame * CFrame.new(0, _G.HoverHeight, 0)
            UseAllSkills()
            task.wait(0.12)
        end
    end
end)

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

if setfpscap then
    setfpscap(_G.FPS_LOCK and _G.FPS or 999)
end
--=====================================================
-- VERYFUN SHOP | HYBRID AUTO REJOIN (FINAL VERSION)
-- วางต่อท้ายสคริปต์หลักได้ทันที
--=====================================================

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

local PLACE_ID = game.PlaceId
local JOB_ID   = game.JobId

-------------------------------------------------------
-- CONFIG
-------------------------------------------------------

-- ใช้ลิงก์รันสคริปต์ใหม่หรือไม่
local USE_LINK = false   -- << true = รันออโต้ 100% | false = สะอาด ไม่ผ่านลิงก์

-- ใส่ลิงก์ไฟล์ "สคริปต์นี้เอง" (ใช้เมื่อ USE_LINK = true)
local MAIN_SCRIPT_URL = "https://raw.githubusercontent.com/yourname/yourscript/main.lua"

-------------------------------------------------------

local REJOINING = false

local function QueueMainScript()
    if not USE_LINK then return end
    if type(queue_on_teleport) ~= "function" then return end

    local code = string.format([[
        repeat task.wait() until game:IsLoaded()
        pcall(function()
            local src = game:HttpGet(%q)
            loadstring(src)()
        end)
    ]], MAIN_SCRIPT_URL)

    queue_on_teleport(code)
end


local function RejoinSameServer(reason)
    if REJOINING then return end
    REJOINING = true

    warn("[VeryFun] Auto Rejoin | Reason:", reason or "Unknown")

    QueueMainScript()

    task.delay(2, function()
        pcall(function()
            TeleportService:TeleportToPlaceInstance(
                PLACE_ID,
                JOB_ID,
                LocalPlayer
            )
        end)
    end)
end

Players.PlayerRemoving:Connect(function(p)
    if p == LocalPlayer then
        RejoinSameServer("PlayerRemoving")
    end
end)

LocalPlayer.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Failed then
        RejoinSameServer("Teleport Failed")
    end
end)

task.spawn(function()
    while task.wait(5) do
        if not game:IsLoaded() then
            RejoinSameServer("Game not loaded")
            break
        end
    end
end)
