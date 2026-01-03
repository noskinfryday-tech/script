local plr, char, mouse, human, torso
repeat wait(); plr = game.Players.LocalPlayer until plr
repeat wait(); mouse = plr:GetMouse() until mouse
local input = game:GetService("UserInputService")

local ui_toggle_fly
local flying = false
local flyspeed = 65
local aimbot = false
local aimbottarget

--[[
--
-- Character
--
--]]

do
    function UpdateCharacter ()
        char = plr.Character
        human = char:WaitForChild("Humanoid")
        torso = human.Torso
    end
    repeat wait() until plr.Character
    UpdateCharacter()
    plr.CharacterAdded:Connect(UpdateCharacter)
    plr.CharacterRemoving:Connect(function()
        ui_toggle_fly:Set(false)
    end)
end

--[[
--
-- Properties
--
--]]

local SetProperty
local RestoreProperty
do
    --
    -- Instance
    -- 
    
    local InstanceHasProperty
    local GetCustomInstanceProperty
    local SetCustomInstanceProperty
    do
        local customprops = {}
        
        -- why is there no function for this, roblox?
        InstanceHasProperty = function (obj, prop)
            return pcall(function() return obj[prop] end) 
        end
        
        GetCustomInstanceProperty = function (obj, key)
            customprops[obj] = customprops[obj] or {}
            return customprops[obj][key]
        end
        
        SetCustomInstanceProperty = function (obj, key, value)
            customprops[obj] = customprops[obj] or {}
            customprops[obj][key] = value
        end
    end
    
    --
    -- Properties
    --
    
    function Get (obj, prop)
        if type(obj) == 'table' then
            return rawget(obj, prop)
        elseif typeof(obj) == 'Instance' then
            if InstanceHasProperty(obj, prop) then
                return obj[prop]
            end
            return GetCustomInstanceProperty(obj, prop)
        end
        error(typeof(obj))
    end
    
    function Set (obj, prop, value)
        if type(obj) == 'table' then
            rawset(obj, prop, value) 
        elseif typeof(obj) == 'Instance' then
            if InstanceHasProperty(obj, prop) then
                obj[prop] = value
            else
                SetCustomInstanceProperty(obj, prop, value)
            end
        else
            error(typeof(obj))
        end
    end
    
    local GetCached
    local SetCached
    do
        function CachedProperty (prop)
            return 'epic_cached_' .. prop
        end
        GetCached = function(obj, prop)        return Get(obj, CachedProperty(prop))        end
        SetCached = function(obj, prop, value)        Set(obj, CachedProperty(prop), value) end
    end
    
    RestoreProperty = function (obj, prop)
        local cached = GetCached(obj, prop)
        if cached then
            Set(obj, prop, cached)
            SetCached(obj, prop, nil)
        end
    end
    
    SetProperty = function (obj, prop, value)
        if Get(obj, prop) then
            if not GetCached(obj, prop) then
                SetCached(obj, prop, Get(obj, prop))
            end
            Set(obj, prop, value)
        end
    end
end

--[[
--
-- Aimbot
--
--]]

game:GetService("RunService").RenderStepped:Connect(function()
    if aimbot then
        local cam = game:GetService("Workspace").CurrentCamera
        if not aimbottarget then
            local closest
            local mpos = Vector2.new(mouse.X, mouse.Y)
            for _,p in pairs(game:GetService("Players"):GetChildren()) do
                if p ~= plr and p.Character then
                    local t = p.Character.Head
                    local scrpos, onscr = cam:WorldToViewportPoint(t.Position)
                    scrpos = Vector2.new(scrpos.X, scrpos.Y)
                    if onscr and (closest==nil or (scrpos-mpos).Magnitude < (closest-mpos).Magnitude) then
                        closest = scrpos
                        aimbottarget = t
                    end
                end
            end
        end
        if aimbottarget then
            cam.CFrame = CFrame.new(cam.CFrame.Position, aimbottarget.Position)
        end
    else
        aimbottarget = nil 
    end
end)

--[[
--
-- UI
--
--]]

