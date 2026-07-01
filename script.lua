local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local corPreta = Color3.fromHex("0A0A0A")
local corNeon = Color3.fromRGB(255, 0, 0)
local corNeonEscuro = Color3.fromRGB(139, 0, 0)
local corBranca = Color3.fromRGB(255, 255, 255)
local corCinza = Color3.fromRGB(60, 60, 60)

local mainFrame = nil
local audioStorage = {}
local soundObj = nil

-- ==========================================
-- CRIAÇÃO DA SCREENGUI GLOBAL (AGORA NO INÍCIO)
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FireHubUI"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 9999
screenGui.Parent = playerGui

-- ==========================================
-- FUNÇÕES BÁSICAS DE CRIAÇÃO DE UI
-- ==========================================

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
    local toggleFrame = Instance.new("TextButton")
    toggleFrame.Size = UDim2.new(0, 44, 0, 22)
    toggleFrame.Position = UDim2.new(1, -44, 0.5, -11)
    toggleFrame.BackgroundColor3 = corCinza
    toggleFrame.Text = ""
    toggleFrame.AutoButtonColor = false
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
            TweenService:Create(toggleFrame, TweenInfo.new(0.2), {BackgroundColor3 = corCinza}):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -9)}):Play()
        end
    end
    atualizarVisual()
    toggleFrame.MouseButton1Click:Connect(function()
        ativado = not ativado
        atualizarVisual()
        if callback then callback(ativado) end
    end)
    return frame
end

local function createActionButton(parent, text, size, position, callback)
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
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 44, 0, 22)
    btn.Position = UDim2.new(1, -44, 0.5, -11)
    btn.BackgroundColor3 = corNeonEscuro
    btn.Text = ">"
    btn.TextColor3 = corBranca
    btn.TextSize = 16
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.ZIndex = 3
    btn.Parent = frame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = btn
    btn.MouseButton1Click:Connect(callback)
    return frame
end

-- ==========================================
-- SELETOR DE JOGADORES (USANDO SCREENGUI GLOBAL)
-- ==========================================

local function createPlayerSelector(parent, yPos)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 55)
    container.Position = UDim2.new(0, 10, 0, yPos)
    container.BackgroundTransparency = 1
    container.ZIndex = 10
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = "Jogador"
    label.TextColor3 = corBranca
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 3
    label.Parent = container

    local visor = Instance.new("TextButton")
    visor.Size = UDim2.new(0, 220, 0, 38)
    visor.Position = UDim2.new(1, -220, 0.5, -19)
    visor.BackgroundColor3 = corPreta
    visor.BackgroundTransparency = 0.2
    visor.BorderSizePixel = 0
    visor.Text = "Selecionar..."
    visor.TextColor3 = corBranca
    visor.TextSize = 14
    visor.Font = Enum.Font.GothamBold
    visor.ZIndex = 10
    visor.Parent = container

    local stroke = Instance.new("UIStroke")
    stroke.Color = corNeon
    stroke.Thickness = 2
    stroke.Transparency = 0
    stroke.Parent = visor

    local visorCorner = Instance.new("UICorner")
    visorCorner.CornerRadius = UDim.new(0, 8)
    visorCorner.Parent = visor
    aplicarNeon(visor, 4, 0.8, corNeon, 10)

    local dropDown = Instance.new("Frame")
    dropDown.Size = UDim2.new(0, 220, 0, 200)
    dropDown.BackgroundColor3 = corPreta
    dropDown.BackgroundTransparency = 0.1
    dropDown.BorderSizePixel = 0
    dropDown.Visible = false
    dropDown.ZIndex = 999
    dropDown.Parent = screenGui

    local dropCorner = Instance.new("UICorner")
    dropCorner.CornerRadius = UDim.new(0, 8)
    dropCorner.Parent = dropDown
    aplicarNeon(dropDown, 8, 0.6, corNeon, 12)

    local scrollingList = Instance.new("ScrollingFrame")
    scrollingList.Size = UDim2.new(1, -10, 1, -10)
    scrollingList.Position = UDim2.new(0, 5, 0, 5)
    scrollingList.BackgroundTransparency = 1
    scrollingList.BorderSizePixel = 0
    scrollingList.ScrollBarThickness = 4
    scrollingList.ScrollBarImageColor3 = corNeon
    scrollingList.ZIndex = 1000
    scrollingList.Parent = dropDown

    -- CORREÇÃO: desativar Active para permitir cliques nos botões filhos
    scrollingList.Active = false

    local function updateList()
        for _, child in ipairs(scrollingList:GetChildren()) do
            child:Destroy()
        end

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 4)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = scrollingList

        local totalHeight = 0
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Name ~= player.Name then
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, -10, 0, 25)
                btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                btn.Text = p.Name
                btn.TextColor3 = corBranca
                btn.TextSize = 14
                btn.Font = Enum.Font.Gotham
                btn.Parent = scrollingList

                btn.MouseButton1Click:Connect(function()
                    visor.Text = p.Name
                    dropDown.Visible = false
                end)

                totalHeight = totalHeight + 29
            end
        end

        scrollingList.CanvasSize = UDim2.new(0, 0, 0, math.max(totalHeight, 10))
    end

    visor.MouseButton1Click:Connect(function()
        dropDown.Visible = not dropDown.Visible
        if dropDown.Visible then
            local absPos = visor.AbsolutePosition
            local absSize = visor.AbsoluteSize
            dropDown.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 5)
            updateList()
        end
    end)

    local function refreshOnChange()
        if dropDown.Visible then updateList() end
    end
    Players.PlayerAdded:Connect(refreshOnChange)
    Players.PlayerRemoving:Connect(refreshOnChange)

    return container
