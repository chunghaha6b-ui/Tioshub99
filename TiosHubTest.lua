-- ═══════════════════════════════════════════════════════════════════════════
--   TIOSHUB v3.2  |  CLEAN FINAL  |  RIVALS EDITION
--   UE-Style UI • Full Features • Optimized • No bugs
-- ═══════════════════════════════════════════════════════════════════════════
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService      = game:GetService("HttpService")
local TweenService     = game:GetService("TweenService")
local Lighting         = game:GetService("Lighting")

local LP     = Players.LocalPlayer
local PGui   = LP:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

-- ═══════════════════════════════════════════════════════════════════════════
--  §1  CLEANUP + GUI SETUP
-- ═══════════════════════════════════════════════════════════════════════════
for _, n in ipairs({"TiosBg","TiosHub","TiosFOV","TiosTracer","TiosInfo","TiosBullet","TiosSilentFOV","TiosCursor"}) do
    local o = PGui:FindFirstChild(n)
    if o then o:Destroy() end
end
pcall(function() RunService:UnbindFromRenderStep("TiosHub_Main") end)

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
local TracerGui    = newGui("TiosTracer", 2)
local InfoGui      = newGui("TiosInfo", 3)
local FOVGui       = newGui("TiosFOV", 4)
local BulletGui    = newGui("TiosBullet", 5)
local SilentFOVGui = newGui("TiosSilentFOV", 6)
local CursorGui    = newGui("TiosCursor", 9999)

BgGui.Enabled = false   -- Background chỉ bật khi UI mở

