--[[
ARCTIC SNIPER — OXIDE-INSPIRED SINGLE PANEL
Local/demo interface only. This script does not read live game banners,
redeem codes, hide players, detect spawns, or send Discord messages.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
if not player then return end
local pg = player:WaitForChild("PlayerGui")
local old = pg:FindFirstChild("ArcticSniperV2")
if old then old:Destroy() end

local C = {
 BG=Color3.fromRGB(5,10,18), PANEL=Color3.fromRGB(11,20,32),
 ROW=Color3.fromRGB(17,32,48), HOVER=Color3.fromRGB(25,46,65),
 BLUE=Color3.fromRGB(105,205,255), DARK=Color3.fromRGB(31,91,128),
 PALE=Color3.fromRGB(190,237,255), WHITE=Color3.fromRGB(242,250,255),
 MUTED=Color3.fromRGB(139,170,192), GREEN=Color3.fromRGB(126,238,205),
 BORDER=Color3.fromRGB(55,108,139)
}
local prefs = {scan=true, autoScope=false, spam=false, hideUser=false, auto=3, scale=100}
local pieces, lastPieceAt = {}, 0
local IDLE_RESET_SECONDS = 4
local logs = {}

local function make(class, props, parent)
 local o=Instance.new(class)
 for k,v in pairs(props or {}) do o[k]=v end
 o.Parent=parent
 return o
end
local function corner(o,r) make("UICorner",{CornerRadius=UDim.new(0,r or 9)},o) end
local function stroke(o,c,t) make("UIStroke",{Color=c or C.BORDER,Thickness=t or 1,Transparency=.15},o) end
local function label(parent,txt,size,pos,fs,color,center)
 return make("TextLabel",{BackgroundTransparency=1,Text=txt or "",Size=size,Position=pos,
  Font=Enum.Font.Gotham,TextSize=fs or 11,TextColor3=color or C.WHITE,
  TextXAlignment=center and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left,
  TextYAlignment=Enum.TextYAlignment.Center,TextWrapped=true},parent)
end
local function button(parent,txt,size,pos,fn,bg)
 local b=make("TextButton",{Size=size,Position=pos,BackgroundColor3=bg or C.ROW,
  BorderSizePixel=0,Text=txt,TextColor3=C.WHITE,TextSize=11,
  Font=Enum.Font.GothamSemibold,AutoButtonColor=false},parent)
 corner(b,8); stroke(b)
 b.MouseEnter:Connect(function() TweenService:Create(b,TweenInfo.new(.12),{BackgroundColor3=C.HOVER}):Play() end)
 b.MouseLeave:Connect(function() TweenService:Create(b,TweenInfo.new(.12),{BackgroundColor3=bg or C.ROW}):Play() end)
 b.Activated:Connect(function() if fn then fn() end end)
 return b
end
local function log(msg)
 table.insert(logs,1,os.date("%H:%M:%S").." • "..msg)
 if #logs>30 then table.remove(logs) end
end

local gui=make("ScreenGui",{Name="ArcticSniperV2",ResetOnSpawn=false,IgnoreGuiInset=true,
 DisplayOrder=999,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},pg)
local main=make("Frame",{Name="Main",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),
 Size=UDim2.fromOffset(390,600),BackgroundColor3=C.BG,BorderSizePixel=0,Active=true},gui)
corner(main,15); stroke(main,C.BORDER,1.3)
local scale=make("UIScale",{Scale=1},main)
local function resize()
 local cam=workspace.CurrentCamera
 if cam then local v=cam.ViewportSize; scale.Scale=math.clamp(math.min((v.X-20)/390,(v.Y-24)/600,prefs.scale/100),.45,1) end
end
resize()
if workspace.CurrentCamera then workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize) end

