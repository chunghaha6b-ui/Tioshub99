-- ═══════════════════════════════════════════════════════════════════════════
--   TIOSHUB v6.0  |  FINAL CLEAN BUILD  |  RIVALS EDITION
--   Silent • Aimbot • LegitCam • Anti-Katana • Skin • Wrap • ESP • Cursor
-- ═══════════════════════════════════════════════════════════════════════════
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService      = game:GetService("HttpService")
local TweenService     = game:GetService("TweenService")
local Lighting         = game:GetService("Lighting")
local MaterialService  = game:GetService("MaterialService")
local ReplicatedStorage= game:GetService("ReplicatedStorage")

local LP     = Players.LocalPlayer
local PGui   = LP:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

-- ═══════════════════════════════════════════════════════════════════════════
--  §1  CLEANUP + GUI
-- ═══════════════════════════════════════════════════════════════════════════
for _, n in ipairs({"TiosBg","TiosHub","TiosFOV","TiosInfo","TiosBullet","TiosSilentFOV","TiosCursor"}) do
    local o = PGui:FindFirstChild(n)
    if o then o:Destroy() end
end
pcall(function()
    RunService:UnbindFromRenderStep("TiosHub_Main")
    RunService:UnbindFromRenderStep("TiosHub_CamFix")
end)

local function newGui(name, order)
    local g = Instance.new("ScreenGui")
    g.Name, g.ResetOnSpawn, g.IgnoreGuiInset = name, false, true
    g.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    g.DisplayOrder = order or 0
    g.Parent = PGui
    return g
end

local BgGui        = newGui("TiosBg", 0)
local ScreenGui    = newGui("TiosHub", 1)
local InfoGui      = newGui("TiosInfo", 2)
local FOVGui       = newGui("TiosFOV", 3)
local BulletGui    = newGui("TiosBullet", 4)
local SilentFOVGui = newGui("TiosSilentFOV", 5)
local CursorGui    = newGui("TiosCursor", 9999)
BgGui.Enabled = false

-- ═══════════════════════════════════════════════════════════════════════════
--  §2  CONSTANTS
-- ═══════════════════════════════════════════════════════════════════════════
local CFG = {
    LOST_TOLERANCE = 0.35, WEAPON_SCAN = 0.15, CACHE_AIM = 0.02,
    CACHE_FILTER = 0.25, CACHE_RAYCAST = 0.03, INFO_UPDATE = 0.05,
    AUTOSAVE_DELAY = 1.5, RENDER_PRIO = Enum.RenderPriority.Last.Value,
    CAM_PRIO = Enum.RenderPriority.Last.Value - 1,
    FOLDER = "TiosHub_Configs", EXT = ".json",
}

local PROJECTILES = {
    scepter={speed=100,gravity=0}, bow={speed=250,gravity=100},
    crossbow={speed=400,gravity=50}, rpg={speed=150,gravity=50},
    grenade={speed=80,gravity=196}, paintball={speed=120,gravity=80},
    ["paintball gun"]={speed=120,gravity=80}, snowball={speed=100,gravity=150},
    ["water balloon"]={speed=90,gravity=150}, flamethrower={speed=60,gravity=0},
}

