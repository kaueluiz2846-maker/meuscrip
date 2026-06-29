lua
local P,T,U,R,C=game:GetService("Players"),game:GetService("TweenService"),game:GetService("UserInputService"),game:GetService("RunService"),workspace.CurrentCamera
local lp=P.LocalPlayer
local pg=lp:WaitForChild("PlayerGui")
local sg=Instance.new("ScreenGui",pg)
sg.Name="MenuK"

local dragObj,dragStart,startPos,isDragging

local function makeDraggable(frame,onClick)
    frame.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            dragObj=frame
            startPos=frame.Position
            dragStart=U:GetMouseLocation()
            isDragging=false
            i.Changed:Connect(function()
                if i.UserInputState==Enum.UserInputState.End then
                    dragObj=nil
                    if not isDragging and onClick then onClick() end
                end
            end)
        end
    end)
    U.InputChanged:Connect(function(i)
        if dragObj==frame and i.UserInputType==Enum.UserInputType.MouseMovement then
            local d=U:GetMouseLocation()-dragStart
            if math.abs(d.X)>3 or math.abs(d.Y)>3 then isDragging=true end
            if isDragging then
                frame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
            end
        end
    end)
end

local function showError(msg)
    local e=Instance.new("TextButton",sg)
    e.Size=UDim2.new(0.3,0,0.07,0)
    e.Position=UDim2.new(0.35,0,0.08,0)
    e.BackgroundColor3=Color3.fromRGB(15,15,15)
    e.Text=msg
    e.TextColor3=Color3.fromRGB(255,60,60)
    e.Font=Enum.Font.GothamBold
    e.TextScaled=true
    e.AutoButtonColor=false
    e.BorderSizePixel=0
    local c=Instance.new("UICorner",e)
    c.CornerRadius=UDim.new(0,8)
    local s=Instance.new("UIStroke",e)
    s.Color=Color3.fromRGB(255,0,0)
    s.Thickness=2
    spawn(function()wait(2)e:Destroy()end)
end

local login=Instance.new("TextButton",sg)
login.Size=UDim2.new(0.2,0,0.22,0)
login.Position=UDim2.new(0.4,0,0.4,0)
login.BackgroundColor3=Color3.fromRGB(10,10,10)
login.BackgroundTransparency=0.1
login.Text=""
login.AutoButtonColor=false
login.BorderSizePixel=0
local lc=Instance.new("UICorner",login)
lc.CornerRadius=UDim.new(0,14)
local ls=Instance.new("UIStroke",login)
ls.Color=Color3.fromRGB(255,20,80)
ls.Thickness=2.5
local title=Instance.new("TextLabel",login)
title.Text="🔐 LOGIN"
title.Size=UDim2.new(1,0,0.2,0)
title.BackgroundTransparency=1
title.TextColor3=Color3.fromRGB(255,255,255)
title.Font=Enum.Font.GothamBlack
title.TextScaled=true
local codeBox=Instance.new("TextBox",login)
codeBox.Size=UDim2.new(0.85,0,0.35,0)
codeBox.Position=UDim2.new(0.075,0,0.25,0)
codeBox.BackgroundColor3=Color3.fromRGB(20,20,20)
codeBox.TextColor3=Color3.fromRGB(255,255,255)
codeBox.PlaceholderText="CÓDIGO"
codeBox.Font=Enum.Font.Gotham
codeBox.TextScaled=true
local cc=Instance.new("UICorner",codeBox)
cc.CornerRadius=UDim.new(0,8)
local cs=Instance.new("UIStroke",codeBox)
cs.Color=Color3.fromRGB(255,50,50)
cs.Thickness=1.5
local confirm=Instance.new("TextButton",login)
confirm.Size=UDim2.new(0.85,0,0.35,0)
confirm.Position=UDim2.new(0.075,0,0.65,0)
confirm.Text="CONFIRMAR"
confirm.BackgroundColor3=Color3.fromRGB(220,30,30)
confirm.TextColor3=Color3.fromRGB(255,255,255)
confirm.Font=Enum.Font.GothamBlack
confirm.TextScaled=true
local cfc=Instance.new("UICorner",confirm)
cfc.CornerRadius=UDim.new(0,8)
local cfs=Instance.new("UIStroke",confirm)
cfs.Color=Color3.fromRGB(255,100,100)
cfs.Thickness=2
makeDraggable(login,nil)

