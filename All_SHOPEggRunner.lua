-- ALL SHOP | Egg Runner V3 (Thai descriptions)
-- Client-side assist for Dig & Hatch Animals. Uses visible world objects and interactions.
-- Game-specific server actions are not public; no claim of guaranteed full automation.
local Players=game:GetService('Players')
local RunService=game:GetService('RunService')
local PathfindingService=game:GetService('PathfindingService')
local TweenService=game:GetService('TweenService')
local UIS=game:GetService('UserInputService')
local LP=Players.LocalPlayer
if not LP then return end
local PG=LP:WaitForChild('PlayerGui')
if _G.ALLSHOP_EGG_STOP then pcall(_G.ALLSHOP_EGG_STOP) end
local active=true
local config={auto=false,train=true,rebirth=false,walk=22,zone='All zones',egg='Any egg',range=180,cycle=.28}
local oldSpeed
local tracked={}
local color={base=Color3.fromRGB(15,19,31),panel=Color3.fromRGB(26,31,48),button=Color3.fromRGB(42,49,70),text=Color3.fromRGB(245,247,255),sub=Color3.fromRGB(162,173,199),accent=Color3.fromRGB(134,106,255),green=Color3.fromRGB(97,226,164),red=Color3.fromRGB(255,116,145)}
local function make(t,p,parent)
 local o=Instance.new(t)
 for k,v in pairs(p or {}) do o[k]=v end
 o.Parent=parent
 return o
end
local function round(x,n)make('UICorner',{CornerRadius=UDim.new(0,n or 9)},x)end
local gui=make('ScreenGui',{Name='ALLSHOP_EggRunnerV3',ResetOnSpawn=false,IgnoreGuiInset=false},PG)
local main=make('Frame',{Size=UDim2.fromOffset(336,405),Position=UDim2.new(.5,-168,.5,-202),BackgroundColor3=color.base,BorderSizePixel=0,Active=true},gui);round(main,15)
make('UIStroke',{Color=color.accent,Thickness=1,Transparency=.5},main)
local title=make('TextLabel',{Text='ALL SHOP   /   EGG RUNNER',Size=UDim2.new(1,-80,0,43),Position=UDim2.fromOffset(14,1),TextXAlignment=Enum.TextXAlignment.Left,TextSize=15,Font=Enum.Font.GothamBold,TextColor3=color.text,BackgroundTransparency=1},main)
local hide=make('TextButton',{Text='−',Size=UDim2.fromOffset(28,27),Position=UDim2.new(1,-66,0,9),BackgroundColor3=color.button,TextColor3=color.text,TextSize=20},main);round(hide)
local close=make('TextButton',{Text='×',Size=UDim2.fromOffset(28,27),Position=UDim2.new(1,-34,0,9),BackgroundColor3=color.button,TextColor3=color.text,TextSize=20},main);round(close)
local page=make('ScrollingFrame',{Position=UDim2.fromOffset(10,45),Size=UDim2.new(1,-20,1,-91),ScrollBarThickness=3,BackgroundTransparency=1,BorderSizePixel=0,CanvasSize=UDim2.fromOffset(0,0)},main)
local stack=make('UIListLayout',{Padding=UDim.new(0,7),SortOrder=Enum.SortOrder.LayoutOrder},page)
stack:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function() page.CanvasSize=UDim2.fromOffset(0,stack.AbsoluteContentSize.Y+10) end)
local info=make('TextLabel',{Text='Ready',Position=UDim2.new(0,12,1,-42),Size=UDim2.new(1,-24,0,34),TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=color.sub,TextSize=10,Font=Enum.Font.Gotham,BackgroundTransparency=1},main)
local function status(s,ok) if active then info.Text=tostring(s);info.TextColor3=ok and color.green or color.sub end end
local function label(s)
 return make('TextLabel',{Text=s,Size=UDim2.new(1,0,0,17),BackgroundTransparency=1,TextColor3=color.sub,TextSize=10,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left},page)
