-- Native UI extracted from the user-supplied reference. Game feature code is supplied by main.lua.
local context = ... or {}
local IS_LION = context.FrontendStyle == "lion"
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local PUBLIC_VERSION, MAX_PUBLIC_VERSION, EXECUTOR_NAME = "1", "1", "Plex"
local function genv() return getgenv and getgenv() or _G end
local function rgb(v) if typeof(v)=="Color3" then return v end return Color3.fromRGB(v[1],v[2],v[3]) end
local function log(level, ...) if level=="WARN" or level=="ERROR" then warn("[Native UI]", ...) end end
local function notify(text) if context.Notify then context.Notify(text) else print("[Native UI]",text) end end
local function reportError(...) warn("[Native UI]",...) end
local function sanitize() end
local function saveConfig() if context.Save then context.Save() end end
local saveConfigSoon = saveConfig
local EXEC = {caps = {files = type(writefile)=="function"}, isfile=isfile, readfile=readfile, writefile=writefile,
    makefolder=makefolder,isfolder=isfolder,getcustomasset=getcustomasset,request=request or http_request}
local DATA = {dir="plex",fonts="plex/fonts"}
EXEC.mkdirs = function(path) if makefolder and isfolder and not isfolder(path) then makefolder(path) end end
UI = UI or {}
UI.BRAND_LOGO_B64 = [[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]]
UI._brandLogoAsset = nil
function UI.decodeBrandLogoBase64(data)
    local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local lookup = {}
    for i = 1, #alphabet do lookup[string.byte(alphabet, i)] = i - 1 end
    local out = {}
    for i = 1, #data, 4 do
        local a = lookup[string.byte(data, i)] or 0
        local b = lookup[string.byte(data, i + 1)] or 0
        local cb = string.byte(data, i + 2)
        local db = string.byte(data, i + 3)
        local c = cb == 61 and nil or lookup[cb]
        local d = db == 61 and nil or lookup[db]
        local value = a * 262144 + b * 4096 + (c or 0) * 64 + (d or 0)
        out[#out + 1] = string.char(math.floor(value / 65536) % 256)
        if c ~= nil then out[#out + 1] = string.char(math.floor(value / 256) % 256) end
        if d ~= nil then out[#out + 1] = string.char(value % 256) end
    end
    return table.concat(out)
end
function UI.brandLogoAsset()
    if UI._brandLogoAsset ~= nil then return UI._brandLogoAsset or nil end
    UI._brandLogoAsset = false
    if not (EXEC.writefile and EXEC.getcustomasset) then return nil end
    pcall(function()
        EXEC.mkdirs(DATA.dir)
        local path = DATA.dir .. "/plexcc-logo.png"
        EXEC.writefile(path, UI.decodeBrandLogoBase64(UI.BRAND_LOGO_B64))
        UI._brandLogoAsset = EXEC.getcustomasset(path)
    end)
    return UI._brandLogoAsset or nil
end
local DEFAULTS = {

    aimbot = false,
    aimKey = "MouseButton2",
    aimFov = 140,
    aimFov360 = false,
    aimSmooth = 4,
    aimReactionMs = 140,
    aimStrength = 100,
    aimOnlyMoving = false,
    aimHumanize = 0,
    keySlot = "",
    aimHitboxes = { Head = true, Body = true },
    aimPrefer = "Head",
    aimVisibleHitbox = true,
    aimbotVisibleCheck = true,
    flickbot = false,
    flickKey = "X",
    flickMs = 90,
    flickOvershoot = 30,
    flickShoot = true,
    legitTriggerVisible = true,

    legitTrigger = false,
    legitTriggerDelayMs = 90,
    legitTriggerChance = 100,
    legitTriggerMode = "Always",
    legitTriggerKey = "MouseButton2",
    legitTriggerHitbox = "Any",
    legitTriggerMaxDist = 400,
    legitTriggerStill = false,
    silentHitboxes = { Head = true, Body = true },
    silentPrefer = "Head",
    silentVisibleHitbox = true,
    teamCheck = true,
    crosshair = false,
    showFov = true,



    silentAim = false,
    silentFov = 160,
    silentFov360 = false,



    silentFovFallback = true,
    fovLinked = false,
    silentHitChance = 100,
    silentWallbang = false,
    silentWallbangDist = 4,
    antiUnder = true,
    antiUnderDist = 8,
    silentOnlyFiring = false,
    silentSpoofServer = true,
    silentRaycastLayer = true,
    silentSettleMs = 100,
    settleAuto = true,
    silentSettleGateShots = false,
    targetPriority = "Closest",
    stickyAim = false,
    targetSwitchMs = 300,
    threatPriority = true,
    deadTargetGuard = true,
    resolver = true,
    resolverBodyOnAA = true,
    resolverWarp = true,

    magicHeight = 30,
    magicJitter = true,
    magicJitterRadius = 3.5,
    magicJitterHz = 4,
    magicWiggle = 1,

    autoShoot = true,
    autoShootHold = true,
    autoShootDelay = 0.06,
    autoShootChance = 100,
    autoShootHealthCheck = true,
    autoShootServerSafe = false,
    autoShootLeadMs = 0,
    autoShootMinHitChance = 0,
    autoShootStopMode = "Off",
    autoShootStop = false,
    autoShootStopLeadMs = 90,
    autoShootAimMode = "Off",
    autoShootAim = false,
    autoShootAdsRelease = 0.4,
    noSpreadStraighten = true,
    fireMethod = "Auto",


    compatLearned = {},
    autoShootWaitAim = true,
    autoShootPulse = true,
    autoShootCooldownSync = true,
    autoShootReactionMs = 0,
    rageAutoShootVisible = true,

    silentCameraData = true,
    backtrackMode = "Off",




    leadMode = "Auto",
    leadMs = 100,
    leadLearnedMs = -1,
    shotsRecord = true,
    shotsLog = true,
    shotsExport = true,
    logDetail = "Normal",
    roundFile = true,


    unsafeMode = true,
    unsafeAccepted = true,
    unsafeFakeLag = false,
    unsafeFakeLagChokeMs = 180,
    unsafeFakeLagEveryMs = 600,
    unsafeFakeLagOnlyWhenTargeted = true,
    unsafePingBoost = false,
    unsafePingBoostMs = 150,
    unsafeShowNet = true,
    autoPeek = false,
    autoPeekKey = "",
    autoPeekDistance = 10,

    noSpread = false,
    noRecoil = false,
    rapidFire = false,
    fullAuto = false,
    rapidFireMult = 0.5,




    rapidThrottle = true,


    rapidGhostRounds = false,
    rapidAdaptive = true,
    rapidFloor = {},
    rapidFloorSafe = {},



    spreadClaimAim = true,
    spreadStillShot = true,
    spreadMode = "Auto",
    spreadLearned = {},


    rapidMelee = false,
    rapidMeleeMult = 0.3,
    rapidMeleeServer = 0.3,
    rapidFloorMelee = {},

    meleeRage = true,
    meleeRageRange = 80,
    meleeMode = "Auto",
    meleeOverrides = {},
    meleeHeavyPolicy = "Heavy then light",
    meleeLookSource = "Auto",
    meleeStandoff = 3,
    meleeOrbitRadius = 1,
    meleeSettlePad = 30,
    meleeHeavyHold = 0.12,
    meleeFaceOnSwing = true,
    meleePredict = true,



    defenseHide = true,
    defenseMode = "Auto",
    defenseMinCooldown = 0.15,
    defenseMaxHide = 3,
    defenseOnlyWhenThreat = false,
    defenseAlways = true,
    defenseVoidSpam = true,
    defenseHopHz = 3,
    defensePinCamera = true,



    voidSpam = false,
    voidSpamMode = "Timer",
    voidSpamDist = 10000000,
    voidSpamSpot = "Auto",

    parkCsync = true,
    parkMinDist = 10000000,
    parkMaxDist = 1000000000,
    parkAwayJitter = 40,
    parkHopEveryFrame = true,
    parkFallenGuard = true,
    translocOffset = -4,
    translocClear = 2,
    translocMaxBudget = 1,
    translocBait = true,
    translocBaitDepth = 0.35,
    antiTransloc = true,
    voidSpamHide = 1.5,
    voidSpamBack = 0.4,
    voidSpamFireBack = true,
    voidSpamMoveBack = false,
    voidSpamUnder = true,
    voidSpamUnderRange = 400,


    voidSpamBait = true,
    voidSpamBaitSpot = "In the floor",
    voidSpamBaitSec = 0.25,
    voidSpamBaitEvery = 2,
    voidSpamAutoOff = 0,
    voidSpamHud = true,

    counterVoid = true,
    counterTeleport = true,
    shieldAware = true,
    antiFlash = false,
    magicHopOnShot = true,
    targetPreferVisible = true,
    autoShootSpam = true,

    oobBlock = false,
    oobMargin = 0.6,
    boundsGuard = true,
    safeMaxHeight = 26,
    noclip = false,
    noclipFloat = true,
    noclipSpeed = 40,
    noclipFollowCamera = false,
    noclipRage = true,

    originMaxDist = 14,
    originInsideWalls = true,
    originBelowMap = true,
    originStick = true,
    originPreferCover = true,

    autoShootEchoGate = false,
    autoShootLeadMaxMs = 120,
    preAim = true,
    preAimRange = 140,
    quantAware = true,

    aaFlick = false,
    aaSpinDir = 1,
    aaSpinJitter = false,
    aaBodyMode = "Same",

    voidHunt = true,
    fastEquip = false,
    fastEquipMult = 0.3,
    fastAim = false,
    fastAimMult = 2,
    speedBoost = false,
    speedMult = 1.25,
    instantBullet = false,
    instantReload = false,
    reloadMult = 0,
    autoReload = false,
    reloadEarly = 0,
    noReloadCancel = false,
    autoSwitchEmpty = false,

    infSlide = false,
    infSprint = false,
    autoSlide = false,
    slideKey = "C",
    noAdsSlow = false,
    noSlow = false,
    bhop = false,
    fly = false,
    flySpeed = 60,
    autoStrafe = false,
    strafeMaxSpeed = 45,
    strafeGain = 0.6,

    rageEnabled = false,


    ragePosition = "Autokill",

    autokill = false,
    autokillMode = "Origin",
    autokillHeight = 2.5,
    autokillRadius = 4,
    autokillOrbit = true,
    autokillOrbitSpeed = 12,
    autokillMove = "Auto",
    autokillHopMs = 220,
    autokillSnapHold = 0.6,
    autokillHvh = true,
    rageBreaker = false,
    autokillMaxSpeed = 45,


    autokillOrbitDeg = 110,
    autokillOrbitJitter = 1.6,
    autokillOrbitJitterHz = 14,
    autokillOrbitFlip = true,
    autokillOrbitDesync = true,
    autokillModeGuard = true,

    autokillModeSniper = "High",
    autokillModeShotgun = "Under",
    autokillModeRifle = "Void",
    autokillModePistol = "Mode",
    autokillModeBurst = "Mode",
    autokillModeProjectile = "Mode",
    autokillModeMelee = "Mode",
    autokillModeOther = "Mode",

    autoStats = {},
    autoExplore = 10,
    autoMinSamples = 8,
    autoDecayDays = 7,
    autoPingHops = 250,

    hvhGlue = true,
    hvhGlueSide = "Auto",
    glueAboveY = -0.7,
    glueBelowY = -3.85,
    glueZ = 0.05,
    hvhFireFrames = 2,
    hvhMelee = true,
    meleeGlueOnlyBots = false,
    hvhSendRate = false,
    hvhSendRateValue = 120,
    directShots = false,
    directMelee = true,
    directPath = "Auto",
    directPayload = "Normal",
    gluebotCounter = true,
    gluebotAwayPct = 30,
    gluebotArrivals = 3,
    gluebotArrivalDist = 2,
    gluebotList = {},
    counterMargin = 80,
    counterDeflect = true,
    counterSpawnHold = true,
    antiMeleePark = true,
    defenseSmart = true,
    autokillUnderDist = 6,
    autokillHighDist = 25,
    highSearch = true,
    highCeilingGap = 2,
    highBearings = 8,
    highHeights = 3,
    highMinDist = 8,
    highRing = 4,
    highSticky = true,
    highStumble = 0.8,
    underMeasure = true,
    underInSlab = 0.5,
    underColumns = 6,
    underColumnRadius = 2.5,
    underMaxSlab = 4,
    underSticky = true,
    underShotgunRadius = 1.5,
    autokillDuration = 6,
    autokillUntilDead = false,
    autokillReturn = true,
    autokillVisible = true,
    autokillAuto = false,
    autokillAutoRange = 400,
    autokillCooldown = 0.5,
    autokillAbortHp = 35,
    voidBurst = 0.8,
    voidRest = 1.2,
    voidHeights = {},
    voidDepths = {},
    voidFatal = {},
    voidFarCap = {},
    voidAutoCalibrate = true,
    autokillAdaptive = true,
    autokillChain = true,

    targetBots = true,
    immuneCheck = true,
    bodyAimHoldMs = 30,
    dynamicHitbox = true,
    targetMaxDistance = 400,
    killConfirmHold = false,
    oneShotSafety = true,
    meleeReachSlack = 1,
    autoQuickMelee = false,
    utilAuto = false,
    utilHeal = true,
    utilHealBelow = 40,
    utilMine = true,
    utilThrow = false,
    gunAbilities = false,
    autoBackstab = true,
    autoBackstabAnyMelee = true,
    autoBackstabRange = 25,

    antiMelee = true,
    antiMeleeFace = true,
    antiMeleeDodge = true,
    antiMeleeDodgeCd = 1.5,
    antiMeleeOnHit = true,
    antiMeleeKeepDistance = true,
    antiMeleeTarget = true,
    antiMeleeMargin = 3,
    aimDynamic = true,
    autoShootScopeSnipers = true,
    aaReplicate = true,
    aaSendHz = 12,


    rageCsync = false,
    rageCsyncAuto = false,

    posDesync = false,
    posDesyncMode = "Flicker",
    posDesyncDist = 40000,
    posDesyncNear = 8,

    csync = false,
    csyncMode = "Flicker",
    csyncDist = 40000,
    awarenessHud = true,
    combatBar = true,
    targetCard = true,
    hudScale = 1,
    statusSituation = false,
    statusAa = false,
    toasts = true,

    watchdog = true,
    autoPerf = true,
    lowSpec = false,
    introAnim = true,

    autoUpdate = true,
    adaptToasts = true,
    placeVersions = {},

    aaEnabled = false,
    aaMode = "Auto",
    aaSpeed = 10,
    aaPitch = "Down",
    aaSwitchMs = 350,
    aaJitterDeg = 70,
    aaOnlyIdle = false,
    aaBody = true,
    fakeDuck = false,

    autoBlock = false,
    autoBlockRange = 45,
    autoBlockAngle = 25,
    katanaCheck = true,
    remoteSpy = false,
    shotCallers = { MechanicsController = true, Gun = true, Item = true },

    esp = true,
    espHighlight = true,
    espBox = true,
    espBoxStyle = "Corner",
    espBoxFill = false,
    espBoxFillAlpha = 0.85,
    espSkeleton = false,
    espHeadDot = false,
    espNames = true,
    espHealthBar = true,
    espDistance = true,
    espWeapon = true,
    espTracers = false,
    espTracerFrom = "Bottom",
    espArrows = true,




    dmgDir = false,
    dmgDirSec = 1.5,
    selfGhost = false,
    radarRotateView = true,
    radarFacing = false,
    radarHeight = false,
    radarNames = false,
    radarTeam = true,
    espPriority = "",
    espArrowRadius = 220,
    espArrowMax = 5,
    espArrowDist = true,
    espVisibleCheck = false,
    espTextSize = 13,
    espLineWidth = 1,
    espOutline = true,
    espHpMode = "When damaged",
    espFlags = true,
    espTeammates = false,
    espRank = true,
    espAmmo = true,
    espStreak = true,
    teamPerf = true,
    espRenderer = "Auto",
    espMaxDistance = 2000,
    espChamsFill = 0.78,
    espChamsOutline = 0,
    espChamsOccluded = false,
    espChamsBlend = true,
    espChamsPartial = true,
    radar = false,
    radarSize = 160,
    radarRange = 150,
    hitMarkers = true,

    hitSound = "Off",
    hitSoundHead = "Same",
    killSound = "Off",
    sfxVolume = 60,
    sfxPitch = 100,
    hitChams = false,
    colHitChams = { 200, 155, 255 },
    hitNotify = false,
    killFeed = true,
    perfMode = false,

    colEsp = { 142, 138, 153 },
    colEspVisible = { 73, 145, 255 },
    colText = { 242, 240, 247 },
    colHp = { 69, 223, 160 },
    colTracer = { 73, 145, 255 },
    colChamsFill = { 73, 145, 255 },
    colChamsHidden = { 255, 72, 120 },
    colChamsOutline = { 206, 170, 255 },
    colEspTeam = { 120, 140, 160 },
    colEspPriority = { 255, 190, 60 },

    nightMode = false,
    nightLevel = 40,
    nightHands = true,
    nightHandsGlow = 60,
    fullbright = false,
    noFog = false,
    skyColorOn = false,
    skyColor = { 20, 24, 48 },
    timeOfDayOn = false,
    timeOfDay = 14,
    fovChanger = false,
    fov = 90,
    antiAfk = true,
    autoRejoin = false,
    autoRejoinDelay = 5,
    thirdPerson = false,
    tpShoulder = "Right",
    tpDist = 6,
    tpUp = 1.5,
    tpSide = 1.5,
    tpSmooth = true,
    tpHideViewmodel = true,
    tpFov = 90,
    tpOrbit = false,
    tpOrbitSpeed = 45,
    noPostFx = false,
    noDamageFx = false,
    brightness = 2,
    noAdsZoom = false,
    noScopeOverlay = false,
    hideViewmodel = false,
    hideHands = false,

    worldPreset = "",

    worldWind = 0,
    timeCycleOn = false,
    timeCycleSec = 240,
    skyboxCustom = "",
    vignetteOn = false,
    vignetteAmount = 45,
    aberrationOn = false,
    aberrationAmount = 40,
    grainOn = false,
    grainAmount = 35,
    sharpenOn = false,
    sharpenAmount = 50,
    colorBlind = "Off",
    noGameShotFx = false,
    worldGrade = false,
    gradeBrightness = 0,
    gradeContrast = 0.1,
    gradeSaturation = 0.15,
    gradeTint = { 255, 255, 255 },
    worldBloom = false,
    bloomIntensity = 0.8,
    bloomSize = 24,
    bloomThreshold = 1.2,
    worldSunRays = false,
    sunRaysIntensity = 0.12,
    sunRaysSpread = 0.6,
    worldDof = false,
    dofFocus = 40,
    dofBlur = 0.35,
    worldAtmos = false,
    atmosDensity = 0.3,
    atmosHaze = 1.2,
    atmosGlare = 0.3,
    atmosColor = { 200, 172, 255 },
    worldAmbientOn = false,
    colAmbient = { 120, 110, 160 },
    colOutdoor = { 150, 140, 190 },
    worldExposureOn = false,
    worldExposure = 0,
    worldShadows = "Default",
    worldStars = false,
    worldMotionBlur = false,
    worldMotionBlurScale = 1,
    worldMotionBlurShutter = 180,
    worldMotionBlurObjects = true,
    worldNoTextures = false,
    worldTextureTint = false,
    colWorldTint = { 73, 145, 255 },
    skyboxPreset = "Off",
    stretchedRes = false,
    stretchedResScale = 0.88,
    crosshairStyle = "Classic",
    crosshairSize = 1,

    nameSpoof = false,
    nameSpoofMode = "Custom",
    nameSpoofText = "Player",
    hideNametags = false,
    streamerMode = false,
    weaponSpoof = false,
    weaponSpoofMode = "Hide",
    weaponSpoofText = "Gun",
    rankSpoof = false,
    rankSpoofText = "1",
    fovRotate = false,
    fovRoll = 0,
    fovSpin = 45,
    overlaySpin = false,
    overlayGradient = false,
    reloadIndicator = false,
    reloadIndicatorStyle = "Bar",
    vmChamsArms = false,
    vmOutline = false,
    vmNoSway = false,
    worldWeather = "Off",
    fxQuality = true,
    weatherDensity = 50,
    shotTracers = false,
    shotTracerLife = 0.6,
    shotTracerAccent = true,
    colShotTracer = { 73, 145, 255 },
    hitNumbers = false,
    hitBlood = false,
    killEffect = "Off",
    vmChams = false,
    vmMaterial = "ForceField",
    colVm = { 73, 145, 255 },
    vmAlpha = 0,
    selfChams = false,
    selfMaterial = "ForceField",
    colSelf = { 73, 145, 255 },

    haloOn = false,
    colHalo = { 255, 42, 42 },
    haloGlow = true,
    haloSize = 1,
    haloHeight = 1.2,
    haloSpin = 40,

    hud = true,
    indicators = false,
    showBinds = true,
    terminal = false,
    logToFile = true,
    debugConsole = false,
    debugModuleIdx = 1,
    theme = IS_LION and "Lion" or "Plex blue",
    maxTheme = "",
    colAccent = { 73, 145, 255 },
    colAccent2 = { 32, 96, 226 },
    uiGlow = 45,
    themeFx = true,
    themeArt = true,
    railGlass = 14,
    menuBlur = false,
    menuBlurSize = 12,
    menuDim = 45,
    menuScale = 1,
    previewPane = true,
    espHideInMenu = true,
    espLobby = false,
    espWhileHidden = true,
    espGhostSec = 6,


    menuKey = "Insert",
    hudPos = {},
    uiMode = "Simple",
    previewHp = 72,
    deviceSpoof = "Real",

    unlockCosmetics = false,
    unlockFinisher = false,



    skinModelSwap = true,


    skinRebuild = true,

    skinEquips = {},
    skinWeapon = "",

    binds = {},


    cfgRev = 0,
}
local cfg = table.clone(DEFAULTS)
local S = {alive=true,menuOpen=false,edition="normal",shownVersion=PUBLIC_VERSION,loadClock=os.clock(),
    cfg=cfg,localEquips={},ui={tabs={},subTabs={},controls={},toggles={}},ext={tabs={},subs={},sections={}},caps={},executor=EXECUTOR_NAME}
local Game = {cleanups={},superseded=function() return not S.alive end,
    parentGui=function(gui) local parent=(gethui and gethui()) or game:GetService("CoreGui") gui.Parent=parent return true end}
local Combat, Skins = {}, {}
local Vis = {col=function(key) local value=cfg[key] if typeof(value)=="Color3" then return value end return rgb(type(value)=="table" and value or {73,145,255}) end}
local capturing=false
local Input = {bindLabels={},bindCallbacks={},toggleBindHandlers={},keyDown={},bindState={},bindTouched={},touchInputs={}}
function Input.keyLabel(value) return tostring(value or "None") end
function Input.inputName(input)
    return input.UserInputType==Enum.UserInputType.Touch and "Touch"
        or input.UserInputType==Enum.UserInputType.MouseButton1 and "MB1"
        or input.UserInputType==Enum.UserInputType.MouseButton2 and "MB2" or input.KeyCode.Name
end
function Input.capturing() return capturing end
function Input.captureKey(callback)
    if capturing then return end
    capturing=true
    local connection
    connection=UIS.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseMovement then return end
        connection:Disconnect() capturing=false
        callback(input.KeyCode==Enum.KeyCode.Escape and false or input.KeyCode==Enum.KeyCode.Backspace and "None"
            or Input.inputName(input))
    end)
    table.insert(Game.cleanups,function() connection:Disconnect() capturing=false end)
end
function Input.releaseAll()
    if Input.releaseTouch then Input.releaseTouch() end
    table.clear(Input.touchInputs)
    table.clear(Input.keyDown)
end
local Configs = {active="",list=function() return {} end,isDirty=function() return false end,
    load=function() return false,"Use the Config section" end,save=function() saveConfig() return true end}
    local UI: any = UI or {}
    UI.cfg = cfg
    UI.publicVersion = PUBLIC_VERSION
    S.uikit = UI



    local C: any = {
        bg = Color3.fromRGB(15, 14, 19),
        side = Color3.fromRGB(11, 10, 15),
        surface = Color3.fromRGB(22, 21, 27),
        card = Color3.fromRGB(28, 27, 34),
        pop = Color3.fromRGB(20, 19, 26),
        hairline = Color3.fromRGB(30, 29, 36),
        edge = Color3.fromRGB(38, 37, 45),
        text = Color3.fromRGB(236, 234, 242),
        dim = Color3.fromRGB(161, 157, 173),
        muted = Color3.fromRGB(106, 102, 116),
        faint = Color3.fromRGB(74, 71, 82),
        off = Color3.fromRGB(38, 36, 46),
        knobOff = Color3.fromRGB(119, 114, 127),
        accent = Color3.fromRGB(73, 145, 255),
        accent2 = Color3.fromRGB(32, 96, 226),
        danger = Color3.fromRGB(255, 92, 122),
        ok = Color3.fromRGB(69, 223, 160),
        warn = Color3.fromRGB(255, 181, 71),
        rage = Color3.fromRGB(255, 92, 122),
        light = false,
    }
    UI.C = C
    S.themeColors = C






    UI.F = {
        body = Font.fromEnum(Enum.Font.BuilderSansExtraBold),
        medium = Font.fromEnum(Enum.Font.BuilderSansExtraBold),
        semibold = Font.fromEnum(Enum.Font.BuilderSansExtraBold),
        bold = Font.fromEnum(Enum.Font.BuilderSansExtraBold),
        black = Font.fromEnum(Enum.Font.BuilderSansExtraBold),
        code = Font.fromEnum(Enum.Font.RobotoMono),
        icon = nil,
    }


    UI.BRAND_FONT = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)

    UI.TEXT_MIN = 12
    UI.TEXT_KEYS = { title = true, desc = true, group = true, value = true, small = true, tiny = true }
    UI.M = {
        title = 14,
        desc = 13,
        group = 14,
        value = 13,
        small = 12,
        tiny = 12,
        row = 26,
        rowToggle = 26,
        rowDanger = 26,
        rowSlider = 26,
        rowCycle = 26,
        rowColor = 26,
        rowKeybind = 26,
        rowButton = 32,
        rowNote = 20,
        descLine = 0,
        listRow = 26,
        pillW = 28,
        pillH = 16,
        knob = 12,
        btnH = 26,
        ctrlW = 118,
        trackW = 100,
        valueW = 40,
        colW = 300,
    }
    if IS_LION then
        UI.TEXT_MIN = 11
        for _, key in ipairs({"title","desc","group","value","small","tiny"}) do UI.M[key] = 12 end
        for _, key in ipairs({"row","rowToggle","rowDanger","rowSlider","rowCycle","rowColor","rowKeybind","listRow"}) do UI.M[key] = 21 end
        UI.M.rowButton, UI.M.btnH, UI.M.pillW, UI.M.pillH = 25, 23, 14, 14
        UI.M.rowSlider, UI.M.rowCycle = 38, 42
        UI.F.body = Font.fromEnum(Enum.Font.GothamMedium)
        UI.F.medium = Font.fromEnum(Enum.Font.GothamMedium)
        UI.F.semibold = Font.fromEnum(Enum.Font.GothamBold)
        UI.F.bold, UI.F.black = UI.F.semibold, UI.F.semibold
    end


    function UI.textH(text: string, size: number, _font: any, width: number): number
        local ts = game:GetService("TextService")
        local ok, sz = pcall(ts.GetTextSize, ts, tostring(text or ""), size, Enum.Font.BuilderSansExtraBold, Vector2.new(math.max(width, 40), 4000))
        if ok and sz then
            return math.ceil(sz.Y)
        end
        return size + 4
    end


    UI.ASSET_DIR = "cocaine/fonts"
    UI.BARLOW = "https://raw.githubusercontent.com/google/fonts/main/ofl/barlow/"
    UI.FONT_FACES = {
        { file = "Barlow-Regular.ttf", weight = 400, name = "Regular" },
        { file = "Barlow-Medium.ttf", weight = 500, name = "Medium" },
        { file = "Barlow-SemiBold.ttf", weight = 600, name = "SemiBold" },
        { file = "Barlow-Bold.ttf", weight = 700, name = "Bold" },
        { file = "Barlow-ExtraBold.ttf", weight = 800, name = "ExtraBold", optional = true },
    }
    UI.ICON_FONT = { file = "MaterialIconsOutlined.otf", url = "https://raw.githubusercontent.com/google/material-design-icons/master/font/MaterialIconsOutlined-Regular.otf" }
    UI.assetState = "builtin"
    function UI.assetPath(file: string): string
        return UI.ASSET_DIR .. "/" .. file
    end
    function UI.haveAsset(file: string): boolean
        local ok, yes = pcall(function()
            return EXEC.isfile(UI.assetPath(file)) and #EXEC.readfile(UI.assetPath(file)) > 10000
        end)
        return ok and yes == true
    end
    function UI.fetchAsset(file: string, url: string): boolean
        if UI.haveAsset(file) then
            return true
        end
        if type(EXEC.request) ~= "function" then
            return false
        end
        local ok, res = pcall(EXEC.request, { Url = url, Method = "GET" })
        if not (ok and type(res) == "table" and res.StatusCode == 200 and type(res.Body) == "string" and #res.Body > 10000) then
            log("WARN", "font download failed:", file, ok and type(res) == "table" and res.StatusCode or tostring(res))
            return false
        end
        pcall(function()
            for _, dir in ipairs({ "cocaine", UI.ASSET_DIR }) do
                if not (EXEC.isfolder and EXEC.isfolder(dir)) and EXEC.makefolder then
                    EXEC.makefolder(dir)
                end
            end
        end)
        local okW = pcall(EXEC.writefile, UI.assetPath(file), res.Body)
        return okW
    end

    function UI.applyFonts(): boolean
        if type(EXEC.getcustomasset) ~= "function" then
            return false
        end
        local ok, err = pcall(function()
            local faces = {}
            local extra = false
            for _, f in ipairs(UI.FONT_FACES) do
                if UI.haveAsset(f.file) then
                    table.insert(faces, { name = f.name, weight = f.weight, style = "normal", assetId = EXEC.getcustomasset(UI.assetPath(f.file)) })
                    extra = extra or f.weight == 800
                elseif not f.optional then
                    error("missing " .. f.file)
                end
            end
            EXEC.writefile(UI.assetPath("CocaineBarlow.json"), HttpService:JSONEncode({ name = "CocaineBarlow", faces = faces }))
            local fam = EXEC.getcustomasset(UI.assetPath("CocaineBarlow.json"))
            local heavy = if extra then Enum.FontWeight.ExtraBold else Enum.FontWeight.Bold
            UI.F.body = Font.new(fam, Enum.FontWeight.Bold)
            UI.F.medium = Font.new(fam, Enum.FontWeight.Bold)
            UI.F.semibold = Font.new(fam, heavy)
            UI.F.bold = Font.new(fam, heavy)
            UI.F.black = Font.new(fam, heavy)
            UI.fontFamily = fam
            if UI.haveAsset(UI.ICON_FONT.file) then
                EXEC.writefile(UI.assetPath("CocaineIcons.json"), HttpService:JSONEncode({ name = "CocaineIcons", faces = { { name = "Regular", weight = 400, style = "normal", assetId = EXEC.getcustomasset(UI.assetPath(UI.ICON_FONT.file)) } } }))
                UI.F.icon = Font.new(EXEC.getcustomasset(UI.assetPath("CocaineIcons.json")))
            end
        end)
        if not ok then
            log("DEBUG", "fonts: built-in (" .. tostring(err):sub(1, 60) .. ")")
            return false
        end
        UI.assetState = "loaded"
        return true
    end


    function UI.loadAssets()
        if IS_LION then UI.assetState = "loaded"; return end
        if UI.applyFonts() then

            local missing = {}
            for _, f in ipairs(UI.FONT_FACES) do
                if f.optional and not UI.haveAsset(f.file) then
                    table.insert(missing, f)
                end
            end
            if #missing > 0 and type(EXEC.request) == "function" then
                task.spawn(function()
                    local got = false
                    for _, f in ipairs(missing) do
                        got = UI.fetchAsset(f.file, UI.BARLOW .. f.file) or got
                    end
                    if got and S.alive ~= false and UI.applyFonts() then
                        task.defer(function()
                            if S.alive ~= false and S.rebuildMenu then
                                pcall(S.rebuildMenu)
                            end
                        end)
                    end
                end)
            end
            return
        end
        if type(EXEC.request) ~= "function" or type(EXEC.getcustomasset) ~= "function" or not EXEC.caps.files then
            UI.assetState = "failed"
            return
        end
        UI.assetState = "loading"
        task.spawn(function()
            local all = true
            for _, f in ipairs(UI.FONT_FACES) do
                all = (UI.fetchAsset(f.file, UI.BARLOW .. f.file) or f.optional == true) and all
            end
            UI.fetchAsset(UI.ICON_FONT.file, UI.ICON_FONT.url)
            if not (all and S.alive ~= false and UI.applyFonts()) then
                UI.assetState = "failed"
                return
            end
            log("INFO", "fonts: Barlow + Material Icons downloaded")
            task.defer(function()
                if S.alive == false then
                    return
                end
                if S.rebuildMenu then
                    pcall(S.rebuildMenu)
                end
                if S.hud and S.hud.retheme then
                    pcall(S.hud.retheme)
                end

                if S.vis and S.vis.resetDrawings and S.vis.useGuiRenderer and S.vis.useGuiRenderer() then
                    pcall(S.vis.resetDrawings)
                end
            end)
        end)
    end



    local THEMES = {
        ["Neon purple"] = { Color3.fromRGB(178, 120, 255), Color3.fromRGB(120, 66, 246) },
        Ice = { Color3.fromRGB(116, 206, 255), Color3.fromRGB(58, 128, 255) },
        Rose = { Color3.fromRGB(255, 122, 182), Color3.fromRGB(238, 60, 122) },
        Mint = { Color3.fromRGB(96, 240, 190), Color3.fromRGB(22, 196, 150) },
        Gold = { Color3.fromRGB(255, 200, 112), Color3.fromRGB(250, 152, 54) },
        Mono = { Color3.fromRGB(246, 246, 250), Color3.fromRGB(150, 150, 162) },
    }



    THEMES.Obsidian = { Color3.fromRGB(73, 145, 255), Color3.fromRGB(32, 96, 226) }
    THEMES["Plex blue"] = { Color3.fromRGB(73, 145, 255), Color3.fromRGB(32, 96, 226) }
    THEMES["Plex pink"] = THEMES["Plex blue"]
    local THEME_ORDER = { "Plex blue", "Neon purple", "Ice", "Rose", "Mint", "Gold", "Mono", "Custom" }
    THEMES.Lion = {Color3.fromRGB(255, 139, 0), Color3.fromRGB(199, 96, 0)}
    if IS_LION then table.insert(THEME_ORDER, 1, "Lion") end



    THEMES.Max = { Color3.fromRGB(255, 42, 42), Color3.fromRGB(139, 0, 0) }

    THEMES["Max Cute"] = { Color3.fromRGB(255, 143, 199), Color3.fromRGB(236, 72, 153) }


    THEMES["Max Pride"] = { Color3.fromRGB(255, 106, 136), Color3.fromRGB(138, 86, 255) }
    THEMES["Max Trans"] = { Color3.fromRGB(91, 206, 250), Color3.fromRGB(240, 128, 170) }
    THEMES["Max Femboy"] = { Color3.fromRGB(247, 138, 205), Color3.fromRGB(96, 184, 245) }
    THEMES["Max Xmas"] = { Color3.fromRGB(255, 84, 98), Color3.fromRGB(196, 24, 52) }
    THEMES["Max Matcha"] = { Color3.fromRGB(162, 210, 104), Color3.fromRGB(90, 150, 62) }
    THEMES["Max Blood"] = { Color3.fromRGB(214, 54, 68), Color3.fromRGB(122, 16, 28) }
    UI.MAX_THEMES = { Max = true, ["Max Cute"] = true, ["Max Pride"] = true, ["Max Trans"] = true, ["Max Femboy"] = true, ["Max Xmas"] = true, ["Max Matcha"] = true, ["Max Blood"] = true }
    do
        local function surf(t: { { number } }): any
            local keys = { "bg", "side", "surface", "card", "pop", "hairline", "edge", "text", "dim", "muted", "faint", "off", "knobOff" }
            local out = {}
            for i, k in ipairs(keys) do
                out[k] = Color3.fromRGB(t[i][1], t[i][2], t[i][3])
            end
            return out
        end
        UI.THEME_SURFACES = {
            Lion = surf({{31,30,28},{24,24,23},{27,27,26},{39,38,35},{29,28,26},{43,41,36},{66,58,43},{248,247,244},{221,218,212},{163,158,148},{110,105,96},{35,34,31},{135,130,120}}),
            Obsidian = surf({ { 13, 13, 17 }, { 10, 10, 14 }, { 20, 20, 25 }, { 28, 28, 34 }, { 20, 20, 24 }, { 31, 31, 36 }, { 41, 41, 48 }, { 242, 243, 246 }, { 180, 184, 191 }, { 124, 127, 136 }, { 85, 85, 95 }, { 32, 33, 38 }, { 141, 145, 153 } }),
            Max = surf({ { 14, 10, 10 }, { 10, 7, 7 }, { 21, 14, 14 }, { 29, 18, 18 }, { 20, 13, 13 }, { 32, 20, 20 }, { 43, 26, 26 }, { 248, 236, 236 }, { 200, 160, 160 }, { 142, 102, 102 }, { 96, 66, 66 }, { 36, 20, 20 }, { 160, 110, 110 } }),
            ["Neon purple"] = surf({ { 14, 12, 20 }, { 10, 8, 16 }, { 22, 18, 32 }, { 30, 24, 44 }, { 18, 14, 28 }, { 32, 26, 48 }, { 44, 36, 64 }, { 248, 244, 255 }, { 196, 184, 220 }, { 140, 128, 164 }, { 96, 88, 118 }, { 48, 40, 68 }, { 160, 148, 188 } }),
            Ice = surf({ { 12, 16, 24 }, { 8, 12, 20 }, { 18, 24, 36 }, { 26, 32, 48 }, { 16, 20, 32 }, { 28, 36, 52 }, { 40, 50, 70 }, { 240, 248, 255 }, { 180, 200, 228 }, { 120, 140, 172 }, { 82, 98, 128 }, { 36, 46, 64 }, { 148, 168, 204 } }),
            Rose = surf({ { 22, 12, 18 }, { 18, 8, 14 }, { 34, 18, 28 }, { 44, 24, 38 }, { 28, 14, 22 }, { 46, 26, 40 }, { 62, 36, 54 }, { 255, 242, 248 }, { 220, 176, 198 }, { 168, 122, 148 }, { 118, 82, 104 }, { 58, 32, 48 }, { 188, 142, 168 } }),
            Mint = surf({ { 10, 18, 16 }, { 7, 14, 12 }, { 16, 28, 24 }, { 22, 38, 32 }, { 14, 24, 20 }, { 24, 42, 36 }, { 34, 58, 48 }, { 238, 255, 248 }, { 176, 214, 198 }, { 118, 158, 138 }, { 78, 108, 92 }, { 32, 52, 44 }, { 142, 182, 162 } }),
            Gold = surf({ { 18, 14, 8 }, { 14, 10, 6 }, { 28, 22, 14 }, { 38, 30, 18 }, { 24, 18, 12 }, { 42, 34, 22 }, { 58, 46, 30 }, { 255, 248, 236 }, { 220, 196, 160 }, { 168, 142, 108 }, { 118, 96, 72 }, { 52, 40, 28 }, { 188, 162, 124 } }),
            Mono = surf({ { 16, 16, 18 }, { 12, 12, 14 }, { 26, 26, 30 }, { 34, 34, 40 }, { 22, 22, 26 }, { 36, 36, 42 }, { 50, 50, 58 }, { 248, 248, 252 }, { 188, 188, 198 }, { 132, 132, 144 }, { 88, 88, 98 }, { 42, 42, 48 }, { 156, 156, 168 } }),
            ["Max Cute"] = surf({ { 24, 14, 22 }, { 19, 10, 18 }, { 35, 20, 32 }, { 46, 27, 42 }, { 30, 17, 27 }, { 48, 29, 43 }, { 64, 38, 56 }, { 255, 240, 248 }, { 226, 178, 205 }, { 172, 122, 152 }, { 120, 82, 106 }, { 62, 35, 54 }, { 196, 146, 176 } }),
            ["Max Pride"] = surf({ { 14, 13, 18 }, { 10, 9, 14 }, { 21, 20, 27 }, { 28, 26, 35 }, { 19, 18, 25 }, { 30, 28, 37 }, { 41, 38, 50 }, { 244, 242, 248 }, { 172, 166, 184 }, { 114, 108, 126 }, { 78, 73, 88 }, { 40, 37, 48 }, { 126, 120, 136 } }),
            ["Max Trans"] = surf({ { 13, 15, 24 }, { 9, 11, 19 }, { 20, 23, 35 }, { 27, 31, 46 }, { 17, 20, 31 }, { 29, 33, 48 }, { 40, 45, 64 }, { 240, 246, 255 }, { 180, 198, 224 }, { 122, 138, 166 }, { 82, 94, 118 }, { 38, 43, 62 }, { 142, 158, 186 } }),
            ["Max Femboy"] = surf({ { 20, 15, 28 }, { 15, 11, 22 }, { 29, 22, 40 }, { 38, 29, 52 }, { 24, 18, 34 }, { 40, 31, 54 }, { 55, 43, 73 }, { 250, 242, 255 }, { 214, 190, 232 }, { 160, 136, 184 }, { 110, 92, 130 }, { 52, 40, 70 }, { 180, 156, 204 } }),
            ["Max Xmas"] = surf({ { 10, 20, 16 }, { 7, 15, 12 }, { 15, 29, 23 }, { 21, 38, 30 }, { 12, 24, 19 }, { 22, 40, 32 }, { 32, 55, 44 }, { 244, 250, 246 }, { 186, 214, 198 }, { 124, 154, 138 }, { 84, 108, 96 }, { 30, 52, 42 }, { 152, 178, 164 } }),
            ["Max Matcha"] = surf({ { 17, 19, 13 }, { 13, 15, 10 }, { 25, 28, 19 }, { 33, 37, 25 }, { 21, 24, 16 }, { 35, 39, 27 }, { 48, 53, 37 }, { 246, 242, 226 }, { 208, 206, 180 }, { 152, 152, 124 }, { 106, 108, 86 }, { 46, 51, 35 }, { 172, 174, 144 } }),
        }
        local function rgbs(t: { { number } }): { Color3 }
            local out = {}
            for i, c in ipairs(t) do
                out[i] = Color3.fromRGB(c[1], c[2], c[3])
            end
            return out
        end



        UI.THEME_FX = {
            ["Plex blue"] = {
                key = "plex",
                flag = rgbs({ { 255, 76, 108 }, { 255, 158, 58 }, { 255, 224, 76 }, { 72, 210, 124 }, { 70, 148, 255 }, { 177, 92, 240 } }),
                tag = rgbs({ { 255, 106, 170 }, { 108, 156, 255 }, { 184, 104, 242 } }),
                ink = Color3.fromRGB(46, 20, 58), ring = Color3.fromRGB(255, 206, 236),
                colors = rgbs({ { 255, 108, 172 }, { 255, 210, 92 }, { 86, 208, 142 }, { 92, 160, 255 }, { 190, 104, 242 } }),
                sprites = { "heart", "star", "butterfly" }, rise = true, intro = "burst",
            },
            ["Max Pride"] = {
                key = "pride",
                flag = rgbs({ { 255, 72, 72 }, { 255, 154, 46 }, { 255, 226, 64 }, { 60, 204, 110 }, { 64, 140, 255 }, { 170, 90, 230 } }),
                tag = rgbs({ { 255, 86, 86 }, { 255, 170, 60 }, { 240, 214, 60 }, { 70, 200, 110 }, { 70, 146, 255 }, { 170, 96, 232 } }),
                ink = Color3.fromRGB(40, 12, 44), ring = Color3.fromRGB(255, 255, 255),
                sprites = { "heart", "heart", "star" }, rise = true, intro = "burst",
            },
            ["Max Trans"] = {
                key = "trans",
                flag = rgbs({ { 91, 206, 250 }, { 245, 169, 184 }, { 255, 255, 255 }, { 245, 169, 184 }, { 91, 206, 250 } }),
                tag = rgbs({ { 110, 212, 252 }, { 170, 190, 250 }, { 245, 150, 184 } }),
                ink = Color3.fromRGB(26, 44, 96), ring = Color3.fromRGB(190, 232, 255),
                colors = rgbs({ { 91, 206, 250 }, { 245, 169, 184 }, { 255, 255, 255 } }),
                sprites = { "heart", "butterfly", "star" }, rise = true, intro = "burst",
            },
            ["Max Femboy"] = {
                key = "femboy",
                flag = rgbs({ { 214, 98, 170 }, { 240, 172, 210 }, { 255, 255, 255 }, { 106, 197, 243 }, { 255, 255, 255 }, { 240, 172, 210 }, { 214, 98, 170 } }),
                tag = rgbs({ { 255, 176, 222 }, { 240, 118, 196 }, { 120, 194, 246 } }),
                ink = Color3.fromRGB(86, 24, 84), ring = Color3.fromRGB(255, 190, 230),
                colors = rgbs({ { 247, 138, 205 }, { 240, 172, 210 }, { 106, 197, 243 }, { 255, 255, 255 } }),
                sprites = { "paw", "heart", "paw" }, rise = true, intro = "burst",
            },
            ["Max Xmas"] = {
                key = "xmas",
                flag = rgbs({ { 255, 84, 98 }, { 255, 214, 120 }, { 70, 196, 120 } }),
                ribbon = rgbs({ { 255, 84, 98 }, { 255, 255, 255 }, { 255, 84, 98 }, { 255, 255, 255 }, { 255, 84, 98 }, { 255, 255, 255 }, { 255, 84, 98 }, { 255, 255, 255 }, { 255, 84, 98 } }),
                tag = rgbs({ { 255, 110, 118 }, { 214, 30, 58 } }),
                ink = Color3.fromRGB(90, 8, 22), ring = Color3.fromRGB(255, 214, 120), candy = true,
                colors = rgbs({ { 255, 255, 255 }, { 232, 244, 255 }, { 255, 255, 255 }, { 255, 214, 120 } }),
                sprites = { "snow", "snow", "snow", "star" }, rise = false, intro = "fall",
            },
            ["Max Matcha"] = {
                key = "matcha",
                flag = rgbs({ { 238, 232, 204 }, { 190, 226, 140 }, { 140, 196, 90 }, { 84, 140, 60 } }),
                tag = rgbs({ { 196, 230, 146 }, { 96, 156, 66 } }),
                ink = Color3.fromRGB(28, 56, 18), ring = Color3.fromRGB(238, 232, 204),
                colors = rgbs({ { 170, 214, 110 }, { 124, 182, 80 }, { 204, 232, 150 }, { 96, 150, 62 } }),
                sprites = { "leaf", "leaf", "leaf", "star" }, rise = false, intro = "fall",
            },
        }
        for _, fx in pairs(UI.THEME_FX) do
            fx.colors = fx.colors or fx.flag
        end


        UI.CUTE_DRIFT = {
            key = "cute",
            sprites = { "butterfly", "heart", "heart" },
            colors = rgbs({ { 255, 196, 226 }, { 255, 118, 186 }, { 206, 84, 206 }, { 255, 255, 255 } }),
            rise = true,
            intro = "burst",
        }
    end


    UI.THEME_METAL = {
        Obsidian = {
            hi = Color3.fromRGB(243, 240, 253), lite = Color3.fromRGB(183, 176, 212), mid = Color3.fromRGB(74, 67, 104),
            dark = Color3.fromRGB(20, 18, 29), ink = Color3.fromRGB(20, 18, 29), edge = Color3.fromRGB(111, 104, 144),
        },

        Max = {
            hi = Color3.fromRGB(255, 205, 205), lite = Color3.fromRGB(214, 40, 40), mid = Color3.fromRGB(112, 12, 12),
            dark = Color3.fromRGB(24, 4, 4), ink = Color3.fromRGB(24, 4, 4), edge = Color3.fromRGB(96, 10, 10),
        },
    }

    UI.BLOOD_METAL = { hi = Color3.fromRGB(255, 214, 214), lite = Color3.fromRGB(255, 42, 42), mid = Color3.fromRGB(139, 0, 0) }
    function UI.maxThemeName(): string
        local t = cfg.maxTheme
        return if type(t) == "string" and (THEMES[t] ~= nil or t == "Custom") then t else "Max"
    end
    if cfg.theme == "Plex pink" then cfg.theme = "Plex blue" end
    do
        local oldPurple, plexBlue = { 173, 102, 255 }, { 73, 145, 255 }
        local changed = false
        for _, k in ipairs({ "colEspVisible", "colTracer", "colChamsFill", "colWorldTint", "colShotTracer", "colVm", "colSelf" }) do
            local v = cfg[k]
            if type(v) == "table" and v[1] == oldPurple[1] and v[2] == oldPurple[2] and v[3] == oldPurple[3] then
                cfg[k] = table.clone(plexBlue)
                changed = true
            end
        end
        if changed then saveConfigSoon() end
    end
    if S.edition == "max" then
        for i, name in ipairs({ "Max", "Max Cute", "Max Pride", "Max Trans", "Max Femboy", "Max Xmas", "Max Matcha", "Max Blood" }) do
            table.insert(THEME_ORDER, i + 1, name)
        end
        cfg.theme = UI.maxThemeName()
        local mark = DATA.dir .. "/max_theme.txt"
        local done = pcall(function()
            return EXEC.isfile(mark) or error("")
        end)
        if not done then
            local purple, blue = { 173, 102, 255 }, { 73, 145, 255 }
            for _, k in ipairs({ "colEspVisible", "colTracer", "colChamsFill", "colWorldTint", "colShotTracer", "colVm", "colSelf" }) do
                local v = cfg[k]
                if type(v) == "table" and v[1] == purple[1] and v[2] == purple[2] and v[3] == purple[3] then
                    cfg[k] = table.clone(blue)
                end
            end
            pcall(function()
                EXEC.mkdirs(DATA.dir)
                EXEC.writefile(mark, "1")
            end)
            saveConfigSoon()
        end
    elseif UI.MAX_THEMES[cfg.theme] then


        cfg.theme = "Obsidian"
    else


        local mark = DATA.dir .. "/obsidian_theme.txt"
        local done = pcall(function()
            return EXEC.isfile(mark) or error("")
        end)
        if not done then
            if cfg.theme == "Neon purple" then
                cfg.theme = "Obsidian"
                saveConfigSoon()
            end
            pcall(function()
                EXEC.mkdirs(DATA.dir)
                EXEC.writefile(mark, "1")
            end)
        end
    end
    UI.THEME_ORDER = THEME_ORDER
    UI.THEMES = THEMES
    function UI.themeName(): string
        if S.edition == "max" then
            return UI.maxThemeName()
        end
        return cfg.theme
    end
    UI.themeListeners = UI.themeListeners or {}
    function UI.onThemeChanged(callback: () -> ())
        table.insert(UI.themeListeners, callback)
        return function()
            local index = table.find(UI.themeListeners, callback)
            if index then table.remove(UI.themeListeners, index) end
        end
    end
    function UI.hex(col: any, fallback: string?): string
        if typeof(col) == "Color3" then
            return col:ToHex()
        end
        return fallback or "ffffff"
    end
    function UI.localUserId(): number
        local lp = Players.LocalPlayer
        if lp then
            return tonumber(lp.UserId) or 0
        end
        return 0
    end
    function UI.localUserName(): string
        local lp = Players.LocalPlayer
        if lp then
            local n = lp.DisplayName
            if type(n) == "string" and n ~= "" then
                return n
            end
            n = lp.Name
            if type(n) == "string" and n ~= "" then
                return n
            end
        end
        return "player"
    end
    function UI.localUserHandle(): string
        local lp = Players.LocalPlayer
        if lp and type(lp.Name) == "string" and lp.Name ~= "" then
            return lp.Name
        end
        return "player"
    end
    function UI.applyTheme()
        local name = UI.themeName()
        local pair = THEMES[name]
        if UI.MAX_THEMES[name] and S.edition ~= "max" then
            pair = THEMES.Obsidian
            name = "Obsidian"
        end
        UI.metal = UI.THEME_METAL[name]

        UI.C_BASE = UI.C_BASE or table.clone(C)
        local surf = UI.THEME_SURFACES[name]
        for k, v in pairs(UI.C_BASE) do
            if k ~= "accent" and k ~= "accent2" and k ~= "light" then
                C[k] = if surf and surf[k] then surf[k] else v
            end
        end
        if name == "Custom" or not pair then
            pair = { rgb(cfg.colAccent), rgb(cfg.colAccent2) }
        end
        C.accent, C.accent2 = pair[1], pair[2]
        C.light = false
        S.themeApplied = name
        for _, callback in ipairs(UI.themeListeners) do
            task.defer(function() pcall(callback, C, name) end)
        end
    end

    function UI.themeFx(): any
        return UI.THEME_FX[S.themeApplied or ""]
    end

    function UI.driftFx(): any
        local fx = UI.themeFx()
        if fx then
            return fx
        end
        return if S.edition == "max" and S.themeApplied == "Max Cute" then UI.CUTE_DRIFT else nil
    end

    function UI.fxSeq(cols: { Color3 }, hard: boolean?): ColorSequence
        local n = #cols
        if n < 2 then
            return ColorSequence.new(cols[1] or Color3.new(1, 1, 1))
        end
        local kps = {}
        if hard then
            for i, c in ipairs(cols) do
                table.insert(kps, ColorSequenceKeypoint.new(if i == 1 then 0 else (i - 1) / n + 0.001, c))
                table.insert(kps, ColorSequenceKeypoint.new(i / n, c))
            end
        else
            for i, c in ipairs(cols) do
                table.insert(kps, ColorSequenceKeypoint.new((i - 1) / (n - 1), c))
            end
        end
        return ColorSequence.new(kps)
    end
    UI.applyTheme()




    UI.GLOW_IMAGE = "rbxassetid://6014261993"


    function UI.pngEncode(N: number, pixel: (number, number) -> (number, number, number, number)): string
        local bxor, band, rshift = bit32.bxor, bit32.band, bit32.rshift
        local crcTable = table.create(256)
        for i = 0, 255 do
            local c = i
            for _ = 1, 8 do
                c = if band(c, 1) == 1 then bxor(0xEDB88320, rshift(c, 1)) else rshift(c, 1)
            end
            crcTable[i + 1] = c
        end
        local function crc32(s: string): number
            local c = 0xFFFFFFFF
            for i = 1, #s do
                c = bxor(crcTable[band(bxor(c, string.byte(s, i)), 0xFF) + 1], rshift(c, 8))
            end
            return bxor(c, 0xFFFFFFFF)
        end
        local function u32(n: number): string
            return string.char(band(rshift(n, 24), 255), band(rshift(n, 16), 255), band(rshift(n, 8), 255), band(n, 255))
        end
        local rows = table.create(N)
        for y = 0, N - 1 do
            local px = table.create(N * 4 + 1)
            px[1] = 0
            for x = 0, N - 1 do
                local i = x * 4 + 2
                px[i], px[i + 1], px[i + 2], px[i + 3] = pixel(x, y)
            end
            rows[y + 1] = string.char(table.unpack(px))
        end
        local raw = table.concat(rows)
        local a1, a2 = 1, 0
        for i = 1, #raw do
            a1 = (a1 + string.byte(raw, i)) % 65521
            a2 = (a2 + a1) % 65521
        end
        local len = #raw
        local nlen = bxor(len, 0xFFFF)
        local zlib = "\120\1" .. string.char(1, band(len, 255), rshift(len, 8), band(nlen, 255), rshift(nlen, 8)) .. raw .. u32(a2 * 65536 + a1)
        local function chunk(kind: string, data: string): string
            return u32(#data) .. kind .. data .. u32(crc32(kind .. data))
        end
        return "\137PNG\r\n\26\n" .. chunk("IHDR", u32(N) .. u32(N) .. "\8\6\0\0\0") .. chunk("IDAT", zlib) .. chunk("IEND", "")
    end

    function UI.pngAsset(file: string, N: number, pixel: (number, number) -> (number, number, number, number)): string?
        if type(EXEC.getcustomasset) ~= "function" or not EXEC.caps.files then
            return nil
        end
        local path = UI.assetPath(file)
        local ok, id = pcall(function()
            if not (EXEC.isfile and EXEC.isfile(path)) then
                local png = UI.pngEncode(N, pixel)
                pcall(function()
                    for _, dir in ipairs({ "cocaine", UI.ASSET_DIR }) do
                        if not (EXEC.isfolder and EXEC.isfolder(dir)) and EXEC.makefolder then
                            EXEC.makefolder(dir)
                        end
                    end
                end)
                EXEC.writefile(path, png)
            end
            return EXEC.getcustomasset(path)
        end)
        return if ok and type(id) == "string" then id else nil
    end
    function UI.buildGlowPng(): string?
        local mid = 63 / 2
        return UI.pngAsset("glow64.png", 64, function(x: number, y: number)
            local d = math.sqrt((x - mid) ^ 2 + (y - mid) ^ 2) / 32
            local a = math.clamp(1 - d, 0, 1)
            a = a * a * (3 - 2 * a)
            return 255, 255, 255, math.floor(a * 255 + 0.5)
        end)
    end
    UI.glowRadial = UI.buildGlowPng()



    function UI.buildNoisePng(): string?
        local rng = Random.new(0xC0CA)
        return UI.pngAsset("acrylic96.png", 96, function()
            local c = if rng:NextNumber() < 0.5 then 0 else 255
            local a = math.floor((0.35 + 0.65 * rng:NextNumber()) * 255 + 0.5)
            return c, c, c, a
        end)
    end
    UI.noiseTile = UI.buildNoisePng()




    UI.faceIcons = {}
    function UI.buildFacePng(N: number): string?
        N = math.clamp(math.floor(N + 0.5), 8, 127)
        if UI.faceIcons[N] ~= nil then
            return UI.faceIcons[N] or nil
        end
        local function seg(px: number, py: number, ax: number, ay: number, bx: number, by: number): number
            local dx, dy = bx - ax, by - ay
            local t = math.clamp(((px - ax) * dx + (py - ay) * dy) / (dx * dx + dy * dy), 0, 1)
            local qx, qy = ax + dx * t - px, ay + dy * t - py
            return math.sqrt(qx * qx + qy * qy)
        end
        local ringW = math.max(0.045, 0.78 / N)
        local lineW = math.max(0.036, 0.72 / N)
        local id = UI.pngAsset(("face%d.png"):format(N), N, function(x: number, y: number)
            local u, v = (x + 0.5) / N, (y + 0.5) / N
            local d = math.abs(math.sqrt((u - 0.5) ^ 2 + (v - 0.5) ^ 2) - 0.41) - ringW
            for _, e in ipairs({ { 0.35, 0.42 }, { 0.65, 0.42 } }) do
                local s = 0.075
                d = math.min(d, seg(u, v, e[1] - s, e[2] - s, e[1] + s, e[2] + s) - lineW)
                d = math.min(d, seg(u, v, e[1] - s, e[2] + s, e[1] + s, e[2] - s) - lineW)
            end
            d = math.min(d, seg(u, v, 0.37, 0.67, 0.63, 0.67) - lineW)
            local a = math.clamp(0.5 - d * N, 0, 1)
            return 255, 255, 255, math.floor(a * 255 + 0.5)
        end)
        UI.faceIcons[N] = id or false
        return id
    end
    UI.faceIcon = UI.buildFacePng(96)



    UI.themeLogos = {}
    UI.fxSprites = {}
    do
        local sqrt, abs, max, min, clamp, floor = math.sqrt, math.abs, math.max, math.min, math.clamp, math.floor
        local PN, pr, pg, pb, pa = 1, 0, 0, 0, 0
        local function len(x: number, y: number): number
            return sqrt(x * x + y * y)
        end

        local function paint(d: number, c: { number }, a: number?)
            local k = clamp(0.5 - d * PN, 0, 1) * (a or 1)
            if k <= 0 then
                return
            end
            local j = 1 - k
            pr, pg, pb, pa = pr * j + c[1] * k, pg * j + c[2] * k, pb * j + c[3] * k, pa * j + k
        end
        local function circle(u: number, v: number, cx: number, cy: number, r: number): number
            return len(u - cx, v - cy) - r
        end


        local function ellipse(u: number, v: number, cx: number, cy: number, rx: number, ry: number, rot: number?): number
            local x, y = u - cx, v - cy
            if rot then
                local c, s = math.cos(rot), math.sin(rot)
                x, y = x * c + y * s, y * c - x * s
            end
            local k0 = len(x / rx, y / ry)
            local k1 = len(x / (rx * rx), y / (ry * ry))
            return if k1 > 1e-9 then k0 * (k0 - 1) / k1 else -min(rx, ry)
        end
        local function seg(u: number, v: number, ax: number, ay: number, bx: number, by: number, w: number): number
            local dx, dy = bx - ax, by - ay
            local t = clamp(((u - ax) * dx + (v - ay) * dy) / (dx * dx + dy * dy), 0, 1)
            return len(ax + dx * t - u, ay + dy * t - v) - w
        end
        local function box(u: number, v: number, cx: number, cy: number, hw: number, hh: number, r: number): number
            local qx, qy = abs(u - cx) - hw + r, abs(v - cy) - hh + r
            return len(max(qx, 0), max(qy, 0)) + min(max(qx, qy), 0) - r
        end

        local function tri(u: number, v: number, ax: number, ay: number, bx: number, by: number, cx: number, cy: number): number
            local e0x, e0y, e1x, e1y, e2x, e2y = bx - ax, by - ay, cx - bx, cy - by, ax - cx, ay - cy
            local v0x, v0y, v1x, v1y, v2x, v2y = u - ax, v - ay, u - bx, v - by, u - cx, v - cy
            local t0 = clamp((v0x * e0x + v0y * e0y) / (e0x * e0x + e0y * e0y), 0, 1)
            local t1 = clamp((v1x * e1x + v1y * e1y) / (e1x * e1x + e1y * e1y), 0, 1)
            local t2 = clamp((v2x * e2x + v2y * e2y) / (e2x * e2x + e2y * e2y), 0, 1)
            local p0x, p0y, p1x, p1y, p2x, p2y = v0x - e0x * t0, v0y - e0y * t0, v1x - e1x * t1, v1y - e1y * t1, v2x - e2x * t2, v2y - e2y * t2
            local sg = if e0x * e2y - e0y * e2x < 0 then -1 else 1
            local dd = min(p0x * p0x + p0y * p0y, p1x * p1x + p1y * p1y, p2x * p2x + p2y * p2y)
            local ss = min(sg * (v0x * e0y - v0y * e0x), sg * (v1x * e1y - v1y * e1x), sg * (v2x * e2y - v2y * e2x))
            return if ss < 0 then sqrt(dd) else -sqrt(dd)
        end

        local function heart(u: number, v: number, cx: number, cy: number, s: number): number
            local x, y = abs(u - cx) / s, (cy - v) / s + 0.55
            if x + y > 1 then
                return (len(x - 0.25, y - 0.75) - 0.35355) * s
            end
            local m = max(x + y, 0) * 0.5
            return sqrt(min(x * x + (y - 1) ^ 2, (x - m) ^ 2 + (y - m) ^ 2)) * (if x < y then -s else s)
        end

        local function sparkle(u: number, v: number, cx: number, cy: number, r: number): number
            local x, y = abs(u - cx), abs(v - cy)
            local w = r * 0.3
            local k = 1 / sqrt(1 / (w * w) + 1 / (r * r))
            return min((x / w + y / r - 1) * k, (x / r + y / w - 1) * k)
        end
        local function xEye(u: number, v: number, cx: number, cy: number, s: number, w: number): number
            return min(seg(u, v, cx - s, cy - s, cx + s, cy + s, w), seg(u, v, cx - s, cy + s, cx + s, cy - s, w))
        end
        local mix = { 0, 0, 0 }
        local function lerp3(a: { number }, b: { number }, t: number): { number }
            t = clamp(t, 0, 1)
            mix[1], mix[2], mix[3] = a[1] + (b[1] - a[1]) * t, a[2] + (b[2] - a[2]) * t, a[3] + (b[3] - a[3]) * t
            return mix
        end

        local function bands(cols: { { number } }, t0: number, t1: number, v: number): { number }
            local n = #cols
            local a = cols[clamp(floor((v - 0.3 / PN - t0) / (t1 - t0) * n), 0, n - 1) + 1]
            local b = cols[clamp(floor((v + 0.3 / PN - t0) / (t1 - t0) * n), 0, n - 1) + 1]
            return lerp3(a, b, 0.5)
        end
        local WHITE, INK, SHADE = { 255, 255, 255 }, { 34, 18, 42 }, { 14, 8, 20 }
        local PRIDE = { { 255, 72, 72 }, { 255, 154, 46 }, { 255, 226, 64 }, { 60, 204, 110 }, { 64, 140, 255 }, { 170, 90, 230 } }
        local ART = {}

        function ART.pride(u: number, v: number, n: number)
            local d = heart(u, v, 0.5, 0.53, 0.74)
            paint(d - 0.04, SHADE, 0.55)
            if d < 2 / n then
                paint(d, bands(PRIDE, 0.16, 0.8, v))
            end
            paint(ellipse(u, v, 0.33, 0.29, 0.085, 0.045, -0.7), WHITE, 0.5)
            if n >= 30 and v > 0.38 and v < 0.7 then
                local w = max(0.024, 0.7 / n)
                paint(min(xEye(u, v, 0.385, 0.46, 0.05, w), xEye(u, v, 0.615, 0.46, 0.05, w), seg(u, v, 0.45, 0.62, 0.55, 0.62, w)), INK, 0.92)
            end
            if n >= 18 and u > 0.7 and v < 0.3 then
                paint(sparkle(u, v, 0.84, 0.16, 0.11), WHITE)
            end
        end

        function ART.egirl(u: number, v: number, n: number)
            local x = 0.5 + abs(u - 0.5)
            local hair = ellipse(u, v, 0.5, 0.56, 0.38, 0.43)
            local face = ellipse(u, v, 0.5, 0.57, 0.27, 0.31)
            local ear = if x > 0.64 and v < 0.42 then tri(x, v, 0.62, 0.35, 0.76, 0.08, 0.83, 0.4) else 1
            paint(min(hair, ear) - 0.045, SHADE, 0.62)
            paint(min(hair, ear), lerp3({ 222, 76, 184 }, { 96, 84, 224 }, v))
            paint(face, lerp3({ 255, 232, 226 }, { 250, 188, 208 }, (v - 0.35) / 0.55))
            local fringe = min(
                tri(u, v, 0.24, 0.27, 0.48, 0.18, 0.41, 0.57),
                tri(u, v, 0.39, 0.2, 0.62, 0.18, 0.51, 0.55),
                tri(u, v, 0.55, 0.2, 0.77, 0.3, 0.61, 0.57)
            )
            paint(fringe, lerp3({ 246, 90, 192 }, { 110, 88, 232 }, u))
            if n >= 24 then
                local w = max(0.014, 0.5 / n)
                paint(seg(u, v, 0.33, 0.56, 0.43, 0.55, w), INK)
                paint(seg(u, v, 0.57, 0.55, 0.67, 0.56, w), INK)
                paint(circle(u, v, 0.385, 0.555, 0.024), { 82, 176, 255 })
                paint(circle(u, v, 0.615, 0.555, 0.024), { 190, 92, 240 })
                paint(circle(u, v, 0.394, 0.545, 0.008), WHITE)
                paint(circle(u, v, 0.624, 0.545, 0.008), WHITE)
                paint(max(abs(circle(u, v, 0.5, 0.7, 0.045)) - w, 0.7 - v), { 126, 38, 78 })
            end
            paint(ellipse(u, v, 0.31, 0.67, 0.06, 0.03), { 255, 92, 150 }, 0.5)
            paint(ellipse(u, v, 0.69, 0.67, 0.06, 0.03), { 255, 92, 150 }, 0.5)
            if v > 0.82 then paint(box(u, v, 0.5, 0.88, 0.24, 0.055, 0.03), bands(PRIDE, 0.25, 0.75, u)) end
            if n >= 20 and u > 0.7 and v < 0.34 then paint(sparkle(u, v, 0.84, 0.16, 0.1), WHITE) end
        end

        local TBLUE, TPINK = { 91, 206, 250 }, { 245, 169, 184 }
        function ART.trans(u: number, v: number, n: number)
            local x = 0.5 + abs(u - 0.5)
            local up = ellipse(x, v, 0.69, 0.35, 0.21, 0.15, -0.6)
            local lo = ellipse(x, v, 0.65, 0.66, 0.15, 0.115, 0.55)
            local body = min(seg(u, v, 0.5, 0.3, 0.5, 0.76, 0.04), circle(u, v, 0.5, 0.25, 0.05))
            local ant = min(seg(x, v, 0.5, 0.23, 0.6, 0.1, 0.014), circle(x, v, 0.6, 0.1, 0.028))
            paint(min(up, lo, body) - 0.04, SHADE, 0.55)
            if n >= 18 then
                paint(ant - 0.022, SHADE, 0.45)
                paint(ant, WHITE)
            end
            paint(lo, TPINK)
            paint(ellipse(x, v, 0.66, 0.665, 0.085, 0.06, 0.55), { 252, 214, 222 }, 0.9)
            paint(up, TBLUE)
            paint(ellipse(x, v, 0.7, 0.35, 0.12, 0.08, -0.6), { 178, 232, 252 }, 0.9)
            if n >= 22 then
                paint(circle(x, v, 0.8, 0.26, 0.03), WHITE)
                paint(circle(x, v, 0.73, 0.73, 0.022), WHITE, 0.9)
            end
            paint(body, WHITE)
        end


        local FPINK = { 247, 138, 205 }
        function ART.femboy(u: number, v: number, n: number)
            local x = 0.5 + abs(u - 0.5)
            local head = ellipse(u, v, 0.5, 0.6, 0.33, 0.28)
            local ear = if x > 0.55 and v < 0.56 then tri(x, v, 0.62, 0.4, 0.79, 0.1, 0.84, 0.46) - 0.02 else 1
            local tuft = if x > 0.7 and v > 0.46 and v < 0.86 then min(tri(x, v, 0.78, 0.53, 0.885, 0.59, 0.8, 0.645), tri(x, v, 0.77, 0.655, 0.865, 0.725, 0.73, 0.78)) - 0.01 else 1
            local sil = min(head, ear, tuft)
            paint(sil - 0.075, SHADE, 0.5)
            paint(sil - 0.045, FPINK)
            paint(sil, lerp3(WHITE, { 234, 222, 248 }, (v - 0.45) / 0.45))
            if ear < 0.1 then
                paint(tri(x, v, 0.66, 0.39, 0.78, 0.17, 0.81, 0.44) - 0.008, { 255, 164, 208 })
            end
            paint(ellipse(x, v, 0.63, 0.6, 0.056, 0.076), { 44, 26, 64 })
            if n >= 20 then
                paint(circle(x, v, 0.648, 0.574, 0.022), WHITE)
            end
            if n >= 30 then
                paint(circle(x, v, 0.615, 0.63, 0.011), WHITE, 0.8)
                local w = max(0.009, 0.4 / n)
                for i = 0, 2 do
                    paint(seg(x, v, 0.69 + i * 0.035, 0.705, 0.71 + i * 0.035, 0.668, w), { 255, 110, 172 })
                end
                paint(max(abs(circle(x, v, 0.53, 0.69, 0.03)) - max(0.009, 0.45 / n), 0.69 - v), INK)
            else
                paint(ellipse(x, v, 0.73, 0.69, 0.05, 0.028), { 255, 120, 180 }, 0.6)
            end
            paint(ellipse(u, v, 0.5, 0.665, 0.022, 0.015), { 255, 140, 190 })
            if n >= 18 and u > 0.6 and v < 0.45 then
                paint(ellipse(u, v, 0.715, 0.3, 0.068, 0.048, -0.35), { 240, 110, 196 })
                paint(ellipse(u, v, 0.845, 0.3, 0.068, 0.048, 0.35), { 240, 110, 196 })
                paint(circle(u, v, 0.78, 0.3, 0.032), { 110, 196, 246 })
            end
        end

        local RED = { 232, 40, 58 }
        function ART.xmas(u: number, v: number, n: number)
            local face = circle(u, v, 0.47, 0.6, 0.31)
            local hat = min(tri(u, v, 0.17, 0.41, 0.78, 0.36, 0.62, 0.06) - 0.015, seg(u, v, 0.62, 0.07, 0.84, 0.2, 0.04))
            local pom = circle(u, v, 0.86, 0.22, 0.07)
            local band = seg(u, v, 0.15, 0.43, 0.8, 0.37, 0.065)
            paint(min(face, hat, pom, band) - 0.04, SHADE, 0.55)
            paint(face, lerp3(WHITE, { 210, 230, 244 }, (v - 0.45) / 0.45))
            if n >= 20 then
                paint(circle(u, v, 0.31, 0.71, 0.05), { 255, 90, 100 }, 0.35)
                paint(circle(u, v, 0.63, 0.71, 0.05), { 255, 90, 100 }, 0.35)
            end
            local w = max(0.024, 0.7 / n)
            paint(min(xEye(u, v, 0.37, 0.6, 0.05, w), xEye(u, v, 0.57, 0.6, 0.05, w), seg(u, v, 0.41, 0.74, 0.53, 0.74, w)), INK)
            paint(hat, lerp3(RED, { 168, 14, 38 }, (0.4 - v) / 0.34))
            paint(band, { 244, 248, 252 })
            paint(pom, WHITE)
            if n >= 28 and u < 0.4 and v < 0.5 then
                paint(ellipse(u, v, 0.22, 0.37, 0.06, 0.03, -0.5), { 46, 170, 90 })
                paint(ellipse(u, v, 0.31, 0.35, 0.06, 0.03, 0.45), { 46, 170, 90 })
                paint(circle(u, v, 0.265, 0.385, 0.024), { 255, 70, 82 })
            end
        end

        function ART.matcha(u: number, v: number, n: number)
            if n >= 18 and v < 0.34 then
                local sw = max(0.016, 0.45 / n)
                local fade = 0.6 * clamp((v - 0.08) / 0.1, 0, 1)
                paint(max(abs(u - (0.4 + 0.028 * math.sin(v * 30 + 4))) - sw, abs(v - 0.2) - 0.12), WHITE, fade)
                paint(max(abs(u - (0.6 + 0.028 * math.sin(v * 30 + 6))) - sw, abs(v - 0.2) - 0.12), WHITE, fade)
            end
            local body = max(ellipse(u, v, 0.5, 0.47, 0.41, 0.39), 0.45 - v)
            local rim = ellipse(u, v, 0.5, 0.45, 0.41, 0.085)
            local foot = box(u, v, 0.5, 0.885, 0.13, 0.035, 0.018)
            paint(min(body, rim, foot) - 0.04, SHADE, 0.55)
            paint(foot, { 196, 180, 150 })
            paint(body, lerp3({ 246, 240, 224 }, { 212, 198, 168 }, (v - 0.45) / 0.42))
            if n >= 26 then
                paint(max(body, abs(v - 0.8) - 0.018), { 128, 184, 72 }, 0.9)
            end
            paint(rim, { 250, 246, 234 })
            paint(ellipse(u, v, 0.5, 0.456, 0.355, 0.062), { 128, 184, 72 })
            paint(ellipse(u, v, 0.45, 0.45, 0.15, 0.028), { 186, 222, 126 }, 0.85)
            if n >= 20 and v > 0.5 and v < 0.8 then
                local w = max(0.024, 0.65 / n)
                paint(min(xEye(u, v, 0.39, 0.62, 0.042, w), xEye(u, v, 0.61, 0.62, 0.042, w), seg(u, v, 0.46, 0.72, 0.54, 0.72, w)), { 60, 44, 30 })
                paint(ellipse(u, v, 0.3, 0.7, 0.05, 0.028), { 255, 150, 160 }, 0.5)
                paint(ellipse(u, v, 0.7, 0.7, 0.05, 0.028), { 255, 150, 160 }, 0.5)
            end
        end
        function UI.themeLogoPng(key: string, size: number): string?
            local N = clamp(floor(size + 0.5), 8, 127)
            local ck = key .. N
            local c = UI.themeLogos[ck]
            if c ~= nil then
                return c or nil
            end
            local art = ART[key]
            local id = art and UI.pngAsset(("tlogo_%s_v1_%d.png"):format(key, N), N, function(x: number, y: number)
                PN, pr, pg, pb, pa = N, 0, 0, 0, 0
                art((x + 0.5) / N, (y + 0.5) / N, N)
                if pa <= 0.002 then
                    return 0, 0, 0, 0
                end
                return clamp(floor(pr / pa + 0.5), 0, 255), clamp(floor(pg / pa + 0.5), 0, 255), clamp(floor(pb / pa + 0.5), 0, 255), clamp(floor(pa * 255 + 0.5), 0, 255)
            end)
            UI.themeLogos[ck] = id or false
            return id
        end

        local SPRITE = {}
        function SPRITE.heart(u: number, v: number): (number, number?)
            return heart(u, v, 0.5, 0.54, 0.76), nil
        end
        function SPRITE.star(u: number, v: number): (number, number?)
            return sparkle(u, v, 0.5, 0.5, 0.46), nil
        end
        function SPRITE.paw(u: number, v: number): (number, number?)
            return min(ellipse(u, v, 0.5, 0.66, 0.22, 0.18), circle(u, v, 0.25, 0.42, 0.09), circle(u, v, 0.41, 0.27, 0.095), circle(u, v, 0.59, 0.27, 0.095), circle(u, v, 0.75, 0.42, 0.09)), nil
        end
        function SPRITE.snow(u: number, v: number): (number, number?)
            local d = circle(u, v, 0.5, 0.5, 0.07)
            for k = 0, 5 do
                local a = k * math.pi / 3
                local c, s = math.cos(a), math.sin(a)
                local bx, by = 0.5 + c * 0.26, 0.5 + s * 0.26
                d = min(d, seg(u, v, 0.5, 0.5, 0.5 + c * 0.42, 0.5 + s * 0.42, 0.04),
                    seg(u, v, bx, by, bx + math.cos(a - 0.7) * 0.13, by + math.sin(a - 0.7) * 0.13, 0.032),
                    seg(u, v, bx, by, bx + math.cos(a + 0.7) * 0.13, by + math.sin(a + 0.7) * 0.13, 0.032))
            end
            return d, nil
        end
        function SPRITE.leaf(u: number, v: number): (number, number?)
            local d = min(ellipse(u, v, 0.52, 0.48, 0.38, 0.19, -0.7), seg(u, v, 0.26, 0.7, 0.14, 0.82, 0.03))
            return d, seg(u, v, 0.26, 0.7, 0.76, 0.28, 0.018)
        end
        function SPRITE.butterfly(u: number, v: number): (number, number?)
            local x = 0.5 + abs(u - 0.5)
            return min(ellipse(x, v, 0.7, 0.36, 0.22, 0.16, -0.6), ellipse(x, v, 0.66, 0.68, 0.16, 0.12, 0.55), seg(u, v, 0.5, 0.28, 0.5, 0.78, 0.045)), nil
        end
        function UI.fxSprite(kind: string): string?
            local c = UI.fxSprites[kind]
            if c ~= nil then
                return c or nil
            end
            local fn = SPRITE[kind]
            local id = fn and UI.pngAsset(("fx_%s_v1.png"):format(kind), 24, function(x: number, y: number)
                local d, hole = fn((x + 0.5) / 24, (y + 0.5) / 24)
                local a = clamp(0.5 - d * 24, 0, 1)
                if hole then
                    a *= 1 - 0.65 * clamp(0.5 - hole * 24, 0, 1)
                end
                return 255, 255, 255, floor(a * 255 + 0.5)
            end)
            UI.fxSprites[kind] = id or false
            return id
        end
    end




    UI.falloffTiles = {}
    function UI.falloffTile(spread: number, radius: number?): (string?, Rect?)
        local rad = radius or 12
        local key = spread * 100 + rad
        local cached = UI.falloffTiles[key]
        if cached then
            return cached.id, cached.slice
        end
        local m = spread + rad
        local n = m * 2 + 4
        local c = n / 2
        local file = if rad == 12 then ("falloff%d.png"):format(spread) else ("falloff%d_%d.png"):format(spread, rad)
        local id = UI.pngAsset(file, n, function(x: number, y: number)
            local qx, qy = math.abs(x + 0.5 - c) - 2, math.abs(y + 0.5 - c) - 2
            local ox, oy = math.max(qx, 0), math.max(qy, 0)
            local d = math.sqrt(ox * ox + oy * oy) + math.min(math.max(qx, qy), 0) - rad
            if d <= 0 then
                return 255, 255, 255, 0
            end
            local t = math.clamp(1 - d / spread, 0, 1)
            return 255, 255, 255, math.floor(t * t * math.min(d, 1) * 255 + 0.5)
        end)
        local slice = Rect.new(m, m, n - m, n - m)
        UI.falloffTiles[key] = { id = id, slice = slice }
        return id, slice
    end
    function UI.glowAlpha(strength: number?): number
        local g = math.clamp((tonumber(cfg.uiGlow) or 45) / 100, 0, 1) * (strength or 1)
        return 1 - 0.8 * g
    end


    function UI.glow(parent: GuiObject, spread: number?, strength: number?, color: Color3?): ImageLabel
        local s = spread or 10
        local g = Instance.new("ImageLabel")
        g.Name = "Glow"
        g.BackgroundTransparency = 1
        g.ImageColor3 = color or C.accent
        if UI.glowRadial then
            g.Image = UI.glowRadial
            g.ScaleType = Enum.ScaleType.Stretch
        else
            g.Image = UI.GLOW_IMAGE
            g.ScaleType = Enum.ScaleType.Slice
            g.SliceCenter = Rect.new(49, 49, 450, 450)
            g.SliceScale = math.clamp(s / 40, 0.05, 1)
        end
        g.AnchorPoint = Vector2.new(0.5, 0.5)
        g.Position = UDim2.fromScale(0.5, 0.5)
        g.Size = UDim2.new(1, s * 2, 1, s * 2)
        g.ImageTransparency = UI.glowAlpha(strength)
        g:SetAttribute("glowStrength", strength or 1)
        g.Parent = parent
        return g
    end

    function UI.refreshGlows(root: Instance?)
        if not root then
            return
        end
        for _, d in ipairs(root:GetDescendants()) do
            if d.Name == "Glow" and d:IsA("ImageLabel") and d:GetAttribute("glowOff") ~= true then
                d.ImageTransparency = UI.glowAlpha(tonumber(d:GetAttribute("glowStrength")) or 1)
            end
        end
    end





    local TW_OPEN = TweenInfo.new(0.32, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local TW_TAB = TweenInfo.new(0.34, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local TW_TOGGLE = TweenInfo.new(0.26, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local TW_KNOB = TweenInfo.new(0.22, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
    local TW_HOVER = TweenInfo.new(0.20, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
    local TW_TOAST_IN = TweenInfo.new(0.30, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local TW_TOAST_OUT = TweenInfo.new(0.26, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
    UI.TW = {
        open = TW_OPEN, close = TweenInfo.new(0.24, Enum.EasingStyle.Quart, Enum.EasingDirection.In), tab = TW_TAB, toggle = TW_TOGGLE, knob = TW_KNOB, hover = TW_HOVER,
        toastIn = TW_TOAST_IN, toastOut = TW_TOAST_OUT, pop = TweenInfo.new(0.26, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        lead = TweenInfo.new(0.24, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), trail = TweenInfo.new(0.42, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        reveal = TweenInfo.new(0.30, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
    }
    local function tween(obj: Instance, info: TweenInfo, props: any)
        local t = TweenService:Create(obj, info, props)
        t:Play()
        return t
    end
    UI.tween = tween







    UI.fadeLive = setmetatable({}, { __mode = "k" })
    function UI.fadeTargets(root: Instance): { { any } }
        local out = {}
        local list = root:GetDescendants()
        table.insert(list, root)
        for _, d in ipairs(list) do
            local props: any = nil
            local live = UI.fadeLive[d]
            if live then
                props = table.clone(live.props)
            elseif d:IsA("UIStroke") then
                if d.Transparency < 1 then
                    props = { Transparency = d.Transparency }
                end
            elseif d:IsA("GuiObject") and d.Visible then
                props = {}
                if d.BackgroundTransparency < 1 then
                    props.BackgroundTransparency = d.BackgroundTransparency
                end
                if (d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox")) and (d :: any).TextTransparency < 1 then
                    props.TextTransparency = (d :: any).TextTransparency
                end
                if (d:IsA("ImageLabel") or d:IsA("ImageButton")) and (d :: any).ImageTransparency < 1 then
                    props.ImageTransparency = (d :: any).ImageTransparency
                end
                if next(props) == nil then
                    props = nil
                end
            end
            if props then
                table.insert(out, { d, props })
            end
        end
        return out
    end
    local function fadeSet(d: Instance, props: any)
        for k, v in pairs(props) do
            pcall(function()
                (d :: any)[k] = v
            end)
        end
    end

    function UI.fadeReset(root: Instance)
        local list = root:GetDescendants()
        table.insert(list, root)
        for _, d in ipairs(list) do
            local live = UI.fadeLive[d]
            if live then
                UI.fadeLive[d] = nil
                pcall(live.tween.Cancel, live.tween)
                fadeSet(d, live.props)
            end
        end
    end
    function UI.fadeIn(root: Instance, info: TweenInfo?)
        local ti = info or UI.TW.pop
        for _, e in ipairs(UI.fadeTargets(root)) do
            local d, props = e[1], e[2]
            local live = UI.fadeLive[d]
            if live then
                pcall(live.tween.Cancel, live.tween)
            else
                for k in pairs(props) do
                    (d :: any)[k] = 1
                end
            end
            local rec: any = { props = props }
            rec.tween = tween(d, ti, props)
            UI.fadeLive[d] = rec
            rec.tween.Completed:Connect(function(state: Enum.PlaybackState)
                if state == Enum.PlaybackState.Completed and UI.fadeLive[d] == rec then
                    UI.fadeLive[d] = nil
                end
            end)
        end
    end




    function UI.fadeOut(root: any, info: TweenInfo?, done: (() -> ())?)
        local ti = info or UI.TW.close
        local targets = {}
        for _, r in ipairs(if typeof(root) == "Instance" then { root } else root) do
            for _, e in ipairs(UI.fadeTargets(r)) do
                table.insert(targets, e)
            end
        end
        local recs = {}
        for i, e in ipairs(targets) do
            local d, props = e[1], e[2]
            local live = UI.fadeLive[d]
            if live then
                pcall(live.tween.Cancel, live.tween)
            end
            local fade = {}
            for k in pairs(props) do
                fade[k] = 1
            end
            local rec: any = { props = props }
            rec.tween = tween(d, ti, fade)
            UI.fadeLive[d] = rec
            recs[i] = rec
        end
        task.delay(ti.Time + ti.DelayTime, function()
            for _, rec in ipairs(recs) do
                pcall(rec.tween.Cancel, rec.tween)
            end
            if done then
                local ok, err = pcall(done)
                if not ok then
                    log("WARN", "fade: " .. tostring(err))
                end
            end
            for i, e in ipairs(targets) do
                local d = e[1]

                if UI.fadeLive[d] == recs[i] then
                    UI.fadeLive[d] = nil
                    fadeSet(d, e[2])
                end
            end
        end)
    end



    function UI.liquid(holder: Instance, apply: (number, number) -> ()): any
        local L: any = { tw = {}, placed = false }
        L.a = Instance.new("NumberValue")
        L.b = Instance.new("NumberValue")
        L.a.Parent, L.b.Parent = holder, holder
        local function paint()
            apply(L.a.Value, L.b.Value)
        end
        L.a.Changed:Connect(paint)
        L.b.Changed:Connect(paint)
        function L.to(a: number, b: number, animate: boolean?)
            for _, t in ipairs(L.tw) do
                t:Cancel()
            end
            table.clear(L.tw)
            if not animate or not L.placed then
                L.placed = true
                L.a.Value, L.b.Value = a, b
                paint()
                return
            end
            local forward = a > L.a.Value
            table.insert(L.tw, tween(L.a, if forward then UI.TW.trail else UI.TW.lead, { Value = a }))
            table.insert(L.tw, tween(L.b, if forward then UI.TW.lead else UI.TW.trail, { Value = b }))
        end
        return L
    end

    local order = 0
    local function nextOrder(): number
        order += 1
        return order
    end
    UI.nextOrder = nextOrder
    local function corner(p: GuiObject, r: number)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, r)
        c.Parent = p
    end
    local function stroke(p: GuiObject, color: Color3, tr: number): UIStroke
        local s = Instance.new("UIStroke")
        s.Color = color
        s.Thickness = 1
        s.Transparency = tr
        s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        s.LineJoinMode = Enum.LineJoinMode.Round
        s.Parent = p
        return s
    end
    local function gradient(p: GuiObject, c1: Color3, c2: Color3, rotation: number?): UIGradient
        local g = Instance.new("UIGradient")
        g.Color = ColorSequence.new(c1, c2)
        g.Rotation = rotation or 0
        g.Parent = p
        return g
    end
    local function vlist(p: GuiObject, pad: number, horizontal: boolean?): UIListLayout
        local l = Instance.new("UIListLayout")
        l.SortOrder = Enum.SortOrder.LayoutOrder
        l.Padding = UDim.new(0, pad)
        if horizontal then
            l.FillDirection = Enum.FillDirection.Horizontal
        end
        l.Parent = p
        return l
    end
    local function padding(p: GuiObject, t: number, r: number, b: number, l: number)
        local u = Instance.new("UIPadding")
        u.PaddingTop = UDim.new(0, t)
        u.PaddingRight = UDim.new(0, r)
        u.PaddingBottom = UDim.new(0, b)
        u.PaddingLeft = UDim.new(0, l)
        u.Parent = p
    end

    function UI.setFont(t: any, font: any)
        if typeof(font) == "Font" then
            t.FontFace = font
        elseif typeof(font) == "EnumItem" then
            t.Font = font
        else
            t.FontFace = UI.F.body
        end
    end
    local function label(p: GuiObject, text: string, size: number, color: Color3, font: any?): TextLabel
        local t = Instance.new("TextLabel")
        t.BackgroundTransparency = 1
        UI.setFont(t, font or UI.F.body)
        t.TextSize = size
        t.TextColor3 = color
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Text = text or ""
        t.Parent = p
        return t
    end
    local function frame(p: GuiObject?, bg: Color3?): Frame
        local f = Instance.new("Frame")
        f.BorderSizePixel = 0
        if bg then
            f.BackgroundColor3 = bg
        else
            f.BackgroundTransparency = 1
        end
        if p then
            f.Parent = p
        end
        return f
    end
    local function button(p: GuiObject, text: string, size: number, color: Color3, bg: Color3?): TextButton
        local b = Instance.new("TextButton")
        b.BackgroundColor3 = bg or C.surface
        b.BorderSizePixel = 0
        UI.setFont(b, UI.F.medium)
        b.TextSize = size
        b.TextColor3 = color
        b.Text = text or ""
        b.AutoButtonColor = false
        b.Parent = p
        return b
    end
    UI.corner, UI.stroke, UI.gradient, UI.vlist, UI.padding, UI.label, UI.frame, UI.button = corner, stroke, gradient, vlist, padding, label, frame, button


    function UI.brushed(f: GuiObject): boolean
        local m = UI.metal
        if not m then
            return false
        end
        f.BackgroundColor3 = Color3.new(1, 1, 1)
        local g = f:FindFirstChild("Brushed") :: UIGradient?
        if not g then
            local ng = Instance.new("UIGradient")
            ng.Name = "Brushed"
            ng.Rotation = 90
            ng.Parent = f
            g = ng
        end
        (g :: UIGradient).Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, m.hi),
            ColorSequenceKeypoint.new(0.58, m.lite),
            ColorSequenceKeypoint.new(1, m.lite:Lerp(m.mid, 0.4)),
        })
        if not f:FindFirstChild("BrushedLight") then
            local sheen = Instance.new("Frame")
            sheen.Name = "BrushedLight"
            sheen.BorderSizePixel = 0
            sheen.BackgroundColor3 = Color3.new(1, 1, 1)
            sheen.BackgroundTransparency = 0.05
            sheen.AnchorPoint = Vector2.new(0.5, 0)
            sheen.Position = UDim2.new(0.5, 0, 0, 1)
            sheen.Size = UDim2.new(1, -8, 0, 1)
            sheen.ZIndex = f.ZIndex
            sheen.Parent = f
            local sg = Instance.new("UIGradient")
            sg.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.18, 0.15), NumberSequenceKeypoint.new(0.82, 0.15), NumberSequenceKeypoint.new(1, 1) })
            sg.Parent = sheen
        end
        local lip = f:FindFirstChildOfClass("UIStroke")
        if lip then
            lip.Color = m.dark
            lip.Transparency = 0.5
        end
        return true
    end


    function UI.softKey(b: TextButton, tint: Color3, st: UIStroke)
        local Cc = UI.C
        UI.setFont(b, UI.F.medium)
        local function paint(hover: boolean)
            if b:GetAttribute("Armed") then
                b.BackgroundColor3, b.BackgroundTransparency, b.TextColor3 = tint, 0.08, Color3.new(1, 1, 1)
                st.Color = tint
                return
            end
            b.BackgroundColor3, b.BackgroundTransparency, b.TextColor3 = if hover then Cc.card else Cc.surface, 0, tint
            st.Color = if hover then tint:Lerp(Cc.edge, 0.4) else Cc.edge
        end
        paint(false)
        b.MouseEnter:Connect(function()
            paint(true)
        end)
        b.MouseLeave:Connect(function()
            paint(false)
        end)
        b:GetAttributeChangedSignal("Armed"):Connect(function()
            paint(false)
        end)
    end

    function UI.keyState(f: GuiObject, on: boolean, offColor: Color3, offAlpha: number?): boolean
        if not UI.brushed(f) then
            return false
        end
        local g = f:FindFirstChild("Brushed")
        if g then
            (g :: UIGradient).Enabled = on
        end
        local light = f:FindFirstChild("BrushedLight")
        if light then
            (light :: Frame).Visible = on
        end
        f.BackgroundColor3 = if on then Color3.new(1, 1, 1) else offColor
        f.BackgroundTransparency = if on then 0 else (offAlpha or 0)
        return true
    end

    function UI.metalFill(g: UIGradient)
        local m = UI.metal
        if not m then
            return
        end
        g.Rotation = 90
        g.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, m.hi),
            ColorSequenceKeypoint.new(0.45, m.lite),
            ColorSequenceKeypoint.new(1, m.lite:Lerp(m.mid, 0.6)),
        })
    end


    function UI.metalEdge(s: UIStroke): UIGradient?
        local m = UI.metal
        if not m then
            return nil
        end
        local a, b, c = m.lite:Lerp(C.accent, 0.35), m.mid:Lerp(m.lite, 0.45), m.lite:Lerp(Color3.new(1, 1, 1), 0.16)
        s.Color = Color3.new(1, 1, 1)
        s.Transparency = 0
        local g = s:FindFirstChildOfClass("UIGradient") or Instance.new("UIGradient")
        g.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, b),
            ColorSequenceKeypoint.new(0.25, a),
            ColorSequenceKeypoint.new(0.5, c),
            ColorSequenceKeypoint.new(0.75, a),
            ColorSequenceKeypoint.new(1, b),
        })
        g.Parent = s
        return g
    end


    function UI.popEdge(p: GuiObject, radius: number?)
        local s = stroke(p, C.accent, 0.6)
        local g = UI.metalEdge(s)
        if g then
            g.Rotation = 35
            UI.softShadow(p, "Aura", C.accent, UI.glowAlpha(0.45), 14, radius)
        end
        return s
    end




    function UI.acrylic(f: GuiObject, opts: any?): any
        opts = opts or {}
        local out: any = {}
        if opts.tint then
            f.BackgroundColor3 = opts.tint
        end
        local lum = if type(opts.light) == "number" then opts.light else 0.1
        if lum > 0 then
            local g = Instance.new("UIGradient")
            g.Name = "AcrylicLight"
            g.Rotation = opts.lightRotation or 90
            g.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(1 - lum, 1 - lum, 1 - lum))
            g.Parent = f
            out.light = g
        end
        if UI.noiseTile and opts.grain ~= false then
            local n = Instance.new("ImageLabel")
            n.Name = "AcrylicGrain"
            n.BackgroundTransparency = 1
            n.Image = UI.noiseTile
            n.ScaleType = Enum.ScaleType.Tile
            n.TileSize = UDim2.fromOffset(96, 96)
            n.ImageTransparency = if type(opts.grain) == "number" then opts.grain else 0.955
            n.Size = opts.grainSize or UDim2.fromScale(1, 1)
            n.ZIndex = opts.z or 1
            n.Active = false
            n.Parent = f
            if opts.radius then
                corner(n, opts.radius)
            end
            out.grain = n
        end
        if type(opts.edge) == "number" then
            local s = stroke(f, opts.edgeColor or Color3.new(1, 1, 1), 0)
            s.Name = "AcrylicEdge"
            local eg = Instance.new("UIGradient")
            eg.Rotation = 90
            eg.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, opts.edge),
                NumberSequenceKeypoint.new(0.5, math.min(1, opts.edge + 0.12)),
                NumberSequenceKeypoint.new(1, math.min(1, opts.edge + 0.22)),
            })
            eg.Parent = s
            out.edge = s
        end
        return out
    end


    function UI.softShadow(parent: GuiObject, name: string, color: Color3, transparency: number, spread: number, radius: number?): ImageLabel?
        local id, slice = UI.falloffTile(spread, radius)
        if not (id and slice) then
            return nil
        end
        local sh = Instance.new("ImageLabel")
        sh.Name = name
        sh.BackgroundTransparency = 1
        sh.Image = id
        sh.ImageColor3 = color
        sh.ImageTransparency = transparency
        sh.ScaleType = Enum.ScaleType.Slice
        sh.SliceCenter = slice
        sh.SliceScale = 1
        sh.AnchorPoint = Vector2.new(0.5, 0.5)
        sh.Position = UDim2.fromScale(0.5, 0.5)
        sh.Size = UDim2.new(1, spread * 2, 1, spread * 2)
        sh.ZIndex = 0
        sh.Active = false
        sh.Parent = parent
        return sh
    end



    local function iconFallback(parent: GuiObject, name: string): Frame
        local canvas = frame(parent)
        canvas.Name = "Icon"
        canvas.Size = UDim2.new(0, 20, 0, 20)
        canvas.AnchorPoint = Vector2.new(0.5, 0.5)
        canvas.Position = UDim2.fromScale(0.5, 0.5)
        local col = Color3.new(1, 1, 1)

        local function box(x: number, y: number, w: number, h: number, opts: any?): Frame
            opts = opts or {}
            local f = frame(canvas, col)
            f.AnchorPoint = Vector2.new(0.5, 0.5)
            f.Position = UDim2.fromScale(x, y)
            f.Size = UDim2.fromScale(w, h)
            f.Rotation = opts.rot or 0
            f.BackgroundTransparency = opts.tr or 0
            if opts.round then
                corner(f, opts.round)
            end
            f:SetAttribute("iconPart", true)
            return f
        end
        local function ring(x: number, y: number, d: number, thick: number, filled: boolean?): Frame
            local f = frame(canvas, col)
            f.AnchorPoint = Vector2.new(0.5, 0.5)
            f.Position = UDim2.fromScale(x, y)
            f.Size = UDim2.fromScale(d, d)
            f.BackgroundTransparency = if filled then 0 else 1
            corner(f, 999)
            f:SetAttribute("iconPart", true)
            if not filled then
                local s = stroke(f, col, 0)
                s.Thickness = thick or 2
                s:SetAttribute("iconStroke", true)
            end
            return f
        end

        local function outline(x: number, y: number, w: number, h: number, thick: number, roundR: number, rot: number?): Frame
            local f = frame(canvas, col)
            f.AnchorPoint = Vector2.new(0.5, 0.5)
            f.Position = UDim2.fromScale(x, y)
            f.Size = UDim2.fromScale(w, h)
            f.Rotation = rot or 0
            f.BackgroundTransparency = 1
            corner(f, roundR)
            f:SetAttribute("iconPart", true)
            local s = stroke(f, col, 0)
            s.Thickness = thick
            s:SetAttribute("iconStroke", true)
            return f
        end
        if name == "Aimbot" or name == "Trigger" then

            ring(0.5, 0.5, 0.8, 2)
            box(0.5, 0.5, 0.12, 0.12, { round = 999 })
            box(0.5, 0.1, 0.08, 0.26, { round = 999 })
            box(0.5, 0.9, 0.08, 0.26, { round = 999 })
            box(0.1, 0.5, 0.26, 0.08, { round = 999 })
            box(0.9, 0.5, 0.26, 0.08, { round = 999 })
        elseif name == "Silent" then

            box(0.62, 0.38, 0.62, 0.26, { round = 999, rot = -35 })
            box(0.26, 0.66, 0.34, 0.08, { round = 999, rot = -35, tr = 0.25 })
            box(0.18, 0.86, 0.22, 0.08, { round = 999, rot = -35, tr = 0.55 })
        elseif name == "Rage" then

            box(0.58, 0.24, 0.2, 0.46, { rot = 28, round = 2 })
            box(0.5, 0.5, 0.42, 0.16, { rot = -20, round = 2 })
            box(0.42, 0.76, 0.2, 0.46, { rot = 28, round = 2 })
        elseif name == "Visuals" then

            outline(0.5, 0.5, 0.96, 0.58, 2, 999)
            ring(0.5, 0.5, 0.42, 2)
            box(0.5, 0.5, 0.16, 0.16, { round = 999 })
        elseif name == "World" then

            ring(0.5, 0.5, 0.92, 2)
            box(0.5, 0.5, 0.86, 0.07, { round = 999 })
            outline(0.5, 0.5, 0.42, 0.9, 2, 999)
        elseif name == "Skins" then

            box(0.5, 0.6, 0.48, 0.62, { round = 3 })
            box(0.24, 0.34, 0.34, 0.2, { round = 3, rot = -30 })
            box(0.76, 0.34, 0.34, 0.2, { round = 3, rot = 30 })
            local notch = box(0.5, 0.29, 0.2, 0.12, { round = 999 })
            notch.BackgroundColor3 = C.surface
            notch:SetAttribute("iconPart", nil)
            notch:SetAttribute("iconHole", true)
        elseif name == "unlock" then
            outline(0.42, 0.68, 0.64, 0.48, 1.5, 3)
            box(0.26, 0.31, 0.08, 0.34, {round=999})
            box(0.48, 0.14, 0.45, 0.08, {round=999})
            box(0.69, 0.23, 0.08, 0.2, {round=999})
            box(0.42, 0.68, 0.07, 0.16, {round=999})
        elseif name == "person" then
            ring(0.5,0.27,0.32,1.5)
            outline(0.5,0.72,0.66,0.42,1.5,999)
        elseif name == "Config" then
            for i,y in ipairs({0.23,0.5,0.77}) do
                box(0.5,y,0.9,0.07,{round=999})
                ring(i==2 and 0.65 or 0.35,y,0.2,1.5,true)
            end
        elseif name == "arrange" then
            box(0.5,0.5,0.08,0.9,{round=999})
            box(0.5,0.5,0.9,0.08,{round=999})
            for _,point in ipairs({{0.4,0.16,45},{0.6,0.16,-45},{0.4,0.84,-45},{0.6,0.84,45}}) do box(point[1],point[2],0.26,0.07,{rot=point[3]}) end
        elseif name == "Interface" or name == "Misc" then

            for _, p in ipairs({ { 0.3, 0.3 }, { 0.7, 0.3 }, { 0.3, 0.7 }, { 0.7, 0.7 } }) do
                box(p[1], p[2], 0.32, 0.32, { round = 3 })
            end
        elseif name == "Debug" then

            outline(0.5, 0.5, 0.92, 0.76, 2, 4)
            box(0.33, 0.43, 0.24, 0.07, { rot = 40, round = 999 })
            box(0.33, 0.57, 0.24, 0.07, { rot = -40, round = 999 })
            box(0.66, 0.64, 0.26, 0.07, { round = 999 })
        elseif name == "menu" then

            for _, y in ipairs({ 0.24, 0.5, 0.76 }) do
                box(0.5, y, 0.78, 0.12, { round = 999 })
            end
        elseif name == "Settings" then

            for i = 0, 7 do
                local a = math.rad(i * 45)
                box(0.5 + math.cos(a) * 0.4, 0.5 + math.sin(a) * 0.4, 0.26, 0.26, { round = 2, rot = i * 45 })
            end
            ring(0.5, 0.5, 0.66, 3, true)
            local hole = ring(0.5, 0.5, 0.26, 2, true)
            hole.BackgroundColor3 = C.surface
            hole:SetAttribute("iconPart", nil)
        else
            box(0.5, 0.5, 0.5, 0.5, { round = 4 })
        end
        return canvas
    end
    local function recolourIcon(canvas: GuiObject, color: Color3)
        if canvas:IsA("TextLabel") then
            canvas.TextColor3 = color
            return
        end
        for _, ch in ipairs(canvas:GetDescendants()) do
            if ch:IsA("UIStroke") then
                ch.Color = color
            elseif ch:GetAttribute("iconPart") then
                (ch :: Frame).BackgroundColor3 = color
            end
        end
    end

    UI.ICONS = {
        Aimbot = "gps_fixed", Trigger = "my_location", Silent = "track_changes", Rage = "bolt", Misc = "widgets", Visuals = "visibility",
        World = "public", Skins = "checkroom", Interface = "dashboard", Settings = "settings", Config = "tune", Debug = "terminal",
        search = "search", save = "save", close = "close", expand = "expand_more", help = "help_outline", warn = "warning_amber",
        check = "check", keyboard = "keyboard", power = "power_settings_new", arrange = "open_with", info = "info", gem = "diamond",
        left = "chevron_left", right = "chevron_right", kill = "my_location", person = "person_outline", refresh = "refresh",
        menu = "menu", unlock = "lock_open", ranks = "military_tech",
    }

    local function icon(parent: GuiObject, name: string, size: number?): GuiObject
        local px = size or 16
        local aliases={main="Aimbot",rage="Rage",world="World",esp="Visuals",visuals="Visuals",skins="Skins",character="person",misc="Misc",spoofers="person",settings="Settings",weaponconfigs="Config",servers="World",gps_fixed="Aimbot",my_location="Trigger",track_changes="Silent",bolt="Rage",visibility="Visuals",public="World",checkroom="Skins",widgets="Misc",tune="Config",dashboard="Interface",person_outline="person",open_with="arrange"}
        name=aliases[name] or name
        if UI.F.icon then
            local t = label(parent, UI.ICONS[name] or name, px, C.muted, UI.F.icon)
            t.Name = "Icon"
            t.Size = UDim2.fromOffset(px + 2, px + 2)
            t.AnchorPoint = Vector2.new(0.5, 0.5)
            t.Position = UDim2.fromScale(0.5, 0.5)
            t.TextXAlignment = Enum.TextXAlignment.Center
            t.TextYAlignment = Enum.TextYAlignment.Center
            return t
        end
        local canvas = iconFallback(parent, name)
        canvas.Size = UDim2.fromOffset(px, px)
        return canvas
    end
    UI.icon, UI.recolourIcon = icon, recolourIcon
    function UI.subtabIcon(title: string): string
        local name=string.lower(title)
        local rules={
            {{"unlock","ownership"},"unlock"},
            {{"trigger","click"},"Trigger"}, {{"silent"},"Silent"}, {{"aim","target"},"Aimbot"},
            {{"weapon","rage","item"},"Rage"}, {{"move","fly","speed","noclip"},"arrange"},
            {{"skin","wrap","charm","finish","viewmodel"},"Skins"}, {{"sound"},"info"},
            {{"world","weather","sky","atmosphere","ambience"},"World"},
            {{"esp","highlight","visual","tracer","effect","overlay"},"Visuals"},
            {{"player","character","spoofer","animation"},"person"},
            {{"config","save","load"},"save"}, {{"bind","key"},"keyboard"},
            {{"setting","option","color","bloom","sun","override","custom"},"Config"},
            {{"queue","ban"},"refresh"},
        }
        for _,rule in ipairs(rules) do for _,word in ipairs(rule[1]) do
            if string.find(name,word,1,true) then return rule[2] end
        end end
        return "Misc"
    end





    function UI.cuteLogo(parent: GuiObject, size: number): Frame
        local sz = math.max(math.floor(size + 0.5), 10)
        local root = Instance.new("Frame")
        root.Name = "LogoMark"
        root.BackgroundTransparency = 1
        root.AnchorPoint = Vector2.new(0.5, 0.5)
        root.Position = UDim2.fromScale(0.5, 0.5)
        root.Size = UDim2.fromOffset(sz, sz)
        local white = Color3.fromRGB(255, 250, 252)
        local order = 0
        local function part(col: Color3, w: number, h: number, x: number, y: number, rot: number?, round: number?): Frame
            order += 1
            local f = Instance.new("Frame")
            f.BorderSizePixel = 0
            f.BackgroundColor3 = col
            f.AnchorPoint = Vector2.new(0.5, 0.5)
            f.Size = UDim2.fromOffset(math.max(1, math.floor(w + 0.5)), math.max(1, math.floor(h + 0.5)))
            f.Position = UDim2.new(0.5, math.floor(x + 0.5), 0.5, math.floor(y + 0.5))
            f.Rotation = rot or 0
            f:SetAttribute("z", order)
            if round then
                corner(f, math.max(1, math.floor(round + 0.5)))
            end
            f.Parent = root
            return f
        end

        order += 1
        local glow = Instance.new("ImageLabel")
        glow.Name = "Glow"
        glow.BackgroundTransparency = 1
        glow.Image = UI.glowRadial or UI.GLOW_IMAGE
        glow.ImageColor3 = C.accent
        glow.ImageTransparency = 0.55
        glow.AnchorPoint = Vector2.new(0.5, 0.5)
        glow.Position = UDim2.fromScale(0.5, 0.52)
        glow.Size = UDim2.fromOffset(math.floor(sz * 1.9), math.floor(sz * 1.9))
        glow:SetAttribute("z", order)
        glow.Parent = root
        local blush = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 214, 234))
        for _, side in ipairs({ -1, 1 }) do
            local ear = part(white, sz * 0.32, sz * 0.32, side * sz * 0.26, -sz * 0.2, 45, sz * 0.07)
            gradient(ear, Color3.new(1, 1, 1), Color3.new(1, 1, 1), 90).Color = blush

            part(C.accent:Lerp(Color3.new(1, 1, 1), 0.35), sz * 0.15, sz * 0.15, side * sz * 0.26, -sz * 0.18, 45, sz * 0.04)
        end
        local face = part(white, sz * 0.88, sz * 0.7, 0, sz * 0.06, 0, sz * 0.35)
        gradient(face, Color3.new(1, 1, 1), Color3.new(1, 1, 1), 90).Color = blush

        for _, side in ipairs({ -1, 1 }) do
            local cheek = part(C.accent, sz * 0.14, sz * 0.08, side * sz * 0.29, sz * 0.17, 0, sz)
            cheek.BackgroundTransparency = 0.45
        end
        local ink = Color3.fromRGB(46, 26, 40)
        for _, side in ipairs({ -1, 1 }) do
            part(ink, math.max(2, sz * 0.09), math.max(2, sz * 0.12), side * sz * 0.19, sz * 0.05, 0, sz)
        end
        part(Color3.fromRGB(255, 196, 92), math.max(2, sz * 0.11), math.max(2, sz * 0.075), 0, sz * 0.14, 0, sz)
        if sz >= 16 then
            for _, side in ipairs({ -1, 1 }) do
                for i = -1, 1 do
                    part(Color3.fromRGB(96, 66, 86), sz * 0.15, 1, side * sz * 0.43, sz * (0.11 + i * 0.065), side * i * 12)
                end
            end
        end
        local bow = C.accent
        for _, side in ipairs({ -1, 1 }) do
            part(bow, sz * 0.21, sz * 0.17, sz * 0.27 + side * sz * 0.1, -sz * 0.31, side * 20, sz * 0.07)
        end
        part(bow:Lerp(Color3.new(1, 1, 1), 0.3), math.max(2, sz * 0.09), math.max(2, sz * 0.09), sz * 0.27, -sz * 0.31, 0, sz)
        local function restack()
            for _, d in ipairs(root:GetChildren()) do
                if d:IsA("GuiObject") then
                    d.ZIndex = root.ZIndex + (d:GetAttribute("z") or 0)
                end
            end
        end
        restack()
        root:GetPropertyChangedSignal("ZIndex"):Connect(restack)
        root.Parent = parent
        return root
    end

    function UI.themeLogo(parent: GuiObject, size: number, key: string): ImageLabel?
        local id = UI.themeLogoPng(key, size)
        if not id then
            return nil
        end
        local px = math.floor(size + 0.5)
        local img = Instance.new("ImageLabel")
        img.Name = "LogoMark"
        img.BackgroundTransparency = 1
        img.Image = id
        img.ScaleType = Enum.ScaleType.Fit
        img.Size = UDim2.fromOffset(px, px)
        img.AnchorPoint = Vector2.new(0.5, 0.5)
        img.Position = UDim2.fromScale(0.5, 0.5)
        img.Parent = parent
        return img
    end
    function UI.logoMark(parent: GuiObject, size: number, rotation: number?): GuiObject
        local brand = UI.brandLogoAsset and UI.brandLogoAsset()
        if brand then
            local h = math.max(6, math.floor(size * 0.55 + 0.5))
            local w = math.max(h, math.floor(size * 1.65 + 0.5))
            local img = Instance.new("ImageLabel")
            img.Name = "PlexBrandLogo"
            img.BackgroundTransparency = 1
            img.Image = brand
            img.ScaleType = Enum.ScaleType.Fit
            img.Size = UDim2.fromOffset(w, h)
            img.AnchorPoint = Vector2.new(0.5, 0.5)
            img.Position = UDim2.fromScale(0.5, 0.5)
            img.Parent = parent
            return img
        end
        if UI.themeName and UI.themeName() == "Max Cute" and S.edition == "max" then
            return UI.cuteLogo(parent, size)
        end
        local fx = UI.themeFx and UI.themeFx()
        if fx then
            local own = UI.themeLogo(parent, size, fx.key)
            if own then
                return own
            end
        end
        local m: GuiObject
        size = math.floor(size + 0.5)
        local face = if UI.faceIcon then UI.buildFacePng(size) or UI.faceIcon else nil
        if face then
            local img = Instance.new("ImageLabel")
            img.Name = "LogoMark"
            img.BackgroundTransparency = 1
            img.Image = face
            img.ImageColor3 = Color3.new(1, 1, 1)
            img.ScaleType = Enum.ScaleType.Fit
            img.Size = UDim2.fromOffset(size, size)
            img.AnchorPoint = Vector2.new(0.5, 0.5)
            img.Position = UDim2.fromScale(0.5, 0.5)
            img.Parent = parent
            m = img
        elseif UI.F.icon then
            m = label(parent, "diamond", size, Color3.new(1, 1, 1), UI.F.icon)
            m.Size = UDim2.fromOffset(size, size)
            m.AnchorPoint = Vector2.new(0.5, 0.5)
            m.Position = UDim2.fromScale(0.5, 0.5);
            (m :: TextLabel).TextXAlignment = Enum.TextXAlignment.Center
        else
            m = frame(parent, Color3.new(1, 1, 1))
            m.Size = UDim2.fromOffset(math.floor(size * 0.65), math.floor(size * 0.65))
            m.AnchorPoint = Vector2.new(0.5, 0.5)
            m.Position = UDim2.fromScale(0.5, 0.5)
            m.Rotation = 45
            corner(m, 2)
        end
        local g = gradient(m, C.accent, C.accent2, rotation or 45)
        local metal = if S.edition == "max" and not fx then UI.BLOOD_METAL elseif not fx then UI.metal else nil
        if metal then

            g.Rotation = 90
            g.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, metal.hi),
                ColorSequenceKeypoint.new(0.35, metal.lite),
                ColorSequenceKeypoint.new(0.55, metal.lite:Lerp(metal.mid, 0.55)),
                ColorSequenceKeypoint.new(0.68, metal.hi),
                ColorSequenceKeypoint.new(1, metal.lite),
            })
        end
        return m
    end





    UI.HUD_FONT = Font.fromEnum(Enum.Font.GothamBold)
    UI.HUD_BOLD = Font.fromEnum(Enum.Font.GothamBold)
    function UI.gw(text: string, size: number, bold: boolean?): number
        local ts = game:GetService("TextService")
        local ok, sz = pcall(ts.GetTextSize, ts, tostring(text or ""), size, if bold then Enum.Font.GothamBold else Enum.Font.GothamMedium, Vector2.new(4000, 400))
        return if ok and sz then math.ceil(sz.X) else math.ceil(#tostring(text or "") * size * 0.62)
    end



    UI.MAX_INK = Color3.fromRGB(26, 8, 8)



    UI.sparkleIds = {}
    function UI.sparklePng(px: number?): string?
        local N = math.clamp(math.ceil((px or 32) * 2 / 8) * 8, 16, 64)
        local have = UI.sparkleIds[N]
        if have ~= nil then
            return have or nil
        end
        local SS = 4
        local id = UI.pngAsset(("sparkle%d_v2.png"):format(N), N, function(x: number, y: number)
            local hit = 0
            for sy = 0, SS - 1 do
                for sx = 0, SS - 1 do
                    local u = math.abs((x + (sx + 0.5) / SS) / N * 2 - 1)
                    local v = math.abs((y + (sy + 0.5) / SS) / N * 2 - 1)
                    if u ^ 0.7 + v ^ 0.7 <= 1 then
                        hit += 1
                    end
                end
            end
            return 255, 255, 255, math.floor(hit / (SS * SS) * 255 + 0.5)
        end)
        UI.sparkleIds[N] = id or false
        UI.sparkleId = UI.sparkleId or id
        return id
    end

    UI.SPARKLES = { { 9.5, 14, 8.5, 2.6, 0 }, { 18.6, 5.4, 4.1, 1.9, 0.7 }, { 19.2, 18.4, 2.6, 2.2, 1.4 } }
    local function glint(parent: GuiObject, x: number, y: number, size: number, delay: number)
        local holder = Instance.new("Frame")
        holder.Name = "Glint"
        holder.BackgroundTransparency = 1
        holder.AnchorPoint = Vector2.new(0.5, 0.5)
        holder.Position = UDim2.new(x, 0, y, 0)
        holder.Size = UDim2.fromOffset(size, size)
        holder.ZIndex = parent.ZIndex + 2
        holder.Parent = parent
        for i = 1, 4 do
            local diag = i > 2
            local bar = Instance.new("Frame")
            bar.BorderSizePixel = 0
            bar.BackgroundColor3 = Color3.new(1, 1, 1)
            bar.BackgroundTransparency = if diag then 0.35 else 0
            bar.AnchorPoint = Vector2.new(0.5, 0.5)
            bar.Position = UDim2.fromScale(0.5, 0.5)
            bar.Size = if i % 2 == 1 then UDim2.new(if diag then 0.55 else 1, 0, 0, 1) else UDim2.new(0, 1, if diag then 0.55 else 1, 0)
            bar.Rotation = if diag then 45 else 0
            bar.ZIndex = holder.ZIndex
            bar.Parent = holder
            local g = Instance.new("UIGradient")
            g.Rotation = if i % 2 == 1 then 0 else 90
            g.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1) })
            g.Parent = bar
        end
        local sc = Instance.new("UIScale")
        sc.Scale = 0.35
        sc.Parent = holder
        pcall(function()
            game:GetService("TweenService"):Create(sc, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true, delay), { Scale = 1 }):Play()
        end)
    end


    function UI.sparkles(parent: GuiObject, size: number, color: Color3, z: number): Frame
        local box = Instance.new("Frame")
        box.Name = "Sparkles"
        box.BackgroundTransparency = 1
        box.Size = UDim2.fromOffset(size, size)
        box.ZIndex = z
        box.Parent = parent
        for _, s in ipairs(UI.SPARKLES) do
            local img = UI.sparklePng(s[3] * 2 / 24 * size)
            if not img then
                glint(box, s[1] / 24, s[2] / 24, math.max(3, math.floor(s[3] * 2 / 24 * size + 0.5)), s[5])
                continue
            end
            local star = Instance.new("ImageLabel")
            star.Name = "Glint"
            star.BackgroundTransparency = 1
            star.Image = img
            star.ImageColor3 = color
            star.AnchorPoint = Vector2.new(0.5, 0.5)
            star.Position = UDim2.fromScale(s[1] / 24, s[2] / 24)
            star.Size = UDim2.fromScale(s[3] * 2 / 24, s[3] * 2 / 24)
            star.ZIndex = z
            star.Parent = box
            local sc = Instance.new("UIScale")
            sc.Parent = star
            pcall(function()
                game:GetService("TweenService"):Create(sc, TweenInfo.new(s[4] / 2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true, s[5]), { Scale = 0.68 }):Play()
            end)
        end
        return box
    end
    function UI.maxBadge(parent: Instance, h: number?, world: boolean?): Frame
        local height = math.max(math.floor((h or 16) + 0.5), 14)
        local size = if height >= 20 then 13 elseif height >= 18 then 12 else 11
        local f = Instance.new("Frame")
        f.Name = "MaxBadge"
        f.BorderSizePixel = 0

        local cl = math.floor(height * 0.8 + 0.5)
        local padL, gap, padR = math.floor(height * 0.28 + 0.5), math.max(2, math.floor(height * 0.16 + 0.5)), math.floor(height * 0.4 + 0.5)
        f.Size = UDim2.fromOffset(padL + cl + gap + UI.gw("max", size, true) + padR, height)
        f.BackgroundColor3 = Color3.new(1, 1, 1)
        corner(f, if world then 5 else 4)
        local cute = UI.themeName and UI.themeName() == "Max Cute"
        local fx = UI.themeFx and UI.themeFx()
        if fx then

            gradient(f, Color3.new(1, 1, 1), Color3.new(1, 1, 1), if #fx.tag > 2 then 0 else 90).Color = UI.fxSeq(fx.tag)
            local ring = Instance.new("UIStroke")
            ring.Color = fx.ring
            ring.Thickness = if world then 2 else 1.5
            ring.Transparency = 0.45
            ring.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            ring.Parent = f
            if fx.candy then
                local cs = Instance.new("Frame")
                cs.Name = "Candy"
                cs.BorderSizePixel = 0
                cs.BackgroundColor3 = Color3.new(1, 1, 1)
                cs.Size = UDim2.fromScale(1, 1)
                cs.Parent = f
                corner(cs, if world then 5 else 4)
                local kp = {}
                for i = 0, 3 do
                    local b = i * 0.25
                    table.insert(kp, NumberSequenceKeypoint.new(b, 1))
                    table.insert(kp, NumberSequenceKeypoint.new(b + 0.125, 1))
                    table.insert(kp, NumberSequenceKeypoint.new(b + 0.126, 0.62))
                    table.insert(kp, NumberSequenceKeypoint.new(b + 0.249, 0.62))
                end
                table.insert(kp, NumberSequenceKeypoint.new(1, 0.62))
                local cg = Instance.new("UIGradient")
                cg.Rotation = 35
                cg.Transparency = NumberSequence.new(kp)
                cg.Parent = cs
            end
        elseif cute then

            local g = gradient(f, Color3.new(1, 1, 1), Color3.new(1, 1, 1), 90)
            g.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 196, 226)),
                ColorSequenceKeypoint.new(0.55, Color3.fromRGB(255, 118, 186)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(206, 84, 206)),
            })
            local ring = Instance.new("UIStroke")
            ring.Color = Color3.fromRGB(255, 150, 206)
            ring.Thickness = 2
            ring.Transparency = 0.45
            ring.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            ring.Parent = f
        else

            local g = gradient(f, Color3.new(1, 1, 1), Color3.new(1, 1, 1), 90)
            g.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, UI.BLOOD_METAL.hi),
                ColorSequenceKeypoint.new(0.52, UI.BLOOD_METAL.lite),
                ColorSequenceKeypoint.new(1, UI.BLOOD_METAL.mid),
            })
            stroke(f, Color3.fromRGB(40, 6, 6), 0)
            f.ClipsDescendants = true
            local shine = Instance.new("Frame")
            shine.Name = "Shine"
            shine.BorderSizePixel = 0
            shine.BackgroundColor3 = Color3.new(1, 1, 1)
            shine.BackgroundTransparency = 0.3
            shine.Size = UDim2.new(0.34, 0, 1, -2)
            shine.Position = UDim2.new(-0.4, 0, 0, 1)
            shine.Parent = f
            local shg = Instance.new("UIGradient")
            shg.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1) })
            shg.Parent = shine
            pcall(function()
                game:GetService("TweenService"):Create(shine, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, false, 3.6), { Position = UDim2.new(1.1, 0, 0, 1) }):Play()
            end)
        end

        local sheen = Instance.new("Frame")
        sheen.Name = "Sheen"
        sheen.BorderSizePixel = 0
        sheen.BackgroundColor3 = Color3.new(1, 1, 1)
        sheen.BackgroundTransparency = 0.45
        sheen.AnchorPoint = Vector2.new(0.5, 0)
        sheen.Position = UDim2.new(0.5, 0, 0, 1)
        sheen.Size = UDim2.new(1, -8, 0, 1)
        sheen.Parent = f
        local sg = Instance.new("UIGradient")
        sg.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1) })
        sg.Parent = sheen
        local blood = not fx and not cute
        local ink = if blood then UI.MAX_INK else Color3.new(1, 1, 1)
        local t = Instance.new("TextLabel")
        t.Name = "Word"
        t.BackgroundTransparency = 1
        t.FontFace = UI.HUD_BOLD
        t.Text = "max"
        t.TextSize = size
        t.TextColor3 = ink
        t.TextStrokeColor3 = if fx then fx.ink else Color3.fromRGB(110, 20, 70)

        t.TextStrokeTransparency = if blood then 1 elseif fx then 0.5 else 0.78
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Size = UDim2.new(1, -(padL + cl + gap), 1, 0)
        t.Position = UDim2.fromOffset(padL + cl + gap, 0)
        t.Parent = f
        local mark = UI.sparkles(f, cl, ink, f.ZIndex + 2)
        mark.AnchorPoint = Vector2.new(0, 0.5)
        mark.Position = UDim2.new(0, padL, 0.5, 0)
        f.Parent = parent
        return f
    end
    S.ext.maxBadge = UI.maxBadge

    UI.MAX_MARK = Color3.fromRGB(255, 64, 64)
    S.ext.sparkles = UI.sparkles



    function UI.fxMenu(root: GuiObject, side: GuiObject, px: (number) -> number, loop: (Instance, TweenInfo, any) -> any)
        local fx = UI.themeFx()
        local drift = UI.driftFx()
        if not fx and not drift then
            return
        end
        if UI.themeName() == "Plex blue" and cfg.themeArt ~= false then
            local backdrop = root:FindFirstChild("DefaultThemeArt")
            if backdrop then backdrop:Destroy() end
            backdrop = frame(root, Color3.fromRGB(25, 28, 39))
            backdrop.Name = "DefaultThemeArt"
            backdrop.Size = UDim2.fromScale(1, 1)
            backdrop.BackgroundTransparency = 0.94
            backdrop.ZIndex = 1
            backdrop.ClipsDescendants = true
            local pride = Instance.new("UIGradient")
            pride.Rotation = 18
            pride.Color = ColorSequence.new(Color3.fromRGB(25, 28, 39), Color3.fromRGB(16, 18, 28))
            pride.Transparency = NumberSequence.new(0.55)
            pride.Parent = backdrop
        end

        if fx then
            local ribbon = frame(root, Color3.new(1, 1, 1))
            ribbon.Name = "ThemeRibbon"
            ribbon.Size = UDim2.new(1, -28, 0, 2)
            ribbon.Position = UDim2.fromOffset(14, 0)
            ribbon.ZIndex = 6
            local rg = Instance.new("UIGradient")
            rg.Color = UI.fxSeq(fx.ribbon or fx.flag, true)
            rg.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.06, 0.05), NumberSequenceKeypoint.new(0.94, 0.05), NumberSequenceKeypoint.new(1, 1) })
            rg.Parent = ribbon
            local emblem = UI.themeName() ~= "Plex blue" and cfg.themeArt ~= false and UI.themeLogoPng(fx.key, px(96)) or nil
            if emblem then
                local e = Instance.new("ImageLabel")
                e.Name = "ThemeEmblem"
                e.BackgroundTransparency = 1
                e.Image = emblem
                e.ImageTransparency = 0.9
                e.Rotation = -14
                e.AnchorPoint = Vector2.new(0.5, 0.5)
                e.Position = UDim2.new(0.66, 0, 1, -px(122))
                e.Size = UDim2.fromOffset(px(96), px(96))
                e.ZIndex = 3
                e.Parent = side
            end
        end
        if UI.themeName() == "Plex blue" or cfg.themeFx == false or cfg.lowSpec or cfg.perfMode then
            return
        end

        local layer = frame(root)
        layer.Name = "ThemeFx"
        layer.Position = UDim2.fromOffset(0, 12)
        layer.Size = UDim2.new(1, 0, 1, -24)
        layer.ClipsDescendants = true
        layer.ZIndex = 1
        local rng = Random.new(#drift.key * 7919)
        for i = 1, 16 do
            local kind = drift.sprites[(i - 1) % #drift.sprites + 1]
            local img = UI.fxSprite(kind)
            local col = drift.colors[rng:NextInteger(1, #drift.colors)]
            local tr = rng:NextNumber(0.35, 0.65)
            local p: GuiObject
            if img then
                local il = Instance.new("ImageLabel")
                il.BackgroundTransparency = 1
                il.Image = img
                il.ImageColor3 = col
                il.ImageTransparency = tr
                p = il
            else
                p = frame(nil, col)
                p.BackgroundTransparency = tr
                corner(p, 999)
            end
            local sz = rng:NextInteger(px(9), px(17))
            if kind == "star" then
                sz = math.floor(sz * 0.75)
            end
            p.Name = "Sprite"
            p.Size = UDim2.fromOffset(sz, sz)
            p.AnchorPoint = Vector2.new(0.5, 0.5)
            local x = rng:NextNumber(0.04, 0.96)
            local y0, y1 = if drift.rise then 1.06 else -0.06, if drift.rise then -0.06 else 1.06
            p.Position = UDim2.fromScale(x, y0)
            p.Rotation = rng:NextNumber(-30, 30)
            p.ZIndex = 1
            p.Parent = layer
            local dur = rng:NextNumber(10, 18)
            loop(p, TweenInfo.new(dur, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false, rng:NextNumber(0, dur * 0.8)), { Position = UDim2.fromScale(x + rng:NextNumber(-0.08, 0.08), y1) })
            loop(p, TweenInfo.new(rng:NextNumber(1.8, 3.2), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Rotation = p.Rotation + rng:NextNumber(-50, 50) })
        end
    end


    function UI.fxIntro(stage: GuiObject, cy: number)
        local fx = UI.driftFx()
        if not fx or cfg.themeFx == false then
            return
        end
        local TS = game:GetService("TweenService")
        local rng = Random.new()
        for i = 1, 22 do
            local img = UI.fxSprite(fx.sprites[(i - 1) % #fx.sprites + 1])
            if not img then
                return
            end
            local p = Instance.new("ImageLabel")
            p.BackgroundTransparency = 1
            p.Image = img
            p.ImageColor3 = fx.colors[rng:NextInteger(1, #fx.colors)]
            local sz = rng:NextInteger(10, 22)
            p.Size = UDim2.fromOffset(sz, sz)
            p.AnchorPoint = Vector2.new(0.5, 0.5)
            p.Rotation = rng:NextNumber(-40, 40)
            p.Parent = stage
            if fx.intro == "fall" then
                local x = rng:NextNumber(0.32, 0.68)
                local lag, t = rng:NextNumber(0, 0.4), rng:NextNumber(1.1, 1.6)
                p.Position = UDim2.new(x, 0, cy, -rng:NextNumber(170, 300))
                p.ImageTransparency = 1
                TS:Create(p, TweenInfo.new(t, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, lag), { Position = UDim2.new(x + rng:NextNumber(-0.04, 0.04), 0, cy, rng:NextNumber(30, 130)), Rotation = p.Rotation + rng:NextNumber(-120, 120) }):Play()
                TS:Create(p, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, lag), { ImageTransparency = rng:NextNumber(0.05, 0.3) }):Play()
                task.delay(lag + t - 0.45, function()
                    if p.Parent then
                        TS:Create(p, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { ImageTransparency = 1 }):Play()
                    end
                end)
            else
                local a = (i / 22) * math.pi * 2 + rng:NextNumber(-0.2, 0.2)
                local r = rng:NextNumber(90, 210)
                p.Position = UDim2.new(0.5, 0, cy, -40)
                p.ImageTransparency = 0.05
                local sc = Instance.new("UIScale")
                sc.Scale = 0.3
                sc.Parent = p
                TS:Create(p, TweenInfo.new(rng:NextNumber(0.9, 1.4), Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Position = UDim2.new(0.5, math.cos(a) * r, cy, -40 + math.sin(a) * r * 0.75 - (if fx.rise then 30 else 0)), Rotation = p.Rotation + rng:NextNumber(-90, 90) }):Play()
                TS:Create(sc, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
                TS:Create(p, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, rng:NextNumber(0.7, 1.1)), { ImageTransparency = 1 }):Play()
            end
        end
    end

    function UI.tintIcon(canvas: GuiObject, color: Color3, animate: boolean?)
        if animate and canvas:IsA("TextLabel") then
            tween(canvas, TW_HOVER, { TextColor3 = color })
        else
            recolourIcon(canvas, color)
        end
    end
    UI.loadAssets()


    UI.rows = {}
    UI.groups = {}
    UI.sync = {}


    UI.lazySync = {}
    function UI.syncLazy(fn: () -> ())
        table.insert(UI.sync, fn)
        UI.lazySync[fn] = true
    end
    UI.bindTags = {}
    UI.searchText = ""
    UI.gui = nil
    UI.root = nil
    UI.conns = {}
    local tipFrame: TextLabel? = nil
    function UI.conn(c: RBXScriptConnection): RBXScriptConnection
        table.insert(UI.conns, c)
        return c
    end
    function UI.resetRegistries()
        for _, c in ipairs(UI.conns) do
            pcall(c.Disconnect, c)
        end
        table.clear(UI.conns)
        UI.dragInstalled = false
        UI.drag = nil
        table.clear(UI.rows)
        table.clear(UI.groups)
        table.clear(UI.sync)
        table.clear(UI.lazySync)
        table.clear(UI.bindTags)
        S.ui.tabs = {}
        S.ui.subTabs = {}
        S.ui.controls = {}
        S.ui.toggles = {}
        tipFrame = nil
    end


    UI.drag = nil
    UI.dragInstalled = false
    function UI.beginDrag(onMove: (Vector2) -> (), onEnd: (() -> ())?)
        local prev = UI.drag
        if prev and prev.onEnd then
            pcall(prev.onEnd)
        end
        UI.drag = { onMove = onMove, onEnd = onEnd }
        if not UI.dragInstalled then
            UI.dragInstalled = true
            UI.conn(UIS.InputChanged:Connect(function(i)
                local d = UI.drag
                if d and i.UserInputType == Enum.UserInputType.MouseMovement then
                    d.onMove(Vector2.new(i.Position.X, i.Position.Y))
                end
            end))
            UI.conn(UIS.InputEnded:Connect(function(i)
                local d = UI.drag
                if d and i.UserInputType == Enum.UserInputType.MouseButton1 then
                    UI.drag = nil
                    if d.onEnd then
                        d.onEnd()
                    end
                end
            end))
        end
    end

    function UI.count(kind: string)
        S.ui.controls[kind] = (S.ui.controls[kind] or 0) + 1
    end
    local function modeAllows(advanced: boolean?): boolean
        return cfg.uiMode == "Advanced" or not advanced
    end







    UI.SIMPLE_KEYS = {

        aimbot = true, aimKey = true, teamCheck = true, aimFov360 = true, aimFov = true, aimSmooth = true, aimStrength = true, aimDynamic = true, targetPriority = true, threatPriority = true, stickyAim = true, crosshair = true, showFov = true,
        utilAuto = true, utilHeal = true, utilHealBelow = true, utilMine = true, utilThrow = true, gunAbilities = true,
        aimHitboxes = true, aimPrefer = true, aimVisibleHitbox = true,

        silentAim = true, silentOnlyFiring = true, leadMode = true, silentFov360 = true, silentFov = true, silentFovFallback = true, targetMaxDistance = true, fovLinked = true, silentHitChance = true, silentWallbang = true, silentWallbangDist = true, antiUnder = true, antiUnderDist = true,
        legitTrigger = true, legitTriggerMode = true, legitTriggerKey = true, legitTriggerHitbox = true, legitTriggerDelayMs = true, legitTriggerChance = true,
        silentHitboxes = true, silentPrefer = true, silentVisibleHitbox = true, dynamicHitbox = true,

        autoShoot = true, autoShootHold = true, autoShootDelay = true, preAim = true, autoShootHealthCheck = true, killConfirmHold = true, oneShotSafety = true, immuneCheck = true, rageAutoShootVisible = true,
        autoShootWaitAim = true, autoShootScopeSnipers = true, autoShootReactionMs = true, autoShootChance = true, autoShootAimMode = true, autoShootStopMode = true,

        autoQuickMelee = true, autoBackstab = true, meleeRage = true, meleeMode = true, meleeHeavyPolicy = true, meleeRageRange = true, meleeOrbitRadius = true,
        magicHeight = true, magicJitter = true, magicJitterRadius = true, originPreferCover = true, rageCsync = true, posDesync = true,

        autokill = true, autokillMode = true, autokillReturn = true, autokillVisible = true, autokillAdaptive = true, autokillChain = true, autokillAuto = true, autokillAutoRange = true, autokillDuration = true, autokillUntilDead = true, originMaxDist = true, autokillAbortHp = true,
        autokillMove = true, autoPeek = true, autoPeekKey = true, autoPeekDistance = true,
        noclip = true, noclipFloat = true, noclipSpeed = true, noclipFollowCamera = true,
        defenseHide = true, defenseMode = true, defenseOnlyWhenThreat = true, defenseVoidSpam = true, voidSpam = true,
        voidSpamMode = true, voidSpamDist = true, voidSpamSpot = true, antiTransloc = true, defenseAlways = true, voidSpamHide = true, voidSpamBack = true, voidSpamFireBack = true, voidSpamMoveBack = true, voidSpamAutoOff = true, voidSpamHud = true, voidSpamUnder = true, voidSpamUnderRange = true, voidSpamBait = true, voidSpamBaitSpot = true, voidSpamBaitSec = true, voidSpamBaitEvery = true,
        oobBlock = true, boundsGuard = true, voidHunt = true, shieldAware = true, antiFlash = true, targetPreferVisible = true, magicHopOnShot = true,
        aaEnabled = true, aaMode = true, aaPitch = true, aaSpeed = true, aaJitterDeg = true, aaBody = true, antiMeleeFace = true, fakeDuck = true,
        resolver = true, resolverBodyOnAA = true, resolverWarp = true, deadTargetGuard = true, autoBlock = true, autoBlockRange = true, katanaCheck = true,

        noSpread = true, noRecoil = true, rapidFire = true, fullAuto = true, rapidFireMult = true, rapidThrottle = true, rapidMelee = true, rapidMeleeMult = true, rapidMeleeServer = true, fastEquip = true, fastEquipMult = true, fastAim = true, fastAimMult = true, instantBullet = true,
        instantReload = true, reloadMult = true, autoReload = true, reloadEarly = true, noReloadCancel = true,
        infSlide = true, infSprint = true, noAdsSlow = true, noSlow = true, autoSlide = true, slideKey = true, bhop = true, speedBoost = true, speedMult = true,

        esp = true, espVisibleCheck = true, espMaxDistance = true, espTextSize = true, espLineWidth = true, espBox = true, espBoxStyle = true, espBoxFill = true, espBoxFillAlpha = true, espTeammates = true, espRank = true, espAmmo = true, espStreak = true, teamPerf = true, espChamsBlend = true, nameSpoof = true, hideNametags = true, streamerMode = true, weaponSpoof = true, rankSpoof = true, fovRotate = true,
        espSkeleton = true, espHeadDot = true, espNames = true, espHealthBar = true, espDistance = true, espWeapon = true, colEsp = true, colEspVisible = true, colText = true, colHp = true,
        espHighlight = true, espChamsOccluded = true, espChamsFill = true, espChamsOutline = true, colChamsFill = true, colChamsHidden = true, colChamsOutline = true,
        espTracers = true, espTracerFrom = true, colTracer = true, espArrows = true, espArrowRadius = true, radar = true, radarSize = true, radarRange = true, hitMarkers = true, killFeed = true,

        nightMode = true, nightLevel = true, nightHands = true, nightHandsGlow = true, fullbright = true, brightness = true, noFog = true, skyColorOn = true, skyColor = true, timeOfDayOn = true, timeOfDay = true, noPostFx = true, noDamageFx = true,
        thirdPerson = true, tpShoulder = true, tpDist = true, tpUp = true, tpSide = true, tpSmooth = true, tpHideViewmodel = true, fovChanger = true, fov = true, noAdsZoom = true, noScopeOverlay = true, hideViewmodel = true, hideHands = true,
        antiAfk = true, autoRejoin = true, autoRejoinDelay = true,

        unlockCosmetics = true, unlockFinisher = true, skinModelSwap = true, skinRebuild = true, hud = true, indicators = true, showBinds = true, awarenessHud = true, combatBar = true, targetCard = true, hudScale = true,
        theme = true, colAccent = true, colAccent2 = true, menuBlur = true, menuKey = true, menuScale = true, espHideInMenu = true, espLobby = true, espWhileHidden = true, espGhostSec = true, introAnim = true, uiMode = true, targetBots = true,
        autoload = true, autoUpdate = true, adaptToasts = true, autoPerf = true, perfMode = true, lowSpec = true,

        espOutline = true, espHpMode = true, espFlags = true, espArrowMax = true, espArrowDist = true, statusSituation = true, toasts = true,
        uiGlow = true, themeFx = true, themeArt = true, railGlass = true, previewPane = true, previewHp = true,
        worldGrade = true, gradeContrast = true, gradeSaturation = true, gradeTint = true, worldBloom = true, bloomIntensity = true,
        worldSunRays = true, sunRaysIntensity = true, worldDof = true, worldAtmos = true, atmosColor = true, atmosDensity = true,
        worldAmbientOn = true, colAmbient = true, worldExposureOn = true, worldExposure = true, worldShadows = true, worldStars = true,
        worldWeather = true, weatherDensity = true, fxQuality = true, shotTracers = true, hitNumbers = true, hitBlood = true, killEffect = true,
        vmChams = true, vmMaterial = true, colVm = true, selfChams = true, colSelf = true,
    }
    UI.SIMPLE_LABELS = {
        ["Start autokill now"] = true, ["Measure the void now"] = false,
        ["Rejoin this server"] = true, ["Server hop"] = true, ["Copy join code"] = true,
        ["Unlock everything"] = true, ["Lock everything"] = true,
        ["Measure this gun's limit"] = true,
        ["Apply now"] = true, ["Follow the weapon in hand"] = true, ["Reset this weapon"] = true, ["Reset all weapons"] = true, ["Refresh the customize screen"] = false,
        ["Save now"] = true, ["Reset to defaults"] = true, ["Unload cocaine"] = true, ["Copy config"] = true, ["Paste config"] = true,
        ["Check for update"] = true, ["Reload the latest version"] = true, ["Reset layout"] = true,
        ["Arrange HUD"] = true, ["Open the console (F9)"] = true, ["Copy logs"] = true, ["Clean look"] = true, ["Turn everything off"] = true, ["Play the intro"] = true,
    }



    UI.NEEDS = {
        autoShoot = "silentAim", autokill = { "silentAim", "rage" }, meleeRage = { "silentAim", "rage" },
        posDesync = "rageEnabled",
        autoBackstab = { "silentAim", "rage", "noMeleeRage" }, autoQuickMelee = "silentAim", defenseHide = { "silentAim", "rage" }, preAim = "silentAim",
        antiMeleeDodge = { "silentAim", "rage" }, defenseVoidSpam = { "defenseHide", "rage" }, voidSpam = "rageEnabled",
        autokillHvh = { "silentAim", "rage" }, rageBreaker = { "silentAim", "rage" },
    }
    UI.NEED_TEXT = { silentAim = "needs silent aim", rage = "rage is off", defenseHide = "needs hide", noMeleeRage = "melee rage has it", rageEnabled = "ragebot disabled" }

    function UI.needText(need: string): string
        if need == "rage" then
            if cfg.rageEnabled == false then
                return UI.NEED_TEXT.rageEnabled
            elseif cfg.ragePosition == nil or cfg.ragePosition == "None" then
                return "no rage mode"
            end
        end
        return UI.NEED_TEXT[need] or ("needs " .. tostring(need))
    end
    function UI.needMet(need: string): boolean
        if need == "rage" then
            return Configs.rageOn(cfg)
        elseif need == "noMeleeRage" then

            return not cfg.meleeRage
        end
        return cfg[need] == true
    end

    function UI.needUnmet(need: any): string?
        if type(need) == "string" then
            return if UI.needMet(need) then nil else need
        elseif type(need) == "table" then
            for _, n in ipairs(need) do
                if not UI.needMet(n) then
                    return n
                end
            end
        end
        return nil
    end
    function UI.isAdvanced(ropts: any, text: string?, groupOpts: any): boolean
        if ropts.advanced ~= nil then
            return ropts.advanced == true
        end
        if groupOpts and groupOpts.simple == true then
            return false
        end
        if ropts.isNote then
            return false
        end
        if ropts.cfgKey ~= nil then
            return UI.SIMPLE_KEYS[ropts.cfgKey] ~= true
        end
        if ropts.isList then
            return false
        end
        return UI.SIMPLE_LABELS[text or ""] ~= true
    end
    local function rowMatches(r: any): boolean
        local q = UI.searchText
        if q == "" then
            return true
        end
        return string.find(string.lower(r.text), q, 1, true) ~= nil or (r.descText ~= nil and string.find(string.lower(r.descText), q, 1, true) ~= nil)
    end




    function UI.animSub(state: any, open: boolean, done: (() -> ())?)
        local rows = {}
        for _, r in ipairs(UI.rows) do
            if r.parent == state and r.frame.Visible then
                table.insert(rows, r)
            end
        end
        if #rows == 0 then
            if done then
                done()
            end
            return
        end
        state.animating = true
        if open then
            for _, r in ipairs(rows) do
                UI.fadeIn(r.frame)
            end
            task.delay(UI.TW.pop.Time, function()
                state.animating = false
                if done then
                    done()
                end
            end)
            return
        end
        local frames = {}
        for _, r in ipairs(rows) do
            table.insert(frames, r.frame)
        end
        UI.fadeOut(frames, UI.TW.hover, function()
            state.animating = false
            if done then
                done()
            end
        end)
    end
    function UI.parentOpen(r: any): boolean
        local p = r.parent
        if p == nil then
            return true
        end
        if UI.searchText ~= "" then
            return true
        end
        return p.open == true and (p.when == nil or p.when() == true)
    end
    function UI.refilter()
        for _, r in ipairs(UI.rows) do
            local show = modeAllows(r.advanced) and rowMatches(r) and UI.parentOpen(r)
            if r.frame.Visible ~= show then r.frame.Visible = show end
            if r.desc then

                local showDesc = r.descText ~= nil and r.descText ~= ""
                if r.desc.Visible ~= showDesc then r.desc.Visible = showDesc end
                local size = UDim2.new(1, 0, 0, r.base + (if showDesc then (r.descH or UI.M.descLine) else 0))
                if r.frame.Size ~= size then r.frame.Size = size end
            end
        end
        for _, g in ipairs(UI.groups) do
            local any, anyControl, hasControls = false, false, false
            for _, r in ipairs(g.rows) do
                if not r.isNote then
                    hasControls = true
                end
                if r.frame.Visible then
                    any = true
                    if not r.isNote then
                        anyControl = true
                    end
                end
            end



            if cfg.uiMode ~= "Advanced" and hasControls and any and not anyControl then
                for _, r in ipairs(g.rows) do
                    if r.isNote and r.frame.Visible then
                        r.frame.Visible = false
                    end
                end
                any = false
            end
            local showGroup = modeAllows(g.advanced) and (any or (#g.rows == 0 and UI.searchText == ""))
            if g.frame.Visible ~= showGroup then g.frame.Visible = showGroup end
        end
        if UI.afterRefilter then
            pcall(UI.afterRefilter)
        end
    end
    function UI.search(text: string)
        UI.searchText = string.lower(tostring(text or ""))
        UI.refilter()
    end
    function UI.setMode(mode: string)
        cfg.uiMode = if mode == "Simple" then "Simple" else "Advanced"
        saveConfig()
        UI.refilter()
    end


    function UI.parseNumber(s: string): number?
        if type(s) ~= "string" then
            return nil
        end
        s = string.gsub(string.lower(string.gsub(s, "×", "")), "%s+", "")

        s = if string.match(s, "^%-?%d+,%d%d%d") then string.gsub(s, ",", "") else string.gsub(s, ",", ".")
        if s == "never" or s == "off" or s == "none" then
            return 0
        end
        local num, suffix = string.match(s, "^x?([%-]?%d*%.?%d+)(%a*)")
        local n = tonumber(num)
        if n == nil or n ~= n then
            return nil
        end
        if suffix == "k" then
            n *= 1000
        end
        return n
    end

    function UI.tip(target: GuiObject, text: string)
        target.MouseEnter:Connect(function()
            if not UI.gui or not text or text == "" then
                return
            end
            if not tipFrame or tipFrame.Parent == nil then

                local t = Instance.new("TextLabel")
                t.Name = "Tooltip"
                t.AutomaticSize = Enum.AutomaticSize.XY
                t.Size = UDim2.new(0, 0, 0, 0)
                t.BackgroundColor3 = C.pop
                UI.setFont(t, UI.F.body)
                t.TextSize = UI.M.desc
                t.TextColor3 = C.text
                t.TextWrapped = true
                t.TextXAlignment = Enum.TextXAlignment.Left
                t.LineHeight = 1.1
                t.ZIndex = 200
                t.Visible = false
                t.Parent = UI.gui
                corner(t, if UI.metal then 8 else 6)
                UI.metalEdge(stroke(t, C.edge, 0))
                padding(t, 7, 10, 8, 10)
                local cap = Instance.new("UISizeConstraint")
                cap.MaxSize = Vector2.new(260, 400)
                cap.Parent = t
                tipFrame = t
            end
            local tf = tipFrame :: TextLabel
            tf.Text = text
            UI.snapWrapped(tf, 240, 20, 15)


            local m0 = UIS:GetMouseLocation()
            local inset0 = if UI.gui.IgnoreGuiInset then 0 else GuiService:GetGuiInset().Y
            tf.Position = UDim2.fromOffset(m0.X + 14, m0.Y - inset0 + 8)
            tf.Visible = false
            task.defer(function()
                if tipFrame ~= tf then
                    return
                end
                local m = UIS:GetMouseLocation()


                local inset = if UI.gui.IgnoreGuiInset then 0 else GuiService:GetGuiInset().Y
                local vp = UI.gui.AbsoluteSize
                local sz = tf.AbsoluteSize
                local x, y = m.X + 14, m.Y - inset + 8
                if x + sz.X > vp.X - 6 then
                    x = math.max(6, m.X - 14 - sz.X)
                end
                if y + sz.Y > vp.Y - 6 then
                    y = math.max(6, m.Y - inset - 8 - sz.Y)
                end
                tf.Position = UDim2.fromOffset(x, y)
                tf.Visible = true
            end)
        end)
        target.MouseLeave:Connect(function()
            if tipFrame then
                tipFrame.Visible = false
            end
        end)
    end




    local BIND_MODES = { "Toggle", "Hold", "Always", "Never" }
    local bindPopup: Frame? = nil

    function UI.textW(text: string, size: number): number
        local ts = game:GetService("TextService")
        local ok, sz = pcall(ts.GetTextSize, ts, tostring(text or ""), size, Enum.Font.BuilderSansExtraBold, Vector2.new(2000, 200))
        return if ok and sz then math.ceil(sz.X) else #tostring(text or "") * (size * 0.6)
    end




    function UI.snapWidth(l: TextLabel, extra: number?): boolean
        local w = l.TextBounds.X
        if w < 1 then
            return false
        end
        local total = math.ceil(w - 0.001) + (extra or 0)
        if total % 2 == 1 then
            total += 1
        end
        if l.AutomaticSize == Enum.AutomaticSize.X then
            l.AutomaticSize = Enum.AutomaticSize.None
        elseif l.AutomaticSize == Enum.AutomaticSize.XY then
            l.AutomaticSize = Enum.AutomaticSize.Y
        end
        if l.Size.X.Scale ~= 0 or l.Size.X.Offset ~= total then
            l.Size = UDim2.new(0, total, l.Size.Y.Scale, l.Size.Y.Offset)
        end
        return true
    end


    function UI.snapWrapped(l: TextLabel, maxW: number, padX: number?, padY: number?): boolean
        local auto = l.AutomaticSize
        l.AutomaticSize = Enum.AutomaticSize.None
        l.TextWrapped = true
        l.Size = UDim2.fromOffset(maxW + (padX or 0), 2000)
        local tb = l.TextBounds
        if tb.X < 1 then
            l.AutomaticSize = auto
            return false
        end
        local w = math.ceil(tb.X - 0.001) + (padX or 0)
        if w % 2 == 1 then
            w += 1
        end
        l.Size = UDim2.fromOffset(w, math.ceil(tb.Y - 0.001) + (padY or 0))
        return true
    end
    function UI.closeBindPopup()
        local p = bindPopup
        bindPopup = nil




        if type(Input.cancelCapture) == "function" then
            Input.cancelCapture()
        end
        if not p then
            return
        end
        if p.Parent and S.menuOpen then

            for _, d in ipairs(p:GetDescendants()) do
                if d:IsA("GuiButton") then
                    d.Active = false
                    pcall(function()
                        (d :: any).Interactable = false
                    end)
                end
            end
            UI.fadeOut(p, UI.TW.hover, function()
                p:Destroy()
            end)
        else
            p:Destroy()
        end
    end
    function UI.openBindPopup(cfgKey: string, title: string?, at: Vector2?)
        local root = UI.root
        if not root then
            return
        end
        UI.closeBindPopup()


        local b = cfg.binds[cfgKey]
        if type(b) ~= "table" then
            b = { key = "", mode = "Toggle" }
        end
        local function commit()
            if cfg.binds[cfgKey] ~= b then
                cfg.binds[cfgKey] = b
            end
            saveConfig()
        end


        local W, H = 300, 206
--[c0:wm-60-77d3acd5fb417604]
        local pop = frame(root, C.pop)
        pop.Name = "BindPopup"
        pop.Size = UDim2.fromOffset(W, H)
        local rel = if at then at - root.AbsolutePosition else Vector2.new(root.AbsoluteSize.X / 2 - W / 2, root.AbsoluteSize.Y / 2 - H / 2)
        pop.Position = UDim2.fromOffset(math.floor(math.clamp(rel.X, 8, math.max(8, root.AbsoluteSize.X - W - 8))), math.floor(math.clamp(rel.Y, 8, math.max(8, root.AbsoluteSize.Y - H - 8))))
        pop.ZIndex = 50
        pop.Active = true
        corner(pop, 10)
        UI.softShadow(pop, "Shadow", Color3.new(0, 0, 0), 0.4, 18, 10)
        UI.popEdge(pop, 10)
        bindPopup = pop
        local function zl(t: any, z: number?): any
            t.ZIndex = z or 51
            return t
        end
        local cap = zl(label(pop, "keybind", UI.M.tiny, C.accent, UI.F.semibold))
        cap.Size = UDim2.new(1, -60, 0, 14)
        cap.Position = UDim2.fromOffset(16, 12)
        local head = zl(label(pop, string.lower(title or Input.bindLabels[cfgKey] or cfgKey), UI.M.title, C.text, UI.F.semibold))
        head.Size = UDim2.new(1, -60, 0, 18)
        head.Position = UDim2.fromOffset(16, 27)
        head.TextTruncate = Enum.TextTruncate.AtEnd
        local closeB = zl(button(pop, "", 10, C.text, C.card))
        closeB.Size = UDim2.fromOffset(28, 28)
        closeB.AnchorPoint = Vector2.new(1, 0)
        closeB.Position = UDim2.new(1, -10, 0, 10)
        closeB.BackgroundTransparency = 1
        corner(closeB, 7)
        local closeIc = zl(icon(closeB, "close", 16), 52)
        recolourIcon(closeIc, C.muted)
        closeB.MouseEnter:Connect(function()
            tween(closeB, TW_HOVER, { BackgroundTransparency = 0 })
            UI.tintIcon(closeIc, C.text, true)
        end)
        closeB.MouseLeave:Connect(function()
            tween(closeB, TW_HOVER, { BackgroundTransparency = 1 })
            UI.tintIcon(closeIc, C.muted, true)
        end)
        local hair = zl(frame(pop, C.hairline))
        hair.Size = UDim2.new(1, -32, 0, 1)
        hair.Position = UDim2.fromOffset(16, 56)
        for _, spec in ipairs({ { "key", 68 }, { "mode", 108 } }) do
            local l = zl(label(pop, spec[1], UI.M.title, C.dim))
            l.Size = UDim2.fromOffset(64, 30)
            l.Position = UDim2.fromOffset(16, spec[2])
        end

        local keyB = zl(button(pop, "", UI.M.value, C.text, C.surface))
        keyB.Size = UDim2.fromOffset(W - 104, 30)
        keyB.Position = UDim2.fromOffset(88, 68)
        corner(keyB, 7)
        local keyStroke = stroke(keyB, C.edge, 0)
        local keyIc = zl(icon(keyB, "keyboard", 15), 52)
        keyIc.AnchorPoint = Vector2.new(0, 0.5)
        keyIc.Position = UDim2.new(0, 10, 0.5, 0)
        recolourIcon(keyIc, C.muted)
        local keyTxt = zl(label(keyB, "", UI.M.value, C.text, UI.F.medium), 52)
        keyTxt.Size = UDim2.new(1, -42, 1, 0)
        keyTxt.Position = UDim2.fromOffset(32, 0)
        keyTxt.TextTruncate = Enum.TextTruncate.AtEnd
        keyB.MouseEnter:Connect(function()
            tween(keyB, TW_HOVER, { BackgroundColor3 = C.card })
        end)
        keyB.MouseLeave:Connect(function()
            tween(keyB, TW_HOVER, { BackgroundColor3 = C.surface })
        end)

        local seg = zl(frame(pop, C.surface))
        seg.Size = UDim2.fromOffset(W - 104, 30)
        seg.Position = UDim2.fromOffset(88, 108)
        corner(seg, 7)
        stroke(seg, C.edge, 0)
        local thumb = zl(frame(seg, C.accent), 52)
        thumb.BackgroundTransparency = 0.78
        corner(thumb, 5)
        stroke(thumb, C.accent, 0.5)
        if UI.brushed(thumb) then
            thumb.BackgroundTransparency = 0
        end
        local thumbLiquid = UI.liquid(thumb, function(a: number, b2: number)
            thumb.Position = UDim2.fromOffset(a, 3)
            thumb.Size = UDim2.fromOffset(math.max(4, b2 - a), 24)
        end)
        local segW = (W - 104 - 6) / #BIND_MODES
        local segBtns: { [string]: TextButton } = {}
        local refresh: (boolean?) -> ()
        for i, m in ipairs(BIND_MODES) do
            local sb = zl(button(seg, string.lower(m), UI.M.small, C.muted, C.surface), 53)
            sb.BackgroundTransparency = 1
            sb.Position = UDim2.fromOffset(3 + math.floor((i - 1) * segW + 0.5), 3)
            sb.Size = UDim2.fromOffset(math.floor(i * segW + 0.5) - math.floor((i - 1) * segW + 0.5), 24)
            segBtns[m] = sb
            sb.MouseButton1Click:Connect(function()
                if (b.mode or "Toggle") ~= m then
                    b.mode = m
                    Input.bindTouched[cfgKey] = nil
                    commit()
                    local callback = Input.bindCallbacks[cfgKey]
                    if callback then pcall(callback,b.key,b.mode) end
                    refresh(true)
                end
            end)
        end

        local dot = zl(frame(pop, C.muted))
        dot.Size = UDim2.fromOffset(6, 6)
        dot.AnchorPoint = Vector2.new(0, 0.5)
        dot.Position = UDim2.fromOffset(16, 157)
        corner(dot, 3)
        local status = zl(label(pop, "", UI.M.small, C.dim, UI.F.medium))
        status.Name = "Status"
        status.Size = UDim2.fromOffset(W - 44, 18)
        status.Position = UDim2.fromOffset(28, 148)
        status.TextTruncate = Enum.TextTruncate.AtEnd
        local clearB = zl(button(pop, "clear", UI.M.value, C.danger, C.danger))
        clearB.Size = UDim2.fromOffset(76, 26)
        clearB.Position = UDim2.fromOffset(16, H - 38)
        clearB.BackgroundTransparency = 0.87
        corner(clearB, 7)
        stroke(clearB, C.danger, 0.6)
        clearB.MouseEnter:Connect(function()
            tween(clearB, TW_HOVER, { BackgroundTransparency = 0.78 })
        end)
        clearB.MouseLeave:Connect(function()
            tween(clearB, TW_HOVER, { BackgroundTransparency = 0.87 })
        end)
        local hint = zl(label(pop, "esc clears · mouse 4 / 5 work", UI.M.small, C.muted))
        hint.Size = UDim2.fromOffset(W - 116, 26)
        hint.Position = UDim2.fromOffset(100, H - 38)
        hint.TextXAlignment = Enum.TextXAlignment.Right
        local function paintStatus()
            local k = b.key
            if type(k) ~= "string" or k == "" then
                status.Text = if b.mode == "Always" or b.mode == "Never" then ("no key · always %s"):format(if b.mode == "Always" then "on" else "off") else "no key yet"
                status.TextColor3 = C.muted
                dot.BackgroundColor3 = if b.mode == "Always" then C.ok else C.faint
                return
            end
            status.Text = ("bound to %s · %s"):format(Input.keyLabel(k), string.lower(b.mode or "Toggle"))
            status.TextColor3 = C.dim
            dot.BackgroundColor3 = if b.mode == "Never" then C.faint else C.ok
        end
        refresh = function(animate: boolean?)
            keyTxt.Text = Input.keyLabel(b.key)
            local mode = b.mode or "Toggle"
            for m, sb in pairs(segBtns) do
                local col = if m == mode then (if UI.metal then UI.metal.ink else C.text) else C.muted
                if animate then
                    tween(sb, TW_HOVER, { TextColor3 = col })
                else
                    sb.TextColor3 = col
                end
                UI.setFont(sb, if m == mode then UI.F.bold else UI.F.medium)
            end
            local sb = segBtns[mode]
            if sb then
                thumbLiquid.to(sb.Position.X.Offset, sb.Position.X.Offset + sb.Size.X.Offset, animate)
            end
            paintStatus()
            local tag = UI.bindTags[cfgKey]
            if tag then
                tag()
            end
        end
        refresh(false)
        keyB.MouseButton1Click:Connect(function()
            keyTxt.Text = "Press a key…"
            keyStroke.Color = C.accent
            recolourIcon(keyIc, C.accent)
            Input.captureKey(function(name)
                if name ~= false then
                    b.key = name or ""
                    commit()
                    local callback = Input.bindCallbacks[cfgKey]
                    if callback then pcall(callback,b.key,b.mode) end
                end
                if pop.Parent then
                    keyStroke.Color = C.edge
                    recolourIcon(keyIc, C.muted)
                    refresh(false)
                end
            end)
        end)
        do
            local base = pop.Position
            pop.Position = base + UDim2.fromOffset(0, 4)
            tween(pop, UI.TW.pop, { Position = base })
            UI.fadeIn(pop)
        end
        clearB.MouseButton1Click:Connect(function()
            cfg.binds[cfgKey] = nil
            Input.bindTouched[cfgKey] = nil
            saveConfig()
            local tag = UI.bindTags[cfgKey]
            if tag then
                tag()
            end
            UI.closeBindPopup()
        end)
        closeB.MouseButton1Click:Connect(UI.closeBindPopup)
    end
    function UI.bindPopupOpen(): boolean
        return bindPopup ~= nil and bindPopup.Parent ~= nil
    end
    local keyModeMenu: Frame? = nil
    local keyModeOutside: RBXScriptConnection? = nil
    function UI.closeKeyModeMenu()
        if keyModeOutside then keyModeOutside:Disconnect() keyModeOutside=nil end
        if keyModeMenu then keyModeMenu:Destroy() keyModeMenu=nil end
    end
    function UI.openKeyModeMenu(cfgKey: string, title: string, at: Vector2?)
        if not UI.root then return end
        UI.closeKeyModeMenu()
        local root = UI.root
        local choices = {
            {mode="Always", label="always"},
            {mode="Never", label="never"},
            {mode="Hold", label="while holding"},
            {mode="Toggle", label="toggle"},
        }
        local width = 210
        local rowH = UIS.TouchEnabled and 36 or 27
        local modesTop = 31
        local keyTop = modesTop + (#choices * rowH) + 7
        local height = keyTop + (UIS.TouchEnabled and 87 or 43)
        local point = at or Vector2.new(root.AbsoluteSize.X/2, root.AbsoluteSize.Y/2)
        local relative = point - root.AbsolutePosition

        local pop = frame(root,C.pop)
        pop.Name = "KeyModeMenu"
        pop.Size = UDim2.fromOffset(width,height)
        pop.Position = UDim2.fromOffset(
            math.floor(math.clamp(relative.X,8,math.max(8,root.AbsoluteSize.X-width-8))),
            math.floor(math.clamp(relative.Y,8,math.max(8,root.AbsoluteSize.Y-height-8))))
        pop.ZIndex = 80
        pop.Active = true
        corner(pop,7)
        UI.softShadow(pop,"Shadow",Color3.new(0,0,0),0.46,12,7)
        stroke(pop,C.edge,0)
        keyModeMenu = pop

        local caption = label(pop,"key mode · "..string.lower(title),UI.M.small,C.dim,UI.F.semibold)
        caption.Position = UDim2.fromOffset(10,5)
        caption.Size = UDim2.new(1,-20,0,18)
        caption.TextTruncate = Enum.TextTruncate.AtEnd
        caption.ZIndex = 81

        local sep = frame(pop,C.hairline)
        sep.Size = UDim2.new(1,-16,0,1)
        sep.Position = UDim2.fromOffset(8,25)
        sep.ZIndex = 81

        local binding = cfg.binds[cfgKey]
        if type(binding)~="table" then
            binding = {key=tostring(cfg[cfgKey] or ""),mode="Toggle"}
            cfg.binds[cfgKey] = binding
        end

        local painters = {}
        for index,choice in ipairs(choices) do
            local y = modesTop + ((index-1)*rowH)
            local item = button(pop,"",UI.M.value,C.text,C.pop)
            item.Name = "Mode_"..choice.mode
            item.BackgroundTransparency = 1
            item.AutoButtonColor = false
            item.Text = ""
            item.Position = UDim2.fromOffset(6,y)
            item.Size = UDim2.new(1,-12,0,rowH-2)
            item.ZIndex = 81
            corner(item,5)

            local activeBar = frame(item,C.accent)
            activeBar.Size = UDim2.fromOffset(2,rowH-11)
            activeBar.Position = UDim2.fromOffset(0,5)
            activeBar.ZIndex = 82
            corner(activeBar,2)

            local textLabel = label(item,choice.label,UI.M.value,C.muted,UI.F.body)
            textLabel.Position = UDim2.fromOffset(9,0)
            textLabel.Size = UDim2.new(1,-31,1,0)
            textLabel.ZIndex = 83
            textLabel.TextXAlignment = Enum.TextXAlignment.Left
            textLabel.TextTruncate = Enum.TextTruncate.AtEnd

            local check = icon(item,"check",13)
            check.AnchorPoint = Vector2.new(1,0.5)
            check.Position = UDim2.new(1,-7,0.5,0)
            check.ZIndex = 83
            recolourIcon(check,C.accent)

            local hovered = false
            local function paint(over)
                if over ~= nil then hovered = over end
                local selected = binding.mode == choice.mode
                item.BackgroundTransparency = (selected or hovered) and 0.5 or 1
                item.BackgroundColor3 = C.surface
                activeBar.Visible = selected
                textLabel.TextColor3 = selected and C.text or (hovered and C.dim or C.muted)
                check.Visible = selected
            end
            painters[index] = paint
            paint(false)

            item.MouseEnter:Connect(function() paint(true) end)
            item.MouseLeave:Connect(function() paint(false) end)
            item.MouseButton1Click:Connect(function()
                binding.mode = choice.mode
                cfg.binds[cfgKey] = binding
                Input.bindTouched[cfgKey] = nil
                local callback = Input.bindCallbacks[cfgKey]
                if callback then pcall(callback,binding.key,binding.mode) end
                saveConfig()
                for _,repaint in ipairs(painters) do repaint(nil) end
            end)
        end

        local keySep = frame(pop,C.hairline)
        keySep.Size = UDim2.new(1,-16,0,1)
        keySep.Position = UDim2.fromOffset(8,keyTop-3)
        keySep.ZIndex = 81

        local keyLabel = label(pop,"keybind",UI.M.small,C.muted,UI.F.semibold)
        keyLabel.Position = UDim2.fromOffset(10,keyTop+4)
        keyLabel.Size = UDim2.fromOffset(72,27)
        keyLabel.ZIndex = 82

        local keyButton = button(pop,"",UI.M.small,C.text,C.surface)
        keyButton.AnchorPoint = Vector2.new(1,0)
        keyButton.Position = UDim2.new(1,-8,0,keyTop+3)
        keyButton.Size = UDim2.fromOffset(112,UIS.TouchEnabled and 36 or 28)
        keyButton.ZIndex = 82
        keyButton.AutoButtonColor = false
        corner(keyButton,5)
        local keyStroke = stroke(keyButton,C.edge,0)

        local keyIcon = icon(keyButton,"keyboard",13)
        keyIcon.AnchorPoint = Vector2.new(0,0.5)
        keyIcon.Position = UDim2.new(0,8,0.5,0)
        keyIcon.ZIndex = 83
        recolourIcon(keyIcon,C.muted)

        local keyText = label(keyButton,"",UI.M.small,C.dim,UI.F.semibold)
        keyText.Position = UDim2.fromOffset(27,0)
        keyText.Size = UDim2.new(1,-34,1,0)
        keyText.ZIndex = 83
        keyText.TextXAlignment = Enum.TextXAlignment.Left
        keyText.TextTruncate = Enum.TextTruncate.AtEnd

        local function refreshKey()
            local key = tostring(binding.key or "")
            keyText.Text = (key == "" or key == "None") and "none" or Input.keyLabel(key)
            local tag = UI.bindTags[cfgKey]
            if tag then tag() end
        end
        refreshKey()

        keyButton.MouseEnter:Connect(function()
            keyButton.BackgroundColor3 = C.card
        end)
        keyButton.MouseLeave:Connect(function()
            keyButton.BackgroundColor3 = C.surface
        end)
        keyButton.MouseButton1Click:Connect(function()
            if Input.capturing() then return end
            keyText.Text = UIS.TouchEnabled and "tap screen..." or "press a key..."
            keyStroke.Color = C.accent
            recolourIcon(keyIcon,C.accent)
            Input.captureKey(function(name)
                if name ~= false then
                    binding.key = name == "None" and "" or tostring(name or "")
                    cfg.binds[cfgKey] = binding
                    Input.bindTouched[cfgKey] = nil
                    local callback = Input.bindCallbacks[cfgKey]
                    if callback then pcall(callback,binding.key,binding.mode) end
                    saveConfig()
                end
                if pop.Parent then
                    keyStroke.Color = C.edge
                    recolourIcon(keyIcon,C.muted)
                    refreshKey()
                end
            end)
        end)
        if UIS.TouchEnabled then
            local clear=button(pop,"clear key",UI.M.small,C.dim,C.surface)
            clear.Name="ClearKey"
            clear.Size=UDim2.new(1,-16,0,30)
            clear.Position=UDim2.fromOffset(8,keyTop+47)
            clear.ZIndex=82
            corner(clear,5)
            clear.Activated:Connect(function()
                binding.key=""
                Input.bindTouched[cfgKey]=nil
                local callback=Input.bindCallbacks[cfgKey]
                if callback then pcall(callback,"",binding.mode) end
                saveConfig()
                refreshKey()
            end)
        end

        UI.fadeIn(pop)
        keyModeOutside = UIS.InputBegan:Connect(function(input)
            if Input.capturing() then return end
            if input.UserInputType~=Enum.UserInputType.MouseButton1 and input.UserInputType~=Enum.UserInputType.MouseButton2
                and input.UserInputType~=Enum.UserInputType.Touch then return end
            local mouse=input.UserInputType==Enum.UserInputType.Touch and Vector2.new(input.Position.X,input.Position.Y)
                or UIS:GetMouseLocation()-Vector2.new(0,GuiService:GetGuiInset().Y)
            local pos,size=pop.AbsolutePosition,pop.AbsoluteSize
            if mouse.X<pos.X or mouse.X>pos.X+size.X or mouse.Y<pos.Y or mouse.Y>pos.Y+size.Y then
                UI.closeKeyModeMenu()
            end
        end)
    end
    table.insert(Game.cleanups,function() UI.closeKeyModeMenu() end)





    UI.popup = nil
    UI.popupHost = nil
    function UI.closeDropdown()
        local p = UI.popup
        UI.popup = nil
        if p then
            pcall(p.catcher.Destroy, p.catcher)
            pcall(p.frame.Destroy, p.frame)
            if p.onClose then
                pcall(p.onClose)
            end
        end
    end


    function UI.openDropdown(anchor: GuiObject, width: number, build: (Frame) -> number, onClose: (() -> ())?): Frame?
        UI.closeDropdown()
        local host = UI.popupHost or UI.root
        if not host then
            return nil
        end
        local sc = if S.menu and S.menu.scale then S.menu.scale.Scale else 1
        sc = math.max(sc, 0.1)
        local catcher = Instance.new("TextButton")
        catcher.Name = "DropdownCatcher"
        catcher.BackgroundTransparency = 1
        catcher.Text = ""
        catcher.AutoButtonColor = false
        catcher.Size = UDim2.new(1, 400, 1, 0)
        catcher.ZIndex = 58
        catcher.Parent = host
        local f = frame(host, C.pop)
        f.Name = "Dropdown"
        f.ZIndex = 60
        f.Active = true
        corner(f, 8)
        UI.softShadow(f, "Shadow", Color3.new(0, 0, 0), 0.45, 14, 8)
        if not UI.metal then
            stroke(f, C.edge, 0)
        else
            UI.popEdge(f, 8)
        end
        local h = build(f)
        local ap = (anchor.AbsolutePosition - host.AbsolutePosition) / sc
        local as = anchor.AbsoluteSize / sc
        local hostH = host.AbsoluteSize.Y / sc
        local w = math.max(width, as.X)
        local y = ap.Y + as.Y + 4
        local above = false
        if y + h > hostH - 6 and ap.Y - h - 4 > 6 then
            y = ap.Y - h - 4
            above = true
        end

        local base = UDim2.fromOffset(math.floor(ap.X + as.X - w + 0.5), math.floor(y + 0.5))
        f.Size = UDim2.fromOffset(w, h)
        f.Position = base + UDim2.fromOffset(0, if above then 4 else -4)
        tween(f, UI.TW.pop, { Position = base })
        UI.fadeIn(f)
        catcher.MouseButton1Click:Connect(UI.closeDropdown)
        UI.popup = { frame = f, catcher = catcher, onClose = onClose }
        return f
    end

    function UI.dropdownOption(parent: Frame, y: number, text: string, selected: boolean, onPick: () -> ()): TextButton
        local b = button(parent, "", UI.M.value, C.dim, C.card)
        b.BackgroundTransparency = 1
        b.Size = UDim2.new(1, -8, 0, 24)
        b.Position = UDim2.fromOffset(4, y)
        b.ZIndex = 61
        corner(b, 5)
        local l = label(b, text, UI.M.value, if selected then C.accent else C.dim, UI.F.body)
        l.Size = UDim2.new(1, -30, 1, 0)
        l.Position = UDim2.fromOffset(8, 0)
        l.ZIndex = 62
        l.TextTruncate = Enum.TextTruncate.AtEnd
        local ic = icon(b, "check", 14)
        ic.AnchorPoint = Vector2.new(1, 0.5)
        ic.Position = UDim2.new(1, -6, 0.5, 0)
        ic.ZIndex = 62
        ic.Visible = selected
        recolourIcon(ic, C.accent)
        b:SetAttribute("selected", selected)

        local keyed = selected and UI.brushed(b)
        if keyed then
            b.BackgroundTransparency = 0
            l.TextColor3 = UI.metal.ink
            UI.setFont(l, UI.F.bold)
            recolourIcon(ic, UI.metal.ink)
        end
        b.MouseEnter:Connect(function()
            if keyed then
                return
            end
            tween(b, TW_HOVER, { BackgroundTransparency = 0 })
            if not b:GetAttribute("selected") then
                tween(l, TW_HOVER, { TextColor3 = C.text })
            end
        end)
        b.MouseLeave:Connect(function()
            if keyed then
                return
            end
            tween(b, TW_HOVER, { BackgroundTransparency = 1 })
            tween(l, TW_HOVER, { TextColor3 = if b:GetAttribute("selected") then C.accent else C.dim })
        end)
        b.MouseButton1Click:Connect(onPick)
        return b
    end

    UI.optionsModal = nil
    function UI.closeOptionsModal()
        local modal = UI.optionsModal
        UI.optionsModal = nil
        if modal then pcall(modal.Destroy, modal) end
    end

    function UI.openOptionsModal(titleText: string, options: {string}, selectedFn: (string)->boolean, onPick: (string)->(), multi: boolean?)
        UI.closeDropdown()
        UI.closeOptionsModal()
        local host = UI.popupHost or UI.root
        if not host then return end

        local overlay = button(host, "", UI.M.value, C.text, Color3.new(0,0,0))
        overlay.Name = "OptionsModal"
        overlay.Size = UDim2.fromScale(1,1)
        overlay.BackgroundTransparency = 1
        overlay.ZIndex = 80
        overlay.AutoButtonColor = false
        UI.optionsModal = overlay

        local width = 304
        local rowH = 25
        local visibleRows = math.min(#options, 12)
        local height = 43 + math.max(1,visibleRows) * rowH + 10
        local card = frame(overlay, C.pop)
        card.Name = "OptionsCard"
        card.AnchorPoint = Vector2.new(0.5,0.5)
        card.Position = UDim2.fromScale(0.5,0.5)
        card.Size = UDim2.fromOffset(width, math.min(356,height))
        card.ZIndex = 81
        corner(card,7)
        UI.softShadow(card,"Shadow",Color3.new(0,0,0),0.5,14,7)
        stroke(card,C.edge,0)

        local title = label(card, string.lower(titleText or "options"), UI.M.small, C.dim, UI.F.semibold)
        title.Position = UDim2.fromOffset(11,7)
        title.Size = UDim2.new(1,-42,0,23)
        title.ZIndex = 82
        title.TextTruncate = Enum.TextTruncate.AtEnd

        local close = button(card, "", UI.M.small, C.muted, C.pop)
        close.AnchorPoint = Vector2.new(1,0)
        close.Position = UDim2.new(1,-7,0,6)
        close.Size = UDim2.fromOffset(24,24)
        close.ZIndex = 83
        close.BackgroundTransparency = 1
        close.AutoButtonColor = false
        corner(close,5)
        local closeIcon = icon(close,"close",13)
        closeIcon.AnchorPoint = Vector2.new(0.5,0.5)
        closeIcon.Position = UDim2.fromScale(0.5,0.5)
        closeIcon.ZIndex = 84
        recolourIcon(closeIcon,C.muted)

        local divider = frame(card,C.hairline)
        divider.Position = UDim2.fromOffset(8,34)
        divider.Size = UDim2.new(1,-16,0,1)
        divider.ZIndex = 82

        local scroll = Instance.new("ScrollingFrame")
        scroll.Name = "Options"
        scroll.Position = UDim2.fromOffset(6,40)
        scroll.Size = UDim2.new(1,-12,1,-46)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = #options > visibleRows and 2 or 0
        scroll.ScrollBarImageColor3 = C.faint
        scroll.CanvasSize = UDim2.fromOffset(0,#options*rowH)
        scroll.ZIndex = 82
        scroll.Parent = card

        local rows = {}
        local function paintRow(opt, row, txt, marker, check)
            local selected = selectedFn(opt) == true
            row.BackgroundColor3 = C.surface
            row.BackgroundTransparency = selected and 0.36 or 1
            marker.Visible = selected
            txt.TextColor3 = selected and C.text or C.dim
            check.Visible = selected
        end

        for i,opt in ipairs(options) do
            local row = button(scroll, "", UI.M.small, C.dim, C.pop)
            row.Position = UDim2.fromOffset(0,(i-1)*rowH)
            row.Size = UDim2.new(1,-4,0,rowH-1)
            row.BackgroundTransparency = 1
            row.AutoButtonColor = false
            row.ZIndex = 83
            corner(row,4)

            local marker = frame(row,C.accent)
            marker.Size = UDim2.fromOffset(2,13)
            marker.Position = UDim2.fromOffset(0,5)
            marker.ZIndex = 84
            corner(marker,2)

            local txt = label(row, tostring(opt), UI.M.small, C.dim, UI.F.body)
            txt.Position = UDim2.fromOffset(9,0)
            txt.Size = UDim2.new(1,-35,1,0)
            txt.ZIndex = 84
            txt.TextTruncate = Enum.TextTruncate.AtEnd

            local check = icon(row,"check",12)
            check.AnchorPoint = Vector2.new(1,0.5)
            check.Position = UDim2.new(1,-7,0.5,0)
            check.ZIndex = 84
            recolourIcon(check,C.accent)

            rows[opt]={row,txt,marker,check}
            paintRow(opt,row,txt,marker,check)

            row.MouseEnter:Connect(function()
                if not selectedFn(opt) then
                    row.BackgroundTransparency = 0.58
                    txt.TextColor3 = C.text
                end
            end)
            row.MouseLeave:Connect(function()
                paintRow(opt,row,txt,marker,check)
            end)
            row.MouseButton1Click:Connect(function()
                onPick(opt)
                if multi then
                    for item,parts in pairs(rows) do
                        paintRow(item,parts[1],parts[2],parts[3],parts[4])
                    end
                else
                    UI.closeOptionsModal()
                end
            end)
        end

        close.MouseEnter:Connect(function()
            close.BackgroundTransparency = 0
            close.BackgroundColor3 = C.surface
            UI.tintIcon(closeIcon,C.text,true)
        end)
        close.MouseLeave:Connect(function()
            close.BackgroundTransparency = 1
            UI.tintIcon(closeIcon,C.muted,true)
        end)
        close.MouseButton1Click:Connect(UI.closeOptionsModal)
        overlay.MouseButton1Click:Connect(function(x,y)
            local p,s=card.AbsolutePosition,card.AbsoluteSize
            if x<p.X or x>p.X+s.X or y<p.Y or y>p.Y+s.Y then UI.closeOptionsModal() end
        end)
    end

    function UI.riskText(tag: any): string
        local t = string.upper(tostring(tag))
        if t == "SERVER-CHECKED" then
            return "The server checks this. Push it too far and shots stop counting or you get pulled back."
        elseif t == "EXPERIMENTAL" then
            return "Experimental: may not work on every map or after a game update."
        elseif t == "TELEPORT" then
            return "Moves your character. Other players can see it."
        elseif t == "UNTESTED VS SERVER" then
            return "Not yet verified against the server in a real match."
        elseif t == "TRUE" or t == "DANGER" then
            return "Risky: other players or the server can notice it."
        end
        return tostring(tag)
    end






    UI.GROUP_ICONS = {
        { "max", "auto_awesome" }, { "extra", "auto_awesome" }, { "intel", "visibility" }, { "right now", "info" }, { "stat", "info" },
        { "farm", "refresh" }, { "esp", "visibility" }, { "cham", "visibility" }, { "info", "info" }, { "color", "tune" },
        { "style", "tune" }, { "look", "tune" }, { "silent", "track_changes" }, { "trigger", "my_location" }, { "aim", "gps_fixed" },
        { "target", "gps_fixed" }, { "rage", "bolt" }, { "anti", "360" }, { "world", "public" }, { "map", "public" }, { "skin", "checkroom" },
        { "hud", "dashboard" }, { "menu", "dashboard" }, { "interface", "dashboard" }, { "bind", "keyboard" }, { "key", "keyboard" },
        { "config", "save" }, { "cloud", "save" }, { "player", "person_outline" }, { "spoof", "person_outline" }, { "staff", "warning_amber" },
    }
    function UI.groupIcon(title: string): string
        local t = string.lower(title)
        for _, p in ipairs(UI.GROUP_ICONS) do
            if string.find(t, p[1], 1, true) then
                return p[2]
            end
        end
        return "tune"
    end
    function UI.group(parent: GuiObject, title: string, opts: any?): any
        opts = opts or {}
        local gf = frame(parent)
        gf.Name = "Group_" .. title
        gf.AutomaticSize = Enum.AutomaticSize.Y
        gf.Size = UDim2.new(1, 0, 0, 0)
        gf.LayoutOrder = nextOrder()
        -- Keep every UI component from visually touching the next one.
        -- Bare groups place controls directly in gf; card groups get spacing on the card below.
        local componentGap = opts.componentGap or (IS_LION and 2 or 6)
        vlist(gf, if opts.bare then componentGap else 0)
        padding(gf, 0, 0, if opts.bare then 0 else 12, 0)
        local M = UI.M

        local body: Frame = gf
        local card,cardBorder,titleLabel
        if not opts.bare then
            card = frame(gf, C.surface:Lerp(C.bg, 0.45))
            card.Name = "Card"
            card.BackgroundTransparency = IS_LION and 0.18 or 0.08
            card.AutomaticSize = Enum.AutomaticSize.Y
            card.Size = UDim2.new(1, 0, 0, 0)
            corner(card, IS_LION and 2 or 10)
            cardBorder=stroke(card, C.hairline, 0.35)
            vlist(card, componentGap)
            padding(card, 0, 10, 6, 10)
            body = card
            local head = frame(card)
            head.Name = "Head"
            head.Size = UDim2.new(1, 0, 0, IS_LION and 22 or 32)
            head.LayoutOrder = nextOrder()
            local separator=frame(head,C.edge)
            separator.Size=UDim2.new(1,20,0,1) separator.Position=UDim2.new(0,-10,1,0)
            local t = label(head, string.lower(title), M.value, C.text, UI.F.semibold)
            t.Name = "Title"
            t.TextTruncate=Enum.TextTruncate.AtEnd
            t.Size = UDim2.new(1, 0, 1, 0)
            titleLabel=t
            if IS_LION then
                t.Text = title
                t.TextXAlignment = Enum.TextXAlignment.Center
                separator.BackgroundColor3 = C.accent
                separator.Position = UDim2.new(0,-10,0,0)
            end

            if not IS_LION then
                local gi = icon(head, UI.groupIcon(title), 14)
                gi.AnchorPoint = Vector2.new(0, 0.5)
                gi.Position = UDim2.new(0, -1, 0.5, 0)
                recolourIcon(gi, C.accent)
                t.Position = UDim2.fromOffset(20, 0)
                t.Size = UDim2.new(1, -20, 1, 0)
            end
            if opts.max then

                local mk = UI.sparkles(head, 13, UI.MAX_MARK, t.ZIndex + 1)
                mk.Name = "MaxMark"
                mk.AnchorPoint = Vector2.new(0, 0.5)
                local function placeMark()
                    mk.Position = UDim2.new(0, t.Position.X.Offset + math.floor(t.TextBounds.X) + 5, 0.5, 0)
                end
                placeMark()
                t:GetPropertyChangedSignal("TextBounds"):Connect(placeMark)
                UI.tip(mk, "Max only")
            end
            local hl = frame(head, C.hairline)
            hl.Size = UDim2.new(1, 20, 0, 1)
            hl.Position = UDim2.new(0, -10, 1, -1)
            local gap = frame(card)
            gap.Size = UDim2.new(1, 0, 0, 4)
            gap.LayoutOrder = nextOrder()
        end

        local g: any = { frame = gf, rows = {}, advanced = opts.advanced == true, title = title,card=card,cardBorder=cardBorder,titleLabel=titleLabel }
        table.insert(UI.groups, g)
        if not UI.groupThemeBound then
            UI.groupThemeBound=true
            UI.onThemeChanged(function()
                for _,group in ipairs(UI.groups or {}) do
                    if group.card and group.card.Parent then
                        group.card.BackgroundColor3=C.surface:Lerp(C.bg,0.45)
                        group.cardBorder.Color=C.hairline
                        group.titleLabel.TextColor3=C.text
                    end
                end
            end)
        end

        local function row(h: number, text: string?, ropts: any?): Frame
            ropts = ropts or {}
            local r = frame(body)
            r.Size = UDim2.new(1, 0, 0, h)
            r.LayoutOrder = nextOrder()
            local entry: any = { frame = r, text = string.lower(text or ""), advanced = UI.isAdvanced(ropts, text, opts), base = h, descText = ropts.desc, isNote = ropts.isNote == true }


            if g.subParent then
                entry.parent = g.subParent
                entry.advanced = false
                local pad = Instance.new("UIPadding")
                pad.PaddingLeft = UDim.new(0, 16)
                pad.Parent = r
                local rail = frame(r, C.hairline)
                rail.Name = "SubRail"
                rail.Size = UDim2.new(0, 1, 1, -6)
                rail.Position = UDim2.new(0, -10, 0, 3)
                r.Visible = false
            end
            table.insert(UI.rows, entry)
            table.insert(g.rows, entry)
            return r
        end
        g.row = row



        local function rowLabel(r: Frame, text: string, ropts: any, reserve: number): TextLabel
            local l = label(r, string.lower(text), M.title, C.text, UI.F.body)
            l.Name = "Label"
            l.Size = UDim2.new(1, -(reserve + 24), 1, 0)
            l.TextTruncate = Enum.TextTruncate.AtEnd
            local warnText = if ropts.danger then UI.riskText(ropts.danger) else nil
            local helpText = if type(ropts.desc) == "string" and ropts.desc ~= "" then ropts.desc else nil


            local function textEnd(): number
                local w = math.ceil(l.TextBounds.X)
                local box = l.AbsoluteSize.X
                return if box > 0 then math.min(w, math.floor(box)) else w
            end


            local function follow(fn: () -> ())
                fn()
                l:GetPropertyChangedSignal("TextBounds"):Connect(fn)
                l:GetPropertyChangedSignal("AbsoluteSize"):Connect(fn)
                task.delay(0.5, fn)
                task.delay(2, fn)
            end
            local markW = 0
            if ropts.max or opts.max then
                markW = 16
                local mk = UI.sparkles(r, 12, UI.MAX_MARK, l.ZIndex + 1)
                mk.Name = "MaxMark"
                mk.AnchorPoint = Vector2.new(0, 0.5)
                follow(function()
                    if mk.Parent then
                        mk.Position = UDim2.new(0, textEnd() + 5, 0.5, 0)
                    end
                end)
            end
            if warnText or helpText then
                local tip = if warnText and helpText then warnText .. "\n\n" .. helpText else (warnText or helpText) :: string
                local holder = frame(r)
                holder.Name = "Hint"
                holder.Size = UDim2.fromOffset(16, 16)
                holder.AnchorPoint = Vector2.new(0, 0.5)
                holder.Position = UDim2.new(0, 0, 0.5, 0)
                local ic = icon(holder, if warnText then "warn" else "help", 14)
                recolourIcon(ic, if warnText then C.warn else C.faint)
                follow(function()
                    if holder.Parent then
                        holder.Position = UDim2.new(0, textEnd() + 7 + markW, 0.5, 0)
                    end
                end)
                UI.tip(holder, tip)
                UI.tip(l, tip)
                holder.MouseEnter:Connect(function()
                    if not warnText then
                        recolourIcon(ic, C.dim)
                    end
                end)
                holder.MouseLeave:Connect(function()
                    if not warnText then
                        recolourIcon(ic, C.faint)
                    end
                end)
            end
            return l
        end
        g.rowLabel = rowLabel

        function g.toggle(_, text: string, key: string, topts: any?)
            topts = topts or {}
            topts.cfgKey = key
            UI.count("toggle")
            Input.bindLabels[key] = text
            if topts.bindable and type(cfg.binds[key])~="table" then
                cfg.binds[key] = {key="",mode="Toggle"}
            end
            local r = row(M.row, text, topts)
            local l = rowLabel(r, text, topts, M.pillW + 8)

            local pill = button(r, "", 10, C.text, C.off)
            pill.Name = "Switch"
            pill.BackgroundTransparency = 1
            pill.Size = UDim2.new(0, M.pillW, 0, M.pillH)
            pill.AnchorPoint = Vector2.new(1, 0.5)
            pill.Position = UDim2.new(1, 0, 0.5, 0)
            if IS_LION then
                pill.AnchorPoint = Vector2.new(0,0.5)
                pill.Position = UDim2.new(0,0,0.5,0)
                l.Position = UDim2.fromOffset(22,0)
            end
            local glow = UI.glow(pill, 7, 0.9)
            glow.ZIndex = 1
            local track = frame(pill, C.off)
            track.Size = UDim2.fromScale(1, 1)
            track.ZIndex = 2
            corner(track, M.pillH // 2)


            local fill = frame(pill, Color3.new(1, 1, 1))
            fill.Size = UDim2.fromScale(1, 1)
            fill.ZIndex = 2
            fill.BackgroundTransparency = 1
            corner(fill, M.pillH // 2)
            UI.metalFill(gradient(fill, C.accent2, C.accent))
            local knob = frame(pill, C.knobOff)
            knob.Size = UDim2.new(0, M.knob, 0, M.knob)
            knob.AnchorPoint = Vector2.new(0, 0.5)
            knob.Position = UDim2.new(0, 2, 0.5, 0)
            knob.ZIndex = 3
            knob.Visible = not IS_LION
            corner(knob, M.knob // 2)

            local tag = label(r, "", M.small, C.muted, UI.F.medium)
            tag.Name = "Bind"
            tag.Size = UDim2.new(0, 30, 0, 18)
            tag.AnchorPoint = Vector2.new(1, 0.5)
            tag.Position = UDim2.new(1, -(M.pillW + 8), 0.5, 0)
            tag.BackgroundColor3 = Color3.fromRGB(26, 25, 32)
            tag.BackgroundTransparency = 0
            tag.TextXAlignment = Enum.TextXAlignment.Center
            tag.Visible = false
            corner(tag, 4)
            stroke(tag, C.edge, 0)

            local need = topts.needs or UI.NEEDS[key]
            local needTag: TextLabel? = nil
            if need then
                local first = if type(need) == "table" then need[1] else need
                local nt = label(r, UI.needText(first), M.small, C.warn, UI.F.medium)
                nt.Name = "Needs"
                nt.Size = UDim2.new(0, 96, 0, 18)
                nt.AnchorPoint = Vector2.new(1, 0.5)
                nt.TextXAlignment = Enum.TextXAlignment.Right
                nt.Visible = false
                needTag = nt
            end


            local subState: any = nil
            local exp: TextButton? = nil
            local expIc: GuiObject? = nil
            if type(topts.sub) == "function" then
                subState = { open = false, when = topts.subWhen }
                local eb = button(r, "", M.small, C.text, C.card)
                eb.Name = "Expand"
                eb.BackgroundTransparency = 1
                eb.Size = UDim2.fromOffset(20, 20)
                eb.AnchorPoint = Vector2.new(1, 0.5)
                corner(eb, 5)
                expIc = icon(eb, "menu", 14)
                recolourIcon(expIc :: GuiObject, C.muted)
                exp = eb
                UI.tip(eb, "More options for " .. text)
            end
            local function expShown(): boolean
                return subState ~= nil and (subState.when == nil or subState.when() == true)
            end

            local function layout()
                local x = M.pillW + 8
                if tag.Visible then
                    x += tag.Size.X.Offset + 6
                end
                if exp then
                    local shown = expShown()
                    exp.Visible = shown
                    exp.Position = UDim2.new(1, -x, 0.5, 0)
                    if shown then
                        x += 20 + 6
                    end
                end
                if needTag then
                    needTag.Position = UDim2.new(1, -x, 0.5, 0)
                    if needTag.Visible then
                        x += needTag.Size.X.Offset + 6
                    end
                end
                l.Size = UDim2.new(1, -(x + 24), 1, 0)
            end
            local function refreshTag()
                local b = cfg.binds[key]
                if type(b) == "table" and ((b.key and b.key ~= "") or b.mode == "Always" or b.mode == "Never") then
                    local mode = b.mode or "Toggle"
                    tag.Text = if mode == "Toggle" then Input.keyLabel(b.key) elseif mode == "Hold" then Input.keyLabel(b.key) .. " hold" else string.lower(mode)
                    tag.Size = UDim2.new(0, math.max(24, UI.textW(tag.Text, M.small) + 14), 0, 18)

                    tag.TextColor3 = if UI.brushed(tag) then UI.metal.ink else C.muted
                    tag.Visible = true
                else
                    tag.Text = ""
                    tag.Visible = false
                end
                layout()
            end
            refreshTag()

            do
                local prevTag = UI.bindTags[key]
                UI.bindTags[key] = if prevTag then function()
                    prevTag()
                    refreshTag()
                end else refreshTag
            end
            r.Active = true
            local lastShown: boolean? = nil
            local lastNeed: string? = nil
            local function displayEnabled(): boolean
                local binding = cfg.binds[key]
                local mode = type(binding) == "table" and binding.mode or "Toggle"
                -- Hold is an armed mode: keep the toggle visibly enabled even while the
                -- bound key is released. cfg[key] remains the live/runtime state.
                return cfg[key] == true or (topts.bindable == true and mode == "Hold")
            end
            local function refresh(animate: boolean)
                local runtimeOn = cfg[key] == true
                local on = displayEnabled()
                lastShown = on
                local unmet = UI.needUnmet(need)
                local blocked = unmet ~= nil
                lastNeed = unmet
                if needTag then
                    local show = runtimeOn and blocked
                    if unmet then
                        needTag.Text = UI.needText(unmet)
                    end
                    if needTag.Visible ~= show then
                        needTag.Visible = show
                        layout()
                    end
                end
                local knobGoal = if on then UDim2.new(1, -(M.knob + 2), 0.5, 0) else UDim2.new(0, 2, 0.5, 0)
                local knobCol = if on then Color3.new(1, 1, 1) else C.knobOff
                local labelCol = if on and not blocked then C.text else C.dim
                local glowTr = if on then UI.glowAlpha(0.9) else 1
                if animate then
                    tween(knob, TW_TOGGLE, { Position = knobGoal, BackgroundColor3 = knobCol })
                    tween(fill, TW_TOGGLE, { BackgroundTransparency = if on then 0 else 1 })
                    tween(l, TW_TOGGLE, { TextColor3 = labelCol })
                    tween(glow, TW_TOGGLE, { ImageTransparency = glowTr })
                else
                    knob.Position = knobGoal
                    knob.BackgroundColor3 = knobCol
                    fill.BackgroundTransparency = if on then 0 else 1
                    l.TextColor3 = labelCol
                    glow.ImageTransparency = glowTr
                end
                glow:SetAttribute("glowOff", not on)
            end
            refresh(false)
            local lastExp = expShown()
            table.insert(UI.sync, function()
                if displayEnabled() ~= lastShown or (need ~= nil and UI.needUnmet(need) ~= lastNeed) then
                    refresh(true)
                end
                if exp and expShown() ~= lastExp then
                    lastExp = expShown()
                    layout()
                    UI.refilter()
                end
            end)



            do
                local prevReg = S.ui.toggles[key]
                S.ui.toggles[key] = { pill = pill, row = r, refresh = function()
                    if prevReg then
                        prevReg.refresh()
                    end
                    refresh(true)
                end, shown = function()
                    return lastShown
                end }
            end
            pill.MouseEnter:Connect(function()
                if displayEnabled() then
                    tween(glow, TW_HOVER, { ImageTransparency = UI.glowAlpha(1.3) })
                else
                    tween(knob, TW_HOVER, { BackgroundColor3 = C.dim })
                end
            end)
            pill.MouseLeave:Connect(function()
                if displayEnabled() then
                    tween(glow, TW_HOVER, { ImageTransparency = UI.glowAlpha(0.9) })
                else
                    tween(knob, TW_HOVER, { BackgroundColor3 = C.knobOff })
                end
            end)
            local function setToggleState(value, transient)
                value = value == true
                if cfg[key] == value then
                    refresh(true)
                    return
                end
                cfg[key] = value
                refresh(true)
                if topts.onChange then
                    topts.onChange(value)
                end
                -- Hold key press/release is runtime state, not a config edit.
                if transient ~= true then saveConfig() end
            end

            pill.MouseButton1Click:Connect(function()
                setToggleState(not cfg[key])
            end)

            if topts.bindable then
                Input.toggleBindHandlers[key] = setToggleState
                Input.bindCallbacks[key] = function(boundKey,mode)
                    local binding = cfg.binds[key]
                    if type(binding)~="table" then
                        binding = {key="",mode="Toggle"}
                    end
                    if boundKey ~= nil then binding.key = tostring(boundKey) end
                    if mode ~= nil then binding.mode = tostring(mode) end
                    cfg.binds[key] = binding
                    if binding.mode == "Always" then
                        setToggleState(true)
                    elseif binding.mode == "Never" then
                        setToggleState(false)
                    elseif binding.mode == "Hold" then
                        setToggleState(binding.key ~= "" and Input.keyDown[binding.key] == true, true)
                    end
                    refreshTag()
                end

                r.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton2 then
                        UI.openBindPopup(key,text,UIS:GetMouseLocation()-Vector2.new(0,GuiService:GetGuiInset().Y))
                    end
                end)

                tag.Active = true
                tag.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Touch then
                        UI.openKeyModeMenu(key,text,Vector2.new(input.Position.X,input.Position.Y))
                    elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                        UI.openBindPopup(key,text,UIS:GetMouseLocation()-Vector2.new(0,GuiService:GetGuiInset().Y))
                    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                        UI.openKeyModeMenu(key,text,UIS:GetMouseLocation()-Vector2.new(0,GuiService:GetGuiInset().Y))
                    end
                end)

                local binding = cfg.binds[key]
                if type(binding)=="table" then
                    task.defer(function()
                        local callback = Input.bindCallbacks[key]
                        if callback then callback(binding.key,binding.mode) end
                    end)
                end
            end
            if subState and exp then

                local prevParent = g.subParent
                g.subParent = subState
                local okSub, errSub = pcall(topts.sub, g)
                g.subParent = prevParent
                if not okSub then
                    log("WARN", ("menu: the sub-options of %s failed to build: %s"):format(text, tostring(errSub)))
                end
                exp.MouseButton1Click:Connect(function()
                    if subState.animating then
                        return
                    end
                    local opening = not subState.open
                    if UI.brushed(exp :: TextButton) then

                        local light = (exp :: TextButton):FindFirstChild("BrushedLight")
                        if light then
                            (light :: Frame).Visible = opening
                        end
                        (exp :: TextButton).BackgroundTransparency = if opening then 0 else 1
                        recolourIcon(expIc :: GuiObject, if opening then UI.metal.ink else C.muted)
                    else
                        recolourIcon(expIc :: GuiObject, if opening then C.accent else C.muted)
                    end
                    if opening then
                        subState.open = true
                        UI.refilter()
                        UI.animSub(subState, true, nil)
                    else
                        UI.animSub(subState, false, function()
                            subState.open = false
                            UI.refilter()
                        end)
                    end
                end)
                exp.MouseEnter:Connect(function()
                    if not (UI.metal and subState.open) then
                        (exp :: TextButton).BackgroundTransparency = if UI.metal then 0.85 else 0
                    end
                end)
                exp.MouseLeave:Connect(function()
                    if not (UI.metal and subState.open) then
                        (exp :: TextButton).BackgroundTransparency = 1
                    end
                end)
            end
            return r
        end

        function g.slider(_, text: string, key: string, min: number, max: number, step: number?, sopts: any?)
            sopts = sopts or {}
            sopts.cfgKey = key
            UI.count("slider")
            local r = row(IS_LION and M.rowSlider or M.row, text, sopts)
            local trackW = sopts.trackW or M.trackW
            local reserve = trackW + 10 + M.valueW
            local sliderLabel = rowLabel(r, text, sopts, reserve)
            if IS_LION then
                sliderLabel.Size = UDim2.new(1,0,0,16)
                sliderLabel.Position = UDim2.fromOffset(0,0)
            end

            local v = button(r, "", M.value, C.text, C.surface)
            v.Name = "Value"
            v.BackgroundTransparency = 1
            v.Size = UDim2.new(0, M.valueW, 1, 0)
            v.AnchorPoint = Vector2.new(1, 0)
            v.Position = UDim2.new(1, 0, 0, 0)
            v.TextXAlignment = Enum.TextXAlignment.Right
            v.RichText = true
            if IS_LION then
                v.AnchorPoint = Vector2.new(0.5,0)
                v.Position = UDim2.new(0.5,0,0,18)
                v.Size = UDim2.new(0.65,0,0,16)
                v.TextXAlignment = Enum.TextXAlignment.Center
                v.ZIndex = 5
            end

            local warnIc: GuiObject? = nil
            if sopts.safe then
                local holder = frame(r)
                holder.Size = UDim2.fromOffset(16, 16)
                holder.AnchorPoint = Vector2.new(1, 0.5)
                holder.Position = UDim2.new(1, -(reserve + 4), 0.5, 0)
                holder.Visible = false
                local wi = icon(holder, "warn", 14)
                recolourIcon(wi, C.warn)
                UI.tip(holder, UI.riskText(sopts.safeText or "SERVER-CHECKED"))
                warnIc = holder
            end

            local rail = button(r, "", 10, C.text, C.off)
            rail.Name = "Rail"
            rail.BackgroundTransparency = 1
            rail.Size = UDim2.new(0, trackW, 0, 16)
            rail.AnchorPoint = Vector2.new(1, 0.5)
            rail.Position = UDim2.new(1, -(M.valueW + 10), 0.5, 0)
            if IS_LION then
                rail.Size = UDim2.new(1,0,0,16)
                rail.AnchorPoint = Vector2.new(0,0)
                rail.Position = UDim2.fromOffset(0,18)
            end
            local track = frame(rail, C.off)
            track.Size = UDim2.new(1, 0, 0, IS_LION and 14 or 4)
            track.AnchorPoint = Vector2.new(0, 0.5)
            track.Position = UDim2.new(0, 0, 0.5, 0)
            corner(track, 2)
            local fillGlow = UI.glow(track, 5, 0.7)
            fillGlow.Visible = not IS_LION
            fillGlow.AnchorPoint = Vector2.new(0, 0.5)
            fillGlow.Position = UDim2.new(0, -5, 0.5, 0)
            local fill = frame(track, Color3.new(1, 1, 1))
            fill.Size = UDim2.new(0, 0, 1, 0)
            corner(fill, 2)
            UI.metalFill(gradient(fill, C.accent2, C.accent))
            local knob = frame(track, Color3.new(1, 1, 1))
            knob.Size = UDim2.new(0, 10, 0, 10)
            knob.AnchorPoint = Vector2.new(0.5, 0.5)
            knob.Position = UDim2.new(0, 0, 0.5, 0)
            knob.Visible = not IS_LION
            corner(knob, 5)
            local ring = stroke(knob, if UI.metal then UI.metal.lite else C.accent, 1)
            ring.Thickness = if UI.metal then 2 else 3
            local function fmt(n: number): string
                if sopts.fmt then
                    return sopts.fmt(n)
                end
                return tostring(math.floor(n * 100 + 0.5) / 100)
            end
            local unit = if type(sopts.unit) == "string" and sopts.unit ~= "" then sopts.unit else nil
            local mutedHex = ("#%02x%02x%02x"):format(math.floor(C.muted.R * 255 + 0.5), math.floor(C.muted.G * 255 + 0.5), math.floor(C.muted.B * 255 + 0.5))
            local shownText = ""
            local function refresh(animateKnob: boolean?)
                local n = tonumber(cfg[key]) or min
                local rel = math.clamp((n - min) / math.max(max - min, 1e-6), 0, 1)
                local kp = UDim2.new(rel, 0, 0.5, 0)
                fillGlow.Visible = not IS_LION and rel > 0.01

                if animateKnob then
                    tween(knob, TW_KNOB, { Position = kp })
                    tween(fill, TW_KNOB, { Size = UDim2.new(rel, 0, 1, 0) })
                    tween(fillGlow, TW_KNOB, { Size = UDim2.new(rel, 10, 1, 10) })
                else
                    knob.Position = kp
                    fill.Size = UDim2.new(rel, 0, 1, 0)
                    fillGlow.Size = UDim2.new(rel, 10, 1, 10)
                end
                shownText = fmt(n)
                local unsafe = sopts.safe ~= nil and (n < sopts.safe[1] or n > sopts.safe[2])
                local numCol = if unsafe then ("#%02x%02x%02x"):format(math.floor(C.warn.R * 255 + 0.5), math.floor(C.warn.G * 255 + 0.5), math.floor(C.warn.B * 255 + 0.5)) else nil
                local num = if numCol then ('<font color="%s">%s</font>'):format(numCol, shownText) else shownText
                v.Text = if unit then ('%s<font color="%s">%s%s</font>'):format(num, mutedHex, if unit == "%" or unit == "°" or unit == "×" then "" else " ", unit) else num
                if warnIc then
                    warnIc.Visible = unsafe
                end
            end
            local function setRing(on: boolean)
                tween(ring, TW_HOVER, { Transparency = if on then 0.72 else 1 })
            end
            rail.MouseEnter:Connect(function()
                setRing(true)
            end)
            rail.MouseLeave:Connect(function()
                if not (UI.drag and UI.drag.owner == rail) then
                    setRing(false)
                end
            end)
            local lastChangeAt = 0
            local function setValue(n: number, dragging: boolean?)
                if step then
                    n = math.floor(n / step + 0.5) * step

                    local digits = math.max(0, math.ceil(-math.log10(step)))
                    local pow = 10 ^ digits
                    n = math.floor(n * pow + 0.5) / pow
                end
                n = math.clamp(n, min, max)
                if cfg[key] == n then
                    return
                end
                cfg[key] = n


                refresh(not dragging)
                if sopts.onChange then
                    local now = os.clock()
                    if not dragging or now - lastChangeAt > 0.05 then
                        lastChangeAt = now
                        sopts.onChange(n)
                    end
                end
            end
            local function setFromX(x: number, dragging: boolean?)
                local rel = math.clamp((x - rail.AbsolutePosition.X) / math.max(rail.AbsoluteSize.X, 1), 0, 1)
                setValue(min + (max - min) * rel, dragging)
            end
            refresh(false)
            table.insert(UI.sync, function()
                if fmt(tonumber(cfg[key]) or min) ~= shownText then
                    refresh(true)
                end
            end)


            rail.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    setFromX(i.Position.X, true)
                    setRing(true)
                    UI.beginDrag(function(pos: Vector2)
                        setFromX(pos.X, true)
                    end, function()
                        if sopts.onChange then
                            sopts.onChange(tonumber(cfg[key]) or min)
                        end
                        refresh(true)
                        setRing(false)
                        saveConfig()
                    end)
                    if UI.drag then
                        UI.drag.owner = rail
                    end
                end
            end)




            local tMin = if type(sopts.typeMin) == "number" then sopts.typeMin else min
            local tMax = if type(sopts.typeMax) == "number" then sopts.typeMax else max
            local typeDigits = if step and step >= 1 then 0 else 3
            local function plain(n: number): string
                local s = ("%." .. typeDigits .. "f"):format(n)
                if typeDigits > 0 then
                    s = string.gsub(string.gsub(s, "0+$", ""), "%.$", "")
                end
                return s
            end
            UI.tip(v, ("Click to type a value (%s – %s)"):format(plain(tMin), plain(tMax)))
            v.MouseEnter:Connect(function()
                v.BackgroundTransparency = 0.55
            end)
            v.MouseLeave:Connect(function()
                v.BackgroundTransparency = 1
            end)
            local editing = false
            v.MouseButton1Click:Connect(function()
                if editing then
                    return
                end
                editing = true
                local box = Instance.new("TextBox")
                box.Size = UDim2.new(0, math.max(M.valueW + 24, 66), 0, 22)
                box.AnchorPoint = Vector2.new(1, 0.5)
                box.Position = UDim2.new(1, 2, 0.5, 0)
                box.BackgroundColor3 = C.surface
                box.BorderSizePixel = 0
                UI.setFont(box, UI.F.medium)
                box.TextSize = M.value
                box.TextColor3 = C.text
                box.PlaceholderText = plain(tonumber(cfg[key]) or min)
                box.PlaceholderColor3 = C.muted
                box.TextXAlignment = Enum.TextXAlignment.Right
                box.Text = plain(tonumber(cfg[key]) or min)
                box.ClearTextOnFocus = false
                box.ZIndex = 5
                box.Parent = r
                corner(box, 5)
                stroke(box, C.accent, 0.2)
                padding(box, 0, 6, 0, 6)
                box:CaptureFocus()
                pcall(function()
                    box.SelectionStart = 1
                    box.CursorPosition = #box.Text + 1
                end)
                box.FocusLost:Connect(function(enterPressed: boolean)
                    editing = false
                    local n = if enterPressed then UI.parseNumber(box.Text) else nil
                    box:Destroy()
                    if n == nil then
                        return
                    end
                    local pow = 10 ^ typeDigits
                    n = math.clamp(math.floor(n * pow + 0.5) / pow, tMin, tMax)
                    if cfg[key] ~= n then
                        cfg[key] = n
                        refresh(true)
                        if sopts.onChange then
                            sopts.onChange(n)
                        end
                    else
                        refresh(true)
                    end
                    saveConfig()
                end)
            end)
            return r
        end

        function g.cycle(_, text: string, key: string, options: { string }, copts: any?)
            copts = copts or {}
            copts.cfgKey = key
            UI.count("cycle")
            local r = row(IS_LION and M.rowCycle or M.row, text, copts)
            local cycleLabel = rowLabel(r, text, copts, M.ctrlW)
            if IS_LION then cycleLabel.Size = UDim2.new(1,0,0,16) end


            local function shownOf(v: any): string
                if v == nil or tostring(v) == "" then
                    return string.lower(tostring(copts.placeholder or "None"))
                end
                if copts.fmt then
                    local okF, s = pcall(copts.fmt, v)
                    if okF and s ~= nil then
                        return string.lower(tostring(s))
                    end
                end
                return string.lower(tostring(v))
            end
            local b = button(r, "", M.value, C.text, C.surface)
            b.Name = "Dropdown"
            b.Size = UDim2.new(0, M.ctrlW, 0, 22)
            b.AnchorPoint = Vector2.new(1, 0.5)
            b.Position = UDim2.new(1, 0, 0.5, 0)
            corner(b, IS_LION and 2 or 5)
            if IS_LION then
                b.Size = UDim2.new(1,0,0,22)
                b.AnchorPoint = Vector2.zero
                b.Position = UDim2.fromOffset(0,18)
            end
            local bs = stroke(b, C.edge, 0)
            local val = label(b, "", M.value, C.text, UI.F.body)
            val.Size = UDim2.new(1, -30, 1, 0)
            val.Position = UDim2.fromOffset(9, 0)
            val.TextTruncate = Enum.TextTruncate.AtEnd
            local chev = icon(b, "expand", 16)
            chev.AnchorPoint = Vector2.new(1, 0.5)
            chev.Position = UDim2.new(1, -4, 0.5, 0)
            recolourIcon(chev, C.muted)
            local function refresh()
                val.Text = shownOf(cfg[key])
            end
            refresh()
            table.insert(UI.sync, function()
                if val.Text ~= shownOf(cfg[key]) then
                    refresh()
                end
            end)
            b.MouseEnter:Connect(function()
                b.BackgroundColor3 = C.card
            end)
            b.MouseLeave:Connect(function()
                b.BackgroundColor3 = C.surface
            end)
            b.MouseButton1Click:Connect(function()
                bs.Color = C.accent
                UI.openDropdown(b, IS_LION and math.max(M.ctrlW,b.AbsoluteSize.X) or M.ctrlW, function(f: Frame): number
                    local shown = #options > 8 and 7 or #options
                    for i = 1, shown do
                        local opt = options[i]
                        UI.dropdownOption(f, 4 + (i - 1) * 24, shownOf(opt), cfg[key] == opt, function()
                            cfg[key] = opt
                            refresh()
                            UI.closeDropdown()
                            if copts.onChange then copts.onChange(opt) end
                            saveConfig()
                        end)
                    end
                    if #options > shown then
                        UI.dropdownOption(f, 4 + shown * 24, "Full options…", false, function()
                            UI.openOptionsModal(text, options, function(opt)
                                return cfg[key] == opt
                            end, function(opt)
                                cfg[key] = opt
                                refresh()
                                if copts.onChange then copts.onChange(opt) end
                                saveConfig()
                            end, false)
                        end)
                        return 8 + (shown + 1) * 24
                    end
                    return 8 + shown * 24
                end, function()
                    bs.Color = C.edge
                end)
            end)
            return r
        end

        function g.color(_, text: string, key: string, copts: any?)
            copts = copts or {}
            copts.cfgKey = key
            UI.count("color")
            local r = row(M.row, text, copts)
            rowLabel(r, text, copts, 36)
            local sw = button(r, "", 10, C.text, Vis.col(key))
            sw.Name = "Swatch"
            sw.Size = UDim2.new(0, 28, 0, 16)
            sw.AnchorPoint = Vector2.new(1, 0.5)
            sw.Position = UDim2.new(1, 0, 0.5, 0)
            corner(sw, 4)
            stroke(sw, Color3.new(1, 1, 1), 0.82)

            local function toHex(c3: Color3): string
                return ("#%02X%02X%02X"):format(
                    math.floor(c3.R * 255 + 0.5),
                    math.floor(c3.G * 255 + 0.5),
                    math.floor(c3.B * 255 + 0.5)
                )
            end

            local function fromHex(raw: string): Color3?
                local clean = tostring(raw or ""):gsub("#", ""):gsub("%s+", "")
                if #clean == 3 then
                    clean = clean:sub(1,1):rep(2) .. clean:sub(2,2):rep(2) .. clean:sub(3,3):rep(2)
                end
                if #clean ~= 6 or clean:find("[^%x]") then return nil end
                local n = tonumber(clean, 16)
                if not n then return nil end
                return Color3.fromRGB(
                    math.floor(n / 65536) % 256,
                    math.floor(n / 256) % 256,
                    n % 256
                )
            end

            local function apply(c3: Color3)
                cfg[key] = {
                    math.floor(c3.R * 255 + 0.5),
                    math.floor(c3.G * 255 + 0.5),
                    math.floor(c3.B * 255 + 0.5)
                }
                sw.BackgroundColor3 = c3
                if copts.onChange then copts.onChange(c3) end
            end

            table.insert(UI.sync, function()
                local c = Vis.col(key)
                if sw.BackgroundColor3 ~= c then sw.BackgroundColor3 = c end
            end)

            sw.MouseButton1Click:Connect(function()
                local hh, ss, vv = Vis.col(key):ToHSV()
                UI.openDropdown(sw, 246, function(f: Frame): number
                    local sv = button(f, "", 10, C.text, Color3.fromHSV(hh, 1, 1))
                    sv.Name = "SaturationValue"
                    sv.Position = UDim2.fromOffset(10, 10)
                    sv.Size = UDim2.new(1, -20, 0, 96)
                    sv.ZIndex = 61
                    corner(sv, 6)
                    stroke(sv, C.edge, 0)

                    local white = frame(sv, Color3.new(1, 1, 1))
                    white.Size = UDim2.fromScale(1, 1)
                    white.ZIndex = 62
                    corner(white, 6)
                    local whiteGrad = Instance.new("UIGradient")
                    whiteGrad.Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 0),
                        NumberSequenceKeypoint.new(1, 1),
                    })
                    whiteGrad.Parent = white

                    local black = frame(sv, Color3.new(0, 0, 0))
                    black.Size = UDim2.fromScale(1, 1)
                    black.ZIndex = 63
                    corner(black, 6)
                    local blackGrad = Instance.new("UIGradient")
                    blackGrad.Rotation = 90
                    blackGrad.Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 1),
                        NumberSequenceKeypoint.new(1, 0),
                    })
                    blackGrad.Parent = black

                    local svMark = frame(sv, Color3.new(1, 1, 1))
                    svMark.Name = "Marker"
                    svMark.Size = UDim2.fromOffset(10, 10)
                    svMark.AnchorPoint = Vector2.new(0.5, 0.5)
                    svMark.ZIndex = 65
                    corner(svMark, 5)
                    stroke(svMark, Color3.new(0, 0, 0), 0.25)

                    local hue = button(f, "", 10, C.text, Color3.new(1, 1, 1))
                    hue.Name = "Hue"
                    hue.Position = UDim2.fromOffset(10, 114)
                    hue.Size = UDim2.new(1, -20, 0, 12)
                    hue.ZIndex = 61
                    corner(hue, 6)
                    local hueKeys = {}
                    for i = 0, 6 do
                        table.insert(hueKeys, ColorSequenceKeypoint.new(i / 6, Color3.fromHSV((i / 6) % 1, 1, 1)))
                    end
                    local hueGrad = Instance.new("UIGradient")
                    hueGrad.Color = ColorSequence.new(hueKeys)
                    hueGrad.Parent = hue
                    local hueMark = frame(hue, Color3.new(1, 1, 1))
                    hueMark.Size = UDim2.fromOffset(4, 16)
                    hueMark.AnchorPoint = Vector2.new(0.5, 0.5)
                    hueMark.ZIndex = 63
                    corner(hueMark, 2)
                    stroke(hueMark, Color3.new(0, 0, 0), 0.35)

                    local hex = Instance.new("TextBox")
                    hex.Name = "Hex"
                    hex.ClearTextOnFocus = false
                    hex.BackgroundColor3 = C.surface
                    hex.BorderSizePixel = 0
                    hex.Position = UDim2.fromOffset(10, 136)
                    hex.Size = UDim2.fromOffset(92, 26)
                    hex.TextColor3 = C.text
                    hex.PlaceholderColor3 = C.muted
                    hex.TextSize = M.value
                    hex.TextXAlignment = Enum.TextXAlignment.Center
                    hex.ZIndex = 62
                    UI.setFont(hex, UI.F.medium)
                    corner(hex, 5)
                    stroke(hex, C.edge, 0)

                    local rgb = label(f, "", M.small, C.dim, UI.F.medium)
                    rgb.Position = UDim2.fromOffset(110, 136)
                    rgb.Size = UDim2.new(1, -120, 0, 26)
                    rgb.TextXAlignment = Enum.TextXAlignment.Right
                    rgb.ZIndex = 62

                    local function current(): Color3
                        return Color3.fromHSV(hh, ss, vv)
                    end
                    local function refreshVisuals()
                        local c3 = current()
                        sv.BackgroundColor3 = Color3.fromHSV(hh, 1, 1)
                        svMark.Position = UDim2.new(ss, 0, 1 - vv, 0)
                        hueMark.Position = UDim2.new(hh, 0, 0.5, 0)
                        hex.Text = toHex(c3)
                        rgb.Text = ("%d, %d, %d"):format(
                            math.floor(c3.R * 255 + 0.5),
                            math.floor(c3.G * 255 + 0.5),
                            math.floor(c3.B * 255 + 0.5)
                        )
                    end
                    local function commit()
                        apply(current())
                        refreshVisuals()
                    end
                    local function setSV(pos: Vector2)
                        ss = math.clamp((pos.X - sv.AbsolutePosition.X) / math.max(sv.AbsoluteSize.X, 1), 0, 1)
                        vv = 1 - math.clamp((pos.Y - sv.AbsolutePosition.Y) / math.max(sv.AbsoluteSize.Y, 1), 0, 1)
                        commit()
                    end
                    local function setHue(pos: Vector2)
                        hh = math.clamp((pos.X - hue.AbsolutePosition.X) / math.max(hue.AbsoluteSize.X, 1), 0, 1)
                        commit()
                    end

                    sv.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            setSV(input.Position)
                            UI.beginDrag(setSV, saveConfig)
                        end
                    end)
                    hue.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            setHue(input.Position)
                            UI.beginDrag(setHue, saveConfig)
                        end
                    end)
                    hex.FocusLost:Connect(function()
                        local parsed = fromHex(hex.Text)
                        if parsed then
                            hh, ss, vv = parsed:ToHSV()
                            apply(parsed)
                            saveConfig()
                        end
                        refreshVisuals()
                    end)

                    local presets = {
                        C.accent,
                        Color3.fromRGB(255, 255, 255),
                        Color3.fromRGB(255, 80, 105),
                        Color3.fromRGB(255, 170, 65),
                        Color3.fromRGB(255, 225, 95),
                        Color3.fromRGB(80, 225, 165),
                        Color3.fromRGB(90, 185, 255),
                        Color3.fromRGB(180, 110, 255),
                    }
                    for i, pc in ipairs(presets) do
                        local pb = button(f, "", 10, C.text, pc)
                        pb.Size = UDim2.fromOffset(18, 18)
                        pb.Position = UDim2.fromOffset(10 + (i - 1) * 22, 170)
                        pb.ZIndex = 62
                        corner(pb, 9)
                        stroke(pb, Color3.new(1, 1, 1), 0.8)
                        pb.MouseButton1Click:Connect(function()
                            hh, ss, vv = pc:ToHSV()
                            apply(pc)
                            saveConfig()
                            refreshVisuals()
                        end)
                    end

                    refreshVisuals()
                    return 198
                end, copts.onClose)
            end)
            return r
        end

        function g.keybind(_, text: string, key: string, kopts: any?)
            kopts = kopts or {}
            kopts.cfgKey = key
            Input.bindLabels[key]=text
            if type(cfg.binds[key])~="table" then
                cfg.binds[key]={key=tostring(cfg[key] or ""),mode=kopts.mode or "Toggle"}
            end
            Input.bindCallbacks[key]=function(boundKey,mode)
                cfg[key]=boundKey
                if kopts.onChange then kopts.onChange(boundKey) end
                if kopts.onModeChange then kopts.onModeChange(mode) end
            end
            UI.count("keybind")
            local r = row(M.row, text, kopts)
            rowLabel(r, text, kopts, 90)
            local b = button(r, "", M.small, C.dim, Color3.fromRGB(26, 25, 32))
            b.Name = "Key"
            b.AutomaticSize = Enum.AutomaticSize.X
            b.Size = UDim2.new(0, 34, 0, 20)
            b.AnchorPoint = Vector2.new(1, 0.5)
            b.Position = UDim2.new(1, 0, 0.5, 0)
            UI.setFont(b, UI.F.semibold)
            corner(b, 4)
            local ks = stroke(b, C.edge, 0)
            padding(b, 0, 8, 0, 8)

            local keyed = UI.brushed(b)
            if keyed then
                b.TextColor3 = UI.metal.ink
                UI.setFont(b, UI.F.bold)
                b.BackgroundColor3 = Color3.fromRGB(228, 228, 232)
            end
            b.MouseEnter:Connect(function()
                if keyed then
                    tween(b, TW_HOVER, { BackgroundColor3 = Color3.new(1, 1, 1) })
                else
                    ks.Color = C.muted
                end
            end)
            b.MouseLeave:Connect(function()
                if keyed then
                    tween(b, TW_HOVER, { BackgroundColor3 = Color3.fromRGB(228, 228, 232) })
                else
                    ks.Color = C.edge
                end
            end)
            local function shownKey(): string
                local raw = cfg[key]
                if raw == nil or tostring(raw) == "" or tostring(raw) == "None" then
                    return tostring(kopts.placeholder or "None")
                end
                return Input.keyLabel(raw)
            end
            local function show()
                b.Text = shownKey()
            end
            show()
            table.insert(UI.sync, function()
                if not Input.capturing() and b.Text ~= shownKey() then
                    show()
                end
            end)
            b.Activated:Connect(function(input)
                if input and input.UserInputType==Enum.UserInputType.Touch then
                    UI.openKeyModeMenu(key,text,Vector2.new(input.Position.X,input.Position.Y))
                    return
                end
                b.Text = "Press a key…"
                Input.captureKey(function(name)
                    if name ~= false then
                        cfg[key] = name or ""
                        cfg.binds[key]=cfg.binds[key] or {mode=kopts.mode or "Toggle"}
                        cfg.binds[key].key=cfg[key]
                        saveConfig()
                        if kopts.onChange then
                            kopts.onChange(cfg[key])
                        end
                    end
                    show()
                end)
            end)
            local function openMode(input)
                if input.UserInputType==Enum.UserInputType.MouseButton2 then
                    UI.openKeyModeMenu(key,text,UIS:GetMouseLocation()-Vector2.new(0,GuiService:GetGuiInset().Y))
                end
            end
            b.InputBegan:Connect(openMode)
            return r
        end

        function g.button(_, text: string, fn: () -> (), tint: Color3?, bopts: any?)
            bopts = bopts or {}
            UI.count("button")
            local r = row(M.rowButton, text, bopts)

            local soft = tint ~= nil and tint ~= C.accent
            local base = if tint and not soft then tint else C.surface
            local b = button(r, string.lower(text), M.value, if tint then tint else C.dim, base)
            b.Size = UDim2.new(1, 0, 0, 26)
            b.AnchorPoint = Vector2.new(0, 0.5)
            b.Position = UDim2.new(0, 0, 0.5, 0)
            b.BackgroundTransparency = if bopts.primary then 0 elseif tint and not soft then 0.87 else 0
            if bopts.primary then
                b.TextColor3=C.bg
                UI.setFont(b,UI.F.bold)
                local fill=Instance.new("UIGradient")
                fill.Rotation=90
                fill.Color=ColorSequence.new(C.accent:Lerp(Color3.new(1,1,1),0.55),C.accent2)
                fill.Parent=b
            end
            b.TextTruncate = Enum.TextTruncate.AtEnd
            corner(b, 6)
            local st = stroke(b, if tint and not soft then tint else C.edge, if tint and not soft then 0.6 else 0)
            if soft then
                UI.softKey(b, tint :: Color3, st)
            end

            local keyed = tint == C.accent and UI.brushed(b)
            local rest = Color3.fromRGB(228, 228, 232)
            if keyed then
                b.BackgroundTransparency = 0
                b.BackgroundColor3 = rest
                b.TextColor3 = UI.metal.ink
                UI.setFont(b, UI.F.bold)
            end
            b.MouseEnter:Connect(function()
                if soft then
                    return
                elseif keyed then
                    tween(b, TW_HOVER, { BackgroundColor3 = Color3.new(1, 1, 1) })
                elseif tint then
                    tween(b, TW_HOVER, { BackgroundTransparency = 0.8 })
                else
                    tween(b, TW_HOVER, { BackgroundColor3 = C.card, TextColor3 = C.text })
                end
            end)
            b.MouseLeave:Connect(function()
                if soft then
                    return
                elseif keyed then
                    tween(b, TW_HOVER, { BackgroundColor3 = rest })
                elseif tint then
                    tween(b, TW_HOVER, { BackgroundTransparency = 0.87 })
                else
                    tween(b, TW_HOVER, { BackgroundColor3 = C.surface, TextColor3 = C.dim })
                end
            end)

            b.MouseButton1Down:Connect(function()
                b.Position = UDim2.new(0, 0, 0.5, 1)
                st.Transparency = 0
            end)
            b.MouseButton1Up:Connect(function()
                b.Position = UDim2.new(0, 0, 0.5, 0)
                st.Transparency = if keyed then 0.5 elseif tint and not soft then 0.6 else 0
            end)
            b.MouseButton1Click:Connect(function()
                local ok, err = pcall(fn)
                if not ok then
                    reportError("button " .. text, err)
                end
            end)
            if type(bopts.desc) == "string" and bopts.desc ~= "" then
                UI.tip(b, bopts.desc)
            end
            return b
        end

        function g.note(_, text: string, nopts: any?)
            nopts = nopts or {}
            nopts.isNote = true
            UI.count("note")


            local width = opts.colW or M.colW
            local minH = if text ~= "" then UI.textH(text, M.desc, nil, width) + 8 else math.max(18, nopts.height or 18)
            local r = row(minH, text, nopts)
            r.AutomaticSize = Enum.AutomaticSize.Y
            local l = label(r, text, M.desc, nopts.color or C.muted, UI.F.body)
            l.Size = UDim2.new(1, 0, 0, 0)
            l.Position = UDim2.new(0, 0, 0, 3)
            l.AutomaticSize = Enum.AutomaticSize.Y
            l.TextWrapped = true
            l.TextYAlignment = Enum.TextYAlignment.Top
            return l
        end


        function g.picker(_, text: string, getList: () -> { string }, idxKey: string, onChange: (string) -> ())
            UI.count("picker")
            local r = row(M.row, text)
            local l = label(r, string.lower(text), M.title, C.text, UI.F.body)
            l.Size = UDim2.new(0, 70, 1, 0)
            local val = label(r, "", M.value, C.text, UI.F.medium)
            val.Size = UDim2.new(1, -140, 1, 0)
            val.Position = UDim2.new(0, 74, 0, 0)
            val.TextTruncate = Enum.TextTruncate.AtEnd
            local function mk(ic: string, x: number): TextButton
                local b = button(r, "", M.title, C.text, C.surface)
                b.Size = UDim2.new(0, 24, 0, 22)
                b.AnchorPoint = Vector2.new(0, 0.5)
                b.Position = UDim2.new(1, x, 0.5, 0)
                corner(b, 5)
                stroke(b, C.edge, 0)
                recolourIcon(icon(b, ic, 16), C.dim)
                return b
            end
            local prev, nxt = mk("left", -52), mk("right", -24)
            local function refresh()
                local list = getList()
                if #list == 0 then
                    val.Text = "—"
                    return
                end
                cfg[idxKey] = ((tonumber(cfg[idxKey]) or 1) - 1) % #list + 1
                local pick = list[cfg[idxKey]]
                val.Text = if pick ~= nil then pick else "—"
                onChange(pick or "")
            end
            prev.MouseButton1Click:Connect(function()
                cfg[idxKey] = (tonumber(cfg[idxKey]) or 1) - 1
                refresh()
                saveConfig()
            end)
            nxt.MouseButton1Click:Connect(function()
                cfg[idxKey] = (tonumber(cfg[idxKey]) or 1) + 1
                refresh()
                saveConfig()
            end)
            refresh()
            return refresh
        end


        function g.multiselect(_, text: string, key: string, options: { string }, mopts: any?)
            mopts = mopts or {}
            mopts.cfgKey = key
            UI.count("multiselect")
            local r = row(IS_LION and M.rowCycle or M.row, text, mopts)
            local multiLabel = rowLabel(r, text, mopts, M.ctrlW)
            if IS_LION then multiLabel.Size = UDim2.new(1,0,0,16) end
            if type(cfg[key]) ~= "table" then
                cfg[key] = {}
            end
            local b = button(r, "", M.value, C.text, C.surface)
            b.Name = "Multiselect"
            b.Size = UDim2.new(0, M.ctrlW, 0, 22)
            b.AnchorPoint = Vector2.new(1, 0.5)
            b.Position = UDim2.new(1, 0, 0.5, 0)
            if IS_LION then
                b.Size = UDim2.new(1,0,0,22)
                b.AnchorPoint = Vector2.zero
                b.Position = UDim2.fromOffset(0,18)
            end
            corner(b, 5)
            local bs = stroke(b, C.edge, 0)
            local val = label(b, "", M.value, C.text, UI.F.body)
            val.Size = UDim2.new(1, -30, 1, 0)
            val.Position = UDim2.fromOffset(9, 0)
            val.TextTruncate = Enum.TextTruncate.AtEnd
            local chev = icon(b, "expand", 16)
            chev.AnchorPoint = Vector2.new(1, 0.5)
            chev.Position = UDim2.new(1, -4, 0.5, 0)
            recolourIcon(chev, C.muted)
            local function summary(): string
                local on = {}
                for _, opt in ipairs(options) do
                    if cfg[key][opt] == true then
                        table.insert(on, opt)
                    end
                end
                if #on == 0 then
                    return tostring(mopts.placeholder or "None")
                elseif #on == #options then
                    return "All"
                end
                return table.concat(on, ", ")
            end
            local function refresh()
                val.Text = summary()
            end
            refresh()

            table.insert(UI.sync, function()
                if val.Text ~= summary() then
                    refresh()
                end
            end)
            b.MouseEnter:Connect(function()
                b.BackgroundColor3 = C.card
            end)
            b.MouseLeave:Connect(function()
                b.BackgroundColor3 = C.surface
            end)
            b.MouseButton1Click:Connect(function()
                bs.Color = C.accent
                UI.openDropdown(b, IS_LION and math.max(M.ctrlW,b.AbsoluteSize.X) or M.ctrlW, function(f: Frame): number
                    local optBtns = {}
                    local function paint()
                        for opt, ob in pairs(optBtns) do
                            local on = cfg[key][opt] == true
                            ob:SetAttribute("selected", on)
                            local ic = ob:FindFirstChild("Icon")
                            if ic then ic.Visible = on end
                            local lb = ob:FindFirstChildOfClass("TextLabel")
                            if lb and lb.Name ~= "Icon" then lb.TextColor3 = if on then C.accent else C.dim end
                        end
                    end
                    local shown = #options > 8 and 7 or #options
                    local function toggleOption(opt)
                        cfg[key][opt] = if cfg[key][opt] then nil else true
                        if mopts.onChange then mopts.onChange(cfg[key]) end
                        saveConfig()
                        refresh()
                    end
                    for i = 1, shown do
                        local opt = options[i]
                        optBtns[opt] = UI.dropdownOption(f, 4 + (i - 1) * 24, opt, cfg[key][opt] == true, function()
                            toggleOption(opt)
                            paint()
                        end)
                    end
                    if #options > shown then
                        UI.dropdownOption(f, 4 + shown * 24, "Full options…", false, function()
                            UI.openOptionsModal(text, options, function(opt)
                                return cfg[key][opt] == true
                            end, function(opt)
                                toggleOption(opt)
                            end, true)
                        end)
                        return 8 + (shown + 1) * 24
                    end
                    return 8 + shown * 24
                end, function()
                    bs.Color = C.edge
                end)
            end)
            return r
        end

        function g.custom(_, hgt: number, text: string?, copts: any?): Frame
            return row(hgt, text or "", copts)
        end


        function g.textbox(_, text: string, key: string, topts: any?)
            topts = topts or {}
            topts.cfgKey = key
            UI.count("textbox")
            local r = row(M.row, text, topts)
            rowLabel(r, text, topts, 150)
            local box = Instance.new("TextBox")
            box.Name = "Field"
            box.Size = UDim2.new(0, 140, 0, 22)
            box.AnchorPoint = Vector2.new(1, 0.5)
            box.Position = UDim2.new(1, 0, 0.5, 0)
            box.BackgroundColor3 = C.surface
            box.BorderSizePixel = 0
            box.ClearTextOnFocus = false
            box.FontFace = UI.F.medium
            box.TextSize = M.value
            box.TextColor3 = C.text
            box.PlaceholderColor3 = C.muted
            box.PlaceholderText = topts.placeholder or ""
            box.TextXAlignment = Enum.TextXAlignment.Left
            box.TextTruncate = Enum.TextTruncate.AtEnd
            box.Text = tostring(cfg[key] or "")
            box.Parent = r
            corner(box, 5)
            stroke(box, C.edge, 0)
            padding(box, 0, 8, 0, 8)
            local maxLen = topts.maxLen or 24
            box:GetPropertyChangedSignal("Text"):Connect(function()
                if utf8.len(box.Text) and utf8.len(box.Text) > maxLen then
                    box.Text = box.Text:sub(1, utf8.offset(box.Text, maxLen + 1) - 1)
                end
            end)
            box.FocusLost:Connect(function()
                local v = box.Text:gsub("^%s+", ""):gsub("%s+$", "")
                cfg[key] = v
                box.Text = v
                if topts.onChange then
                    topts.onChange(v)
                end
            end)
            table.insert(UI.sync, function()
                if not box:IsFocused() and box.Text ~= tostring(cfg[key] or "") then
                    box.Text = tostring(cfg[key] or "")
                end
            end)
            return box
        end

        function g.field(_, text: string, placeholder: string?, initial: string?, fopts: any?): TextBox
            fopts = fopts or {}
            UI.count("field")
            local r = row(M.row, text, fopts)
            rowLabel(r, text, fopts, 150)
            local box = Instance.new("TextBox")
            box.Name = "Field"
            box.Size = UDim2.new(0, 150, 0, 24)
            box.AnchorPoint = Vector2.new(1, 0.5)
            box.Position = UDim2.new(1, 0, 0.5, 0)
            box.BackgroundColor3 = C.surface
            box.BorderSizePixel = 0
            box.ClearTextOnFocus = false
            box.FontFace = UI.F.medium
            box.TextSize = M.value
            box.TextColor3 = C.text
            box.PlaceholderColor3 = C.muted
            box.PlaceholderText = placeholder or ""
            box.TextXAlignment = Enum.TextXAlignment.Left
            box.TextTruncate = Enum.TextTruncate.AtEnd
            box.Text = initial or ""
            box.Parent = r
            corner(box, 5)
            local st = stroke(box, C.edge, 0)
            padding(box, 0, 8, 0, 8)
            box.Focused:Connect(function()
                tween(st, TW_HOVER, { Color = if UI.metal then UI.metal.lite else C.accent })
            end)
            box.FocusLost:Connect(function()
                tween(st, TW_HOVER, { Color = C.edge })
            end)
            return box
        end


        function g.info(_, text: string, getter: () -> any, iopts: any?): TextLabel
            iopts = iopts or {}
            UI.count("info")
            local r = row(M.row, text, iopts)
            local l = label(r, string.lower(text), M.title, C.dim, UI.F.body)
            l.Size = UDim2.new(0.45, 0, 1, 0)
            l.TextTruncate = Enum.TextTruncate.AtEnd
            local v = label(r, "", M.value, C.text, UI.F.medium)
            v.Size = UDim2.new(0.55, 0, 1, 0)
            v.Position = UDim2.new(0.45, 0, 0, 0)
            v.TextXAlignment = Enum.TextXAlignment.Right
            v.TextTruncate = Enum.TextTruncate.AtEnd
            local function refresh()
                local ok, s = pcall(getter)
                local txt = if ok and s ~= nil then tostring(s) else "—"
                if v.Text ~= txt then
                    v.Text = txt
                end
            end
            refresh()
            UI.syncLazy(function()
                if r.Visible then
                    refresh()
                end
            end)
            return v
        end


        function g.stat(_, text: string, sopts: any?): TextLabel
            UI.count("info")
            local r = row(M.row, text, sopts or {})
            local l = label(r, string.lower(text), M.title, C.dim, UI.F.body)
            l.Size = UDim2.new(0.34, 0, 1, 0)
            l.TextTruncate = Enum.TextTruncate.AtEnd
            local v = label(r, "—", M.value, C.text, UI.F.medium)
            v.Size = UDim2.new(0.66, -8, 1, 0)
            v.Position = UDim2.new(0.34, 8, 0, 0)
            v.TextXAlignment = Enum.TextXAlignment.Right
            v.TextTruncate = Enum.TextTruncate.AtEnd
            return v
        end

        function g.logBlock(_, text: string, n: number): { TextLabel }
            local lineH = math.max(16, UI.TEXT_MIN + 5)
            local r = row(n * lineH + 18, text, {})
            local card = frame(r, C.surface)
            card.Size = UDim2.new(1, 0, 1, -6)
            card.Position = UDim2.fromOffset(0, 3)
            corner(card, 8)
            stroke(card, C.edge, 0)
            padding(card, 6, 10, 6, 10)
            vlist(card, 0)
            local out = {}
            for i = 1, n do
                local t = label(card, "", UI.TEXT_MIN, C.dim, UI.F.code)
                t.Size = UDim2.new(1, 0, 0, lineH)
                t.TextTruncate = Enum.TextTruncate.AtEnd
                t.LayoutOrder = i
                out[i] = t
            end
            return out
        end


        function g.buttonRow(_, text: string, items: { any }, bopts: any?): { TextButton }
            bopts = bopts or {}
            UI.count("button")
            local r = row(M.rowButton, text, bopts)
            local out = {}
            local n = #items
            for i, it in ipairs(items) do
                local tint = it[3]
                local soft = tint ~= nil and tint ~= C.accent
                local b = button(r, string.lower(tostring(it[1])), M.value, if tint then tint else C.dim, if tint and not soft then tint else C.surface)
                b.Size = UDim2.new(1 / n, if i < n then -6 else 0, 0, 26)
                b.AnchorPoint = Vector2.new(0, 0.5)
                b.Position = UDim2.new((i - 1) / n, if i > 1 then (i - 1) * 6 / n else 0, 0.5, 0)
                b.BackgroundTransparency = if tint and not soft then 0.87 else 0
                b.TextTruncate = Enum.TextTruncate.AtEnd
                corner(b, 6)
                local st = stroke(b, if tint and not soft then tint else C.edge, if tint and not soft then 0.6 else 0)
                if soft then
                    UI.softKey(b, tint, st)
                end

                local keyed = tint == C.accent and UI.brushed(b)
                if keyed then
                    b.BackgroundTransparency = 0
                    b.BackgroundColor3 = Color3.fromRGB(228, 228, 232)
                    b.TextColor3 = UI.metal.ink
                    UI.setFont(b, UI.F.bold)
                end
                b.MouseEnter:Connect(function()
                    if soft then
                        return
                    elseif keyed then
                        b.BackgroundColor3 = Color3.new(1, 1, 1)
                    elseif tint then
                        b.BackgroundTransparency = 0.8
                    else
                        b.BackgroundColor3 = C.card
                        b.TextColor3 = C.text
                    end
                end)
                b.MouseLeave:Connect(function()
                    if soft then
                        return
                    elseif keyed then
                        b.BackgroundColor3 = Color3.fromRGB(228, 228, 232)
                    elseif tint then
                        b.BackgroundTransparency = 0.87
                    else
                        b.BackgroundColor3 = C.surface
                        b.TextColor3 = C.dim
                    end
                end)
                b.MouseButton1Click:Connect(function()
                    local ok, err = pcall(it[2])
                    if not ok then
                        reportError("button " .. tostring(it[1]), err)
                    end
                end)
                out[i] = b
            end
            return out
        end




        function g.list(_, text: string, lopts: any)
            lopts = lopts or {}
            lopts.isList = true
            UI.count("list")


            local RH = math.max(M.listRow, 44)
            local page, pageCount = 1, 1
            local pageSize = math.clamp(tonumber(lopts.pageSize) or 40, 1, 100)
            local hdr = if lopts.search ~= false then 52 else 24
            local wanted = math.ceil((lopts.height or 200) * 1.15)
            local rowsFit = math.max(3, math.floor((wanted - hdr - 8) / RH))
            local height = hdr + rowsFit * RH + 34
            local r = row(height, text, lopts)
            local l = label(r, string.lower(text), M.title, C.text, UI.F.body)
            l.Size = UDim2.new(1, -110, 0, 22)
            local countLbl = label(r, "", M.small, C.muted, UI.F.medium)
            countLbl.Size = UDim2.new(0, 100, 0, 22)
            countLbl.Position = UDim2.new(1, -100, 0, 0)
            countLbl.TextXAlignment = Enum.TextXAlignment.Right
            local top = 24
            local query = ""
            local refresh: any
            local searchToken = 0
            if lopts.search ~= false then
                local box = Instance.new("TextBox")
                box.Size = UDim2.new(1, 0, 0, 24)
                box.Position = UDim2.new(0, 0, 0, 24)
                box.BackgroundColor3 = C.surface
                box.BorderSizePixel = 0
                UI.setFont(box, UI.F.body)
                box.TextSize = M.value
                box.TextColor3 = C.text
                box.PlaceholderText = lopts.placeholder or "Search"
                box.PlaceholderColor3 = C.muted
                box.Text = ""
                box.ClearTextOnFocus = false
                box.TextXAlignment = Enum.TextXAlignment.Left
                box.Parent = r
                corner(box, 6)
                local bs = stroke(box, C.edge, 0)
                padding(box, 0, 8, 0, UI.HideSearchIcons and 8 or 26)
                if not UI.HideSearchIcons then
                    local sic = icon(box, "search", 14)
                    sic.AnchorPoint = Vector2.new(0, 0.5)
                    sic.Position = UDim2.new(0, -19, 0.5, 0)
                    recolourIcon(sic, C.muted)
                end
                box.Focused:Connect(function()
                    tween(bs, TW_HOVER, { Color = C.accent })
                end)
                box.FocusLost:Connect(function()
                    tween(bs, TW_HOVER, { Color = C.edge })
                end)
                box:GetPropertyChangedSignal("Text"):Connect(function()
                    query = string.lower(box.Text)
                    page = 1
                    searchToken += 1
                    local token = searchToken
                    task.delay(0.08, function()
                        if token == searchToken and r.Parent and refresh then refresh() end
                    end)
                end)
                top = 52
            end
            local sc = Instance.new("ScrollingFrame")
            sc.Size = UDim2.new(1, 0, 1, -top - 26)
            sc.Position = UDim2.new(0, 0, 0, top)
            sc.BackgroundColor3 = C.side
            sc.BackgroundTransparency = 0
            sc.BorderSizePixel = 0
            sc.ScrollBarThickness = 4
            sc.ScrollBarImageColor3 = C.faint
            sc.ScrollBarImageTransparency = 0
            sc.AutomaticCanvasSize = Enum.AutomaticSize.Y
            sc.CanvasSize = UDim2.new(0, 0, 0, 0)
            sc.ScrollingDirection = Enum.ScrollingDirection.Y
            sc.Parent = r
            corner(sc, 6)
            stroke(sc, C.edge, 0)
            vlist(sc, 2)
            padding(sc, 4, 6, 4, 4)
            local previous = button(r, "‹", M.value, C.text, C.surface)
            previous.Size = UDim2.fromOffset(28, 22)
            previous.Position = UDim2.new(0, 0, 1, -22)
            corner(previous, 5)
            local nextPage = button(r, "›", M.value, C.text, C.surface)
            nextPage.Size = UDim2.fromOffset(28, 22)
            nextPage.Position = UDim2.new(1, -28, 1, -22)
            corner(nextPage, 5)
            local pageLabel = label(r, "", M.small, C.muted, UI.F.medium)
            pageLabel.Size = UDim2.new(1, -64, 0, 22)
            pageLabel.Position = UDim2.new(0, 32, 1, -22)
            pageLabel.TextXAlignment = Enum.TextXAlignment.Center
            previous.MouseButton1Click:Connect(function()
                if page > 1 then page -= 1; sc.CanvasPosition = Vector2.zero; refresh() end
            end)
            nextPage.MouseButton1Click:Connect(function()
                if page < pageCount then page += 1; sc.CanvasPosition = Vector2.zero; refresh() end
            end)
            local pool: { any } = {}
            local rowId: { [Instance]: string } = {}
            local lastSel: any = nil
            local function mkRow(): any
                local b = button(sc, "", M.value, C.dim, C.accent)
                b.BackgroundTransparency = 1
                b.Size = UDim2.new(1, 0, 0, RH - 2)
                b.TextXAlignment = Enum.TextXAlignment.Left
                b.TextTruncate = Enum.TextTruncate.AtEnd
                UI.setFont(b, UI.F.body)
                corner(b, 5)
                padding(b, 0, 8, 0, 8)
                local st = stroke(b, C.accent, 1)
                local itemImage = Instance.new("ImageLabel")
                itemImage.Name = "ItemImage"
                itemImage.Size = UDim2.fromOffset(36, 36)
                itemImage.Position = UDim2.fromOffset(4, 3)
                itemImage.BackgroundTransparency = 1
                itemImage.ScaleType = Enum.ScaleType.Fit
                itemImage.Image = ""
                itemImage.Visible = false
                itemImage.Parent = b
                local nameLabel = label(b, "", M.value, C.dim, UI.F.body)
                nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
                local sub = label(b, "", M.small, C.muted, UI.F.medium)
                sub.Size = UDim2.new(0, 120, 1, 0)
                sub.Position = UDim2.new(1, -120, 0, 0)
                sub.TextXAlignment = Enum.TextXAlignment.Right
                local rec = { btn = b, name = nameLabel, sub = sub, image = itemImage, stroke = st, selected = false }
                b.MouseEnter:Connect(function()
                    if not rec.selected then
                        tween(b, TW_HOVER, { BackgroundTransparency = 0.88 })
                    end
                end)
                b.MouseLeave:Connect(function()
                    if not rec.selected then
                        tween(b, TW_HOVER, { BackgroundTransparency = 1 })
                    end
                end)
                b.MouseButton1Click:Connect(function()
                    local id = rowId[b]
                    if id ~= nil and lopts.onSelect then
                        local value: any = id
                        if lopts.multi then
                            value = table.clone(lopts.selected and lopts.selected() or {})
                            value[id] = if value[id] then nil else true
                        end
                        local ok, err = pcall(lopts.onSelect, value)
                        if not ok then
                            reportError("list " .. text, err)
                        end
                        refresh()
                    end
                end)
                return rec
            end
            local scrolledFor: any = nil
            refresh = function()
                local items = lopts.items and lopts.items() or {}
                local sel = lopts.selected and lopts.selected() or nil
                local matches, selectedIndex = {}, nil
                for _, value in ipairs(items) do
                    local it = type(value) == "table" and value or {id = value, label = value}
                    local lab = tostring(it.label or it.id)
                    if query == "" or string.find(string.lower(lab), query, 1, true) or (it.sub and string.find(string.lower(tostring(it.sub)), query, 1, true)) then
                        table.insert(matches, it)
                            if not lopts.multi and it.id == sel then selectedIndex = #matches end
                    end
                end
                pageCount = math.max(1, math.ceil(#matches / pageSize))
                if sel ~= lastSel and selectedIndex then page = math.ceil(selectedIndex / pageSize) end
                page = math.clamp(page, 1, pageCount)
                lastSel = sel
                local shown = 0
                local selIdx: number? = nil
                for i = (page - 1) * pageSize + 1, math.min(#matches, page * pageSize) do
                    local it = matches[i]
                    local lab = tostring(it.label or it.id)
                        shown += 1
                        local rec = pool[shown]
                        if not rec then
                            rec = mkRow()
                            pool[shown] = rec
                        end
                        local b = rec.btn
                        rowId[b] = it.id
                        b.Visible = true
                        b.LayoutOrder = shown
                        local imageId = tostring(it.image or "")
                        rec.image.Image = imageId
                        rec.image.Visible = imageId ~= ""
                        local offset = imageId ~= "" and 44 or 0
                        rec.name.Text = lab
                        rec.name.Position = UDim2.fromOffset(offset, 0)
                        rec.name.Size = UDim2.new(it.sub and 0.7 or 1, -offset, 1, 0)
                        rec.sub.Text = tostring(it.sub or "")
                        rec.sub.Size = UDim2.new(0.3, 0, 1, 0)
                        rec.sub.Position = UDim2.fromScale(0.7, 0)
                        rec.sub.TextColor3 = it.color or C.muted
                            rec.selected = if lopts.multi then type(sel) == "table" and sel[it.id] == true else it.id == sel
                        if rec.selected then
                            selIdx = shown
                        end
                        rec.name.TextColor3 = if rec.selected then C.text elseif it.dim then C.muted else C.dim
                        b.BackgroundColor3 = C.accent
                        b.BackgroundTransparency = if rec.selected then 0.82 else 1
                        rec.stroke.Transparency = if rec.selected then 0.35 else 1
                end
                for i = shown + 1, #pool do
                    pool[i].btn.Visible = false
                end
                countLbl.Text = tostring(#matches) .. " items"
                pageLabel.Text = ("Page %d / %d"):format(page, pageCount)
                previous.Active = page > 1
                nextPage.Active = page < pageCount

                if not lopts.multi and selIdx and sel ~= scrolledFor then
                    scrolledFor = sel
                    local visible = math.max(sc.AbsoluteWindowSize.Y, RH)
                    local y = math.max(0, (selIdx - 1) * RH - visible / 2 + RH / 2)
                    task.defer(function()
                        if sc.Parent then
                            sc.CanvasPosition = Vector2.new(0, y)
                        end
                    end)
                end
            end
            refresh()
            table.insert(UI.sync, function()
                local sel = lopts.selected and lopts.selected() or nil
                if sel ~= lastSel then
                    refresh()
                end
            end)
            return refresh
        end

        function g.multilist(_, text: string, params: any)
            local options = table.clone(params)
            local cachedItems, cachedVersion
            options.multi = true
            options.items = function()
                local version = params.version and params.version()
                if not cachedItems or version == nil or version ~= cachedVersion then
                    cachedItems = params.items()
                    cachedVersion = version
                end
                return cachedItems
            end
            return g:list(text, options)
        end

        function g:AddLabel(text)
            local object = {Native = self:note(tostring(text))}
            function object:SetText(value) self.Native.Text = tostring(value) end
            return object
        end

        return g
    end




    local Menu: any = { pages = {}, tabBtns = {}, subs = {}, activeTab = "", chips = {}, syncMarks = {} }
    S.menu = Menu


    local MENU_W, MENU_H, RAIL_W, HEADER_H, SUBBAR_H, PREVIEW_W = 820, 570, 184, 50, 28, 236
    if IS_LION then MENU_W, MENU_H, RAIL_W, HEADER_H, SUBBAR_H = 660, 640, 64, 64, 24 end
    local PANEL_GAP = 14
    local menuAnimToken = 0

    local TAB_ORDER = {"main", "rage", "melee", "world", "esp", "visuals", "skins", "customcosmetics", "inventoryspoofer", "character", "misc", "spoofers", "servers", "settings"}

    function S.ext.addTab(id: string, label: string, section: string, icon: string, build: any)
        if not table.find(TAB_ORDER, id) then
            table.insert(TAB_ORDER, (table.find(TAB_ORDER, "Config") or #TAB_ORDER + 1), id)
        end
        Menu.TAB_LABEL[id], Menu.TAB_SECTION[id] = label, section
        UI.ICONS[id] = icon
        for i, t in ipairs(S.ext.tabs) do
            if t.id == id then
                table.remove(S.ext.tabs, i)
                break
            end
        end
        table.insert(S.ext.tabs, { id = id, build = build })
    end

    function S.ext.addSub(tab: string, sub: string)
        local list = S.ext.subs[tab]
        if not list then
            list = {}
            S.ext.subs[tab] = list
        end
        if not table.find(list, sub) then
            table.insert(list, sub)
        end
    end



    function S.ext.addSection(id: string, tab: string, sub: string, side: string, build: any)
        for i, s in ipairs(S.ext.sections) do
            if s.id == id then
                table.remove(S.ext.sections, i)
                break
            end
        end
        table.insert(S.ext.sections, { id = id, tab = tab, sub = sub, side = side, build = build })
    end
    Menu.TAB_LABEL = {
        Aimbot = "Aimbot", Trigger = "Triggerbot", Silent = "Silent aim", Rage = "Ragebot", Visuals = "Players",
        World = "World", Skins = "Skins", Misc = "Misc", Interface = "Interface", Config = "Config", Debug = "Debug",
    }
    Menu.TAB_SECTION = {
        Aimbot = "Combat", Trigger = "Combat", Silent = "Combat", Rage = "Combat",
        Visuals = "Visuals", World = "Visuals", Skins = "Visuals",
        Misc = "Other", Interface = "Other", Config = "Other", Debug = "Other",
    }



    function Menu.debugAllowed(): boolean
        local lic = genv().CocaineLicense
        return type(lic) ~= "table" or lic.debugMenu == true
    end


    Menu.s = 1
    function Menu.px(n: number): number
        return math.floor(n * Menu.s + 0.5)
    end
    Menu.M_BASE = nil
    function Menu.layout()
        local vs = if Menu.gui then Menu.gui.AbsoluteSize else Vector2.new(1920, 1080)
        if vs.X < 200 or vs.Y < 200 then
            local cam = workspace.CurrentCamera
            vs = if cam then cam.ViewportSize else Vector2.new(1920, 1080)
        end

        local want = tonumber(cfg.menuScale) or 1
        local baseW, baseH = IS_LION and 660 or 820, IS_LION and 640 or 570
        local baseRail, baseHeader, baseSubbar = IS_LION and 64 or 184, IS_LION and 64 or 50, IS_LION and 24 or 32
        local s = 0.9
        for _, step in ipairs({ 1.25, 1.1, 1, 0.9 }) do
            if step <= want + 1e-6 and (baseW + 250) * step <= vs.X - 24 and baseH * step <= vs.Y - 24 then
                s = step
                break
            end
        end
        Menu.s = s
        MENU_W, MENU_H = Menu.px(baseW), Menu.px(baseH)
        MENU_W -= MENU_W % 2
        MENU_H -= MENU_H % 2
        RAIL_W, HEADER_H, SUBBAR_H, PREVIEW_W, PANEL_GAP = Menu.px(baseRail), Menu.px(baseHeader), Menu.px(baseSubbar), Menu.px(236), Menu.px(14)

        Menu.M_BASE = Menu.M_BASE or table.clone(UI.M)
        for k, v in pairs(Menu.M_BASE) do
            if type(v) == "number" and k ~= "descLine" then
                UI.M[k] = if UI.TEXT_KEYS[k] then math.max(UI.TEXT_MIN, Menu.px(v)) else Menu.px(v)
            end
        end
    end

    Menu.SIDE_PANEL = { Aimbot = "hitbox", Silent = "hitbox", Rage = "hitbox", Visuals = "preview" }

    function Menu.blur(open: boolean)
        local blur = Lighting:FindFirstChild("PlexNativeBlur") :: BlurEffect?
        if not cfg.menuBlur or cfg.lowSpec then
            if blur then
                blur.Enabled = false
            end
            return
        end
        if not blur then
            blur = Instance.new("BlurEffect")
            blur.Name = "PlexNativeBlur"
            blur.Size = 0
            blur.Parent = Lighting
        end
        blur.Enabled = true
        local t = tween(blur, TW_OPEN, { Size = if open then cfg.menuBlurSize else 0 })
        if not open then
            t.Completed:Connect(function()
                if not S.menuOpen and blur then
                    blur.Enabled = false
                end
            end)
        end
    end


    local HUD_setEdit: any = nil
    function Menu.setHudEditHook(fn: any)
        HUD_setEdit = fn
    end



    function Menu.slide(obj: GuiObject, base: UDim2, dy: number, dur: number, fade: GuiObject?, closing: boolean?, done: (() -> ())?)
        local info = TweenInfo.new(dur, Enum.EasingStyle.Quart, if closing then Enum.EasingDirection.In else Enum.EasingDirection.Out)
        obj.Position = if closing then base else base + UDim2.fromOffset(0, dy)
        local t: Tween
        if fade then
            fade.BackgroundTransparency = if closing then 1 else 0
            t = TweenService:Create(fade, info, { BackgroundTransparency = if closing then 0 else 1 })
            if dy ~= 0 then
                tween(obj, info, { Position = if closing then base + UDim2.fromOffset(0, dy) else base })
            end
        else
            t = TweenService:Create(obj, info, { Position = if closing then base + UDim2.fromOffset(0, dy) else base })
        end
        t.Completed:Connect(function(state: Enum.PlaybackState)
            if state ~= Enum.PlaybackState.Completed then
                return
            end
            if closing and obj.Parent then
                obj.Position = base
            end
            if done then
                done()
            end
        end)
        t:Play()
    end


    function Menu.loop(obj: Instance, info: TweenInfo, props: any): Tween
        local t = TweenService:Create(obj, info, props)
        table.insert(Menu.loops, t)
        if S.menuOpen then
            t:Play()
        end
        return t
    end
    function Menu.runLoops(on: boolean)
        for _, t in ipairs(Menu.loops or {}) do
            if on then
                t:Play()
            else
                t:Pause()
            end
        end
    end


    function Menu.applyGlass()
        local g = Menu.glassGrad
        if not g then
            return
        end

        local railA = if UI.metal then 0 else math.clamp((tonumber(cfg.railGlass) or 14) / 100, 0, 0.4)
        local r = math.clamp(Menu.glassSplit or 0.22, 0.01, 0.98)

        local railTint = if UI.metal then C.side:Lerp(UI.metal.mid, 0.1) else C.side:Lerp(C.accent2, 0.16)
        g.Rotation = 0
        g.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, railTint),
            ColorSequenceKeypoint.new(r - 0.002, railTint),
            ColorSequenceKeypoint.new(r, C.bg),
            ColorSequenceKeypoint.new(1, C.bg),
        })
        g.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, railA),
            NumberSequenceKeypoint.new(r - 0.002, railA),
            NumberSequenceKeypoint.new(r, 0),
            NumberSequenceKeypoint.new(1, 0),
        })
    end
    function Menu.ctrlDown(): boolean
        local down = false
        pcall(function()
            down = UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.RightControl)
        end)
        if not down then
            pcall(function()
                for _, pressed in ipairs(UIS:GetKeysPressed()) do
                    local code = pressed.KeyCode
                    if code == Enum.KeyCode.LeftControl or code == Enum.KeyCode.RightControl then
                        down = true
                    end
                end
            end)
        end
        if down then
            return true
        end

        local kd = Input.keyDown
        return type(kd) == "table" and (kd.LeftControl == true or kd.RightControl == true)
    end
    function Menu.pressed(kc: any): boolean
        if typeof(kc) ~= "EnumItem" then
            return false
        end
        if kc == Enum.KeyCode.O and Menu.ctrlDown() then
            return true
        end
        local mk = cfg.menuKey
        return type(mk) == "string" and mk ~= "" and mk ~= "None" and kc.Name == mk
    end
    function Menu.panic(err: any)
        local msg = string.sub(tostring(err), 1, 90)
        log("ERROR", "menu:", msg)
        notify("menu failed: " .. msg, 8, "error")
    end
    function Menu.toggle()

        if Game.superseded() then
            return
        end
        local now = os.clock()
        if now - (Menu._toggleAt or 0) < 0.2 then
            return
        end
        Menu._toggleAt = now
        if not (Menu.gui and Menu.root and Menu.backdrop and Menu.host) then
            local okB, errB = pcall(Menu.rebuild)
            if not okB then
                Menu.panic(errB)
                return
            end
        end
        local ok, err = pcall(Menu.set, not S.menuOpen)
        if ok then
            return
        end
        if S.hookErr then
            S.hookErr("menu", err)
        end
        local ok2, err2 = pcall(Menu.rebuild)
        if not ok2 then
            Menu.panic(err2)
            return
        end
        pcall(Menu.set, true)
    end





    function UI.mouseTick()
        if not S.menuOpen or S.alive == false then
            return
        end
        if UIS.MouseBehavior ~= Enum.MouseBehavior.Default then
            UIS.MouseBehavior = Enum.MouseBehavior.Default
        end
        if not UI.PlexCustomCursorActive and not UIS.MouseIconEnabled then
            UIS.MouseIconEnabled = true
        end
    end


    function Menu.chatHide(hide: boolean)
        local okC, win = pcall(function()
            return game:GetService("TextChatService").ChatWindowConfiguration
        end)
        if not (okC and win) then
            return
        end
        if hide then
            if Menu.chatWas == nil then
                Menu.chatWas = win.Enabled
            end
            pcall(function()
                win.Enabled = false
            end)
        elseif Menu.chatWas ~= nil then
            local was = Menu.chatWas
            Menu.chatWas = nil
            if not win.Enabled then
                pcall(function()
                    win.Enabled = was
                end)
            end
        end
    end
    function Menu.set(open: boolean)
        if open and shared.ModernLoading then return end
        S.menuOpen = open
        S.aimHeld = false
        menuAnimToken += 1
        local token = menuAnimToken
        Menu.blur(open)
        Menu.chatHide(open)
        if Menu.mouseFree then
            Menu.mouseFree.Visible = open
        end
        if not (Menu.gui and Menu.root and Menu.backdrop and Menu.host) then
            return
        end
        local host, curtain = Menu.host, Menu.curtain


        Menu.hostBase = Menu.hostBase or host.Position
        local base = Menu.hostBase
        if open then
            if HUD_setEdit then
                HUD_setEdit(false)
            end
            Menu.gui.Enabled = true
            Menu.runLoops(true)
            Menu.backdrop.Visible = true
            Menu.backdrop.BackgroundTransparency = 1


            tween(Menu.backdrop, TW_OPEN, { BackgroundTransparency = 1 - math.clamp(cfg.menuDim or 0, 0, 90) / 100 })
            Menu.root.Visible = true
            host.Visible = true
            if curtain then
                curtain.Visible = true
                curtain.BackgroundTransparency = 0
            end
            UI.mouseTick()

            Menu.measureSoon(false)
            task.defer(function()
                if token == menuAnimToken then
                    Menu.syncNow(Menu.activeTab)
                end
            end)


            Menu.slide(host, base, 0, TW_OPEN.Time, curtain, false, function()
                if token == menuAnimToken and curtain then
                    curtain.Visible = false
                end
                if token == menuAnimToken and S.menuOpen and Menu.clampToScreen then
                    Menu.clampToScreen()
                end
            end)
        else
            UI.closeBindPopup()
            UI.closeDropdown()


            if curtain then
                curtain.Visible = true
            end

            tween(Menu.backdrop, UI.TW.close, { BackgroundTransparency = 1 })
            Menu.slide(host, base, 0, UI.TW.close.Time, curtain, true, function()
                if token == menuAnimToken and not S.menuOpen then
                    if host and host.Parent then
                        host.Visible = false
                        host.Position = base
                    end
                    if Menu.backdrop and Menu.backdrop.Parent then
                        Menu.backdrop.Visible = false
                    end
                    if Menu.gui and Menu.gui.Parent then
                        Menu.gui.Enabled = false
                    end
                    Menu.runLoops(false)
                end
            end)
        end
    end
    S.setMenu = Menu.set






    Menu.revealTw = setmetatable({}, { __mode = "k" })
    function Menu.settle(obj: GuiObject, base: UDim2)
        local t = Menu.revealTw[obj]
        if t then
            t:Cancel()
            Menu.revealTw[obj] = nil
        end
        if obj.Position ~= base then
            obj.Position = base
        end
    end
    function Menu.reveal(obj: GuiObject, base: UDim2, _dx: number, _dy: number, cover: number)
        Menu.settle(obj, base)
        local sheet = Menu.pageCurtain
        if not sheet then
            return
        end
        Menu.revealToken = (Menu.revealToken or 0) + 1
        local token = Menu.revealToken
        sheet.Position = UDim2.fromOffset(0, cover)
        sheet.Size = UDim2.new(1, 0, 1, -cover)
        sheet.BackgroundTransparency = 0.12
        sheet.Visible = true
        tween(sheet, UI.TW.reveal, { BackgroundTransparency = 1 }).Completed:Connect(function(state: Enum.PlaybackState)
            if state == Enum.PlaybackState.Completed and token == Menu.revealToken then
                sheet.Visible = false
            end
        end)
    end
    function Menu.showTab(name: string)
        local was = Menu.activeTab
        Menu.activeTab = name
        UI.closeDropdown()
        local changed = was ~= name
        local animate = changed and was ~= "" and S.menuOpen == true
        local dir = 1
        if animate and (table.find(TAB_ORDER, name) or 0) < (table.find(TAB_ORDER, was) or 0) then
            dir = -1
        end
        for n, page in pairs(Menu.pages) do
            local show = n == name
            if show and animate then
                Menu.reveal(page, UDim2.new(), 0, dir * Menu.px(18), 0)
            elseif changed then
                Menu.settle(page, UDim2.new())
            end
            page.Visible = show
        end
        if Menu.layoutPane then
            Menu.layoutPane(name)
        end
        for n, d in pairs(Menu.tabBtns) do
            if d.paint and (not changed or n == name or n == was or not animate) then
                d.paint(n == name, animate)
            end
        end
        Menu.measureSoon(animate)
        if changed and Menu.syncNow then
            Menu.syncNow(name)
        end
    end



    function Menu.measureSoon(animate: boolean?)
        if Menu.measurePending then
            Menu.measureAnimate = Menu.measureAnimate or animate
            return
        end
        Menu.measurePending = true
        Menu.measureAnimate = animate
        local function run()
            Menu.measurePending = false
            local anim = Menu.measureAnimate
            Menu.measureAnimate = nil
            if Menu.placeNav then
                Menu.placeNav(anim)
            end
            Menu.placeSubThumb(Menu.activeTab, false)
        end
        local ok = pcall(function()
            RunService.Heartbeat:Once(run)
        end)
        if not ok then
            task.defer(run)
        end
    end
    function Menu.placeSubThumb(tab: string, animate: boolean?)
        local st = Menu.subs[tab]
        if not (st and st.liquid and st.track) then
            return
        end
        local b = st.btns and st.btns[st.active]
        local btn = b and b.btn
        if not (st.thumb and btn and btn.Visible) then
            if st.thumb then st.thumb.Visible = false end
            return
        end
        local w = btn.AbsoluteSize.X
        if w < 1 then
            return
        end
        st.thumb.Visible = true
        local x = btn.AbsolutePosition.X - st.track.AbsolutePosition.X
        st.liquid.to(x, x + w, animate and S.menuOpen == true)
    end
    function Menu.showSub(tab: string, sub: string)
        local st = Menu.subs[tab]
        if not st then
            return
        end
        UI.closeDropdown()
        local was = st.active
        st.active = sub
        local changed = was ~= sub
        if st.crumb then
            st.crumb.Text = string.lower((Menu.TAB_SECTION[tab] or "Other") .. " / " .. (Menu.TAB_LABEL[tab] or tab) .. " / " .. sub)
        end
        local animate = changed and st.built == true and S.menuOpen == true and Menu.activeTab == tab
        local dir = 1
        if animate and (table.find(st.order, sub) or 0) < (table.find(st.order, was) or 0) then
            dir = -1
        end
        for n, fr in pairs(st.frames) do
            local show = n == sub
            if show and animate then
                Menu.reveal(fr, st.base, dir * Menu.px(22), 0, st.top)
            elseif changed then
                Menu.settle(fr, st.base)
            end
            fr.Visible = show
        end
        for n, b in pairs(st.btns) do
            local on = n == sub
            local col = if on then (IS_LION and C.accent or C.bg) else C.muted
            if animate then
                tween(b.lbl, TW_HOVER, { TextColor3 = col })
            else
                b.lbl.TextColor3 = col
            end
            UI.setFont(b.lbl, if on then UI.F.semibold else UI.F.body)
            if b.glyph then UI.tintIcon(b.glyph,if on then (IS_LION and C.accent or C.bg) else C.muted,animate) end
        end
        if animate then

            local ok = pcall(function()
                RunService.Heartbeat:Once(function()
                    Menu.placeSubThumb(tab, true)
                end)
            end)
            if not ok then
                Menu.placeSubThumb(tab, true)
            end
        else
            Menu.placeSubThumb(tab, false)
        end
    end
    local function scrollColumns(sc: any, pack: any): (Instance?, Instance?)
        if pack then
            local L, R = pack.L, pack.R
            if typeof(L) == "Instance" and typeof(R) == "Instance" then
                return L, R
            end
        end
        if typeof(sc) == "Instance" then
            return sc:FindFirstChild("L"), sc:FindFirstChild("R")
        end
        return nil, nil
    end



    function Menu.hideEmptySubs()

        local live: { [Instance]: boolean } = {}
        for _, g in ipairs(UI.groups) do
            if g.frame.Visible then
                for _, r in ipairs(g.rows) do
                    if not r.isNote and r.frame.Visible then
                        live[g.frame] = true
                        break
                    end
                end
            end
        end
        local activeTabVisible = Menu.activeTab == nil
        for tab, st in pairs(Menu.subs or {}) do
            local firstVisible: string? = nil
            local firstOrder = math.huge
            local activeVisible = false
            local tabAny = false
            for sub, fr in pairs(st.frames) do
                local any, nGroups = false, 0
                local pack = st[sub]
                for _, colName in ipairs({ "L", "R" }) do
                    local col
                    if pack and typeof(pack[colName]) == "Instance" then
                        col = pack[colName]
                    elseif typeof(fr) == "Instance" then
                        col = fr:FindFirstChild(colName)
                    end
                    if col then
                        for _, ch in ipairs(col:GetChildren()) do
                            if ch:IsA("Frame") then
                                nGroups += 1
                                if live[ch] or (function() for _,nested in ipairs(ch:GetDescendants()) do if live[nested] then return true end end return false end)() then
                                    any = true
                                end
                            end
                        end
                    end
                end

                if nGroups == 0 then
                    any = true
                end
                tabAny = tabAny or any
                local b = st.btns[sub]
                local btn = b and b.lbl and b.lbl.Parent
                if btn and btn:IsA("GuiObject") then
                    btn.Visible = any
                    if any and btn.LayoutOrder < firstOrder then
                        firstOrder, firstVisible = btn.LayoutOrder, sub
                    end
                elseif any and firstVisible == nil then
                    firstVisible = sub
                end
                if any and sub == st.active then
                    activeVisible = true
                end
            end
            if not activeVisible and firstVisible then
                Menu.showSub(tab, firstVisible)
            end

            local tb = Menu.tabBtns and Menu.tabBtns[tab]
            if tb and tb.item then
                tb.item.Visible = tabAny
            end
            if tab == Menu.activeTab and tabAny and (tb ~= nil or tab ~= "Debug") then
                activeTabVisible = true
            end
        end

        for sec, cap in pairs(Menu.sectionCaps or {}) do
            local anyItem = false
            for tab, d in pairs(Menu.tabBtns or {}) do
                if Menu.TAB_SECTION[tab] == sec and d.item and d.item.Visible then
                    anyItem = true
                end
            end
            cap.Visible = anyItem
        end

        if not activeTabVisible and Menu.pages then
            for _, name in ipairs(TAB_ORDER) do
                local tb = Menu.tabBtns and Menu.tabBtns[name]
                if Menu.pages[name] and tb and tb.item and tb.item.Visible then
                    Menu.showTab(name)
                    break
                end
            end
        end
    end
    UI.afterRefilter = function()
        Menu.hideEmptySubs()


        if Menu.balanceColumns then
            Menu.balanceColumns()
        end

        task.defer(function()
            if Menu.placeNav then
                Menu.placeNav(false)
            end
        end)
    end


    function Menu.addTab(name: string, subs: { string }): any
        local extra = S.ext.subs[name]
        if extra and #extra > 0 then
            local merged = table.clone(subs)
            for _, s in ipairs(extra) do
                if not table.find(merged, s) then
                    table.insert(merged, s)
                end
            end
            subs = merged
        end
        table.insert(Menu.syncMarks, { at = #UI.sync + 1, tab = name })
        local content = Menu.content
        local page = frame(content)
        page.Name = "Page_" .. name
        page.Size = UDim2.new(1, 0, 1, 0)
        page.Visible = false
        Menu.pages[name] = page
        S.ui.tabs[name] = page
        S.ui.subTabs[name] = {}
        local multi = #subs > 1



        local bar = frame(page)
        bar.Name = "SubBar"
        bar.Size = UDim2.new(1, -36, 0, if multi then SUBBAR_H + 18 else 18)
        bar.Position = UDim2.new(0, 18, 0, 4)
        bar.Visible = true
        local track = frame(bar, C.surface)
        track.Name = "Track"
        track.AutomaticSize = Enum.AutomaticSize.X
        track.Size = UDim2.new(0, 0, 0, SUBBAR_H - 2)
        track.Visible = multi
        track.AnchorPoint = Vector2.new(0, 0.5)
        track.Position = UDim2.new(0, 0, 0, 18 + SUBBAR_H / 2)
        corner(track, 7)
        local trackOutline = stroke(track, C.edge, 0.2)
        if IS_LION then track.BackgroundTransparency = 1; trackOutline.Transparency = 1 end

        local thumb = frame(track, Color3.new(1, 1, 1))
        thumb.Name = "Thumb"
        thumb.BackgroundTransparency = 0
        thumb.BackgroundColor3 = Color3.new(1,1,1)
        local subGradient=Instance.new("UIGradient")
        subGradient.Rotation=90
        subGradient.Color=ColorSequence.new(C.accent:Lerp(Color3.new(1,1,1),0.5),C.accent)
        subGradient.Parent=thumb
        if IS_LION then subGradient.Color = ColorSequence.new(C.accent) end
        thumb.ZIndex = 2
        thumb.Visible = false
        corner(thumb, 5)
        stroke(thumb, Color3.new(1, 1, 1), 0.9)
        if UI.brushed(thumb) then
            thumb.BackgroundTransparency = 0
        end
        local list = frame(track)
        list.Name = "Segments"
        list.AutomaticSize = Enum.AutomaticSize.X
        list.Size = UDim2.new(0, 0, 1, 0)
        list.ZIndex = 3
        vlist(list, 2, true)
        padding(list, 2, 2, 2, 2)
        local st: any = { frames = {}, btns = {}, active = subs[1], order = subs, track = track, thumb = thumb }
        Menu.subs[name] = st

        local crumb = label(bar, "", UI.M.small, C.muted, UI.F.body)
        crumb.Name = "Crumb"
        crumb.AnchorPoint = Vector2.zero
        crumb.Position = UDim2.new(0, 0, 0, 0)
        crumb.Size = UDim2.new(1, 0, 0, 16)
        crumb.TextXAlignment = Enum.TextXAlignment.Left
        crumb.TextTruncate = Enum.TextTruncate.AtEnd
        st.crumb = crumb
        local function layoutCrumb()
            crumb.Size = UDim2.new(1, 0, 0, 16)
            crumb.Visible = true
        end
        UI.conn(bar:GetPropertyChangedSignal("AbsoluteSize"):Connect(layoutCrumb))
        st.liquid = UI.liquid(thumb, function(a: number, b: number)
            thumb.Position = IS_LION and UDim2.new(0,a,1,-2) or UDim2.new(0, a, 0, 3)
            thumb.Size = IS_LION and UDim2.new(0,math.max(4,b-a),0,2) or UDim2.new(0, math.max(4, b - a), 1, -6)
        end)
        UI.conn(list:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            Menu.placeSubThumb(name, false)
            layoutCrumb()
        end))
        local top = if multi then SUBBAR_H + 24 else 24
        st.top = top
        st.base = UDim2.new(0, 0, 0, top)
        for i, sub in ipairs(subs) do
            local b = button(list, "", UI.M.value, C.muted, C.surface)
            b.BackgroundTransparency = 1
            b.AutomaticSize = Enum.AutomaticSize.X
            b.Size = UDim2.new(0, 0, 1, 0)
            b.LayoutOrder = i
            b.ZIndex = 3

            local glyph=icon(b,UI.subtabIcon(sub),Menu.px(11))
            glyph.AnchorPoint=Vector2.new(0,0.5)
            glyph.Position=UDim2.new(0,Menu.px(8),0.5,0)
            glyph.ZIndex=3
            local lbl = label(b, string.lower(sub), UI.M.value, C.muted, UI.F.body)
            lbl.Size = UDim2.new(0, UI.gw(string.lower(sub),UI.M.value)+Menu.px(34), 1, 0)
            lbl.TextYAlignment = Enum.TextYAlignment.Center
            lbl.ZIndex = 3
            padding(lbl, 0, Menu.px(9), 0, Menu.px(24))
            st.btns[sub] = { lbl = lbl, btn = b, glyph=glyph }
            b.MouseEnter:Connect(function()
                if st.active ~= sub then
                    tween(lbl, TW_HOVER, { TextColor3 = C.dim })
                end
            end)
            b.MouseLeave:Connect(function()
                if st.active ~= sub then
                    tween(lbl, TW_HOVER, { TextColor3 = C.muted })
                end
            end)
            b.MouseButton1Click:Connect(function()
                Menu.showSub(name, sub)
            end)
            local scroll = Instance.new("ScrollingFrame")
            scroll.Name = "Sub_" .. sub
            scroll.Size = UDim2.new(1, 0, 1, -top)
            scroll.Position = UDim2.new(0, 0, 0, top)
            scroll.BackgroundTransparency = 1
            scroll.BorderSizePixel = 0
            scroll.ScrollBarThickness = 4
            scroll.ScrollBarImageColor3 = C.faint
            scroll.ScrollBarImageTransparency = 0.1
            scroll.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
            scroll.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
            scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
            scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
            scroll.Visible = i == 1
            scroll.Parent = page
            padding(scroll, 14, 18, 10, 18)

            scroll:GetPropertyChangedSignal("CanvasPosition"):Connect(UI.closeDropdown)




            local left = frame(scroll)
            left.Name = "L"
            left.Size = UDim2.new(0.5, -30, 0, 0)
            left.AutomaticSize = Enum.AutomaticSize.Y
            vlist(left, 0)
            local right = frame(scroll)
            right.Name = "R"
            right.Size = UDim2.new(0.5, -30, 0, 0)
            right.Position = UDim2.new(0.5, 12, 0, 0)
            right.AutomaticSize = Enum.AutomaticSize.Y
            vlist(right, 0)
            st.frames[sub] = scroll
            S.ui.subTabs[name][sub] = scroll
            scroll:SetAttribute("Sub", sub)
            st[sub] = { L = left, R = right, scroll = scroll }
        end
        Menu.showSub(name, subs[1])
        st.built = true
        return st
    end







    UI.avatarSlots = {}
    UI.avatarState = "idle"




    function UI.avatarAssemble(model: Model)
        local root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
        if not (root and root:IsA("BasePart")) then
            return
        end
        local placed = { [root] = true }
        local joints, parts = {}, {}
        for _, d in ipairs(model:GetDescendants()) do
            if d:IsA("JointInstance") and d.Part0 and d.Part1 then
                table.insert(joints, d)
            elseif d:IsA("BasePart") then
                table.insert(parts, d)
            end
        end
        for _ = 1, 12 do
            local moved = false
            for _ = 1, 32 do
                local step = false
                for _, j in ipairs(joints) do
                    local p0, p1 = j.Part0, j.Part1
                    if placed[p0] and not placed[p1] then
                        p1.CFrame = p0.CFrame * j.C0 * j.C1:Inverse()
                        placed[p1], step = true, true
                    elseif placed[p1] and not placed[p0] then
                        p0.CFrame = p1.CFrame * j.C1 * j.C0:Inverse()
                        placed[p0], step = true, true
                    end
                end
                moved = moved or step
                if not step then
                    break
                end
            end
            for _, part in ipairs(parts) do
                if not placed[part] then
                    for _, att in ipairs(part:GetChildren()) do
                        if att:IsA("Attachment") then
                            local mate: Attachment? = nil
                            for _, other in ipairs(parts) do
                                if placed[other] then
                                    local a = other:FindFirstChild(att.Name)
                                    if a and a:IsA("Attachment") then
                                        mate = a
                                        break
                                    end
                                end
                            end
                            if mate then
                                part.CFrame = mate.WorldCFrame * att.CFrame:Inverse()
                                placed[part], moved = true, true
                                break
                            end
                        end
                    end
                end
            end
            if not moved then
                break
            end
        end
    end

    function UI.avatarPrepare(model: Model)
        for _, d in ipairs(model:GetDescendants()) do
            if d:IsA("LuaSourceContainer") or d:IsA("ForceField") or d:IsA("Sound") then
                d:Destroy()
            elseif d:IsA("BasePart") then
                d.Anchored = true
                d.CanCollide = false
                d.CastShadow = false
            elseif d:IsA("Humanoid") then
                d.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
                d.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
            end
        end
        local root = model:FindFirstChild("HumanoidRootPart")
        if root and root:IsA("BasePart") then
            model.PrimaryPart = root
        end
        model:PivotTo(CFrame.new())
    end
    function UI.avatarLoad()
        if UI.avatarState ~= "idle" then
            return
        end
        UI.avatarState = "loading"
        task.spawn(function()
            local model: Model? = nil
            local ok, m = pcall(function()
                return Players:CreateHumanoidModelFromUserId(LP.UserId)
            end)
            if ok and typeof(m) == "Instance" and m:IsA("Model") then
                model = m
            else

                pcall(function()
                    local char = LP.Character
                    if char then
                        local was = char.Archivable
                        char.Archivable = true
                        model = char:Clone()
                        char.Archivable = was
                    end
                end)
            end
            if not model then
                UI.avatarState = "failed"
                log("DEBUG", "preview: no avatar model (" .. tostring(m) .. ")")
                return
            end
            pcall(UI.avatarAssemble, model)
            pcall(UI.avatarPrepare, model)
            UI.avatarModel = model
            UI.avatarState = "ready"
            for _, slot in ipairs(UI.avatarSlots) do
                pcall(UI.avatarFill, slot)
            end
        end)
    end


    function UI.avatarViewport(parent: GuiObject, x: number, y: number, w: number, h: number, z: number, opts: any?): any
        local vf = Instance.new("ViewportFrame")
        vf.Name = "Avatar"
        vf.BackgroundTransparency = 1
        vf.Position = UDim2.fromOffset(x, y)
        vf.Size = UDim2.fromOffset(w, h)
        vf.ZIndex = z
        vf.Ambient = Color3.fromRGB(170, 165, 185)
        vf.LightColor = Color3.fromRGB(255, 250, 245)
        vf.LightDirection = Vector3.new(-0.4, -1, -0.6)
        local world = Instance.new("WorldModel")
        world.Parent = vf
        local cam = Instance.new("Camera")
        cam.FieldOfView = 30
        cam.Parent = vf
        vf.CurrentCamera = cam
        vf.Parent = parent
        local slot = { vf = vf, world = world, cam = cam, w = w, h = h, model = nil, orig = {}, clothes = nil, tintSig = nil, onReady = nil, bodyOnly = opts and opts.bodyOnly == true, fill = opts and opts.fill or 0.9 }

        for i = #UI.avatarSlots, 1, -1 do
            if not UI.avatarSlots[i].vf.Parent then
                table.remove(UI.avatarSlots, i)
            end
        end
        table.insert(UI.avatarSlots, slot)
        if UI.avatarState == "ready" then
            pcall(UI.avatarFill, slot)
        else
            UI.avatarLoad()
        end
        return slot
    end
    function UI.avatarFill(slot: any)
        if slot.model or not slot.vf.Parent or not UI.avatarModel then
            return
        end
        local m = UI.avatarModel:Clone()
        if slot.bodyOnly then
            for _, d in ipairs(m:GetChildren()) do
                if d:IsA("Accoutrement") then
                    d:Destroy()
                end
            end
        end
        m.Parent = slot.world
        slot.model = m

        local lo, hi = Vector3.one * math.huge, Vector3.one * -math.huge
        for _, p in ipairs(UI.avatarBody(m)) do
            for _, c in ipairs(UI.CORNERS) do
                local wp = p.CFrame:PointToWorldSpace(p.Size * 0.5 * c)
                lo, hi = lo:Min(wp), hi:Max(wp)
            end
        end
        local center, size
        if lo.X == math.huge then
            local cf, sz = m:GetBoundingBox()
            center, size = cf.Position, sz
        else
            center, size = (lo + hi) * 0.5, hi - lo
        end
        local t = math.tan(math.rad(slot.cam.FieldOfView) * 0.5)
        local aspect = slot.w / math.max(slot.h, 1)
        local dist = math.max((size.Y * 0.5 / slot.fill) / t, (size.X * 0.5 / 0.96) / (t * aspect)) + size.Z * 0.5
        local root = m:FindFirstChild("HumanoidRootPart")
        local front = if root and root:IsA("BasePart") then root.CFrame.LookVector else m:GetPivot().LookVector
        slot.cam.CFrame = CFrame.lookAt(center + front * dist, center)
        slot.tintSig = nil
        if slot.onReady then
            slot.onReady(slot)
        end
    end
    UI.CORNERS = {
        Vector3.new(-1, -1, -1), Vector3.new(1, -1, -1), Vector3.new(-1, 1, -1), Vector3.new(1, 1, -1),
        Vector3.new(-1, -1, 1), Vector3.new(1, -1, 1), Vector3.new(-1, 1, 1), Vector3.new(1, 1, 1),
    }
    function UI.avatarBody(m: Model): { BasePart }
        local out = {}
        for _, d in ipairs(m:GetDescendants()) do
            if d:IsA("BasePart") and UI.HITBOX_OF[d.Name] and not d:FindFirstAncestorWhichIsA("Accoutrement") then
                table.insert(out, d)
            end
        end
        return out
    end

    function UI.avatarProject(slot: any, p: Vector3): Vector2?
        local q = slot.cam.CFrame:PointToObjectSpace(p)
        if q.Z > -0.05 then
            return nil
        end
        local t = math.tan(math.rad(slot.cam.FieldOfView) * 0.5)
        local aspect = slot.w / math.max(slot.h, 1)
        return Vector2.new((1 + q.X / (-q.Z * t * aspect)) * 0.5 * slot.w, (1 - q.Y / (-q.Z * t)) * 0.5 * slot.h)
    end

    function UI.avatarRect(slot: any): (number?, number?, number?, number?)
        if not slot.model then
            return nil, nil, nil, nil
        end
        local x0, y0, x1, y1 = math.huge, math.huge, -math.huge, -math.huge
        for _, p in ipairs(UI.avatarBody(slot.model)) do
            for _, c in ipairs(UI.CORNERS) do
                local s = UI.avatarProject(slot, p.CFrame:PointToWorldSpace(p.Size * 0.5 * c))
                if s then
                    x0, y0, x1, y1 = math.min(x0, s.X), math.min(y0, s.Y), math.max(x1, s.X), math.max(y1, s.Y)
                end
            end
        end
        if x0 == math.huge then
            return nil, nil, nil, nil
        end
        return x0, y0, x1 - x0, y1 - y0
    end


    function UI.avatarEspRect(slot: any): (number?, number?, number?, number?)
        local m = slot.model
        if not m then
            return nil, nil, nil, nil
        end
        local pps = (slot.h * 0.5) / math.tan(math.rad(slot.cam.FieldOfView) * 0.5)
        local x0, y0, x1, y1 = math.huge, math.huge, -math.huge, -math.huge
        for _, nm in ipairs(Vis.BOX_KEYS) do
            local p = m:FindFirstChild(nm)
            if p and p:IsA("BasePart") then
                local depth = -slot.cam.CFrame:PointToObjectSpace(p.Position).Z
                local s = UI.avatarProject(slot, p.Position)
                if s and depth > 0.05 then
                    local rad = p.Size.Magnitude * 0.5 * pps / depth
                    x0, y0, x1, y1 = math.min(x0, s.X - rad), math.min(y0, s.Y - rad), math.max(x1, s.X + rad), math.max(y1, s.Y + rad)
                end
            end
        end
        if x0 == math.huge then
            return UI.avatarRect(slot)
        end
        return x0, y0, x1 - x0, y1 - y0
    end

    UI.HITBOX_OF = {
        Head = "Head", UpperTorso = "Body", LowerTorso = "Body", Torso = "Body",
        LeftUpperArm = "Arms", LeftLowerArm = "Arms", LeftHand = "Arms", RightUpperArm = "Arms", RightLowerArm = "Arms", RightHand = "Arms", ["Left Arm"] = "Arms", ["Right Arm"] = "Arms",
        LeftUpperLeg = "Legs", LeftLowerLeg = "Legs", LeftFoot = "Legs", RightUpperLeg = "Legs", RightLowerLeg = "Legs", RightFoot = "Legs", ["Left Leg"] = "Legs", ["Right Leg"] = "Legs",
    }



    function UI.avatarTint(slot: any, sig: string, colorOf: (BasePart) -> (Color3?, number?))
        local m = slot.model
        if not m or slot.tintSig == sig then
            return
        end
        slot.tintSig = sig
        local orig = slot.orig
        local painted = false
        for _, d in ipairs(m:GetDescendants()) do
            if d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" and (if orig[d] then orig[d].tr else d.Transparency) < 0.99 then
                local c, a = colorOf(d)
                local o = orig[d]
                if c then
                    if not o then
                        o = { color = d.Color, mat = d.Material, tr = d.Transparency, tex = if d:IsA("MeshPart") then d.TextureID else nil }
                        orig[d] = o
                    end
                    d.Color, d.Material, d.Transparency = c, Enum.Material.SmoothPlastic, a or 0
                    if d:IsA("MeshPart") then
                        d.TextureID = ""
                    end
                    painted = true
                elseif o then
                    d.Color, d.Material, d.Transparency = o.color, o.mat, o.tr
                    if o.tex ~= nil and d:IsA("MeshPart") then
                        d.TextureID = o.tex
                    end
                    orig[d] = nil
                end
            elseif d:IsA("Decal") and d.Parent and d.Parent:IsA("BasePart") and d.Parent.Name == "Head" then
                if orig[d] == nil then
                    orig[d] = { tr = d.Transparency }
                end
                d.Transparency = if colorOf(d.Parent :: BasePart) then 1 else orig[d].tr
            end
        end
        if painted and not slot.clothes then
            slot.clothes = {}
            for _, d in ipairs(m:GetDescendants()) do
                if d:IsA("Clothing") or d:IsA("ShirtGraphic") or d:IsA("SurfaceAppearance") then
                    table.insert(slot.clothes, { d, d.Parent })
                end
            end
            for _, e in ipairs(slot.clothes) do
                pcall(function()
                    e[1].Parent = nil
                end)
            end
        elseif not painted and slot.clothes then
            for _, e in ipairs(slot.clothes) do
                if e[2] == m or (e[2] and e[2]:IsDescendantOf(m)) then
                    pcall(function()
                        e[1].Parent = e[2]
                    end)
                end
            end
            slot.clothes = nil
        end
    end
    function Menu.buildPreview(parent: GuiObject)
        local root = frame(parent)
        root.Name = "EspPreview"
        root.Size = UDim2.new(1, 0, 1, 0)
        root.ClipsDescendants = true



        local s = Menu.s or 1
        local VW, VH = math.floor(172 * s), math.floor(292 * s)
        local FX, FY = math.floor(30 * s), math.floor(28 * s)
        local scene = frame(root)
        scene.Size = UDim2.fromOffset(VW + FX * 2, FY + VH + math.floor(26 * s))
        scene.AnchorPoint = Vector2.new(0.5, 0.5)
        scene.Position = UDim2.fromScale(0.5, 0.5)
        local shadow = frame(scene, Color3.new(0, 0, 0))
        shadow.Size = UDim2.fromOffset(math.floor(VW * 0.62), math.max(6, math.floor(8 * s)))
        shadow.AnchorPoint = Vector2.new(0.5, 0.5)
        shadow.Position = UDim2.fromOffset(FX + math.floor(VW / 2), FY + VH)
        shadow.BackgroundTransparency = 0.55
        corner(shadow, 4)


        local BX, BY = FX + math.floor(VW * 0.14), FY + math.floor(VH * 0.04)
        local BW, BH = math.floor(VW * 0.72), math.floor(VH * 0.92)
        local headX, headY = FX + math.floor(VW / 2), FY + math.floor(VH * 0.13)

        local avatar = UI.avatarViewport(scene, FX, FY, VW, VH, 2, { fill = 0.8 })
        local function bar(z: number, color: Color3): Frame
            local f = frame(scene, color)
            f.ZIndex = z
            f.Visible = false
            return f
        end
        local fill = bar(3, Color3.new(1, 1, 1))
        local outlines: { Frame } = {}
        local lines: { Frame } = {}
        for i = 1, 8 do
            outlines[i] = bar(4, Color3.new(0, 0, 0))
            lines[i] = bar(5, Color3.new(1, 1, 1))
        end
        local hpOut, hpFill = bar(4, Color3.new(0, 0, 0)), bar(5, Color3.new(1, 1, 1))
        local headDot = bar(5, Color3.new(1, 1, 1))
        headDot.BackgroundTransparency = 1
        corner(headDot, 100)
        local headStroke = stroke(headDot, Color3.new(1, 1, 1), 0)
        local function txt(size: number, xAlign: Enum.TextXAlignment): TextLabel
            local t = label(scene, "", size, Color3.new(1, 1, 1), UI.F.semibold)
            t.ZIndex = 6
            t.TextXAlignment = xAlign
            t.TextStrokeTransparency = 0.15
            t.TextStrokeColor3 = Color3.new(0, 0, 0)
            return t
        end
        local nameT = txt(UI.TEXT_MIN + 1, Enum.TextXAlignment.Center)
        nameT.Text = UI.localUserName()
        local wpT = txt(UI.TEXT_MIN, Enum.TextXAlignment.Center)
        wpT.Text = "Sniper"
        local rkT = txt(UI.TEXT_MIN, Enum.TextXAlignment.Center)
        rkT.Text = "R 12"
        local amT = txt(UI.TEXT_MIN, Enum.TextXAlignment.Center)
        amT.Text = "18/60"
        local skT = txt(UI.TEXT_MIN, Enum.TextXAlignment.Center)
        skT.Text = "x3"
        local hpT = txt(UI.TEXT_MIN, Enum.TextXAlignment.Right)
        local flags: { TextLabel } = {}
        for i = 1, 3 do
            flags[i] = txt(UI.TEXT_MIN, Enum.TextXAlignment.Left)
        end

        local function seg(i: number, x: number, y: number, w: number, h: number, color: Color3, outline: boolean)
            local l, o = lines[i], outlines[i]
            l.Visible = true
            l.Position = UDim2.fromOffset(x, y)
            l.Size = UDim2.fromOffset(w, h)
            l.BackgroundColor3 = color
            o.Visible = outline
            o.Position = UDim2.fromOffset(x - 1, y - 1)
            o.Size = UDim2.fromOffset(w + 2, h + 2)
        end
        local function refresh()
            local on = cfg.esp == true
            local color = Vis.col("colEspVisible")
            local chams = on and cfg.espHighlight == true and not cfg.espChamsOccluded

            local fillC = Vis.col("colChamsFill")
            local fillA = math.clamp(cfg.espChamsFill, 0, 0.9) * 0.8
            UI.avatarTint(avatar, if chams then ("chams %s %.2f"):format(tostring(fillC), fillA) else "real", function(_p: BasePart)
                if chams then
                    return fillC, fillA
                end
                return nil, nil
            end)
            for i = 1, 8 do
                lines[i].Visible, outlines[i].Visible = false, false
            end
            local box = on and cfg.espBox == true
            local outline = cfg.espOutline ~= false
            fill.Visible = box and cfg.espBoxFill == true
            fill.Position, fill.Size = UDim2.fromOffset(BX, BY), UDim2.fromOffset(BW, BH)
            fill.BackgroundColor3 = color
            fill.BackgroundTransparency = cfg.espBoxFillAlpha
            if box and cfg.espBoxStyle == "Corner" then
                local L = math.floor(math.min(BW, BH) * 0.25)
                seg(1, BX, BY, L, 1, color, outline)
                seg(2, BX, BY, 1, L, color, outline)
                seg(3, BX + BW - L, BY, L, 1, color, outline)
                seg(4, BX + BW - 1, BY, 1, L, color, outline)
                seg(5, BX, BY + BH - 1, L, 1, color, outline)
                seg(6, BX, BY + BH - L, 1, L, color, outline)
                seg(7, BX + BW - L, BY + BH - 1, L, 1, color, outline)
                seg(8, BX + BW - 1, BY + BH - L, 1, L, color, outline)
            elseif box then
                seg(1, BX, BY, BW, 1, color, outline)
                seg(2, BX, BY + BH - 1, BW, 1, color, outline)
                seg(3, BX, BY, 1, BH, color, outline)
                seg(4, BX + BW - 1, BY, 1, BH, color, outline)
            end
            local hp = math.clamp((tonumber(cfg.previewHp) or 72) / 100, 0.01, 1)
            local showBar = on and cfg.espHealthBar == true
            hpOut.Visible, hpFill.Visible = showBar, showBar
            hpOut.Position, hpOut.Size = UDim2.fromOffset(BX - 7, BY - 1), UDim2.fromOffset(4, BH + 2)
            local fh = math.max(1, math.floor(BH * hp + 0.5))
            hpFill.Position, hpFill.Size = UDim2.fromOffset(BX - 6, BY + BH - fh), UDim2.fromOffset(2, fh)
            hpFill.BackgroundColor3 = Vis.hpColor(hp)
            local mode = cfg.espHpMode or "When damaged"
            hpT.Visible = showBar and (mode == "Always" or (mode == "When damaged" and hp < 1))
            hpT.Text = tostring(math.floor(hp * 100 + 0.5))
            hpT.Size = UDim2.fromOffset(30, 12)
            hpT.Position = UDim2.fromOffset(BX - 40, BY + BH - fh - 4)
            headDot.Visible = on and cfg.espHeadDot == true
            headDot.Size = UDim2.fromOffset(12, 12)
            headDot.Position = UDim2.fromOffset(headX - 6, headY - 6)
            headStroke.Color = color
            local textColor = Vis.col("colText")
            nameT.Visible = on and cfg.espNames == true
            nameT.TextColor3 = textColor
            nameT.Size = UDim2.fromOffset(BW + 60, 14)
            nameT.Position = UDim2.fromOffset(BX - 30, BY - 18)
            wpT.Visible = on and cfg.espWeapon == true
            wpT.TextColor3 = textColor
            wpT.Size = UDim2.fromOffset(BW + 40, 12)
            wpT.Position = UDim2.fromOffset(BX - 20, BY + BH + 4)
            local rowY = BY + BH + (if wpT.Visible then 16 else 4)
            local function intel(t: TextLabel, show: boolean)
                t.Visible = on and show
                t.TextColor3 = textColor
                t.Size = UDim2.fromOffset(BW + 40, 12)
                t.Position = UDim2.fromOffset(BX - 20, rowY)
                if t.Visible then
                    rowY += 12
                end
            end
            intel(rkT, cfg.espRank ~= false)
            intel(amT, cfg.espAmmo ~= false)
            intel(skT, cfg.espStreak ~= false)
            local fl = {}
            if on and cfg.espDistance then
                table.insert(fl, { "24m", textColor:Lerp(Vis.FLAG_DIM, 0.4) })
            end
            if on and cfg.espFlags ~= false then
                table.insert(fl, { "AA", color })
                table.insert(fl, { "LAG", Vis.TAG_COLOR })
            end
            for i = 1, 3 do
                local e = fl[i]
                flags[i].Visible = e ~= nil
                if e then
                    flags[i].Text = e[1]
                    flags[i].TextColor3 = e[2]
                    flags[i].Size = UDim2.fromOffset(40, 12)
                    flags[i].Position = UDim2.fromOffset(BX + BW + 5, BY + (i - 1) * 12)
                end
            end
        end
        table.insert(UI.sync, function()
            if Menu.activeTab == "Visuals" and ((Menu.panel and Menu.panel.Visible) or parent.Visible) then
                refresh()
            end
        end)
        local function place()
            local x, y, w, h = UI.avatarEspRect(avatar)
            if not (x and y and w and h) then
                return
            end
            BX, BY = math.floor(FX + x + 0.5), math.floor(FY + y + 0.5)
            BW, BH = math.max(6, math.floor(w + 0.5)), math.max(8, math.floor(h + 0.5))
            local head = avatar.model and avatar.model:FindFirstChild("Head")
            local hp = if head and head:IsA("BasePart") then UI.avatarProject(avatar, head.Position) else nil
            if hp then
                headX, headY = math.floor(FX + hp.X + 0.5), math.floor(FY + hp.Y + 0.5)
            end
            shadow.Position = UDim2.fromOffset(BX + math.floor(BW / 2), BY + BH - 1)
        end
        avatar.onReady = function()
            place()
            refresh()
        end
        if avatar.model then
            place()
        end
        refresh()
    end



    Menu.hitboxSet = "Silent"
    function Menu.hitboxKeys(): (string, string)
        if Menu.hitboxSet == "Aimbot" then
            return "aimHitboxes", "aimPrefer"
        end
        return "silentHitboxes", "silentPrefer"
    end
    function Menu.buildHitboxPanel(parent: GuiObject)
        local SC = 0.9
        local fig = frame(parent)
        fig.Name = "HitboxFigure"
        local FW, FH = math.floor(200 * SC), math.floor(330 * SC)
        fig.Size = UDim2.fromOffset(FW, FH)
        fig.AnchorPoint = Vector2.new(0.5, 0.5)
        fig.Position = UDim2.fromScale(0.5, 0.5)


        local avatar = UI.avatarViewport(fig, 0, 0, FW, FH, 2, { bodyOnly = true, fill = 0.92 })
        local DOTS = {
            { "Head", 100, 40, { { "Head", 0 } } },
            { "Body", 100, 102, { { "UpperTorso", 0 }, { "Torso", 0.45 } } },
            { "Body", 100, 146, { { "LowerTorso", 0 }, { "Torso", -0.55 } } },
            { "Arms", 47, 188, { { "RightLowerArm", 0 }, { "Right Arm", -0.3 } } },
            { "Arms", 153, 188, { { "LeftLowerArm", 0 }, { "Left Arm", -0.3 } } },
            { "Legs", 86, 262, { { "RightLowerLeg", 0 }, { "Right Leg", -0.4 } } },
            { "Legs", 114, 262, { { "LeftLowerLeg", 0 }, { "Left Leg", -0.4 } } },
        }
        local recs = {}
        local function place()
            local m = avatar.model
            if not m then
                return
            end
            for _, rec in ipairs(recs) do
                for _, a in ipairs(rec.anchors) do
                    local p = m:FindFirstChild(a[1])
                    if p and p:IsA("BasePart") then
                        local s = UI.avatarProject(avatar, p.Position + Vector3.new(0, a[2], 0))
                        if s then
                            rec.hit.Position = UDim2.fromOffset(math.floor(s.X + 0.5), math.floor(s.Y + 0.5))
                        end
                        break
                    end
                end
            end
        end
        local OFF_TINT = Color3.fromRGB(42, 40, 50)
        local function paint()
            local setKey, prefKey = Menu.hitboxKeys()
            local set = if type(cfg[setKey]) == "table" then cfg[setKey] else {}
            for _, rec in ipairs(recs) do
                local on = set[rec.part] == true
                rec.dot.Visible = on
                rec.off.Visible = not on
                rec.glow.ImageTransparency = if on then UI.glowAlpha(1.1) else 1
                rec.glow:SetAttribute("glowOff", not on)
                rec.ring.Visible = cfg[prefKey] == rec.part
            end

            local accent = C.accent
            local sig = ("%s %s %s %s %s %s"):format(setKey, tostring(set.Head), tostring(set.Body), tostring(set.Arms), tostring(set.Legs), tostring(accent))
            UI.avatarTint(avatar, sig, function(p: BasePart)
                local grp = UI.HITBOX_OF[p.Name]
                if grp and set[grp] == true then
                    return accent, 0.1
                end
                return OFF_TINT, 0
            end)
        end
        avatar.onReady = function()
            place()
            paint()
        end
        for _, d in ipairs(DOTS) do
            local hit = button(fig, "", UI.TEXT_MIN, C.text, C.bg)
            hit.BackgroundTransparency = 1
            hit.Size = UDim2.fromOffset(24, 24)
            hit.AnchorPoint = Vector2.new(0.5, 0.5)
            hit.Position = UDim2.fromOffset(math.floor(d[2] * SC), math.floor(d[3] * SC))
            hit.ZIndex = 5
            local glow = UI.glow(hit, 0, 1)
            glow.Size = UDim2.fromOffset(24, 24)
            glow.SliceScale = 0.12
            glow.ZIndex = 5
            local ring = frame(hit)
            ring.Size = UDim2.fromOffset(19, 19)
            ring.AnchorPoint = Vector2.new(0.5, 0.5)
            ring.Position = UDim2.fromScale(0.5, 0.5)
            ring.ZIndex = 6
            corner(ring, 10)
            stroke(ring, C.accent, 0.4)
            local dot = frame(hit, C.accent)
            dot.Size = UDim2.fromOffset(11, 11)
            dot.AnchorPoint = Vector2.new(0.5, 0.5)
            dot.Position = UDim2.fromScale(0.5, 0.5)
            dot.ZIndex = 7
            corner(dot, 6)
            local core = frame(dot, Color3.new(1, 1, 1))
            core.Size = UDim2.fromOffset(4, 4)
            core.AnchorPoint = Vector2.new(0.5, 0.5)
            core.Position = UDim2.fromScale(0.5, 0.5)
            core.ZIndex = 8
            corner(core, 2)
            local off = frame(hit, C.bg)
            off.Size = UDim2.fromOffset(9, 9)
            off.AnchorPoint = Vector2.new(0.5, 0.5)
            off.Position = UDim2.fromScale(0.5, 0.5)
            off.ZIndex = 7
            corner(off, 5)
            local offStroke = stroke(off, C.muted, 0)
            offStroke.Thickness = 1.5
            table.insert(recs, { part = d[1], ring = ring, glow = glow, dot = dot, off = off, hit = hit, anchors = d[4] })
            UI.tip(hit, d[1])
            hit.MouseEnter:Connect(function()
                offStroke.Color = C.accent
            end)
            hit.MouseLeave:Connect(function()
                offStroke.Color = C.muted
            end)
            hit.MouseButton1Click:Connect(function()
                local setKey, prefKey = Menu.hitboxKeys()
                if type(cfg[setKey]) ~= "table" then
                    cfg[setKey] = {}
                end
                if cfg[prefKey] == d[1] then
                    notify(d[1] .. " is the preferred hitbox, so it stays on", 2, "info")
                    return
                end
                cfg[setKey][d[1]] = if cfg[setKey][d[1]] then nil else true
                sanitize(cfg)
                saveConfig()
                paint()
            end)
        end
        Menu.paintHitboxes = paint
        local nextHitboxPaint = 0
        table.insert(UI.sync, function()
            local now = os.clock()
            if Menu.panel and Menu.panel.Visible and now >= nextHitboxPaint then
                nextHitboxPaint = now + 0.25
                paint()
            end
        end)
        if avatar.model then
            place()
        end
        paint()
    end




    Menu.balanceColumns = function() end
    Menu.TAB_SECTION = {main="Combat",rage="Combat",melee="Combat",weaponconfigs="Combat",world="Visuals",esp="Visuals",visuals="Visuals",skins="Visuals",customcosmetics="Visuals",inventoryspoofer="Visuals",character="Player",misc="Other",servers="Other",spoofers="Other",ranks="Other",settings="Settings"}
    Menu.TAB_LABEL.melee = "Melee"
    Menu.TAB_LABEL.skins = "Skins / Emotes"
    Menu.TAB_LABEL.customcosmetics = "Custom Cosmetics"
    Menu.TAB_LABEL.inventoryspoofer = "Inventory Spoofer"
    Menu.TAB_LABEL.weaponconfigs = "Weapon Configs"
    Menu.TAB_LABEL.servers = "Servers"
    Menu.TAB_LABEL.ranks = "Ranks"
    Menu.SIDE_PANEL = {}
    Menu.buildPreview = function() end
    Menu.buildHitboxPanel = function() end
    UI.PAGE_SUBTABS={
        main={"aimbot","silent aim","triggerbot","weapon","movement"},rage={"ragebot","priority"},melee={"combat","reach","targets"},world={"lighting","atmosphere","sky","effects","camera"},
        esp={"options","appearance","highlight","preview"},skins={"skin","wrap","charm","finisher","gun animations","emotes","unlock all"},customcosmetics={"skin","wrap","charm","finisher","emote"},inventoryspoofer={"cosmetics","boxes"},visuals={"weapons / viewmodels","crosshair","effects","sounds","hud"},
        character={"movement","character","animations"},misc={"general","loadout","queue","chat","ranks/ranked","overlays / extras"},
        spoofers={"spoofers","enemy spoofer","device","marketplace"},settings={"menu","configs","script","themes"},
        weaponconfigs={"presets"},servers={"browser"},ranks={"enemy ranks","ranked access","auto ban"},
    }
    function UI.pageSubtab(page,title)
        local text=string.lower(title or "")
        local rules={
            main={{{"silent"},"silent aim"},{{"aim","target"},"aimbot"},{{"trigger","click"},"triggerbot"},{{"weapon"},"weapon"},{{"move","speed","fly"},"movement"}},
            rage={{{"priority"},"priority"}},
            melee={{{"reach","hitbox"},"reach"},{{"target","team","dummy"},"targets"},{{"melee","backstab","attack","impact","combat"},"combat"}},
            world={{{"camera","stretch"},"camera"},{{"sky","weather","ambience"},"sky"},{{"bloom","sun","effect"},"effects"},{{"atmosphere","color correction"},"atmosphere"}},
            esp={{{"preview"},"preview"},{{"appearance","override","custom"},"appearance"},{{"highlight"},"highlight"}},
            skins={{{"unlock","ownership"},"unlock all"},{{"animation","gun animation"},"gun animations"},{{"emote"},"emotes"},{{"finish"},"finisher"},{{"charm"},"charm"},{{"wrap"},"wrap"},{{"skin"},"skin"}},
            customcosmetics={{{"emote"},"emote"},{{"finish"},"finisher"},{{"charm"},"charm"},{{"wrap"},"wrap"},{{"skin"},"skin"}},
            inventoryspoofer={{{"box","case"},"boxes"},{{"cosmetic","inventory"},"cosmetics"}},
            visuals={{{"viewmodel","weapon"},"weapons / viewmodels"},{{"crosshair"},"crosshair"},{{"sound"},"sounds"},{{"tracer","effect"},"effects"},{{"target","indicator","hud"},"hud"}},
            character={{{"animation"},"animations"},{{"character","anti aim","third person","noclip","fly"},"character"}},
            misc={{{"input overlay","input sounds","music player"},"overlays / extras"},{{"rank","lobby info"},"ranks/ranked"},{{"load"},"loadout"},{{"queue","ban"},"queue"},{{"chat"},"chat"}},
            spoofers={{{"robux","gifting","marketplace"},"marketplace"},{{"enemy"},"enemy spoofer"},{{"device"},"device"}},
            ranks={{{"access","preview"},"ranked access"},{{"ban"},"auto ban"},{{"rank","lobby info"},"enemy ranks"}},
            settings={{{"script","auto load","silent load"},"script"},{{"config"},"configs"},{{"theme"},"themes"}},
        }
        for _,rule in ipairs(rules[page] or {}) do for _,word in ipairs(rule[1]) do
            if string.find(text,word,1,true) then return rule[2] end
        end end
        return (UI.PAGE_SUBTABS[page] or {"General"})[1]
    end
    function Menu.buildPages()
        for _, name in ipairs(TAB_ORDER) do Menu.addTab(name,UI.PAGE_SUBTABS[name] or {"General"}) end
    end

    function Menu.buildLionArt(root)
        local art = frame(root)
        art.Name = "LionThemeArt"
        art.Size = UDim2.fromScale(1,1)
        art.ClipsDescendants = true
        art.ZIndex = 2
        art.Visible = cfg.themeArt ~= false
        Menu.lionArt = art
        local function line(a, b, transparency)
            local delta = b - a
            local segment = frame(art, Color3.fromRGB(223,221,211))
            segment.AnchorPoint = Vector2.new(0.5,0.5)
            segment.Position = UDim2.fromOffset((a.X+b.X)/2,(a.Y+b.Y)/2)
            segment.Size = UDim2.fromOffset(delta.Magnitude,1)
            segment.Rotation = math.deg(math.atan2(delta.Y,delta.X))
            segment.BackgroundTransparency = transparency
            segment.ZIndex = 2
        end
        local origin = Vector2.new(10,10)
        for ray = 0, 6 do
            local angle = ray * math.pi / 12
            line(origin, origin + Vector2.new(math.cos(angle),math.sin(angle))*205, 0.48)
        end
        for ring = 1, 5 do
            local radius = ring * 38
            for ray = 0, 5 do
                local a, b = ray*math.pi/12, (ray+1)*math.pi/12
                local p = origin + Vector2.new(math.cos(a),math.sin(a))*radius
                local q = origin + Vector2.new(math.cos(b),math.sin(b))*radius
                local midAngle = (a+b)/2
                local mid = origin + Vector2.new(math.cos(midAngle),math.sin(midAngle))*(radius-5)
                line(p,mid,0.56); line(mid,q,0.56)
            end
        end
        local function pumpkin(x, y, size, transparency)
            local holder = frame(art)
            holder.Size = UDim2.fromOffset(size,size)
            holder.Position = UDim2.fromScale(x,y)
            holder.AnchorPoint = Vector2.new(0.5,0.5)
            holder.ZIndex = 2
            for lobe = 1, 3 do
                local body = frame(holder,Color3.fromRGB(237,126,0))
                body.Size = UDim2.fromScale(0.58,0.78)
                body.Position = UDim2.fromScale(0.04+(lobe-1)*0.17,0.14)
                body.BackgroundTransparency = transparency
                body.ZIndex = 2
                corner(body,size/2)
            end
            local stem = frame(holder,Color3.fromRGB(181,128,40))
            stem.Position = UDim2.fromScale(0.46,0.04)
            stem.Size = UDim2.fromScale(0.1,0.19)
            stem.Rotation = 15
            stem.BackgroundTransparency = transparency
            stem.ZIndex = 2
            local face = label(holder,"▲  ▲\n▰▰▰",size*0.18,Color3.fromRGB(18,17,14),UI.F.semibold)
            face.TextXAlignment = Enum.TextXAlignment.Center
            face.Size = UDim2.fromScale(0.9,0.65)
            face.Position = UDim2.fromScale(0.05,0.22)
            face.TextTransparency = transparency
            face.ZIndex = 3
        end
        pumpkin(0.58,0.63,300,0.91)
        pumpkin(0.36,0.48,28,0.34)
        pumpkin(0.87,0.32,23,0.47)
        pumpkin(0.47,0.87,32,0.41)
    end

    function Menu.build()
        UI.resetRegistries()
        Menu.syncMarks = {}
        UI.syncTab = {}
        local gui = Instance.new("ScreenGui")
        gui.Name = "PlexNativeUI"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.DisplayOrder = 1000
        gui.Enabled = false
        if not Game.parentGui(gui) then
            error("could not parent the menu (PlayerGui, gethui and CoreGui all refused)")
        end
        Menu.gui = gui
        UI.gui = gui


        local backdrop = frame(gui)
        backdrop.Name = "Backdrop"
        backdrop.Size = UDim2.fromScale(1, 1)

        backdrop.BackgroundColor3 = Color3.new(0, 0, 0)
        backdrop.BackgroundTransparency = 1
        backdrop.Active = false
        backdrop.Visible = false
        backdrop.ZIndex = 1
        Menu.backdrop = backdrop



        UI.cursor = nil
        if not UI.mouseBound then
            UI.mouseBound = true
            pcall(RunService.UnbindFromRenderStep, RunService, "plex_nativeMenuMouse")
            pcall(RunService.BindToRenderStep, RunService, "plex_nativeMenuMouse", Enum.RenderPriority.Last.Value, function()
                if S.menuOpen and S.alive ~= false then
                    pcall(UI.mouseTick)
                end
            end)
        end


        Menu.layout()
        local px = Menu.px

        UI.M.colW = math.floor((MENU_W - RAIL_W) / 2) - 30

        local host = frame(gui)
        host.Name = "Host"
        host.AnchorPoint = Vector2.new(0.5, 0.5)
        host.Size = UDim2.new(0, MENU_W, 0, MENU_H)
        host.Position = UDim2.fromScale(0.5, 0.5)
        host.Visible = false
        host.ZIndex = 2
        Menu.host = host
        Menu.hostBase = nil
        Menu.panelShift = 0
        UI.popupHost = host





        local root = frame(host, Color3.new(1, 1, 1))
        root.Name = "Root"
        root.Size = UDim2.fromScale(1, 1)
        root.ZIndex = 1
        root.Active = true
        root.ClipsDescendants = false
        corner(root, IS_LION and 5 or 12)
        Menu.root = root
        UI.root = root
        if IS_LION then
            root.BackgroundTransparency = 0.06
            Menu.buildLionArt(root)
        end
        Menu.loops = {}
        Menu.glassSplit = RAIL_W / MENU_W
        Menu.glassGrad = gradient(root, C.side, C.bg)
        do
            local edge = stroke(root, Color3.new(1, 1, 1), 0)
            local eg = Instance.new("UIGradient")
            eg.Rotation = 35
            local lookFx = UI.themeFx()
            eg.Color = if lookFx
                then UI.fxSeq(lookFx.flag)
                else ColorSequence.new({
                    ColorSequenceKeypoint.new(0, C.accent),
                    ColorSequenceKeypoint.new(0.35, C.edge),
                    ColorSequenceKeypoint.new(0.7, C.edge),
                    ColorSequenceKeypoint.new(1, C.accent2),
                })
            eg.Parent = edge
            if not lookFx and UI.metalEdge(edge) then
                Menu.loop(eg, TweenInfo.new(30, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), { Rotation = 395 })
            end

            UI.softShadow(root, "Shadow", Color3.new(0, 0, 0), 0.45, 22)
            if not IS_LION then UI.softShadow(root, "Aura", C.accent, UI.glowAlpha(0.4), 20) end
        end

        local mouseFree = Instance.new("TextButton")
        mouseFree.Name = "MouseFree"
        mouseFree.Modal = true
        mouseFree.Text = ""
        mouseFree.AutoButtonColor = false
        mouseFree.BackgroundTransparency = 1
        mouseFree.Size = UDim2.fromOffset(1, 1)
        mouseFree.Visible = S.menuOpen == true
        mouseFree.Parent = root
        Menu.mouseFree = mouseFree

        local curtain = frame(root, C.bg)
        curtain.Name = "Curtain"
        curtain.Size = UDim2.fromScale(1, 1)
        curtain.ZIndex = 60
        curtain.Visible = false
        corner(curtain, 12)
        Menu.curtain = curtain





        local side = frame(root)
        side.Name = "Sidebar"
        side.Size = UDim2.new(0, RAIL_W, 1, 0)
        side.ZIndex = 2
        side.ClipsDescendants = true
        if IS_LION then side.BackgroundColor3 = C.side; side.BackgroundTransparency = 0 end
        corner(side, 12)
        do
            local wash = frame(side, Color3.new(1, 1, 1))
            wash.Name = "AcrylicWash"
            wash.Size = UDim2.new(1, 12, 1, 0)
            wash.ZIndex = 2
            wash.Active = false
            corner(wash, 12)
            local wg = gradient(wash, C.accent, C.accent2, 90)
            local washFx = UI.themeFx()
            if UI.themeName() == "Plex blue" then
                wg.Color = ColorSequence.new(C.side, C.bg)
            elseif washFx then
                wg.Color = UI.fxSeq(washFx.flag)
            elseif UI.metal then
                wg.Color = ColorSequence.new(UI.metal.lite, UI.metal.mid)
            end
            wg.Transparency = if UI.metal and not washFx
                then NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.9),
                    NumberSequenceKeypoint.new(0.45, 0.975),
                    NumberSequenceKeypoint.new(1, 0.93),
                })
                else NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.8),
                    NumberSequenceKeypoint.new(0.45, 0.94),
                    NumberSequenceKeypoint.new(1, 0.84),
                })
            UI.acrylic(wash, { light = 0, grain = 0.96, radius = 12, z = 2 })


            if UI.glowRadial then
                for _, spec in ipairs({ { C.accent, 0.72, math.floor(RAIL_W * 0.55), px(80), px(240), px(190) }, { C.accent2, 0.8, px(170), MENU_H - px(90), px(260), px(260) } }) do
                    local bleed = Instance.new("ImageLabel")
                    bleed.Name = "AcrylicBleed"
                    bleed.BackgroundTransparency = 1
                    bleed.Image = UI.glowRadial
                    bleed.ImageColor3 = spec[1]
                    bleed.ImageTransparency = spec[2]
                    bleed.AnchorPoint = Vector2.new(0.5, 0.5)
                    bleed.Position = UDim2.fromOffset(spec[3], spec[4])
                    bleed.Size = UDim2.fromOffset(spec[5], spec[6])
                    bleed.ZIndex = 3
                    bleed.Parent = side
                end
            end
        end
        local sideHair = frame(root, Color3.new(1, 1, 1))
        sideHair.Size = UDim2.new(0, 1, 1, 0)
        sideHair.Position = UDim2.new(0, RAIL_W, 0, 0)
        sideHair.ZIndex = 4
        gradient(sideHair, C.accent, C.hairline, 90).Transparency = NumberSequence.new(0.2, 0)
        local LOGO_H = px(58)
        local logo = frame(side)
        logo.Name = "Logo"
        logo.Size = UDim2.new(1, 0, 0, LOGO_H)
        logo.ZIndex = 4
        logo.Active = true
        local gemPx = px(20)
        local gemHolder = frame(logo)
        gemHolder.Size = UDim2.fromOffset(gemPx, gemPx)
        gemHolder.AnchorPoint = Vector2.new(0, 0.5)
        gemHolder.Position = UDim2.new(0, px(18), 0.5, 0)
        gemHolder.ZIndex = 5

        local gem = UI.logoMark(gemHolder, gemPx + 2, 45)
        gem.ZIndex = 6

        local brandRow = frame(logo)
        brandRow.Name = "Brand"
        brandRow.Visible = not IS_LION
        brandRow.Size = UDim2.new(1, -px(50), 1, 0)
        brandRow.Position = UDim2.new(0, px(46), 0, 0)
        brandRow.ZIndex = 5
        local brl = vlist(brandRow, px(7), true)
        brl.VerticalAlignment = Enum.VerticalAlignment.Center
        local wordSize = px(21)
        local word = label(brandRow, "plex.cc\n<font size=\"9\">DEV · v1</font>", wordSize, C.text, UI.HUD_BOLD)
        word.RichText = true
        word.AutomaticSize = Enum.AutomaticSize.None
        word.Size = UDim2.fromScale(1,1)
        word.LayoutOrder = 1
        word.ZIndex = 5
        if S.edition == "max" then
            local chip = UI.maxBadge(brandRow, px(16))
            chip.LayoutOrder = 2
            chip.ZIndex = 6
            for _, d in ipairs(chip:GetDescendants()) do
                if d:IsA("GuiObject") then
                    d.ZIndex = 7
                end
            end
        end

        do
            local shimmer = Instance.new("UIGradient")
            shimmer.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                ColorSequenceKeypoint.new(0.42, Color3.new(1, 1, 1)),
                ColorSequenceKeypoint.new(0.5, C.accent),
                ColorSequenceKeypoint.new(0.58, Color3.new(1, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1)),
            })
            local shineFx = UI.themeFx()
            if shineFx then
                local kp = { ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)), ColorSequenceKeypoint.new(0.36, Color3.new(1, 1, 1)) }
                local n = #shineFx.flag
                for i, c in ipairs(shineFx.flag) do
                    table.insert(kp, ColorSequenceKeypoint.new(0.4 + 0.2 * (i - 1) / (n - 1), c))
                end
                table.insert(kp, ColorSequenceKeypoint.new(0.64, Color3.new(1, 1, 1)))
                table.insert(kp, ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1)))
                shimmer.Color = ColorSequence.new(kp)
            end
            if UI.metal and not shineFx then


                word.Text = "plex.cc\n<font size=\"9\">DEV · v1</font>"
                word.TextColor3 = Color3.new(1, 1, 1)
                shimmer.Rotation = 90
                shimmer.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, UI.metal.hi),
                    ColorSequenceKeypoint.new(0.34, UI.metal.hi:Lerp(UI.metal.lite, 0.6)),
                    ColorSequenceKeypoint.new(0.48, UI.metal.lite:Lerp(UI.metal.mid, 0.3)),
                    ColorSequenceKeypoint.new(0.58, UI.metal.hi),
                    ColorSequenceKeypoint.new(0.78, UI.metal.hi:Lerp(UI.metal.lite, 0.5)),
                    ColorSequenceKeypoint.new(1, UI.metal.hi),
                })
                shimmer.Offset = Vector2.new(0, -0.14)
                shimmer.Parent = word
                Menu.loop(shimmer, TweenInfo.new(6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Offset = Vector2.new(0, 0.14) })
            else
                shimmer.Offset = Vector2.new(-1, 0)
                shimmer.Parent = word
                Menu.loop(shimmer, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, false, 3.2), { Offset = Vector2.new(1, 0) })
            end
        end

        do
            local fxOk, fxErr = pcall(UI.fxMenu, root, side, px, Menu.loop)
            if not fxOk then
                log("WARN", "theme effects: " .. tostring(fxErr):sub(1, 120))
            end
        end


        local top = frame(root)
        top.Name = "TopBar"
        top.Size = UDim2.new(1, -RAIL_W, 0, HEADER_H)
        top.Position = UDim2.new(0, RAIL_W, 0, 0)
        top.ZIndex = 3
        top.Active = true
        if IS_LION then
            local title = label(top, "plex.cc  •  Lion", 14, C.text, UI.F.semibold)
            title.Position = UDim2.fromOffset(12,3)
            title.Size = UDim2.new(1,-24,0,20)
            title.TextXAlignment = Enum.TextXAlignment.Center
            title.ZIndex = 6
        end
        local topHair = frame(top, C.hairline)
        topHair.Size = UDim2.new(1, 0, 0, 1)
        topHair.Position = UDim2.new(0, 0, 1, -1)
        topHair.ZIndex = 3
        local function topButton(w: number, x: number, anchorRight: boolean): TextButton
            local b = button(top, "", UI.M.value, C.dim, C.surface)
            b.Size = UDim2.fromOffset(px(w), px(28))
            b.AnchorPoint = Vector2.new(if anchorRight then 1 else 0, 0.5)
            b.Position = UDim2.new(if anchorRight then 1 else 0, px(x), IS_LION and 0 or 0.5, IS_LION and 44 or 0)
            b.ZIndex = 4
            corner(b, 6)
            stroke(b, C.edge, 0)
            return b
        end

        local cfgBtn = topButton(140, 16, false)
        local cfgLbl = label(cfgBtn, "", UI.M.value, C.text, UI.F.body)
        cfgLbl.Size = UDim2.new(1, -30, 1, 0)
        cfgLbl.Position = UDim2.fromOffset(10, 0)
        cfgLbl.TextTruncate = Enum.TextTruncate.AtEnd
        cfgLbl.ZIndex = 5
        local cfgChev = icon(cfgBtn, "expand", 16)
        cfgChev.AnchorPoint = Vector2.new(1, 0.5)
        cfgChev.Position = UDim2.new(1, -5, 0.5, 0)
        cfgChev.ZIndex = 5
        recolourIcon(cfgChev, C.muted)
        local function syncCfgLabel()
            local t2 = if Configs.active ~= "" then Configs.active else "No config"
            if cfgLbl.Text ~= t2 then
                cfgLbl.Text = t2
            end
            cfgLbl.TextColor3 = if Configs.active ~= "" then C.text else C.muted
        end
        syncCfgLabel()
        table.insert(UI.sync, syncCfgLabel)
        cfgBtn.MouseButton1Click:Connect(function()
            local names = Configs.list()
            local shown = math.min(#names, 8)
            UI.openDropdown(cfgBtn, 180, function(f: Frame): number
                for i = 1, shown do
                    local nm = names[i]
                    UI.dropdownOption(f, 4 + (i - 1) * 24, nm, nm == Configs.active, function()
                        UI.closeDropdown()
                        local ok, res = Configs.load(nm)
                        notify(if ok then "Loaded " .. res else res, if ok then 2 else 3, if ok then "ok" else "warn")
                        if ok then
                            Menu.afterConfigSwap()
                        end
                    end)
                end
                UI.dropdownOption(f, 4 + shown * 24, if #names > shown then "All configs…" else "Manage configs…", false, function()
                    UI.closeDropdown()
                    Menu.showTab("settings")
                end)
                return 8 + (shown + 1) * 24
            end)
        end)
        UI.tip(cfgBtn, "The config your settings came from. Pick another to load it, or manage them on the Config page.")
        local saveBtn = topButton(76, 164, false)
        local saveIc = icon(saveBtn, "save", 15)
        saveIc.AnchorPoint = Vector2.new(0, 0.5)
        saveIc.Position = UDim2.new(0, 10, 0.5, 0)
        saveIc.ZIndex = 5
        recolourIcon(saveIc, C.dim)
        local saveLbl = label(saveBtn, "save", UI.M.value, C.dim, UI.F.medium)
        saveLbl.Size = UDim2.new(1, -32, 1, 0)
        saveLbl.Position = UDim2.fromOffset(31, 0)
        saveLbl.ZIndex = 5


        local dirtyDot = frame(saveBtn, C.accent)
        dirtyDot.Size = UDim2.fromOffset(9, 9)
        dirtyDot.AnchorPoint = Vector2.new(0.5, 0.5)
        dirtyDot.Position = UDim2.new(1, -2, 0, 2)
        dirtyDot.ZIndex = 6
        dirtyDot.Visible = false
        corner(dirtyDot, 5)
        local dirtyRing = stroke(dirtyDot, C.accent, 0)
        table.insert(UI.sync, function()
            local d = Configs.isDirty()
            if dirtyDot.Visible ~= d then
                dirtyDot.Visible = d
            end
            if d then
                local wave = 0.5 + 0.5 * math.sin(os.clock() * math.pi * 3)
                dirtyDot.BackgroundTransparency = 0.45 * (1 - wave)
                dirtyRing.Color = dirtyDot.BackgroundColor3
                dirtyRing.Thickness = 1 + 4 * wave
                dirtyRing.Transparency = 0.25 + 0.75 * wave
            end
        end)
        saveBtn.MouseButton1Click:Connect(function()
            if Configs.active == "" then
                notify("Create a config first — your settings are kept either way", 3, "info")
                Menu.showTab("settings")
                return
            end
            local ok, res = Configs.save()
            notify(if ok then "Saved into " .. res else res, if ok then 2 else 3, if ok then "ok" else "warn")
        end)
        UI.tip(saveBtn, "Writes your current settings into the active config. The dot means there are changes it doesn't have yet.")

        if UI.brushed(saveBtn) then
            saveLbl.TextColor3 = UI.metal.ink
            recolourIcon(saveIc, UI.metal.ink)
            UI.setFont(saveLbl, UI.F.bold)
            saveBtn.BackgroundColor3 = Color3.fromRGB(228, 228, 232)
        end
        for _, b in ipairs({ cfgBtn, saveBtn }) do
            b.MouseEnter:Connect(function()
                tween(b, TW_HOVER, { BackgroundColor3 = if b == saveBtn and UI.metal then Color3.new(1, 1, 1) else C.card })
            end)
            b.MouseLeave:Connect(function()
                tween(b, TW_HOVER, { BackgroundColor3 = if b == saveBtn and UI.metal then Color3.fromRGB(228, 228, 232) else C.surface })
            end)
        end
        local function iconButton(name: string, x: number, hoverColor: Color3?): TextButton
            local b = button(top, "", 10, C.text, C.card)
            b.Size = UDim2.fromOffset(px(28), px(28))
            b.AnchorPoint = Vector2.new(1, 0.5)
            b.Position = UDim2.new(1, px(x), IS_LION and 0 or 0.5, IS_LION and 44 or 0)
            b.BackgroundTransparency = 1
            b.ZIndex = 4
            corner(b, 6)
            local ic = icon(b, name, px(17))
            ic.ZIndex = 5
            recolourIcon(ic, C.muted)
            b.MouseEnter:Connect(function()
                tween(b, TW_HOVER, { BackgroundTransparency = 0 })
                UI.tintIcon(ic, hoverColor or C.text, true)
            end)
            b.MouseLeave:Connect(function()
                tween(b, TW_HOVER, { BackgroundTransparency = 1 })
                UI.tintIcon(ic, C.muted, true)
            end)
            return b
        end
        local closeBtn = iconButton("close", -14)
        closeBtn.MouseButton1Click:Connect(function()
            Menu.set(false)
        end)
        UI.tip(closeBtn, "Close the menu (Insert)")
        local settingsBtn = iconButton("Settings", -46)
        settingsBtn.MouseButton1Click:Connect(function()
            Menu.showTab("settings")
        end)
        UI.tip(settingsBtn, "Interface: Simple / Advanced mode, accent, menu size, panic")
        local searchBox = frame(top, C.surface)
        searchBox.Size = UDim2.fromOffset(px(176), px(28))
        searchBox.AnchorPoint = Vector2.new(1, 0.5)
        searchBox.Position = UDim2.new(1, -px(82), IS_LION and 0 or 0.5, IS_LION and 44 or 0)
        searchBox.ZIndex = 4
        corner(searchBox, 6)
        local searchStroke = stroke(searchBox, C.edge, 0)
        local sIc = icon(searchBox, "search", 15)
        sIc.AnchorPoint = Vector2.new(0, 0.5)
        sIc.Position = UDim2.new(0, 9, 0.5, 0)
        sIc.ZIndex = 5
        recolourIcon(sIc, C.muted)
        local search = Instance.new("TextBox")
        search.Name = "Search"
        search.Size = UDim2.new(1, -38, 1, 0)
        search.Position = UDim2.fromOffset(30, 0)
        search.BackgroundTransparency = 1
        search.BorderSizePixel = 0
        UI.setFont(search, UI.F.body)
        search.TextSize = UI.M.value
        search.TextColor3 = C.text
        search.PlaceholderText = "search settings"
        search.PlaceholderColor3 = C.muted
        search.Text = ""
        search.ClearTextOnFocus = false
        search.TextXAlignment = Enum.TextXAlignment.Left
        search.ZIndex = 5
        search.Parent = searchBox
        search:GetPropertyChangedSignal("Text"):Connect(function()
            UI.search(search.Text)
        end)
        search.Focused:Connect(function()
            tween(searchStroke, TW_HOVER, { Color = C.accent })
        end)
        search.FocusLost:Connect(function()
            tween(searchStroke, TW_HOVER, { Color = C.edge })
        end)
        Menu.search = search

        function Menu.refreshModeSwitch() end


        local content = frame(root)
        content.Name = "Content"
        content.Size = UDim2.new(1, -RAIL_W, 1, -HEADER_H)
        content.Position = UDim2.new(0, RAIL_W, 0, HEADER_H)
        content.ClipsDescendants = true
        content.ZIndex = 3
        Menu.content = content


        do
            local pageCurtain = frame(content, C.bg)
            pageCurtain.Name = "PageCurtain"
            pageCurtain.Size = UDim2.fromScale(1, 1)
            pageCurtain.ZIndex = 40
            pageCurtain.Visible = false
            pageCurtain.Active = false
            corner(pageCurtain, 12)
            Menu.pageCurtain = pageCurtain
        end



        local CARD_H = px(56)
        local nav = Instance.new("ScrollingFrame")
        nav.Name = "Nav"
        nav.Position = UDim2.new(0, 0, 0, LOGO_H)
        nav.Size = UDim2.new(1, 0, 1, -LOGO_H - CARD_H)
        nav.BackgroundTransparency = 1
        nav.BorderSizePixel = 0
        nav.ScrollBarThickness = 2
        nav.ScrollBarImageColor3 = C.faint
        nav.ScrollingDirection = Enum.ScrollingDirection.Y
        nav.AutomaticCanvasSize = Enum.AutomaticSize.Y
        nav.CanvasSize = UDim2.new(0, 0, 0, 0)
        nav.ZIndex = 4
        nav.Parent = side
        vlist(nav, 1)
        padding(nav, 0, 8, px(6), 8)



        do
            local navClip = frame(side)
            navClip.Name = "NavSelection"
            navClip.Position = nav.Position
            navClip.Size = nav.Size
            navClip.ClipsDescendants = true
            navClip.ZIndex = 3

            local sel = frame(navClip, Color3.new(1, 1, 1))
            sel.Name = "Pill"
            sel.BackgroundTransparency = 0.93
            sel.Visible = false
            if IS_LION then sel.BackgroundTransparency = 1 end
            sel.ZIndex = 3
            corner(sel, 6)
            stroke(sel, Color3.new(1, 1, 1), 0.92)

            if UI.brushed(sel) then
                sel.BackgroundTransparency = 0
            end
            Menu.navSel = sel
            Menu.navLiquid = UI.liquid(sel, function(a: number, b: number)
                sel.Position = UDim2.fromOffset(Menu.navSelX or 8, a)
                sel.Size = UDim2.fromOffset(Menu.navSelW or (RAIL_W - 16), math.max(4, b - a))
            end)
            function Menu.placeNav(animate: boolean?)
                local d = Menu.tabBtns[Menu.activeTab]
                local item = d and d.item
                if not (item and item.Parent and item.Visible) then
                    sel.Visible = false
                    return
                end
                local rel = item.AbsolutePosition - navClip.AbsolutePosition
                local size = item.AbsoluteSize
                if size.Y < 1 then
                    return
                end
                Menu.navSelX, Menu.navSelW = rel.X, size.X
                sel.Visible = true
                Menu.navLiquid.to(rel.Y, rel.Y + size.Y, animate and S.menuOpen == true)
            end
            UI.conn(nav:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
                if Menu.placeNav then
                    Menu.placeNav(false)
                end
            end))
        end
        Menu.sectionCaps = {}
        local lastSection: string? = nil
        local navOrder = 0
        for _, name in ipairs(TAB_ORDER) do
            if name == "Debug" and not Menu.debugAllowed() then
                continue
            end
            local sec = Menu.TAB_SECTION[name]
            if not IS_LION and sec and sec ~= lastSection then
                navOrder += 1
                local cap = label(nav, string.lower(sec), UI.M.tiny, C.muted, UI.F.body)
                cap.Size = UDim2.new(1, 0, 0, px(26))
                cap.TextYAlignment = Enum.TextYAlignment.Bottom
                cap.LayoutOrder = navOrder
                cap.ZIndex = 5
                padding(cap, 0, 0, 5, 10)
                Menu.sectionCaps[sec] = cap
                lastSection = sec
            end
            navOrder += 1
            local item = button(nav, "", 10, C.text, Color3.new(1, 1, 1))
            item.Name = "Nav_" .. name
            item.BackgroundTransparency = 1
            item.Size = UDim2.new(1, 0, 0, px(30))
            item.LayoutOrder = navOrder
            item.ZIndex = 5
            corner(item, 6)
            local ic = icon(item, name, px(17))
            ic.AnchorPoint = Vector2.new(0, 0.5)
            ic.Position = UDim2.new(0, px(11), 0.5, 0)
            ic.ZIndex = 7
            local lbl = label(item, string.lower(Menu.TAB_LABEL[name] or name), UI.M.title, C.dim, UI.F.body)
            if IS_LION then
                lbl.Visible = false
                ic.AnchorPoint = Vector2.new(0.5,0.5)
                ic.Position = UDim2.fromScale(0.5,0.5)
                UI.tip(item, Menu.TAB_LABEL[name] or name)
            end
            local lionMarker
            if IS_LION then
                lionMarker = frame(item,C.accent)
                lionMarker.Size = UDim2.new(0,2,1,-8)
                lionMarker.Position = UDim2.fromOffset(0,4)
                lionMarker.Visible = false
                lionMarker.ZIndex = 7
            end
            lbl.Size = UDim2.new(1, -px(46), 1, 0)
            lbl.Position = UDim2.new(0, px(38), 0, 0)
            lbl.ZIndex = 7
            local hovered = false


            local function paint(on: boolean, animate: boolean?)
                if lionMarker then lionMarker.Visible = on end

                local icCol = if on and UI.metal then UI.metal.ink elseif on or name == "Max" then C.accent elseif hovered then C.dim else C.muted
                local txtCol = if on and UI.metal then UI.metal.ink elseif on or hovered then C.text elseif name == "Max" then C.accent:Lerp(C.text, 0.3) else C.dim
                local bgTr = if hovered and not on then 0.96 else 1
                UI.tintIcon(ic, icCol, animate)
                if animate then
                    tween(lbl, TW_HOVER, { TextColor3 = txtCol })
                    tween(item, TW_HOVER, { BackgroundTransparency = bgTr })
                else
                    lbl.TextColor3 = txtCol
                    item.BackgroundTransparency = bgTr
                end
                UI.setFont(lbl, if on then UI.F.medium else UI.F.body)
            end
            item.MouseEnter:Connect(function()
                hovered = true
                paint(Menu.activeTab == name, true)
            end)
            item.MouseLeave:Connect(function()
                hovered = false
                paint(Menu.activeTab == name, true)
            end)
            item.MouseButton1Click:Connect(function()
                Menu.showTab(name)
            end)
            Menu.tabBtns[name] = { item = item, paint = paint, glyph = ic, cap = lbl }
            paint(false)
        end

        local DIGITS = { One = 1, Two = 2, Three = 3, Four = 4, Five = 5, Six = 6, Seven = 7, Eight = 8, Nine = 9 }
        UI.conn(UIS.InputBegan:Connect(function(input: InputObject)
            if Game.superseded() or not S.menuOpen or input.UserInputType ~= Enum.UserInputType.Keyboard or UIS:GetFocusedTextBox() then
                return
            end
            local n = DIGITS[input.KeyCode.Name]
            if not n then
                return
            end
            local items = {}
            for tabName, d in pairs(Menu.tabBtns) do
                if d.item and d.item.Parent and d.item.Visible then
                    table.insert(items, { name = tabName, order = d.item.LayoutOrder })
                end
            end
            table.sort(items, function(a, b)
                return a.order < b.order
            end)
            if items[n] then
                Menu.showTab(items[n].name)
            end
        end))



        local card = frame(side)
        card.Name = "UserCard"
        card.Size = UDim2.new(1, 0, 0, CARD_H)
        card.Position = UDim2.new(0, 0, 1, -CARD_H)
        card.ZIndex = 8
        card.Active = true
        corner(card, 12)
        local cardHair = frame(card, C.hairline)
        cardHair.Size = UDim2.new(1, 0, 0, 1)
        cardHair.ZIndex = 8
        local avPx = px(28)
        local avatar = Instance.new("ImageLabel")
        avatar.Size = UDim2.fromOffset(avPx, avPx)
        avatar.AnchorPoint = Vector2.new(0, 0.5)
        avatar.Position = UDim2.new(0, px(14), 0.5, 0)
        avatar.BackgroundColor3 = C.card
        avatar.Image = ("rbxthumb://type=AvatarHeadShot&id=%d&w=48&h=48"):format(UI.localUserId())
        avatar.ZIndex = 9
        avatar.Parent = card
        corner(avatar, avPx // 2)
        do

            local ring = stroke(avatar, C.accent, 0.55)
            if UI.metalEdge(ring) then
                ring.Thickness = 1.5
            end
        end
        local online = frame(avatar, C.ok)
        online.Size = UDim2.fromOffset(8, 8)
        online.AnchorPoint = Vector2.new(1, 1)
        online.Position = UDim2.new(1, 1, 1, 1)
        online.ZIndex = 10
        corner(online, 4)
        local onStroke = stroke(online, C.side, 0)
        onStroke.Thickness = 2

        local shownVer = "v" .. (if S.edition == "max" then MAX_PUBLIC_VERSION else PUBLIC_VERSION)
        local verW = UI.gw(shownVer, UI.M.small) + px(4)
        local verL = label(card, shownVer, UI.M.small, C.faint, UI.F.body)
        verL.Name = "VerLine"
        verL.Size = UDim2.new(0, verW, 0, px(16))
        verL.AnchorPoint = Vector2.new(1, 0)
        verL.Position = UDim2.new(1, -px(12), 0, px(11))
        verL.TextXAlignment = Enum.TextXAlignment.Right
        verL.ZIndex = 9
        local nameL = label(card, UI.localUserName(), UI.M.title, C.text, UI.F.medium)
        nameL.Size = UDim2.new(1, -px(66) - verW, 0, px(16))
        nameL.Position = UDim2.new(0, px(50), 0, px(11))
        nameL.TextTruncate = Enum.TextTruncate.AtEnd
        nameL.ZIndex = 9
        local subL = label(card, string.lower(EXECUTOR_NAME), UI.M.small, C.muted, UI.F.body)
        subL.Name = "SubLine"
        subL.Size = UDim2.new(1, -px(62), 0, px(14))
        subL.Position = UDim2.new(0, px(50), 0, px(28))
        subL.TextTruncate = Enum.TextTruncate.AtEnd
        subL.ZIndex = 9
        if S.edition == "max" then

            local chip = UI.maxBadge(card, 15)
            chip.AnchorPoint = Vector2.new(0, 0.5)
            chip.Position = UDim2.new(0, px(50), 0, px(28) + px(7))
            chip.ZIndex = 10
            for _, d in ipairs(chip:GetDescendants()) do
                if d:IsA("GuiObject") then
                    d.ZIndex = 11
                end
            end
            local cw = chip.Size.X.Offset + px(6)
            subL.Position = UDim2.new(0, px(50) + cw, 0, px(28))
            subL.Size = UDim2.new(1, -px(62) - cw, 0, px(14))
        end
        UI.tip(avatar, "@" .. UI.localUserHandle())
        if IS_LION then
            avatar.Position = UDim2.new(0,18,0.5,0)
            for _, object in ipairs(card:GetDescendants()) do
                if object:IsA("TextLabel") then object.Visible = false end
            end
        end


        local panel = frame(host, C.bg)
        panel.Name = "SidePanel"
        panel.Size = UDim2.new(0, PREVIEW_W, 1, 0)
        panel.Position = UDim2.new(1, PANEL_GAP, 0, 0)
        panel.Visible = false
        panel.Active = true
        panel.ZIndex = 1
        corner(panel, 12)
        UI.softShadow(panel, "Shadow", Color3.new(0, 0, 0), 0.45, 22)
        do

            local peg = UI.metalEdge(stroke(panel, C.edge, 0))
            if peg then
                peg.Rotation = 180
                Menu.loop(peg, TweenInfo.new(30, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), { Rotation = 540 })
                UI.softShadow(panel, "Aura", C.accent, UI.glowAlpha(0.4), 20)
            end
        end
        Menu.panel = panel
        Menu.applyGlass()
        local function panelView(title: string): (Frame, Frame)
            local v = frame(panel)
            v.Size = UDim2.fromScale(1, 1)
            v.Visible = false
            local head = frame(v)
            head.Size = UDim2.new(1, 0, 0, HEADER_H)
            local t = label(head, string.lower(title), UI.M.group, C.text, UI.F.semibold)
            t.Size = UDim2.new(1, -28, 1, 0)
            t.Position = UDim2.fromOffset(14, 0)
            local hh = frame(head, C.hairline)
            hh.Size = UDim2.new(1, 0, 0, 1)
            hh.Position = UDim2.new(0, 0, 1, -1)
            return v, head
        end
        local function footer(v: Frame, h: number): Frame
            local foot = frame(v)
            foot.Size = UDim2.new(1, 0, 0, h)
            foot.Position = UDim2.new(0, 0, 1, -h)
            local fh = frame(foot, C.hairline)
            fh.Size = UDim2.new(1, 0, 0, 1)
            local holder = frame(foot)
            holder.Size = UDim2.new(1, -28, 1, -14)
            holder.Position = UDim2.fromOffset(14, 9)
            return holder
        end

        local hbView, hbHead = panelView("Hitboxes")
        local segF = frame(hbHead, C.surface)
        segF.Size = UDim2.fromOffset(112, 24)
        segF.AnchorPoint = Vector2.new(1, 0.5)
        segF.Position = UDim2.new(1, -12, 0.5, 0)
        corner(segF, 6)
        stroke(segF, C.edge, 0)
        local segBtns = {}
        for i, nm in ipairs({ "Aimbot", "Silent" }) do
            local sb = button(segF, string.lower(nm), UI.M.small, C.muted, C.accent)
            sb.Size = UDim2.new(0.5, -3, 1, -4)
            sb.Position = UDim2.new((i - 1) * 0.5, if i == 1 then 2 else 1, 0, 2)
            sb.BackgroundTransparency = 1
            corner(sb, 4)
            segBtns[nm] = sb
            sb.MouseButton1Click:Connect(function()
                Menu.setHitboxSet(nm)
            end)
        end
        local hbBody = frame(hbView)
        hbBody.Position = UDim2.new(0, 0, 0, HEADER_H)
        hbBody.Size = UDim2.new(1, 0, 1, -HEADER_H - 76)
        Menu.buildHitboxPanel(hbBody)
        local hbHolder = footer(hbView, 76)
        local function hitboxRows(prefKey: string, visKey: string): Frame
            local holder = frame(hbHolder)
            holder.Size = UDim2.fromScale(1, 1)
            local gg = UI.group(holder, "Hitbox figure " .. prefKey, { bare = true, simple = true })
            gg:cycle("Prefer", prefKey, { "Head", "Body", "Arms", "Legs" }, { onChange = function()
                sanitize(cfg)
                if Menu.paintHitboxes then
                    Menu.paintHitboxes()
                end
            end })
            gg:toggle("Visible fallback", visKey, { desc = "Aims at any exposed hitbox when the preferred one is covered." })
            return holder
        end
        local rowsAim = hitboxRows("aimPrefer", "aimVisibleHitbox")
        local rowsSilent = hitboxRows("silentPrefer", "silentVisibleHitbox")
        function Menu.setHitboxSet(nm: string)
            Menu.hitboxSet = nm
            rowsAim.Visible = nm == "Aimbot"
            rowsSilent.Visible = nm ~= "Aimbot"
            for k, sb in pairs(segBtns) do
                local on = k == nm

                if UI.brushed(sb) then
                    local light = sb:FindFirstChild("BrushedLight")
                    if light then
                        (light :: Frame).Visible = on
                    end
                    sb.BackgroundTransparency = if on then 0 else 1
                    sb.TextColor3 = if on then UI.metal.ink else C.muted
                    UI.setFont(sb, if on then UI.F.bold else UI.F.medium)
                else
                    sb.BackgroundTransparency = if on then 0.86 else 1
                    sb.TextColor3 = if on then C.accent else C.muted
                end
            end
            if Menu.paintHitboxes then
                Menu.paintHitboxes()
            end
        end
        Menu.setHitboxSet("Silent")

        local pvView, pvHead = panelView("Preview")
        local pvHint = label(pvHead, "visible enemy", UI.M.small, C.muted, UI.F.body)
        pvHint.Size = UDim2.fromOffset(100, 16)
        pvHint.AnchorPoint = Vector2.new(1, 0.5)
        pvHint.Position = UDim2.new(1, -14, 0.5, 0)
        pvHint.TextXAlignment = Enum.TextXAlignment.Right
        local pvBody = frame(pvView)
        pvBody.Position = UDim2.new(0, 0, 0, HEADER_H)
        pvBody.Size = UDim2.new(1, 0, 1, -HEADER_H - 50)
        Menu.buildPreview(pvBody)
        local pvHolder = footer(pvView, 50)
        local pg = UI.group(pvHolder, "Preview health", { bare = true, simple = true })
        pg:slider("Health", "previewHp", 1, 100, 1, { unit = "%", trackW = 86, fmt = function(n)
            return tostring(math.floor(n))
        end })


        do
            local sheet = frame(panel, C.bg)
            sheet.Name = "Sheet"
            sheet.Size = UDim2.fromScale(1, 1)
            sheet.ZIndex = 50
            sheet.Visible = false
            sheet.Active = false
            corner(sheet, 12)
            Menu.panelSheet = sheet
        end



        function Menu.layoutPane(tabName: string)
            local kind = if cfg.previewPane ~= false then Menu.SIDE_PANEL[tabName] else nil
            local show = kind ~= nil
            local wasKind = Menu.paneKind
            Menu.paneKind = kind
            if panel.Visible ~= show then
                panel.Visible = show
            end
            hbView.Visible = kind == "hitbox"
            pvView.Visible = kind == "preview"
            local sheet = Menu.panelSheet
            if sheet and show and kind ~= wasKind and S.menuOpen then
                Menu.panelSheetToken = (Menu.panelSheetToken or 0) + 1
                local token = Menu.panelSheetToken
                sheet.BackgroundTransparency = 0.1
                sheet.Visible = true
                tween(sheet, UI.TW.reveal, { BackgroundTransparency = 1 }).Completed:Connect(function(state: Enum.PlaybackState)
                    if state == Enum.PlaybackState.Completed and token == Menu.panelSheetToken then
                        sheet.Visible = false
                    end
                end)
            end
            if kind == "hitbox" then
                Menu.setHitboxSet(if tabName == "Aimbot" then "Aimbot" else "Silent")
            end
            if show then
                local vp = gui.AbsoluteSize
                local base = Menu.hostBase or host.Position
                local cx = base.X.Scale * vp.X + base.X.Offset
                local over = cx + MENU_W / 2 + PANEL_GAP + PREVIEW_W - (vp.X - 12)
                if vp.X > 100 and over > 0 then
                    local nx = math.floor(math.max(MENU_W / 2 + 12, cx - over) + 0.5)
                    local ny = math.floor(base.Y.Scale * vp.Y + base.Y.Offset + 0.5)
                    Menu.hostBase = UDim2.fromOffset(nx, ny)
                    host.Position = Menu.hostBase
                end
            end
        end

        Menu.pages = {}
        Menu.subs = {}
        Menu.buildPages()


        table.insert(Menu.syncMarks, { at = #UI.sync + 1, tab = nil })
        for i, mark in ipairs(Menu.syncMarks) do
            local nextAt = if Menu.syncMarks[i + 1] then Menu.syncMarks[i + 1].at else mark.at
            for j = mark.at, nextAt - 1 do
                UI.syncTab[j] = mark.tab
            end
        end
        Menu.showTab(TAB_ORDER[1])
        UI.refilter()
        Menu.balanceColumns()


        local dragging, dragStart, startPos = false, Vector2.zero, UDim2.new()
        function Menu.clampToScreen()
            local vp = gui.AbsoluteSize
            if vp.X < 100 or vp.Y < 100 then
                return
            end
            local half = host.AbsoluteSize * 0.5
            local center = host.AbsolutePosition + half
            local extra = if panel.Visible then PANEL_GAP + PREVIEW_W else 0

            local inset = if gui.IgnoreGuiInset then GuiService:GetGuiInset().Y else 0
            local cx = math.clamp(center.X, half.X, math.max(half.X, vp.X - half.X - extra))
            local cy = math.clamp(center.Y, half.Y - inset, math.max(half.Y - inset, vp.Y - half.Y - inset))


            local nx = math.floor(cx + 0.5)
            local ny = math.floor(cy + inset + 0.5)
            if host.Position.X.Scale ~= 0 or host.Position.Y.Scale ~= 0 or math.abs(cx - center.X) > 0.01 or math.abs(cy - center.Y) > 0.01 then
                host.Position = UDim2.fromOffset(nx, ny)
            end
            Menu.hostBase = host.Position
        end
        for _, handle in ipairs({ top, logo }) do
            handle.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    dragStart = i.Position
                    startPos = host.Position
                end
            end)
            handle.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                    Menu.applyDrag()
                    Menu.clampToScreen()
                end
            end)
        end



        UI.conn(UIS.InputChanged:Connect(function(i)
            if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                local d = i.Position - dragStart
                Menu.dragTo = UDim2.new(startPos.X.Scale, startPos.X.Offset + math.floor(d.X + 0.5), startPos.Y.Scale, startPos.Y.Offset + math.floor(d.Y + 0.5))
            end
        end))
        function Menu.applyDrag()
            local to = Menu.dragTo
            if to then
                Menu.dragTo = nil
                if host.Position ~= to then
                    host.Position = to
                end
                Menu.hostBase = to
            end
        end
        UI.conn(gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            task.defer(Menu.clampToScreen)
        end))
    end

    function Menu.destroy()
        UI.closeBindPopup()
        UI.closeDropdown()
        for _, t in ipairs(Menu.loops or {}) do
            pcall(t.Cancel, t)
        end
        Menu.loops = {}
        Menu.glassGrad = nil
        for _, c in ipairs(UI.conns) do
            pcall(c.Disconnect, c)
        end
        table.clear(UI.conns)
        UI.dragInstalled = false
        UI.drag = nil


        UI.searchText = ""
        if Menu.gui then
            pcall(Menu.gui.Destroy, Menu.gui)
        end
        Menu.gui = nil
        Menu.root = nil
        Menu.host = nil
        Menu.panel = nil
        Menu.backdrop = nil
        Menu.curtain = nil
        Menu.pageCurtain = nil
        Menu.navSel = nil
        Menu.navLiquid = nil
        Menu.placeNav = nil
        Menu.hostBase = nil
        Menu.paintHitboxes = nil
        UI.gui = nil
        UI.root = nil
        UI.popupHost = nil
        Menu.tabBtns = {}
        Menu.pages = {}
        Menu.subs = {}
    end
    table.insert(Game.cleanups, function()
        Menu.destroy()
    end)

    function Menu.refreshToggles()
        for _, t2 in pairs(S.ui.toggles or {}) do
            if t2.refresh then
                pcall(t2.refresh)
            end
        end
    end


    function Menu.panicAll()
        if Combat.stopAutokill then
            Combat.stopAutokill("panic")
        end
        for _, k in ipairs({
            "aimbot", "silentAim", "autoShoot", "esp", "aaEnabled", "aaBody", "autokill", "autokillAuto", "autoBackstab", "autoQuickMelee",
            "rapidFire", "noSpread", "noRecoil", "instantBullet", "instantReload", "fastEquip", "fastAim", "noAdsZoom", "speedBoost", "noAdsSlow", "bhop", "autoSlide",
            "thirdPerson", "fakeDuck", "autoPeek", "autoBlock", "unsafeMode", "unsafeFakeLag", "unsafePingBoost", "meleeRage", "voidSpam", "defenseHide",
            "antiMelee",



            "legitTrigger", "noclip", "rapidMelee", "fullAuto", "noSlow", "infSlide", "infSprint", "utilAuto", "gunAbilities",
            "fly", "autoStrafe", "flickbot",
        }) do
            cfg[k] = false
        end
        cfg.deviceSpoof = "Real"

        cfg.ragePosition = "None"
        sanitize(cfg)
        if Combat.body then
            Combat.body.goHome("panic")
        end
        if Combat.releaseFire then
            Combat.releaseFire()
        end
        if Input.releaseAll then
            Input.releaseAll("panic")
        end
        if Combat.aaBody then
            Combat.aaBody(false)
        end
        cfg.rageCsync = false
        cfg.posDesync = false
        cfg.csync = false
        if Combat.csync then
            pcall(Combat.csync, false)
        end
        if Combat.thirdPerson then
            Combat.thirdPerson(false)
        end
        if S.net and S.net.uninstall then
            pcall(S.net.uninstall)
        end
        if Combat.applyWeaponStats then
            Combat.applyWeaponStats(true)
        end
        saveConfig()
        Menu.refreshToggles()
        notify("Everything is off", 3, "warn")
    end



    Menu.VISUAL_OFF = {
        "esp", "espHighlight", "radar", "crosshair", "showFov", "overlaySpin", "overlayGradient",
        "selfChams", "vmChams", "vmChamsArms", "vmOutline", "vmNoSway", "haloOn", "hideViewmodel", "hideHands",
        "nightMode", "fullbright", "fovChanger", "noAdsZoom", "fovRotate", "reloadIndicator", "hitMarkers",
        "nameSpoof", "weaponSpoof", "rankSpoof", "streamerMode", "hideNametags",
        "worldNoTextures", "worldTextureTint", "stretchedRes", "noScopeOverlay",

        "maxAlertCard", "maxTargetCard", "maxSnapline", "maxDamageLog", "maxLowHp", "maxKillAnnounce",
        "maxIntel", "maxIntelAim", "maxLookLines", "maxTrails", "maxOneShot", "maxXray", "maxRgbWorld",
        "maxDayCycle", "maxLegit", "maxFarm", "maxBroadcast", "maxBadge", "maxHitSound", "maxKillSound",
    }
    function Menu.allOff(save: boolean?)
        Menu.panicAll()
        for _, k in ipairs(Menu.VISUAL_OFF) do
            if type(cfg[k]) == "boolean" then
                cfg[k] = false
            end
        end
        sanitize(cfg)
        if S.vis and S.vis.haloDrop then
            pcall(S.vis.haloDrop)
        end
        if S.vis and S.vis.worldRestore then
            pcall(S.vis.worldRestore)
        end
        Menu.refreshToggles()
        if save ~= false then
            saveConfig()
        end
    end
    S.allOff = Menu.allOff

    function Menu.rebuild()
        local wasOpen = S.menuOpen
        local tab = Menu.activeTab
        local ok, err = pcall(function()
            Menu.destroy()
            S.menuOpen = false
            Menu.build()
        end)
        if not ok then
            Menu.panic(err)



            pcall(Menu.destroy)
            local ok2, err2 = pcall(Menu.build)
            if not ok2 then
                Menu.panic(err2)
                return
            end
        end
        if tab ~= "" and Menu.pages[tab] then
            Menu.showTab(tab)
        end
        if wasOpen then
            pcall(Menu.set, true)
        end
    end
    function Menu.applyTheme()
        local previous = table.clone(C)
        UI.applyTheme()
        -- Rebuilding the shell discards every group added by the feature loader.
        -- Repaint the existing instances so their controls and callbacks survive.
        local function recolor(color: Color3): Color3
            for key, old in pairs(previous) do
                if typeof(old) == "Color3" and color == old and typeof(C[key]) == "Color3" then
                    return C[key]
                end
            end
            return color
        end
        if Menu.gui then
            for _, item in ipairs(Menu.gui:GetDescendants()) do
                if item:IsA("GuiObject") then
                    item.BackgroundColor3 = recolor(item.BackgroundColor3)
                    item.BorderColor3 = recolor(item.BorderColor3)
                    if item:IsA("TextLabel") or item:IsA("TextButton") or item:IsA("TextBox") then
                        item.TextColor3 = recolor(item.TextColor3)
                        item.TextStrokeColor3 = recolor(item.TextStrokeColor3)
                    elseif item:IsA("ImageLabel") or item:IsA("ImageButton") then
                        item.ImageColor3 = recolor(item.ImageColor3)
                    elseif item:IsA("ScrollingFrame") then
                        item.ScrollBarImageColor3 = recolor(item.ScrollBarImageColor3)
                    end
                elseif item:IsA("UIStroke") then
                    item.Color = recolor(item.Color)
                elseif item:IsA("UIGradient") then
                    local points = {}
                    for _, point in ipairs(item.Color.Keypoints) do
                        points[#points + 1] = ColorSequenceKeypoint.new(point.Time, recolor(point.Value))
                    end
                    item.Color = ColorSequence.new(points)
                end
            end
        end
        if Menu.glassGrad then Menu.glassGrad.Color = ColorSequence.new(C.side, C.bg) end
        if Menu.lionArt then Menu.lionArt.Visible = cfg.themeArt ~= false end
        if Menu.root then
            local art = Menu.root:FindFirstChild("DefaultThemeArt")
            local showArt = UI.themeName() == "Plex blue" and cfg.themeArt ~= false
            if art then art.Visible = showArt end
            if showArt and not art then
                local backdrop = frame(Menu.root, Color3.fromRGB(25, 28, 39))
                backdrop.Name = "DefaultThemeArt"
                backdrop.Size = UDim2.fromScale(1, 1)
                backdrop.BackgroundTransparency = 0.94
                backdrop.ZIndex = 1
                backdrop.ClipsDescendants = true
                local shade = Instance.new("UIGradient")
                shade.Rotation = 18
                shade.Color = ColorSequence.new(Color3.fromRGB(25, 28, 39), Color3.fromRGB(16, 18, 28))
                shade.Transparency = NumberSequence.new(0.55)
                shade.Parent = backdrop
            end
        end
        UI.refilter()
        if S.hud and S.hud.retheme then
            pcall(S.hud.retheme)
        end
        notify("Theme: " .. UI.themeName(), 2, "ok")
        log("INFO", "theme:", UI.themeName())
    end



    function Menu.afterConfigSwap()

        table.clear(S.localEquips)
        pcall(Skins.load)
        Skins.equipGen = (Skins.equipGen or 0) + 1
        pcall(Skins.refreshEquipmentUi)
        task.defer(function()
            pcall(Skins.applyNow, nil)
        end)
        if S.edition == "max" then
            cfg.theme = UI.maxThemeName()
        end
        Menu.applyTheme()
        if S.hud and S.hud.retheme then
            pcall(S.hud.retheme)
        end
        if Combat.applyWeaponStats then
            pcall(Combat.applyWeaponStats, true)
        end
    end
    S.rebuildMenu = Menu.rebuild
    S.applyTheme = Menu.applyTheme
    S.ui.openBindPopup = function(cfgKey: string)
        UI.openBindPopup(cfgKey)
    end
    S.ui.closeBindPopup = UI.closeBindPopup
    S.ui.search = UI.search
    S.ui.setMode = function(mode: string)
        UI.setMode(mode)
        if Menu.refreshModeSwitch then
            Menu.refreshModeSwitch()
        end
    end



    local lastSyncAt = 0
    local syncBuckets, syncGlobal, syncCount = {}, {}, -1
    local function rebuildSyncBuckets()
        table.clear(syncBuckets)
        table.clear(syncGlobal)
        local owner = UI.syncTab or {}
        for i, fn in ipairs(UI.sync) do
            local tab = owner[i]
            if tab then
                local bucket = syncBuckets[tab]
                if not bucket then bucket = {} syncBuckets[tab] = bucket end
                bucket[#bucket + 1] = fn
            else
                syncGlobal[#syncGlobal + 1] = fn
            end
        end
        syncCount = #UI.sync
    end
    function Menu.syncNow(tab: string?)
        if #UI.sync ~= syncCount then rebuildSyncBuckets() end
        if tab == nil then
            for _, fn in ipairs(UI.sync) do pcall(fn) end
            return
        end
        for _, fn in ipairs(syncGlobal) do pcall(fn) end
        for _, fn in ipairs(syncBuckets[tab] or {}) do pcall(fn) end
    end
    function Menu.tick(enemies: { any })
        if not S.menuOpen then
            return
        end
        -- Feature modules add their controls after the window is built. Refresh
        -- visibility when a deferred module registers new rows so its cards appear.
        local rowCount = #UI.rows
        if rowCount ~= Menu.lastRefilterRows then
            Menu.lastRefilterRows = rowCount
            UI.refilter()
        end
        if Menu.dragTo and Menu.applyDrag then
            Menu.applyDrag()
        end
        local now = os.clock()
        if now - lastSyncAt >= 0.12 then
            lastSyncAt = now
            Menu.syncNow(Menu.activeTab)
        end
    end





-- Compatibility surface maps the existing module definitions to the native widgets.
local Library = {Toggles={},Options={},NativeUI=UI,NativeMenu=Menu,FontColor=C.text,MainColor=C.surface,
    BackgroundColor=C.bg,OutlineColor=C.edge,AccentColor=C.accent,KeybindFrame={Visible=false}}
UI.onThemeChanged(function()
    Library.FontColor=C.text
    Library.MainColor=C.surface
    Library.BackgroundColor=C.bg
    Library.OutlineColor=C.edge
    Library.AccentColor=C.accent
end)
local events, options, serial = {}, {}, 0
local scheduleAutoSave = function() end
function Library:OnEvent(name)
    if not events[name] then events[name]=Instance.new("BindableEvent") end
    return events[name].Event
end
local function fire(name,...) if events[name] then events[name]:Fire(...) end end
local originalSet = Menu.set
Menu.set=function(open) originalSet(open) fire("VisibilityChanged",open) end
function Library:Toggle() Menu.set(not S.menuOpen) end
function Library:SetVisible(open) Menu.set(open==true) end

local mobileControlsGui
local function ensureMobileControls()
    if not UIS.TouchEnabled then return nil end
    if mobileControlsGui and mobileControlsGui.Parent then return mobileControlsGui end

    local parent
    pcall(function() parent = gethui and gethui() end)
    if not parent then pcall(function() parent = game:GetService("CoreGui") end) end
    if not parent then parent = LP:WaitForChild("PlayerGui") end

    local gui = Instance.new("ScreenGui")
    gui.Name = "PlexMobileControls"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 100004
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = parent
    mobileControlsGui = gui

    local holder = Instance.new("Frame")
    holder.Name = "Controls"
    holder.AnchorPoint = Vector2.new(1, 0.5)
    holder.Position = UDim2.new(1, -12, 0.5, 0)
    holder.Size = UDim2.fromOffset(116, 76)
    holder.BackgroundTransparency = 1
    holder.Parent = gui

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 8)
    layout.Parent = holder

    local function addButton(name, label, callback)
        local button = Instance.new("TextButton")
        button.Name = name
        button.Size = UDim2.fromOffset(116, 34)
        button.BackgroundColor3 = C.bg
        button.BackgroundTransparency = 0.08
        button.BorderSizePixel = 0
        button.AutoButtonColor = false
        button.Text = label
        button.TextColor3 = C.text
        button.TextSize = 13
        button.Font = Enum.Font.BuilderSansExtraBold
        button.ZIndex = 100
        button.Parent = holder

        local round = Instance.new("UICorner")
        round.CornerRadius = UDim.new(0, 8)
        round.Parent = button

        local outline = Instance.new("UIStroke")
        outline.Color = C.accent
        outline.Transparency = 0.15
        outline.Thickness = 1
        outline.Parent = button

        button.Activated:Connect(function()
            if S.alive == false then return end
            pcall(callback)
        end)
        return button
    end

    addButton("OpenUI", "OPEN UI", function()
        Menu.set(true)
    end)
    addButton("Unload", "UNLOAD", function()
        Library:Unload()
    end)

    table.insert(Game.cleanups, function()
        if gui and gui.Parent then gui:Destroy() end
        if mobileControlsGui == gui then mobileControlsGui = nil end
    end)
    return gui
end
local toastHost
local function makeToastHost()
    if toastHost and toastHost.Parent then return toastHost end
    local parent
    pcall(function() parent=gethui and gethui() end)
    if not parent then pcall(function() parent=game:GetService("CoreGui") end) end
    if not parent then parent=LP:WaitForChild("PlayerGui") end
    local gui=Instance.new("ScreenGui")
    gui.Name="PlexNativeToasts"
    gui.ResetOnSpawn=false
    gui.IgnoreGuiInset=true
    gui.DisplayOrder=100002
    gui.Parent=parent
    toastHost=UI.frame(gui)
    toastHost.Name="ToastStack"
    toastHost.Position=UDim2.fromOffset(18,18)
    toastHost.Size=UDim2.fromOffset(306,440)
    toastHost.ZIndex=50
    local viewport=workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1400,800)
    local hostScale=Instance.new("UIScale")
    hostScale.Scale=math.clamp(viewport.X/1400,0.9,1.45)
    hostScale.Parent=toastHost
    local layout=Instance.new("UIListLayout")
    layout.SortOrder=Enum.SortOrder.LayoutOrder
    layout.Padding=UDim.new(0,7)
    layout.Parent=toastHost
    table.insert(Game.cleanups,function() if gui.Parent then gui:Destroy() end end)
    return toastHost
end
local function plexAlertCategory(data, kind)
    local title=tostring(data.Title or ""):lower()
    local text=tostring(data.Text or ""):lower()
    kind=tostring(kind or ""):lower()
    if kind=="ready" then return "system" end
    if kind=="error" or title:find("error",1,true) or text:find("error",1,true) or text:find("failed",1,true) then return "errors" end
    if kind=="warning" or kind=="warn" or title:find("warn",1,true) or text:find("warning",1,true) or text:find("denied",1,true) then return "warnings" end
    if title:find("staff",1,true) or text:find("staff",1,true) or text:find("moderator",1,true) then return "staff" end
    if title:find("ragebot",1,true) or text:find("prioritized",1,true) or text:find("ragebot",1,true) then return "ragebot" end
    if title:find("config",1,true) or text:find("config",1,true) or text:find("autoload",1,true) or text:find("auto load",1,true) then return "configs" end
    if title:find("hit",1,true) or text:find("damage",1,true) or text:find("hit ",1,true) or text:find("killed",1,true) or text:find("target",1,true) then return "combat" end
    if title:find("plex",1,true) or text:find("loaded",1,true) or text:find("update",1,true) or text:find("ready",1,true) then return "system" end
    return "other"
end
local function plexAlertAllowed(data, kind)
    local settings=genv().__PlexAlertSettings
    if type(settings)~="table" then return true end
    if settings.enabled==false then return false end
    local categories=settings.categories
    if type(categories)~="table" then return true end
    return categories[plexAlertCategory(data,kind)]==true
end
function Library:Notify(arg, duration)
    local data=type(arg)=="table" and arg or {Text=tostring(arg or "")}
    local kind=tostring(data.Kind or data.Type or "alert"):lower()
    if not plexAlertAllowed(data,kind) then return nil end
    local isReady=kind=="ready"
    local life=math.clamp(tonumber(data.Duration or data.Durn or duration) or (isReady and 4 or 3),1,12)
    local text=tostring(data.Text or "")
    local title=tostring(data.Title or (isReady and "plex.cc" or "plex.cc alerts"))
    local blue=C.accent
    local blue2=C.accent2
    local green=Color3.fromRGB(38,232,166)
    local white=C.text
    local dim=C.dim
    local host=makeToastHost()
    local card=UI.frame(host,Color3.fromRGB(13,10,19))
    card.Name=isReady and "ReadyToast" or "AlertToast"
    card.Size=UDim2.fromOffset(304,isReady and 54 or 66)
    card.ZIndex=51
    card.LayoutOrder=math.floor(os.clock()*1000)
    UI.corner(card,11)
    UI.stroke(card,blue,0.03)
    local scale=Instance.new("UIScale")
    scale.Scale=0.88
    scale.Parent=card
    TweenService:Create(scale,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1}):Play()
    if isReady then
        local markHolder=UI.frame(card)
        markHolder.Name="PlexBrandIcon"
        markHolder.BackgroundTransparency=1
        markHolder.Position=UDim2.fromOffset(10,10)
        markHolder.Size=UDim2.fromOffset(32,24)
        markHolder.ZIndex=53
        local mark=UI.logoMark(markHolder,18)
        mark.ZIndex=54
        local heading=UI.label(card,title,13,white,UI.F.semibold)
        heading.Position=UDim2.fromOffset(48,8)
        heading.Size=UDim2.fromOffset(212,20)
        heading.ZIndex=53
        local body=UI.label(card,text,11,green,UI.F.medium)
        body.Position=UDim2.fromOffset(45,26)
        body.Size=UDim2.fromOffset(225,17)
        body.TextTruncate=Enum.TextTruncate.AtEnd
        body.ZIndex=53
        local check=UI.icon(card,"check",18)
        check.AnchorPoint=Vector2.new(0,0)
        check.Position=UDim2.fromOffset(276,18)
        check.Size=UDim2.fromOffset(17,17)
        check.ZIndex=53
        UI.recolourIcon(check,green)
    else
        local header=UI.frame(card,blue)
        header.Position=UDim2.fromOffset(9,8)
        header.Size=UDim2.new(1,-18,0,20)
        header.ZIndex=52
        UI.corner(header,6)
        UI.gradient(header,blue,blue2,90)
        local heading=UI.label(header,string.lower(title),11,Color3.fromRGB(28,12,29),UI.F.semibold)
        heading.Position=UDim2.fromOffset(10,0)
        heading.Size=UDim2.new(1,-20,1,0)
        heading.ZIndex=53
        local body=UI.label(card,text,11,white,UI.F.medium)
        body.Position=UDim2.fromOffset(12,34)
        body.Size=UDim2.new(1,-24,0,23)
        body.TextTruncate=Enum.TextTruncate.AtEnd
        body.ZIndex=53
        local highlight=tostring(data.Highlight or "")
        if highlight~="" and string.sub(text,1,#highlight)==highlight then
            local tail=string.sub(text,#highlight+1)
            local function escape(value)
                return value:gsub("&","&amp;"):gsub("<","&lt;"):gsub(">","&gt;")
            end
            body.RichText=true
            body.Text='<font color="#FF5B77">'..escape(highlight)..'</font>'..escape(tail)
        end
    end
    local track=UI.frame(card,C.hairline)
    track.Position=UDim2.new(0,10,1,-3)
    track.Size=UDim2.new(1,-20,0,2)
    track.ZIndex=53
    local fill=UI.frame(track,blue)
    fill.Size=UDim2.fromScale(1,1)
    fill.ZIndex=54
    TweenService:Create(fill,TweenInfo.new(life,Enum.EasingStyle.Linear),{Size=UDim2.fromScale(0,1)}):Play()
    task.delay(life,function()
        if not card.Parent then return end
        local out=TweenService:Create(scale,TweenInfo.new(0.17,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Scale=0.82})
        out:Play()
        out.Completed:Wait()
        if card.Parent then card:Destroy() end
    end)
    return card
end
function Library:UpdateColorsUsingRegistry() end
function Library:GetDarkerColor(color) return color:Lerp(Color3.new(),0.35) end
local function sync() if Menu.gui then Menu.syncNow(Menu.activeTab) UI.refilter() end end
Menu.afterConfigSwap=sync
local function option(id,definition,kind,value)
    if id==nil then serial+=1 id="NativeOption_"..serial end
    local object={Type=kind,Value=value,Properties={},Definition=definition,Id=id,Mode=definition.Mode or "Toggle",Transparency=definition.Transparency}
    cfg[id]=kind=="ColorPicker" and {value.R*255,value.G*255,value.B*255} or value
    function object:Emit(value)
        self.Value=value
        if kind=="Toggle" then self.Value=value==true end
        if kind~="ColorPicker" and kind~="KeyPicker" then
            cfg[id]=type(self.Value)=="table" and table.clone(self.Value) or self.Value
        end
        if kind=="KeyPicker" then cfg.binds[id]={key=tostring(self.Value or ""),mode=self.Mode} end
        if definition.Callback then definition.Callback(self.Value,self.Transparency) end
        if self.Callback then self.Callback(self.Value) end
        scheduleAutoSave()
    end
    function object:SetValue(value)
        cfg[id]=value
        self:Emit(value)
        sync()
    end
    function object:OnClick(callback) self.ClickCallback=callback end
    function object:OnChanged(callback) self.Callback=callback end
    function object:SetValueRGB(value,transparency)
        self.Transparency=transparency~=nil and transparency or self.Transparency
        cfg[id]={value.R*255,value.G*255,value.B*255}
        self:Emit(value)
        sync()
    end
    function object:SetValues(values)
        table.clear(self.Values)
        for _,v in ipairs(values or {}) do table.insert(self.Values,v) end
        sync()
    end
    function object:SetList(values) self:SetValues(values) end
    function object:SetMode(mode)
        if kind~="KeyPicker" or (mode~="Always" and mode~="Never" and mode~="Hold" and mode~="Toggle") then return end
        self.Mode=mode
        if mode=="Always" then self.Active=true elseif mode=="Never" then self.Active=false end
        cfg.binds[id]={key=tostring(self.Value or ""),mode=mode}
        if definition.ModeCallback then definition.ModeCallback(mode) end
        scheduleAutoSave()
        sync()
    end
    function object:GetState()
        if self.Mode=="Always" then return true end
        if self.Mode=="Never" then return false end
        if self.Mode=="Toggle" then return self.Active==true end
        return Input.keyDown[self.Value]==true
    end
    function object:Update() sync() end
    function object:Display() sync() end
    options[id]=object
    if kind=="Toggle" then Library.Toggles[id]=object else Library.Options[id]=object end
    return object
end
local tabboxPainters={}
local originalRefilter=UI.afterRefilter
UI.afterRefilter=function()
    for _,paint in ipairs(tabboxPainters) do paint() end
    if originalRefilter then originalRefilter() end
end
local makeGroup
local function attachExtras(object,group)
    function object:AddColorPicker(id,definition) return group:AddColorPicker(id,definition) end
    function object:AddKeyPicker(id,definition) return group:AddKeyPicker(id,definition) end
    function object:AddSlider(id,definition) return group:AddSlider(id,definition) end
    function object:AddDropdown(id,definition) return group:AddDropdown(id,definition) end
    return object
end
makeGroup=function(parent,title)
    local native=UI.group(parent,title,{simple=true})
    local group={Native=native,Container=native.frame}
    function group:AddToggle(id,definition)
        local object=option(id,definition,"Toggle",definition.Default==true)
        object.Row=native:toggle(definition.Text or id,id,{
            bindable=definition.Bindable==true,
            onChange=function(value) object:Emit(value) end
        })
        return attachExtras(object,self)
    end
    function group:AddSlider(id,definition)
        local object=option(id,definition,"Slider",definition.Default or definition.Min or 0)
        object.Min,object.Max=definition.Min,definition.Max
        object.Row=native:slider(definition.Text or id,id,definition.Min or 0,definition.Max or 100,
            10^-(definition.Rounding or 0),{unit=definition.Suffix,onChange=function(value) object:Emit(value) end})
        return object
    end
    function group:AddDropdown(id,definition)
        local values=table.clone(definition.Values or {})
        local default=definition.Default
        if type(default)=="number" then default=values[default] end
        if default==nil then default=definition.Multi and {} or values[1] or "" end
        local object=option(id,definition,"Dropdown",default)
        object.Values,object.Multi=values,definition.Multi==true
        if object.Multi then object.Row=native:multiselect(definition.Text or id,id,values,{placeholder=definition.Placeholder,onChange=function(value) object:Emit(value) end})
        else object.Row=native:cycle(definition.Text or id,id,values,{placeholder=definition.Placeholder,onChange=function(value) object:Emit(value) end}) end
        return attachExtras(object,self)
    end
    function group:AddInput(id,definition)
        local object=option(id,definition,"Input",tostring(definition.Default or ""))
        object.Row=native:textbox(definition.Text or id,id,{placeholder=definition.Placeholder,maxLen=4096,onChange=function(value) object:Emit(value) end})
        return object
    end
    function group:AddColorPicker(id,definition)
        local object=option(id,definition,"ColorPicker",definition.Default or C.accent)
        object.Row=native:color(definition.Title or definition.Text or "Color",id,{onChange=function(value) object:Emit(value) end})
        if definition.Transparency~=nil then
            local opacityId=id.."_Transparency"
            cfg[opacityId]=definition.Transparency
            native:slider("Transparency",opacityId,0,1,0.01,{onChange=function(value)
                object.Transparency=value
                if definition.Callback then definition.Callback(object.Value,value) end
            end})
        end
        return object
    end
    function group:AddKeyPicker(id,definition)
        local object=option(id,definition,"KeyPicker",definition.Default or "None")
        object.Row=native:keybind(definition.Text or "Keybind",id,{
            mode=object.Mode,
            placeholder=definition.Placeholder,
            onChange=function(value) object:Emit(value) end,
            onModeChange=function(mode) object:SetMode(mode) end,
        })
        cfg.binds[id]={key=object.Value,mode=object.Mode}
        return object
    end
    function group:AddLabel(text)
        local object={Native=native:note(tostring(text)),Properties={}}
        function object:SetText(value) self.Native.Text=tostring(value) end
        return attachExtras(object,self)
    end
    function group:AddButton(definition,fn)
        if type(definition)=="string" then definition={Text=definition,Func=fn} end
        return native:button(definition.Text or "Button",definition.Func or function()end)
    end
    function group:AddDivider() return native:note("────────────────") end
    function group:AddBlank(height) return native:custom(height or 4) end
    return group
end
function UI.applySavedBindings(savedBindings,savedStates)
    if type(savedBindings)~="table" then return end
    for id in pairs(Input.toggleBindHandlers) do
        if savedBindings[id]==nil then
            cfg.binds[id]={key="",mode="Toggle"}
            Input.bindTouched[id]=nil
            local tag=UI.bindTags[id]
            if tag then pcall(tag) end
        end
    end
    for id,binding in pairs(savedBindings) do
        if type(id)=="string" and type(binding)=="table" then
            local mode=binding.mode
            if mode~="Always" and mode~="Never" and mode~="Hold" and mode~="Toggle" then mode="Toggle" end
            local key=tostring(binding.key or "")
            cfg.binds[id]={key=key,mode=mode}
            Input.bindTouched[id]=nil
            local object=options[id]
            if not (object and object.Type=="KeyPicker") then
                local callback=Input.bindCallbacks[id]
                if callback then pcall(callback,key,mode) end
            end
            local tag=UI.bindTags[id]
            if tag then pcall(tag) end
        end
    end
    if type(savedStates)=="table" then
        for id,state in pairs(savedStates) do
            if type(id)=="string" and type(state)=="boolean" then
                local binding=cfg.binds[id]
                local mode=type(binding)=="table" and binding.mode or "Toggle"
                local enabled=mode=="Always" or (mode=="Toggle" and state)
                local handler=Input.toggleBindHandlers[id]
                if handler then handler(enabled)
                elseif type(cfg[id])=="boolean" then cfg[id]=enabled end
            end
        end
    end
    sync()
end
function UI.snapshotBindings()
    local bindings,states={},{}
    for id,binding in pairs(cfg.binds) do
        if type(id)=="string" and type(binding)=="table" then
            bindings[id]={key=tostring(binding.key or ""),mode=tostring(binding.mode or "Toggle")}
        end
    end
    for id in pairs(Input.toggleBindHandlers) do
        states[id]=cfg[id]==true
        if not bindings[id] then bindings[id]={key="",mode="Toggle"} end
    end
    return bindings,states
end
function Library:CreateWindow(config)
    Menu.build()
    ensureMobileControls()
    local window={Holder=Menu.host,PreviewAnchor=Menu.host,Tabs={}}
    function window:SetWindowTitle(title) end
    function window:AddTab(name)
        if not Menu.subs[name] then Menu.addTab(name,UI.PAGE_SUBTABS[name] or {"General"}) end
        local tab={Groupboxes={},Tabboxes={}}
        local function pageGroup(title,side)
            local sub=UI.pageSubtab(name,title)
            local columns=Menu.subs[name][sub]
            local g=makeGroup(columns[side],title)
            tab.Groupboxes[title]=g
            return g
        end
        function tab:ShowTab() Menu.showTab(name) end
        function tab:AddLeftGroupbox(title) return pageGroup(title,"L") end
        function tab:AddRightGroupbox(title) return pageGroup(title,"R") end
        local function tabbox(side)
            local box={Groups={}}
            function box:AddTab(title)
                if not self.Groups[title] then self.Groups[title]=pageGroup(title,side) end
                return self.Groups[title]
            end
            function box:ShowTab(title) Menu.showSub(name,UI.pageSubtab(name,title)) end
            return box
        end
        function tab:AddLeftTabbox() return tabbox("L") end
        function tab:AddRightTabbox() return tabbox("R") end
        self.Tabs[name]=tab
        return tab
    end
    function window:Update() sync() end
    UI.conn(RunService.Heartbeat:Connect(function() Menu.tick() end))
    UI.conn(UIS.InputBegan:Connect(function(input,processed)
        if input.KeyCode==Enum.KeyCode.F1 and not UIS:GetFocusedTextBox() and not capturing then
            if Library.SaveManager then
                local ok,result,message=pcall(Library.SaveManager.QuickSave,Library.SaveManager)
                notify(ok and result and "Config saved (F1)" or "Save failed: "..tostring(message or result))
            end
            return
        end
        if processed or UIS:GetFocusedTextBox() or capturing then return end
        local name=Input.inputName(input)
        if name=="Touch" then
            if S.menuOpen then return end
            local alreadyHeld=next(Input.touchInputs)~=nil
            Input.touchInputs[input]=true
            if alreadyHeld then return end
        end
        Input.keyDown[name]=true
        for _,object in pairs(options) do
            if object.Type=="KeyPicker" and object.Value==name then
                if object.Mode=="Toggle" then
                    object.Active=not object.Active
                    if Library.ToggleKeybind==object then Library:Toggle()
                    elseif object.ClickCallback then object.ClickCallback(object.Active) end
                elseif object.Mode=="Hold" then
                    object.Active=true
                    if Library.ToggleKeybind==object then Library:SetVisible(true)
                    elseif object.ClickCallback then object.ClickCallback(true) end
                end
            end
        end
        for cfgKey,handler in pairs(Input.toggleBindHandlers) do
            local binding = cfg.binds[cfgKey]
            if type(binding)=="table" and binding.key==name then
                local mode = binding.mode or "Toggle"
                if mode=="Toggle" then
                    handler(cfg[cfgKey] ~= true)
                elseif mode=="Hold" then
                    handler(true, true)
                end
            end
        end
    end))
    local function releaseKey(name)
        Input.keyDown[name]=nil
        for _,object in pairs(options) do
            if object.Type=="KeyPicker" and object.Mode=="Hold" and object.Value==name then
                object.Active=false
                if Library.ToggleKeybind==object then Library:SetVisible(false)
                elseif object.ClickCallback then object.ClickCallback(false) end
            end
        end
        for cfgKey,handler in pairs(Input.toggleBindHandlers) do
            local binding = cfg.binds[cfgKey]
            if type(binding)=="table" and binding.mode=="Hold" and binding.key==name then
                handler(false, true)
            end
        end
    end
    Input.releaseTouch=function() releaseKey("Touch") end
    UI.conn(UIS.InputEnded:Connect(function(input)
        local name=Input.inputName(input)
        if name=="Touch" then
            if not Input.touchInputs[input] then return end
            Input.touchInputs[input]=nil
            if next(Input.touchInputs) then return end
        end
        releaseKey(name)
    end))
    UI.conn(UIS.WindowFocusReleased:Connect(Input.releaseAll))
    if config.AutoShow then Menu.set(true) end
    return window
end
function Library:Unload()
    if not S.alive then return end
    Input.releaseAll()
    Menu.set(false) S.alive=false
    RunService:UnbindFromRenderStep("plex_nativeMenuMouse")
    for _,cleanup in ipairs(Game.cleanups) do pcall(cleanup) end
    for _,event in pairs(events) do event:Destroy() end
end
local themeManager={}
function themeManager:SetLibrary() end
function themeManager:SetFolder() end
function themeManager:ApplyToTab(tab)
    local group=tab:AddRightGroupbox("Native UI themes")
    group:AddDropdown("NativeTheme",{Text="Theme",Values=(function() local names={} for _,name in ipairs(THEME_ORDER) do if not UI.MAX_THEMES[name] then table.insert(names,name) end end return names end)(),Default=cfg.theme,Callback=function(value)
        cfg.theme=value
        -- Rebuild from the new palette so gradients, icons, shadows, strokes,
        -- surfaces and overlays all change together. Exact-color replacement
        -- missed UIGradient sequences and any derived accent colors.
        Menu.applyTheme()
    end})
    group:AddToggle("NativeThemeArt",{Text="Background art",Default=cfg.themeArt~=false,Callback=function(value)
        cfg.themeArt=value==true
        Menu.applyTheme()
    end})
end
local AUTOLOAD_FILE = "Overlay/autoload.json"
local AutoLoadState = {Enabled=false, Silent=false, LastConfig="", AutoLoadConfig="", TPHandlerPending=false}
do
    if readfile and isfile and isfile(AUTOLOAD_FILE) then
        local ok,data=pcall(function() return HttpService:JSONDecode(readfile(AUTOLOAD_FILE)) end)
        if ok and type(data)=="table" then
            AutoLoadState.Enabled=data.Enabled==true
            AutoLoadState.Silent=data.Silent==true
            AutoLoadState.LastConfig=type(data.LastConfig)=="string" and data.LastConfig or ""
            AutoLoadState.AutoLoadConfig=type(data.AutoLoadConfig)=="string" and data.AutoLoadConfig or AutoLoadState.LastConfig
            AutoLoadState.TPHandlerPending=data.TPHandlerPending==true
        end
    end
end
local function saveAutoLoadState()
    if not writefile then return end
    pcall(function()
        if makefolder and isfolder and not isfolder("Overlay") then makefolder("Overlay") end
        writefile(AUTOLOAD_FILE,HttpService:JSONEncode(AutoLoadState))
    end)
end
local function cloneConfigValue(value)
    if type(value)~="table" then return value end
    local out={}
    for k,v in pairs(value) do out[k]=cloneConfigValue(v) end
    return out
end
local saveManager={Folder="Overlay",AutoSaveEnabled=true,AutoSaveDelay=0.8,AutoSaveToken=0,Ready=false,Loading=false}
function saveManager:SetLibrary() end
function saveManager:SetIgnoreIndexes(indexes) self.Ignore={} for _,id in ipairs(indexes or {}) do self.Ignore[id]=true end end
function saveManager:IgnoreThemeSettings() self.IgnoreTheme=true end
function saveManager:SetFolder(folder) self.Folder=folder end
function saveManager:BuildFolderTree()
    if makefolder and isfolder then for _,folder in ipairs({self.Folder,self.Folder.."/settings"}) do if not isfolder(folder) then makefolder(folder) end end end
end
function saveManager:RefreshConfigList()
    local result={}
    if listfiles then pcall(function() for _,file in ipairs(listfiles(self.Folder.."/settings")) do
        local name=file:match("([^/\\]+)%.json$") if name then table.insert(result,name) end end end) end
    return result
end
local function configName(value) return tostring(value or ""):gsub("[^%w_%-%[%] %.']","") end
-- Transfers use the existing saved-config schema; importing never enables modules.
do
    local function decodeTransfer(text)
        if type(text)~="string" or #text==0 or #text>524288 then
            return nil,"Paste config JSON smaller than 512 KB"
        end
        local ok,data=pcall(HttpService.JSONDecode,HttpService,text)
        if not ok or type(data)~="table" or type(data.objects)~="table" then
            return nil,"Invalid config JSON: expected a saved config with objects"
        end
        local count=0
        for index,entry in pairs(data.objects) do
            count+=1
            if count>10000 or type(index)~="number" or index%1~=0 or index<1
                or type(entry)~="table" or type(entry.idx)~="string" or #entry.idx>256
                or type(entry.type)~="string" then return nil,"Invalid config setting" end
        end
        if count~=#data.objects then return nil,"Invalid config settings list" end
        for _,key in ipairs({"bindings","bindingStates","custom"}) do
            if data[key]~=nil and type(data[key])~="table" then return nil,"Invalid config "..key end
        end
        return data
    end
    function saveManager:Export(name)
        name=configName(name)
        if name=="" then return false,"Select a saved config first" end
        if type(readfile)~="function" then return false,"Workspace file access is unavailable" end
        local ok,text=pcall(readfile,self.Folder.."/settings/"..name..".json")
        if not ok then return false,"Could not read config: "..name end
        local data,err=decodeTransfer(text)
        if not data then return false,err end
        local encoded,result=pcall(HttpService.JSONEncode,HttpService,data)
        if not encoded then return false,"Could not export config" end
        return true,result
    end
    function saveManager:Import(name,text)
        name=configName(name):gsub("^%s+",""):gsub("%s+$","")
        if name=="" then return false,"Enter a new config name" end
        if type(writefile)~="function" or type(isfile)~="function" then
            return false,"Workspace file access is unavailable"
        end
        local data,err=decodeTransfer(text)
        if not data then return false,err end
        local path=self.Folder.."/settings/"..name..".json"
        local ok,result=pcall(function()
            if isfile(path) then return false end
            local encoded=HttpService:JSONEncode(data)
            self:BuildFolderTree()
            writefile(path,encoded)
            return true
        end)
        if not ok then return false,"Could not save imported config" end
        if not result then return false,"That config already exists; enter a new name" end
        return true,name
    end
end
function saveManager:Save(name)
    name=configName(name) if name=="" then return false,"Enter a config name" end
    self:BuildFolderTree()
    local data={objects={},bindings={},bindingStates={},custom=self.CustomSave and self.CustomSave() or nil}
    if Library.NativeUI and type(Library.NativeUI.snapshotBindings)=="function" then
        local bindings,states=Library.NativeUI.snapshotBindings()
        for id,binding in pairs(bindings) do
            if not (self.Ignore and self.Ignore[id]) then data.bindings[id]=binding end
        end
        for id,state in pairs(states) do
            if not (self.Ignore and self.Ignore[id]) then data.bindingStates[id]=state end
        end
    end
    for id,object in pairs(options) do
        if id=="NativeConfigName" or id=="SaveManager_ConfigList" or id=="NativeAutoLoad" or id=="NativeSilentLoad" or (self.Ignore and self.Ignore[id]) or (self.IgnoreTheme and id=="NativeTheme") then continue end
        local entry={idx=id,type=object.Type,value=cloneConfigValue(object.Value)}
        if object.Type=="ColorPicker" then entry.value=object.Value:ToHex() entry.transparency=object.Transparency end
        if object.Type=="KeyPicker" then entry.mode=object.Mode end
        table.insert(data.objects,entry)
    end
    writefile(self.Folder.."/settings/"..name..".json",HttpService:JSONEncode(data))
    Configs.active=name
    AutoLoadState.LastConfig=name
    saveAutoLoadState()
    saveConfig()
    return true
end
function saveManager:Load(name)
    name=configName(name)
    if name=="" then return false,"Select a config" end
    local path=self.Folder.."/settings/"..name..".json"
    if not readfile or not isfile or not isfile(path) then return false,"Config not found: "..name end

    local decoded,data=pcall(function()
        return HttpService:JSONDecode(readfile(path))
    end)
    if not decoded or type(data)~="table" then
        return false,"Could not read config: "..tostring(data)
    end

    self.Loading=true
    local appliedCount, failedCount, firstError = 0, 0, nil
    local applied,applyError=pcall(function()
        if self.BeforeLoad then self.BeforeLoad() end
        if data.objects then
            local toggles={}
            local function applyEntry(entry)
                local object=options[entry.idx]
                if not object or (self.Ignore and self.Ignore[entry.idx]) then return end
                local ok,err=pcall(function()
                    if object.Type=="ColorPicker" then
                        object:SetValueRGB(Color3.fromHex(entry.value),entry.transparency)
                    elseif object.Type=="Slider" then
                        object:SetValue(tonumber(entry.value) or object.Value)
                    else
                        if object.Type=="KeyPicker" and entry.mode then object:SetMode(entry.mode) end
                        object:SetValue(entry.value)
                    end
                end)
                if ok then
                    appliedCount+=1
                else
                    failedCount+=1
                    firstError=firstError or (tostring(entry.idx)..": "..tostring(err))
                end
            end
            for _,entry in ipairs(data.objects) do
                local object=options[entry.idx]
                if object and object.Type=="Toggle" then
                    table.insert(toggles,entry)
                else
                    applyEntry(entry)
                end
            end
            for _,entry in ipairs(toggles) do applyEntry(entry) end
            -- A saved toggle is applied after its key, then persistent modes win.
            for _,entry in ipairs(data.objects) do
                local object=options[entry.idx]
                if object and object.Type=="KeyPicker" and not (self.Ignore and self.Ignore[entry.idx])
                    and (object.Mode=="Always" or object.Mode=="Never" or object.Mode=="Hold") then
                    local ok,err=pcall(object.SetMode,object,object.Mode)
                    if not ok then failedCount+=1 firstError=firstError or (tostring(entry.idx)..": "..tostring(err)) end
                end
            end
        else
            for id,value in pairs(data) do
                local object=options[id]
                if object and type(value)=="table" then
                    local ok,err=pcall(function()
                        if value.Color then object:SetValueRGB(Color3.new(table.unpack(value.Color)),value.Transparency)
                        elseif value.Value~=nil then object:SetValue(value.Value) end
                    end)
                    if ok then appliedCount+=1 else failedCount+=1 firstError=firstError or (tostring(id)..": "..tostring(err)) end
                end
            end
        end
        if type(data.bindings)=="table" and Library.NativeUI
            and type(Library.NativeUI.applySavedBindings)=="function" then
            Library.NativeUI.applySavedBindings(data.bindings,data.bindingStates)
        end
        if self.CustomLoad and data.custom then self.CustomLoad(data.custom) end
    end)
    self.Loading=false

    if not applied then return false,tostring(applyError) end
    if failedCount>0 then warn("[Plex Config] "..failedCount.." settings skipped in "..name.."; first error: "..tostring(firstError)) end
    Configs.active=name
    AutoLoadState.LastConfig=name
    saveAutoLoadState()
    return true,appliedCount,failedCount
end
function saveManager:BuildConfigSection(tab)
    local group=tab:AddLeftGroupbox("Configurations")
    local name=group:AddInput("NativeConfigName",{Text="Config name",Default="default"})
    self.ConfigNameInput=name
    group:AddToggle("NativeAutoSave",{Text="Auto save changes",Default=true,Callback=function(enabled) self.AutoSaveEnabled=enabled end})
    local choice=group:AddDropdown("SaveManager_ConfigList",{
        Text="Saved config",
        Values=self:RefreshConfigList(),
        Default=AutoLoadState.LastConfig or "",
        Callback=function(value)
            if self.Loading then return end
            local selected=configName(value)
            if selected~="" and AutoLoadState.LastConfig~=selected then
                AutoLoadState.LastConfig=selected
                saveAutoLoadState()
            end
        end
    })
    self.ConfigChoice=choice
    local transferGroup=tab:AddRightGroupbox("Config import / export")
    transferGroup:AddLabel("Export a saved config or paste JSON to import.")
    transferGroup:AddLabel("Import uses Config name and does not load it.")
    local transferRow=transferGroup.Native:custom(130,"Config JSON")
    local transfer=Instance.new("TextBox")
    transfer.Name="ConfigJSON"
    transfer.Size=UDim2.fromScale(1,1)
    transfer.BackgroundColor3=C.surface
    transfer.BorderSizePixel=0
    transfer.ClearTextOnFocus=false
    transfer.MultiLine=true
    transfer.TextWrapped=false
    transfer.TextXAlignment=Enum.TextXAlignment.Left
    transfer.TextYAlignment=Enum.TextYAlignment.Top
    transfer.FontFace=UI.F.medium
    transfer.TextSize=11
    transfer.TextColor3=C.text
    transfer.PlaceholderColor3=C.muted
    transfer.PlaceholderText="Paste config JSON here"
    transfer.Text=""
    transfer.Parent=transferRow
    UI.corner(transfer,5)
    UI.stroke(transfer,C.edge,0)
    UI.padding(transfer,6,8,6,8)
    -- This transient editor is intentionally absent from Options/config serialization.
    self.TransferInput=transfer
    transferGroup:AddButton({Text="Export config",Func=function()
        local ok,result=self:Export(choice.Value)
        if not ok then notify(result) return false end
        transfer.Text=result
        local copy=setclipboard or toclipboard
        local copied=type(copy)=="function" and pcall(copy,result)
        notify(copied and "Config copied to clipboard" or "Config JSON ready to copy",2,"ok")
        return true
    end})
    transferGroup:AddButton({Text="Import config",Func=function()
        local ok,result=self:Import(name.Value,transfer.Text)
        if not ok then notify(result) return false end
        self.Loading=true
        choice:SetValues(self:RefreshConfigList())
        choice:SetValue(result)
        self.Loading=false
        notify("Imported "..result.."; press Load config to apply",2,"ok")
        return true
    end})
    local function saveSelected()
        local ok,result,message=pcall(self.Save,self,name.Value)
        if not ok or result==false then notify(message or result) return false end
        self.Loading=true
        choice:SetValues(self:RefreshConfigList())
        choice:SetValue(Configs.active)
        self.Loading=false
        return true,Configs.active
    end
    local function loadSelected()
        local ok,result,message=pcall(self.Load,self,choice.Value)
        if not ok or result==false then notify(message or result) return false end
        name:SetValue(Configs.active)
        return true,Configs.active
    end
    group:AddButton({Text="Save config",Func=saveSelected})
    group:AddButton({Text="Load config",Func=loadSelected})
    group:AddButton({Text="Refresh list",Func=function() choice:SetValues(self:RefreshConfigList()) end})
    group:AddButton({Text="Disable everything",Func=function()
        if type(context.DisableEverything)~="function" then notify("Disable everything is unavailable") return false end
        local ok,count=pcall(context.DisableEverything)
        if not ok then notify("Disable everything failed: "..tostring(count)) return false end
        notify("Disabled "..tostring(tonumber(count) or 0).." active modules",2,"ok")
        return true
    end})
    local autoLoadLabel=group:AddLabel("Auto-load config: "..(AutoLoadState.AutoLoadConfig~="" and AutoLoadState.AutoLoadConfig or "none"))
    group:AddButton({Text="Auto-load selected config",Func=function()
        local selected=configName(choice.Value)
        if selected=="" then notify("Select a saved config first") return false end
        local path=self.Folder.."/settings/"..selected..".json"
        if not isfile or not isfile(path) then notify("Config not found: "..selected) return false end
        AutoLoadState.AutoLoadConfig=selected
        saveAutoLoadState()
        autoLoadLabel:SetText("Auto-load config: "..selected)
        if self.AutoLoadToggle then self.AutoLoadToggle:SetValue(true) end
        notify("Auto-load config set to "..selected,2,"ok")
        return true
    end})
    Configs.list=function() return self:RefreshConfigList() end
    Configs.load=function(value) choice:SetValue(value) return loadSelected() end
    Configs.save=saveSelected
end

function saveManager:BuildScriptSection(tab)
    local group=tab:AddLeftGroupbox("Script")
    self.AutoLoadToggle=group:AddToggle("NativeAutoLoad",{
        Text="Auto load",
        Default=AutoLoadState.Enabled,
        Callback=function(enabled)
            AutoLoadState.Enabled=enabled==true
            saveAutoLoadState()
            if AutoLoadState.Enabled then
                self.TPHandlerArmed=false
                if not self:ArmTPHandler() then
                    notify("Auto load needs a cached main.lua and teleport queue support")
                end
            end
        end
    })
    group:AddToggle("NativeSilentLoad",{
        Text="Silent",
        Default=AutoLoadState.Silent,
        Callback=function(enabled)
            AutoLoadState.Silent=enabled==true
            saveAutoLoadState()
        end
    })
    group:AddLabel("Auto load arms TPHandler itself; executor auto-load is not required.")
    group:AddLabel("Silent hides the config load notification after teleport.")
end
function saveManager:ScheduleAutoSave() scheduleAutoSave() end
function saveManager:QuickSave()
    local name=Configs.active
    if name=="" and self.ConfigNameInput then name=self.ConfigNameInput.Value end
    if name=="" then name="autosave" end
    local result,message=self:Save(name)
    if result and self.ConfigChoice then
        self.Loading=true
        self.ConfigChoice:SetValues(self:RefreshConfigList())
        self.ConfigChoice:SetValue(name)
        self.Loading=false
    end
    return result,message
end
function saveManager:ArmTPHandler(force)
    if not AutoLoadState.Enabled then return false end
    if self.TPHandlerArmed and not force then return true end

    local env = getgenv and getgenv() or _G
    local mainSource = env.__PlexMainSource
    if type(mainSource) ~= "string" or mainSource == "" then
        self.TPHandlerArmed = false
        warn("[Plex TPHandler] local main.lua source is unavailable; execute the current main.lua or loader.lua first")
        return false
    end
    if type(writefile) ~= "function" or type(readfile) ~= "function" or type(isfile) ~= "function" then
        self.TPHandlerArmed = false
        warn("[Plex TPHandler] file read/write APIs are unavailable")
        return false
    end
    local cacheKey=table.concat({tostring(env.__PlexBuildId),tostring(env.__PlexEntryMode),
        tostring(env.__PlexLicensedEntry),tostring(env.__PlexLicenseOrigin),tostring(env.__PlexDevEntryPath),tostring(env.__PlexSourceRoot)},"|")
    local cachePresent=false
    if self.TPHandlerCachedSource==mainSource and self.TPHandlerCacheKey==cacheKey then
        local ok,present=pcall(function()return isfile("Overlay/plex_main.lua") and isfile("Overlay/plex_entry_resolver.lua") end)
        cachePresent=ok and present
    end
    if not cachePresent then
    local cached, cacheError = pcall(function()
        if type(makefolder)=="function" and type(isfolder)=="function" and not isfolder("Overlay") then makefolder("Overlay") end
        writefile("Overlay/plex_main.lua", mainSource)
        writefile("Overlay/plex_entry_resolver.lua",env.__PlexEntryResolverSource)
        local entry={Mode="bundle",BuildId=env.__PlexBuildId}
        if env.__PlexLicensedEntry then entry.Mode="licensed";entry.Origin=env.__PlexLicenseOrigin end
        if env.__PlexEntryMode=="dev" then
            entry.Mode,entry.Path,entry.SourceRoot="dev",env.__PlexDevEntryPath,env.__PlexSourceRoot
            local existsOk,exists=pcall(isfile,entry.Path)
            if not existsOk or not exists then entry.Path="plex.cc dev/main_dev.lua" end
        end
        writefile("Overlay/plex_entry.json",HttpService:JSONEncode(entry))
    end)
    if not cached then
        self.TPHandlerArmed = false
        warn("[Plex TPHandler] failed to cache main.lua: " .. tostring(cacheError))
        return false
    end

        self.TPHandlerCachedSource,self.TPHandlerCacheKey=mainSource,cacheKey
    end
    local tpHandlers,seenHandlers={},{}
    local function addHandler(name,callback)
        if type(callback)=="function" and not seenHandlers[callback] then
            seenHandlers[callback]=true;tpHandlers[#tpHandlers+1]={Name=name,Callback=callback}
        end
    end
    addHandler("queue_on_teleport",queue_on_teleport)
    addHandler("queueonteleport",queueonteleport)
    addHandler("env.queue_on_teleport",env.queue_on_teleport)
    addHandler("env.queueonteleport",env.queueonteleport)
    for _,scope in pairs({syn,env.syn,_G.syn,fluxus,env.fluxus,_G.fluxus}) do
        if type(scope)=="table" then addHandler("executor.queue_on_teleport",scope.queue_on_teleport) end
    end
    if #tpHandlers==0 then self.TPHandlerArmed=false;return false end

    local queuedSource = [==[
task.spawn(function()
-- BEGIN PLEX STARTUP WAIT
local function waitForLoadingScreen()
    local players = game:GetService("Players")
    local coreGui = game:GetService("CoreGui")
    local replicatedStorage = game:GetService("ReplicatedStorage")

    local deadline = os.clock() + 120
    while (not game:IsLoaded() or not players.LocalPlayer) and os.clock() < deadline do task.wait(0.2) end
    local player = players.LocalPlayer
    if not game:IsLoaded() or not player then
        warn("[Plex] Roblox did not finish loading within 120 seconds.")
        return false
    end
    local env = getgenv and getgenv() or _G
    local previousWait = env.__PlexStartupWaitReady
    if previousWait and previousWait.JobId == game.JobId and previousWait.Player == player
        and type(previousWait.At) == "number"
        and os.clock() - previousWait.At < 5 then
        return true
    end

    local playerGui, playerScripts, controllers, modules, playerDataModule, enumModule
    repeat
        playerGui = player:FindFirstChild("PlayerGui")
        playerScripts = player:FindFirstChild("PlayerScripts")
        controllers = playerScripts and playerScripts:FindFirstChild("Controllers")
        modules = replicatedStorage:FindFirstChild("Modules")
        playerDataModule = controllers and controllers:FindFirstChild("PlayerDataController")
        enumModule = modules and modules:FindFirstChild("EnumLibrary")
        if playerGui and playerDataModule and enumModule then break end
        task.wait(0.2)
    until os.clock() >= deadline
    if not (playerGui and playerDataModule and enumModule) then
        warn("[Plex] Native game modules did not appear within 120 seconds.")
        return false
    end
    local playerData, enumLibrary
    local function requireNative(object)
        local identity = getthreadidentity and getthreadidentity()
        if setthreadidentity then pcall(setthreadidentity, 2) end
        local ok, result = pcall(require, object)
        if identity and setthreadidentity then pcall(setthreadidentity, identity) end
        return ok, result
    end
    local function isActiveLoadingGui(object)
        local normalizedName = object.Name:lower():gsub("[%s_%-]", "")
        if normalizedName ~= "loadingscreen" and not normalizedName:find("loadingscreen", 1, true) then
            return false
        end

        local current = object
        while current and current ~= playerGui and current ~= coreGui do
            if current:IsA("LayerCollector") and not current.Enabled then
                return false
            end
            if current:IsA("GuiObject") and not current.Visible then
                return false
            end
            current = current.Parent
        end
        return object:IsDescendantOf(playerGui) or object:IsDescendantOf(coreGui)
    end

    local loadingCandidates = {}
    local loadingConnections = {}
    local function watchLoadingGui(object)
        local name = object.Name:lower():gsub("[%s_%-]", "")
        if name:find("loadingscreen", 1, true) then
            loadingCandidates[object] = true
        end
    end
    for _, root in ipairs({playerGui, coreGui}) do
        for _, object in ipairs(root:GetDescendants()) do watchLoadingGui(object) end
        table.insert(loadingConnections, root.DescendantAdded:Connect(watchLoadingGui))
        table.insert(loadingConnections, root.DescendantRemoving:Connect(function(object)
            loadingCandidates[object] = nil
        end))
    end
    local function stopWatchingLoadingGui()
        for _, connection in ipairs(loadingConnections) do connection:Disconnect() end
    end

    local clearSince, probeThread, probeRunning, nextProbe = nil, nil, false, 0
    local waitReason = "native loading screen"
    repeat
        local loading = false
        for object in pairs(loadingCandidates) do
            if isActiveLoadingGui(object) then
                loading = true
                waitReason = "loading GUI: " .. object.Name
                break
            end
        end
        clearSince = loading and nil or (clearSince or os.clock())
        -- Never start/require Client while the game's loader is visible. Its
        -- initialization can wait on its own callbacks, blocking our timeout.
        -- Read only native dependencies already loaded by the game, after the
        -- GUI clears. A separate task bounds even an executor's yielding require.
        if clearSince and os.clock() - clearSince >= 0.75 and not probeRunning
            and not playerData and os.clock() >= nextProbe then
            nextProbe = os.clock() + 0.5
            local modulesLoaded = type(getloadedmodules) ~= "function"
            if not modulesLoaded then
                local ok, loaded = pcall(getloadedmodules)
                if ok and type(loaded) == "table" then
                    local enumLoaded, dataLoaded = false, false
                    for _, object in pairs(loaded) do
                        enumLoaded = enumLoaded or object == enumModule
                        dataLoaded = dataLoaded or object == playerDataModule
                    end
                    modulesLoaded = enumLoaded and dataLoaded
                end
            end
            waitReason = "native enum/data initialization"
            if modulesLoaded then
                probeRunning = true
                probeThread = task.spawn(function()
                    local ok, result = requireNative(enumModule)
                    if ok and type(result) == "table" and result._enum_builder_complete == true then
                        enumLibrary = result
                        local dataOk, controller = requireNative(playerDataModule)
                        if dataOk and type(controller) == "table" then playerData = controller end
                    end
                    probeRunning = false
                end)
            end
        end
        local data = playerData and playerData.CurrentData
        local ready = data and type(data.Data) == "table"
            and enumLibrary and enumLibrary._enum_builder_complete == true
        if ready and clearSince and os.clock() - clearSince >= 0.75 then
            stopWatchingLoadingGui()
            env.__PlexStartupWaitReady = {JobId = game.JobId, Player = player, At = os.clock()}
            return true
        end
        if os.clock() >= deadline then
            stopWatchingLoadingGui()
            if probeRunning and probeThread and task.cancel then pcall(task.cancel, probeThread) end
            warn("[Plex] Startup timed out waiting for " .. waitReason .. ". Rejoin a fresh game before retrying.")
            return false
        end
        task.wait(0.2)
    until false
end

if not waitForLoadingScreen() then
    local env = getgenv and getgenv() or _G
    env.__PlexRunning = nil
    env.__PlexAutoExecStarted = nil
    return
end
-- END PLEX STARTUP WAIT

    local bootEnv = getgenv and getgenv() or _G
    if bootEnv.__PlexRunningJobId and bootEnv.__PlexRunningJobId ~= game.JobId then
        bootEnv.__PlexRunning, bootEnv.__PlexAutoExecStarted, bootEnv.__PlexRunningJobId = nil, nil, nil
        bootEnv.__PlexTPHandlerBoot, bootEnv.__PlexExpectedBootToken, bootEnv.__PlexRuntimeReadyToken = nil, nil, nil
    end
    if bootEnv.__PlexAutoExecStarted or bootEnv.__PlexRunning then return end
    local shouldLoad = false
    if type(readfile) == "function" and type(isfile) == "function" and isfile("Overlay/autoload.json") then
        local ok, state = pcall(function()
            return game:GetService("HttpService"):JSONDecode(readfile("Overlay/autoload.json"))
        end)
        if ok and type(state) == "table" then
            shouldLoad = state.Enabled == true
        end
    end
    if not shouldLoad then return end

    local env = getgenv and getgenv() or _G
    local destinationKey = tostring(game.PlaceId) .. ":" .. tostring(game.JobId)
    local activeBoot = env.__PlexTPHandlerBoot
    if type(activeBoot) == "table" and activeBoot.Key == destinationKey
        and os.clock() - (tonumber(activeBoot.StartedAt) or 0) < 180 then
        return
    end
    local bootToken = destinationKey .. ":" .. tostring(os.clock())
    -- Reserve before the resolver can yield for a licensed HTTP request.
    env.__PlexTPHandlerBoot = {Key = destinationKey, Token = bootToken, StartedAt = os.clock()}
    local function releaseBoot()
        if type(env.__PlexTPHandlerBoot) == "table" and env.__PlexTPHandlerBoot.Token == bootToken then
            env.__PlexTPHandlerBoot = nil
            if env.__PlexExpectedBootToken == bootToken then
                env.__PlexExpectedBootToken, env.__PlexRuntimeReadyToken = nil, nil
                env.__PlexRunning, env.__PlexAutoExecStarted, env.__PlexRunningJobId = nil, nil, nil
            end
        end
    end
    local function writeStatus(phase)
        pcall(function()
            if type(writefile) == "function" then
                if type(makefolder) == "function" and type(isfolder) == "function" and not isfolder("Overlay") then
                    makefolder("Overlay")
                end
                writefile("Overlay/tphandler_status.txt",
                    phase .. "|" .. tostring(game.PlaceId) .. "|" .. tostring(game.JobId))
            end
        end)
    end
    writeStatus("started")

    local source
    if isfile and readfile and isfile("Overlay/plex_entry_resolver.lua") then
        local resolver,err=loadstring(readfile("Overlay/plex_entry_resolver.lua"),"PlexEntryResolver")
        if not resolver then releaseBoot();writeStatus("resolver-failed");warn(err);return end
        local resolvedOk,resolved,why=pcall(function() return resolver()() end)
        if not resolvedOk then releaseBoot();writeStatus("resolver-failed");warn("[Plex TPHandler] "..tostring(resolved));return end
        if type(resolved)~="string" then releaseBoot();writeStatus("entry-missing");warn(why);return end
        source=resolved
    end
    if not source and type(readfile) == "function" and type(isfile) == "function" and isfile("Overlay/plex_main.lua") then
        local ok, result = pcall(readfile, "Overlay/plex_main.lua")
        if ok then source = result end
    end
    if type(source) ~= "string" or source == "" then
        source = env.__PlexMainSource
    end
    if type(source) ~= "string" or source == "" then
        releaseBoot()
        writeStatus("cache-missing")
        warn("[Plex TPHandler] cached main.lua is unavailable")
        return
    end

    local chunk, compileError = loadstring(source, "plex.cc TPHandler")
    if not chunk then
        releaseBoot()
        writeStatus("compile-failed")
        warn("[Plex TPHandler] " .. tostring(compileError))
        return
    end

    env.__PlexExpectedBootToken = bootToken
    env.__PlexRuntimeReadyToken = nil
    local ran, runError = pcall(chunk)
    if not ran then
        releaseBoot()
        writeStatus("run-failed")
        warn("[Plex TPHandler] " .. tostring(runError))
    else
        local deadline = os.clock() + 150
        while env.__PlexRuntimeReadyToken ~= bootToken and os.clock() < deadline do
            local currentBoot = env.__PlexTPHandlerBoot
            if type(currentBoot) ~= "table" or currentBoot.Token ~= bootToken then break end
            task.wait(0.25)
        end
        if env.__PlexRuntimeReadyToken == bootToken then
            writeStatus("loaded")
        else
            releaseBoot()
            writeStatus("init-timeout")
            warn("[Plex TPHandler] runtime did not finish initializing; the next auto-load may retry")
        end
    end
end)
]==]

    if self.TPHandlerBootSource~=queuedSource or not isfile("Overlay/plex_teleport_boot.lua") then
        local ok,why=pcall(writefile,"Overlay/plex_teleport_boot.lua",queuedSource)
        if not ok then self.TPHandlerArmed=false;warn("[Plex TPHandler] "..tostring(why));return false end
        self.TPHandlerBootSource=queuedSource
    end
    local queueEntry=[==[
local function status(value)
    if writefile then pcall(writefile,"Overlay/tphandler_status.txt",value.."|"..tostring(game.PlaceId).."|"..tostring(game.JobId)) end
end
status("queue-entered")
local ok,source=pcall(function()return readfile("Overlay/plex_teleport_boot.lua")end)
if not ok or type(source)~="string" then status("boot-file-missing");warn("[Plex TPHandler] cached boot file missing");return end
local chunk,err=loadstring(source,"PlexTeleportBoot")
if not chunk then status("boot-compile-failed");warn(err);return end
local ran,why=pcall(chunk)
if not ran then status("boot-run-failed");warn(why) end
]==]
    self.TPHandlerArmed=false
    for _,handler in ipairs(tpHandlers) do
        local ok,accepted=pcall(handler.Callback,queueEntry)
        if ok and accepted~=false then
            self.TPHandlerArmed=true;self.TPHandlerAPI=handler.Name;break
        end
    end
    pcall(writefile,"Overlay/queue_submit_status.txt",(self.TPHandlerArmed and "accepted" or "rejected")
        .."|"..tostring(self.TPHandlerAPI).."|"..tostring(env.__PlexBuildId).."|"..tostring(game.JobId))
    return self.TPHandlerArmed
end

function saveManager:PrepareTPHandlerHandoff()
    if not AutoLoadState.Enabled then return false end
    if not self:ArmTPHandler() then return false end

    local name=Configs.active
    if name=="" and self.ConfigChoice then name=configName(self.ConfigChoice.Value) end
    if name=="" and self.ConfigNameInput then name=configName(self.ConfigNameInput.Value) end
    if name=="" then name=configName(AutoLoadState.LastConfig) end
    if name=="" then name="autosave" end

    -- Flush the current config before the teleport starts. The executor TPHandler
    -- is responsible for re-running the script in the destination server.
    local ok,result=false,false
    if self.Ready then ok,result=pcall(self.QuickSave,self) end
    if ok and result~=false then
        AutoLoadState.LastConfig=Configs.active~="" and Configs.active or name
    elseif AutoLoadState.LastConfig=="" then
        AutoLoadState.LastConfig=name
    end

    AutoLoadState.TPHandlerPending=true
    saveAutoLoadState()
    return true
end

function saveManager:TryAutoLoad()
    if not AutoLoadState.Enabled then return false end
    local function status(value)
        if type(writefile)=="function" then pcall(writefile,"Overlay/config_load_status.txt",value) end
    end
    local name=configName(AutoLoadState.AutoLoadConfig)
    if name=="" then status("missing-selection") warn("[Plex Config] Auto load has no selected config") return false end
    local path=self.Folder.."/settings/"..name..".json"
    if not isfile or not isfile(path) then status("missing-file|"..name) warn("[Plex Config] Auto load cannot find "..path) return false end
    local ok,result,appliedCount,failedCount=pcall(self.Load,self,name)
    if not ok or result==false then
        status("failed|"..name.."|"..tostring(appliedCount or result))
        warn("[Plex Config] Auto load failed: "..tostring(appliedCount or result))
        if not AutoLoadState.Silent then notify(appliedCount or result or "Auto load failed") end
        return false
    end
    if self.ConfigNameInput then self.ConfigNameInput:SetValue(name) end
    if self.ConfigChoice then
        self.Loading=true
        self.ConfigChoice:SetValues(self:RefreshConfigList())
        self.ConfigChoice:SetValue(name)
        self.Loading=false
    end
    if Menu and Menu.afterConfigSwap then Menu.afterConfigSwap() end
    local resumedFromTPHandler=AutoLoadState.TPHandlerPending==true
    if resumedFromTPHandler then
        AutoLoadState.TPHandlerPending=false
        saveAutoLoadState()
    end
    if not AutoLoadState.Silent then
        notify((resumedFromTPHandler and "TPHandler loaded " or "Auto loaded ")..name.." ("..tostring(appliedCount or 0).." settings)",2,"ok")
    end
    status("loaded|"..name.."|"..tostring(appliedCount or 0).."|"..tostring(failedCount or 0))
    self:ArmTPHandler()
    return true
end
function saveManager:StartAutoSave()
    self.Ready=true
    if AutoLoadState.Enabled then
        self:ArmTPHandler()
    end
end
scheduleAutoSave=function()
    if not saveManager.Ready or saveManager.Loading or not saveManager.AutoSaveEnabled or type(writefile)~="function" then return end
    saveManager.AutoSaveToken+=1
    local token=saveManager.AutoSaveToken
    task.delay(saveManager.AutoSaveDelay,function()
        if token~=saveManager.AutoSaveToken or not saveManager.AutoSaveEnabled then return end
        local ok,err=pcall(saveManager.QuickSave,saveManager)
        if not ok then warn("[Plex] Auto save failed:",err) end
    end)
end
-- BEGIN PLEX LOADER WINDOW
-- Plex loader window, installed as a method on the native UI library.
function Library:CreateLoaderWindow(options)
    local library=self
    if getgenv then
        local previous=getgenv().__PlexLoaderUI
        if previous and previous.Unload then pcall(previous.Unload,previous) end
    end
    local Players = game:GetService("Players")
    local UIS = game:GetService("UserInputService")
    local player = Players.LocalPlayer
    local ui = library.NativeUI
    local palette = ui.C
    local fonts = ui.F
    local connections = {}
    local running = false
    local chosen = "normal"
    local page = "licence"

    local function rgb(r, g, b) return Color3.fromRGB(r, g, b) end
    local colors = {
        back=palette.bg, side=palette.side, edge=palette.edge,
        card=palette.card, text=palette.text, dim=palette.dim,
        faint=palette.faint, blue=palette.accent,
        green=rgb(46, 218, 160), red=rgb(255, 79, 92), blue2=palette.accent2,
    }
    local function make(class, parent, properties)
        local object
        if class=="Frame" then
            object=ui.frame(parent,properties and properties.BackgroundColor3)
        elseif class=="TextLabel" then
            object=ui.label(parent,properties and properties.Text or "",properties and properties.TextSize or 12,properties and properties.TextColor3 or colors.text,properties and properties.FontFace)
        elseif class=="TextButton" then
            object=ui.button(parent,properties and properties.Text or "",properties and properties.TextSize or 12,properties and properties.TextColor3 or colors.text,properties and properties.BackgroundColor3)
        else
            object=Instance.new(class)
        end
        for property,value in pairs(properties or {}) do object[property]=value end
        object.Parent=parent
        return object
    end
    local function round(parent, radius) ui.corner(parent,radius) end
    local function stroke(parent, color, width, transparency)
        local line=ui.stroke(parent,color,transparency or 0)
        line.Thickness=width or 1
        return line
    end
    local function label(parent, text, size, color, x, y, w, h, bold)
        return make("TextLabel",parent,{
            BackgroundTransparency=1,Text=text,TextColor3=color,TextSize=size,
            FontFace=bold and fonts.semibold or fonts.body,TextXAlignment=Enum.TextXAlignment.Left,
            TextYAlignment=Enum.TextYAlignment.Center,TextTruncate=Enum.TextTruncate.AtEnd,
            Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),ZIndex=5,
        })
    end
    local function button(parent,text,x,y,w,h,background,foreground)
        local object=make("TextButton",parent,{
            AutoButtonColor=false,Text=text,TextColor3=foreground,TextSize=12,
            FontFace=fonts.semibold,BackgroundColor3=background,
            Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),ZIndex=6,
        })
        round(object,7)
        return object
    end
    local function glyph(parent,name,x,y,size,color)
        local object=ui.icon(parent,name,size)
        object.AnchorPoint=Vector2.new(0,0)
        object.Position=UDim2.fromOffset(x,y)
        object.Size=UDim2.fromOffset(size,size)
        object.ZIndex=7
        ui.recolourIcon(object,color)
        return object
    end
    local function brandLogo(parent,x,y,w,h)
        local holder=make("Frame",parent,{
            BackgroundTransparency=1,Position=UDim2.fromOffset(x,y),
            Size=UDim2.fromOffset(w,h),ZIndex=7,
        })
        local markSize=math.max(8,math.min(h,math.floor(w/1.65)))
        local mark=ui.logoMark(holder,markSize)
        mark.ZIndex=8
        return holder
    end
    local function connect(signal, callback)
        local connection=signal:Connect(callback)
        table.insert(connections,connection)
        return connection
    end

    local parent
    pcall(function() parent=gethui and gethui() end)
    if not parent then pcall(function() parent=game:GetService("CoreGui") end) end
    if not parent then parent=player:WaitForChild("PlayerGui") end
    local gui=make("ScreenGui",parent,{
        Name="PlexBetaLoader",ResetOnSpawn=false,IgnoreGuiInset=true,
        DisplayOrder=100000,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
    })
    make("Frame",gui,{
        Size=UDim2.fromScale(1,1),BackgroundColor3=colors.back,
        BackgroundTransparency=0.66,BorderSizePixel=0,ZIndex=1,
    })
    local frame=make("Frame",gui,{
        Name="Loader",AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),
        Size=UDim2.fromOffset(682,302),BackgroundColor3=colors.back,BorderSizePixel=0,ZIndex=2,
    })
    local viewport=workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(900,600)
    make("UIScale",frame,{Scale=math.clamp(viewport.X/900,0.85,2)})
    round(frame,14)
    stroke(frame,colors.blue,1,0.25)
    local shadow=make("UIStroke",frame,{Color=Color3.new(0,0,0),Thickness=7,Transparency=0.58})
    local side=make("Frame",frame,{
        Position=UDim2.fromOffset(1,1),Size=UDim2.new(0,201,1,-2),
        BackgroundColor3=colors.side,BorderSizePixel=0,ZIndex=3,
    })
    round(side,13)
    make("UIGradient",side,{Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0,palette.surface),
        ColorSequenceKeypoint.new(1,palette.side),
    }),Rotation=90})
    make("Frame",side,{Position=UDim2.new(1,-1,0,0),Size=UDim2.new(0,1,1,0),BackgroundColor3=colors.edge,BorderSizePixel=0,ZIndex=4})
    brandLogo(side,13,12,30,30)
    local wordmark=label(side,"plex.cc",17,colors.text,45,13,110,28,true)
    wordmark.ZIndex=20
    label(side,"DEV · v1",9,colors.faint,18,65,80,18,true)
    label(side,"v1",9,colors.faint,147,65,42,18)
    local navLabels={licence="licence",edition="edition",download="download",launch="launch"}
    local navIcons={licence="keyboard",edition="gem",download="save",launch="power"}
    local nav={}
    local navGlyphs={}
    local navText={}
    for index,name in ipairs({"licence","edition","download","launch"}) do
        local row=button(side,"",9,84+(index-1)*30,184,28,colors.side,colors.dim)
        navText[name]=label(row,navLabels[name],12,colors.dim,37,0,130,28,true)
        navGlyphs[name]=glyph(row,navIcons[name],13,5,17,colors.dim)
        nav[name]=row
    end
    make("Frame",side,{Position=UDim2.new(0,0,1,-55),Size=UDim2.new(1,0,0,1),BackgroundColor3=colors.edge,BorderSizePixel=0,ZIndex=4})
    local avatar=make("ImageLabel",side,{
        Position=UDim2.new(0,13,1,-43),Size=UDim2.fromOffset(29,29),
        BackgroundColor3=colors.card,Image="",ZIndex=5,
    })
    round(avatar,15)
    stroke(avatar,colors.blue,1,0.2)
    label(side,player and player.DisplayName or "player",11,colors.text,51,252,100,16,true)
    label(side,player and ("@"..player.Name) or "online",9,colors.dim,51,268,112,14)
    label(side,"beta",9,colors.faint,164,257,28,14)
    if player then
        task.spawn(function()
            local ok,thumbnail=pcall(Players.GetUserThumbnailAsync,Players,player.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size48x48)
            if ok and avatar.Parent then avatar.Image=thumbnail end
        end)
    end

    local top=make("Frame",frame,{
        Position=UDim2.fromOffset(202,0),Size=UDim2.new(1,-202,0,50),
        BackgroundTransparency=1,ZIndex=3,
    })
    local title=label(top,"sign in",12,colors.text,17,8,270,18,true)
    local subtitle=label(top,"enter a key to continue",10,colors.dim,17,25,310,15)
    local online=button(top,"●  online",363,11,82,25,colors.card,colors.green)
    round(online,14)
    stroke(online,colors.edge,1,0.45)
    local close=button(top,"×",451,9,23,27,colors.back,colors.dim)
    close.TextSize=18
    make("Frame",frame,{Position=UDim2.fromOffset(202,49),Size=UDim2.new(1,-202,0,1),BackgroundColor3=colors.edge,BorderSizePixel=0,ZIndex=4})

    local content=make("Frame",frame,{
        Position=UDim2.fromOffset(202,50),Size=UDim2.new(1,-202,1,-50),
        BackgroundTransparency=1,ZIndex=3,
    })
    local pages={}
    for _,name in ipairs({"licence","edition","download","launch"}) do
        pages[name]=make("Frame",content,{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false,ZIndex=3})
    end

    local licenceCard=make("Frame",pages.licence,{
        Position=UDim2.fromOffset(18,17),Size=UDim2.new(1,-36,0,116),
        BackgroundColor3=colors.card,BackgroundTransparency=1,BorderSizePixel=0,ZIndex=4,
    })
    round(licenceCard,10)
    stroke(licenceCard,colors.edge,1,0.35)
    glyph(licenceCard,"keyboard",13,10,17,colors.blue)
    label(licenceCard,"licence key",11,colors.text,35,9,165,20,true)
    label(licenceCard,"saved on this device",9,colors.faint,314,9,115,20)
    make("Frame",licenceCard,{Position=UDim2.fromOffset(0,32),Size=UDim2.new(1,0,0,1),BackgroundColor3=colors.edge,BorderSizePixel=0,ZIndex=5})
    local input=make("TextBox",licenceCard,{
        Position=UDim2.fromOffset(10,42),Size=UDim2.new(1,-20,0,39),
        BackgroundColor3=colors.back,TextColor3=colors.text,PlaceholderColor3=colors.faint,
        PlaceholderText="Enter any key",Text="",TextSize=12,FontFace=fonts.medium,
        TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false,ZIndex=6,
    })
    round(input,7)
    stroke(input,colors.edge,1,0.35)
    make("UIPadding",input,{PaddingLeft=UDim.new(0,12)})
    local keyStatus=label(licenceCard,"any nonempty key works",10,colors.dim,14,88,400,19)
    local continue=button(pages.licence,"continue",18,145,444,45,colors.blue,colors.text)
    continue.TextSize=13
    round(continue,8)
    make("UIGradient",continue,{Color=ColorSequence.new(colors.blue,colors.blue2),Rotation=90})
    label(pages.licence,"press Enter to continue",10,colors.faint,147,203,200,18)

    local editionCards={}
    local editionData={
        {name="normal",accent=colors.blue,desc="the current beta",version="v1",available=true},
        {name="max",accent=colors.red,desc="coming soon",version="unavailable",available=false},
        {name="nightly",accent=colors.blue2,desc="coming soon",version="unavailable",available=false},
    }
    for index,data in ipairs(editionData) do
        local card=button(pages.edition,"",15+(index-1)*152,20,142,183,colors.card,colors.text)
        card.BackgroundTransparency=1
        stroke(card,data.accent,1,0.42)
        round(card,11)
        brandLogo(card,12,14,32,32)
        label(card,"plex.cc",15,colors.text,15,65,105,20,true)
        label(card,data.name,10,data.accent,15,85,112,19,true)
        label(card,data.desc,10,colors.dim,15,107,115,18)
        make("Frame",card,{Position=UDim2.fromOffset(15,143),Size=UDim2.fromOffset(112,1),BackgroundColor3=colors.edge,BorderSizePixel=0,ZIndex=7})
        label(card,data.version,9,colors.faint,15,150,90,18)
        label(card,data.available and "▶" or "—",14,data.available and data.accent or colors.faint,112,150,20,18,true)
        editionCards[data.name]=card
    end
    local editionHint=label(pages.edition,"normal is ready to launch",10,colors.dim,157,211,250,20)

    local downloadCard=make("Frame",pages.download,{
        Position=UDim2.fromOffset(18,23),Size=UDim2.new(1,-36,0,120),
        BackgroundColor3=colors.card,BackgroundTransparency=1,BorderSizePixel=0,ZIndex=4,
    })
    round(downloadCard,10)
    stroke(downloadCard,colors.edge,1,0.35)
    label(downloadCard,"↓  current build",12,colors.text,16,13,200,25,true)
    label(downloadCard,"Plex beta is ready. The script loads when you launch.",10,colors.dim,16,45,408,31)
    local downloadStatus=label(downloadCard,"waiting to launch",10,colors.green,16,93,270,17)
    local downloadNext=button(pages.download,"continue to launch",18,156,444,43,colors.blue,colors.text)
    round(downloadNext,8)

    local launchCard=make("Frame",pages.launch,{
        Position=UDim2.fromOffset(18,22),Size=UDim2.new(1,-36,0,116),
        BackgroundColor3=colors.card,BackgroundTransparency=1,BorderSizePixel=0,ZIndex=4,
    })
    round(launchCard,10)
    stroke(launchCard,colors.edge,1,0.35)
    label(launchCard,"▶  ready to launch",13,colors.text,16,16,250,25,true)
    label(launchCard,"plex.cc DEV · v1 · normal edition",10,colors.dim,16,51,389,22)
    local launchStatus=label(launchCard,"the loader will close when Plex starts",10,colors.faint,16,88,400,19)
    local launchButton=button(pages.launch,"launch Plex",18,151,444,46,colors.blue,colors.text)
    launchButton.TextSize=13
    round(launchButton,8)
    make("UIGradient",launchButton,{Color=ColorSequence.new(colors.blue,colors.blue2),Rotation=90})

    local function setPage(name)
        page=name
        for key,container in pairs(pages) do container.Visible=key==name end
        for key,row in pairs(nav) do
            local active=key==name
            row.BackgroundColor3=active and colors.blue or colors.side
            navText[key].TextColor3=active and colors.text or colors.dim
            ui.recolourIcon(navGlyphs[key],active and colors.text or colors.dim)
        end
        if name=="licence" then
            title.Text="sign in" subtitle.Text="enter a key to continue"
        elseif name=="edition" then
            title.Text="choose an edition" subtitle.Text="your key opens the current beta"
        elseif name=="download" then
            title.Text="download" subtitle.Text="current beta build"
        else
            title.Text="launch" subtitle.Text="ready when you are"
        end
    end
    local function validKey()
        local value=input.Text:match("^%s*(.-)%s*$")
        if value=="" then keyStatus.Text="enter a key first" keyStatus.TextColor3=colors.red return false end
        if getgenv then getgenv().PlexLoaderKey=value end
        if type(writefile)=="function" then
            pcall(function()
                if type(makefolder)=="function" and type(isfolder)=="function" and not isfolder("Overlay") then makefolder("Overlay") end
                writefile("Overlay/plex_loader_key.txt",value)
            end)
        end
        keyStatus.Text="key saved · ready to choose an edition"
        keyStatus.TextColor3=colors.green
        return true
    end
    local function launch()
        if running then return end
        if not validKey() then setPage("licence") return end
        running=true
        launchStatus.Text="loading Plex..."
        downloadStatus.Text="loading Plex..."
        local ok,script,errorMessage=pcall(options.getMain)
        if not ok or type(script)~="function" then
            running=false
            launchStatus.Text="load failed: "..tostring(errorMessage or script)
            downloadStatus.Text=launchStatus.Text
            return
        end
        if getgenv then getgenv().PlexLoaderEdition=chosen end
        gui:Destroy()
        for _,connection in ipairs(connections) do connection:Disconnect() end
        pcall(function() library:Unload() end)
        task.spawn(script)
    end

    connect(continue.MouseButton1Click,function() if validKey() then setPage("edition") end end)
    connect(downloadNext.MouseButton1Click,function() setPage("launch") end)
    connect(launchButton.MouseButton1Click,launch)
    connect(close.MouseButton1Click,function()
        gui:Destroy()
        for _,connection in ipairs(connections) do connection:Disconnect() end
        pcall(function() library:Unload() end)
    end)
    for name,row in pairs(nav) do
        connect(row.MouseButton1Click,function()
            if name~="licence" and not validKey() then setPage("licence") return end
            setPage(name)
        end)
    end
    for name,card in pairs(editionCards) do
        connect(card.MouseButton1Click,function()
            if name~="normal" then editionHint.Text=name.." is coming soon" return end
            chosen=name
            editionHint.Text="normal selected · ready to launch"
            setPage("download")
        end)
    end
    connect(UIS.InputBegan,function(inputEvent)
        if inputEvent.KeyCode==Enum.KeyCode.Return then
            if page=="licence" then if validKey() then setPage("edition") end
            elseif page=="edition" then setPage("download")
            elseif page=="download" then setPage("launch")
            else launch() end
        end
    end)
    if type(readfile)=="function" and type(isfile)=="function" then
        pcall(function()
            if isfile("Overlay/plex_loader_key.txt") then
                input.Text=readfile("Overlay/plex_loader_key.txt")
                if input.Text~="" then keyStatus.Text="saved key ready · press continue" end
            end
        end)
    end
    setPage("licence")
    local control={Gui=gui,KeyInput=input,GoTo=setPage,Launch=launch}
    function control:Unload()
        if gui.Parent then gui:Destroy() end
        for _,connection in ipairs(connections) do connection:Disconnect() end
        pcall(function() library:Unload() end)
    end
    if getgenv then getgenv().__PlexLoaderUI=control end
    return control
end
-- END PLEX LOADER WINDOW
function Library:RegisterExternalOption(id, object)
    options[id] = object
    cfg[id] = object.Value
    if object.Type == "Toggle" then self.Toggles[id] = object else self.Options[id] = object end
end
Library.ThemeManager,Library.SaveManager=themeManager,saveManager
return Library