local pepsi = loadstring(game:GetObjects("rbxassetid://131114267717150")[1].Source)():CreateWindow({
    Name = "Tweeks Arsenal Private",
    Themeable = {
        Info = "https://discord.gg/8WrXTw9N8P"
    }
})
local general = pepsi:CreateTab({ Name="Arsenal" })

--[[
--
-- EPIC
--
--]]

do
    local epic = general:CreateSection({ Name="Aim Options" })
    
    function SetAllBasepartProperties (prop, value, ifobjfunc)
        for _,v in pairs(game.Workspace:GetDescendants()) do
            if v:IsA("BasePart") and (ifobjfunc==nil or ifobjfunc(v)) then
                SetProperty(v, prop, value)
            end
        end
    end
    
    function RestoreAllBasepartProperties (prop)
        for _,v in pairs(game.Workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                RestoreProperty(v, prop)
            end
        end
    end
    
    epic:AddToggle({ Name="Aimlock", Key=Enum.KeyCode.T, Value=false, Callback=function(yes)
        aimbot = yes
    end})
end

--[[
--
-- FLY
--
--]]

do
    local useplatformstand = true
    local left, right, up, down, frwd, back, x2, x4
    
    function Fly ()
        local bg = Instance.new("BodyGyro", torso)
        bg.P = 9e4
        bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        local bv = Instance.new("BodyVelocity", torso)
        bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
        
        if useplatformstand then human.PlatformStand = true end
        
        while flying do
            local camframe = game.Workspace.CurrentCamera.CoordinateFrame
            bg.cframe = camframe
            bv.velocity = Vector3.zero
            local markiplier = (input:IsKeyDown(x4:Get()) and 4) or (input:IsKeyDown(x2:Get()) and 2) or 1
            if input:IsKeyDown(frwd:Get())  then bv.velocity += flyspeed * markiplier * camframe.LookVector end
            if input:IsKeyDown(left:Get())  then bv.velocity += flyspeed * markiplier * camframe.RightVector * -1 end
            if input:IsKeyDown(back:Get())  then bv.velocity += flyspeed * markiplier * camframe.LookVector * -1 end
            if input:IsKeyDown(right:Get()) then bv.velocity += flyspeed * markiplier * camframe.RightVector end
            if input:IsKeyDown(up:Get())    then bv.velocity += flyspeed * markiplier * Vector3.new(0,1,0) end
            if input:IsKeyDown(down:Get())  then bv.velocity += flyspeed * markiplier * Vector3.new(0,-1,0) end
            wait()
        end
        
        bg:Destroy()
        bv:Destroy()
        if useplatformstand then human.PlatformStand = false end
    end
    
    local fly = general:CreateSection({ Name="Fly" })
    
    ui_toggle_fly = fly:AddToggle({ Name="Fly", Key=Enum.KeyCode.U, Callback=function(yes)
        flying = yes
        if yes then Fly() end
    end, UnloadFunc = function()
        flying = false
    end})
    
    fly:AddSlider({ Name="Fly Speed", Value=flyspeed, Min=1, Max=5000, Callback=function(v)
        flyspeed = v
    end})
    
    fly:AddToggle({ Name="Use PlatformStand", Value=useplatformstand, Callback=function(yes)
        useplatformstand = yes
    end})
    
    frwd  = fly:AddKeybind({ Name="forwards", Value=Enum.KeyCode.W })
    back  = fly:AddKeybind({ Name="backwards", Value=Enum.KeyCode.S })
    left  = fly:AddKeybind({ Name="left",  Value=Enum.KeyCode.A })
    right = fly:AddKeybind({ Name="right", Value=Enum.KeyCode.D })
    up    = fly:AddKeybind({ Name="up",    Value=Enum.KeyCode.Space })
    down  = fly:AddKeybind({ Name="down",  Value=Enum.KeyCode.LeftShift })
    x2    = fly:AddKeybind({ Name="2x speed (hold)", Value=Enum.KeyCode.LeftControl })
    x4    = fly:AddKeybind({ Name="4x speed (hold)", Value=Enum.KeyCode.LeftAlt })
end

--[[
--
-- JAILBREAK
--
--]]

do
    local jb = pepsi:CreateTab({ Name="ESP" })
    local g = jb:CreateSection({ Name="Visuals" })
    
    function SetGCProperties (prop, value)
        for _,v in pairs(getgc(true)) do
            if type(v) == 'table' then
                SetProperty(v, prop, value)
            end
        end
    end
    
    function RestoreGCProperties (prop)
        for _,v in pairs(getgc(true)) do
            if type(v) == 'table' then
                RestoreProperty(v, prop)
            end
        end
    end
    
    g:AddToggle({ Name="X toggle ESP", Key=true, Callback=function(yes)
        if yes then
            SetGCProperties("BulletSpread", 0)
        else
            RestoreGCProperties("BulletSpread")
        end
    end})
end

local function API_Check()
    if Drawing == nil then
        return "No"
    else
        return "Yes"
    end
end

local Find_Required = API_Check()

if Find_Required == "No" then
    game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = "Tweeks Loader";
        Text = "ESP script could not be loaded because your exploit is unsupported.";
        Duration = math.huge;
        Button1 = "OK"
    })

    return
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local Typing = false

