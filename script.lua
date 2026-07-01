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

local function createFrame(parent, size, position, color, transparency, cornerRadius)
    local frame = Instance.new("Frame")
    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = color or corPreta
    frame.BackgroundTransparency = transparency or 0
    frame.BorderSizePixel = 0
    frame.ZIndex = 2
    frame.Parent = parent
    if cornerRadius then
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, cornerRadius)
        corner.Parent = frame
    end
    return frame
end

local function createTextLabel(parent, text, size, position, color, font, textSize, transparency)
    local label = Instance.new("TextLabel")
    label.Size = size
    label.Position = position
    label.BackgroundTransparency = transparency or 1
    label.Text = text
    label.TextColor3 = color or corBranca
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
    local frame = createFrame(parent, size, position, nil, 1)
    local label = createTextLabel(frame, text, UDim2.new(0.7, 0, 1, 0), UDim2.new(0, 0, 0, 0), corBranca, Enum.Font.Gotham, 14)
    label.TextXAlignment = Enum.TextXAlignment.Left

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
    local frame = createFrame(parent, size, position, nil, 1)
    local label = createTextLabel(frame, text, UDim2.new(0.7, 0, 1, 0), UDim2.new(0, 0, 0, 0), corBranca, Enum.Font.Gotham, 14)
    label.TextXAlignment = Enum.TextXAlignment.Left

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