local bubble,menu,menuOpen,currentTab,selectedPlayer,viewEnabled,dropdownFrame,teleDropdownFrame,mainArea,sidebarBtns={}
local viewConn,antiSitConn

local function updateCamera()
    if viewEnabled and selectedPlayer then
        if viewConn then viewConn:Disconnect() end
        if selectedPlayer.Character then C.CameraSubject=selectedPlayer.Character end
        viewConn=selectedPlayer.CharacterAdded:Connect(function(char)C.CameraSubject=char end)
    else
        if viewConn then viewConn:Disconnect() viewConn=nil end
        C.CameraSubject=lp.Character
    end
end

local function toggleMenu()
    if not menu or not menu.Parent then return end
    if not menuOpen then
        menu.Visible=true
        menu:TweenSize(UDim2.new(0.75,0,0.75,0),"Out","Quad",0.3,true)
        menuOpen=true
    else
        menu:TweenSize(UDim2.new(0,0,0,0),"In","Quad",0.3,true,function()menu.Visible=false end)
        menuOpen=false
    end
end

local function refreshDropdown(frame)
    if frame then
        local scroll=frame.ScrollingFrame
        for _,v in ipairs(scroll:GetChildren())do if v:IsA("TextButton")then v:Destroy()end end
        local sorted={}
        for _,p in ipairs(P:GetPlayers())do table.insert(sorted,p.Name)end
        table.sort(sorted)
        if #sorted==0 then
            local empty=Instance.new("TextLabel",scroll)
            empty.Size=UDim2.new(1,0,0,30)
            empty.Text="Sem jogadores"
            empty.TextColor3=Color3.fromRGB(200,200,200)
            empty.BackgroundTransparency=1
            empty.Font=Enum.Font.Gotham
            empty.TextScaled=true
        else
            for _,name in ipairs(sorted)do
                local btn=Instance.new("TextButton",scroll)
                btn.Size=UDim2.new(1,0,0,30)
                btn.Text=name
                btn.BackgroundColor3=Color3.fromRGB(40,40,40)
                btn.TextColor3=Color3.fromRGB(255,255,255)
                btn.Font=Enum.Font.Gotham
                btn.TextScaled=true
                btn.MouseButton1Click:Connect(function()
                    if frame==dropdownFrame then
                        for _,p in ipairs(P:GetPlayers())do if p.Name==name then selectedPlayer=p break end end
                        sidebarBtns.selectBar.Text=name
                        dropdownFrame.Visible=false
                        if viewEnabled then updateCamera() end
                    elseif frame==teleDropdownFrame then
                        for _,p in ipairs(P:GetPlayers())do
                            if p.Name==name and p.Character and p.Character:FindFirstChild("HumanoidRootPart")then
                                if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")then
                                    lp.Character:SetPrimaryPartCFrame(p.Character.HumanoidRootPart.CFrame)
                                elseif lp.Character then
                                    lp.Character:MoveTo(p.Character.HumanoidRootPart.Position)
                                end
                                break
                            end
                        end
                        teleDropdownFrame.Visible=false
                    end
                end)
            end
        end
    end
end

local function onTabClick(tab)
    currentTab=tab
    for name,btn in pairs(sidebarBtns)do
        if type(btn)=="userdata" and name~="selectBar" and name~="teleportBar" then
            btn.BackgroundColor3=name==tab and Color3.fromRGB(200,20,20)or Color3.fromRGB(40,40,40)
        end
    end
    for _,content in ipairs(mainArea:GetChildren())do
        if content:IsA("Frame")then content.Visible=content.Name==tab end
    end
    if tab=="Principal"then refreshDropdown(dropdownFrame)end