_G.SendNotifications = true   -- If set to true then the script would notify you frequently on any changes applied and when loaded / errored. (If a game can detect this, it is recommended to set it to false)
_G.DefaultSettings = false   -- If set to true then the ESP script would run with default settings regardless of any changes you made.

_G.TeamCheck = false   -- If set to true then the script would create ESP only for the enemy team members.

_G.ESPVisible = true   -- If set to true then the ESP will be visible and vice versa.
_G.TextColor = Color3.fromRGB(102, 204, 0)   -- The color that the boxes would appear as.
_G.TextSize = 14   -- The size of the text.
_G.Center = true   -- If set to true then the script would be located at the center of the label.
_G.Outline = true   -- If set to true then the text would have an outline.
_G.OutlineColor = Color3.fromRGB(0, 0, 0)   -- The outline color of the text.
_G.TextTransparency = 0.7   -- The transparency of the text.
_G.TextFont = Drawing.Fonts.UI   -- The font of the text. (UI, System, Plex, Monospace) 

_G.DisableKey = Enum.KeyCode.X   -- The key that disables / enables the ESP.

local function CreateESP()
    for _, v in next, Players:GetPlayers() do
        if v.Name ~= Players.LocalPlayer.Name then
            local ESP = Drawing.new("Text")

            RunService.RenderStepped:Connect(function()
                if workspace:FindFirstChild(v.Name) ~= nil and workspace[v.Name]:FindFirstChild("HumanoidRootPart") ~= nil then
                    local Vector, OnScreen = Camera:WorldToViewportPoint(workspace[v.Name]:WaitForChild("Head", math.huge).Position)

                    ESP.Size = _G.TextSize
                    ESP.Center = _G.Center
                    ESP.Outline = _G.Outline
                    ESP.OutlineColor = _G.OutlineColor
                    ESP.Color = _G.TextColor
                    ESP.Transparency = _G.TextTransparency
                    ESP.Font = _G.TextFont

                    if OnScreen == true then
                        local Part1 = workspace:WaitForChild(v.Name, math.huge):WaitForChild("HumanoidRootPart", math.huge).Position
                        local Part2 = workspace:WaitForChild(Players.LocalPlayer.Name, math.huge):WaitForChild("HumanoidRootPart", math.huge).Position or 0
                        local Dist = (Part1 - Part2).Magnitude
                        ESP.Position = Vector2.new(Vector.X, Vector.Y - 25)
                        ESP.Text = ("("..tostring(math.floor(tonumber(Dist)))..") "..v.Name.." ["..workspace[v.Name].Humanoid.Health.."]")
                        if _G.TeamCheck == true then 
                            if Players.LocalPlayer.Team ~= v.Team then
                                ESP.Visible = _G.ESPVisible
                            else
                                ESP.Visible = true
                            end
                        else
                            ESP.Visible = _G.ESPVisible
                        end
                    else
                        ESP.Visible = false
                    end
                else
                    ESP.Visible = false
                end
            end)

            Players.PlayerRemoving:Connect(function()
                ESP.Visible = false
            end)
        end
    end

    Players.PlayerAdded:Connect(function(Player)
        Player.CharacterAdded:Connect(function(v)
            if v.Name ~= Players.LocalPlayer.Name then 
                local ESP = Drawing.new("Text")
    
                RunService.RenderStepped:Connect(function()
                    if workspace:FindFirstChild(v.Name) ~= nil and workspace[v.Name]:FindFirstChild("HumanoidRootPart") ~= nil then
                        local Vector, OnScreen = Camera:WorldToViewportPoint(workspace[v.Name]:WaitForChild("Head", math.huge).Position)
    
                        ESP.Size = _G.TextSize
                        ESP.Center = _G.Center
                        ESP.Outline = _G.Outline
                        ESP.OutlineColor = _G.OutlineColor
                        ESP.Color = _G.TextColor
                        ESP.Transparency = _G.TextTransparency
    
                        if OnScreen == true then
                            local Part1 = workspace:WaitForChild(v.Name, math.huge):WaitForChild("HumanoidRootPart", math.huge).Position
                        local Part2 = workspace:WaitForChild(Players.LocalPlayer.Name, math.huge):WaitForChild("HumanoidRootPart", math.huge).Position or 0
                            local Dist = (Part1 - Part2).Magnitude
                            ESP.Position = Vector2.new(Vector.X, Vector.Y - 25)
                            ESP.Text = ("("..tostring(math.floor(tonumber(Dist)))..") "..v.Name.." ["..workspace[v.Name].Humanoid.Health.."]")
                            if _G.TeamCheck == true then 
                                if Players.LocalPlayer.Team ~= Player.Team then
                                    ESP.Visible = _G.ESPVisible
                                else
                                    ESP.Visible = false
                                end
                            else
                                ESP.Visible = _G.ESPVisible
                            end
                        else
                            ESP.Visible = false
                        end
                    else
                        ESP.Visible = false
                    end
                end)
    
                Players.PlayerRemoving:Connect(function()
                    ESP.Visible = false
                end)
            end
        end)
    end)
