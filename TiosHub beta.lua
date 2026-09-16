-- ═══════════════ §12  UI BUILDER (CLEAN THEME) ═══════════════
-- Palette
local CLR = {
    bg         = Color3.fromRGB(18, 18, 22),
    bgHeader   = Color3.fromRGB(24, 24, 30),
    bgCard     = Color3.fromRGB(28, 28, 34),
    bgHover    = Color3.fromRGB(38, 38, 46),
    bgInput    = Color3.fromRGB(34, 34, 40),
    accent     = Color3.fromRGB(235, 65, 85),
    accentAlt  = Color3.fromRGB(255, 100, 120),
    accentDim  = Color3.fromRGB(120, 40, 52),
    text       = Color3.fromRGB(240, 240, 245),
    textDim    = Color3.fromRGB(150, 150, 160),
    textMuted  = Color3.fromRGB(100, 100, 110),
    border     = Color3.fromRGB(45, 45, 55),
    green      = Color3.fromRGB(80, 220, 130),
    cyan       = Color3.fromRGB(80, 200, 240),
    yellow     = Color3.fromRGB(255, 200, 100),
    red        = Color3.fromRGB(240, 80, 80),
}
local FONT       = Enum.Font.GothamMedium
local FONT_BOLD  = Enum.Font.GothamBold
local FONT_BLACK = Enum.Font.GothamBlack

local function corner(obj, r)
    local c = Instance.new("UICorner", obj)
    c.CornerRadius = UDim.new(0, r or 8)
    return c
end

local function stroke(obj, color, thick, trans)
    local s = Instance.new("UIStroke", obj)
    s.Color = color or CLR.border
    s.Thickness = thick or 1
    s.Transparency = trans or 0.4
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end

local function makeDraggable(gui)
    local dragging, dragStart, startPos, dragInput
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging, dragStart, startPos = true, input.Position, gui.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local dd = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + dd.X,
                startPos.Y.Scale, startPos.Y.Offset + dd.Y)
        end
    end)
end

-- Hover effect
local function addHover(btn, normalColor, hoverColor)
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = hoverColor
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = normalColor
    end)
end

-- Toggle icon (nút tròn)
local ToggleIcon = Instance.new("TextButton", ScreenGui)
ToggleIcon.Size = UDim2.new(0, 50, 0, 50)
ToggleIcon.Position = UDim2.new(0.02, 0, 0.3, 0)
ToggleIcon.BackgroundColor3 = CLR.accent
ToggleIcon.TextColor3 = Color3.new(1,1,1)
ToggleIcon.Text = "⚔"
ToggleIcon.Font = FONT_BLACK
ToggleIcon.TextSize = 22
ToggleIcon.Active = true
ToggleIcon.AutoButtonColor = false
corner(ToggleIcon, 25)
local toggleStroke = stroke(ToggleIcon, CLR.accentAlt, 1.5, 0.3)
makeDraggable(ToggleIcon)
addHover(ToggleIcon, CLR.accent, CLR.accentAlt)

-- Main frame
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 300, 0, 520)
Main.Position = UDim2.new(0.15, 0, 0.12, 0)
Main.BackgroundColor3 = CLR.bg
Main.BorderSizePixel = 0
Main.Active = true
corner(Main, 12)
stroke(Main, CLR.border, 1, 0.3)
makeDraggable(Main)

-- Header (gradient)
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 44)
Header.BackgroundColor3 = CLR.bgHeader
Header.BorderSizePixel = 0
corner(Header, 12)
local headerGradient = Instance.new("UIGradient", Header)
headerGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, CLR.accent),
    ColorSequenceKeypoint.new(0.5, CLR.accentDim),
    ColorSequenceKeypoint.new(1, CLR.bgHeader),
})
headerGradient.Rotation = 15