-- ═══════════════════════════════════════════════════════════════════════════
--  §2  CONSTANTS
-- ═══════════════════════════════════════════════════════════════════════════
local CFG = {
    LOST_TOLERANCE = 0.35,
    WEAPON_SCAN    = 0.15,
    CACHE_AIM      = 0.02,
    CACHE_FILTER   = 0.25,
    CACHE_RAYCAST  = 0.03,
    INFO_UPDATE    = 0.05,
    AUTOSAVE_DELAY = 1.5,
    RENDER_PRIO    = Enum.RenderPriority.Camera.Value + 1,
    FOLDER         = "TiosHub_Configs",
    EXT            = ".json",
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

local WRAPS = {"Default","Gold","Diamond","Ruby","Emerald","Sapphire","Galaxy","Neon","Crimson","Frost","Toxic","Void"}
local ESP_COLORS = {
    {name="Blue",   color=Color3.fromRGB(100,180,255)},
    {name="Red",    color=Color3.fromRGB(235,65,85)},
    {name="Green",  color=Color3.fromRGB(80,220,150)},
    {name="Yellow", color=Color3.fromRGB(255,205,110)},
    {name="Cyan",   color=Color3.fromRGB(100,210,240)},
    {name="Purple", color=Color3.fromRGB(200,90,240)},
    {name="White",  color=Color3.fromRGB(255,255,255)},
    {name="Orange", color=Color3.fromRGB(255,150,60)},
    {name="Pink",   color=Color3.fromRGB(255,120,180)},
    {name="Lime",   color=Color3.fromRGB(180,255,100)},
}

-- ═══════════════════════════════════════════════════════════════════════════
--  §3  STATE
-- ═══════════════════════════════════════════════════════════════════════════
local S = {
    autoSave=true, configName="tioshub_v3",

    -- Aimbot
    aimbot=false, fovRadius=150, fovThickness=2, smooth=10,
    wallCheck=true, teamCheck=true, targetPart="Head", showFOV=false,
    fovColor=Color3.fromRGB(100,180,255),

    -- Legit Camera
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
    legitPrediction=false, legitMult=1.0,

    -- Silent
    silent=false, silentFOV=200, silentPart="Head", silentHitChance=100,
    silentWall=false, silentTeam=true, silentOnlyFiring=true, silentShowFOV=false,

    -- Ragebot
    rage=false, rageFOV=360, rageTargetPart="Head", rageAutoFire=true,
    rageAutoFireDelay=0.05, rageIgnoreWall=true, rageInstantLock=true,
    rageSpinBot=false, rageSpinSpeed=18, rageKeybind="E", rageUseKeybind=false,

    -- Anti Katana
    antiKatana=false, antiKatanaMode="Bypass", antiKatanaBypassDeflect=true,
    antiKatanaAutoParry=true, antiKatanaParryRange=15, antiKatanaParryCooldown=0.3,
    antiKatanaDetectDistance=50, antiKatanaIgnoreTeam=true, antiKatanaShowIndicator=true,

    -- No Recoil
    noRecoil=false, noShake=false, noSpread=false,

    -- Rapid Fire
    rapid=false, rapidMode="Enabled-Spam", rapidMult=1,

    -- Auto Reload
    autoReload=false, autoReloadMode="Smart", autoReloadThreshold=1,
    autoReloadKeybind="R", autoReloadDelay=0.1,

    -- No Task Scheduler
    noTaskSchedule=false, noTaskMaxWait=10, noTaskBoostPriority=true,

    -- Mod Skin
    skinWeaponEnabled=false, skinWeaponWrap="Default",
    skinBodyColorEnabled=false, skinBodyColor=Color3.fromRGB(20,20,25),
    skinCharacterEnabled=false, skinCharacterId=0,

    -- Prediction
    prediction=false, projSpeed=1000, predMult=1.0, projGravity=0, showBulletTracer=false,

    -- Info
    showInfo=true,

    -- ESP
    esp=false, espBox=true, espBoxStyle="Corner", espBoxThickness=1.5,
    espName=true, espNameSize=11, espHealth=true,
    espSkeleton=false, espSkeletonThickness=2,
    espTracer=false, espTracerOrigin="Bottom", espTracerThickness=1.5,
    espChams=false, espChamsFillColor=Color3.fromRGB(100,180,255),
    espChamsOutlineColor=Color3.fromRGB(255,255,255),
    espChamsFillTransparency=0.55, espChamsDepthMode="AlwaysOnTop",
    espTeamCheck=true, espColor=Color3.fromRGB(100,180,255),
    espTeamColor=Color3.fromRGB(80,220,150),
    espRainbow=false, espRainbowSpeed=1,
    espDistanceFade=true, espFadeNear=50, espFadeFar=500,
    espMaxDistance=1000,

    -- Custom Cursor
    cursorEnabled=false, cursorStyle="Crosshair", cursorSize=24,
    cursorThickness=2, cursorGap=4,
    cursorColor=Color3.fromRGB(100,180,255), cursorOutlineColor=Color3.fromRGB(15,20,35),
    cursorOutlineThickness=1, cursorSpinSpeed=0,
    cursorPulse=false, cursorPulseSpeed=1.2, cursorPulseAmount=0.15,
    cursorRainbow=false, cursorRainbowSpeed=1.5, cursorCenterDot=true,
    cursorHideInGame=true,
}

local RT = {
    lockedTarget=nil, lastSeen=0,
    silentCache=nil, silentPos=nil, silentTime=0,
    legitCache=nil, legitPos=nil, legitTime=0,
    currentTarget=nil,
    mouseDown=false, adsDown=false,
    baseFOV=Camera.FieldOfView,
    skipHook=false,
    projConfig=nil,
    lcTarget=nil, lcPart=nil, lcStartTime=0, lcLastSeen=0, lcBreakUntil=0,
    lcOvershootDone=false, lcJitter=Vector2.new(0,0), lcStickyUntil=0,
    lcAimKeyHeld=false, lcBulletCount=0, lcFlashUntil=0,
    rageTarget=nil, rageLastFire=0, rageKeyHeld=false,
    katanaUsers={}, lastParryTime=0,
    rapidBackup={}, lastReloadTime=0, taskSchedulerInstalled=false,
    originalWraps={}, lastTool=nil,
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

-- ═══════════════════════════════════════════════════════════════════════════
--  §5  CONFIG SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════
pcall(function() if not isfolder(CFG.FOLDER) then makefolder(CFG.FOLDER) end end)

local function serialize(v)
    if typeof(v) == "Color3" then return {__t="C3", r=v.R, g=v.G, b=v.B}
    elseif typeof(v) == "Vector2" then return {__t="V2", x=v.X, y=v.Y}
    elseif typeof(v) == "Vector3" then return {__t="V3", x=v.X, y=v.Y, z=v.Z}
    elseif type(v) == "table" then
        local o = {}; for k, val in pairs(v) do o[k] = serialize(val) end; return o
    end
    return v
end

local function deserialize(v)
    if type(v) == "table" then
        if v.__t == "C3" then return Color3.new(v.r, v.g, v.b)
        elseif v.__t == "V2" then return Vector2.new(v.x, v.y)
        elseif v.__t == "V3" then return Vector3.new(v.x, v.y, v.z) end
        local o = {}; for k, val in pairs(v) do o[k] = deserialize(val) end; return o
    end
    return v
end

local function cfgPath(n) return CFG.FOLDER .. "/" .. (n or S.configName) .. CFG.EXT end

local function saveConfig(silent)
    local ok, err = pcall(function()
        writefile(cfgPath(), HttpService:JSONEncode(serialize(S)))
        if not silent then print("[TiosHub] 💾 Saved: " .. cfgPath()) end
    end)
    if not ok and not silent then warn("[TiosHub] Save failed: " .. tostring(err)) end
    return ok
end

local function loadConfig(silent)
    local path = cfgPath()
    if not isfile(path) then return false end
    local ok = pcall(function()
        local data = deserialize(HttpService:JSONDecode(readfile(path)))
        for k, v in pairs(data) do if S[k] ~= nil then S[k] = v end end
        if not silent then print("[TiosHub] ✅ Loaded: " .. path) end
    end)
    return ok
end

local function listConfigs()
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

-- ═══════════════════════════════════════════════════════════════════════════
--  §6  PROJECTILE
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
        if S.legitCamKeybindMode == "Toggle" then
            RT.lcAimKeyHeld = not RT.lcAimKeyHeld
        else RT.lcAimKeyHeld = true end
    end
    if i.KeyCode and i.KeyCode.Name == S.rageKeybind then RT.rageKeyHeld = true end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then RT.mouseDown = false
    elseif i.UserInputType == Enum.UserInputType.MouseButton2 then RT.adsDown = false end
    if i.KeyCode and i.KeyCode.Name == S.legitCamAimKeybind and S.legitCamKeybindMode == "Hold" then
        RT.lcAimKeyHeld = false
    end
    if i.KeyCode and i.KeyCode.Name == S.rageKeybind then RT.rageKeyHeld = false end
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
--  §9  UNIFIED AIM
-- ═══════════════════════════════════════════════════════════════════════════
local function getAimTarget(mode)
    local isSilent = mode == "silent"
    local enabled   = isSilent and S.silent or S.legit
    local onlyFire  = isSilent and S.silentOnlyFiring or S.legitOnlyFiring
    local hitChance = isSilent and S.silentHitChance or S.legitHitChance
    local fovPx     = isSilent and S.silentFOV or S.legitRadius
    local partName  = isSilent and S.silentPart or S.legitPart
    local wall      = isSilent and S.silentWall or S.legitWall
    local team      = isSilent and S.silentTeam or S.legitTeam
    local cacheT    = isSilent and RT.silentTime or RT.legitTime

    if not enabled then return nil, nil end
    if onlyFire and not RT.mouseDown then return nil, nil end
    if hitChance < 100 and math.random(1,100) > hitChance then return nil, nil end
    if tick() - cacheT < CFG.CACHE_AIM then
        return isSilent and RT.silentCache or RT.legitCache,
               isSilent and RT.silentPos or RT.legitPos
    end

    local t, p = findBestTarget(fovPx, partName, wall, team, false)
    local pos = nil
    if t and p then
        local usePred = (isSilent and S.prediction) or (not isSilent and S.legitPrediction)
        local mult = isSilent and S.predMult or S.legitMult
        pos = predict(t.Character, p, usePred, RT.projConfig, mult)
    end

    local now = tick()
    if isSilent then RT.silentCache, RT.silentPos, RT.silentTime = t, pos, now
    else RT.legitCache, RT.legitPos, RT.legitTime = t, pos, now end
    return t, pos
end

-- ═══════════════════════════════════════════════════════════════════════════
--  §10  LEGIT CAMERA
-- ═══════════════════════════════════════════════════════════════════════════
local function lcCanSee(char, part)
    if not S.legitCamOnlyVisible then return true end
    rayParams.FilterDescendantsInstances = getFilter()
    local r = rawRay(Camera.CFrame.Position, part.Position - Camera.CFrame.Position)
    return not r or r.Instance:IsDescendantOf(char)
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
    local t, invT = 0.1, 0.9
    return Vector2.new(
        invT*invT*currentScreen.X + 2*invT*t*midX + t*t*targetScreen.X,
        invT*invT*currentScreen.Y + 2*invT*t*midY + t*t*targetScreen.Y
    )
end

local function processLegitCam(dt)
    if not S.legitCam then RT.lcTarget = nil; return nil end
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
        RT.lcBulletCount = 0
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

    if S.legitCamTriggerAssist then
        local dToCenter = (ts - curScreen).Magnitude
        if dToCenter < 15 then
            local tool = getLocalTool()
            if tool then pcall(function() tool:Activate() end) end
        end
    end

    RT.lcBulletCount = RT.lcBulletCount + 1
    return target, part
end

local lastBrightness = Lighting.Brightness
Lighting:GetPropertyChangedSignal("Brightness"):Connect(function()
    if math.abs(Lighting.Brightness - lastBrightness) > 2 then
        RT.lcFlashUntil = tick() + 1.5
    end
    lastBrightness = Lighting.Brightness
end)

-- ═══════════════════════════════════════════════════════════════════════════
--  §11  RAGEBOT
-- ═══════════════════════════════════════════════════════════════════════════
local function processRagebot(dt)
    if not S.rage then RT.rageTarget = nil; return nil end
    if S.rageUseKeybind and not RT.rageKeyHeld then RT.rageTarget = nil; return nil end

    local target, part
    if RT.rageTarget and isAlive(RT.rageTarget.Character) then
        local p = getPart(RT.rageTarget.Character, S.rageTargetPart)
        if p and (p.Position - Camera.CFrame.Position).Magnitude < 1000 then
            target, part = RT.rageTarget, p
        end
    end
    if not target then
        target, part = findBestTarget(S.rageFOV, S.rageTargetPart, not S.rageIgnoreWall, S.teamCheck, true)
        RT.rageTarget = target
    end

    if target and part then
        if S.rageAutoFire then
            local now = tick()
            if now - RT.rageLastFire >= S.rageAutoFireDelay then
                RT.rageLastFire = now
                local tool = getLocalTool()
                if tool then pcall(function() tool:Activate() end) end
            end
        end
        if S.rageInstantLock then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, part.Position)
        end
        if S.rageSpinBot then
            Camera.CFrame = Camera.CFrame * CFrame.Angles(0, math.rad(S.rageSpinSpeed * dt), 0)
        end
    end
    return target
end

-- ═══════════════════════════════════════════════════════════════════════════
--  §12  ANTI KATANA
-- ═══════════════════════════════════════════════════════════════════════════
local antiKatanaIndicator

local function createAntiKatanaIndicator()
    if antiKatanaIndicator then return end
    antiKatanaIndicator = Instance.new("TextLabel", ScreenGui)
    antiKatanaIndicator.Size = UDim2.new(0, 160, 0, 28)
    antiKatanaIndicator.Position = UDim2.new(0.5, -80, 0.82, 0)
    antiKatanaIndicator.BackgroundColor3 = Color3.fromRGB(60, 20, 30)
    antiKatanaIndicator.BackgroundTransparency = 0.3
    antiKatanaIndicator.TextColor3 = Color3.fromRGB(255, 100, 120)
    antiKatanaIndicator.Font = Enum.Font.GothamBold
    antiKatanaIndicator.TextSize = 11
    antiKatanaIndicator.Text = "⚔ KATANA DETECTED"
    antiKatanaIndicator.Visible = false
    antiKatanaIndicator.ZIndex = 100
    local c = Instance.new("UICorner", antiKatanaIndicator); c.CornerRadius = UDim.new(0, 8)
    local s = Instance.new("UIStroke", antiKatanaIndicator)
    s.Color = Color3.fromRGB(255, 80, 80); s.Thickness = 1; s.Transparency = 0.4
end

local function detectKatanaUsers()
    RT.katanaUsers = {}
    local myRoot = getLocalRoot()
    if not myRoot then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and isAlive(plr.Character) then
            if S.antiKatanaIgnoreTeam and plr.Team and LP.Team and plr.Team == LP.Team then continue end
            local tool = plr.Character:FindFirstChildOfClass("Tool")
            if tool then
                local n = string.lower(tool.Name)
                if string.find(n, "katana") or string.find(n, "sword")
                    or string.find(n, "blade") or string.find(n, "saber") then
                    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local dist = (hrp.Position - myRoot.Position).Magnitude
                        if dist <= S.antiKatanaDetectDistance then
                            RT.katanaUsers[plr] = {tool=tool, dist=dist, hrp=hrp}
                        end
                    end
                end
            end
        end
    end
end

local function processAutoParry()
    if not S.antiKatanaAutoParry then return end
    local now = tick()
    if now - RT.lastParryTime < S.antiKatanaParryCooldown then return end
    local nearestDist = S.antiKatanaParryRange
    local hasTarget = false
    for _, data in pairs(RT.katanaUsers) do
        if data.dist < nearestDist then nearestDist = data.dist; hasTarget = true end
    end
    if not hasTarget then return end

    local myTool = getLocalTool()
    if myTool then
        local n = string.lower(myTool.Name)
        if string.find(n, "katana") or string.find(n, "sword")
            or string.find(n, "shield") or string.find(n, "parry") then
            pcall(function() myTool:Activate() end)
            RT.lastParryTime = now
        end
    end
end

local function processAntiKatana()
    if not S.antiKatana then
        if antiKatanaIndicator then antiKatanaIndicator.Visible = false end
        return
    end
    detectKatanaUsers()
    if S.antiKatanaShowIndicator and antiKatanaIndicator then
        local count = 0
        for _ in pairs(RT.katanaUsers) do count = count + 1 end
        if count > 0 then
            antiKatanaIndicator.Visible = true
            antiKatanaIndicator.Text = "⚔ KATANA x" .. count
        else
            antiKatanaIndicator.Visible = false
        end
    end
    if S.antiKatanaMode == "AutoParry" or S.antiKatanaMode == "Full" then
        processAutoParry()
    end
end

createAntiKatanaIndicator()

-- ═══════════════════════════════════════════════════════════════════════════
--  §13  HOOK
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
            local tPos = nil

            if S.antiKatana and S.antiKatanaBypassDeflect and next(RT.katanaUsers) then
                if method == "Raycast" and typeof(args[1]) == "Vector3" and typeof(args[2]) == "Vector3" then
                    local origin, dir = args[1], args[2]
                    for _, data in pairs(RT.katanaUsers) do
                        if data.hrp then
                            local toT = data.hrp.Position - origin
                            local dot = dir.Unit:Dot(toT.Unit)
                            if dot > 0.9 then
                                args[2] = toT
                                return old(self, unpack(args))
                            end
                        end
                    end
                end
            end

            if S.legit then local _, p = getAimTarget("legit"); if p then tPos = p end end
            if not tPos and S.silent then local _, p = getAimTarget("silent"); if p then tPos = p end end

            if tPos then
                if method == "Raycast" and typeof(args[1]) == "Vector3" then
                    args[2] = tPos - args[1]
                elseif typeof(args[1]) == "Ray" then
                    args[1] = Ray.new(args[1].Origin, tPos - args[1].Origin)
                end
                return old(self, unpack(args))
            end

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
--  §14  EFFECTS
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
                if string.find(n, "cooldown") or string.find(n, "firerate")
                    or string.find(n, "fire_rate") or string.find(n, "delay") then
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

local function findAmmoValue(tool)
    if not tool then return nil end
    for _, v in ipairs(tool:GetDescendants()) do
        if v:IsA("IntValue") or v:IsA("NumberValue") then
            local n = string.lower(v.Name)
            if string.find(n, "ammo") or string.find(n, "clip")
                or string.find(n, "mag") or string.find(n, "bullet") then
                return v
            end
        end
    end
    return nil
end

local function doReload()
    local tool = getLocalTool()
    if not tool then return false end
    pcall(function() tool:Activate() end)
    for _, r in ipairs(tool:GetDescendants()) do
        if r:IsA("RemoteEvent") then
            local n = string.lower(r.Name)
            if string.find(n, "reload") or string.find(n, "recharge") then
                pcall(function() r:FireServer() end)
            end
        end
    end
    return true
end

local function processAutoReload()
    if not S.autoReload then return end
    local tool = getLocalTool()
    if not tool then return end
    local ammoVal = findAmmoValue(tool)
    if not ammoVal then return end
    local shouldReload = false
    if S.autoReloadMode == "Smart" then shouldReload = ammoVal.Value <= S.autoReloadThreshold
    elseif S.autoReloadMode == "Always" then shouldReload = true
    elseif S.autoReloadMode == "Manual-Key" then
        shouldReload = UserInputService:IsKeyDown(Enum.KeyCode[S.autoReloadKeybind]) and ammoVal.Value < 999
    end
    if shouldReload then
        local now = tick()
        if now - RT.lastReloadTime >= S.autoReloadDelay then
            RT.lastReloadTime = now
            doReload()
        end
    end
end

-- No Task Scheduler
local originalTaskWait, originalWait
local function installTaskSchedulerHook()
    if RT.taskSchedulerInstalled then return end
    RT.taskSchedulerInstalled = true
    originalTaskWait, originalWait = task.wait, wait
    pcall(function()
        task.wait = newcclosure(function(t)
            if not S.noTaskSchedule then return originalTaskWait(t) end
            local maxW = S.noTaskMaxWait / 1000
            if t == nil or t > maxW then t = maxW end
            return originalTaskWait(t)
        end)
        wait = function(t)
            if not S.noTaskSchedule then return originalWait(t) end
            local maxW = S.noTaskMaxWait / 1000
            if t == nil or t > maxW then t = maxW end
            return originalWait(t)
        end
    end)
    if S.noTaskBoostPriority then
        pcall(function() if setthreadidentity then setthreadidentity(8) end end)
    end
end

local function uninstallTaskSchedulerHook()
    if not RT.taskSchedulerInstalled then return end
    pcall(function()
        if originalTaskWait then task.wait = originalTaskWait end
        if originalWait then wait = originalWait end
    end)
    RT.taskSchedulerInstalled = false
end

-- ═══════════════════════════════════════════════════════════════════════════
--  §15  MOD SKIN
-- ═══════════════════════════════════════════════════════════════════════════
local function findWrap(tool)
    if not tool then return nil end
    return tool:FindFirstChild("Wrap") or tool:FindFirstChild("Skin")
        or tool:FindFirstChild("WeaponSkin") or tool:FindFirstChild("Camo")
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
end

local function processModSkin()
    if not S.skinWeaponEnabled and not S.skinBodyColorEnabled then return end
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
end

-- ═══════════════════════════════════════════════════════════════════════════
--  §16  ESP MODULE
-- ═══════════════════════════════════════════════════════════════════════════
local function destroyESP(plr)
    local d = RT.espData[plr]; if not d then return end
    for _, c in ipairs(d.conns) do pcall(function() c:Disconnect() end) end
    if d.billboard then d.billboard:Destroy() end
    if d.tracer then d.tracer:Destroy() end
    if d.skelFolder then d.skelFolder:Destroy() end
    if d.chams then d.chams:Destroy() end
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
    hl.Adornee, hl.Parent = char, char
    return hl
end

local function refreshESPColor()
    for _, d in pairs(RT.espData) do
        if d.boxStroke then d.boxStroke.Color = S.espColor end
        if d.cornerFrames then
            for _, f in ipairs(d.cornerFrames) do f.BackgroundColor3 = S.espColor end
        end
        if d.tracer then d.tracer.BackgroundColor3 = S.espColor end
        if d.bones then for _, b in ipairs(d.bones) do b.line.BackgroundColor3 = S.espColor end end
        if d.chams then
            pcall(function()
                d.chams.FillColor = S.espChamsFillColor
                d.chams.OutlineColor = S.espChamsOutlineColor
            end)
        end
    end
end

local function createESP(plr)
    if plr == LP then return end
    destroyESP(plr)
    local d = {conns = {}, bones = {}, cornerFrames = {}}
    RT.espData[plr] = d

    local tracer = Instance.new("Frame", TracerGui)
    tracer.BackgroundColor3, tracer.BorderSizePixel = S.espColor, 0
    tracer.AnchorPoint, tracer.Visible, tracer.ZIndex = Vector2.new(0,0.5), false, 2
    d.tracer = tracer

    local function setup(char)
        task.spawn(function()
            local hrp = char:WaitForChild("HumanoidRootPart", 5)
            local hum = char:WaitForChild("Humanoid", 5)
            if not hrp or not hum then return end

            local bb = Instance.new("BillboardGui")
            bb.Name, bb.AlwaysOnTop = "TiosESP", true
            bb.Size, bb.Adornee, bb.Parent = UDim2.new(4.5,0,5.8,0), hrp, hrp
            d.billboard = bb

            if S.espBoxStyle == "Corner" then
                for i = 1, 8 do
                    local c = Instance.new("Frame", bb)
                    c.BackgroundColor3, c.BorderSizePixel, c.ZIndex = S.espColor, 0, 2
                    d.cornerFrames[i] = c
                end
            else
                local box = Instance.new("Frame", bb)
                box.Size, box.BackgroundTransparency, box.Visible = UDim2.new(1,0,1,0), 1, S.espBox
                local stroke = Instance.new("UIStroke", box)
                stroke.Color, stroke.Thickness = S.espColor, S.espBoxThickness
                d.box, d.boxStroke = box, stroke
            end

            local nameLbl = Instance.new("TextLabel", bb)
            nameLbl.Size, nameLbl.Position = UDim2.new(1,60,0,16), UDim2.new(-0.2,0,-0.2,0)
            nameLbl.BackgroundTransparency, nameLbl.TextColor3 = 1, Color3.new(1,1,1)
            nameLbl.Font, nameLbl.TextSize = Enum.Font.GothamBold, S.espNameSize
            nameLbl.TextStrokeTransparency, nameLbl.ZIndex = 0, 3
            d.nameLbl = nameLbl

            local hpBg = Instance.new("Frame", bb)
            hpBg.Size, hpBg.Position = UDim2.new(0.06,0,1,0), UDim2.new(-0.12,0,0,0)
            hpBg.BackgroundColor3, hpBg.BorderSizePixel, hpBg.ZIndex = Color3.fromRGB(20,20,20), 0, 2
            local hpFill = Instance.new("Frame", hpBg)
            hpFill.BorderSizePixel, hpFill.ZIndex = 0, 2
            d.hpBg, d.hpFill = hpBg, hpFill

            local sf = Instance.new("Folder", TracerGui)
            sf.Name = "TiosSkeleton"
            d.skelFolder = sf
            local bones = char:FindFirstChild("UpperTorso") and R15_BONES or R6_BONES
            for i, pair in ipairs(bones) do
                local ln = Instance.new("Frame", sf)
                ln.BackgroundColor3, ln.BorderSizePixel = S.espColor, 0
                ln.AnchorPoint, ln.Visible, ln.ZIndex = Vector2.new(0,0.5), false, 1
                d.bones[i] = {line=ln, partA=char:FindFirstChild(pair[1]), partB=char:FindFirstChild(pair[2])}
            end

            d.chams = applyChams(char)

            local function updHp()
                if not hum.Parent then return end
                local r = math.clamp(hum.Health / math.max(hum.MaxHealth,1), 0, 1)
                if d.hpFill then
                    d.hpFill.Size = UDim2.new(1,0,r,0)
                    d.hpFill.Position = UDim2.new(0,0,1-r,0)
                    d.hpFill.BackgroundColor3 = r > 0.5 and Color3.fromRGB(80,220,130)
                        or r > 0.2 and Color3.fromRGB(255,200,100) or Color3.fromRGB(240,80,80)
                end
                if d.nameLbl then
                    d.nameLbl.Text = string.format("%s [%d/%d]", plr.DisplayName,
                        math.floor(hum.Health), math.floor(hum.MaxHealth))
                end
            end
            updHp()
            table.insert(d.conns, hum.HealthChanged:Connect(updHp))

            local function clean()
                if d.billboard then d.billboard:Destroy(); d.billboard = nil end
                if d.skelFolder then d.skelFolder:Destroy(); d.skelFolder = nil end
                if d.tracer then d.tracer.Visible = false end
                if d.chams then d.chams:Destroy(); d.chams = nil end
            end
            table.insert(d.conns, char.Destroying:Connect(clean))
            table.insert(d.conns, hum.Died:Connect(clean))
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

-- ═══════════════════════════════════════════════════════════════════════════
--  §17  ESP VISUALS
-- ═══════════════════════════════════════════════════════════════════════════
local function updateESPVisuals()
    local vp = Camera.ViewportSize
    local bx, by = vp.X/2, vp.Y
    local camPos, lookVec = Camera.CFrame.Position, Camera.CFrame.LookVector
    local myRoot = getLocalRoot()

    if S.espRainbow then
        RT.espRainbowHue = (RT.espRainbowHue + 0.005 * S.espRainbowSpeed) % 1
        local c = Color3.fromHSV(RT.espRainbowHue, 1, 1)
        S.espColor = c
        for _, d in pairs(RT.espData) do
            if d.boxStroke then d.boxStroke.Color = c end
            if d.cornerFrames then for _, f in ipairs(d.cornerFrames) do f.BackgroundColor3 = c end end
            if d.tracer then d.tracer.BackgroundColor3 = c end
            if d.bones then for _, b in ipairs(d.bones) do b.line.BackgroundColor3 = c end end
        end
    end

    RT.espSkipToggle = not RT.espSkipToggle
    local counter = 0

    for plr, d in pairs(RT.espData) do
        counter = counter + 1
        if (counter % 2 == 0) == RT.espSkipToggle then
            local char = plr.Character
            if not isAlive(char) then
                if d.tracer then d.tracer.Visible = false end
                for _, b in ipairs(d.bones) do if b.line.Visible then b.line.Visible = false end end
                if d.cornerFrames then for _, f in ipairs(d.cornerFrames) do if f.Visible then f.Visible = false end end end
            else
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local visible, dist = true, 0
                if hrp and myRoot then
                    dist = (hrp.Position - myRoot.Position).Magnitude
                    if dist > S.espMaxDistance then visible = false end
                end
                local alpha = 1
                if S.espDistanceFade and dist > 0 then
                    alpha = 1 - math.clamp((dist - S.espFadeNear) / (S.espFadeFar - S.espFadeNear), 0, 1)
                end
                local ec = S.espColor
                if S.espTeamCheck and plr.Team and LP.Team and plr.Team == LP.Team then ec = S.espTeamColor end

                if visible then
                    if S.espBox and S.espBoxStyle == "Corner" and d.cornerFrames then
                        local head = char:FindFirstChild("Head")
                        if head and hrp then
                            local tPos, tOn = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,0.5,0))
                            local bPos, bOn = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0,3,0))
                            if tOn and bOn and tPos.Z > 0 and bPos.Z > 0 then
                                local x1, y1, x2, y2 = tPos.X, tPos.Y, bPos.X, bPos.Y
                                local w, h = math.abs(x2-x1), math.abs(y2-y1)
                                local cl = math.min(w, h) * 0.3
                                local th = S.espBoxThickness
                                local p = {
                                    {x1, y1, cl, th}, {x1, y1, th, cl},
                                    {x2-cl, y1, cl, th}, {x2-th, y1, th, cl},
                                    {x1, y2-th, cl, th}, {x1, y2-cl, th, cl},
                                    {x2-cl, y2-th, cl, th}, {x2-th, y2-cl, th, cl},
                                }
                                for i, pos in ipairs(p) do
                                    local f = d.cornerFrames[i]
                                    if f then
                                        f.Visible = true
                                        f.Position = UDim2.new(0, pos[1], 0, pos[2])
                                        f.Size = UDim2.new(0, pos[3], 0, pos[4])
                                        f.BackgroundColor3 = ec
                                        f.BackgroundTransparency = 1 - alpha
                                    end
                                end
                            else
                                for _, f in ipairs(d.cornerFrames) do f.Visible = false end
                            end
                        end
                    end

                    if S.espSkeleton then
                        for _, b in ipairs(d.bones) do
                            local pA, pB = b.partA, b.partB
                            if pA and pB and pA.Parent and pB.Parent then
                                local sA, oA = Camera:WorldToViewportPoint(pA.Position)
                                local sB, oB = Camera:WorldToViewportPoint(pB.Position)
                                if oA and oB and sA.Z > 0 and sB.Z > 0 then
                                    local dx, dy = sB.X-sA.X, sB.Y-sA.Y
                                    local len = math.sqrt(dx*dx+dy*dy)
                                    if len > 0.5 then
                                        b.line.Visible = true
                                        b.line.Size = UDim2.new(0, len, 0, S.espSkeletonThickness)
                                        b.line.Position = UDim2.new(0, sA.X, 0, sA.Y)
                                        b.line.Rotation = math.deg(math.atan2(dy, dx))
                                        b.line.BackgroundColor3 = ec
                                        b.line.BackgroundTransparency = 1 - alpha
                                    elseif b.line.Visible then b.line.Visible = false end
                                elseif b.line.Visible then b.line.Visible = false end
                            elseif b.line.Visible then b.line.Visible = false end
                        end
                    elseif d.bones[1] and d.bones[1].line.Visible then
                        for _, b in ipairs(d.bones) do b.line.Visible = false end
                    end

                    if S.espTracer and d.tracer then
                        local head = char:FindFirstChild("Head")
                        if head then
                            local toT = head.Position - camPos
                            local d3 = toT.Magnitude
                            local dot = lookVec:Dot(toT / math.max(d3, 0.001))
                            if dot > 0.1 then
                                local sp, on = Camera:WorldToViewportPoint(head.Position)
                                if on and sp.Z > 0 then
                                    local ox, oy
                                    if S.espTracerOrigin == "Bottom" then ox, oy = bx, by
                                    elseif S.espTracerOrigin == "Center" then ox, oy = bx, vp.Y/2
                                    else
                                        local m = UserInputService:GetMouseLocation()
                                        ox, oy = m.X, m.Y
                                    end
                                    local dx, dy = sp.X-ox, sp.Y-oy
                                    local len = math.sqrt(dx*dx+dy*dy)
                                    if len > 20 then
                                        d.tracer.Visible = true
                                        d.tracer.Position = UDim2.new(0, ox, 0, oy)
                                        d.tracer.Size = UDim2.new(0, len, 0, S.espTracerThickness)
                                        d.tracer.Rotation = math.deg(math.atan2(dy, dx))
                                        d.tracer.BackgroundColor3 = ec
                                        d.tracer.BackgroundTransparency = 1 - alpha
                                    elseif d.tracer.Visible then d.tracer.Visible = false end
                                elseif d.tracer.Visible then d.tracer.Visible = false end
                            elseif d.tracer.Visible then d.tracer.Visible = false end
                        end
                    elseif d.tracer and d.tracer.Visible then
                        d.tracer.Visible = false
                    end
                else
                    if d.tracer then d.tracer.Visible = false end
                    for _, b in ipairs(d.bones) do if b.line.Visible then b.line.Visible = false end end
                    if d.cornerFrames then for _, f in ipairs(d.cornerFrames) do if f.Visible then f.Visible = false end end end
                end
            end
        end
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
--  §18  CUSTOM CURSOR
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
    local c = Instance.new("UICorner", f)
    c.CornerRadius = UDim.new(0, math.min(size.X, size.Y) / 2)
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
    elseif S.cursorStyle == "Ring" then
        local r = newCursorPart(Vector2.new(sz, sz), Vector2.new(0,0))
        r.BackgroundTransparency = 1
        r:FindFirstChildOfClass("UIStroke").Thickness = th
        for i = 0, 3 do
            local a = math.rad(i*90)
            newCursorPart(Vector2.new(th+2, th+2), Vector2.new(math.cos(a)*(sz/2), math.sin(a)*(sz/2)))
        end
    elseif S.cursorStyle == "X" then
        local a = newCursorPart(Vector2.new(th, sz), Vector2.new(0,0)); a.Rotation = 45
        local b = newCursorPart(Vector2.new(th, sz), Vector2.new(0,0)); b.Rotation = -45
    elseif S.cursorStyle == "Chevron" then
        local p = {
            {x=0, y=-(gap+len/2), rot=0}, {x=0, y=gap+len/2, rot=180},
            {x=-(gap+len/2), y=0, rot=90}, {x=gap+len/2, y=0, rot=-90},
        }
        for _, pos in ipairs(p) do
            local f = newCursorPart(Vector2.new(th, len), Vector2.new(pos.x, pos.y))
            f.Rotation = pos.rot
        end
    elseif S.cursorStyle == "Arrow" then
        newCursorPart(Vector2.new(th, sz), Vector2.new(0, -gap))
    elseif S.cursorStyle == "Star" then
        for i = 0, 5 do
            local a = math.rad(i*60)
            local f = newCursorPart(Vector2.new(th, len), Vector2.new(math.cos(a)*(gap+len/2), math.sin(a)*(gap+len/2)))
            f.Rotation = i*60 + 90
        end
    end
    if S.cursorCenterDot then
        newCursorPart(Vector2.new(th*1.5, th*1.5), Vector2.new(0,0))
    end
