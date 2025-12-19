local HWID_URL = "https://raw.githubusercontent.com/amnad2003/veryfunscript/refs/heads/main/LockHWID"
local WEBHOOK_URL = "https://discordapp.com/api/webhooks/1451427146030514320/hv-hwREUX0cjOMyMSWraR6SEY4ER4K9sGlC3zi_641CRKRSXHKJbWeGRvbtbB6RRMixm"

local _G_SENT_HWID_LOG = false

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local now = os.time()

local function GetHWID()
    if gethwid then
        return tostring(gethwid())
    elseif syn and syn.get_hwid then
        return tostring(syn.get_hwid())
    elseif crypt and crypt.generate_hash then
        return crypt.generate_hash("HWID")
    else
        return game:GetService("RbxAnalyticsService"):GetClientId()
    end
end

local myHWID = GetHWID()

local whitelistData = {}
pcall(function()
    whitelistData = loadstring(game:HttpGet(HWID_URL))()
end)

local function CheckHWID()
    if type(whitelistData) ~= "table" then
        return false, "SERVER_ERROR"
    end

    for _, info in ipairs(whitelistData) do
        if tostring(info.HWID) == tostring(myHWID) then
            if (info.EXPIRE or 0) ~= 0 and now > (info.EXPIRE or 0) then
                return false, "EXPIRED", info
            end
            return true, "OK", info
        end
    end

    return false, "NOT_FOUND"
end

local function SendWebhook(status, info)
    if _G_SENT_HWID_LOG then return end
    _G_SENT_HWID_LOG = true

    local gameName = "ไม่ทราบชื่อเกม"
    pcall(function()
        gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
    end)

    -- แปลงสถานะเป็นภาษาไทย
    local statusText = "ไม่ทราบสถานะ"
    local statusColor = 16711680 -- แดง

    if status == "OK" then
        statusText = "✅ ผ่านการตรวจสอบ"
        statusColor = 65280
    elseif status == "EXPIRED" then
        statusText = "⛔ หมดอายุการใช้งาน"
    elseif status == "NOT_FOUND" then
        statusText = "❌ HWID ไม่อยู่ในระบบ"
    elseif status == "SERVER_ERROR" then
        statusText = "⚠ เซิร์ฟเวอร์ตรวจสอบผิดพลาด"
        statusColor = 16776960
    end

    local expireText = "ถาวร"
    local remainText = "-"

    if info and (info.EXPIRE or 0) ~= 0 then
        expireText = os.date("%d/%m/%Y %H:%M:%S", info.EXPIRE)
        remainText = math.max(0, math.floor((info.EXPIRE - now) / 86400)) .. " วัน"
    end

    local payload = {
        username = "VERYFUN HWID SYSTEM",
        embeds = {{
            title = "🔐 รายงานการตรวจสอบ HWID",
            color = statusColor,
            fields = {
                { name = "👤 ผู้เล่น", value = player.Name.." ("..player.UserId..")", inline = true },
                { name = "🎮 เกม", value = gameName, inline = true },
                { name = "🆔 HWID", value = "```"..myHWID.."```", inline = false },
                { name = "📌 สถานะ", value = statusText, inline = true },
                { name = "📅 วันหมดอายุ", value = expireText, inline = true },
                { name = "⏳ เวลาคงเหลือ", value = remainText, inline = true }
            },
            footer = { text = "VeryFun Shop | ระบบป้องกันพรีเมียม" },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }

    local req = syn and syn.request or request or http_request or (http and http.request)
    if req then
        pcall(function()
            req({
                Url = WEBHOOK_URL,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = HttpService:JSONEncode(payload)
            })
        end)
    end
end

local function ShowHWIDScreen()
    local gui = Instance.new("ScreenGui")
    gui.Name = "VERYFUN_HWID_UI"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = player:WaitForChild("PlayerGui")

    local blur = Instance.new("BlurEffect", Lighting)
    blur.Size = 15

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 450, 0, 260)
    frame.Position = UDim2.new(0.5, -225, 0.5, 260)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 16)

    local stroke = Instance.new("UIStroke", frame)
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(255, 70, 70)

    TweenService:Create(frame, TweenInfo.new(.4, Enum.EasingStyle.Back), {
        Position = UDim2.new(0.5, -225, 0.5, -130)
    }):Play()

    local bar = Instance.new("Frame", frame)
    bar.Size = UDim2.new(1, 0, 0, 45)
    bar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 16)

    local title = Instance.new("TextLabel", bar)
    title.Size = UDim2.new(1, -50, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 21
    title.TextColor3 = Color3.fromRGB(255, 90, 90)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = "VERYFUN SHOP — HWID LOCK"

    local close = Instance.new("TextButton", bar)
    close.Size = UDim2.new(0, 50, 1, 0)
    close.Position = UDim2.new(1, -50, 0, 0)
    close.BackgroundTransparency = 1
    close.Font = Enum.Font.GothamBold
    close.TextSize = 22
    close.TextColor3 = Color3.fromRGB(255, 60, 60)
    close.Text = "✕"

    close.MouseButton1Click:Connect(function()
        TweenService:Create(frame, TweenInfo.new(.3), {
            Position = UDim2.new(0.5, -225, 0.5, 300)
        }):Play()
        task.wait(.25)
        gui:Destroy()
        blur:Destroy()
    end)

    local hwidLabel = Instance.new("TextLabel", frame)
    hwidLabel.Size = UDim2.new(1, -20, 0, 80)
    hwidLabel.Position = UDim2.new(0, 10, 0, 60)
    hwidLabel.BackgroundTransparency = 1
    hwidLabel.Font = Enum.Font.Gotham
    hwidLabel.TextSize = 16
    hwidLabel.TextWrapped = true
    hwidLabel.TextColor3 = Color3.new(1,1,1)
    hwidLabel.Text = "HWID ของคุณ:\n" .. myHWID

    local loading = Instance.new("TextLabel", frame)
    loading.Size = UDim2.new(1, 0, 0, 30)
    loading.Position = UDim2.new(0, 0, 1, -85)
    loading.BackgroundTransparency = 1
    loading.Font = Enum.Font.GothamBold
    loading.TextSize = 18
    loading.TextColor3 = Color3.fromRGB(255, 80, 80)

    task.spawn(function()
        while gui.Parent do
            loading.Text = "กำลังตรวจสอบ HWID."
            task.wait(0.25)
            loading.Text = "กำลังตรวจสอบ HWID.."
            task.wait(0.25)
            loading.Text = "กำลังตรวจสอบ HWID..."
            task.wait(0.25)
        end
    end)

    local copyBtn = Instance.new("TextButton", frame)
    copyBtn.Size = UDim2.new(0, 200, 0, 40)
    copyBtn.Position = UDim2.new(0.5, -100, 1, -45)
    copyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.TextSize = 16
    copyBtn.TextColor3 = Color3.new(1,1,1)
    copyBtn.Text = "คัดลอก HWID"
    Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 10)

    copyBtn.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(myHWID)
            copyBtn.Text = "คัดลอกแล้ว!"
            copyBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
        end
    end)
