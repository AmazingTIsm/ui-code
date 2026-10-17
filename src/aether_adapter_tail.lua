local context = ... or {}
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local createAetherBridge=assert(loadstring(bridgeSource,"PlexAetherBridge"))()
local Aether=createAetherBridge(assert(loadstring(vendorSource,"PlexAetherVendor"))())
Aether.OnCaptureChanged=function(active,cancel)
    local api=shared.Modern
    if api then api.BindingBusy=active==true;api.ActiveBindCancel=active and cancel or nil end
end
local BRAND_ICON = assert(loadstring(brandSource,"PlexBrandAsset"))()() or ""

local cfg = {}
local events = {}
local options = {}
local serial = 0
local scheduleAutoSave = function() end
local Configs = {active="",list=function() return {} end,isDirty=function() return false end,
    load=function() return false end,save=function() return false end}

local UI = {
    cfg = cfg,
    publicVersion = "Aether 1.1",
    M = {small=10,value=12},
    F = {body=Aether.Font,medium=Aether.Font,semibold=Aether.Font,bold=Aether.Font},
    StartupStyle = {Radius=8,Title="",Interface="Aether",TitleSize=14,LogoWidth=132,LogoHeight=44,Width=380,Height=148,BackdropTransparency=0.55},
    TW = {pop=TweenInfo.new(0.18,Enum.EasingStyle.Back,Enum.EasingDirection.Out),close=TweenInfo.new(0.16,Enum.EasingStyle.Quad,Enum.EasingDirection.In)},
}

local function refreshPalette()
    local theme = Aether.Theme
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
    local original=Aether[method]
    if type(original)=="function" then
        Aether[method]=function(self,...)
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
function UI.fadeIn(root) return Aether:AnimateUI(root,true) end
function UI.fadeOut(root,info,callback) return Aether:AnimateUI(root,false,callback) end
function UI.logoMark(parent,size)
    local object=Instance.new("ImageLabel")
    object.BackgroundTransparency=1
    object.Size=UDim2.fromOffset(size or 132,(size or 132)/3)
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
    object:SetAttribute("AetherIcon",tostring(name or ""))
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
Library.ActiveTabName="info"
Aether.OnTabChanged=function(name)
    Library.ActiveTabName=name
    fire("TabChanged",name)
end
function Library:IsPreviewTabActive()
    return self.ActiveTabName=="esp"
