local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local corPreta = Color3.fromHex("0A0A0A")
local corNeon = Color3.fromRGB(255, 0, 0)
local corNeonEscuro = Color3.fromRGB(139, 0, 0)
local corBranca = Color3.fromRGB(255, 255, 255)

local function makeDraggable(frame, dragHandle)
    local dragging = false
    local dragStart, startPos

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    dragHandle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local function aplicarNeon(parent, tamanhoExtra, transparencia, cor, raio)
    local glow = Instance.new("Frame")
    glow.Size = UDim2.new(1, tamanhoExtra, 1, tamanhoExtra)
    glow.Position = UDim2.new(0, -tamanhoExtra/2, 0, -tamanhoExtra/2)
    glow.BackgroundColor3 = cor
    glow.BackgroundTransparency = transparencia
    glow.BorderSizePixel = 0
    glow.ZIndex = 1
    glow.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, raio)
    corner.Parent = glow

    parent.ZIndex = 2
    return glow
end

local function createRoundedFrame(parent, size, position, color, transparency, cornerRadius)
    local frame = Instance.new("Frame")
    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = color or corPreta
    frame.BackgroundTransparency = transparency or 0
    frame.BorderSizePixel = 0
    frame.ZIndex = 2
    frame.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, cornerRadius or 8)
    corner.Parent = frame

    return frame
end

local function createTextLabel(parent, text, size, position, color, font, textSize, transparency)
    local label = Instance.new("TextLabel")
    label.Size = size
    label.Position = position
    label.BackgroundTransparency = transparency or 1
    label.Text = text
    label.TextColor3 = color or corBranca
    label.TextScaled = false
    label.TextSize = textSize or 16
    label.Font = font or Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.ZIndex = 3
    label.Parent = parent
    return label
end

local function createTextButton(parent, text, size, position, color, textColor, font, textSize)
    local btn = Instance.new("TextButton")
    btn.Size = size
    btn.Position = position
    btn.BackgroundColor3 = color or corNeon
    btn.BackgroundTransparency = 0
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = textColor or corBranca
    btn.TextScaled = false
    btn.TextSize = textSize or 16
    btn.Font = font or Enum.Font.GothamBold
    btn.ZIndex = 2
    btn.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    aplicarNeon(btn, 14, 0.7, corNeon, 10)
    aplicarNeon(btn, 8, 0.5, corNeon, 8)

    return btn
end

local function createTextBox(parent, placeholder, size, position, color, textColor, font, textSize)
    local box = Instance.new("TextBox")
    box.Size = size
    box.Position = position
    box.BackgroundColor3 = color or corBranca
    box.BackgroundTransparency = 0.15
    box.BorderSizePixel = 0
    box.PlaceholderText = placeholder or "Digite sua chave..."
    box.Text = ""
    box.TextColor3 = textColor or corPreta
    box.TextScaled = false
    box.TextSize = textSize or 16
    box.Font = font or Enum.Font.Gotham
    box.ClearTextOnFocus = false
    box.ZIndex = 2
    box.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = box

    aplicarNeon(box, 6, 0.8, corNeon, 10)
    return box
end

local function createToggle(parent, text, size, position, callback)
    local frame = Instance.new("Frame")
    frame.Size = size
    frame.Position = position
    frame.BackgroundTransparency = 1
    frame.ZIndex = 3
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = corBranca
    label.TextScaled = false
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 3
    label.Parent = frame

    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(0, 44, 0, 22)
    toggleFrame.Position = UDim2.new(1, -44, 0.5, -11)
    toggleFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    toggleFrame.BorderSizePixel = 0
    toggleFrame.ZIndex = 3
    toggleFrame.Parent = frame

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleFrame

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = UDim2.new(0, 2, 0.5, -9)
    knob.BackgroundColor3 = corBranca
    knob.BorderSizePixel = 0
    knob.ZIndex = 4
    knob.Parent = toggleFrame

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local ativado = false

    local function atualizarVisual()
        if ativado then
            TweenService:Create(toggleFrame, TweenInfo.new(0.2), {BackgroundColor3 = corNeon}):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {Position = UDim2.new(1, -20, 0.5, -9)}):Play()
        else
            TweenService:Create(toggleFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -9)}):Play()
        end
    end

    toggleFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            ativado = not ativado
            atualizarVisual()
            if callback then
                callback(ativado)
            end
        end
    end)

    return frame
end