end

local function updateCursorColor(color)
    for _, p in ipairs(RT.cursorParts) do
        pcall(function()
            p.BackgroundColor3 = color
            local s = p:FindFirstChildOfClass("UIStroke")
            if s then s.Color = S.cursorOutlineColor end
        end)
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
        updateCursorColor(Color3.fromHSV(RT.cursorHue, 0.85, 1))
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
--  §19  UI SYSTEM (CLEAN · UE-STYLE HORIZONTAL)
-- ═══════════════════════════════════════════════════════════════════════════

-- ─── COLOR PALETTE ───
local C = {
    bgDeep      = Color3.fromRGB(8, 10, 20),
    bgDark      = Color3.fromRGB(12, 16, 30),
    bgPanel     = Color3.fromRGB(16, 22, 42),
    bgPanel2    = Color3.fromRGB(22, 30, 55),
    bgInput     = Color3.fromRGB(28, 38, 68),
    bgHover     = Color3.fromRGB(38, 52, 88),
    accent      = Color3.fromRGB(95, 155, 255),
    accentSoft  = Color3.fromRGB(140, 190, 255),
    accentDim   = Color3.fromRGB(50, 90, 160),
    accentGlow  = Color3.fromRGB(120, 180, 255),
    text        = Color3.fromRGB(235, 240, 255),
    textDim     = Color3.fromRGB(160, 175, 205),
    textMuted   = Color3.fromRGB(105, 120, 150),
    border      = Color3.fromRGB(55, 75, 120),
    borderSoft  = Color3.fromRGB(70, 95, 150),
    green       = Color3.fromRGB(90, 230, 160),
    yellow      = Color3.fromRGB(255, 205, 120),
    red         = Color3.fromRGB(250, 100, 120),
    cyan        = Color3.fromRGB(110, 220, 255),
    white       = Color3.fromRGB(255, 255, 255),
}