local R15_BONES = {
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
}
local R6_BONES = {
    {"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},
    {"Torso","Left Leg"},{"Torso","Right Leg"},
}

local WEAPON_WRAPS = {"Default","Gold","Diamond","Ruby","Emerald","Sapphire","Galaxy","Neon","Crimson","Frost","Toxic","Void"}
local SKIN_PRESETS = {
    Shadow=Color3.fromRGB(20,20,25), Ghost=Color3.fromRGB(255,255,255),
    Crimson=Color3.fromRGB(180,20,20), Toxic=Color3.fromRGB(50,200,80),
    Frost=Color3.fromRGB(80,150,240), Void=Color3.fromRGB(140,60,220),
    Gold=Color3.fromRGB(255,200,50), Blood=Color3.fromRGB(120,0,0),
    Neon=Color3.fromRGB(0,255,200), Sunset=Color3.fromRGB(255,100,50),
}
local ESP_COLORS = {
    {name="Blue",   color=Color3.fromRGB(100,180,255)},
    {name="Red",    color=Color3.fromRGB(235,65,85)},
    {name="Green",  color=Color3.fromRGB(80,220,150)},
    {name="Yellow", color=Color3.fromRGB(255,205,110)},
    {name="Cyan",   color=Color3.fromRGB(100,210,240)},
    {name="Purple", color=Color3.fromRGB(200,90,240)},
    {name="White",  color=Color3.fromRGB(255,255,255)},
}

-- ═══════════════════════════════════════════════════════════════════════════
--  §3  STATE
-- ═══════════════════════════════════════════════════════════════════════════
local S = {
    autoSave=true, configName="tioshub_v6",
    -- Aimbot
    aimbot=false, fovRadius=150, fovThickness=2, smooth=10,
    wallCheck=true, teamCheck=true, targetPart="Head", showFOV=false,
    -- Legit Cam
    legitCam=false, legitCamFOV=60, legitCamReaction=120, legitCamReactionMax=250,
    legitCamSpeedMin=3.5, legitCamSpeedMax=7.0, legitCamJitter=0.4,
    legitCamOvershoot=true, legitCamBreak=true, legitCamRequireADS=false,
    legitCamOnlyVisible=true, legitCamMaxSpeed=500, legitCamHitbox="Head",
    legitCamSmoothUneven=true, legitCamAimMethod="Curve", legitCamCurveStrength=65,
    legitCamStickyAim=true, legitCamStickyTime=0.5, legitCamTriggerAssist=false,
    legitCamAimSmoothing="Dynamic", legitCamMouseLockX=50, legitCamMouseLockY=50,
    legitCamAntiFlash=true, legitCamIgnoreJump=true, legitCamAimKeybind="None",
    legitCamKeybindMode="Hold",
    -- Legit Silent
    legit=false, legitRadius=45, legitOnlyFiring=true, legitWall=true,
    legitTeam=true, legitHitChance=100, legitIndicator=true, legitPart="Head",
    -- Silent Aim (direction-based)
    silent=false, silentAngle=90, silentPart="Head", silentHitChance=100,
    silentWall=false, silentTeam=true, silentOnlyFiring=true,
    -- Anti Katana
    antiKatana=false, antiKatanaWindow=0.8, antiKatanaNotify=false,
    -- Effects
    noRecoil=false, noShake=false, noSpread=false,
    rapid=false, rapidMode="Enabled-Spam", rapidMult=1,
    autoReload=false, autoReloadMode="Smart", autoReloadThreshold=1,
    autoReloadKeybind="R", autoReloadDelay=0.1,
    noTaskSchedule=false, noTaskMaxWait=10, noTaskBoostPriority=true,
    -- Mod Skin
    skinWeaponEnabled=false, skinWeaponWrap="Default",
    skinBodyColorEnabled=false, skinBodyColor=Color3.fromRGB(20,20,25),
    skinAutoApply=true, skinShowNotify=true,
    -- Skin Changer (ViewModels Model Swap)
    skinModelEnabled=false, skinWeaponModelName="Sniper", skinTargetSkinName="Default",
    -- Texture
    texEnabled=false, texPreset="None", texCustomId="",
    texTransparency=0, texReflectance=0,
    texApplyToWeapon=true, texApplyToChar=false,
    -- Prediction
    prediction=false, projSpeed=1000, predMult=1.0, projGravity=0, showBulletTracer=false,
    showInfo=true,
    -- ESP
    esp=false, espBox=true, espBoxThickness=1.5,
    espName=true, espDistance=true, espHealth=true,
    espSkeleton=false, espSkeletonThickness=1.5,
    espTracer=false, espTracerOrigin="Bottom", espTracerThickness=1.5,
    espChams=false, espChamsFillColor=Color3.fromRGB(100,180,255),
    espChamsOutlineColor=Color3.fromRGB(255,255,255),
    espChamsFillTransparency=0.55, espChamsDepthMode="AlwaysOnTop",
    espTeamCheck=true, espColor=Color3.fromRGB(100,180,255),
    espTeamColor=Color3.fromRGB(80,220,150),
    espRainbow=false, espRainbowSpeed=1,
    espDistanceFade=true, espFadeNear=50, espFadeFar=500,
    espMaxDistance=1000,
    -- Cursor
    cursorEnabled=false, cursorStyle="Crosshair", cursorSize=24,
    cursorThickness=2, cursorGap=4,
    cursorColor=Color3.fromRGB(255,60,60), cursorOutlineColor=Color3.fromRGB(0,0,0),
    cursorOutlineThickness=1, cursorSpinSpeed=0,
    cursorPulse=false, cursorPulseSpeed=1.2, cursorPulseAmount=0.15,
    cursorRainbow=false, cursorRainbowSpeed=1.5, cursorCenterDot=true,
    cursorHideInGame=true,
}

local RT = {
    lockedTarget=nil, lastSeen=0,
    legitCache=nil, legitPos=nil, legitTime=0,
    silentTargetCache=nil,
    currentTarget=nil,
    mouseDown=false, adsDown=false, baseFOV=Camera.FieldOfView,
    skipHook=false, projConfig=nil,
    lcTarget=nil, lcPart=nil, lcStartTime=0, lcLastSeen=0, lcBreakUntil=0,
    lcOvershootDone=false, lcJitter=Vector2.new(0,0), lcStickyUntil=0,
    lcAimKeyHeld=false, lcFlashUntil=0, lcLastCFrame=nil,
    katanaCache={},
    rapidBackup={}, lastReloadTime=0, taskSchedulerInstalled=false,
    originalWraps={}, skinBackup={}, lastTool=nil,
    espData={}, espSkipToggle=false, espRainbowHue=0,
    cursorParts={}, cursorHue=0, cursorPulseTime=0, cursorSpinAngle=0,
    filterCache=nil, filterTime=0, rayCache={},
    main=nil,
}

-- ═══════════════════════════════════════════════════════════════════════════
--  §4  UTILS
-- ═══════════════════════════════════════════════════════════════════════════
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude or Enum.RaycastFilterType.Blacklist
rayParams.IgnoreWater, rayParams.RespectCanCollide = true, false

local function getFilter()
    local now = tick()
    if RT.filterCache and now - RT.filterTime < CFG.CACHE_FILTER then return RT.filterCache end
    RT.filterTime = now
    RT.filterCache = LP.Character and {Camera, LP.Character} or {Camera}
    return RT.filterCache
end

local function rawRay(origin, dir)
    RT.skipHook = true
    local r = workspace:Raycast(origin, dir, rayParams)
    RT.skipHook = false
    return r
end

local function isAlive(c)
    if not c or not c.Parent then return false end
    local h = c:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

local function getPart(char, name)
    return char:FindFirstChild(name) or char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
end

local function screenDist(sp, cx, cy)
    local dx, dy = sp.X - cx, sp.Y - cy
    return math.sqrt(dx*dx + dy*dy)
end

local function getLocalTool()
    local char = LP.Character
    return char and char:FindFirstChildOfClass("Tool")
end

local function getLocalRoot()
    local char = LP.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function corner(o, r)
    local c = Instance.new("UICorner", o)
    c.CornerRadius = UDim.new(0, r or 4)
    return c
end

local function outline(o, col, th, tr)
    local s = Instance.new("UIStroke", o)
    s.Color, s.Thickness, s.Transparency = col or Color3.fromRGB(35,35,35), th or 1, tr or 0.4
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end

-- ═══════════════════════════════════════════════════════════════════════════
--  §5  CONFIG SYSTEM (pre-load, UI bind, apply runtime)
-- ═══════════════════════════════════════════════════════════════════════════
pcall(function() if not isfolder(CFG.FOLDER) then makefolder(CFG.FOLDER) end end)

local HAS_FILE_IO = (type(writefile) == "function" and type(readfile) == "function"
    and type(isfile) == "function" and type(listfiles) == "function")

local function serialize(v)
    if typeof(v) == "Color3" then return {__t="C3", r=v.R, g=v.G, b=v.B}
    elseif type(v) == "table" then
        local o = {}; for k, val in pairs(v) do o[k] = serialize(val) end; return o
    end
    return v
end

local function deserialize(v)
    if type(v) == "table" then
        if v.__t == "C3" then return Color3.new(v.r, v.g, v.b) end
        local o = {}; for k, val in pairs(v) do o[k] = deserialize(val) end; return o
    end
    return v
end

local function cfgPath(n) return CFG.FOLDER .. "/" .. (n or S.configName) .. CFG.EXT end

local UI_BIND = {}
local function bindState(key, setter)
    if not key then return end
    UI_BIND[key] = UI_BIND[key] or {}
    table.insert(UI_BIND[key], setter)
end

local function normalize(s)
    return string.lower(s):gsub("[%s%-_%(%)%[%]:%.,!?]", "")
end

local function guessKey(text, valueType)
    local clean = normalize(text)
    for k, v in pairs(S) do
        if type(v) == valueType and normalize(k) == clean then return k end
    end
    local bestKey, bestLen = nil, 0
    for k, v in pairs(S) do
        if type(v) == valueType then
            local nk = normalize(k)
            if #nk >= 4 and string.find(clean, nk, 1, true) and #nk > bestLen then
                bestKey, bestLen = k, #nk
            end
        end
    end
    return bestKey
end

local function saveConfig(silent)
    if not HAS_FILE_IO then return false end
    local ok = pcall(function()
        writefile(cfgPath(), HttpService:JSONEncode(serialize(S)))
    end)
    if not silent and ok then print("[TiosHub] 💾 Saved") end
    return ok
end

local function loadConfig(silent)
    if not HAS_FILE_IO then return false end
    local path = cfgPath()
    if not isfile(path) then return false end
    local ok = pcall(function()
        local data = deserialize(HttpService:JSONDecode(readfile(path)))
        local count = 0
        for k, v in pairs(data) do
            if S[k] ~= nil then
                S[k] = v
                count = count + 1
                if UI_BIND[k] then
                    for _, setter in ipairs(UI_BIND[k]) do pcall(setter, v) end
                end
            end
        end
        if not silent then print(string.format("[TiosHub] ✅ Loaded %d settings", count)) end
    end)
    return ok
end

local function listConfigs()
    if not HAS_FILE_IO then return {} end
    local out = {}
    local files = listfiles(CFG.FOLDER); if not files then return out end
    for _, f in ipairs(files) do
        local n = string.match(f, "([^/\\]+)" .. CFG.EXT .. "$")
        if n then table.insert(out, n) end
    end
    return out
end

local saveQueued, saveTimer = false, 0
local function queueSave()
    if not S.autoSave then return end
    saveQueued, saveTimer = true, 0
end
local function processAutoSave(dt)
    if not saveQueued then return end
    saveTimer = saveTimer + dt
    if saveTimer >= CFG.AUTOSAVE_DELAY then
        saveQueued, saveTimer = false, 0
        saveConfig(true)
    end
end

-- Pre-load TRƯỚC khi build UI để widget đọc đúng state
if HAS_FILE_IO and isfile(cfgPath()) then
    pcall(function()
        local data = deserialize(HttpService:JSONDecode(readfile(cfgPath())))
        local count = 0
        for k, v in pairs(data) do
            if S[k] ~= nil then S[k] = v; count = count + 1 end
        end
        print(string.format("[TiosHub] ✅ Pre-loaded %d settings", count))
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════
--  §6  PROJECTILE + PREDICTION
-- ═══════════════════════════════════════════════════════════════════════════
local function scanWeapon()
    local tool = getLocalTool()
    RT.projConfig = tool and PROJECTILES[string.lower(tool.Name)] or nil
end

local function predict(char, part, usePred, cfg, mult)
    if not usePred then return part.Position end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return part.Position end
    local spd, grav = S.projSpeed, S.projGravity
    if cfg then spd, grav = cfg.speed, cfg.gravity end
    if not spd or spd <= 0 then return part.Position end
    local dist = (part.Position - Camera.CFrame.Position).Magnitude
    local t = (dist / spd) * (mult or S.predMult)
    local p = part.Position + root.AssemblyLinearVelocity * t
    if grav > 0 then p = p + Vector3.new(0, 0.5 * grav * t * t, 0) end
    return p
end

-- ═══════════════════════════════════════════════════════════════════════════
--  §7  INPUT
-- ═══════════════════════════════════════════════════════════════════════════
UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.UserInputType == Enum.UserInputType.MouseButton1 then RT.mouseDown = true
    elseif i.UserInputType == Enum.UserInputType.MouseButton2 then RT.adsDown = true end
    if i.KeyCode and i.KeyCode.Name == S.legitCamAimKeybind then
        if S.legitCamKeybindMode == "Toggle" then RT.lcAimKeyHeld = not RT.lcAimKeyHeld
        else RT.lcAimKeyHeld = true end
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then RT.mouseDown = false
    elseif i.UserInputType == Enum.UserInputType.MouseButton2 then RT.adsDown = false end
    if i.KeyCode and i.KeyCode.Name == S.legitCamAimKeybind and S.legitCamKeybindMode == "Hold" then
        RT.lcAimKeyHeld = false
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
--  §8  TARGET FINDER
-- ═══════════════════════════════════════════════════════════════════════════
local function checkWall(char, part, camPos)
    local now = tick()
    local c = RT.rayCache[char]
    if c and now - c.time < CFG.CACHE_RAYCAST then return c.blocked end
    rayParams.FilterDescendantsInstances = getFilter()
    local r = rawRay(camPos, part.Position - camPos)
    local blocked = (r and not r.Instance:IsDescendantOf(char)) or false
    RT.rayCache[char] = {time=now, blocked=blocked}
    return blocked
end

local function findBestTarget(fovPx, partName, doWall, doTeam, sticky)
    local vp = Camera.ViewportSize
    local cx, cy = vp.X/2, vp.Y/2
    local camPos = Camera.CFrame.Position

    if sticky and RT.lockedTarget and isAlive(RT.lockedTarget.Character) then
        local p = getPart(RT.lockedTarget.Character, partName)
        if p then
            local sp, on = Camera:WorldToViewportPoint(p.Position)
            if on and sp.Z > 0 then
                local d = screenDist(sp, cx, cy)
                if d <= fovPx then
                    local blocked = doWall and checkWall(RT.lockedTarget.Character, p, camPos)
                    if not blocked then RT.lastSeen = tick(); return RT.lockedTarget, p end
                end
            end
        end
        if tick() - RT.lastSeen > CFG.LOST_TOLERANCE then RT.lockedTarget = nil end
    end

    local list = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            -- Anti-Katana skip
            local kEntry = RT.katanaCache[plr]
            if S.antiKatana and kEntry and kEntry.holding and (tick() - kEntry.lastDeflect) < S.antiKatanaWindow then
                goto skipPlr
            end
            local skipTeam = doTeam and plr.Team and LP.Team and plr.Team == LP.Team
            if not skipTeam then
                local char = plr.Character
                if isAlive(char) then
                    local p = getPart(char, partName)
                    if p then
                        local sp, on = Camera:WorldToViewportPoint(p.Position)
                        if on and sp.Z > 0 then
                            local d = screenDist(sp, cx, cy)
                            if d <= fovPx then list[#list+1] = {plr=plr, part=p, dist=d, char=char} end
                        end
                    end
                end
            end
            ::skipPlr::
        end
    end
    table.sort(list, function(a,b) return a.dist < b.dist end)

    for i = 1, math.min(#list, 3) do
        local c = list[i]
        local blocked = doWall and checkWall(c.char, c.part, camPos)
        if not blocked then
            RT.lockedTarget = c.plr; RT.lastSeen = tick()
            return c.plr, c.part
        end
    end
    return nil, nil
end

-- ═══════════════════════════════════════════════════════════════════════════
--  §9  SILENT AIM (Direction-based · bắn đâu cũng vào đầu)
-- ═══════════════════════════════════════════════════════════════════════════
local silentCacheTime = 0
local SILENT_CACHE = 0.01

local function findSilentTarget(origin, dirUnit, maxAngle, partName, doWall, doTeam)
    local best, bestAngle, bestPart = nil, maxAngle, nil
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local kEntry = RT.katanaCache[plr]
            if S.antiKatana and kEntry and kEntry.holding and (tick() - kEntry.lastDeflect) < S.antiKatanaWindow then
                goto skipS
            end
            local skipTeam = doTeam and plr.Team and LP.Team and plr.Team == LP.Team
            if not skipTeam then
                local char = plr.Character
                if isAlive(char) then
                    local p = getPart(char, partName)
                    if p then
                        local toT = p.Position - origin
                        local dist = toT.Magnitude
                        if dist > 0.5 then
                            local dot = dirUnit:Dot(toT / dist)
                            if dot > 0.001 then
                                local angle = math.deg(math.acos(math.clamp(dot, -1, 1)))
                                if angle < bestAngle then
                                    local blocked = false
                                    if doWall then
                                        rayParams.FilterDescendantsInstances = getFilter()
                                        local r = rawRay(origin, toT)
                                        if r and not r.Instance:IsDescendantOf(char) then blocked = true end
                                    end
                                    if not blocked then
                                        bestAngle, best, bestPart = angle, plr, p
                                    end
                                end
                            end
                        end
                    end
                end
            end
            ::skipS::
        end
    end
    return best, bestPart
end

local function getSilentTargetFor(origin, dir)
    if not S.silent then return nil end
    if S.silentOnlyFiring and not RT.mouseDown then return nil end
    if S.silentHitChance < 100 and math.random(1,100) > S.silentHitChance then return nil end

    local now = tick()
    if now - silentCacheTime < SILENT_CACHE then return RT.silentTargetCache end
    silentCacheTime = now

    local _, part = findSilentTarget(origin, dir.Unit, S.silentAngle, S.silentPart, S.silentWall, S.silentTeam)
    RT.silentTargetCache = part
    return part
end

-- Legit Silent (center-screen based)
local function getLegitTarget()
    if not S.legit then return nil, nil end
    if S.legitOnlyFiring and not RT.mouseDown then return nil, nil end
    if S.legitHitChance < 100 and math.random(1,100) > S.legitHitChance then return nil, nil end
    if tick() - RT.legitTime < CFG.CACHE_AIM then
        return RT.legitCache, RT.legitPos
    end

    local vp = Camera.ViewportSize
    local cx, cy = vp.X/2, vp.Y/2
    local best, bestDist, bestPart = nil, S.legitRadius, nil

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local skipTeam = S.legitTeam and plr.Team and LP.Team and plr.Team == LP.Team
            if not skipTeam then
                local char = plr.Character
                if isAlive(char) then
                    local p = getPart(char, S.legitPart)
                    if p then
                        local sp, on = Camera:WorldToViewportPoint(p.Position)
                        if on and sp.Z > 0 then
                            local d = screenDist(sp, cx, cy)
                            if d < bestDist then
                                local blocked = false
                                if S.legitWall then
                                    rayParams.FilterDescendantsInstances = getFilter()
                                    local r = rawRay(Camera.CFrame.Position, p.Position - Camera.CFrame.Position)
                                    if r and not r.Instance:IsDescendantOf(char) then blocked = true end
                                end
                                if not blocked then bestDist, best, bestPart = d, plr, p end
                            end
                        end
                    end
                end
            end
        end
    end

    RT.legitCache, RT.legitPos, RT.legitTime = best, bestPart and bestPart.Position or nil, tick()
    return RT.legitCache, RT.legitPos
end

-- ═══════════════════════════════════════════════════════════════════════════
--  §10  LEGIT CAMERA (không Scriptable · giữ movement)
-- ═══════════════════════════════════════════════════════════════════════════
local function lcCanSee(char, part)
    if not S.legitCamOnlyVisible then return true end
    rayParams.FilterDescendantsInstances = getFilter()
    local r = rawRay(Camera.CFrame.Position, part.Position - Camera.CFrame.Position)
    if not r then return true end
    if r.Instance:IsDescendantOf(char) then return true end
    if r.Instance:IsA("Accessory") or r.Instance:IsA("Hat") then return true end
    return false
end

local function lcIsJumping(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.FloorMaterial == Enum.Material.Air or false
end

local function lcFind()
    local vp = Camera.ViewportSize
    local cx, cy = vp.X/2, vp.Y/2
    local best, bestD, bestP = nil, S.legitCamFOV, nil
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and not (S.teamCheck and plr.Team == LP.Team and LP.Team) then
            local char = plr.Character
            if isAlive(char) then
                if S.legitCamIgnoreJump and lcIsJumping(char) then continue end
                local p = getPart(char, S.legitCamHitbox)
                if p then
                    local sp, on = Camera:WorldToViewportPoint(p.Position)
                    if on and sp.Z > 0 then
                        local d = screenDist(sp, cx, cy)
                        if d < bestD and lcCanSee(char, p) then bestD, best, bestP = d, plr, p end
                    end
                end
            end
        end
    end
    return best, bestP
end

local function lcGenJitter()
    local a = math.random() * math.pi * 2
    local m = math.random() * S.legitCamJitter
    return Vector2.new(math.cos(a)*m, math.sin(a)*m)
end

local function lcCurveAim(targetScreen, currentScreen, strength)
    local dx = targetScreen.X - currentScreen.X
    local dy = targetScreen.Y - currentScreen.Y
    local len = math.sqrt(dx*dx + dy*dy)
    if len < 0.1 then return targetScreen end
    local cf = strength / 100
    local offX = -dy / len * cf * 20
    local offY = dx / len * cf * 20
    local midX = (currentScreen.X + targetScreen.X) / 2 + offX
    local midY = (currentScreen.Y + targetScreen.Y) / 2 + offY
    return Vector2.new(
        0.81*currentScreen.X + 0.18*midX + 0.01*targetScreen.X,
        0.81*currentScreen.Y + 0.18*midY + 0.01*targetScreen.Y
    )
end

local function processLegitCam(dt)
    if not S.legitCam then RT.lcTarget = nil; RT.lcLastCFrame = nil; return nil end
    if S.legitCamAimKeybind ~= "None" and not RT.lcAimKeyHeld then RT.lcTarget = nil; return nil end
    if S.legitCamRequireADS and not RT.adsDown then RT.lcTarget = nil; return nil end
    if S.legitCamAntiFlash and RT.lcFlashUntil > tick() then return nil end

    local now = tick()
    if now < RT.lcBreakUntil then return RT.lcTarget, RT.lcPart end

    local target, part = lcFind()
    if not target or not part then
        if S.legitCamStickyAim and RT.lcTarget and now < RT.lcStickyUntil then
            local char = RT.lcTarget.Character
            if char and isAlive(char) then
                part = char:FindFirstChild(S.legitCamHitbox)
                if part and lcCanSee(char, part) then target = RT.lcTarget end
            end
        end
        if not target then
            if RT.lcTarget and now - RT.lcLastSeen > 0.3 then
                RT.lcTarget, RT.lcPart, RT.lcOvershootDone = nil, nil, false
            end
            return nil
        end
    end

    if target ~= RT.lcTarget then
        RT.lcTarget, RT.lcPart = target, part
        local reaction = S.legitCamReaction + math.random() * (S.legitCamReactionMax - S.legitCamReaction)
        RT.lcStartTime = now + reaction / 1000
        RT.lcOvershootDone = false
        RT.lcJitter = lcGenJitter()
        RT.lcStickyUntil = now + S.legitCamStickyTime
    end
    RT.lcLastSeen = now
    if now < RT.lcStartTime then return nil end

    if S.legitCamBreak and math.random() < 0.04 then
        RT.lcBreakUntil = now + 0.05 + math.random() * 0.15
        return nil
    end
    if math.random() < 0.15 then RT.lcJitter = lcGenJitter() end

    local sp, on = Camera:WorldToViewportPoint(part.Position)
    if not on or sp.Z <= 0 then return nil end
    local ts = Vector2.new(sp.X + RT.lcJitter.X, sp.Y + RT.lcJitter.Y)

    if S.legitCamOvershoot and not RT.lcOvershootDone and math.random() < 0.35 then
        ts = ts + Vector2.new((math.random()-0.5)*25, (math.random()-0.5)*25)
        RT.lcOvershootDone = true
    end

    local vp = Camera.ViewportSize
    local curScreen = Vector2.new(vp.X/2, vp.Y/2)
    local aimScreen
    if S.legitCamAimMethod == "Curve" then
        aimScreen = lcCurveAim(ts, curScreen, S.legitCamCurveStrength)
    else
        aimScreen = curScreen:Lerp(ts, math.clamp(S.legitCamSpeedMin * dt, 0.01, 0.35))
    end

    local ray = Camera:ViewportPointToRay(aimScreen.X, aimScreen.Y)
    local aimPos = ray.Origin + ray.Direction * 1000

    local baseSpeed = (S.legitCamSpeedMin + S.legitCamSpeedMax) / 2
    if S.legitCamSmoothUneven then
        baseSpeed = S.legitCamSpeedMin + math.random() * (S.legitCamSpeedMax - S.legitCamSpeedMin)
    end
    if S.legitCamAimSmoothing == "Dynamic" then
        local dist = (Camera.CFrame.Position - aimPos).Magnitude
        baseSpeed = baseSpeed * (1 + (100 - math.min(dist, 100)) / 100)
    end

    local dist = (Camera.CFrame.Position - aimPos).Magnitude
    local alpha = math.clamp(baseSpeed * dt, 0.01, 0.35)
    local maxA = math.clamp(S.legitCamMaxSpeed * dt / math.max(dist,1), 0.01, 0.6)
    alpha = math.min(alpha, maxA)

    local curCF = Camera.CFrame
    local newCF = curCF:Lerp(CFrame.new(curCF.Position, aimPos), alpha)

    if S.legitCamMouseLockX < 100 or S.legitCamMouseLockY < 100 then
        local deltaCF = curCF:ToObjectSpace(newCF)
        local x, y, z = deltaCF:ToEulerAnglesXYZ()
        x = x * (S.legitCamMouseLockX / 100)
        y = y * (S.legitCamMouseLockY / 100)
        newCF = curCF * CFrame.Angles(x, y, z)
    end
    Camera.CFrame = newCF
    RT.lcLastCFrame = newCF

    if S.legitCamTriggerAssist and (ts - curScreen).Magnitude < 15 then
        local tool = getLocalTool()
        if tool then pcall(function() tool:Activate() end) end
    end
    return target, part
end

-- Anti-flash detection
local lastBrightness = Lighting.Brightness
Lighting:GetPropertyChangedSignal("Brightness"):Connect(function()
    if math.abs(Lighting.Brightness - lastBrightness) > 2 then
        RT.lcFlashUntil = tick() + 1.5
    end
    lastBrightness = Lighting.Brightness
end)

-- ═══════════════════════════════════════════════════════════════════════════
--  §11  ANTI-KATANA (Animation Watcher)
-- ═══════════════════════════════════════════════════════════════════════════
local KATANA_KW = {"katana", "sword", "blade", "saber"}
local DEFLECT_KW = {"deflect", "parry", "block", "slash", "counter", "guard"}

local function isKatana(tool)
    if not tool then return false end
    local n = string.lower(tool.Name)
    for _, kw in ipairs(KATANA_KW) do if string.find(n, kw, 1, true) then return true end end
    return false
end

local function isDeflectAnim(track)
    if not track or not track.Animation then return false end
    local n = string.lower(track.Animation.Name)
    local id = string.lower(tostring(track.Animation.AnimationId))
    for _, kw in ipairs(DEFLECT_KW) do
        if string.find(n, kw, 1, true) or string.find(id, kw, 1, true) then return true end
    end
    return false
end

local function watchKatana(plr)
    if plr == LP or RT.katanaCache[plr] then return end
    local entry = {conns = {}, holding = false, lastDeflect = 0}
    RT.katanaCache[plr] = entry

    local function onChar(char)
        if not char then return end
        entry.holding = false
        entry.lastDeflect = 0

        local tool = char:FindFirstChildOfClass("Tool")
        entry.holding = isKatana(tool)

        table.insert(entry.conns, char.ChildAdded:Connect(function(c)
            if c:IsA("Tool") then entry.holding = isKatana(c) end
        end))
        table.insert(entry.conns, char.ChildRemoved:Connect(function(c)
            if c:IsA("Tool") then
                local t = char:FindFirstChildOfClass("Tool")
                entry.holding = isKatana(t)
            end
        end))

        local hum = char:WaitForChild("Humanoid", 5)
        if not hum then return end
        local animator = hum:FindFirstChildOfClass("Animator") or hum:WaitForChild("Animator", 5)
        if animator then
            table.insert(entry.conns, animator.AnimationPlayed:Connect(function(track)
                if entry.holding and isDeflectAnim(track) then
                    entry.lastDeflect = tick()
                    if S.antiKatanaNotify then
                        print(string.format("[Anti-Katana] %s deflect!", plr.Name))
                    end
                end
            end))
        end
    end

    if plr.Character then onChar(plr.Character) end
    table.insert(entry.conns, plr.CharacterAdded:Connect(onChar))
end

local function unwatchKatana(plr)
    local e = RT.katanaCache[plr]
    if not e then return end
    for _, c in ipairs(e.conns) do pcall(function() c:Disconnect() end) end
    RT.katanaCache[plr] = nil
end

for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= LP then watchKatana(plr) end
end
Players.PlayerAdded:Connect(watchKatana)
Players.PlayerRemoving:Connect(unwatchKatana)

-- ═══════════════════════════════════════════════════════════════════════════
--  §12  HOOK (Silent Aim + Legit Silent + Rapid Fire + No Spread)
-- ═══════════════════════════════════════════════════════════════════════════
local function installHook()
    local ok, err = pcall(function()
        local old
        old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local method = getnamecallmethod()

            if method == "FireServer" and S.rapid and S.rapidMode == "FireRemote-Spam"
                and not RT.skipHook and typeof(self) == "Instance"
                and self:IsA("RemoteEvent") and string.find(string.lower(self.Name), "fire") then
                local r = old(self, ...)
                for _ = 1, S.rapidMult do old(self, ...) end
                return r
            end

            if RT.skipHook then return old(self, ...) end

            local isRay = method == "Raycast" or method == "FindPartOnRay"
                or method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRayWithWhitelist"
            if not isRay then return old(self, ...) end

            local args = {...}

            -- Silent Aim (direction-based)
            if S.silent then
                local origin, dir
                if method == "Raycast" and typeof(args[1]) == "Vector3" and typeof(args[2]) == "Vector3" then
                    origin, dir = args[1], args[2]
                elseif typeof(args[1]) == "Ray" then
                    origin, dir = args[1].Origin, args[1].Direction
                end
                if origin and dir then
                    local part = getSilentTargetFor(origin, dir)
                    if part then
                        local newDir = part.Position - origin
                        if method == "Raycast" then args[2] = newDir
                        else args[1] = Ray.new(origin, newDir) end
                        return old(self, unpack(args))
                    end
                end
            end

            -- Legit Silent (center-screen)
            if S.legit then
                local _, p = getLegitTarget()
                if p then
                    if method == "Raycast" and typeof(args[1]) == "Vector3" then
                        args[2] = p - args[1]
                    elseif typeof(args[1]) == "Ray" then
                        args[1] = Ray.new(args[1].Origin, p - args[1].Origin)
                    end
                    return old(self, unpack(args))
                end
            end

            -- No Spread
            if S.noSpread and method == "Raycast"
                and typeof(args[1]) == "Vector3" and typeof(args[2]) == "Vector3" then
                args[2] = Camera.CFrame.LookVector * args[2].Magnitude
                return old(self, unpack(args))
            end
            return old(self, ...)
        end))
    end)
    if not ok then warn("[TiosHub] Hook failed: " .. tostring(err)) end
end
installHook()

-- ═══════════════════════════════════════════════════════════════════════════
--  §13  EFFECTS
-- ═══════════════════════════════════════════════════════════════════════════
local function processNoRecoil()
    if S.noRecoil and Camera.CameraOffset.Magnitude > 0.001 then Camera.CameraOffset = Vector3.zero end
    if S.noShake and math.abs(Camera.FieldOfView - RT.baseFOV) > 0.5 then Camera.FieldOfView = RT.baseFOV end
end

local function processRapidFire()
    if not S.rapid then return end
    local tool = getLocalTool()
    if not tool then return end
    if S.rapidMode == "Enabled-Spam" then
        if not tool.Enabled then pcall(function() tool.Enabled = true end) end
    elseif S.rapidMode == "Cooldown-Zero" then
        for _, obj in ipairs(tool:GetDescendants()) do
            if obj:IsA("NumberValue") then
                local n = string.lower(obj.Name)
                if string.find(n,"cooldown") or string.find(n,"firerate")
                    or string.find(n,"fire_rate") or string.find(n,"delay") then
                    if not RT.rapidBackup[obj] then RT.rapidBackup[obj] = obj.Value end
                    pcall(function() obj.Value = 0 end)
                end
            end
        end
    elseif S.rapidMode == "FireRemote-Spam" then
        if RT.mouseDown then pcall(function() tool:Activate() end) end
    end
end

local function restoreRapid()
    for obj, val in pairs(RT.rapidBackup) do
        pcall(function() if obj and obj.Parent then obj.Value = val end end)
    end
    RT.rapidBackup = {}
end

local function findAmmo(tool)
    if not tool then return nil end
    for _, v in ipairs(tool:GetDescendants()) do
        if v:IsA("IntValue") or v:IsA("NumberValue") then
            local n = string.lower(v.Name)
            if string.find(n,"ammo") or string.find(n,"clip")
                or string.find(n,"mag") or string.find(n,"bullet") then
                return v
            end
        end
    end
    return nil
end

local function doReload()
    local tool = getLocalTool()
    if not tool then return end
    pcall(function() tool:Activate() end)
    for _, r in ipairs(tool:GetDescendants()) do
        if r:IsA("RemoteEvent") then
            local n = string.lower(r.Name)
            if string.find(n,"reload") or string.find(n,"recharge") then
                pcall(function() r:FireServer() end)
            end
        end
    end
end

local function processAutoReload()
    if not S.autoReload then return end
    local tool = getLocalTool()
    if not tool then return end
    local ammo = findAmmo(tool)
    if not ammo then return end
    local should = false
    if S.autoReloadMode == "Smart" then should = ammo.Value <= S.autoReloadThreshold
    elseif S.autoReloadMode == "Always" then should = true
    elseif S.autoReloadMode == "Manual-Key" then
        should = UserInputService:IsKeyDown(Enum.KeyCode[S.autoReloadKeybind]) and ammo.Value < 999
    end
    if should then
        local now = tick()
        if now - RT.lastReloadTime >= S.autoReloadDelay then
            RT.lastReloadTime = now
            doReload()
        end
    end
end

local originalTaskWait, originalWait
local function installNTS()
    if RT.taskSchedulerInstalled then return end
    RT.taskSchedulerInstalled = true
    originalTaskWait, originalWait = task.wait, wait
    pcall(function()
        task.wait = newcclosure(function(t)
            if not S.noTaskSchedule then return originalTaskWait(t) end
            local m = S.noTaskMaxWait / 1000
            if t == nil or t > m then t = m end
            return originalTaskWait(t)
        end)
        wait = function(t)
            if not S.noTaskSchedule then return originalWait(t) end
            local m = S.noTaskMaxWait / 1000
            if t == nil or t > m then t = m end
            return originalWait(t)
        end
    end)
    if S.noTaskBoostPriority then
        pcall(function() if setthreadidentity then setthreadidentity(8) end end)
    end
end

local function uninstallNTS()
    if not RT.taskSchedulerInstalled then return end
    pcall(function()
        if originalTaskWait then task.wait = originalTaskWait end
        if originalWait then wait = originalWait end
    end)
    RT.taskSchedulerInstalled = false
end

-- ═══════════════════════════════════════════════════════════════════════════
--  §14  SKIN SYSTEMS (Wrap · Body Color · ViewModels Model Swap · Texture)
-- ═══════════════════════════════════════════════════════════════════════════

-- ── Wrap ──
local function findWrap(tool)
    if not tool then return nil end
    for _, n in ipairs({"Wrap","Skin","WeaponSkin","Camo","Cosmetic","SkinName"}) do
        local v = tool:FindFirstChild(n)
        if v and v:IsA("ValueBase") then return v end
    end
    for _, v in ipairs(tool:GetDescendants()) do
        if v:IsA("StringValue") then
            local n = string.lower(v.Name)
            if string.find(n,"wrap") or string.find(n,"skin") or string.find(n,"camo") then return v end
        end
    end
    return nil
end

local function applyWeaponWrap()
    if not S.skinWeaponEnabled then return end
    local tool = getLocalTool()
    if not tool then return end
    local wrap = findWrap(tool)
    if wrap then
        if not RT.originalWraps[tool] then RT.originalWraps[tool] = wrap.Value end
        pcall(function() wrap.Value = S.skinWeaponWrap end)
    end
end

local function applyBodyColor()
    if not S.skinBodyColorEnabled then return end
    local char = LP.Character
    if not char then return end
    local bc = char:FindFirstChild("Body Colors")
    if not bc then
        bc = Instance.new("BodyColors")
        bc.Name = "Body Colors"
        bc.Parent = char
    end
    pcall(function()
        local c = S.skinBodyColor
        bc.HeadColor3, bc.TorsoColor3 = c, c
        bc.LeftArmColor3, bc.RightArmColor3 = c, c
        bc.LeftLegColor3, bc.RightLegColor3 = c, c
    end)
end

local function restoreSkin()
    for tool, val in pairs(RT.originalWraps) do
        pcall(function()
            if typeof(tool) == "Instance" and tool.Parent then
                local wrap = findWrap(tool)
                if wrap then wrap.Value = val end
            end
        end)
    end
    RT.originalWraps = {}
    local char = LP.Character
    if char then
        local bc = char:FindFirstChild("Body Colors")
        if bc then
            pcall(function()
                bc.HeadColor3 = Color3.fromRGB(255,224,180)
                bc.TorsoColor3 = Color3.fromRGB(255,224,180)
                bc.LeftArmColor3 = Color3.fromRGB(255,224,180)
                bc.RightArmColor3 = Color3.fromRGB(255,224,180)
                bc.LeftLegColor3 = Color3.fromRGB(255,224,180)
                bc.RightLegColor3 = Color3.fromRGB(255,224,180)
            end)
        end
    end
end

-- ── ViewModels Model Swap (Skin Changer) ──
local VIEWMODELS = nil
local SKIN_BACKUPS = {}
local WEAPON_SKIN_DB = {
    ["Bow"]={"Compound Bow","Raven Bow"},
    ["Assault Rifle"]={"AK-47","AUG"},
    ["Chainsaw"]={"Blobsaw","Handsaws"},
    ["RPG"]={"Nuke Launcher","RPKEY","Spaceship Launcher"},
    ["Burst Rifle"]={"Aqua Burst","Electro Rifle"},
    ["Exogun"]={"Singularity","Wondergun"},
    ["Fists"]={"Boxing Gloves","Brass Knuckles"},
    ["Flamethrower"]={"Lamethrower","Pixel Flamethrower"},
    ["Flare Gun"]={"Dynamite Gun","Firework Gun"},
    ["Freeze Ray"]={"Bubble Ray","Temporal Ray"},
    ["Grenade"]={"Water Balloon","Whoopee Cushion"},
    ["Grenade Launcher"]={"Swashbuckler","Uranium Launcher"},
    ["Handgun"]={"Blaster"},
    ["Katana"]={"Lightning Bolt","Saber"},
    ["Minigun"]={"Lasergun 3000","Pixel Minigun"},
    ["Paintball Gun"]={"Boba Gun","Slime Gun"},
    ["Revolver"]={"Sheriff"},
    ["Slingshot"]={"Goalpost","Stick"},
    ["Subspace Tripmine"]={"Don't Press","Spring"},
    ["Uzi"]={"Electro Uzi","Water Uzi"},
    ["Sniper"]={"Pixel Sniper","Hyper Sniper"},
    ["Knife"]={"Karambit","Chancla"},
}
local WEAPON_NAMES = {}
for k in pairs(WEAPON_SKIN_DB) do table.insert(WEAPON_NAMES, k) end
table.sort(WEAPON_NAMES)

local function getViewModelsFolder()
    if VIEWMODELS and VIEWMODELS.Parent then return VIEWMODELS end
    local ps = LP:FindFirstChild("PlayerScripts"); if not ps then return nil end
    local assets = ps:FindFirstChild("Assets"); if not assets then return nil end
    local vm = assets:FindFirstChild("ViewModels")
    if vm then
        VIEWMODELS = vm
        local weapons = vm:FindFirstChild("Weapons")
        if weapons then VIEWMODELS = weapons end
        return VIEWMODELS
    end
    return nil
end

local function getSkinsForWeapon(weaponName)
    local out = {"Default"}
    local list = WEAPON_SKIN_DB[weaponName]
    if list then for _, s in ipairs(list) do table.insert(out, s) end end
    return out
end

local function swapWeaponSkin(weaponName, skinName, state)
    local vm = getViewModelsFolder()
    if not vm then
        if S.skinShowNotify then warn("[SkinChanger] Không tìm thấy ViewModels") end
        return false
    end
    local weapon = vm:FindFirstChild(weaponName)
    if not weapon then
        if S.skinShowNotify then warn("[SkinChanger] Không có weapon: " .. weaponName) end
        return false
    end
    if state and not SKIN_BACKUPS[weaponName] then
        SKIN_BACKUPS[weaponName] = weapon:Clone()
    end
    if not state or skinName == "Default" then
        local backup = SKIN_BACKUPS[weaponName]
        if backup then
            weapon:ClearAllChildren()
            for _, c in ipairs(backup:GetChildren()) do c:Clone().Parent = weapon end
        end
        return true
    end
    local skin = vm:FindFirstChild(skinName)
    if not skin then
        if S.skinShowNotify then warn("[SkinChanger] Không có skin: " .. skinName) end
        return false
    end
    weapon:ClearAllChildren()
    for _, c in ipairs(skin:GetChildren()) do c:Clone().Parent = weapon end
    if S.skinShowNotify then
        print(string.format("[SkinChanger] %s ← %s ✅", weaponName, skinName))
    end
    return true
end

local function restoreAllSkins()
    for name in pairs(SKIN_BACKUPS) do
        swapWeaponSkin(name, "Default", false)
    end
    if S.skinShowNotify then print("[SkinChanger] Restored all") end
end

-- ── Texture Changer ──
local TEX_PRESETS = { ["None"]=nil }
local texBackup = {}

local function backupTex(part)
    if texBackup[part] then return end
    local b = {textures={}, decals={}, surfaceApps={}}
    for _, c in ipairs(part:GetChildren()) do
        if c:IsA("Texture") then table.insert(b.textures, c:Clone())
        elseif c:IsA("Decal") then table.insert(b.decals, c:Clone())
        elseif c:IsA("SurfaceAppearance") then table.insert(b.surfaceApps, c:Clone()) end
    end
    texBackup[part] = b
end

local function clearTex(part)
    for _, c in ipairs(part:GetChildren()) do
        if c:IsA("Texture") or c:IsA("Decal") or c:IsA("SurfaceAppearance") then c:Destroy() end
    end
end

local function restoreTex(part)
    local b = texBackup[part]; if not b then return end
    clearTex(part)
    for _, t in ipairs(b.textures) do t:Clone().Parent = part end
    for _, d in ipairs(b.decals) do d:Clone().Parent = part end
    for _, s in ipairs(b.surfaceApps) do s:Clone().Parent = part end
    texBackup[part] = nil
end

local function applyTexToPart(part, texId)
    backupTex(part)
    clearTex(part)
    if texId then
        local d = Instance.new("Decal")
        d.Texture = texId
        d.Face = Enum.NormalId.Front
        d.Parent = part
    end
    if part:IsA("BasePart") then
        part.Transparency = S.texTransparency
        part.Reflectance = S.texReflectance
    end
end

local function applyTexNow()
    if not S.texEnabled then
        for p in pairs(texBackup) do restoreTex(p) end
        texBackup = {}
        return
    end
    local texId = TEX_PRESETS[S.texPreset]
    if S.texPreset == "Custom" and S.texCustomId ~= "" then texId = S.texCustomId end
    if S.texApplyToWeapon then
        local tool = getLocalTool()
        if tool then
            for _, d in ipairs(tool:GetDescendants()) do
                if d:IsA("BasePart") and d.Transparency < 1 then applyTexToPart(d, texId) end
            end
        end
    end
    if S.texApplyToChar and LP.Character then
        for _, d in ipairs(LP.Character:GetDescendants()) do
            if d:IsA("BasePart") and d.Transparency < 1 then applyTexToPart(d, texId) end
        end
    end
end

-- ── Process all ──
local function processSkin()
    local char = LP.Character
    if not char then return end
    if S.skinWeaponEnabled then
        local tool = getLocalTool()
        if tool ~= RT.lastTool then
            RT.lastTool = tool
            task.wait(0.1)
            applyWeaponWrap()
        end
    end
    if S.skinBodyColorEnabled then applyBodyColor() end
    if S.skinModelEnabled and S.skinWeaponModelName and S.skinTargetSkinName then
        local tool = getLocalTool()
        if tool and string.find(string.lower(tool.Name), string.lower(S.skinWeaponModelName)) then
            local vm = getViewModelsFolder()
            if vm and vm:FindFirstChild(S.skinWeaponModelName) then
                local key = S.skinWeaponModelName .. "_" .. S.skinTargetSkinName
                if not SKIN_BACKUPS[key] then
                    if swapWeaponSkin(S.skinWeaponModelName, S.skinTargetSkinName, true) then
                        SKIN_BACKUPS[key] = true
                    end
                end
            end
        end
    end
end

LP.CharacterAdded:Connect(function()
    task.wait(1)
    if S.skinWeaponEnabled then applyWeaponWrap() end
    if S.skinBodyColorEnabled then applyBodyColor() end
    texBackup = {}
    if S.texEnabled then task.wait(0.3); applyTexNow() end
end)

-- ═══════════════════════════════════════════════════════════════════════════
--  §15  ESP (Drawing API · UE-style)
-- ═══════════════════════════════════════════════════════════════════════════
local HAS_DRAWING = (typeof(Drawing) == "table" and Drawing.new ~= nil)

local function closestPointOnPart(part, target)
    local lt = part.CFrame:PointToObjectSpace(target)
    local hs = part.Size * 0.5
    return (part.CFrame * CFrame.new(
        math.clamp(lt.X, -hs.X, hs.X),
        math.clamp(lt.Y, -hs.Y, hs.Y),
        math.clamp(lt.Z, -hs.Z, hs.Z)
    )).Position
end

local function destroyESP(plr)
    local d = RT.espData[plr]; if not d then return end
    for _, c in ipairs(d.conns) do pcall(function() c:Disconnect() end) end
    for _, obj in pairs(d) do
        if typeof(obj) == "Instance" then pcall(function() obj:Destroy() end)
        elseif typeof(obj) == "userdata" then pcall(function() obj:Remove() end) end
    end
    if d.bones then
        for _, b in ipairs(d.bones) do
            if b.line then pcall(function() b.line:Remove() end) end
        end
    end
    RT.espData[plr] = nil
end

local function applyChams(char)
    local old = char:FindFirstChild("TiosChams"); if old then old:Destroy() end
    if not S.espChams then return nil end
    local hl = Instance.new("Highlight")
    hl.Name = "TiosChams"
    hl.FillColor = S.espChamsFillColor
    hl.OutlineColor = S.espChamsOutlineColor
    hl.FillTransparency = S.espChamsFillTransparency
    hl.OutlineTransparency = 0
    hl.DepthMode = S.espChamsDepthMode == "AlwaysOnTop"
        and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
    hl.Adornee = char
    hl.Parent = char
    return hl
end

local function refreshESPColor()
    for _, d in pairs(RT.espData) do
        if d.box then pcall(function() d.box.Color = S.espColor end) end
        if d.tracer then pcall(function() d.tracer.Color = S.espColor end) end
        if d.chams then pcall(function() d.chams.FillColor = S.espChamsFillColor end) end
    end
end

local function createESP(plr)
    if plr == LP or not HAS_DRAWING then return end
    destroyESP(plr)
    local d = {conns = {}, bones = {}}
    RT.espData[plr] = d

    d.box = Drawing.new("Square")
    d.box.Visible, d.box.Thickness, d.box.Filled = false, 1.5, false
    d.box.Color = S.espColor

    d.hpBg = Drawing.new("Square")
    d.hpBg.Visible, d.hpBg.Filled, d.hpBg.Color = false, true, Color3.fromRGB(15,15,15)

    d.hpFill = Drawing.new("Square")
    d.hpFill.Visible, d.hpFill.Filled, d.hpFill.Color = false, true, Color3.fromRGB(60,220,90)

    d.nameText = Drawing.new("Text")
    d.nameText.Visible, d.nameText.Size, d.nameText.Center = false, 14, true
    d.nameText.Outline = true
    d.nameText.Font = Drawing.Fonts.Plex
    d.nameText.Color = Color3.new(1,1,1)

    d.distText = Drawing.new("Text")
    d.distText.Visible, d.distText.Size, d.distText.Center = false, 12, true
    d.distText.Outline = true
    d.distText.Font = Drawing.Fonts.Plex
    d.distText.Color = Color3.fromRGB(220,220,220)

    d.tracer = Drawing.new("Line")
    d.tracer.Visible, d.tracer.Thickness = false, S.espTracerThickness
    d.tracer.Color = S.espColor

    local function setup(char)
        task.spawn(function()
            local hrp = char:WaitForChild("HumanoidRootPart", 5)
            local hum = char:WaitForChild("Humanoid", 5)
            if not hrp or not hum then return end

            local boneList = char:FindFirstChild("UpperTorso") and R15_BONES or R6_BONES
            for i, pair in ipairs(boneList) do
                d.bones[i] = {
                    line = Drawing.new("Line"),
                    partA = char:FindFirstChild(pair[1]),
                    partB = char:FindFirstChild(pair[2]),
                }
                if d.bones[i].line then
                    d.bones[i].line.Visible, d.bones[i].line.Thickness = false, S.espSkeletonThickness
                    d.bones[i].line.Color = Color3.new(1,1,1)
                end
            end

            d.chams = applyChams(char)

            local function updHp()
                if not hum.Parent then return end
                local r = math.clamp(hum.Health / math.max(hum.MaxHealth,1), 0, 1)
                d.hpRatio, d.hpValue = r, math.floor(hum.Health)
                if d.hpFill then
                    if r > 0.6 then d.hpFill.Color = Color3.fromRGB(60,220,90)
                    elseif r > 0.3 then d.hpFill.Color = Color3.fromRGB(255,210,60)
                    else d.hpFill.Color = Color3.fromRGB(240,60,60) end
                end
            end
            updHp()
            table.insert(d.conns, hum.HealthChanged:Connect(updHp))

            table.insert(d.conns, char.Destroying:Connect(function() destroyESP(plr) end))
            table.insert(d.conns, hum.Died:Connect(function() destroyESP(plr) end))
        end)
    end

    if plr.Character then setup(plr.Character) end
    table.insert(d.conns, plr.CharacterAdded:Connect(setup))
end

local function refreshESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            if S.esp then createESP(plr) else destroyESP(plr) end
        end
    end
end

Players.PlayerAdded:Connect(function(p) if S.esp then createESP(p) end end)
Players.PlayerRemoving:Connect(destroyESP)

local function hideESP(d)
    if d.box then d.box.Visible = false end
    if d.hpBg then d.hpBg.Visible = false end
    if d.hpFill then d.hpFill.Visible = false end
    if d.nameText then d.nameText.Visible = false end
    if d.distText then d.distText.Visible = false end
    if d.tracer then d.tracer.Visible = false end
    if d.bones then for _, b in ipairs(d.bones) do if b.line then b.line.Visible = false end end end
end

local function updateESPVisuals()
    if not HAS_DRAWING then return end
    local vp = Camera.ViewportSize
    local cx, cy = vp.X * 0.5, vp.Y * 0.5
    local camPos = Camera.CFrame.Position
    local lookVec = Camera.CFrame.LookVector
    local myRoot = getLocalRoot()

    if S.espRainbow then
        RT.espRainbowHue = (RT.espRainbowHue + 0.005 * S.espRainbowSpeed) % 1
        S.espColor = Color3.fromHSV(RT.espRainbowHue, 1, 1)
        refreshESPColor()
    end

    RT.espSkipToggle = not RT.espSkipToggle
    local idx = 0

    for plr, d in pairs(RT.espData) do
        idx = idx + 1
        if (idx % 2 == 0) == RT.espSkipToggle then
            local char = plr.Character
            if not isAlive(char) or not d.box then hideESP(d) continue end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local head = char:FindFirstChild("Head")
            if not hrp or not head then hideESP(d) continue end
            local dist = myRoot and (hrp.Position - myRoot.Position).Magnitude or 0
            if dist > S.espMaxDistance then hideESP(d) continue end

            local alpha = 1
            if S.espDistanceFade then
                alpha = 1 - math.clamp((dist - S.espFadeNear) / (S.espFadeFar - S.espFadeNear), 0, 1)
            end
            local ec = S.espColor
            if S.espTeamCheck and plr.Team and LP.Team and plr.Team == LP.Team then ec = S.espTeamColor end

            local headPos = head.Position + Vector3.new(0, 0.6, 0)
            local footPos = hrp.Position - Vector3.new(0, 3, 0)
            local topSP, topOn = Camera:WorldToViewportPoint(headPos)
            local botSP, botOn = Camera:WorldToViewportPoint(footPos)
            if not (topOn and botOn and topSP.Z > 0 and botSP.Z > 0) then hideESP(d) continue end

            local boxX = math.min(topSP.X, botSP.X)
            local boxY = math.min(topSP.Y, botSP.Y)
            local boxW = math.abs(botSP.X - topSP.X)
            local boxH = math.abs(botSP.Y - topSP.Y)

            -- Box
            if S.espBox then
                d.box.Visible = true
                d.box.Position = Vector2.new(boxX, boxY)
                d.box.Size = Vector2.new(boxW, boxH)
                d.box.Color = ec
                d.box.Thickness = S.espBoxThickness
                d.box.Transparency = alpha
            else d.box.Visible = false end

            -- Health bar
            if S.espHealth then
                local hpW = 2
                local hpX = boxX - 4 - hpW
                d.hpBg.Visible = true
                d.hpBg.Position = Vector2.new(hpX, boxY)
                d.hpBg.Size = Vector2.new(hpW, boxH)
                d.hpBg.Transparency = alpha * 0.85

                local ratio = d.hpRatio or 1
                local fillH = boxH * ratio
                d.hpFill.Visible = true
                d.hpFill.Position = Vector2.new(hpX, boxY + (boxH - fillH))
                d.hpFill.Size = Vector2.new(hpW, fillH)
                d.hpFill.Transparency = alpha * 0.15
            else
                d.hpBg.Visible = false
                d.hpFill.Visible = false
            end

            -- Name
            if S.espName then
                d.nameText.Visible = true
                d.nameText.Text = plr.DisplayName or plr.Name
                d.nameText.Position = Vector2.new(boxX + boxW * 0.5, boxY - 18)
                d.nameText.Transparency = alpha
            else d.nameText.Visible = false end

            -- Distance
            if S.espDistance then
                d.distText.Visible = true
                d.distText.Text = string.format("[%d]", math.floor(dist))
                d.distText.Position = Vector2.new(boxX + boxW * 0.5, boxY - 4)
                d.distText.Transparency = alpha
            else d.distText.Visible = false end

            -- Skeleton
            if S.espSkeleton then
                for _, b in ipairs(d.bones) do
                    local pA, pB = b.partA, b.partB
                    if b.line and pA and pB and pA.Parent and pB.Parent then
                        local wA = closestPointOnPart(pA, pB.Position)
                        local wB = closestPointOnPart(pB, pA.Position)
                        local sA, oA = Camera:WorldToViewportPoint(wA)
                        local sB, oB = Camera:WorldToViewportPoint(wB)
                        if oA and oB and sA.Z > 0 and sB.Z > 0 then
                            b.line.Visible = true
                            b.line.From = Vector2.new(sA.X, sA.Y)
                            b.line.To = Vector2.new(sB.X, sB.Y)
                            b.line.Transparency = alpha
                            b.line.Thickness = S.espSkeletonThickness
                        else b.line.Visible = false end
                    elseif b.line then b.line.Visible = false end
                end
            elseif d.bones then
                for _, b in ipairs(d.bones) do
                    if b.line then b.line.Visible = false end
                end
            end

            -- Tracer
            if S.espTracer then
                local toT = head.Position - camPos
                if lookVec:Dot(toT.Unit) > 0.05 then
                    local ox, oy
                    local o = S.espTracerOrigin
                    if o == "Top" then ox, oy = cx, 0
                    elseif o == "Bottom" then ox, oy = cx, vp.Y
                    elseif o == "Left" then ox, oy = 0, cy
                    elseif o == "Right" then ox, oy = vp.X, cy
                    elseif o == "Mouse" then
                        local m = UserInputService:GetMouseLocation()
                        ox, oy = m.X, m.Y
                    else ox, oy = cx, cy end
                    local tx, ty = boxX + boxW * 0.5, boxY + boxH * 0.5
                    d.tracer.Visible = true
                    d.tracer.From = Vector2.new(ox, oy)
                    d.tracer.To = Vector2.new(tx, ty)
                    d.tracer.Color = ec
                    d.tracer.Thickness = S.espTracerThickness
                    d.tracer.Transparency = alpha * 0.6
                else d.tracer.Visible = false end
            else d.tracer.Visible = false end
        end
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
--  §16  CUSTOM CURSOR
-- ═══════════════════════════════════════════════════════════════════════════
local cursorContainer = Instance.new("Frame", CursorGui)
cursorContainer.BackgroundTransparency = 1
cursorContainer.Size = UDim2.new(0, 200, 0, 200)
cursorContainer.AnchorPoint = Vector2.new(0.5, 0.5)
cursorContainer.ZIndex = 9999

local function clearCursorParts()
    for _, p in ipairs(RT.cursorParts) do pcall(function() p:Destroy() end) end
    RT.cursorParts = {}
end

local function newCursorPart(size, pos)
    local f = Instance.new("Frame", cursorContainer)
    f.Size = UDim2.new(0, size.X, 0, size.Y)
    f.Position = UDim2.new(0.5, pos.X, 0.5, pos.Y)
    f.AnchorPoint = Vector2.new(0.5, 0.5)
    f.BackgroundColor3, f.BorderSizePixel, f.ZIndex = S.cursorColor, 0, 10000
    corner(f, math.min(size.X, size.Y) / 2)
    local s = Instance.new("UIStroke", f)
    s.Color, s.Thickness = S.cursorOutlineColor, S.cursorOutlineThickness
    table.insert(RT.cursorParts, f)
    return f
end

local function buildCursor()
    clearCursorParts()
    local sz, th, gap = S.cursorSize, S.cursorThickness, S.cursorGap
    local len = sz/2 - gap
    if S.cursorStyle == "Crosshair" then
        newCursorPart(Vector2.new(th, len), Vector2.new(0, -(gap+len/2)))
        newCursorPart(Vector2.new(th, len), Vector2.new(0, gap+len/2))
        newCursorPart(Vector2.new(len, th), Vector2.new(-(gap+len/2), 0))
        newCursorPart(Vector2.new(len, th), Vector2.new(gap+len/2, 0))
    elseif S.cursorStyle == "Dot" then
        newCursorPart(Vector2.new(th*2, th*2), Vector2.new(0,0))
    elseif S.cursorStyle == "Circle" then
        local r = newCursorPart(Vector2.new(sz, sz), Vector2.new(0,0))
        r.BackgroundTransparency = 1
        r:FindFirstChildOfClass("UIStroke").Thickness = th
    elseif S.cursorStyle == "X" then
        local a = newCursorPart(Vector2.new(th, sz), Vector2.new(0,0)); a.Rotation = 45
        local b = newCursorPart(Vector2.new(th, sz), Vector2.new(0,0)); b.Rotation = -45
    end
    if S.cursorCenterDot then
        newCursorPart(Vector2.new(th*1.5, th*1.5), Vector2.new(0,0))
    end
end

local function processCursor(dt)
    if not S.cursorEnabled then return end
    local mouse = UserInputService:GetMouseLocation()
    cursorContainer.Position = UDim2.new(0, mouse.X, 0, mouse.Y)
    if S.cursorHideInGame and RT.main and RT.main.Visible ~= true then
        cursorContainer.Visible = false
        UserInputService.MouseIconEnabled = true
        return
    end
    cursorContainer.Visible = true
    UserInputService.MouseIconEnabled = false
    if S.cursorSpinSpeed > 0 then
        RT.cursorSpinAngle = (RT.cursorSpinAngle + S.cursorSpinSpeed * 30 * dt) % 360
        cursorContainer.Rotation = RT.cursorSpinAngle
    elseif cursorContainer.Rotation ~= 0 then
        cursorContainer.Rotation = 0
    end
    if S.cursorPulse then
        RT.cursorPulseTime = RT.cursorPulseTime + dt * S.cursorPulseSpeed
        local pulse = 1 + math.sin(RT.cursorPulseTime * math.pi) * S.cursorPulseAmount
        cursorContainer.Size = UDim2.new(0, 200*pulse, 0, 200*pulse)
    else
        cursorContainer.Size = UDim2.new(0, 200, 0, 200)
    end
    if S.cursorRainbow then
        RT.cursorHue = (RT.cursorHue + 0.005 * S.cursorRainbowSpeed) % 1
        for _, p in ipairs(RT.cursorParts) do
            p.BackgroundColor3 = Color3.fromHSV(RT.cursorHue, 0.85, 1)
        end
    end
end

local function applyCursor()
    if not S.cursorEnabled then
        clearCursorParts()
        UserInputService.MouseIconEnabled = true
        cursorContainer.Visible = false
        return
    end
    cursorContainer.Visible = true
    UserInputService.MouseIconEnabled = false
    buildCursor()
end

-- ═══════════════════════════════════════════════════════════════════════════
--  §17  UI SYSTEM (DARK MINIMAL)
-- ═══════════════════════════════════════════════════════════════════════════
local C = {
    bg=Color3.fromRGB(10,10,10), bg2=Color3.fromRGB(16,16,16), bg3=Color3.fromRGB(22,22,22),
    bgHover=Color3.fromRGB(30,30,30), border=Color3.fromRGB(35,35,35),
    accent=Color3.fromRGB(255,60,60), accentDim=Color3.fromRGB(140,30,30),
    text=Color3.fromRGB(240,240,240), textDim=Color3.fromRGB(150,150,150),
    textMuted=Color3.fromRGB(90,90,90),
    green=Color3.fromRGB(80,220,120), yellow=Color3.fromRGB(255,200,80),
    red=Color3.fromRGB(255,70,70), cyan=Color3.fromRGB(80,200,255),
}

local FONTFACE = {}
pcall(function()
    local F = "rbxasset://fonts/families/GothamSSm.json"
    FONTFACE = {
        medium = Font.new(F, Enum.FontWeight.Medium, Enum.FontStyle.Normal),
        bold   = Font.new(F, Enum.FontWeight.Bold,   Enum.FontStyle.Normal),
        black  = Font.new(F, Enum.FontWeight.Black,  Enum.FontStyle.Normal),
    }
end)

local function applyFont(lbl, w)
    if FONTFACE[w or "medium"] then
        pcall(function() lbl.FontFace = FONTFACE[w or "medium"] end)
    else lbl.Font = Enum.Font.Gotham end
end

local function hover(btn, normal, hoverCol)
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = hoverCol end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = normal end)
end

local function draggable(gui)
    local dragging, dragStart, startPos, dragInput
    gui.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
            dragging, dragStart, startPos = true, i.Position, gui.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    gui.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement
            or i.UserInputType == Enum.UserInputType.Touch then dragInput = i end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if i == dragInput and dragging then
            local d = i.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

-- Background
local bgFrame = Instance.new("Frame", BgGui)
bgFrame.Size = UDim2.new(1, 0, 1, 0)
bgFrame.BackgroundColor3, bgFrame.BackgroundTransparency = C.bg, 0.35
bgFrame.BorderSizePixel = 0

-- Icon
local Icon = Instance.new("TextButton", ScreenGui)
Icon.Size, Icon.Position = UDim2.new(0, 40, 0, 40), UDim2.new(0.02, 0, 0.3, 0)
Icon.BackgroundColor3 = C.bg2
Icon.TextColor3 = C.accent
Icon.Text, Icon.TextSize = "T", 20
Icon.AutoButtonColor = false
applyFont(Icon, "black")
corner(Icon, 6); outline(Icon, C.accent, 1, 0.3)
draggable(Icon)
hover(Icon, C.bg2, C.bg3)

-- Main window
local WIN_W, WIN_H = 440, 360
local Main = Instance.new("Frame", ScreenGui)
Main.Size, Main.Position = UDim2.new(0, WIN_W, 0, WIN_H), UDim2.new(0.2, 0, 0.2, 0)
Main.BackgroundColor3, Main.BackgroundTransparency = C.bg, 0
Main.BorderSizePixel, Main.Active, Main.Visible = 0, true, false
corner(Main, 6); outline(Main, C.border, 1, 0.3)
draggable(Main)

-- Header
local Header = Instance.new("Frame", Main)
Header.Size, Header.BackgroundColor3 = UDim2.new(1, 0, 0, 32), C.bg2
Header.BorderSizePixel = 0
corner(Header, 6)

local accentBar = Instance.new("Frame", Header)
accentBar.Size, accentBar.Position = UDim2.new(0, 3, 0, 32), UDim2.new(0, 0, 0, 0)
accentBar.BackgroundColor3, accentBar.BorderSizePixel = C.accent, 0
corner(accentBar, 6)

local Title = Instance.new("TextLabel", Header)
Title.Size, Title.Position = UDim2.new(0.5, 0, 1, 0), UDim2.new(0, 14, 0, 0)
Title.BackgroundTransparency, Title.Text = 1, "TIOSHUB"
Title.TextColor3, Title.TextSize = C.text, 13
Title.TextXAlignment = Enum.TextXAlignment.Left
applyFont(Title, "black")

local SubTitle = Instance.new("TextLabel", Header)
SubTitle.Size, SubTitle.Position = UDim2.new(0.15, 0, 1, 0), UDim2.new(0.5, 0, 0, 0)
SubTitle.BackgroundTransparency, SubTitle.Text = 1, "v6"
SubTitle.TextColor3, SubTitle.TextSize = C.textMuted, 9
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
applyFont(SubTitle, "bold")

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size, CloseBtn.Position = UDim2.new(0, 24, 0, 24), UDim2.new(1, -28, 0.5, -12)
CloseBtn.BackgroundColor3, CloseBtn.BackgroundTransparency = C.red, 0.85
CloseBtn.TextColor3, CloseBtn.Text, CloseBtn.TextSize = Color3.new(1,1,1), "×", 14
CloseBtn.AutoButtonColor = false
applyFont(CloseBtn, "bold")
corner(CloseBtn, 4)
CloseBtn.MouseEnter:Connect(function() CloseBtn.BackgroundTransparency = 0.5 end)
CloseBtn.MouseLeave:Connect(function() CloseBtn.BackgroundTransparency = 0.85 end)

local MinBtn = Instance.new("TextButton", Header)
MinBtn.Size, MinBtn.Position = UDim2.new(0, 24, 0, 24), UDim2.new(1, -56, 0.5, -12)
MinBtn.BackgroundColor3, MinBtn.BackgroundTransparency = C.bg3, 0.3
MinBtn.TextColor3, MinBtn.Text, MinBtn.TextSize = C.textDim, "—", 14
MinBtn.AutoButtonColor = false
applyFont(MinBtn, "bold")
corner(MinBtn, 4)
MinBtn.MouseEnter:Connect(function() MinBtn.BackgroundTransparency = 0.1 end)
MinBtn.MouseLeave:Connect(function() MinBtn.BackgroundTransparency = 0.3 end)

-- Sidebar
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size, Sidebar.Position = UDim2.new(0, 90, 1, -32), UDim2.new(0, 0, 0, 32)
Sidebar.BackgroundColor3, Sidebar.BackgroundTransparency = C.bg2, 0
Sidebar.BorderSizePixel = 0

local SideLayout = Instance.new("UIListLayout", Sidebar)
SideLayout.SortOrder, SideLayout.Padding = Enum.SortOrder.LayoutOrder, UDim.new(0, 1)
SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local SidePad = Instance.new("UIPadding", Sidebar)
SidePad.PaddingTop = UDim.new(0, 8)

-- Content
local ContentArea = Instance.new("Frame", Main)
ContentArea.Size, ContentArea.Position = UDim2.new(1, -90, 1, -32), UDim2.new(0, 90, 0, 32)
ContentArea.BackgroundTransparency = 1

-- Search
local SearchBox = Instance.new("Frame", ContentArea)
SearchBox.Size, SearchBox.Position = UDim2.new(1, -16, 0, 26), UDim2.new(0, 8, 0, 8)
SearchBox.BackgroundColor3, SearchBox.BackgroundTransparency = C.bg3, 0.3
SearchBox.BorderSizePixel = 0
corner(SearchBox, 4); outline(SearchBox, C.border, 1, 0.5)

local SearchInput = Instance.new("TextBox", SearchBox)
SearchInput.Size, SearchInput.Position = UDim2.new(1, -12, 1, 0), UDim2.new(0, 6, 0, 0)
SearchInput.BackgroundTransparency, SearchInput.Text = 1, ""
SearchInput.PlaceholderText, SearchInput.PlaceholderColor3 = "Search...", C.textMuted
SearchInput.TextColor3, SearchInput.TextSize = C.textDim, 10
SearchInput.TextXAlignment = Enum.TextXAlignment.Left
applyFont(SearchInput, "medium")

-- Tab system
local Tab = {buttons = {}, content = {}, active = nil, rows = {}}
local searchQuery = ""

local function applySearch()
    for row, data in pairs(Tab.rows) do
        if searchQuery == "" then row.Visible = true
        else row.Visible = string.find(data.text, searchQuery, 1, true) ~= nil end
    end
end

local function switchTab(id)
    if Tab.active == id then return end
    if Tab.active then
        Tab.buttons[Tab.active].setActive(false)
        Tab.content[Tab.active].Visible = false
    end
    Tab.active = id
    Tab.buttons[id].setActive(true)
    Tab.content[id].Visible = true
    applySearch()
end

local function registerRow(row, text)
    Tab.rows[row] = { text = string.lower(text) }
end

SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
    searchQuery = string.lower(SearchInput.Text)
    applySearch()
end)

local function createTab(id, label, icon)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size, btn.BackgroundColor3, btn.BackgroundTransparency = UDim2.new(1, -8, 0, 30), C.bg2, 1
    btn.Text, btn.AutoButtonColor, btn.BorderSizePixel = "", false, 0
    corner(btn, 4)

    local leftBar = Instance.new("Frame", btn)
    leftBar.Size, leftBar.Position = UDim2.new(0, 2, 0, 30), UDim2.new(0, 0, 0, 0)
    leftBar.BackgroundColor3, leftBar.BorderSizePixel, leftBar.BackgroundTransparency = C.accent, 0, 1
    corner(leftBar, 4)

    local lbl = Instance.new("TextLabel", btn)
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency, lbl.Text = 1, icon .. " " .. label
    lbl.TextColor3, lbl.TextSize = C.textDim, 10
    applyFont(lbl, "bold")

    local function setActive(on)
        if on then
            btn.BackgroundTransparency = 0
            btn.BackgroundColor3 = C.bg3
            lbl.TextColor3 = C.accent
            leftBar.BackgroundTransparency = 0
        else
            btn.BackgroundTransparency = 1
            btn.BackgroundColor3 = C.bg2
            lbl.TextColor3 = C.textDim
            leftBar.BackgroundTransparency = 1
        end
    end

    btn.MouseEnter:Connect(function()
        if Tab.active ~= id then
            btn.BackgroundTransparency = 0.5
            lbl.TextColor3 = C.text
        end
    end)
    btn.MouseLeave:Connect(function()
        if Tab.active ~= id then
            btn.BackgroundTransparency = 1
            lbl.TextColor3 = C.textDim
        end
    end)
    btn.MouseButton1Click:Connect(function() switchTab(id) end)

    Tab.buttons[id] = {button=btn, setActive=setActive}

    local scroll = Instance.new("ScrollingFrame", ContentArea)
    scroll.Size = UDim2.new(1, -16, 1, -46)
    scroll.Position = UDim2.new(0, 8, 0, 40)
    scroll.BackgroundTransparency, scroll.BorderSizePixel = 1, 0
    scroll.ScrollBarThickness, scroll.ScrollBarImageColor3 = 2, C.accent
    scroll.ScrollBarImageTransparency = 0.6
    scroll.AutomaticCanvasSize, scroll.CanvasSize = Enum.AutomaticSize.Y, UDim2.new(0,0,0,0)
    scroll.Visible = false

    local layout = Instance.new("UIListLayout", scroll)
    layout.SortOrder, layout.Padding = Enum.SortOrder.LayoutOrder, UDim.new(0, 3)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local p2 = Instance.new("UIPadding", scroll)
    p2.PaddingTop, p2.PaddingBottom = UDim.new(0, 4), UDim.new(0, 10)

    Tab.content[id] = scroll
    return scroll
end

-- ─── WIDGETS ───
local function addSection(parent, text)
    local w = Instance.new("Frame", parent)
    w.Size, w.BackgroundTransparency = UDim2.new(0.96, 0, 0, 22), 1
    local bar = Instance.new("Frame", w)
    bar.Size, bar.Position = UDim2.new(0, 2, 0, 10), UDim2.new(0, 0, 0.5, -5)
    bar.BackgroundColor3, bar.BorderSizePixel = C.accent, 0
    corner(bar, 2)
    local l = Instance.new("TextLabel", w)
    l.Size, l.Position = UDim2.new(1, -10, 1, 0), UDim2.new(0, 10, 0, 0)
    l.BackgroundTransparency, l.Text = 1, string.upper(text)
    l.TextColor3, l.TextSize = C.textDim, 9
    l.TextXAlignment = Enum.TextXAlignment.Left
    applyFont(l, "black")
    registerRow(w, "section " .. text)
end

local function addToggle(parent, text, cb, stateKey)
    if not stateKey then stateKey = guessKey(text, "boolean") end
    local state = stateKey and S[stateKey] or false

    local card = Instance.new("TextButton", parent)
    card.Size = UDim2.new(0.96, 0, 0, 26)
    card.BackgroundColor3, card.BackgroundTransparency = C.bg3, 0.3
    card.Text, card.AutoButtonColor, card.BorderSizePixel = "", false, 0
    corner(card, 4); outline(card, C.border, 1, 0.6)

    local lbl = Instance.new("TextLabel", card)
    lbl.Size, lbl.Position = UDim2.new(1, -46, 1, 0), UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency, lbl.Text = 1, text
    lbl.TextColor3, lbl.TextSize = C.text, 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    applyFont(lbl, "medium")

    local track = Instance.new("Frame", card)
    track.Size, track.Position = UDim2.new(0, 30, 0, 16), UDim2.new(1, -38, 0.5, -8)
    track.BackgroundColor3, track.BorderSizePixel = C.bg, 0
    corner(track, 8); outline(track, C.border, 1, 0.4)

    local thumb = Instance.new("Frame", track)
    thumb.Size, thumb.Position = UDim2.new(0, 12, 0, 12), UDim2.new(0, 2, 0.5, -6)
    thumb.BackgroundColor3, thumb.BorderSizePixel = C.textMuted, 0
    corner(thumb, 6)

    local function setVisual(v, animate)
        if v then
            track.BackgroundColor3 = C.accent
            thumb.BackgroundColor3 = Color3.new(1,1,1)
            if animate then
                TweenService:Create(thumb, TweenInfo.new(0.15, Enum.EasingStyle.Quint),
                    {Position = UDim2.new(1,-14,0.5,-6)}):Play()
            else thumb.Position = UDim2.new(1,-14,0.5,-6) end
        else
            track.BackgroundColor3 = C.bg
            thumb.BackgroundColor3 = C.textMuted
            if animate then
                TweenService:Create(thumb, TweenInfo.new(0.15, Enum.EasingStyle.Quint),
                    {Position = UDim2.new(0,2,0.5,-6)}):Play()
            else thumb.Position = UDim2.new(0,2,0.5,-6) end
        end
    end

    setVisual(state, false)
    if stateKey then bindState(stateKey, function(v) state = v; setVisual(v, true) end) end

    card.MouseEnter:Connect(function() card.BackgroundColor3 = C.bgHover end)
    card.MouseLeave:Connect(function() card.BackgroundColor3 = C.bg3 end)
    card.MouseButton1Click:Connect(function()
        state = not state
        setVisual(state, true)
        cb(state)
        queueSave()
    end)
    registerRow(card, "toggle " .. text)
end

local function addSlider(parent, name, def, mn, mx, cb, stateKey)
    if not stateKey then stateKey = guessKey(name, "number") end
    local val = stateKey and S[stateKey] or def
    if type(val) ~= "number" then val = def end

    local card = Instance.new("Frame", parent)
    card.Size = UDim2.new(0.96, 0, 0, 40)
    card.BackgroundColor3, card.BackgroundTransparency = C.bg3, 0.3
    card.BorderSizePixel = 0
    corner(card, 4); outline(card, C.border, 1, 0.6)

    local lbl = Instance.new("TextLabel", card)
    lbl.Size, lbl.Position = UDim2.new(1, -70, 0, 16), UDim2.new(0, 10, 0, 3)
    lbl.BackgroundTransparency, lbl.Text = 1, name
    lbl.TextColor3, lbl.TextSize = C.text, 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    applyFont(lbl, "medium")

    local valLbl = Instance.new("TextLabel", card)
    valLbl.Size, valLbl.Position = UDim2.new(0, 60, 0, 16), UDim2.new(1, -68, 0, 3)
    valLbl.BackgroundTransparency, valLbl.Text = 1, tostring(val)
    valLbl.TextColor3, valLbl.TextSize = C.accent, 10
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    applyFont(valLbl, "bold")

    local sub = Instance.new("TextButton", card)
    sub.Size, sub.Position = UDim2.new(0.5, -4, 0, 16), UDim2.new(0, 6, 0, 21)
    sub.BackgroundColor3, sub.BackgroundTransparency = C.bg, 0.3
    sub.TextColor3, sub.Text, sub.TextSize = C.red, "−", 12
    sub.AutoButtonColor = false
    applyFont(sub, "black")
    corner(sub, 3)

    local add = Instance.new("TextButton", card)
    add.Size, add.Position = UDim2.new(0.5, -4, 0, 16), UDim2.new(0.5, 2, 0, 21)
    add.BackgroundColor3, add.BackgroundTransparency = C.bg, 0.3
    add.TextColor3, add.Text, add.TextSize = C.green, "+", 12
    add.AutoButtonColor = false
    applyFont(add, "black")
    corner(add, 3)

    local function set(v, fire)
        val = v
        valLbl.Text = tostring(v)
        if fire then cb(v); queueSave() end
    end

    if stateKey then
        bindState(stateKey, function(v) if type(v) == "number" then set(v, false) end end)
    end

    local step = 1
    sub.MouseButton1Click:Connect(function() set(math.max(mn, val - step), true) end)
    add.MouseButton1Click:Connect(function() set(math.min(mx, val + step), true) end)
    sub.MouseEnter:Connect(function() sub.BackgroundColor3 = C.red end)
    sub.MouseLeave:Connect(function() sub.BackgroundColor3 = C.bg end)
    add.MouseEnter:Connect(function() add.BackgroundColor3 = C.green end)
    add.MouseLeave:Connect(function() add.BackgroundColor3 = C.bg end)

    registerRow(card, "slider " .. name)
end

local function addCycler(parent, name, options, cb, stateKey)
    if not stateKey then stateKey = guessKey(name, "string") end
    local currentVal = stateKey and S[stateKey] or options[1]
    local idx = 1
    for i, o in ipairs(options) do if o == currentVal then idx = i; break end end

    local card = Instance.new("TextButton", parent)
    card.Size = UDim2.new(0.96, 0, 0, 26)
    card.BackgroundColor3, card.BackgroundTransparency = C.bg3, 0.3
    card.Text, card.AutoButtonColor, card.BorderSizePixel = "", false, 0
    corner(card, 4); outline(card, C.border, 1, 0.6)

    local lbl = Instance.new("TextLabel", card)
    lbl.Size, lbl.Position = UDim2.new(0.5, 0, 1, 0), UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency, lbl.Text = 1, name
    lbl.TextColor3, lbl.TextSize = C.text, 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    applyFont(lbl, "medium")

    local valLbl = Instance.new("TextLabel", card)
    valLbl.Size, valLbl.Position = UDim2.new(0.5, -10, 1, 0), UDim2.new(0.5, 0, 0, 0)
    valLbl.BackgroundTransparency, valLbl.Text = 1, options[idx]
    valLbl.TextColor3, valLbl.TextSize = C.cyan, 10
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    applyFont(valLbl, "bold")

    if stateKey then S[stateKey] = options[idx] end
    if stateKey then
        bindState(stateKey, function(v)
            for i, o in ipairs(options) do
                if o == v then idx = i; valLbl.Text = o; break end
            end
        end)
    end

    card.MouseEnter:Connect(function() card.BackgroundColor3 = C.bgHover end)
    card.MouseLeave:Connect(function() card.BackgroundColor3 = C.bg3 end)

    card.MouseButton1Click:Connect(function()
        idx = idx + 1
        if idx > #options then idx = 1 end
        valLbl.Text = options[idx]
        cb(options[idx])
        queueSave()
    end)
    registerRow(card, "cycler " .. name)
end

local function addButton(parent, text, cb, color)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0.96, 0, 0, 24)
    b.BackgroundColor3, b.BackgroundTransparency = color or C.bg3, 0.2
    b.TextColor3, b.TextSize = C.text, 10
    b.Text, b.AutoButtonColor, b.BorderSizePixel = text, false, 0
    applyFont(b, "bold")
    corner(b, 4); outline(b, color or C.border, 1, 0.5)
    b.MouseEnter:Connect(function() b.BackgroundTransparency = 0 end)
    b.MouseLeave:Connect(function() b.BackgroundTransparency = 0.2 end)
    b.MouseButton1Click:Connect(cb)
    registerRow(b, "button " .. text)