local function createDropdown(parent, placeholder, items, yPos)
    local container = createFrame(parent, UDim2.new(1, -20, 0, 55), UDim2.new(0, 10, 0, yPos), nil, 1)
    
    local label = createTextLabel(container, placeholder, UDim2.new(0.4, 0, 1, 0), UDim2.new(0, 0, 0, 0), corBranca, Enum.Font.GothamBold, 16)
    label.TextXAlignment = Enum.TextXAlignment.Left

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
    dropDown.Size = UDim2.new(0, 220, 0, #items * 30 + 10)
    dropDown.BackgroundColor3 = corBranca
    dropDown.BackgroundTransparency = 0.0
    dropDown.BorderSizePixel = 0
    dropDown.Visible = false
    dropDown.ZIndex = 10000
    dropDown.Parent = screenGui
    dropDown.ClipsDescendants = false

    aplicarNeon(dropDown, 8, 0.6, corNeon, 12)

    local listFrame = Instance.new("ScrollingFrame")
    listFrame.Size = UDim2.new(1, -10, 1, -10)
    listFrame.Position = UDim2.new(0, 5, 0, 5)
    listFrame.BackgroundTransparency = 1
    listFrame.BorderSizePixel = 0
    listFrame.ScrollBarThickness = 4
    listFrame.ScrollBarImageColor3 = corNeon
    listFrame.ZIndex = 10001
    listFrame.Parent = dropDown
    listFrame.Active = true
    listFrame.CanvasSize = UDim2.new(0, 0, 0, #items * 30)

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 2)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = listFrame

    for _, item in ipairs(items) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 25)
        btn.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
        btn.Text = item
        btn.TextColor3 = corPreta
        btn.TextSize = 14
        btn.Font = Enum.Font.Gotham
        btn.Parent = listFrame
        btn.MouseButton1Click:Connect(function()
            visor.Text = item
            dropDown.Visible = false
        end)
    end

    local function posicionar()
        local btnPos = visor.AbsolutePosition
        local btnSize = visor.AbsoluteSize
        local guiPos = playerGui.AbsolutePosition
        local offsetX = btnPos.X - guiPos.X
        local offsetY = btnPos.Y - guiPos.Y
        dropDown.Position = UDim2.new(0, offsetX, 0, offsetY + btnSize.Y + 5)
    end

    visor.MouseButton1Click:Connect(function()
        dropDown.Visible = not dropDown.Visible
        if dropDown.Visible then
            posicionar()
        end
    end)

    local function updateItems(newItems)
        for _, child in pairs(listFrame:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        dropDown.Size = UDim2.new(0, 220, 0, #newItems * 30 + 10)
        listFrame.CanvasSize = UDim2.new(0, 0, 0, #newItems * 30)
        for _, item in ipairs(newItems) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -10, 0, 25)
            btn.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
            btn.Text = item
            btn.TextColor3 = corPreta
            btn.TextSize = 14
            btn.Font = Enum.Font.Gotham
            btn.Parent = listFrame
            btn.MouseButton1Click:Connect(function()
                visor.Text = item
                dropDown.Visible = false
            end)
        end
    end

    return {
        Container = container,
        Visor = visor,
        UpdateItems = updateItems
    }
end

local function createPlayerDropdown(parent, yPos)
    local function getPlayerNames()
        local names = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player then
                table.insert(names, p.Name)
            end
        end
        return names
    end

    local dropdown = createDropdown(parent, "Jogador", getPlayerNames(), yPos)
    
    local function refresh()
        dropdown.UpdateItems(getPlayerNames())
    end
    Players.PlayerAdded:Connect(refresh)
    Players.PlayerRemoving:Connect(refresh)
    
    return dropdown
end

local function createMethodDropdown(parent, yPos)
    return createDropdown(parent, "Método", {"ball", "bus", "boat"}, yPos)
end

local function criarTelaLogin(gui)
    local keyFrame = createFrame(gui, UDim2.new(0, 340, 0, 220), UDim2.new(0.5, -170, 0.5, -110), corPreta, 0, 12)
    keyFrame.ZIndex = 999
    aplicarNeon(keyFrame, 16, 0.65, corNeon, 16)
    aplicarNeon(keyFrame, 8, 0.45, corNeon, 14)

    local titleBar = createFrame(keyFrame, UDim2.new(1, 0, 0, 32), UDim2.new(0, 0, 0, 0), corNeonEscuro, 0, 12)
    createTextLabel(titleBar, "🔐 VERIFICAÇÃO", UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0))
    createTextLabel(keyFrame, "Insira sua chave para continuar", UDim2.new(1, -30, 0, 25), UDim2.new(0, 15, 0, 42), corBranca, Enum.Font.Gotham, 13)

    local keyBox = createTextBox(keyFrame, "Digite sua chave...", UDim2.new(1, -30, 0, 38), UDim2.new(0, 15, 0, 74), Color3.fromRGB(30,30,30), corBranca)
    local verifyBtn = createTextButton(keyFrame, "VERIFICAR", UDim2.new(1, -30, 0, 40), UDim2.new(0, 15, 0, 125))

    makeDraggable(keyFrame, titleBar)

    return {
        Frame = keyFrame,
        KeyBox = keyBox,
        VerifyBtn = verifyBtn
    }
end

local function criarTelaPrincipal(gui)
    local mainFrame = createFrame(gui, UDim2.new(0, 580, 0, 420), UDim2.new(0.5, -290, 0.5, -210), corPreta, 0, 12)
    mainFrame.Visible = false
    aplicarNeon(mainFrame, 16, 0.65, corNeon, 16)
    aplicarNeon(mainFrame, 8, 0.45, corNeon, 14)

    local titleBar = createFrame(mainFrame, UDim2.new(1, 0, 0, 32), UDim2.new(0, 0, 0, 0), corNeonEscuro, 0, 12)
    local titleText = createTextLabel(titleBar, "FIRE HUB", UDim2.new(0, 200, 1, 0), UDim2.new(0, 15, 0, 0), corBranca, Enum.Font.GothamBold, 18)
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    
    makeDraggable(mainFrame, titleBar)

    local tabPanel = createFrame(mainFrame, UDim2.new(0, 120, 1, -42), UDim2.new(0, 0, 0, 42), Color3.fromHex("141414"), 0, 12)

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
    contentArea.Active = true

    return {
        Frame = mainFrame,
        TabPanel = tabPanel,
        ContentArea = contentArea
    }
end

local audioStorage = {}
local soundObj = nil

local function criarAbaInfo(contentArea)
    createTextLabel(contentArea, "Criado por kkscript", UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, 30), corBranca, Enum.Font.GothamBold, 16)
    createTextLabel(contentArea, "Este script está em desenvolvimento", UDim2.new(1, -20, 0, 25), UDim2.new(0, 10, 0, 70), Color3.fromRGB(200,200,200), Enum.Font.Gotham, 14)
    createTextLabel(contentArea, "esse não é o produto completo", UDim2.new(1, -20, 0, 20), UDim2.new(0, 10, 0, 100), Color3.fromRGB(200,200,200), Enum.Font.Gotham, 14)
    contentArea.CanvasSize = UDim2.new(0, 0, 0, 150)
end

