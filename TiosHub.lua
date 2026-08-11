-- TIOS HUB ULTIMATE - FULL PACK (AIMBOT, RAGEBOT, LINES, SKELETON, LAG FIX, ANTI BAN, HIDE NAME)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")

if not LocalPlayer then return end

-- Tự động tìm CoreGui hoặc gethui
local targetParent
pcall(function() targetParent = gethui() end)
if not targetParent then pcall(function() targetParent = game:GetService("CoreGui") end) end
if not targetParent then targetParent = LocalPlayer:WaitForChild("PlayerGui", 3) end
if not targetParent then return end

-- Dọn dẹp UI cũ
if targetParent:FindFirstChild("TiosHubUltimate") then
    targetParent.TiosHubUltimate:Destroy()
end
if targetParent:FindFirstChild("TiosFOVUltimate") then
    targetParent.TiosFOVUltimate:Destroy()
end

-- Tạo GUI chính
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TiosHubUltimate"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = targetParent

-- FOV GUI
local FOVGui = Instance.new("ScreenGui")
FOVGui.Name = "TiosFOVUltimate"
FOVGui.ResetOnSpawn = false
FOVGui.Parent = targetParent

local FOVFrame = Instance.new("Frame", FOVGui)
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVFrame.BackgroundTransparency = 1
FOVFrame.Visible = false

local FOVStroke = Instance.new("UIStroke", FOVFrame)
FOVStroke.Transparency = 0.2
FOVStroke.Color = Color3.fromRGB(0, 230, 255)
FOVStroke.Thickness = 2

local FOVCorner = Instance.new("UICorner", FOVFrame)
FOVCorner.CornerRadius = UDim.new(1, 0)

-- ==================== NÚT LOGO ====================
local ToggleIcon = Instance.new("ImageButton", ScreenGui)
ToggleIcon.Size = UDim2.new(0, 50, 0, 50)
ToggleIcon.Position = UDim2.new(0.02, 0, 0.2, 0)
ToggleIcon.BackgroundColor3 = Color3.fromRGB(15, 20, 28)
ToggleIcon.BackgroundTransparency = 0.2
ToggleIcon.Active = true
ToggleIcon.Draggable = true
ToggleIcon.Image = "rbxassetid://1000014258" -- THAY ID ẢNH CỦA BẠN
Instance.new("UICorner", ToggleIcon).CornerRadius = UDim.new(0, 10)
local IconStroke = Instance.new("UIStroke", ToggleIcon)
IconStroke.Color = Color3.fromRGB(0, 230, 255)
IconStroke.Thickness = 1.5

-- Menu chính
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 230, 0, 350)
MainFrame.Position = UDim2.new(0.12, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 16, 22)
MainFrame.BackgroundTransparency = 0.1
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(0, 230, 255)
MainStroke.Thickness = 1

ToggleIcon.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Header
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundColor3 = Color3.fromRGB(20, 26, 36)
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)
local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.Position = UDim2.new(0.05, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "TIOS HUB"
Title.TextColor3 = Color3.fromRGB(110, 255, 50)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(0.85, 0, 0.15, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 50)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 11
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 5)
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- Danh sách cuộn
local Scroll = Instance.new("ScrollingFrame", MainFrame)
Scroll.Size = UDim2.new(1, 0, 1, -40)
Scroll.Position = UDim2.new(0, 0, 0, 40)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 0, 850) -- Tăng cho nút Hide Name
Scroll.ScrollBarThickness = 4