local FONTS = {
    medium = Enum.Font.GothamMedium,
    bold   = Enum.Font.GothamBold,
    black  = Enum.Font.GothamBlack,
    light  = Enum.Font.Gotham,
}
local FONTFACE_CACHE = {}
pcall(function()
    local FAMILY = "rbxasset://fonts/families/GothamSSm.json"
    FONTFACE_CACHE = {
        medium = Font.new(FAMILY, Enum.FontWeight.Medium,   Enum.FontStyle.Normal),
        bold   = Font.new(FAMILY, Enum.FontWeight.Bold,     Enum.FontStyle.Normal),
        black  = Font.new(FAMILY, Enum.FontWeight.Black,    Enum.FontStyle.Normal),
        light  = Font.new(FAMILY, Enum.FontWeight.Regular,  Enum.FontStyle.Normal),
    }
end)

local function applyFont(lbl, weight)
    weight = weight or "medium"
    if FONTFACE_CACHE[weight] then
        pcall(function() lbl.FontFace = FONTFACE_CACHE[weight] end)
    else
        lbl.Font = FONTS[weight] or FONTS.medium
    end
end

local function corner(o, r)
    local c = Instance.new("UICorner", o)
    c.CornerRadius = UDim.new(0, r or 10)
    return c
end

local function outline(o, col, th, tr)
    local s = Instance.new("UIStroke", o)
    s.Color = col or C.border
    s.Thickness = th or 1
    s.Transparency = tr or 0.5
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
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