local header=make("Frame",{Name="Header",Size=UDim2.new(1,0,0,58),BackgroundColor3=C.PANEL,BorderSizePixel=0,Active=true},main)
corner(header,15)
make("Frame",{Size=UDim2.new(1,0,0,16),Position=UDim2.new(0,0,1,-16),BackgroundColor3=C.PANEL,BorderSizePixel=0},header)
local logo=make("Frame",{Size=UDim2.fromOffset(30,30),Position=UDim2.fromOffset(12,13),BackgroundColor3=C.DARK,BorderSizePixel=0},header)
corner(logo,10); stroke(logo,C.BLUE)
label(logo,"A",UDim2.fromScale(1,1),UDim2.new(),19,C.PALE,true)
label(header,"ARCTIC SNIPER",UDim2.new(0,205,0,22),UDim2.fromOffset(52,7),13,C.WHITE)
label(header,"FROST EDITION  /  DEMO",UDim2.new(0,205,0,14),UDim2.fromOffset(53,30),8,C.MUTED)
local dot=make("Frame",{Size=UDim2.fromOffset(7,7),Position=UDim2.new(1,-99,0,25),BackgroundColor3=C.GREEN,BorderSizePixel=0},header)
corner(dot,9)
button(header,"—",UDim2.fromOffset(25,25),UDim2.new(1,-59,0,14),function() main.Visible=false; mini.Visible=true end,C.ROW)
local close=button(header,"×",UDim2.fromOffset(25,25),UDim2.new(1,-30,0,14),function() gui:Destroy() end,C.DARK)
close.TextSize=17; close.TextColor3=C.PALE

do
 local dragging=false; local startPoint; local startPos; local kind
 header.InputBegan:Connect(function(i)
  if i.UserInputType==Enum.UserInputType.Touch then dragging=true; kind="touch"; startPoint=i.Position; startPos=main.Position
  elseif i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; kind="mouse"; startPoint=i.Position; startPos=main.Position end
 end)
 UIS.InputChanged:Connect(function(i)
  if not dragging then return end
  local moved=(kind=="touch" and i.UserInputType==Enum.UserInputType.Touch) or (kind=="mouse" and i.UserInputType==Enum.UserInputType.MouseMovement)
  if moved then local d=i.Position-startPoint; main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y) end
 end)
 UIS.InputEnded:Connect(function(i)
  if (kind=="touch" and i.UserInputType==Enum.UserInputType.Touch) or (kind=="mouse" and i.UserInputType==Enum.UserInputType.MouseButton1) then dragging=false; kind=nil end
 end)
end
local mini=button(gui,"❄  AS",UDim2.fromOffset(76,38),UDim2.new(0,14,.5,-19),function() main.Visible=true; mini.Visible=false end,C.PANEL)
mini.Visible=false; stroke(mini,C.BLUE)

local content=make("ScrollingFrame",{Name="Content",Size=UDim2.new(1,-14,1,-66),Position=UDim2.fromOffset(7,61),
 BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=C.BLUE,
 CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y},main)
make("UIListLayout",{Padding=UDim.new(0,7),SortOrder=Enum.SortOrder.LayoutOrder},content)
make("UIPadding",{PaddingTop=UDim.new(0,2),PaddingBottom=UDim.new(0,10),PaddingLeft=UDim.new(0,2),PaddingRight=UDim.new(0,5)},content)

local function card(title, height)
 local f=make("Frame",{Size=UDim2.new(1,-3,0,height),BackgroundColor3=C.PANEL,BorderSizePixel=0},content)
 corner(f,10); stroke(f)
 label(f,title,UDim2.new(1,-18,0,20),UDim2.fromOffset(9,4),10,C.MUTED)
 return f
end
local codeCard=card("SNIPED CODE",82)
local combined=label(codeCard,"—",UDim2.new(1,-100,0,36),UDim2.fromOffset(10,27),22,C.PALE)
combined.TextTruncate=Enum.TextTruncate.AtEnd
local codeReset=button(codeCard,"RESET",UDim2.fromOffset(65,27),UDim2.new(1,-75,0,31),function()
 table.clear(pieces); combined.Text="—"; log("Code display reset")
end,C.DARK)

local statusCard=card("SCANNER STATUS",55)
local status=label(statusCard,"Ready • local text input only",UDim2.new(1,-18,0,20),UDim2.fromOffset(9,27),9,C.GREEN)