local layout = Instance.new("UIListLayout", Scroll)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 6)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- ==================== HÀM TẠO THANH ĐIỀU CHỈNH ====================
local function addAdjuster(text, min, max, default, step, callback)
    local frame = Instance.new("Frame", Scroll)
    frame.Size = UDim2.new(0.9, 0, 0, 32)
    frame.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = text
    
    local minusBtn = Instance.new("TextButton", frame)
    minusBtn.Size = UDim2.new(0, 20, 0, 20)
    minusBtn.Position = UDim2.new(0.42, 0, 0.15, 0)
    minusBtn.BackgroundColor3 = Color3.fromRGB(30, 38, 50)
    minusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minusBtn.Text = "-"
    minusBtn.Font = Enum.Font.SourceSansBold
    minusBtn.TextSize = 14
    Instance.new("UICorner", minusBtn).CornerRadius = UDim.new(0, 4)
    
    local valBox = Instance.new("TextBox", frame)
    valBox.Size = UDim2.new(0, 30, 0, 20)
    valBox.Position = UDim2.new(0.55, 0, 0.15, 0)
    valBox.BackgroundColor3 = Color3.fromRGB(25, 32, 44)
    valBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    valBox.Font = Enum.Font.SourceSans
    valBox.TextSize = 11
    valBox.Text = tostring(default)
    valBox.PlaceholderText = tostring(default)
    
    local plusBtn = Instance.new("TextButton", frame)
    plusBtn.Size = UDim2.new(0, 20, 0, 20)
    plusBtn.Position = UDim2.new(0.72, 0, 0.15, 0)
    plusBtn.BackgroundColor3 = Color3.fromRGB(30, 38, 50)
    plusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    plusBtn.Text = "+"
    plusBtn.Font = Enum.Font.SourceSansBold
    plusBtn.TextSize = 14
    Instance.new("UICorner", plusBtn).CornerRadius = UDim.new(0, 4)
    
    local currentValue = default
    
    local function updateValue(newVal)
        newVal = math.clamp(newVal, min, max)
        currentValue = newVal
        valBox.Text = tostring(newVal)
        callback(newVal)
    end
    
    minusBtn.MouseButton1Click:Connect(function()
        updateValue(currentValue - step)
    end)
    plusBtn.MouseButton1Click:Connect(function()
        updateValue(currentValue + step)
    end)
    valBox.FocusLost:Connect(function(enterPressed)
        local num = tonumber(valBox.Text)
        if num then
            updateValue(num)
        else
            valBox.Text = tostring(currentValue)
        end
    end)
end

-- ==================== LOGIC CHÍNH ====================
local aimbotEnabled = false
local showFOV = false
local wallCheck = false
local teamCheck = false
local fovRadius = 150
local targetPart = "Head"
local espActive = false
local rageBotEnabled = false
local fireDelay = 0.1
local lastFireTime = 0
local aimbotLineEnabled = false
local espLineEnabled = false
local skeletonEnabled = false
local lagFixEnabled = false
local antibanEnabled = false
local hideNameEnabled = false

-- Drawing objects
local aimbotLine = nil
local espLines = {}
local skeletonLines = {}

local bonePairs = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"},
}

local function findPart(char, partName)
    local part = char:FindFirstChild(partName)
    if part then return part end
    local r6Map = {
        UpperTorso = "Torso", LowerTorso = "Torso",
        LeftUpperArm = "Left Arm", LeftLowerArm = "Left Arm", LeftHand = "Left Arm",
        RightUpperArm = "Right Arm", RightLowerArm = "Right Arm", RightHand = "Right Arm",
        LeftUpperLeg = "Left Leg", LeftLowerLeg = "Left Leg", LeftFoot = "Left Leg",
        RightUpperLeg = "Right Leg", RightLowerLeg = "Right Leg", RightFoot = "Right Leg",
    }
    return char:FindFirstChild(r6Map[partName])
end

local function clearSkeleton(plr)
    if skeletonLines[plr] then
        for _, line in ipairs(skeletonLines[plr]) do
            pcall(function() line:Remove() end)
        end
        skeletonLines[plr] = nil
    end
end

