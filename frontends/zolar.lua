-- Zolar UI compatibility library for plex.cc.
-- Upstream visual library: https://github.com/Da7mu/Ui-Collection/tree/main/Zolar%20Ui
local vendorSource = [=======[
if getgenv().Zolar and getgenv().Zolar.Unload then
    getgenv().Zolar:Unload()
end

local Library = { } do
    local cloneref = cloneref or function(Object)
        return Object
    end

    local Players = cloneref(game:GetService("Players"))
    local UserInputService = cloneref(game:GetService("UserInputService"))
    local RunService = cloneref(game:GetService("RunService"))
    local TweenService = cloneref(game:GetService("TweenService"))
    local HttpService = cloneref(game:GetService("HttpService"))
    local GuiService = cloneref(game:GetService("GuiService"))
    local TextService = cloneref(game:GetService("TextService"))
    local StatsService = cloneref(game:GetService("Stats"))
    local MarketplaceService = cloneref(game:GetService("MarketplaceService"))
    local ContentProvider = cloneref(game:GetService("ContentProvider"))

    local LocalPlayer = Players.LocalPlayer
    local GuiInset = GuiService:GetGuiInset().Y
    local IsMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

    local GetHui = gethui or function()
        return cloneref(game:GetService("CoreGui"))
    end

    Library.Directory = "Zolar"
    Library.ConfigFolder = "Zolar/Configs"
    Library.AssetsFolder = "Zolar/Assets"

    if isfolder then
        for _, Folder in { Library.Directory, Library.ConfigFolder, Library.AssetsFolder } do
            if not isfolder(Folder) then
                makefolder(Folder)
            end
        end
    end

    local UiFont
    local UiFontBold

    local CustomFont = { } do
        local FontMagics = {
            "\0\1\0\0",
            "OTTO",
            "true",
            "ttcf",
            "wOFF"
        }

        local function LooksLikeFont(Body)
            if type(Body) ~= "string" or #Body < 4096 then
                return false
            end

            local Head = string.sub(Body, 1, 4)

            for _, Magic in FontMagics do
                if Head == Magic then
                    return true
                end
            end

            return false
        end

        function CustomFont:New(Name, Weight, Style, Data)
            local JsonPath = Library.AssetsFolder .. "/" .. Name .. ".json"
            local FontPath = Library.AssetsFolder .. "/" .. Name .. ".ttf"

            if isfile(FontPath) and not LooksLikeFont(readfile(FontPath)) then
                pcall(delfile, FontPath)
            end

            if not isfile(FontPath) then
                local Body = game:HttpGet(Data.Url)

                if not LooksLikeFont(Body) then
                    return nil
                end

                writefile(FontPath, Body)
            end

            local FontData = {
                name = Name,
                faces = {
                    {
                        name = "Regular",
                        weight = Weight,
                        style = Style,
                        assetId = getcustomasset(FontPath)
                    }
                }
            }

            writefile(JsonPath, HttpService:JSONEncode(FontData))

            local Asset = getcustomasset(JsonPath)
            return Font.new(Asset, Enum.FontWeight.Regular, Enum.FontStyle.Normal)
        end

        local MainOk, MainFont = pcall(function()
            return CustomFont:New("Inter", 400, "normal", {
                Url = "https://github.com/Da7mu/font/raw/refs/heads/main/Inter%20Medium%20500.ttf"
            })
        end)

        if not MainOk then warn(MainFont) end

        UiFont = (MainOk and MainFont) or Font.fromEnum(Enum.Font.GothamMedium)
        UiFontBold = UiFont
    end

    Library.Font = UiFont
    Library.TitleFont = UiFontBold

    local IconPack

    pcall(function()
        local Url = "https://raw.githubusercontent.com/Footagesus/Icons/main/Main-v2.lua"
        IconPack = loadstring(game:HttpGetAsync(Url))()
        IconPack.SetIconsType("lucide")
    end)

    local function ResolveIcon(Icon)
        if type(Icon) == "number" then
            return "rbxassetid://" .. Icon
        end

        if type(Icon) ~= "string" then
            return "rbxassetid://0"
        end

        if string.match(Icon, "^rbxassetid://") or string.match(Icon, "^rbxasset://") then
            return Icon
        end

        if string.match(Icon, "^%d+$") then
            return "rbxassetid://" .. Icon
        end

        if IconPack then
            local Ok, Result = pcall(function()
                return IconPack.GetIcon(Icon)
            end)

            if Ok and Result and Result ~= "rbxassetid://0" then
                return Result
            end
        end

        return "rbxassetid://0"
    end

    local function ToVector2(Value)
        if typeof(Value) == "Vector2" then
            return Value
        end

        if type(Value) == "table" then
            return Vector2.new(Value[1] or Value.X or 0, Value[2] or Value.Y or 0)
        end

        return Vector2.new(0, 0)
    end

    local function ApplyIcon(Object, Icon)
        if not Icon then return end

        local Image, Offset, Size = ResolveIcon(Icon)

        Object.Image = Image
        Object.ImageRectOffset = ToVector2(Offset)
        Object.ImageRectSize = ToVector2(Size)
    end

    local function MeasureText(Text, Size, Width, FontFace)
        local Ok, Bounds = pcall(function()
            return TextService:GetTextBoundsAsync({
                Text = Text,
                Font = FontFace or UiFont,
                Size = Size,
                Width = Width
            })
        end)

        if Ok and Bounds then
            return Bounds
        end

        local Estimate = math.min(#Text * Size * 0.52, Width)
        return Vector2.new(Estimate, Size * 1.25)
    end

    Library.__index = Library
    Library.Version = "1"
    Library.WindowWidth = 716
    Library.WindowHeight = 540

    Library.Theme = {
        Background = Color3.fromRGB(20, 22, 26),
        Section = Color3.fromRGB(23, 26, 30),
        Element = Color3.fromRGB(27, 31, 35),
        Light = Color3.fromRGB(34, 39, 44),
        Hover = Color3.fromRGB(38, 43, 49),
        Line = Color3.fromRGB(27, 31, 35),
        Text = Color3.fromRGB(255, 255, 255),
        DimText = Color3.fromRGB(120, 120, 120),
        DimIcon = Color3.fromRGB(120, 120, 120),
        Accent = Color3.fromRGB(73, 145, 255)
    }

    Library.AccentPresets = {
        Color3.fromRGB(179, 165, 255),
        Color3.fromRGB(120, 132, 255),
        Color3.fromRGB(96, 170, 255),
        Color3.fromRGB(72, 214, 168),
        Color3.fromRGB(245, 130, 120)
    }

    local function MakePreset(Name, Colors)
        local Preset = {
            Name = Name,
            Swatch = Colors.Accent
        }

        for Key, Value in Colors do
            Preset[Key] = Value
        end

        return Preset
    end

    Library.ThemePresets = {
        MakePreset("Default", Library.Theme),
        MakePreset("Azure", {
            Background = Color3.fromRGB(16, 20, 30),
            Section = Color3.fromRGB(20, 25, 37),
            Element = Color3.fromRGB(25, 31, 46),
            Light = Color3.fromRGB(33, 41, 60),
            Hover = Color3.fromRGB(39, 48, 70),
            Line = Color3.fromRGB(25, 31, 46),
            Text = Color3.fromRGB(233, 239, 250),
            DimText = Color3.fromRGB(110, 120, 142),
            DimIcon = Color3.fromRGB(110, 120, 142),
            Accent = Color3.fromRGB(96, 150, 255)
        }),
        MakePreset("Emerald", {
            Background = Color3.fromRGB(14, 24, 20),
            Section = Color3.fromRGB(18, 30, 25),
            Element = Color3.fromRGB(23, 37, 31),
            Light = Color3.fromRGB(30, 48, 40),
            Hover = Color3.fromRGB(36, 56, 47),
            Line = Color3.fromRGB(23, 37, 31),
            Text = Color3.fromRGB(232, 244, 238),
            DimText = Color3.fromRGB(106, 128, 118),
            DimIcon = Color3.fromRGB(106, 128, 118),
            Accent = Color3.fromRGB(76, 214, 148)
        }),
        MakePreset("Ocean", {
            Background = Color3.fromRGB(14, 23, 28),
            Section = Color3.fromRGB(18, 28, 34),
            Element = Color3.fromRGB(23, 35, 42),
            Light = Color3.fromRGB(30, 45, 54),
            Hover = Color3.fromRGB(36, 53, 63),
            Line = Color3.fromRGB(23, 35, 42),
            Text = Color3.fromRGB(230, 240, 244),
            DimText = Color3.fromRGB(104, 122, 132),
            DimIcon = Color3.fromRGB(104, 122, 132),
            Accent = Color3.fromRGB(72, 200, 214)
        }),
        MakePreset("Rose", {
            Background = Color3.fromRGB(26, 17, 21),
            Section = Color3.fromRGB(32, 21, 26),
            Element = Color3.fromRGB(39, 26, 32),
            Light = Color3.fromRGB(50, 33, 41),
            Hover = Color3.fromRGB(58, 39, 48),
            Line = Color3.fromRGB(39, 26, 32),
            Text = Color3.fromRGB(245, 234, 238),
            DimText = Color3.fromRGB(132, 110, 118),
            DimIcon = Color3.fromRGB(132, 110, 118),
            Accent = Color3.fromRGB(240, 118, 150)
        })
    }

    Library.ThemeKeys = {
        "Background",
        "Section",
        "Element",
        "Light",
        "Line",
        "Text",
        "DimText"
    }

    local function DeriveTheme()
        local T = Library.Theme

        T.AccentDark = T.Accent:Lerp(Color3.new(0, 0, 0), 0.44)
        T.AccentDeep = T.Accent:Lerp(Color3.new(0, 0, 0), 0.24)
        T.Ripple = T.Accent:Lerp(Color3.new(1, 1, 1), 0.12)
        T.AccentSoft = T.Accent:Lerp(T.Background, 0.72)
    end

    DeriveTheme()

    Library.Flags = { }
    Library.SetFlags = { }
    Library.Connections = { }
    Library.Threads = { }
    Library.ThemingStuff = { }
    Library.ThemeMap = { }
    Library.AccentGradients = { }
    Library.AccentShadows = { }
    Library.OpenFrames = { }
    Library.Windows = { }
    Library.Notifs = { }
    Library.TouchButtons = { }
    Library.TouchShields = { }
    Library.Searchables = { }
    Library.MenuKeybind = Enum.KeyCode.G
    Library.Binding = false
    Library.UserScale = 1
    Library.Silent = false
    Library.ThemeDirty = false
    Library.PreloadDirty = false
    Library.PreloadClock = 0
    Library.Preloaded = setmetatable({ }, { __mode = "k" })
    Library.Animation = {
        Time = 0.25,
        Style = Enum.EasingStyle.Quart,
        Direction = Enum.EasingDirection.Out
    }

    Library.Create = function(Self, Class, Properties)
        local Data = {
            Class = Class,
            Instance = Instance.new(Class)
        }

        for Property, Value in Properties do
            if Property == "Name" then
                Data.Instance.Name = "\0"
                continue
            end

            Data.Instance[Property] = Value
        end

        if Class == "ImageLabel" or Class == "ImageButton" then
            Library.PreloadDirty = true
        end

        if Library.SeedBaseline then
            Library:SeedBaseline(Data.Instance)
        end

        return setmetatable(Data, Library)
    end

    Library.PreloadAll = function(Self)
        local Roots = {
            Library.Holder,
            Library.PopupHolder,
            Library.UnusedHolder
        }

        local Assets = { }

        for _, Root in Roots do
            if not Root or not Root.Instance then continue end

            for _, Child in Root.Instance:GetDescendants() do
                if Library.Preloaded[Child] then continue end
                if not Child:IsA("ImageLabel") and not Child:IsA("ImageButton") then continue end
                if Child.Image == "" then continue end

                Library.Preloaded[Child] = true
                table.insert(Assets, Child)
            end
        end

        if #Assets == 0 then return end

        Library:Thread(function()
            pcall(function()
                ContentProvider:PreloadAsync(Assets)
            end)
        end)
    end

    Library.Connect = function(Self, Signal, Callback)
        local Connection

        if type(Signal) == "string" and Self.Instance then
            local IsClick = Signal == "MouseButton1Down" or Signal == "MouseButton1Click"

            if IsMobile and IsClick and Self.Instance:IsA("GuiButton") then
                local LastFire = 0

                local function Fire(Input)
                    local Now = os.clock()
                    if Now - LastFire < 0.25 then return end
                    LastFire = Now
                    Callback(Input)
                end

                table.insert(Library.TouchButtons, {
                    Instance = Self.Instance,
                    Fire = Fire
                })

                Connection = Self.Instance.Activated:Connect(function(Input)
                    Fire(Input)
                end)
            else
                Connection = Self.Instance[Signal]:Connect(Callback)
            end
        else
            Connection = Signal:Connect(Callback)
        end

        table.insert(Library.Connections, Connection)
        return Connection
    end

    Library.Thread = function(Self, Function)
        local NewThread = coroutine.create(Function)
        coroutine.resume(NewThread)
        table.insert(Library.Threads, NewThread)
        return NewThread
    end

    Library.SafeCall = function(Self, Function, ...)
        if type(Function) ~= "function" then return end

        local Success, Result = pcall(Function, ...)
        if not Success then warn(Result) end

        return Success, Result
    end

    Library.Round = function(Self, Number, Float)
        Float = Float or 1

        local Result = math.floor(Number / Float + 0.5) * Float
        local Places = math.max(0, math.ceil(-math.log(Float, 10)))

        return tonumber(string.format("%." .. Places .. "f", Result))
    end

    Library.Tween = function(Self, Properties, Info, RawItem)
        local Object = RawItem or Self.Instance

        Info = Info or TweenInfo.new(
            Library.Animation.Time,
            Library.Animation.Style,
            Library.Animation.Direction
        )

        local NewTween = TweenService:Create(Object, Info, Properties)
        NewTween:Play()

        return NewTween
    end

    Library.GetTweenProperty = function(Self, RawItem)
        local Object = RawItem or Self.Instance

        if Object:IsA("TextLabel") or Object:IsA("TextButton") or Object:IsA("TextBox") then
            return { "TextTransparency", "BackgroundTransparency" }
        elseif Object:IsA("ImageLabel") or Object:IsA("ImageButton") then
            return { "BackgroundTransparency", "ImageTransparency" }
        elseif Object:IsA("ScrollingFrame") then
            return { "BackgroundTransparency", "ScrollBarImageTransparency" }
        elseif Object:IsA("Frame") then
            return { "BackgroundTransparency" }
        elseif Object:IsA("UIStroke") then
            return { "Transparency" }
        elseif Object.ClassName == "UIShadow" then
            return { "Transparency" }
        end
    end

    Library.RestingValues = setmetatable({ }, { __mode = "k" })
    Library.Baselines = setmetatable({ }, { __mode = "k" })
    Library.FadeTokens = setmetatable({ }, { __mode = "k" })

    local function BumpFadeToken(Root)
        local Next = (Library.FadeTokens[Root] or 0) + 1
        Library.FadeTokens[Root] = Next
        return Next
    end

    local function CollectFadeable(Root)
        local Children = Root:GetDescendants()
        table.insert(Children, Root)
        return Children
    end

    local function ForEachFadeable(Children, Handler)
        for _, Child in Children do
            local Properties = Library:GetTweenProperty(Child)
            if not Properties then continue end

            for _, Property in Properties do
                Handler(Child, Property)
            end
        end
    end

    local function RestoreResting(Children)
        ForEachFadeable(Children, function(Child, Property)
            local Resting = Library:ReleaseResting(Child, Property)

            if Resting ~= nil then
                Child[Property] = Resting
            end
        end)
    end

    Library.SetBaseline = function(Self, Object, Property, Value)
        local Store = Library.Baselines[Object]

        if not Store then
            Store = { }
            Library.Baselines[Object] = Store
        end

        Store[Property] = Value
    end

    Library.SeedBaseline = function(Self, Object)
        local Properties = Library:GetTweenProperty(Object)
        if not Properties then return end

        for _, Property in Properties do
            local Store = Library.Baselines[Object]

            if not Store or Store[Property] == nil then
                Library:SetBaseline(Object, Property, Object[Property])
            end
        end
    end

    Library.CaptureResting = function(Self, Object, Property)
        local Store = Library.RestingValues[Object]

        if not Store then
            Store = { }
            Library.RestingValues[Object] = Store
        end

        if Store[Property] == nil then
            local Base = Library.Baselines[Object]
            local Known = Base and Base[Property]

            Store[Property] = Known ~= nil and Known or Object[Property]

            if Known == nil then
                Library:SetBaseline(Object, Property, Store[Property])
            end
        end

        return Store[Property]
    end

    Library.ReleaseResting = function(Self, Object, Property)
        local Store = Library.RestingValues[Object]
        if not Store then return nil end

        local Value = Store[Property]
        Store[Property] = nil

        return Value
    end

    Library.StampResting = function(Self, Object, Property, Value)
        local Store = Library.RestingValues[Object]

        if not Store then
            Store = { }
            Library.RestingValues[Object] = Store
        end

        Store[Property] = Value
        Library:SetBaseline(Object, Property, Value)
    end

    Library.HardRestore = function(Self)
        local Root = Self.Instance
        BumpFadeToken(Root)

        ForEachFadeable(CollectFadeable(Root), function(Child, Property)
            local Base = Library.Baselines[Child]
            if not Base then return end

            Library:ReleaseResting(Child, Property)

            if Base[Property] ~= nil then
                pcall(function()
                    Child[Property] = Base[Property]
                end)
            end
        end)
    end

    Library.Fade = function(Self, Property, Visibility, RawItem)
        local Object = RawItem or Self.Instance
        local Resting = Library:CaptureResting(Object, Property)
        local Target = Visibility and Resting or 1

        if Visibility then
            Object[Property] = 1
        end

        local Ok = pcall(function()
            Library:Tween({ [Property] = Target }, nil, Object)
        end)

        if not Ok then
            pcall(function()
                Object[Property] = Target
            end)
        end
    end

    Library.FadeDescendants = function(Self, Visibility, Callback)
        local Root = Self.Instance
        local Token = BumpFadeToken(Root)

        if Visibility then
            Root.Visible = true
        end

        local Children = CollectFadeable(Root)

        ForEachFadeable(Children, function(Child, Property)
            Library:Fade(Property, Visibility, Child)
        end)

        task.delay(Library.Animation.Time + 0.03, function()
            if Library.FadeTokens[Root] == Token then
                Root.Visible = Visibility
                RestoreResting(Children)
            end

            if Callback then Callback() end
        end)
    end

    Library.CancelFade = function(Self)
        BumpFadeToken(Self.Instance)
    end

    Library.ResetFade = function(Self)
        local Root = Self.Instance
        BumpFadeToken(Root)
        RestoreResting(CollectFadeable(Root))
    end

    Library.AddToTheme = function(Self, Properties)
        local Object = Self.Instance

        local ThemeData = {
            Item = Object,
            Properties = Properties
        }

        for Property, Value in Properties do
            if type(Value) == "string" then
                Object[Property] = Library.Theme[Value]
            else
                Object[Property] = Value()
            end
        end

        table.insert(Library.ThemingStuff, ThemeData)
        Library.ThemeMap[Object] = ThemeData

        return Self
    end

    Library.ChangeItemTheme = function(Self, Properties)
        local Object = Self.Instance
        if not Library.ThemeMap[Object] then return end
        Library.ThemeMap[Object].Properties = Properties
    end

    local function AccentSequence()
        return ColorSequence.new({
            ColorSequenceKeypoint.new(0, Library.Theme.Accent),
            ColorSequenceKeypoint.new(1, Library.Theme.AccentDark)
        })
    end

    Library.RegisterGradient = function(Self, Gradient)
        Gradient.Color = AccentSequence()
        table.insert(Library.AccentGradients, Gradient)
    end

    Library.ApplyThemeInstant = function(Self)
        for _, Item in Library.ThemingStuff do
            for Property, Value in Item.Properties do
                if type(Value) == "string" then
                    Item.Item[Property] = Library.Theme[Value]
                elseif type(Value) == "function" then
                    Item.Item[Property] = Value()
                end
            end
        end

        for _, Gradient in Library.AccentGradients do
            Gradient.Color = AccentSequence()
        end

        for _, Shadow in Library.AccentShadows do
            pcall(function()
                Shadow.Color = Library.Theme.Accent
            end)
        end
    end

    Library.SetAccent = function(Self, Color)
        Library.Theme.Accent = Color
        DeriveTheme()
        Library.ThemeDirty = true
    end

    Library.SetThemeColor = function(Self, Key, Color)
        Library.Theme[Key] = Color
        DeriveTheme()
        Library.ThemeDirty = true
    end

    Library.SetTheme = function(Self, Preset)
        if type(Preset) == "string" then
            for _, Entry in Library.ThemePresets do
                if Entry.Name == Preset then
                    Preset = Entry
                    break
                end
            end
        end

        if type(Preset) ~= "table" then return end

        for Key, Value in Preset do
            if Key ~= "Name" and Key ~= "Swatch" and typeof(Value) == "Color3" then
                Library.Theme[Key] = Value
            end
        end

        DeriveTheme()
        Library.ThemeDirty = true
    end

    Library.OnHover = function(Self, OnEnter, OnLeave)
        Library:Connect(Self.Instance.MouseEnter, OnEnter)
        Library:Connect(Self.Instance.MouseLeave, OnLeave)
    end

    Library.GetScreenScale = function(Self)
        if Library.UIScale and Library.UIScale.Instance then
            return Library.UIScale.Instance.Scale
        end

        return 1
    end

    local function IsOverObject(Object)
        local Position = UserInputService:GetMouseLocation() - Vector2.new(0, GuiInset)
        local Corner = Object.AbsolutePosition
        local Size = Object.AbsoluteSize

        return Position.X >= Corner.X
        and Position.X <= Corner.X + Size.X
        and Position.Y >= Corner.Y
        and Position.Y <= Corner.Y + Size.Y
    end

    Library.IsMouseOverFrame = function(Self)
        return IsOverObject(Self.Instance)
    end

    local function IsOverAnyPopup()
        for Panel in Library.TouchShields do
            if not Panel.Parent then continue end
            if not Panel.Visible then continue end
            if IsOverObject(Panel) then return true end
        end

        return false
    end

    Library.MakeDraggable = function(Self, Handle)
        local Gui = Self.Instance
        Handle = Handle or Gui
        Handle.Active = true

        local Dragging = false
        local DragStart
        local StartPosition
        local InputChanged

        local function Set(Input)
            local Scale = Library:GetScreenScale()
            local DragDelta = (Input.Position - DragStart) / Scale
            local NewX = StartPosition.X + DragDelta.X
            local NewY = StartPosition.Y + DragDelta.Y

            local ScreenSize = Gui.Parent.AbsoluteSize / Scale
            local GuiSize = Gui.AbsoluteSize / Scale
            local Anchor = Gui.AnchorPoint

            NewX = math.clamp(NewX, GuiSize.X * Anchor.X, ScreenSize.X - GuiSize.X * (1 - Anchor.X))
            NewY = math.clamp(NewY, GuiSize.Y * Anchor.Y, ScreenSize.Y - GuiSize.Y * (1 - Anchor.Y))

            local Info = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            Self:Tween({ Position = UDim2.fromOffset(NewX, NewY) }, Info)
        end

        Library:Connect(Handle.InputBegan, function(Input)
            local IsClick = Input.UserInputType == Enum.UserInputType.MouseButton1
            local IsTouch = Input.UserInputType == Enum.UserInputType.Touch

            if not IsClick and not IsTouch then return end
            if IsOverAnyPopup() then return end

            Dragging = true
            DragStart = Input.Position

            local Scale = Library:GetScreenScale()
            local ParentSize = Gui.Parent.AbsoluteSize / Scale

            StartPosition = Vector2.new(
                Gui.Position.X.Scale * ParentSize.X + Gui.Position.X.Offset,
                Gui.Position.Y.Scale * ParentSize.Y + Gui.Position.Y.Offset
            )

            if InputChanged then return end

            InputChanged = Input.Changed:Connect(function()
                if Input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                    InputChanged:Disconnect()
                    InputChanged = nil
                end
            end)
        end)

        Library:Connect(UserInputService.InputChanged, function(Input)
            local IsMove = Input.UserInputType == Enum.UserInputType.MouseMovement
            local IsTouch = Input.UserInputType == Enum.UserInputType.Touch

            if (IsMove or IsTouch) and Dragging then
                Set(Input)
            end
        end)
    end

    Library.Unload = function(Self)
        for _, Connection in Library.Connections do
            pcall(function()
                Connection:Disconnect()
            end)
        end

        for _, Thread in Library.Threads do
            pcall(coroutine.close, Thread)
        end

        for _, Root in { Library.Holder, Library.PopupHolder, Library.UnusedHolder } do
            if Root then Root.Instance:Destroy() end
        end

        getgenv().Zolar = nil
    end

    Library.Holder = Library:Create("ScreenGui", {
        Parent = GetHui(),
        Name = "\0",
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 1000
    })

    Library.PopupHolder = Library:Create("ScreenGui", {
        Parent = GetHui(),
        Name = "\0",
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 1001
    })

    Library.UnusedHolder = Library:Create("ScreenGui", {
        Parent = GetHui(),
        Name = "\0",
        Enabled = false,
        ResetOnSpawn = false
    })

    do
        local Probe = Library:Create("Frame", {
            Parent = Library.Holder.Instance,
            Name = "\0",
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(0, 0),
            Size = UDim2.fromOffset(1, 1),
            BorderSizePixel = 0
        })

        task.defer(function()
            GuiInset = -Probe.Instance.AbsolutePosition.Y
            Probe.Instance:Destroy()
        end)
    end

    Library.UIScale = Library:Create("UIScale", {
        Parent = Library.Holder.Instance,
        Scale = 1
    })

    Library.PopupScale = Library:Create("UIScale", {
        Parent = Library.PopupHolder.Instance,
        Scale = 1
    })

    local function Corner(Object, Radius)
        Library:Create("UICorner", {
            Parent = Object,
            CornerRadius = UDim.new(0, Radius)
        })
    end

    local function SetRest(Object, Property, Value)
        Object[Property] = Value
        Library:StampResting(Object, Property, Value)
    end

    local function MakeFrame(Params)
        local Frame = Library:Create(Params.Class or "Frame", {
            Parent = Params.Parent,
            Name = "\0",
            Position = Params.Pos or UDim2.fromOffset(0, 0),
            Size = Params.Size or UDim2.fromOffset(0, 0),
            AnchorPoint = Params.Anchor or Vector2.new(0, 0),
            BackgroundTransparency = Params.Color and 0 or 1,
            ZIndex = Params.Z or 1,
            ClipsDescendants = Params.Clip or false,
            BorderSizePixel = 0,
            BackgroundColor3 = Params.Color and Library.Theme[Params.Color] or Color3.new(1, 1, 1)
        })

        if Params.Color then
            Frame:AddToTheme({ BackgroundColor3 = Params.Color })
        end

        if Params.Raw then
            Frame.Instance.BackgroundColor3 = Params.Raw
            Frame.Instance.BackgroundTransparency = Params.Alpha or 0
            Library:SetBaseline(Frame.Instance, "BackgroundTransparency", Params.Alpha or 0)
        end

        if Params.Round then
            Corner(Frame.Instance, Params.Round)
        end

        return Frame
    end

    local function MakeText(Params)
        return Library:Create("TextLabel", {
            Parent = Params.Parent,
            Name = "\0",
            FontFace = Params.Bold and UiFontBold or UiFont,
            Text = Params.Text or "",
            TextSize = Params.TextSize or 15,
            TextColor3 = Library.Theme[Params.Color or "Text"],
            BackgroundTransparency = 1,
            Position = Params.Pos or UDim2.fromOffset(0, 0),
            Size = Params.Size or UDim2.fromOffset(0, 0),
            AnchorPoint = Params.Anchor or Vector2.new(0, 0),
            TextXAlignment = Params.Align or Enum.TextXAlignment.Left,
            TextTruncate = Params.Truncate and Enum.TextTruncate.AtEnd or Enum.TextTruncate.None,
            TextWrapped = Params.Wrap or false,
            ZIndex = Params.Z or 1,
            BorderSizePixel = 0
        }):AddToTheme({ TextColor3 = Params.Color or "Text" })
    end

    local function MakeImage(Params)
        local Raw = Params.Raw

        local Image = Library:Create("ImageLabel", {
            Parent = Params.Parent,
            Name = "\0",
            BackgroundTransparency = 1,
            ImageColor3 = Raw or Library.Theme[Params.Color or "DimIcon"],
            Position = Params.Pos or UDim2.fromOffset(0, 0),
            Size = Params.Size or UDim2.fromOffset(16, 16),
            AnchorPoint = Params.Anchor or Vector2.new(0, 0),
            ScaleType = Params.Fit and Enum.ScaleType.Fit or Enum.ScaleType.Stretch,
            ZIndex = Params.Z or 1,
            BorderSizePixel = 0
        })

        if not Raw then
            Image:AddToTheme({ ImageColor3 = Params.Color or "DimIcon" })
        end

        ApplyIcon(Image.Instance, Params.Icon)
        return Image
    end

    local function MakeButton(Params)
        return Library:Create("TextButton", {
            Parent = Params.Parent,
            Name = "\0",
            Text = "",
            AutoButtonColor = false,
            BackgroundTransparency = 1,
            Position = Params.Pos or UDim2.fromOffset(0, 0),
            Size = Params.Size or UDim2.new(1, 0, 1, 0),
            AnchorPoint = Params.Anchor or Vector2.new(0, 0),
            ZIndex = Params.Z or 5,
            BorderSizePixel = 0
        })
    end

    local function MakeInput(Params)
        local Input = Library:Create("TextBox", {
            Parent = Params.Parent,
            Name = "\0",
            FontFace = UiFont,
            TextColor3 = Library.Theme.Text,
            PlaceholderColor3 = Library.Theme.DimText,
            PlaceholderText = Params.Placeholder or "",
            Text = Params.Text or "",
            TextSize = Params.TextSize or 15,
            ClearTextOnFocus = false,
            CursorPosition = -1,
            BackgroundTransparency = 1,
            Position = Params.Pos or UDim2.fromOffset(0, 0),
            Size = Params.Size or UDim2.new(1, 0, 1, 0),
            TextXAlignment = Params.Align or Enum.TextXAlignment.Left,
            ZIndex = Params.Z or 6,
            BorderSizePixel = 0
        }):AddToTheme({
            TextColor3 = "Text",
            PlaceholderColor3 = "DimText"
        })

        if IsMobile then
            local Focus = MakeButton({
                Parent = Params.Parent,
                Pos = Params.Pos,
                Size = Params.Size or UDim2.new(1, 0, 1, 0),
                Z = (Params.Z or 6) + 2
            })

            Focus:Connect("MouseButton1Down", function()
                Input.Instance:CaptureFocus()
            end)
        end

        return Input
    end

    local function MakeShadow(Parent, Color, Spread, Blur, Transparency)
        local Ok, Shadow = pcall(function()
            local S = Instance.new("UIShadow")
            S.Name = "\0"
            S.Color = Color
            S.Spread = Spread
            S.BlurRadius = Blur
            S.Transparency = Transparency
            S.Parent = Parent
            return S
        end)

        if Ok and Shadow then
            Library:SetBaseline(Shadow, "Transparency", Transparency)
            return Shadow
        end

        return nil
    end

    local function MakeAccentShadow(Parent, Spread, Blur, Transparency)
        local Shadow = MakeShadow(Parent, Library.Theme.Accent, Spread, Blur, Transparency)

        if Shadow then
            table.insert(Library.AccentShadows, Shadow)
        end

        return Shadow
    end

    Library.DimCount = 0
    Library.Dims = { }

    for Index = 1, 3 do
        local Dim = Library:Create("Frame", {
            Parent = Library.UnusedHolder.Instance,
            Name = "\0",
            BackgroundColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 1,
            Visible = false,
            Position = UDim2.fromOffset(0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = Index == 3 and 28 or 15,
            BorderSizePixel = 0
        })

        Corner(Dim.Instance, 10)
        Library.Dims[Index] = Dim
    end

    Library.Dim = Library.Dims[1]

    Library.SetDim = function(Self, Bool)
        Library.DimCount = math.max(0, Library.DimCount + (Bool and 1 or -1))

        local Window = Library.Windows[1]
        if not Window then return end

        local Info = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local Shown = Library.DimCount > 0
        local Target = Shown and 0.55 or 1

        local Hosts = {
            Window.Items.Main.Instance,
            Window.Items.Rail.Instance,
            Window.Items.SubBar.Instance
        }

        for Index, Dim in Library.Dims do
            Library:StampResting(Dim.Instance, "BackgroundTransparency", Target)

            if Shown then
                Dim.Instance.Parent = Hosts[Index]
                Dim.Instance.Visible = true
            end

            Library:Tween({ BackgroundTransparency = Target }, Info, Dim.Instance)
        end

        if Shown then return end

        task.delay(0.28, function()
            if Library.DimCount > 0 then return end

            for _, Dim in Library.Dims do
                Dim.Instance.Visible = false
                Dim.Instance.Parent = Library.UnusedHolder.Instance
            end
        end)
    end

    Library.CloseAllPopups = function(Self)
        for _, Value in Library.OpenFrames do
            if Value.SetOpen then Value:SetOpen(false) end
        end
    end

    local function UpdateScale()
        local Scale = Library.UserScale

        if IsMobile and workspace.CurrentCamera then
            local Viewport = workspace.CurrentCamera.ViewportSize
            local FitX = (Viewport.X * 0.94) / Library.WindowWidth
            local FitY = (Viewport.Y * 0.9) / Library.WindowHeight
            Scale = Scale * math.clamp(math.min(FitX, FitY), 0.3, 1)
        end

        local Old = Library.UIScale.Instance.Scale
        local Centers = { }

        for Index, Window in Library.Windows do
            local Root = Window.Items and Window.Items.Root
            if not Root then continue end

            local Pos = Root.Instance.Position
            local Size = Root.Instance.Size

            Centers[Index] = Vector2.new(
                (Pos.X.Offset + Size.X.Offset / 2) * Old,
                (Pos.Y.Offset + Size.Y.Offset / 2) * Old
            )
        end

        Library.UIScale.Instance.Scale = Scale
        Library.PopupScale.Instance.Scale = Scale

        if IsMobile then
            for _, Window in Library.Windows do
                if Window.Center then Window:Center() end
            end

            return
        end

        local Viewport = workspace.CurrentCamera.ViewportSize

        for Index, Window in Library.Windows do
            local Root = Window.Items and Window.Items.Root
            local Center = Centers[Index]

            if not Root or not Center then continue end

            local Size = Root.Instance.Size
            local HalfX = Size.X.Offset / 2
            local HalfY = Size.Y.Offset / 2
            local LimitX = Viewport.X / Scale
            local LimitY = Viewport.Y / Scale

            local NewX = math.clamp(Center.X / Scale - HalfX, 0, math.max(LimitX - HalfX * 2, 0))
            local NewY = math.clamp(Center.Y / Scale - HalfY, 0, math.max(LimitY - HalfY * 2, 0))

            Root.Instance.Position = UDim2.fromOffset(NewX, NewY)
        end
    end

    Library.SetUIScale = function(Self, Multiplier)
        Library.UserScale = Multiplier
        Library:CloseAllPopups()
        UpdateScale()
    end

    UpdateScale()

    Library:Connect(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), function()
        task.wait()
        UpdateScale()
    end)

    local function PointInside(Position, Object)
        local Corner = Object.AbsolutePosition
        local Size = Object.AbsoluteSize

        return Position.X >= Corner.X
        and Position.X <= Corner.X + Size.X
        and Position.Y >= Corner.Y
        and Position.Y <= Corner.Y + Size.Y
    end

    do
        local TouchStart

        Library:Connect(UserInputService.InputBegan, function(Input)
            if Input.UserInputType == Enum.UserInputType.Touch then
                TouchStart = Input.Position
            end
        end)

        Library:Connect(UserInputService.InputEnded, function(Input)
            if not IsMobile then return end
            if Input.UserInputType ~= Enum.UserInputType.Touch then return end
            if not TouchStart then return end

            local Delta = Input.Position - TouchStart
            if math.abs(Delta.X) > 12 or math.abs(Delta.Y) > 12 then return end

            local Position = Input.Position
            local ShieldLevel = 0

            for Panel, Level in Library.TouchShields do
                local Live = Panel:IsDescendantOf(Library.Holder.Instance)
                or Panel:IsDescendantOf(Library.PopupHolder.Instance)

                if Live and PointInside(Position, Panel) then
                    ShieldLevel = math.max(ShieldLevel, Level)
                end
            end

            local Best

            for _, Data in Library.TouchButtons do
                local Object = Data.Instance
                if not Object or not Object.Visible then continue end
                if not PointInside(Position, Object) then continue end
                if Object.ZIndex < ShieldLevel then continue end

                if not Best or Object.ZIndex >= Best.Instance.ZIndex then
                    Best = Data
                end
            end

            if Best then Best.Fire(Input) end
        end)
    end

    local function AxisFraction(Input, Object, Axis)
        local Base = Object.AbsolutePosition[Axis]
        local Span = Object.AbsoluteSize[Axis]

        if Span == 0 then return 0 end

        return math.clamp((Input.Position[Axis] - Base) / Span, 0, 1)
    end

    local function AttachDrag(Hit, Handlers)
        local Watcher
        local Active = false

        Hit:Connect("InputBegan", function(Input)
            local IsClick = Input.UserInputType == Enum.UserInputType.MouseButton1
            local IsTouch = Input.UserInputType == Enum.UserInputType.Touch

            if not IsClick and not IsTouch then return end

            Active = true
            Handlers.OnGrab(Input)

            if Watcher then return end

            Watcher = Input.Changed:Connect(function()
                if Input.UserInputState ~= Enum.UserInputState.End then return end

                Active = false

                if Handlers.OnRelease then Handlers.OnRelease() end

                Watcher:Disconnect()
                Watcher = nil
            end)
        end)

        Library:Connect(UserInputService.InputChanged, function(Input)
            local IsMove = Input.UserInputType == Enum.UserInputType.MouseMovement
            local IsTouch = Input.UserInputType == Enum.UserInputType.Touch

            if (IsMove or IsTouch) and Active then
                Handlers.OnMove(Input)
            end
        end)
    end

    local function PlaceBelow(GetAnchor)
        return function(Extra)
            local Anchor = GetAnchor()
            local Scale = Library:GetScreenScale()
            local X = Anchor.AbsolutePosition.X / Scale
            local Y = Anchor.AbsolutePosition.Y + Anchor.AbsoluteSize.Y + GuiInset

            return UDim2.fromOffset(X, Y / Scale + (Extra or 0))
        end
    end

    local function PlaceBeside(GetAnchor)
        return function(Extra)
            local Anchor = GetAnchor()
            local Scale = Library:GetScreenScale()
            local Right = Anchor.AbsolutePosition.X + Anchor.AbsoluteSize.X
            local X = Right / Scale + 8
            local Y = (Anchor.AbsolutePosition.Y + GuiInset) / Scale

            return UDim2.fromOffset(X, Y + (Extra or 0))
        end
    end

    local function RetreatUp(Current)
        return UDim2.fromOffset(Current.X.Offset, Current.Y.Offset - 8)
    end

    local function RetreatLeft(Current)
        return UDim2.fromOffset(Current.X.Offset - 8, Current.Y.Offset)
    end

    local function AttachPopup(Config)
        local Popup = Config.Popup
        local Frame = Config.Frame
        local Level = Config.Level
        local Place = Config.Place
        local GetAnchor = Config.GetAnchor
        local From = Config.From or -6
        local To = Config.To or 6
        local Retreat = Config.Retreat or RetreatUp

        local KeepOpen = Config.KeepOpen or function(Value)
            return Value == Popup or Value == Popup.Host
        end

        function Popup:SetOpen(Bool)
            if Popup.Debounce then return end
            if Popup.IsOpen == Bool then return end

            Popup.IsOpen = Bool
            Popup.Debounce = true

            if Popup.OnState then Popup.OnState(Bool) end

            if Popup.Host and Popup.Host.SetChildDim then
                Popup.Host.SetChildDim(Bool)
            end

            if Bool then
                if Config.OnOpen then Config.OnOpen() end

                Frame.Instance.Parent = Library.PopupHolder.Instance
                Frame.Instance.Position = Place(From)
                Frame.Instance.Visible = true
                Library.TouchShields[Frame.Instance] = Level
                Library:SetDim(true)
                Frame:Tween({ Position = Place(To) })

                for _, Value in Library.OpenFrames do
                    if not KeepOpen(Value) then
                        Value:SetOpen(false)
                    end
                end

                Library.OpenFrames[Popup] = Popup

                Frame:FadeDescendants(true, function()
                    Popup.Debounce = false
                end)
            else
                if Config.OnClose then Config.OnClose() end

                Library.OpenFrames[Popup] = nil
                Library:SetDim(false)
                Frame:Tween({ Position = Retreat(Frame.Instance.Position) })

                Frame:FadeDescendants(false, function()
                    Popup.Debounce = false
                    if Popup.IsOpen then return end
                    Library.TouchShields[Frame.Instance] = nil
                    Frame.Instance.Parent = Library.UnusedHolder.Instance
                end)
            end
        end

        Library:Connect(UserInputService.InputBegan, function(Input)
            local IsClick = Input.UserInputType == Enum.UserInputType.MouseButton1
            local IsTouch = Input.UserInputType == Enum.UserInputType.Touch

            if not IsClick and not IsTouch then return end
            if not Popup.IsOpen then return end
            if Config.HoldOpen and Config.HoldOpen() then return end
            if Frame:IsMouseOverFrame() then return end
            if IsOverObject(GetAnchor()) then return end

            Popup:SetOpen(false)
        end)

        return Popup
    end

    local function MakeAccentRow(Params)
        local Z = Params.Z

        local Row = MakeFrame({
            Parent = Params.Parent,
            Pos = Params.Pos,
            Size = Params.Size,
            Color = Params.Color or "Section",
            Round = 5,
            Z = Z
        })

        SetRest(Row.Instance, "BackgroundTransparency", 1)

        local Line = MakeFrame({
            Parent = Row.Instance,
            Anchor = Vector2.new(0, 0.5),
            Pos = UDim2.new(0, Params.LineX, 0.5, 0),
            Size = UDim2.fromOffset(3, 0),
            Color = "Accent",
            Round = 4,
            Z = Z + 1
        })

        local Shadow = MakeAccentShadow(
            Line.Instance,
            UDim2.fromOffset(3, 15),
            UDim.new(0, 10),
            0
        )

        if Shadow then
            SetRest(Shadow, "Transparency", 1)
        end

        local Label = MakeText({
            Parent = Row.Instance,
            Text = Params.Text,
            TextSize = Params.TextSize,
            Pos = UDim2.fromOffset(Params.TextX, 0),
            Size = Params.LabelSize,
            Color = "DimText",
            Truncate = true,
            Z = Z + 1
        })

        local Hit = MakeButton({
            Parent = Row.Instance,
            Z = Z + 2
        })

        local function SetActive(Active, Instant)
            Library:StampResting(Row.Instance, "BackgroundTransparency", Active and 0 or 1)
            Label:ChangeItemTheme({ TextColor3 = Active and "Text" or "DimText" })

            local Info = Instant and TweenInfo.new(0) or nil
            local Color = Active and Library.Theme.Text or Library.Theme.DimText
            local TextX = Active and Params.TextActiveX or Params.TextX

            Library:Tween({ BackgroundTransparency = Active and 0 or 1 }, Info, Row.Instance)
            Library:Tween({ Size = UDim2.fromOffset(3, Active and Params.LineH or 0) }, Info, Line.Instance)
            Library:Tween({
                TextColor3 = Color,
                Position = UDim2.fromOffset(TextX, 0)
            }, Info, Label.Instance)

            if not Shadow then return end

            Library:StampResting(Shadow, "Transparency", Active and 0 or 1)

            if Params.SnapShadow or Instant then
                Shadow.Transparency = Active and 0 or 1
            else
                Library:Tween({ Transparency = Active and 0 or 1 }, Info, Shadow)
            end
        end

        return {
            Row = Row,
            Line = Line,
            Label = Label,
            Hit = Hit,
            Shadow = Shadow,
            SetActive = SetActive
        }
    end

    local function MakeOptionPopup(GetAnchor, Level, WidthOverride)
        Level = Level or 40

        local Popup = {
            IsOpen = false,
            Debounce = false,
            Order = { },
            Host = nil,
            OnPick = function() end
        }

        local Items = { }
        local RowHeight = 30
        local SearchHeight = 30

        Items.Frame = MakeFrame({
            Parent = Library.UnusedHolder.Instance,
            Size = UDim2.fromOffset(150, 0),
            Color = "Element",
            Round = 6,
            Clip = true,
            Z = Level
        })

        Items.Frame.Instance.Visible = false

        Items.SearchHolder = MakeFrame({
            Parent = Items.Frame.Instance,
            Size = UDim2.new(1, 0, 0, SearchHeight),
            Color = "Element",
            Z = Level + 5
        })

        Items.SearchHolder.Instance.Visible = false

        MakeImage({
            Parent = Items.SearchHolder.Instance,
            Icon = "search",
            Pos = UDim2.fromOffset(9, (SearchHeight - 13) / 2),
            Size = UDim2.fromOffset(13, 13),
            Color = "DimText",
            Z = Level + 7
        })

        Items.Search = MakeInput({
            Parent = Items.SearchHolder.Instance,
            Placeholder = "Search...",
            Pos = UDim2.fromOffset(27, 0),
            Size = UDim2.new(1, -32, 1, 0),
            TextSize = 14,
            Z = Level + 6
        })

        MakeFrame({
            Parent = Items.SearchHolder.Instance,
            Pos = UDim2.new(0, 6, 1, -1),
            Size = UDim2.new(1, -12, 0, 1),
            Color = "Line",
            Z = Level + 6
        })

        Items.Scroll = Library:Create("ScrollingFrame", {
            Parent = Items.Frame.Instance,
            Name = "\0",
            BackgroundTransparency = 1,
            ScrollBarThickness = 0,
            ScrollBarImageTransparency = 1,
            Selectable = false,
            Active = true,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            CanvasSize = UDim2.fromOffset(0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = Level + 4,
            BorderSizePixel = 0
        })

        Library:Create("UIListLayout", {
            Parent = Items.Scroll.Instance,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 3)
        })

        Library:Create("UIPadding", {
            Parent = Items.Scroll.Instance,
            PaddingTop = UDim.new(0, 4),
            PaddingBottom = UDim.new(0, 4),
            PaddingLeft = UDim.new(0, 4),
            PaddingRight = UDim.new(0, 4)
        })

        Popup.Items = Items

        local function ApplySearch(Query)
            Query = string.lower(Query)

            for _, Data in Popup.Order do
                local Match = Query == ""
                or string.find(string.lower(Data.Name), Query, 1, true) ~= nil

                Data.Row.Instance.Visible = Match
            end
        end

        Library:Connect(Items.Search.Instance:GetPropertyChangedSignal("Text"), function()
            ApplySearch(Items.Search.Instance.Text)
        end)

        function Popup:AddRow(Text, Image)
            local Built = MakeAccentRow({
                Parent = Items.Scroll.Instance,
                Size = UDim2.new(1, -4, 0, Image and 44 or RowHeight - 4),
                Text = Text,
                TextSize = 14,
                LabelSize = UDim2.new(1, Image and -58 or -20, 1, 0),
                LineX = 8,
                LineH = 16,
                TextX = Image and 48 or 11,
                TextActiveX = Image and 48 or 20,
                Z = Level + 1
            })
            if Image then
                local icon = Instance.new("ImageLabel")
                icon.Name, icon.Image = "ItemIcon", tostring(Image)
                icon.Size, icon.Position = UDim2.fromOffset(36, 36), UDim2.new(0, 8, 0.5, -18)
                icon.BackgroundTransparency, icon.ScaleType = 1, Enum.ScaleType.Fit
                icon.ZIndex, icon.Parent = Level + 2, Built.Row.Instance
            end

            local Data = {
                Name = Text,
                Selected = false,
                Row = Built.Row
            }

            function Data:Set(Active, Instant)
                Data.Selected = Active
                Built.SetActive(Active, Instant)
            end

            Built.Row:OnHover(function()
                if Data.Selected then return end
                Library:Tween({ BackgroundTransparency = 0.7 }, nil, Built.Row.Instance)
            end, function()
                if Data.Selected then return end
                Library:Tween({ BackgroundTransparency = 1 }, nil, Built.Row.Instance)
            end)

            Built.Hit:Connect("MouseButton1Down", function()
                Popup.OnPick(Data)
            end)

            table.insert(Popup.Order, Data)
            return Data
        end

        function Popup:Clear()
            for _, Data in Popup.Order do
                Data.Row.Instance:Destroy()
            end

            Popup.Order = { }
        end

        return AttachPopup({
            Popup = Popup,
            Frame = Items.Frame,
            Level = Level,
            GetAnchor = GetAnchor,
            Place = PlaceBelow(GetAnchor),
            OnOpen = function()
                local Anchor = GetAnchor()
                local Scale = Library:GetScreenScale()
                local ShowSearch = #Popup.Order > 8
                local Width = WidthOverride or (Anchor.AbsoluteSize.X / Scale)
                local ListHeight = math.min(#Popup.Order * RowHeight + 8, 168)

                Items.Search.Instance.Text = ""
                ApplySearch("")

                Items.SearchHolder.Instance.Visible = ShowSearch

                if ShowSearch then
                    Items.Scroll.Instance.Position = UDim2.fromOffset(0, SearchHeight)
                    Items.Scroll.Instance.Size = UDim2.new(1, 0, 1, -SearchHeight)
                    Items.Frame.Instance.Size = UDim2.fromOffset(Width, ListHeight + SearchHeight)
                else
                    Items.Scroll.Instance.Position = UDim2.fromOffset(0, 0)
                    Items.Scroll.Instance.Size = UDim2.new(1, 0, 1, 0)
                    Items.Frame.Instance.Size = UDim2.fromOffset(Width, ListHeight)
                end
            end,
            OnClose = function()
                Items.Search.Instance.Text = ""
            end
        })
    end

    local function MakeSwatch(Parent, RightOffset, Default, Z)
        local Swatch = { }
        local Base = Z or 3

        Swatch.Halo = MakeFrame({
            Parent = Parent,
            Anchor = Vector2.new(1, 0.5),
            Pos = UDim2.new(1, RightOffset, 0.5, 0),
            Size = UDim2.fromOffset(22, 22),
            Round = 20,
            Z = Base
        })

        Swatch.Halo.Instance.BackgroundColor3 = Default
        SetRest(Swatch.Halo.Instance, "BackgroundTransparency", 0.72)

        Swatch.Core = MakeFrame({
            Parent = Swatch.Halo.Instance,
            Anchor = Vector2.new(0.5, 0.5),
            Pos = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.fromOffset(12, 12),
            Raw = Default,
            Round = 20,
            Z = Base + 1
        })

        Swatch.Shadow = MakeShadow(
            Swatch.Core.Instance,
            Default,
            UDim2.fromOffset(0, 0),
            UDim.new(0, 6),
            0.35
        )

        Swatch.Hit = MakeButton({
            Parent = Swatch.Halo.Instance,
            Z = Base + 2
        })

        function Swatch:SetColor(Color, Alpha)
            Alpha = Alpha or 0

            Library:StampResting(Swatch.Core.Instance, "BackgroundTransparency", Alpha)
            Library:StampResting(Swatch.Halo.Instance, "BackgroundTransparency", 0.72)

            Swatch.Halo:Tween({ BackgroundColor3 = Color })
            Swatch.Core:Tween({
                BackgroundColor3 = Color,
                BackgroundTransparency = Alpha
            })

            if Swatch.Shadow then
                pcall(function()
                    Swatch.Shadow.Color = Color
                end)
            end
        end

        return Swatch
    end

    local function MakeColorPopup(GetAnchor, Title, Default, DefaultAlpha, OnChanged)
        local Picker = {
            Hue = 0,
            Saturation = 0,
            Value = 1,
            Transparency = DefaultAlpha or 0,
            Color = Color3.new(1, 1, 1),
            IsOpen = false,
            Debounce = false
        }

        local Items = { }
        local Level = 120
        local Field = 150
        local PanelW = Field + 32
        local CursorSize = 14
        local CursorThickness = 2

        Items.Window = MakeFrame({
            Parent = Library.UnusedHolder.Instance,
            Size = UDim2.fromOffset(PanelW, Field + 110),
            Color = "Section",
            Round = 8,
            Z = Level
        })

        Items.Window.Instance.Visible = false

        Items.Field = Library:Create("ImageButton", {
            Parent = Items.Window.Instance,
            Name = "\0",
            AutoButtonColor = false,
            BackgroundColor3 = Color3.fromRGB(255, 0, 0),
            Position = UDim2.fromOffset(16, 16),
            Size = UDim2.fromOffset(Field, Field),
            ZIndex = Level + 1,
            BorderSizePixel = 0
        })

        Corner(Items.Field.Instance, 8)

        Items.Tint = MakeFrame({
            Parent = Items.Field.Instance,
            Size = UDim2.new(1, 0, 1, 0),
            Raw = Color3.new(1, 1, 1),
            Round = 8,
            Z = Level + 2
        })

        Library:Create("UIGradient", {
            Parent = Items.Tint.Instance,
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(1, 1)
            })
        })

        Items.Shade = MakeFrame({
            Parent = Items.Field.Instance,
            Size = UDim2.new(1, 0, 1, 0),
            Raw = Color3.new(0, 0, 0),
            Round = 8,
            Z = Level + 3
        })

        Library:Create("UIGradient", {
            Parent = Items.Shade.Instance,
            Rotation = 90,
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(1, 0)
            })
        })

        local function MakeCursor(Parent, Pos, Z)
            local Cursor = MakeFrame({
                Parent = Parent,
                Anchor = Vector2.new(0.5, 0.5),
                Pos = Pos,
                Size = UDim2.fromOffset(CursorSize, CursorSize),
                Raw = Color3.new(1, 1, 1),
                Alpha = 1,
                Round = 20,
                Z = Z
            })

            Library:Create("UIStroke", {
                Parent = Cursor.Instance,
                Color = Color3.new(1, 1, 1),
                Thickness = CursorThickness
            })

            return Cursor
        end

        Items.FieldCursor = MakeCursor(
            Items.Field.Instance,
            UDim2.new(0.5, 0, 0.5, 0),
            Level + 4
        )

        local function MakeBar(Y)
            local Bar = Library:Create("ImageButton", {
                Parent = Items.Window.Instance,
                Name = "\0",
                AutoButtonColor = false,
                Position = UDim2.fromOffset(16, Y),
                Size = UDim2.fromOffset(Field, 10),
                ZIndex = Level + 1,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.new(1, 1, 1)
            })

            Corner(Bar.Instance, 5)

            local Cursor = MakeCursor(
                Bar.Instance,
                UDim2.new(1, 0, 0.5, 0),
                Level + 3
            )

            return Bar, Cursor
        end

        Items.HueBar, Items.HueCursor = MakeBar(Field + 30)

        Library:Create("UIGradient", {
            Parent = Items.HueBar.Instance,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
            })
        })

        Items.AlphaBar, Items.AlphaCursor = MakeBar(Field + 50)

        local AlphaGradient = Library:Create("UIGradient", {
            Parent = Items.AlphaBar.Instance,
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(1, 1)
            })
        })

        Items.Hex = MakeFrame({
            Parent = Items.Window.Instance,
            Pos = UDim2.fromOffset(16, Field + 72),
            Size = UDim2.fromOffset(Field, 26),
            Color = "Element",
            Round = 5,
            Clip = true,
            Z = Level + 1
        })

        Items.HexInput = MakeInput({
            Parent = Items.Hex.Instance,
            Text = "#FFFFFF",
            Placeholder = "#FFFFFF",
            Pos = UDim2.fromOffset(9, 0),
            Size = UDim2.new(1, -18, 1, 0),
            TextSize = 14,
            Z = Level + 2
        })

        local Grabbing = nil
        local SlideInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

        local function Refresh(Instant)
            Picker.Color = Color3.fromHSV(Picker.Hue, Picker.Saturation, Picker.Value)

            local Pure = Color3.fromHSV(Picker.Hue, 1, 1)
            local Info = Instant and TweenInfo.new(0) or SlideInfo

            AlphaGradient.Instance.Color = ColorSequence.new(Picker.Color)
            Library:Tween({ BackgroundColor3 = Pure }, Info, Items.Field.Instance)

            Library:Tween({
                Position = UDim2.new(Picker.Saturation, 0, 1 - Picker.Value, 0)
            }, Info, Items.FieldCursor.Instance)

            Library:Tween({ Position = UDim2.new(Picker.Hue, 0, 0.5, 0) }, Info, Items.HueCursor.Instance)
            Library:Tween({ Position = UDim2.new(Picker.Transparency, 0, 0.5, 0) }, Info, Items.AlphaCursor.Instance)

            if not Items.HexInput.Instance:IsFocused() then
                Items.HexInput.Instance.Text = "#" .. string.upper(Picker.Color:ToHex())
            end

            Library:SafeCall(OnChanged, Picker.Color, Picker.Transparency)
        end

        function Picker:Set(Color, Alpha, Silent)
            if type(Color) == "table" then
                Color = Color3.fromRGB(Color[1], Color[2], Color[3])
            end

            if type(Color) == "string" then
                Color = Color3.fromHex(Color)
            end

            Picker.Hue, Picker.Saturation, Picker.Value = Color:ToHSV()
            Picker.Transparency = Alpha or Picker.Transparency or 0

            if Silent then
                Picker.Color = Color3.fromHSV(Picker.Hue, Picker.Saturation, Picker.Value)
                return
            end

            Refresh(true)
        end

        local function Slide(Input)
            if Grabbing == "Field" then
                Picker.Saturation = AxisFraction(Input, Items.Field.Instance, "X")
                Picker.Value = 1 - AxisFraction(Input, Items.Field.Instance, "Y")
            elseif Grabbing == "Hue" then
                Picker.Hue = AxisFraction(Input, Items.HueBar.Instance, "X")
            elseif Grabbing == "Alpha" then
                Picker.Transparency = AxisFraction(Input, Items.AlphaBar.Instance, "X")
            else
                return
            end

            Refresh()
        end

        local function Grabber(Object, Mode)
            local Watcher

            Library:Connect(Object.InputBegan, function(Input)
                local IsClick = Input.UserInputType == Enum.UserInputType.MouseButton1
                local IsTouch = Input.UserInputType == Enum.UserInputType.Touch

                if not IsClick and not IsTouch then return end

                Grabbing = Mode
                Slide(Input)

                if Watcher then return end

                Watcher = Input.Changed:Connect(function()
                    if Input.UserInputState == Enum.UserInputState.End then
                        if Grabbing == Mode then Grabbing = nil end
                        Watcher:Disconnect()
                        Watcher = nil
                    end
                end)
            end)
        end

        Grabber(Items.Field.Instance, "Field")
        Grabber(Items.HueBar.Instance, "Hue")
        Grabber(Items.AlphaBar.Instance, "Alpha")

        Library:Connect(UserInputService.InputChanged, function(Input)
            local IsMove = Input.UserInputType == Enum.UserInputType.MouseMovement
            local IsTouch = Input.UserInputType == Enum.UserInputType.Touch

            if (IsMove or IsTouch) and Grabbing then
                Slide(Input)
            end
        end)

        Items.HexInput:Connect("FocusLost", function()
            local Text = string.gsub(Items.HexInput.Instance.Text, "#", "")

            local Ok, Color = pcall(function()
                return Color3.fromHex(Text)
            end)

            if Ok and Color then
                Picker:Set(Color, Picker.Transparency)
            else
                Refresh(true)
            end
        end)

        AttachPopup({
            Popup = Picker,
            Frame = Items.Window,
            Level = Level,
            GetAnchor = GetAnchor,
            Place = PlaceBeside(GetAnchor)
        })

        Picker:Set(Default or Library.Theme.Accent, Picker.Transparency)
        return Picker
    end

    local function KeyName(Key)
        if not Key then return "None" end

        local Text = tostring(Key)
        Text = string.gsub(Text, "Enum.KeyCode.", "")
        Text = string.gsub(Text, "Enum.UserInputType.", "")

        return Text
    end

    local function ParseKey(Value)
        if type(Value) ~= "string" or Value == "None" then
            return nil
        end

        local Name = string.gsub(Value, "Enum.KeyCode.", "")
        Name = string.gsub(Name, "Enum.UserInputType.", "")

        local Ok, Key = pcall(function()
            return Enum.KeyCode[Name]
        end)

        if Ok and Key then return Key end

        return nil
    end

    local function CaptureKey(State, Display, OnPicked)
        if State.Picking then return end

        State.Picking = true
        Library.Binding = true
        Display.Text = ". . ."

        task.wait()

        local Connection

        Connection = UserInputService.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseMovement then return end

            Connection:Disconnect()

            local IsBack = Input.KeyCode == Enum.KeyCode.Backspace
            local IsEsc = Input.KeyCode == Enum.KeyCode.Escape

            if IsBack or IsEsc then
                OnPicked(nil)
            elseif Input.UserInputType == Enum.UserInputType.Keyboard then
                OnPicked(Input.KeyCode)
            else
                OnPicked(Input.UserInputType)
            end

            task.defer(function()
                Library.Binding = false
            end)
        end)
    end

    local function KeyMatches(Input, Key)
        return Input.KeyCode == Key or Input.UserInputType == Key
    end

    Library.Notification = function(Self, Params)
        if Library.Silent then return end

        Params = Params or { }

        local Title = Params.Name or Params.Title or "Notification"
        local Content = Params.Description or Params.Content or ""
        local Icon = Params.Icon or "bell"
        local Accent = Params.Color or Library.Theme.Accent
        local Duration = Params.Duration or 5

        local CardW = 300
        local Bounds = Vector2.new(0, 0)

        if Content ~= "" then
            Bounds = MeasureText(Content, 14, CardW - 26, UiFont)
        end

        local CardH = 38 + (Content ~= "" and Bounds.Y + 6 or 0) + 18
        local Items = { }

        Items.Frame = MakeFrame({
            Parent = Library.Holder.Instance,
            Anchor = Vector2.new(1, 0),
            Pos = UDim2.new(1, 340, 0, 15),
            Size = UDim2.fromOffset(CardW, CardH),
            Color = "Section",
            Round = 10,
            Z = 80
        })

        Items.Icon = MakeImage({
            Parent = Items.Frame.Instance,
            Icon = Icon,
            Pos = UDim2.fromOffset(13, 11),
            Size = UDim2.fromOffset(18, 18),
            Raw = Accent,
            Z = 81
        })

        Items.Title = MakeText({
            Parent = Items.Frame.Instance,
            Text = Title,
            TextSize = 15,
            Pos = UDim2.fromOffset(40, 10),
            Size = UDim2.new(1, -70, 0, 20),
            Color = "Text",
            Truncate = true,
            Z = 81
        })

        Items.Close = MakeImage({
            Parent = Items.Frame.Instance,
            Icon = "x",
            Anchor = Vector2.new(1, 0),
            Pos = UDim2.new(1, -13, 0, 13),
            Size = UDim2.fromOffset(14, 14),
            Color = "DimText",
            Z = 82
        })

        Items.CloseHit = MakeButton({
            Parent = Items.Frame.Instance,
            Anchor = Vector2.new(1, 0),
            Pos = UDim2.new(1, -8, 0, 8),
            Size = UDim2.fromOffset(24, 24),
            Z = 83
        })

        if Content ~= "" then
            Items.Body = MakeText({
                Parent = Items.Frame.Instance,
                Text = Content,
                TextSize = 14,
                Pos = UDim2.fromOffset(13, 35),
                Size = UDim2.new(1, -26, 0, Bounds.Y),
                Color = "DimText",
                Wrap = true,
                Z = 81
            })

            Items.Body.Instance.TextYAlignment = Enum.TextYAlignment.Top
        end

        Items.BarBack = MakeFrame({
            Parent = Items.Frame.Instance,
            Pos = UDim2.new(0, 13, 1, -12),
            Size = UDim2.new(1, -26, 0, 5),
            Color = "Element",
            Round = 4,
            Z = 81
        })

        Items.BarFill = MakeFrame({
            Parent = Items.BarBack.Instance,
            Size = UDim2.new(1, 0, 1, 0),
            Raw = Color3.new(1, 1, 1),
            Round = 4,
            Z = 82
        })

        Library:RegisterGradient(Library:Create("UIGradient", {
            Parent = Items.BarFill.Instance
        }).Instance)

        local Notif = {
            Items = Items,
            Dead = false,
            Height = CardH
        }

        table.insert(Library.Notifs, Notif)

        local function StackHeight(Stop)
            local Y = 15

            for _, Value in Library.Notifs do
                if Value == Stop then break end
                if Value.Dead then continue end

                Y += Value.Height + 10
            end

            return Y
        end

        local function Reflow()
            local Info = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            local Y = 15

            for _, Value in Library.Notifs do
                if Value.Dead then continue end

                Library:Tween({ Position = UDim2.new(1, -15, 0, Y) }, Info, Value.Items.Frame.Instance)
                Y += Value.Height + 10
            end
        end

        local StartY = StackHeight(Notif)
        local SlideIn = TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

        Items.Frame.Instance.Position = UDim2.new(1, 340, 0, StartY)
        Items.Frame:Tween({ Position = UDim2.new(1, -15, 0, StartY) }, SlideIn)

        local function Dismiss()
            if Notif.Dead then return end
            Notif.Dead = true

            local Fade = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            local Current = Items.Frame.Instance.Position
            local Lift = UDim2.new(1, -15, 0, Current.Y.Offset - 14)

            Library:Tween({ Position = Lift }, Fade, Items.Frame.Instance)
            Items.Frame:FadeDescendants(false)

            task.delay(0.3, function()
                local Index = table.find(Library.Notifs, Notif)
                if Index then table.remove(Library.Notifs, Index) end

                Items.Frame.Instance:Destroy()
                Reflow()
            end)
        end

        Items.CloseHit:Connect("MouseButton1Down", Dismiss)

        local Countdown = TweenInfo.new(Duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        Library:Tween({ Size = UDim2.new(0, 0, 1, 0) }, Countdown, Items.BarFill.Instance)

        task.delay(Duration, Dismiss)
    end

    Library.Window = function(Self, Params)
        Params = Params or { }

        local W = Library.WindowWidth
        local H = Library.WindowHeight
        local TopH = 51
        local Gap = 10
        local RailW = 60
        local RailH = 340
        local SubW = 260
        local SubH = 50
        local MainX = RailW + Gap
        local RailY = math.floor((H - RailH) / 2)
        local SubX = MainX + math.floor((W - SubW) / 2)
        local SubY = H - math.floor(SubH / 2)
        local RootW = MainX + W
        local RootH = SubY + SubH
        local ColW = math.floor((W - 46) / 2)
        local Col2X = ColW + 16
        local SubCenterX = MainX + math.floor(W / 2)
        local MaxSubW = W - 120

        local Window = {
            Name = Params.Name or "ZOLAR",
            Icon = Params.Icon or "layers",
            IsOpen = true,
            Tabs = { },
            Current = nil,
            ContentW = W - 30,
            ContentH = H - 96,
            ColW = ColW,
            Col2X = Col2X,
            Items = { }
        }

        if Params.Accent then
            Library:SetAccent(Params.Accent)
        end

        local Items = { }
        local Viewport = workspace.CurrentCamera.ViewportSize
        local Scale = Library:GetScreenScale()

        Items.Root = MakeFrame({
            Parent = Library.Holder.Instance,
            Pos = UDim2.fromOffset(
                Viewport.X / (2 * Scale) - RootW / 2,
                Viewport.Y / (2 * Scale) - RootH / 2
            ),
            Size = UDim2.fromOffset(RootW, RootH),
            Z = 1
        })

        Items.Main = MakeFrame({
            Parent = Items.Root.Instance,
            Pos = UDim2.fromOffset(MainX, 0),
            Size = UDim2.fromOffset(W, H),
            Color = "Background",
            Round = 10,
            Clip = true,
            Z = 1
        })

        Items.Rail = MakeFrame({
            Class = "ScrollingFrame",
            Parent = Items.Root.Instance,
            Pos = UDim2.fromOffset(0, RailY),
            Size = UDim2.fromOffset(RailW, RailH),
            Color = "Section",
            Round = 10,
            Z = 1
        })

        Items.Rail.Instance.ScrollBarThickness = 2
        Items.Rail.Instance.ScrollBarImageColor3 = Library.Theme.Accent
        Items.Rail.Instance.ScrollingDirection = Enum.ScrollingDirection.Y
        Items.Rail.Instance.CanvasSize = UDim2.fromOffset(0, 0)
        Items.Rail.Instance.ClipsDescendants = true

        Items.SubBar = MakeFrame({
            Parent = Items.Root.Instance,
            Pos = UDim2.fromOffset(SubX, SubY),
            Size = UDim2.fromOffset(SubW, SubH),
            Color = "Section",
            Round = 10,
            Clip = true,
            Z = 20
        })

        Items.TopBar = MakeFrame({
            Parent = Items.Main.Instance,
            Size = UDim2.fromOffset(W, TopH),
            Color = "Section",
            Round = 10,
            Z = 2
        })

        MakeFrame({
            Parent = Items.TopBar.Instance,
            Pos = UDim2.fromOffset(0, TopH - 12),
            Size = UDim2.fromOffset(W, 12),
            Color = "Section",
            Z = 2
        })

        Items.TopLine = MakeFrame({
            Parent = Items.Main.Instance,
            Pos = UDim2.fromOffset(0, 50),
            Size = UDim2.fromOffset(W, 1),
            Color = "Element",
            Z = 3
        })

        Items.HubIcon = MakeImage({
            Parent = Items.TopBar.Instance,
            Icon = Window.Icon,
            Pos = UDim2.fromOffset(10, 10),
            Size = UDim2.fromOffset(30, 30),
            Raw = Color3.new(1, 1, 1),
            Fit = true,
            Z = 3
        })

        Items.Search = MakeFrame({
            Parent = Items.TopBar.Instance,
            Pos = UDim2.new(1,-388,0,7),
            Size = UDim2.fromOffset(136, 26),
            Color = "Element",
            Round = 5,
            Z = 3
        })

        MakeImage({
            Parent = Items.Search.Instance,
            Icon = "search",
            Pos = UDim2.fromOffset(7, 7),
            Size = UDim2.fromOffset(16, 16),
            Color = "DimText",
            Z = 4
        })

        Items.Breadcrumb=MakeText({Parent=Items.TopBar.Instance,Text="",TextSize=11,
            Pos=UDim2.fromOffset(50,30),Size=UDim2.new(1,-230,0,16),Color="DimText",Truncate=true,Z=4})
        Items.Breadcrumb.Instance.Name="PlexBreadcrumb"
        function Window:UpdateBreadcrumb(Tab,Sub)
            if Tab then Items.Breadcrumb.Instance.Text=string.lower((Tab.Category or "Other").." / "..Tab.Name.." / "..(Sub and Sub.Name or "")) end
        end

        Items.SearchBox = MakeInput({
            Parent = Items.Search.Instance,
            Placeholder = "search",
            Pos = UDim2.fromOffset(30, -1),
            Size = UDim2.new(1, -38, 1, 0),
            TextSize = 15,
            Z = 4
        })

        Items.Username = MakeText({
            Parent = Items.TopBar.Instance,
            Text = LocalPlayer.DisplayName,
            TextSize = 15,
            Anchor = Vector2.new(1, 0),
            Pos = UDim2.new(1, -56, 0, 8),
            Size = UDim2.fromOffset(180, 18),
            Color = "Text",
            Align = Enum.TextXAlignment.Right,
            Truncate = true,
            Z = 3
        })

        Items.Version = MakeFrame({
            Parent = Items.TopBar.Instance,
            Anchor = Vector2.new(1, 0),
            Pos = UDim2.new(1, -56, 0, 29),
            Size = UDim2.fromOffset(108, 16),
            Color = "Background",
            Round = 3,
            Z = 3
        })

        Library:Create("UIStroke", {
            Parent = Items.Version.Instance,
            Color = Library.Theme.Element,
            Thickness = 1
        }):AddToTheme({ Color = "Element" })

        MakeText({
            Parent = Items.Version.Instance,
            Text = "DEV BUILD  ·  v" .. Library.Version,
            TextSize = 12,
            Size = UDim2.new(1, 0, 1, 0),
            Color = "DimText",
            Align = Enum.TextXAlignment.Center,
            Z = 4
        })

        local function MakeAvatar(Parent, Props)
            local Avatar = Library:Create("ImageLabel", {
                Parent = Parent,
                Name = "\0",
                AnchorPoint = Props.Anchor or Vector2.new(0, 0),
                Position = Props.Pos,
                Size = UDim2.fromOffset(Props.Size, Props.Size),
                BackgroundColor3 = Library.Theme.Element,
                ZIndex = Props.Z,
                BorderSizePixel = 0,
                Image = "rbxthumb://type=AvatarHeadShot&id="
                .. LocalPlayer.UserId
                .. "&w=" .. Props.Res .. "&h=" .. Props.Res
            }):AddToTheme({ BackgroundColor3 = "Element" })

            Corner(Avatar.Instance, Props.Round)
            return Avatar
        end

        Items.Avatar = MakeAvatar(Items.TopBar.Instance, {
            Anchor = Vector2.new(1, 0.5),
            Pos = UDim2.new(1, -10, 0.5, 0),
            Size = 30,
            Res = 60,
            Round = 20,
            Z = 3
        })

        Items.ProfileHit = MakeButton({
            Parent = Items.TopBar.Instance,
            Anchor = Vector2.new(1, 0),
            Pos = UDim2.new(1, -4, 0, 8),
            Size = UDim2.fromOffset(42, 36),
            Z = 5
        })

        local Profile = {
            IsOpen = false,
            Debounce = false
        }

        local ProfileW = 240

        local ProfilePanel = MakeFrame({
            Parent = Library.UnusedHolder.Instance,
            Size = UDim2.fromOffset(ProfileW, 272),
            Color = "Section",
            Round = 10,
            Z = 45
        })

        ProfilePanel.Instance.Visible = false

        MakeAvatar(ProfilePanel.Instance, {
            Pos = UDim2.fromOffset(14, 14),
            Size = 42,
            Res = 100,
            Round = 21,
            Z = 46
        })

        MakeText({
            Parent = ProfilePanel.Instance,
            Text = LocalPlayer.DisplayName,
            TextSize = 15,
            Pos = UDim2.fromOffset(68, 16),
            Size = UDim2.fromOffset(ProfileW - 82, 20),
            Color = "Text",
            Truncate = true,
            Z = 46
        })

        MakeText({
            Parent = ProfilePanel.Instance,
            Text = "@" .. LocalPlayer.Name,
            TextSize = 13,
            Pos = UDim2.fromOffset(68, 37),
            Size = UDim2.fromOffset(ProfileW - 82, 16),
            Color = "DimText",
            Truncate = true,
            Z = 46
        })

        local function ProfileDivider(Y)
            MakeFrame({
                Parent = ProfilePanel.Instance,
                Pos = UDim2.fromOffset(14, Y),
                Size = UDim2.fromOffset(ProfileW - 28, 1),
                Color = "Element",
                Z = 46
            })
        end

        local function ProfileStat(Y, Label, Value)
            MakeText({
                Parent = ProfilePanel.Instance,
                Text = Label,
                TextSize = 14,
                Pos = UDim2.fromOffset(14, Y),
                Size = UDim2.fromOffset(100, 18),
                Color = "DimText",
                Z = 46
            })

            MakeText({
                Parent = ProfilePanel.Instance,
                Text = Value,
                TextSize = 14,
                Anchor = Vector2.new(1, 0),
                Pos = UDim2.new(1, -14, 0, Y),
                Size = UDim2.fromOffset(120, 18),
                Color = "Text",
                Align = Enum.TextXAlignment.Right,
                Truncate = true,
                Z = 46
            })
        end

        ProfileDivider(68)
        ProfileStat(79, "User ID", tostring(LocalPlayer.UserId))
        ProfileStat(105, "Account age", tostring(LocalPlayer.AccountAge) .. " days")

        local IdHit = MakeButton({
            Parent = ProfilePanel.Instance,
            Pos = UDim2.fromOffset(10, 76),
            Size = UDim2.fromOffset(ProfileW - 20, 24),
            Z = 47
        })

        IdHit:Connect("MouseButton1Down", function()
            if setclipboard then
                pcall(setclipboard, tostring(LocalPlayer.UserId))
            end

            Library:Notification({
                Name = "User ID copied",
                Description = "Your user id is now in the clipboard.",
                Icon = "copy",
                Duration = 3
            })
        end)

        local RefreshProfilePos

        ProfileDivider(134)

        MakeText({
            Parent = ProfilePanel.Instance,
            Text = "Interface scale",
            TextSize = 14,
            Pos = UDim2.fromOffset(14, 146),
            Size = UDim2.fromOffset(140, 18),
            Color = "DimText",
            Z = 46
        })

        local ScaleValue = MakeText({
            Parent = ProfilePanel.Instance,
            Text = "100%",
            TextSize = 14,
            Anchor = Vector2.new(1, 0),
            Pos = UDim2.new(1, -14, 0, 146),
            Size = UDim2.fromOffset(60, 18),
            Color = "Text",
            Align = Enum.TextXAlignment.Right,
            Z = 46
        })

        local ScaleTrack = MakeFrame({
            Parent = ProfilePanel.Instance,
            Pos = UDim2.fromOffset(14, 172),
            Size = UDim2.fromOffset(ProfileW - 28, 8),
            Color = "Light",
            Round = 20,
            Z = 46
        })

        local ScaleFill = MakeFrame({
            Parent = ScaleTrack.Instance,
            Size = UDim2.new(0.5, 0, 1, 0),
            Raw = Color3.new(1, 1, 1),
            Round = 20,
            Z = 47
        })

        Library:RegisterGradient(Library:Create("UIGradient", {
            Parent = ScaleFill.Instance
        }).Instance)

        local ScaleKnob = MakeFrame({
            Parent = ScaleTrack.Instance,
            Anchor = Vector2.new(0.5, 0.5),
            Pos = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.fromOffset(12, 12),
            Raw = Color3.fromRGB(197, 197, 197),
            Round = 20,
            Z = 48
        })

        local ScaleHit = MakeButton({
            Parent = ProfilePanel.Instance,
            Pos = UDim2.fromOffset(8, 166),
            Size = UDim2.fromOffset(ProfileW - 16, 22),
            Z = 49
        })

        local ScaleGrab = false
        local ScalePercent = 100

        local function ApplyScale(Input)
            local Base = ScaleTrack.Instance
            local Span = (Input.Position.X - Base.AbsolutePosition.X) / Base.AbsoluteSize.X

            ScalePercent = Library:Round(50 + math.clamp(Span, 0, 1) * 100, 5)

            local Normal = (ScalePercent - 50) / 100

            ScaleValue.Instance.Text = tostring(ScalePercent) .. "%"
            ScaleFill.Instance.Size = UDim2.new(Normal, 0, 1, 0)
            ScaleKnob.Instance.Position = UDim2.new(Normal, 0, 0.5, 0)
        end

        ScaleHit:Connect("InputBegan", function(Input)
            local IsClick = Input.UserInputType == Enum.UserInputType.MouseButton1
            local IsTouch = Input.UserInputType == Enum.UserInputType.Touch

            if not IsClick and not IsTouch then return end

            ScaleGrab = true
            ApplyScale(Input)
        end)

        Library:Connect(UserInputService.InputEnded, function(Input)
            local IsClick = Input.UserInputType == Enum.UserInputType.MouseButton1
            local IsTouch = Input.UserInputType == Enum.UserInputType.Touch

            if (IsClick or IsTouch) and ScaleGrab then
                ScaleGrab = false
                Library.UserScale = ScalePercent / 100
                UpdateScale()

                if RefreshProfilePos then RefreshProfilePos() end
            end
        end)

        Library:Connect(UserInputService.InputChanged, function(Input)
            local IsMove = Input.UserInputType == Enum.UserInputType.MouseMovement
            local IsTouch = Input.UserInputType == Enum.UserInputType.Touch

            if (IsMove or IsTouch) and ScaleGrab then
                ApplyScale(Input)
            end
        end)

        MakeText({
            Parent = ProfilePanel.Instance,
            Text = "Menu toggle",
            TextSize = 14,
            Anchor = Vector2.new(0, 0.5),
            Pos = UDim2.new(0, 14, 0, 205),
            Size = UDim2.fromOffset(110, 20),
            Color = "DimText",
            Z = 46
        })

        local KeyIcon = MakeImage({
            Parent = ProfilePanel.Instance,
            Icon = "command",
            Anchor = Vector2.new(1, 0.5),
            Pos = UDim2.new(1, -14, 0, 205),
            Size = UDim2.fromOffset(16, 16),
            Color = "DimText",
            Z = 46
        })

        local KeyIconHit = MakeButton({
            Parent = ProfilePanel.Instance,
            Anchor = Vector2.new(1, 0.5),
            Pos = UDim2.new(1, -8, 0, 205),
            Size = UDim2.fromOffset(26, 26),
            Z = 48
        })

        KeyIconHit:OnHover(function()
            KeyIcon:Tween({ ImageColor3 = Library.Theme.Text })
        end, function()
            KeyIcon:Tween({ ImageColor3 = Library.Theme.DimText })
        end)

        local KeyPanelW = 170

        local KeyPanel = MakeFrame({
            Parent = Library.UnusedHolder.Instance,
            Size = UDim2.fromOffset(KeyPanelW, 72),
            Color = "Section",
            Round = 8,
            Z = 46
        })

        KeyPanel.Instance.Visible = false

        MakeText({
            Parent = KeyPanel.Instance,
            Text = "Menu keybind",
            TextSize = 12,
            Pos = UDim2.fromOffset(11, 8),
            Size = UDim2.fromOffset(KeyPanelW - 22, 14),
            Color = "DimText",
            Truncate = true,
            Z = 47
        })

        local KeyBox = MakeFrame({
            Parent = KeyPanel.Instance,
            Pos = UDim2.fromOffset(9, 32),
            Size = UDim2.fromOffset(KeyPanelW - 18, 30),
            Color = "Light",
            Round = 5,
            Clip = true,
            Z = 47
        })

        local KeyText = MakeText({
            Parent = KeyBox.Instance,
            Text = KeyName(Library.MenuKeybind),
            TextSize = 13,
            Size = UDim2.new(1, 0, 1, 0),
            Color = "Text",
            Align = Enum.TextXAlignment.Center,
            Truncate = true,
            Z = 48
        })

        local KeyBoxHit = MakeButton({
            Parent = KeyBox.Instance,
            Z = 49
        })

        local KeyState = {
            IsOpen = false,
            Debounce = false,
            Picking = false,
            Host = Profile
        }

        local function KeyPlace(Off)
            local Anchor = KeyIcon.Instance
            local PScale = Library:GetScreenScale()
            local Right = Anchor.AbsolutePosition.X + Anchor.AbsoluteSize.X
            local PX = Right / PScale + 8 + (Off or 0)
            local PY = (Anchor.AbsolutePosition.Y + GuiInset) / PScale - 4

            return UDim2.fromOffset(PX, PY)
        end

        AttachPopup({
            Popup = KeyState,
            Frame = KeyPanel,
            Level = 46,
            GetAnchor = function()
                return KeyIconHit.Instance
            end,
            Place = KeyPlace,
            From = -6,
            To = 2,
            Retreat = RetreatLeft
        })

        KeyIconHit:Connect("MouseButton1Down", function()
            KeyState:SetOpen(not KeyState.IsOpen)
        end)

        KeyBoxHit:Connect("MouseButton1Click", function()
            if KeyState.Picking then return end

            KeyState.Picking = true
            Library.Binding = true
            KeyText.Instance.Text = ". . ."

            task.wait()

            local Connection

            Connection = UserInputService.InputBegan:Connect(function(Input)
                if Input.UserInputType ~= Enum.UserInputType.Keyboard then return end

                Connection:Disconnect()

                if Input.KeyCode ~= Enum.KeyCode.Escape then
                    Library.MenuKeybind = Input.KeyCode
                end

                KeyText.Instance.Text = KeyName(Library.MenuKeybind)
                KeyState.Picking = false

                task.defer(function()
                    Library.Binding = false
                end)
            end)
        end)

        local UnloadButton = MakeFrame({
            Parent = ProfilePanel.Instance,
            Pos = UDim2.fromOffset(14, 236),
            Size = UDim2.fromOffset(ProfileW - 28, 28),
            Color = "Light",
            Round = 6,
            Clip = true,
            Z = 46
        })

        MakeText({
            Parent = UnloadButton.Instance,
            Text = "Unload",
            TextSize = 14,
            Size = UDim2.new(1, 0, 1, 0),
            Color = "Text",
            Align = Enum.TextXAlignment.Center,
            Z = 47
        })

        local UnloadHit = MakeButton({
            Parent = UnloadButton.Instance,
            Z = 48
        })

        UnloadButton:OnHover(function()
            UnloadButton:Tween({ BackgroundColor3 = Library.Theme.Hover })
        end, function()
            UnloadButton:Tween({ BackgroundColor3 = Library.Theme.Light })
        end)

        UnloadHit:Connect("MouseButton1Down", function()
            Window:SetOpen(false)

            task.delay(Library.Animation.Time + 0.12, function()
                Library:Unload()
            end)
        end)

        local function ProfilePlace(Extra)
            local Anchor = Items.Avatar.Instance
            local PScale = Library:GetScreenScale()
            local Right = Anchor.AbsolutePosition.X + Anchor.AbsoluteSize.X
            local X = Right / PScale - ProfileW
            local Y = Anchor.AbsolutePosition.Y + Anchor.AbsoluteSize.Y + GuiInset

            return UDim2.fromOffset(X, Y / PScale + (Extra or 0))
        end

        RefreshProfilePos = function()
            if Profile.IsOpen then
                ProfilePanel.Instance.Position = ProfilePlace(10)
            end
        end

        AttachPopup({
            Popup = Profile,
            Frame = ProfilePanel,
            Level = 45,
            GetAnchor = function()
                return Items.ProfileHit.Instance
            end,
            Place = ProfilePlace,
            From = -2,
            To = 10,
            HoldOpen = function()
                return KeyState.IsOpen
            end
        })

        Window.Profile = Profile

        Items.ProfileHit:Connect("MouseButton1Down", function()
            Profile:SetOpen(not Profile.IsOpen)
        end)

        Items.Content = MakeFrame({
            Parent = Items.Main.Instance,
            Pos = UDim2.fromOffset(15, 65),
            Size = UDim2.fromOffset(W - 30, H - 96),
            Clip = true,
            Z = 2
        })

        Window.Items = Items

        Items.Root:MakeDraggable(Items.Main.Instance)
        Items.Root:MakeDraggable(Items.Rail.Instance)

        table.insert(Library.Windows, Window)

        function Window:Center()
            local CScale = Library:GetScreenScale()
            local Vp = workspace.CurrentCamera.ViewportSize

            Items.Root.Instance.Position = UDim2.fromOffset(
                Vp.X / (2 * CScale) - RootW / 2,
                Vp.Y / (2 * CScale) - RootH / 2
            )
        end

        function Window:LayoutRail()
            local Count = #Window.Tabs
            local CanvasH = Count > 0 and (50 * Count + 10) or RailH
            local NewH = math.min(H, CanvasH)
            local NewY = math.floor((H - NewH) / 2)

            Items.Rail.Instance.CanvasSize = UDim2.fromOffset(0, CanvasH)
            Items.Rail.Instance.Size = UDim2.fromOffset(RailW, NewH)
            Items.Rail.Instance.Position = UDim2.fromOffset(0, NewY)
        end

        function Window:FitSubBar(Instant)
            local Tab = Window.Current
            if not Tab or not Tab.SubLayout then return end
            if #Tab.Subs == 0 then return end

            local ContentScale = Library:GetScreenScale()
            local Content = Tab.SubLayout.AbsoluteContentSize.X / ContentScale + 16

            if Content <= 16 then return end

            local Overflow = Content > MaxSubW
            local Target = math.min(Content, MaxSubW)
            local NewX = SubCenterX - math.floor(Target / 2)

            local Info = Instant and TweenInfo.new(0)
            or TweenInfo.new(0.24, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

            Library:Tween({
                Position = UDim2.fromOffset(NewX, SubY),
                Size = UDim2.fromOffset(Target, SubH)
            }, Info, Items.SubBar.Instance)

            local Row = Tab.Items.SubRow.Instance
            Row.ScrollingEnabled = Overflow
            Row.ScrollBarThickness = Overflow and 3 or 0
        end

        function Window:LayoutSubBar(Instant)
            Window:FitSubBar(Instant)
        end

        function Window:SetOpen(Bool)
            Window.IsOpen = Bool

            if not Bool then
                Library:CloseAllPopups()
            end

            local Sub = Window.Current and Window.Current.Current
            if Sub and Sub.SnapVisible then
                Sub:SnapVisible()
            end

            if Bool and Window.PlayIntro then
                Window:PlayIntro()
            else
                Items.Root:FadeDescendants(Bool)
            end
        end

        Library:Connect(UserInputService.InputBegan, function(Input, Processed)
            if Processed or Library.Binding then return end

            if Input.KeyCode == Library.MenuKeybind then
                Window:SetOpen(not Window.IsOpen)
            end
        end)

        local function RunSearch(Query)
            Query = string.lower(Query)

            for _, Data in Library.Searchables do
                if Data.Window ~= Window then continue end

                local Match = Query == ""
                or string.find(string.lower(Data.Name), Query, 1, true) ~= nil

                if not Match and Data.Section then
                    Match = string.find(string.lower(Data.Section.Name), Query, 1, true) ~= nil
                end

                Data.Visible = Match

                if Data.Section then
                    Data.Section.Dirty = true
                end
            end

            for _, Tab in Window.Tabs do
                for _, Sub in Tab.Subs do
                    for _, Section in Sub.Sections do
                        if Section.Dirty then
                            Section.Dirty = false
                            Section:Reflow()
                        end
                    end
                end
            end

            local Tab = Window.Current
            local Sub = Tab and Tab.Current

            if Sub and #Sub.Sections > 0 then
                local Sig = tostring(Sub)

                for _, Section in Sub.Sections do
                    for _, Data in Section.Rows do
                        Sig ..= Data.Visible ~= false and "1" or "0"
                    end
                end

                if Sig ~= Window.SearchSig then
                    Window.SearchSig = Sig
                    Sub:Show()
                end
            end
        end

        local SearchToken = 0

        Library:Connect(Items.SearchBox.Instance:GetPropertyChangedSignal("Text"), function()
            SearchToken += 1

            local Token = SearchToken

            task.delay(0.1, function()
                if Token ~= SearchToken then return end
                RunSearch(Items.SearchBox.Instance.Text)
            end)
        end)

        function Window:PlayIntro()
            local Base = Items.Root.Instance.Position
            local Rise = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

            Items.Root.Instance.Position = UDim2.fromOffset(
                Base.X.Offset,
                Base.Y.Offset + 24
            )

            Items.Root:FadeDescendants(true)
            Library:Tween({ Position = Base }, Rise, Items.Root.Instance)
        end

        task.defer(function()
            Window:PlayIntro()
        end)

        return setmetatable(Window, Library)
    end

    Library.Tab = function(Self, Params)
        Params = Params or { }

        local Window = Self

        local Tab = {
            Category = Params.Category or "Other",
            Name = Params.Name or "Tab",
            Icon = Params.Icon or "circle",
            Window = Window,
            Subs = { },
            Current = nil,
            Active = false,
            Items = { }
        }

        local Items = { }
        local Index = #Window.Tabs
        local RowY = 10 + Index * 50

        Items.Row = MakeFrame({
            Parent = Window.Items.Rail.Instance,
            Pos = UDim2.fromOffset(10, RowY),
            Size = UDim2.fromOffset(40, 40),
            Color = "Element",
            Round = 8,
            Clip = true,
            Z = 3
        })

        SetRest(Items.Row.Instance, "BackgroundTransparency", 1)

        Items.Bar = MakeFrame({
            Parent = Window.Items.Rail.Instance,
            Anchor = Vector2.new(0, 0.5),
            Pos = UDim2.new(0, 0, 0, RowY + 20),
            Size = UDim2.fromOffset(3, 0),
            Color = "Accent",
            Round = 4,
            Z = 4
        })

        Items.BarShadow = MakeAccentShadow(
            Items.Bar.Instance,
            UDim2.fromOffset(3, 15),
            UDim.new(0, 10),
            0
        )

        if Items.BarShadow then
            SetRest(Items.BarShadow, "Transparency", 1)
        end

        Items.Icon = MakeImage({
            Parent = Items.Row.Instance,
            Icon = Tab.Icon,
            Pos = UDim2.fromOffset(10, 10),
            Size = UDim2.fromOffset(20, 20),
            Color = "DimIcon",
            Z = 4
        })

        Items.Hit = MakeButton({
            Parent = Items.Row.Instance,
            Z = 6
        })

        Items.SubRow = Library:Create("ScrollingFrame", {
            Parent = Window.Items.SubBar.Instance,
            Name = "\0",
            BackgroundTransparency = 1,
            ScrollBarThickness = 0,
            ScrollBarImageColor3 = Library.Theme.Accent,
            ScrollingDirection = Enum.ScrollingDirection.X,
            ScrollingEnabled = false,
            Selectable = false,
            Active = true,
            AutomaticCanvasSize = Enum.AutomaticSize.X,
            CanvasSize = UDim2.fromOffset(0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 21,
            BorderSizePixel = 0
        }):AddToTheme({ ScrollBarImageColor3 = "Accent" })

        Items.SubRow.Instance.Visible = false

        Items.SubLayout = Library:Create("UIListLayout", {
            Parent = Items.SubRow.Instance,
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 6)
        })

        Library:Create("UIPadding", {
            Parent = Items.SubRow.Instance,
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8)
        })

        Window.Items.Root:MakeDraggable(Items.SubRow.Instance)

        Tab.SubLayout = Items.SubLayout.Instance

        Library:Connect(Tab.SubLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
            if Window.Current == Tab then
                Window:FitSubBar(true)
            end
        end)

        Tab.Items = Items

        function Tab:SetVisual(Active)
            Tab.Active = Active

            Library:StampResting(Items.Row.Instance, "BackgroundTransparency", Active and 0 or 1)

            if Items.BarShadow then
                Library:StampResting(Items.BarShadow, "Transparency", Active and 0 or 1)
                Items.BarShadow.Transparency = Active and 0 or 1
            end

            Items.Icon:ChangeItemTheme({ ImageColor3 = Active and "Accent" or "DimIcon" })
            Items.Icon:Tween({
                ImageColor3 = Active and Library.Theme.Accent or Library.Theme.DimIcon
            })

            Items.Row:Tween({ BackgroundTransparency = Active and 0 or 1 })
            Items.Bar:Tween({ Size = UDim2.fromOffset(3, Active and 16 or 0) })
        end

        Items.Row:OnHover(function()
            if Tab.Active then return end
            Items.Icon:Tween({ ImageColor3 = Library.Theme.Text })
        end, function()
            if Tab.Active then return end
            Items.Icon:Tween({ ImageColor3 = Library.Theme.DimIcon })
        end)

        local function EnterFirstSub()
            local Sub = Tab.Current or Tab.Subs[1]
            if not Sub then return end

            Tab.Current = Sub

            for _, Other in Tab.Subs do
                Other:SetVisual(Other == Sub)
            end

            Sub:Show()
        end

        function Tab:Select()
            if Window.Current == Tab then return end

            Library:CloseAllPopups()

            if Window.Current then
                Window.Current:SetVisual(false)
                Window.Current.Items.SubRow.Instance.Visible = false

                if Window.Current.Current then
                    Window.Current.Current:Hide()
                end
            end

            Window.Current = Tab
            Tab:SetVisual(true)
            Items.SubRow.Instance.Visible = true

            EnterFirstSub()
            Window:LayoutSubBar()
        end

        Items.Hit:Connect("MouseButton1Down", function()
            Tab:Select()
        end)

        table.insert(Window.Tabs, Tab)
        Window:LayoutRail()

        if #Window.Tabs == 1 then
            Window.Current = Tab
            Tab:SetVisual(true)
            Items.SubRow.Instance.Visible = true

            task.defer(function()
                EnterFirstSub()
                Window:LayoutSubBar()
            end)
        end

        return setmetatable(Tab, Library)
    end

    Library.SubTab = function(Self, Params)
        Params = Params or { }

        local Tab = Self
        local Window = Tab.Window

        local SubTab = {
            Name = Params.Name or "SubTab",
            Icon = Params.Icon or "circle",
            Tab = Tab,
            Window = Window,
            Sections = { },
            Columns = { },
            Active = false,
            ShowToken = 0,
            Items = { }
        }

        local Items = { }
        local ContentW = Window.ContentW
        local ContentH = Window.ContentH
        local ColW = Window.ColW
        local Col2X = Window.Col2X

        local TextW = math.ceil(MeasureText(SubTab.Name, 15, 300, UiFont).X)
        local CollapsedW = 40
        local ExpandedW = 37 + TextW + 12

        SubTab.CollapsedW = CollapsedW
        SubTab.ExpandedW = ExpandedW

        Items.Pill = MakeFrame({
            Parent = Tab.Items.SubRow.Instance,
            Size = UDim2.fromOffset(CollapsedW, 30),
            Color = "Element",
            Round = 5,
            Clip = true,
            Z = 22
        })

        SetRest(Items.Pill.Instance, "BackgroundTransparency", 1)
        Items.Pill.Instance.LayoutOrder = #Tab.Subs

        Items.Icon = MakeImage({
            Parent = Items.Pill.Instance,
            Icon = SubTab.Icon,
            Anchor = Vector2.new(0, 0.5),
            Pos = UDim2.new(0, 11, 0.5, 0),
            Size = UDim2.fromOffset(18, 18),
            Color = "DimIcon",
            Z = 23
        })

        Items.Label = MakeText({
            Parent = Items.Pill.Instance,
            Text = SubTab.Name,
            TextSize = 15,
            Anchor = Vector2.new(0, 0.5),
            Pos = UDim2.new(0, 37, 0.5, 0),
            Size = UDim2.fromOffset(TextW + 8, 20),
            Color = "Text",
            Z = 23
        })

        SetRest(Items.Label.Instance, "TextTransparency", 1)

        local function SyncWidth()
            local Bounds = math.ceil(Items.Label.Instance.TextBounds.X)
            if Bounds <= 0 then return end

            ExpandedW = 37 + Bounds + 12
            SubTab.ExpandedW = ExpandedW
            Items.Label.Instance.Size = UDim2.fromOffset(Bounds + 8, 20)

            if Tab.Current == SubTab then
                Items.Pill.Instance.Size = UDim2.fromOffset(ExpandedW, 30)
                Window:FitSubBar(true)
            end
        end

        Library:Connect(Items.Label.Instance:GetPropertyChangedSignal("TextBounds"), SyncWidth)
        task.defer(SyncWidth)

        Items.Hit = MakeButton({
            Parent = Items.Pill.Instance,
            Z = 25
        })

        Items.Page = MakeFrame({
            Parent = Library.UnusedHolder.Instance,
            Size = UDim2.fromOffset(ContentW, ContentH),
            Z = 3
        })

        Items.Page.Instance.Visible = false

        local function MakeColumn(X)
            local Scroll = Library:Create("ScrollingFrame", {
                Parent = Items.Page.Instance,
                Name = "\0",
                BackgroundTransparency = 1,
                ScrollBarThickness = 0,
                ScrollBarImageTransparency = 1,
                Selectable = false,
                Active = true,
                Position = UDim2.fromOffset(X, 0),
                Size = UDim2.fromOffset(ColW, ContentH),
                CanvasSize = UDim2.fromOffset(0, 0),
                ZIndex = 3,
                BorderSizePixel = 0
            })

            local Column = {
                Scroll = Scroll,
                Width = ColW,
                Sections = { }
            }

            function Column:Reflow()
                local Y = 0

                for _, Section in Column.Sections do
                    Section.Y = Y
                    Section.Items.Holder.Instance.Position = UDim2.fromOffset(0, Y)
                    Y += Section.Height + 16
                end

                Scroll.Instance.CanvasSize = UDim2.fromOffset(0, math.max(Y - 16, 0))
            end

            return Column
        end

        SubTab.Columns[1] = MakeColumn(0)
        SubTab.Columns[2] = MakeColumn(Col2X)
        SubTab.Items = Items

        function SubTab:SetVisual(Active, Instant)
            Library:StampResting(Items.Pill.Instance, "BackgroundTransparency", Active and 0 or 1)
            Library:StampResting(Items.Label.Instance, "TextTransparency", Active and 0 or 1)

            local Info = Instant and TweenInfo.new(0)
            or TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

            local Width = Active and ExpandedW or CollapsedW

            Library:Tween({ Size = UDim2.fromOffset(Width, 30) }, Info, Items.Pill.Instance)
            Library:Tween({ TextTransparency = Active and 0 or 1 }, Info, Items.Label.Instance)

            Items.Icon:ChangeItemTheme({ ImageColor3 = Active and "Accent" or "DimIcon" })
            Items.Icon:Tween({
                ImageColor3 = Active and Library.Theme.Accent or Library.Theme.DimIcon
            }, Info)

            Items.Pill:Tween({ BackgroundTransparency = Active and 0 or 1 }, Info)
        end

        Items.Pill:OnHover(function()
            if Tab.Current == SubTab then return end
            Items.Icon:Tween({ ImageColor3 = Library.Theme.Text })
        end, function()
            if Tab.Current == SubTab then return end
            Items.Icon:Tween({ ImageColor3 = Library.Theme.DimIcon })
        end)

        local RowIn = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        local Sink = TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

        local PageSlide = 22
        local RowSlide = 18
        local SectionStep = 0.07
        local RowStep = 0.045

        local function ForEachSectionPart(Section, Handler)
            local Parts = Section.Items

            local Objects = {
                Parts.Header.Instance,
                Parts.HeaderFill.Instance,
                Parts.Label.Instance,
                Parts.Frame.Instance,
                Parts.BodyFill.Instance
            }

            for _, Object in Objects do
                local Properties = Library:GetTweenProperty(Object)
                if not Properties then continue end

                for _, Property in Properties do
                    Handler(Object, Property)
                end
            end
        end

        local function PrimeParts(Section)
            ForEachSectionPart(Section, function(Object, Property)
                Library:CaptureResting(Object, Property)
                Object[Property] = 1
            end)
        end

        local function RevealParts(Section)
            ForEachSectionPart(Section, function(Object, Property)
                local Resting = Library:CaptureResting(Object, Property)
                Library:Tween({ [Property] = Resting }, nil, Object)
            end)
        end

        local function ForEachRow(Handler)
            for _, Column in SubTab.Columns do
                for _, Section in Column.Sections do
                    for _, Data in Section.Rows do
                        Handler(Data, Section)
                    end
                end
            end
        end

        local PageTween

        local function StopTween(Handle)
            if not Handle then return end

            pcall(function()
                Handle:Cancel()
            end)
        end

        local function StopPageTween()
            StopTween(PageTween)
            PageTween = nil
        end

        local function StopRowTweens()
            ForEachRow(function(Data)
                StopTween(Data.Move)
                Data.Move = nil
            end)
        end

        local function LayoutPage()
            for _, Column in SubTab.Columns do
                for _, Section in Column.Sections do
                    Section.Items.Holder.Instance.Position = UDim2.fromOffset(0, Section.Y)
                    Section.Items.Frame.Instance.Position = UDim2.fromOffset(0, 26)

                    for _, Data in Section.Rows do
                        Data.Frame:CancelFade()
                        Data.Frame.Instance.Visible = Data.Visible ~= false
                    end
                end
            end
        end

        local function CleanPage()
            Items.Page.Instance.Position = UDim2.fromOffset(0, 0)
            Items.Page:HardRestore()

            LayoutPage()

            ForEachRow(function(Data)
                Data.Frame.Instance.Position = UDim2.fromOffset(0, Data.Y)
            end)
        end

        function SubTab:Show()
            Window:UpdateBreadcrumb(Tab,SubTab)
            SubTab.ShowToken += 1

            local Token = SubTab.ShowToken
            SubTab.Active = true

            StopPageTween()
            StopRowTweens()

            Items.Page:CancelFade()
            Items.Page:HardRestore()
            Items.Page.Instance.Parent = Window.Items.Content.Instance
            Items.Page.Instance.Position = UDim2.fromOffset(0, 0)
            Items.Page.Instance.Visible = true

            Library:SafeCall(SubTab.PageIntro)

            if #SubTab.Sections == 0 then
                for _, Column in SubTab.Columns do
                    Column:Reflow()
                end
                return
            end

            LayoutPage()
            for _, Column in SubTab.Columns do
                Column:Reflow()
            end

            local Order = 0

            for _, Column in SubTab.Columns do
                for _, Section in Column.Sections do
                    Order += 1
                    PrimeParts(Section)

                    for _, Data in Section.Rows do
                        Data.Frame:CancelFade()
                        Data.Frame.Instance.Visible = false
                    end

                    local Slot = Order

                    task.delay((Slot - 1) * SectionStep, function()
                        if SubTab.ShowToken ~= Token or not SubTab.Active then return end

                        RevealParts(Section)

                        for RowIndex, Data in Section.Rows do
                            if Data.Visible == false then continue end

                            task.delay(RowIndex * RowStep, function()
                                local Home = UDim2.fromOffset(0, Data.Y)

                                Data.Frame.Instance.Visible = true

                                if SubTab.ShowToken ~= Token or not SubTab.Active then
                                    Data.Frame.Instance.Position = Home
                                    return
                                end

                                Data.Frame.Instance.Position = UDim2.fromOffset(RowSlide, Data.Y)
                                Data.Move = Library:Tween({ Position = Home }, RowIn, Data.Frame.Instance)
                                Data.Frame:FadeDescendants(true)
                            end)
                        end
                    end)
                end
            end
        end

        function SubTab:Hide(OnDone)
            SubTab.Active = false
            SubTab.ShowToken += 1

            Library:SafeCall(SubTab.PageOutro)

            StopRowTweens()

            ForEachRow(function(Data)
                Data.Frame:CancelFade()
            end)

            StopPageTween()

            PageTween = Library:Tween({
                Position = UDim2.fromOffset(-PageSlide, 0)
            }, Sink, Items.Page.Instance)

            Items.Page:FadeDescendants(false, function()
                if not SubTab.Active then
                    StopPageTween()
                    Items.Page:ResetFade()
                    CleanPage()

                    Items.Page.Instance.Visible = false
                    Items.Page.Instance.Parent = Library.UnusedHolder.Instance
                end

                if OnDone then Library:SafeCall(OnDone) end
            end)
        end

        function SubTab:SnapVisible()
            Window:UpdateBreadcrumb(Tab,SubTab)
            SubTab.ShowToken += 1
            SubTab.Active = true

            StopPageTween()
            StopRowTweens()

            Items.Page:CancelFade()
            Items.Page:HardRestore()
            Items.Page.Instance.Parent = Window.Items.Content.Instance
            Items.Page.Instance.Position = UDim2.fromOffset(0, 0)
            CleanPage()
            Items.Page.Instance.Visible = true

            for _, Column in SubTab.Columns do
                Column:Reflow()
            end
        end

        Items.Hit:Connect("MouseButton1Down", function()
            if Tab.Current == SubTab then return end

            Library:CloseAllPopups()

            if Tab.Current then
                Tab.Current:SetVisual(false)
                Tab.Current:Hide()
            end

            Tab.Current = SubTab
            SubTab:SetVisual(true)
            SubTab:Show()

            Window:LayoutSubBar()
        end)

        table.insert(Tab.Subs, SubTab)

        if #Tab.Subs == 1 then
            Tab.Current = SubTab
            SubTab:SetVisual(true, true)
        end

        if Window.Current == Tab then
            Window:LayoutSubBar()
        end

        return setmetatable(SubTab, Library)
    end

    Library.Section = function(Self, Params)
        Params = Params or { }

        local SubTab = Self
        local Side = Params.Side or 1

        if Side == "Right" then Side = 2 end
        if Side == "Left" then Side = 1 end

        local Column = SubTab.Columns[Side] or SubTab.Columns[1]

        local Section = {
            Name = Params.Name or "Section",
            SubTab = SubTab,
            Column = Column,
            Width = Column.Width,
            Y = 0,
            Height = 0,
            Rows = { },
            Dirty = false,
            Items = { }
        }

        local Items = { }

        Items.Holder = MakeFrame({
            Parent = Column.Scroll.Instance,
            Size = UDim2.fromOffset(Column.Width, 40),
            Z = 3
        })

        local HeaderTextW = math.ceil(MeasureText(Section.Name, 15, 240, UiFont).X)
        local HeaderW = Column.Width

        Items.Header = MakeFrame({
            Parent = Items.Holder.Instance,
            Pos = UDim2.fromOffset(0, 1),
            Size = UDim2.fromOffset(HeaderW, 25),
            Color = "Section",
            Round = 10,
            Z = 3
        })

        Items.HeaderFill = MakeFrame({
            Parent = Items.Header.Instance,
            Pos = UDim2.fromOffset(0, 15),
            Size = UDim2.fromOffset(HeaderW, 10),
            Color = "Section",
            Z = 3
        })

        Items.Label = MakeText({
            Parent = Items.Header.Instance,
            Text = string.lower(Section.Name),
            TextSize = 14,
            Font = UiFontBold,
            Truncate = true,
            Anchor = Vector2.new(0, 0.5),
            Pos = UDim2.new(0, 13, 0.5, 1),
            Size = UDim2.fromOffset(HeaderTextW + 6, 20),
            Color = "Text",
            Z = 4
        })

        local function SyncHeader()
            local Bounds = math.ceil(Items.Label.Instance.TextBounds.X)
            if Bounds <= 0 then return end

            HeaderTextW = Bounds
            HeaderW = Column.Width

            Items.Label.Instance.Size = UDim2.fromOffset(math.max(40,Column.Width-26), 20)
            Items.Header.Instance.Size = UDim2.fromOffset(HeaderW, 25)
            Items.HeaderFill.Instance.Size = UDim2.fromOffset(HeaderW, 10)
        end

        Library:Connect(Items.Label.Instance:GetPropertyChangedSignal("TextBounds"), SyncHeader)
        task.defer(SyncHeader)

        Items.Frame = MakeFrame({
            Parent = Items.Holder.Instance,
            Pos = UDim2.fromOffset(0, 26),
            Size = UDim2.fromOffset(Column.Width, 14),
            Color = "Section",
            Round = 10,
            Z = 3
        })

        Items.BodyFill = MakeFrame({
            Parent = Items.Frame.Instance,
            Pos = UDim2.fromOffset(0, 0),
            Size = UDim2.fromOffset(10, 10),
            Color = "Section",
            Z = 3
        })

        Library:Create("UIStroke",{Parent=Items.Header.Instance,Color=Library.Theme.Line,Thickness=1,Transparency=0.45}):AddToTheme({Color="Line"})
        Library:Create("UIStroke",{Parent=Items.Frame.Instance,Color=Library.Theme.Line,Thickness=1,Transparency=0.45}):AddToTheme({Color="Line"})
        Items.BodyFill.Instance.Size=UDim2.fromOffset(Column.Width,10)
        Section.Items = Items

        function Section:Reflow()
            local Y = 8
            local Visible = 0

            for _, Data in Section.Rows do
                local Shown = Data.Visible ~= false

                Data.Frame.Instance.Visible = Shown

                if not Shown then continue end

                Data.Y = Y
                Data.Frame.Instance.Position = UDim2.fromOffset(0, Y)
                Y += Data.Height
                Visible += 1
            end

            local FrameHeight = Visible > 0 and (Y + 8) or 0

            Items.Frame.Instance.Size = UDim2.fromOffset(Section.Width, FrameHeight)
            Items.Holder.Instance.Visible = Visible > 0
            Section.Height = Visible > 0 and (26 + FrameHeight) or 0
            Items.Holder.Instance.Size = UDim2.fromOffset(Section.Width, math.max(Section.Height, 1))

            Column:Reflow()
        end

        function Section:AddRow(Height, SearchName)
            local Frame = MakeFrame({
                Parent = Items.Frame.Instance,
                Size = UDim2.fromOffset(Section.Width, Height),
                Z = 4
            })

            local Data = {
                Frame = Frame,
                Height = Height,
                Y = 0,
                Visible = true,
                Name = SearchName or Section.Name,
                Section = Section,
                Window = SubTab.Window
            }

            table.insert(Section.Rows, Data)
            table.insert(Library.Searchables, Data)

            Section:Reflow()
            if SubTab.Active and SubTab.Tab.Current == SubTab then
                task.defer(function()
                    if SubTab.Active and SubTab.Tab.Current == SubTab then
                        SubTab:SnapVisible()
                    end
                end)
            end
            return Frame, Data
        end

        table.insert(SubTab.Sections, Section)
        table.insert(Column.Sections, Section)
        Section:Reflow()
        if SubTab.Active and SubTab.Tab.Current == SubTab then
            task.defer(function()
                if SubTab.Active and SubTab.Tab.Current == SubTab then
                    SubTab:SnapVisible()
                end
            end)
        end

        return setmetatable(Section, Library)
    end

    Library.Toggle = function(Self, Params)
        Params = Params or { }

        local Section = Self

        local Toggle = {
            Name = Params.Name or "Toggle",
            Default = Params.Default or false,
            Flag = Params.Flag,
            Callback = Params.Callback or function() end,
            Value = false,
            Visual = nil,
            Token = 0,
            Items = { }
        }

        local Row = Section:AddRow(32, Toggle.Name)
        local Items = { Row = Row }

        Items.Label = MakeText({
            Parent = Row.Instance,
            Text = Toggle.Name,
            TextSize = 15,
            Anchor = Vector2.new(0, 0.5),
            Pos = UDim2.new(0, 15, 0.5, 0),
            Size = UDim2.fromOffset(Section.Width - 80, 20),
            Color = "DimText",
            Truncate = true,
            Z = 5
        })

        Items.Box = MakeFrame({
            Parent = Row.Instance,
            Anchor = Vector2.new(1, 0.5),
            Pos = UDim2.new(1, -15, 0.5, 0),
            Size = UDim2.fromOffset(35, 21),
            Color = "Element",
            Round = 10,
            Clip = true,
            Z = 5
        })

        Items.Circle = MakeFrame({
            Parent = Items.Box.Instance,
            Anchor = Vector2.new(0, 0.5),
            Pos = UDim2.new(0, 4, 0.5, 0),
            Size = UDim2.fromOffset(13, 13),
            Color = "DimText",
            Round = 20,
            Z = 6
        })

        MakeAccentShadow(
            Items.Circle.Instance,
            UDim2.fromOffset(3, 3),
            UDim.new(0, 5),
            0.7
        )

        Items.Hit = MakeButton({
            Parent = Row.Instance,
            Size = UDim2.new(1, 0, 1, 0),
            Z = 8
        })

        Toggle.Items = Items

        local Pad = 4
        local InnerW = 35 - Pad * 2
        local LeftPos = UDim2.new(0, Pad, 0.5, 0)
        local RightPos = UDim2.new(1, -Pad, 0.5, 0)
        local Small = UDim2.fromOffset(13, 13)

        function Toggle.SetVisual(State, Instant)
            State = State and true or false
            if Toggle.Visual == State then return end
            Toggle.Visual = State

            Toggle.Token += 1
            local Token = Toggle.Token

            if Toggle.GrowTween then
                pcall(function()
                    Toggle.GrowTween:Cancel()
                end)
            end

            if Toggle.SnapTween then
                pcall(function()
                    Toggle.SnapTween:Cancel()
                end)
            end

            Toggle.GrowTween = nil
            Toggle.SnapTween = nil

            local BoxColor = State and "Light" or "Element"
            local CircleKey = State and "Accent" or "DimText"
            local CircleColor = Library.Theme[CircleKey]
            local LabelColor = State and "Text" or "DimText"

            local StartAnchor = State and Vector2.new(0, 0.5) or Vector2.new(1, 0.5)
            local StartPos = State and LeftPos or RightPos
            local EndAnchor = State and Vector2.new(1, 0.5) or Vector2.new(0, 0.5)
            local EndPos = State and RightPos or LeftPos

            Items.Box:ChangeItemTheme({ BackgroundColor3 = BoxColor })
            Items.Label:ChangeItemTheme({ TextColor3 = LabelColor })
            Items.Circle:ChangeItemTheme({ BackgroundColor3 = CircleKey })

            if Instant then
                Items.Box.Instance.BackgroundColor3 = Library.Theme[BoxColor]
                Items.Label.Instance.TextColor3 = Library.Theme[LabelColor]
                Items.Circle.Instance.BackgroundColor3 = CircleColor
                Items.Circle.Instance.Size = Small
                Items.Circle.Instance.AnchorPoint = EndAnchor
                Items.Circle.Instance.Position = EndPos
                return
            end

            local Grow = TweenInfo.new(0.14, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            local Snap = TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            local Fade = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

            Library:Tween({ BackgroundColor3 = Library.Theme[BoxColor] }, Fade, Items.Box.Instance)
            Library:Tween({ TextColor3 = Library.Theme[LabelColor] }, Fade, Items.Label.Instance)
            Library:Tween({ BackgroundColor3 = CircleColor }, Fade, Items.Circle.Instance)

            Items.Circle.Instance.AnchorPoint = StartAnchor
            Items.Circle.Instance.Position = StartPos
            Toggle.GrowTween = Library:Tween({ Size = UDim2.fromOffset(InnerW, 13) }, Grow, Items.Circle.Instance)

            task.delay(0.08, function()
                if Toggle.Token ~= Token then return end

                Items.Circle.Instance.AnchorPoint = EndAnchor
                Items.Circle.Instance.Position = EndPos
                Toggle.SnapTween = Library:Tween({ Size = Small }, Snap, Items.Circle.Instance)
            end)

            task.delay(0.3, function()
                if Toggle.Token ~= Token then return end
                if Items.Circle.Instance.Size == Small then return end

                Items.Circle.Instance.AnchorPoint = EndAnchor
                Items.Circle.Instance.Position = EndPos
                Items.Circle.Instance.Size = Small
            end)
        end

        function Toggle:Set(Bool)
            Toggle.Value = Bool and true or false

            if Toggle.Flag then
                Library.Flags[Toggle.Flag] = Toggle.Value
            end

            Toggle.SetVisual(Toggle.Value, false)
            Library:SafeCall(Toggle.Callback, Toggle.Value)
        end

        function Toggle:Get()
            return Toggle.Value
        end

        Items.Hit:Connect("MouseButton1Down", function()
            Toggle:Set(not Toggle.Value)
        end)

        Toggle.SlotX = -58

        local function TakeSlot(Width)
            local X = Toggle.SlotX
            Toggle.SlotX -= Width + 8
            Items.Label.Instance.Size = UDim2.fromOffset(Section.Width + Toggle.SlotX - 15, 20)
            return X
        end

        local function SlotIcon(X, Icon)
            local Glyph = MakeImage({
                Parent = Row.Instance,
                Icon = Icon,
                Anchor = Vector2.new(1, 0.5),
                Pos = UDim2.new(1, X, 0.5, 0),
                Size = UDim2.fromOffset(16, 16),
                Color = "DimText",
                Z = 6
            })

            local Hit = MakeButton({
                Parent = Row.Instance,
                Anchor = Vector2.new(1, 0.5),
                Pos = UDim2.new(1, X + 2, 0.5, 0),
                Size = UDim2.fromOffset(22, 22),
                Z = 9
            })

            Hit:OnHover(function()
                Glyph:Tween({ ImageColor3 = Library.Theme.Text })
            end, function()
                Glyph:Tween({ ImageColor3 = Library.Theme.DimText })
            end)

            return Glyph, Hit
        end

        local function SidePlace(Anchor)
            return function(Off)
                local PScale = Library:GetScreenScale()
                local Right = Anchor.AbsolutePosition.X + Anchor.AbsoluteSize.X
                local PX = Right / PScale + 8 + (Off or 0)
                local PY = (Anchor.AbsolutePosition.Y + GuiInset) / PScale - 4

                return UDim2.fromOffset(PX, PY)
            end
        end

        function Toggle:Colorpicker(CParams)
            CParams = CParams or { }

            local Picker = {
                Color = CParams.Default or Library.Theme.Accent,
                Transparency = CParams.Transparency or 0
            }

            local X = TakeSlot(22)
            local Swatch = MakeSwatch(Row.Instance, X, Picker.Color, 6)

            local Inner = MakeColorPopup(function()
                return Swatch.Halo.Instance
            end, CParams.Name or Toggle.Name, Picker.Color, Picker.Transparency, function(Color, Alpha)
                Picker.Color = Color
                Picker.Transparency = Alpha
                Swatch:SetColor(Color, Alpha)

                if CParams.Flag then
                    Library.Flags[CParams.Flag] = {
                        __color = Color:ToHex(),
                        __alpha = Alpha
                    }
                end

                Library:SafeCall(CParams.Callback, Color, Alpha)
            end)

            Swatch.Hit:Connect("MouseButton1Down", function()
                Inner:SetOpen(not Inner.IsOpen)
            end)

            if CParams.Flag then
                Library.SetFlags[CParams.Flag] = function(Color, Alpha)
                    Inner:Set(Color, Alpha)
                end
            end

            function Picker:Set(Color, Alpha)
                Inner:Set(Color, Alpha)
            end

            Picker.Picker = Inner
            return Picker
        end

        function Toggle:Keybind(KParams)
            KParams = KParams or { }

            local Keybind = {
                Key = KParams.Default,
                Mode = KParams.Mode or "None",
                Flag = KParams.Flag,
                Picking = false,
                IsOpen = false,
                Debounce = false
            }

            local X = TakeSlot(20)
            local BindIcon, BindHit = SlotIcon(X, "command")

            local PanelW = 160

            local Panel = MakeFrame({
                Parent = Library.UnusedHolder.Instance,
                Size = UDim2.fromOffset(PanelW, 224),
                Color = "Section",
                Round = 8,
                Z = 40
            })

            Panel.Instance.Visible = false

            MakeText({
                Parent = Panel.Instance,
                Text = "Keybind",
                TextSize = 12,
                Pos = UDim2.fromOffset(11, 7),
                Size = UDim2.fromOffset(PanelW - 22, 14),
                Color = "DimText",
                Z = 41
            })

            local KeyBox = MakeFrame({
                Parent = Panel.Instance,
                Pos = UDim2.fromOffset(8, 26),
                Size = UDim2.fromOffset(PanelW - 16, 26),
                Color = "Light",
                Round = 5,
                Z = 41
            })

            local PanelKey = MakeText({
                Parent = KeyBox.Instance,
                Text = "None",
                TextSize = 13,
                Size = UDim2.new(1, 0, 1, 0),
                Color = "Text",
                Align = Enum.TextXAlignment.Center,
                Truncate = true,
                Z = 42
            })

            local KeyHit = MakeButton({
                Parent = KeyBox.Instance,
                Z = 43
            })

            local ModeRows = { }

            local function ModeRow(Y, ModeName)
                local Built = MakeAccentRow({
                    Parent = Panel.Instance,
                    Pos = UDim2.fromOffset(8, Y),
                    Size = UDim2.fromOffset(PanelW - 16, 28),
                    Color = "Element",
                    Text = ModeName,
                    TextSize = 13,
                    LabelSize = UDim2.new(1, -18, 1, 0),
                    LineX = 6,
                    LineH = 14,
                    TextX = 10,
                    TextActiveX = 17,
                    SnapShadow = true,
                    Z = 41
                })

                Built.Hit:Connect("MouseButton1Down", function()
                    Keybind:SetMode(ModeName)
                end)

                table.insert(ModeRows, {
                    Name = ModeName,
                    SetActive = Built.SetActive
                })
            end

            ModeRow(60, "None")
            ModeRow(92, "Toggle")
            ModeRow(124, "Hold")
            ModeRow(156, "Always")
            ModeRow(188, "Never")

            local function SaveFlag()
                if not Keybind.Flag then return end

                Library.Flags[Keybind.Flag] = {
                    Key = Keybind.Key and tostring(Keybind.Key) or "None",
                    Mode = Keybind.Mode
                }
            end

            function Keybind:SetMode(Mode, Instant)
                Keybind.Mode = Mode

                for _, Data in ModeRows do
                    Data.SetActive(Data.Name == Mode, Instant)
                end

                SaveFlag()
                if Mode == "Always" then
                    Toggle:Set(true)
                elseif Mode == "Never" or Mode == "None" then
                    Toggle:Set(false)
                end
            end

            function Keybind:Set(Key)
                Keybind.Key = Key
                PanelKey.Instance.Text = KeyName(Key)
                Keybind.Picking = false

                SaveFlag()
            end

            AttachPopup({
                Popup = Keybind,
                Frame = Panel,
                Level = 40,
                GetAnchor = function()
                    return BindHit.Instance
                end,
                Place = SidePlace(BindIcon.Instance),
                From = -6,
                To = 2,
                Retreat = RetreatLeft
            })

            BindHit:Connect("MouseButton1Down", function()
                Keybind:SetOpen(not Keybind.IsOpen)
            end)
            BindHit:Connect("MouseButton2Down", function()
                Keybind:SetOpen(not Keybind.IsOpen)
            end)

            KeyHit:Connect("MouseButton1Click", function()
                CaptureKey(Keybind, PanelKey.Instance, function(Key)
                    Keybind:Set(Key)
                end)
            end)

            Library:Connect(UserInputService.InputBegan, function(Input, Processed)
                if Processed or Keybind.Picking or not Keybind.Key then return end
                if not KeyMatches(Input, Keybind.Key) then return end

                if Keybind.Mode == "None" or Keybind.Mode == "Never" or Keybind.Mode == "Always" then
                    return
                elseif Keybind.Mode == "Hold" then
                    Toggle:Set(true)
                else
                    Toggle:Set(not Toggle.Value)
                end
            end)

            Library:Connect(UserInputService.InputEnded, function(Input)
                if Keybind.Mode ~= "Hold" or not Keybind.Key then return end
                if not KeyMatches(Input, Keybind.Key) then return end

                Toggle:Set(false)
            end)

            if Keybind.Flag then
                Library.SetFlags[Keybind.Flag] = function(Value)
                    if type(Value) == "table" then
                        if Value.Mode then Keybind:SetMode(Value.Mode, true) end
                        Value = Value.Key
                    end

                    Keybind:Set(ParseKey(Value))
                end
            end

            Keybind:SetMode(Keybind.Mode, true)
            Keybind:Set(Keybind.Key)

            return Keybind
        end

        function Toggle:Extra(EParams)
            EParams = EParams or { }

            if Toggle.ExtraPanel then
                return Toggle.ExtraPanel
            end

            local Extra = {
                IsOpen = false,
                Debounce = false,
                NextY = 30,
                Width = EParams.Width or 220
            }

            local X = TakeSlot(20)
            local ExtraIcon, ExtraHit = SlotIcon(X, "settings-2")

            local Frame = MakeFrame({
                Parent = Library.UnusedHolder.Instance,
                Size = UDim2.fromOffset(Extra.Width, 38),
                Color = "Section",
                Round = 8,
                Z = 2
            })

            Frame.Instance.Visible = false

            MakeText({
                Parent = Frame.Instance,
                Text = Toggle.Name,
                TextSize = 12,
                Pos = UDim2.fromOffset(12, 8),
                Size = UDim2.fromOffset(Extra.Width - 24, 14),
                Color = "DimText",
                Truncate = true,
                Z = 3
            })

            local ChildDim = MakeFrame({
                Parent = Frame.Instance,
                Size = UDim2.new(1, 0, 1, 0),
                Raw = Color3.new(0, 0, 0),
                Alpha = 1,
                Round = 8,
                Z = 30
            })

            ChildDim.Instance.Visible = false
            Library:StampResting(ChildDim.Instance, "BackgroundTransparency", 1)

            local DimShown = false

            function Extra.SetChildDim(Bool)
                if DimShown == Bool then return end
                DimShown = Bool

                local Info = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                local Target = Bool and 0.5 or 1

                Library:StampResting(ChildDim.Instance, "BackgroundTransparency", Target)

                if Bool then
                    ChildDim.Instance.Visible = true
                end

                Library:Tween({ BackgroundTransparency = Target }, Info, ChildDim.Instance)

                if Bool then return end

                task.delay(0.24, function()
                    if not DimShown then ChildDim.Instance.Visible = false end
                end)
            end

            function Extra:AddRow(Height, SearchName)
                local RowFrame = MakeFrame({
                    Parent = Frame.Instance,
                    Pos = UDim2.fromOffset(0, Extra.NextY),
                    Size = UDim2.fromOffset(Extra.Width, Height),
                    Z = 3
                })

                local Data = {
                    Frame = RowFrame,
                    Height = Height,
                    Y = Extra.NextY,
                    Visible = true,
                    Name = SearchName or Toggle.Name
                }

                Extra.NextY += Height
                Frame.Instance.Size = UDim2.fromOffset(Extra.Width, Extra.NextY + 8)

                return RowFrame, Data
            end

            local function HasOpenChild()
                for _, Value in Library.OpenFrames do
                    if Value.Host == Extra then return true end
                end

                return false
            end

            AttachPopup({
                Popup = Extra,
                Frame = Frame,
                Level = 2,
                GetAnchor = function()
                    return ExtraHit.Instance
                end,
                Place = SidePlace(ExtraIcon.Instance),
                From = -6,
                To = 2,
                Retreat = RetreatLeft,
                KeepOpen = function(Value)
                    return Value == Extra or Value.Host == Extra
                end,
                HoldOpen = HasOpenChild,
                OnClose = function()
                    for _, Value in Library.OpenFrames do
                        if Value.Host == Extra then Value:SetOpen(false) end
                    end
                end
            })

            ExtraHit:Connect("MouseButton1Down", function()
                Extra:SetOpen(not Extra.IsOpen)
            end)

            setmetatable(Extra, {
                __index = function(_, Key)
                    local Builder = Library[Key]
                    if type(Builder) ~= "function" then return nil end

                    return function(SelfArg, BuildParams)
                        local Element = Builder(SelfArg, BuildParams)

                        if type(Element) == "table" then
                            if rawget(Element, "Popup") then Element.Popup.Host = Extra end
                            if rawget(Element, "Picker") then Element.Picker.Host = Extra end
                        end

                        return Element
                    end
                end
            })

            Toggle.ExtraPanel = Extra
            return Extra
        end

        Toggle.Value = Toggle.Default

        if Toggle.Flag then
            Library.Flags[Toggle.Flag] = Toggle.Value

            Library.SetFlags[Toggle.Flag] = function(Value)
                Toggle:Set(Value)
            end
        end

        Toggle.SetVisual(Toggle.Value, true)
        Library:SafeCall(Toggle.Callback, Toggle.Value)

        return setmetatable(Toggle, Library)
    end

    local SlideInfo = TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local KnobColor = Color3.fromRGB(197, 197, 197)

    local function MakeKnob(Parent)
        local Knob = MakeFrame({
            Parent = Parent,
            Anchor = Vector2.new(0.5, 0.5),
            Pos = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.fromOffset(13, 13),
            Raw = KnobColor,
            Round = 20,
            Z = 7
        })

        MakeShadow(Knob.Instance, KnobColor, UDim2.fromOffset(0, 0), UDim.new(0, 5), 0.5)
        return Knob
    end

    local function BuildSliderRow(Section, Name, SearchName)
        local Row = Section:AddRow(44, SearchName or Name)
        local Width = Section.Width
        local TrackW = Width - 30
        local Items = { Row = Row }

        Items.Label = MakeText({
            Parent = Row.Instance,
            Text = Name,
            TextSize = 15,
            Pos = UDim2.fromOffset(15, 3),
            Size = UDim2.fromOffset(Width - 120, 20),
            Color = "Text",
            Truncate = true,
            Z = 5
        })

        Items.Value = MakeText({
            Parent = Row.Instance,
            Text = "",
            TextSize = 15,
            Anchor = Vector2.new(1, 0),
            Pos = UDim2.new(1, -15, 0, 3),
            Size = UDim2.fromOffset(100, 20),
            Color = "DimText",
            Align = Enum.TextXAlignment.Right,
            Truncate = true,
            Z = 5
        })

        Items.Track = MakeFrame({
            Parent = Row.Instance,
            Anchor = Vector2.new(0, 0.5),
            Pos = UDim2.new(0, 15, 0, 32),
            Size = UDim2.fromOffset(TrackW, 10),
            Color = "Element",
            Round = 20,
            Z = 5
        })

        Items.Fill = MakeFrame({
            Parent = Items.Track.Instance,
            Size = UDim2.fromOffset(0, 10),
            Raw = Color3.new(1, 1, 1),
            Round = 20,
            Z = 6
        })

        Library:RegisterGradient(Library:Create("UIGradient", {
            Parent = Items.Fill.Instance
        }).Instance)

        Items.Hit = MakeButton({
            Parent = Row.Instance,
            Pos = UDim2.fromOffset(9, 22),
            Size = UDim2.fromOffset(TrackW + 12, 22),
            Z = 8
        })

        Items.TrackWidth = TrackW
        return Items
    end

    Library.Slider = function(Self, Params)
        Params = Params or { }

        local Section = Self

        local Slider = {
            Name = Params.Name or "Slider",
            Min = Params.Min or 0,
            Max = Params.Max or 100,
            Default = Params.Default or 0,
            Decimals = Params.Decimals or 1,
            Suffix = Params.Suffix or "",
            Flag = Params.Flag,
            Callback = Params.Callback or function() end,
            Value = 0,
            Sliding = false
        }

        local Items = BuildSliderRow(Section, Slider.Name)
        local TrackW = Items.TrackWidth

        Slider.Items = Items
        Items.Knob = MakeKnob(Items.Track.Instance)

        function Slider:Set(Value, Instant)
            local Clamped = math.clamp(Value, Slider.Min, Slider.Max)
            Slider.Value = Library:Round(Clamped, Slider.Decimals)

            if Slider.Flag then
                Library.Flags[Slider.Flag] = Slider.Value
            end

            local Span = Slider.Max - Slider.Min
            local Fraction = Span == 0 and 0 or (Slider.Value - Slider.Min) / Span
            local Info = Instant and TweenInfo.new(0) or SlideInfo

            Library:Tween({ Size = UDim2.fromOffset(Fraction * TrackW, 10) }, Info, Items.Fill.Instance)
            Library:Tween({ Position = UDim2.new(Fraction, 0, 0.5, 0) }, Info, Items.Knob.Instance)

            Items.Value.Instance.Text = tostring(Slider.Value) .. Slider.Suffix
            Library:SafeCall(Slider.Callback, Slider.Value)
        end

        function Slider:Get()
            return Slider.Value
        end

        local function Calculate(Input)
            local Fraction = AxisFraction(Input, Items.Track.Instance, "X")
            return Slider.Min + (Slider.Max - Slider.Min) * Fraction
        end

        local function Apply(Input)
            Slider:Set(Calculate(Input))
        end

        AttachDrag(Items.Hit, {
            OnGrab = function(Input)
                Slider.Sliding = true
                Apply(Input)
            end,
            OnMove = Apply,
            OnRelease = function()
                Slider.Sliding = false
            end
        })

        Slider:Set(Slider.Default, true)

        if Slider.Flag then
            Library.SetFlags[Slider.Flag] = function(Value)
                Slider:Set(Value)
            end
        end

        return setmetatable(Slider, Library)
    end

    Library.RangeSlider = function(Self, Params)
        Params = Params or { }

        local Section = Self

        local Slider = {
            Name = Params.Name or "Range",
            Min = Params.Min or 0,
            Max = Params.Max or 100,
            Default = Params.Default,
            Decimals = Params.Decimals or 1,
            Suffix = Params.Suffix or "",
            Flag = Params.Flag,
            Callback = Params.Callback or function() end,
            Value = { 0, 0 },
            Grabbing = nil
        }

        Slider.MinGap = Params.MinGap or Slider.Decimals
        Slider.Default = Slider.Default or { Slider.Min, Slider.Max }

        local Items = BuildSliderRow(Section, Slider.Name)
        local TrackW = Items.TrackWidth

        Slider.Items = Items
        Items.MinKnob = MakeKnob(Items.Track.Instance)
        Items.MaxKnob = MakeKnob(Items.Track.Instance)

        local function Normalize(Value)
            local Span = Slider.Max - Slider.Min
            return Span == 0 and 0 or (Value - Slider.Min) / Span
        end

        function Slider:Set(MinValue, MaxValue, Instant)
            if type(MinValue) == "table" then
                MinValue, MaxValue = MinValue[1], MinValue[2]
            end

            MinValue = math.clamp(MinValue or Slider.Min, Slider.Min, Slider.Max)
            MaxValue = math.clamp(MaxValue or Slider.Max, Slider.Min, Slider.Max)

            MinValue = Library:Round(MinValue, Slider.Decimals)
            MaxValue = Library:Round(MaxValue, Slider.Decimals)

            if MinValue > MaxValue then
                MinValue, MaxValue = MaxValue, MinValue
            end

            Slider.Value = { MinValue, MaxValue }

            if Slider.Flag then
                Library.Flags[Slider.Flag] = Slider.Value
            end

            local MinF = Normalize(MinValue)
            local MaxF = Normalize(MaxValue)
            local Info = Instant and TweenInfo.new(0) or SlideInfo

            Library:Tween({
                Position = UDim2.fromOffset(MinF * TrackW, 0),
                Size = UDim2.fromOffset((MaxF - MinF) * TrackW, 10)
            }, Info, Items.Fill.Instance)

            Library:Tween({ Position = UDim2.new(MinF, 0, 0.5, 0) }, Info, Items.MinKnob.Instance)
            Library:Tween({ Position = UDim2.new(MaxF, 0, 0.5, 0) }, Info, Items.MaxKnob.Instance)

            local Text = tostring(MinValue) .. Slider.Suffix
            Text = Text .. " - " .. tostring(MaxValue) .. Slider.Suffix

            Items.Value.Instance.Text = Text
            Library:SafeCall(Slider.Callback, Slider.Value)
        end

        function Slider:Get()
            return Slider.Value
        end

        local function Apply(Input)
            local Point = AxisFraction(Input, Items.Track.Instance, "X")
            local Value = Slider.Min + (Slider.Max - Slider.Min) * Point

            if Slider.Grabbing == "Min" then
                Slider:Set(math.min(Value, Slider.Value[2] - Slider.MinGap), Slider.Value[2])
            else
                Slider:Set(Slider.Value[1], math.max(Value, Slider.Value[1] + Slider.MinGap))
            end
        end

        AttachDrag(Items.Hit, {
            OnGrab = function(Input)
                local Point = AxisFraction(Input, Items.Track.Instance, "X")
                local MinF = Normalize(Slider.Value[1])
                local MaxF = Normalize(Slider.Value[2])

                Slider.Grabbing = math.abs(Point - MinF) <= math.abs(Point - MaxF) and "Min" or "Max"
                Apply(Input)
            end,
            OnMove = Apply,
            OnRelease = function()
                Slider.Grabbing = nil
            end
        })

        Slider:Set(Slider.Default[1], Slider.Default[2], true)

        if Slider.Flag then
            Library.SetFlags[Slider.Flag] = function(Value)
                Slider:Set(Value)
            end
        end

        return setmetatable(Slider, Library)
    end

    local function MakeFieldRow(Section, Name, SearchName)
        local Row = Section:AddRow(54, SearchName or Name)
        local Items = { Row = Row }

        Items.Label = MakeText({
            Parent = Row.Instance,
            Text = Name,
            TextSize = 15,
            Pos = UDim2.fromOffset(15, 4),
            Size = UDim2.fromOffset(Section.Width - 30, 18),
            Color = "DimText",
            Truncate = true,
            Z = 5
        })

        Items.Box = MakeFrame({
            Parent = Row.Instance,
            Pos = UDim2.fromOffset(15, 24),
            Size = UDim2.fromOffset(Section.Width - 30, 30),
            Color = "Element",
            Round = 6,
            Clip = true,
            Z = 5
        })

        return Items
    end

    local function MakeSweep(Parent, Z)
        local Sweep = MakeFrame({
            Parent = Parent,
            Anchor = Vector2.new(0.5, 0.5),
            Pos = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 0, 1, 0),
            Color = "Accent",
            Round = 6,
            Z = Z
        })

        Sweep.Instance.BackgroundTransparency = 1
        Library:StampResting(Sweep.Instance, "BackgroundTransparency", 1)

        return Sweep
    end

    local function PlaySweep(Sweep)
        local In = TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        local Out = TweenInfo.new(0.32, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

        Sweep.Size = UDim2.new(0, 0, 1, 0)
        Sweep.BackgroundTransparency = 1

        Library:Tween({
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 0.15
        }, In, Sweep)

        task.delay(0.17, function()
            Library:Tween({
                Size = UDim2.new(0, 0, 1, 0),
                BackgroundTransparency = 1
            }, Out, Sweep)
        end)
    end

    local function HoverSwap(Frame)
        Frame:OnHover(function()
            Frame:Tween({ BackgroundColor3 = Library.Theme.Hover })
        end, function()
            Frame:Tween({ BackgroundColor3 = Library.Theme.Element })
        end)
    end

    Library.Dropdown = function(Self, Params)
        Params = Params or { }

        local Section = Self

        local Dropdown = {
            Name = Params.Name or "Dropdown",
            Options = Params.Items or Params.Options or { },
            Default = Params.Default,
            Multi = Params.Multi or false,
            Flag = Params.Flag,
            Callback = Params.Callback or function() end,
            Value = nil,
            Items = { }
        }

        if Dropdown.Multi then
            Dropdown.Value = { }
        end

        local Items = MakeFieldRow(Section, Dropdown.Name)

        Items.Selected = MakeText({
            Parent = Items.Box.Instance,
            Text = "None",
            TextSize = 15,
            Pos = UDim2.fromOffset(11, 0),
            Size = UDim2.new(1, -34, 1, 0),
            Color = "Text",
            Truncate = true,
            Z = 6
        })

        Items.Arrow = MakeImage({
            Parent = Items.Box.Instance,
            Icon = "chevron-down",
            Anchor = Vector2.new(1, 0.5),
            Pos = UDim2.new(1, -10, 0.5, 0),
            Size = UDim2.fromOffset(14, 14),
            Color = "DimText",
            Z = 6
        })

        Items.Hit = MakeButton({
            Parent = Items.Box.Instance,
            Z = 7
        })

        Dropdown.Items = Items

        local Popup = MakeOptionPopup(function()
            return Items.Box.Instance
        end)

        Popup.OnState = function(Open)
            Items.Arrow:Tween({ Rotation = Open and 180 or 0 })
        end

        Dropdown.Popup = Popup

        local function Report()
            if Dropdown.Flag then
                Library.Flags[Dropdown.Flag] = Dropdown.Value
            end

            if Dropdown.Multi then
                Items.Selected.Instance.Text = #Dropdown.Value > 0
                and table.concat(Dropdown.Value, ", ")
                or "None"
            else
                Items.Selected.Instance.Text = Dropdown.Value ~= nil
                and tostring(Dropdown.Value)
                or "None"
            end

            Library:SafeCall(Dropdown.Callback, Dropdown.Value)
        end

        Popup.OnPick = function(Data)
            if Dropdown.Multi then
                local Index = table.find(Dropdown.Value, Data.Name)

                if Index then
                    table.remove(Dropdown.Value, Index)
                    Data:Set(false)
                else
                    table.insert(Dropdown.Value, Data.Name)
                    Data:Set(true)
                end
            else
                Dropdown.Value = Data.Name

                for _, Other in Popup.Order do
                    Other:Set(Other == Data)
                end
            end

            Report()
            if not Dropdown.Multi then
                Popup:SetOpen(false)
            end
        end

        function Dropdown:Refresh(List, Icons)
            Popup:Clear()
            Dropdown.Options = List

            for _, Option in List do
                Popup:AddRow(tostring(Option), Icons and Icons[tostring(Option)])
            end

            if not Dropdown.Multi and Dropdown.Value ~= nil then
                local Current = Dropdown.Value
                Dropdown.Value = nil
                Dropdown:Set(Current)
            end
        end

        function Dropdown:Set(Value)
            if Dropdown.Multi then
                if type(Value) ~= "table" then return end

                Dropdown.Value = Value

                for _, Data in Popup.Order do
                    Data:Set(table.find(Value, Data.Name) ~= nil, true)
                end
            else
                local Found = false

                for _, Data in Popup.Order do
                    if Data.Name == Value then Found = true end
                end

                if not Found then return end

                Dropdown.Value = Value

                for _, Data in Popup.Order do
                    Data:Set(Data.Name == Value, true)
                end
            end

            Report()
        end

        function Dropdown:Get()
            return Dropdown.Value
        end

        Items.Hit:Connect("MouseButton1Down", function()
            Popup:SetOpen(not Popup.IsOpen)
        end)

        HoverSwap(Items.Box)

        for _, Option in Dropdown.Options do
            Popup:AddRow(tostring(Option))
        end

        if Dropdown.Default ~= nil then
            Dropdown:Set(Dropdown.Default)
        end

        if Dropdown.Flag then
            Library.SetFlags[Dropdown.Flag] = function(Value)
                Dropdown:Set(Value)
            end
        end

        return setmetatable(Dropdown, Library)
    end

    Library.Button = function(Self, Params)
        Params = Params or { }

        local Section = Self

        local Button = {
            Name = Params.Name or "Button",
            Callback = Params.Callback or function() end,
            Items = { }
        }

        local Row = Section:AddRow(36, Button.Name)
        local Items = { Row = Row }

        Items.Frame = MakeFrame({
            Parent = Row.Instance,
            Pos = UDim2.fromOffset(15, 3),
            Size = UDim2.fromOffset(Section.Width - 30, 30),
            Color = "Element",
            Round = 6,
            Clip = true,
            Z = 5
        })

        Items.Sweep = MakeSweep(Items.Frame.Instance, 6)

        Items.Label = MakeText({
            Parent = Items.Frame.Instance,
            Text = Button.Name,
            TextSize = 15,
            Size = UDim2.new(1, 0, 1, 0),
            Color = "Text",
            Align = Enum.TextXAlignment.Center,
            Truncate = true,
            Z = 7
        })

        Items.Hit = MakeButton({
            Parent = Items.Frame.Instance,
            Z = 8
        })

        Button.Items = Items
        HoverSwap(Items.Frame)

        function Button:Press()
            PlaySweep(Items.Sweep.Instance)
            Library:SafeCall(Button.Callback)
        end

        function Button:SetText(Text)
            Items.Label.Instance.Text = tostring(Text)
        end

        Items.Hit:Connect("MouseButton1Down", function()
            Button:Press()
        end)

        return setmetatable(Button, Library)
    end

    Library.Textbox = function(Self, Params)
        Params = Params or { }

        local Section = Self

        local Textbox = {
            Name = Params.Name or "Textbox",
            Default = Params.Default or "",
            Placeholder = Params.Placeholder or "...",
            Finished = Params.Finished or false,
            Flag = Params.Flag,
            Callback = Params.Callback or function() end,
            Value = "",
            Items = { }
        }

        local Items = MakeFieldRow(Section, Textbox.Name)

        Items.Input = MakeInput({
            Parent = Items.Box.Instance,
            Placeholder = Textbox.Placeholder,
            Pos = UDim2.fromOffset(11, 0),
            Size = UDim2.new(1, -22, 1, 0),
            TextSize = 15,
            Z = 6
        })

        Textbox.Items = Items

        function Textbox:Set(Value)
            Textbox.Value = tostring(Value)
            Items.Input.Instance.Text = Textbox.Value

            if Textbox.Flag then
                Library.Flags[Textbox.Flag] = Textbox.Value
            end

            Library:SafeCall(Textbox.Callback, Textbox.Value)
        end

        function Textbox:Get()
            return Textbox.Value
        end

        if Textbox.Finished then
            Items.Input:Connect("FocusLost", function(Enter)
                if Enter then
                    Textbox:Set(Items.Input.Instance.Text)
                end
            end)
        else
            Library:Connect(Items.Input.Instance:GetPropertyChangedSignal("Text"), function()
                Textbox:Set(Items.Input.Instance.Text)
            end)
        end

        if Textbox.Default ~= "" then
            Textbox:Set(Textbox.Default)
        end

        if Textbox.Flag then
            Library.SetFlags[Textbox.Flag] = function(Value)
                Textbox:Set(Value)
            end
        end

        return setmetatable(Textbox, Library)
    end

    Library.Keybind = function(Self, Params)
        Params = Params or { }

        local Section = Self

        local Keybind = {
            Name = Params.Name or "Keybind",
            Key = Params.Default,
            Flag = Params.Flag,
            Callback = Params.Callback or function() end,
            Picking = false,
            IsOpen = false,
            Debounce = false,
            Items = { }
        }

        local Row = Section:AddRow(32, Keybind.Name)
        local Items = { Row = Row }

        Items.Label = MakeText({
            Parent = Row.Instance,
            Text = Keybind.Name,
            TextSize = 15,
            Anchor = Vector2.new(0, 0.5),
            Pos = UDim2.new(0, 14, 0.5, 0),
            Size = UDim2.fromOffset(Section.Width - 60, 20),
            Color = "Text",
            Truncate = true,
            Z = 5
        })

        Items.Icon = MakeImage({
            Parent = Row.Instance,
            Icon = "command",
            Anchor = Vector2.new(1, 0.5),
            Pos = UDim2.new(1, -16, 0.5, 0),
            Size = UDim2.fromOffset(16, 16),
            Color = "DimText",
            Z = 6
        })

        Items.Hit = MakeButton({
            Parent = Row.Instance,
            Anchor = Vector2.new(1, 0.5),
            Pos = UDim2.new(1, -8, 0.5, 0),
            Size = UDim2.fromOffset(30, 26),
            Z = 8
        })

        Items.Hit:OnHover(function()
            Items.Icon:Tween({ ImageColor3 = Library.Theme.Text })
        end, function()
            Items.Icon:Tween({ ImageColor3 = Library.Theme.DimText })
        end)

        Keybind.Items = Items

        local PanelW = 170

        local Panel = MakeFrame({
            Parent = Library.UnusedHolder.Instance,
            Size = UDim2.fromOffset(PanelW, 72),
            Color = "Section",
            Round = 8,
            Z = 40
        })

        Panel.Instance.Visible = false

        MakeText({
            Parent = Panel.Instance,
            Text = Keybind.Name,
            TextSize = 12,
            Pos = UDim2.fromOffset(11, 8),
            Size = UDim2.fromOffset(PanelW - 22, 14),
            Color = "DimText",
            Truncate = true,
            Z = 41
        })

        local KeyBox = MakeFrame({
            Parent = Panel.Instance,
            Pos = UDim2.fromOffset(9, 32),
            Size = UDim2.fromOffset(PanelW - 18, 30),
            Color = "Light",
            Round = 5,
            Clip = true,
            Z = 41
        })

        local PanelKey = MakeText({
            Parent = KeyBox.Instance,
            Text = "None",
            TextSize = 13,
            Size = UDim2.new(1, 0, 1, 0),
            Color = "Text",
            Align = Enum.TextXAlignment.Center,
            Truncate = true,
            Z = 42
        })

        local KeyHit = MakeButton({
            Parent = KeyBox.Instance,
            Z = 43
        })

        function Keybind:Set(Key)
            Keybind.Key = Key
            PanelKey.Instance.Text = KeyName(Key)
            Keybind.Picking = false

            if Keybind.Flag then
                Library.Flags[Keybind.Flag] = Key and tostring(Key) or "None"
            end
        end

        function Keybind:Get()
            return Keybind.Key
        end

        AttachPopup({
            Popup = Keybind,
            Frame = Panel,
            Level = 40,
            GetAnchor = function()
                return Items.Hit.Instance
            end,
            Place = function(Off)
                local Anchor = Items.Icon.Instance
                local PScale = Library:GetScreenScale()
                local Right = Anchor.AbsolutePosition.X + Anchor.AbsoluteSize.X
                local PX = Right / PScale + 8 + (Off or 0)
                local PY = (Anchor.AbsolutePosition.Y + GuiInset) / PScale - 4

                return UDim2.fromOffset(PX, PY)
            end,
            From = -6,
            To = 2,
            Retreat = RetreatLeft
        })

        Items.Hit:Connect("MouseButton1Down", function()
            Keybind:SetOpen(not Keybind.IsOpen)
        end)

        KeyHit:Connect("MouseButton1Click", function()
            CaptureKey(Keybind, PanelKey.Instance, function(Key)
                Keybind:Set(Key)
            end)
        end)

        Library:Connect(UserInputService.InputBegan, function(Input, Processed)
            if Processed or Keybind.Picking or not Keybind.Key then return end
            if not KeyMatches(Input, Keybind.Key) then return end

            Library:SafeCall(Keybind.Callback, Keybind.Key)
        end)

        Keybind:Set(Keybind.Key)

        if Keybind.Flag then
            Library.SetFlags[Keybind.Flag] = function(Value)
                Keybind:Set(ParseKey(Value))
            end
        end

        return setmetatable(Keybind, Library)
    end

    Library.Colorpicker = function(Self, Params)
        Params = Params or { }

        local Section = Self

        local Colorpicker = {
            Name = Params.Name or "Color",
            Default = Params.Default or Library.Theme.Accent,
            Transparency = Params.Transparency or 0,
            Flag = Params.Flag,
            Callback = Params.Callback or function() end,
            Color = Params.Default or Library.Theme.Accent,
            Items = { }
        }

        local Row = Section:AddRow(32, Colorpicker.Name)
        local Items = { Row = Row }

        Items.Label = MakeText({
            Parent = Row.Instance,
            Text = Colorpicker.Name,
            TextSize = 15,
            Anchor = Vector2.new(0, 0.5),
            Pos = UDim2.new(0, 14, 0.5, 0),
            Size = UDim2.fromOffset(Section.Width - 60, 20),
            Color = "Text",
            Truncate = true,
            Z = 5
        })

        Items.Swatch = MakeSwatch(Row.Instance, -13, Colorpicker.Default, 5)
        Colorpicker.Items = Items

        local Picker = MakeColorPopup(function()
            return Items.Swatch.Halo.Instance
        end, Colorpicker.Name, Colorpicker.Default, Colorpicker.Transparency, function(Color, Alpha)
            Colorpicker.Color = Color
            Colorpicker.Transparency = Alpha
            Items.Swatch:SetColor(Color, Alpha)

            if Colorpicker.Flag then
                Library.Flags[Colorpicker.Flag] = {
                    __color = Color:ToHex(),
                    __alpha = Alpha
                }
            end

            Library:SafeCall(Colorpicker.Callback, Color, Alpha)
        end)

        Colorpicker.Picker = Picker

        function Colorpicker:Set(Color, Alpha)
            Picker:Set(Color, Alpha)
        end

        function Colorpicker:Get()
            return Colorpicker.Color, Colorpicker.Transparency
        end

        Items.Swatch.Hit:Connect("MouseButton1Down", function()
            Picker:SetOpen(not Picker.IsOpen)
        end)

        if Colorpicker.Flag then
            Library.SetFlags[Colorpicker.Flag] = function(Color, Alpha)
                Picker:Set(Color, Alpha)
            end
        end

        return setmetatable(Colorpicker, Library)
    end

    Library.Label = function(Self, Params)
        Params = Params or { }

        local Section = Self

        local Label = {
            Name = Params.Name or "Label",
            Items = { }
        }

        local Row = Section:AddRow(24, Label.Name)

        Label.Items.Text = MakeText({
            Parent = Row.Instance,
            Text = Label.Name,
            TextSize = 15,
            Anchor = Vector2.new(0, 0.5),
            Pos = UDim2.new(0, 14, 0.5, 0),
            Size = UDim2.fromOffset(Section.Width - 28, 20),
            Color = "DimText",
            Truncate = true,
            Z = 5
        })

        function Label:Set(Text)
            Label.Items.Text.Instance.Text = tostring(Text)
        end

        return setmetatable(Label, Library)
    end

    Library.Paragraph = function(Self, Params)
        Params = Params or { }

        local Section = Self

        local Paragraph = {
            Title = Params.Title or Params.Name or "Paragraph",
            Content = Params.Content or "",
            Items = { }
        }

        local Width = Section.Width - 28
        local TitleBounds = MeasureText(Paragraph.Title, 15, Width, UiFont)
        local BodyBounds = MeasureText(Paragraph.Content, 14, Width, UiFont)
        local Total = TitleBounds.Y + BodyBounds.Y + 16

        local Row = Section:AddRow(Total, Paragraph.Title .. " " .. Paragraph.Content)

        local function Block(Text, TextSize, Y, Height, Color)
            local Item = MakeText({
                Parent = Row.Instance,
                Text = Text,
                TextSize = TextSize,
                Pos = UDim2.fromOffset(14, Y),
                Size = UDim2.fromOffset(Width, Height),
                Color = Color,
                Wrap = true,
                Z = 5
            })

            Item.Instance.TextYAlignment = Enum.TextYAlignment.Top
            return Item
        end

        Paragraph.Items.Title = Block(Paragraph.Title, 15, 6, TitleBounds.Y, "Text")
        Paragraph.Items.Body = Block(Paragraph.Content, 14, TitleBounds.Y + 8, BodyBounds.Y, "DimText")

        function Paragraph:SetTitle(Text)
            Paragraph.Items.Title.Instance.Text = tostring(Text)
        end

        function Paragraph:SetContent(Text)
            Paragraph.Items.Body.Instance.Text = tostring(Text)
        end

        return setmetatable(Paragraph, Library)
    end

    Library.ThemeConfig = function(Self, Params)
        Params = Params or { }

        local SubTab = Self
        local Window = SubTab.Window
        local Page = SubTab.Items.Page
        local ContentH = Window.ContentH
        local ColW = Window.ColW
        local Col2X = Window.Col2X

        SubTab.Columns[1].Scroll.Instance.Visible = false
        SubTab.Columns[2].Scroll.Instance.Visible = false

        local Config = {
            Rows = { },
            Selected = nil,
            IntroToken = 0,
            Items = { }
        }

        local Items = Config.Items

        local function ConfigPath(Name)
            return Library.ConfigFolder .. "/" .. Name .. ".json"
        end

        Items.CreateBox = MakeFrame({
            Parent = Page.Instance,
            Pos = UDim2.fromOffset(0, 0),
            Size = UDim2.fromOffset(ColW, 40),
            Z = 3
        })

        Items.NameBox = MakeFrame({
            Parent = Items.CreateBox.Instance,
            Size = UDim2.fromOffset(ColW - 94, 40),
            Color = "Element",
            Round = 6,
            Clip = true,
            Z = 4
        })

        MakeImage({
            Parent = Items.NameBox.Instance,
            Icon = "pencil",
            Anchor = Vector2.new(0, 0.5),
            Pos = UDim2.new(0, 12, 0.5, 0),
            Size = UDim2.fromOffset(14, 14),
            Color = "DimText",
            Z = 5
        })

        Items.NameInput = MakeInput({
            Parent = Items.NameBox.Instance,
            Placeholder = "config name",
            Pos = UDim2.fromOffset(34, 0),
            Size = UDim2.new(1, -44, 1, 0),
            TextSize = 15,
            Z = 5
        })

        Items.Create = MakeFrame({
            Parent = Items.CreateBox.Instance,
            Anchor = Vector2.new(1, 0),
            Pos = UDim2.new(1, 0, 0, 0),
            Size = UDim2.fromOffset(84, 40),
            Color = "Element",
            Round = 6,
            Clip = true,
            Z = 4
        })

        HoverSwap(Items.Create)
        Items.CreateSweep = MakeSweep(Items.Create.Instance, 5)

        MakeText({
            Parent = Items.Create.Instance,
            Text = "Create",
            TextSize = 15,
            Size = UDim2.new(1, 0, 1, 0),
            Color = "Text",
            Align = Enum.TextXAlignment.Center,
            Z = 6
        })

        Items.CreateHit = MakeButton({
            Parent = Items.Create.Instance,
            Z = 7
        })

        Items.ListHolder = MakeFrame({
            Parent = Page.Instance,
            Pos = UDim2.fromOffset(0, 52),
            Size = UDim2.fromOffset(ColW, ContentH - 52),
            Z = 3
        })

        Items.List = Library:Create("ScrollingFrame", {
            Parent = Items.ListHolder.Instance,
            Name = "\0",
            BackgroundTransparency = 1,
            ScrollBarThickness = 0,
            ScrollBarImageTransparency = 1,
            Selectable = false,
            Active = true,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.fromOffset(0, 0),
            ZIndex = 3,
            BorderSizePixel = 0
        })

        Library:Create("UIListLayout", {
            Parent = Items.List.Instance,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8)
        })

        Items.InfoPanel = MakeFrame({
            Parent = Page.Instance,
            Pos = UDim2.fromOffset(Col2X, 0),
            Size = UDim2.fromOffset(ColW, 204),
            Color = "Section",
            Round = 10,
            Z = 3
        })

        MakeText({
            Parent = Items.InfoPanel.Instance,
            Text = "Config info",
            TextSize = 15,
            Pos = UDim2.fromOffset(14, 12),
            Size = UDim2.fromOffset(ColW - 28, 20),
            Color = "Text",
            Z = 4
        })

        local InfoRows = { }

        local function InfoRow(Index, Icon, Label)
            local Y = 44 + (Index - 1) * 32

            MakeImage({
                Parent = Items.InfoPanel.Instance,
                Icon = Icon,
                Pos = UDim2.fromOffset(14, Y + 3),
                Size = UDim2.fromOffset(14, 14),
                Color = "DimIcon",
                Z = 4
            })

            MakeText({
                Parent = Items.InfoPanel.Instance,
                Text = Label,
                TextSize = 15,
                Pos = UDim2.fromOffset(36, Y),
                Size = UDim2.fromOffset(ColW - 170, 20),
                Color = "DimText",
                Z = 4
            })

            local Value = MakeText({
                Parent = Items.InfoPanel.Instance,
                Text = "-",
                TextSize = 15,
                Anchor = Vector2.new(1, 0),
                Pos = UDim2.new(1, -14, 0, Y),
                Size = UDim2.fromOffset(150, 20),
                Color = "Text",
                Align = Enum.TextXAlignment.Right,
                Truncate = true,
                Z = 4
            })

            if Index < 5 then
                MakeFrame({
                    Parent = Items.InfoPanel.Instance,
                    Pos = UDim2.fromOffset(14, Y + 27),
                    Size = UDim2.fromOffset(ColW - 28, 1),
                    Color = "Element",
                    Z = 4
                })
            end

            return Value
        end

        InfoRows.Version = InfoRow(1, "layers", "Config version")
        InfoRows.Compatible = InfoRow(2, "link", "Compatibility")
        InfoRows.Created = InfoRow(3, "clock", "Created")
        InfoRows.Creator = InfoRow(4, "user", "Creator")
        InfoRows.Elements = InfoRow(5, "box", "Saved flags")

        local function ShowInfo(Name)
            if not Name then
                for _, Value in InfoRows do
                    Value.Instance.Text = "-"
                end

                return
            end

            local Data = { }

            pcall(function()
                Data = HttpService:JSONDecode(readfile(ConfigPath(Name)))
            end)

            local Count = 0

            for Key in Data do
                if string.sub(Key, 1, 2) ~= "__" then
                    Count += 1
                end
            end

            local Same = Data.__version == Library.Version

            InfoRows.Version.Instance.Text = Data.__version or "Unknown"
            InfoRows.Compatible.Instance.Text = Same and "Compatible" or "Outdated"
            InfoRows.Created.Instance.Text = Data.__created or "Unknown"
            InfoRows.Creator.Instance.Text = Data.__creator or "Unknown"
            InfoRows.Elements.Instance.Text = tostring(Count) .. " flags"
        end

        Items.ThemePanel = MakeFrame({
            Parent = Page.Instance,
            Pos = UDim2.fromOffset(Col2X, 216),
            Size = UDim2.fromOffset(ColW, 194),
            Color = "Section",
            Round = 10,
            Z = 3
        })

        MakeText({
            Parent = Items.ThemePanel.Instance,
            Text = "Theme",
            TextSize = 15,
            Pos = UDim2.fromOffset(14, 8),
            Size = UDim2.fromOffset(ColW - 28, 20),
            Color = "Text",
            Z = 4
        })

        local RefreshThemeUI
        local PresetDots = { }

        local function SelectPreset(Target)
            for _, Dot in PresetDots do
                Library:Tween({ Thickness = Dot == Target and 2 or 0 }, nil, Dot.Ring.Instance)
            end
        end

        MakeText({
            Parent = Items.ThemePanel.Instance,
            Text = "Presets",
            TextSize = 15,
            Pos = UDim2.fromOffset(14, 34),
            Size = UDim2.fromOffset(100, 20),
            Color = "DimText",
            Z = 4
        })

        for Index, Preset in Library.ThemePresets do
            local Dot = MakeFrame({
                Parent = Items.ThemePanel.Instance,
                Anchor = Vector2.new(1, 0),
                Pos = UDim2.new(1, -14 - (#Library.ThemePresets - Index) * 28, 0, 35),
                Size = UDim2.fromOffset(18, 18),
                Raw = Preset.Swatch or Preset.Accent,
                Round = 20,
                Z = 4
            })

            Dot.Ring = Library:Create("UIStroke", {
                Parent = Dot.Instance,
                Color = Color3.new(1, 1, 1),
                Thickness = 0
            })

            local Hit = MakeButton({
                Parent = Dot.Instance,
                Z = 5
            })

            Hit:Connect("MouseButton1Down", function()
                Library:SetTheme(Preset)
                SelectPreset(Dot)

                if RefreshThemeUI then
                    RefreshThemeUI()
                end
            end)

            table.insert(PresetDots, Dot)
        end

        PresetDots[1].Ring.Instance.Thickness = 2

        local ThemeCells = {
            { "Background", "Background" },
            { "Section", "Sections" },
            { "Element", "Elements" },
            { "Light", "Boxes" },
            { "Text", "Text" },
            { "DimText", "Dim text" }
        }

        local ThemeCellList = { }
        local CellW = math.floor((ColW - 42) / 2)

        for Index, Entry in ThemeCells do
            local Key = Entry[1]
            local CellX = 14 + ((Index - 1) % 2) * (CellW + 14)
            local CellY = 66 + math.floor((Index - 1) / 2) * 30

            MakeText({
                Parent = Items.ThemePanel.Instance,
                Text = Entry[2],
                TextSize = 15,
                Pos = UDim2.fromOffset(CellX, CellY),
                Size = UDim2.fromOffset(CellW - 28, 20),
                Color = "DimText",
                Truncate = true,
                Z = 4
            })

            local Swatch = MakeSwatch(Items.ThemePanel.Instance, 0, Library.Theme[Key], 4)

            Swatch.Halo.Instance.AnchorPoint = Vector2.new(0, 0)
            Swatch.Halo.Instance.Position = UDim2.fromOffset(CellX + CellW - 22, CellY - 1)

            local CellPicker = MakeColorPopup(function()
                return Swatch.Halo.Instance
            end, Entry[2], Library.Theme[Key], 0, function(Color)
                Swatch:SetColor(Color)
                Library:SetThemeColor(Key, Color)
            end)

            Swatch.Hit:Connect("MouseButton1Down", function()
                CellPicker:SetOpen(not CellPicker.IsOpen)
            end)

            table.insert(ThemeCellList, {
                Key = Key,
                Swatch = Swatch,
                Picker = CellPicker
            })
        end

        MakeText({
            Parent = Items.ThemePanel.Instance,
            Text = "Accent",
            TextSize = 15,
            Pos = UDim2.fromOffset(14, 160),
            Size = UDim2.fromOffset(ColW - 60, 20),
            Color = "DimText",
            Truncate = true,
            Z = 4
        })

        Items.Swatch = MakeSwatch(Items.ThemePanel.Instance, -14, Library.Theme.Accent, 4)
        Items.Swatch.Halo.Instance.AnchorPoint = Vector2.new(1, 0.5)
        Items.Swatch.Halo.Instance.Position = UDim2.new(1, -14, 0, 170)

        local Picker = MakeColorPopup(function()
            return Items.Swatch.Halo.Instance
        end, "Accent", Library.Theme.Accent, 0, function(Color)
            Items.Swatch:SetColor(Color)
            Library:SetAccent(Color)
        end)

        Items.Swatch.Hit:Connect("MouseButton1Down", function()
            Picker:SetOpen(not Picker.IsOpen)
        end)

        RefreshThemeUI = function()
            Items.Swatch:SetColor(Library.Theme.Accent)
            Picker:Set(Library.Theme.Accent, 0, true)

            for _, Cell in ThemeCellList do
                Cell.Swatch:SetColor(Library.Theme[Cell.Key])
                Cell.Picker:Set(Library.Theme[Cell.Key], 0, true)
            end
        end

        local RefreshList

        local function AddRow(Index, Name)
            local Slot = MakeFrame({
                Parent = Items.List.Instance,
                Size = UDim2.fromOffset(ColW, 44),
                Clip = true,
                Z = 4
            })

            Slot.Instance.LayoutOrder = Index

            local Row = MakeFrame({
                Parent = Slot.Instance,
                Size = UDim2.fromOffset(ColW, 44),
                Color = "Section",
                Round = 8,
                Z = 4
            })

            local Bar = MakeFrame({
                Parent = Row.Instance,
                Anchor = Vector2.new(0, 0.5),
                Pos = UDim2.new(0, 0, 0.5, 0),
                Size = UDim2.fromOffset(3, 0),
                Color = "Accent",
                Round = 4,
                Z = 6
            })

            local BarShadow = MakeAccentShadow(
                Bar.Instance,
                UDim2.fromOffset(3, 15),
                UDim.new(0, 10),
                0
            )

            if BarShadow then
                SetRest(BarShadow, "Transparency", 1)
            end

            local Label = MakeText({
                Parent = Row.Instance,
                Text = Name,
                TextSize = 15,
                Anchor = Vector2.new(0, 0.5),
                Pos = UDim2.new(0, 15, 0.5, 0),
                Size = UDim2.fromOffset(ColW - 130, 20),
                Color = "DimText",
                Truncate = true,
                Z = 5
            })

            local Data = {
                Name = Name,
                Slot = Slot,
                Row = Row
            }

            local function IconButton(Offset, Icon, Callback)
                local Image = MakeImage({
                    Parent = Row.Instance,
                    Icon = Icon,
                    Anchor = Vector2.new(1, 0.5),
                    Pos = UDim2.new(1, Offset, 0.5, 0),
                    Size = UDim2.fromOffset(15, 15),
                    Color = "DimText",
                    Z = 5
                })

                local Hit = MakeButton({
                    Parent = Row.Instance,
                    Anchor = Vector2.new(1, 0.5),
                    Pos = UDim2.new(1, Offset + 7, 0.5, 0),
                    Size = UDim2.fromOffset(28, 28),
                    Z = 6
                })

                Hit:OnHover(function()
                    Image:Tween({ ImageColor3 = Library.Theme.Text })
                end, function()
                    Image:Tween({ ImageColor3 = Library.Theme.DimText })
                end)

                Hit:Connect("MouseButton1Down", Callback)
            end

            IconButton(-66, "download", function()
                local Created

                pcall(function()
                    Created = HttpService:JSONDecode(readfile(ConfigPath(Name))).__created
                end)

                writefile(ConfigPath(Name), Library:GetConfig(Created))
                ShowInfo(Name)

                Library:Notification({
                    Name = "Config saved",
                    Description = "Current values were written into \"" .. Name .. "\".",
                    Icon = "download"
                })
            end)

            IconButton(-40, "share-2", function()
                if setclipboard then
                    pcall(function()
                        setclipboard(readfile(ConfigPath(Name)))
                    end)
                end

                Library:Notification({
                    Name = "Config copied",
                    Description = "\"" .. Name .. "\" was copied to your clipboard.",
                    Icon = "share-2"
                })
            end)

            IconButton(-14, "trash-2", function()
                if Data.Removing then return end
                Data.Removing = true

                if delfile and isfile and isfile(ConfigPath(Name)) then
                    delfile(ConfigPath(Name))
                end

                if Config.Selected == Name then
                    Config.Selected = nil
                    ShowInfo(nil)
                end

                local Index = table.find(Config.Rows, Data)
                if Index then table.remove(Config.Rows, Index) end

                local Sink = TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

                Library:Tween({ Size = UDim2.fromOffset(ColW, 0) }, Sink, Slot.Instance)
                Row:FadeDescendants(false)

                Library:Notification({
                    Name = "Config deleted",
                    Description = "\"" .. Name .. "\" was removed.",
                    Icon = "trash-2"
                })

                task.delay(0.3, function()
                    Slot.Instance:Destroy()

                    local NewHeight = #Config.Rows * 52
                    Items.List.Instance.CanvasSize = UDim2.fromOffset(0, math.max(NewHeight - 8, 0))
                end)
            end)

            function Data:SetSelected(Active)
                local Key = Active and "Text" or "DimText"

                Label:ChangeItemTheme({ TextColor3 = Key })
                Label:Tween({ TextColor3 = Library.Theme[Key] })
                Library:Tween({ Size = UDim2.fromOffset(3, Active and 16 or 0) }, nil, Bar.Instance)

                if BarShadow then
                    Library:StampResting(BarShadow, "Transparency", Active and 0 or 1)
                    BarShadow.Transparency = Active and 0 or 1
                end
            end

            local Hit = MakeButton({
                Parent = Row.Instance,
                Size = UDim2.new(1, -96, 1, 0),
                Z = 5
            })

            Hit:Connect("MouseButton1Down", function()
                Config.Selected = Name

                for _, Other in Config.Rows do
                    Other:SetSelected(Other == Data)
                end

                ShowInfo(Name)
                Library:LoadConfigFile(Name)

                if RefreshThemeUI then
                    RefreshThemeUI()
                end

                Library:Notification({
                    Name = "Config loaded",
                    Description = "All values were restored from \"" .. Name .. "\".",
                    Icon = "check"
                })
            end)

            table.insert(Config.Rows, Data)
            return Data
        end

        RefreshList = function()
            for _, Data in Config.Rows do
                Data.Slot.Instance:Destroy()
            end

            Config.Rows = { }

            for Index, Name in Library:ListConfigs() do
                local Data = AddRow(Index, Name)
                Data:SetSelected(Name == Config.Selected)
            end

            local Height = #Config.Rows * 52
            Items.List.Instance.CanvasSize = UDim2.fromOffset(0, math.max(Height - 8, 0))
        end

        Items.CreateHit:Connect("MouseButton1Down", function()
            PlaySweep(Items.CreateSweep.Instance)

            local Name = string.gsub(Items.NameInput.Instance.Text, "[^%w _%-]", "")

            if Name == "" then
                Library:Notification({
                    Name = "Config name required",
                    Description = "Type a name into the box before creating.",
                    Icon = "triangle-alert"
                })

                return
            end

            if isfile and isfile(ConfigPath(Name)) then
                Library:Notification({
                    Name = "Name already used",
                    Description = "A config called \"" .. Name .. "\" already exists.",
                    Icon = "triangle-alert"
                })

                return
            end

            writefile(ConfigPath(Name), Library:GetConfig())
            Items.NameInput.Instance.Text = ""
            Config.Selected = Name
            RefreshList()
            ShowInfo(Name)

            Library:Notification({
                Name = "Config created",
                Description = "\"" .. Name .. "\" now holds your current values.",
                Icon = "plus"
            })
        end)

        local Blocks = {
            { Frame = Items.CreateBox, Home = UDim2.fromOffset(0, 0) },
            { Frame = Items.ListHolder, Home = UDim2.fromOffset(0, 52) },
            { Frame = Items.InfoPanel, Home = UDim2.fromOffset(Col2X, 0) },
            { Frame = Items.ThemePanel, Home = UDim2.fromOffset(Col2X, 216) }
        }

        local BlockSlide = 30
        local BlockStep = 0.06

        SubTab.PageIntro = function()
            Config.IntroToken += 1

            local Token = Config.IntroToken
            local Slide = TweenInfo.new(0.36, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

            for _, Block in Blocks do
                Block.Frame:CancelFade()
                Block.Frame.Instance.Visible = false
                Block.Frame.Instance.Position = Block.Home + UDim2.fromOffset(BlockSlide, 0)
            end

            for Index, Block in Blocks do
                task.delay((Index - 1) * BlockStep, function()
                    Block.Frame.Instance.Visible = true

                    if Config.IntroToken ~= Token then
                        Block.Frame.Instance.Position = Block.Home
                        return
                    end

                    Block.Frame:FadeDescendants(true)
                    Library:Tween({ Position = Block.Home }, Slide, Block.Frame.Instance)
                end)
            end
        end

        SubTab.PageOutro = function()
            Config.IntroToken += 1

            local Token = Config.IntroToken
            local Slide = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

            for Index, Block in Blocks do
                local Away = Block.Home + UDim2.fromOffset(-BlockSlide, 0)

                task.delay((Index - 1) * BlockStep, function()
                    if Config.IntroToken ~= Token then return end

                    Block.Frame:FadeDescendants(false)
                    Library:Tween({ Position = Away }, Slide, Block.Frame.Instance)
                end)
            end
        end

        function Config:Refresh()
            RefreshList()
        end

        RefreshList()
        ShowInfo(nil)

        return Config
    end

    Library.Watermark = function(Self, Params)
        Params = Params or { }

        if Library.WatermarkBar then
            return Library.WatermarkBar
        end

        local Icon = Params.Icon or (Self and Self.Icon) or "layers"
        local Items = { }
        local Order = 0

        Items.Bar = MakeFrame({
            Parent = Library.Holder.Instance,
            Anchor = Vector2.new(0.5, 0),
            Pos = UDim2.new(0.5, 0, 0, 14),
            Size = UDim2.fromOffset(0, 32),
            Color = "Section",
            Round = 8,
            Z = 60
        })

        Items.Bar.Instance.AutomaticSize = Enum.AutomaticSize.X

        Library:Create("UIPadding", {
            Parent = Items.Bar.Instance,
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12)
        })

        Library:Create("UIListLayout", {
            Parent = Items.Bar.Instance,
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10)
        })

        local function NextOrder()
            Order += 1
            return Order
        end

        Items.Icon = MakeImage({
            Parent = Items.Bar.Instance,
            Icon = Icon,
            Size = UDim2.fromOffset(20, 20),
            Raw = Color3.new(1, 1, 1),
            Fit = true,
            Z = 61
        })

        Items.Icon.Instance.LayoutOrder = NextOrder()

        local function Separator()
            local Sep = MakeFrame({
                Parent = Items.Bar.Instance,
                Size = UDim2.fromOffset(1, 14),
                Color = "Light",
                Z = 61
            })

            Sep.Instance.LayoutOrder = NextOrder()
        end

        local function Stat(Text)
            local Label = MakeText({
                Parent = Items.Bar.Instance,
                Text = Text,
                TextSize = 14,
                Size = UDim2.fromOffset(0, 16),
                Color = "DimText",
                Z = 61
            })

            Label.Instance.AutomaticSize = Enum.AutomaticSize.X
            Label.Instance.LayoutOrder = NextOrder()

            return Label
        end

        Separator()
        local GameStat = Stat("...")
        Separator()
        local FpsStat = Stat("0 fps")
        Separator()
        local PingStat = Stat("0 ms")
        Separator()
        local TimeStat = Stat(os.date("%I:%M %p"))

        Library:Thread(function()
            local Ok, Info = pcall(function()
                return MarketplaceService:GetProductInfo(game.PlaceId)
            end)

            GameStat.Instance.Text = (Ok and Info and Info.Name) or "Unknown"
        end)

        local Frames = 0

        Library:Connect(RunService.RenderStepped, function()
            Frames += 1
        end)

        Library:Thread(function()
            while task.wait(0.5) do
                if not Items.Bar.Instance.Parent then break end

                FpsStat.Instance.Text = tostring(Frames * 2) .. " fps"
                Frames = 0

                local Ping = 0

                pcall(function()
                    local Stat = StatsService.Network.ServerStatsItem["Data Ping"]
                    Ping = math.floor(Stat:GetValue())
                end)

                PingStat.Instance.Text = tostring(Ping) .. " ms"
                TimeStat.Instance.Text = os.date("%I:%M %p")
            end
        end)

        Items.Bar:MakeDraggable()
        Library.WatermarkBar = Items.Bar

        local Watermark = { Instance = Items.Bar.Instance }

        function Watermark:SetIcon(NewIcon)
            ApplyIcon(Items.Icon.Instance, NewIcon)
        end

        function Watermark:SetName()
        end

        function Watermark:SetVisible(Bool)
            Items.Bar:FadeDescendants(Bool)
        end

        return Watermark
    end

    Library.GetConfig = function(Self, Created)
        local Config = { }

        for Index, Value in Library.Flags do
            if typeof(Value) == "Color3" then
                Config[Index] = { __color = Value:ToHex() }
            else
                Config[Index] = Value
            end
        end

        local ThemeColors = { }

        for _, Key in Library.ThemeKeys do
            ThemeColors[Key] = Library.Theme[Key]:ToHex()
        end

        Config.__accent = Library.Theme.Accent:ToHex()
        Config.__theme = ThemeColors
        Config.__created = Created or os.date("%d.%m.%Y %H:%M")
        Config.__version = Library.Version
        Config.__creator = LocalPlayer.DisplayName

        return HttpService:JSONEncode(Config)
    end

    Library.LoadConfig = function(Self, Config)
        local Ok, Decoded = pcall(function()
            return HttpService:JSONDecode(Config)
        end)

        if not Ok or type(Decoded) ~= "table" then return false end

        Library.Silent = true

        for Index, Value in Decoded do
            local SetFunction = Library.SetFlags[Index]
            if not SetFunction then continue end

            if type(Value) == "table" and Value.__color then
                SetFunction(Color3.fromHex(Value.__color), Value.__alpha)
            else
                SetFunction(Value)
            end
        end

        if type(Decoded.__theme) == "table" then
            for Key, Hex in Decoded.__theme do
                local OkColor, Color = pcall(Color3.fromHex, Hex)
                if OkColor then Library.Theme[Key] = Color end
            end

            DeriveTheme()
            Library.ThemeDirty = true
        end

        if type(Decoded.__accent) == "string" then
            local OkColor, Color = pcall(Color3.fromHex, Decoded.__accent)
            if OkColor then Library:SetAccent(Color) end
        end

        Library.Silent = false
        return true
    end

    Library.SaveConfigFile = function(Self, Name)
        if not writefile then return false end

        writefile(Library.ConfigFolder .. "/" .. Name .. ".json", Library:GetConfig())
        return true
    end

    Library.LoadConfigFile = function(Self, Name)
        if not isfile then return false end

        local Path = Library.ConfigFolder .. "/" .. Name .. ".json"
        if not isfile(Path) then return false end

        return Library:LoadConfig(readfile(Path))
    end

    Library.ListConfigs = function(Self)
        local Result = { }

        if not listfiles then return Result end

        for _, File in listfiles(Library.ConfigFolder) do
            if string.sub(File, -5) ~= ".json" then continue end

            local Name = string.match(File, "([^/\\]+)%.json$")
            if Name then table.insert(Result, Name) end
        end

        return Result
    end

    Library:Connect(RunService.Heartbeat, function(Delta)
        if Library.ThemeDirty then
            Library.ThemeDirty = false
            Library:ApplyThemeInstant()
        end

        if not Library.PreloadDirty then return end

        Library.PreloadClock += Delta or 0

        if Library.PreloadClock >= 0.35 then
            Library.PreloadDirty = false
            Library.PreloadClock = 0
            Library:PreloadAll()
        end
    end)

    getgenv().Zolar = Library
end

return Library

]=======]
local context = ... or {}
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Zolar = assert(loadstring(vendorSource, "PlexZolarVendor"))()
local BRAND_ICON = "rbxassetid://110265513619691"

