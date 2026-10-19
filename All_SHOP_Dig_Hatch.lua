-- All SHOP | Dig & Hatch compact controller
-- LocalScript/client executor. Game-specific remote paths and arguments may need configuration.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
if not player then return end
local pg = player:WaitForChild("PlayerGui")
local old = pg:FindFirstChild("AllSHOP_DigHatch")
if old then old:Destroy() end

local cfg = {dig=false,hatch=false,rebirth=false,egg="Basic Egg",digInterval=.35,hatchInterval=1.2,rebirthInterval=4}
local alive=true
local theme={bg=Color3.fromRGB(15,18,28),surface=Color3.fromRGB(24,29,43),surface2=Color3.fromRGB(33,39,56),accent=Color3.fromRGB(120,101,255),text=Color3.fromRGB(238,241,251),sub=Color3.fromRGB(149,159,184),good=Color3.fromRGB(86,213,152),bad=Color3.fromRGB(255,122,132)}
local function mk(class,props,parent)
    local obj=Instance.new(class)
    for k,v in pairs(props or {}) do obj[k]=v end
    obj.Parent=parent
    return obj
end
local function corner(o,r) mk("UICorner",{CornerRadius=UDim.new(0,r)},o) end
local function stroke(o,c,t) mk("UIStroke",{Color=c,Thickness=t or 1,Transparency=.45},o) end
local screen=mk("ScreenGui",{Name="AllSHOP_DigHatch",ResetOnSpawn=false,IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},pg)
local root=mk("Frame",{Name="Panel",Size=UDim2.fromOffset(340,410),Position=UDim2.new(.5,-170,.5,-205),BackgroundColor3=theme.bg,BorderSizePixel=0,Active=true},screen)
corner(root,16);stroke(root,Color3.fromRGB(81,91,121))
local scale=mk("UIScale",{Scale=1},root)
local cam=workspace.CurrentCamera
local function adapt()
  cam=workspace.CurrentCamera
  local v=cam and cam.ViewportSize or Vector2.new(800,600)
  scale.Scale=math.clamp(math.min(v.X/390,v.Y/490),.66,1)
end
adapt()
if cam then cam:GetPropertyChangedSignal("ViewportSize"):Connect(adapt) end
local header=mk("Frame",{Size=UDim2.new(1,0,0,64),BackgroundTransparency=1,Active=true},root)
mk("TextLabel",{Size=UDim2.new(1,-96,0,28),Position=UDim2.fromOffset(18,10),Text="ALL SHOP",TextXAlignment=Enum.TextXAlignment.Left,TextColor3=theme.text,TextSize=21,Font=Enum.Font.GothamBold,BackgroundTransparency=1},header)
mk("TextLabel",{Size=UDim2.new(1,-96,0,18),Position=UDim2.fromOffset(18,36),Text="DIG & HATCH  •  CONTROL",TextXAlignment=Enum.TextXAlignment.Left,TextColor3=theme.sub,TextSize=10,Font=Enum.Font.GothamMedium,BackgroundTransparency=1},header)
local minbtn=mk("TextButton",{Size=UDim2.fromOffset(31,31),Position=UDim2.new(1,-77,0,16),Text="−",Font=Enum.Font.GothamBold,TextSize=23,TextColor3=theme.text,BackgroundColor3=theme.surface2,BorderSizePixel=0},header);corner(minbtn,9)
local closebtn=mk("TextButton",{Size=UDim2.fromOffset(31,31),Position=UDim2.new(1,-40,0,16),Text="×",Font=Enum.Font.GothamBold,TextSize=22,TextColor3=theme.text,BackgroundColor3=theme.surface2,BorderSizePixel=0},header);corner(closebtn,9)
local content=mk("ScrollingFrame",{Position=UDim2.fromOffset(12,64),Size=UDim2.new(1,-24,1,-109),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=theme.accent,CanvasSize=UDim2.new()},root)
local layout=mk("UIListLayout",{Padding=UDim.new(0,9),SortOrder=Enum.SortOrder.LayoutOrder},content)
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()content.CanvasSize=UDim2.fromOffset(0,layout.AbsoluteContentSize.Y+8)end)
local function label(t)
 local f=mk("TextLabel",{Size=UDim2.new(1,0,0,20),Text=t,TextColor3=theme.sub,TextXAlignment=Enum.TextXAlignment.Left,TextSize=11,Font=Enum.Font.GothamBold,BackgroundTransparency=1},content)
 return f
