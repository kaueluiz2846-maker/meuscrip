-- Variáveis de serviço
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local SoundService = game:GetService("SoundService")
local LocalPlayer = Players.LocalPlayer

-- Configurações
local CONFIG = {
    Theme = "Dark",
    NeonColor = Color3.fromRGB(255, 0, 0),
    NeonDark = Color3.fromRGB(139, 0, 0),
    Background = Color3.fromRGB(10, 10, 10),
    TextColor = Color3.fromRGB(255, 255, 255),
    DisabledColor = Color3.fromRGB(60, 60, 60),
    StrokeColor = Color3.fromRGB(255, 0, 0),
    AnimationSpeed = 0.2,
    ShowGlow = true,
    ShowFPS = false,
    CornerRadius = UDim.new(0, 8),
    Font = Enum.Font.GothamBold,
    FontSize = 14,
}

local LoginKey = "HUB123"
local IsLoggedIn = false
local NotificationQueue = {}
local IsNotifying = false
local CurrentTab = nil
local SavedAudioIDs = {}
local AudioPlayers = {}

local function createSound(id, volume)
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. id
    sound.Volume = volume or 1
    sound.Parent = CoreGui
    return sound
end

local SOUNDS = {
    Click = createSound(9120386435, 0.5),
    Open = createSound(9120386435, 0.5),
    Close = createSound(9120386435, 0.5),
    Dropdown = createSound(9120386435, 0.5),
    ToggleOn = createSound(9120386435, 0.5),
    ToggleOff = createSound(9120386435, 0.5),
    Error = createSound(9120386435, 0.5),
    Success = createSound(9120386435, 0.5),
}

local function playSound(name)
    local s = SOUNDS[name]
    if s then
        s:Play()
    end
end

-- Funções de criação de componentes
local function createFrame(parent, size, position, bgColor, transparency, zIndex)
    local frame = Instance.new("Frame")
    frame.Size = size or UDim2.new(0, 100, 0, 100)
    frame.Position = position or UDim2.new(0, 0, 0, 0)
    frame.BackgroundColor3 = bgColor or CONFIG.Background
    frame.BackgroundTransparency = transparency or 0
    frame.ZIndex = zIndex or 1
    frame.BorderSizePixel = 0
    if parent then frame.Parent = parent end
    return frame
end

local function createLabel(parent, size, position, text, textColor, font, fontSize, zIndex)
    local label = Instance.new("TextLabel")
    label.Size = size or UDim2.new(0, 100, 0, 20)
    label.Position = position or UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text or ""
    label.TextColor3 = textColor or CONFIG.TextColor
    label.Font = font or CONFIG.Font
    label.TextSize = fontSize or CONFIG.FontSize
    label.ZIndex = zIndex or 1
    label.TextScaled = false
    label.TextWrapped = true
    if parent then label.Parent = parent end
    return label
end

local function createButton(parent, size, position, text, bgColor, callback)
    local button = Instance.new("TextButton")
    button.Size = size or UDim2.new(0, 100, 0, 30)
    button.Position = position or UDim2.new(0, 0, 0, 0)
    button.BackgroundColor3 = bgColor or CONFIG.NeonDark
    button.Text = text or ""
    button.TextColor3 = CONFIG.TextColor
    button.Font = CONFIG.Font
    button.TextSize = CONFIG.FontSize
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.ZIndex = 2
    if parent then button.Parent = parent end
    if callback then
        button.MouseButton1Click:Connect(function()
            playSound("Click")
            callback()
        end)
    end
    return button
end

local function createTextBox(parent, size, position, placeholder, callback)
    local box = Instance.new("TextBox")
    box.Size = size or UDim2.new(0, 100, 0, 30)
    box.Position = position or UDim2.new(0, 0, 0, 0)
    box.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    box.TextColor3 = CONFIG.TextColor
    box.PlaceholderText = placeholder or ""
    box.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    box.Font = CONFIG.Font
    box.TextSize = CONFIG.FontSize
    box.BorderSizePixel = 0
    box.ZIndex = 2
    box.ClearTextOnFocus = false
    if parent then box.Parent = parent end
    if callback then
        box.FocusLost:Connect(function(enterPressed)
            callback(box.Text, enterPressed)
        end)
    end
    return box
end

local function addUICorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or CONFIG.CornerRadius
    corner.Parent = parent
    return corner