-- ==================== FIX LAG ====================
local defaultGraphicSettings = {}
local function applyLagFix(state)
    if state then
        pcall(function()
            defaultGraphicSettings.GlobalShadows = Lighting.GlobalShadows
            Lighting.GlobalShadows = false
        end)
        pcall(function()
            if Lighting:FindFirstChild("Bloom") then
                defaultGraphicSettings.BloomEnabled = Lighting.Bloom.Enabled
                Lighting.Bloom.Enabled = false
            end
            if Lighting:FindFirstChild("DepthOfField") then
                defaultGraphicSettings.DOFEnabled = Lighting.DepthOfField.Enabled
                Lighting.DepthOfField.Enabled = false
            end
            if Lighting:FindFirstChild("SunRays") then
                defaultGraphicSettings.SunRaysEnabled = Lighting.SunRays.Enabled
                Lighting.SunRays.Enabled = false
            end
        end)
        pcall(function()
            defaultGraphicSettings.MaterialQuality = workspace.MaterialQuality
            workspace.MaterialQuality = Enum.MaterialQuality.QualityLevel01
        end)
        pcall(function()
            local terrain = workspace:FindFirstChild("Terrain")
            if terrain then
                defaultGraphicSettings.WaterWaveSize = terrain.WaterWaveSize
                defaultGraphicSettings.WaterTransparency = terrain.WaterTransparency
                terrain.WaterWaveSize = 0
                terrain.WaterTransparency = 1
            end
        end)
        pcall(function()
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("Beam") or obj:IsA("Trail") then
                    if not defaultGraphicSettings.FXDisabled then
                        defaultGraphicSettings.FXDisabled = {}
                    end
                    table.insert(defaultGraphicSettings.FXDisabled, {obj, obj.Enabled})
                    obj.Enabled = false
                end
            end
        end)
    else
        pcall(function() Lighting.GlobalShadows = defaultGraphicSettings.GlobalShadows end)
        pcall(function()
            if Lighting:FindFirstChild("Bloom") then Lighting.Bloom.Enabled = defaultGraphicSettings.BloomEnabled end
            if Lighting:FindFirstChild("DepthOfField") then Lighting.DepthOfField.Enabled = defaultGraphicSettings.DOFEnabled end
            if Lighting:FindFirstChild("SunRays") then Lighting.SunRays.Enabled = defaultGraphicSettings.SunRaysEnabled end
        end)
        pcall(function() workspace.MaterialQuality = defaultGraphicSettings.MaterialQuality end)
        pcall(function()
            local terrain = workspace:FindFirstChild("Terrain")
            if terrain then
                terrain.WaterWaveSize = defaultGraphicSettings.WaterWaveSize
                terrain.WaterTransparency = defaultGraphicSettings.WaterTransparency
            end
        end)
        if defaultGraphicSettings.FXDisabled then
            for _, entry in ipairs(defaultGraphicSettings.FXDisabled) do
                pcall(function() entry[1].Enabled = entry[2] end)
            end
        end
        defaultGraphicSettings = {}
    end
end

-- ==================== ANTI BAN ====================
local oldKick, oldNamecall
local function setupAntiBan(state)
    if state then
        pcall(function()
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
        end)
        oldKick = hookfunction(LocalPlayer.Kick, function(...) return nil end)
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if method == "FireServer" and tostring(self) == "Kick" then
                return nil
            end
            return oldNamecall(self, ...)
        end)
    else
        pcall(function()
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
        end)
        if oldKick then
            hookfunction(LocalPlayer.Kick, oldKick)
            oldKick = nil
        end
        if oldNamecall then
            pcall(function() hookmetamethod(game, "__namecall", oldNamecall) end)
            oldNamecall = nil
        end
    end
end

-- ==================== HIDE NAME ====================
local function applyHideName(plr, state)
    local char = plr.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.NameDisplayDistance = state and 0 or 100
    end
    local head = char:FindFirstChild("Head")
    if head then
        for _, child in ipairs(head:GetChildren()) do
            if child:IsA("BillboardGui") and (child.Name == "NameTag" or child.Name == "Nametag" or child.Name:lower():find("name")) then
                child.Enabled = not state
            end
        end
    end
end