local function toggle(title, sub, key)
 local r=make("Frame",{Size=UDim2.new(1,-3,0,48),BackgroundColor3=C.ROW,BorderSizePixel=0},content)
 corner(r,9); stroke(r)
 label(r,title,UDim2.new(1,-82,0,19),UDim2.fromOffset(10,5),10,C.WHITE)
 label(r,sub,UDim2.new(1,-82,0,14),UDim2.fromOffset(10,25),8,C.MUTED)
 local on=prefs[key]==true
 local track=make("TextButton",{Size=UDim2.fromOffset(43,23),Position=UDim2.new(1,-53,.5,-11),BackgroundColor3=on and C.BLUE or C.PANEL,BorderSizePixel=0,Text="",AutoButtonColor=false},r)
 corner(track,20)
 local knob=make("Frame",{Size=UDim2.fromOffset(15,15),Position=on and UDim2.new(1,-19,.5,-7) or UDim2.fromOffset(4,4),BackgroundColor3=C.WHITE,BorderSizePixel=0},track); corner(knob,10)
 track.Activated:Connect(function()
  on=not on; prefs[key]=on; track.BackgroundColor3=on and C.BLUE or C.PANEL
  TweenService:Create(knob,TweenInfo.new(.12),{Position=on and UDim2.new(1,-19,.5,-7) or UDim2.fromOffset(4,4)}):Play()
  log(title.." set to "..(on and "ON" or "OFF"))
  if key=="scan" then status.Text=on and "Ready • local text input only" or "Scanner toggle is OFF"; status.TextColor3=on and C.GREEN or C.PALE end
  if key=="spam" then status.Text=on and "Spam Redeem ON • preview only" or "Ready • local text input only" end
 end)
end
toggle("Scan Announcements","Local test input only; no live banner reading","scan")
toggle("Auto Scope","Visual preference only","autoScope")
toggle("Spam Redeem","Preview preference only; no codes are redeemed","spam")
toggle("Hide User","Visual preference only","hideUser")

local threshold=card("AUTO SUBMIT  /  PIECES NEEDED",58)
local thresholdText=label(threshold,tostring(prefs.auto),UDim2.new(0,54,0,28),UDim2.new(.5,-27,0,25),13,C.PALE,true)
button(threshold,"−",UDim2.fromOffset(28,26),UDim2.new(.5,-65,0,26),function()
 prefs.auto=math.max(1,prefs.auto-1); thresholdText.Text=tostring(prefs.auto)
 log("Auto Submit threshold set to "..prefs.auto)
end,C.DARK)
button(threshold,"+",UDim2.fromOffset(28,26),UDim2.new(.5,37,0,26),function()
 prefs.auto=math.min(5,prefs.auto+1); thresholdText.Text=tostring(prefs.auto)
 log("Auto Submit threshold set to "..prefs.auto)
end,C.DARK)

local inputCard=card("LOCAL CODE-PIECE TEST",107)
local box=make("TextBox",{Size=UDim2.new(1,-18,0,32),Position=UDim2.fromOffset(9,26),BackgroundColor3=C.BG,BorderSizePixel=0,
 Text="",PlaceholderText="Paste a phrase or enter one piece...",PlaceholderColor3=C.MUTED,TextColor3=C.WHITE,
 TextSize=11,Font=Enum.Font.Gotham,ClearTextOnFocus=false,TextXAlignment=Enum.TextXAlignment.Left},inputCard)
corner(box,8); stroke(box); make("UIPadding",{PaddingLeft=UDim.new(0,9),PaddingRight=UDim.new(0,7)},box)
local function extractPiece(text)
 local piece=string.match(text,"[Uu][Ss][Ee]%s+[Cc][Oo][Dd][Ee]%s+([%w_%-]+)") or string.match(text,"[Cc][Oo][Dd][Ee]%s+[Ii][Ss]%s+([%w_%-]+)")
 if piece then return piece end
 local trimmed=string.gsub(text,"^%s*(.-)%s*$","%1")
 if trimmed~="" and not string.find(trimmed,"%s") then return trimmed end
 return nil
end
button(inputCard,"ADD PIECE",UDim2.new(.5,-13,0,28),UDim2.new(0,9,0,67),function()
 if not prefs.scan then status.Text="Turn Scan Announcements ON first"; status.TextColor3=C.PALE; return end
 if box.Text=="" then status.Text="Enter a phrase or piece first"; status.TextColor3=C.PALE; return end
 local piece=extractPiece(box.Text)
 if not piece then status.Text="Could not find one code piece"; status.TextColor3=C.MUTED; return end
 local now=os.clock(); if now-lastPieceAt>IDLE_RESET_SECONDS then table.clear(pieces) end; lastPieceAt=now
 table.insert(pieces,piece)
 status.Text="Piece added: "..piece.."  ("..#pieces.."/"..prefs.auto..")"; status.TextColor3=C.GREEN
 log("Local piece added: "..piece)
 if #pieces>=prefs.auto then
  combined.Text=table.concat(pieces,""); status.Text="Threshold reached • preview only"; status.TextColor3=C.GREEN
  log("Combined local preview created; no redemption")
  table.clear(pieces)
 end
end,C.DARK)
button(inputCard,"CLEAR",UDim2.new(.5,-13,0,28),UDim2.new(.5,4,0,67),function()
 box.Text=""; table.clear(pieces); status.Text="Code pieces cleared"; status.TextColor3=C.MUTED; log("Code pieces cleared")
end,C.BLUE)