end

-- ==========================================
-- SELETOR DE MÉTODO (MESMA CORREÇÃO)
-- ==========================================

local function createMethodSelector(parent, yPos)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 55)
    container.Position = UDim2.new(0, 10, 0, yPos)
    container.BackgroundTransparency = 1
    container.ZIndex = 10
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = "Método"
    label.TextColor3 = corBranca
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 3
    label.Parent = container

    local visor = Instance.new("TextButton")
    visor.Size = UDim2.new(0, 220, 0, 38)
    visor.Position = UDim2.new(1, -220, 0.5, -19)
    visor.BackgroundColor3 = corPreta
    visor.BackgroundTransparency = 0.2
    visor.BorderSizePixel = 0
    visor.Text = "Selecionar..."
    visor.TextColor3 = corBranca
    visor.TextSize = 14
    visor.Font = Enum.Font.GothamBold
    visor.ZIndex = 10
    visor.Parent = container

    local stroke = Instance.new("UIStroke")
    stroke.Color = corNeon
    stroke.Thickness = 2
    stroke.Transparency = 0
    stroke.Parent = visor

    local visorCorner = Instance.new("UICorner")
    visorCorner.CornerRadius = UDim.new(0, 8)
    visorCorner.Parent = visor
    aplicarNeon(visor, 4, 0.8, corNeon, 10)

    local dropDown = Instance.new("Frame")
    dropDown.Size = UDim2.new(0, 220, 0, 110)
    dropDown.BackgroundColor3 = corPreta
    dropDown.BackgroundTransparency = 0.1
    dropDown.BorderSizePixel = 0
    dropDown.Visible = false
    dropDown.ZIndex = 999
    dropDown.Parent = screenGui

    local dropCorner = Instance.new("UICorner")
    dropCorner.CornerRadius = UDim.new(0, 8)
    dropCorner.Parent = dropDown
    aplicarNeon(dropDown, 8, 0.6, corNeon, 12)

    local list = Instance.new("Frame")
    list.Size = UDim2.new(1, -4, 1, -4)
    list.Position = UDim2.new(0, 2, 0, 2)
    list.BackgroundTransparency = 1
    list.BorderSizePixel = 0
    list.ZIndex = 1000
    list.Parent = dropDown

    local y = 0
    local methods = {"ball", "bus", "boat"}
    for _, m in ipairs(methods) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 28)
        btn.Position = UDim2.new(0, 0, 0, y)
        btn.BackgroundTransparency = 1
        btn.Text = m
        btn.TextColor3 = corBranca
        btn.TextSize = 14
        btn.Font = Enum.Font.GothamBold
        btn.ZIndex = 1001
        btn.Parent = list
        btn.MouseButton1Click:Connect(function()
            visor.Text = m
            dropDown.Visible = false
        end)
        y = y + 30
    end

    visor.MouseButton1Click:Connect(function()
        dropDown.Visible = not dropDown.Visible
        if dropDown.Visible then
            local absPos = visor.AbsolutePosition
            local absSize = visor.AbsoluteSize
            dropDown.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 5)
        end
    end)

    return container
