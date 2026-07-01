--[[
    FIRE HUB - Interface Modular Roblox
    Tema: Preto fosco com vermelho neon vibrante
    Correções: dropdowns acima de tudo, toggles melhorados, layout refeito
--]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local COLOR = {
    Background = Color3.fromRGB(10, 10, 10),
    Dark = Color3.fromRGB(18, 18, 18),
    Red = Color3.fromRGB(255, 0, 0),
    DarkRed = Color3.fromRGB(120, 0, 0),
    White = Color3.fromRGB(255, 255, 255),
    Gray = Color3.fromRGB(160, 160, 160),
    ComponentBg = Color3.fromRGB(25, 25, 25)
}

local FONT = Enum.Font.GothamBold
local CORNER = UDim.new(0, 8)

-- ================== COMPONENTES BÁSICOS ==================
local function Frame(parent, size, pos, bg, z)
    local f = Instance.new("Frame")
    f.Size = size
    f.Position = pos
    f.BackgroundColor3 = bg or COLOR.Background
    f.BorderSizePixel = 0
    f.ZIndex = z or 1
    if parent then f.Parent = parent end
    return f
end

local function Label(parent, size, pos, text, color, sizeT, z)
    local l = Instance.new("TextLabel")
    l.Size = size
    l.Position = pos
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = color or COLOR.White
    l.Font = FONT
    l.TextSize = sizeT or 14
    l.ZIndex = z or 2
    l.TextWrapped = true
    if parent then l.Parent = parent end
    return l
end

local function Button(parent, size, pos, text, bg, cb)
    local b = Instance.new("TextButton")
    b.Size = size
    b.Position = pos
    b.BackgroundColor3 = bg or COLOR.DarkRed
    b.Text = text
    b.TextColor3 = COLOR.White
    b.Font = FONT
    b.TextSize = 14
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.ZIndex = 3
    if parent then b.Parent = parent end
    if cb then b.MouseButton1Click:Connect(cb) end
    return b
end

local function TextBox(parent, size, pos, placeholder, cb)
    local tb = Instance.new("TextBox")
    tb.Size = size
    tb.Position = pos
    tb.BackgroundColor3 = COLOR.ComponentBg
    tb.TextColor3 = COLOR.White
    tb.PlaceholderText = placeholder or ""
    tb.PlaceholderColor3 = COLOR.Gray
    tb.Font = FONT
    tb.TextSize = 14
    tb.BorderSizePixel = 0
    tb.ZIndex = 3
    tb.ClearTextOnFocus = false
    if parent then tb.Parent = parent end
    if cb then tb.FocusLost:Connect(function(ep) cb(tb.Text, ep) end) end
    return tb
end

local function Corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = radius or CORNER
    c.Parent = parent
    return c
end

local function Stroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or COLOR.Red
    s.Thickness = thickness or 1.5
    s.Transparency = 0.2
    s.Parent = parent
    return s
end

local function Glow(parent, color, size)
    local g = Instance.new("ImageLabel")
    g.Name = "Glow"
    g.BackgroundTransparency = 1
    g.Image = "rbxassetid://6031280886"
    g.ImageColor3 = color or COLOR.Red
    g.ScaleType = Enum.ScaleType.Slice
    g.SliceCenter = Rect.new(32, 32, 32, 32)
    g.Size = UDim2.new(1, size*2, 1, size*2)
    g.Position = UDim2.new(0, -size, 0, -size)
    g.ZIndex = 0
    g.Parent = parent
    return g
end

local function Draggable(frame)
    local drag, startInput, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            drag = true
            startInput = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then drag = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if drag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startInput
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- ================== TOGGLE SWITCH MELHORADO ==================
local function ToggleSwitch(parent, size, position, default, cb)
    local width = size.X.Offset or 44
    local height = size.Y.Offset or 24
    local frame = Frame(parent, UDim2.new(0, width, 0, height), position, COLOR.Dark, 3)
    Corner(frame, UDim.new(1, 0))
    Stroke(frame, COLOR.Red, 1)
    local knobSize = height - 6
    local knob = Frame(frame, UDim2.new(0, knobSize, 0, knobSize), UDim2.new(0, 3, 0, 3), COLOR.White, 4)
    Corner(knob, UDim.new(1, 0))
    local state = default or false
    local function update()
        if state then
            frame.BackgroundColor3 = COLOR.Red
            TweenService:Create(knob, TweenInfo.new(0.2), {Position = UDim2.new(1, -knobSize-3, 0, 3)}):Play()
        else
            frame.BackgroundColor3 = COLOR.Dark
            TweenService:Create(knob, TweenInfo.new(0.2), {Position = UDim2.new(0, 3, 0, 3)}):Play()
        end
    end
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.Position = UDim2.new(0, 0, 0, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 5
    btn.Parent = frame
    btn.MouseButton1Click:Connect(function()
        state = not state
        update()
        if cb then cb(state) end
    end)
    if default then update() end
    return {
        Set = function(v) state = v; update(); if cb then cb(v) end end,
        Get = function() return state end
    }
end

-- ================== DROPDOWN COM ALTA CAMADA ==================
local function Dropdown(parent, size, pos, placeholder, items, cb)
    local container = Frame(parent, size, pos, COLOR.ComponentBg, 5)
    Corner(container)
    local selectedLabel = Label(container, UDim2.new(1, -25, 1, 0), UDim2.new(0, 10, 0, 0), placeholder, COLOR.Gray, 14, 6)
    Label(container, UDim2.new(0, 20, 1, 0), UDim2.new(1, -25, 0, 0), "▼", COLOR.White, 12, 6)
    local btn = Button(container, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), "", nil, nil)
    btn.BackgroundTransparency = 1
    btn.ZIndex = 7

    -- Lista com ZIndex altíssimo para ficar acima de tudo
    local listFrame = Frame(nil, UDim2.new(1, 0, 0, 0), UDim2.new(0, 0, 1, 4), COLOR.ComponentBg, 999)
    Corner(listFrame)
    Stroke(listFrame, COLOR.Red, 1)
    listFrame.Visible = false
    listFrame.Parent = container

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -4, 1, -4)
    scroll.Position = UDim2.new(0, 2, 0, 2)
    scroll.BackgroundTransparency = 1
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.ScrollBarThickness = 2
    scroll.ScrollBarImageColor3 = COLOR.Red
    scroll.ZIndex = 1000
    scroll.Parent = listFrame
    local layout = Instance.new("UIListLayout")
    layout.Parent = scroll
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 5)
    end)

    local selectedItem = nil
    local function populate()
        for _, child in ipairs(scroll:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        for _, item in ipairs(items) do
            local itm = Instance.new("TextButton")
            itm.Size = UDim2.new(1, -4, 0, 26)
            itm.BackgroundColor3 = COLOR.Dark
            itm.Text = item
            itm.TextColor3 = COLOR.White
            itm.Font = FONT
            itm.TextSize = 13
            itm.BorderSizePixel = 0
            Corner(itm, UDim.new(0, 4))
            itm.ZIndex = 1001
            itm.Parent = scroll
            itm.MouseButton1Click:Connect(function()
                selectedItem = item
                selectedLabel.Text = item
                selectedLabel.TextColor3 = COLOR.White
                listFrame.Visible = false
                if cb then cb(item) end
            end)
        end
    end
    populate()
    btn.MouseButton1Click:Connect(function()
        listFrame.Visible = not listFrame.Visible
        if listFrame.Visible then
            listFrame.Size = UDim2.new(1, 0, 0, 0)
            TweenService:Create(listFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, math.clamp(#items * 26, 30, 150))}):Play()
        end
    end)
    return {
        UpdateItems = function(newItems)
            items = newItems
            populate()
            selectedItem = nil
            selectedLabel.Text = placeholder
            selectedLabel.TextColor3 = COLOR.Gray
        end,
        GetSelected = function() return selectedItem end
    }
end

-- ================== SLIDER ==================
local function Slider(parent, size, pos, text, min, max, default, cb)
    local cont = Frame(parent, size, pos, COLOR.ComponentBg, 3)
    Corner(cont)
    Label(cont, UDim2.new(0, 60, 1, 0), UDim2.new(0, 8, 0, 0), text, COLOR.White, 13, 4)
    local valLabel = Label(cont, UDim2.new(0, 40, 1, 0), UDim2.new(1, -45, 0, 0), tostring(default), COLOR.White, 13, 4)
    valLabel.TextXAlignment = Enum.TextXAlignment.Right
    local bar = Frame(cont, UDim2.new(1, -110, 0, 6), UDim2.new(0, 65, 0.5, -3), COLOR.Dark, 3)
    Corner(bar, UDim.new(1, 0))
    local fill = Frame(bar, UDim2.new((default - min) / (max - min), 0, 1, 0), UDim2.new(0, 0, 0, 0), COLOR.Red, 4)
    Corner(fill, UDim.new(1, 0))
    local knob = Frame(bar, UDim2.new(0, 14, 1, 6), UDim2.new(0, 0, 0, -3), COLOR.White, 5)
    Corner(knob, UDim.new(1, 0))
    local dragging = false
    local function update(input)
        local relX = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local val = math.floor((min + relX * (max - min)) * 100) / 100
        fill.Size = UDim2.new(relX, 0, 1, 0)
        knob.Position = UDim2.new(relX, -7, 0, -3)
        valLabel.Text = tostring(val)
        if cb then cb(val) end
    end
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            update(input)
            dragging = true
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    return cont
end

-- ================== NOTIFICAÇÃO ==================
local function Notify(title, msg)
    local notif = Frame(ScreenGui, UDim2.new(0, 260, 0, 60), UDim2.new(1, -270, 1, -70), Color3.fromRGB(15, 15, 15), 10)
    Corner(notif)
    Stroke(notif, COLOR.Red, 1)
    Label(notif, UDim2.new(1, -10, 0, 20), UDim2.new(0, 8, 0, 5), title, COLOR.Red, 16, 11).TextXAlignment = Enum.TextXAlignment.Left
    Label(notif, UDim2.new(1, -10, 0, 20), UDim2.new(0, 8, 0, 30), msg, COLOR.White, 12, 11).TextXAlignment = Enum.TextXAlignment.Left
    TweenService:Create(notif, TweenInfo.new(0.3), {Position = UDim2.new(1, -270, 1, -70)}):Play()
    delay(3, function()
        TweenService:Create(notif, TweenInfo.new(0.3), {Position = UDim2.new(1, 10, 1, -70)}):Play()
        wait(0.3)
        notif:Destroy()
    end)
end

-- ================== TELA DE LOGIN ==================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FireHub"
ScreenGui.Parent = CoreGui
ScreenGui.DisplayOrder = 999
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local loginFrame = Frame(ScreenGui, UDim2.new(0, 350, 0, 280), UDim2.new(0.5, -175, 0.5, -140), COLOR.Background, 1)
Corner(loginFrame)
Stroke(loginFrame, COLOR.Red, 2)
Glow(loginFrame, COLOR.Red, 25)
Draggable(loginFrame)

local topBar = Frame(loginFrame, UDim2.new(1, 0, 0, 40), UDim2.new(0, 0, 0, 0), COLOR.DarkRed, 2)
Corner(topBar, UDim.new(0, 8))
Label(topBar, UDim2.new(1, -35, 1, 0), UDim2.new(0, 10, 0, 0), "FIRE HUB", COLOR.White, 20, 3)
Button(topBar, UDim2.new(0, 30, 0, 30), UDim2.new(1, -35, 0, 5), "×", COLOR.DarkRed, function() ScreenGui:Destroy() end).TextSize = 22

Label(loginFrame, UDim2.new(0, 80, 0, 40), UDim2.new(0.5, -40, 0, 42), "🔥", COLOR.Red, 34, 2)
Label(loginFrame, UDim2.new(1, -20, 0, 20), UDim2.new(0, 10, 0, 90), "Insira a chave de acesso", COLOR.White, 14, 2)
local keyBox = TextBox(loginFrame, UDim2.new(1, -40, 0, 36), UDim2.new(0, 20, 0, 120), "Chave...")
Stroke(keyBox, COLOR.Red, 1)

local statusLabel = Label(loginFrame, UDim2.new(1, -20, 0, 20), UDim2.new(0, 20, 0, 190), "", COLOR.Red, 13, 2)
statusLabel.TextTransparency = 1

local function shake(elem)
    local orig = elem.Position
    for _, x in ipairs({5, -5, 0}) do
        TweenService:Create(elem, TweenInfo.new(0.04), {Position = orig + UDim2.new(0, x, 0, 0)}):Play()
        wait(0.04)
    end
end

Button(loginFrame, UDim2.new(1, -40, 0, 38), UDim2.new(0, 20, 0, 162), "Verificar", COLOR.DarkRed, function()
    if keyBox.Text == "menu k" then
        Notify("FIRE HUB", "Acesso liberado!")
        TweenService:Create(loginFrame, TweenInfo.new(0.4), {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
        wait(0.4)
        loginFrame:Destroy()
        BuildHub()
    else
        keyBox.BackgroundColor3 = Color3.fromRGB(255, 40, 40)
        shake(keyBox)
        statusLabel.Text = "Chave inválida!"
        statusLabel.TextTransparency = 0
        wait(1)
        keyBox.BackgroundColor3 = COLOR.ComponentBg
        TweenService:Create(statusLabel, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    end
end)

Label(loginFrame, UDim2.new(1, -40, 0, 20), UDim2.new(0, 20, 0, 210), "Não tem chave? Contate o admin.", COLOR.Gray, 11, 2)

-- ================== CONSTRUÇÃO DO HUB ==================
function BuildHub()
    local main = Frame(ScreenGui, UDim2.new(0, 620, 0, 420), UDim2.new(0.5, -310, 0.5, -210), COLOR.Background, 2)
    main.Visible = false
    main.Size = UDim2.new(0, 0, 0, 0)
    Corner(main)
    Stroke(main, COLOR.Red, 2)
    Glow(main, COLOR.Red, 22)
    Draggable(main)

    local topBar = Frame(main, UDim2.new(1, 0, 0, 42), UDim2.new(0, 0, 0, 0), COLOR.DarkRed, 3)
    Corner(topBar, UDim.new(0, 8))
    Label(topBar, UDim2.new(1, -70, 1, 0), UDim2.new(0, 12, 0, 0), "FIRE HUB", COLOR.White, 20, 4)
    Button(topBar, UDim2.new(0, 32, 0, 32), UDim2.new(1, -70, 0, 5), "—", COLOR.DarkRed, function() main.Visible = false end)
    Button(topBar, UDim2.new(0, 32, 0, 32), UDim2.new(1, -36, 0, 5), "×", COLOR.DarkRed, function() main.Visible = false end).TextSize = 20

    local sidebar = Frame(main, UDim2.new(0, 130, 1, -42), UDim2.new(0, 0, 0, 42), Color3.fromRGB(15, 15, 15), 2)
    local contentArea = Frame(main, UDim2.new(1, -130, 1, -42), UDim2.new(0, 130, 0, 42), COLOR.Background, 2)

    local tabs = {}
    local activeTab = nil
    local tabNames = {"ℹ️ Info", "🔥 Principal", "👤 Avatar", "🔊 Áudio", "⚔️ Combate", "🏃 Movimento", "📦 Outros", "⚡ Jogador", "⚙️ Config"}

    local function switchTab(name, build)
        if activeTab and activeTab.content then activeTab.content:Destroy() end
        if activeTab and activeTab.btn then activeTab.btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15) end
        local btn = tabs[name]
        btn.BackgroundColor3 = COLOR.DarkRed
        local content = build()
        content.Parent = contentArea
        activeTab = {btn = btn, content = content}
    end

    for i, name in ipairs(tabNames) do
        local btn = Button(sidebar, UDim2.new(1, -6, 0, 34), UDim2.new(0, 3, 0, (i - 1) * 36 + 4), name, Color3.fromRGB(15, 15, 15))
        btn.TextSize = 12
        Corner(btn, UDim.new(0, 5))
        tabs[name] = btn
    end

    -- Lista global de dropdowns de jogadores para atualização
    _G.PlayerDropdowns = {}

    local function updateAllPlayerDropdowns()
        local players = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                table.insert(players, p.Name)
            end
        end
        for _, dd in ipairs(_G.PlayerDropdowns) do
            dd.UpdateItems(players)
        end
    end

    -- Função para criar um dropdown de jogador e registrá-lo
    local function createPlayerDropdown(parent, size, pos, placeholder)
        local dd = Dropdown(parent, size, pos, placeholder, {}, function() end)
        table.insert(_G.PlayerDropdowns, dd)
        -- Atualizar imediatamente com a lista atual
        local currentList = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then table.insert(currentList, p.Name) end
        end
        dd.UpdateItems(currentList)
        return dd
    end

    -- ============ ABA INFO ============
    tabs["ℹ️ Info"].MouseButton1Click:Connect(function()
        switchTab("ℹ️ Info", function()
            local f = Frame(nil, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0))
            Label(f, UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, 15), "Bem-vindo ao Fire Hub", COLOR.Red, 22)
            Label(f, UDim2.new(1, -20, 0, 60), UDim2.new(0, 10, 0, 55), "Interface modular e otimizada.", COLOR.White, 14)
            return f
        end)
    end)

    -- ============ ABA PRINCIPAL (REFEITA) ============
    tabs["🔥 Principal"].MouseButton1Click:Connect(function()
        switchTab("🔥 Principal", function()
            local f = Frame(nil, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0))
            local y = 10

            -- Linha Jogador
            local row1 = Frame(f, UDim2.new(1, -20, 0, 36), UDim2.new(0, 10, 0, y), nil, 2)
            row1.BackgroundTransparency = 1
            Label(row1, UDim2.new(0, 65, 1, 0), UDim2.new(0, 0, 0, 0), "Jogador", COLOR.White, 13, 2)
            local playerDD = createPlayerDropdown(row1, UDim2.new(1, -70, 1, 0), UDim2.new(0, 70, 0, 0), "Selecionar")
            y = y + 46

            -- Linha Método
            local row2 = Frame(f, UDim2.new(1, -20, 0, 36), UDim2.new(0, 10, 0, y), nil, 2)
            row2.BackgroundTransparency = 1
            Label(row2, UDim2.new(0, 65, 1, 0), UDim2.new(0, 0, 0, 0), "Método", COLOR.White, 13, 2)
            local methodDD = Dropdown(row2, UDim2.new(1, -70, 1, 0), UDim2.new(0, 70, 0, 0), "Escolher", {"Ball", "Bus", "Boat"}, function() end)
            y = y + 46

            -- Botão Kill (com seta >)
            local killRow = Frame(f, UDim2.new(1, -20, 0, 36), UDim2.new(0, 10, 0, y), nil, 2)
            killRow.BackgroundTransparency = 1
            Label(killRow, UDim2.new(0, 65, 1, 0), UDim2.new(0, 0, 0, 0), "Kill", COLOR.White, 13, 2)
            Button(killRow, UDim2.new(1, -70, 1, 0), UDim2.new(0, 70, 0, 0), "Kill >", COLOR.DarkRed, function()
                local target = playerDD.GetSelected()
                if target then
                    local plr = Players:FindFirstChild(target)
                    if plr and plr.Character and plr.Character:FindFirstChild("Humanoid") then
                        plr.Character.Humanoid.Health = 0
                        Notify("Kill", target .. " eliminado")
                    end
                end
            end)
            y = y + 46

            -- Toggle Fling
            local flingRow = Frame(f, UDim2.new(1, -20, 0, 24), UDim2.new(0, 10, 0, y), nil, 2)
            flingRow.BackgroundTransparency = 1
            Label(flingRow, UDim2.new(0, 65, 1, 0), UDim2.new(0, 0, 0, 0), "Fling", COLOR.White, 13, 2)
            ToggleSwitch(flingRow, UDim2.new(0, 44, 0, 24), UDim2.new(0, 70, 0, 0), false, function(state) end)
            y = y + 30

            -- Toggle View
            local viewRow = Frame(f, UDim2.new(1, -20, 0, 24), UDim2.new(0, 10, 0, y), nil, 2)
            viewRow.BackgroundTransparency = 1
            Label(viewRow, UDim2.new(0, 65, 1, 0), UDim2.new(0, 0, 0, 0), "View", COLOR.White, 13, 2)
            ToggleSwitch(viewRow, UDim2.new(0, 44, 0, 24), UDim2.new(0, 70, 0, 0), false, function(state) end)
            y = y + 30

            -- Toggle Black Hole (nova)
            local bhRow = Frame(f, UDim2.new(1, -20, 0, 24), UDim2.new(0, 10, 0, y), nil, 2)
            bhRow.BackgroundTransparency = 1
            Label(bhRow, UDim2.new(0, 65, 1, 0), UDim2.new(0, 0, 0, 0), "Black Hole", COLOR.White, 13, 2)
            ToggleSwitch(bhRow, UDim2.new(0, 44, 0, 24), UDim2.new(0, 70, 0, 0), false, function(state) end)

            return f
        end)
    end)

    -- ============ ABA AVATAR (ALINHADA) ============
    tabs["👤 Avatar"].MouseButton1Click:Connect(function()
        switchTab("👤 Avatar", function()
            local f = Frame(nil, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0))
            local row = Frame(f, UDim2.new(1, -20, 0, 36), UDim2.new(0, 10, 0, 10), nil, 2)
            row.BackgroundTransparency = 1
            Label(row, UDim2.new(0, 65, 1, 0), UDim2.new(0, 0, 0, 0), "Avatar", COLOR.White, 13, 2)
            local avatarDD = createPlayerDropdown(row, UDim2.new(1, -70, 1, 0), UDim2.new(0, 70, 0, 0), "Jogador")
            Button(f, UDim2.new(1, -20, 0, 36), UDim2.new(0, 10, 0, 56), "Copiar Avatar", COLOR.DarkRed, function()
                local plrName = avatarDD.GetSelected()
                if plrName then
                    local target = Players:FindFirstChild(plrName)
                    if target and target.Character and target.Character:FindFirstChild("Humanoid") then
                        local desc = target.Character.Humanoid:GetAppliedDescription()
                        if desc and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                            LocalPlayer.Character.Humanoid:ApplyDescription(desc)
                            Notify("Avatar", "Copiado de " .. plrName)
                        end
                    end
                end
            end)
            return f
        end)
    end)

    -- ============ ABA ÁUDIO (REORGANIZADA) ============
    tabs["🔊 Áudio"].MouseButton1Click:Connect(function()
        switchTab("🔊 Áudio", function()
            local f = Frame(nil, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0))
            local y = 10

            -- Linha Áudio (label + textbox)
            local row1 = Frame(f, UDim2.new(1, -20, 0, 36), UDim2.new(0, 10, 0, y), nil, 2)
            row1.BackgroundTransparency = 1
            Label(row1, UDim2.new(0, 65, 1, 0), UDim2.new(0, 0, 0, 0), "Áudio", COLOR.White, 13, 2)
            local audioInput = TextBox(row1, UDim2.new(1, -70, 1, 0), UDim2.new(0, 70, 0, 0), "ID do áudio")
            y = y + 46

            -- Linha Arquivos (dropdown com IDs salvos)
            local row2 = Frame(f, UDim2.new(1, -20, 0, 36), UDim2.new(0, 10, 0, y), nil, 2)
            row2.BackgroundTransparency = 1
            Label(row2, UDim2.new(0, 65, 1, 0), UDim2.new(0, 0, 0, 0), "Arquivos", COLOR.White, 13, 2)
            local savedAudio = {}
            local savedDD = Dropdown(row2, UDim2.new(1, -70, 1, 0), UDim2.new(0, 70, 0, 0), "Salvos", savedAudio, function() end)
            y = y + 46

            -- Toggle Tocar (com label)
            local row3 = Frame(f, UDim2.new(1, -20, 0, 24), UDim2.new(0, 10, 0, y), nil, 2)
            row3.BackgroundTransparency = 1
            Label(row3, UDim2.new(0, 65, 1, 0), UDim2.new(0, 0, 0, 0), "Tocar", COLOR.White, 13, 2)
            local currentSound = nil
            local playTog = ToggleSwitch(row3, UDim2.new(0, 44, 0, 24), UDim2.new(0, 70, 0, 0), false, function(state)
                if state then
                    local sel = savedDD.GetSelected()
                    if sel and tonumber(sel) then
                        if currentSound then currentSound:Destroy() end
                        currentSound = Instance.new("Sound")
                        currentSound.SoundId = "rbxassetid://" .. sel
                        currentSound.Volume = 1
                        currentSound.Parent = workspace
                        currentSound:Play()
                    end
                else
                    if currentSound then
                        currentSound:Stop()
                        currentSound:Destroy()
                        currentSound = nil
                    end
                end
            end)
            y = y + 30

            -- Botão Save (>)
            local saveRow = Frame(f, UDim2.new(1, -20, 0, 36), UDim2.new(0, 10, 0, y), nil, 2)
            saveRow.BackgroundTransparency = 1
            Label(saveRow, UDim2.new(0, 65, 1, 0), UDim2.new(0, 0, 0, 0), "Save", COLOR.White, 13, 2)
            Button(saveRow, UDim2.new(1, -70, 1, 0), UDim2.new(0, 70, 0, 0), "Save >", COLOR.DarkRed, function()
                local id = audioInput.Text
                if id ~= "" and tonumber(id) and not table.find(savedAudio, id) then
                    table.insert(savedAudio, id)
                    savedDD.UpdateItems(savedAudio)
                    Notify("Áudio", "ID " .. id .. " salvo!")
                end
            end)

            return f
        end)
    end)

    -- ============ ABA JOGADOR (SLIDERS) ============
    tabs["⚡ Jogador"].MouseButton1Click:Connect(function()
        switchTab("⚡ Jogador", function()
            local f = Frame(nil, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0))
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
            Slider(f, UDim2.new(1, -20, 0, 32), UDim2.new(0, 10, 0, 10), "Velocidade", 16, 200, 16, function(v) if hum then hum.WalkSpeed = v end end)
            Slider(f, UDim2.new(1, -20, 0, 32), UDim2.new(0, 10, 0, 50), "Pulo", 50, 200, 50, function(v) if hum then hum.JumpPower = v end end)
            Slider(f, UDim2.new(1, -20, 0, 32), UDim2.new(0, 10, 0, 90), "Gravidade", 0, 196.2, 196.2, function(v) workspace.Gravity = v end)
            Slider(f, UDim2.new(1, -20, 0, 32), UDim2.new(0, 10, 0, 130), "HipHeight", 0, 10, 2, function(v) if hum then hum.HipHeight = v end end)
            Slider(f, UDim2.new(1, -20, 0, 32), UDim2.new(0, 10, 0, 170), "FOV", 30, 120, 70, function(v) workspace.CurrentCamera.FieldOfView = v end)
            return f
        end)
    end)

    -- Demais abas (placeholder)
    for _, name in ipairs({"⚔️ Combate", "🏃 Movimento", "📦 Outros", "⚙️ Config"}) do
        tabs[name].MouseButton1Click:Connect(function()
            switchTab(name, function()
                local f = Frame(nil, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0))
                Label(f, UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, 15), "Em breve...", COLOR.Gray, 14)
                return f
            end)
        end)
    end

    -- Botão flutuante (apenas emoji)
    local floatBtn = Instance.new("TextButton")
    floatBtn.Size = UDim2.new(0, 60, 0, 60)
    floatBtn.Position = UDim2.new(0, 20, 0.5, -30)
    floatBtn.BackgroundTransparency = 1
    floatBtn.Text = "🔥"
    floatBtn.TextSize = 38
    floatBtn.Font = FONT
    floatBtn.ZIndex = 10
    floatBtn.Parent = ScreenGui
    Draggable(floatBtn)

    floatBtn.MouseButton1Click:Connect(function()
        if main.Visible then
            TweenService:Create(main, TweenInfo.new(0.25), {Size = UDim2.new(0, 0, 0, 0)}):Play()
            wait(0.25)
            main.Visible = false
        else
            main.Visible = true
            TweenService:Create(main, TweenInfo.new(0.25), {Size = UDim2.new(0, 620, 0, 420)}):Play()
        end
    end)

    -- Atualização automática ao entrar/sair jogadores
    Players.PlayerAdded:Connect(updateAllPlayerDropdowns)
    Players.PlayerRemoving:Connect(updateAllPlayerDropdowns)
end
