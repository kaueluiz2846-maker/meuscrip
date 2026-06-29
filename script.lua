local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local COLORS = {
    Black      = Color3.fromRGB(20, 20, 20),
    Red        = Color3.fromRGB(220, 20, 20),
    NeonRed    = Color3.fromRGB(255, 0, 0),
    White      = Color3.fromRGB(240, 240, 240),
    Gray       = Color3.fromRGB(60, 60, 60),
    DarkGray   = Color3.fromRGB(30, 30, 30),
    LightGray  = Color3.fromRGB(180, 180, 180)
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MenuK"
ScreenGui.Parent = PlayerGui

local dragObject, dragStart, startPos
local dragConnection

local function makeDraggable(guiObject)
    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputObject == guiObject then
            dragObject = guiObject
            startPos = guiObject.Position
            dragStart = UserInputService:GetMouseLocation()
            if dragConnection then dragConnection:Disconnect() end
            dragConnection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragObject = nil
                    if dragConnection then dragConnection:Disconnect(); dragConnection = nil end
                end
            end)
        end
    end)
end

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragObject then
        local delta = UserInputService:GetMouseLocation() - dragStart
        dragObject.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

local loginFrame = Instance.new("Frame")
loginFrame.Size = UDim2.new(0, 280, 0, 230)
loginFrame.Position = UDim2.new(0.5, -140, 0.4, -115)
loginFrame.BackgroundColor3 = COLORS.Black
loginFrame.BackgroundTransparency = 0.1
loginFrame.BorderSizePixel = 0
loginFrame.ClipsDescendants = true
loginFrame.Parent = ScreenGui
makeDraggable(loginFrame)

local loginStroke = Instance.new("UIStroke")
loginStroke.Color = COLORS.NeonRed
loginStroke.Thickness = 2.5
loginStroke.Transparency = 0.2
loginStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
loginStroke.Parent = loginFrame

local loginCorner = Instance.new("UICorner")
loginCorner.CornerRadius = UDim.new(0, 18)
loginCorner.Parent = loginFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -20, 0, 40)
titleLabel.Position = UDim2.new(0, 10, 0, 10)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🔑 VERIFICAÇÃO DE CHAVE"
titleLabel.TextColor3 = COLORS.White
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextScaled = true
titleLabel.TextXAlignment = Enum.TextXAlignment.Center
titleLabel.Parent = loginFrame

local codeBox = Instance.new("TextBox")
codeBox.Size = UDim2.new(0.85, 0, 0, 40)
codeBox.Position = UDim2.new(0.075, 0, 0, 60)
codeBox.BackgroundColor3 = COLORS.DarkGray
codeBox.TextColor3 = COLORS.White
codeBox.PlaceholderText = "Digite sua chave..."
codeBox.PlaceholderColor3 = COLORS.LightGray
codeBox.Font = Enum.Font.Gotham
codeBox.TextScaled = true
codeBox.BorderSizePixel = 0
codeBox.ClearTextOnFocus = false
codeBox.Parent = loginFrame

local codeCorner = Instance.new("UICorner")
codeCorner.CornerRadius = UDim.new(0, 12)
codeCorner.Parent = codeBox

local verifyBtn = Instance.new("TextButton")
verifyBtn.Size = UDim2.new(0.85, 0, 0, 40)
verifyBtn.Position = UDim2.new(0.075, 0, 0, 115)
verifyBtn.Text = "VERIFICAR"
verifyBtn.BackgroundColor3 = COLORS.Red
verifyBtn.TextColor3 = COLORS.White
verifyBtn.Font = Enum.Font.GothamBold
verifyBtn.TextScaled = true
verifyBtn.BorderSizePixel = 0
verifyBtn.AutoButtonColor = false
verifyBtn.Parent = loginFrame

local verifyCorner = Instance.new("UICorner")
verifyCorner.CornerRadius = UDim.new(0, 12)
verifyCorner.Parent = verifyBtn

verifyBtn.MouseEnter:Connect(function()
    verifyBtn.BackgroundColor3 = COLORS.NeonRed
end)
verifyBtn.MouseLeave:Connect(function()
    verifyBtn.BackgroundColor3 = COLORS.Red
end)

local errorLabel = Instance.new("TextLabel")
errorLabel.Size = UDim2.new(0.85, 0, 0, 25)
errorLabel.Position = UDim2.new(0.075, 0, 0, 165)
errorLabel.Text = "❌ Chave inválida!"
errorLabel.TextColor3 = COLORS.NeonRed
errorLabel.BackgroundTransparency = 1
errorLabel.Font = Enum.Font.GothamBold
errorLabel.TextScaled = true
errorLabel.Visible = false
errorLabel.Parent = loginFrame

local contactLabel = Instance.new("TextLabel")
contactLabel.Size = UDim2.new(0.85, 0, 0, 25)
contactLabel.Position = UDim2.new(0.075, 0, 0, 195)
contactLabel.Text = "Não tem uma chave? Contate o criador"
contactLabel.TextColor3 = COLORS.LightGray
contactLabel.BackgroundTransparency = 1
contactLabel.Font = Enum.Font.Gotham
contactLabel.TextScaled = true
contactLabel.Parent = loginFrame