local cfg = {}
local events = {}
local options = {}
local serial = 0
local scheduleAutoSave = function() end
local Configs = {active="",list=function() return {} end,isDirty=function() return false end,
    load=function() return false end,save=function() return false end}

local UI = {
    cfg = cfg,
    publicVersion = "Zolar 1.1",
    M = {small=10,value=12},
    F = {body=Font.fromEnum(Enum.Font.Gotham),medium=Font.fromEnum(Enum.Font.GothamMedium),semibold=Font.fromEnum(Enum.Font.GothamBold)},
    TW = {pop=TweenInfo.new(0.18,Enum.EasingStyle.Back,Enum.EasingDirection.Out),close=TweenInfo.new(0.16,Enum.EasingStyle.Quad,Enum.EasingDirection.In)},
}

local function refreshPalette()
    local theme = Zolar.Theme
    UI.C = {
        bg=theme.Background, pop=theme.Section, surface=theme.Section, card=theme.Element,
        text=theme.Text, dim=theme.DimText, muted=theme.DimText, faint=theme.DimText,
        accent=theme.Accent, accent2=theme.AccentDark or theme.Accent,
        edge=theme.Light, hairline=theme.Line, ok=Color3.fromRGB(72,214,168),
    }
end
refreshPalette()

local themeListeners = {}
local activeThemeName = "Default"
local refreshThemeArt = function() end
function UI.onThemeChanged(callback)
    table.insert(themeListeners,callback)
    return {Disconnect=function()
        local index=table.find(themeListeners,callback)
        if index then table.remove(themeListeners,index) end
    end}
