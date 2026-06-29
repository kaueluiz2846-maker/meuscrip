local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local COLORS = {
    Black   = Color3.fromRGB(208, 208, 208),
    Red     = Color3.fromRGB(255, 26, 26),
    NeonRed = Color3.fromRGB(255, 0, 0),
    White   = Color3.fromRGB(255, 255, 255)
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MenuK"
ScreenGui.Parent = PlayerGui

local dragObject, dragStart, startPos
local dragConn

local function makeDraggable(guiObject)
    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputObject == guiObject then
            dragObject = guiObject
            startPos = guiObject.Position
            dragStart = UserInputService:GetMouseLocation()
            if dragConn then dragConn:Disconnect() end
            dragConn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragObject = nil
                    if dragConn then dragConn:Disconnect() end
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
loginFrame.Size = UDim2.new(0, 420, 0, 300)
loginFrame.Position = UDim2.new(0.5, -210, 0.4, -150)
loginFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
loginFrame.BackgroundTransparency = 0.05
loginFrame.BorderSizePixel = 0
loginFrame.Parent = ScreenGui
makeDraggable(loginFrame)

local loginCorner = Instance.new("UICorner")
loginCorner.CornerRadius = UDim.new(0, 22)
loginCorner.Parent = loginFrame

local loginStroke = Instance.new("UIStroke")
loginStroke.Color = COLORS.NeonRed
loginStroke.Thickness = 3
loginStroke.Transparency = 0.3
loginStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
loginStroke.Parent = loginFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0.2, 0)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🔑 VERIFICAÇÃO DE CHAVE"
titleLabel.TextColor3 = COLORS.White
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextScaled = true
titleLabel.Parent = loginFrame

local codeBox = Instance.new("TextBox")
codeBox.Size = UDim2.new(0.85, 0, 0.3, 0)
codeBox.Position = UDim2.new(0.075, 0, 0.28, 0)
codeBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
codeBox.TextColor3 = COLORS.White
codeBox.PlaceholderText = "Digite sua chave..."
codeBox.PlaceholderColor3 = COLORS.Black
codeBox.Font = Enum.Font.Gotham
codeBox.TextScaled = true
codeBox.BorderSizePixel = 0
codeBox.Parent = loginFrame

local codeCorner = Instance.new("UICorner")
codeCorner.CornerRadius = UDim.new(0, 12)
codeCorner.Parent = codeBox

local verifyBtn = Instance.new("TextButton")
verifyBtn.Size = UDim2.new(0.85, 0, 0.3, 0)
verifyBtn.Position = UDim2.new(0.075, 0, 0.63, 0)
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
errorLabel.Size = UDim2.new(1, 0, 0.12, 0)
errorLabel.Position = UDim2.new(0, 0, 0.88, 0)
errorLabel.Text = "❌ Chave inválida!"
errorLabel.TextColor3 = COLORS.NeonRed
errorLabel.BackgroundTransparency = 1
errorLabel.Font = Enum.Font.Gotham
errorLabel.TextScaled = true
errorLabel.Visible = false
errorLabel.Parent = loginFrame

local contactLabel = Instance.new("TextLabel")
contactLabel.Size = UDim2.new(1, 0, 0.1, 0)
contactLabel.Position = UDim2.new(0, 0, 0.78, 0)
contactLabel.Text = "Não tem uma chave? Contate o criador"
contactLabel.TextColor3 = COLORS.Black
contactLabel.BackgroundTransparency = 1
contactLabel.Font = Enum.Font.Gotham
contactLabel.TextScaled = true
contactLabel.Parent = loginFrame

local bubble = nil
local menu = nil
local menuOpen = false
local currentTab = "Créditos"
local selectedPlayer = nil
local viewEnabled = false
local viewConn
local dropdownFrame, teleDropdownFrame, mainArea, sidebarBtns = {}, {}