-- ─── BACKGROUND ───
local bgFrame = Instance.new("Frame", BgGui)
bgFrame.Size = UDim2.new(1, 0, 1, 0)
bgFrame.BorderSizePixel = 0

local bgGrad = Instance.new("UIGradient", bgFrame)
bgGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(5, 7, 18)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(24, 34, 72)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(3, 5, 14)),
})
bgGrad.Rotation = 25

task.spawn(function()
    while bgFrame.Parent do
        TweenService:Create(bgGrad, TweenInfo.new(25, Enum.EasingStyle.Linear), {Rotation = 385}):Play()
        task.wait(25)
        bgGrad.Rotation = 25
    end
end)

local snowContainer = Instance.new("Frame", BgGui)
snowContainer.Size = UDim2.new(1, 0, 1, 0)
snowContainer.BackgroundTransparency = 1
snowContainer.ClipsDescendants = true

local function spawnSnow()
    local flake = Instance.new("Frame", snowContainer)
    local s = math.random(2, 5)
    flake.Size = UDim2.new(0, s, 0, s)
    flake.Position = UDim2.new(math.random(), 0, -0.05, 0)
    flake.BackgroundColor3 = Color3.fromRGB(210, 225, 255)
    flake.BackgroundTransparency = 0.55 + math.random()*0.3
    flake.BorderSizePixel = 0
    corner(flake, 999)
    local dur = 9 + math.random()*10
    local drift = (math.random()-0.5) * 0.14
    TweenService:Create(flake, TweenInfo.new(dur, Enum.EasingStyle.Linear), {
        Position = UDim2.new(flake.Position.X.Scale + drift, 0, 1.05, 0),
        BackgroundTransparency = 0.92,
    }):Play()
    task.delay(dur + 0.5, function() if flake then flake:Destroy() end end)
end

for _ = 1, 60 do
    task.spawn(function()
        task.wait(math.random() * 6)
        while snowContainer.Parent do
            spawnSnow()
            task.wait(math.random(4, 11))
        end
    end)
end

-- ─── TOGGLE ICON ───
local Icon = Instance.new("TextButton", ScreenGui)
Icon.Size, Icon.Position = UDim2.new(0, 58, 0, 58), UDim2.new(0.02, 0, 0.3, 0)
Icon.BackgroundColor3 = C.accent
Icon.TextColor3 = C.bgDeep
Icon.Text, Icon.TextSize = "T", 26
Icon.Active, Icon.AutoButtonColor = true, false
applyFont(Icon, "black")
corner(Icon, 29)
local iconGlow = outline(Icon, C.accentGlow, 2.5, 0.2)
draggable(Icon)
hover(Icon, C.accent, C.accentSoft)

task.spawn(function()
    while Icon.Parent do
        TweenService:Create(iconGlow, TweenInfo.new(1.8, Enum.EasingStyle.Sine), {Transparency = 0.75}):Play()
        task.wait(1.8)
        TweenService:Create(iconGlow, TweenInfo.new(1.8, Enum.EasingStyle.Sine), {Transparency = 0.2}):Play()
        task.wait(1.8)
    end
end)

-- ─── MAIN WINDOW ───
local Main = Instance.new("Frame", ScreenGui)
Main.Size, Main.Position = UDim2.new(0, 360, 0, 540), UDim2.new(0.15, 0, 0.12, 0)
Main.BackgroundColor3 = C.bgDark
Main.BackgroundTransparency = 0.08
Main.BorderSizePixel, Main.Active, Main.Visible = 0, true, false
corner(Main, 20)
outline(Main, C.borderSoft, 1.2, 0.3)
draggable(Main)

local topLine = Instance.new("Frame", Main)
topLine.Size, topLine.BackgroundColor3 = UDim2.new(1, 0, 0, 1), C.accent
topLine.BackgroundTransparency, topLine.BorderSizePixel = 0.5, 0

-- ─── HEADER ───
local Header = Instance.new("Frame", Main)
Header.Size, Header.BackgroundTransparency = UDim2.new(1, 0, 0, 44), 1

local BrandDot = Instance.new("Frame", Header)
BrandDot.Size, BrandDot.Position = UDim2.new(0, 8, 0, 8), UDim2.new(0, 18, 0, 0.5, -4)
BrandDot.AnchorPoint = Vector2.new(0, 0.5)
BrandDot.BackgroundColor3, BrandDot.BorderSizePixel = C.accent, 0
corner(BrandDot, 4)
local brandGlow = outline(BrandDot, C.accentGlow, 2, 0.3)

local Title = Instance.new("TextLabel", Header)
Title.Size, Title.Position = UDim2.new(0.4, 0, 1, 0), UDim2.new(0, 34, 0, 0)
Title.BackgroundTransparency, Title.Text = 1, "TIOSHUB"
Title.TextColor3, Title.TextSize = C.text, 15
Title.TextXAlignment = Enum.TextXAlignment.Left
applyFont(Title, "black")

local SubTitle = Instance.new("TextLabel", Header)
SubTitle.Size, SubTitle.Position = UDim2.new(0, 50, 1, 0), UDim2.new(0.38, 0, 0, 0)
SubTitle.BackgroundTransparency, SubTitle.Text = 1, "v3.2"
SubTitle.TextColor3, SubTitle.TextSize = C.textMuted, 9
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
applyFont(SubTitle, "bold")

local StatusDot = Instance.new("Frame", Header)
StatusDot.Size, StatusDot.Position = UDim2.new(0, 6, 0, 6), UDim2.new(0.47, 0, 0.5, -3)
StatusDot.AnchorPoint = Vector2.new(0, 0.5)
StatusDot.BackgroundColor3, StatusDot.BorderSizePixel = C.green, 0
corner(StatusDot, 3)

local StatusLbl = Instance.new("TextLabel", Header)
StatusLbl.Size, StatusLbl.Position = UDim2.new(0, 55, 1, 0), UDim2.new(0.49, 0, 0, 0)
StatusLbl.BackgroundTransparency, StatusLbl.Text = 1, "READY"
StatusLbl.TextColor3, StatusLbl.TextSize = C.green, 8
StatusLbl.TextXAlignment = Enum.TextXAlignment.Left
applyFont(StatusLbl, "bold")

local function headerBtn(txt, xPos, txtColor, normal, hoverCol)
    local b = Instance.new("TextButton", Header)
    b.Size, b.Position = UDim2.new(0, 26, 0, 26), UDim2.new(xPos, 0, 0.5, -13)
    b.BackgroundColor3, b.BackgroundTransparency = normal, 0.5
    b.TextColor3, b.Text, b.TextSize = txtColor, txt, 13
    b.AutoButtonColor = false
    applyFont(b, "bold")
    corner(b, 7)
    hover(b, normal, hoverCol)
    return b
end
local CloseBtn = headerBtn("✕", 0.92, C.red, Color3.fromRGB(70, 30, 42), Color3.fromRGB(100, 42, 58))
local MinBtn   = headerBtn("—", 0.85, C.textDim, Color3.fromRGB(36, 42, 62), Color3.fromRGB(52, 60, 88))

-- ─── SEARCH ───
local SearchBox = Instance.new("Frame", Main)
SearchBox.Size, SearchBox.Position = UDim2.new(1, -16, 0, 30), UDim2.new(0, 8, 0, 90)
SearchBox.BackgroundColor3, SearchBox.BackgroundTransparency = C.bgInput, 0.15
SearchBox.BorderSizePixel = 0
corner(SearchBox, 8)
outline(SearchBox, C.border, 1, 0.6)

local SearchIcon = Instance.new("TextLabel", SearchBox)
SearchIcon.Size, SearchIcon.BackgroundTransparency = UDim2.new(0, 30, 1, 0), 1
SearchIcon.Text, SearchIcon.TextSize = "⌕", 15
SearchIcon.TextColor3 = C.textDim
applyFont(SearchIcon, "bold")

local SearchInput = Instance.new("TextBox", SearchBox)
SearchInput.Size, SearchInput.Position = UDim2.new(1, -36, 1, 0), UDim2.new(0, 34, 0, 0)
SearchInput.BackgroundTransparency, SearchInput.Text = 1, ""
SearchInput.PlaceholderText, SearchInput.PlaceholderColor3 = "Search...", C.textMuted
SearchInput.TextColor3, SearchInput.TextSize = C.text, 10
SearchInput.TextXAlignment = Enum.TextXAlignment.Left
applyFont(SearchInput, "medium")

-- ─── TAB BAR ───
local TabBar = Instance.new("Frame", Main)
TabBar.Size, TabBar.Position = UDim2.new(1, -16, 0, 36), UDim2.new(0, 8, 0, 128)
TabBar.BackgroundTransparency = 1

local TabLayout = Instance.new("UIListLayout", TabBar)
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Padding = UDim.new(0, 4)
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center

-- ─── CONTENT AREA ───
local ContentArea = Instance.new("Frame", Main)
ContentArea.Size, ContentArea.Position = UDim2.new(1, -16, 1, -172), UDim2.new(0, 8, 0, 172)
ContentArea.BackgroundTransparency = 1

-- ─── TAB SYSTEM ───
local Tab = {
    buttons  = {},
    content  = {},
    active   = nil,
    rows     = {},
}
local searchQuery = ""