end
local function help(message)
 local line=make('TextLabel',{
  Text='↳  '..message,
  Size=UDim2.new(1,-6,0,22),AutomaticSize=Enum.AutomaticSize.Y,
  BackgroundTransparency=1,TextColor3=color.sub,
  Font=Enum.Font.SourceSans,TextSize=13,TextWrapped=true,
  TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top
 },page)
 return line
end
local function button(s,fn,h)
 local b=make('TextButton',{Text=s,Size=UDim2.new(1,0,0,h or 34),BackgroundColor3=color.button,TextColor3=color.text,Font=Enum.Font.GothamSemibold,TextSize=12,TextWrapped=true},page);round(b,8)
 b.MouseButton1Click:Connect(function()task.spawn(fn)end);return b
end
local function toggle(name,key)
 local b
 local function update() b.Text=(config[key] and '●  ' or '○  ')..name;b.BackgroundColor3=config[key] and color.accent or color.button end
 b=button('',function()config[key]=not config[key];update();status(name..(config[key] and ' enabled' or ' disabled'),true)end)
 update();return b
end
local function input(name,value,fn)
 label(name)
 local box=make('TextBox',{Text=tostring(value),PlaceholderText=name,ClearTextOnFocus=false,Size=UDim2.new(1,0,0,32),BackgroundColor3=color.panel,TextColor3=color.text,TextSize=12,Font=Enum.Font.Gotham,BorderSizePixel=0},page);round(box)
 box.FocusLost:Connect(function()fn(box.Text)end)
 return box
end
local function hrp()
 local ch=LP.Character
 local humanoid=ch and ch:FindFirstChildOfClass('Humanoid')
 local root=ch and ch:FindFirstChild('HumanoidRootPart')
 return root,humanoid,ch
end
local function primary(o)
 if o:IsA('BasePart') then return o end
 if o:IsA('Model') then return o.PrimaryPart or o:FindFirstChildWhichIsA('BasePart',true) end
 if o:IsA('ProximityPrompt') then return o.Parent and (o.Parent:IsA('BasePart') and o.Parent or o.Parent:FindFirstAncestorWhichIsA('Model') and primary(o.Parent:FindFirstAncestorWhichIsA('Model'))) end
end
local eggs,zones={},{}
local function inspect()
 table.clear(eggs);table.clear(zones)
 local seen={}
 for _,obj in ipairs(workspace:GetDescendants()) do
  if (obj:IsA('Model') or obj:IsA('BasePart')) and (obj.Name:lower():find('egg') or obj:GetAttribute('EggType')) then
   if not obj:FindFirstAncestorOfClass('Tool') and not (obj.Parent and obj.Parent:IsA('Model') and obj.Parent.Name:lower():find('egg')) then
    local part=primary(obj)
    if part and not obj:IsDescendantOf(LP.Character or LP) then
     local zone=obj:GetAttribute('Zone') or obj:GetAttribute('Stage') or obj:GetAttribute('World')
     if type(zone)~='string' then
      local ancestor=obj.Parent
      for i=1,4 do
       if not ancestor or ancestor==workspace then break end
       if ancestor.Name:lower():match('zone') or ancestor.Name:lower():match('stage') or ancestor.Name:lower():match('world') then zone=ancestor.Name;break end
       ancestor=ancestor.Parent
      end
     end
     zone=zone or 'Unclassified'
     local signature=obj:GetFullName()
     if not seen[signature] then seen[signature]=true;table.insert(eggs,{obj=obj,part=part,zone=tostring(zone),name=obj.Name});zones[tostring(zone)]=true end
    end
   end
  end
 end
 return #eggs
end
local function candidates()
 local r=hrp();if not r then return {} end
 local list={}
 for _,e in ipairs(eggs) do
  if e.part.Parent and (config.zone=='All zones' or config.zone==e.zone) and (config.egg=='Any egg' or config.egg==e.name) then
   local d=(e.part.Position-r.Position).Magnitude
   if d<config.range then table.insert(list,{item=e,distance=d}) end
  end
 end
 table.sort(list,function(a,b)return a.distance<b.distance end)
 return list