end

local function createBubble()
    bubble=Instance.new("TextButton",sg)
    bubble.Size=UDim2.new(0,52,0,52)
    bubble.Position=UDim2.new(0,0,0,0)
    bubble.BackgroundColor3=Color3.fromRGB(10,10,10)
    bubble.Text=""
    bubble.AutoButtonColor=false
    bubble.BorderSizePixel=0
    local bc=Instance.new("UICorner",bubble)
    bc.CornerRadius=UDim.new(1,0)
    local bs=Instance.new("UIStroke",bubble)
    bs.Color=Color3.fromRGB(255,20,80)
    bs.Thickness=3
    local inner=Instance.new("Frame",bubble)
    inner.Size=UDim2.new(0.8,0,0.8,0)
    inner.Position=UDim2.new(0.1,0,0.1,0)
    inner.BackgroundColor3=Color3.fromRGB(0,0,0)
    inner.BorderSizePixel=0
    local ic=Instance.new("UICorner",inner)
    ic.CornerRadius=UDim.new(1,0)
    local is=Instance.new("UIStroke",inner)
    is.Color=Color3.fromRGB(255,0,0)
    is.Thickness=2
    local kLabel=Instance.new("TextLabel",inner)
    kLabel.Size=UDim2.new(1,0,1,0)
    kLabel.Text="K"
    kLabel.TextColor3=Color3.fromRGB(255,50,50)
    kLabel.Font=Enum.Font.GothamBlack
    kLabel.TextScaled=true
    kLabel.BackgroundTransparency=1
    local glow=Instance.new("UIGradient",bubble)
    glow.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(80,0,0)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,0,0))})
    bubble.MouseButton1Click:Connect(toggleMenu)
    bubble.Visible=true
end

