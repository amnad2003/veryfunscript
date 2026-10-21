-- Feed A Mosquito - Smart Max (public-mechanics-based experimental build)
-- No unverified RemoteEvent calls; no Robux purchasing; uses world objects & prompts if exposed.
-- START/STOP + status. This is NOT a verified full auto farm.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local PathfindingService = game:GetService("PathfindingService")
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer
if not player then return end
local old = getgenv and getgenv().FeedAMosquitoSmartMax
if old and old.destroy then pcall(old.destroy) end
local active, dead, busy = false, false, false
local stats = { eggs=0, interactions=0, walked=0, errors=0, last="Ready", target="None", missing={} }
local config = {searchRadius=420, actionRange=10, safeHealth=.4, moveTimeout=16, minEggScore=1}
local connections={}
local function bind(s,fn) local c=s:Connect(fn); table.insert(connections,c); return c end
local function char() local c=player.Character; return c,c and c:FindFirstChildOfClass("Humanoid"),c and c:FindFirstChild("HumanoidRootPart") end
local function alive() local _,h,r=char(); return h and r and h.Health>0 and r end
local function setLast(msg) stats.last=msg end
local gui=Instance.new("ScreenGui")
gui.Name="MosquitoSmartMax"; gui.ResetOnSpawn=false
pcall(function() gui.Parent=game:GetService("CoreGui") end)
if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end
local panel=Instance.new("Frame",gui)
panel.Name="Panel"; panel.Size=UDim2.fromOffset(330,232); panel.Position=UDim2.new(0,15,.3,0)
panel.BackgroundColor3=Color3.fromRGB(17,23,34); panel.BorderSizePixel=0; panel.Active=true; panel.Draggable=true
Instance.new("UICorner",panel).CornerRadius=UDim.new(0,10)
local function txt(y,size,bold)
 local t=Instance.new("TextLabel",panel); t.Position=UDim2.fromOffset(12,y); t.Size=UDim2.new(1,-24,0,size+8)
 t.BackgroundTransparency=1; t.TextXAlignment=Enum.TextXAlignment.Left; t.Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham
 t.TextSize=size; t.TextColor3=Color3.fromRGB(232,238,248); t.TextWrapped=true; return t
end
local heading=txt(10,16,true); heading.Text="FEED A MOSQUITO  |  SMART MAX"
local subtitle=txt(36,11,false); subtitle.Text="Experimental • world-based automation"
local toggle=Instance.new("TextButton",panel); toggle.Position=UDim2.fromOffset(12,62); toggle.Size=UDim2.fromOffset(305,36)
toggle.Font=Enum.Font.GothamBold; toggle.TextSize=15; toggle.Text="START"; toggle.TextColor3=Color3.new(1,1,1)
toggle.BackgroundColor3=Color3.fromRGB(30,151,88); Instance.new("UICorner",toggle).CornerRadius=UDim.new(0,7)
local info=txt(110,12,false); info.Size=UDim2.new(1,-24,0,113); info.TextYAlignment=Enum.TextYAlignment.Top
local function refresh()
 toggle.Text=active and "STOP" or "START"; toggle.BackgroundColor3=active and Color3.fromRGB(190,65,65) or Color3.fromRGB(30,151,88)
 info.Text=string.format("Mode: %s\nTarget: %s\nActions: %d  |  Egg pickups attempted: %d\nMoves: %d  |  Errors: %d\nStatus: %s",active and "RUNNING" or "STOPPED",stats.target,stats.interactions,stats.eggs,stats.walked,stats.errors,stats.last)
end
bind(toggle.MouseButton1Click,function() active=not active; if not active then setLast("Stopped by user") else setLast("Scanning world") end; refresh() end)
local function named(obj,patterns)
 local s=string.lower(obj.Name)
 for _,p in ipairs(patterns) do if string.find(s,p,1,true) then return true end end
 return false