-- Kết nối sự kiện respawn để áp dụng lại
LocalPlayer.CharacterAdded:Connect(function(char)
    if hideNameEnabled then
        applyHideName(LocalPlayer, true)
    end
end)

-- ==================== AIMBOT & VISUALS ====================
local function getClosestPlayer()
    local closest = nil
    local shortestDist = fovRadius
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char = plr.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                local part = char:FindFirstChild(targetPart) or char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
                
                if hum and hum.Health > 0 and part then
                    if teamCheck and plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then
                        continue
                    end

                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        if dist < shortestDist then
                            local canSee = true
                            if wallCheck then
                                local rayParams = RaycastParams.new()
                                rayParams.FilterType = Enum.RaycastFilterType.Exclude
                                local filterList = {}
                                if LocalPlayer.Character then
                                    table.insert(filterList, LocalPlayer.Character)
                                end
                                rayParams.FilterDescendantsInstances = filterList

                                local direction = part.Position - Camera.CFrame.Position
                                local success, rayResult = pcall(workspace.Raycast, workspace, Camera.CFrame.Position, direction, rayParams)
                                if success and rayResult then
                                    if not rayResult.Instance:IsDescendantOf(char) and rayResult.Instance.CanCollide then
                                        canSee = false
                                    end
                                end
                            end
                            if canSee then
                                shortestDist = dist
                                closest = part
                            end
                        end
                    end
                end
            end
        end
    end
    return closest
end

local function attemptFire()
    local char = LocalPlayer.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end
    pcall(function() tool:Activate() end)
end

local function updateAimbotLine(targetScreenPos)
    if not aimbotLine then
        pcall(function()
            aimbotLine = Drawing.new("Line")
            aimbotLine.Color = Color3.fromRGB(255, 50, 50)
            aimbotLine.Thickness = 1.5
            aimbotLine.Transparency = 1
        end)
    end
    if aimbotLine and aimbotLineEnabled and aimbotEnabled and targetScreenPos then
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        aimbotLine.From = center
        aimbotLine.To = targetScreenPos
        aimbotLine.Visible = true
    elseif aimbotLine then
        aimbotLine.Visible = false
    end
end

local function updateESPLines()
    for plr, line in pairs(espLines) do
        if not plr.Parent then
            line:Remove()
            espLines[plr] = nil
        end
    end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char = plr.Character
            local line = espLines[plr]
            if not line then
                pcall(function()
                    line = Drawing.new("Line")
                    line.Color = Color3.fromRGB(0, 230, 255)
                    line.Thickness = 1
                    line.Transparency = 1
                    espLines[plr] = line
                end)
            end
            if line then
                if espLineEnabled and char then
                    local hrp = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hrp and hum and hum.Health > 0 then
                        if teamCheck and plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then
                            line.Visible = false
                            continue
                        end
                        local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                        if onScreen then
                            local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                            line.From = center
                            line.To = Vector2.new(screenPos.X, screenPos.Y)
                            if wallCheck then
                                local rayParams = RaycastParams.new()
                                rayParams.FilterType = Enum.RaycastFilterType.Exclude
                                local filterList = {}
                                if LocalPlayer.Character then
                                    table.insert(filterList, LocalPlayer.Character)
                                end
                                rayParams.FilterDescendantsInstances = filterList
                                local direction = hrp.Position - Camera.CFrame.Position
                                local success, rayResult = pcall(workspace.Raycast, workspace, Camera.CFrame.Position, direction, rayParams)
                                if success and rayResult and not rayResult.Instance:IsDescendantOf(char) and rayResult.Instance.CanCollide then
                                    line.Visible = false
                                else
                                    line.Visible = true
                                end
                            else
                                line.Visible = true
                            end
                        else
                            line.Visible = false
                        end
                    else
                        line.Visible = false
                    end
                else
                    line.Visible = false
                end
            end
        end
    end
end