end
local function travel(pos)
 local root,hum=hrp();if not root or not hum or hum.Health<=0 then return false,'No living character' end
 local start=os.clock()
 local path=PathfindingService:CreatePath({AgentRadius=2,AgentHeight=5,AgentCanJump=true,WaypointSpacing=4})
 local ok=pcall(function()path:ComputeAsync(root.Position,pos)end)
 local steps=ok and path.Status==Enum.PathStatus.Success and path:GetWaypoints() or {{Position=pos}}
 for _,point in ipairs(steps) do
  if not active or not config.auto then return false,'Stopped' end
  root,hum=hrp();if not root or not hum then return false,'Character lost' end
  if point.Action==Enum.PathWaypointAction.Jump then hum.Jump=true end
  hum:MoveTo(point.Position)
  local deadline=os.clock()+math.max(3,(root.Position-point.Position).Magnitude/math.max(hum.WalkSpeed,1)*2+2)
  repeat
   task.wait(.12)
   if not active or not config.auto then return false,'Stopped' end
   root,hum=hrp();if not root or not hum then return false,'Character lost' end
  until (root.Position-point.Position).Magnitude<3.8 or os.clock()>deadline
  if os.clock()>deadline then return false,'Walk path blocked' end
  if os.clock()-start>45 then return false,'Travel timeout' end
 end
 return true
end
local function interact(target)
 local prompt=target:FindFirstChildWhichIsA('ProximityPrompt',true)
 if prompt and prompt.Enabled then
  if type(fireproximityprompt)=='function' then
   local ok=pcall(fireproximityprompt,prompt);return ok,ok and 'Prompt fired' or 'Prompt failed'
  end
  return false,'At prompt: press '..tostring(prompt.KeyboardKeyCode)..' manually'
 end
 return false,'No usable prompt on object'
end
local function carriesEgg()
 local char=LP.Character
 if not char then return false end
 for _,v in ipairs(char:GetDescendants()) do
  if (v:IsA('Tool') or v:IsA('Model')) and v.Name:lower():find('egg') then return true end
 end
 for _,name in ipairs({'CarryingEgg','HasEgg','HoldingEgg'}) do if LP:GetAttribute(name)==true or char:GetAttribute(name)==true then return true end end
 return false
end
local function findHome()
 local root=hrp();if not root then return end
 local best,dist
 for _,v in ipairs(workspace:GetDescendants()) do
  if (v:IsA('Model') or v:IsA('BasePart')) and v.Name:lower():match('farm') or (v:IsA('Model') and v.Name:lower():match('plot')) then
   local p=primary(v)
   if p and (not dist or (root.Position-p.Position).Magnitude<dist) then best=v;dist=(root.Position-p.Position).Magnitude end
  end
 end
 return best
end
local homeOverride=nil
label('AUTO FARM')
help('เลือกด่านและชนิดไข่ด้านล่างก่อน แล้วเปิดเดินเก็บไข่อัตโนมัติเพื่อเริ่มทำงาน')
toggle('Auto Walk & Collect Eggs','auto')
help('เดินไปหาไข่ที่เลือก พยายามเก็บไข่ แล้วเดินกลับบ้านเมื่อถือไข่ โดยไม่วาร์ป')
toggle('Dig While Walking','train')
help('ใช้เครื่องมือขุดที่สวมอยู่ระหว่างเดินอัตโนมัติ ต้องถืออุปกรณ์ขุดก่อนใช้งาน')
toggle('Auto Rebirth','rebirth')
help('ส่งคำสั่งรีเบิร์ธทุก 6 วินาที จะสำเร็จเมื่อถึงเงื่อนไขที่เกมกำหนด')
local zoneBtn,eggBtn
local function options()
 local zs={'All zones'};for z in pairs(zones) do table.insert(zs,z) end;table.sort(zs,function(a,b)if a=='All zones' then return true elseif b=='All zones' then return false end return a<b end)
 local es={'Any egg'};local names={};for _,e in ipairs(eggs) do if (config.zone=='All zones' or e.zone==config.zone) then names[e.name]=true end end
 for name in pairs(names) do table.insert(es,name) end;table.sort(es,function(a,b)if a=='Any egg' then return true elseif b=='Any egg' then return false end return a<b end)
 return zs,es
