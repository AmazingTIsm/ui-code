local function createAetherBridge(native)
    local UIS=game:GetService("UserInputService")
    local TweenService=game:GetService("TweenService")
    local bridge={ThemePresets={{Name="Default"}},MenuKeybind=Enum.KeyCode.End}
    local theme=native.PlexTheme
    bridge.Font=theme.Font
    bridge.Theme={Background=theme.Background,Section=theme.SectionBackground,Element=theme.ElementBackground,
        Text=theme.TextColor,DimText=theme.Unselected,Accent=theme.Accent,Light=theme.Inline,Line=theme.ElementOutline}
    local connections,bindings={},{}
    native.LerpKeybinds=function()end
    native.LerpMods=function()end
    native.PlexCaptureChanged=function(active,cancel)
        if bridge.OnCaptureChanged then bridge.OnCaptureChanged(active,cancel) end
    end
    local activeWindow
    local savedMouseBehavior
    local function releaseMouse()
        if savedMouseBehavior~=nil then
            local previous=savedMouseBehavior
            savedMouseBehavior=nil
            UIS.MouseBehavior=previous
        end
    end
    local function own(connection)
        connections[#connections+1]=connection
        native.Connections=native.Connections or {}
        native.Connections[#native.Connections+1]={Connection=connection}
        return connection
    end
    local layoutPath="Overlay/Aether/card_layouts.json"
    local layouts,cardsByPage={},{}
    local json=game:GetService("HttpService")
    if isfile and readfile and isfile(layoutPath) then
        local ok,value=pcall(function()return json:JSONDecode(readfile(layoutPath))end)
        if ok and type(value)=="table" then layouts=value end
    end
    local cardGhost
    local function attachCardLayout(page,section,definition)
        if not page.PlexLayoutKey or not page.Items.Left or not page.Items.Right then return end
        local cards=cardsByPage[page] or {};cardsByPage[page]=cards
        local id=page.PlexLayoutKey.."|"..tostring(definition.Side).."|"..tostring(definition.Name)
        local saved=layouts[id]
        local side=definition.Side==2 and "Right" or "Left"
        if type(saved)=="table" and (saved.Side=="Left" or saved.Side=="Right") then side=saved.Side end
        local frame=section.Items.Section.Instance
        frame.Parent=page.Items[side].Instance
        frame.LayoutOrder=type(saved)=="table" and type(saved.Order)=="number" and math.clamp(math.floor(saved.Order),1,10000) or 1000+#cards
        local savedCollapsed
        if type(saved)=="table" then savedCollapsed=saved.Collapsed end
        local record={Id=id,Side=side,Frame=frame,Section=section,SavedCollapsed=savedCollapsed};cards[#cards+1]=record
        section.OnCollapsed=function(collapsed)
            layouts[id]=layouts[id] or {Side=record.Side,Order=frame.LayoutOrder}
            layouts[id].Collapsed=collapsed==true
            record.SavedCollapsed=collapsed==true
            if writefile then pcall(function()
                if makefolder then
                    if not isfolder or not isfolder("Overlay") then makefolder("Overlay") end
                    if not isfolder or not isfolder("Overlay/Aether") then makefolder("Overlay/Aether") end
                end
                writefile(layoutPath,json:JSONEncode(layouts))
            end) end
        end
        local origin,lastPoint,moving,blocked
        local function move(input)
            if blocked then return end
            local point=Vector2.new(input.Position.X,input.Position.Y)
            if not origin then
                local bar=section.Items.TopBar.Instance
                if point.X>bar.AbsolutePosition.X+bar.AbsoluteSize.X-30 then blocked=true;return end
                origin=point;lastPoint=point;moving=false
            end
            lastPoint=point
            if not moving and (point-origin).Magnitude<6 then return end
            moving=true
            if not cardGhost then
                cardGhost=native:Create("TextLabel",{Name="CardDragPreview",Text="",FontFace=theme.Font,TextSize=13,
                    BackgroundColor3=theme.SectionBackground,BackgroundTransparency=0.15,TextColor3=theme.TextColor,
                    BorderSizePixel=0,ZIndex=50,Active=false,Visible=false,Parent=native.Elements.Instance})
                native:Create("UICorner",{CornerRadius=UDim.new(0,6),Parent=cardGhost.Instance})
                native:Create("UIStroke",{Color=theme.Accent,Parent=cardGhost.Instance})
            end
            cardGhost.Instance.Text=tostring(definition.Name)
            cardGhost.Instance.Size=UDim2.fromOffset(frame.AbsoluteSize.X,30)
            cardGhost.Instance.Position=UDim2.fromOffset(point.X+12,point.Y+8)
            cardGhost.Instance.Visible=true
        end
        local function finish(_,cancelled)
            if cardGhost then cardGhost.Instance.Visible=false end
            local point=lastPoint
            local dropped=moving and not cancelled
            origin,lastPoint,moving,blocked=nil,nil,false,false
            if not dropped or not point then return end
            local target
            for _,column in ipairs({"Left","Right"}) do
                local container=page.Items[column].Instance
                local pos,size=container.AbsolutePosition,container.AbsoluteSize
                if point.X>=pos.X and point.X<=pos.X+size.X and point.Y>=pos.Y and point.Y<=pos.Y+size.Y then target=column;break end
            end
            if not target then return end
            local ordered={}
            for _,card in ipairs(cards) do if card~=record and card.Side==target then ordered[#ordered+1]=card end end
            table.sort(ordered,function(a,b)return a.Frame.LayoutOrder<b.Frame.LayoutOrder end)
            local index=#ordered+1
            for at,card in ipairs(ordered) do
                if point.Y<card.Frame.AbsolutePosition.Y+card.Frame.AbsoluteSize.Y/2 then index=at;break end
            end
            table.insert(ordered,index,record)
            record.Side=target;frame.Parent=page.Items[target].Instance
            for at,card in ipairs(ordered) do card.Frame.LayoutOrder=at end
            for _,card in ipairs(cards) do
                local state=layouts[card.Id] or {}
                state.Side,state.Order=card.Side,card.Frame.LayoutOrder
                layouts[card.Id]=state
            end
            if writefile then
                local ok,why=pcall(function()
                    if makefolder then
                        if not isfolder or not isfolder("Overlay") then makefolder("Overlay") end
                        if not isfolder or not isfolder("Overlay/Aether") then makefolder("Overlay/Aether") end
                    end
                    writefile(layoutPath,json:JSONEncode(layouts))
                end)
                if not ok then warn("[Plex UI] Could not save card layout: "..tostring(why)) end
            end
        end
        section.PlexDragHandle=native:Create("TextButton",{Name="MoveCard",Text="",BackgroundTransparency=1,
            AutoButtonColor=false,BorderSizePixel=0,ZIndex=5,Size=UDim2.new(1,-30,1,0),Parent=section.Items.TopBar.Instance})
        section.PlexDragHandle:OnDrag(move,finish)
    end
    function bridge:FinalizeCards()
        for _,cards in pairs(cardsByPage) do
            for _,record in ipairs(cards) do
                if not record.Initialized then
                    record.Initialized=true
                    local collapsed=record.SavedCollapsed
                    if type(collapsed)~="boolean" then collapsed=(record.Section.CachedSize or 0)>420 end
                    if record.Section.Collapsed~=collapsed then record.Section.Collapse(collapsed,true) end
                end
            end
        end
    end
    local function key(value)
        if typeof(value)=="EnumItem" then return value end
        local name=tostring(value or "None"):gsub("Enum.KeyCode%.",""):gsub("Enum.UserInputType%.","")
        local aliases={MB1="MouseButton1",MB2="MouseButton2",MB3="MouseButton3"}
        name=aliases[name] or name
        local ok,result=pcall(function()return Enum.KeyCode[name]end)
        if ok then return result end
        ok,result=pcall(function()return Enum.UserInputType[name]end)
        return ok and result or nil
    end
    local function wrap(control)
        local object={Native=control,Items=control.Items,Value=control.Value,Properties={}}
        function object:Set(value,alpha)
            control.Set(value,alpha)
            self.Value=control.Value or control.Enabled or value
        end
        function object:SetText(value) if control.ChangeText then control.ChangeText(value) end end
        return object
    end
    -- Detached panels share Aether's creation, theme registry and lifetime.
    function bridge:CreatePreviewPanel(parent, text)
        local frame=native:Create("Frame",{Name="AetherPreviewPanel",BorderSizePixel=0,
            Size=UDim2.fromScale(1,1),BackgroundColor3=theme.SectionBackground,ZIndex=51,Parent=parent})
        frame:Themify("SectionBackground","BackgroundColor3")
        native:Create("UICorner",{CornerRadius=UDim.new(0,8),Parent=frame.Instance})
        local stroke=native:Create("UIStroke",{ApplyStrokeMode=Enum.ApplyStrokeMode.Border,
            Color=theme.Inline,Thickness=1,Parent=frame.Instance})
        stroke:Themify("Inline","Color")
        local header=native:Create("Frame",{Name="Header",BorderSizePixel=0,
            BackgroundColor3=theme.ElementBackground,Size=UDim2.new(1,0,0,35),ZIndex=52,Parent=frame.Instance})
        header:Themify("ElementBackground","BackgroundColor3")
        native:Create("UICorner",{CornerRadius=UDim.new(0,8),Parent=header.Instance})
        local title=native:Create("TextLabel",{Name="Title",Text=text,TextSize=15,FontFace=theme.Font,
            TextColor3=theme.TextColor,BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,
            Size=UDim2.new(1,-90,1,0),Position=UDim2.fromOffset(34,0),ZIndex=53,Parent=header.Instance})
        title:Themify("TextColor","TextColor3")
        native:CreatePlexIcon(header.Instance,"preview",UDim2.fromOffset(12,18),14,theme.Unselected)
        local mode=native:Create("TextLabel",{Name="Mode",Text="2D",TextSize=12,FontFace=theme.Font,
            TextColor3=theme.Unselected,BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Right,
            Size=UDim2.fromOffset(48,35),Position=UDim2.new(1,-60,0,0),ZIndex=53,Parent=header.Instance})
        mode:Themify("Unselected","TextColor3")
        local panel={Frame=frame.Instance,Title=title.Instance,Mode=mode.Instance,Stroke=stroke.Instance}
        function panel:CreateButton()
            local button=native:Create("TextButton",{BackgroundColor3=theme.ElementBackground,
                TextColor3=theme.TextColor,FontFace=theme.Font,BorderSizePixel=0,Parent=frame.Instance})
            button:Themify("ElementBackground","BackgroundColor3")
            button:Themify("TextColor","TextColor3")
            native:Create("UICorner",{CornerRadius=UDim.new(0,4),Parent=button.Instance})
            return button.Instance
        end
        return panel
    end
    local function section(page,definition)
        local nativeSection=page:AddSection({Text=definition.Name,Side=definition.Side==2 and "Right" or "Left"})
        attachCardLayout(page,nativeSection,definition)
        local result={Items={Holder=nativeSection.Items.Elements},Native=nativeSection}
        local function params(def)
            return {Text=def.Name,Flag=def.Flag,Default=def.Default,Callback=def.Callback or function()end}
        end
        function result:AddRow(height)
            local row=native:Create("Frame",{BackgroundTransparency=1,BorderSizePixel=0,
                Size=UDim2.new(1,0,0,height),Parent=nativeSection.Items.Elements.Instance})
            nativeSection.UpdateSection(row.Instance)
            return row
        end
        function result:Colorpicker(def)
            local p=params(def)
            p.Alpha=def.Transparency or 0
            p.Callback=function(color,alpha) if def.Callback then def.Callback(color,alpha or 0) end end
            local object=wrap(nativeSection:AddColorPicker(p))
            function object:Set(color,alpha) self.Native.Set(color,alpha or 0);self.Value=color end
            return object
        end
        function result:Toggle(def)
            local control=nativeSection:AddToggle(params(def))
            local object=wrap(control)
            object.Items.Box=control.Items.Toggle
            function object:Colorpicker(d)return result:Colorpicker(d)end
            function object:Keybind(d)
                local picker=nativeSection:AddKeyPicker({Text=def.Name,Flag=d.Flag,Default=key(d.Default),Mode=d.Mode,
                    Callback=function(value) object:Set(value==true) end})
                local bind={Mode=d.Mode,Value=key(d.Default),Native=picker}
                local originalSet,originalMode=picker.Set,picker.SetMode
                local registered
                local function register()
                    if registered and bindings[registered] then bindings[registered][picker]=nil end
                    registered=key(picker.Key)
                    if registered then bindings[registered]=bindings[registered] or {};bindings[registered][picker]=true end
                end
                function bind:Set(value)
                    originalSet({Key=key(value) or "NONE",Mode=self.Mode,Active=picker.Active})
                    self.Value=key(picker.Key);register()
                end
                function bind:SetMode(mode)
                    self.Mode=mode
                    originalMode(mode)
                    if mode=="Never" or mode=="None" then originalSet(false) end
                end
                picker.Set=function(value)
                    originalSet(value)
                    register()
                    if typeof(value)=="EnumItem" or (type(value)=="table" and value.Key~=nil) then bind:Set(picker.Key)
                    elseif type(value)=="string" and (value=="Hold" or value=="Toggle" or value=="Always") then bind:SetMode(value) end
                end
                register()
                return bind
            end
            return object
        end
        function result:Slider(def)
            local p=params(def)
            p.Min,p.Max,p.Default=def.Min,def.Max,def.Default
            p.Decimal,p.Suffix=def.Decimals or 1,def.Suffix
            return wrap(nativeSection:AddSlider(p))
        end
        function result:Dropdown(def)
            local p=params(def)
            p.Options,p.Multi=def.Items or {},def.Multi
            local object=wrap(nativeSection:AddDropdown(p))
            function object:Refresh(values)self.Native.RefreshOptions(values or {})end
            return object
        end
        function result:Textbox(def)
            local p=params(def);p.PlaceHolder=def.Placeholder
            return wrap(nativeSection:AddInput(p))
        end
        function result:Label(def)
            local control=nativeSection:AddLabel({Text=def.Name})
            local object=wrap(control)
            function object:Set(value)control.ChangeText(tostring(value))end
            return object
        end
        function result:Button(def)
            return nativeSection:AddButton({Text=def.Name,Callback=def.Callback})
        end
        return result
    end
    function bridge:Window(def)
        local window=native:CreateWindow({Title=(def.Name or "plex.cc"):gsub("%s*DEV$",""),SubText="Rivals | Detecting",Image=def.Icon,
            Size=UDim2.fromOffset(850,620),IsMobile=false})
        if def.Icon and def.Icon~="" then
            local logo=window.Items.Logo.Instance
            logo.Position=UDim2.fromOffset(14,10)
            logo.Size=UDim2.fromOffset(144,48)
            logo.ScaleType=Enum.ScaleType.Fit
            logo.ImageColor3=Color3.new(1,1,1)
            window.Items.BrandTitle.Instance.Visible=false
        end
        local subtitle=window.Items.Subtitle and window.Items.Subtitle.Instance
        if subtitle then
            subtitle.Parent=window.Items.Topbar.Instance
            subtitle.AnchorPoint=Vector2.new(0,0)
            subtitle.Position=UDim2.fromOffset(14,62)
            subtitle.Size=UDim2.fromOffset(112,16)
            subtitle.AutomaticSize=Enum.AutomaticSize.None
            subtitle.TextSize=10
            subtitle.TextXAlignment=Enum.TextXAlignment.Left
        end
        local menu=window.Items.Menu.Instance
        local viewport=workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280,720)
        local scale=menu:FindFirstChildOfClass("UIScale")
        if scale then scale.Scale=math.clamp(math.min((viewport.X-32)/850,(viewport.Y-48)/620),0.4,1) end
        menu.AnchorPoint=Vector2.new(0.5,0.5)
        menu.Position=UDim2.fromScale(0.5,0.5)
        native.Items.Instance.Name="PlexAetherUI"
        native.Items.Instance.DisplayOrder=100000
        self.ScreenGui=native.Items.Instance
        self.TypographyRoots={native.Items.Instance,native.Elements.Instance,native.HUD.Instance}
        native.Elements.Instance.DisplayOrder=100001
        native.HUD.Instance.DisplayOrder=99999
        window.Items.KeybindList.Instance.Visible=false
        window.Items.Watermark.Instance.Visible=false
        window.Items.ModHolder.Instance.Visible=false
        window.Items.TabButtonHolder.Instance.Visible=false
        local sidebar=native:Create("ScrollingFrame",{Name="PlexCategorySidebar",
            BackgroundTransparency=1,BorderSizePixel=0,Position=UDim2.fromOffset(0,88),
            Size=UDim2.new(1,0,1,-100),CanvasSize=UDim2.fromOffset(0,0),
            AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=3,
            ScrollBarImageColor3=theme.Unselected,ScrollingDirection=Enum.ScrollingDirection.Y,
            Parent=window.Items.SideBar.Instance})
        native:Create("UIPadding",{PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,12),
            PaddingBottom=UDim.new(0,8),Parent=sidebar.Instance})
        native:Create("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder,
            Parent=sidebar.Instance})
        local categories={}
        for order,name in ipairs({"Combat","Visuals","Cosmetics","Player","System"}) do
            local root=native:Create("Frame",{Name="Category_"..name,BackgroundTransparency=1,
                Size=UDim2.new(1,0,0,36),ClipsDescendants=true,LayoutOrder=order,Parent=sidebar.Instance})
            local header=native:Create("TextButton",{Name="CategoryToggle",Text=name,
                AutoButtonColor=false,TextXAlignment=Enum.TextXAlignment.Left,FontFace=theme.Font,
                TextSize=13,TextColor3=theme.TextColor,BackgroundColor3=theme.TabButtons,BackgroundTransparency=0.7,
                BorderSizePixel=0,Size=UDim2.new(1,0,0,36),Parent=root.Instance}):Themify("TextColor","TextColor3"):Themify("TabButtons","BackgroundColor3")
            native:CreatePlexIcon(header.Instance,"category"..name,UDim2.new(0,-24,0.5,0),16,theme.Unselected)
            native:Create("UICorner",{CornerRadius=UDim.new(0,8),Parent=header.Instance})
            native:Create("UIPadding",{PaddingLeft=UDim.new(0,32),PaddingRight=UDim.new(0,24),Parent=header.Instance})
            local arrow=native:CreatePlexIcon(header.Instance,"chevron",UDim2.new(1,-4,0.5,0),12,theme.Unselected)
            arrow.Instance.AnchorPoint=Vector2.new(1,0.5)
            local children=native:Create("Frame",{Name="Pages",BackgroundTransparency=1,
                Position=UDim2.fromOffset(0,40),Size=UDim2.new(1,0,0,0),Visible=false,Parent=root.Instance})
            native:Create("UIPadding",{PaddingLeft=UDim.new(0,12),Parent=children.Instance})
            native:Create("UIListLayout",{Padding=UDim.new(0,3),SortOrder=Enum.SortOrder.LayoutOrder,Parent=children.Instance})
            local category={Root=root,Header=header,Arrow=arrow,Children=children,Count=0,Expanded=false,Tweens={},AnimationToken=0}
            function category:StopAnimation()
                self.AnimationToken+=1
                if self.Completion then self.Completion:Disconnect();self.Completion=nil end
                for _,tween in ipairs(self.Tweens) do tween:Cancel() end
                table.clear(self.Tweens)
            end
            function category:SetExpanded(expanded,animate)
                expanded=expanded==true
                if animate and expanded==self.Expanded then return end
                self:StopAnimation()
                self.Expanded=expanded
                self.Children.Instance.Size=UDim2.new(1,0,0,self.Count*35)
                local height=36+(expanded and (4+self.Count*35) or 0)
                local rotation=expanded and 90 or 0
                local transparency=expanded and 0.45 or 0.7
                if not animate then
                    self.Children.Instance.Visible=expanded
                    self.Root.Instance.Size=UDim2.new(1,0,0,height)
                    self.Arrow.Instance.Rotation=rotation
                    self.Header.Instance.BackgroundTransparency=transparency
                    return
                end
                self.Children.Instance.Visible=true
                local info=TweenInfo.new(0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
                self.Tweens={TweenService:Create(self.Root.Instance,info,{Size=UDim2.new(1,0,0,height)}),
                    TweenService:Create(self.Arrow.Instance,info,{Rotation=rotation}),
                    TweenService:Create(self.Header.Instance,info,{BackgroundTransparency=transparency})}
                local token=self.AnimationToken
                self.Completion=self.Tweens[1].Completed:Connect(function()
                    if token~=self.AnimationToken or native.PlexUnloaded then return end
                    self.Children.Instance.Visible=self.Expanded
                    if self.Completion then self.Completion:Disconnect();self.Completion=nil end
                end)
                for _,tween in ipairs(self.Tweens) do tween:Play() end
            end
            header:OnClick(function()category:SetExpanded(not category.Expanded,true)end)
            categories[name]=category
        end
        -- Modal belongs to a GuiButton, not the menu Frame. Keep it tiny so
        -- it releases first-person mouse capture without covering controls.
        local inputModal=native:Create("TextButton",{Name="PlexMenuInputModal",Text="",
            BackgroundTransparency=1,BorderSizePixel=0,AutoButtonColor=false,
            Size=UDim2.fromOffset(1,1),Position=UDim2.fromOffset(0,0),
            Visible=false,Modal=false,Parent=menu}).Instance
        local result={IsOpen=false,Native=window,SidebarCategories=categories,Items={Root=window.Items.Menu,Main=window.Items.Menu}}
        function result:SetDragLocked(locked)
            menu:SetAttribute("PlexDragLocked",locked==true)
        end
        function result:SetOpen(visible)
            self.IsOpen=visible==true
            inputModal.Modal=self.IsOpen
            inputModal.Visible=self.IsOpen
            if self.IsOpen and UIS.MouseEnabled then
                if savedMouseBehavior==nil then savedMouseBehavior=UIS.MouseBehavior end
                UIS.MouseBehavior=Enum.MouseBehavior.Default
            else
                releaseMouse()
            end
            -- Visibility is owned by Plex. Avoid fading every control on each menu toggle.
            if self.IsOpen then native.Items.Instance.Enabled=true end
            if self.IsOpen then native.Elements.Instance.Enabled=true end
            local opening=self.IsOpen
            native:AnimateVisibility(menu,opening,function()
                if self.IsOpen==opening then
                    native.Items.Instance.Enabled=opening
                    native.Elements.Instance.Enabled=opening
                end
            end,nil,native.PlexUnloaded)
            if not self.IsOpen then
                if native.PlexActiveKeyCapture then native.PlexActiveKeyCapture.CancelCapture() end
                if native.PlexActiveNumberEdit then native.PlexActiveNumberEdit.CancelNumberEdit() end
                local drag=native.PlexDrag;native.PlexDrag=nil
                if drag and drag.Finish then drag.Finish(nil,true) end
                native:ClosePopups()
            end
        end
        function result:Tab(definition)
            local pages=definition.Pages or {"general"}
            local objects={window:AddTab({Text=definition.Name,Pages=pages,
                Icon=definition.Icon and definition.Icon:match("^rbxassetid://") and definition.Icon or nil})}
            local tab={Pages={},Current=nil,Native=objects[1]}
            local tabInfo=objects[1] and objects[1].PlexTabOwner
            local category=categories[definition.Category] or categories.System
            if tabInfo then
                local pageFrame=tabInfo.Items.MainPage.Instance
                own(pageFrame:GetPropertyChangedSignal("Visible"):Connect(function()
                    if pageFrame.Visible and bridge.OnTabChanged then bridge.OnTabChanged(definition.Name) end
                end))
                category.Count+=1
                local button=tabInfo.Items.Button.Instance
                button.Parent=category.Children.Instance
                button.Size=UDim2.new(1,0,0,32)
                button.LayoutOrder=category.Count
                category:SetExpanded(category.Expanded)
            end
            function tab:Select()
                category:SetExpanded(true,true)
                if tabInfo then tabInfo.OpenPage() end
                if self.OnSelect then self.OnSelect() end
            end
            if tabInfo then
                tabInfo.Items.Button:OnClick(function() if tab.OnSelect then tab.OnSelect() end end)
            end
            for index,name in ipairs(pages) do
                local page=objects[index]
                page.PlexLayoutKey=definition.Name.."|"..name
                local sub={Tab=tab,Name=name,Page=page,Active=index==1}
                function sub:Section(d)return section(self.Page,d)end
                function sub:SetVisual(active)self.Active=active end
                function sub:Hide()self.Page.Items.Page.Instance.Visible=false end
                function sub:Show()self.Page.OpenPage();self.Active=true;self.Tab.Current=self end
                function sub:SnapVisible()
                    self.Page.OpenPage()
                    self.Page.Items.Page.Instance.Visible=true
                    self.Active=true
                end
                tab.Pages[name]=sub
                if index==1 then tab.Current=sub end
            end
            function tab:SubTab(d)return assert(self.Pages[d.Name],"Unknown Aether page: "..tostring(d.Name))end
            return tab
        end
        activeWindow=result
        result:SetOpen(false)
        return result
    end
    function bridge:AnimateUI(root,showing,callback,position)
        return native:AnimateVisibility(root,showing,callback,position)
    end
    function bridge:SetGameMode(mode)
        local labels={Normal="Matchmaking",Ranked="Ranked",Lobby="Lobby",["Private server"]="Private Server"}
        local subtitle=activeWindow and activeWindow.Native.Items.Subtitle
        if subtitle then subtitle.Instance.Text="Rivals | "..(labels[mode] or "Detecting") end
    end
    function bridge:SetAccent(color)
        native:Refresh("Accent",color);self.Theme.Accent=color
    end
    function bridge:SetTheme(name) if name=="Default" then self:SetAccent(theme.Accent) end end
    function bridge:SetThemeColor(name,color)
        local aliases={Background="Background",Section="SectionBackground",Element="ElementBackground",
            Text="TextColor",DimText="Unselected",Accent="Accent",Light="Inline",Line="ElementOutline"}
        if aliases[name] then native:Refresh(aliases[name],color);self.Theme[name]=color end
    end
    function bridge:Notification(def)return native:Notify({Text=def.Description or def.Name,Lifetime=def.Duration})end
    function bridge:Unload()
        if activeWindow then
            for _,category in pairs(activeWindow.SidebarCategories) do category:StopAnimation() end
        end
        if activeWindow then activeWindow:SetOpen(false) else releaseMouse() end
        for _,connection in ipairs(connections) do connection:Disconnect() end
        table.clear(bindings);table.clear(cardsByPage);native:Unload()
    end
    own(UIS.InputChanged:Connect(function(input)
        local drag=native.PlexDrag
        if drag and (input.UserInputType==Enum.UserInputType.MouseMovement or input==drag.Input) then drag.Move(input) end
    end))
    own(UIS.InputEnded:Connect(function(input)
        local drag=native.PlexDrag
        if drag and (input==drag.Input or input.UserInputType==Enum.UserInputType.MouseButton1) then
            native.PlexDrag=nil;if drag.Finish then drag.Finish(input) end
        end
        local selected=input.UserInputType==Enum.UserInputType.Keyboard and input.KeyCode or input.UserInputType
        for picker in pairs(bindings[selected] or {}) do if picker.Mode=="Hold" then picker.Set(false) end end
    end))
    own(UIS.InputBegan:Connect(function(input,processed)
        if native.PlexActiveKeyCapture or processed or UIS:GetFocusedTextBox() then return end
        local selected=input.UserInputType==Enum.UserInputType.Keyboard and input.KeyCode or input.UserInputType
        if activeWindow and selected==bridge.MenuKeybind then activeWindow:SetOpen(not activeWindow.IsOpen) end
        for picker in pairs(bindings[selected] or {}) do
            if not picker.Binding then
                if picker.Mode=="Toggle" then picker.Set(not picker.Active)
                elseif picker.Mode=="Hold" then picker.Set(true) end
            end
        end
    end))
    return bridge
end

return createAetherBridge