local function applySearch()
    for row, data in pairs(Tab.rows) do
        if searchQuery == "" then
            row.Visible = true
        else
            row.Visible = string.find(data.text, searchQuery, 1, true) ~= nil
        end
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
    local btn = Instance.new("TextButton", TabBar)
    btn.Size, btn.BackgroundColor3, btn.BackgroundTransparency = UDim2.new(0, 0, 1, 0), C.bgPanel, 0.4
    btn.AutomaticSize = Enum.AutomaticSize.X
    btn.Text, btn.AutoButtonColor, btn.BorderSizePixel = "", false, 0
    corner(btn, 8)

    local pad = Instance.new("UIPadding", btn)
    pad.PaddingLeft, pad.PaddingRight = UDim.new(0, 10), UDim.new(0, 10)

    local lbl = Instance.new("TextLabel", btn)
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = icon .. " " .. label
    lbl.TextColor3, lbl.TextSize = C.textDim, 10
    applyFont(lbl, "bold")

    local function setActive(on)
        if on then
            btn.BackgroundColor3, btn.BackgroundTransparency = C.accent, 0
            lbl.TextColor3 = C.bgDeep
        else
            btn.BackgroundColor3, btn.BackgroundTransparency = C.bgPanel, 0.4
            lbl.TextColor3 = C.textDim
        end
    end

    btn.MouseEnter:Connect(function()
        if Tab.active ~= id then
            btn.BackgroundColor3 = C.bgPanel2
            lbl.TextColor3 = C.text
        end
    end)
    btn.MouseLeave:Connect(function()
        if Tab.active ~= id then
            btn.BackgroundColor3 = C.bgPanel
            lbl.TextColor3 = C.textDim
        end
    end)
    btn.MouseButton1Click:Connect(function() switchTab(id) end)

    Tab.buttons[id] = { button = btn, setActive = setActive }

    local scroll = Instance.new("ScrollingFrame", ContentArea)
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency, scroll.BorderSizePixel = 1, 0
    scroll.ScrollBarThickness, scroll.ScrollBarImageColor3 = 3, C.accent
    scroll.ScrollBarImageTransparency = 0.3
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.Visible = false

    local layout = Instance.new("UIListLayout", scroll)
    layout.SortOrder, layout.Padding = Enum.SortOrder.LayoutOrder, UDim.new(0, 5)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local padding = Instance.new("UIPadding", scroll)
    padding.PaddingTop, padding.PaddingBottom = UDim.new(0, 8), UDim.new(0, 16)

    Tab.content[id] = scroll
    return scroll
end

-- ─── WIDGETS ───
local function addSection(parent, text)
    local w = Instance.new("Frame", parent)
    w.Size, w.BackgroundTransparency = UDim2.new(0.97, 0, 0, 26), 1

    local acc = Instance.new("Frame", w)
    acc.Size, acc.Position = UDim2.new(0, 2, 0, 10), UDim2.new(0, 6, 0.5, -5)
    acc.BackgroundColor3, acc.BorderSizePixel = C.accent, 0
    corner(acc, 2)

    local l = Instance.new("TextLabel", w)
    l.Size, l.Position = UDim2.new(1, -20, 1, 0), UDim2.new(0, 18, 0, 0)
    l.BackgroundTransparency, l.Text = 1, string.upper(text)
    l.TextColor3, l.TextSize = C.accentSoft, 10
    l.TextXAlignment = Enum.TextXAlignment.Left
    applyFont(l, "black")

    registerRow(w, "section " .. text)
end

local function addToggle(parent, text, cb)
    local card = Instance.new("TextButton", parent)
    card.Size = UDim2.new(0.97, 0, 0, 36)
    card.BackgroundColor3, card.BackgroundTransparency = C.bgPanel, 0.2
    card.Text, card.AutoButtonColor, card.BorderSizePixel = "", false, 0
    corner(card, 10)
    outline(card, C.border, 1, 0.75)

    local lbl = Instance.new("TextLabel", card)
    lbl.Size, lbl.Position = UDim2.new(1, -70, 1, 0), UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency, lbl.Text = 1, text
    lbl.TextColor3, lbl.TextSize = C.text, 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    applyFont(lbl, "medium")

    local track = Instance.new("Frame", card)
    track.Size, track.Position = UDim2.new(0, 38, 0, 20), UDim2.new(1, -52, 0.5, -10)
    track.BackgroundColor3, track.BorderSizePixel = Color3.fromRGB(42, 52, 78), 0
    corner(track, 10)
    local trackStroke = outline(track, C.border, 1, 0.5)

    local thumb = Instance.new("Frame", track)
    thumb.Size, thumb.Position = UDim2.new(0, 16, 0, 16), UDim2.new(0, 2, 0.5, -8)
    thumb.BackgroundColor3, thumb.BorderSizePixel = C.textMuted, 0
    corner(thumb, 8)

    local state = false
    card.MouseEnter:Connect(function() card.BackgroundColor3 = C.bgPanel2 end)
    card.MouseLeave:Connect(function() card.BackgroundColor3 = C.bgPanel end)
    card.MouseButton1Click:Connect(function()
        state = not state
        if state then
            track.BackgroundColor3 = C.accent
            trackStroke.Color = C.accentGlow
            thumb.BackgroundColor3 = C.white
            TweenService:Create(thumb, TweenInfo.new(0.22, Enum.EasingStyle.Quint), {Position = UDim2.new(1, -18, 0.5, -8)}):Play()
        else
            track.BackgroundColor3 = Color3.fromRGB(42, 52, 78)
            trackStroke.Color = C.border
            thumb.BackgroundColor3 = C.textMuted
            TweenService:Create(thumb, TweenInfo.new(0.22, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 2, 0.5, -8)}):Play()
        end
        cb(state)
        queueSave()
    end)

    registerRow(card, "toggle " .. text)
end

local function addSlider(parent, name, def, mn, mx, cb)
    local card = Instance.new("Frame", parent)
    card.Size = UDim2.new(0.97, 0, 0, 54)
    card.BackgroundColor3, card.BackgroundTransparency = C.bgPanel, 0.2
    card.BorderSizePixel = 0
    corner(card, 10)
    outline(card, C.border, 1, 0.75)

    local lbl = Instance.new("TextLabel", card)
    lbl.Size, lbl.Position = UDim2.new(1, -90, 0, 22), UDim2.new(0, 14, 0, 5)
    lbl.BackgroundTransparency, lbl.Text = 1, name
    lbl.TextColor3, lbl.TextSize = C.text, 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    applyFont(lbl, "medium")

    local valLbl = Instance.new("TextLabel", card)
    valLbl.Size, valLbl.Position = UDim2.new(0, 70, 0, 22), UDim2.new(1, -84, 0, 5)
    valLbl.BackgroundTransparency, valLbl.Text = 1, tostring(def)
    valLbl.TextColor3, valLbl.TextSize = C.accentSoft, 12
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    applyFont(valLbl, "bold")

    local steps, si, step = { 1, 2, 5, 10 }, 1, 1
    local stepBtn = Instance.new("TextButton", card)
    stepBtn.Size, stepBtn.Position = UDim2.new(0, 44, 0, 20), UDim2.new(0, 14, 0, 29)
    stepBtn.BackgroundColor3, stepBtn.BackgroundTransparency = C.bgInput, 0.15
    stepBtn.TextColor3, stepBtn.Text = C.textMuted, "±" .. step
    stepBtn.TextSize, stepBtn.AutoButtonColor = 9, false
    applyFont(stepBtn, "bold")
    corner(stepBtn, 6)
    hover(stepBtn, C.bgInput, C.bgHover)
    stepBtn.MouseButton1Click:Connect(function()
        si = si + 1
        if si > #steps then si = 1 end
        step = steps[si]
        stepBtn.Text = "±" .. step
    end)

    local sub = Instance.new("TextButton", card)
    sub.Size, sub.Position = UDim2.new(0, 44, 0, 20), UDim2.new(0.5, -49, 0, 29)
    sub.BackgroundColor3, sub.BackgroundTransparency = C.bgInput, 0.15
    sub.TextColor3, sub.Text, sub.TextSize = C.red, "−", 14
    sub.AutoButtonColor = false
    applyFont(sub, "black")
    corner(sub, 6)
    hover(sub, C.bgInput, Color3.fromRGB(60, 32, 45))

    local add = Instance.new("TextButton", card)
    add.Size, add.Position = UDim2.new(0, 44, 0, 20), UDim2.new(0.5, 5, 0, 29)
    add.BackgroundColor3, add.BackgroundTransparency = C.bgInput, 0.15
    add.TextColor3, add.Text, add.TextSize = C.green, "+", 14
    add.AutoButtonColor = false
    applyFont(add, "black")
    corner(add, 6)
    hover(add, C.bgInput, Color3.fromRGB(32, 58, 50))

    local val = def
    local function set(v)
        val = v
        valLbl.Text = tostring(v)
        cb(v)
        queueSave()
    end
    sub.MouseButton1Click:Connect(function() set(math.max(mn, val - step)) end)
    add.MouseButton1Click:Connect(function() set(math.min(mx, val + step)) end)

    registerRow(card, "slider " .. name)
end

local function addCycler(parent, name, options, cb)
    local card = Instance.new("TextButton", parent)
    card.Size = UDim2.new(0.97, 0, 0, 36)
    card.BackgroundColor3, card.BackgroundTransparency = C.bgPanel, 0.2
    card.Text, card.AutoButtonColor, card.BorderSizePixel = "", false, 0
    corner(card, 10)
    outline(card, C.border, 1, 0.75)

    local lbl = Instance.new("TextLabel", card)
    lbl.Size, lbl.Position = UDim2.new(0.5, 0, 1, 0), UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency, lbl.Text = 1, name
    lbl.TextColor3, lbl.TextSize = C.text, 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    applyFont(lbl, "medium")

    local valLbl = Instance.new("TextLabel", card)
    valLbl.Size, valLbl.Position = UDim2.new(0.5, -14, 1, 0), UDim2.new(0.5, 0, 0, 0)
    valLbl.BackgroundTransparency, valLbl.Text = 1, options[1]
    valLbl.TextColor3, valLbl.TextSize = C.cyan, 11
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    applyFont(valLbl, "bold")

    card.MouseEnter:Connect(function() card.BackgroundColor3 = C.bgPanel2 end)
    card.MouseLeave:Connect(function() card.BackgroundColor3 = C.bgPanel end)

    local i = 1
    card.MouseButton1Click:Connect(function()
        i = i + 1
        if i > #options then i = 1 end
        valLbl.Text = options[i]
        cb(options[i])
        queueSave()
    end)

    registerRow(card, "cycler " .. name)