local function updateSkeletons()
    for plr, _ in pairs(skeletonLines) do
        if not plr.Parent then clearSkeleton(plr) end
    end
    if not skeletonEnabled then
        for plr, lines in pairs(skeletonLines) do
            for _, line in ipairs(lines) do line.Visible = false end
        end
        return
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        if not char then clearSkeleton(plr) continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then clearSkeleton(plr) continue end
        if teamCheck and plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then
            clearSkeleton(plr) continue
        end
        if not skeletonLines[plr] then
            skeletonLines[plr] = {}
            for _ = 1, #bonePairs do
                local line = Drawing.new("Line")
                line.Color = Color3.fromRGB(255, 255, 0)
                line.Thickness = 1
                line.Transparency = 1
                table.insert(skeletonLines[plr], line)
            end
        end
        local lines = skeletonLines[plr]
        for i, pair in ipairs(bonePairs) do
            local partA = findPart(char, pair[1])
            local partB = findPart(char, pair[2])
            local line = lines[i]
            if partA and partB then
                local posA, onScreenA = Camera:WorldToViewportPoint(partA.Position)
                local posB, onScreenB = Camera:WorldToViewportPoint(partB.Position)
                if onScreenA and onScreenB then
                    if wallCheck then
                        local midPoint = (partA.Position + partB.Position) / 2
                        local rayParams = RaycastParams.new()
                        rayParams.FilterType = Enum.RaycastFilterType.Exclude
                        local filterList = {}
                        if LocalPlayer.Character then table.insert(filterList, LocalPlayer.Character) end
                        rayParams.FilterDescendantsInstances = filterList
                        local direction = midPoint - Camera.CFrame.Position
                        local success, rayResult = pcall(workspace.Raycast, workspace, Camera.CFrame.Position, direction, rayParams)
                        if success and rayResult and not rayResult.Instance:IsDescendantOf(char) and rayResult.Instance.CanCollide then
                            line.Visible = false
                            continue
                        end
                    end
                    line.From = Vector2.new(posA.X, posA.Y)
                    line.To = Vector2.new(posB.X, posB.Y)
                    line.Visible = true
                else
                    line.Visible = false
                end
            else
                line.Visible = false
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    FOVFrame.Size = UDim2.new(0, fovRadius * 2, 0, fovRadius * 2)
    FOVFrame.Visible = showFOV

    local targetPartObj = nil
    local targetScreenPos = nil
    if aimbotEnabled then
        targetPartObj = getClosestPlayer()
        if targetPartObj then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPartObj.Position)
            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPartObj.Position)
            if onScreen then
                targetScreenPos = Vector2.new(screenPos.X, screenPos.Y)
            end
        end
    end

    if rageBotEnabled and aimbotEnabled and targetPartObj then
        local now = tick()
        if now - lastFireTime >= fireDelay then
            attemptFire()
            lastFireTime = now
        end
    end

    updateAimbotLine(targetScreenPos)
    updateESPLines()
    updateSkeletons()
end)

-- ==================== HÀM TẠO TOGGLE ====================
local function addToggle(text, defaultState, callback)
    local btn = Instance.new("TextButton", Scroll)
    btn.Size = UDim2.new(0.9, 0, 0, 32)
    btn.BackgroundColor3 = defaultState and Color3.fromRGB(0, 180, 220) or Color3.fromRGB(25, 32, 44)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text .. (defaultState and ": ON" or ": OFF")
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local state = defaultState
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. (state and ": ON" or ": OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 180, 220) or Color3.fromRGB(25, 32, 44)
        task.spawn(function() callback(state) end)
    end)
    return btn
end