local bubble, menu, menuOpen
local currentTab = "Créditos"
local selectedPlayer, viewEnabled, viewConn
local dropdownFrame, teleDropdownFrame, mainArea, sidebarBtns
local killTargetPlayer = nil
local killTargetLabel = nil
local killDropdownFrame = nil

function toggleMenu()
    if not menu then return end
    if not menuOpen then
        menu.Visible = true
        menu:TweenSize(UDim2.new(0.8, 0, 0.75, 0), "Out", "Quad", 0.3, true)
        menuOpen = true
    else
        menu:TweenSize(UDim2.new(0, 0, 0, 0), "In", "Quad", 0.3, true, function()
            menu.Visible = false
        end)
        menuOpen = false
    end
end

local function updateCamera()
    if viewEnabled and selectedPlayer then
        if viewConn then viewConn:Disconnect() end
        if selectedPlayer.Character then
            Camera.CameraSubject = selectedPlayer.Character
        end
        viewConn = selectedPlayer.CharacterAdded:Connect(function(char)
            Camera.CameraSubject = char
        end)
    else
        if viewConn then viewConn:Disconnect(); viewConn = nil end
        Camera.CameraSubject = LocalPlayer.Character
    end
end

local function refreshDropdown(frame)
    if not frame then return end
    local scroll = frame.ScrollingFrame
    for _, v in ipairs(scroll:GetChildren()) do
        if v:IsA("TextButton") or v:IsA("TextLabel") then v:Destroy() end
    end
    local sorted = {}
    for _, p in ipairs(Players:GetPlayers()) do
        table.insert(sorted, p.Name)
    end
    table.sort(sorted)
    if #sorted == 0 then
        local empty = Instance.new("TextLabel")
        empty.Size = UDim2.new(1, 0, 0, 30)
        empty.Text = "Sem jogadores"
        empty.TextColor3 = COLORS.LightGray
        empty.BackgroundTransparency = 1
        empty.Font = Enum.Font.Gotham
        empty.TextScaled = true
        empty.Parent = scroll
    else
        for _, name in ipairs(sorted) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 30)
            btn.Text = name
            btn.BackgroundColor3 = COLORS.DarkGray
            btn.TextColor3 = COLORS.White
            btn.Font = Enum.Font.Gotham
            btn.TextScaled = true
            btn.BorderSizePixel = 0
            btn.Parent = scroll
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 6)
            btnCorner.Parent = btn
            btn.MouseEnter:Connect(function()
                btn.BackgroundColor3 = COLORS.Gray
            end)
            btn.MouseLeave:Connect(function()
                btn.BackgroundColor3 = COLORS.DarkGray
            end)
            btn.MouseButton1Click:Connect(function()
                if frame == dropdownFrame then
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p.Name == name then
                            selectedPlayer = p
                            break
                        end
                    end
                    sidebarBtns.selectBar.Text = name
                    dropdownFrame.Visible = false
                    if viewEnabled then updateCamera() end
                elseif frame == teleDropdownFrame then
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p.Name == name and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                LocalPlayer.Character:SetPrimaryPartCFrame(p.Character.HumanoidRootPart.CFrame)
                            elseif LocalPlayer.Character then
                                LocalPlayer.Character:MoveTo(p.Character.HumanoidRootPart.Position)
                            end
                            break
                        end
                    end
                    teleDropdownFrame.Visible = false
                elseif frame == killDropdownFrame then
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p.Name == name then
                            killTargetPlayer = p
                            break
                        end
                    end
                    if killTargetLabel then
                        killTargetLabel.Text = killTargetPlayer and killTargetPlayer.Name or "Nenhum"
                    end
                    killDropdownFrame.Visible = false
                end
            end)
        end
    end
end

function onTabClick(tab)
    currentTab = tab
    for name, btn in pairs(sidebarBtns) do
        if type(btn) == "userdata" and name ~= "selectBar" and name ~= "teleportBar" then
            btn.BackgroundColor3 = (name == tab) and COLORS.Red or COLORS.DarkGray
        end
    end
    for _, content in ipairs(mainArea:GetChildren()) do
        if content:IsA("Frame") then
            content.Visible = (content.Name == tab)
        end
    end
    if tab == "Principal" then
        refreshDropdown(dropdownFrame)
        if killDropdownFrame then refreshDropdown(killDropdownFrame) end
    end
end