end
local function notify(message,duration,kind)
    local data=type(message)=="table" and message or {Text=tostring(message or ""),Duration=duration,Kind=kind}
    return Aether:Notification({
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
    if name=="" or name:upper()=="NONE" or name=="Unknown" then return nil end
    if name=="MB1" or name=="MouseButton1" then return Enum.UserInputType.MouseButton1 end
    if name=="MB2" or name=="MouseButton2" then return Enum.UserInputType.MouseButton2 end
    if name=="MB3" or name=="MouseButton3" then return Enum.UserInputType.MouseButton3 end
    local ok,key=pcall(function()return Enum.KeyCode[name]end)
    return ok and key or Enum.KeyCode.Unknown
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
    if id==nil then serial+=1 id="AetherOption_"..serial end
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
    -- Aether section row so the custom control participates in reflow, search,
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
        -- A key picker attached to a Aether toggle already drives that toggle in
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
            if id=="MenuKeybind" then Aether.MenuKeybind=parseKey(value) end
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
    info={"overview"},
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
local mobileControlsGui, mobileHolder, mobileEditControl
local mobileButtons, mobileConnections = {}, {}
local mobileEditing, mobileAlive = false, true
local mobilePath="Overlay/Aether/mobile_controls.json"
local mobilePositions={ToggleUI={X=0.93,Y=0.45},LockUI={X=0.93,Y=0.55}}
local mobileSaveToken=0
local function mobileNumber(value, fallback)
    value=tonumber(value)
    return value and value==value and math.abs(value)<math.huge and math.clamp(value,0,1) or fallback
end
if isfile and readfile and isfile(mobilePath) then
    local ok,data=pcall(function()return HttpService:JSONDecode(readfile(mobilePath))end)
    if ok and type(data)=="table" then
        for name,position in pairs(mobilePositions) do
            if type(data[name])=="table" then
                position.X=mobileNumber(data[name].X,position.X)
                position.Y=mobileNumber(data[name].Y,position.Y)
            end
        end
    end
end
local function saveMobilePositions()
    if not writefile then return end
    pcall(function()
        if makefolder and isfolder then
            for _,folder in ipairs({"Overlay","Overlay/Aether"}) do if not isfolder(folder) then makefolder(folder) end end
        end
        writefile(mobilePath,HttpService:JSONEncode(mobilePositions))
    end)
end
local function applyMobilePositions()
    if not mobileHolder then return end
    local size=mobileHolder.AbsoluteSize
    if size.X<=0 or size.Y<=0 then return end
    for name,button in pairs(mobileButtons) do
        local p=mobilePositions[name]
        local halfX,halfY=math.min(60,size.X/2),math.min(25,size.Y/2)
        button.Position=UDim2.fromOffset(math.clamp(p.X*size.X,halfX,size.X-halfX),math.clamp(p.Y*size.Y,halfY,size.Y-halfY))
    end
end
function Library:SetMobileButtonPosition(name,x,y)
    local p=mobilePositions[name]
    if not p then return end
    p.X,p.Y=mobileNumber(x,p.X),mobileNumber(y,p.Y)
    applyMobilePositions()
    mobileSaveToken+=1
    local token=mobileSaveToken
    task.delay(0.25,function()if mobileAlive and token==mobileSaveToken then saveMobilePositions() end end)
end
local function ensureMobileControls()
    if not UIS.TouchEnabled then return nil end
    if mobileControlsGui and mobileControlsGui.Parent then return mobileControlsGui end
    local parent
    pcall(function() parent=gethui and gethui() end)
    if not parent then pcall(function() parent=game:GetService("CoreGui") end) end
    if not parent then parent=Players.LocalPlayer:WaitForChild("PlayerGui") end
    local gui=Instance.new("ScreenGui")
    gui.Name="PlexAetherMobileControls"
    gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=100004
    gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=parent
    mobileControlsGui=gui
    local holder=Instance.new("Frame")
    holder.Name="Buttons";holder.Size=UDim2.fromScale(1,1);holder.BackgroundTransparency=1;holder.Parent=gui
    mobileHolder=holder
    local drag
    local function own(connection) table.insert(mobileConnections,connection) end
    local function addButton(name,text,callback)
        local button=Instance.new("TextButton")
        button.Name=name;button.AnchorPoint=Vector2.new(0.5,0.5);button.Size=UDim2.fromOffset(108,34)
        button.BackgroundColor3=UI.C.surface;button.BackgroundTransparency=0.05;button.BorderSizePixel=0
        button.AutoButtonColor=false;button.Text=text;button.TextColor3=UI.C.text;button.TextSize=12
        button.FontFace=UI.F.medium;button.Parent=holder;mobileButtons[name]=button
        UI.corner(button,8)
        local outline=UI.stroke(button,UI.C.accent,0.12)
        own(button.Activated:Connect(function()if not mobileEditing then pcall(callback) end end))
        own(button.InputBegan:Connect(function(input)
            if mobileEditing and (input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1) then
                local p=mobilePositions[name]
                drag={Input=input,Origin=input.Position,Name=name,X=p.X,Y=p.Y}
            end
        end))
        own(UI.onThemeChanged(function()
            if not button.Parent then return end
            button.BackgroundColor3=UI.C.surface;button.TextColor3=UI.C.text;outline.Color=UI.C.accent
        end))
        return button
    end
    addButton("ToggleUI","Toggle UI",function() Library:Toggle() end)
    local locked=false
    local lockButton
    lockButton=addButton("LockUI","Lock UI",function()
        locked=not locked
        if ZWindow and ZWindow.SetDragLocked then ZWindow:SetDragLocked(locked) end
        lockButton.Text=locked and "Unlock UI" or "Lock UI"
    end)
    own(holder:GetPropertyChangedSignal("AbsoluteSize"):Connect(applyMobilePositions))
    own(UIS.InputChanged:Connect(function(input)
        if not drag or not mobileEditing then return end
        if input~=drag.Input and input.UserInputType~=Enum.UserInputType.MouseMovement then return end
        local delta=input.Position-drag.Origin
        local size=holder.AbsoluteSize
        Library:SetMobileButtonPosition(drag.Name,drag.X+delta.X/math.max(size.X,1),drag.Y+delta.Y/math.max(size.Y,1))
    end))
    own(UIS.InputEnded:Connect(function(input)if drag and input==drag.Input then drag=nil;saveMobilePositions() end end))
    applyMobilePositions()
    return gui
end
function Library:CreatePreviewPanel(parent, title)
    return Aether:CreatePreviewPanel(parent, title)
end

function Library:CreateWindow(config)
    Aether.WindowWidth=850
    Aether.WindowHeight=620
    ZWindow=Aether:Window({Name="plex.cc DEV",Icon=BRAND_ICON,Accent=Color3.fromRGB(73,145,255)})
    self.ScreenGui=Aether.ScreenGui
    refreshThemeArt=function()end
    local originalOpen=ZWindow.SetOpen
    function ZWindow:SetOpen(value)
        if value and shared.ModernLoading then return end
        if not value and mobileEditing then
            mobileEditing=false
            if mobileEditControl then mobileEditControl:Set(false) end
        end
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
        local zTab=ZWindow:Tab({Pages=PAGE_SUBTABS[name] or {"general"},Name=PAGE_NAMES[name] or tostring(name),Icon=ICONS[name] or "circle",Category=({main="Combat",rage="Combat",melee="Combat",weaponconfigs="Combat",world="Visuals",esp="Visuals",visuals="Visuals",skins="Cosmetics",customcosmetics="Cosmetics",inventoryspoofer="Cosmetics",character="Player",misc="Player",spoofers="Player",servers="System",settings="System",optimizations="System"})[name] or "System"})
        local tab={Aether=zTab,Groupboxes={},Tabboxes={},Subs={}}
        Menu.subs[name]={}
        for _,subName in ipairs(PAGE_SUBTABS[name] or {"general"}) do
            local zSub=zTab:SubTab({Name=subName,Icon=(SUB_ICONS[name] and SUB_ICONS[name][subName]) or "circle"})
            tab.Subs[subName]=zSub
            Menu.subs[name][subName]={L={Sub=zSub,Side=1},R={Sub=zSub,Side=2},Aether=zSub}
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
        if name=="settings" then
            local overlays=tab:AddLeftGroupbox("Overlay visibility")
            overlays:AddToggle("PlexShowWatermark",{Text="Show watermark",Default=true,Callback=function(value) fire("OverlayVisibilityChanged","Watermark",value) end})
            overlays:AddToggle("PlexShowKeybindList",{Text="Show keybind list",Default=true,Callback=function(value) fire("OverlayVisibilityChanged","KeybindList",value) end})
            local controls=tab:AddRightGroupbox("Mobile buttons").Native
            local selected="ToggleUI"
            local syncing=true
            local x,y
            local function sync()
                if not x then return end
                syncing=true;x:Set(mobilePositions[selected].X*100);y:Set(mobilePositions[selected].Y*100);syncing=false
            end
            controls:Label({Name="Choose a button, then set its screen position."})
            controls:Dropdown({Name="Button",Items={"ToggleUI","LockUI"},Default=selected,Callback=function(value)selected=value;sync()end})
            x=controls:Slider({Name="Horizontal position",Min=0,Max=100,Default=mobilePositions[selected].X*100,Decimals=1,Suffix="%",Callback=function(value)
                if not syncing then Library:SetMobileButtonPosition(selected,value/100,mobilePositions[selected].Y) end
            end})
            y=controls:Slider({Name="Vertical position",Min=0,Max=100,Default=mobilePositions[selected].Y*100,Decimals=1,Suffix="%",Callback=function(value)
                if not syncing then Library:SetMobileButtonPosition(selected,mobilePositions[selected].X,value/100) end
            end})
            syncing=false
            mobileEditControl=controls:Toggle({Name="Drag mobile buttons to position",Default=false,Callback=function(value)mobileEditing=value==true end})
            controls:Label({Name="Drag mode pauses button actions. Turn it off when done."})
            controls:Button({Name="Reset mobile positions",Callback=function()
                Library:SetMobileButtonPosition("ToggleUI",0.93,0.45)
                Library:SetMobileButtonPosition("LockUI",0.93,0.55);sync()
            end})
        end
        return tab
    end
    do
        local info=window:AddTab("info")
        local started=os.clock()
        local env=getgenv and getgenv() or _G
        local fields={}
        local snapshot={}
        local function line(group,key)
            fields[key]=group:AddLabel("Loading...")
        end
        local function copy(value)
            local clipboard=setclipboard or toclipboard
            if type(clipboard)~="function" then notify("Clipboard is unavailable in this executor",3) return end
            local ok=pcall(clipboard,tostring(value))
            notify(ok and "Copied to clipboard" or "Could not copy to clipboard",2)
        end
        local account=info:AddLeftGroupbox("Account")
        for _,key in ipairs({"User","Display name","User ID"}) do line(account,key) end
        account:AddButton("Copy user ID",function() copy(Players.LocalPlayer.UserId) end)
        local session=info:AddLeftGroupbox("Game & Server")
        for _,key in ipairs({"Game","Place ID","Universe ID","Place version","Server","Session"}) do line(session,key) end
        session:AddButton("Copy server ID",function() copy(game.JobId) end)
        session:AddButton("Copy join snippet",function()
            if game.JobId=="" then notify("This session has no server ID",3) return end
            copy(string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%s, %q, game:GetService("Players").LocalPlayer)',tostring(game.PlaceId),game.JobId))
        end)
        local runtime=info:AddRightGroupbox("Runtime")
        for _,key in ipairs({"Executor","Input","Ping","Modules","Startup errors"}) do line(runtime,key) end
        local build=info:AddRightGroupbox("Build")
        for _,key in ipairs({"Interface","Build","Loading"}) do line(build,key) end
        local function refresh()
            local player=Players.LocalPlayer
            local api=shared.Modern
            local enabled,total=0,0
            for _,module in pairs(api and api.Modules or {}) do
                total+=1;if module.Enabled then enabled+=1 end
            end
            local executor="Unavailable"
            local identify=identifyexecutor or getexecutorname
            if type(identify)=="function" then
                local ok,name,version=pcall(identify)
                if ok then executor=tostring(name)..(version and " "..tostring(version) or "") end
            end
            local ping="Unavailable"
            local ok,value=pcall(function()return player:GetNetworkPing()end)
            if ok and type(value)=="number" then ping=tostring(math.floor(value*1000+0.5)).." ms" end
            local seconds=math.max(0,math.floor(os.clock()-started))
            snapshot={
                ["User"]=player.Name,["Display name"]=player.DisplayName,["User ID"]=tostring(player.UserId),
                ["Game"]=game.Name,["Place ID"]=tostring(game.PlaceId),["Universe ID"]=tostring(game.GameId),
                ["Place version"]=tostring(game.PlaceVersion),["Server"]=game.JobId~="" and game.JobId:sub(1,18).."..." or "Unavailable",
                ["Session"]=string.format("%dm %ds",math.floor(seconds/60),seconds%60),
                ["Executor"]=executor,["Input"]=UIS.TouchEnabled and (UIS.MouseEnabled and "Touch + mouse" or "Touch") or (UIS.KeyboardEnabled and "Keyboard + mouse" or "Gamepad"),
                ["Ping"]=ping,["Modules"]=string.format("%d enabled / %d total",enabled,total),
                ["Startup errors"]=tostring(#(shared.PlexFeatureErrors or {})),["Interface"]=UI.publicVersion,
                ["Build"]=tostring(env.__PlexBuildId or "Local source build"),
                ["Loading"]=api and api.FeatureLoadComplete and "Complete" or "In progress",
            }
            for key,widget in pairs(fields) do widget:SetText(key..": "..tostring(snapshot[key] or "Unavailable")) end
        end
        local diagnostics=info:AddLeftGroupbox("Diagnostics")
        diagnostics:AddLabel("Values refresh when Info opens.")
        diagnostics:AddButton("Refresh info",refresh)
        diagnostics:AddButton("Copy diagnostic summary",function()
            refresh()
            local lines={"Plex session diagnostics"}
            for _,key in ipairs({"Interface","Build","Executor","Input","Place ID","Universe ID","Place version","Session","Ping","Modules","Startup errors","Loading"}) do
                lines[#lines+1]=key..": "..tostring(snapshot[key])
            end
            lines[#lines+1]="Server ID: "..game.JobId
            copy(table.concat(lines,"\n"))
        end)
        local support=info:AddRightGroupbox("Support")
        support:AddLabel("Report the issue and steps to reproduce.")
        support:AddLabel("Attach your copied diagnostic summary.")
        support:AddButton("Copy project link",function() copy("https://github.com/AmazingTIsm/Plex.cc-Source") end)
        info.Aether.OnSelect=refresh
        refresh()
    end
    function window:Update() end
    return window
end
function Library:SetGameMode(mode) Aether:SetGameMode(mode) end
function Library:SetVisible(open)
    if not ZWindow then return end
    if open and shared.ModernLoading then return end
    local visible=open==true
    ZWindow:SetOpen(visible)
    if visible and Menu.syncNow then
        task.defer(function() pcall(Menu.syncNow) end)
    end
end
function Library:Toggle()
    if ZWindow then Library:SetVisible(not ZWindow.IsOpen) end
end
function Library:Unload()
    mobileAlive=false
    mobileSaveToken+=1
    if mobileHolder then saveMobilePositions() end
    for _,connection in ipairs(mobileConnections) do connection:Disconnect() end
    table.clear(mobileConnections)
    Aether:Unload()
    for _,event in pairs(events) do event:Destroy() end
    if mobileControlsGui then pcall(function() mobileControlsGui:Destroy() end) mobileControlsGui=nil end
end
function Menu.set(open) Library:SetVisible(open) end
function Menu.showTab(name)
    local tab=Library.Tabs and Library.Tabs[name]
    if tab then tab.Aether:Select() Menu.activeTab=name end
end
function Menu.showSub(name,subName)
    Menu.showTab(name)
    local sub=Menu.subs[name] and Menu.subs[name][subName]
    if sub and sub.Aether then
        local zsub=sub.Aether
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
        if tab and tab.Aether and tab.Aether.Current then
            local current=tab.Aether.Current
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
            object:SetValue(binding.key or "None") object:SetMode(binding.mode or "None")
            if type(states)=="table" and states[id]~=nil then object.Active=states[id]==true end
        end
    end
end

local themeManager={}
function themeManager:SetLibrary() end
function themeManager:SetFolder() end
function themeManager:ApplyToTab(tab)
    local names={} for _,entry in ipairs(Aether.ThemePresets) do table.insert(names,entry.Name) end
    local group=tab:AddRightGroupbox("Aether appearance")
    group:AddDropdown("NativeTheme",{Text="Theme",Values=names,Default="Default",Callback=function(value) Aether:SetTheme(value) end})
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

    local function ignored(id)
        return id=="NativeConfigName" or id=="SaveManager_ConfigList" or id=="NativeAutoLoad" or id=="NativeSilentLoad"
            or (self.Ignore and self.Ignore[id]) or (self.IgnoreTheme and id=="NativeTheme")
    end
    self.Loading=true
    local appliedCount, failedCount, firstError = 0, 0, nil
    local applied,applyError=pcall(function()
        if self.BeforeLoad then self.BeforeLoad() end
        -- Binding mode callbacks can disable their parent feature. Restore them
        -- before saved toggles, then enforce only persistent modes afterwards.
        if type(data.bindings)=="table" and Library.NativeUI
            and type(Library.NativeUI.applySavedBindings)=="function" then
            local bindings,states={},{}
            for id,binding in pairs(data.bindings) do
                if not ignored(id) then
                    bindings[id]=binding
                    if data.bindingStates then states[id]=data.bindingStates[id] end
                end
            end
            Library.NativeUI.applySavedBindings(bindings,states)
        end
        if data.objects then
            local toggles={}
            local function applyEntry(entry)
                local object=options[entry.idx]
                if not object or ignored(entry.idx) then return end
                local ok,err=pcall(function()
                    if object.Type=="ColorPicker" then
                        object:SetValueRGB(Color3.fromHex(entry.value),entry.transparency)
                    elseif object.Type=="Slider" then
                        object:SetValue(tonumber(entry.value) or object.Value)
                    else
                        object:SetValue(entry.value)
                        if object.Type=="KeyPicker" and entry.mode then object:SetMode(entry.mode) end
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
                if object and object.Type=="KeyPicker" and not ignored(entry.idx)
                    and (object.Mode=="Always" or object.Mode=="Never" or object.Mode=="Hold") then
                    local ok,err=pcall(object.SetMode,object,object.Mode)
                    if not ok then failedCount+=1 firstError=firstError or (tostring(entry.idx)..": "..tostring(err)) end
                end
            end
        else
            for id,value in pairs(data) do
                local object=options[id]
                if object and not ignored(id) and type(value)=="table" then
                    local ok,err=pcall(function()
                        if value.Color then object:SetValueRGB(Color3.new(table.unpack(value.Color)),value.Transparency)
                        elseif value.Value~=nil then object:SetValue(value.Value) end
                    end)
                    if ok then appliedCount+=1 else failedCount+=1 firstError=firstError or (tostring(id)..": "..tostring(err)) end
                end
            end
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
    group:AddLabel("Auto load reloads Plex after teleports while the executor remains injected.")
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
    local function bootStatus(phase)
        if type(writefile)=="function" then pcall(writefile,"Overlay/tphandler_status.txt",
            phase.."|"..tostring(game.PlaceId).."|"..tostring(game.JobId)) end
    end
    bootStatus("waiting-native")
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
    bootStatus("native-wait-failed")
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
    Aether:FinalizeCards()
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