end
local function toggle(title,desc,key)
 local f=mk("Frame",{Size=UDim2.new(1,0,0,61),BackgroundColor3=theme.surface,BorderSizePixel=0},content);corner(f,11)
 mk("TextLabel",{Position=UDim2.fromOffset(13,9),Size=UDim2.new(1,-80,0,23),Text=title,Font=Enum.Font.GothamSemibold,TextSize=13,TextColor3=theme.text,TextXAlignment=Enum.TextXAlignment.Left,BackgroundTransparency=1},f)
 mk("TextLabel",{Position=UDim2.fromOffset(13,31),Size=UDim2.new(1,-80,0,18),Text=desc,Font=Enum.Font.Gotham,TextSize=10,TextColor3=theme.sub,TextXAlignment=Enum.TextXAlignment.Left,BackgroundTransparency=1},f)
 local b=mk("TextButton",{Size=UDim2.fromOffset(44,25),Position=UDim2.new(1,-57,.5,-12),Text="",AutoButtonColor=false,BackgroundColor3=theme.surface2,BorderSizePixel=0},f);corner(b,14)
 local knob=mk("Frame",{Size=UDim2.fromOffset(19,19),Position=UDim2.fromOffset(3,3),BackgroundColor3=theme.text,BorderSizePixel=0},b);corner(knob,10)
 local function visual()
  TweenService:Create(b,TweenInfo.new(.15),{BackgroundColor3=cfg[key] and theme.accent or theme.surface2}):Play()
  TweenService:Create(knob,TweenInfo.new(.15),{Position=cfg[key] and UDim2.fromOffset(22,3) or UDim2.fromOffset(3,3)}):Play()
 end
 b.MouseButton1Click:Connect(function()cfg[key]=not cfg[key];visual()end)
 return f
end
local statusLabel
local function status(message,good)
 if statusLabel and statusLabel.Parent then
  statusLabel.Text=message
  statusLabel.TextColor3=good and theme.good or theme.sub
 end
end
local function inputRow(title,initial,callback)
 local f=mk("Frame",{Size=UDim2.new(1,0,0,68),BackgroundColor3=theme.surface,BorderSizePixel=0},content);corner(f,11)
 mk("TextLabel",{Position=UDim2.fromOffset(12,5),Size=UDim2.new(1,-24,0,19),Text=title,TextColor3=theme.sub,TextSize=11,Font=Enum.Font.GothamSemibold,TextXAlignment=Enum.TextXAlignment.Left,BackgroundTransparency=1},f)
 local box=mk("TextBox",{Position=UDim2.fromOffset(10,28),Size=UDim2.new(1,-20,0,31),BackgroundColor3=theme.surface2,TextColor3=theme.text,PlaceholderColor3=theme.sub,TextSize=12,Font=Enum.Font.Gotham,Text=initial,ClearTextOnFocus=false,BorderSizePixel=0},f);corner(box,8)
 box.FocusLost:Connect(function()callback(box.Text)end)
 return f