-- Header cover (che phần dưới của UICorner)
local headerCover = Instance.new("Frame", Header)
headerCover.Size = UDim2.new(1, 0, 0.5, 0)
headerCover.Position = UDim2.new(0, 0, 0.5, 0)
headerCover.BackgroundColor3 = CLR.bgHeader
headerCover.BorderSizePixel = 0
headerCover.ZIndex = 1

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(0.75, 0, 1, 0)
Title.Position = UDim2.new(0.05, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "COMBAT HUB"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = FONT_BLACK
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 2

local TitleSub = Instance.new("TextLabel", Header)
TitleSub.Size = UDim2.new(0.3, 0, 1, 0)
TitleSub.Position = UDim2.new(0.75, 0, 0, 0)
TitleSub.BackgroundTransparency = 1
TitleSub.Text = "v10.1"
TitleSub.TextColor3 = CLR.textDim
TitleSub.Font = FONT_BOLD
TitleSub.TextSize = 10
TitleSub.TextXAlignment = Enum.TextXAlignment.Right
TitleSub.ZIndex = 2

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(0.9, 0, 0.5, 0)
CloseBtn.AnchorPoint = Vector2.new(0, 0.5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(60, 30, 35)
CloseBtn.TextColor3 = CLR.red
CloseBtn.Text = "✕"
CloseBtn.Font = FONT_BOLD
CloseBtn.TextSize = 14
CloseBtn.AutoButtonColor = false
CloseBtn.ZIndex = 3
corner(CloseBtn, 6)
stroke(CloseBtn, CLR.red, 1, 0.5)
addHover(CloseBtn, Color3.fromRGB(60, 30, 35), Color3.fromRGB(90, 40, 45))

-- Minimize button
local MinBtn = Instance.new("TextButton", Header)
MinBtn.Size = UDim2.new(0, 28, 0, 28)
MinBtn.Position = UDim2.new(0.76, 0, 0.5, 0)
MinBtn.AnchorPoint = Vector2.new(0, 0.5)
MinBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
MinBtn.TextColor3 = CLR.textDim
MinBtn.Text = "—"
MinBtn.Font = FONT_BOLD
MinBtn.TextSize = 14
MinBtn.AutoButtonColor = false
MinBtn.ZIndex = 3
corner(MinBtn, 6)
addHover(MinBtn, Color3.fromRGB(40, 40, 50), Color3.fromRGB(55, 55, 65))

-- Toggle visibility
local minimized = false
local normalHeight = 520
local function toggleUI() Main.Visible = not Main.Visible end
local function toggleMinimize()
    minimized = not minimized
    if minimized then
        Main:TweenSize(UDim2.new(0, 300, 0, 44), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
    else
        Main:TweenSize(UDim2.new(0, 300, 0, normalHeight), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
    end
end
ToggleIcon.MouseButton1Click:Connect(toggleUI)
CloseBtn.MouseButton1Click:Connect(toggleUI)
MinBtn.MouseButton1Click:Connect(toggleMinimize)

-- Search bar
local SearchBox = Instance.new("Frame", Main)
SearchBox.Size = UDim2.new(1, -20, 0, 30)
SearchBox.Position = UDim2.new(0, 10, 0, 50)
SearchBox.BackgroundColor3 = CLR.bgInput
SearchBox.BorderSizePixel = 0
corner(SearchBox, 8)
stroke(SearchBox, CLR.border, 1, 0.5)

local SearchIcon = Instance.new("TextLabel", SearchBox)
SearchIcon.Size = UDim2.new(0, 30, 1, 0)
SearchIcon.BackgroundTransparency = 1
SearchIcon.Text = "🔍"
SearchIcon.TextColor3 = CLR.textMuted
SearchIcon.TextSize = 12
SearchIcon.Font = FONT

local SearchInput = Instance.new("TextBox", SearchBox)
SearchInput.Size = UDim2.new(1, -40, 1, 0)
SearchInput.Position = UDim2.new(0, 35, 0, 0)
SearchInput.BackgroundTransparency = 1
SearchInput.Text = ""
SearchInput.PlaceholderText = "Tìm chức năng..."
SearchInput.PlaceholderColor3 = CLR.textMuted
SearchInput.TextColor3 = CLR.text
SearchInput.Font = FONT
SearchInput.TextSize = 11
SearchInput.TextXAlignment = Enum.TextXAlignment.Left

-- Scroll area
local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -20, 1, -100)
Scroll.Position = UDim2.new(0, 10, 0, 88)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 3
Scroll.ScrollBarImageColor3 = CLR.accent
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)

local LL = Instance.new("UIListLayout", Scroll)
LL.SortOrder = Enum.SortOrder.LayoutOrder
LL.Padding = UDim.new(0, 4)
LL.HorizontalAlignment = Enum.HorizontalAlignment.Center

local pad = Instance.new("UIPadding", Scroll)
pad.PaddingTop = UDim.new(0, 4)
pad.PaddingBottom = UDim.new(0, 12)

-- Search filter tracking
local searchQuery = ""
local allRows = {} -- [row] = searchText

local function registerSearch(row, text)
    allRows[row] = string.lower(text)
    -- Apply filter
    local q = searchQuery
    if q == "" then
        row.Visible = true
    else
        row.Visible = string.find(string.lower(text), q, 1, true) ~= nil
    end
end

SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
    searchQuery = string.lower(SearchInput.Text)
    for row, txt in pairs(allRows) do
        if searchQuery == "" then
            row.Visible = true
        else
            row.Visible = string.find(txt, searchQuery, 1, true) ~= nil
        end
    end
end)

-- ──────── WIDGETS ────────
local function addSection(text)
    local wrap = Instance.new("Frame", Scroll)
    wrap.Size = UDim2.new(0.96, 0, 0, 26)
    wrap.BackgroundTransparency = 1
    wrap.LayoutOrder = 1

    local lineL = Instance.new("Frame", wrap)
    lineL.Size = UDim2.new(0.25, -4, 0, 1)
    lineL.Position = UDim2.new(0, 0, 0.5, 0)
    lineL.BackgroundColor3 = CLR.accent
    lineL.BorderSizePixel = 0
    lineL.BackgroundTransparency = 0.4

    local lbl = Instance.new("TextLabel", wrap)
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.Position = UDim2.new(0.25, 0, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = string.upper(text)
    lbl.TextColor3 = CLR.accentAlt
    lbl.Font = FONT_BLACK
    lbl.TextSize = 10
    lbl.ZIndex = 1

    local lineR = Instance.new("Frame", wrap)
    lineR.Size = UDim2.new(0.25, -4, 0, 1)
    lineR.Position = UDim2.new(0.75, 4, 0.5, 0)
    lineR.BackgroundColor3 = CLR.accent
    lineR.BorderSizePixel = 0
    lineR.BackgroundTransparency = 0.4

    registerSearch(wrap, "section " .. text)
    return wrap
end

-- Toggle switch (đẹp hơn)
local function addToggle(text, cb)
    local card = Instance.new("TextButton", Scroll)
    card.Size = UDim2.new(0.96, 0, 0, 36)
    card.BackgroundColor3 = CLR.bgCard
    card.Text = ""
    card.AutoButtonColor = false
    card.BorderSizePixel = 0
    corner(card, 8)

    local nameLbl = Instance.new("TextLabel", card)
    nameLbl.Size = UDim2.new(1, -70, 1, 0)
    nameLbl.Position = UDim2.new(0, 12, 0, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = text
    nameLbl.TextColor3 = CLR.text
    nameLbl.Font = FONT
    nameLbl.TextSize = 11
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left

    -- Switch track
    local track = Instance.new("Frame", card)
    track.Size = UDim2.new(0, 38, 0, 20)
    track.Position = UDim2.new(1, -50, 0.5, 0)
    track.AnchorPoint = Vector2.new(0, 0.5)
    track.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    track.BorderSizePixel = 0
    corner(track, 10)
    local trackStroke = stroke(track, CLR.border, 1, 0.3)

    -- Thumb
    local thumb = Instance.new("Frame", track)
    thumb.Size = UDim2.new(0, 16, 0, 16)
    thumb.Position = UDim2.new(0, 2, 0.5, 0)
    thumb.AnchorPoint = Vector2.new(0, 0.5)
    thumb.BackgroundColor3 = Color3.fromRGB(140, 140, 150)
    thumb.BorderSizePixel = 0
    corner(thumb, 8)

    local st = false
    local function setState(v)
        st = v
        if v then
            track.BackgroundColor3 = CLR.accent
            trackStroke.Color = CLR.accentAlt
            thumb.BackgroundColor3 = Color3.new(1, 1, 1)
            thumb:TweenPosition(UDim2.new(1, -18, 0.5, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
        else
            track.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            trackStroke.Color = CLR.border
            thumb.BackgroundColor3 = Color3.fromRGB(140, 140, 150)
            thumb:TweenPosition(UDim2.new(0, 2, 0.5, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
        end
    end

    card.MouseEnter:Connect(function() card.BackgroundColor3 = CLR.bgHover end)
    card.MouseLeave:Connect(function() card.BackgroundColor3 = CLR.bgCard end)
    card.MouseButton1Click:Connect(function()
        setState(not st)
        cb(st)
    end)

    registerSearch(card, "toggle " .. text)
    return { frame = card, setState = setState }
end

-- Slider
local function addSlider(name, def, mn, mx, cb)
    local card = Instance.new("Frame", Scroll)
    card.Size = UDim2.new(0.96, 0, 0, 52)
    card.BackgroundColor3 = CLR.bgCard
    card.BorderSizePixel = 0
    corner(card, 8)

    local nameLbl = Instance.new("TextLabel", card)
    nameLbl.Size = UDim2.new(1, -80, 0, 22)
    nameLbl.Position = UDim2.new(0, 12, 0, 4)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = name
    nameLbl.TextColor3 = CLR.text
    nameLbl.Font = FONT
    nameLbl.TextSize = 11
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left

    local valLbl = Instance.new("TextLabel", card)
    valLbl.Size = UDim2.new(0, 60, 0, 22)
    valLbl.Position = UDim2.new(1, -70, 0, 4)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(def)
    valLbl.TextColor3 = CLR.accentAlt
    valLbl.Font = FONT_BOLD
    valLbl.TextSize = 11
    valLbl.TextXAlignment = Enum.TextXAlignment.Right

    -- Step cycler nhỏ
    local steps = {1, 2, 5, 10}
    local si, step = 1, 1
    local stepBtn = Instance.new("TextButton", card)
    stepBtn.Size = UDim2.new(0, 40, 0, 18)
    stepBtn.Position = UDim2.new(0, 12, 0, 28)
    stepBtn.BackgroundColor3 = CLR.bgInput
    stepBtn.TextColor3 = CLR.textMuted
    stepBtn.Text = "±" .. step
    stepBtn.Font = FONT_BOLD
    stepBtn.TextSize = 9
    stepBtn.AutoButtonColor = false
    corner(stepBtn, 4)
    addHover(stepBtn, CLR.bgInput, CLR.bgHover)
    stepBtn.MouseButton1Click:Connect(function()
        si = si + 1; if si > #steps then si = 1 end
        step = steps[si]
        stepBtn.Text = "±" .. step
    end)

    -- Minus / Plus
    local sub = Instance.new("TextButton", card)
    sub.Size = UDim2.new(0, 40, 0, 18)
    sub.Position = UDim2.new(0.5, -45, 0, 28)
    sub.BackgroundColor3 = CLR.bgInput
    sub.TextColor3 = CLR.red
    sub.Text = "−"
    sub.Font = FONT_BLACK
    sub.TextSize = 14
    sub.AutoButtonColor = false
    corner(sub, 4)
    addHover(sub, CLR.bgInput, Color3.fromRGB(60, 30, 35))

    local add = Instance.new("TextButton", card)
    add.Size = UDim2.new(0, 40, 0, 18)
    add.Position = UDim2.new(0.5, 5, 0, 28)
    add.BackgroundColor3 = CLR.bgInput
    add.TextColor3 = CLR.green
    add.Text = "+"
    add.Font = FONT_BLACK
    add.TextSize = 14
    add.AutoButtonColor = false
    corner(add, 4)
    addHover(add, CLR.bgInput, Color3.fromRGB(30, 55, 40))

    local val = def
    local function set(v)
        val = v
        valLbl.Text = tostring(v)
        cb(v)
    end
    sub.MouseButton1Click:Connect(function() set(math.max(mn, val - step)) end)
    add.MouseButton1Click:Connect(function() set(math.min(mx, val + step)) end)

    registerSearch(card, "slider " .. name)
end

-- Cycler
local function addCycler(name, options, cb)
    local card = Instance.new("TextButton", Scroll)
    card.Size = UDim2.new(0.96, 0, 0, 36)
    card.BackgroundColor3 = CLR.bgCard
    card.Text = ""
    card.AutoButtonColor = false
    card.BorderSizePixel = 0
    corner(card, 8)

    local nameLbl = Instance.new("TextLabel", card)
    nameLbl.Size = UDim2.new(0.6, 0, 1, 0)
    nameLbl.Position = UDim2.new(0, 12, 0, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = name
    nameLbl.TextColor3 = CLR.text
    nameLbl.Font = FONT
    nameLbl.TextSize = 11
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left

    local valLbl = Instance.new("TextLabel", card)
    valLbl.Size = UDim2.new(0.4, -12, 1, 0)
    valLbl.Position = UDim2.new(0.6, 0, 0, 0)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = options[1]
    valLbl.TextColor3 = CLR.cyan
    valLbl.Font = FONT_BOLD
    valLbl.TextSize = 11
    valLbl.TextXAlignment = Enum.TextXAlignment.Right

    card.MouseEnter:Connect(function() card.BackgroundColor3 = CLR.bgHover end)
    card.MouseLeave:Connect(function() card.BackgroundColor3 = CLR.bgCard end)

    local i = 1
    card.MouseButton1Click:Connect(function()
        i = i + 1; if i > #options then i = 1 end
        valLbl.Text = options[i]
        cb(options[i])
    end)

    registerSearch(card, "cycler " .. name)
end

-- ═══════════════ §13  VISUAL OVERLAYS ═══════════════
local FOVFrame = Instance.new("Frame", FOVGui)
FOVFrame.AnchorPoint, FOVFrame.Position = Vector2.new(0.5,0.5), UDim2.new(0.5,0,0.5,0)
FOVFrame.BackgroundTransparency, FOVFrame.Visible = 1, false
local FOVStroke = Instance.new("UIStroke", FOVFrame)
FOVStroke.Transparency = 0.2
corner(FOVFrame, 999)

local SilentFOVFrame = Instance.new("Frame", SilentFOVGui)
SilentFOVFrame.AnchorPoint, SilentFOVFrame.Position = Vector2.new(0.5,0.5), UDim2.new(0.5,0,0.5,0)
SilentFOVFrame.BackgroundTransparency, SilentFOVFrame.Visible = 1, false
local SilentStroke = Instance.new("UIStroke", SilentFOVFrame)
SilentStroke.Transparency, SilentStroke.Color = 0.2, CLR.cyan
corner(SilentFOVFrame, 999)

local legitIndicator = Instance.new("Frame", ScreenGui)
legitIndicator.Size, legitIndicator.BackgroundColor3 = UDim2.new(0,14,0,14), CLR.green
legitIndicator.BackgroundTransparency = 0.3
legitIndicator.AnchorPoint, legitIndicator.Visible = Vector2.new(0.5,0.5), false
corner(legitIndicator, 999)
local indStroke = Instance.new("UIStroke", legitIndicator)
indStroke.Color, indStroke.Thickness = Color3.new(1,1,1), 1

-- Info panel
local InfoPanel = Instance.new("Frame", InfoGui)
InfoPanel.Size, InfoPanel.Position = UDim2.new(0,220,0,110), UDim2.new(0.72,0,0.05,0)
InfoPanel.BackgroundColor3, InfoPanel.BackgroundTransparency = CLR.bg, 0.05
InfoPanel.BorderSizePixel, InfoPanel.Visible, InfoPanel.Active = 0, false, true
corner(InfoPanel, 10)
local infoStroke = Instance.new("UIStroke", InfoPanel)
infoStroke.Color, infoStroke.Thickness = CLR.accent, 1
makeDraggable(InfoPanel)

local infoTitleBar = Instance.new("Frame", InfoPanel)
infoTitleBar.Size = UDim2.new(1, 0, 0, 26)
infoTitleBar.BackgroundColor3 = CLR.bgHeader
infoTitleBar.BorderSizePixel = 0
corner(infoTitleBar, 10)

local infoTitle = Instance.new("TextLabel", infoTitleBar)
infoTitle.Size = UDim2.new(1,-10,1,0)
infoTitle.Position = UDim2.new(0,10,0,0)
infoTitle.BackgroundTransparency = 1
infoTitle.TextColor3, infoTitle.Font, infoTitle.TextSize = CLR.accentAlt, FONT_BLACK, 11
infoTitle.TextXAlignment, infoTitle.Text = Enum.TextXAlignment.Left, "🎯 TARGET INFO"

local infoName = Instance.new("TextLabel", InfoPanel)
infoName.Size, infoName.Position = UDim2.new(1,-16,0,20), UDim2.new(0,8,0,30)
infoName.BackgroundTransparency = 1
infoName.TextColor3, infoName.Font, infoName.TextSize = CLR.text, FONT_BOLD, 12
infoName.TextXAlignment, infoName.Text = Enum.TextXAlignment.Left, "Không có"

local infoHpBg = Instance.new("Frame", InfoPanel)
infoHpBg.Size, infoHpBg.Position = UDim2.new(1,-16,0,8), UDim2.new(0,8,0,54)
infoHpBg.BackgroundColor3, infoHpBg.BorderSizePixel = Color3.fromRGB(35,35,42), 0
corner(infoHpBg, 4)
local infoHpFill = Instance.new("Frame", infoHpBg)
infoHpFill.Size, infoHpFill.BackgroundColor3 = UDim2.new(1,0,1,0), CLR.green
infoHpFill.BorderSizePixel = 0
corner(infoHpFill, 4)

local infoHp = Instance.new("TextLabel", InfoPanel)
infoHp.Size, infoHp.Position = UDim2.new(1,-16,0,16), UDim2.new(0,8,0,66)
infoHp.BackgroundTransparency = 1
infoHp.TextColor3, infoHp.Font, infoHp.TextSize = CLR.textDim, FONT, 10
infoHp.TextXAlignment, infoHp.Text = Enum.TextXAlignment.Left, "HP: -- / --"

local infoDist = Instance.new("TextLabel", InfoPanel)
infoDist.Size, infoDist.Position = UDim2.new(1,-16,0,16), UDim2.new(0,8,0,86)
infoDist.BackgroundTransparency = 1
infoDist.TextColor3, infoDist.Font, infoDist.TextSize = CLR.yellow, FONT, 10
infoDist.TextXAlignment, infoDist.Text = Enum.TextXAlignment.Left, "Khoảng cách: --"

-- Bullet tracer
local bulletTracer = Instance.new("Frame", BulletGui)
bulletTracer.BackgroundColor3, bulletTracer.BorderSizePixel = CLR.yellow, 0
bulletTracer.AnchorPoint, bulletTracer.Visible, bulletTracer.ZIndex = Vector2.new(0,0.5), false, 3

-- ═══════════════ §14  UI LAYOUT ═══════════════
addSection("Aimbot Camera")
addToggle("Aimbot Lock", function(v)
    S.aimbot = v
    if v then S.legit = false end
    if not v then lockedTarget = nil end
end)
addToggle("Vòng Aim FOV", function(v) S.showFOV = v end)
addToggle("Wall Check", function(v) S.wallCheck = v end)
addToggle("Team Check", function(v) S.teamCheck = v end)
addCycler("Aim Part", {"Head", "HumanoidRootPart"}, function(o)
    S.targetPart = o
end)
addSlider("Size FOV", 150, 30, 600, function(v) S.fovRadius = v end)
addSlider("Độ dày FOV", 2, 1, 10, function(v) S.fovThickness = v end)
addSlider("Độ Mượt Aim", 10, 1, 10, function(v) S.smooth = v end)

addSection("Legit Silent")
addToggle("Legit Silent Aim", function(v)
    S.legit = v
    if v then S.aimbot = false end
    legitCache = nil
end)
addToggle("Chỉ khi bắn (LMB)", function(v) S.legitOnlyFiring = v end)
addToggle("Wall Check", function(v) S.legitWall = v end)
addToggle("Team Check", function(v) S.legitTeam = v end)
addToggle("Hiện dấu +", function(v) S.legitIndicator = v end)
addToggle("Dùng Prediction", function(v) S.legitPrediction = v end)
addCycler("Hitbox", {"Head","HumanoidRootPart","UpperTorso","Torso"}, function(o) S.legitPart = o end)
addSlider("Vùng Pixel", 45, 10, 200, function(v) S.legitRadius = v end)
addSlider("Hit Chance (%)", 100, 0, 100, function(v) S.legitHitChance = v end)
addSlider("Pred Mult (x10)", 10, 1, 30, function(v) S.legitMult = v / 10 end)

addSection("Silent Aim (Large)")
addToggle("Silent Aim", function(v) S.silent = v end)
addToggle("Chỉ khi bắn", function(v) S.silentOnlyFiring = v end)
addToggle("Wall Check", function(v) S.silentWall = v end)
addToggle("Team Check", function(v) S.silentTeam = v end)
addToggle("Hiện Silent FOV", function(v) S.silentShowFOV = v end)
addCycler("Hitbox", {"Head","HumanoidRootPart","UpperTorso","Torso","LowerTorso"}, function(o) S.silentPart = o end)
addSlider("Silent FOV", 200, 30, 800, function(v) S.silentFOV = v end)
addSlider("Hit Chance (%)", 100, 0, 100, function(v) S.silentHitChance = v end)

addSection("No Recoil / Spread")
addToggle("No Recoil", function(v)
    S.noRecoil = v
    if v then Camera.CameraOffset = Vector3.zero end
end)
addToggle("No Camera Shake", function(v)
    S.noShake = v
    if v then baseFOV = Camera.FieldOfView end
end)
addToggle("No Spread", function(v) S.noSpread = v end)

addSection("Rapid Fire")
addToggle("Rapid Fire", function(v)
    S.rapid = v
    if not v then restoreRapid() end
end)
addCycler("Mode", {"Enabled-Spam", "Cooldown-Zero", "FireRemote-Spam"}, function(o)
    S.rapidMode = o
    if o ~= "Cooldown-Zero" then restoreRapid() end
end)
addSlider("Multiplier", 1, 1, 5, function(v) S.rapidMult = v end)

addSection("Prediction")
addToggle("Aim Prediction", function(v)
    S.prediction = v
    if v then scanWeapon() end
end)
addToggle("Vẽ đường đạn", function(v) S.showBulletTracer = v end)
addSlider("Tốc độ đạn", 1000, 100, 5000, function(v) S.projSpeed = v end)
addSlider("Hệ số (x10)", 10, 1, 30, function(v) S.predMult = v / 10 end)
addSlider("Trọng lực", 0, 0, 200, function(v) S.projGravity = v end)

addSection("Info Panel")
addToggle("Hiện Target Info", function(v) S.showInfo = v end)

addSection("ESP")
addToggle("Full ESP", function(v) S.esp = v; refreshESP() end)
addToggle("Box + Health", function(v)
    S.espBox = v
    for _, d in pairs(espData) do
        if d.box then d.box.Visible = v end
    end
end)
addToggle("Skeleton", function(v)
    S.espSkeleton = v
    if not v then
        for _, d in pairs(espData) do
            for _, b in ipairs(d.bones) do b.line.Visible = false end
        end
    end
end)
addToggle("Tracer", function(v)
    S.espTracer = v
    if not v then
        for _, d in pairs(espData) do
            if d.tracer then d.tracer.Visible = false end
        end
    end
end)
addToggle("Chams", function(v)
    S.espChams = v
    for plr, d in pairs(espData) do
        local c = plr.Character
        if c then
            if d.chams then d.chams:Destroy(); d.chams = nil end
            if v then d.chams = applyChams(c) end
        end
    end
end)

local ESP_COLORS = {
    {name="Đỏ",        color=Color3.fromRGB(255,50,50)},
    {name="Xanh Lá",   color=Color3.fromRGB(0,255,120)},
    {name="Xanh Dương",color=Color3.fromRGB(50,150,255)},
    {name="Vàng",      color=Color3.fromRGB(255,220,0)},
    {name="Cyan",      color=Color3.fromRGB(0,255,255)},
    {name="Tím",       color=Color3.fromRGB(200,50,255)},
    {name="Trắng",     color=Color3.fromRGB(255,255,255)},
}
local colorNames = {}
for _, c in ipairs(ESP_COLORS) do table.insert(colorNames, c.name) end
addCycler("Màu ESP", colorNames, function(name)
    for _, c in ipairs(ESP_COLORS) do
        if c.name == name then S.espColor = c.color; break end
    end
    refreshESPColor()
    infoStroke.Color = S.espColor
    bulletTracer.BackgroundColor3 = S.espColor
end)