end

local function addUIStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or CONFIG.StrokeColor
    stroke.Thickness = thickness or 2
    stroke.Transparency = 0.5
    stroke.Parent = parent
    return stroke
end

local function addGlow(parent, color, size)
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://6031280886"
    glow.ImageColor3 = color or CONFIG.NeonColor
    glow.ScaleType = Enum.ScaleType.Slice
    glow.SliceCenter = Rect.new(32, 32, 32, 32)
    glow.Size = UDim2.new(1, size*2 or 20, 1, size*2 or 20)
    glow.Position = UDim2.new(0, -size or -10, 0, -size or -10)
    glow.ZIndex = 0
    glow.Visible = CONFIG.ShowGlow
    glow.Parent = parent
    return glow
end

local function createDrag(frame)
    local dragging
    local dragInput
    local dragStart
    local startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local function createToggle(parent, size, position, text, default, callback)
    local toggleFrame = createFrame(parent, size or UDim2.new(0, 40, 0, 20), position, CONFIG.DisabledColor, 0, 2)
    addUICorner(toggleFrame, UDim.new(1, 0))
    local knob = createFrame(toggleFrame, UDim2.new(1, -2, 1, -2), UDim2.new(0, 1, 0, 1), CONFIG.TextColor, 0, 3)
    addUICorner(knob, UDim.new(1, 0))
    local state = default or false
    local function updateVisual()
        if state then
            toggleFrame.BackgroundColor3 = CONFIG.NeonColor
            TweenService:Create(knob, TweenInfo.new(CONFIG.AnimationSpeed), {Position = UDim2.new(1, -toggleFrame.Size.Y.Offset + 1, 0, 1)}):Play()
        else
            toggleFrame.BackgroundColor3 = CONFIG.DisabledColor
            TweenService:Create(knob, TweenInfo.new(CONFIG.AnimationSpeed), {Position = UDim2.new(0, 1, 0, 1)}):Play()
        end
    end
    local label = createLabel(parent, UDim2.new(1, -size.X.Offset - 10, 0, 20), UDim2.new(0, size.X.Offset + 10, 0.5, -10), text, CONFIG.TextColor, CONFIG.Font, 14, 2)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    local button = Instance.new("TextButton")
    button.Size = size
    button.Position = position
    button.BackgroundTransparency = 1
    button.Text = ""
    button.ZIndex = 4
    button.Parent = parent
    button.MouseButton1Click:Connect(function()
        state = not state
        updateVisual()
        if callback then callback(state) end
        playSound(state and "ToggleOn" or "ToggleOff")
    end)
    if default then
        updateVisual()
    end
    return {
        Frame = toggleFrame,
        Set = function(value)
            state = value
            updateVisual()
            if callback then callback(state) end
        end,
        Get = function() return state end
    }
end