-- NOVO: Criador do seletor de jogadores
local function createPlayerSelector(parent, yPos)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 35)
    container.Position = UDim2.new(0, 10, 0, yPos)
    container.BackgroundTransparency = 1
    container.ZIndex = 3
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = "Jogador"
    label.TextColor3 = corBranca
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 3
    label.Parent = container

    local visor = Instance.new("TextButton")
    visor.Size = UDim2.new(0, 150, 0, 30)
    visor.Position = UDim2.new(1, -150, 0.5, -15)
    visor.BackgroundColor3 = corPreta
    visor.BackgroundTransparency = 0.2
    visor.BorderSizePixel = 0
    visor.Text = "Selecionar..."
    visor.TextColor3 = corBranca
    visor.TextSize = 13
    visor.Font = Enum.Font.Gotham
    visor.ZIndex = 3
    visor.Parent = container

    local visorCorner = Instance.new("UICorner")
    visorCorner.CornerRadius = UDim.new(0, 6)
    visorCorner.Parent = visor
    aplicarNeon(visor, 6, 0.7, corNeon, 10)

    local dropDown = Instance.new("Frame")
    dropDown.Size = UDim2.new(0, 150, 0, 150)
    dropDown.Position = UDim2.new(1, -150, 1, 5)
    dropDown.BackgroundColor3 = corPreta
    dropDown.BackgroundTransparency = 0.1
    dropDown.BorderSizePixel = 0
    dropDown.Visible = false
    dropDown.ZIndex = 5
    dropDown.Parent = container

    local dropCorner = Instance.new("UICorner")
    dropCorner.CornerRadius = UDim.new(0, 6)
    dropCorner.Parent = dropDown
    aplicarNeon(dropDown, 8, 0.6, corNeon, 12)

    local scrollingList = Instance.new("ScrollingFrame")
    scrollingList.Size = UDim2.new(1, -4, 1, -4)
    scrollingList.Position = UDim2.new(0, 2, 0, 2)
    scrollingList.BackgroundTransparency = 1
    scrollingList.BorderSizePixel = 0
    scrollingList.ScrollBarThickness = 2
    scrollingList.ScrollBarImageColor3 = corNeon
    scrollingList.ZIndex = 6
    scrollingList.Parent = dropDown

    local function updateList()
        for _, child in pairs(scrollingList:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end

        local y = 0
        for _, p in pairs(Players:GetPlayers()) do
            if p.Name ~= player.Name then -- Opção: ignorar o próprio jogador
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, 0, 0, 25)
                btn.Position = UDim2.new(0, 0, 0, y)
                btn.BackgroundTransparency = 1
                btn.Text = p.Name
                btn.TextColor3 = corBranca
                btn.TextSize = 13
                btn.Font = Enum.Font.Gotham
                btn.ZIndex = 7
                btn.Parent = scrollingList

                btn.MouseButton1Click:Connect(function()
                    visor.Text = p.Name
                    dropDown.Visible = false
                end)
                y = y + 25
            end
        end
        
        scrollingList.CanvasSize = UDim2.new(0, 0, 0, y)
        
        if y == 0 then
            local lb = Instance.new("TextLabel")
            lb.Size = UDim2.new(1, 0, 1, 0)
            lb.Position = UDim2.new(0, 0, 0, 0)
            lb.BackgroundTransparency = 1
            lb.Text = "Nenhum jogador"
            lb.TextColor3 = Color3.fromRGB(150, 150, 150)
            lb.TextSize = 13
            lb.Font = Enum.Font.Gotham
            lb.ZIndex = 7
            lb.Parent = scrollingList
        end
    end

    visor.MouseButton1Click:Connect(function()
        dropDown.Visible = not dropDown.Visible
        if dropDown.Visible then updateList() end
    end)

    return container
end

local screenGui = Instance.new("ScreenGui")
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local keyFrame = createRoundedFrame(screenGui, UDim2.new(0, 340, 0, 220), UDim2.new(0.5, -170, 0.5, -110), corPreta, 0, 12)
aplicarNeon(keyFrame, 16, 0.65, corNeon, 16)
aplicarNeon(keyFrame, 8, 0.45, corNeon, 14)

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = corNeonEscuro
titleBar.BackgroundTransparency = 0
titleBar.BorderSizePixel = 0
titleBar.ZIndex = 3
titleBar.Parent = keyFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

createTextLabel(titleBar, "🔐 VERIFICAÇÃO", UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), corBranca, Enum.Font.GothamBold, 16)
createTextLabel(keyFrame, "Insira sua chave para continuar", UDim2.new(1, -30, 0, 25), UDim2.new(0, 15, 0, 42), corBranca, Enum.Font.Gotham, 13)

local keyBox = createTextBox(keyFrame, "Digite sua chave...", UDim2.new(1, -30, 0, 38), UDim2.new(0, 15, 0, 74), Color3.fromRGB(30,30,30), corBranca, Enum.Font.Gotham, 15)
local verifyBtn = createTextButton(keyFrame, "VERIFICAR", UDim2.new(1, -30, 0, 40), UDim2.new(0, 15, 0, 125), corNeon, corBranca, Enum.Font.GothamBold, 16)