end
local function fireThemeChanged()
    refreshPalette()
    for _,callback in ipairs(themeListeners) do pcall(callback) end
end
for _,method in ipairs({"SetTheme","SetAccent","SetThemeColor"}) do
    local original=Zolar[method]
    if type(original)=="function" then
        Zolar[method]=function(self,...)
            if method=="SetTheme" then
                local requested=select(1,...)
                if type(requested)=="string" then activeThemeName=requested
                elseif type(requested)=="table" and type(requested.Name)=="string" then activeThemeName=requested.Name end
            end
            local result=original(self,...)
            fireThemeChanged()
            refreshThemeArt()
            return result
        end
    end
end

function UI.frame(parent,color)
    local object=Instance.new("Frame")
    object.BackgroundColor3=color or UI.C.bg
    object.BackgroundTransparency=color and 0 or 1
    object.BorderSizePixel=0
    object.Parent=parent
    return object
end
function UI.label(parent,text,size,color,font)
    local object=Instance.new("TextLabel")
    object.BackgroundTransparency=1
    object.Text=tostring(text or "")
    object.TextSize=size or 12
    object.TextColor3=color or UI.C.text
    object.TextXAlignment=Enum.TextXAlignment.Left
    object.FontFace=font or UI.F.body
    object.Parent=parent
    return object