function toggleMenu()
    if not menu then return end
    if not menuOpen then
        menu.Visible = true
        menu:TweenSize(UDim2.new(0.8, 0, 0.75, 0), "Out", "Quad", 0.25, true)
        menuOpen = true
    else
        menu:TweenSize(UDim2.new(0, 0, 0, 0), "In", "Quad", 0.25, true, function()
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
        if v:IsA("TextButton") then v:Destroy() end
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
        empty.TextColor3 = COLORS.Black
        empty.BackgroundTransparency = 1
        empty.Font = Enum.Font.Gotham
        empty.TextScaled = true
        empty.Parent = scroll
    else
        for _, name in ipairs(sorted) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 30)
            btn.Text = name
            btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            btn.TextColor3 = COLORS.White
            btn.Font = Enum.Font.Gotham
            btn.TextScaled = true
            btn.BorderSizePixel = 0
            btn.Parent = scroll
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 6)
            btnCorner.Parent = btn
            btn.MouseEnter:Connect(function()
                btn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
            end)
            btn.MouseLeave:Connect(function()
                btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
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
                end
            end)
        end
    end
end

function onTabClick(tab)
    currentTab = tab
    for name, btn in pairs(sidebarBtns) do
        if type(btn) == "userdata" and name ~= "selectBar" and name ~= "teleportBar" then
            btn.BackgroundColor3 = (name == tab) and COLORS.Red or Color3.fromRGB(35, 35, 35)
        end
    end
    for _, content in ipairs(mainArea:GetChildren()) do
        if content:IsA("Frame") then
            content.Visible = (content.Name == tab)
        end
    end
    if tab == "Principal" then
        refreshDropdown(dropdownFrame)
    end
end

local function createBubble()
    bubble = Instance.new("TextButton")
    bubble.Size = UDim2.new(0, 60, 0, 60)
    bubble.Position = UDim2.new(0.93, -30, 0.87, -30)
    bubble.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    bubble.Text = "K"
    bubble.TextColor3 = COLORS.White
    bubble.Font = Enum.Font.GothamBold
    bubble.TextScaled = true
    bubble.AutoButtonColor = false
    bubble.BorderSizePixel = 0
    bubble.Parent = ScreenGui
    makeDraggable(bubble)

    local bubbleCorner = Instance.new("UICorner")
    bubbleCorner.CornerRadius = UDim.new(1, 0)
    bubbleCorner.Parent = bubble

    local bubbleStroke = Instance.new("UIStroke")
    bubbleStroke.Color = COLORS.NeonRed
    bubbleStroke.Thickness = 3
    bubbleStroke.Transparency = 0.3
    bubbleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    bubbleStroke.Parent = bubble

    local glow = Instance.new("Frame")
    glow.Size = UDim2.new(1.5, 0, 1.5, 0)
    glow.Position = UDim2.new(-0.25, 0, -0.25, 0)
    glow.BackgroundColor3 = COLORS.NeonRed
    glow.BackgroundTransparency = 0.85
    glow.BorderSizePixel = 0
    glow.ZIndex = 0
    glow.Parent = bubble
    local glowCorner = Instance.new("UICorner")
    glowCorner.CornerRadius = UDim.new(1, 0)
    glowCorner.Parent = glow

    bubble.MouseButton1Click:Connect(toggleMenu)
end