-- ==================== TẤT CẢ CÁC NÚT ====================
addToggle("Aimbot Lock", false, function(s) aimbotEnabled = s end)
addToggle("Vòng Aim FOV", false, function(s) showFOV = s end)
addToggle("Wall Check", false, function(s) wallCheck = s end)
addToggle("Team Check", false, function(s) teamCheck = s end)
addToggle("Aim Body (Off: Head)", false, function(s) targetPart = s and "HumanoidRootPart" or "Head" end)
addToggle("RageBot (Auto Fire)", false, function(s) rageBotEnabled = s end)
addToggle("Aimbot Line", false, function(s) aimbotLineEnabled = s end)
addToggle("ESP Line", false, function(s) espLineEnabled = s end)
addToggle("Skeleton ESP", false, function(s)
    skeletonEnabled = s
    if not s then for plr, _ in pairs(skeletonLines) do clearSkeleton(plr) end end
end)
addToggle("Fix Lag (FPS Boost)", false, function(s)
    lagFixEnabled = s
    applyLagFix(s)
end)
addToggle("Anti Ban", false, function(s)
    antibanEnabled = s
    setupAntiBan(s)
end)

-- NÚT HIDE NAME
addToggle("Hide Name", false, function(s)
    hideNameEnabled = s
    if LocalPlayer.Character then
        applyHideName(LocalPlayer, s)
    end
end)

-- Thanh điều chỉnh
addAdjuster("FOV Radius", 50, 500, fovRadius, 10, function(val) fovRadius = val end)
addAdjuster("RageBot Fire Delay", 0.05, 1.0, fireDelay, 0.05, function(val) fireDelay = val end)

-- ==================== BOX ESP SYSTEM ====================
local function applyESP(plr)
    if plr == LocalPlayer then return end
    local function setup(char)
        if not char then return end
        pcall(function()
            local hrp = char:WaitForChild("HumanoidRootPart", 5) or char.PrimaryPart
            local hum = char:WaitForChild("Humanoid", 5) or char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum then return end
            if hrp:FindFirstChild("TiosESP") then hrp.TiosESP:Destroy() end
            local bb = Instance.new("BillboardGui")
            bb.Name = "TiosESP"
            bb.AlwaysOnTop = true
            bb.Size = UDim2.new(4, 0, 5.5, 0)
            bb.Adornee = hrp
            bb.Parent = hrp
            local box = Instance.new("Frame", bb)
            box.Size = UDim2.new(1, 0, 1, 0)
            box.BackgroundTransparency = 1
            local stroke = Instance.new("UIStroke", box)
            stroke.Color = Color3.fromRGB(0, 230, 255)
            stroke.Thickness = 1.5
            local name = Instance.new("TextLabel", bb)
            name.Size = UDim2.new(1, 40, 0, 15)
            name.Position = UDim2.new(-0.2, 0, -0.15, 0)
            name.BackgroundTransparency = 1
            name.TextColor3 = Color3.fromRGB(110, 255, 50)
            name.Font = Enum.Font.SourceSansBold
            name.TextSize = 10
            local function update()
                if not hum or not hum.Parent then return end
                name.Text = string.format("%s [%d]", plr.DisplayName, math.floor(hum.Health))
            end
            update()
            hum.HealthChanged:Connect(update)
        end)
    end
    if plr.Character then setup(plr.Character) end
    plr.CharacterAdded:Connect(setup)
end

addToggle("Full ESP", false, function(state)
    espActive = state
    for _, plr in pairs(Players:GetPlayers()) do
        if state then applyESP(plr) else
            pcall(function()
                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character.HumanoidRootPart:FindFirstChild("TiosESP") then
                    plr.Character.HumanoidRootPart.TiosESP:Destroy()
                end
            end)
        end
    end
end)

Players.PlayerAdded:Connect(function(plr)
    if espActive then applyESP(plr) end
end)

-- Dọn dẹp khi thoát
game:GetService("RunService").Heartbeat:Connect(function()
    if not ScreenGui or not ScreenGui.Parent then
        pcall(function()
            if aimbotLine then aimbotLine:Remove() end
            for _, line in pairs(espLines) do line:Remove() end
            for _, lines in pairs(skeletonLines) do
                for _, line in ipairs(lines) do line:Remove() end
            end
            if lagFixEnabled then applyLagFix(false) end
            if antibanEnabled then setupAntiBan(false) end
            if hideNameEnabled then applyHideName(LocalPlayer, false) end
        end)
    end
end)