local function createDropdown(parent, size, position, placeholder, items, callback)
    local container = createFrame(parent, size, position, Color3.fromRGB(30, 30, 30), 0, 5)
    addUICorner(container, CONFIG.CornerRadius)
    local selectedText = createLabel(container, UDim2.new(1, -30, 1, 0), UDim2.new(0, 10, 0, 0), placeholder, Color3.fromRGB(150,150,150), CONFIG.Font, 14, 6)
    local arrow = createLabel(container, UDim2.new(0, 20, 1, 0), UDim2.new(1, -25, 0, 0), "▼", CONFIG.TextColor, CONFIG.Font, 12, 6)
    local dropdownButton = createButton(container, UDim2.new(1, 0, 1, 0), UDim2.new(0,0,0,0), "", nil, nil)
    dropdownButton.BackgroundTransparency = 1
    dropdownButton.ZIndex = 7
    local listFrame = createFrame(nil, UDim2.new(1, 0, 0, 0), UDim2.new(0,0,1,5), Color3.fromRGB(40,40,40), 0, 10)
    addUICorner(listFrame, CONFIG.CornerRadius)
    addUIStroke(listFrame, CONFIG.NeonDark, 1)
    listFrame.Visible = false
    listFrame.Parent = container
    local scrolling = Instance.new("ScrollingFrame")
    scrolling.Size = UDim2.new(1, -4, 1, -4)
    scrolling.Position = UDim2.new(0,2,0,2)
    scrolling.BackgroundTransparency = 1
    scrolling.CanvasSize = UDim2.new(0,0,0,0)
    scrolling.ScrollBarThickness = 3
    scrolling.ScrollBarImageColor3 = CONFIG.NeonColor
    scrolling.ZIndex = 11
    scrolling.Parent = listFrame
    local listLayout = Instance.new("UIListLayout")
    listLayout.Parent = scrolling
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrolling.CanvasSize = UDim2.new(0,0,0,listLayout.AbsoluteContentSize.Y + 5)
    end)
    local selectedItem = nil
    local function populate()
        for _, child in ipairs(scrolling:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        for _, item in ipairs(items) do
            local itemBtn = Instance.new("TextButton")
            itemBtn.Size = UDim2.new(1, -4, 0, 24)
            itemBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
            itemBtn.Text = item
            itemBtn.TextColor3 = CONFIG.TextColor
            itemBtn.Font = CONFIG.Font
            itemBtn.TextSize = 13
            itemBtn.ZIndex = 11
            itemBtn.BorderSizePixel = 0
            addUICorner(itemBtn, UDim.new(0,4))
            itemBtn.Parent = scrolling
            itemBtn.MouseButton1Click:Connect(function()
                selectedItem = item
                selectedText.Text = item
                selectedText.TextColor3 = CONFIG.TextColor
                listFrame.Visible = false
                if callback then callback(item) end
                playSound("Dropdown")
            end)
        end
        scrolling.CanvasSize = UDim2.new(0,0,0,listLayout.AbsoluteContentSize.Y + 5)
    end
    populate()
    dropdownButton.MouseButton1Click:Connect(function()
        listFrame.Visible = not listFrame.Visible
        if listFrame.Visible then
            listFrame.Size = UDim2.new(1,0,0,0)
            TweenService:Create(listFrame, TweenInfo.new(CONFIG.AnimationSpeed), {Size = UDim2.new(1,0,0, math.clamp(#items * 25, 30, 150))}):Play()
        end
    end)
    return {
        Container = container,
        UpdateItems = function(newItems)
            items = newItems
            populate()
            selectedItem = nil
            selectedText.Text = placeholder
            selectedText.TextColor3 = Color3.fromRGB(150,150,150)
        end,
        GetSelected = function() return selectedItem end,
        SetSelected = function(item)
            if table.find(items, item) then
                selectedItem = item
                selectedText.Text = item
                selectedText.TextColor3 = CONFIG.TextColor
            end
        end
    }
end

local function createSlider(parent, size, position, text, min, max, default, callback)
    local container = createFrame(parent, size, position, Color3.fromRGB(30,30,30), 0, 2)
    addUICorner(container, CONFIG.CornerRadius)
    local label = createLabel(container, UDim2.new(0,60,1,0), UDim2.new(0,5,0,0), text, CONFIG.TextColor, CONFIG.Font, 13, 3)
    label.TextXAlignment = Enum.TextXAlignment.Left
    local valueLabel = createLabel(container, UDim2.new(0,40,1,0), UDim2.new(1,-45,0,0), tostring(default), CONFIG.TextColor, CONFIG.Font, 13, 3)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    local barFrame = createFrame(container, UDim2.new(1,-110,0,6), UDim2.new(0,65,0.5,-3), CONFIG.DisabledColor, 0, 3)
    addUICorner(barFrame, UDim.new(1,0))
    local fill = createFrame(barFrame, UDim2.new((default-min)/(max-min),0,1,0), UDim2.new(0,0,0,0), CONFIG.NeonColor, 0, 3)
    addUICorner(fill, UDim.new(1,0))
    local knob = createFrame(barFrame, UDim2.new(0,12,1,4), UDim2.new(0,0,0,-2), Color3.new(1,1,1), 0, 4)
    addUICorner(knob, UDim.new(1,0))
    local dragging = false
    local function updateValue(input)
        local relX = math.clamp((input.Position.X - barFrame.AbsolutePosition.X) / barFrame.AbsoluteSize.X, 0, 1)
        local val = min + relX * (max - min)
        val = math.floor(val * 100) / 100
        fill.Size = UDim2.new(relX, 0, 1, 0)
        knob.Position = UDim2.new(relX, -6, 0, -2)
        valueLabel.Text = tostring(val)
        if callback then callback(val) end
    end
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    barFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            updateValue(input)
            dragging = true
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateValue(input)
        end
    end)
    return container
end

local function createNotification(title, message, duration)
    local notif = createFrame(nil, UDim2.new(0, 250, 0, 60), UDim2.new(1, -260, 1, -(60*#NotificationQueue + 10*#NotificationQueue + 10)), Color3.fromRGB(20,20,20), 0.1, 10)
    addUICorner(notif, CONFIG.CornerRadius)
    addUIStroke(notif, CONFIG.NeonColor, 1)
    local titleLabel = createLabel(notif, UDim2.new(1,-10,0,20), UDim2.new(0,5,0,5), title, CONFIG.NeonColor, CONFIG.Font, 16, 11)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    local msgLabel = createLabel(notif, UDim2.new(1,-10,0,20), UDim2.new(0,5,0,30), message, CONFIG.TextColor, CONFIG.Font, 12, 11)
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    notif.Parent = CoreGui:FindFirstChild("HubUI") or game:GetService("CoreGui")
    notif.Position = UDim2.new(1, 0, 1, -notif.Size.Y.Offset - 10)
    TweenService:Create(notif, TweenInfo.new(0.3), {Position = UDim2.new(1, -260, 1, -(notif.Size.Y.Offset+10) - (60+10)*#NotificationQueue)}):Play()
    table.insert(NotificationQueue, notif)
    delay(duration or 3, function()
        TweenService:Create(notif, TweenInfo.new(0.3), {Position = UDim2.new(1, 0, notif.Position.Y.Scale, notif.Position.Y.Offset)}):Play()
        wait(0.3)
        notif:Destroy()
        for i,v in ipairs(NotificationQueue) do
            if v == notif then
                table.remove(NotificationQueue, i)
                break
            end
        end
    end)
end

local function createSeparator(parent, position, width)
    local sep = createFrame(parent, UDim2.new(width or 1, -10, 0, 1), position or UDim2.new(0,5,0,0), CONFIG.NeonColor, 0, 2)
    return sep
end

-- MAIN GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HubUI"
ScreenGui.Parent = CoreGui
ScreenGui.DisplayOrder = 999
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- LOGIN SCREEN
local LoginFrame = createFrame(ScreenGui, UDim2.new(0, 350, 0, 300), UDim2.new(0.5, -175, 0.5, -150), CONFIG.Background, 0, 1)
addUICorner(LoginFrame, CONFIG.CornerRadius)
addUIStroke(LoginFrame, CONFIG.NeonDark, 2)
addGlow(LoginFrame, CONFIG.NeonColor, 20)
createDrag(LoginFrame)

local titleBar = createFrame(LoginFrame, UDim2.new(1, 0, 0, 40), UDim2.new(0,0,0,0), CONFIG.NeonDark, 0, 2)
addUICorner(titleBar, UDim.new(0, 8))
local titleLabel = createLabel(titleBar, UDim2.new(1,-30,1,0), UDim2.new(0,10,0,0), "HUB PREMIUM", CONFIG.TextColor, CONFIG.Font, 20, 3)
local closeBtn = createButton(titleBar, UDim2.new(0,30,0,30), UDim2.new(1,-35,0,5), "×", CONFIG.NeonDark, function() ScreenGui:Destroy() end)
closeBtn.TextSize = 24

local logoLabel = createLabel(LoginFrame, UDim2.new(0,100,0,40), UDim2.new(0.5,-50,0,50), "🔥", CONFIG.NeonColor, nil, 36, 2)
logoLabel.BackgroundTransparency = 1
local subtitle = createLabel(LoginFrame, UDim2.new(1,-20,0,20), UDim2.new(0,10,0,100), "Insira sua chave para continuar", CONFIG.TextColor, CONFIG.Font, 14, 2)
local keyBox = createTextBox(LoginFrame, UDim2.new(1,-40,0,35), UDim2.new(0,20,0,130), "Chave de acesso", nil)
local statusLabel = createLabel(LoginFrame, UDim2.new(1,-20,0,20), UDim2.new(0,20,0,210), "", CONFIG.NeonColor, CONFIG.Font, 13, 2)
statusLabel.TextTransparency = 1

local function shakeElement(element)
    local originalPos = element.Position
    local tween1 = TweenService:Create(element, TweenInfo.new(0.05), {Position = originalPos + UDim2.new(0,5,0,0)})
    local tween2 = TweenService:Create(element, TweenInfo.new(0.05), {Position = originalPos - UDim2.new(0,5,0,0)})
    local tween3 = TweenService:Create(element, TweenInfo.new(0.05), {Position = originalPos})
    tween1:Play()
    tween1.Completed:Connect(function() tween2:Play() end)
    tween2.Completed:Connect(function() tween3:Play() end)
end

local verifyBtn = createButton(LoginFrame, UDim2.new(0.45,-10,0,35), UDim2.new(0.025,20,0,170), "Verificar", CONFIG.NeonDark, function()
    if keyBox.Text == LoginKey then
        playSound("Success")
        createNotification("Sucesso", "Login efetuado!", 2)
        TweenService:Create(LoginFrame, TweenInfo.new(0.5), {Size = UDim2.new(0,0,0,0), Position = UDim2.new(0.5,0,0.5,0)}):Play()
        wait(0.5)
        LoginFrame:Destroy()
        IsLoggedIn = true
        buildMainUI()
    else
        playSound("Error")
        keyBox.BackgroundColor3 = Color3.fromRGB(255,0,0)
        shakeElement(keyBox)
        statusLabel.Text = "Chave incorreta!"
        statusLabel.TextTransparency = 0
        wait(0.3)
        keyBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
        TweenService:Create(statusLabel, TweenInfo.new(1), {TextTransparency = 1}):Play()
    end
end)
local copyLinkBtn = createButton(LoginFrame, UDim2.new(0.45,-10,0,35), UDim2.new(0.525,20,0,170), "Copiar Link", CONFIG.NeonDark, function()
    if setclipboard then setclipboard("discord.gg/exemplo") end
    createNotification("Link copiado!", "Convite do Discord copiado.", 2)
end)
local discordBtn = createButton(LoginFrame, UDim2.new(1,-40,0,35), UDim2.new(0,20,0,215), "Discord", CONFIG.NeonDark, function()
    if setclipboard then setclipboard("discord.gg/exemplo") end
    createNotification("Discord", "Link copiado!", 2)
end)

function buildMainUI()
    -- Botão flutuante
    local floatBtn = createButton(ScreenGui, UDim2.new(0,50,0,50), UDim2.new(0,20,0.5,-25), "☰", CONFIG.NeonDark, function()
        if MainFrame.Visible then
            TweenService:Create(MainFrame, TweenInfo.new(0.2), {Size = UDim2.new(0,0,0,0)}):Play()
            wait(0.2)
            MainFrame.Visible = false
        else
            MainFrame.Visible = true
            TweenService:Create(MainFrame, TweenInfo.new(0.2), {Size = UDim2.new(0,600,0,400)}):Play()
        end
    end)
    floatBtn.TextSize = 22
    addUICorner(floatBtn, UDim.new(1,0))
    addGlow(floatBtn, CONFIG.NeonColor, 10)
    createDrag(floatBtn)

    -- Menu principal
    local MainFrame = createFrame(ScreenGui, UDim2.new(0,600,0,400), UDim2.new(0.5,-300,0.5,-200), CONFIG.Background, 0, 2)
    MainFrame.Visible = false
    MainFrame.Size = UDim2.new(0,0,0,0)
    addUICorner(MainFrame, CONFIG.CornerRadius)
    addUIStroke(MainFrame, CONFIG.NeonDark, 2)
    addGlow(MainFrame, CONFIG.NeonColor, 20)
    createDrag(MainFrame)

    -- Barra superior
    local topBar = createFrame(MainFrame, UDim2.new(1,0,0,40), UDim2.new(0,0,0,0), CONFIG.NeonDark, 0, 3)
    addUICorner(topBar, UDim.new(0, 8))
    createLabel(topBar, UDim2.new(1,-60,1,0), UDim2.new(0,10,0,0), "HUB PREMIUM", CONFIG.TextColor, CONFIG.Font, 20, 4)
    createButton(topBar, UDim2.new(0,30,0,30), UDim2.new(1,-65,0,5), "_", CONFIG.NeonDark, function()
        MainFrame.Visible = false
    end)
    createButton(topBar, UDim2.new(0,30,0,30), UDim2.new(1,-35,0,5), "×", CONFIG.NeonDark, function()
        MainFrame.Visible = false
    end)

    -- Sidebar
    local sidebar = createFrame(MainFrame, UDim2.new(0,120,1,-40), UDim2.new(0,0,0,40), Color3.fromRGB(15,15,15), 0, 2)
    local tabButtons = {}
    local tabNames = {"ℹ️ Info", "🔥 Principal", "👤 Avatar", "🔊 Áudio", "⚔️ Combate", "🏃 Movimento", "📦 Outros", "⚡ Jogador", "⚙️ Config"}
    local tabContentArea = createFrame(MainFrame, UDim2.new(1,-120,1,-40), UDim2.new(0,120,0,40), CONFIG.Background, 0, 1)
    local activeTab = nil

    local function switchTab(tabName, callback)
        if activeTab then
            if activeTab.Content then activeTab.Content:Destroy() end
            if activeTab.Button then activeTab.Button.BackgroundColor3 = Color3.fromRGB(15,15,15) end
        end
        activeTab = {Button = tabButtons[tabName], Content = nil}
        activeTab.Button.BackgroundColor3 = CONFIG.NeonDark
        local content = callback()
        content.Parent = tabContentArea
        activeTab.Content = content
    end

    for i, name in ipairs(tabNames) do
        local btn = createButton(sidebar, UDim2.new(1,-4,0,32), UDim2.new(0,2,0,(i-1)*34+2), name, Color3.fromRGB(15,15,15), nil)
        btn.TextSize = 12
        addUICorner(btn, UDim.new(0,5))
        tabButtons[name] = btn
    end

    -- Conteúdo das abas
    tabButtons["ℹ️ Info"].MouseButton1Click:Connect(function()
        switchTab("ℹ️ Info", function()
            local frame = createFrame(nil, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0))
            createLabel(frame, UDim2.new(1,-20,0,30), UDim2.new(0,10,0,10), "Bem-vindo ao Hub Premium", CONFIG.TextColor, nil, 20)
            createLabel(frame, UDim2.new(1,-20,0,50), UDim2.new(0,10,0,50), "Script completo e modular.", CONFIG.TextColor, nil, 14)
            return frame
        end)
    end)

    tabButtons["🔥 Principal"].MouseButton1Click:Connect(function()
        switchTab("🔥 Principal", function()
            local frame = createFrame(nil, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0))
            local playerDropdown = createDropdown(frame, UDim2.new(1,-20,0,35), UDim2.new(0,10,0,20), "Selecionar jogador", {}, function(player) end)
            local methodDropdown = createDropdown(frame, UDim2.new(1,-20,0,35), UDim2.new(0,10,0,70), "Método", {"Ball","Bus","Boat"}, function(method) end)
            createButton(frame, UDim2.new(0.45,-5,0,35), UDim2.new(0,10,0,120), "Kill", CONFIG.NeonDark, function()
                local plr = playerDropdown.GetSelected()
                if plr then
                    local target = Players:FindFirstChild(plr)
                    if target and target.Character and target.Character:FindFirstChild("Humanoid") then
                        target.Character.Humanoid.Health = 0
                    end
                end
            end)
            createButton(frame, UDim2.new(0.45,-5,0,35), UDim2.new(0.525,10,0,120), "Teleport", CONFIG.NeonDark, function()
                local plr = playerDropdown.GetSelected()
                if plr then
                    local target = Players:FindFirstChild(plr)
                    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
                    end
                end
            end)
            createToggle(frame, UDim2.new(0,40,0,20), UDim2.new(0,10,0,170), "Fling", false, function(state) end)
            return frame
        end)
    end)

    tabButtons["👤 Avatar"].MouseButton1Click:Connect(function()
        switchTab("👤 Avatar", function()
            local frame = createFrame(nil, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0))
            local playerDropdown = createDropdown(frame, UDim2.new(1,-20,0,35), UDim2.new(0,10,0,20), "Selecionar jogador", {}, function() end)
            createButton(frame, UDim2.new(1,-20,0,35), UDim2.new(0,10,0,70), "Copy Avatar", CONFIG.NeonDark, function()
                local plr = playerDropdown.GetSelected()
                if plr then
                    local target = Players:FindFirstChild(plr)
                    if target then
                        local humanoidDescription = target.Character and target.Character:FindFirstChild("Humanoid") and target.Character.Humanoid:GetAppliedDescription()
                        if humanoidDescription then
                            LocalPlayer.Character.Humanoid:ApplyDescription(humanoidDescription)
                        end
                    end
                end
            end)
            return frame
        end)
    end)

    tabButtons["🔊 Áudio"].MouseButton1Click:Connect(function()
        switchTab("🔊 Áudio", function()
            local frame = createFrame(nil, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0))
            local idBox = createTextBox(frame, UDim2.new(1,-20,0,35), UDim2.new(0,10,0,20), "ID do áudio (rbxassetid)", nil)
            local idListFrame = createFrame(frame, UDim2.new(1,-20,0,150), UDim2.new(0,10,0,70), Color3.fromRGB(20,20,20), 0, 2)
            addUICorner(idListFrame)
            local idScroll = Instance.new("ScrollingFrame")
            idScroll.Size = UDim2.new(1,0,1,0)
            idScroll.BackgroundTransparency = 1
            idScroll.CanvasSize = UDim2.new(0,0,0,0)
            idScroll.Parent = idListFrame
            local idLayout = Instance.new("UIListLayout")
            idLayout.Parent = idScroll
            idLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                idScroll.CanvasSize = UDim2.new(0,0,0,idLayout.AbsoluteContentSize.Y)
            end)
            local function refreshIdList()
                for _, child in ipairs(idScroll:GetChildren()) do
                    if child:IsA("TextLabel") or child:IsA("TextButton") then child:Destroy() end
                end
                for i, id in ipairs(SavedAudioIDs) do
                    local item = createLabel(idScroll, UDim2.new(1,0,0,24), UDim2.new(0,0,0,(i-1)*26), id, CONFIG.TextColor, nil, 13)
                    item.TextXAlignment = Enum.TextXAlignment.Left
                end
            end
            createButton(frame, UDim2.new(0.3,0,0,35), UDim2.new(0,10,0,230), "Salvar", CONFIG.NeonDark, function()
                if idBox.Text ~= "" then
                    table.insert(SavedAudioIDs, idBox.Text)
                    refreshIdList()
                end
            end)
            createButton(frame, UDim2.new(0.3,0,0,35), UDim2.new(0.35,10,0,230), "Tocar", CONFIG.NeonDark, function()
                local sound = Instance.new("Sound")
                sound.SoundId = "rbxassetid://" .. idBox.Text
                sound.Volume = 1
                sound.Parent = workspace
                sound:Play()
            end)
            return frame
        end)
    end)

    tabButtons["⚡ Jogador"].MouseButton1Click:Connect(function()
        switchTab("⚡ Jogador", function()
            local frame = createFrame(nil, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0))
            createSlider(frame, UDim2.new(1,-20,0,30), UDim2.new(0,10,0,20), "WalkSpeed", 16, 200, 16, function(val)
                if Humanoid then Humanoid.WalkSpeed = val end
            end)
            createSlider(frame, UDim2.new(1,-20,0,30), UDim2.new(0,10,0,70), "JumpPower", 50, 200, 50, function(val)
                if Humanoid then Humanoid.JumpPower = val end
            end)
            createSlider(frame, UDim2.new(1,-20,0,30), UDim2.new(0,10,0,120), "Gravity", 0, 196.2, 196.2, function(val)
                workspace.Gravity = val/196.2 * 196.2
            end)
            createSlider(frame, UDim2.new(1,-20,0,30), UDim2.new(0,10,0,170), "HipHeight", 0, 10, 2, function(val)
                if Humanoid then Humanoid.HipHeight = val end
            end)
            createSlider(frame, UDim2.new(1,-20,0,30), UDim2.new(0,10,0,220), "FOV", 30, 120, 70, function(val)
                workspace.CurrentCamera.FieldOfView = val
            end)
            return frame
        end)
    end)

    tabButtons["⚙️ Config"].MouseButton1Click:Connect(function()
        switchTab("⚙️ Config", function()
            local frame = createFrame(nil, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0))
            createLabel(frame, UDim2.new(1,0,0,30), UDim2.new(0,0,0,10), "Configurações em breve", CONFIG.TextColor)
            return frame
        end)
    end)

    -- Atualizar lista de jogadores
    local function updatePlayerList(dropdown)
        local players = {}
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                table.insert(players, player.Name)
            end
        end
        dropdown.UpdateItems(players)
    end
    Players.PlayerAdded:Connect(function() updatePlayerList(playerDropdown) end)
    Players.PlayerRemoving:Connect(function() updatePlayerList(playerDropdown) end)
end