end

-- ==========================================
-- CRIAÇÃO DA INTERFACE E TELA DE LOGIN
-- ==========================================

local keyFrame = createRoundedFrame(screenGui, UDim2.new(0, 340, 0, 220), UDim2.new(0.5, -170, 0.5, -110), corPreta, 0, 12)
keyFrame.ZIndex = 999
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

mainFrame = createRoundedFrame(screenGui, UDim2.new(0, 580, 0, 420), UDim2.new(0.5, -290, 0.5, -210), corPreta, 0, 12)
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
tabPanel.Parent = mainFrame

local tabPanelCorner = Instance.new("UICorner")
tabPanelCorner.CornerRadius = UDim.new(0, 12)
tabPanelCorner.Parent = tabPanel

local contentArea = Instance.new("ScrollingFrame")
contentArea.Size = UDim2.new(1, -130, 1, -52)
contentArea.Position = UDim2.new(0, 125, 0, 47)
contentArea.BackgroundTransparency = 1
contentArea.BorderSizePixel = 0
contentArea.ScrollBarThickness = 4
contentArea.ScrollBarImageColor3 = corNeon
contentArea.CanvasSize = UDim2.new(0, 0, 0, 500)
contentArea.ZIndex = 3
contentArea.Parent = mainFrame

-- CORREÇÃO PRINCIPAL: desativa o Active para permitir cliques nos botões internos
contentArea.Active = false

local tabs = {"ℹ️ Inf", "🔥 Principal", "👤 Avatar", "🔊 Áudio", "⚔️ Combate", "🏃 Movimento", "📦 Outros", "⚡ Jogador", "⚙️ Config"}
local tabButtons = {}
local selectedTab = "ℹ️ Inf"

