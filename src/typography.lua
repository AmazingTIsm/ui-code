-- Shared, event-driven typography for Plex-owned GUI trees only.
return function()
    local roles={"Window title","Subtitle","Categories","Tabs","Card titles","Labels","Values","Buttons","Descriptions","Overlay titles","Overlay text"}
    local fonts={"Theme default","Gotham","GothamBold","SourceSans","SourceSansBold","Code","Roboto","RobotoMono","Arial","ArialBold","Ubuntu"}
    local state,entries,connections={},{},{}
    local alive=true
    local manager={Roles=roles}
    for _,role in ipairs(roles)do state[role]={Font="Theme default",Size=0,CustomColor=false,Color=Color3.new(1,1,1),Text=""}end
    local function classify(object)
        local explicit=object.Name:match('^PlexRole_(.+)$')
        if state[explicit] then return explicit end
        if object.Name=="CategoryToggle"then return "Categories"end
        if object.Name=="PlexBrand"then return "Window title"end
        local parent=object.Parent
        while parent do
            if parent.Name=="PlexRole_Buttons"then return "Buttons"end
            local name=parent.Name:lower()
            if name:find("watermark",1,true)then return "Overlay text"end
            if name:find("activefeatures",1,true)or name:find("activehud",1,true)or name:find("keybind",1,true)or name:find("previewpanel",1,true)then
                return (object.Name=="Title"or object.Name=="Mode"or(object.Parent and object.Parent.Name=="Header"))and "Overlay titles"or "Overlay text"
            end
            if parent:IsA("ScreenGui")then break end
            parent=parent.Parent
        end
        if object:IsA("TextBox")then return "Values"end
        if object:IsA("TextButton")then return "Buttons"end
        return "Labels"
    end
    local function apply(object,entry)
        if not alive or entry.Writing then return end
        local choice=state[entry.Role]
        entry.Writing=true
        local values={FontFace=choice.Font~="Theme default"and Font.fromEnum(Enum.Font[choice.Font])or entry.Native.FontFace,
            TextSize=choice.Size>0 and choice.Size or entry.Native.TextSize,
            TextColor3=choice.CustomColor and choice.Color or entry.Native.TextColor3,
            Text=(entry.Role=="Window title"or entry.Role=="Subtitle")and(choice.Text~=""and choice.Text or entry.Native.Text)or nil}
        for property,value in pairs(values)do
            entry.Applied[property]=value
            if object[property]~=value then object[property]=value end
        end
        entry.Writing=false
    end
    function manager:Track(object)
        if not alive or entries[object]or not(object:IsA("TextLabel")or object:IsA("TextButton")or object:IsA("TextBox"))then return end
        local entry={Role=classify(object),Native={},Applied={},Connections={}}
        entries[object]=entry
        local properties={"FontFace","TextSize","TextColor3"}
        if entry.Role=="Window title"or entry.Role=="Subtitle"then properties[#properties+1]="Text"end
        for _,property in ipairs(properties)do
            entry.Native[property]=object[property]
            entry.Connections[#entry.Connections+1]=object:GetPropertyChangedSignal(property):Connect(function()
                if not alive or entry.Writing or object[property]==entry.Applied[property]then return end
                entry.Native[property]=object[property]
                local choice=state[entry.Role]
                if choice.Font=="Theme default"and choice.Size==0 and not choice.CustomColor and choice.Text==""then return end
                apply(object,entry)
            end)
        end
        entry.Connections[#entry.Connections+1]=object.Destroying:Connect(function()
            for _,c in ipairs(entry.Connections)do c:Disconnect()end
            entries[object]=nil
        end)
        apply(object,entry)
    end
    local watched={}
    function manager:Watch(root)
        if not root or watched[root]then return end
        watched[root]=true
        for _,object in ipairs(root:GetDescendants())do self:Track(object)end
        connections[#connections+1]=root.DescendantAdded:Connect(function(object)
            if not(object:IsA("TextLabel")or object:IsA("TextButton")or object:IsA("TextBox"))then return end
            task.defer(function()if alive and object.Parent then self:Track(object)end end)
        end)
    end
    function manager:Set(role,key,value)
        local choice=assert(state[role],"Unknown text role")
        if key=="Font"then assert(table.find(fonts,value),"Unknown font")
        elseif key=="Size"then value=math.clamp(tonumber(value)or 0,0,32)
        elseif key=="Text"then assert(role=="Window title"or role=="Subtitle");value=tostring(value or "")end
        choice[key]=value
        for object,entry in pairs(entries)do if entry.Role==role then apply(object,entry)end end
    end
    function manager:AddSettings(tab,defaultColor)
        local left=tab:AddLeftGroupbox("Text fonts and sizes")
        local right=tab:AddRightGroupbox("Text colors and titles")
        left:AddLabel("Theme default / size 0 keeps normal styling.")
        right:AddInput("Typography_TitleText",{Text="Window title",Default="",Placeholder="Blank uses normal title",Finished=false,
            Callback=function(value)self:Set("Window title","Text",value)end})
        right:AddInput("Typography_SubtitleText",{Text="Subtitle",Default="",Placeholder="Blank uses game / mode subtitle",Finished=false,
            Callback=function(value)self:Set("Subtitle","Text",value)end})
        for _,role in ipairs(roles)do
            local id="Typography_"..role:gsub("%W","_")
            left:AddDropdown(id.."_Font",{Text=role.." font",Values=fonts,Default="Theme default",Callback=function(value)self:Set(role,"Font",value)end})
            left:AddSlider(id.."_Size",{Text=role.." size",Min=0,Max=32,Default=0,Rounding=0,Suffix="px",Callback=function(value)self:Set(role,"Size",value)end})
            state[role].Color=defaultColor
            right:AddToggle(id.."_CustomColor",{Text=role.." custom color",Default=false,Callback=function(value)self:Set(role,"CustomColor",value)end})
                :AddColorPicker(id.."_Color",{Title=role.." color",Default=defaultColor,Callback=function(value)self:Set(role,"Color",value)end})
        end
    end
    function manager:Destroy()
        alive=false
        for _,c in ipairs(connections)do c:Disconnect()end
        for object,entry in pairs(entries)do
            for _,c in ipairs(entry.Connections)do c:Disconnect()end
            pcall(function()for property,value in pairs(entry.Native)do if object[property]==entry.Applied[property]then object[property]=value end end end)
        end
        table.clear(entries)
    end
    return manager
end