local function criarAbaPrincipal(contentArea)
    local playerSelect = createPlayerDropdown(contentArea, 10)
    local methodSelect = createMethodDropdown(contentArea, 68)
    
    local toggleSize = UDim2.new(1, -20, 0, 28)
    local yBase = 140

    createActionButton(contentArea, "Kill", toggleSize, UDim2.new(0, 10, 0, yBase), function()
        local target = playerSelect.Visor.Text
        if target ~= "Selecionar..." then
            local targetPlayer = Players:FindFirstChild(target)
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") then
                targetPlayer.Character.Humanoid.Health = 0
            end
        end
    end)

    createToggle(contentArea, "Fling", toggleSize, UDim2.new(0, 10, 0, yBase + 35), function(at) end)
    createToggle(contentArea, "black hole", toggleSize, UDim2.new(0, 10, 0, yBase + 70), function(at) end)
    createToggle(contentArea, "View", toggleSize, UDim2.new(0, 10, 0, yBase + 105), function(at) end)

    createActionButton(contentArea, "Teleport", toggleSize, UDim2.new(0, 10, 0, yBase + 140), function()
        local target = playerSelect.Visor.Text
        if target ~= "Selecionar..." then
            local targetPlayer = Players:FindFirstChild(target)
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local localChar = player.Character
                if localChar and localChar:FindFirstChild("HumanoidRootPart") then
                    localChar.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
                end
            end
        end
    end)

    contentArea.CanvasSize = UDim2.new(0, 0, 0, yBase + 180)
end

local function criarAbaAvatar(contentArea)
    local playerSelect = createPlayerDropdown(contentArea, 10)
    createActionButton(contentArea, "Copy avatar", UDim2.new(1, -20, 0, 28), UDim2.new(0, 10, 0, 75), function()
        local target = playerSelect.Visor.Text
        if target ~= "Selecionar..." then
        end
    end)
    contentArea.CanvasSize = UDim2.new(0, 0, 0, 150)
end