local function createMenu()
    menu = Instance.new("Frame")
    menu.Size = UDim2.new(0, 0, 0, 0)
    menu.Position = UDim2.new(0.1, 0, 0.1, 0)
    menu.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    menu.BackgroundTransparency = 0.05
    menu.BorderSizePixel = 0
    menu.Visible = false
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
    sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    sidebar.BackgroundTransparency = 0.1
    sidebar.BorderSizePixel = 0
    sidebar.Parent = menu

    local sidebarCorner = Instance.new("UICorner")
    sidebarCorner.CornerRadius = UDim.new(0, 20)
    sidebarCorner.Parent = sidebar

    local sidebarScroll = Instance.new("ScrollingFrame")
    sidebarScroll.Size = UDim2.new(1, 0, 1, 0)
    sidebarScroll.BackgroundTransparency = 1
    sidebarScroll.ScrollBarThickness = 2
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

    local tabs = {"Créditos", "Principal", "Armas"}
    local icons = {["Créditos"] = "📄", ["Principal"] = "⚡", ["Armas"] = "🔫"}
    sidebarBtns = {}

    for _, tab in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 44)
        btn.Text = icons[tab] .. " " .. tab
        btn.BackgroundColor3 = (tab == "Créditos") and COLORS.Red or Color3.fromRGB(35, 35, 35)
        btn.TextColor3 = COLORS.White
        btn.Font = Enum.Font.Gotham
        btn.TextScaled = true
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.Parent = sidebarScroll

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 10)
        btnCorner.Parent = btn

        btn.MouseEnter:Connect(function()
            if currentTab ~= tab then
                btn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
            end
        end)
        btn.MouseLeave:Connect(function()
            if currentTab ~= tab then
                btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
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

    local credTab = Instance.new("Frame")
    credTab.Name = "Créditos"
    credTab.Size = UDim2.new(1, 0, 1, 0)
    credTab.BackgroundTransparency = 1
    credTab.Visible = true
    credTab.Parent = mainArea

    local credLabel = Instance.new("TextLabel")
    credLabel.Size = UDim2.new(1, 0, 1, 0)
    credLabel.Text = "Criado por kkscript\n⚡ Interface moderna com cores exclusivas"
    credLabel.TextColor3 = COLORS.White
    credLabel.BackgroundTransparency = 1
    credLabel.Font = Enum.Font.GothamBold
    credLabel.TextScaled = true
    credLabel.TextXAlignment = Enum.TextXAlignment.Center
    credLabel.TextYAlignment = Enum.TextYAlignment.Center
    credLabel.Parent = credTab

    local principalTab = Instance.new("Frame")
    principalTab.Name = "Principal"
    principalTab.Size = UDim2.new(1, 0, 1, 0)
    principalTab.BackgroundTransparency = 1
    principalTab.Visible = false
    principalTab.Parent = mainArea

    local viewToggle = Instance.new("TextButton")
    viewToggle.Size = UDim2.new(0.18, 0, 0, 34)
    viewToggle.Position = UDim2.new(0.05, 0, 0.05, 0)
    viewToggle.Text = "👁️ View: OFF"
    viewToggle.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    viewToggle.TextColor3 = COLORS.White
    viewToggle.Font = Enum.Font.Gotham
    viewToggle.TextScaled = true
    viewToggle.BorderSizePixel = 0
    viewToggle.Parent = principalTab

    local vtCorner = Instance.new("UICorner")
    vtCorner.CornerRadius = UDim.new(0, 10)
    vtCorner.Parent = viewToggle

    viewToggle.MouseEnter:Connect(function()
        if not viewEnabled then viewToggle.BackgroundColor3 = Color3.fromRGB(55, 55, 55) end
    end)
    viewToggle.MouseLeave:Connect(function()
        if not viewEnabled then viewToggle.BackgroundColor3 = Color3.fromRGB(35, 35, 35) end
    end)

    viewToggle.MouseButton1Click:Connect(function()
        viewEnabled = not viewEnabled
        viewToggle.Text = "👁️ View: " .. (viewEnabled and "ON" or "OFF")
        viewToggle.BackgroundColor3 = viewEnabled and COLORS.Red or Color3.fromRGB(35, 35, 35)
        updateCamera()
    end)

    local selectBar = Instance.new("TextButton")
    selectBar.Size = UDim2.new(0.65, 0, 0, 34)
    selectBar.Position = UDim2.new(0.27, 0, 0.05, 0)
    selectBar.Text = "Selecionar jogador"
    selectBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    selectBar.TextColor3 = COLORS.White
    selectBar.Font = Enum.Font.Gotham
    selectBar.TextScaled = true
    selectBar.BorderSizePixel = 0
    selectBar.Parent = principalTab

    local selCorner = Instance.new("UICorner")
    selCorner.CornerRadius = UDim.new(0, 10)
    selCorner.Parent = selectBar

    selectBar.MouseEnter:Connect(function()
        selectBar.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    end)
    selectBar.MouseLeave:Connect(function()
        selectBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    end)

    sidebarBtns.selectBar = selectBar

    dropdownFrame = Instance.new("Frame")
    dropdownFrame.Size = UDim2.new(0.8, 0, 0.22, 0)
    dropdownFrame.Position = UDim2.new(0.1, 0, 0.16, 0)
    dropdownFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
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

    local teleLabel = Instance.new("TextLabel")
    teleLabel.Size = UDim2.new(0.12, 0, 0, 34)
    teleLabel.Position = UDim2.new(0.05, 0, 0.40, 0)
    teleLabel.Text = "📌 Tele:"
    teleLabel.TextColor3 = COLORS.White
    teleLabel.BackgroundTransparency = 1
    teleLabel.Font = Enum.Font.GothamBold
    teleLabel.TextScaled = true
    teleLabel.Parent = principalTab

    local teleportBar = Instance.new("TextButton")
    teleportBar.Size = UDim2.new(0.65, 0, 0, 34)
    teleportBar.Position = UDim2.new(0.20, 0, 0.40, 0)
    teleportBar.Text = "Jogador"
    teleportBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    teleportBar.TextColor3 = COLORS.White
    teleportBar.Font = Enum.Font.Gotham
    teleportBar.TextScaled = true
    teleportBar.BorderSizePixel = 0
    teleportBar.Parent = principalTab

    local tpCorner = Instance.new("UICorner")
    tpCorner.CornerRadius = UDim.new(0, 10)
    tpCorner.Parent = teleportBar

    teleportBar.MouseEnter:Connect(function()
        teleportBar.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    end)
    teleportBar.MouseLeave:Connect(function()
        teleportBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    end)

    sidebarBtns.teleportBar = teleportBar

    teleDropdownFrame = Instance.new("Frame")
    teleDropdownFrame.Size = UDim2.new(0.8, 0, 0.22, 0)
    teleDropdownFrame.Position = UDim2.new(0.1, 0, 0.48, 0)
    teleDropdownFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
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

    local armasTab = Instance.new("Frame")
    armasTab.Name = "Armas"
    armasTab.Size = UDim2.new(1, 0, 1, 0)
    armasTab.BackgroundTransparency = 1
    armasTab.Visible = false
    armasTab.Parent = mainArea

    local giveAllBtn = Instance.new("TextButton")
    giveAllBtn.Size = UDim2.new(0.6, 0, 0.35, 0)
    giveAllBtn.Position = UDim2.new(0.2, 0, 0.33, 0)
    giveAllBtn.Text = "Pegar Todos Itens"
    giveAllBtn.BackgroundColor3 = COLORS.Red
    giveAllBtn.TextColor3 = COLORS.White
    giveAllBtn.Font = Enum.Font.GothamBold
    giveAllBtn.TextScaled = true
    giveAllBtn.BorderSizePixel = 0
    giveAllBtn.Parent = armasTab

    local gaCorner = Instance.new("UICorner")
    gaCorner.CornerRadius = UDim.new(0, 14)
    gaCorner.Parent = giveAllBtn

    local gaStroke = Instance.new("UIStroke")
    gaStroke.Color = COLORS.NeonRed
    gaStroke.Thickness = 2
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
        local giveAllRemote = game:GetService("ReplicatedStorage"):FindFirstChild("GiveAllItems")
        if giveAllRemote and giveAllRemote:IsA("RemoteEvent") then
            giveAllRemote:FireServer(LocalPlayer)
        else
            local function grabFrom(loc)
                for _, obj in ipairs(loc:GetChildren()) do
                    if obj:IsA("Tool") then
                        obj:Clone().Parent = LocalPlayer.Backpack
                    end
                end
            end
            grabFrom(game:GetService("ReplicatedStorage"))
            if workspace:FindFirstChild("Itens") then
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
        wait(2)
        errorLabel.Visible = false
    end
end)