local function createBubble()
    bubble = Instance.new("TextButton")
    bubble.Size = UDim2.new(0, 65, 0, 65)
    bubble.Position = UDim2.new(0.92, -32, 0.85, -32)
    bubble.BackgroundColor3 = COLORS.Black
    bubble.BackgroundTransparency = 0.05
    bubble.Text = "K"
    bubble.TextColor3 = COLORS.White
    bubble.Font = Enum.Font.GothamBlack
    bubble.TextScaled = true
    bubble.AutoButtonColor = false
    bubble.BorderSizePixel = 0
    bubble.ZIndex = 10
    bubble.Parent = ScreenGui
    makeDraggable(bubble)

    local bubbleCorner = Instance.new("UICorner")
    bubbleCorner.CornerRadius = UDim.new(1, 0)
    bubbleCorner.Parent = bubble

    local bubbleStroke = Instance.new("UIStroke")
    bubbleStroke.Color = COLORS.NeonRed
    bubbleStroke.Thickness = 3
    bubbleStroke.Transparency = 0.2
    bubbleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    bubbleStroke.Parent = bubble

    local glow = Instance.new("Frame")
    glow.Size = UDim2.new(1.6, 0, 1.6, 0)
    glow.Position = UDim2.new(-0.3, 0, -0.3, 0)
    glow.BackgroundColor3 = COLORS.NeonRed
    glow.BackgroundTransparency = 0.9
    glow.BorderSizePixel = 0
    glow.ZIndex = 0
    glow.Parent = bubble
    local glowCorner = Instance.new("UICorner")
    glowCorner.CornerRadius = UDim.new(1, 0)
    glowCorner.Parent = glow

    bubble.MouseButton1Click:Connect(toggleMenu)
end

local function createSlider(parent, yPos, label, minVal, maxVal, default, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0.9, 0, 0, 40)
    container.Position = UDim2.new(0.05, 0, yPos, 0)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.35, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = COLORS.White
    lbl.Font = Enum.Font.Gotham
    lbl.TextScaled = true
    lbl.Parent = container

    local track = Instance.new("Frame")
    track.Size = UDim2.new(0.45, 0, 0, 12)
    track.Position = UDim2.new(0.35, 0, 0.5, -6)
    track.BackgroundColor3 = COLORS.DarkGray
    track.BorderSizePixel = 0
    track.Active = true
    track.Parent = container
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 6)
    trackCorner.Parent = track

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = COLORS.NeonRed
    fill.BorderSizePixel = 0
    fill.Parent = track
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 6)
    fillCorner.Parent = fill

    local thumb = Instance.new("TextButton")
    thumb.Size = UDim2.new(0, 20, 0, 20)
    thumb.Position = UDim2.new(0, -10, 0.5, -10)
    thumb.BackgroundColor3 = COLORS.White
    thumb.Text = ""
    thumb.BorderSizePixel = 0
    thumb.AutoButtonColor = false
    thumb.Parent = track
    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(1, 0)
    thumbCorner.Parent = thumb

    local valLabel = Instance.new("TextLabel")
    valLabel.Size = UDim2.new(0.2, 0, 1, 0)
    valLabel.Position = UDim2.new(0.8, 0, 0, 0)
    valLabel.BackgroundTransparency = 1
    valLabel.Text = tostring(default)
    valLabel.TextColor3 = COLORS.White
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextScaled = true
    valLabel.Parent = container

    local currentValue = default

    local function setFromMouseX(mouseX)
        local trackAbs = track.AbsolutePosition.X
        local trackWidth = track.AbsoluteSize.X
        local fraction = (mouseX - trackAbs) / trackWidth
        fraction = math.clamp(fraction, 0, 1)
        return fraction
    end

    local function updateValue(newValue)
        newValue = math.clamp(newValue, minVal, maxVal)
        currentValue = newValue
        local fraction = (newValue - minVal) / (maxVal - minVal)
        fill.Size = UDim2.new(fraction, 0, 1, 0)
        thumb.Position = UDim2.new(fraction, -10, 0.5, -10)
        valLabel.Text = tostring(math.floor(newValue * 10 + 0.5) / 10)
        if callback then callback(newValue) end
    end

    local function startDrag()
        local moveCon, endCon
        moveCon = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                local frac = setFromMouseX(UserInputService:GetMouseLocation().X)
                updateValue(minVal + frac * (maxVal - minVal))
            end
        end)
        endCon = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                if moveCon then moveCon:Disconnect() end
                if endCon then endCon:Disconnect() end
            end
        end)
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local frac = setFromMouseX(UserInputService:GetMouseLocation().X)
            updateValue(minVal + frac * (maxVal - minVal))
            startDrag()
        end
    end)

    thumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            startDrag()
        end
    end)

    updateValue(default)
    return container
end