local function createJogadorTab(mainArea)
    local jog=Instance.new("Frame",mainArea)
    jog.Name="Jogador"
    jog.Size=UDim2.new(1,0,1,0)
    jog.BackgroundTransparency=1
    jog.Visible=false
    local list=Instance.new("UIListLayout",jog)
    list.SortOrder=Enum.SortOrder.LayoutOrder
    list.Padding=UDim.new(0,10)
    local pad=Instance.new("UIPadding",jog)
    pad.PaddingLeft=UDim.new(0,20)
    pad.PaddingRight=UDim.new(0,20)
    pad.PaddingTop=UDim.new(0,15)
    local function createStat(name,default,applyFunc)
        local section=Instance.new("Frame",jog)
        section.Size=UDim2.new(1,0,0,50)
        section.BackgroundColor3=Color3.fromRGB(25,25,25)
        section.BorderSizePixel=0
        local sc=Instance.new("UICorner",section)
        sc.CornerRadius=UDim.new(0,8)
        local ss=Instance.new("UIStroke",section)
        ss.Color=Color3.fromRGB(255,40,40)
        ss.Thickness=1.5
        local label=Instance.new("TextLabel",section)
        label.Size=UDim2.new(0.4,0,1,0)
        label.Position=UDim2.new(0,0,0,0)
        label.Text=name
        label.TextColor3=Color3.fromRGB(255,255,255)
        label.BackgroundTransparency=1
        label.Font=Enum.Font.GothamBold
        label.TextScaled=true
        local valueBtn=Instance.new("TextButton",section)
        valueBtn.Size=UDim2.new(0.5,0,1,0)
        valueBtn.Position=UDim2.new(0.45,0,0,0)
        valueBtn.Text=tostring(default)
        valueBtn.BackgroundColor3=Color3.fromRGB(40,40,40)
        valueBtn.TextColor3=Color3.fromRGB(255,255,255)
        valueBtn.Font=Enum.Font.Gotham
        valueBtn.TextScaled=true
        local vc=Instance.new("UICorner",valueBtn)
        vc.CornerRadius=UDim.new(0,8)
        local input=Instance.new("TextBox",section)
        input.Size=UDim2.new(0.5,0,1,0)
        input.Position=UDim2.new(0.45,0,0,0)
        input.BackgroundColor3=Color3.fromRGB(30,30,30)
        input.TextColor3=Color3.fromRGB(255,255,255)
        input.PlaceholderText="Número"
        input.Font=Enum.Font.Gotham
        input.TextScaled=true
        input.Visible=false
        local ic=Instance.new("UICorner",input)
        ic.CornerRadius=UDim.new(0,8)
        valueBtn.MouseButton1Click:Connect(function()
            valueBtn.Visible=false
            input.Visible=true
            input:CaptureFocus()
      end)
    input.FocusLost:Connect(function(enter)
            local num=tonumber(input.Text)
            if num then
                applyFunc(num)
                valueBtn.Text=input.Text
                input.Visible=false
                valueBtn.Visible=true
            else
                input.Text=""
                input.Visible=false
                valueBtn.Visible=true
            end
        end)
    end
    createStat("Velocidade",16,function(v)if lp.Character and lp.Character:FindFirstChild("Humanoid")then lp.Character.Humanoid.WalkSpeed=v end end)
    createStat("Pulo",50,function(v)if lp.Character and lp.Character:FindFirstChild("Humanoid")then lp.Character.Humanoid.JumpPower=v end end)
    createStat("Gravidade",workspace.Gravity,function(v)workspace.Gravity=v end)
    local antiSitSection=Instance.new("Frame",jog)
    antiSitSection.Size=UDim2.new(1,0,0,50)
    antiSitSection.BackgroundColor3=Color3.fromRGB(25,25,25)
    antiSitSection.BorderSizePixel=0
    local asc=Instance.new("UICorner",antiSitSection)
    asc.CornerRadius=UDim.new(0,8)
    local ass=Instance.new("UIStroke",antiSitSection)
    ass.Color=Color3.fromRGB(255,40,40)
    ass.Thickness=1.5
    local antiSitLabel=Instance.new("TextLabel",antiSitSection)
    antiSitLabel.Size=UDim2.new(0.4,0,1,0)
    antiSitLabel.Position=UDim2.new(0,0,0,0)
    antiSitLabel.Text="Anti Sit"
    antiSitLabel.TextColor3=Color3.fromRGB(255,255,255)
    antiSitLabel.BackgroundTransparency=1
    antiSitLabel.Font=Enum.Font.GothamBold
    antiSitLabel.TextScaled=true
    local antiSitToggle=Instance.new("TextButton",antiSitSection)
    antiSitToggle.Size=UDim2.new(0.5,0,1,0)
    antiSitToggle.Position=UDim2.new(0.45,0,0,0)
    antiSitToggle.Text="OFF"
    antiSitToggle.BackgroundColor3=Color3.fromRGB(40,40,40)
    antiSitToggle.TextColor3=Color3.fromRGB(255,255,255)
    antiSitToggle.Font=Enum.Font.Gotham
    antiSitToggle.TextScaled=true
    local atc=Instance.new("UICorner",antiSitToggle)
    atc.CornerRadius=UDim.new(0,8)
    local antiSitEnabled=false
    local function enableAntiSit()
        if antiSitConn then antiSitConn:Disconnect() antiSitConn=nil end
        if lp.Character and lp.Character:FindFirstChild("Humanoid")then
            local hum=lp.Character.Humanoid
            hum:SetStateEnabled(Enum.HumanoidStateType.Seated,false)
            hum.Sit=true
            hum.AutoRotate=false
            local hrp=lp.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local bodyVelocity=Instance.new("BodyVelocity",hrp)
                bodyVelocity.MaxForce=Vector3.new(1e6,0,1e6)
                bodyVelocity.Velocity=Vector3.new(0,0,0)
                local bodyGyro=Instance.new("BodyGyro",hrp)
                bodyGyro.MaxTorque=Vector3.new(0,1e6,0)
                bodyGyro.P=1e4
                antiSitConn=R.Heartbeat:Connect(function()
                    if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart")then return end
                    local moveDir=Vector3.new(lp.Character.Humanoid.MoveDirection.X,0,lp.Character.Humanoid.MoveDirection.Z)
                    if moveDir.Magnitude>0 then
                        local newPos=hrp.Position+moveDir.Unit*hum.WalkSpeed*R.Heartbeat:Wait()
                        hrp.CFrame=CFrame.new(newPos)*CFrame.Angles(0,math.atan2(moveDir.X,moveDir.Z),0)
                    end
                    bodyGyro.CFrame=CFrame.Angles(0,hrp.CFrame.LookVector.Y,0)
                    hum.Sit=true
                end)
            end
        end
    end
    local function disableAntiSit()
        if antiSitConn then antiSitConn:Disconnect() antiSitConn=nil end
        if lp.Character and lp.Character:FindFirstChild("Humanoid")then
            local hum=lp.Character.Humanoid
            hum:SetStateEnabled(Enum.HumanoidStateType.Seated,true)
            hum.Sit=false
            hum.AutoRotate=true
            local hrp=lp.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _,v in ipairs(hrp:GetChildren())do
                    if v:IsA("BodyVelocity")or v:IsA("BodyGyro")then v:Destroy()end
                end
            end
        end
    end
    antiSitToggle.MouseButton1Click:Connect(function()
        antiSitEnabled=not antiSitEnabled
        if antiSitEnabled then
            antiSitToggle.Text="ON"
            antiSitToggle.BackgroundColor3=Color3.fromRGB(200,20,20)
            enableAntiSit()
        else
            antiSitToggle.Text="OFF"
            antiSitToggle.BackgroundColor3=Color3.fromRGB(40,40,40)
            disableAntiSit()
        end
    end)
    return jog