end

-- Toggle UI
local minimized = false
local function toggleUI()
    Main.Visible = not Main.Visible
    BgGui.Enabled = Main.Visible
end
local function toggleMinimize()
    minimized = not minimized
    Main:TweenSize(
        minimized and UDim2.new(0, WIN_W, 0, 32) or UDim2.new(0, WIN_W, 0, WIN_H),
        Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true
    )
end
Icon.MouseButton1Click:Connect(toggleUI)
CloseBtn.MouseButton1Click:Connect(toggleUI)
MinBtn.MouseButton1Click:Connect(toggleMinimize)

-- ─── VISUAL OVERLAYS ───
local FOVFrame = Instance.new("Frame", FOVGui)
FOVFrame.AnchorPoint, FOVFrame.Position = Vector2.new(0.5,0.5), UDim2.new(0.5,0,0.5,0)
FOVFrame.BackgroundTransparency, FOVFrame.Visible = 1, false
local FOVStroke = Instance.new("UIStroke", FOVFrame)
FOVStroke.Transparency, FOVStroke.Color = 0.2, C.accent
corner(FOVFrame, 999)

local SilentFrame = Instance.new("Frame", SilentFOVGui)
SilentFrame.AnchorPoint, SilentFrame.Position = Vector2.new(0.5,0.5), UDim2.new(0.5,0,0.5,0)
SilentFrame.BackgroundTransparency, SilentFrame.Visible = 1, false
local SilentStroke = Instance.new("UIStroke", SilentFrame)
SilentStroke.Transparency, SilentStroke.Color = 0.2, C.cyan
corner(SilentFrame, 999)