local function updateContent(tabName)
    for _, child in pairs(contentArea:GetChildren()) do
        child:Destroy()
    end

    if tabName == "ℹ️ Inf" then
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
        
        contentArea.CanvasSize = UDim2.new(0, 0, 0, 150)

    elseif tabName == "🔥 Principal" then
        createPlayerSelector(contentArea, 10)
        createMethodSelector(contentArea, 68)

        local toggleSize = UDim2.new(1, -20, 0, 28)
        local yBase = 140 

        createActionButton(contentArea, "Kill", toggleSize, UDim2.new(0, 10, 0, yBase), function()
            local containers = contentArea:GetChildren()
            local targetName = "Selecionar..."
            for _, c in ipairs(containers) do
                if c:IsA("Frame") and c:FindFirstChild("TextButton") then
                    local v = c:FindFirstChild("TextButton")
                    if v and v.Text ~= "Selecionar..." and v.Text ~= "" then
                        targetName = v.Text
                        break
                    end
                end
            end
            if targetName == "Selecionar..." then return end
            local targetPlayer = Players:FindFirstChild(targetName)
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") then
                targetPlayer.Character.Humanoid.Health = 0
            end
        end)

        createToggle(contentArea, "Fling", toggleSize, UDim2.new(0, 10, 0, yBase + 35), function(ativado)
            print("Fling Ativado:", ativado)
        end)

        createToggle(contentArea, "black hole", toggleSize, UDim2.new(0, 10, 0, yBase + 70), function(ativado)
            print("Black Hole Ativado:", ativado)
        end)

        createToggle(contentArea, "View", toggleSize, UDim2.new(0, 10, 0, yBase + 105), function(ativado)
            print("View Ativado:", ativado)
        end)

        createActionButton(contentArea, "Teleport", toggleSize, UDim2.new(0, 10, 0, yBase + 140), function()
            local containers = contentArea:GetChildren()
            local targetName = "Selecionar..."
            for _, c in ipairs(containers) do
                if c:IsA("Frame") and c:FindFirstChild("TextButton") then
                    local v = c:FindFirstChild("TextButton")
                    if v and v.Text ~= "Selecionar..." and v.Text ~= "" then
                        targetName = v.Text
                        break
                    end
                end
            end
            if targetName == "Selecionar..." then return end
            local targetPlayer = Players:FindFirstChild(targetName)
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local localChar = player.Character
                if localChar and localChar:FindFirstChild("HumanoidRootPart") then
                    localChar.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
                end
            end
        end)

        contentArea.CanvasSize = UDim2.new(0, 0, 0, yBase + 180)

    elseif tabName == "👤 Avatar" then
        createPlayerSelector(contentArea, 10)
        
        createActionButton(contentArea, "Copy avatar", UDim2.new(1, -20, 0, 28), UDim2.new(0, 10, 0, 75), function()
            local containers = contentArea:GetChildren()
            local targetName = "Selecionar..."
            for _, c in ipairs(containers) do
                if c:IsA("Frame") and c:FindFirstChild("TextButton") then
                    local v = c:FindFirstChild("TextButton")
                    if v and v.Text ~= "Selecionar..." and v.Text ~= "" then
                        targetName = v.Text
                        break
                    end
                end
            end
            if targetName == "Selecionar..." then return end
            print("Copiando avatar do jogador:", targetName)
        end)
        
        contentArea.CanvasSize = UDim2.new(0, 0, 0, 150)

    elseif tabName == "🔊 Áudio" then
        local audioBox = createTextBox(contentArea, "Insira o ID...", UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, 10), corPreta, corBranca, Enum.Font.Gotham, 14)
        
        local arquivoContainer = createRoundedFrame(contentArea, UDim2.new(1, -20, 0, 120), UDim2.new(0, 10, 0, 50), corPreta, 0.1, 8)
        local listFrame = Instance.new("ScrollingFrame")
        listFrame.Size = UDim2.new(1, -10, 1, -10)
        listFrame.Position = UDim2.new(0, 5, 0, 5)
        listFrame.BackgroundTransparency = 1
        listFrame.BorderSizePixel = 0
        listFrame.ScrollBarThickness = 4
        listFrame.ScrollBarImageColor3 = corNeon
        listFrame.Parent = arquivoContainer
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 2)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = listFrame
        
        local function updateAudioList()
            for _, child in ipairs(listFrame:GetChildren()) do
                if child:IsA("TextLabel") then child:Destroy() end
            end
            for _, id in ipairs(audioStorage) do
                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1, -10, 0, 20)
                lbl.BackgroundTransparency = 1
                lbl.Text = id
                lbl.TextColor3 = corBranca
                lbl.TextSize = 13
                lbl.Parent = listFrame
            end
        end

        createActionButton(contentArea, "Save", UDim2.new(1, -20, 0, 28), UDim2.new(0, 10, 0, 185), function()
            local id = audioBox.Text
            if id and id ~= "" then
                table.insert(audioStorage, id)
                updateAudioList()
                audioBox.Text = ""
            end
        end)

        createToggle(contentArea, "Tocar", UDim2.new(1, -20, 0, 28), UDim2.new(0, 10, 0, 220), function(ativado)
            if ativado then
                local id = audioBox.Text
                if id and id ~= "" then
                    if soundObj then soundObj:Destroy() end
                    soundObj = Instance.new("Sound")
                    soundObj.SoundId = "rbxassetid://" .. id
                    soundObj.Looped = true
                    soundObj.Parent = SoundService
                    soundObj:Play()
                end
            else
                if soundObj then
                    soundObj:Stop()
                    soundObj:Destroy()
                    soundObj = nil
                end
            end
        end)
        
        updateAudioList()
        contentArea.CanvasSize = UDim2.new(0, 0, 0, 260)

    elseif tabName == "⚡ Jogador" then
        local function updatePlayerStats(stat, value)
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                local hum = player.Character:FindFirstChild("Humanoid")
                if stat == "Velocidade" then
                    hum.WalkSpeed = value
                elseif stat == "Pulo" then
                    hum.JumpPower = value
                elseif stat == "Gravidade" then
                    hum.UseJumpPower = false
                    hum.Gravity = value
                end
            end
        end

        local function createSlider(parent, text, yPos, defaultVal, minVal, maxVal, statName)
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, -20, 0, 40)
            frame.Position = UDim2.new(0, 10, 0, yPos)
            frame.BackgroundTransparency = 1
            frame.ZIndex = 3
            frame.Parent = parent

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.5, 0, 1, 0)
            label.Position = UDim2.new(0, 0, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = corBranca
            label.TextSize = 14
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.ZIndex = 3
            label.Parent = frame

            local valueDisplay = Instance.new("TextLabel")
            valueDisplay.Size = UDim2.new(0, 50, 0, 20)
            valueDisplay.Position = UDim2.new(1, -60, 0, 0)
            valueDisplay.BackgroundTransparency = 1
            valueDisplay.Text = tostring(defaultVal)
            valueDisplay.TextColor3 = corNeon
            valueDisplay.TextSize = 14
            valueDisplay.Font = Enum.Font.GothamBold
            valueDisplay.ZIndex = 3
            valueDisplay.Parent = frame

            local sliderFrame = Instance.new("Frame")
            sliderFrame.Size = UDim2.new(0, 120, 0, 8)
            sliderFrame.Position = UDim2.new(1, -190, 0.5, -4)
            sliderFrame.BackgroundColor3 = corCinza
            sliderFrame.BorderSizePixel = 0
            sliderFrame.Active = true 
            sliderFrame.ZIndex = 3
            sliderFrame.Parent = frame

            local sliderCorner = Instance.new("UICorner")
            sliderCorner.CornerRadius = UDim.new(1, 0)
            sliderCorner.Parent = sliderFrame

            local fillBar = Instance.new("Frame")
            fillBar.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
            fillBar.BackgroundColor3 = corNeon
            fillBar.BorderSizePixel = 0
            fillBar.ZIndex = 4
            fillBar.Parent = sliderFrame

            local fillCorner = Instance.new("UICorner")
            fillCorner.CornerRadius = UDim.new(1, 0)
            fillCorner.Parent = fillBar

            local sliderBtn = Instance.new("TextButton")
            sliderBtn.Size = UDim2.new(0, 20, 0, 20)
            sliderBtn.Position = UDim2.new((defaultVal - minVal) / (maxVal - minVal), -10, 0.5, -10)
            sliderBtn.BackgroundColor3 = corBranca
            sliderBtn.Text = ""
            sliderBtn.AutoButtonColor = false
            sliderBtn.BorderSizePixel = 0
            sliderBtn.ZIndex = 5
            sliderBtn.Parent = sliderFrame

            local sliderCornerBtn = Instance.new("UICorner")
            sliderCornerBtn.CornerRadius = UDim.new(1, 0)
            sliderCornerBtn.Parent = sliderBtn

            local dragging = false
            local currentVal = defaultVal

            local char = player.Character
            if char and char:FindFirstChild("Humanoid") then
                updatePlayerStats(statName, defaultVal)
            end

            sliderBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if not dragging then return end
                if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end

                local pos = input.Position.X
                local startX = sliderFrame.AbsolutePosition.X
                local sizeX = sliderFrame.AbsoluteSize.X

                local percent = math.clamp((pos - startX) / sizeX, 0, 1)
                currentVal = math.floor(minVal + percent * (maxVal - minVal))

                fillBar.Size = UDim2.new(percent, 0, 1, 0)
                sliderBtn.Position = UDim2.new(percent, -10, 0.5, -10)
                valueDisplay.Text = tostring(currentVal)

                updatePlayerStats(statName, currentVal)
            end)
        end

        createSlider(contentArea, "Velocidade", 10, 16, 0, 100, "Velocidade")
        createSlider(contentArea, "Pulo", 60, 50, 0, 300, "Pulo")
        createSlider(contentArea, "Gravidade", 110, 196, 0, 500, "Gravidade")

        contentArea.CanvasSize = UDim2.new(0, 0, 0, 180)

    else
        createTextLabel(contentArea, tabName, UDim2.new(1, 0, 0, 30), UDim2.new(0, 10, 0, 10), corBranca, Enum.Font.GothamBold, 18)
        createTextLabel(contentArea, "Conteúdo em desenvolvimento...", UDim2.new(1, 0, 0, 20), UDim2.new(0, 10, 0, 50), corBranca, Enum.Font.Gotham, 14)
        contentArea.CanvasSize = UDim2.new(0, 0, 0, 150)
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
    table.insert(tabButtons, btn)
end

selectTab("ℹ️ Inf")

verifyBtn.MouseButton1Click:Connect(function()
    local rawInput = keyBox.Text
    local trimmedInput = rawInput:match("^%s*(.-)%s*$")
    if trimmedInput then trimmedInput = trimmedInput:lower() end

    if trimmedInput == "menu k" or trimmedInput == "menuk" then
        keyBox.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
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