end

local function ShowExpireText3Sec(info)
    local gui = Instance.new("ScreenGui")
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 520, 0, 90)
    frame.Position = UDim2.new(0.5, -260, 0.5, -45)
    frame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 0.05

    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)

    local stroke = Instance.new("UIStroke", frame)
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(120, 255, 120)
    stroke.Transparency = 0.2

    local shadow = Instance.new("ImageLabel", frame)
    shadow.Image = "rbxassetid://1316045217"
    shadow.Size = UDim2.new(1, 40, 1, 40)
    shadow.Position = UDim2.new(0, -20, 0, -20)
    shadow.BackgroundTransparency = 1
    shadow.ImageTransparency = 0.7
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10,10,118,118)
    shadow.ZIndex = 0

    frame.ZIndex = 1

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -30, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 20
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.TextStrokeTransparency = 0.35
    label.TextColor3 = Color3.fromRGB(120, 255, 120)

    local expireText = "ถาวร"
    local remainText = "-"

    if (info.EXPIRE or 0) ~= 0 then
        expireText = os.date("%d/%m/%Y %H:%M:%S", info.EXPIRE)
        remainText = math.max(0, math.floor((info.EXPIRE - os.time()) / 86400)) .. " วัน"
    end

    label.Text =
        "✅ ผ่านการตรวจสอบ HWID\n" ..
        "หมดอายุ: "..expireText.."  |  คงเหลือ: "..remainText

    -- fade in
    frame.BackgroundTransparency = 1
    stroke.Transparency = 1
    label.TextTransparency = 1

    game:GetService("TweenService"):Create(
        frame,
        TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { BackgroundTransparency = 0.05 }
    ):Play()

    game:GetService("TweenService"):Create(
        stroke,
        TweenInfo.new(0.25),
        { Transparency = 0.2 }
    ):Play()

    game:GetService("TweenService"):Create(
        label,
        TweenInfo.new(0.25),
        { TextTransparency = 0 }
    ):Play()

    task.delay(3, function()
        game:GetService("TweenService"):Create(
            frame,
            TweenInfo.new(0.25),
            { BackgroundTransparency = 1 }
        ):Play()

        game:GetService("TweenService"):Create(
            stroke,
            TweenInfo.new(0.25),
            { Transparency = 1 }
        ):Play()

        game:GetService("TweenService"):Create(
            label,
            TweenInfo.new(0.25),
            { TextTransparency = 1 }
        ):Play()

        task.wait(0.3)
        gui:Destroy()
    end)
end

local ok, status, info = CheckHWID()
SendWebhook(status, info)

if not ok then
    ShowHWIDScreen()
    return
end

ShowExpireText3Sec(info)
task.wait(5)