local legitDot = Instance.new("Frame", ScreenGui)
legitDot.Size, legitDot.BackgroundColor3 = UDim2.new(0, 10, 0, 10), C.green
legitDot.BackgroundTransparency, legitDot.AnchorPoint, legitDot.Visible = 0.3, Vector2.new(0.5,0.5), false
corner(legitDot, 999)

local Info = Instance.new("Frame", InfoGui)
Info.Size, Info.Position = UDim2.new(0, 200, 0, 100), UDim2.new(0.75, 0, 0.05, 0)
Info.BackgroundColor3, Info.BackgroundTransparency = C.bg, 0.1
Info.BorderSizePixel, Info.Visible, Info.Active = 0, false, true
corner(Info, 6); outline(Info, C.accent, 1, 0.4)
draggable(Info)

local InfoHeader = Instance.new("Frame", Info)
InfoHeader.Size, InfoHeader.BackgroundColor3 = UDim2.new(1, 0, 0, 20), C.bg2
InfoHeader.BorderSizePixel = 0
corner(InfoHeader, 6)

local InfoTitle = Instance.new("TextLabel", InfoHeader)
InfoTitle.Size, InfoTitle.Position = UDim2.new(1, -8, 1, 0), UDim2.new(0, 8, 0, 0)
InfoTitle.BackgroundTransparency, InfoTitle.Text = 1, "TARGET"
InfoTitle.TextColor3, InfoTitle.TextSize = C.accent, 9
InfoTitle.TextXAlignment = Enum.TextXAlignment.Left
applyFont(InfoTitle, "black")