end
local eggWords={"egg","larva","larvae","drop","ไข่"}
local promptWords={"collect","pick","grab","take","hatch","place","feed","claim","cash","buy","upgrade","equip","เก็บ","ฟัก","ซื้อ"}
local forbid={"robux","gamepass","premium","product","developer product","r$"}
local rarity={common=1,uncommon=2,rare=3,epic=4,legendary=5,mythic=6,mythical=6,secret=7,divine=8,celestial=9}
local function posOf(x)
 if x:IsA("BasePart") then return x.Position end
 if x:IsA("Model") then local p=x.PrimaryPart or x:FindFirstChildWhichIsA("BasePart",true); return p and p.Position end
 if x:IsA("ProximityPrompt") then local p=x.Parent; if p and p:IsA("Attachment") then p=p.Parent end; if p and p:IsA("BasePart") then return p.Position end end
 return nil
end
local function scoreEgg(o,p)
 local s=string.lower(o.Name .. " " .. (o.Parent and o.Parent.Name or ""))
 local rank=0
 for label,n in pairs(rarity) do if string.find(s,label,1,true) then rank=math.max(rank,n) end end
 local scale=0
 local size=o:IsA("BasePart") and o.Size or nil
 if size then scale=math.max(size.X,size.Y,size.Z) end
 for _,attribute in ipairs({"Rarity","Tier","Size","Scale"}) do
  local v=o:GetAttribute(attribute)
  if type(v)=="number" then if attribute=="Size" or attribute=="Scale" then scale=math.max(scale,v) else rank=math.max(rank,v) end
  elseif type(v)=="string" then for label,n in pairs(rarity) do if string.find(v:lower(),label,1,true) then rank=math.max(rank,n) end end end
 end
 local root=alive(); local distance=root and (root.Position-p).Magnitude or 9999
 return rank*100000+scale*100-math.min(distance,9999)
end
local function findEgg()
 local best,bestScore=nil,-math.huge
 local root=alive(); if not root then return nil end
 for _,o in ipairs(workspace:GetDescendants()) do
  if (o:IsA("BasePart") or o:IsA("Model")) and named(o,eggWords) then
   local p=posOf(o)
   if p and (p-root.Position).Magnitude<config.searchRadius then
    local sc=scoreEgg(o,p)
    if sc>bestScore then best,bestScore=o,sc end
   end
  end
 end
 return best
end
local function getPrompts()
 local out={}
 local root=alive(); if not root then return out end
 for _,o in ipairs(workspace:GetDescendants()) do
  if o:IsA("ProximityPrompt") and o.Enabled then
   local p=posOf(o)
   if p and (p-root.Position).Magnitude<config.searchRadius then
    local words=(o.Name.." "..o.ActionText.." "..o.ObjectText.." "..o.Parent.Name):lower()
    local excluded=false
    for _,s in ipairs(forbid) do if words:find(s,1,true) then excluded=true end end
    if not excluded then
     for _,s in ipairs(promptWords) do if words:find(s,1,true) then table.insert(out,{prompt=o,pos=p,words=words}); break end end
    end
   end
  end
 end
 return out
end
local function moveTo(point)
 local _,hum,root=char(); if not hum or not root then return false end
 local start=os.clock(); stats.walked=stats.walked+1
 local ok,path=pcall(function()
  local path=PathfindingService:CreatePath({AgentRadius=2,AgentHeight=5,AgentCanJump=true})
  path:ComputeAsync(root.Position,point); return path
 end)
 local waypoints=ok and path.Status==Enum.PathStatus.Success and path:GetWaypoints() or { {Position=point} }
 for _,waypoint in ipairs(waypoints) do
  if not active or not alive() or os.clock()-start>config.moveTimeout then return false end
  if waypoint.Action==Enum.PathWaypointAction.Jump then hum.Jump=true end
  hum:MoveTo(waypoint.Position)
  local untilTime=os.clock()+math.min(5,config.moveTimeout)
  while active and alive() and (root.Position-waypoint.Position).Magnitude>5 and os.clock()<untilTime do task.wait(.12) end
  if (root.Position-waypoint.Position).Magnitude>7 then return false end
 end
 return true