end
function UI.button(parent,text,size,color,background)
    local object=Instance.new("TextButton")
    object.AutoButtonColor=false
    object.BorderSizePixel=0
    object.BackgroundColor3=background or UI.C.card
    object.Text=tostring(text or "")
    object.TextSize=size or 12
    object.TextColor3=color or UI.C.text
    object.FontFace=UI.F.medium
    object.Parent=parent
    return object
end
function UI.corner(parent,radius)
    local object=Instance.new("UICorner")
    object.CornerRadius=typeof(radius)=="UDim" and radius or UDim.new(0,tonumber(radius) or 6)
    object.Parent=parent
    return object
end
function UI.stroke(parent,color,transparency)
    local object=Instance.new("UIStroke")
    object.Color=color or UI.C.edge
    object.Transparency=transparency or 0
    object.Parent=parent
    return object
end
function UI.gradient(parent,a,b,rotation)
    local object=Instance.new("UIGradient")
    object.Color=ColorSequence.new(a or UI.C.accent,b or UI.C.accent2)
    object.Rotation=rotation or 0
    object.Parent=parent
    return object
end
function UI.tween(object,info,properties)
    local tween=TweenService:Create(object,info or TweenInfo.new(0.15),properties)
    tween:Play()
    return tween
end
function UI.fadeOut(root,info,callback)
    local tween=UI.tween(root,info or UI.TW.close,{BackgroundTransparency=1})
    tween.Completed:Connect(function() if callback then callback() end end)
    return tween