local InfoName = Instance.new("TextLabel", Info)
InfoName.Size, InfoName.Position = UDim2.new(1, -16, 0, 18), UDim2.new(0, 8, 0, 26)
InfoName.BackgroundTransparency, InfoName.Text = 1, "None"
InfoName.TextColor3, InfoName.TextSize = C.text, 11
InfoName.TextXAlignment = Enum.TextXAlignment.Left
applyFont(InfoName, "bold")

local HpBg = Instance.new("Frame", Info)
HpBg.Size, HpBg.Position = UDim2.new(1, -16, 0, 6), UDim2.new(0, 8, 0, 48)
HpBg.BackgroundColor3, HpBg.BorderSizePixel = C.bg3, 0
corner(HpBg, 3)
local HpFill = Instance.new("Frame", HpBg)
HpFill.Size, HpFill.BackgroundColor3 = UDim2.new(1, 0, 1, 0), C.green
HpFill.BorderSizePixel = 0
corner(HpFill, 3)

local InfoHp = Instance.new("TextLabel", Info)
InfoHp.Size, InfoHp.Position = UDim2.new(1, -16, 0, 14), UDim2.new(0, 8, 0, 58)
InfoHp.BackgroundTransparency, InfoHp.Text = 1, "HP: -- / --"
InfoHp.TextColor3, InfoHp.TextSize = C.textDim, 9
InfoHp.TextXAlignment = Enum.TextXAlignment.Left
applyFont(InfoHp, "medium")