local linkLabel = Instance.new("TextLabel")
linkLabel.Size = UDim2.new(1, -30, 0, 20)
linkLabel.Position = UDim2.new(0, 15, 0, 178)
linkLabel.BackgroundTransparency = 1
linkLabel.Text = "Não tem chave? Contate o criador"
linkLabel.TextColor3 = corNeonEscuro
linkLabel.TextScaled = false
linkLabel.TextSize = 12
linkLabel.Font = Enum.Font.Gotham
linkLabel.TextXAlignment = Enum.TextXAlignment.Center
linkLabel.TextYAlignment = Enum.TextYAlignment.Center
linkLabel.ZIndex = 3
linkLabel.Parent = keyFrame

makeDraggable(keyFrame, titleBar)

local floatBtn = Instance.new("TextButton")
floatBtn.Size = UDim2.new(0, 55, 0, 55)
floatBtn.Position = UDim2.new(1, -75, 1, -85)
floatBtn.BackgroundTransparency = 1
floatBtn.Text = "🔥"
floatBtn.TextSize = 45
floatBtn.Font = Enum.Font.GothamBold
floatBtn.TextColor3 = corBranca
floatBtn.ZIndex = 3
floatBtn.Parent = screenGui
floatBtn.Visible = false

makeDraggable(floatBtn, floatBtn)

local mainFrame = createRoundedFrame(screenGui, UDim2.new(0, 580, 0, 420), UDim2.new(0.5, -290, 0.5, -210), corPreta, 0, 12)
mainFrame.Visible = false
aplicarNeon(mainFrame, 16, 0.65, corNeon, 16)
aplicarNeon(mainFrame, 8, 0.45, corNeon, 14)

local mainTitleBar = Instance.new("Frame")
mainTitleBar.Size = UDim2.new(1, 0, 0, 32)
mainTitleBar.Position = UDim2.new(0, 0, 0, 0)
mainTitleBar.BackgroundColor3 = corNeonEscuro
mainTitleBar.BackgroundTransparency = 0
mainTitleBar.BorderSizePixel = 0
mainTitleBar.ZIndex = 3
mainTitleBar.Parent = mainFrame

local mainTitleCorner = Instance.new("UICorner")
mainTitleCorner.CornerRadius = UDim.new(0, 12)
mainTitleCorner.Parent = mainTitleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(0, 200, 1, 0)
titleText.Position = UDim2.new(0, 15, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "FIRE HUB"
titleText.TextColor3 = corBranca
titleText.TextSize = 18
titleText.Font = Enum.Font.GothamBold
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.TextYAlignment = Enum.TextYAlignment.Center
titleText.ZIndex = 3
titleText.Parent = mainTitleBar

makeDraggable(mainFrame, mainTitleBar)

local tabPanel = Instance.new("Frame")
tabPanel.Size = UDim2.new(0, 120, 1, -42)
tabPanel.Position = UDim2.new(0, 0, 0, 42)
tabPanel.BackgroundColor3 = Color3.fromHex("141414")
tabPanel.BackgroundTransparency = 0
tabPanel.BorderSizePixel = 0
tabPanel.ZIndex = 2
tabPanel.Parent = mainFrame

local tabPanelCorner = Instance.new("UICorner")
tabPanelCorner.CornerRadius = UDim.new(0, 12)
tabPanelCorner.Parent = tabPanel

contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, -130, 1, -52)
contentArea.Position = UDim2.new(0, 125, 0, 47)
contentArea.BackgroundTransparency = 1
contentArea.ZIndex = 3
contentArea.Parent = mainFrame

local tabs = {"ℹ️ Inf", "🔥 Principal", "🎨 Visual", "🧍 Jogador", "🌍 Mundo", "⚔️ Combate", "🏃 Movimento", "📦 Outros", "⚙️ Config"}
local tabButtons = {}
local selectedTab = "ℹ️ Inf"