end

local function addButton(parent, text, cb, color)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0.97, 0, 0, 32)
    b.BackgroundColor3, b.BackgroundTransparency = color or C.accentDim, 0.15
    b.TextColor3, b.TextSize = C.white, 11
    b.Text, b.AutoButtonColor, b.BorderSizePixel = text, false, 0
    applyFont(b, "bold")
    corner(b, 10)
    outline(b, C.accent, 1, 0.5)
    hover(b, color or C.accentDim, C.accent)
    b.MouseButton1Click:Connect(cb)

    registerRow(b, "button " .. text)
end

-- ─── VISUAL OVERLAYS ───
local FOVFrame = Instance.new("Frame", FOVGui)
FOVFrame.AnchorPoint, FOVFrame.Position = Vector2.new(0.5, 0.5), UDim2.new(0.5, 0, 0.5, 0)
FOVFrame.BackgroundTransparency, FOVFrame.Visible = 1, false
local FOVStroke = Instance.new("UIStroke", FOVFrame)
FOVStroke.Transparency = 0.2
corner(FOVFrame, 999)

local SilentFrame = Instance.new("Frame", SilentFOVGui)
SilentFrame.AnchorPoint, SilentFrame.Position = Vector2.new(0.5, 0.5), UDim2.new(0.5, 0, 0.5, 0)
SilentFrame.BackgroundTransparency, SilentFrame.Visible = 1, false
local SilentStroke = Instance.new("UIStroke", SilentFrame)
SilentStroke.Transparency, SilentStroke.Color = 0.2, C.cyan
corner(SilentFrame, 999)

local legitDot = Instance.new("Frame", ScreenGui)
legitDot.Size, legitDot.BackgroundColor3 = UDim2.new(0, 14, 0, 14), C.green
legitDot.BackgroundTransparency, legitDot.AnchorPoint, legitDot.Visible = 0.3, Vector2.new(0.5, 0.5), false
corner(legitDot, 999)

local Info = Instance.new("Frame", InfoGui)
Info.Size, Info.Position = UDim2.new(0, 230, 0, 115), UDim2.new(0.72, 0, 0.05, 0)
Info.BackgroundColor3, Info.BackgroundTransparency = C.bgPanel, 0.1
Info.BorderSizePixel, Info.Visible, Info.Active = 0, false, true
corner(Info, 14)
outline(Info, C.accent, 1, 0.3)
draggable(Info)

local InfoBar = Instance.new("Frame", Info)
InfoBar.Size, InfoBar.BackgroundColor3 = UDim2.new(1, 0, 0, 28), C.bgPanel2
InfoBar.BackgroundTransparency, InfoBar.BorderSizePixel = 0.1, 0
corner(InfoBar, 14)

local InfoTitle = Instance.new("TextLabel", InfoBar)
InfoTitle.Size, InfoTitle.Position = UDim2.new(1, -10, 1, 0), UDim2.new(0, 14, 0, 0)
InfoTitle.BackgroundTransparency, InfoTitle.Text = 1, "TARGET"
InfoTitle.TextColor3, InfoTitle.TextSize = C.accentSoft, 10
InfoTitle.TextXAlignment = Enum.TextXAlignment.Left
applyFont(InfoTitle, "black")

local InfoName = Instance.new("TextLabel", Info)
InfoName.Size, InfoName.Position = UDim2.new(1, -16, 0, 22), UDim2.new(0, 10, 0, 34)
InfoName.BackgroundTransparency, InfoName.Text = 1, "None"
InfoName.TextColor3, InfoName.TextSize = C.text, 12
InfoName.TextXAlignment = Enum.TextXAlignment.Left
applyFont(InfoName, "bold")

local HpBg = Instance.new("Frame", Info)
HpBg.Size, HpBg.Position = UDim2.new(1, -20, 0, 8), UDim2.new(0, 10, 0, 60)
HpBg.BackgroundColor3, HpBg.BorderSizePixel = Color3.fromRGB(32, 42, 68), 0
corner(HpBg, 4)
local HpFill = Instance.new("Frame", HpBg)
HpFill.Size, HpFill.BackgroundColor3 = UDim2.new(1, 0, 1, 0), C.green
HpFill.BorderSizePixel = 0
corner(HpFill, 4)

local InfoHp = Instance.new("TextLabel", Info)
InfoHp.Size, InfoHp.Position = UDim2.new(1, -20, 0, 16), UDim2.new(0, 10, 0, 72)
InfoHp.BackgroundTransparency, InfoHp.Text = 1, "HP: -- / --"
InfoHp.TextColor3, InfoHp.TextSize = C.textDim, 10
InfoHp.TextXAlignment = Enum.TextXAlignment.Left
applyFont(InfoHp, "medium")

local InfoDist = Instance.new("TextLabel", Info)
InfoDist.Size, InfoDist.Position = UDim2.new(1, -20, 0, 16), UDim2.new(0, 10, 0, 90)
InfoDist.BackgroundTransparency, InfoDist.Text = 1, "Distance: --"
InfoDist.TextColor3, InfoDist.TextSize = C.yellow, 10
InfoDist.TextXAlignment = Enum.TextXAlignment.Left
applyFont(InfoDist, "medium")

local BulletTracer = Instance.new("Frame", BulletGui)
BulletTracer.BackgroundColor3, BulletTracer.BorderSizePixel = C.yellow, 0
BulletTracer.AnchorPoint, BulletTracer.Visible, BulletTracer.ZIndex = Vector2.new(0, 0.5), false, 3

RT.main = Main

-- ═══════════════════════════════════════════════════════════════════════════
--  §20  BUILD TABS
-- ═══════════════════════════════════════════════════════════════════════════
local aimTab    = createTab("aim",    "AIM",    "🎯")
local combatTab = createTab("combat", "COMBAT", "⚔")
local visualTab = createTab("visual", "VISUAL", "👁")
local miscTab   = createTab("misc",   "MISC",   "⚙")
local configTab = createTab("config", "CONFIG", "💾")

-- TAB: AIM
do
    local p = aimTab
    addSection(p, "Ragebot")
    addToggle(p, "Enable Ragebot", function(v)
        S.rage = v
        if v then S.aimbot = false; S.legitCam = false; S.legit = false end
        RT.rageTarget = nil
    end)
    addToggle(p, "Auto Fire", function(v) S.rageAutoFire = v end)
    addToggle(p, "Ignore Wall", function(v) S.rageIgnoreWall = v end)
    addToggle(p, "Instant Lock", function(v) S.rageInstantLock = v end)
    addToggle(p, "Spinbot", function(v) S.rageSpinBot = v end)
    addCycler(p, "Target Part", {"Head", "HumanoidRootPart", "UpperTorso"}, function(o) S.rageTargetPart = o end)
    addSlider(p, "Rage FOV", 360, 100, 500, function(v) S.rageFOV = v end)
    addSlider(p, "Fire Delay (ms)", 50, 10, 500, function(v) S.rageAutoFireDelay = v / 1000 end)

    addSection(p, "Aimbot Camera")
    addToggle(p, "Aimbot Lock", function(v)
        S.aimbot = v
        if v then S.legitCam = false; S.legit = false; S.rage = false end
        if not v then RT.lockedTarget = nil end
    end)
    addToggle(p, "Show FOV", function(v) S.showFOV = v end)
    addToggle(p, "Wall Check", function(v) S.wallCheck = v end)
    addToggle(p, "Team Check", function(v) S.teamCheck = v end)
    addCycler(p, "Aim Part", {"Head", "HumanoidRootPart"}, function(o) S.targetPart = o end)
    addSlider(p, "FOV Size", 150, 30, 600, function(v) S.fovRadius = v end)
    addSlider(p, "Aim Smoothness", 10, 1, 10, function(v) S.smooth = v end)

    addSection(p, "Legit Camera")
    addToggle(p, "Legit Camera Aim", function(v)
        S.legitCam = v
        if v then S.aimbot = false; S.legit = false; S.rage = false end
        RT.lcTarget = nil
    end)
    addCycler(p, "Aim Method", {"Linear", "Curve"}, function(o) S.legitCamAimMethod = o end)
    addSlider(p, "Curve Strength", 65, 0, 100, function(v) S.legitCamCurveStrength = v end)
    addToggle(p, "Require ADS", function(v) S.legitCamRequireADS = v end)
    addToggle(p, "Overshoot", function(v) S.legitCamOvershoot = v end)
    addToggle(p, "Sticky Aim", function(v) S.legitCamStickyAim = v end)
    addCycler(p, "Hitbox", {"Head", "UpperTorso", "HumanoidRootPart"}, function(o) S.legitCamHitbox = o end)
    addSlider(p, "Legit FOV", 60, 20, 200, function(v) S.legitCamFOV = v end)
    addSlider(p, "Reaction Min (ms)", 120, 0, 500, function(v) S.legitCamReaction = v end)
    addSlider(p, "Speed Min (x10)", 35, 10, 100, function(v) S.legitCamSpeedMin = v / 10 end)

    addSection(p, "Legit Silent")
    addToggle(p, "Legit Silent Aim", function(v)
        S.legit = v
        if v then S.aimbot = false; S.legitCam = false end
    end)
    addToggle(p, "Only When Firing", function(v) S.legitOnlyFiring = v end)
    addCycler(p, "Hitbox", {"Head", "HumanoidRootPart", "UpperTorso"}, function(o) S.legitPart = o end)
    addSlider(p, "Pixel Radius", 45, 10, 200, function(v) S.legitRadius = v end)
    addSlider(p, "Hit Chance (%)", 100, 0, 100, function(v) S.legitHitChance = v end)

    addSection(p, "Silent Aim (Large)")
    addToggle(p, "Silent Aim", function(v) S.silent = v end)
    addCycler(p, "Hitbox", {"Head", "HumanoidRootPart", "UpperTorso"}, function(o) S.silentPart = o end)
    addSlider(p, "Silent FOV", 200, 30, 800, function(v) S.silentFOV = v end)
    addSlider(p, "Hit Chance (%)", 100, 0, 100, function(v) S.silentHitChance = v end)