end

local function createMenu()
    menu=Instance.new("TextButton",sg)
    menu.Size=UDim2.new(0,0,0,0)
    menu.Position=UDim2.new(0.125,0,0.125,0)
    menu.BackgroundColor3=Color3.fromRGB(10,10,10)
    menu.BackgroundTransparency=0.05
    menu.Text=""
    menu.AutoButtonColor=false
    menu.BorderSizePixel=0
    menu.Visible=false
    local mc=Instance.new("UICorner",menu)
    mc.CornerRadius=UDim.new(0,14)
    local ms=Instance.new("UIStroke",menu)
    ms.Color=Color3.fromRGB(255,20,80)
    ms.Thickness=2.5
    local mg=Instance.new("UIGradient",menu)
    mg.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(20,20,20)),ColorSequenceKeypoint.new(1,Color3.fromRGB(5,5,5))})
    local sidebar=Instance.new("Frame",menu)
    sidebar.Size=UDim2.new(0.12,0,1,0)
    sidebar.BackgroundColor3=Color3.fromRGB(15,15,15)
    sidebar.BorderSizePixel=0
    local sc=Instance.new("UICorner",sidebar)
    sc.CornerRadius=UDim.new(0,14)
    local scroll=Instance.new("ScrollingFrame",sidebar)
    scroll.Size=UDim2.new(1,0,1,0)
    scroll.BackgroundTransparency=1
    scroll.ScrollBarThickness=2
    scroll.CanvasSize=UDim2.new(0,0,0,0)
    scroll.AutomaticCanvasSize="Y"
    local list=Instance.new("UIListLayout",scroll)
    list.SortOrder=Enum.SortOrder.LayoutOrder
    list.Padding=UDim.new(0,5)
    local pad=Instance.new("UIPadding",scroll)
    pad.PaddingLeft=UDim.new(0,8)
    pad.PaddingRight=UDim.new(0,8)
    pad.PaddingTop=UDim.new(0,10)
    local tabs={"Créditos","Principal","Jogador","Armas"}
    local tabIcons={["Créditos"]="📄",["Principal"]="👤",["Jogador"]="⚡",["Armas"]="🔫"}
    sidebarBtns={}
    for _,tab in ipairs(tabs)do
        local btn=Instance.new("TextButton",scroll)
        btn.Size=UDim2.new(1,0,0,45)
        btn.Text=tabIcons[tab].." "..tab
        btn.BackgroundColor3=Color3.fromRGB(40,40,40)
        btn.TextColor3=Color3.fromRGB(255,255,255)
        btn.Font=Enum.Font.Gotham
        btn.TextScaled=true
        btn.BorderSizePixel=0
        local bc=Instance.new("UICorner",btn)
        bc.CornerRadius=UDim.new(0,8)
        btn.MouseButton1Click:Connect(function()onTabClick(tab)end)
        btn.MouseEnter:Connect(function()btn.BackgroundColor3=currentTab==tab and Color3.fromRGB(200,20,20)or Color3.fromRGB(60,60,60)end)
        btn.MouseLeave:Connect(function()btn.BackgroundColor3=currentTab==tab and Color3.fromRGB(200,20,20)or Color3.fromRGB(40,40,40)end)
        sidebarBtns[tab]=btn
    end
    mainArea=Instance.new("Frame",menu)
    mainArea.Size=UDim2.new(0.88,0,1,0)
    mainArea.Position=UDim2.new(0.12,0,0,0)
    mainArea.BackgroundTransparency=1
    mainArea.BorderSizePixel=0
    local cred=Instance.new("Frame",mainArea)
    cred.Name="Créditos"
    cred.Size=UDim2.new(1,0,1,0)
    cred.BackgroundTransparency=1
    cred.Visible=false
    local credLabel=Instance.new("TextLabel",cred)
    credLabel.Text="Criador: kkscript"
    credLabel.Size=UDim2.new(1,0,1,0)
    credLabel.TextColor3=Color3.fromRGB(255,255,255)
    credLabel.BackgroundTransparency=1
    credLabel.Font=Enum.Font.GothamBlack
    credLabel.TextScaled=true
    credLabel.TextXAlignment=Enum.TextXAlignment.Center
    credLabel.TextYAlignment=Enum.TextYAlignment.Center
    local principal=Instance.new("Frame",mainArea)
    principal.Name="Principal"
    principal.Size=UDim2.new(1,0,1,0)
    principal.BackgroundTransparency=1
    principal.Visible=false
    local viewGroup=Instance.new("Frame",principal)
    viewGroup.Size=UDim2.new(0.9,0,0.35,0)
    viewGroup.Position=UDim2.new(0.05,0,0.02,0)
    viewGroup.BackgroundColor3=Color3.fromRGB(20,20,20)
    viewGroup.BackgroundTransparency=0.3
    viewGroup.BorderSizePixel=0
    local vgCorner=Instance.new("UICorner",viewGroup)
    vgCorner.CornerRadius=UDim.new(0,10)
    local vgStroke=Instance.new("UIStroke",viewGroup)
    vgStroke.Color=Color3.fromRGB(255,40,40)
    vgStroke.Thickness=1.5
    local viewTitle=Instance.new("TextLabel",viewGroup)
    viewTitle.Size=UDim2.new(1,0,0.3,0)
    viewTitle.Text="VISÃO"
    viewTitle.TextColor3=Color3.fromRGB(255,255,255)
    viewTitle.BackgroundTransparency=1
    viewTitle.Font=Enum.Font.GothamBlack
    viewTitle.TextScaled=true
    local viewToggle=Instance.new("TextButton",viewGroup)
    viewToggle.Size=UDim2.new(0.4,0,0.4,0)
    viewToggle.Position=UDim2.new(0.3,0,0.4,0)
    viewToggle.Text="View: OFF"
    viewToggle.BackgroundColor3=Color3.fromRGB(40,40,40)
    viewToggle.TextColor3=Color3.fromRGB(255,255,255)
    viewToggle.Font=Enum.Font.Gotham
    viewToggle.TextScaled=true
    local vc=Instance.new("UICorner",viewToggle)
    vc.CornerRadius=UDim.new(0,8)
    viewToggle.MouseButton1Click:Connect(function()
        viewEnabled=not viewEnabled
        viewToggle.Text="View: "..(viewEnabled and "ON" or "OFF")
        viewToggle.BackgroundColor3=viewEnabled and Color3.fromRGB(200,20,20)or Color3.fromRGB(40,40,40)
        updateCamera()
    end)
    local selectBar=Instance.new("TextButton",viewGroup)
    selectBar.Size=UDim2.new(0.8,0,0.25,0)
    selectBar.Position=UDim2.new(0.1,0,0.85,0)
    selectBar.Text="Selecionar jogador"
    selectBar.BackgroundColor3=Color3.fromRGB(40,40,40)
    selectBar.TextColor3=Color3.fromRGB(255,255,255)
    selectBar.Font=Enum.Font.Gotham
    selectBar.TextScaled=true
    local sc2=Instance.new("UICorner",selectBar)
    sc2.CornerRadius=UDim.new(0,6)
    sidebarBtns.selectBar=selectBar
    dropdownFrame=Instance.new("Frame",principal)
    dropdownFrame.Size=UDim2.new(0.8,0,0.18,0)
    dropdownFrame.Position=UDim2.new(0.1,0,0.38,0)
    dropdownFrame.BackgroundColor3=Color3.fromRGB(25,25,25)
    dropdownFrame.BackgroundTransparency=0.1
    dropdownFrame.BorderSizePixel=0
    dropdownFrame.Visible=false
    local dc=Instance.new("UICorner",dropdownFrame)
    dc.CornerRadius=UDim.new(0,8)
    local dropScroll=Instance.new("ScrollingFrame",dropdownFrame)
    dropScroll.Size=UDim2.new(1,0,1,0)
    dropScroll.BackgroundTransparency=1
    dropScroll.ScrollBarThickness=2
    dropScroll.CanvasSize=UDim2.new(0,0,0,0)
    dropScroll.AutomaticCanvasSize="Y"
    local dlist=Instance.new("UIListLayout",dropScroll)
    dlist.SortOrder=Enum.SortOrder.LayoutOrder
    selectBar.MouseButton1Click:Connect(function()
        dropdownFrame.Visible=not dropdownFrame.Visible
        if dropdownFrame.Visible then refreshDropdown(dropdownFrame)end
    end)
    local teleGroup=Instance.new("Frame",principal)
    teleGroup.Size=UDim2.new(0.9,0,0.35,0)
    teleGroup.Position=UDim2.new(0.05,0,0.55,0)
    teleGroup.BackgroundColor3=Color3.fromRGB(20,20,20)
    teleGroup.BackgroundTransparency=0.3
    teleGroup.BorderSizePixel=0
    local tgCorner=Instance.new("UICorner",teleGroup)
    tgCorner.CornerRadius=UDim.new(0,10)
    local tgStroke=Instance.new("UIStroke",teleGroup)
    tgStroke.Color=Color3.fromRGB(255,40,40)
    tgStroke.Thickness=1.5
    local teleTitle=Instance.new("TextLabel",teleGroup)
    teleTitle.Size=UDim2.new(1,0,0.3,0)
    teleTitle.Text="TELEPORTE"
    teleTitle.TextColor3=Color3.fromRGB(255,255,255)
    teleTitle.BackgroundTransparency=1
    teleTitle.Font=Enum.Font.GothamBlack
    teleTitle.TextScaled=true
    local teleportBar=Instance.new("TextButton",teleGroup)
    teleportBar.Size=UDim2.new(0.8,0,0.25,0)
    teleportBar.Position=UDim2.new(0.1,0,0.4,0)
    teleportBar.Text="Jogador"
    teleportBar.BackgroundColor3=Color3.fromRGB(40,40,40)
    teleportBar.TextColor3=Color3.fromRGB(255,255,255)
    teleportBar.Font=Enum.Font.Gotham
    teleportBar.TextScaled=true
    local tc=Instance.new("UICorner",teleportBar)
    tc.CornerRadius=UDim.new(0,6)
    sidebarBtns.teleportBar=teleportBar
    teleDropdownFrame=Instance.new("Frame",principal)
    teleDropdownFrame.Size=UDim2.new(0.8,0,0.18,0)
    teleDropdownFrame.Position=UDim2.new(0.1,0,0.91,0)
    teleDropdownFrame.BackgroundColor3=Color3.fromRGB(25,25,25)
    teleDropdownFrame.BackgroundTransparency=0.1
    teleDropdownFrame.BorderSizePixel=0
    teleDropdownFrame.Visible=false
    local tdc=Instance.new("UICorner",teleDropdownFrame)
    tdc.CornerRadius=UDim.new(0,8)
    local teleScroll=Instance.new("ScrollingFrame",teleDropdownFrame)
    teleScroll.Size=UDim2.new(1,0,1,0)
    teleScroll.BackgroundTransparency=1
    teleScroll.ScrollBarThickness=2
    teleScroll.CanvasSize=UDim2.new(0,0,0,0)
    teleScroll.AutomaticCanvasSize="Y"
    local tlist=Instance.new("UIListLayout",teleScroll)
    tlist.SortOrder=Enum.SortOrder.LayoutOrder
    teleportBar.MouseButton1Click:Connect(function()
        teleDropdownFrame.Visible=not teleDropdownFrame.Visible
        if teleDropdownFrame.Visible then refreshDropdown(teleDropdownFrame)end
    end)
    local jogador=createJogadorTab(mainArea)
    local armas=Instance.new("Frame",mainArea)
    armas.Name="Armas"
    armas.Size=UDim2.new(1,0,1,0)
    armas.BackgroundTransparency=1
    armas.Visible=false
    local giveAllBtn=Instance.new("TextButton",armas)
    giveAllBtn.Size=UDim2.new(0.6,0,0.35,0)
    giveAllBtn.Position=UDim2.new(0.2,0,0.33,0)
    giveAllBtn.Text="Pegar Todos Itens"
    giveAllBtn.BackgroundColor3=Color3.fromRGB(220,30,30)
    giveAllBtn.TextColor3=Color3.fromRGB(255,255,255)
    giveAllBtn.Font=Enum.Font.GothamBlack
    giveAllBtn.TextScaled=true
    local ga=Instance.new("UICorner",giveAllBtn)
    ga.CornerRadius=UDim.new(0,10)
    local gs=Instance.new("UIStroke",giveAllBtn)
    gs.Color=Color3.fromRGB(255,100,100)
    gs.Thickness=2
    giveAllBtn.MouseButton1Click:Connect(function()
        local giveAllRemote=game:GetService("ReplicatedStorage"):FindFirstChild("GiveAllItems")
        if giveAllRemote and giveAllRemote:IsA("RemoteEvent")then
            giveAllRemote:FireServer(lp)
        else
            local function grabFrom(loc)
                for _,obj in ipairs(loc:GetChildren())do
                    if obj:IsA("Tool")then obj:Clone().Parent=lp.Backpack end
                end
            end
            grabFrom(game:GetService("ReplicatedStorage"))
            if workspace:FindFirstChild("Itens")then grabFrom(workspace.Itens)end
        end
    end)
    makeDraggable(menu,nil)
    onTabClick("Créditos")
end

confirm.MouseButton1Click:Connect(function()
    if codeBox.Text:lower()=="menu k"then
        login:Destroy()
        createBubble()
        createMenu()
    else
        showError("Código incorreto!")
    end
end)

bubble=nil
menu=nil
menuOpen=false
currentTab="Créditos"
selectedPlayer=nil
viewEnabled=false