end
local function doPrompt(prompt)
 if not prompt or not prompt.Parent or not prompt.Enabled then return false end
 if type(fireproximityprompt)=="function" then
  local ok=pcall(function() fireproximityprompt(prompt) end)
  if ok then stats.interactions=stats.interactions+1; return true end
 end
 setLast("Prompt detected; automatic triggering unavailable in this environment")
 stats.missing.promptTrigger=true
 return false
end
local function eggAction()
 local egg=findEgg(); if not egg then return false end
 local point=posOf(egg); if not point then return false end
 stats.target=egg.Name; setLast("Best visible egg: "..egg.Name); refresh()
 if not moveTo(point) then setLast("Cannot reach egg: "..egg.Name); return false end
 local best,bestDistance=nil,math.huge
 for _,item in ipairs(getPrompts()) do
  local distance=(item.pos-point).Magnitude
  if distance<bestDistance and distance<14 and (item.words:find("pick") or item.words:find("grab") or item.words:find("collect") or item.words:find("take")) then best=item.prompt; bestDistance=distance end
 end
 if best and doPrompt(best) then stats.eggs=stats.eggs+1; setLast("Egg pickup interaction attempted; inventory not verified"); return true end
 setLast("Egg found, but pickup method not identified"); stats.missing.pickup=true; return false
end
local function promptPriority(s)
 if s:find("hatch") or s:find("ฟัก") then return 95 end
 if s:find("place") then return 90 end
 if s:find("feed") then return 85 end
 if s:find("cash") or s:find("collect") or s:find("claim") then return 75 end
 if s:find("upgrade") then return 60 end
 if s:find("equip") then return 55 end
 if s:find("buy") or s:find("ซื้อ") then return 45 end
 return 10
end
local lastInteracted={}
local function otherAction()
 local choices=getPrompts(); local root=alive(); if not root then return false end
 table.sort(choices,function(a,b)
  local pa,pb=promptPriority(a.words),promptPriority(b.words)
  if pa~=pb then return pa>pb end
  return (root.Position-a.pos).Magnitude<(root.Position-b.pos).Magnitude
 end)
 for _,entry in ipairs(choices) do
  if not active then return false end
  if os.clock()-(lastInteracted[entry.prompt] or 0)>20 then
   stats.target=entry.prompt.ObjectText~="" and entry.prompt.ObjectText or entry.prompt.Name
   setLast("Attempting "..entry.prompt.ActionText); refresh()
   local moved=moveTo(entry.pos)
   lastInteracted[entry.prompt]=os.clock()
   if moved and doPrompt(entry.prompt) then
    setLast("Interaction attempted: "..entry.prompt.ActionText.." (not verified)")
    return true
   end
  end
 end
 return false
end
local function farmTick()
 if not active or busy or dead then return end
 busy=true
 local success,err=pcall(function()
  local _,hum=char()
  if not alive() then setLast("Waiting for respawn"); return end
  if hum.Health/hum.MaxHealth<config.safeHealth then
   setLast("Low health: waiting for recovery"); task.wait(2); return
  end
  if eggAction() then return end
  if otherAction() then return end
  stats.target="None"
  setLast("No supported actions detected; boss combat/game-specific actions need adapters")
  stats.missing.combat=true; stats.missing.hatch=true; stats.missing.feed=true; stats.missing.buy=true
 end)
 if not success then stats.errors=stats.errors+1; setLast("Error: "..tostring(err):sub(1,100)) end
 busy=false; refresh()
end
bind(player.CharacterAdded,function() setLast("Respawn detected; resuming if started") end)
-- AFK handling is client-dependent and does not guarantee server reconnection.
pcall(function() bind(player.Idled,function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end) end)
task.spawn(function() while not dead do if active then farmTick() end; refresh(); task.wait(1.5) end end)
local controller={}
function controller.destroy()
 dead=true; active=false
 for _,c in ipairs(connections) do pcall(function() c:Disconnect() end) end
 gui:Destroy()
end
if getgenv then getgenv().FeedAMosquitoSmartMax=controller end
refresh()