local function createMenu()
    menu = Instance.new("Frame")
    menu.Size = UDim2.new(0, 0, 0, 0)
    menu.Position = UDim2.new(0.1, 0, 0.1, 0)
    menu.BackgroundColor3 = COLORS.Black
    menu.BackgroundTransparency = 0.05
    menu.BorderSizePixel = 0
    menu.Visible = false
    menu.ClipsDescendants = true
    menu.Parent = ScreenGui
    makeDraggable(menu)

    local menuCorner = Instance.new("UICorner")
    menuCorner.CornerRadius = UDim.new(0, 20)
    menuCorner.Parent = menu

    local menuStroke = Instance.new("UIStroke")
    menuStroke.Color = COLORS.NeonRed
    menuStroke.Thickness = 2.5
    menuStroke.Transparency = 0.2
    menuStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    menuStroke.Parent = menu

    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0.15, 0, 1, 0)
    sidebar.BackgroundColor3 = COLORS.DarkGray
    sidebar.BorderSizePixel = 0
    sidebar.Parent = menu

    local sidebarCorner = Instance.new("UICorner")
    sidebarCorner.CornerRadius = UDim.new(0, 20)
    sidebarCorner.Parent = sidebar

    local sidebarScroll = Instance.new("ScrollingFrame")
    sidebarScroll.Size = UDim2.new(1, 0, 1, 0)
    sidebarScroll.BackgroundTransparency = 1
    sidebarScroll.ScrollBarThickness = 2
    sidebarScroll.ScrollBarImageColor3 = COLORS.NeonRed
    sidebarScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    sidebarScroll.AutomaticCanvasSize = "Y"
    sidebarScroll.Parent = sidebar

    local sidebarLayout = Instance.new("UIListLayout")
    sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sidebarLayout.Padding = UDim.new(0, 8)
    sidebarLayout.Parent = sidebarScroll

    local sidebarPadding = Instance.new("UIPadding")
    sidebarPadding.PaddingLeft = UDim.new(0, 10)
    sidebarPadding.PaddingRight = UDim.new(0, 10)
    sidebarPadding.PaddingTop = UDim.new(0, 10)
    sidebarPadding.Parent = sidebarScroll

    local tabs = {"Créditos", "Principal", "Jogador", "Armas"}
    local icons = {["Créditos"] = "📄", ["Principal"] = "⚡", ["Jogador"] = "🏃", ["Armas"] = "🔫"}
    sidebarBtns = {}

    for _, tab in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 44)
        btn.Text = icons[tab] .. " " .. tab
        btn.BackgroundColor3 = (tab == "Créditos") and COLORS.Red or COLORS.DarkGray
        btn.TextColor3 = COLORS.White
        btn.Font = Enum.Font.GothamSemibold
        btn.TextScaled = true
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.Parent = sidebarScroll

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 12)
        btnCorner.Parent = btn

        btn.MouseEnter:Connect(function()
            if currentTab ~= tab then
                btn.BackgroundColor3 = COLORS.Gray
            end
        end)
        btn.MouseLeave:Connect(function()
            if currentTab ~= tab then
                btn.BackgroundColor3 = COLORS.DarkGray
            end
        end)
        btn.MouseButton1Click:Connect(function()
            onTabClick(tab)
        end)

        sidebarBtns[tab] = btn
    end

    mainArea = Instance.new("Frame")
    mainArea.Size = UDim2.new(0.85, 0, 1, 0)
    mainArea.Position = UDim2.new(0.15, 0, 0, 0)
    mainArea.BackgroundTransparency = 1
    mainArea.BorderSizePixel = 0
    mainArea.Parent = menu

    -- Créditos
    local credTab = Instance.new("Frame")
    credTab.Name = "Créditos"
    credTab.Size = UDim2.new(1, 0, 1, 0)
    credTab.BackgroundTransparency = 1
    credTab.Visible = true
    credTab.Parent = mainArea

    local credLabel = Instance.new("TextLabel")
    credLabel.Size = UDim2.new(1, -20, 1, -20)
    credLabel.Position = UDim2.new(0, 10, 0, 10)
    credLabel.Text = "Criado por kkscript\n⚡ Interface moderna com cores exclusivas"
    credLabel.TextColor3 = COLORS.White
    credLabel.BackgroundTransparency = 1
    credLabel.Font = Enum.Font.GothamBold
    credLabel.TextScaled = true
    credLabel.TextXAlignment = Enum.TextXAlignment.Center
    credLabel.TextYAlignment = Enum.TextYAlignment.Center
    credLabel.Parent = credTab

    -- Principal
    local principalTab = Instance.new("Frame")
    principalTab.Name = "Principal"
    principalTab.Size = UDim2.new(1, 0, 1, 0)
    principalTab.BackgroundTransparency = 1
    principalTab.Visible = false
    principalTab.Parent = mainArea

    -- ========== KILL (Brookhaven) ==========
    local killTitle = Instance.new("TextLabel")
    killTitle.Size = UDim2.new(1, 0, 0, 25)
    killTitle.Position = UDim2.new(0.03, 0, 0.03, 0)
    killTitle.Text = "🎯 Matar"
    killTitle.TextColor3 = COLORS.NeonRed
    killTitle.BackgroundTransparency = 1
    killTitle.Font = Enum.Font.GothamBold
    killTitle.TextScaled = true
    killTitle.TextXAlignment = Enum.TextXAlignment.Left
    killTitle.Parent = principalTab

    local killSelectBar = Instance.new("TextButton")
    killSelectBar.Size = UDim2.new(0.6, 0, 0, 36)
    killSelectBar.Position = UDim2.new(0.03, 0, 0.1, 0)
    killSelectBar.Text = "Selecionar alvo"
    killSelectBar.BackgroundColor3 = COLORS.DarkGray
    killSelectBar.TextColor3 = COLORS.White
    killSelectBar.Font = Enum.Font.Gotham
    killSelectBar.TextScaled = true
    killSelectBar.BorderSizePixel = 0
    killSelectBar.Parent = principalTab

    local ksCorner = Instance.new("UICorner")
    ksCorner.CornerRadius = UDim.new(0, 10)
    ksCorner.Parent = killSelectBar

    killSelectBar.MouseEnter:Connect(function()
        killSelectBar.BackgroundColor3 = COLORS.Gray
    end)
    killSelectBar.MouseLeave:Connect(function()
        killSelectBar.BackgroundColor3 = COLORS.DarkGray
    end)

    killTargetLabel = Instance.new("TextLabel")
    killTargetLabel.Size = UDim2.new(0.3, 0, 0, 36)
    killTargetLabel.Position = UDim2.new(0.65, 0, 0.1, 0)
    killTargetLabel.Text = "Nenhum"
    killTargetLabel.TextColor3 = COLORS.White
    killTargetLabel.BackgroundTransparency = 1
    killTargetLabel.Font = Enum.Font.GothamBold
    killTargetLabel.TextScaled = true
    killTargetLabel.Parent = principalTab

    killDropdownFrame = Instance.new("Frame")
    killDropdownFrame.Size = UDim2.new(0.6, 0, 0.18, 0)
    killDropdownFrame.Position = UDim2.new(0.03, 0, 0.2, 0)
    killDropdownFrame.BackgroundColor3 = COLORS.DarkGray
    killDropdownFrame.BackgroundTransparency = 0.1
    killDropdownFrame.BorderSizePixel = 0
    killDropdownFrame.Visible = false
    killDropdownFrame.Parent = principalTab

    local kdCorner = Instance.new("UICorner")
    kdCorner.CornerRadius = UDim.new(0, 12)
    kdCorner.Parent = killDropdownFrame

    local killScroll = Instance.new("ScrollingFrame")
    killScroll.Size = UDim2.new(1, 0, 1, 0)
    killScroll.BackgroundTransparency = 1
    killScroll.ScrollBarThickness = 2
    killScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    killScroll.AutomaticCanvasSize = "Y"
    killScroll.Parent = killDropdownFrame

    local killLayout = Instance.new("UIListLayout")
    killLayout.SortOrder = Enum.SortOrder.LayoutOrder
    killLayout.Parent = killScroll

    killSelectBar.MouseButton1Click:Connect(function()
        killDropdownFrame.Visible = not killDropdownFrame.Visible
        if killDropdownFrame.Visible then refreshDropdown(killDropdownFrame) end
    end)

    local killBtn = Instance.new("TextButton")
    killBtn.Size = UDim2.new(0.4, 0, 0, 36)
    killBtn.Position = UDim2.new(0.03, 0, 0.39, 0)
    killBtn.Text = "💀 KILL"
    killBtn.BackgroundColor3 = COLORS.Red
    killBtn.TextColor3 = COLORS.White
    killBtn.Font = Enum.Font.GothamBold
    killBtn.TextScaled = true
    killBtn.BorderSizePixel = 0
    killBtn.AutoButtonColor = false
    killBtn.Parent = principalTab

    local killBtnCorner = Instance.new("UICorner")
    killBtnCorner.CornerRadius = UDim.new(0, 12)
    killBtnCorner.Parent = killBtn

    killBtn.MouseEnter:Connect(function()
        killBtn.BackgroundColor3 = COLORS.NeonRed
    end)
    killBtn.MouseLeave:Connect(function()
        killBtn.BackgroundColor3 = COLORS.Red
    end)

    killBtn.MouseButton1Click:Connect(function()
        if not killTargetPlayer then return end
        local target = killTargetPlayer
        local myChar = LocalPlayer.Character
        if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
        local originalPos = myChar.HumanoidRootPart.CFrame

        -- Procura sofá no padrão Brookhaven
        local sofa = nil
        local possibleNames = {"Sofá", "Sofa", "Couch"}
        -- Procura no workspace (pasta Itens) e ReplicatedStorage
        for _, place in ipairs({workspace, game:GetService("ReplicatedStorage")}) do
            for _, nm in ipairs(possibleNames) do
                local obj = place:FindFirstChild(nm)
                if obj and obj:IsA("Tool") then
                    sofa = obj
                    break
                end
            end
            if sofa then break end
            -- Procura dentro de "Itens"
            local itensFolder = place:FindFirstChild("Itens")
            if itensFolder then
                for _, item in ipairs(itensFolder:GetChildren()) do
                    if item:IsA("Tool") then
                        for _, nm in ipairs(possibleNames) do
                            if item.Name == nm then
                                sofa = item
                                break
                            end
                        end
                    end
                    if sofa then break end
                end
            end
            if sofa then break end
        end

        if not sofa then return end

        local clonedSofa = sofa:Clone()
        clonedSofa.Parent = LocalPlayer.Backpack
        task.wait(0.2)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid:EquipTool(clonedSofa)
        end

        -- Teleporta até o alvo
        if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            myChar:SetPrimaryPartCFrame(target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0))
        end
        task.wait(0.3)

        -- Força o alvo a sentar no sofá (mecânica Brookhaven)
        local function forceSit()
            if target.Character and target.Character:FindFirstChild("Humanoid") then
                target.Character.Humanoid.Sit = true
            end
        end
        -- Tenta forçar depois de 0.5s e novamente após 1s
        task.delay(0.5, forceSit)
        task.delay(1.5, forceSit)

        -- Gira ao redor do alvo
        local angle = 0
        local spinConn
        local sitDetected = false
        spinConn = RunService.Heartbeat:Connect(function(delta)
            if not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
                spinConn:Disconnect()
                return
            end
            -- Verifica se o alvo sentou
            if target.Character:FindFirstChild("Humanoid") and target.Character.Humanoid.Sit then
                if not sitDetected then
                    sitDetected = true
                    spinConn:Disconnect()
                    -- Joga o alvo para longe
                    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
                    if targetRoot then
                        targetRoot.Velocity = Vector3.new(0, 500, 0) + (targetRoot.CFrame.LookVector * 200)
                    end
                    task.wait(0.2)
                    if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                        myChar:SetPrimaryPartCFrame(originalPos)
                    end
                end
                return
            end
            angle = angle + delta * 5
            local radius = 5
            local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
            local targetPos = target.Character.HumanoidRootPart.Position
            if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                myChar:SetPrimaryPartCFrame(CFrame.new(targetPos + offset) * CFrame.Angles(0, angle, 0))
            end
        end)
    end)

    -- ========== FLING (Brookhaven) ==========
    local flingTitle = Instance.new("TextLabel")
    flingTitle.Size = UDim2.new(1, 0, 0, 25)
    flingTitle.Position = UDim2.new(0.03, 0, 0.48, 0)
    flingTitle.Text = "🌀 Fling"
    flingTitle.TextColor3 = COLORS.NeonRed
    flingTitle.BackgroundTransparency = 1
    flingTitle.Font = Enum.Font.GothamBold
    flingTitle.TextScaled = true
    flingTitle.TextXAlignment = Enum.TextXAlignment.Left
    flingTitle.Parent = principalTab

    local flingBtn = Instance.new("TextButton")
    flingBtn.Size = UDim2.new(0.4, 0, 0, 36)
    flingBtn.Position = UDim2.new(0.03, 0, 0.55, 0)
    flingBtn.Text = "Ativar Fling"
    flingBtn.BackgroundColor3 = COLORS.Red
    flingBtn.TextColor3 = COLORS.White
    flingBtn.Font = Enum.Font.GothamBold
    flingBtn.TextScaled = true
    flingBtn.BorderSizePixel = 0
    flingBtn.AutoButtonColor = false
    flingBtn.Parent = principalTab

    local flingCorner = Instance.new("UICorner")
    flingCorner.CornerRadius = UDim.new(0, 12)
    flingCorner.Parent = flingBtn

    flingBtn.MouseEnter:Connect(function()
        flingBtn.BackgroundColor3 = COLORS.NeonRed
    end)
    flingBtn.MouseLeave:Connect(function()
        flingBtn.BackgroundColor3 = COLORS.Red
    end)

    flingBtn.MouseButton1Click:Connect(function()
        if not killTargetPlayer then return end
        local target = killTargetPlayer
        if not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then return end

        -- Procura bola no padrão Brookhaven
        local ball = nil
        local ballNames = {"Bola", "Ball", "Bola de Futebol", "SoccerBall", "SportsBall"}
        for _, place in ipairs({workspace, game:GetService("ReplicatedStorage")}) do
            for _, nm in ipairs(ballNames) do
                local obj = place:FindFirstChild(nm)
                if obj and obj:IsA("Tool") then
                    ball = obj
                    break
                end
            end
            if ball then break end
            local itensFolder = place:FindFirstChild("Itens")
            if itensFolder then
                for _, item in ipairs(itensFolder:GetChildren()) do
                    if item:IsA("Tool") then
                        for _, nm in ipairs(ballNames) do
                            if item.Name == nm then
                                ball = item
                                break
                            end
                        end
                    end
                    if ball then break end
                end
            end
            if ball then break end
        end

        if not ball then return end

        local clonedBall = ball:Clone()
        clonedBall.Parent = target.Character
        clonedBall.Handle.CFrame = target.Character.HumanoidRootPart.CFrame
        clonedBall.Handle.Anchored = false
        clonedBall.Handle.CanCollide = true
        clonedBall.Handle.Massless = false

        -- Fixa a bola ao HumanoidRootPart
        local weld = Instance.new("Weld")
        weld.Part0 = clonedBall.Handle
        weld.Part1 = target.Character.HumanoidRootPart
        weld.Parent = clonedBall.Handle

        -- Gira violentamente
        local spinVel = Instance.new("BodyAngularVelocity")
        spinVel.AngularVelocity = Vector3.new(0, 50, 0)
        spinVel.MaxTorque = Vector3.new(400000, 400000, 400000)
        spinVel.P = 1250
        spinVel.Parent = clonedBall.Handle

        -- Remove após 5 segundos
        task.delay(5, function()
            if clonedBall and clonedBall.Parent then
                clonedBall:Destroy()
            end
        end)
    end)

    -- ===== VIEW =====
    local viewToggle = Instance.new("TextButton")
    viewToggle.Size = UDim2.new(0.18, 0, 0, 36)
    viewToggle.Position = UDim2.new(0.03, 0, 0.65, 0)
    viewToggle.Text = "👁️ View: OFF"
    viewToggle.BackgroundColor3 = COLORS.DarkGray
    viewToggle.TextColor3 = COLORS.White
    viewToggle.Font = Enum.Font.Gotham
    viewToggle.TextScaled = true
    viewToggle.BorderSizePixel = 0
    viewToggle.Parent = principalTab

    local vtCorner = Instance.new("UICorner")
    vtCorner.CornerRadius = UDim.new(0, 10)
    vtCorner.Parent = viewToggle

    viewToggle.MouseEnter:Connect(function()
        if not viewEnabled then viewToggle.BackgroundColor3 = COLORS.Gray end
    end)
    viewToggle.MouseLeave:Connect(function()
        if not viewEnabled then viewToggle.BackgroundColor3 = COLORS.DarkGray end
    end)
    viewToggle.MouseButton1Click:Connect(function()
        viewEnabled = not viewEnabled
        viewToggle.Text = "👁️ View: " .. (viewEnabled and "ON" or "OFF")
        viewToggle.BackgroundColor3 = viewEnabled and COLORS.Red or COLORS.DarkGray
        updateCamera()
    end)

    local selectBar = Instance.new("TextButton")
    selectBar.Size = UDim2.new(0.65, 0, 0, 36)
    selectBar.Position = UDim2.new(0.24, 0, 0.65, 0)
    selectBar.Text = "Selecionar jogador"
    selectBar.BackgroundColor3 = COLORS.DarkGray
    selectBar.TextColor3 = COLORS.White
    selectBar.Font = Enum.Font.Gotham
    selectBar.TextScaled = true
    selectBar.BorderSizePixel = 0
    selectBar.Parent = principalTab

    local selCorner = Instance.new("UICorner")
    selCorner.CornerRadius = UDim.new(0, 10)
    selCorner.Parent = selectBar

    selectBar.MouseEnter:Connect(function()
        selectBar.BackgroundColor3 = COLORS.Gray
    end)
    selectBar.MouseLeave:Connect(function()
        selectBar.BackgroundColor3 = COLORS.DarkGray
    end)

    sidebarBtns.selectBar = selectBar

    dropdownFrame = Instance.new("Frame")
    dropdownFrame.Size = UDim2.new(0.76, 0, 0.12, 0)
    dropdownFrame.Position = UDim2.new(0.12, 0, 0.77, 0)
    dropdownFrame.BackgroundColor3 = COLORS.DarkGray
    dropdownFrame.BackgroundTransparency = 0.1
    dropdownFrame.BorderSizePixel = 0
    dropdownFrame.Visible = false
    dropdownFrame.Parent = principalTab

    local ddCorner = Instance.new("UICorner")
    ddCorner.CornerRadius = UDim.new(0, 12)
    ddCorner.Parent = dropdownFrame

    local dropScroll = Instance.new("ScrollingFrame")
    dropScroll.Size = UDim2.new(1, 0, 1, 0)
    dropScroll.BackgroundTransparency = 1
    dropScroll.ScrollBarThickness = 2
    dropScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    dropScroll.AutomaticCanvasSize = "Y"
    dropScroll.Parent = dropdownFrame

    local dropLayout = Instance.new("UIListLayout")
    dropLayout.SortOrder = Enum.SortOrder.LayoutOrder
    dropLayout.Parent = dropScroll

    selectBar.MouseButton1Click:Connect(function()
        dropdownFrame.Visible = not dropdownFrame.Visible
        if dropdownFrame.Visible then refreshDropdown(dropdownFrame) end
    end)

    -- ===== TELEPORT =====
    local teleLabel = Instance.new("TextLabel")
    teleLabel.Size = UDim2.new(0.15, 0, 0, 36)
    teleLabel.Position = UDim2.new(0.03, 0, 0.87, 0)
    teleLabel.Text = "📌 Teleport:"
    teleLabel.TextColor3 = COLORS.White
    teleLabel.BackgroundTransparency = 1
    teleLabel.Font = Enum.Font.GothamBold
    teleLabel.TextScaled = true
    teleLabel.Parent = principalTab

    local teleportBar = Instance.new("TextButton")
    teleportBar.Size = UDim2.new(0.55, 0, 0, 36)
    teleportBar.Position = UDim2.new(0.22, 0, 0.87, 0)
    teleportBar.Text = "Jogador"
    teleportBar.BackgroundColor3 = COLORS.DarkGray
    teleportBar.TextColor3 = COLORS.White
    teleportBar.Font = Enum.Font.Gotham
    teleportBar.TextScaled = true
    teleportBar.BorderSizePixel = 0
    teleportBar.Parent = principalTab

    local tpCorner = Instance.new("UICorner")
    tpCorner.CornerRadius = UDim.new(0, 10)
    tpCorner.Parent = teleportBar

    teleportBar.MouseEnter:Connect(function()
        teleportBar.BackgroundColor3 = COLORS.Gray
    end)
    teleportBar.MouseLeave:Connect(function()
        teleportBar.BackgroundColor3 = COLORS.DarkGray
    end)

    sidebarBtns.teleportBar = teleportBar

    teleDropdownFrame = Instance.new("Frame")
    teleDropdownFrame.Size = UDim2.new(0.76, 0, 0.12, 0)
    teleDropdownFrame.Position = UDim2.new(0.12, 0, 0.93, 0)
    teleDropdownFrame.BackgroundColor3 = COLORS.DarkGray
    teleDropdownFrame.BackgroundTransparency = 0.1
    teleDropdownFrame.BorderSizePixel = 0
    teleDropdownFrame.Visible = false
    teleDropdownFrame.Parent = principalTab

    local tpdCorner = Instance.new("UICorner")
    tpdCorner.CornerRadius = UDim.new(0, 12)
    tpdCorner.Parent = teleDropdownFrame

    local teleScroll = Instance.new("ScrollingFrame")
    teleScroll.Size = UDim2.new(1, 0, 1, 0)
    teleScroll.BackgroundTransparency = 1
    teleScroll.ScrollBarThickness = 2
    teleScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    teleScroll.AutomaticCanvasSize = "Y"
    teleScroll.Parent = teleDropdownFrame

    local teleLayout = Instance.new("UIListLayout")
    teleLayout.SortOrder = Enum.SortOrder.LayoutOrder
    teleLayout.Parent = teleScroll

    teleportBar.MouseButton1Click:Connect(function()
        teleDropdownFrame.Visible = not teleDropdownFrame.Visible
        if teleDropdownFrame.Visible then refreshDropdown(teleDropdownFrame) end
    end)

    -- Jogador (sliders)
    local jogadorTab = Instance.new("Frame")
    jogadorTab.Name = "Jogador"
    jogadorTab.Size = UDim2.new(1, 0, 1, 0)
    jogadorTab.BackgroundTransparency = 1
    jogadorTab.Visible = false
    jogadorTab.Parent = mainArea

    local currentWalkSpeed = 16
    local currentJumpPower = 50
    local currentGravity = 196.2

    local function applyPlayerStats()
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then
                hum.WalkSpeed = currentWalkSpeed
                hum.JumpPower = currentJumpPower
            end
        end
        workspace.Gravity = currentGravity
    end

    createSlider(jogadorTab, 0.05, "🏃 Velocidade", 0, 100, 16, function(val)
        currentWalkSpeed = val
        applyPlayerStats()
    end)
    createSlider(jogadorTab, 0.25, "🦘 Pulo", 0, 200, 50, function(val)
        currentJumpPower = val
        applyPlayerStats()
    end)
    createSlider(jogadorTab, 0.45, "🌍 Gravidade", 0, 400, 196.2, function(val)
        currentGravity = val
        applyPlayerStats()
    end)

    local function onCharacterAdded(char)
        local hum = char:WaitForChild("Humanoid")
        hum.WalkSpeed = currentWalkSpeed
        hum.JumpPower = currentJumpPower
        workspace.Gravity = currentGravity
        hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            hum.WalkSpeed = currentWalkSpeed
        end)
        hum:GetPropertyChangedSignal("JumpPower"):Connect(function()
            hum.JumpPower = currentJumpPower
        end)
    end
    LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
    if LocalPlayer.Character then
        onCharacterAdded(LocalPlayer.Character)
    end

    -- Armas
    local armasTab = Instance.new("Frame")
    armasTab.Name = "Armas"
    armasTab.Size = UDim2.new(1, 0, 1, 0)
    armasTab.BackgroundTransparency = 1
    armasTab.Visible = false
    armasTab.Parent = mainArea

    local giveAllBtn = Instance.new("TextButton")
    giveAllBtn.Size = UDim2.new(0.65, 0, 0.4, 0)
    giveAllBtn.Position = UDim2.new(0.175, 0, 0.3, 0)
    giveAllBtn.Text = "Pegar Todos Itens"
    giveAllBtn.BackgroundColor3 = COLORS.Red
    giveAllBtn.TextColor3 = COLORS.White
    giveAllBtn.Font = Enum.Font.GothamBold
    giveAllBtn.TextScaled = true
    giveAllBtn.BorderSizePixel = 0
    giveAllBtn.AutoButtonColor = false
    giveAllBtn.Parent = armasTab

    local gaCorner = Instance.new("UICorner")
    gaCorner.CornerRadius = UDim.new(0, 14)
    gaCorner.Parent = giveAllBtn

    local gaStroke = Instance.new("UIStroke")
    gaStroke.Color = COLORS.NeonRed
    gaStroke.Thickness = 2.5
    gaStroke.Transparency = 0.3
    gaStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    gaStroke.Parent = giveAllBtn

    giveAllBtn.MouseEnter:Connect(function()
        giveAllBtn.BackgroundColor3 = COLORS.NeonRed
    end)
    giveAllBtn.MouseLeave:Connect(function()
        giveAllBtn.BackgroundColor3 = COLORS.Red
    end)

    giveAllBtn.MouseButton1Click:Connect(function()
        local giveAllRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Itens") then
                grabFrom(workspace.Itens)
            end
        end
    end)

    onTabClick("Créditos")
end

verifyBtn.MouseButton1Click:Connect(function()
    if codeBox.Text:lower() == "menu k" then
        loginFrame:Destroy()
        createBubble()
        createMenu()
    else
        errorLabel.Visible = true
        task.wait(2)
        errorLabel.Visible = false
    end
end)