local InfoDist = Instance.new("TextLabel", Info)
InfoDist.Size, InfoDist.Position = UDim2.new(1, -16, 0, 14), UDim2.new(0, 8, 0, 74)
InfoDist.BackgroundTransparency, InfoDist.Text = 1, "Distance: --"
InfoDist.TextColor3, InfoDist.TextSize = C.yellow, 9
InfoDist.TextXAlignment = Enum.TextXAlignment.Left
applyFont(InfoDist, "medium")

local BulletTracer = Instance.new("Frame", BulletGui)
BulletTracer.BackgroundColor3, BulletTracer.BorderSizePixel = C.yellow, 0
BulletTracer.AnchorPoint, BulletTracer.Visible, BulletTracer.ZIndex = Vector2.new(0,0.5), false, 3

RT.main = Main

-- ═══════════════════════════════════════════════════════════════════════════
--  §18  BUILD TABS
-- ═══════════════════════════════════════════════════════════════════════════
local aimTab    = createTab("aim",    "AIM",    "🎯")
local combatTab = createTab("combat", "COMBAT", "⚔")
local visualTab = createTab("visual", "VIS",    "👁")
local miscTab   = createTab("misc",   "MISC",   "⚙")
local configTab = createTab("config", "CONF",   "💾")

-- TAB: AIM
do
    local p = aimTab
    addSection(p, "Aimbot Camera")
    addToggle(p, "Aimbot Lock", function(v)
        S.aimbot = v
        if v then S.legitCam = false; S.legit = false end
        if not v then RT.lockedTarget = nil end
    end)
    addToggle(p, "Show FOV", function(v) S.showFOV = v end)
    addToggle(p, "Wall Check", function(v) S.wallCheck = v end)
    addToggle(p, "Team Check", function(v) S.teamCheck = v end)
    addCycler(p, "Aim Part", {"Head","HumanoidRootPart"}, function(o) S.targetPart = o end)
    addSlider(p, "FOV Size", 150, 30, 600, function(v) S.fovRadius = v end)
    addSlider(p, "Aim Smoothness", 10, 1, 10, function(v) S.smooth = v end)

    addSection(p, "Legit Camera")
    addToggle(p, "Legit Camera Aim", function(v)
        S.legitCam = v
        if v then S.aimbot = false; S.legit = false end
        RT.lcTarget = nil
    end)
    addCycler(p, "Aim Method", {"Linear","Curve"}, function(o) S.legitCamAimMethod = o end)
    addSlider(p, "Curve Strength", 65, 0, 100, function(v) S.legitCamCurveStrength = v end)
    addToggle(p, "Require ADS", function(v) S.legitCamRequireADS = v end)
    addToggle(p, "Only Visible", function(v) S.legitCamOnlyVisible = v end)
    addToggle(p, "Overshoot", function(v) S.legitCamOvershoot = v end)
    addToggle(p, "Sticky Aim", function(v) S.legitCamStickyAim = v end)
    addCycler(p, "Hitbox", {"Head","UpperTorso","HumanoidRootPart"}, function(o) S.legitCamHitbox = o end)
    addSlider(p, "Legit FOV", 60, 20, 200, function(v) S.legitCamFOV = v end)
    addSlider(p, "Reaction Min (ms)", 120, 0, 500, function(v) S.legitCamReaction = v end)
    addSlider(p, "Speed Min (x10)", 35, 10, 100, function(v) S.legitCamSpeedMin = v / 10 end)
    addSlider(p, "Speed Max (x10)", 70, 10, 100, function(v) S.legitCamSpeedMax = v / 10 end)
    addSlider(p, "Mouse Lock X", 50, 0, 100, function(v) S.legitCamMouseLockX = v end)
    addSlider(p, "Mouse Lock Y", 50, 0, 100, function(v) S.legitCamMouseLockY = v end)

    addSection(p, "Silent Aim (Bắn vào đâu cũng vào đầu)")
    addToggle(p, "Silent Aim", function(v) S.silent = v end)
    addToggle(p, "Chỉ khi bắn (LMB)", function(v) S.silentOnlyFiring = v end)
    addToggle(p, "Wall Check", function(v) S.silentWall = v end)
    addToggle(p, "Team Check", function(v) S.silentTeam = v end)
    addCycler(p, "Hitbox", {"Head","UpperTorso","HumanoidRootPart"}, function(o) S.silentPart = o end)
    addSlider(p, "Max Angle (°)", 90, 5, 180, function(v) S.silentAngle = v end)
    addSlider(p, "Hit Chance (%)", 100, 0, 100, function(v) S.silentHitChance = v end)

    addSection(p, "Legit Silent")
    addToggle(p, "Legit Silent Aim", function(v)
        S.legit = v
        if v then S.aimbot = false; S.legitCam = false end
    end)
    addToggle(p, "Only When Firing", function(v) S.legitOnlyFiring = v end)
    addCycler(p, "Hitbox", {"Head","HumanoidRootPart","UpperTorso"}, function(o) S.legitPart = o end)
    addSlider(p, "Pixel Radius", 45, 10, 200, function(v) S.legitRadius = v end)
    addSlider(p, "Hit Chance (%)", 100, 0, 100, function(v) S.legitHitChance = v end)