end
function UI.logoMark(parent,size)
    local object=Instance.new("ImageLabel")
    object.BackgroundTransparency=1
    object.Size=UDim2.fromOffset(size or 18,size or 18)
    object.Image=BRAND_ICON
    object.ScaleType=Enum.ScaleType.Fit
    object.ImageColor3=Color3.new(1,1,1)
    object.Parent=parent
    return object
end
function UI.icon(parent,name,size)
    local object=Instance.new("ImageLabel")
    object.BackgroundTransparency=1
    object.Size=UDim2.fromOffset(size or 16,size or 16)
    object.Image=""
    object:SetAttribute("ZolarIcon",tostring(name or ""))
    object.Parent=parent
    return object
end
function UI.recolourIcon(object,color) object.ImageColor3=color end

local Menu={subs={},activeTab=nil,activeSub=nil,afterConfigSwap=nil}
local Library={Toggles={},Options={},NativeUI=UI,NativeMenu=Menu,KeybindFrame={Visible=false}}
local function updateLibraryColors()
    Library.FontColor=UI.C.text
    Library.MainColor=UI.C.surface
    Library.BackgroundColor=UI.C.bg
    Library.OutlineColor=UI.C.edge
    Library.AccentColor=UI.C.accent
end
updateLibraryColors()
UI.onThemeChanged(updateLibraryColors)