local scaleCard=card("UI SCALE",57)
local scaleText=label(scaleCard,"100%",UDim2.new(0,50,0,22),UDim2.new(1,-59,0,25),10,C.PALE,true)
local slider=make("Frame",{Size=UDim2.new(1,-78,0,6),Position=UDim2.fromOffset(10,34),BackgroundColor3=C.ROW,BorderSizePixel=0},scaleCard); corner(slider,6)
local fill=make("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=C.BLUE,BorderSizePixel=0},slider); corner(fill,6)
local knob=make("TextButton",{Size=UDim2.fromOffset(14,14),Position=UDim2.new(1,-7,.5,-7),BackgroundColor3=C.WHITE,BorderSizePixel=0,Text="",AutoButtonColor=false},slider); corner(knob,8)
local sliding=false
local function setScaleFromX(x)
 local a=math.clamp((x-slider.AbsolutePosition.X)/slider.AbsoluteSize.X,.6,1)
 prefs.scale=math.floor(a*100+0.5); fill.Size=UDim2.new(a,0,1,0); knob.Position=UDim2.new(a,-7,.5,-7); scaleText.Text=prefs.scale.."%"
 scale.Scale=a; log("UI scale set to "..prefs.scale.."%")
end
knob.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sliding=true end end)
UIS.InputChanged:Connect(function(i) if sliding and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then setScaleFromX(i.Position.X) end end)
UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sliding=false end end)
slider.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then setScaleFromX(i.Position.X) end end)

local actions=card("QUICK ACTIONS",43)
button(actions,"FEEDBACK",UDim2.new(.33,-8,0,25),UDim2.fromOffset(8,14),function() status.Text="Feedback: demo UI only"; status.TextColor3=C.PALE; log("Feedback button pressed") end,C.DARK)
button(actions,"CLEAR BOX",UDim2.new(.33,-8,0,25),UDim2.new(.335,0,0,14),function() box.Text=""; status.Text="Input box cleared"; log("Input box cleared") end,C.DARK)
button(actions,"RESET",UDim2.new(.33,-8,0,25),UDim2.new(.67,-1,0,14),function()
 prefs.scan=true; prefs.autoScope=false; prefs.spam=false; prefs.hideUser=false; prefs.auto=3; prefs.scale=100
 status.Text="Reset requested • reload UI to reset all toggles"; status.TextColor3=C.PALE
 thresholdText.Text="3"; scaleText.Text="100%"; scale.Scale=1; fill.Size=UDim2.new(1,0,1,0); knob.Position=UDim2.new(1,-7,.5,-7)
 table.clear(pieces); combined.Text="—"; log("Reset pressed")
end,C.BLUE)

local footer=label(main,"LOCAL DEMO • NO LIVE GAME CONNECTION",UDim2.new(1,-18,0,13),UDim2.new(0,9,1,-15),7,C.MUTED,true)

task.spawn(function()
 while gui.Parent do
  local flake=make("TextLabel",{BackgroundTransparency=1,Text="✦",TextColor3=C.PALE,TextTransparency=.7,TextSize=math.random(8,13),Font=Enum.Font.Gotham,
   Size=UDim2.fromOffset(18,18),Position=UDim2.new(math.random(5,95)/100,0,-.05,0),ZIndex=10},main)
  local tw=TweenService:Create(flake,TweenInfo.new(math.random(5,8),Enum.EasingStyle.Linear),{Position=UDim2.new(flake.Position.X.Scale+math.random(-6,6)/100,0,1.08,0),TextTransparency=1})
  tw:Play(); tw.Completed:Connect(function() if flake.Parent then flake:Destroy() end end)
  task.wait(.65)
 end
end)
log("Arctic Sniper single-panel UI loaded")