end
label("AUTOMATION")
toggle("Auto Dig", "Tool activation / detected dig remote", "dig")
toggle("Auto Hatch", "Open selected egg repeatedly", "hatch")
toggle("Auto Rebirth", "Rebirth at a limited rate", "rebirth")
label("HATCH SETTINGS")
inputRow("Egg name (must match game)",cfg.egg,function(value) if value~="" then cfg.egg=value end end)
label("STATUS")
local statusFrame=mk("Frame",{Size=UDim2.new(1,0,0,47),BackgroundColor3=theme.surface,BorderSizePixel=0},content);corner(statusFrame,11)
statusLabel=mk("TextLabel",{Position=UDim2.fromOffset(12,5),Size=UDim2.new(1,-24,1,-10),Text="Ready • waiting for action",TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,Font=Enum.Font.Gotham,TextSize=11,TextColor3=theme.sub,BackgroundTransparency=1},statusFrame)
local footer=mk("TextLabel",{Position=UDim2.new(0,12,1,-37),Size=UDim2.new(1,-24,0,29),BackgroundTransparency=1,Text="ALL SHOP  •  drag to move  •  Ctrl to hide",TextColor3=theme.sub,TextSize=10,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Center},root)
local collapsed=false
minbtn.MouseButton1Click:Connect(function()
 collapsed=not collapsed
 content.Visible=not collapsed;footer.Visible=not collapsed
 root.Size=collapsed and UDim2.fromOffset(340,64) or UDim2.fromOffset(340,410)
 minbtn.Text=collapsed and "+" or "−"
end)
local dragging,startPos,startInput
header.InputBegan:Connect(function(i)
 if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true;startInput=i.Position;startPos=root.Position end
end)
UserInputService.InputChanged:Connect(function(i)
 if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
  local d=i.Position-startInput;root.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
 end
end)
UserInputService.InputEnded:Connect(function(i)
 if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
end)
local keyboardConn=UserInputService.InputBegan:Connect(function(i,processed)
 if not processed and i.KeyCode==Enum.KeyCode.LeftControl then root.Visible=not root.Visible end
end)
closebtn.MouseButton1Click:Connect(function()alive=false;cfg.dig=false;cfg.hatch=false;cfg.rebirth=false;keyboardConn:Disconnect();screen:Destroy()end)

-- Game-specific resolution: never assume a found remote has a compatible payload.
-- Set exact names and arguments below after inspecting the game's authorized client code.
local REMOTE_NAMES={dig={"Dig","Mine","Click","DigEvent","MineEvent"},hatch={"Hatch","OpenEgg","BuyEgg","HatchEgg"},rebirth={"Rebirth","DoRebirth","RebirthEvent"}}
local function findRemote(names)
 for _,container in ipairs({ReplicatedStorage:FindFirstChild("Remotes"),ReplicatedStorage}) do
  if container then
   for _,name in ipairs(names) do
    local r=container:FindFirstChild(name,true)
    if r and (r:IsA("RemoteEvent") or r:IsA("RemoteFunction")) then return r end
   end
  end
 end
end
local function fire(remote,...)
 if not remote then return false,"remote not found" end
 local args=table.pack(...)
 local ok,err=pcall(function()
  if remote:IsA("RemoteEvent") then remote:FireServer(table.unpack(args,1,args.n))
  else remote:InvokeServer(table.unpack(args,1,args.n)) end
 end)
 return ok,err
end
local lastInfo={dig="",hatch="",rebirth=""}
local function action(kind)
 if kind=="dig" then
  local char=player.Character;local tool=char and char:FindFirstChildOfClass("Tool")
  if tool then
   local ok,err=pcall(function()tool:Activate()end)
   if ok then return true,"tool activated" end
   return false,tostring(err)
  end
  local remote=findRemote(REMOTE_NAMES.dig)
  if remote then
   local ok,err=fire(remote)
   return ok,ok and "dig request sent" or tostring(err)
  end
  return false,"equip a digging tool; no dig remote found"
 elseif kind=="hatch" then
  local remote=findRemote(REMOTE_NAMES.hatch)
  if not remote then return false,"hatch remote not found" end
  local ok,err=fire(remote,cfg.egg,1)
  return ok,ok and "hatch request sent" or tostring(err)
 else
  local remote=findRemote(REMOTE_NAMES.rebirth)
  if not remote then return false,"rebirth remote not found" end
  local ok,err=fire(remote)
  return ok,ok and "rebirth request sent" or tostring(err)
 end
end
local function runner(kind,interval)
 task.spawn(function()
  local lastStatus=0
  while alive and screen.Parent do
   if cfg[kind] then
    local ok,message=action(kind)
    if os.clock()-lastStatus>2 then
     status((kind:sub(1,1):upper()..kind:sub(2))..": "..message,ok)
     lastStatus=os.clock()
    end
    task.wait(interval)
   else task.wait(.15) end
  end
 end)
end
runner("dig",cfg.digInterval)
runner("hatch",cfg.hatchInterval)
runner("rebirth",cfg.rebirthInterval)
status("Ready • features depend on actual game remotes",true)