local function updateContent(tabName)
    for _, child in pairs(contentArea:GetChildren()) do
        child:Destroy()
    end

    if tabName == "ℹ️ Inf" then
        -- Imagem removida e textos centralizados
        local criador = Instance.new("TextLabel")
        criador.Size = UDim2.new(1, -20, 0, 30)
        criador.Position = UDim2.new(0, 10, 0, 30)
        criador.BackgroundTransparency = 1
        criador.Text = "Criado por kkscript"
        criador.TextColor3 = corBranca
        criador.TextSize = 16
        criador.Font = Enum.Font.GothamBold
        criador.ZIndex = 3
        criador.Parent = contentArea

        local desc1 = Instance.new("TextLabel")
        desc1.Size = UDim2.new(1, -20, 0, 25)
        desc1.Position = UDim2.new(0, 10, 0, 70)
        desc1.BackgroundTransparency = 1
        desc1.Text = "Este script está em desenvolvimento"
        desc1.TextColor3 = Color3.fromRGB(200, 200, 200)
        desc1.TextSize = 14
        desc1.Font = Enum.Font.Gotham
        desc1.ZIndex = 3
        desc1.Parent = contentArea

        local desc2 = Instance.new("TextLabel")
        desc2.Size = UDim2.new(1, -20, 0, 20)
        desc2.Position = UDim2.new(0, 10, 0, 100)
        desc2.BackgroundTransparency = 1
        desc2.Text = "esse não é o produto completo"
        desc2.TextColor3 = Color3.fromRGB(200, 200, 200)
        desc2.TextSize = 14
        desc2.Font = Enum.Font.Gotham
        desc2.ZIndex = 3
        desc2.Parent = contentArea

    elseif tabName == "🔥 Principal" then
        -- NOVO: Seletor de jogadores na primeira opção
        createPlayerSelector(contentArea, 10)

        -- Toggles deslocados para baixo
        local funcs = {"Auto Farm", "Auto Quest", "Auto Boss", "Coletar Itens"}
        for i, name in ipairs(funcs) do
            local yPos = 55 + (i-1)*40
            createToggle(contentArea, name, UDim2.new(1, -20, 0, 35), UDim2.new(0, 10, 0, yPos), function(ativado)
                print(name, ativado and "LIGADO" or "DESLIGADO")
            end)
        end

        createTextLabel(contentArea, "TELEPORTE", UDim2.new(1, 0, 0, 25), UDim2.new(0, 10, 0, 225), corBranca, Enum.Font.GothamBold, 14)
        createTextButton(contentArea, "TELEPORTAR", UDim2.new(1, -20, 0, 35), UDim2.new(0, 10, 0, 255), corNeon, corBranca, Enum.Font.GothamBold, 14)
    else
        createTextLabel(contentArea, tabName, UDim2.new(1, 0, 0, 30), UDim2.new(0, 10, 0, 10), corBranca, Enum.Font.GothamBold, 18)
        createTextLabel(contentArea, "Conteúdo em desenvolvimento...", UDim2.new(1, 0, 0, 20), UDim2.new(0, 10, 0, 50), corBranca, Enum.Font.Gotham, 14)
    end
end

local function selectTab(tabName)
    for _, btn in pairs(tabButtons) do
        local ind = btn:FindFirstChild("Indicator")
        if ind then
            if btn.Text == tabName then
                ind.BackgroundTransparency = 0
                btn.TextColor3 = corBranca
            else
                ind.BackgroundTransparency = 1
                btn.TextColor3 = Color3.fromRGB(150, 150, 150)
            end
        end
    end
    selectedTab = tabName
    updateContent(tabName)
end

local function createTabButton(text, yPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -12, 0, 30)
    btn.Position = UDim2.new(0, 6, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.BackgroundTransparency = 0
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    btn.TextScaled = false
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.ZIndex = 3
    btn.Parent = tabPanel

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    local indicator = Instance.new("Frame")
    indicator.Name = "Indicator"
    indicator.Size = UDim2.new(0, 3, 1, -8)
    indicator.Position = UDim2.new(0, 2, 0, 4)
    indicator.BackgroundColor3 = corNeon
    indicator.BackgroundTransparency = 1
    indicator.BorderSizePixel = 0
    indicator.ZIndex = 4
    indicator.Parent = btn

    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(0, 2)
    indicatorCorner.Parent = indicator

    btn.MouseButton1Click:Connect(function()
        selectTab(text)
    end)

    return btn
end

for i, tab in ipairs(tabs) do
    local yPos = 10 + (i-1)*36
    local btn = createTabButton(tab, yPos)
    tabButtons[#tabButtons+1] = btn
end

selectTab("ℹ️ Inf")

verifyBtn.MouseButton1Click:Connect(function()
    local rawInput = keyBox.Text
    local trimmedInput = rawInput:match("^%s*(.-)%s*$")
    if trimmedInput then trimmedInput = trimmedInput:lower() end

    if trimmedInput == "menu k" or trimmedInput == "menuk" then
        keyBox.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        TweenService:Create(keyBox, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        TweenService:Create(keyBox, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(30,30,30)}):Play()

        keyFrame.Visible = false
        floatBtn.Visible = true
        mainFrame.Visible = false
    else
        keyBox.BackgroundColor3 = corNeonEscuro
        TweenService:Create(keyBox, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(30,30,30)}):Play()
        keyBox.PlaceholderText = "Chave inválida!"
        task.wait(1)
        keyBox.PlaceholderText = "Digite sua chave..."
    end
end)

keyBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        verifyBtn.MouseButton1Click:Fire()
    end
end)

local menuAberto = false
floatBtn.MouseButton1Click:Connect(function()
    menuAberto = not menuAberto
    mainFrame.Visible = menuAberto
end)

keyFrame.Visible = true
floatBtn.Visible = false
mainFrame.Visible = false
