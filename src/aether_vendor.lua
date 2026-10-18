-- Variables
    local ServiceCache = {};
    local Services = setmetatable({}, {__index = function(Self, Index)
        if not ServiceCache[Index] then
            ServiceCache[Index] = cloneref(game:GetService(Index));
        end;

        return ServiceCache[Index];
    end});

    local Keys = {
        [Enum.KeyCode.LeftShift] = "LS",
        [Enum.KeyCode.RightShift] = "RS",
        [Enum.KeyCode.LeftControl] = "LC",
        [Enum.KeyCode.RightControl] = "RC",
        [Enum.KeyCode.Insert] = "INS",
        [Enum.KeyCode.Backspace] = "BS",
        [Enum.KeyCode.Return] = "Ent",
        [Enum.KeyCode.LeftAlt] = "LA",
        [Enum.KeyCode.RightAlt] = "RA",
        [Enum.KeyCode.CapsLock] = "CAPS",
        [Enum.KeyCode.One] = "1",
        [Enum.KeyCode.Two] = "2",
        [Enum.KeyCode.Three] = "3",
        [Enum.KeyCode.Four] = "4",
        [Enum.KeyCode.Five] = "5",
        [Enum.KeyCode.Six] = "6",
        [Enum.KeyCode.Seven] = "7",
        [Enum.KeyCode.Eight] = "8",
        [Enum.KeyCode.Nine] = "9",
        [Enum.KeyCode.Zero] = "0",
        [Enum.KeyCode.KeypadOne] = "Num1",
        [Enum.KeyCode.KeypadTwo] = "Num2",
        [Enum.KeyCode.KeypadThree] = "Num3",
        [Enum.KeyCode.KeypadFour] = "Num4",
        [Enum.KeyCode.KeypadFive] = "Num5",
        [Enum.KeyCode.KeypadSix] = "Num6",
        [Enum.KeyCode.KeypadSeven] = "Num7",
        [Enum.KeyCode.KeypadEight] = "Num8",
        [Enum.KeyCode.KeypadNine] = "Num9",
        [Enum.KeyCode.KeypadZero] = "Num0",
        [Enum.KeyCode.Minus] = "-",
        [Enum.KeyCode.Equals] = "=",

        [Enum.KeyCode.LeftBracket] = "[",
        [Enum.KeyCode.RightBracket] = "]",

        [Enum.KeyCode.Semicolon] = ",",
        [Enum.KeyCode.Quote] = "'",
        [Enum.KeyCode.BackSlash] = "\\",
        [Enum.KeyCode.Comma] = ",",
        [Enum.KeyCode.Period] = ".",
        [Enum.KeyCode.Slash] = "/",

        [Enum.KeyCode.Period] = ".",
        [Enum.KeyCode.Backquote] = "`",
        [Enum.UserInputType.MouseButton1] = "MB1",
        [Enum.UserInputType.MouseButton2] = "MB2",
        [Enum.UserInputType.MouseButton3] = "MB3",
        [Enum.KeyCode.Escape] = "ESC",
        [Enum.KeyCode.Space] = "SPC",
    }

    local Camera = workspace.CurrentCamera
    local LocalPlayer = Services.Players.LocalPlayer
    local GuiInset = Services.GuiService:GetGuiInset().Y
    local Mouse = LocalPlayer:GetMouse()
--

if getgenv().__PlexAetherVendor and getgenv().__PlexAetherVendor.Unload then
    getgenv().__PlexAetherVendor:Unload()
end