end
local function choose(btn,arr,current,cb)
 local idx=table.find(arr,current) or 0
 local item=arr[idx%#arr+1]
 cb(item);btn.Text=btn==zoneBtn and 'Zone: '..item or 'Egg: '..item
end
label('EGG & ZONE SELECTION')
help('กดปุ่มเพื่อเปลี่ยนตัวเลือกจากสิ่งที่พบในแผนที่ เลือกด่านก่อน แล้วค่อยเลือกชนิดไข่')
zoneBtn=button('Zone: All zones',function()
 local zs=options();choose(zoneBtn,zs,config.zone,function(z)config.zone=z;config.egg='Any egg';eggBtn.Text='Egg: Any egg' end)
end)
eggBtn=button('Egg: Any egg',function()
 local _,es=options();choose(eggBtn,es,config.egg,function(e)config.egg=e end)
end)
help('Any egg คือเลือกไข่ใกล้ที่สุดที่ตรงเงื่อนไข หากเลือกชื่อไข่ จะหาเฉพาะไข่ชื่อนั้น')
button('Scan Map / Refresh Egg List',function()
 local count=inspect();local z=0;for _ in pairs(zones) do z=z+1 end
 status(('Found %d egg objects / %d groups'):format(count,z),count>0)
end)
help('สแกนหาไข่ใหม่จากวัตถุที่โหลดแล้ว ไข่นอกระยะโหลดของเกมอาจไม่แสดง')
label('MOVEMENT SETTINGS')
input('Walking Speed (16–45)',config.walk,function(s)
 config.walk=math.clamp(tonumber(s) or 22,16,45)
 local _,hum=hrp();if hum then hum.WalkSpeed=config.walk end
 status('WalkSpeed '..config.walk,true)
end)
help('ใส่ความเร็วที่ต้องการแล้วกด Enter เกมอาจจำกัดหรือปรับความเร็วกลับเอง')
input('Egg Search Radius (studs)',config.range,function(s)config.range=math.clamp(tonumber(s) or 180,30,1500)end)
help('กำหนดระยะค้นหาไข่ หน่วยเป็น studs ค่ายิ่งสูงยิ่งค้นหาได้ไกล')
label('HOME & RETURN')
button('Save Current Position as Home',function()
 local root=hrp();if root then homeOverride=root.Position;status('Home position recorded',true) end
end)
help('ยืนที่บ้านของตัวเองแล้วกด เพื่อบันทึกจุดเดินกลับสำหรับการเล่นรอบนี้')
button('Walk Back Home',function()
 local root=hrp();local home=findHome();local part=home and primary(home);local p=homeOverride or part and part.Position
 if not p then status('Home not found: stand at home and save position');return end
 local was=config.auto;config.auto=true
 local ok,msg=travel(p);config.auto=was
 status(ok and 'Reached home' or msg,ok)
end)
help('เดินกลับตำแหน่งบ้านที่บันทึกไว้ ไม่วาร์ป และยังไม่รับประกันว่าจะวางไข่ได้อัตโนมัติ')
label('STATUS & LIMITATIONS')
help('การเก็บไข่ ฟักไข่ วางสัตว์เข้าบ้าน และอัปเกรด ยังขึ้นอยู่กับระบบเฉพาะของเกม สคริปต์นี้ยังตรวจยืนยันผลจริงไม่ได้')
help('ดูแถบสถานะด้านล่างเพื่อตรวจว่าระบบกำลังทำงานขั้นตอนไหน')
local folded=false
hide.MouseButton1Click:Connect(function()folded=not folded;page.Visible=not folded;info.Visible=not folded;main.Size=folded and UDim2.fromOffset(336,44) or UDim2.fromOffset(336,405);hide.Text=folded and '+' or '−' end)
local dragging,last,start
main.InputBegan:Connect(function(input)if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=true;last=input.Position;start=main.Position end end)
UIS.InputChanged:Connect(function(input)if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then local d=input.Position-last;main.Position=UDim2.new(start.X.Scale,start.X.Offset+d.X,start.Y.Scale,start.Y.Offset+d.Y) end end)
UIS.InputEnded:Connect(function(input)if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
local function stop()
 active=false;config.auto=false;config.train=false;config.rebirth=false
 local _,hum=hrp();if hum and oldSpeed then hum.WalkSpeed=oldSpeed end
 if gui then gui:Destroy() end
end
_G.ALLSHOP_EGG_STOP=stop
close.MouseButton1Click:Connect(stop)
local reloading=false
LP.CharacterAdded:Connect(function()task.wait(1);local _,hum=hrp();if hum then oldSpeed=hum.WalkSpeed;hum.WalkSpeed=config.walk end end)
local _,hum=hrp();if hum then oldSpeed=hum.WalkSpeed;hum.WalkSpeed=config.walk end
local function train()
 if not config.train then return end
 local _,_,ch=hrp();local tool=ch and ch:FindFirstChildOfClass('Tool')
 if tool then pcall(function()tool:Activate()end) end
end
local function nearEgg(e)
 local root=hrp();return root and e.part.Parent and (root.Position-e.part.Position).Magnitude<12
end
inspect()
task.spawn(function()
 local lastScan=0
 while active do
  task.wait(.26)
  if config.auto then
   local root,h=hrp();if not root or not h or h.Health<=0 then status('Waiting for character');continue end
   h.WalkSpeed=config.walk
   if os.clock()-lastScan>4 then inspect();lastScan=os.clock() end
   if carriesEgg() then
    local home=findHome();local part=home and primary(home)
    local destination=homeOverride or part and part.Position
    if destination then
     status('Carrying egg: walking home...',true)
     local ok,msg=travel(destination)
     if ok then
      if home then local worked,detail=interact(home);status(worked and 'Home prompt requested — check hatch' or 'At home: '..detail,worked) else status('At saved home: use game hatch interaction') end
     else status(msg) end
    else status('Holding egg: save home position once') end
   else
    local list=candidates()
    if #list==0 then status('No matching eggs. Tap Scan or change zone / range')
    else
     local target=list[1].item
     status(('Walking to %s [%s]'):format(target.name,target.zone),true)
     local ok,msg=travel(target.part.Position)
     if ok and nearEgg(target) then
      local worked,detail=interact(target.obj)
      status(worked and 'Pickup prompt sent; checking server result' or detail,worked)
      task.wait(1.5)
     else status(msg or 'Egg moved') end
    end
   end
  end
 end
end)
task.spawn(function()while active do if config.auto then train() end;task.wait(.35) end end)
-- Keep the previously working Rebirth fallback, but do not flood the server.
local RS=game:GetService('ReplicatedStorage')
local function doRebirth()
 local folders={RS:FindFirstChild('Remotes'),RS}
 for _,folder in ipairs(folders) do
  if folder then
   for _,name in ipairs({'Rebirth','DoRebirth','RebirthEvent'}) do
    local r=folder:FindFirstChild(name,true)
    if r and (r:IsA('RemoteEvent') or r:IsA('RemoteFunction')) then
     local ok=pcall(function()if r:IsA('RemoteEvent') then r:FireServer() else r:InvokeServer() end end)
     return ok
    end
   end
  end
 end
 return false
end
task.spawn(function()while active do
 if config.rebirth then local ok=doRebirth();status(ok and 'Rebirth request sent' or 'Rebirth remote not found',ok) end
 task.wait(6)
end end)
status(('Ready: %d candidate egg objects. Configure zone and home.'):format(#eggs),true)