local function criarAbaAudio(contentArea)
    local audioBox = createTextBox(contentArea, "Insira o ID...", UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, 10), corPreta, corBranca)
    
    local arquivoContainer = createFrame(contentArea, UDim2.new(1, -20, 0, 120), UDim2.new(0, 10, 0, 50), corPreta, 0.1, 8)
    local listFrame = Instance.new("ScrollingFrame")
    listFrame.Size = UDim2.new(1, -10, 1, -10)
    listFrame.Position = UDim2.new(0, 5, 0, 5)
    listFrame.BackgroundTransparency = 1
    listFrame.BorderSizePixel = 0
    listFrame.ScrollBarThickness = 4
    listFrame.ScrollBarImageColor3 = corNeon
    listFrame.Parent = arquivoContainer
    listFrame.Active = true
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 2)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = listFrame

    local function updateAudioList()
        for _, child in pairs(listFrame:GetChildren()) do
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
        listFrame.CanvasSize = UDim2.new(0, 0, 0, #audioStorage * 22)
    end

    createActionButton(contentArea, "Save", UDim2.new(1, -20, 0, 28), UDim2.new(0, 10, 0, 185), function()
        local id = audioBox.Text
        if id ~= "" then
            table.insert(audioStorage, id)
            updateAudioList()
            audioBox.Text = ""
        end
    end)

    createToggle(contentArea, "Tocar", UDim2.new(1, -20, 0, 28), UDim2.new(0, 10, 0, 220), function(ativado)
        if ativado then
            local id = audioBox.Text
            if id ~= "" then
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
end

local function criarAbaJogador(contentArea)
    local function updatePlayerStats(stat, value)
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") then
            local hum = char.Humanoid
            if stat == "Velocidade" then hum.WalkSpeed = value
            elseif stat == "Pulo" then hum.JumpPower = value
            elseif stat == "Gravidade" then hum.UseJumpPower = false; hum.Gravity = value end
        end
    end

    local function createSlider(parent, text, yPos, defaultVal, minVal, maxVal, statName)
        local frame = createFrame(parent, UDim2.new(1, -20, 0, 40), UDim2.new(0, 10, 0, yPos), nil, 1)
        local label = createTextLabel(frame, text, UDim2.new(0.5, 0, 1, 0), UDim2.new(0, 0, 0, 0), corBranca, Enum.Font.Gotham, 14)
        label.TextXAlignment = Enum.TextXAlignment.Left

        local valueDisplay = createTextLabel(frame, tostring(defaultVal), UDim2.new(0, 50, 0, 20), UDim2.new(1, -60, 0, 0), corNeon, Enum.Font.GothamBold, 14)

        local sliderFrame = createFrame(frame, UDim2.new(0, 120, 0, 8), UDim2.new(1, -190, 0.5, -4), corCinza, 0, 0)
        sliderFrame.Active = true
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
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(1, 0)
        btnCorner.Parent = sliderBtn

        local dragging = false
        local currentVal = defaultVal

        updatePlayerStats(statName, defaultVal)

        sliderBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if not dragging or input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
            local percent = math.clamp((input.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1)
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
end

local function criarAbaGenerica(contentArea, nome)
    createTextLabel(contentArea, nome, UDim2.new(1, 0, 0, 30), UDim2.new(0, 10, 0, 10), corBranca, Enum.Font.GothamBold, 18)
    createTextLabel(contentArea, "Conteúdo em desenvolvimento...", UDim2.new(1, 0, 0, 20), UDim2.new(0, 10, 0, 50), corBranca, Enum.Font.Gotham, 14)
    contentArea.CanvasSize = UDim2.new(0, 0, 0, 150)
end

local function buildUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FireHubUI"
    screenGui.IgnoreGuiInset = false
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 9999
    screenGui.Parent = playerGui

    local login = criarTelaLogin(screenGui)
    
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

    local main = criarTelaPrincipal(screenGui)

    local tabs = {
        {"ℹ️ Inf", criarAbaInfo},
        {"🔥 Principal", criarAbaPrincipal},
        {"👤 Avatar", criarAbaAvatar},
        {"🔊 Áudio", criarAbaAudio},
        {"⚔️ Combate", criarAbaGenerica},
        {"🏃 Movimento", criarAbaGenerica},
        {"📦 Outros", criarAbaGenerica},
        {"⚡ Jogador", criarAbaJogador},
        {"⚙️ Config", criarAbaGenerica},
    }

    local tabButtons = {}

    local function selectTab(tabName, creator)
        for _, btn in pairs(tabButtons) do
            local ind = btn:FindFirstChild("Indicator")
            if ind then
                ind.BackgroundTransparency = (btn.Text == tabName) and 0 or 1
                btn.TextColor3 = (btn.Text == tabName) and corBranca or Color3.fromRGB(150,150,150)
            end
        end
        for _, child in pairs(main.ContentArea:GetChildren()) do
            child:Destroy()
        end
        creator(main.ContentArea)
    end

    for i, tab in ipairs(tabs) do
        local yPos = 10 + (i-1)*36
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -12, 0, 30)
        btn.Position = UDim2.new(0, 6, 0, yPos)
        btn.BackgroundColor3 = Color3.fromRGB(30,30,30)
        btn.BorderSizePixel = 0
        btn.Text = tab[1]
        btn.TextColor3 = Color3.fromRGB(150,150,150)
        btn.TextSize = 13
        btn.Font = Enum.Font.GothamBold
        btn.ZIndex = 3
        btn.Parent = main.TabPanel

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
        local indCorner = Instance.new("UICorner")
        indCorner.CornerRadius = UDim.new(0, 2)
        indCorner.Parent = indicator

        btn.MouseButton1Click:Connect(function()
            selectTab(tab[1], tab[2])
        end)

        table.insert(tabButtons, btn)
    end

    selectTab("ℹ️ Inf", criarAbaInfo)

    login.VerifyBtn.MouseButton1Click:Connect(function()
        local input = login.KeyBox.Text:lower():match("^%s*(.-)%s*$")
        if input == "menu k" or input == "menuk" then
            login.Frame.Visible = false
            floatBtn.Visible = true
            main.Frame.Visible = false
        else
            login.KeyBox.BackgroundColor3 = corNeonEscuro
            TweenService:Create(login.KeyBox, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(30,30,30)}):Play()
            login.KeyBox.PlaceholderText = "Chave inválida!"
            task.wait(1)
            login.KeyBox.PlaceholderText = "Digite sua chave..."
        end
    end)

    login.KeyBox.FocusLost:Connect(function(enter)
        if enter then login.VerifyBtn.MouseButton1Click:Fire() end
    end)

    floatBtn.MouseButton1Click:Connect(function()
        main.Frame.Visible = not main.Frame.Visible
    end)

    return screenGui
end

buildUI()