end

-- TAB: COMBAT
do
    local p = combatTab
    addSection(p, "Anti-Katana")
    addToggle(p, "Anti-Katana (Skip Deflect)", function(v) S.antiKatana = v end)
    addSlider(p, "Deflect Window (ms)", 800, 200, 2000, function(v) S.antiKatanaWindow = v / 1000 end)
    addToggle(p, "Notify khi địch deflect", function(v) S.antiKatanaNotify = v end)

    addSection(p, "No Recoil / Spread")
    addToggle(p, "No Recoil", function(v)
        S.noRecoil = v
        if v then Camera.CameraOffset = Vector3.zero end
    end)
    addToggle(p, "No Camera Shake", function(v)
        S.noShake = v
        if v then RT.baseFOV = Camera.FieldOfView end
    end)
    addToggle(p, "No Spread", function(v) S.noSpread = v end)

    addSection(p, "Rapid Fire")
    addToggle(p, "Rapid Fire", function(v)
        S.rapid = v
        if not v then restoreRapid() end
    end)
    addCycler(p, "Mode", {"Enabled-Spam","Cooldown-Zero","FireRemote-Spam"}, function(o)
        S.rapidMode = o
        if o ~= "Cooldown-Zero" then restoreRapid() end
    end)
    addSlider(p, "Multiplier", 1, 1, 5, function(v) S.rapidMult = v end)

    addSection(p, "Auto Reload")
    addToggle(p, "Auto Reload", function(v) S.autoReload = v end)
    addCycler(p, "Mode", {"Smart","Always","Manual-Key"}, function(o) S.autoReloadMode = o end)
    addCycler(p, "Keybind", {"R","Q","E","F","G"}, function(o) S.autoReloadKeybind = o end)
    addSlider(p, "Threshold", 1, 1, 30, function(v) S.autoReloadThreshold = v end)

    addSection(p, "Prediction")
    addToggle(p, "Aim Prediction", function(v)
        S.prediction = v
        if v then scanWeapon() end
    end)
    addSlider(p, "Projectile Speed", 1000, 100, 5000, function(v) S.projSpeed = v end)
    addSlider(p, "Prediction Mult (x10)", 10, 1, 30, function(v) S.predMult = v / 10 end)