function Library:OnEvent(name)
    if not events[name] then events[name]=Instance.new("BindableEvent") end
    return events[name].Event
end
local function fire(name,...)
    if events[name] then events[name]:Fire(...) end
end
local function notify(message,duration,kind)
    local data=type(message)=="table" and message or {Text=tostring(message or ""),Duration=duration,Kind=kind}
    return Zolar:Notification({
        Name=tostring(data.Title or (data.Kind=="ready" and "plex.cc" or "plex.cc alerts")),
        Description=tostring(data.Text or data.Description or ""),
        Icon=data.Icon or (data.Kind=="error" and "triangle-alert" or data.Kind=="ready" and "check" or "bell"),
        Duration=tonumber(data.Duration or duration) or 3,
    })
end
function Library:Notify(message,duration) return notify(message,duration) end
function Library:UpdateColorsUsingRegistry() end
function Library:GetDarkerColor(color) return color:Lerp(Color3.new(),0.35) end

local function keyName(value)
    if typeof(value)=="EnumItem" then
        if value==Enum.UserInputType.MouseButton1 then return "MB1" end
        if value==Enum.UserInputType.MouseButton2 then return "MB2" end
        if value==Enum.UserInputType.MouseButton3 then return "MB3" end
        return value.Name
    end
    local text=tostring(value or "None")
    text=text:gsub("Enum%.KeyCode%.",""):gsub("Enum%.UserInputType%.","")
    return text