end

if _G.DefaultSettings == true then
    _G.TeamCheck = false
    _G.ESPVisible = true
    _G.TextColor = Color3.fromRGB(40, 90, 255)
    _G.TextSize = 14
    _G.Center = true
    _G.Outline = false
    _G.OutlineColor = Color3.fromRGB(0, 0, 0)
    _G.DisableKey = Enum.KeyCode.C
    _G.TextTransparency = 0.75
end

UserInputService.TextBoxFocused:Connect(function()
    Typing = true
end)

UserInputService.TextBoxFocusReleased:Connect(function()
    Typing = false
end)

UserInputService.InputBegan:Connect(function(Input)
    if Input.KeyCode == _G.DisableKey and Typing == false then
        _G.ESPVisible = not _G.ESPVisible
        
        if _G.SendNotifications == true then
            game:GetService("StarterGui"):SetCore("SendNotification",{
                Title = "Tweeks Developer";
                Text = "The ESP's visibility is now set to "..tostring(_G.ESPVisible)..".";
                Duration = 3;
            })
        end
    end
end)

local Success, Errored = pcall(function()
    CreateESP()
end)

if Success and not Errored then
    if _G.SendNotifications == true then
        game:GetService("StarterGui"):SetCore("SendNotification",{
            Title = "Tweeks Esp";
            Text = "ESP is now Activated.";
            Duration = 3;
        })
    end
elseif Errored and not Success then
    if _G.SendNotifications == true then
        game:GetService("StarterGui"):SetCore("SendNotification",{
            Title = "Tweeks Esp";
            Text = "ESP script has errored while loading, please check the developer console! (F9)";
            Duration = 3;
        })
    end
    TestService:Message("The ESP script has errored, please notify Exunys with the following information :")
    warn(Errored)
    print("!! IF THE ERROR IS A FALSE POSITIVE (says that a player cannot be found) THEN DO NOT BOTHER !!")
end