end

-- TAB: VISUAL
do
    local p = visualTab
    addSection(p, "ESP")
    addToggle(p, "Full ESP", function(v) S.esp = v; refreshESP() end)
    addToggle(p, "Box", function(v) S.espBox = v end)
    addSlider(p, "Box Thickness (x10)", 15, 5, 50, function(v) S.espBoxThickness = v / 10 end)
    addToggle(p, "Player Name", function(v) S.espName = v end)
    addToggle(p, "Distance", function(v) S.espDistance = v end)
    addToggle(p, "Health Bar", function(v) S.espHealth = v end)
    addToggle(p, "Skeleton", function(v)
        S.espSkeleton = v
        if not v then
            for _, d in pairs(RT.espData) do
                for _, b in ipairs(d.bones) do if b.line then b.line.Visible = false end end
            end
        end
    end)
    addSlider(p, "Skeleton Thickness (x10)", 15, 5, 50, function(v) S.espSkeletonThickness = v / 10 end)
    addToggle(p, "Tracer", function(v)
        S.espTracer = v
        if not v then
            for _, d in pairs(RT.espData) do
                if d.tracer then d.tracer.Visible = false end
            end
        end
    end)
    addCycler(p, "Tracer Origin", {"Top","Bottom","Center","Left","Right","Mouse"}, function(o) S.espTracerOrigin = o end)
    addToggle(p, "Chams", function(v)
        S.espChams = v
        for plr, d in pairs(RT.espData) do
            local c = plr.Character
            if c then
                if d.chams then d.chams:Destroy(); d.chams = nil end
                if v then d.chams = applyChams(c) end
            end
        end
    end)
    addToggle(p, "Team Check", function(v) S.espTeamCheck = v end)
    addToggle(p, "Rainbow Mode", function(v) S.espRainbow = v end)
    addSlider(p, "Max Distance", 1000, 100, 5000, function(v) S.espMaxDistance = v end)

    local colorNames = {}
    for _, c in ipairs(ESP_COLORS) do table.insert(colorNames, c.name) end
    addCycler(p, "ESP Color", colorNames, function(name)
        for _, c in ipairs(ESP_COLORS) do
            if c.name == name then S.espColor = c.color; break end
        end
        refreshESPColor()
    end)

    addSection(p, "Info Panel")
    addToggle(p, "Show Target Info", function(v) S.showInfo = v end)
    addToggle(p, "Show Bullet Tracer", function(v) S.showBulletTracer = v end)

    addSection(p, "Custom Cursor")
    addToggle(p, "Enable Cursor", function(v)
        S.cursorEnabled = v
        applyCursor()
    end)
    addCycler(p, "Style", {"Crosshair","Dot","Circle","X"}, function(o)
        S.cursorStyle = o
        if S.cursorEnabled then buildCursor() end
    end)
    addToggle(p, "Rainbow", function(v) S.cursorRainbow = v end)
    addSlider(p, "Size", 24, 8, 80, function(v)
        S.cursorSize = v
        if S.cursorEnabled then buildCursor() end
    end)
end

-- TAB: MISC
do
    local p = miscTab

    addSection(p, "🔫 Skin Changer (ViewModels)")
    addToggle(p, "Enable Model Swap", function(v)
        S.skinModelEnabled = v
        if not v then restoreAllSkins() end
    end)
    addCycler(p, "Weapon", WEAPON_NAMES, function(o)
        S.skinWeaponModelName = o
    end)
    addButton(p, "🔄 Apply Model Swap", function()
        S.skinModelEnabled = true
        swapWeaponSkin(S.skinWeaponModelName, S.skinTargetSkinName, true)
    end)
    addButton(p, "❌ Reset Model", function()
        restoreAllSkins()
    end, Color3.fromRGB(140, 30, 30))

    addSection(p, "🎨 Weapon Wrap")
    addToggle(p, "Enable Wrap", function(v)
        S.skinWeaponEnabled = v
        if v then applyWeaponWrap() else restoreSkin() end
    end)
    addCycler(p, "Wrap", WEAPON_WRAPS, function(o)
        S.skinWeaponWrap = o
        if S.skinWeaponEnabled then applyWeaponWrap() end
    end)

    addSection(p, "👤 Body Color")
    addToggle(p, "Enable Body Color", function(v)
        S.skinBodyColorEnabled = v
        if v then applyBodyColor() else restoreSkin() end
    end)
    for name, color in pairs(SKIN_PRESETS) do
        addButton(p, name, function()
            S.skinBodyColor = color
            S.skinBodyColorEnabled = true
            applyBodyColor()
        end)
    end

    addSection(p, "🖼 Texture Changer")
    addToggle(p, "Enable Texture", function(v)
        S.texEnabled = v
        applyTexNow()
    end)
    addSlider(p, "Transparency (x100)", 0, 0, 100, function(v)
        S.texTransparency = v / 100
        if S.texEnabled then applyTexNow() end
    end)
    addSlider(p, "Reflectance (x100)", 0, 0, 100, function(v)
        S.texReflectance = v / 100
        if S.texEnabled then applyTexNow() end
    end)
    addToggle(p, "Apply to Weapon", function(v) S.texApplyToWeapon = v end)
    addToggle(p, "Apply to Character", function(v) S.texApplyToChar = v end)
    addButton(p, "🔄 Apply Texture", function()
        S.texEnabled = true
        applyTexNow()
    end)
    addButton(p, "❌ Reset Texture", function()
        S.texEnabled = false
        applyTexNow()
    end, Color3.fromRGB(140, 30, 30))

    addSection(p, "⚡ No Task Scheduler")
    addToggle(p, "Enable NTS", function(v)
        S.noTaskSchedule = v
        if v then installNTS() else uninstallNTS() end
    end)
    addToggle(p, "Boost Priority", function(v) S.noTaskBoostPriority = v end)
    addSlider(p, "Max Wait (ms)", 10, 1, 100, function(v) S.noTaskMaxWait = v end)
end

-- TAB: CONFIG
do
    local p = configTab
    addSection(p, "Config")
    addToggle(p, "Auto Save", function(v)
        S.autoSave = v
        if v then saveConfig(true) end
    end)
    addCycler(p, "Slot", (#listConfigs() > 0 and listConfigs() or {"tioshub_v6"}), function(name)
        S.configName = name
        queueSave()
    end)
    addButton(p, "💾 Save Config", function() saveConfig() end)
    addButton(p, "📂 Load Config", function()
        if loadConfig() then print("Loaded. Rejoin to fully apply.") end
    end)

    addSection(p, "Info")
    local info = Instance.new("TextLabel", p)
    info.Size = UDim2.new(0.96, 0, 0, 60)
    info.BackgroundColor3, info.BackgroundTransparency = C.bg3, 0.4
    info.TextColor3, info.TextSize = C.textDim, 9
    info.Text = "TiosHub v6.0 FINAL\n" .. CFG.FOLDER .. "/" .. S.configName .. CFG.EXT
    info.TextWrapped, info.TextXAlignment = true, Enum.TextXAlignment.Left
    applyFont(info, "medium")
    corner(info, 4)
    local ip = Instance.new("UIPadding", info)
    ip.PaddingLeft, ip.PaddingRight = UDim.new(0, 8), UDim.new(0, 8)
    registerRow(info, "info")
end

switchTab("aim")

-- ═══════════════════════════════════════════════════════════════════════════
--  §19  MAIN LOOP
-- ═══════════════════════════════════════════════════════════════════════════
local weaponTimer, infoTimer, bulletSkip = 0, 0, 0
local lastInfo = {name="", hp="", dist="", ratio=-1}

local function mainLoop(dt)
    weaponTimer = weaponTimer + dt
    if weaponTimer >= CFG.WEAPON_SCAN then weaponTimer = 0; scanWeapon() end

    if S.showFOV then
        FOVFrame.Size = UDim2.new(0, S.fovRadius * 2, 0, S.fovRadius * 2)
        FOVStroke.Thickness, FOVStroke.Color = S.fovThickness or 2, S.espColor
    end
    FOVFrame.Visible = S.showFOV

    -- Aim resolution
    if S.legitCam then
        RT.currentTarget = processLegitCam(dt)
    elseif S.aimbot then
        local t, p = findBestTarget(S.fovRadius, S.targetPart, S.wallCheck, S.teamCheck, true)
        RT.currentTarget = t
        if t and p then
            local aimPos = predict(t.Character, p, S.prediction, RT.projConfig, S.predMult)
            local dest = CFrame.new(Camera.CFrame.Position, aimPos)
            if S.smooth >= 10 then Camera.CFrame = dest
            else Camera.CFrame = Camera.CFrame:Lerp(dest, math.clamp(S.smooth/10, 0.05, 0.9)) end
        end
    elseif S.legit then
        getLegitTarget(); RT.currentTarget = RT.legitCache
    elseif S.silent then
        RT.currentTarget = nil
    else RT.currentTarget = nil end

    processNoRecoil()
    processRapidFire()
    processAutoReload()
    processAutoSave(dt)
    processSkin()
    processCursor(dt)

    -- Legit indicator
    if S.legit and S.legitIndicator and RT.legitCache and RT.legitCache.Character then
        local head = RT.legitCache.Character:FindFirstChild(S.legitPart) or RT.legitCache.Character:FindFirstChild("Head")
        if head then
            local sp, on = Camera:WorldToViewportPoint(head.Position)
            if on and sp.Z > 0 then
                legitDot.Visible = true
                legitDot.Position = UDim2.new(0, sp.X, 0, sp.Y)
            else legitDot.Visible = false end
        else legitDot.Visible = false end
    else legitDot.Visible = false end

    -- Info panel
    infoTimer = infoTimer + dt
    if infoTimer >= CFG.INFO_UPDATE then
        infoTimer = 0
        if S.showInfo and RT.currentTarget then
            Info.Visible = true
            local char = RT.currentTarget.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if lastInfo.name ~= RT.currentTarget.DisplayName then
                lastInfo.name = RT.currentTarget.DisplayName
                InfoName.Text = RT.currentTarget.DisplayName
            end
            if hum then
                local hp = math.floor(math.clamp(hum.Health, 0, hum.MaxHealth))
                local ratio = hum.MaxHealth > 0 and hum.Health / hum.MaxHealth or 0
                local hpStr = string.format("HP: %d / %d", hp, math.floor(hum.MaxHealth))
                if lastInfo.hp ~= hpStr then lastInfo.hp = hpStr; InfoHp.Text = hpStr end
                if math.abs(ratio - lastInfo.ratio) > 0.01 then
                    lastInfo.ratio = ratio
                    HpFill.Size = UDim2.new(math.clamp(ratio,0,1), 0, 1, 0)
                    HpFill.BackgroundColor3 = ratio > 0.5 and C.green or ratio > 0.2 and C.yellow or C.red
                end
            end
            if hrp then
                local mRoot = getLocalRoot()
                if mRoot then
                    local ds = string.format("Distance: %d", math.floor((hrp.Position - mRoot.Position).Magnitude))
                    if lastInfo.dist ~= ds then lastInfo.dist = ds; InfoDist.Text = ds end
                end
            end
        elseif Info.Visible then Info.Visible = false end
    end

    if S.esp then updateESPVisuals() end
end

RunService:BindToRenderStep("TiosHub_Main", CFG.RENDER_PRIO, mainLoop)

local function cameraFix()
    if not RT.lcLastCFrame then return end
    if not (S.legitCam or S.aimbot) then return end
    if Camera.CameraType == Enum.CameraType.Scriptable then
        Camera.CameraType = Enum.CameraType.Custom
    end
    Camera.CFrame = RT.lcLastCFrame
end
RunService:BindToRenderStep("TiosHub_CamFix", CFG.CAM_PRIO, cameraFix)

-- ═══════════════════════════════════════════════════════════════════════════
--  §20  INIT
-- ═══════════════════════════════════════════════════════════════════════════
task.spawn(function()
    task.wait(0.3)
    if S.noTaskSchedule then installNTS() end
    if S.esp then refreshESP() end
    if S.cursorEnabled then applyCursor() end
    print("[TiosHub] ⚙ Runtime applied")
end)

pcall(function()
    game:BindToClose(function()
        if S.autoSave then saveConfig(true) end
    end)
end)

print("═══════════════════════════════════════════════════")
print("  TIOSHUB v6.0 FINAL  |  Rivals Edition")
print("  → Silent · Aimbot · LegitCam · Anti-Katana")
print("  → Skin · Wrap · Texture · ESP · Cursor")
print("═══════════════════════════════════════════════════")