end
local function parseKey(value)
    if typeof(value)=="EnumItem" then return value end
    local name=keyName(value)
    if name=="" or name=="None" or name=="Unknown" then return nil end
    if name=="MB1" or name=="MouseButton1" then return Enum.UserInputType.MouseButton1 end
    if name=="MB2" or name=="MouseButton2" then return Enum.UserInputType.MouseButton2 end
    if name=="MB3" or name=="MouseButton3" then return Enum.UserInputType.MouseButton3 end
    return Enum.KeyCode[name] or Enum.KeyCode.Unknown
end
local function cloneValue(value)
    if type(value)~="table" then return value end
    local out={} for key,item in pairs(value) do out[key]=cloneValue(item) end return out
end
local function multiToArray(value)
    local out={}
    if type(value)~="table" then return out end
    if #value>0 then for _,item in ipairs(value) do table.insert(out,tostring(item)) end
    else for item,enabled in pairs(value) do if enabled then table.insert(out,tostring(item)) end end end
    table.sort(out)
    return out
end
local function multiToMap(value)
    local out={}
    if type(value)~="table" then return out end
    if #value>0 then for _,item in ipairs(value) do out[item]=true end
    else for item,enabled in pairs(value) do if enabled then out[item]=true end end end
    return out
end

local function makeOption(id,definition,kind,value)
    if id==nil then serial+=1 id="ZolarOption_"..serial end
    definition=definition or {}
    local initialMode=definition.Mode or "Toggle"
    if kind=="KeyPicker" and (keyName(value)=="None" or keyName(value)=="Unknown" or keyName(value)=="") then
        initialMode="None"
    end
    local object={Id=id,Type=kind,Definition=definition,Value=cloneValue(value),Mode=initialMode,
        Transparency=definition.Transparency,Properties={},Active=false}
    function object:Emit(nextValue,transparency)
        if kind=="Dropdown" and self.Multi then nextValue=multiToMap(nextValue) end
        if kind=="Toggle" then nextValue=nextValue==true end
        self.Value=cloneValue(nextValue)
        if transparency~=nil then self.Transparency=transparency end
        cfg[id]=cloneValue(self.Value)
        if definition.Callback then definition.Callback(self.Value,self.Transparency) end
        if self.Callback then self.Callback(self.Value) end
        scheduleAutoSave()
    end
    function object:SetValue(nextValue)
        if kind=="KeyPicker" and (keyName(nextValue)=="None" or keyName(nextValue)=="Unknown" or keyName(nextValue)=="") then
            self:SetMode("None")
        end
        if self.Widget then
            if kind=="Dropdown" and self.Multi then self.Widget:Set(multiToArray(nextValue))
            elseif kind=="KeyPicker" then self.Widget:Set(parseKey(nextValue))
            else self.Widget:Set(nextValue) end
        else self:Emit(nextValue) end
    end
    function object:SetValueRGB(color,transparency)
        self.Transparency=transparency~=nil and transparency or self.Transparency
        if self.Widget then self.Widget:Set(color,self.Transparency) else self:Emit(color,self.Transparency) end
    end
    function object:SetValues(values)
        self.Values=table.clone(values or {})
        if self.Widget and self.Widget.Refresh then self.Widget:Refresh(self.Values) end
    end
    function object:SetList(values) self:SetValues(values) end
    function object:SetMode(mode)
        if mode~="None" and mode~="Always" and mode~="Never" and mode~="Hold" and mode~="Toggle" then return end
        self.Mode=mode
        if self.BindWidget and self.BindWidget.SetMode then
            self.BindWidget:SetMode(mode,true)
            return
        end
        if mode=="Always" then self.Active=true elseif mode=="Never" or mode=="None" then self.Active=false end
        if definition.ModeCallback then definition.ModeCallback(mode) end
        scheduleAutoSave()
    end
    function object:GetState()
        if self.Mode=="Always" then return true end
        if self.Mode=="Never" or self.Mode=="None" then return false end
        if self.Mode=="Toggle" then return self.Active==true end
        local key=parseKey(self.Value)
        if not key then return false end
        if key.EnumType==Enum.KeyCode then return UIS:IsKeyDown(key) end
        if key==Enum.UserInputType.MouseButton1 then return UIS:IsMouseButtonPressed(key) end
        if key==Enum.UserInputType.MouseButton2 then return UIS:IsMouseButtonPressed(key) end
        return self.Active==true
    end
    function object:OnClick(callback) self.ClickCallback=callback end
    function object:OnChanged(callback) self.Callback=callback end
    function object:Update() end
    function object:Display() end
    options[id]=object
    cfg[id]=cloneValue(object.Value)
    if kind=="Toggle" then Library.Toggles[id]=object else Library.Options[id]=object end
    return object
end

local makeGroup
local function attachExtras(object,group,zToggle)
    function object:AddColorPicker(id,definition) return group:AddColorPicker(id,definition,zToggle) end
    function object:AddKeyPicker(id,definition) return group:AddKeyPicker(id,definition,zToggle) end
    function object:AddSlider(id,definition) return group:AddSlider(id,definition) end
    function object:AddDropdown(id,definition) return group:AddDropdown(id,definition) end
    return object
