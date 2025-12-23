local UI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/amnad2003/veryfun_autofarm/refs/heads/main/VeryFunSHOPUIHUD.lua"
))()

UI:SetLogo(82270910588453)
UI:SetTitle("VeryFun SHOP | Premium Hub")

--=====================================================
-- CREATE PAGES
--=====================================================
local FarmPage = UI:CreatePage("Auto Farm")
local PerfPage = UI:CreatePage("Performance")
local AFKPage  = UI:CreatePage("Anti AFK")

--=====================================================
-- GLOBAL VALUES
--=====================================================
_G.Sea = "1"
_G.AutoKill = false
_G.AutoKillBuff = false
_G.AutoSell = false
_G.FPS_LOCK = false
_G.FPS = 60
_G.AFK = false
_G.AFK_TIME = 300
_G.FLY = false
_G.FLY_SPEED = 30

--=====================================================
-- AUTO FARM UI
--=====================================================
UI:CreateLabel(FarmPage,"⚔ Auto Farm")

UI:CreateDropdown(
    FarmPage,
    "Select Sea",
    {"1","2","3","4","5"},
    function(v)
        _G.Sea = v
    end
)

UI:CreateToggle(FarmPage,"Auto Kill",false,function(v)
    _G.AutoKill = v
end)

UI:CreateToggle(FarmPage,"Auto Kill [ Buff Fish ]",false,function(v)
    _G.AutoKillBuff = v
end)

UI:CreateToggle(FarmPage,"Auto Sell",false,function(v)
    _G.AutoSell = v
end)

--=====================================================
-- SERVICES
--=====================================================
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer

--=====================================================
-- SEA POSITION
--=====================================================
local SeaPos = {
    ["1"] = CFrame.new(1264,85,90),
    ["2"] = CFrame.new(1277,85,-77),
    ["3"] = CFrame.new(1259,85,-276),
    ["4"] = CFrame.new(1257,85,-527),
    ["5"] = CFrame.new(459.347, 83.376, -1032.163),
}

local function EquipTool()
    for _,v in pairs(LP.Backpack:GetChildren()) do
        if v.Name:find("Harpoon") then
            LP.Character.Humanoid:EquipTool(v)
        end
    end
end

--=====================================================
-- AUTO KILL
--=====================================================
task.spawn(function()
    while task.wait() do
        if _G.AutoKill then
            pcall(function()
                local sea = workspace.WorldSea:FindFirstChild("Sea".._G.Sea)
                if not sea then
                    LP.Character.HumanoidRootPart.CFrame = SeaPos[_G.Sea]
                    return
                end

                EquipTool()
                for _,fish in pairs(sea:GetChildren()) do
                    if fish:IsA("Part") then
                        RS.Remotes.FireRE:FireServer("Fire",{
                            cameraOrigin = workspace.CurrentCamera.CFrame.Position,
                            player = LP,
                            toolInstance = LP.Character:FindFirstChildOfClass("Tool"),
                            destination = fish.Position,
                            isCharge = true
                        })

                        RS.Remotes.FireRE:FireServer("Hit",{
                            fishInstance = fish,
                            HitPos = fish.Position,
                            toolInstance = LP.Character:FindFirstChildOfClass("Tool")
                        })

                        LP.Character.HumanoidRootPart.CFrame =
                            fish.Model.Root.CFrame * CFrame.new(0,5,0)
                        break
                    end
                end
            end)
        end
    end
end)

--=====================================================
-- AUTO SELL
--=====================================================
task.spawn(function()
    while task.wait(0.3) do
        if _G.AutoSell then
            pcall(function()
                local list = {}
                for _,v in pairs(LP.PlayerGui.Data.Fish:GetChildren()) do
                    table.insert(list,v.Name)
                end
                if #list > 0 then
                    RS.Remotes.FishRE:FireServer("SellAll",{UIDs=list})
                end
            end)
        end
    end
end)

--=====================================================
-- PERFORMANCE
--=====================================================
UI:CreateLabel(PerfPage,"⚙ FPS")

UI:CreateSlider(PerfPage,"FPS",5,120,60,function(v)
    _G.FPS = v
    if _G.FPS_LOCK and setfpscap then
        setfpscap(v)
    end
end)

UI:CreateToggle(PerfPage,"Enable FPS Lock",false,function(v)
    _G.FPS_LOCK = v
    if setfpscap then
        setfpscap(v and _G.FPS or 999)
    end
end)

--=====================================================
-- ANTI AFK
--=====================================================
UI:CreateLabel(AFKPage,"🕒 Anti AFK")

UI:CreateSlider(AFKPage,"AFK Interval",30,900,300,function(v)
    _G.AFK_TIME = v
end)

UI:CreateToggle(AFKPage,"Enable Anti AFK",false,function(v)
    _G.AFK = v
end)

task.spawn(function()
    while task.wait(1) do
        if _G.AFK then
            task.wait(_G.AFK_TIME)
            pcall(function()
                local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:Move(Vector3.new(0,0,-1),false)
                    task.wait(1)
                    hum:Move(Vector3.zero,false)
                end
            end)
        end
    end
end)