end

-- TAB: COMBAT
do
    local p = combatTab
    addSection(p, "Anti Katana")
    addToggle(p, "Anti Katana", function(v) S.antiKatana = v end)
    addCycler(p, "Mode", {"Bypass", "AutoParry", "Full"}, function(o) S.antiKatanaMode = o end)
    addToggle(p, "Bypass Deflect", function(v) S.antiKatanaBypassDeflect = v end)
    addToggle(p, "Auto Parry", function(v) S.antiKatanaAutoParry = v end)
    addSlider(p, "Parry Range", 15, 5, 50, function(v) S.antiKatanaParryRange = v end)

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
    addCycler(p, "Mode", {"Enabled-Spam", "Cooldown-Zero", "FireRemote-Spam"}, function(o)
        S.rapidMode = o
        if o ~= "Cooldown-Zero" then restoreRapid() end
    end)
    addSlider(p, "Multiplier", 1, 1, 5, function(v) S.rapidMult = v end)

    addSection(p, "Auto Reload")
    addToggle(p, "Auto Reload", function(v) S.autoReload = v end)
    addCycler(p, "Mode", {"Smart", "Always", "Manual-Key"}, function(o) S.autoReloadMode = o end)
    addCycler(p, "Keybind", {"R", "Q", "E", "F", "G"}, function(o) S.autoReloadKeybind = o end)
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
    addToggle(p, "Box", function(v) S.espBox = v; refreshESP() end)
    addToggle(p, "Player Name", function(v) S.espName = v; refreshESP() end)
    addToggle(p, "Skeleton", function(v)
        S.espSkeleton = v
        if not v then
            for _, d in pairs(RT.espData) do
                for _, b in ipairs(d.bones) do b.line.Visible = false end
            end
        end
    end)
    addToggle(p, "Tracer", function(v)
        S.espTracer = v
        if not v then
            for _, d in pairs(RT.espData) do
                if d.tracer then d.tracer.Visible = false end
            end
        end
    end)
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
        BulletTracer.BackgroundColor3 = S.espColor
    end)

    addSection(p, "Info Panel")
    addToggle(p, "Show Target Info", function(v) S.showInfo = v end)
    addToggle(p, "Show Bullet Tracer", function(v) S.showBulletTracer = v end)

    addSection(p, "Custom Cursor")
    addToggle(p, "Enable Cursor", function(v)
        S.cursorEnabled = v
        applyCursor()
    end)
    addCycler(p, "Style",
        {"Crosshair", "Dot", "Circle", "X", "Ring", "Chevron", "Arrow", "Star"},
        function(o)
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
    addSection(p, "Mod Skin")
    addToggle(p, "Weapon Wrap", function(v)
        S.skinWeaponEnabled = v
        if v then applyWeaponWrap() else restoreSkin() end
    end)
    addCycler(p, "Wrap", WRAPS, function(o)
        S.skinWeaponWrap = o
        if S.skinWeaponEnabled then applyWeaponWrap() end
    end)
    addToggle(p, "Body Color", function(v)
        S.skinBodyColorEnabled = v
        if v then applyBodyColor() end
    end)

    local SKIN_COLORS = {
        { name = "Shadow",  color = Color3.fromRGB(20, 20, 25) },
        { name = "Ghost",   color = Color3.fromRGB(255, 255, 255) },
        { name = "Crimson", color = Color3.fromRGB(180, 20, 20) },
        { name = "Toxic",   color = Color3.fromRGB(50, 200, 80) },
        { name = "Frost",   color = Color3.fromRGB(80, 150, 240) },
        { name = "Void",    color = Color3.fromRGB(140, 60, 220) },
    }
    for _, sk in ipairs(SKIN_COLORS) do
        addButton(p, sk.name, function()
            S.skinBodyColor = sk.color
            S.skinBodyColorEnabled = true
            applyBodyColor()
        end)
    end

    addSection(p, "No Task Scheduler")
    addToggle(p, "Enable NTS", function(v)
        S.noTaskSchedule = v
        if v then installTaskSchedulerHook() else uninstallTaskSchedulerHook() end
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
    addCycler(p, "Config Slot",
        (#listConfigs() > 0 and listConfigs() or { "tioshub_v3" }),
        function(name)
            S.configName = name
            queueSave()
        end)
    addButton(p, "💾 Save Config", function() saveConfig() end)
    addButton(p, "📂 Load Config", function()
        if loadConfig() then print("Loaded. Rejoin to apply.") end
    end)

    addSection(p, "Info")
    local info = Instance.new("TextLabel", p)
    info.Size = UDim2.new(0.97, 0, 0, 70)
    info.BackgroundColor3, info.BackgroundTransparency = C.bgInput, 0.4
    info.TextColor3, info.TextSize = C.textDim, 10
    info.Text = "TiosHub v3.2 • UE-Style UI\n"
        .. CFG.FOLDER .. "/" .. S.configName .. CFG.EXT .. "\n"
        .. "Save để lưu, Load để áp dụng."
    info.TextWrapped, info.TextXAlignment = true, Enum.TextXAlignment.Left
    applyFont(info, "medium")
    corner(info, 10)
    local ip = Instance.new("UIPadding", info)
    ip.PaddingLeft, ip.PaddingRight = UDim.new(0, 10), UDim.new(0, 10)
    registerRow(info, "info")
end

-- ─── TAB CONTROLS ───
local minimized = false
local function toggleUI()
    Main.Visible = not Main.Visible
    BgGui.Enabled = Main.Visible
end
local function toggleMinimize()
    minimized = not minimized
    Main:TweenSize(
        minimized and UDim2.new(0, 360, 0, 44) or UDim2.new(0, 360, 0, 540),
        Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.28, true
    )
end
Icon.MouseButton1Click:Connect(toggleUI)
CloseBtn.MouseButton1Click:Connect(toggleUI)
MinBtn.MouseButton1Click:Connect(toggleMinimize)

-- Start on AIM tab
switchTab("aim")

-- ═══════════════════════════════════════════════════════════════════════════
--  §21  MAIN LOOP
-- ═══════════════════════════════════════════════════════════════════════════
local weaponTimer, infoTimer, bulletSkip = 0, 0, 0
local lastInfo = {name="", hp="", dist="", ratio=-1}

local function mainLoop(dt)
    weaponTimer = weaponTimer + dt
    if weaponTimer >= CFG.WEAPON_SCAN then
        weaponTimer = 0
        scanWeapon()
    end

    if S.showFOV then
        FOVFrame.Size = UDim2.new(0, S.fovRadius * 2, 0, S.fovRadius * 2)
        FOVStroke.Thickness, FOVStroke.Color = S.fovThickness, S.fovColor
    end
    FOVFrame.Visible = S.showFOV

    if S.silentShowFOV and S.silent then
        SilentFrame.Size = UDim2.new(0, S.silentFOV * 2, 0, S.silentFOV * 2)
        SilentFrame.Visible = true
    else SilentFrame.Visible = false end

    -- Aim priority
    if S.rage then
        RT.currentTarget = processRagebot(dt)
    elseif S.legitCam then
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
        getAimTarget("legit"); RT.currentTarget = RT.legitCache
    elseif S.silent then
        getAimTarget("silent"); RT.currentTarget = RT.silentCache
    else RT.currentTarget = nil end

    -- Effects
    processNoRecoil()
    processRapidFire()
    processAutoReload()
    processAutoSave(dt)
    processAntiKatana()
    processModSkin()
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
                    HpFill.BackgroundColor3 = ratio > 0.5 and C.green
                        or ratio > 0.2 and C.yellow or C.red
                end
            end
            if hrp then
                local mRoot = getLocalRoot()
                if mRoot then
                    local ds = string.format("Distance: %d studs",
                        math.floor((hrp.Position - mRoot.Position).Magnitude))
                    if lastInfo.dist ~= ds then lastInfo.dist = ds; InfoDist.Text = ds end
                end
            end
        elseif Info.Visible then Info.Visible = false end
    end

    -- Bullet tracer
    bulletSkip = bulletSkip + 1
    if bulletSkip >= 3 then
        bulletSkip = 0
        if S.showBulletTracer and (S.aimbot or S.legitCam) and RT.currentTarget and (RT.projConfig or S.prediction) then
            local char = RT.currentTarget.Character
            local part = char and getPart(char, S.targetPart)
            if part then
                local pp = predict(char, part, true, RT.projConfig, S.predMult)
                local oS = Camera:WorldToViewportPoint(Camera.CFrame.Position)
                local tS = Camera:WorldToViewportPoint(pp)
                if oS and tS then
                    local dx, dy = tS.X - oS.X, tS.Y - oS.Y
                    local len = math.sqrt(dx*dx + dy*dy)
                    if len > 1 then
                        BulletTracer.Visible = true
                        BulletTracer.Position = UDim2.new(0, oS.X, 0, oS.Y)
                        BulletTracer.Size = UDim2.new(0, len, 0, 2)
                        BulletTracer.Rotation = math.deg(math.atan2(dy, dx))
                        BulletTracer.BackgroundTransparency = 0.3
                    else BulletTracer.Visible = false end
                else BulletTracer.Visible = false end
            else BulletTracer.Visible = false end
        elseif BulletTracer.Visible then BulletTracer.Visible = false end
    end

    if S.esp then updateESPVisuals() end
end

RunService:BindToRenderStep("TiosHub_Main", CFG.RENDER_PRIO, mainLoop)

-- Auto load config
task.spawn(function()
    task.wait(0.3)
    if isfile(cfgPath()) and loadConfig(true) then
        print("[TiosHub] ✅ Config loaded from previous session")
    end
end)

-- Save on close
pcall(function()
    game:BindToClose(function()
        if S.autoSave then saveConfig(true) end
    end)
end)

print("═══════════════════════════════════════════════════")
print("  TIOSHUB v3.2 FINAL  |  Rivals Edition")
print("  → UE-Style Horizontal UI (5 tabs)")
print("  → All features working · Clean code 9/10")
print("═══════════════════════════════════════════════════")