end
makeGroup=function(parent,title)
    local sub=parent.Sub or parent
    local side=parent.Side or 1
    local section=sub:Section({Name=tostring(title or "Section"),Side=side})
    local group={Native=section,Container=section.Items and section.Items.Holder and section.Items.Holder.Instance}
    -- Shared Plex controls such as AddCurveEditor use the classic UI's
    -- `group.Native:custom(height, name)` escape hatch.  Back it with a real
    -- Zolar section row so the custom control participates in reflow, search,
    -- and scrolling instead of aborting the module while it is being built.
    function section:custom(height,searchName)
        local row=self:AddRow(math.max(1,tonumber(height) or 1),tostring(searchName or title or "Custom"))
        return row.Instance
    end
    function group:AddToggle(id,definition)
        definition=definition or {}
        local object=makeOption(id,definition,"Toggle",definition.Default==true)
        local creating=true
        local widget=section:Toggle({Name=definition.Text or id,Default=object.Value,Flag="plex_"..id,Callback=function(value)
            if not creating then object:Emit(value) end
        end})
        creating=false object.Widget=widget
        return attachExtras(object,self,widget)
    end
    function group:AddSlider(id,definition)
        definition=definition or {}
        local object=makeOption(id,definition,"Slider",definition.Default or definition.Min or 0)
        object.Min,object.Max=definition.Min,definition.Max
        local creating=true
        object.Widget=section:Slider({Name=definition.Text or id,Min=definition.Min or 0,Max=definition.Max or 100,
            Default=object.Value,Decimals=10^-(definition.Rounding or 0),Suffix=definition.Suffix or "",Flag="plex_"..id,
            Callback=function(value) if not creating then object:Emit(value) end end})
        creating=false
        return object
    end
    function group:AddDropdown(id,definition)
        definition=definition or {}
        local values=table.clone(definition.Values or {})
        local default=definition.Default
        if type(default)=="number" then default=values[default] end
        if default==nil then default=definition.Multi and {} or values[1] or "" end
        local object=makeOption(id,definition,"Dropdown",definition.Multi and multiToMap(default) or default)
        object.Values,object.Multi=values,definition.Multi==true
        local creating=true
        object.Widget=section:Dropdown({Name=definition.Text or id,Items=values,Multi=object.Multi,
            Default=object.Multi and multiToArray(default) or default,Flag="plex_"..id,
            Callback=function(value) if not creating then object:Emit(value) end end})
        creating=false
        return attachExtras(object,self)
    end
    function group:AddInput(id,definition)
        definition=definition or {}
        local object=makeOption(id,definition,"Input",tostring(definition.Default or ""))
        local creating=true
        object.Widget=section:Textbox({Name=definition.Text or id,Default=object.Value,Placeholder=definition.Placeholder or "...",
            Finished=definition.Finished==true,Flag="plex_"..id,Callback=function(value) if not creating then object:Emit(value) end end})
        creating=false
        return object
    end
    function group:AddColorPicker(id,definition,parentToggle)
        definition=definition or {}
        local object=makeOption(id,definition,"ColorPicker",definition.Default or UI.C.accent)
        local creating=true
        local params={Name=definition.Title or definition.Text or "Color",Default=object.Value,
            Transparency=definition.Transparency or 0,Flag="plex_"..id,
            Callback=function(value,alpha) if not creating then object:Emit(value,alpha) end end}
        object.Widget=parentToggle and parentToggle:Colorpicker(params) or section:Colorpicker(params)
        creating=false
        return object
    end
    function group:AddKeyPicker(id,definition,parentToggle)
        definition=definition or {}
        local object=makeOption(id,definition,"KeyPicker",keyName(definition.Default or "None"))
        -- A key picker attached to a Zolar toggle already drives that toggle in
        -- the vendor input handler.  Plex's shared module-bind loop uses this
        -- marker to avoid processing the same key a second time.
        object.HandlesInput=parentToggle~=nil
        local host=parentToggle
        if not host then
            local creating=true
            host=section:Toggle({Name=definition.Text or "Keybind",Default=false,Flag="plex_bindhost_"..id,Callback=function(value)
                if not creating then
                    object.Active=value==true
                    if object.ClickCallback then object.ClickCallback(object.Active) end
                end
            end})
            creating=false
            if host.Items and host.Items.Box then host.Items.Box.Instance.Visible=false end
        end
        local bind=host:Keybind({Default=parseKey(object.Value),Mode=object.Mode,Flag="plex_bind_"..id})
        local initializingBind=true
        local originalSet=bind.Set
        function bind:Set(value)
            originalSet(self,value)
            object.Value=keyName(value)
            cfg[id]=object.Value
            if id=="MenuKeybind" then Zolar.MenuKeybind=parseKey(value) end
            if not initializingBind then object:Emit(object.Value) end
        end
        local originalMode=bind.SetMode
        function bind:SetMode(mode,instant)
            originalMode(self,mode,instant)
            object.Mode=mode
            if mode=="Always" then object.Active=true elseif mode=="Never" or mode=="None" then object.Active=false end
            if not initializingBind then
                if definition.ModeCallback then definition.ModeCallback(mode) end
                scheduleAutoSave()
            end
        end
        object.Widget=bind object.BindWidget=bind
        bind:SetMode(object.Mode,true) bind:Set(parseKey(object.Value))
        initializingBind=false
        return object
    end
    function group:AddLabel(text)
        local label=section:Label({Name=tostring(text or "")})
        local object={Native=label,Properties={}}
        function object:SetText(value) if self.Native.Set then self.Native:Set(tostring(value)) end end
        return attachExtras(object,self)
    end
    function group:AddButton(definition,callback)
        if type(definition)=="string" then definition={Text=definition,Func=callback} end
        return section:Button({Name=definition.Text or "Button",Callback=definition.Func or function() end})
    end
    function group:AddDivider() return section:Label({Name="────────────────"}) end
    function group:AddBlank() return section:Label({Name=" "}) end
    return group
end

local PAGE_SUBTABS={
    main={"aimbot","silent aim","triggerbot","weapon","movement"},rage={"ragebot","priority"},melee={"combat","reach","targets"},
    world={"lighting","atmosphere","sky","effects","camera"},esp={"options","appearance","highlight","preview"},
    skins={"skin","wrap","charm","finisher","gun animations","emotes","unlock all"},visuals={"weapons / viewmodels","crosshair","effects","sounds","hud"},
    character={"movement","character","animations"},misc={"general","loadout","queue","chat","ranks/ranked","overlays / extras"},
    spoofers={"spoofers","enemy spoofer","device","marketplace"},ranks={"enemy ranks","ranked access","auto ban"},customcosmetics={"skin","wrap","charm","finisher","emote"},inventoryspoofer={"cosmetics","boxes"},settings={"menu","configs","script","themes"},weaponconfigs={"presets"},servers={"browser"},optimizations={"general"},
}
local function pageSubtab(page,title)
    local text=string.lower(title or "")
    local rules={
        main={{{"silent"},"silent aim"},{{"aim","target"},"aimbot"},{{"trigger","click"},"triggerbot"},{{"weapon"},"weapon"},{{"move","speed","fly"},"movement"}},
        rage={{{"priority"},"priority"}},melee={{{"reach","hitbox"},"reach"},{{"target","team","dummy"},"targets"}},
        world={{{"camera","stretch"},"camera"},{{"sky","weather","ambience"},"sky"},{{"bloom","sun","effect"},"effects"},{{"atmosphere","color correction"},"atmosphere"}},
        esp={{{"preview"},"preview"},{{"appearance","override","custom"},"appearance"},{{"highlight"},"highlight"}},
        skins={{{"unlock","ownership"},"unlock all"},{{"animation"},"gun animations"},{{"emote"},"emotes"},{{"finish"},"finisher"},{{"charm"},"charm"},{{"wrap"},"wrap"}},
        customcosmetics={{{"emote"},"emote"},{{"finish"},"finisher"},{{"charm"},"charm"},{{"wrap"},"wrap"},{{"skin"},"skin"}},
        inventoryspoofer={{{"box","case"},"boxes"},{{"cosmetic","inventory"},"cosmetics"}},
        visuals={{{"viewmodel","weapon"},"weapons / viewmodels"},{{"crosshair"},"crosshair"},{{"sound"},"sounds"},{{"tracer","effect"},"effects"},{{"target","indicator","hud"},"hud"}},
        character={{{"animation"},"animations"}},misc={{{"input overlay","input sounds","music player"},"overlays / extras"},{{"rank","lobby info"},"ranks/ranked"},{{"load"},"loadout"},{{"queue","ban"},"queue"},{{"chat"},"chat"}},
        ranks={{{"access","preview"},"ranked access"},{{"ban"},"auto ban"},{{"rank","lobby info"},"enemy ranks"}},
        spoofers={{{"robux","gifting","marketplace"},"marketplace"},{{"enemy"},"enemy spoofer"},{{"device"},"device"}},settings={{{"script","auto load"},"script"},{{"config"},"configs"},{{"theme"},"themes"}},
    }
    for _,rule in ipairs(rules[page] or {}) do
        for _,word in ipairs(rule[1]) do if text:find(word,1,true) then return rule[2] end end
    end
    return (PAGE_SUBTABS[page] or {"general"})[1]
end

local ICONS={main="crosshair",rage="skull",melee="swords",world="globe",esp="scan",visuals="eye",character="user",misc="wrench",optimizations="gauge",spoofers="venetian-mask",skins="sparkles",customcosmetics="palette",inventoryspoofer="package-open",weaponconfigs="sliders-horizontal",servers="server",ranks="medal",settings="settings"}
local PAGE_NAMES={ranks="ranks",customcosmetics="custom cosmetics",inventoryspoofer="inventory spoofer",weaponconfigs="weapon configs"}
local SUB_ICONS={
    main={["aimbot"]="crosshair",["silent aim"]="mouse-pointer-2",triggerbot="zap",weapon="target",movement="move"},
    rage={ragebot="flame",priority="list-filter"},
    melee={combat="swords",reach="maximize-2",targets="users"},
    world={lighting="sun",atmosphere="cloud",sky="cloud-sun",effects="sparkles",camera="camera"},
    esp={options="scan",appearance="palette",highlight="highlighter",preview="eye"},
    skins={skin="shirt",wrap="paintbrush",charm="gem",finisher="badge-check",["gun animations"]="play",emotes="smile",["unlock all"]="lock-open"},
    customcosmetics={skin="shirt",wrap="paintbrush",charm="gem",finisher="badge-check",emote="music"},
    inventoryspoofer={cosmetics="backpack",boxes="package-open"},
    visuals={["weapons / viewmodels"]="pistol",crosshair="crosshair",effects="wand-sparkles",sounds="volume-2",hud="panel-top"},
    character={movement="person-standing",character="user-round",animations="activity"},
    misc={general="wrench",loadout="package",queue="list-ordered",chat="message-square",["ranks/ranked"]="medal",["overlays / extras"]="keyboard"},
    spoofers={spoofers="venetian-mask",["enemy spoofer"]="user-x",device="smartphone"},
    settings={menu="panel-left",configs="folder-cog",script="code-2",themes="palette"},
    optimizations={general="gauge"},
}
local ZWindow
local zolarThemeArt
local mobileControlsGui
local function ensureMobileControls()
    if not UIS.TouchEnabled then return nil end
    if mobileControlsGui and mobileControlsGui.Parent then return mobileControlsGui end
    local parent
    pcall(function() parent=gethui and gethui() end)
    if not parent then pcall(function() parent=game:GetService("CoreGui") end) end
    if not parent then parent=Players.LocalPlayer:WaitForChild("PlayerGui") end
    local gui=Instance.new("ScreenGui")
    gui.Name="PlexZolarMobileControls"
    gui.ResetOnSpawn=false
    gui.IgnoreGuiInset=true
    gui.DisplayOrder=100004
    gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    gui.Parent=parent
    mobileControlsGui=gui
    local holder=Instance.new("Frame")
    holder.AnchorPoint=Vector2.new(1,0.5)
    holder.Position=UDim2.new(1,-12,0.5,0)
    holder.Size=UDim2.fromOffset(108,76)
    holder.BackgroundTransparency=1
    holder.Parent=gui
    local layout=Instance.new("UIListLayout")
    layout.HorizontalAlignment=Enum.HorizontalAlignment.Center
    layout.VerticalAlignment=Enum.VerticalAlignment.Center
    layout.Padding=UDim.new(0,8)
    layout.Parent=holder
    local function addButton(name,text,callback)
        local button=Instance.new("TextButton")
        button.Name=name
        button.Size=UDim2.fromOffset(108,34)
        button.BackgroundColor3=UI.C.surface
        button.BackgroundTransparency=0.05
        button.BorderSizePixel=0
        button.AutoButtonColor=false
        button.Text=text
        button.TextColor3=UI.C.text
        button.TextSize=12
        button.Font=Enum.Font.GothamBold
        button.Parent=holder
        UI.corner(button,8)
        local outline=UI.stroke(button,UI.C.accent,0.12)
        button.Activated:Connect(function() pcall(callback) end)
        UI.onThemeChanged(function()
            if not button.Parent then return end
            button.BackgroundColor3=UI.C.surface
            button.TextColor3=UI.C.text
            outline.Color=UI.C.accent
        end)
    end
    addButton("ToggleUI","PLEX MENU",function() Library:Toggle() end)
    addButton("Unload","UNLOAD",function() Library:Unload() end)
    return gui
end
function Library:CreateWindow(config)
    Zolar.WindowWidth=660
    Zolar.WindowHeight=480
    ZWindow=Zolar:Window({Name="plex.cc DEV",Icon=BRAND_ICON,Accent=Color3.fromRGB(73,145,255)})
    pcall(function()
        local main=ZWindow.Items.Main.Instance
        local border=Instance.new("UIStroke")
        border.Name="PlexRainbowBorder"
        border.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
        border.Thickness=1.5
        border.Parent=main
        local borderColors=Instance.new("UIGradient")
        borderColors.Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0,Color3.fromRGB(255,76,112)),
            ColorSequenceKeypoint.new(0.2,Color3.fromRGB(255,174,67)),
            ColorSequenceKeypoint.new(0.4,Color3.fromRGB(255,226,82)),
            ColorSequenceKeypoint.new(0.6,Color3.fromRGB(77,210,132)),
            ColorSequenceKeypoint.new(0.8,Color3.fromRGB(72,149,255)),
            ColorSequenceKeypoint.new(1,Color3.fromRGB(188,91,241)),
        })
        borderColors.Parent=border
        local art=Instance.new("Frame")
        art.Name="PlexDefaultThemeArt"
        art.BackgroundColor3=Color3.fromRGB(22,25,35)
        art.BackgroundTransparency=0.94
        art.BorderSizePixel=0
        art.Size=UDim2.fromScale(1,1)
        art.ClipsDescendants=true
        art.ZIndex=1
        art.Parent=main
        local shade=Instance.new("UIGradient")
        shade.Rotation=90
        shade.Color=ColorSequence.new(Color3.fromRGB(22,25,35),Color3.fromRGB(12,15,23))
        shade.Transparency=NumberSequence.new(0.55)
        shade.Parent=art
        zolarThemeArt=art
    end)
    refreshThemeArt=function()
        if zolarThemeArt then zolarThemeArt.Visible=activeThemeName=="Default" and cfg.NativeThemeArt~=false end
    end
    refreshThemeArt()
    local originalOpen=ZWindow.SetOpen
    function ZWindow:SetOpen(value)
        if value and shared.ModernLoading then return end
        originalOpen(self,value)
        Library.Opened=value==true
        fire("VisibilityChanged",Library.Opened)
    end
    self.Holder=ZWindow.Items.Root.Instance
    local env=getgenv and getgenv() or _G
    if env.__PlexInitBootstrap==true then
        self.Holder.Visible=false
    end
    ensureMobileControls()
    pcall(function()
        local top=ZWindow.Items.TopBar and ZWindow.Items.TopBar.Instance
        if top then
            local brand=Instance.new("TextLabel")
            brand.Name="PlexBrand"
            brand.BackgroundTransparency=1
            brand.Position=UDim2.fromOffset(50,7)
            brand.Size=UDim2.fromOffset(180,20)
            brand.Font=Enum.Font.GothamBold
            brand.Text="plex.cc  ·  DEV"
            brand.TextSize=15
            brand.TextColor3=UI.C.text
            UI.onThemeChanged(function() if brand.Parent then brand.TextColor3=UI.C.text end end)
            brand.TextXAlignment=Enum.TextXAlignment.Left
            brand.ZIndex=20
            brand.Parent=top
        end
    end)
    local window={Holder=self.Holder,PreviewAnchor=ZWindow.Items.Main.Instance,Tabs={}}
    function window:SetWindowTitle() end
    function window:AddTab(name)
        local zTab=ZWindow:Tab({Name=PAGE_NAMES[name] or tostring(name),Icon=ICONS[name] or "circle",Category=({main="Combat",rage="Combat",melee="Combat",weaponconfigs="Combat",world="Visuals",esp="Visuals",visuals="Visuals",skins="Visuals",customcosmetics="Visuals",inventoryspoofer="Visuals",character="Player",misc="Other",servers="Other",spoofers="Other",settings="Settings",optimizations="Other"})[name] or "Other"})
        local tab={Zolar=zTab,Groupboxes={},Tabboxes={},Subs={}}
        Menu.subs[name]={}
        for _,subName in ipairs(PAGE_SUBTABS[name] or {"general"}) do
            local zSub=zTab:SubTab({Name=subName,Icon=(SUB_ICONS[name] and SUB_ICONS[name][subName]) or "circle"})
            tab.Subs[subName]=zSub
            Menu.subs[name][subName]={L={Sub=zSub,Side=1},R={Sub=zSub,Side=2},Zolar=zSub}
        end
        local function group(title,side)
            local subName=pageSubtab(name,title)
            local zSub=tab.Subs[subName] or tab.Subs[(PAGE_SUBTABS[name] or {"general"})[1]]
            local result=makeGroup({Sub=zSub,Side=side},title)
            tab.Groupboxes[title]=result
            return result
        end
        function tab:ShowTab() zTab:Select() end
        function tab:AddLeftGroupbox(title) return group(title,1) end
        function tab:AddRightGroupbox(title) return group(title,2) end
        local function tabbox(side)
            local box={Groups={}}
            function box:AddTab(title) self.Groups[title]=self.Groups[title] or group(title,side) return self.Groups[title] end
            function box:ShowTab(title)
                local sub=tab.Subs[pageSubtab(name,title)]
                if sub then sub:Show() end
            end
            return box
        end
        function tab:AddLeftTabbox() return tabbox(1) end
        function tab:AddRightTabbox() return tabbox(2) end
        window.Tabs[name]=tab Library.Tabs=window.Tabs
        return tab
    end
    function window:Update() end
    return window
end
function Library:SetVisible(open)
    if not ZWindow then return end
    if open and shared.ModernLoading then return end
    local visible=open==true
    if ZWindow.Items and ZWindow.Items.Root and ZWindow.Items.Root.Instance then
        ZWindow.Items.Root.Instance.Visible=visible
    end
    ZWindow:SetOpen(visible)
    if visible and Menu.syncNow then
        task.defer(function() pcall(Menu.syncNow) end)
    end
end
function Library:Toggle()
    if ZWindow then Library:SetVisible(not ZWindow.IsOpen) end
end
function Library:Unload()
    for _,event in pairs(events) do event:Destroy() end
    if mobileControlsGui then pcall(function() mobileControlsGui:Destroy() end) mobileControlsGui=nil end
    Zolar:Unload()
end
function Menu.set(open) Library:SetVisible(open) end
function Menu.showTab(name)
    local tab=Library.Tabs and Library.Tabs[name]
    if tab then tab.Zolar:Select() Menu.activeTab=name end
end
function Menu.showSub(name,subName)
    Menu.showTab(name)
    local sub=Menu.subs[name] and Menu.subs[name][subName]
    if sub and sub.Zolar then
        local zsub=sub.Zolar
        if zsub.Tab.Current ~= zsub then
            if zsub.Tab.Current then
                zsub.Tab.Current:SetVisual(false)
                zsub.Tab.Current:Hide()
            end
            zsub.Tab.Current=zsub
            zsub:SetVisual(true,true)
        end
        zsub:SnapVisible()
        Menu.activeSub=subName
    end
end
function Menu.refreshToggles() end
function Menu.syncNow()
    if not Library.Tabs then return end
    for _,tab in pairs(Library.Tabs) do
        if tab and tab.Zolar and tab.Zolar.Current then
            local current=tab.Zolar.Current
            if current.Active then
                pcall(function() current:SnapVisible() end)
            end
        end
    end
end

local directRefreshers={}
local directSyncers={}
function UI.refilter() for _,syncer in ipairs(directSyncers) do pcall(syncer) end end
function UI.group(parent,title)
    local compat=makeGroup(parent,title)
    local native=compat.Native
    function compat:toggle(label,key,params)
        cfg[key]=cfg[key]==true
        local creating=true
        local widget=native:Toggle({Name=label,Default=cfg[key],Flag="plex_direct_"..key,Callback=function(value)
            cfg[key]=value==true
            if not creating and params and params.onChange then params.onChange(cfg[key]) end
        end})
        creating=false
        table.insert(directSyncers,function()
            local wanted=cfg[key]==true
            if widget.Value~=wanted then widget:Set(wanted) end
        end)
        return widget
    end
    function compat:button(label,callback) return self:AddButton({Text=label,Func=callback}) end
    function compat:note(text) return self:AddLabel(text) end
    function compat:field(label,placeholder,default)
        local proxy={_Text=tostring(default or "")}
        local box=native:Textbox({Name=label,Default=proxy._Text,Placeholder=placeholder or "...",Callback=function(value) proxy._Text=tostring(value) end})
        proxy.Widget=box
        return setmetatable(proxy,{__index=function(self,key) if key=="Text" then return self._Text end return rawget(self,key) end,
            __newindex=function(self,key,value) if key=="Text" then rawset(self,"_Text",tostring(value)) box:Set(tostring(value)) else rawset(self,key,value) end end})
    end
    function compat:slider(label,min,max,default)
        min,max=tonumber(min) or 0,tonumber(max) or 100
        local proxy={Value=math.clamp(math.floor(tonumber(default) or min),min,max)}
        proxy.Widget=native:Slider({Name=label,Min=min,Max=max,Default=proxy.Value,Decimals=1,Callback=function(value)
            proxy.Value=math.clamp(math.floor(tonumber(value) or proxy.Value),min,max)
        end})
        return proxy
    end
    function compat:list(label,params)
        local map,reverse={},{}
        local refreshing=true
        local page,query,searchToken=1,"",0
        local cachedItems,cachedVersion,lastRender,lastError
        local refresh,pageLabel
        local pageSize=params.pageSize or (params.height and params.height>180 and 40 or nil)
        if pageSize then
            native:Textbox({Name="search "..label,Default="",Placeholder=params.placeholder or "Search...",Callback=function(value)
                query=tostring(value or ""):lower()
                page=1
                searchToken+=1
                local token=searchToken
                task.delay(0.15,function() if token==searchToken and refresh then refresh() end end)
            end})
        end
        local dropdown=native:Dropdown({Name=label,Items={},Default=nil,Callback=function(value)
            if refreshing or not reverse[value] then return end
            if params.onSelect then params.onSelect(reverse[value]) end
        end})
        refresh=function()
            local version=params.version and params.version()
            local selected=params.selected and tostring(params.selected() or "") or ""
            local signature=version~=nil and (tostring(version).."|"..query.."|"..page.."|"..selected)
            if signature and signature==lastRender then return end
            if not cachedItems or version==nil or version~=cachedVersion then
                local ok,items=pcall(params.items)
                if not ok or type(items)~="table" then
                    local err=ok and "The list did not return items" or tostring(items)
                    if lastError~=err then
                        warn("[Plex UI] "..label..": "..err)
                        Library:Notify("Could not load "..label..": "..err,5)
                    end
                    lastError=err
                    return
                end
                cachedItems,cachedVersion,lastError=items,version,nil
            end
            local matches={}
            for _,item in ipairs(cachedItems) do
                local name=type(item)=="table" and tostring(item.label or item.id) or tostring(item)
                if query=="" or name:lower():find(query,1,true) then table.insert(matches,item) end
            end
            local pages=pageSize and math.max(1,math.ceil(#matches/pageSize)) or 1
            page=math.clamp(page,1,pages)
            local first=pageSize and ((page-1)*pageSize+1) or 1
            local last=pageSize and math.min(#matches,first+pageSize-1) or #matches
            table.clear(map) table.clear(reverse)
            local labels,images={},{}
            for i=first,last do
                local item=matches[i]
                local id=type(item)=="table" and tostring(item.id) or tostring(item)
                local name=type(item)=="table" and tostring(item.label or item.id) or tostring(item)
                if reverse[name] then name=name.." ["..id.."]" end
                map[id]=name reverse[name]=id table.insert(labels,name)
                if type(item)=="table" and type(item.image)=="string" and item.image~="" then images[name]=item.image end
            end
            -- Refresh can fire the vendor's selection callback. Guard the whole
            -- operation so a data refresh never selects/enables anything.
            refreshing=true
            dropdown:Refresh(labels,images)
            if map[selected] then dropdown:Set(map[selected]) end
            refreshing=false
            if pageLabel then pageLabel:SetText("Page "..page.." / "..pages.." · "..#matches.." items") end
            lastRender=version~=nil and (tostring(version).."|"..query.."|"..page.."|"..selected) or nil
        end
        if pageSize then
            pageLabel=self:AddLabel("")
            self:AddButton({Text="previous page",Func=function() page=math.max(1,page-1) refresh() end})
            self:AddButton({Text="next page",Func=function() page+=1 refresh() end})
        end
        table.insert(directRefreshers,refresh)
        refresh()
        refreshing=false
        return refresh
    end

    function compat:multilist(label,params)
        local reverse,currentIds={},{}
        local refreshing=true
        local page,query,searchToken=1,"",0
        local cachedItems,cachedVersion,lastRender,lastError
        local refresh,pageLabel
        local pageSize=params.pageSize or 40
        native:Textbox({Name="search "..label,Default="",Placeholder=params.placeholder or "Search...",Callback=function(value)
            query=tostring(value or ""):lower()
            page=1
            searchToken+=1
            local token=searchToken
            task.delay(0.15,function() if token==searchToken and refresh then refresh() end end)
        end})
        local function selectedLabels(value)
            local chosen={}
            if type(value)~="table" then return chosen end
            for key,item in pairs(value) do
                if type(key)=="string" and item==true then chosen[key]=true
                elseif type(item)=="string" then chosen[item]=true
                elseif type(key)=="string" and item then chosen[key]=true end
            end
            return chosen
        end
        local dropdown=native:Dropdown({Name=label,Items={},Multi=true,Default={},Callback=function(value)
            if refreshing then return end
            local selected={}
            if params.selected then
                for id,enabled in pairs(params.selected() or {}) do if enabled then selected[id]=true end end
            end
            for id in pairs(currentIds) do selected[id]=nil end
            for shown in pairs(selectedLabels(value)) do
                local id=reverse[shown]
                if id then selected[id]=true end
            end
            if params.onSelect then params.onSelect(selected) end
        end})
        refresh=function()
            local version=params.version and params.version()
            local selected=params.selected and params.selected() or {}
            local selectedKey={}
            for id,enabled in pairs(selected) do if enabled then table.insert(selectedKey,tostring(id)) end end
            table.sort(selectedKey)
            local signature=tostring(version).."|"..query.."|"..page.."|"..table.concat(selectedKey,",")
            if signature==lastRender then return end
            if not cachedItems or version==nil or version~=cachedVersion then
                local ok,items=pcall(params.items)
                if not ok or type(items)~="table" then
                    local err=ok and "The list did not return items" or tostring(items)
                    if lastError~=err then
                        warn("[Plex UI] "..label..": "..err)
                        Library:Notify("Could not load "..label..": "..err,5)
                    end
                    lastError=err
                    return
                end
                cachedItems,cachedVersion,lastError=items,version,nil
            end
            local matches={}
            for _,item in ipairs(cachedItems) do
                local name=type(item)=="table" and tostring(item.label or item.id) or tostring(item)
                if query=="" or name:lower():find(query,1,true) then table.insert(matches,item) end
            end
            local pages=math.max(1,math.ceil(#matches/pageSize))
            page=math.clamp(page,1,pages)
            local first=(page-1)*pageSize+1
            local last=math.min(#matches,first+pageSize-1)
            table.clear(reverse) table.clear(currentIds)
            local labels,images,chosen={},{},{}
            for i=first,last do
                local item=matches[i]
                local id=type(item)=="table" and tostring(item.id) or tostring(item)
                local name=type(item)=="table" and tostring(item.label or item.id) or tostring(item)
                if reverse[name] then name=name.." ["..id.."]" end
                reverse[name]=id currentIds[id]=true table.insert(labels,name)
                if selected[id] then table.insert(chosen,name) end
                if type(item)=="table" and type(item.image)=="string" and item.image~="" then images[name]=item.image end
            end
            refreshing=true
            dropdown:Refresh(labels,images)
            dropdown:Set(chosen)
            refreshing=false
            if pageLabel then pageLabel:SetText("Page "..page.." / "..pages.." · "..#matches.." items") end
            lastRender=signature
        end
        pageLabel=self:AddLabel("")
        self:AddButton({Text="previous page",Func=function() page=math.max(1,page-1) lastRender=nil refresh() end})
        self:AddButton({Text="next page",Func=function() page+=1 lastRender=nil refresh() end})
        table.insert(directRefreshers,refresh)
        refresh()
        refreshing=false
        return refresh
    end
    return compat
end

function UI.snapshotBindings()
    local bindings,states={},{}
    for id,object in pairs(options) do
        if object.Type=="KeyPicker" then bindings[id]={key=tostring(object.Value or ""),mode=object.Mode or "None"} states[id]=object.Active==true end
    end
    return bindings,states
end
function UI.applySavedBindings(bindings,states)
    for id,binding in pairs(bindings or {}) do
        local object=options[id]
        if object and object.Type=="KeyPicker" then
            object:SetMode(binding.mode or "None") object:SetValue(binding.key or "None")
            if type(states)=="table" and states[id]~=nil then object.Active=states[id]==true end
        end
    end
end

local themeManager={}
function themeManager:SetLibrary() end
function themeManager:SetFolder() end
function themeManager:ApplyToTab(tab)
    local names={} for _,entry in ipairs(Zolar.ThemePresets) do table.insert(names,entry.Name) end
    local group=tab:AddRightGroupbox("Zolar themes")
    group:AddDropdown("NativeTheme",{Text="Theme",Values=names,Default="Default",Callback=function(value) Zolar:SetTheme(value) end})
    group:AddToggle("NativeThemeArt",{Text="Background art",Default=true,Callback=function(value)
        cfg.NativeThemeArt=value==true
        refreshThemeArt()
    end})
end

local function saveConfig() end

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
    -- Local HTTP mode queues the companion loader, preserving its live snapshot.
    if not env.__PlexLicensedEntry and type(env.__PlexLocalSourceURL)=="string"
        and env.__PlexLocalSourceURL:match("^http://127%.0%.0%.1:%d+/")
        and type(env.__PlexLocalTeleportSource)=="string" and env.__PlexLocalTeleportSource~="" then
        queueEntry=env.__PlexLocalTeleportSource
    end
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
Library.ThemeManager, Library.SaveManager = themeManager, saveManager
return Library