getgenv().__PlexAetherVendor = {
    Directory = "Overlay/Aether",
    Folders = {
        "/Fonts",
        "/Configs",
        "/Themes",
		"/Hitsounds"
    },

    Flags = {};
    ConfigFlags = {};
    Connections = {};
    Threads = {};
    Blurs = {};
    Notifications = {Notifs = {}};
    Keybinds = {};
    Mods = {};

    OpenElement = {};

    EasingStyle = Enum.EasingStyle.Quint;
    EasingDirection = Enum.EasingDirection.InOut;
    TweeningSpeed = .3;
    DraggingSpeed = .05;
    Tweening = false;
}; do
	local Library = getgenv().__PlexAetherVendor
	Library.__index = Library

    for _,path in ipairs({"Overlay",Library.Directory}) do if not isfolder(path) then makefolder(path) end end
    for _,path in Library.Folders do
        if not isfolder(Library.Directory..path) then makefolder(Library.Directory .. path) end
    end

    if not isfile(Library.Directory.."/Autoload.txt") then
        writefile(Library.Directory.."/Autoload.txt", "")
    end

    local Flags = Library.Flags
    local ConfigFlags = Library.ConfigFlags
    local Notifications = Library.Notifications

    local Themes = {
        Preset = {
            ["Accent"] = Color3.fromRGB(255, 182, 193),
            ["ElementBackground"] = Color3.fromRGB(20, 20, 22),
            ["SectionBackground"] = Color3.fromRGB(15, 16, 18),
            ["ElementOutline"] = Color3.fromRGB(25, 25, 29),
            ["Inline"] = Color3.fromRGB(23, 24, 27),
            ["Other"] = Color3.fromRGB(24, 24, 24),
            ["TabButtons"] = Color3.fromRGB(20, 22, 26),
            ["Unselected"] = Color3.fromRGB(170, 170, 170),
            ["TextColor"] = Color3.fromRGB(255, 255, 255),
            ["Background"] = Color3.fromRGB(12, 12, 14),
            ["Font"] = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
        };
        Utility = {};
    }; do
        for Theme, Color in Themes.Preset do
            if Theme == "font" then
                continue
            end

            Themes.Utility[Theme] = {
                BackgroundColor3 = {};
                TextColor3 = {};
                ImageColor3 = {};
                ScrollBarImageColor3 = {};
                Color = {};
            }
        end

        Library.Themify = function(self, Theme, Property)
            table.insert(Themes.Utility[Theme][Property], self.Instance)

            return self
        end

        Library.Refresh = function(self, Theme, Color)
            for Property, Data in Themes.Utility[Theme] do
                for _,Object in Data do
                    if (Property == "Color" or property == "Transparency") and not (Object:IsA("UIStroke") or Object:IsA("UIGradient")) then
                        continue
                    end

                    if (Object[Property] == Themes.Preset[Theme]) then
                        Object[Property] = Color
                    end
                end
            end

            Themes.Preset[Theme] = Color
        end

        Library.GetTheme = function(self)
            local Config = {}

            for Idx, Value in Themes.Preset do
                if Idx == "Font" then
                    continue
                end

                Config[Idx] = {Transparency = 1, Color = Value:ToHex()}
            end

            return Services.HttpService:JSONEncode(Config)
        end

        Library.SaveTheme = function(self, Config)
            local Path = string.format("%s/%s/%s.Cfg", Library.Directory, "Themes", Config)
            writefile(Path, self:GetTheme())
        end

        Library.DeleteTheme = function(self, Config)
            local Path = string.format("%s/%s/%s.Cfg", Library.Directory, "Themes", Config)

            if isfile(Path) then
                delfile(Path)
            end
        end

        Library.UpdateThemingList = function(self)
            local List = {}

            for _, File in listfiles(Library.Directory .. "/Themes") do
                local Name = File:gsub(Library.Directory .. "/Themes\\", ""):gsub(".Cfg", ""):gsub(Library.Directory .. "\\Themes\\", "")
                List[#List + 1] = Name
            end

            self.RefreshOptions(List)
        end
    end

    Library.GetTransparency = function(self, obj)
        local Instance = obj

        if Instance:IsA("Frame") then
            return {"BackgroundTransparency"}
        elseif Instance:IsA("TextLabel") or Instance:IsA("TextButton") then
            return { "TextTransparency", "BackgroundTransparency" }
        elseif Instance:IsA("ImageLabel") or Instance:IsA("ImageButton") then
            return { "BackgroundTransparency", "ImageTransparency" }
        elseif Instance:IsA("ScrollingFrame") then
            return { "BackgroundTransparency", "ScrollBarImageTransparency" }
        elseif Instance:IsA("TextBox") then
            return { "TextTransparency", "BackgroundTransparency" }
        elseif Instance:IsA("UIStroke") then
            return { "Transparency" }
        elseif Instance:IsA("BasePart") then
            return { "Transparency" }
        end

        return nil
    end

    Library.Tween = function(self, Properties, Info, Obj)
        local Instance = self.Instance or Obj

        local Tween = Services.TweenService:Create(Instance, Info or TweenInfo.new(Library.TweeningSpeed, Library.EasingStyle, Enum.EasingDirection.InOut, 0, false, 0), Properties)
        Tween:Play()

        return Tween
    end

    Library.AddGlow = function(self, Options)
        Options = Options or {}

        local Cfg = {
            Amount = Options.Amount or 5;
            DampingFactor = Options.DampingFactor or 0.4;
            Parent = self.Instance;
            Items = {};
        }

        local Items = Cfg.Items;

        for Outline = 0, Cfg.Amount do
            Items[tostring(Outline)] = Library:Create( "UIStroke", {
                Parent = self.Instance;
                Color = Themes.Preset.Accent;
                BorderOffset = UDim.new(0, Outline);
                Transparency = (Outline / (Cfg.Amount + Cfg.DampingFactor))
            }):Themify("Accent", "Color")

            Library:Create( "UIGradient", {
                Parent = Items[tostring(Outline)].Instance;
                Transparency = NumberSequence.new{
                    NumberSequenceKeypoint.new(0, Cfg.DampingFactor),
                    NumberSequenceKeypoint.new(1, Cfg.DampingFactor)
                }
            })
        end

        table.insert(Library.Glows, Cfg)

        return self
    end

    Library.Fade = function(self, obj, prop, vis)
        if not (prop and obj) then
            return
        end

        local OldTransparency = obj[prop]
        obj[prop] = vis and 1 or OldTransparency

        local Animation = Library:Tween({[prop] = vis and OldTransparency or 1}, nil, obj)
        Library:Connect(Animation.Completed, function()
            if not vis then
                obj[prop] = OldTransparency
            end
        end)

        return Animation
    end

    Library.PlexOpenPopups={}
    Library.ClosePopups=function(self)
        for _,popup in pairs(table.clone(self.PlexOpenPopups)) do popup.SetVisible(false) end
    end
    Library.PlexVisibilityAnimations={}
    Library.StopVisibilityAnimations=function(self)
        for root,state in pairs(self.PlexVisibilityAnimations) do
            if state.Connection then state.Connection:Disconnect() end
            for _,tween in ipairs(state.Tweens or {}) do tween:Cancel() end
            if root.Parent then
                root.Position=state.Position
                if state.Scale then state.Scale.Scale=state.ScaleValue end
                root.Visible=state.Showing
            end
        end
        table.clear(self.PlexVisibilityAnimations)
    end
    Library.AnimateVisibility=function(self,root,showing,callback,position,instant)
        showing=showing==true
        local previous=self.PlexVisibilityAnimations[root]
        local running=previous and previous.Connection~=nil
        local base=position or (running and previous.Position) or root.Position
        if previous then
            if previous.Connection then previous.Connection:Disconnect() end
            for _,tween in ipairs(previous.Tweens or {}) do tween:Cancel() end
        end
        local scale=root:FindFirstChildOfClass("UIScale")
        if not scale and root.Parent and root.Parent:IsA("LayerCollector") then
            scale=self:Create("UIScale",{Name="PlexPopupScale",Scale=1,Parent=root}).Instance
        end
        local value=running and previous.ScaleValue or (scale and scale.Scale or 1)
        if not showing and not root.Visible and not running then instant=true end
        local state={Position=base,Scale=scale,ScaleValue=value,Showing=showing,Tweens={}}
        self.PlexVisibilityAnimations[root]=state
        if instant or shared.ModernLoading or self.PlexUnloaded then
            root.Position=base;root.Visible=showing
            if scale then scale.Scale=value end
            if callback then callback() end
            return
        end
        local wasVisible=root.Visible
        root.Visible=true
        if showing and not wasVisible then
            root.Position=base+UDim2.fromOffset(0,6)
            if scale then scale.Scale=value*0.975 end
        end
        local info=TweenInfo.new(showing and 0.18 or 0.12,Enum.EasingStyle.Quad,showing and Enum.EasingDirection.Out or Enum.EasingDirection.In)
        state.Tweens[1]=Services.TweenService:Create(root,info,{Position=showing and base or base+UDim2.fromOffset(0,6)})
        if scale then state.Tweens[2]=Services.TweenService:Create(scale,info,{Scale=showing and value or value*0.975}) end
        state.Connection=state.Tweens[1].Completed:Connect(function()
            if self.PlexVisibilityAnimations[root]~=state or self.PlexUnloaded then return end
            state.Connection:Disconnect();state.Connection=nil
            for _,tween in ipairs(state.Tweens) do tween:Cancel() end
            root.Position=base;root.Visible=showing
            if scale then scale.Scale=value end
            table.clear(state.Tweens)
            if callback then callback() end
        end)
        for _,tween in ipairs(state.Tweens) do tween:Play() end
        return state.Tweens[1]
    end
    Library.TweenDescendants = function(self, Bool, Path)
        if Path then Path.Tweening=false end
        Library:AnimateVisibility(self.Instance,Bool)
    end

    Library.Resizify = function(self)
        local Instance = self.Instance

        local Resizing = Library:Create("TextButton", {Name="PlexRole_Buttons";
            Position = UDim2.new(1, -10, 1, -10);
            Size = UDim2.new(0, 10, 0, 10);
            BorderSizePixel = 0;
            Parent = Instance;
            BackgroundTransparency = 1;
            Text = ""
        })

        local IsResizing = false
        local Size;
        local InputLost;
        local ParentSize = Instance.Size

        Resizing.Instance.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                IsResizing = true
                InputLost = input.Position
                Size = Instance.Size
            end
        end)

        Resizing.Instance.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                IsResizing = false
            end
        end)

        Library:Connect(Services.UserInputService.InputChanged, function(input, game_event)
            if IsResizing and input.UserInputType == Enum.UserInputType.MouseMovement then
                self:Tween({
                    Size = UDim2.new(
                        Size.X.Scale,
                        math.clamp(Size.X.Offset + (input.Position.X - InputLost.X), ParentSize.X.Offset, Camera.ViewportSize.X),
                        Size.Y.Scale,
                        math.clamp(Size.Y.Offset + (input.Position.Y - InputLost.Y), ParentSize.Y.Offset, Camera.ViewportSize.Y)
                    )
                }, TweenInfo.new(Library.DraggingSpeed, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0))
            end
        end)
    end

    Library.Hovering = function(self)
        local y_cond = self.Instance.AbsolutePosition.Y <= Mouse.Y and Mouse.Y <= self.Instance.AbsolutePosition.Y + self.Instance.AbsoluteSize.Y
        local x_cond = self.Instance.AbsolutePosition.X <= Mouse.X and Mouse.X <= self.Instance.AbsolutePosition.X + self.Instance.AbsoluteSize.X

        return (y_cond and x_cond)
    end

    Library.Draggify = function(self)
        local Instance = self.Instance

        local Dragging = false
        local InitialSize = Instance.Position
        local InitialPosition

        Instance.InputBegan:Connect(function(Input)
            if Instance:GetAttribute("PlexDragLocked") or Services.UserInputService:GetFocusedTextBox() then return end
            if Input.UserInputType == Enum.UserInputType.Touch and Input.Position.Y - Instance.AbsolutePosition.Y > 88 then return end
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                Dragging = true
                InitialPosition = Input.Position
                InitialSize = Instance.Position
            end
        end)

        Instance.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                Dragging = false
            end
        end)

        Library:Connect(Services.UserInputService.InputChanged, function(Input, GameEvent)
            if Instance:GetAttribute("PlexDragLocked") then Dragging=false;return end
            if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                local Horizontal = Camera.ViewportSize.X
                local Vertical = Camera.ViewportSize.Y

                local NewPosition = UDim2.new(
                    0,
                    InitialSize.X.Offset + (Input.Position.X - InitialPosition.X),
                    0,
                    InitialSize.Y.Offset + (Input.Position.Y - InitialPosition.Y)
                )

                self:Tween({Position = NewPosition}, TweenInfo.new(Library.DraggingSpeed, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0))
            end
        end)

        return self
    end

    Library.ConvertToHex = function(self, Color)
        local r = math.floor(Color.R * 255)
        local g = math.floor(Color.G * 255)
        local b = math.floor(Color.B * 255)
        return string.format("#%02X%02X%02X", r, g, b)
    end

    Library.ConvertFromHex = function(self, Color)
        Color = Color:gsub("#", "")
        local r = tonumber(Color:sub(1, 2), 16) / 255
        local g = tonumber(Color:sub(3, 4), 16) / 255
        local b = tonumber(Color:sub(5, 6), 16) / 255
        return Color3.new(r, g, b)
    end

    Library.GroupRGB = function(self, String)
        local Values = {}

        for Value in string.gmatch(String, "[^,]+") do
            table.insert(Values, tonumber(Value))
        end

        if #Values == 4 then
            return unpack(Values)
        else
            return
        end
    end

    Library.ConvertEnum = function(self,value)
        if typeof(value)=="EnumItem" then return value end
        local name=tostring(value or ""):gsub("^%s+",""):gsub("%s+$","")
        name=name:gsub("^Enum%.",""):gsub("^KeyCode%.",""):gsub("^UserInputType%.","")
        local normalized=name:lower():gsub("[%s_%-]","")
        if normalized=="" or normalized=="none" or normalized=="clear" then return "NONE" end
        local aliases={m1="MouseButton1",mb1="MouseButton1",leftclick="MouseButton1",m2="MouseButton2",mb2="MouseButton2",
            rightclick="MouseButton2",m3="MouseButton3",mb3="MouseButton3",middleclick="MouseButton3",ctrl="LeftControl",
            shift="LeftShift",alt="LeftAlt",enter="Return",esc="Escape",spacebar="Space",
            ["0"]="Zero",["1"]="One",["2"]="Two",["3"]="Three",["4"]="Four",["5"]="Five",["6"]="Six",["7"]="Seven",["8"]="Eight",["9"]="Nine"}
        name=aliases[normalized] or name
        normalized=name:lower()
        for _,kind in ipairs({Enum.KeyCode,Enum.UserInputType}) do
            for _,item in ipairs(kind:GetEnumItems()) do
                if item.Name:lower()==normalized and item~=Enum.KeyCode.Unknown then
                    if kind==Enum.KeyCode or item==Enum.UserInputType.MouseButton1 or item==Enum.UserInputType.MouseButton2 or item==Enum.UserInputType.MouseButton3 then return item end
                end
            end
        end
        return nil
    end

    Library.Lerp = function(self, start, finish, t)
        t = t or 1 / 8

        return start * (1 - t) + finish * t
    end

    Library.Round = function(self, num, float)
        local Multiplier = 1 / (float or 1)
        return math.floor(num * Multiplier + 0.5) / Multiplier
    end

    Library.UpdateConfigList = function(self)
        local List = {}

        for _, File in listfiles(Library.Directory .. "/Configs") do
            local Name = File:gsub(Library.Directory .. "/Configs\\", ""):gsub(".Cfg", ""):gsub(Library.Directory .. "\\Configs\\", "")
            List[#List + 1] = Name
        end

        self.RefreshOptions(List)
    end

    Library.Keypicker = function(self, properties)
        local Cfg = {
            Text = properties.Text or "Color",
            Flag = properties.Flag or properties.Name or "Colorpicker",
            Callback = properties.Callback or function() end,

            Color = properties.Color or Color3.fromRGB(1, 1, 1), -- Default to white color if not provided
            Alpha = properties.Alpha or properties.Transparency or 0,

            -- Other
            Open = false,
            Items = {};
            Tweening = false;
        }

        local DraggingSat = false
        local DraggingHue = false
        local DraggingAlpha = false

        local h, s, v = Cfg.Color:ToHSV()
        local a = Cfg.Alpha

        local OldHue = h;
        local OldAlpha = a;

        Flags[Cfg.Flag] = {Color = Cfg.Color, Transparency = Cfg.Alpha}

        local Items = Cfg.Items; do
            Items.Holder = self.Items.Holder
            if not Items.Holder then
                Items.Object = Library:Create( "Frame", {
                    Parent = self.Items.Elements.Instance;
                    BackgroundTransparency = 1;
                    Size = UDim2.new(1, 0, 0, 18);
                    BorderSizePixel = 0
                })

                Items.Text = Library:Create( "TextLabel", {Name="PlexRole_Values";
                    FontFace = Themes.Preset.Font;
                    TextColor3 = Color3.fromRGB(252, 252, 252);
                    Text = Cfg.Text;
                    Parent = Items.Object.Instance;
                    AnchorPoint = Vector2.new(0, 0.5);
                    AutomaticSize = Enum.AutomaticSize.XY;
                    BackgroundTransparency = 1;
                    Position = UDim2.new(0, 0, 0.5, 0);
                    BorderSizePixel = 0;
                    ZIndex = 2
                })

                Items.Holder = Library:Create( "Frame", {
                    Parent = Items.Object.Instance;
                    Position = UDim2.new(1, 1, 0, 0);
                    Size = UDim2.new(0, 0, 1, 0);
                    BorderSizePixel = 0
                })

                Library:Create( "UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal;
                    HorizontalAlignment = Enum.HorizontalAlignment.Right;
                    Parent = Items.Holder.Instance;
                    Padding = UDim.new(0, 7);
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
            end

            Items.ColorpickerObject = Library:Create( "Frame", {
                AnchorPoint = Vector2.new(1, 0);
                Parent = Items.Holder.Instance;
                Position = UDim2.new(1, 1, 0, 0);
                Size = UDim2.new(0, 16, 0, 16);
                BorderSizePixel = 0;
                BackgroundColor3 = Themes.Preset["Accent"]
            }):Themify("Accent", "BackgroundColor3")

            Library:Create( "UICorner", {
                Parent = Items.ColorpickerObject.Instance;
                CornerRadius = UDim.new(0, 5)
            })

            do -- Element clicker
                Items.Colorpicker = Library:Create( "TextButton", {Name="PlexRole_Buttons";
                    Parent = Library.Other.Instance;
                    Position = UDim2.new(0.04664722830057144, 0, 0.17076167464256287, 0);
                    Size = UDim2.new(0, 221, 0, 257);
                    BorderSizePixel = 0;
                    BackgroundColor3 = Themes.Preset["Background"]
                }):Themify("Background", "BackgroundColor3")

                Library:Create( "UIStroke", {
                    Parent = Items.Colorpicker.Instance;
                    Transparency = 0.5
                })

                Library:Create( "UICorner", {
                    Parent = Items.Colorpicker.Instance;
                    CornerRadius = UDim.new(0, 10)
                })

                Items.Title = Library:Create( "TextLabel", {Name="PlexRole_Labels";
                    FontFace = Themes.Preset.Font;
                    TextColor3 = Themes.Preset["TextColor"];
                    Text = "Colorpicker";
                    Parent = Items.Colorpicker.Instance;
                    AutomaticSize = Enum.AutomaticSize.XY;
                    BackgroundTransparency = 1;
                    Position = UDim2.new(0, 8, 0, 8);
                    BorderSizePixel = 0;
                    ZIndex = 2
                }):Themify("TextColor", "TextColor3")

                Items.SatValBackground = Library:Create( "Frame", {
                    Parent = Items.Colorpicker.Instance;
                    Position = UDim2.new(0, 8, 0, 33);
                    Size = UDim2.new(1, -43, 1, -101);
                    BorderSizePixel = 0;
                    BackgroundColor3 = Color3.fromRGB(21, 255, 99)
                })

                Items.Saturation = Library:Create( "Frame", {
                    Parent = Items.SatValBackground.Instance;
                    Size = UDim2.new(1, 0, 1, 0);
                    ZIndex = 2;
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                    BorderSizePixel = 0
                })

                Library:Create( "UIGradient", {
                    Rotation = 270;
                    Transparency = NumberSequence.new{
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(1, 1)
                };
                    Parent = Items.Saturation.Instance;
                    Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
                }
                })

                Library:Create( "UICorner", {
                    Parent = Items.Saturation.Instance;
                    CornerRadius = UDim.new(0, 3)
                })

                Items.Value = Library:Create( "Frame", {
                    Parent = Items.SatValBackground.Instance;
                    Size = UDim2.new(1, 0, 1, 0);
                    BorderSizePixel = 0
                })

                Library:Create( "UIGradient", {
                    Parent = Items.Value.Instance;
                    Transparency = NumberSequence.new{
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(1, 1)
                }
                })

                Library:Create( "UICorner", {
                    Parent = Items.Value.Instance;
                    CornerRadius = UDim.new(0, 5)
                })

                Library:Create( "UICorner", {
                    Parent = Items.SatValBackground.Instance;
                    CornerRadius = UDim.new(0, 5)
                })

                Library:Create( "UIStroke", {
                    Color = Themes.Preset.ElementOutline;
                    Parent = Items.SatValBackground.Instance
                }):Themify("ElementOutline", "Color")

                Items.SatValPickerHolder = Library:Create( "Frame", {
                    Parent = Items.SatValBackground.Instance;
                    BackgroundTransparency = 1;
                    Position = UDim2.new(0, 3, 0, 3);
                    Size = UDim2.new(1, -6, 1, -6);
                    BorderSizePixel = 0
                })

                Items.SatValPicker = Library:Create( "Frame", {
                    AnchorPoint = Vector2.new(0.5, 0.5);
                    Parent = Items.SatValPickerHolder.Instance;
                    Position = UDim2.new(0.5, 0, 0.5, 0);
                    Size = UDim2.new(0, 7, 0, 7);
                    ZIndex = 1000;
                    BorderSizePixel = 0;
                    BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                })

                Library:Create( "UICorner", {
                    Parent = Items.SatValPicker.Instance;
                    CornerRadius = UDim.new(1, 5)
                })

                Items.Inline = Library:Create( "Frame", {
                    Parent = Items.SatValPicker.Instance;
                    AnchorPoint = Vector2.new(0.5, 0.5);
                    BackgroundTransparency = 0.3499999940395355;
                    Position = UDim2.new(0.5, 0, 0.5, 0);
                    Size = UDim2.new(1, -2, 1, -2);
                    ZIndex = 1001;
                    BorderSizePixel = 0
                })

                Library:Create( "UICorner", {
                    Parent = Items.Inline.Instance;
                    CornerRadius = UDim.new(1, 0)
                })

                Items.Hue = Library:Create( "Frame", {
                    AnchorPoint = Vector2.new(1, 0);
                    Parent = Items.Colorpicker.Instance;
                    Position = UDim2.new(1, -8, 0, 32);
                    Size = UDim2.new(0, 18, 1, -100);
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                    BorderSizePixel = 0
                })

                Library:Create( "UICorner", {
                    Parent = Items.Hue.Instance;
                    CornerRadius = UDim.new(0, 5)
                })

                Library:Create( "UIGradient", {
                    Rotation = 90;
                    Parent = Items.Hue.Instance;
                    Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                    }
                })

                Library:Create( "UIStroke", {
                    Color = Themes.Preset.ElementOutline;
                    Parent = Items.Hue.Instance
                }):Themify("ElementOutline", "Color")

                Items.HuePickerHolder = Library:Create( "Frame", {
                    Parent = Items.Hue.Instance;
                    BackgroundTransparency = 1;
                    Position = UDim2.new(0, 0, 0, 3);
                    Size = UDim2.new(1, 0, 1, -6);
                    BorderSizePixel = 0
                })

                Items.HuePicker = Library:Create( "Frame", {
                    Parent = Items.HuePickerHolder.Instance;
                    AnchorPoint = Vector2.new(0.5, 0.5);
                    BackgroundTransparency = 0.3499999940395355;
                    Position = UDim2.new(0.5, 0, 0.5, 0);
                    Size = UDim2.new(1, 0, 0, 6);
                    ZIndex = 100;
                    BorderSizePixel = 0
                })

                Library:Create( "UICorner", {
                    Parent = Items.HuePicker.Instance;
                    CornerRadius = UDim.new(0, 2)
                })

                Library:Create( "UIStroke", {
                    Parent = Items.HuePicker.Instance
                })

                Items.Alpha = Library:Create( "Frame", {
                    AnchorPoint = Vector2.new(0, 1);
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                    Parent = Items.Colorpicker.Instance;
                    Position = UDim2.new(0, 8, 1, -41);
                    Size = UDim2.new(1, -17, 0, 18);
                    BorderSizePixel = 0
                })

                Library:Create( "UICorner", {
                    Parent = Items.Alpha.Instance;
                    CornerRadius = UDim.new(0, 5)
                })

                Items.AlphaIndicator = Library:Create( "ImageLabel", {
                    ScaleType = Enum.ScaleType.Tile;
                    ClipsDescendants = true;
                    Parent = Items.Alpha.Instance;
                    Rotation = 180;
                    Image = "rbxassetid://18274452449";
                    BackgroundTransparency = 1;
                    Size = UDim2.new(1, 0, 1, 0);
                    TileSize = UDim2.new(0, 6, 0, 6);
                    BorderSizePixel = 0
                })

                Items.AlphaIndicatorHolder = Library:Create( "Frame", {
                    Parent = Items.AlphaIndicator.Instance;
                    Size = UDim2.new(1, 0, 1, 0);
                    BorderSizePixel = 0
                })

                Library:Create( "UICorner", {
                    Parent = Items.AlphaIndicatorHolder.Instance;
                    CornerRadius = UDim.new(0, 5)
                })

                Items.AlphaGradient = Library:Create( "UIGradient", {
                    Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(21, 255, 99)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(21, 255, 99))
                };
                    Transparency = NumberSequence.new{
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0)
                };
                    Parent = Items.AlphaIndicatorHolder.Instance
                })

                Library:Create( "UICorner", {
                    Parent = Items.AlphaIndicator.Instance;
                    CornerRadius = UDim.new(0, 5)
                })

                Library:Create( "UIStroke", {
                    Color = Themes.Preset.ElementOutline;
                    Parent = Items.Alpha.Instance
                }):Themify("ElementOutline", "Color")

                Items.AlphaPickerHolder = Library:Create( "Frame", {
                    Parent = Items.Alpha.Instance;
                    BackgroundTransparency = 1;
                    Position = UDim2.new(0, 3, 0, 0);
                    Size = UDim2.new(1, -6, 1, 0);
                    BorderSizePixel = 0
                })

                Items.AlphaPicker = Library:Create( "Frame", {
                    Parent = Items.AlphaPickerHolder.Instance;
                    AnchorPoint = Vector2.new(0.5, 0.5);
                    BackgroundTransparency = 0.3499999940395355;
                    Position = UDim2.new(0.5, 0, 0.5, 0);
                    Size = UDim2.new(0, 6, 1, 0);
                    ZIndex = 100;
                    BorderSizePixel = 0
                })

                Library:Create( "UICorner", {
                    Parent = Items.AlphaPicker.Instance;
                    CornerRadius = UDim.new(0, 2)
                })

                Library:Create( "UIStroke", {
                    Parent = Items.AlphaPicker.Instance
                })

                Items.Elements = Library:Create( "Frame", {
                    Parent = Items.Colorpicker.Instance;
                    BackgroundTransparency = 1;
                    Position = UDim2.new(0, 8, 1, -32);
                    Size = UDim2.new(1, -16, 0, 0);
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.Y
                })

                local Section = setmetatable({Items = Items}, Library)
                Items.RGB = Section:AddInput({Flag = "ignore", PlaceHolder = "Color", Callback = function(text)
                    if Cfg.Set then
                        local r, g, b, a = Library:GroupRGB(text)

                        if (r and g and b and a) then
                            Cfg.Set(Color3.fromRGB(r, g, b), 1 - a)
                        else
                            Cfg.Set(Color3.fromHSV(h, s, v), 1 - a)
                        end
                    end
                end})

                Library:Create( "UIListLayout", {
                    Parent = Items.Elements.Instance;
                    Padding = UDim.new(0, 7);
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
            end

            do -- Holder
                Items.Colorpicker:Resizify()
                Items.Colorpicker:Reparent(Library.Elements.Instance)
            end
        end

        Cfg.SetVisible = function(open)
            local showing=open==nil and not Cfg.Open or open==true
            if showing==Cfg.Open then return end
            Cfg.Open=showing
            Cfg.PlexPopupAnchor=Items.ColorpickerObject.Instance
            Library.PlexOpenPopups[Items.Colorpicker.Instance]=Cfg
            local position
            if showing then
                local anchor=Items.ColorpickerObject.Instance
                position=UDim2.fromOffset(anchor.AbsolutePosition.X,anchor.AbsolutePosition.Y+anchor.AbsoluteSize.Y+6)
            end
            Library:AnimateVisibility(Items.Colorpicker.Instance,showing,function()
                if not Cfg.Open then Library.PlexOpenPopups[Items.Colorpicker.Instance]=nil end
            end,position)
        end

        Cfg.UpdateColor = function()
            local Mouse = Services.UserInputService:GetMouseLocation()
            local Offset = Vector2.new(Mouse.X, Mouse.Y - GuiInset)

            if DraggingSat then
                s = math.clamp((Offset - Items.Saturation.Instance.AbsolutePosition).X / Items.Saturation.Instance.AbsoluteSize.X, 0, 1)
                v = 1 - math.clamp((Offset - Items.Saturation.Instance.AbsolutePosition).Y / Items.Saturation.Instance.AbsoluteSize.Y, 0, 1)
            elseif DraggingHue then
                h = math.clamp((Offset - Items.Hue.Instance.AbsolutePosition).Y / Items.Hue.Instance.AbsoluteSize.Y, 0, 1)
            elseif DraggingAlpha then
                a = math.clamp((Offset - Items.Alpha.Instance.AbsolutePosition).X / Items.Alpha.Instance.AbsoluteSize.X, 0, 1)
            end

            Cfg.Set()
        end

        Cfg.Set = function(Color, Alpha)
            if type(Color) == "boolean" then
                return
            end

            if Color then
                h, s, v = Color:ToHSV()
            end

            if Alpha then
                a = Alpha
            end

            local TweenInformation = TweenInfo.new(Library.DraggingSpeed, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0)
            local Flag = Flags[Cfg.Flag]

            Items.ColorpickerObject.Instance.BackgroundColor3 = Color3.fromHSV(h, s, v)
            Items.SatValBackground.Instance.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            Items.AlphaGradient.Instance.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromHSV(h, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromHSV(h, 1, 1))
            }

            Items.SatValPicker:Tween({Position = UDim2.new(s, 0, 1 - v, 0)}, TweenInformation)
            Items.AlphaPicker:Tween({Position = UDim2.new(a, 0, 0.5, 0)}, TweenInformation)
            Items.HuePicker:Tween({Position = UDim2.new(0.5, 0, h, 0)}, TweenInformation)

            OldHue = h
            OldAlpha = a

            Color = Items.ColorpickerObject.Instance.BackgroundColor3 -- Overwriting to format<<

            if not Items.RGB.Focused then
                Items.RGB.Items.Textbox.Instance.Text = string.format("%s, %s, %s, %s", Library:Round(Color.R * 255), Library:Round(Color.G * 255), Library:Round(Color.B * 255), Library:Round(1 - a, 0.01))
            end

            Flags[Cfg.Flag] = {
                Color = Color;
                Transparency = a
            }

            Cfg.Callback(Color, a)
        end

        Items.ColorpickerObject:OnClick(Cfg.SetVisible)
        Items.Colorpicker:OutsideClick(Cfg)

        Cfg.DisableDragging = function()
            DraggingSat = false
            DraggingHue = false
            DraggingAlpha = false
        end

        Items.Alpha:OnDrag(Cfg.UpdateColor, function(Dragging)
            if Dragging then
                DraggingAlpha = true
            else
                Cfg.DisableDragging()
            end
        end)

        Items.Hue:OnDrag(Cfg.UpdateColor, function(Dragging)
            if Dragging then
                DraggingHue = true
            else
                Cfg.DisableDragging()
            end
        end)

        Items.Saturation:OnDrag(Cfg.UpdateColor, function(Dragging)
            if Dragging then
                DraggingSat = true
            else
                Cfg.DisableDragging()
            end
        end)

        Cfg.Set(Cfg.Color, Cfg.Alpha)

        ConfigFlags[Cfg.Flag] = Cfg.Set

        if self.UpdateSection then
            self.UpdateSection(Items.Object.Instance or self.Items.Object.Instance)
        end

        return setmetatable(Cfg, Library)
    end

    Library.GetConfig = function(self)
        local Config = {}

        for Idx, Value in Flags do
            if type(Value) == "table" and Value.Key then
                Config[Idx] = {Active = Value.Active, Mode = Value.Mode, Key = tostring(Value.Key)}
            elseif type(Value) == "table" and Value["Transparency"] and Value["Color"] then
                Config[Idx] = {Transparency = Value["Transparency"], Color = Value["Color"]:ToHex()}
            else
                Config[Idx] = Value
            end
        end

        return Services.HttpService:JSONEncode(Config)
    end

    Library.LoadConfig = function(self, JSON)
        local Config = Services.HttpService:JSONDecode(JSON)

        for Idx, Value in Config do
            local Function = ConfigFlags[Idx]

            if Idx == "ignore" then
                continue
            end

            if Function then
                if type(Value) == "table" and Value["Transparency"] and Value["Color"] then
                    Function(Color3.fromHex(Value["Color"]), Value["Transparency"])
                else
                    Function(Value)
                end
            end
        end
    end

    Library.DeleteConfig = function(self, Config)
        local Path = string.format("%s/%s/%s.Cfg", Library.Directory, "Configs", Config)
        if isfile(Path) then
            delfile(Path)
        end
    end

    Library.SaveConfig = function(self, Config)
        local Path = string.format("%s/%s/%s.Cfg", Library.Directory, "Configs", Config)
        writefile(Path, self:GetConfig())
    end

    Library.AutoLoad = function(self)
        self.Window.Tweening = true
        local Name = readfile(Library.Directory.."/Autoload.txt")

        if Name ~= "" then
            for i = 1, 2 do
                self:LoadConfig(readfile(Library.Directory .. "/Configs/" .. Name .. ".Cfg"))
            end
        end
        self.Window.Tweening = false
    end

    Library.Thread = function(self, Function)
        local Thread = coroutine.create(Function)

        coroutine.wrap(function()
            coroutine.resume(Thread)
        end)()

        table.insert(self.Threads, Thread)

        return Thread
    end

    Library.SafeCall = function(self, Function, ...)
        local Arguments = { ... }
        local Success, Result = pcall(Function, table.unpack(Arguments))

        if not Success then
            warn(Result)
            return false
        end

        return Success
    end

    Library.Connect = function(self,Signal,Callback)
        local entry={Event=Signal,Callback=Callback,Connection=Signal:Connect(Callback)}
        table.insert(Library.Connections,entry)
        return entry
    end

    Library.OnClick = function(self, Callback)
        local Connection = Library:Connect(self.Instance.InputBegan, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                Callback()
            end
        end)

        return Connection
    end

    Library.OnHover = function(self, Callback1, Callback2)
        Callback2 = Callback2 or function() end

        Library:Connect(self.Instance.MouseEnter, function()
            Callback1()
        end)

        Library:Connect(self.Instance.MouseLeave, function()
            Callback2()
        end)
    end

    Library.OnDrag = function(self,Callback1,Callback2)
        Library:Connect(self.Instance.InputBegan,function(input)
            if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
                Library.PlexDrag={Input=input,Move=Callback1,Finish=Callback2}
                Callback1(input)
            end
        end)
    end

    Library.Reparent = function(self, Parent)
        Parent = Parent or self.Instance.Parent

        local Connection = Library:Connect(self.Instance:GetPropertyChangedSignal("Visible"), function()
            local Visible = self.Instance.Visible

            self.Instance.Parent = Visible and Parent or Library.Other.Instance
        end)
    end

    Library.OutsideClick = function(self, Cfg)
        local Connection = Library:Connect(Services.UserInputService.InputBegan, function(input)
            if self.Instance.Visible == false then
                return
            end

            local InputType = input.UserInputType

            if not (InputType == Enum.UserInputType.MouseButton1 or InputType == Enum.UserInputType.Touch) then
                return
            end

            local point=input.Position
            local function contains(instance)
                if not instance or not point then return false end
                local position,size=instance.AbsolutePosition,instance.AbsoluteSize
                return point.X>=position.X and point.Y>=position.Y
                    and point.X<=position.X+size.X and point.Y<=position.Y+size.Y
            end
            if contains(self.Instance) or contains(Cfg.PlexPopupAnchor) then return end
            -- Detached child popups still belong to the settings panel that opened them.
            for root,popup in pairs(Library.PlexOpenPopups) do
                local anchor=popup.PlexPopupAnchor
                if root.Visible and anchor and anchor:IsDescendantOf(self.Instance) and contains(root) then return end
            end
            Cfg.SetVisible(false)
        end)

        return Connection
    end

    Library.Disconnect = function(self, Name)
        self.Connection:Disconnect()
    end

    Library.PrepareTouchTextBox = function(self, box)
        if not Services.UserInputService.TouchEnabled or not box.TextEditable then return end
        box.Active = true
        box.Selectable = true
        box.ShowNativeInput = true
        local touch, origin
        Library:Connect(box.InputBegan, function(input)
            if input.UserInputType == Enum.UserInputType.Touch then touch=input;origin=input.Position end
        end)
        Library:Connect(box.InputEnded, function(input)
            if input ~= touch then return end
            touch=nil
            if Library.PlexUnloaded or not box.Parent or not box.Visible or not box.TextEditable then return end
            -- A scroll gesture must not open the keyboard.
            if (input.Position-origin).Magnitude <= 12 and not box:IsFocused() then box:CaptureFocus() end
        end)
        Library:Connect(box.ReturnPressedFromOnScreenKeyboard, function()
            if not box.MultiLine and box:IsFocused() then box:ReleaseFocus(true) end
        end)
    end

    Library.Create = function(self, Class, Options)
        Library.PlexCreateCount=(Library.PlexCreateCount or 0)+1
        if shared.ModernLoading and Library.PlexCreateCount%200==0 then
            Services.RunService.Heartbeat:Wait()
        end
        local Info = {
            Instance = Instance.new(Class);
            Properties = Options;
            Blur;
        }

        local Instance = Info.Instance
        Library.PlexInstances=Library.PlexInstances or {}
        table.insert(Library.PlexInstances,Instance)

        for Property, Value in Info.Properties do
            Instance[Property] = Value
        end

        if Class == "TextButton" then
            Instance.AutoButtonColor = false
            if Options.Text == nil then Instance.Text = "" end
        end

        if Class == "TextLabel" or Class == "TextBox" or Class == "TextButton" then
            if Options.FontFace == nil then Instance.FontFace = Themes.Preset.Font end
            if Options.TextSize == nil then Instance.TextSize = 15 end
        end

        if Class == "TextBox" then Library:PrepareTouchTextBox(Instance) end
        Instance.Name = Options.Name or "\0"

        return setmetatable(Info, Library)
    end

    Library.Unload = function(self)
        if self.PlexUnloaded then return end
        self.PlexUnloaded=true
        self:StopVisibilityAnimations()
        table.clear(self.PlexOpenPopups)
        if self.PlexActiveKeyCapture then self.PlexActiveKeyCapture.CancelCapture() end
        if self.PlexActiveNumberEdit then self.PlexActiveNumberEdit.CancelNumberEdit() end
        for _,entry in ipairs(self.Connections) do
            if entry.Connection then entry.Connection:Disconnect() end
        end
        for _,thread in ipairs(self.Threads) do pcall(task.cancel,thread) end
        for _,instance in ipairs(self.PlexInstances or {}) do pcall(instance.Destroy,instance) end
        table.clear(self.Connections)
        if getgenv().__PlexAetherVendor==self then getgenv().__PlexAetherVendor=nil end
    end

    Library.GetCalculatePosition = function(self, Position, Normal, Origin, Direction)
        local n = Normal;
        local d = Direction;
        local v = Origin - Position;

        local num = (n.x * v.x) + (n.y * v.y) + (n.z * v.z); -- Dot exists for vector3.new too lazy to test
        local den = (n.x * d.x) + (n.y * d.y) + (n.z * d.z);
        local a = -num / den;

        return Origin + (a * Direction);
    end;

    Library.Blurify = function(self, Strength)
        Strength = Strength or 0.97

        local Instance = self.Instance
        self.Strength = Strength
        Library.Blurs[#Library.Blurs + 1] = self
        local Part = Library:Create("Part", {
            Material = Enum.Material.Glass;
            Transparency = Strength;
            Reflectance = 1;
            CastShadow = false;
            Anchored = true;
            CanCollide = false;
            CanQuery = false;
            CollisionGroup = " ";
            Size = Vector3.new(1, 1, 1) * 0.01;
            Color = Color3.fromRGB(0,0,0);
            Parent = Camera,
        });

        local BlockMesh = Library:Create("BlockMesh", {
            Parent = Part.Instance;
        })

        local DepthOfField = Library:Create("DepthOfFieldEffect", {
            Parent = Services.Lighting;
            Enabled = true;
            FarIntensity = 0;
            FocusDistance = 0;
            InFocusRadius = 1000;
            NearIntensity = 1;
            Name = ""
        })

        Library:Connect(Services.RunService.RenderStepped, function()
            if not self.Instance.Visible then
                Part.Transparency = 1
                Part.Instance.CFrame = CFrame.new(0/0, 9e9, 9e9)
                return
            end

            local Corner0 = Instance.AbsolutePosition;
            local Corner1 = Corner0 + Instance.AbsoluteSize;

            local Ray0 = Workspace.CurrentCamera.ScreenPointToRay(Workspace.CurrentCamera,Corner0.X, Corner0.Y, 1);
            local Ray1 = Workspace.CurrentCamera.ScreenPointToRay(Workspace.CurrentCamera,Corner1.X, Corner1.Y, 1);

            local Origin = Workspace.CurrentCamera.CFrame.Position + Workspace.CurrentCamera.CFrame.LookVector * (0.05 - Workspace.CurrentCamera.NearPlaneZ);

            local Normal = Workspace.CurrentCamera.CFrame.LookVector;

            local Pos0 = Library:GetCalculatePosition(Origin, Normal, Ray0.Origin, Ray0.Direction);
            local Pos1 = Library:GetCalculatePosition(Origin, Normal, Ray1.Origin, Ray1.Direction);

            Pos0 = Workspace.CurrentCamera.CFrame:PointToObjectSpace(Pos0);
            Pos1 = Workspace.CurrentCamera.CFrame:PointToObjectSpace(Pos1);

            local Size = Pos1 - Pos0;
            local Center = (Pos0 + Pos1) / 2;

            BlockMesh.Instance.Offset = Center
            BlockMesh.Instance.Scale  = Size / 0.0101;

            Part.Instance.CFrame = Workspace.CurrentCamera.CFrame;
            Part.Instance.Transparency = self.Strength
        end)

        return self
    end

    Library.Items = Library:Create( "ScreenGui" , {
        Parent = Services.CoreGui;
        Name = "\0";
        Enabled = true;
        ZIndexBehavior = Enum.ZIndexBehavior.Global;
        IgnoreGuiInset = true;
        DisplayOrder = 100;
    });

    Library.Other = Library:Create( "ScreenGui" , {
        Parent = Services.CoreGui;
        Name = "\0";
        Enabled = false;
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
        IgnoreGuiInset = true;
    });

    Library.Elements = Library:Create( "ScreenGui" , {
        Parent = Services.CoreGui;
        Name = "\0";
        Enabled = true;
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
        IgnoreGuiInset = true;
        DisplayOrder = 101;
    });

    -- // Elements
    Library.CreateWindow = function(self, Data)
        Data = Data or {}
        local Self = self

        local Cfg = {
            Title = Data.Title or "Aether.lua";
            SubText = Data.SubText or "Baseplate";
            Size = Data.Size or UDim2.fromOffset(775, 531);
            Image = Data.Image or "rbxassetid://95259225424429";
            IsMobile = Data.IsMobile or false;

            Position;
            Size;
            Items = {};
            Tweening = false;
            Tick = tick();
            Fps = 0;
            TabInfo;
            Visible = true;
        }

        local Items = Cfg.Items; do
            Items.Menu = Library:Create( "Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5);
                Parent = Library.Items.Instance;
                ClipsDescendants = true;
                Position = UDim2.new(0.5, 0, 0.5, 75);
                Size = Cfg.Size;
                Visible = false;
                BorderSizePixel = 0;
                BackgroundColor3 = Themes.Preset["Background"]
            }):Themify("Background", "BackgroundColor3")

            Library:Create( "UIScale", {
                Parent = Items.Menu.Instance;
                Scale = 0.65
            })

            Items.Menu.Instance.Position = UDim2.fromOffset(Items.Menu.Instance.AbsolutePosition.X, Items.Menu.Instance.AbsolutePosition.Y)
            Items.Menu.Instance.AnchorPoint = Vector2.new(0, 0)

            Items.Menu:Draggify()
            Items.Menu:Resizify()

            Library:Create( "UICorner", {
                Parent = Items.Menu.Instance;
                CornerRadius = UDim.new(0, 10)
            })

            Library:Create( "UIStroke", {
                Parent = Items.Menu.Instance;
                Transparency = 0.5
            })

            Items.SideBar = Library:Create( "Frame", {
                Parent = Items.Menu.Instance;
                Size = UDim2.new(0, 178, 1, 0);
                BorderSizePixel = 0;
                BackgroundColor3 = Themes.Preset["Background"]
            }):Themify("Background", "BackgroundColor3")

            Items.TabButtonHolder = Library:Create( "Frame", {
                Parent = Items.SideBar.Instance;
                BackgroundTransparency = 1;
                Position = UDim2.new(0, 0, 0, 88);
                Size = UDim2.new(1, 0, 1, -88);
                BorderSizePixel = 0
            })

            Library:Create( "UIListLayout", {
                Parent = Items.TabButtonHolder.Instance;
                Padding = UDim.new(0, 8);
                SortOrder = Enum.SortOrder.LayoutOrder
            })

            Library:Create( "UIPadding", {
                Parent = Items.TabButtonHolder.Instance;
                PaddingRight = UDim.new(0, 16);
                PaddingLeft = UDim.new(0, 16)
            })

            Library:Create( "UICorner", {
                Parent = Items.SideBar.Instance;
                CornerRadius = UDim.new(0, 10)
            })

            Library:Create( "Frame", {
                Parent = Items.SideBar.Instance;
                Position = UDim2.new(1, 0, 0, 0);
                Size = UDim2.new(0, 1, 1, 0);
                BorderSizePixel = 0;
                BackgroundColor3 = Themes.Preset["Inline"]
            }):Themify("Inline", "BackgroundColor3")

            Items.Pages = Library:Create( "Frame", {
                Parent = Items.Menu.Instance;
                BackgroundTransparency = 1;
                Position = UDim2.new(0, 178, 0, 88);
                Size = UDim2.new(1, -178, 1, -88);
                BorderSizePixel = 0
            })

            Library:Create( "UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal;
                HorizontalFlex = Enum.UIFlexAlignment.Fill;
                Parent = Items.Pages.Instance;
                Padding = UDim.new(0, 15);
                SortOrder = Enum.SortOrder.LayoutOrder;
                VerticalFlex = Enum.UIFlexAlignment.Fill
            })

            Library:Create( "UIPadding", {
                PaddingBottom = UDim.new(0, 16);
                Parent = Items.Pages.Instance;
                PaddingLeft = UDim.new(0, 17);
                PaddingRight = UDim.new(0, 16)
            })

            Items.Topbar = Library:Create( "Frame", {
                Parent = Items.Menu.Instance;
                BackgroundTransparency = 1;
                Size = UDim2.new(1, 0, 0, 71);
                BorderSizePixel = 0
            })

            Items.Subtabs = Library:Create( "Frame", {
                Parent = Items.Topbar.Instance;
                BackgroundTransparency = 1;
                Position = UDim2.new(0, 178, 0, 0);
                Size = UDim2.new(1, -178, 1, 0);
                BorderSizePixel = 0
            })

            Library:Create( "UIPadding", {
                PaddingTop = UDim.new(0, 17);
                PaddingBottom = UDim.new(0, 17);
                Parent = Items.Subtabs.Instance;
                PaddingRight = UDim.new(0, 15);
                PaddingLeft = UDim.new(0, 18)
            })

            Library:Create( "Frame", {
                Parent = Items.Topbar.Instance;
                Position = UDim2.new(0, 0, 1, 0);
                Size = UDim2.new(1, 0, 0, 1);
                BorderSizePixel = 0;
                BackgroundColor3 = Themes.Preset["Inline"]
            }):Themify("Inline", "BackgroundColor3")

            Items.LogoHolder = Library:Create( "Frame", {
                Parent = Items.Topbar.Instance;
                BackgroundTransparency = 1;
                Position = UDim2.new(0, 0, 0, 1);
                Size = UDim2.new(1, 0, 0, 82);
                BorderSizePixel = 0
            })

            Items.Logo = Library:Create( "ImageLabel", {
                ImageColor3 = Color3.new(1,1,1);
                Parent = Items.LogoHolder.Instance;
                AnchorPoint = Vector2.new(0, 0);
                Image = Cfg.Image;
                BackgroundTransparency = 1;
                Position = UDim2.fromOffset(14, 24);
                Size = UDim2.fromOffset(30, 30);
                BorderSizePixel = 0
            })

            Items.BrandTitle = Library:Create( "TextLabel", {Name="PlexRole_Window title";
                FontFace = Font.fromEnum(Enum.Font.GothamBold);
                TextSize = 14;
                TextColor3 = Themes.Preset["TextColor"];
                Text = Cfg.Title;
                Parent = Items.Topbar.Instance;
                AnchorPoint = Vector2.new(0, 0);
                AutomaticSize = Enum.AutomaticSize.None;
                Size = UDim2.fromOffset(62, 18);
                TextXAlignment = Enum.TextXAlignment.Left;
                BackgroundTransparency = 1;
                Position = UDim2.fromOffset(52, 23);
                BorderSizePixel = 0;
                ZIndex = 2
            }):Themify("TextColor", "TextColor3")

            local buildBadge=Library:Create("TextLabel",{Name="BuildBadge",Text="DEV",FontFace=Font.fromEnum(Enum.Font.GothamBold),
                TextSize=9,TextColor3=Themes.Preset.Accent,BackgroundColor3=Themes.Preset.Accent,
                BackgroundTransparency=0.9,BorderSizePixel=0,Size=UDim2.fromOffset(27,16),
                Position=UDim2.fromOffset(130,62),ZIndex=2,Parent=Items.Topbar.Instance}):Themify("Accent","TextColor3"):Themify("Accent","BackgroundColor3")
            Library:Create("UICorner",{CornerRadius=UDim.new(0,4),Parent=buildBadge.Instance})

            Items.Subtitle = Library:Create( "TextLabel", {Name="PlexRole_Subtitle";
                FontFace = Font.fromEnum(Enum.Font.Gotham);
                TextSize = 10;
                TextColor3 = Themes.Preset["Unselected"];
                Text = Cfg.SubText;
                Parent = Items.Logo.Instance;
                AnchorPoint = Vector2.new(0, 0.5);
                AutomaticSize = Enum.AutomaticSize.XY;
                BackgroundTransparency = 1;
                Position = UDim2.new(1, 10, 0.550000011920929, 1);
                BorderSizePixel = 0;
                ZIndex = 2
            }):Themify("Unselected", "TextColor3")

            Items.MobileFrame = Library:Create( "Frame", {
                Visible = false;
                Parent = Items.Menu.Instance;
                BackgroundTransparency = 1;
                Position = UDim2.new(0, 0, 0, 71);
                Size = UDim2.new(1, 0, 1, -71);
                ZIndex = 100;
                BorderSizePixel = 0;
                BackgroundColor3 = Themes.Preset["Background"]
            }):Themify("Background", "BackgroundColor3")

            Items.MobileFrame2 = Library:Create( "Frame", {
                Visible = false;
                Parent = Items.Menu.Instance;
                BackgroundTransparency = 1;
                Position = UDim2.new(0, 71, 0, 0);
                Size = UDim2.new(1, 0, 1, 0);
                ZIndex = 100;
                BorderSizePixel = 0;
                BackgroundColor3 = Themes.Preset["Background"]
            }):Themify("Background", "BackgroundColor3");

                        -- // keybind list top
            Items.KeybindList = Library:Create("Frame",{ZIndex = 999; Parent = Library.HUD.Instance; Size = UDim2.new(0, 200, 0, 31); Position = UDim2.new(0, 37, 0, 401); BorderSizePixel = 0; ZIndex = 2; BackgroundColor3 = Color3.fromRGB(20, 20, 22)})
            Items.UIStroke = Library:Create("UIStroke",{Color = Color3.fromRGB(23, 24, 27); Parent = Items.KeybindList.Instance})
            Items.UIPadding = Library:Create("UIPadding",{PaddingTop = UDim.new(0, 2); PaddingBottom = UDim.new(0, 2); Parent = Items.KeybindList.Instance; PaddingRight = UDim.new(0, 2); PaddingLeft = UDim.new(0, 2)})
            Items.UICorner = Library:Create("UICorner",{Parent = Items.KeybindList.Instance})
            Items.Titles = Library:Create("TextLabel",{Name="PlexRole_Overlay titles"; LayoutOrder = 1; TextColor3 = Color3.fromRGB(245, 245, 245); Text = "Keybinds"; Parent = Items.KeybindList.Instance; AutomaticSize = Enum.AutomaticSize.XY; Position = UDim2.new(0, 0, 0, 3); BackgroundTransparency = 1; TextXAlignment = Enum.TextXAlignment.Left; BorderSizePixel = 0; ZIndex = 2; BackgroundColor3 = Color3.fromRGB(255, 255, 255)})
            Items.UIPadding = Library:Create("UIPadding",{PaddingTop = UDim.new(0, 4); PaddingBottom = UDim.new(0, 6); Parent = Items.Titles.Instance; PaddingRight = UDim.new(0, 5); PaddingLeft = UDim.new(0, 7)})
            Items.Filler = Library:Create("Frame",{Parent = Items.KeybindList.Instance; Position = UDim2.new(0, -3, 1, -14); Size = UDim2.new(1, 6, 0, 18); BorderSizePixel = 0; BackgroundColor3 = Color3.fromRGB(20, 20, 22)})
            Items.BottomFiller = Library:Create("Frame",{AnchorPoint = Vector2.new(0, 1); Parent = Items.Filler.Instance; Position = UDim2.new(0, 0, 1, 0); Size = UDim2.new(1, 0, 0, 1); BorderSizePixel = 0; BackgroundColor3 = Color3.fromRGB(23, 24, 27)})
            Items.KeyboardIcon = Library:Create("ImageLabel",{ImageColor3 = Themes.Preset.Accent; Parent = Items.KeybindList.Instance; Size = UDim2.new(0, 18, 0, 18); AnchorPoint = Vector2.new(1, 0); Image = "rbxassetid://97239058232142"; BackgroundTransparency = 1; Position = UDim2.new(1, -5, 0, 5); ZIndex = 2; BorderSizePixel = 0; BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Themify("Accent", "ImageColor3")

            Items.KeybindList:Draggify()


            -- // Where the keybinds are parented
            Items.KeybindHolder = Library:Create("Frame",{ZIndex = 0; Parent = Items.KeybindList.Instance; Size = UDim2.new(0, 200, 0, 0); Position = UDim2.new(0, -2, 0, 18); BorderSizePixel = 0; BackgroundColor3 = Color3.fromRGB(15, 16, 18)})
            Items.UICorner = Library:Create("UICorner",{Parent = Items.KeybindHolder.Instance})
            Items.UIPadding = Library:Create("UIPadding",{PaddingTop = UDim.new(0, 18); PaddingBottom = UDim.new(0, 2); Parent = Items.KeybindHolder.Instance; PaddingRight = UDim.new(0, 2); PaddingLeft = UDim.new(0, 2)})
            Items.UIStroke = Library:Create("UIStroke",{Color = Color3.fromRGB(23, 24, 27); Parent = Items.KeybindHolder.Instance})


            -- // Modlist list top
            Items.ModList = Library:Create("Frame",{ZIndex = 999; Parent = Library.HUD.Instance; Size = UDim2.new(0, 200, 0, 31); Position = UDim2.new(0, 37 + 200 + 10, 0, 401); BorderSizePixel = 0; ZIndex = 2; BackgroundColor3 = Color3.fromRGB(20, 20, 22)})
            Items.UIStroke = Library:Create("UIStroke",{Color = Color3.fromRGB(23, 24, 27); Parent = Items.ModList.Instance})
            Items.UIPadding = Library:Create("UIPadding",{PaddingTop = UDim.new(0, 2); PaddingBottom = UDim.new(0, 2); Parent = Items.ModList.Instance; PaddingRight = UDim.new(0, 2); PaddingLeft = UDim.new(0, 2)})
            Items.UICorner = Library:Create("UICorner",{Parent = Items.ModList.Instance})
            Items.Titles = Library:Create("TextLabel",{Name="PlexRole_Overlay titles"; LayoutOrder = 1; TextColor3 = Color3.fromRGB(245, 245, 245); Text = "Mods"; Parent = Items.ModList.Instance; AutomaticSize = Enum.AutomaticSize.XY; Position = UDim2.new(0, 0, 0, 3); BackgroundTransparency = 1; TextXAlignment = Enum.TextXAlignment.Left; BorderSizePixel = 0; ZIndex = 2; BackgroundColor3 = Color3.fromRGB(255, 255, 255)})
            Items.UIPadding = Library:Create("UIPadding",{PaddingTop = UDim.new(0, 4); PaddingBottom = UDim.new(0, 6); Parent = Items.Titles.Instance; PaddingRight = UDim.new(0, 5); PaddingLeft = UDim.new(0, 7)})
            Items.Filler = Library:Create("Frame",{Parent = Items.ModList.Instance; Position = UDim2.new(0, -3, 1, -14); Size = UDim2.new(1, 6, 0, 18); BorderSizePixel = 0; BackgroundColor3 = Color3.fromRGB(20, 20, 22)})
            Items.BottomFiller = Library:Create("Frame",{AnchorPoint = Vector2.new(0, 1); Parent = Items.Filler.Instance; Position = UDim2.new(0, 0, 1, 0); Size = UDim2.new(1, 0, 0, 1); BorderSizePixel = 0; BackgroundColor3 = Color3.fromRGB(23, 24, 27)})
            Items.KeyboardIcon = Library:Create("ImageLabel",{ImageColor3 = Themes.Preset.Accent; Parent = Items.ModList.Instance; Size = UDim2.new(0, 18, 0, 18); AnchorPoint = Vector2.new(1, 0); Image = "rbxassetid://74208295465261"; BackgroundTransparency = 1; Position = UDim2.new(1, -5, 0, 5); ZIndex = 2; BorderSizePixel = 0; BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Themify("Accent", "ImageColor3")

            Items.ModList:Draggify()

            -- // Where the Mods are parented
            Items.ModHolder = Library:Create("Frame",{ZIndex = 0; Parent = Items.ModList.Instance; Size = UDim2.new(0, 200, 0, 0); Position = UDim2.new(0, -2, 0, 18); BorderSizePixel = 0; BackgroundColor3 = Color3.fromRGB(15, 16, 18)})
            Items.UICorner = Library:Create("UICorner",{Parent = Items.ModHolder.Instance})
            Items.UIPadding = Library:Create("UIPadding",{PaddingTop = UDim.new(0, 18); PaddingBottom = UDim.new(0, 2); Parent = Items.ModHolder.Instance; PaddingRight = UDim.new(0, 2); PaddingLeft = UDim.new(0, 2)})
            Items.UIStroke = Library:Create("UIStroke",{Color = Color3.fromRGB(23, 24, 27); Parent = Items.ModHolder.Instance})
        end

        Items.Menu.Instance:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
            if Cfg.Visible or Cfg.Tweening then
                return
            end

            Cfg.Position = Items.Menu.Instance.AbsolutePosition
        end)

        Items.Menu.Instance:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            if not Cfg.Visible or Cfg.Tweening then
                return
            end

            local AbsoluteSize = Items.Menu.Instance.AbsoluteSize
            Cfg.Size = Vector2.new(AbsoluteSize.X, AbsoluteSize.Y)
        end)

        Items.Watermark = Library:Create("CanvasGroup",{Parent = Library.HUD.Instance; Position = UDim2.new(0, 30, 0, 200); BorderSizePixel = 0; AutomaticSize = Enum.AutomaticSize.XY; BackgroundColor3 = Color3.fromRGB(12, 12, 14)}):Draggify()
        Items.Title = Library:Create("TextLabel",{Name="PlexRole_Overlay titles"; LayoutOrder = 1; TextColor3 = Color3.fromRGB(245, 245, 245); Text = Cfg.Text; Parent = Items.Watermark.Instance; BackgroundTransparency = 1; BorderSizePixel = 0; AutomaticSize = Enum.AutomaticSize.XY; BackgroundColor3 = Color3.fromRGB(255, 255, 255)})
        Items.UIPadding = Library:Create("UIPadding",{PaddingTop = UDim.new(0, 5); PaddingBottom = UDim.new(0, 7); Parent = Items.Title.Instance; PaddingRight = UDim.new(0, 8); PaddingLeft = UDim.new(0, 8)})
        Items.UIPadding = Library:Create("UIPadding",{PaddingTop = UDim.new(0, 2); PaddingBottom = UDim.new(0, 2); Parent = Items.Watermark.Instance; PaddingRight = UDim.new(0, 2); PaddingLeft = UDim.new(0, 2)})
        Items.UICorner = Library:Create("UICorner",{Parent = Items.Watermark.Instance})


        local AbsoluteSize = Items.Menu.Instance.AbsoluteSize
        Cfg.Size = Vector2.new(AbsoluteSize.X, AbsoluteSize.Y)

        local Frames = 0
        local FPS = 0
        local LastTick = tick()
        Library:Connect(Services.RunService.Heartbeat,function()
            Frames += 1
            local Tick = tick()

            if Tick - LastTick >= 1 then
                FPS = Frames
                Frames = 0
                LastTick = Tick
                Items.Title.Instance.Text = string.format("%s | FPS: %s | %s", Cfg.Title, tostring(FPS), os.date("%H:%M:%S"))
            end
        end)

        function Cfg.SetVisible(Bool)
            Cfg.Visible = Bool

            if not Cfg.IsMobile then
                Items.Menu:TweenDescendants(Bool, Cfg)
                return
            end

            if not Cfg.Size then
                return
            end

            Items.MobileFrame:Tween({BackgroundTransparency = Bool and 1 or 0})
            Items.MobileFrame2:Tween({BackgroundTransparency = Bool and 1 or 0})
            Items.Menu:Tween({Size = Bool and UDim2.new(0, Cfg.Size.X, 0, Cfg.Size.Y) or UDim2.new(0, 70, 0, 70)})

            if not (Items.Subtabs.Instance.Visible and Bool) then
                Items.Subtabs:TweenDescendants(Bool, Cfg)
            end

            Cfg.Tweening = false

            if not (Items.SideBar.Instance.Visible and Bool) then
                Items.SideBar:TweenDescendants(Bool, Cfg)
            end
        end

        if Cfg.IsMobile then
            task.delay(Library.TweeningSpeed, function()
                Items.Menu:TweenDescendants(true, Cfg)
            end)

            Items.Logo:OnClick(function()
                if Cfg.Tweening then
                    return
                end

                Cfg.Visible = not Cfg.Visible

                Cfg.SetVisible(Cfg.Visible)
            end)
        end

        Library.Window = setmetatable(Cfg, Library)

        return Library.Window
    end

    Library.PlexIconPaths = {
        info={"12,10 12,18","12,6 12,7"},
        chevron={"8,4 16,12 8,20"},
        shield={"12,2 21,6 20,15 12,22 4,15 3,6 12,2"},
        monitor={"3,3 21,3 21,17 3,17 3,3","12,17 12,21","7,22 17,22"},
        diamond={"3,8 7,3 17,3 21,8 12,22 3,8 21,8","7,3 9,8 12,22 15,8 17,3"},
        users={"2,21 2,16 5,13 11,13 14,16 14,21","16,13 20,13 23,16 23,21"},
        chip={"6,6 18,6 18,18 6,18 6,6","9,9 15,9 15,15 9,15 9,9","9,2 9,6","15,2 15,6","9,18 9,22","15,18 15,22","2,9 6,9","18,15 22,15"},
        crosshair={"12,1 12,7","12,17 12,23","1,12 7,12","17,12 23,12"},
        flame={"13,2 19,10 20,16 17,21 7,21 3,16 4,10 8,13 10,8 13,2","12,13 15,18 12,21 9,18 12,13"},
        sword={"4,20 19,3 22,2 21,6 7,20","3,13 11,21","2,22 5,19"},
        globe={"2,12 22,12","12,2 7,7 7,17 12,22 17,17 17,7 12,2"},
        scan={"2,8 2,2 8,2","16,2 22,2 22,8","22,16 22,22 16,22","8,22 2,22 2,16","6,12 18,12","12,6 12,18"},
        eye={"1,12 6,6 12,4 18,6 23,12 18,18 12,20 6,18 1,12"},
        user={"4,22 4,18 8,14 16,14 20,18 20,22"},
        grid={"3,3 9,3 9,9 3,9 3,3","15,3 21,3 21,9 15,9 15,3","3,15 9,15 9,21 3,21 3,15","15,15 21,15 21,21 15,21 15,15"},
        bolt={"13,1 3,14 11,14 10,23 21,9 13,9 13,1"},
        mask={"2,6 22,6 21,15 16,18 12,14 8,18 3,15 2,6","6,10 9,11","15,11 18,10"},
        shirt={"8,3 3,5 1,10 6,12 6,22 18,22 18,12 23,10 21,5 16,3 15,6 9,6 8,3"},
        palette={"12,2 5,4 2,10 3,17 9,22 14,21 13,17 16,14 21,14 23,10 20,4 12,2"},
        box={"2,7 12,2 22,7 22,18 12,23 2,18 2,7 12,12 22,7","12,12 12,23","7,4 17,9"},
        sliders={"2,5 22,5","2,12 22,12","2,19 22,19","7,2 7,8","17,9 17,15","10,16 10,22"},
        server={"3,2 21,2 21,10 3,10 3,2","3,14 21,14 21,22 3,22 3,14","7,6 9,6","7,18 9,18"},
        gear={"9,2 15,2 16,6 20,6 23,11 20,14 20,18 15,22 12,20 9,22 4,18 4,14 1,11 4,6 8,6 9,2"},
        target={"12,2 12,6","18,12 22,12","12,18 12,22","2,12 6,12"},
        feather={"3,22 17,8","5,18 5,10 13,2 21,2 21,10 13,18 5,18","10,13 10,7","10,13 16,13"},
        ghost={"4,22 4,9 7,3 17,3 20,9 20,22 16,19 12,22 8,19 4,22","8,9 8,11","16,9 16,11"},
        pointer={"4,2 4,21 9,16 13,23 16,21 12,14 20,14 4,2"},
        gun={"2,6 21,6 21,12 12,12 10,21 5,21 7,12 2,12 2,6","12,12 17,16 20,12"},
        arrows={"12,1 12,23","1,12 23,12","8,5 12,1 16,5","8,19 12,23 16,19","5,8 1,12 5,16","19,8 23,12 19,16"},
        phone={"7,1 17,1 19,3 19,21 17,23 7,23 5,21 5,3 7,1","9,4 15,4","10,20 14,20"},
    }
    Library.PlexIconNames={info="info",account="user",gameserver="globe",runtime="chip",build="box",diagnostics="scan",support="feather",combat="shield",categorycombat="shield",categoryvisuals="monitor",categorycosmetics="diamond",categoryplayer="users",categorysystem="chip",
        main="crosshair",rage="flame",melee="sword",world="globe",esp="scan",visuals="eye",character="user",misc="grid",optimizations="bolt",spoofers="mask",
        skins="shirt",customcosmetics="palette",inventoryspoofer="box",weaponconfigs="sliders",servers="server",settings="gear",
        aimbot="target",legitbot="feather",silentaim="ghost",triggerbot="pointer",weapon="gun",movement="arrows",mobilesettings="phone",effects="diamond",sounds="server",hud="monitor",camera="pointer",sky="globe",atmosphere="eye",appearance="palette",preview="monitor",highlight="scan",priority="target",reach="sword",targets="crosshair",unlockall="shield",gunanimations="gun",emotes="user",animations="feather",loadout="box",queue="users",chat="ghost",themes="palette",configs="sliders",script="chip",general="grid"}
    Library.PlexIconKey=function(name)
        local key=tostring(name or ""):lower():gsub("[^%w]","")
        if Library.PlexIconNames[key] then return Library.PlexIconNames[key] end
        if Library.PlexIconPaths[key] then return key end
        for _,pair in ipairs({{"aim","target"},{"skin","shirt"},{"wrap","palette"},{"charm","diamond"},{"finish","sword"},{"emote","user"},{"case","box"},{"sound","server"},{"mobile","phone"},{"config","sliders"},{"rank","shield"},{"world","globe"},{"color","palette"},{"viewmodel","gun"},{"crosshair","crosshair"}}) do
            if key:find(pair[1],1,true) then return pair[2] end
        end
        return "sliders"
    end
    Library.CreatePlexIcon=function(self,parent,name,position,size,color)
        local key=Library.PlexIconKey(name)
        local icon=Library:Create("ImageLabel",{Name="Icon_"..key,Image="",BackgroundTransparency=1,
            Size=UDim2.fromOffset(size,size),Position=position,AnchorPoint=Vector2.new(0,0.5),ZIndex=3,ImageColor3=color,Parent=parent})
        local parts={}
        local function line(x,y,xx,yy)
            local dx,dy=xx-x,yy-y
            local part=Library:Create("Frame",{BorderSizePixel=0,BackgroundColor3=color,AnchorPoint=Vector2.new(0.5,0.5),
                Position=UDim2.fromScale((x+xx)/48,(y+yy)/48),Size=UDim2.new(math.sqrt(dx*dx+dy*dy)/24,0,0,1.4),
                Rotation=math.deg(math.atan2(dy,dx)),ZIndex=4,Parent=icon.Instance})
            parts[#parts+1]={part.Instance,"BackgroundColor3"}
        end
        for _,path in ipairs(Library.PlexIconPaths[key]) do
            local x,y
            for xx,yy in path:gmatch("(%d+),(%d+)") do
                xx,yy=tonumber(xx),tonumber(yy)
                if x then line(x,y,xx,yy) end
                x,y=xx,yy
            end
        end
        for _,circle in ipairs(({info={{12,12,10}},crosshair={{12,12,8}},globe={{12,12,10}},eye={{12,12,4}},user={{12,6,4}},users={{8,6,4},{19,7,3}},gear={{12,12,4}},target={{12,12,8},{12,12,3}},palette={{7,8,1},{13,6,1},{18,9,1}}})[key] or {}) do
            local ring=Library:Create("Frame",{BackgroundTransparency=1,ZIndex=4,AnchorPoint=Vector2.new(0.5,0.5),
                Position=UDim2.fromScale(circle[1]/24,circle[2]/24),Size=UDim2.fromScale(circle[3]/12,circle[3]/12),Parent=icon.Instance})
            Library:Create("UICorner",{CornerRadius=UDim.new(1,0),Parent=ring.Instance})
            local stroke=Library:Create("UIStroke",{Color=color,Thickness=1.4,Parent=ring.Instance})
            parts[#parts+1]={stroke.Instance,"Color"}
        end
        Library:Connect(icon.Instance:GetPropertyChangedSignal("ImageColor3"),function()
            for _,part in ipairs(parts) do part[1][part[2]]=icon.Instance.ImageColor3 end
        end)
        return icon:Themify("Unselected","ImageColor3")
    end

    Library.AddTab = function(self, Data)
        Data = Data or {}

        local Cfg = {
            Text = Data.Text or Data.Name or Data.Title or "Tab";
            Icon = Data.Icon or "rbxassetid://108020878442937";
            Pages = Data.Pages or {"Page 1", "Page 2"};

            -- DO NOT TOUCH
            Sections = {};
            Enabled = false;
            Items = {};
            Tweening = false;
        }

        local Items = Cfg.Items; do
            do -- Button
                Items.Button = Library:Create( "Frame", {
                    Parent = self.Items.TabButtonHolder.Instance;
                    BackgroundTransparency = 1;
                    Size = UDim2.new(1, 0, 0, 40);
                    ZIndex = 2;
                    BorderSizePixel = 0;
                    BackgroundColor3 = Themes.Preset["TabButtons"]
                }):Themify("TabButtons", "BackgroundColor3")

                Library:Create( "UICorner", {
                    Parent = Items.Button.Instance;
                    CornerRadius = UDim.new(0, 6)
                })

                Library:Create( "ImageLabel", {
                    Parent = Items.Button.Instance;
                    AnchorPoint = Vector2.new(1, 0);
                    Image = "rbxassetid://112325323968017";
                    Size = UDim2.new(0, 5, 0, 17);
                    Position = UDim2.new(1, -7, 0, 12);
                    ZIndex = 2;
                    BorderSizePixel = 0
                })

                Items.Icon = Library:CreatePlexIcon(Items.Button.Instance, Cfg.Text,
                    UDim2.new(0,8,0.5,0),18,Themes.Preset.Unselected)

                Items.Title = Library:Create( "TextLabel", {Name="PlexRole_Tabs";
                    FontFace = Themes.Preset.Font;
                    TextColor3 = Themes.Preset["Unselected"];
                    Text = Cfg.Text;
                    Parent = Items.Icon.Instance;
                    AnchorPoint = Vector2.new(0, 0.5);
                    AutomaticSize = Enum.AutomaticSize.XY;
                    BackgroundTransparency = 1;
                    Position = UDim2.new(1, 10, 0.5, 0);
                    BorderSizePixel = 0;
                    ZIndex = 2
                }):Themify("Unselected", "TextColor3")

                Items.Glow = Library:Create( "Frame", {
                    Parent = Items.Button.Instance;
                    BackgroundTransparency = 1;
                    Size = UDim2.new(0, 20, 1, 0);
                    BorderSizePixel = 0;
                    BackgroundColor3 = Themes.Preset["Accent"]
                }):Themify("Accent", "BackgroundColor3")

                Library:Create( "UICorner", {
                    Parent = Items.Glow.Instance;
                    CornerRadius = UDim.new(0, 3)
                })

                Items.GlowImage = Library:Create( "ImageLabel", {
                    ImageColor3 = Themes.Preset["Accent"];
                    ScaleType = Enum.ScaleType.Slice;
                    ImageTransparency = 1;
                    Parent = Items.Glow.Instance;
                    BackgroundColor3 = Themes.Preset["Accent"];
                    Size = UDim2.new(1, 20, 1, 20);
                    Image = "rbxassetid://18245826428";
                    BackgroundTransparency = 1;
                    Position = UDim2.new(0, -20, 0, -10);
                    ZIndex = 2;
                    BorderSizePixel = 0;
                    SliceCenter = Rect.new(Vector2.new(20, 20), Vector2.new(80, 80))
                }):Themify("Accent", "ImageColor3")

                Items.Background = Library:Create( "Frame", {
                    Parent = Items.Button.Instance;
                    BackgroundTransparency = 1;
                    Position = UDim2.new(0, 3, 0, 0);
                    Size = UDim2.new(1, -3, 1, 0);
                    BorderSizePixel = 0;
                    BackgroundColor3 = Themes.Preset["TabButtons"]
                }):Themify("TabButtons", "BackgroundColor3")

                Library:Create( "UICorner", {
                    Parent = Items.Background.Instance;
                    CornerRadius = UDim.new(0, 6)
                })

                Items.Filler = Library:Create( "Frame", {
                    Parent = Items.Background.Instance;
                    BackgroundTransparency = 1;
                    Size = UDim2.new(0, 6, 1, 0);
                    BorderSizePixel = 0;
                    BackgroundColor3 = Themes.Preset["TabButtons"]
                }):Themify("TabButtons", "BackgroundColor3")
            end

            do -- Page
                Items.MainPage = Library:Create( "Frame", {
                    Parent = Library.Other.Instance; -- self.Items.Main.Instance
                    Visible = false;
                    BackgroundTransparency = 1;
                    Position = UDim2.new(0, 178, 0, 88);
                    Size = UDim2.new(1, -178, 1, -88);
                    BorderSizePixel = 0
                })
            end

            do -- Subtabs
                Items.Holder = Library:Create( "Frame", {
                    Parent = Library.Other.Instance; -- self.Items.Subtabs.Instance
                    Size = UDim2.new(0, 0, 0, 37);
                    BorderSizePixel = 0;
                    Visible = false;
                    AutomaticSize = Enum.AutomaticSize.X;
                    BackgroundColor3 = Themes.Preset["Background"]
                }):Themify("Background", "BackgroundColor3")

                Library:Create( "UICorner", {
                    Parent = Items.Holder.Instance
                })

                Items.Outline = Library:Create( "UIStroke", {
                    Color = Themes.Preset["ElementBackground"];
                    Parent = Items.Holder.Instance
                }):Themify("ElementBackground", "Color")

                Library:Create( "UIPadding", {
                    PaddingTop = UDim.new(0, 8);
                    PaddingBottom = UDim.new(0, 8);
                    Parent = Items.Holder.Instance;
                    PaddingRight = UDim.new(0, 8);
                    PaddingLeft = UDim.new(0, 7)
                })

                Library:Create( "UIListLayout", {
                    Parent = Items.Holder.Instance;
                    Padding = UDim.new(0, 5);
                    SortOrder = Enum.SortOrder.LayoutOrder;
                    FillDirection = Enum.FillDirection.Horizontal
                })
            end
        end

        for _,Page in Cfg.Pages do
            local PageData = {
               Items = {},
               Tweening = false
            }

            local ButtonParent = Items.Holder
            local PageParent = Items.MainPage

            local MiscItems = PageData.Items; do
                -- // Button
                MiscItems.Button = Library:Create( "Frame", {
                    Parent = ButtonParent.Instance;
                    BackgroundTransparency = 1;
                    Size = UDim2.new(0, 0, 1, 0);
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.X;
                    BackgroundColor3 = Themes.Preset["Accent"];
                    ZIndex = 9999
                }):Themify("Accent", "BackgroundColor3")

                Library:Create( "UIGradient", {
                    Parent = MiscItems.Button.Instance;
                    Transparency = NumberSequence.new{
                        NumberSequenceKeypoint.new(0, 0.59375),
                        NumberSequenceKeypoint.new(1, 0)
                    }
                })

                Library:Create( "UICorner", {
                    Parent = MiscItems.Button.Instance;
                    CornerRadius = UDim.new(0, 6)
                })

                MiscItems.Text = Library:Create( "TextLabel", {Name="PlexRole_Tabs";
                    FontFace = Themes.Preset.Font;
                    Parent = MiscItems.Button.Instance;
                    TextColor3 = Themes.Preset["Unselected"];
                    Text = Page;
                    AutomaticSize = Enum.AutomaticSize.XY;
                    AnchorPoint = Vector2.new(0, 0.5);
                    Size = UDim2.new(0, 0, 1, 0);
                    BackgroundTransparency = 1;
                    Position = UDim2.new(0, 27, 0.5, -1);
                    BorderSizePixel = 0;
                    ZIndex = 2;
                    BackgroundColor3 = Themes.Preset["ElementBackground"]
                }):Themify("ElementBackground", "BackgroundColor3")

                Library:Create( "UIPadding", {
                    Parent = MiscItems.Button.Instance;
                    PaddingTop = UDim.new(0, 2);
                    PaddingRight = UDim.new(0, 7);
                    PaddingLeft = UDim.new(0, -3);
                })

                Library:CreatePlexIcon(MiscItems.Button.Instance,Page,UDim2.new(0,6,0.5,0),14,Themes.Preset.Unselected)

                MiscItems.Outline = Library:Create( "UIStroke", {
                    Color = Themes.Preset["Accent"];
                    Transparency = 1;
                    Parent = MiscItems.Button.Instance
                }):Themify("Accent", "Color")

                --// Page
                MiscItems.Page = Library:Create( "Frame", {
                    Parent = Library.Other.Instance; -- PageParent.Instance
                    BackgroundTransparency = 1;
                    Visible = false;
                    Size = UDim2.new(1, 0, 1, 0);
                    BorderSizePixel = 0
                })

                Library:Create( "UIPadding", {
                    PaddingBottom = UDim.new(0, 16);
                    Parent = MiscItems.Page.Instance;
                    PaddingLeft = UDim.new(0, 17);
                    PaddingRight = UDim.new(0, 16)
                })

                Library:Create( "UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal;
                    HorizontalFlex = Enum.UIFlexAlignment.Fill;
                    Parent = MiscItems.Page.Instance;
                    Padding = UDim.new(0, 15);
                    SortOrder = Enum.SortOrder.LayoutOrder;
                    VerticalFlex = Enum.UIFlexAlignment.Fill
                })

                MiscItems.Left = Library:Create( "ScrollingFrame", {
                    ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0);
                    Active = true;
                    AutomaticCanvasSize = Enum.AutomaticSize.Y;
                    ScrollBarThickness = 0;
                    Parent = MiscItems.Page.Instance;
                    BackgroundTransparency = 1;
                    Size = UDim2.new(0, 100, 0, 100);
                    BorderSizePixel = 0;
                    CanvasSize = UDim2.new(0, 0, 0, 0)
                })

                Library:Create( "UIPadding", {
                    PaddingTop = UDim.new(0, 1);
                    PaddingBottom = UDim.new(0, 1);
                    Parent = MiscItems.Left.Instance;
                    PaddingRight = UDim.new(0, 1);
                    PaddingLeft = UDim.new(0, 1)
                })

                Library:Create( "UIListLayout", {
                    Parent = MiscItems.Left.Instance;
                    Padding = UDim.new(0, 15);
                    SortOrder = Enum.SortOrder.LayoutOrder
                })

                MiscItems.Right = Library:Create( "ScrollingFrame", {
                    ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0);
                    Active = true;
                    AutomaticCanvasSize = Enum.AutomaticSize.Y;
                    ScrollBarThickness = 0;
                    Parent = MiscItems.Page.Instance;
                    BackgroundTransparency = 1;
                    Size = UDim2.new(0, 100, 0, 100);
                    CanvasSize = UDim2.new(0, 0, 0, 0);
                    BorderSizePixel = 0
                })

                Library:Create( "UIPadding", {
                    PaddingTop = UDim.new(0, 1);
                    PaddingBottom = UDim.new(0, 1);
                    Parent = MiscItems.Right.Instance;
                    PaddingRight = UDim.new(0, 1);
                    PaddingLeft = UDim.new(0, 1)
                })

                Library:Create( "UIListLayout", {
                    Parent = MiscItems.Right.Instance;
                    Padding = UDim.new(0, 15);
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
            end

            PageData.OpenPage = function()
                local OldTab = Cfg.TabInfo

                if OldTab == PageData then
                    return
                end

                if PageData.Tweening or (OldTab and OldTab.Tweening) then
                    return
                end

                if OldTab then
                    OldTab.Items.Text:Tween({TextColor3 = Themes.Preset.Unselected})
                    OldTab.Items.Outline:Tween({Transparency = 1})
                    OldTab.Items.Button:Tween({BackgroundTransparency = 1})

                    OldTab.Items.Page:TweenDescendants(false, OldTab)
                end

                MiscItems.Text:Tween({TextColor3 = Themes.Preset.TextColor})
                MiscItems.Outline:Tween({Transparency = 0})
                MiscItems.Button:Tween({BackgroundTransparency = 0})
                MiscItems.Page.Instance.Size = UDim2.new(1, -40, 1, -40)
                MiscItems.Page:Tween({Size = UDim2.new(1, 0, 1, 0)})
                MiscItems.Page:TweenDescendants(true, PageData)

                Cfg.TabInfo = PageData
            end

            MiscItems.Button:OnClick(PageData.OpenPage)
            MiscItems.Page:Reparent(PageParent.Instance)

            if not Cfg.TabInfo then
                MiscItems.Outline.Instance.Transparency = 0
                MiscItems.Button.Instance.BackgroundTransparency = 0
                PageData.OpenPage()
            end

            PageData.PlexTabOwner=Cfg
            Cfg.Sections[#Cfg.Sections + 1] = setmetatable(PageData, Library)
        end

        Cfg.OpenPage = function()
            local OldTab = self.TabInfo

            if OldTab == Cfg then
                return
            end

            if OldTab then
                OldTab.Items.Icon:Tween({ImageColor3 = Themes.Preset.Unselected})
                OldTab.Items.Title:Tween({TextColor3 = Themes.Preset.Unselected})
                OldTab.Items.GlowImage:Tween({ImageTransparency = 1})

                OldTab.Items.Glow.Instance.BackgroundTransparency = 1
                OldTab.Items.Background.Instance.BackgroundTransparency = 1
                OldTab.Items.Filler.Instance.BackgroundTransparency = 1

                OldTab.Items.MainPage:TweenDescendants(false, self)
                self.Tweening = false
                OldTab.Items.Holder:TweenDescendants(false, self)
            end

            Items.Icon:Tween({ImageColor3 = Themes.Preset.TextColor})
            Items.Title:Tween({TextColor3 = Themes.Preset.TextColor})
            Items.GlowImage:Tween({ImageTransparency = 0.69})

            Items.Glow.Instance.BackgroundTransparency = 0
            Items.Background.Instance.BackgroundTransparency = 0
            Items.Filler.Instance.BackgroundTransparency = 0

            Items.Title:Tween({TextColor3 = Themes.Preset.Accent})
            Items.Icon:Tween({ImageColor3 = Themes.Preset.Accent})

            Items.MainPage.Instance.Size = UDim2.new(1, -178 - 40, 1, -88 - 40);
            Items.MainPage:Tween({Size = UDim2.new(1, -178, 1, -88)})

            Items.MainPage:TweenDescendants(true, Cfg)
            Cfg.Tweening = false
            Items.Holder:TweenDescendants(true, Cfg)

            self.TabInfo = Cfg
        end

        Items.Holder:Reparent(self.Items.Subtabs.Instance)
        Items.MainPage:Reparent(self.Items.Menu.Instance)
        Items.Button:OnClick(Cfg.OpenPage)

        Items.GlowImage.Instance:GetPropertyChangedSignal("ImageColor3"):Connect(function()
            task.wait()

            if self.TabInfo == Cfg then
                Items.Title:Tween({TextColor3 = Themes.Preset.Accent})
                Items.Icon:Tween({ImageColor3 = Themes.Preset.Accent})
            end
        end)

        if not self.TabInfo then
            Cfg.OpenPage()
        end

        return unpack(Cfg.Sections)
    end

    Library.AddSection = function(self, Data)
        Data = Data or {}

        local Cfg = {
            Title = Data.Title or Data.Text or Data.Name or "Title";
            Side = Data.Side or "Left";
            Collapsed = Data.Collapsed or false;

            Items = {};
            Tweening = false;
            CachedSize = 0;
            Incrementing = false;
        }

        local ScalingSize = (self.Items and self.Items[Cfg.Side] and self.Items[Cfg.Side].Instance) and 1 or 0
        local OffsetSize = ScalingSize == 1 and 0 or 200

        local Items = Cfg.Items; do
            Items.Section = Library:Create( "Frame", {
                Parent = (self.Items and self.Items[Cfg.Side] and self.Items[Cfg.Side].Instance) or Library.Other.Instance;
                Size = UDim2.new(ScalingSize, OffsetSize, 0, 0);
                Position = UDim2.new(0, 1, 0, 0);
                BorderSizePixel = 0;
                ClipsDescendants = true;
                -- AutomaticSize = Enum.AutomaticSize.Y;
                BackgroundColor3 = Themes.Preset["SectionBackground"]
            }):Themify("SectionBackground", "BackgroundColor3")

            Library:Create( "TextLabel", {Name="PlexRole_Card titles";
                FontFace = Themes.Preset.Font;
                TextColor3 = Themes.Preset["Unselected"];
                Text = Cfg.Title;
                Parent = Items.Section.Instance;
                AutomaticSize = Enum.AutomaticSize.XY;
                BackgroundTransparency = 1;
                Position = UDim2.new(0, 34, 0, 10);
                BorderSizePixel = 0;
                ZIndex = 2
            }):Themify("Unselected", "TextColor3")

            Library:CreatePlexIcon(Items.Section.Instance,Cfg.Title,UDim2.fromOffset(12,18),14,Themes.Preset.Unselected)

            Items.Elements = Library:Create( "Frame", {
                Parent = Items.Section.Instance;
                BackgroundTransparency = 1;
                Position = UDim2.new(0, 12, 0, 43);
                Size = UDim2.new(1, -24, 0, 0);
                BorderSizePixel = 0;
                AutomaticSize = Enum.AutomaticSize.Y
            })

            Library:Create( "UIPadding", {
                PaddingBottom = UDim.new(0, 8);
                Parent = Items.Elements.Instance
            })

            Library:Create( "UIListLayout", {
                Parent = Items.Elements.Instance;
                Padding = UDim.new(0, 13);
                SortOrder = Enum.SortOrder.LayoutOrder
            })

            Library:Create( "UICorner", {
                Parent = Items.Section.Instance;
                CornerRadius = UDim.new(0, 6)
            })

            Library:Create( "UIStroke", {
                Color = Themes.Preset["Inline"];
                Parent = Items.Section.Instance
            }):Themify("Inline", "Color")

            Items.TopBar = Library:Create( "Frame", {
                Parent = Items.Section.Instance;
                Size = UDim2.new(1, 0, 0, 35);
                BorderSizePixel = 0;
                BackgroundColor3 = Themes.Preset["ElementBackground"]
            }):Themify("ElementBackground", "BackgroundColor3")

            Items.Filler1 = Library:Create( "Frame", {
                AnchorPoint = Vector2.new(0, 1);
                Parent = Items.TopBar.Instance;
                Position = UDim2.new(0, 0, 1, 0);
                Size = UDim2.new(1, 0, 0, 6);
                BorderSizePixel = 0;
                BackgroundColor3 = Themes.Preset["ElementBackground"]
            }):Themify("ElementBackground", "BackgroundColor3")

            Items.Filler2 = Library:Create( "Frame", {
                Parent = Items.TopBar.Instance;
                Position = UDim2.new(0, 0, 1, -1);
                Size = UDim2.new(1, 0, 0, 1);
                BorderSizePixel = 0;
                BackgroundColor3 = Themes.Preset["TabButtons"]
            }):Themify("TabButtons", "BackgroundColor3")

            Library:Create( "UICorner", {
                Parent = Items.TopBar.Instance;
                CornerRadius = UDim.new(0, 6)
            })

            Items.Image = Library:Create( "ImageLabel", {
                Parent = Items.TopBar.Instance;
                Size = UDim2.new(0, 9, 0, 6);
                AnchorPoint = Vector2.new(1, 0.5);
                Image = "rbxassetid://75133155165707";
                BackgroundTransparency = 1;
                Position = UDim2.new(1, -11, 0.5, 0);
                Rotation = 0;
                BorderSizePixel = 0;
                BackgroundColor3 = Themes.Preset.Other
            }):Themify("Other", "BackgroundColor3")
        end

        local Section = Items.Section.Instance

        Cfg.Collapse = function(bool, instant)
            if Cfg.Tweening then
                return
            end

            Cfg.Collapsed = bool
            Items.Elements.Instance.Visible=not bool
            if instant then
                Items.Section.Instance.Size=UDim2.new(ScalingSize,OffsetSize,0,bool and 35 or Cfg.CachedSize+43)
                Items.Filler1.Instance.BackgroundTransparency=bool and 1 or 0
                Items.Filler2.Instance.BackgroundTransparency=bool and 1 or 0
                Items.Image.Instance.Rotation=bool and 180 or 0
                return
            end

            if bool then
                Items.Section:Tween({Size = UDim2.new(ScalingSize, OffsetSize, 0, 35)})
                Items.Filler1:Tween({BackgroundTransparency = 1})
                Items.Filler2:Tween({BackgroundTransparency = 1})
                Items.Image:Tween({Rotation = 180})

                Items.Elements:Tween({Position = UDim2.new(0, 12, 0, 23)})
            else
                Items.Section:Tween({Size = UDim2.new(ScalingSize, OffsetSize, 0, Cfg.CachedSize + 43)})
                Items.Filler1:Tween({BackgroundTransparency = 0})
                Items.Filler2:Tween({BackgroundTransparency = 0})
                Items.Image:Tween({Rotation = 0})

                Items.Elements:Tween({Position = UDim2.new(0, 12, 0, 43)})
            end
        end

        Items.CollapseButton=Library:Create("TextButton",{Name="CollapseCard",Text="",BackgroundTransparency=1,
            AutoButtonColor=false,Size=UDim2.fromOffset(30,35),Position=UDim2.new(1,-30,0,0),
            BorderSizePixel=0,ZIndex=6,Parent=Items.TopBar.Instance})
        Items.CollapseButton:OnClick(function()
            if Cfg.Tweening then
                return
            end

            Cfg.Collapsed = not Cfg.Collapsed

            Cfg.Collapse(Cfg.Collapsed)
            if Cfg.OnCollapsed then Cfg.OnCollapsed(Cfg.Collapsed) end
        end)

        local layout=Items.Elements.Instance:FindFirstChildOfClass("UIListLayout")
        local queued=false
        Cfg.UpdateSection=function()
            if queued then return end
            queued=true
            task.defer(function()
                queued=false
                if Library.PlexUnloaded or not Items.Section.Instance.Parent then return end
                Cfg.CachedSize=layout.AbsoluteContentSize.Y+8
                Items.Section.Instance.Size=UDim2.new(ScalingSize,OffsetSize,0,Cfg.Collapsed and 35 or Cfg.CachedSize+43)
            end)
        end
        Library:Connect(layout:GetPropertyChangedSignal("AbsoluteContentSize"),Cfg.UpdateSection)
        Cfg.UpdateSection()

        return setmetatable(Cfg, Library)
    end

    Library.AddToggle = function(self, Data)
        Data = Data or {}

        local Cfg = {
            Text = Data.Text or "Toggle";
            Flag = Data.Flag or Data.Name or Data.Text or "Toggle";
            Enabled = Data.Default or false;
            Callback = Data.Callback or function() end;

            Items = {};
        }

        local Items = Cfg.Items; do
            Items.Object = Library:Create( "TextButton", {Name="PlexRole_Buttons";
                Parent = self.Items.Elements.Instance;
                BackgroundTransparency = 1;
                Size = UDim2.new(1, 0, 0, 18);
                BorderSizePixel = 0
            })

            Items.AccentChange = Library:Create( "TextButton", {Name="PlexRole_Buttons";
                Parent = Library.Other.Instance;
                BackgroundTransparency = 1;
                Size = UDim2.new(1, 0, 0, 18);
                BorderSizePixel = 0;
                BackgroundColor3 = Themes.Preset.Accent
            }):Themify("Accent", "BackgroundColor3")

            Items.Text = Library:Create( "TextLabel", {Name="PlexRole_Labels";
                FontFace = Themes.Preset.Font;
                TextColor3 = Themes.Preset["Unselected"];
                Text = Cfg.Text;
                Parent = Items.Object.Instance;
                AnchorPoint = Vector2.new(0, 0.5);
                AutomaticSize = Enum.AutomaticSize.XY;
                BackgroundTransparency = 1;
                Position = UDim2.new(0, -1, 0.5, 0);
                BorderSizePixel = 0;
                ZIndex = 2
            }):Themify("Unselected", "TextColor3"):Themify("TextColor", "TextColor3")

            Items.Holder = Library:Create( "Frame", {
                Parent = Items.Object.Instance;
                Position = UDim2.new(1, 0, 0, 0);
                Size = UDim2.new(0, 0, 1, 0);
                BorderSizePixel = 0
            })

            Library:Create( "UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal;
                HorizontalAlignment = Enum.HorizontalAlignment.Right;
                Parent = Items.Holder.Instance;
                Padding = UDim.new(0, 7);
                SortOrder = Enum.SortOrder.LayoutOrder
            })

            Items.Toggle = Library:Create( "Frame", {
                AnchorPoint = Vector2.new(1, 0);
                Parent = Items.Holder.Instance;
                Position = UDim2.new(1, 0, 0, 0);
                Size = UDim2.new(0, 34, 0, 16);
                BorderSizePixel = 0;
                BackgroundColor3 = Themes.Preset.Other
            }):Themify("Other", "BackgroundColor3"):Themify("Accent", "BackgroundColor3")

            Items.Stroke = Library:Create( "UIStroke", {
                Color = Themes.Preset["Inline"];
                Parent = Items.Toggle.Instance
            }):Themify("Inline", "Color"):Themify("Accent", "Color")

            Library:Create( "UICorner", {
                Parent = Items.Toggle.Instance;
                CornerRadius = UDim.new(1, 0)
            })

            Items.Gradient = Library:Create( "UIGradient", {
                Parent = Items.Toggle.Instance;
                Transparency = NumberSequence.new{
                    NumberSequenceKeypoint.new(0, 0.59375),
                    NumberSequenceKeypoint.new(1, 0)
                };
                Enabled = false;
            })

            Items.Circle = Library:Create( "Frame", {
                AnchorPoint = Vector2.new(0, 0.5);
                Parent = Items.Toggle.Instance;
                Position = UDim2.new(0, 2, 0.5, 0);
                Size = UDim2.new(0, 12, 0, 12);
                BorderSizePixel = 0;
                BackgroundColor3 = Color3.fromRGB(56, 56, 56)
            })

            Library:Create( "UICorner", {
                Parent = Items.Circle.Instance;
                CornerRadius = UDim.new(1, 0)
            })
        end

        Cfg.Set = function(bool)
            Items.Gradient.Instance.Enabled = bool
            Cfg.Enabled = bool

            if bool then
                Items.Circle:Tween({AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -2, 0.5, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255)})
                Items.Stroke:Tween({Color = Themes.Preset.Accent})
                Items.Toggle:Tween({BackgroundColor3 = Themes.Preset.Accent})
                Items.Text:Tween({TextColor3 = Themes.Preset.TextColor})
            else
                Items.Toggle:Tween({BackgroundColor3 = Themes.Preset.Inline})
                Items.Circle:Tween({AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 2, 0.5, 0), BackgroundColor3 = Color3.fromRGB(56, 56, 56)})
                Items.Stroke:Tween({Color = Themes.Preset.Inline})
                Items.Text:Tween({TextColor3 = Themes.Preset.Unselected})
            end

            Flags[Cfg.Flag] = bool
            Cfg.Callback(bool)
        end

        Items.Object:OnClick(function()
            Cfg.Enabled = not Cfg.Enabled
            Cfg.Set(Cfg.Enabled)
        end)

        Items.AccentChange.Instance:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
        -- print("hi")
            if Cfg.Enabled then
                Items.Stroke:Tween({Color = Themes.Preset.Accent})
                Items.Toggle:Tween({BackgroundColor3 = Themes.Preset.Accent})
            end
        end)

        ConfigFlags[Cfg.Flag] = Cfg.Set
        Cfg.Set(Cfg.Enabled)

        self.UpdateSection(Items.Object.Instance)

        return setmetatable(Cfg, Library)
    end

    Library.AddSlider = function(self, Data)
        Data = Data or {}

        local Cfg = {
            Text = Data.Text or "Text",
            Suffix = Data.Suffix or "",
            Flag = Data.Flag or Data.Name or "Slider",
            Callback = Data.Callback or function() end,

            Min = Data.Min or 0,
            Max = Data.Max or 100,
            Intervals = Data.Decimal or Data.Rounding or 1,
            Value = Data.Default or 10,

            Dragging = false,
            Items = {}
        }

        local Items = Cfg.Items; do
            Items.Object = Library:Create( "TextButton", {Name="PlexRole_Buttons";
                Parent = self.Items.Elements.Instance;
                BackgroundTransparency = 1;
                Size = UDim2.new(1, 0, 0, 33);
                BorderSizePixel = 0;
                AutomaticSize = Enum.AutomaticSize.Y;
            })

            Items.Title = Library:Create( "TextLabel", {Name="PlexRole_Labels";
                FontFace = Themes.Preset.Font;
                TextColor3 = Color3.fromRGB(252, 252, 252);
                Text = Cfg.Text;
                Parent = Items.Object.Instance;
                AutomaticSize = Enum.AutomaticSize.XY;
                BackgroundTransparency = 1;
                Position = UDim2.new(0, -1, 0, 0);
                BorderSizePixel = 0;
                ZIndex = 2
            })

            Items.Value = Library:Create( "TextBox", {Name="PlexRole_Values";
                FontFace = Themes.Preset.Font;
                TextColor3 = Color3.fromRGB(252, 252, 252);
                Text = "";
                ClearTextOnFocus = false;
                MultiLine = false;
                TextXAlignment = Enum.TextXAlignment.Right;
                Size = UDim2.new(0, 72, 0, 20);
                Parent = Items.Object.Instance;
                AnchorPoint = Vector2.new(1, 0);
                AutomaticSize = Enum.AutomaticSize.X;
                BackgroundTransparency = 1;
                Position = UDim2.new(1, 0, 0, 0);
                BorderSizePixel = 0;
                ZIndex = 2
            })

            Items.Accent = Library:Create( "Frame", {
                Parent = Items.Object.Instance;
                Size = UDim2.new(0.5, -2, 0, 5);
                Position = UDim2.new(0, 1, 0, 27);
                ZIndex = 2;
                BorderSizePixel = 0;
                BackgroundColor3 = Themes.Preset["Accent"]
            }):Themify("Accent", "BackgroundColor3")

            Library:Create( "UIGradient", {
                Parent = Items.Accent.Instance;
                Transparency = NumberSequence.new{
                NumberSequenceKeypoint.new(0, 0.824999988079071),
                NumberSequenceKeypoint.new(1, 0)
            }
            })

            Library:Create( "UIStroke", {
                Color = Themes.Preset["Accent"];
                Parent = Items.Accent.Instance
            }):Themify("Accent", "Color")

            Library:Create( "UICorner", {
                Parent = Items.Accent.Instance;
                CornerRadius = UDim.new(1, 0)
            })

            Items.Circle = Library:Create( "Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5);
                Parent = Items.Accent.Instance;
                Position = UDim2.new(1, 0, 0.5, 0);
                Size = UDim2.new(0, 7, 0, 7);
                ZIndex = 2;
                BorderSizePixel = 0;
                BackgroundColor3 = Color3.fromRGB(246, 245, 254)
            })

            Library:Create( "UIStroke", {
                Color = Themes.Preset["TextColor"];
                Parent = Items.Circle.Instance
            }):Themify("TextColor", "Color")

            Library:Create( "UICorner", {
                Parent = Items.Circle.Instance;
                CornerRadius = UDim.new(1, 8)
            })

            Items.SliderDragger = Library:Create( "Frame", {
                Parent = Items.Object.Instance;
                Position = UDim2.new(0, 0, 0, 26);
                Size = UDim2.new(1, 1, 0, 7);
                BorderSizePixel = 0;
                BackgroundColor3 = Themes.Preset["ElementBackground"]
            }):Themify("ElementBackground", "BackgroundColor3")

            Library:Create( "UICorner", {
                Parent = Items.SliderDragger.Instance;
                CornerRadius = UDim.new(1, 0)
            })
        end

        local function displayValue()
            Items.Value.Instance.Text=tostring(Cfg.Value)..Cfg.Suffix
        end
        Cfg.CancelNumberEdit=function()
            if not Cfg.Editing then return end
            Cfg.Editing=false
            if Library.PlexActiveNumberEdit==Cfg then Library.PlexActiveNumberEdit=nil end
            displayValue()
            Items.Value.Instance:ReleaseFocus(false)
        end
        Cfg.Set = function(Value)
            Value=tonumber(Value)
            if not Value or Value~=Value or math.abs(Value)==math.huge then return end
            Cfg.Value = math.clamp(Library:Round(Value, Cfg.Intervals), Cfg.Min, Cfg.Max)

            if not Cfg.Editing then displayValue() end
            Items.Accent:Tween({Size = UDim2.new((Cfg.Value - Cfg.Min) / (Cfg.Max - Cfg.Min), -2, 0, 5)}, TweenInfo.new(Library.DraggingSpeed, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0))

            Flags[Cfg.Flag] = Cfg.Value
            Cfg.Callback(Flags[Cfg.Flag])
        end

        Library:Connect(Items.Value.Instance.Focused,function()
            if Library.PlexActiveNumberEdit and Library.PlexActiveNumberEdit~=Cfg then
                Library.PlexActiveNumberEdit.CancelNumberEdit()
            end
            Cfg.Editing=true
            Library.PlexActiveNumberEdit=Cfg
            local box=Items.Value.Instance
            box.Text=tostring(Cfg.Value)
            box.CursorPosition=#box.Text+1
            box.SelectionStart=1
        end)
        Library:Connect(Items.Value.Instance.InputBegan,function(input)
            if input.KeyCode==Enum.KeyCode.Escape then Cfg.CancelNumberEdit() end
        end)
        Library:Connect(Items.Value.Instance.FocusLost,function()
            if not Cfg.Editing then return end
            Cfg.Editing=false
            if Library.PlexActiveNumberEdit==Cfg then Library.PlexActiveNumberEdit=nil end
            if Library.PlexUnloaded then displayValue();return end
            local text=Items.Value.Instance.Text:match("^%s*(.-)%s*$")
            if Cfg.Suffix~="" and text:sub(-#Cfg.Suffix)==Cfg.Suffix then
                text=text:sub(1,#text-#Cfg.Suffix)
            end
            local value=tonumber(text)
            if value and value==value and math.abs(value)<math.huge then Cfg.Set(value) end
            displayValue()
        end)

        Cfg.UpdateSlider = function(input)
            if Cfg.Editing then Cfg.CancelNumberEdit() end
            local Size = (input.Position.X - Items.SliderDragger.Instance.AbsolutePosition.X) / Items.SliderDragger.Instance.AbsoluteSize.X
            local Value = ((Cfg.Max - Cfg.Min) * Size) + Cfg.Min

            Cfg.Set(Value)
        end

        Cfg.Set(Cfg.Value);
        Items.SliderDragger:OnDrag(Cfg.UpdateSlider)
        self.UpdateSection(Items.Object.Instance)

        ConfigFlags[Cfg.Flag] = Cfg.Set
        return setmetatable(Cfg, Library)
    end

    Library.AddDropdown = function(self, Data)
        Data = Data or {}

        local Cfg = {
            Text = Data.Text or Data.Title or Data.Name or nil;
            Flag = Data.Flag or Data.Text or Data.Title or Data.Name or "Dropdown";
            Options = Data.Options or Data.Values or {""};
            Callback = Data.Callback or function() end;
            Multi = Data.Multi or false;

            -- Ignore these
            Open = false;
            OptionInstances = {};
            MultiItems = {};
            Items = {};
            Tweening = false;
        } Cfg.Default = Data.Default or Cfg.Options[1] or "";

        local Items = Cfg.Items; do
            do -- Outline
                Items.Dropdown = Library:Create( "Frame", {
                    Parent = self.Items.Elements.Instance;
                    BackgroundTransparency = 1;
                    Size = UDim2.new(1, 0, 0, 28);
                    AutomaticSize = Enum.AutomaticSize.None;
                    BorderSizePixel = 0
                })

                Items.Text = Library:Create( "TextLabel", {Name="PlexRole_Labels";
                    FontFace = Themes.Preset.Font;
                    TextColor3 = Themes.Preset.TextColor;
                    Text = Cfg.Text;
                    TextSize = 12;
                    Parent = Items.Dropdown.Instance;
                    AutomaticSize = Enum.AutomaticSize.None;
                    TextTruncate = Enum.TextTruncate.AtEnd;
                    TextXAlignment = Enum.TextXAlignment.Left;
                    Size = UDim2.new(1, -130, 1, 0);
                    BackgroundTransparency = 1;
                    Position = UDim2.new(0, 0, 0, 0);
                    BorderSizePixel = 0;
                    ZIndex = 2
                })

                Items.Outline = Library:Create( "Frame", {
                    Parent = Items.Dropdown.Instance;
                    AnchorPoint = Vector2.new(1, 0.5);
                    Position = UDim2.new(1, 0, 0.5, 0);
                    Size = UDim2.new(0, 118, 0, 22);
                    BorderSizePixel = 0;
                    BackgroundColor3 = Themes.Preset["ElementBackground"]
                }):Themify("ElementBackground", "BackgroundColor3")

                Items.OutlineStroke = Library:Create( "UIStroke", {
                    Color = Themes.Preset.ElementOutline;
                    Parent = Items.Outline.Instance
                }):Themify("ElementOutline", "Color")

                Library:Create( "UICorner", {
                    Parent = Items.Outline.Instance;
                    CornerRadius = UDim.new(0, 5)
                })

                Items.Rectangles = Library:Create( "ImageLabel", {
                    ImageColor3 = Themes.Preset.Unselected;
                    Parent = Items.Outline.Instance;
                    AnchorPoint = Vector2.new(1, 0.5);
                    Image = "rbxassetid://131251144676490";
                    BackgroundTransparency = 1;
                    Position = UDim2.new(1, -8, 0.5, 0);
                    Size = UDim2.new(0, 12, 0, 12);
                    BorderSizePixel = 0
                }):Themify("Unselected", "ImageColor3")

                Items.Value = Library:Create( "TextLabel", {Name="PlexRole_Values";
                    FontFace = Themes.Preset.Font;
                    TextColor3 = Themes.Preset.TextColor;
                    Text = "Dropdown";
                    TextSize = 12;
                    Parent = Items.Outline.Instance;
                    AnchorPoint = Vector2.new(0, 0.5);
                    AutomaticSize = Enum.AutomaticSize.None;
                    Size = UDim2.new(1, -30, 1, 0);
                    TextTruncate = Enum.TextTruncate.AtEnd;
                    TextXAlignment = Enum.TextXAlignment.Left;
                    BackgroundTransparency = 1;
                    Position = UDim2.new(0, 9, 0.5, 0);
                    BorderSizePixel = 0;
                    ZIndex = 2
                })
            end

            do -- Menu
                Items.DropdownHolder = Library:Create( "TextButton", {Name="PlexRole_Buttons";
                    Text = "";
                    AutoButtonColor = false;
                    Size = UDim2.new(0, 180, 0, 0);
                    Position = UDim2.new(0.05539358779788017, 0, 0.5614250898361206, 0);
                    BorderSizePixel = 0;
                    Visible = false;
                    Parent = Library.Other.Instance;
                    AutomaticSize = Enum.AutomaticSize.Y;
                    BackgroundColor3 = Themes.Preset["SectionBackground"]
                }):Themify("SectionBackground", "BackgroundColor3")

                Library:Create( "UIStroke", {
                    Color = Themes.Preset.ElementOutline;
                    Parent = Items.DropdownHolder.Instance
                }):Themify("ElementOutline", "Color")

                Library:Create( "UICorner", {
                    Parent = Items.DropdownHolder.Instance;
                    CornerRadius = UDim.new(0, 8)
                })

                Library:Create( "UIPadding", {
                    PaddingTop = UDim.new(0, 4);
                    PaddingBottom = UDim.new(0, 4);
                    Parent = Items.DropdownHolder.Instance;
                    PaddingRight = UDim.new(0, 4);
                    PaddingLeft = UDim.new(0, 4)
                })

                Library:Create( "UIListLayout", {
                    Parent = Items.DropdownHolder.Instance;
                    Padding = UDim.new(0, 0);
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
            end
        end

        Cfg.RenderOption = function(text)
            local DropdownItems = {}

            DropdownItems.Button = Library:Create( "Frame", {
                Parent = Items.DropdownHolder.Instance;
                BackgroundTransparency = 1;
                Size = UDim2.new(1, 0, 0, 0);
                BorderSizePixel = 0;
                AutomaticSize = Enum.AutomaticSize.XY;
                BackgroundColor3 = Themes.Preset["Inline"]
            }):Themify("Inline", "BackgroundColor3")

            Library:Create( "UICorner", {
                Parent = DropdownItems.Button.Instance;
                CornerRadius = UDim.new(0, 5)
            })

            DropdownItems.Text = Library:Create( "TextLabel", {Name="PlexRole_Labels";
                FontFace = Themes.Preset.Font;
                Parent = DropdownItems.Button.Instance;
                TextColor3 = Themes.Preset["Unselected"];
                Text = text;
                TextSize = 12;
                AutomaticSize = Enum.AutomaticSize.None;
                TextTruncate = Enum.TextTruncate.AtEnd;
                TextXAlignment = Enum.TextXAlignment.Left;
                AnchorPoint = Vector2.new(0, 0.5);
                Size = UDim2.new(1, -30, 1, 0);
                BackgroundTransparency = 1;
                Position = UDim2.new(0, 8, 0.5, -1);
                BorderSizePixel = 0;
                ZIndex = 2;
            }):Themify("Unselected", "TextColor3"):Themify("TextColor", "TextColor3")

            DropdownItems.Stroke = Library:Create( "UIStroke", {
                Color = Themes.Preset["Accent"];
                Transparency = 1;
                Parent = DropdownItems.Button.Instance
            }):Themify("Accent", "Color")

            DropdownItems.Check = Library:Create("Frame", {BackgroundTransparency=1,
                Size=UDim2.fromOffset(14,14),AnchorPoint=Vector2.new(1,0.5),
                Position=UDim2.new(1,-6,0.5,0),Visible=false,Parent=DropdownItems.Button.Instance})
            for _, segment in ipairs({{2,7,5,2,45},{5,6,8,2,-45}}) do
                Library:Create("Frame", {BackgroundColor3=Themes.Preset.Accent,BorderSizePixel=0,
                    Size=UDim2.fromOffset(segment[3],segment[4]),Position=UDim2.fromOffset(segment[1],segment[2]),
                    Rotation=segment[5],Parent=DropdownItems.Check.Instance}):Themify("Accent","BackgroundColor3")
            end
            Library:Connect(DropdownItems.Button.Instance.MouseEnter,function()
                DropdownItems.Hovered=true
                DropdownItems.Button.Instance.BackgroundTransparency=0
                if not DropdownItems.Selected then DropdownItems.Text.Instance.TextColor3=Themes.Preset.TextColor end
            end)
            Library:Connect(DropdownItems.Button.Instance.MouseLeave,function()
                DropdownItems.Hovered=false
                DropdownItems.Button.Instance.BackgroundTransparency=1
                DropdownItems.Text.Instance.TextColor3=DropdownItems.Selected and Themes.Preset.Accent or Themes.Preset.Unselected
            end)
            table.insert(Cfg.OptionInstances, DropdownItems)

            return DropdownItems
        end

        Cfg.Page=1
        Cfg.PageSize=10
        Cfg.Query=""
        Cfg.Lookup={}
        local function paintOption(row)
            local selected=Cfg.Multi and table.find(Cfg.MultiItems,row.ItemName)~=nil or (not Cfg.Multi and Cfg.Value==row.ItemName)
            row.Selected=selected
            row.Text.Instance.TextColor3=selected and Themes.Preset.Accent or (row.Hovered and Themes.Preset.TextColor or Themes.Preset.Unselected)
            row.Button.Instance.BackgroundTransparency=row.Hovered and 0 or 1
            row.Stroke.Instance.Transparency=1
            row.Check.Instance.Visible=selected
        end
        Cfg.Set=function(value)
            local selected={}
            if Cfg.Multi then
                for _,item in ipairs(type(value)=="table" and value or {}) do
                    if Cfg.Lookup[item] and not table.find(selected,item) then selected[#selected+1]=item end
                end
                Cfg.MultiItems=selected;Cfg.Value=table.clone(selected)
                Flags[Cfg.Flag]=table.clone(selected)
                Items.Value.Instance.Text=table.concat(selected,", ")
            else
                Cfg.Value=Cfg.Lookup[value] and value or nil
                Flags[Cfg.Flag]=Cfg.Value
                Items.Value.Instance.Text=tostring(Cfg.Value or "")
            end
            for _,row in ipairs(Cfg.OptionInstances) do paintOption(row) end
            Cfg.Callback(Flags[Cfg.Flag])
        end
        Cfg.RenderPage=function()
            if not Cfg.Open then return end
            if not Items.Search then
                Items.Search=Library:Create("TextBox",{Name="PlexRole_Values"; Text="",PlaceholderText="Search options...",ClearTextOnFocus=false,
                    FontFace=Themes.Preset.Font,TextSize=13,TextColor3=Themes.Preset.TextColor,
                    BackgroundColor3=Themes.Preset.Inline,BorderSizePixel=0,Size=UDim2.new(1,0,0,26),
                    LayoutOrder=-2,Parent=Items.DropdownHolder.Instance})
                Items.Pager=Library:Create("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,24),
                    LayoutOrder=100,Parent=Items.DropdownHolder.Instance})
                local function nav(text,x,callback)
                    local button=Library:Create("TextButton",{Name="PlexRole_Buttons"; BackgroundColor3=Themes.Preset.Inline,TextColor3=Themes.Preset.TextColor,
                        FontFace=Themes.Preset.Font,TextSize=13,BorderSizePixel=0,Size=UDim2.new(0.5,-2,1,0),
                        Position=UDim2.new(x,x==0 and 0 or 2,0,0),Parent=Items.Pager.Instance})
                    button.Instance.Text=text;button:OnClick(callback)
                end
                nav("Previous",0,function()Cfg.Page=math.max(1,Cfg.Page-1);Cfg.RenderPage()end)
                nav("Next",0.5,function()Cfg.Page=math.min(Cfg.Pages or 1,Cfg.Page+1);Cfg.RenderPage()end)
                local token=0
                Library:Connect(Items.Search.Instance:GetPropertyChangedSignal("Text"),function()
                    token+=1;local current=token
                    task.defer(function()
                        if current~=token or Library.PlexUnloaded then return end
                        Cfg.Query=Items.Search.Instance.Text:lower();Cfg.Page=1;Cfg.RenderPage()
                    end)
                end)
            end
            local matches={}
            for _,item in ipairs(Cfg.Options) do
                if Cfg.Query=="" or tostring(item):lower():find(Cfg.Query,1,true) then matches[#matches+1]=item end
            end
            Cfg.Pages=math.max(1,math.ceil(#matches/Cfg.PageSize));Cfg.Page=math.clamp(Cfg.Page,1,Cfg.Pages)
            Items.Search.Instance.Visible=#Cfg.Options>Cfg.PageSize
            Items.Pager.Instance.Visible=#matches>Cfg.PageSize
            Items.Search.Instance.PlaceholderText="Search "..tostring(#Cfg.Options).." options · "..Cfg.Page.." / "..Cfg.Pages
            for index=1,Cfg.PageSize do
                local item=matches[(Cfg.Page-1)*Cfg.PageSize+index]
                local row=Cfg.OptionInstances[index]
                if item~=nil and not row then
                    row=Cfg.RenderOption(tostring(item))
                    row.Button.Instance.Size=UDim2.new(1,0,0,24)
                    row.Button.Instance.AutomaticSize=Enum.AutomaticSize.None
                    row.Button:OnClick(function()
                        if Cfg.Multi then
                            local selected=table.clone(Cfg.MultiItems)
                            local at=table.find(selected,row.ItemName)
                            if at then table.remove(selected,at) else selected[#selected+1]=row.ItemName end
                            Cfg.Set(selected)
                        else Cfg.Set(row.ItemName);Cfg.SetVisible() end
                    end)
                end
                if row then
                    row.ItemName=item;row.Button.Instance.Visible=item~=nil
                    row.Button.Instance.LayoutOrder=index
                    row.Text.Instance.Text=tostring(item or "")
                    paintOption(row)
                end
            end
        end
        Cfg.RefreshOptions=function(options)
            Cfg.Options=table.clone(options or {})
            Cfg.Lookup={}
            for _,item in ipairs(Cfg.Options) do Cfg.Lookup[item]=true end
            Cfg.Page=1
            if Cfg.Open then Cfg.RenderPage() end
        end
        Cfg.SetVisible=function(open)
            local showing=open==nil and not Cfg.Open or open==true
            if showing==Cfg.Open then return end
            Cfg.Open=showing
            Cfg.PlexPopupAnchor=Items.Outline.Instance
            Library.PlexOpenPopups[Items.DropdownHolder.Instance]=Cfg
            local targetPosition
            if Cfg.Open then
                Cfg.RenderPage()
                local size=Items.Outline.Instance.AbsoluteSize
                local position=Items.Outline.Instance.AbsolutePosition
                local viewport=workspace.CurrentCamera.ViewportSize
                local width=math.max(180,size.X)
                local height=math.min(#Cfg.Options,Cfg.PageSize)*24+8+(#Cfg.Options>Cfg.PageSize and 50 or 0)
                local y=position.Y+size.Y+5
                if y+height>viewport.Y-8 then y=math.max(8,position.Y-height-5) end
                Items.DropdownHolder.Instance.Size=UDim2.fromOffset(width,0)
                targetPosition=UDim2.fromOffset(math.clamp(position.X+size.X-width,8,math.max(8,viewport.X-width-8)),y)
            end
            Library:AnimateVisibility(Items.DropdownHolder.Instance,Cfg.Open,function()
                if not Cfg.Open then Library.PlexOpenPopups[Items.DropdownHolder.Instance]=nil end
            end,targetPosition)
        end

        Library:Connect(Items.Outline.Instance.MouseEnter,function()
            Items.Outline.Instance.BackgroundColor3=Themes.Preset.Inline
        end)
        Library:Connect(Items.Outline.Instance.MouseLeave,function()
            Items.Outline.Instance.BackgroundColor3=Themes.Preset.ElementBackground
        end)
        Items.Outline:OnClick(Cfg.SetVisible)
        Items.DropdownHolder:Reparent(Library.Elements.Instance)
        Items.DropdownHolder:OutsideClick(Cfg)

        Cfg.RefreshOptions(Cfg.Options)
        Cfg.Set(Cfg.Default)

        self.UpdateSection(Items.Dropdown.Instance)

        return setmetatable(Cfg, Library)
    end

    Library.AddKeyPicker = function(self, Data)
        Data = Data or {}

        local Cfg = {
            Text = Data.Text or Data.Name or Data.Title or "Keybind";
            Flag = Data.Flag or Data.Text or Data.Name or Data.Title or "Flag";
            Callback = Data.Callback or function() end;
            ShowInList = Data.ShowInList or true;

            Key = Data.Key or Data.Default or nil;
            Mode = Data.Mode or "Toggle";
            Active = Data.Active or false;

            Open = false;
            Tweening = false;
            Binding;

            Items = {};
            Debounce = false;
        }

        Flags[Cfg.Flag] = {
            Mode = Cfg.Mode,
            Key = Cfg.Key,
            Active = Cfg.Active,
            active = Cfg.Active;
        }

        local Items = Cfg.Items; do
            Items.Object = Library:Create( "Frame", {
                Parent = self.Items.Elements.Instance;
                BackgroundTransparency = 1;
                Size = UDim2.new(1, 0, 0, 16);
                BorderSizePixel = 0
            })

            Items.Title = Library:Create( "TextLabel", {Name="PlexRole_Labels";
                FontFace = Themes.Preset.Font;
                TextColor3 = Color3.fromRGB(252, 252, 252);
                Text = Cfg.Text;
                Parent = Items.Object.Instance;
                AnchorPoint = Vector2.new(0, 0.5);
                AutomaticSize = Enum.AutomaticSize.XY;
                BackgroundTransparency = 1;
                Position = UDim2.new(0, -1, 0.5, 0);
                BorderSizePixel = 0;
                ZIndex = 2
            })

            Items.Holder = Library:Create( "Frame", {
                Parent = Items.Object.Instance;
                Position = UDim2.new(1, 0, 0, 0);
                Size = UDim2.new(0, 0, 1, 0);
                BorderSizePixel = 0
            })

            Library:Create( "UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal;
                HorizontalAlignment = Enum.HorizontalAlignment.Right;
                Parent = Items.Holder.Instance;
                Padding = UDim.new(0, 13);
                SortOrder = Enum.SortOrder.LayoutOrder
            })

            Items.Holder2 = Library:Create( "TextButton", {Name="PlexRole_Buttons";
                Text = "";
                AutoButtonColor = false;
                Active = true;
                AnchorPoint = Vector2.new(1, 0);
                Parent = Items.Holder.Instance;
                Position = UDim2.new(1, 0, 0, 0);
                Size = UDim2.new(0, 34, 0, 16);
                BorderSizePixel = 0;
                AutomaticSize = Enum.AutomaticSize.X;
                BackgroundColor3 = Themes.Preset.Other
            }):Themify("Other", "BackgroundColor3")

            Library:Create( "UIStroke", {
                Color = Themes.Preset["Inline"];
                Parent = Items.Holder2.Instance
            }):Themify("Inline", "Color")

            Library:Create( "UIPadding", {
                Parent = Items.Holder2.Instance;
                PaddingRight = UDim.new(0, 8);
                PaddingLeft = UDim.new(0, 8)
            })

            Library:Create( "UICorner", {
                Parent = Items.Holder2.Instance;
                CornerRadius = UDim.new(0, 5)
            })

            Items.Value = Library:Create( "TextLabel", {Name="PlexRole_Values";
                FontFace = Themes.Preset.Font;
                TextColor3 = Color3.fromRGB(252, 252, 252);
                Text = "RightShift";
                Parent = Items.Holder2.Instance;
                AnchorPoint = Vector2.new(0, 0.5);
                AutomaticSize = Enum.AutomaticSize.XY;
                BackgroundTransparency = 1;
                Position = UDim2.new(0, -1, 0.5, 0);
                BorderSizePixel = 0;
                ZIndex = 2
            })

            do -- Keybind holder
                local Section = Library:AddSection({Text = "Settings"})
                Items.Dropdown = Section:AddDropdown({Text = "Mode", Flag = Cfg.Flag.."_MODE", Options = {"Toggle", "Hold", "Always"}, Callback = function(Option)
                    if Cfg.Debounce then
                        return
                    end

                    if Cfg.Set then
                        Cfg.Set(Option)
                    end
                end})

                Items.KeyName=Section:AddInput({Text="Key name",Flag=Cfg.Flag.."_KEYNAME",Default="",
                    PlaceHolder="F, RightShift, M2...",Callback=function(text)
                        if Cfg.SetTypedKey then Cfg.SetTypedKey(text) end
                    end})
                Items.KeyName.Items.Textbox.Instance.Active=true
                Items.KeyName.Items.Textbox.Instance.Selectable=true
                Items.KeyName.Items.Textbox.Instance.TextEditable=true
                Items.KeyName.Items.Textbox.Instance.MultiLine=false
                Library:Connect(Items.KeyName.Items.Textbox.Instance.Focused,function()
                    if Library.PlexActiveKeyCapture then Library.PlexActiveKeyCapture.CancelCapture() end
                end)
                Section:AddButton({Text="Set key / mouse button",Callback=function() if Cfg.NewKey then Cfg.NewKey() end end})
                Section:AddButton({Text="Clear binding",Callback=function()
                    if Cfg.CancelCapture then Cfg.CancelCapture() end
                    if Cfg.Set then Cfg.Set({Key="NONE",Mode=Cfg.Mode,Active=Cfg.Active}) end
                end})
                Items.Section = Section.Items.Section
                Items.Section.Instance.Parent = Library.Items.Instance
                Items.Section.Instance.Visible = false

                Items.Section:Reparent(Library.Elements.Instance)
            end
        end

        local KeybindListElement = Library:AddHotKey({Key = Cfg.Key or "NONE", Name = Cfg.Text})

        Cfg.SetMode = function(Mode)
            Cfg.Mode = Mode

            if Mode == "Always" then
                Cfg.Set(true)
            elseif Mode == "Hold" then
                Cfg.Set(false)
            end

            Flags[Cfg.Flag].Mode = Mode
        end

        Cfg.Set = function(input)
            if type(input) == "boolean" then
                Cfg.Active = input

                if Cfg.Mode == "Always" then
                    Cfg.Active = true
                end
            elseif typeof(input)=="EnumItem" then
                Cfg.Key = input
            elseif table.find({"Toggle", "Hold", "Always"}, input) then
                if input == "Always" then
                    Cfg.Active = true
                end

                Cfg.Mode = input
                Cfg.SetMode(Cfg.Mode)
            elseif type(input) == "table" then
                input.Key = type(input.Key) == "string" and input.Key ~= "NONE" and Library:ConvertEnum(input.Key) or input.Key

                Cfg.Key = input.Key or "NONE"

                if input.Active then
                    Cfg.Active = input.Active
                end

                Cfg.SetMode(input.Mode)
            end

            Cfg.Callback(Cfg.Active)

            local text = (tostring(Cfg.Key) ~= "Enums" and (Keys[Cfg.Key] or tostring(Cfg.Key):gsub("Enum.", "")) or nil)
            local __text = text and tostring(text):gsub("KeyCode.", ""):gsub("UserInputType.", "") or ""

            Items.Value.Instance.Text = string.format("Key: %s", __text)
            if Items.KeyName and not Items.KeyName.Focused then
                Items.KeyName.Items.Textbox.Instance.Text=__text
            end

            Cfg.Debounce = true
            Items.Dropdown.Set(Cfg.Mode)
            Cfg.Debounce = false


            KeybindListElement:ChangeKey(__text or "NONE")
            KeybindListElement:SetEnabled(Cfg.Active)

            Flags[Cfg.Flag] = {
                Mode = Cfg.Mode,
                Key = Cfg.Key,
                Active = Cfg.Active;
                active = Cfg.Active;
            }
        end

        Cfg.SetTypedKey=function(text)
            local value=Library:ConvertEnum(text)
            local box=Items.KeyName.Items.Textbox.Instance
            if value==nil then
                box.TextColor3=Color3.fromRGB(239,101,115)
                return false
            end
            box.TextColor3=Themes.Preset.TextColor
            Cfg.CancelCapture()
            Cfg.Set({Key=value,Mode=Cfg.Mode,Active=Cfg.Active})
            return true
        end
        Cfg.CancelCapture=function()
            if Cfg.Binding then Cfg.Binding.Connection:Disconnect();Cfg.Binding=nil end
            if Cfg.PreviousCaption then Items.Value.Instance.Text=Cfg.PreviousCaption;Cfg.PreviousCaption=nil end
            if Library.PlexActiveKeyCapture==Cfg then
                Library.PlexActiveKeyCapture=nil
                if Library.PlexCaptureChanged then Library.PlexCaptureChanged(false) end
            end
        end
        Cfg.NewKey = function()
            if Library.PlexUnloaded then return end
            if Library.PlexActiveKeyCapture then Library.PlexActiveKeyCapture.CancelCapture() end
            Cfg.PreviousCaption=Items.Value.Instance.Text
            Items.Value.Instance.Text="Press key or mouse..."
            Library.PlexActiveKeyCapture=Cfg
            if Library.PlexCaptureChanged then Library.PlexCaptureChanged(true,Cfg.CancelCapture) end
            task.defer(function()
                if Library.PlexActiveKeyCapture~=Cfg or Library.PlexUnloaded then return end
                Cfg.Binding=Library:Connect(Services.UserInputService.InputBegan,function(input)
                    local kind=input.UserInputType
                    if Services.UserInputService:GetFocusedTextBox() then return end
                    local value
                    if input.KeyCode and input.KeyCode~=Enum.KeyCode.Unknown then value=input.KeyCode
                    elseif kind==Enum.UserInputType.MouseButton1 or kind==Enum.UserInputType.MouseButton2 or kind==Enum.UserInputType.MouseButton3 then value=kind end
                    if not value then return end
                    Cfg.CancelCapture()
                    Cfg.Set(value)
                end)
            end)
        end

        Cfg.SetVisible = function(bool)
            local showing=bool==true
            if showing==Cfg.Open then return end
            Cfg.Open=showing
            Cfg.PlexPopupAnchor=Items.Holder2.Instance
            Library.PlexOpenPopups[Items.Section.Instance]=Cfg
            local position
            if Cfg.Open then
                local anchor=Items.Holder2.Instance
                position=UDim2.fromOffset(anchor.AbsolutePosition.X,anchor.AbsolutePosition.Y+anchor.AbsoluteSize.Y+6)
            end
            Library:AnimateVisibility(Items.Section.Instance,Cfg.Open,function()
                if not Cfg.Open then Library.PlexOpenPopups[Items.Section.Instance]=nil end
            end,position)
        end

        local captureClick=false
        Library:Connect(Items.Holder2.Instance.InputBegan,function(input)
            if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
                captureClick=Library.PlexActiveKeyCapture~=nil
            end
        end)
        Library:Connect(Items.Holder2.Instance.Activated,function()
            if not captureClick then Cfg.NewKey() end
            captureClick=false
        end)

        Items.Dropdown.Items.DropdownHolder:OnClick(function()
            task.spawn(function()
                Cfg.Tweening = true
                task.wait()
                Cfg.Tweening = false
            end)
        end)

        Items.Section:OutsideClick(Cfg)

        Library:Connect(Items.Holder2.Instance.InputBegan, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton2 then
                Cfg.SetVisible(not Cfg.Open)
            end
        end)

        Cfg.Set({Mode = Cfg.Mode, Active = Cfg.Active, Key = Cfg.Key})
        ConfigFlags[Cfg.Flag] = Cfg.Set

        self.UpdateSection(Items.Object.Instance)

        return setmetatable(Cfg, Library)
    end

    Library.AddColorPicker = function(self, Data)
        Data = Data or {}

        local Cfg = {
            Text = Data.Text or Data.Name or "Color",
            Flag = Data.Flag or Data.Name or self.Name or "Colorpicker",
            Callback = Data.Callback or function() end,

            Color = Data.Color or Data.Default or Color3.new(1, 1, 1),  -- Default to white color if not provided
            Alpha = Data.Alpha or Data.Transparency or 1,

            -- Other
            Open = false;
            Items = {};
        }

        local Picker = self:Keypicker(Cfg)

        local Items = Picker.Items; do
            Cfg.Items = Items
            Cfg.Set = Picker.Set
        end;

        Cfg.Set(Cfg.Color, Cfg.Alpha)
        ConfigFlags[Cfg.Flag] = Cfg.Set

        return setmetatable(Cfg, Library)
    end

    Library.AddButton = function(self, Data)
        Data = Data or {}

        local Cfg = {
            Text = Data.Text or "Button";
            Callback = Data.Callback or function() end;

            Items = {}
        }

        local Items = Cfg.Items; do
            Items.ButtonHolder = self.Items and self.Items.ButtonHolder

            if not Items.ButtonHolder then
                Items.ButtonHolder = Library:Create( "Frame", {
                    Parent = self.Items.Elements.Instance;
                    BackgroundTransparency = 1;
                    Size = UDim2.new(1, 0, 0, 30);
                    BorderSizePixel = 0
                })

                Library:Create( "UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal;
                    HorizontalFlex = Enum.UIFlexAlignment.Fill;
                    Parent = Items.ButtonHolder.Instance;
                    Padding = UDim.new(0, 13);
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
            end

            Items.Outline = Library:Create( "TextButton", {Name="PlexRole_Buttons";
                Parent = Items.ButtonHolder.Instance;
                Position = UDim2.new(0, 1, 0, 0);
                Size = UDim2.new(1, -1, 0, 30);
                BorderSizePixel = 0;
                BackgroundColor3 = Themes.Preset["ElementBackground"]
            }):Themify("ElementBackground", "BackgroundColor3")

            Library:Create( "UIStroke", {
                Color = Themes.Preset.ElementOutline;
                Thickness = 1.25;
                Parent = Items.Outline.Instance
            }):Themify("ElementOutline", "Color")

            Library:Create( "UICorner", {
                Parent = Items.Outline.Instance;
                CornerRadius = UDim.new(0, 5)
            })

            Library:Create( "TextLabel", {
                FontFace = Themes.Preset.Font;
                TextColor3 = Color3.fromRGB(252, 252, 252);
                Text = Cfg.Text;
                Parent = Items.Outline.Instance;
                AutomaticSize = Enum.AutomaticSize.XY;
                BackgroundTransparency = 1;
                Size = UDim2.new(1, 0, 1, 0);
                BorderSizePixel = 0;
                Position = UDim2.new(0, 0, 0, -1);
                ZIndex = 2;
                BackgroundColor3 = Themes.Preset["Accent"]
            }):Themify("Accent", "BackgroundColor3")

            Items.Accent = Library:Create( "Frame", {
                Parent = Items.Outline.Instance;
                BackgroundTransparency = 1;
                Size = UDim2.new(1, 0, 1, 0);
                BorderSizePixel = 0;
                BackgroundColor3 = Themes.Preset["Accent"]
            }):Themify("Accent", "BackgroundColor3")

            Items.Stroke = Library:Create( "UIStroke", {
                Color = Themes.Preset["Accent"];
                Transparency = 1;
                Parent = Items.Accent.Instance
            }):Themify("Accent", "Color")

            Library:Create( "UIGradient", {
                Parent = Items.Accent.Instance;
                Transparency = NumberSequence.new{
                NumberSequenceKeypoint.new(0, 0.59375),
                NumberSequenceKeypoint.new(1, 0)
            }
            })

            Library:Create( "UICorner", {
                Parent = Items.Accent.Instance;
                CornerRadius = UDim.new(0, 5)
            })
        end

        Cfg.Press = function()
            Items.Accent.Instance.BackgroundTransparency = 0
            Items.Accent:Tween({BackgroundTransparency = 1})

            Items.Stroke.Instance.Transparency = 0
            Items.Stroke:Tween({Transparency = 1})

            Cfg.Callback()
        end

        Items.Outline:OnClick(Cfg.Press)

        if self.UpdateSection then
            self.UpdateSection(Items.ButtonHolder.Instance)
        end

        return setmetatable(Cfg, Library)
    end

    Library.AddLabel = function(self, Data)
        local Cfg = {
            Text = Data.Text or Data.Title or Data.Name or "Label";
            Items = {};
        }

        local Items = Cfg.Items; do
            Items.Object = Library:Create( "TextButton", {Name="PlexRole_Buttons";
                Parent = self.Items.Elements.Instance;
                BackgroundTransparency = 1;
                Size = UDim2.new(1, 0, 0, 18);
                BorderSizePixel = 0
            })

            Items.Text = Library:Create( "TextLabel", {Name="PlexRole_Descriptions";
                FontFace = Themes.Preset.Font;
                TextColor3 = Themes.Preset["TextColor"];
                Text = Cfg.Text;
                Parent = Items.Object.Instance;
                AnchorPoint = Vector2.new(0, 0.5);
                AutomaticSize = Enum.AutomaticSize.XY;
                BackgroundTransparency = 1;
                Position = UDim2.new(0, -1, 0.5, 0);
                BorderSizePixel = 0;
                ZIndex = 2
            }):Themify("TextColor", "TextColor3")

            Cfg.ChangeText = function(Text)
                Items.Text.Instance.Text = Text
            end
        end

        self.UpdateSection(Items.Object.Instance)

        return setmetatable(Cfg, Library)
    end

    Library.AddList = function(self, Data)
        Data = Data or {}

        local Cfg = {
            Flag = Data.Flag or Data.Name or "";
            Options = Data.Options or {"CONTACT FOR BUG"};
            Callback = Data.Callback or function() end;
            Multi = Data.Multi or false;

            Size = Data.Size or 100;

            Items = {};
            OptionInstances = {};
            MultiItems = {};
        }

        local Items = Cfg.Items; do
            Items.List = Library:Create( "Frame", {
                Parent = self.Items.Elements.Instance;
                BackgroundTransparency = 1;
                Size = UDim2.new(1, 0, 0, Cfg.Size);
                BorderSizePixel = 0;
            });

            Items.Outline = Library:Create( "Frame", {
                Parent = Items.List.Instance;
                Size = UDim2.new(1, 0, 1, 0);
                BorderSizePixel = 0;
                BackgroundColor3 = Themes.Preset["Inlines"]
            }):Themify("Inlines", "BackgroundColor3")

            Library:Create( "UICorner", {
                Parent = Items.Outline.Instance;
                CornerRadius = UDim.new(0, 5)
            })

            Items.Inline = Library:Create( "Frame", {
                Parent = Items.Outline.Instance;
                Position = UDim2.new(0, 1, 0, 1);
                Size = UDim2.new(1, -2, 1, -2);
                BorderSizePixel = 0;
                BackgroundColor3 = Themes.Preset.ElementBackground
            }):Themify("ElementBackground", "BackgroundColor3")

            Items.ScrollingFrame = Library:Create( "ScrollingFrame", {
                Active = true;
                AutomaticCanvasSize = Enum.AutomaticSize.Y;
                BorderSizePixel = 0;
                CanvasSize = UDim2.new(0, 0, 0, 0);
                ScrollingEnabled = true;
                ScrollBarImageColor3 = Color3.fromRGB(207, 155, 166);
                MidImage = "rbxassetid://102257413888451";
                ScrollBarThickness = 2;
                Parent = Items.Inline.Instance;
                Size = UDim2.new(1, -5, 1, -10);
                BackgroundTransparency = 1;
                Position = UDim2.new(0, 0, 0, 5);
                BottomImage = "rbxassetid://102257413888451";
                TopImage = "rbxassetid://102257413888451"
            })

            Library:Create( "UIPadding", {
                PaddingBottom = UDim.new(0, -4);
                PaddingTop = UDim.new(0, -4);
                Parent = Items.ScrollingFrame.Instance;
            })

            Library:Create( "UIListLayout", {
                Parent = Items.ScrollingFrame.Instance;
                SortOrder = Enum.SortOrder.LayoutOrder;
                Padding = UDim.new(0, -7);
            })

            Library:Create( "UICorner", {
                Parent = Items.ScrollingFrame.Instance;
                CornerRadius = UDim.new(0, 3)
            })

            Library:Create( "UICorner", {
                Parent = Items.Inline.Instance;
                CornerRadius = UDim.new(0, 3)
            })
        end

        Cfg.Set = function(value)
            local Selected = {}
            local IsTable = type(value) == "table"

            for _,option in Cfg.OptionInstances do
                if option.Instance.Text == value or (IsTable and table.find(value, option.Instance.Text)) then
                    table.insert(Selected, option.Instance.Text)
                    Cfg.MultiItems = Selected
                    option:Tween({TextColor3 = Themes.Preset.Accent})
                    option.Instance.FontFace = Fonts.Bold
                    option.Instance.TextSize = 13
                else
                    option:Tween({TextColor3 = Themes.Preset.UnselectedElement})
                    option.Instance.FontFace = Fonts.Elements
                    option.Instance.TextSize = 13
                end
            end

            if IsTable then
                Flags[Cfg.Flag]=Selected
            else
                Flags[Cfg.Flag]=Selected[1]
            end

            Cfg.Callback(Flags[Cfg.Flag])
        end

        Cfg.RenderOption = function(name)
            local Button = Library:Create( "TextButton", {Name="PlexRole_Buttons";
                FontFace = Themes.Preset.Font;
                TextColor3 = Themes.Preset["Element Text"];
                Text = name;
                Parent = Items.ScrollingFrame.Instance;
                Size = UDim2.new(1, 0, 0, 0);
                Position = UDim2.new(0, 0, 0, -1);
                BackgroundTransparency = 1;
                TextXAlignment = Enum.TextXAlignment.Left;
                BorderSizePixel = 0;
                AutomaticSize = Enum.AutomaticSize.XY
            }):Themify("Accent", "TextColor3"):Themify("Element Text", "TextColor3")
            Button.Instance.Text = name

            Library:Create( "UIPadding", {
                PaddingBottom = UDim.new(0, 6);
                PaddingTop = UDim.new(0, 6);
                PaddingLeft = UDim.new(0, 6);
                Parent = Button.Instance
            })

            Button:OnHover(
                function()
                    if Flags[Cfg.Flag] == Button.Instance.Text or (type(Flags[Cfg.Flag]) == "table" and table.find(Flags[Cfg.Flag], Button.Instance.Text)) then
                        return
                    end

                    Button:Tween({TextColor3 = Themes.Preset.SelectedMultiTabText})
                end,
                function()
                    if Flags[Cfg.Flag] == Button.Instance.Text or (type(Flags[Cfg.Flag]) == "table" and table.find(Flags[Cfg.Flag], Button.Instance.Text)) then
                        return
                    end

                    Button:Tween({TextColor3 = Themes.Preset.UnselectedElement})
                end
            )

            table.insert(Cfg.OptionInstances, Button)

            return Button
        end

        Cfg.RefreshOptions = function(options)
            for _,option in Cfg.OptionInstances do
                option.Instance:Destroy()
            end

            Cfg.OptionInstances = {}

            for _,option in options do
                local Button = Cfg.RenderOption(option)

                Button:OnClick(function()
                    if Cfg.Multi then
                        local Selected = table.find(Cfg.MultiItems, Button.Instance.Text)

                        if Selected then
                            table.remove(Cfg.MultiItems, Selected)
                        else
                            table.insert(Cfg.MultiItems, Button.Instance.Text)
                        end

                        Cfg.Set(Cfg.MultiItems)
                    else
                        Cfg.Set(Button.Instance.Text)
                    end
                end)
            end
        end

        Flags[Cfg.Flag] = {}
        ConfigFlags[Cfg.Flag] = Cfg.Set
        Cfg.RefreshOptions(Cfg.Options)
        Cfg.Set(Cfg.Default)

        return setmetatable(Cfg, Library)
    end

    Library.AddInput = function(self, Data)
        Data = Data or {}

        local Cfg = {
            Text = Data.Text or Data.Title or Data.Name or nil;
            PlaceHolder = Data.PlaceHolder or Data.PlaceHolderText or Data.Holder or Data.HolderText or "Input here...";
            Default = Data.Default or "";
            Flag = Data.Flag or Data.Name or "TextBox";
            Callback = Data.Callback or function() end;

            Items = {};
            Focused = false;
        }

        Flags[Cfg.Flag] = Cfg.Default

        local Items = Cfg.Items; do
            Items.Object = Library:Create( "Frame", {
                Parent = self.Items.Elements.Instance;
                BackgroundTransparency = 1;
                Size = UDim2.new(1, 0, 0, Cfg.Text and 50 or 26);
                BorderSizePixel = 0
            })

            if Cfg.Text then
                Library:Create( "TextLabel", {
                    FontFace = Themes.Preset.Font;
                    TextColor3 = Color3.fromRGB(252, 252, 252);
                    Text = Cfg.Text;
                    Parent = Items.Object.Instance;
                    AutomaticSize = Enum.AutomaticSize.XY;
                    BackgroundTransparency = 1;
                    Position = UDim2.new(0, -1, 0, 0);
                    BorderSizePixel = 0;
                    ZIndex = 2
                })
            end

            Items.Outline = Library:Create( "Frame", {
                Parent = Items.Object.Instance;
                Position = UDim2.new(0, 1, 0, Cfg.Text and 26 or 0);
                Size = UDim2.new(1, -1, 0, 24);
                BorderSizePixel = 0;
                BackgroundColor3 = Themes.Preset["ElementBackground"]
            }):Themify("ElementBackground", "BackgroundColor3")

            Library:Create( "UIStroke", {
                Color = Themes.Preset.ElementOutline;
                Parent = Items.Outline.Instance
            }):Themify("ElementOutline", "Color")

            Library:Create( "UICorner", {
                Parent = Items.Outline.Instance;
                CornerRadius = UDim.new(0, 5)
            })

            Items.Textbox = Library:Create( "TextBox", {Name="PlexRole_Values";
                Parent = Items.Outline.Instance;
                FontFace = Themes.Preset.Font;
                Active = false;
                ClearTextOnFocus = false;
                Text = Cfg.Default;
                TextColor3 = Color3.fromRGB(252, 252, 252);
                Size = UDim2.new(1, 0, 1, 0);
                Selectable = false;
                BorderSizePixel = 0;
                PlaceholderText = Cfg.PlaceHolder;
                BackgroundTransparency = 1;
                TextXAlignment = Enum.TextXAlignment.Left;
                AutomaticSize = Enum.AutomaticSize.XY;
                ZIndex = 2
            })

            Library:Create( "UIPadding", {
                PaddingLeft = UDim.new(0, 8);
                Parent = Items.Textbox.Instance
            })
        end

        Cfg.Set = function(Text)
            Flags[Cfg.Flag] = Text

            Items.Textbox.Instance.Text = Text

            Cfg.Callback(Text)
        end

        Items.Textbox.Instance.Focused:Connect(function()
            Cfg.Focused = true;
        end)

        Items.Textbox.Instance.FocusLost:Connect(function()
            Cfg.Focused = false;

            Cfg.Set(Items.Textbox.Instance.Text)
        end)

        ConfigFlags[Cfg.Flag] = Cfg.Set

        if self.UpdateSection then
            self.UpdateSection(Items.Object.Instance)
        end

        return setmetatable(Cfg, Library)
    end

    Library.InitConfigs = function(self, Window)
        local Tab = Window:AddTab({
            Title = "Settings",
            Icon = "rbxassetid://117366234081415",
            Pages = {"Configs"},
        })

        local Section = Tab:AddSection({
            Side = "Left",
            Title = "Configs"
        })

        local ConfigText;
        local ConfigHolder = Section:AddDropdown({Text = "Configs", Flag = "ConfigList", Callback = function(option)
            if Text and Text.Set and option then
                Text.Set(option)
            end
        end})

        Text = Section:AddInput({Text = "Config Name", Default = "", PlaceHolder = "Config Name:", Flag = "config_Name_text", PlaceHolder = "Type config name here...", Callback = function(text)
            ConfigText = text
        end})

        Section:AddButton({Text = "Save", Callback = function()
            if not ConfigText then
                return
            end

            Library:SaveConfig(ConfigText)
            ConfigHolder:UpdateConfigList()
        end}):AddButton({Text = "Load", Callback = function()
            Window.Tweening = true
            if not ConfigText then
                return
            end

            for i = 1, 2 do
                Library:LoadConfig(readfile(Library.Directory .. "/Configs/" .. ConfigText .. ".cfg"))
            end

            ConfigHolder:UpdateConfigList()

            Window.Tweening = false
        end})

        Section:AddButton({Text = "Delete", Callback = function()
            if not ConfigText then
                return
            end

            Library:DeleteConfig(ConfigText)
            ConfigHolder:UpdateConfigList()
        end}):AddButton({Text = "Refresh", Callback = function()
            ConfigHolder:UpdateConfigList()
        end})

        Section:AddButton({Text = "Set As Auto Load", Callback = function()
            writefile(Library.Directory.."/Autoload.txt", ConfigText)
            Label.ChangeText("Current Config: " .. readfile(Library.Directory.."/Autoload.txt"))
        end})
        Label = Section:AddLabel({Text = "Current Config: ".. readfile(Library.Directory.."/Autoload.txt")})
        Section:AddButton({Text = "Remove Auto Load", Callback = function()
            writefile(Library.Directory.."/Autoload.txt", "")
            Label.ChangeTet("Current Config: "..readfile(Library.Directory.."/Autoload.txt"))
        end})

        local Section = Tab:AddSection({
            Side = "Right",
            Title = "Theming"
        })

        Section:AddColorPicker({Text = "Accent", Default = Themes.Preset.Accent, Transparency = 0, Flag = Name, Callback = function(Value, Alpha)
            Library:Refresh("Accent", Value)
        end})

        local Section = Tab:AddSection({
            Side = "Right",
            Title = "Other"
        })

        Section:AddKeyPicker({Text = "Menu bind", Mode = "Toggle", ShowInList = false, Callback = function(Value)
            Window.SetVisible(Value)
        end})
        Section:AddToggle({Text = "Watermark", Callback = function(Bool)
            self.Window.Items.Watermark.Instance.Visible = Bool
        end})
        Section:AddToggle({Text = "Mod List", Callback = function(Bool)
            self.Window.Items.ModList.Instance.Visible = Bool
        end})
        Section:AddToggle({Text = "Keybind List", Callback = function(Bool)
            self.Window.Items.KeybindList.Instance.Visible = Bool
        end})

        ConfigHolder:UpdateConfigList();
    end

    do -- Keybind lib
        local YOffset = 0
        local BiggestX = 0

        Library.AddHotKey = function(self, Data)
            Data = Data or {}

            local Cfg = {
                Text = Data.Title or Data.Name or Data.Text or "Title";
                Lifetime = Data.Lifetime or 5;

                Items = {};
                Status = true;
                Fade = 2;
                Tick = tick();
                Index = #self.Keybinds + 1
            }

            local Items = Cfg.Items; do
                Items.Keybind = Library:Create("CanvasGroup",{Parent = self.Window.Items.KeybindHolder.Instance; BackgroundTransparency = 1; Size = UDim2.new(1, 0, 0, 25); BorderSizePixel = 0; BackgroundColor3 = Color3.fromRGB(255, 255, 255)})
                Items.Name = Library:Create("TextLabel",{Name="PlexRole_Labels"; LayoutOrder = 1; TextColor3 = Color3.fromRGB(245, 245, 245); Text = "Idfk"; Parent = Items.Keybind.Instance; AutomaticSize = Enum.AutomaticSize.XY; BackgroundTransparency = 1; TextXAlignment = Enum.TextXAlignment.Left; BorderSizePixel = 0; ZIndex = 2; BackgroundColor3 = Color3.fromRGB(255, 255, 255)})
                Items.UIPadding = Library:Create("UIPadding",{PaddingTop = UDim.new(0, 4); PaddingBottom = UDim.new(0, 6); Parent = Items.Name.Instance; PaddingRight = UDim.new(0, 5); PaddingLeft = UDim.new(0, 7)})
                Items.Key = Library:Create("TextLabel",{Name="PlexRole_Values"; LayoutOrder = 1; Parent = Items.Keybind.Instance; TextColor3 = Color3.fromRGB(170, 170, 170); Text = "[X]"; AutomaticSize = Enum.AutomaticSize.XY; AnchorPoint = Vector2.new(1, 0); Position = UDim2.new(1, 0, 0, 0); BackgroundTransparency = 1; TextXAlignment = Enum.TextXAlignment.Right; BorderSizePixel = 0; ZIndex = 2; BackgroundColor3 = Color3.fromRGB(255, 255, 255)})
                Items.UIPadding = Library:Create("UIPadding",{PaddingTop = UDim.new(0, 4); PaddingBottom = UDim.new(0, 6); Parent = Items.Key.Instance; PaddingRight = UDim.new(0, 5); PaddingLeft = UDim.new(0, 7)})
            end

            function Cfg:ChangeKey(Key)
                if not Key then
                    return
                end

                Items.Key.Instance.Text = tostring("["..Key.."]")
            end

            function Cfg:ChangeName(Name)
                Items.Name.Instance.Text = tostring(Name)
            end

            function Cfg:SetEnabled(Bool)
                Cfg.Status = Bool
            end

            Cfg:ChangeKey(Cfg.Key)
            Cfg:ChangeName(Cfg.Text)

            self.Keybinds[Cfg.Index] = Cfg

            return setmetatable(Cfg, Library)
        end

        Library.LerpKeybinds = function(self)
            YOffset = 0
            BiggestX = 0

            local Tick = tick()
            for _,Object in self.Keybinds do
                Object.Fade = Library:Lerp(Object.Fade, Object.Status and 255 or 0, 0.02)
                local Instance = Object.Items.Keybind.Instance

                local Offset = UDim2.new(0, 0, 0, 0) -- great pasting skills
                local Transparency = 1 - (1 * (Object.Fade / 255))

                Instance.Position = Offset + UDim2.new(0, -(Instance.AbsoluteSize.X - (Instance.AbsoluteSize.X * (Object.Fade / 255))), 0, YOffset)
                Object:SetKeypickerTransparency(Transparency)

                if Object.Status and BiggestX < Instance.AbsoluteSize.X then
                    BiggestX = math.max(BiggestX, Instance.AbsoluteSize.X)
                end

                YOffset += (Instance.AbsoluteSize.Y) * (Object.Fade / 255)
                self.Window.Items.KeybindHolder.Instance.Size = UDim2.new(0, 200, 0, YOffset + 22)
            end
        end

        Library.SetKeypickerTransparency = function(self, Num)
            self.Items.Keybind.Instance.GroupTransparency = Num
        end
    end

    do -- Notification Library
        Library.HUD = Library:Create( "ScreenGui" , {
            Parent = Services.CoreGui;
            Name = "\0";
            Enabled = true;
            IgnoreGuiInset = true;
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
            DisplayOrder = 1000001;
        });

        local YOffset = 0
        local BiggestX = 0

        Library.Notify = function(self, Data)
            Data = Data or {}

            local Cfg = setmetatable({
                Text = Data.Title or Data.Name or Data.Text or "Title";
                Lifetime = Data.Lifetime or 5;

                Items = {};
                Status = true;
                Fade = 2;
                Tick = tick();
                Index = #self.Notifications + 1
            }, Library);

            local Items = Cfg.Items; do
                Items.Notification = Library:Create("CanvasGroup",{GroupTransparency = 1; Parent = Library.HUD.Instance; Position = UDim2.new(0, 30, 0, 60); BorderSizePixel = 0; AutomaticSize = Enum.AutomaticSize.XY; BackgroundColor3 = Color3.fromRGB(12, 12, 14)})
                Items.Accent = Library:Create("Frame",{Parent = Items.Notification.Instance; Position = UDim2.new(0, -3, 1, -1); Size = UDim2.new(0, 0, 0, 4); BorderSizePixel = 0; BackgroundColor3 = Themes.Preset.Accent}):Themify("Accent", "BackgroundColor3")
                Items.Icon = Library:Create("ImageLabel",{ImageColor3 = Themes.Preset.Accent; Parent = Items.Notification.Instance; AnchorPoint = Vector2.new(0, 0.5); Image = Cfg.Icon; Image = "rbxassetid://103028899808055"; BackgroundTransparency = 1; Position = UDim2.new(0, 5, 0.5, -2); Size = UDim2.new(0, 16, 0, 16); BorderSizePixel = 0; BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Themify("Accent", "ImageColor3")
                Items.Title = Library:Create("TextLabel",{Name="PlexRole_Overlay text"; LayoutOrder = 1; TextColor3 = Color3.fromRGB(245, 245, 245); Text = Cfg.Text; Parent = Items.Notification.Instance; BackgroundTransparency = 1; BorderSizePixel = 0; AutomaticSize = Enum.AutomaticSize.XY; BackgroundColor3 = Color3.fromRGB(255, 255, 255)})
                Items.UIPadding = Library:Create("UIPadding",{PaddingTop = UDim.new(0, 4); PaddingBottom = UDim.new(0, 8); Parent = Items.Title.Instance; PaddingRight = UDim.new(0, 5); PaddingLeft = UDim.new(0, 24)})
                Items.UIPadding = Library:Create("UIPadding",{PaddingTop = UDim.new(0, 2); PaddingBottom = UDim.new(0, 2); Parent = Items.Notification.Instance; PaddingRight = UDim.new(0, 2); PaddingLeft = UDim.new(0, 2)})
                Items.UICorner = Library:Create("UICorner",{Parent = Items.Notification.Instance})
            end

            self.Notifications.Notifs[Cfg.Index] = Cfg
            Items.Accent:Tween({Size = UDim2.new(1, 4, 0, 4)}, TweenInfo.new(Cfg.Lifetime, Library.EasingStyle, Library.EasingDirection, 0, false, 0))

            task.delay(Cfg.Lifetime + 1, function()
                Items.Notification.Instance:Destroy()
                self.Notifications.Notifs[Cfg.Index] = nil
            end)

            return setmetatable(Cfg, Library)
        end

        Library.LerpObjects = function(self)
            YOffset = 0
            BiggestX = 0

            local Tick = tick()
            for _,Object in self.Notifications.Notifs do
                if not Object.Fade then
                    Object.Fade = 2;
                end;
                Object.Fade = Library:Lerp(Object.Fade, Object.Status and 255 or 0, 0.02)

                if Tick - Object.Tick >= Object.Lifetime then
                    Object.Status = false
                end

                local Instance = Object.Items.Notification.Instance

                local Offset = UDim2.new(0, 30, 0, 80)
                local Transparency = 1 - (1 * (Object.Fade / 255))

                Instance.Position = Offset + UDim2.new(0, -(Instance.AbsoluteSize.X - (Instance.AbsoluteSize.X * (Object.Fade / 255))), 0, YOffset)
                Object:SetTransparency(Transparency)

                if Object.Status and BiggestX < Instance.AbsoluteSize.X then
                    BiggestX = math.max(BiggestX, Instance.AbsoluteSize.X)
                end

                YOffset += (Instance.AbsoluteSize.Y + 6) * (Object.Fade / 255)
            end
        end

        Library.SetTransparency = function(self, Num)
            self.Items.Notification.Instance.GroupTransparency = Num
        end

        Library:Notify({ Text = 'Loaded!' })
    end

    do -- Mods lib
        local YOffset = 0
        local BiggestX = 0

        Library.AddMod = function(self, Data)
            Data = Data or {}

            local Cfg = {
                Text = Data.Title or Data.Name or Data.Text or "Title";
                Lifetime = Data.Lifetime or 5;

                Items = {};
                Status = true;
                Fade = 2;
                Tick = tick();
                Index = #self.Mods + 1
            }

            local Items = Cfg.Items; do
                Items.Mod = Library:Create("CanvasGroup",{Parent = self.Window.Items.ModHolder.Instance; BackgroundTransparency = 1; Size = UDim2.new(1, 0, 0, 25); BorderSizePixel = 0; BackgroundColor3 = Color3.fromRGB(255, 255, 255)})
                Items.Name = Library:Create("TextLabel",{Name="PlexRole_Labels"; LayoutOrder = 1; Parent = Items.Mod.Instance; TextColor3 = Color3.fromRGB(170, 170, 170); Text = "[X]"; AutomaticSize = Enum.AutomaticSize.XY; AnchorPoint = Vector2.new(0, 0); Position = UDim2.new(0, 0, 0, 0); BackgroundTransparency = 1; TextXAlignment = Enum.TextXAlignment.Right; BorderSizePixel = 0; ZIndex = 2; BackgroundColor3 = Color3.fromRGB(255, 255, 255)})
                Items.UIPadding = Library:Create("UIPadding",{PaddingTop = UDim.new(0, 4); PaddingBottom = UDim.new(0, 6); Parent = Items.Name.Instance; PaddingRight = UDim.new(0, 5); PaddingLeft = UDim.new(0, 7)})
            end

            function Cfg:ChangeName(Name)
                Items.Name.Instance.Text = tostring(Name)
            end

            function Cfg:Destroy()
                Cfg.Status = false

                task.delay(1, function()
                    Items.Mod.Instance:Destroy()
                end)
            end

            Cfg:ChangeName(Cfg.Text)

            self.Mods[Cfg.Index] = Cfg

            return setmetatable(Cfg, Library)
        end

        Library.LerpMods = function(self)
            YOffset = 0
            BiggestX = 0

            local Tick = tick()
            for _,Object in self.Mods do
                Object.Fade = Library:Lerp(Object.Fade, Object.Status and 255 or 0, 0.02)
                local Instance = Object.Items.Mod.Instance

                local Offset = UDim2.new(0, 0, 0, 0) -- great pasting skills
                local Transparency = 1 - (1 * (Object.Fade / 255))

                Instance.Position = Offset + UDim2.new(0, -(Instance.AbsoluteSize.X - (Instance.AbsoluteSize.X * (Object.Fade / 255))), 0, YOffset)
                Object:SetModTransparency(Transparency)

                if Object.Status and BiggestX < Instance.AbsoluteSize.X then
                    BiggestX = math.max(BiggestX, Instance.AbsoluteSize.X)
                end

                YOffset += (Instance.AbsoluteSize.Y) * (Object.Fade / 255)
                self.Window.Items.ModHolder.Instance.Size = UDim2.new(0, 200, 0, YOffset + 22)
            end
        end

        Library.SetModTransparency = function(self, Num)
            self.Items.Mod.Instance.GroupTransparency = Num
        end
    end

    Library:Connect(Services.RunService.Heartbeat, function()
        if not (Library.LerpObjects and Library.LerpMods) then
            return
        end

        Library:LerpObjects()
        Library:LerpKeybinds()
        Library:LerpMods()
    end)
    Library.PlexTheme=Themes.Preset
end

return getgenv().__PlexAetherVendor
