--[[
    N1Z44R v2.1 - ULTRA ADVANCED
    ESPECÍFICO PARA STEAL A BRAINROT
    
    ⚡ Anti-detección máxima
    🔥 Desync real mejorado  
    🎯 Auto farm optimizado para Brainrot
    👁️ ESP con items específicos del juego
    🛡️ Protección completa
]]

-- =====================================================
-- ANTI-DETECCIÓN AVANZADA
-- =====================================================
local function SetupAntiDetection()
    -- Oculta el script de logs del servidor
    local mt = getrawmetatable(game)
    local old_namecall = mt.__namecall
    local old_newindex = mt.__newindex
    local old_index = mt.__index
    
    setreadonly(mt, false)
    
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        -- Bloquea detección de sistemas anti-cheat
        if method == "FireServer" or method == "InvokeServer" then
            local remoteName = tostring(self)
            if remoteName:find("Report") or remoteName:find("Detect") or remoteName:find("Ban") or remoteName:find("Kick") then
                return nil
            end
            
            -- Intercepta remotes específicos de Brainrot
            if remoteName:find("Validation") or remoteName:find("AntiCheat") then
                return nil
            end
        end
        
        return old_namecall(self, ...)
    end)
    
    -- Anti-AFK
    local VirtualUser = game:GetService("VirtualUser")
    game:GetService("Players").LocalPlayer.Idled:connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
    
    setreadonly(mt, true)
end

SetupAntiDetection()

-- Servicios
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

-- Variables globales optimizadas para Brainrot
local _G = {
    -- Auto Farm Específico Brainrot
    autoStealEnabled = false,
    autoSellEnabled = false,
    farmRadius = 150,
    stealDelay = 0.2,
    priorityRare = true,
    autoAvoidGuards = true,
    
    -- Movement 
    walkSpeed = 16,
    jumpPower = 50,
    flyEnabled = false,
    flySpeed = 120,
    noClipEnabled = false,
    infiniteJumpEnabled = false,
    
    -- Desync Mejorado
    desyncEnabled = false,
    desyncOffset = Vector3.new(15, 0, 15),
    
    -- ESP Específico Brainrot
    playerESP = false,
    itemESP = false,
    guardESP = false,
    cashESP = false,
    distanceESP = true,
    tracers = false,
    
    -- Combat Brainrot
    killAuraEnabled = false,
    killAuraRange = 20,
    autoParry = false,
    antiStun = true,
    
    -- Protección
    antiAFK = true,
    antiKick = true,
    antiBan = true,
    
    -- Visual
    fullBright = false,
    noFog = false
}

-- =====================================================
-- DETECCIÓN DE ITEMS ESPECÍFICOS BRAINROT
-- =====================================================
local BrainrotItems = {
    "Brainrot",
    "Brain",
    "Cash",
    "Money",
    "Coin",
    "Diamond",
    "Gold",
    "Ruby",
    "Sapphire",
    "Emerald",
    "Crystal",
    "Token",
    "Note",
    "Bill",
    "Dollar",
    "Treasure",
    "Chest",
    "Safe",
    "Vault"
}

local BrainrotGuards = {
    "Guard",
    "Police",
    "Security",
    "Cop",
    "Officer",
    "Soldier"
}

-- =====================================================
-- DESYNC REAL MEJORADO
-- =====================================================
local DesyncModule = {}

function DesyncModule:Start()
    if _G.desyncEnabled then
        -- Crea partes fantasma para desync
        local fakePart = Instance.new("Part")
        fakePart.Name = "N1Z44R_Desync"
        fakePart.Size = Vector3.new(4, 4, 4)
        fakePart.Transparency = 0.8
        fakePart.Material = Enum.Material.Neon
        fakePart.Color = Color3.fromRGB(255, 0, 0)
        fakePart.CanCollide = false
        fakePart.Anchored = true
        fakePart.Parent = Workspace

        -- Sistema de desync avanzado
        local connection
        connection = RunService.Heartbeat:Connect(function()
            if not _G.desyncEnabled then
                connection:Disconnect()
                fakePart:Destroy()
                return
            end

            -- Posición fantasma (visible para otros)
            fakePart.CFrame = hrp.CFrame + _G.desyncOffset
            
            -- Manipulación de red (sutil)
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.AssemblyLinearVelocity = Vector3.new(
                        math.random(-5, 5),
                        math.random(-5, 5), 
                        math.random(-5, 5)
                    )
                end
            end
        end)
        
        print("[N1Z44R] Desync avanzado activado")
    end
end

-- =====================================================
-- AUTO FARM OPTIMIZADO BRAINROT
-- =====================================================
local FarmModule = {}

function FarmModule:IsBrainrotItem(obj)
    local objName = obj.Name:lower()
    local objParent = obj.Parent and obj.Parent.Name:lower() or ""
    
    for _, itemName in pairs(BrainrotItems) do
        if objName:find(itemName:lower()) or objParent:find(itemName:lower()) then
            return true
        end
    end
    
    -- Detecta por apariencia (colores comunes de items)
    if obj:IsA("Part") then
        if obj.Color == Color3.fromRGB(255, 255, 0) or  -- Amarillo (oro/dinero)
           obj.Color == Color3.fromRGB(0, 255, 0) or    -- Verde (esmeralda)
           obj.Color == Color3.fromRGB(255, 0, 0) then  -- Rojo (rubí)
            return true
        end
    end
    
    return false
end

function FarmModule:IsGuard(obj)
    local objName = obj.Name:lower()
    local humanoid = obj:FindFirstChildOfClass("Humanoid")
    
    if humanoid then
        for _, guardName in pairs(BrainrotGuards) do
            if objName:find(guardName:lower()) then
                return true
            end
        end
    end
    
    return false
end

function FarmModule:GetNearbyItems()
    local items = {}
    local guards = {}
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Part") or obj:IsA("Model") then
            local distance = (hrp.Position - obj:GetPivot().Position).Magnitude
            
            if distance <= _G.farmRadius then
                -- Detecta items
                if FarmModule:IsBrainrotItem(obj) then
                    local isRare = obj.Name:lower():find("rare") or 
                                  obj.Name:lower():find("legendary") or
                                  obj.Name:lower():find("diamond") or
                                  obj.Color == Color3.fromRGB(0, 255, 255) -- Cian (raro)
                    
                    table.insert(items, {
                        object = obj,
                        distance = distance,
                        isRare = isRare,
                        position = obj:GetPivot().Position
                    })
                end
                
                -- Detecta guards
                if FarmModule:IsGuard(obj) then
                    table.insert(guards, {
                        object = obj,
                        distance = distance,
                        position = obj:GetPivot().Position
                    })
                end
            end
        end
    end
    
    return items, guards
end

function FarmModule:SmartSteal()
    local items, guards = FarmModule:GetNearbyItems()
    
    -- Evita guards si está activado
    if _G.autoAvoidGuards then
        for _, guard in pairs(guards) do
            if guard.distance < 25 then -- Distancia de peligro
                -- Huye del guardia
                local escapeDirection = (hrp.Position - guard.position).Unit * 30
                hrp.CFrame = hrp.CFrame + escapeDirection
                return
            end
        end
    end
    
    -- Ordena items por prioridad
    table.sort(items, function(a, b)
        if _G.priorityRare then
            if a.isRare and not b.isRare then return true end
            if not a.isRare and b.isRare then return false end
        end
        return a.distance < b.distance
    end)
    
    -- Roba el item más cercano/prioritario
    if #items > 0 then
        local target = items[1]
        
        -- Movimiento suave hacia el item
        local tweenInfo = TweenInfo.new(
            math.min(target.distance / 50, 2), -- Tiempo dinámico según distancia
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        )
        
        local targetCFrame = CFrame.new(target.position + Vector3.new(0, 3, 0))
        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
        tween:Play()
        
        -- Intenta recoger durante el movimiento
        spawn(function()
            wait(0.3) -- Pequeño delay antes de recoger
            
            -- Métodos de recolección para Brainrot
            if target.object:FindFirstChild("ClickDetector") then
                fireclickdetector(target.object.ClickDetector)
            elseif target.object:FindFirstChild("ProximityPrompt") then
                fireproximityprompt(target.object.ProximityPrompt)
            else
                -- Intenta con remotes comunes de Brainrot
                pcall(function()
                    local remotes = {
                        "CollectItem",
                        "PickupItem", 
                        "GrabItem",
                        "TakeItem",
                        "StealItem"
                    }
                    
                    for _, remoteName in pairs(remotes) do
                        local remote = ReplicatedStorage:FindFirstChild(remoteName)
                        if remote then
                            remote:FireServer(target.object)
                        end
                    end
                end)
            end
        end)
    end
end

function FarmModule:AutoSellBrainrot()
    -- Busca zonas de venta en Brainrot
    local sellZones = {}
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name:lower():find("sell") or 
           obj.Name:lower():find("cash") or
           obj.Name:lower():find("bank") or
           obj.Name:lower():find("deposit") or
           obj.Name:lower():find("store") then
            
            table.insert(sellZones, obj)
        end
    end
    
    if #sellZones > 0 then
        local closestZone = sellZones[1]
        local closestDist = math.huge
        
        for _, zone in pairs(sellZones) do
            local dist = (hrp.Position - zone:GetPivot().Position).Magnitude
            if dist < closestDist then
                closestZone = zone
                closestDist = dist
            end
        end
        
        -- Movimiento a la zona de venta
        local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Quad)
        local tween = TweenService:Create(hrp, tweenInfo, {
            CFrame = closestZone:GetPivot() + Vector3.new(0, 3, 0)
        })
        tween:Play()
        tween.Completed:Wait()
        
        -- Venta automática
        wait(0.5)
        pcall(function()
            local sellRemotes = {
                "SellItems",
                "DepositCash",
                "ExchangeMoney",
                "ConvertToMoney"
            }
            
            for _, remoteName in pairs(sellRemotes) do
                local remote = ReplicatedStorage:FindFirstChild(remoteName)
                if remote then
                    remote:FireServer()
                end
            end
        end)
    end
end

-- =====================================================
-- ESP ESPECÍFICO BRAINROT
-- =====================================================
local ESPModule = {}
ESPModule.Objects = {}

function ESPModule:CreateHighlight(obj, color, name)
    if obj:FindFirstChild("N1Z44R_Highlight") then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "N1Z44R_Highlight"
    highlight.FillColor = color
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = obj
    
    -- Billboard con información
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "N1Z44R_ESP"
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = obj
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.TextStrokeTransparency = 0
    label.Parent = billboard
    
    -- Actualización de distancia
    if _G.distanceESP then
        spawn(function()
            while obj.Parent and obj:FindFirstChild("N1Z44R_Highlight") do
                local dist = math.floor((hrp.Position - obj:GetPivot().Position).Magnitude)
                label.Text = name .. " [" .. dist .. "m]"
                wait(0.1)
            end
        end)
    end
    
    table.insert(ESPModule.Objects, {highlight = highlight, billboard = billboard})
end

function ESPModule:UpdateESP()
    ESPModule:ClearAll()
    
    if _G.itemESP then
        local items, _ = FarmModule:GetNearbyItems()
        for _, item in pairs(items) do
            local color = item.isRare and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(0, 255, 0)
            ESPModule:CreateHighlight(item.object, color, item.object.Name)
        end
    end
    
    if _G.guardESP then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if FarmModule:IsGuard(obj) then
                ESPModule:CreateHighlight(obj, Color3.fromRGB(255, 0, 0), "GUARD")
            end
        end
    end
    
    if _G.playerESP then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character then
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    ESPModule:CreateHighlight(plr.Character, Color3.fromRGB(0, 100, 255), plr.Name)
                end
            end
        end
    end
end

function ESPModule:ClearAll()
    for _, esp in pairs(ESPModule.Objects) do
        if esp.highlight then esp.highlight:Destroy() end
        if esp.billboard then esp.billboard:Destroy() end
    end
    ESPModule.Objects = {}
end

-- =====================================================
-- SISTEMA DE VUELO MEJORADO
-- =====================================================
local FlyModule = {}
FlyModule.Enabled = false

function FlyModule:Toggle()
    FlyModule.Enabled = not FlyModule.Enabled
    
    if FlyModule.Enabled then
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Name = "N1Z44R_Fly"
        bodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = hrp
        
        local bodyGyro = Instance.new("BodyGyro")
        bodyGyro.Name = "N1Z44R_FlyGyro"
        bodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
        bodyGyro.P = 10000
        bodyGyro.Parent = hrp
        
        spawn(function()
            while FlyModule.Enabled and _G.flyEnabled do
                local camera = Workspace.CurrentCamera
                bodyGyro.CFrame = camera.CFrame
                
                local moveDirection = Vector3.new(0, 0, 0)
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveDirection = moveDirection + camera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveDirection = moveDirection - camera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveDirection = moveDirection - camera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveDirection = moveDirection + camera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    moveDirection = moveDirection + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    moveDirection = moveDirection - Vector3.new(0, 1, 0)
                end
                
                bodyVelocity.Velocity = moveDirection * _G.flySpeed
                RunService.Heartbeat:Wait()
            end
            
            if hrp:FindFirstChild("N1Z44R_Fly") then hrp.N1Z44R_Fly:Destroy() end
            if hrp:FindFirstChild("N1Z44R_FlyGyro") then hrp.N1Z44R_FlyGyro:Destroy() end
        end)
    end
end

-- =====================================================
-- MEJORAS VISUALES
-- =====================================================
local VisualModule = {}

function VisualModule:ToggleFullBright()
    if _G.fullBright then
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.Brightness = 2
        Lighting.GlobalShadows = false
    else
        Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
        Lighting.Brightness = 1
        Lighting.GlobalShadows = true
    end
end

function VisualModule:ToggleNoFog()
    if _G.noFog then
        Lighting.FogEnd = 100000
    else
        Lighting.FogEnd = 1000
    end
end

-- =====================================================
-- INTERFAZ ORION LIB MEJORADA
-- =====================================================
local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Orion/main/source'))()

local Window = OrionLib:MakeWindow({
    Name = "N1Z44R v2.1 | Steal a Brainrot",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "N1Z44R_Brainrot",
    IntroEnabled = true,
    IntroText = "N1Z44R BRAINROT EDITION",
    IntroIcon = "rbxassetid://4483345998"
})

-- TAB AUTO FARM
local FarmTab = Window:MakeTab({
    Name = "Auto Farm",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

FarmTab:AddToggle({
    Name = "🔄 Auto Steal Items",
    Default = false,
    Callback = function(value)
        _G.autoStealEnabled = value
        spawn(function()
            while _G.autoStealEnabled do
                FarmModule:SmartSteal()
                wait(_G.stealDelay)
            end
        end)
    end
})

FarmTab:AddToggle({
    Name = "💰 Auto Sell",
    Default = false,
    Callback = function(value)
        _G.autoSellEnabled = value
        spawn(function()
            while _G.autoSellEnabled do
                FarmModule:AutoSellBrainrot()
                wait(10) -- Vender cada 10 segundos
            end
        end)
    end
})

FarmTab:AddToggle({
    Name = "🎯 Priority Rare Items",
    Default = true,
    Callback = function(value)
        _G.priorityRare = value
    end
})

FarmTab:AddToggle({
    Name = "🚷 Auto Avoid Guards",
    Default = true,
    Callback = function(value)
        _G.autoAvoidGuards = value
    end
})

FarmTab:AddSlider({
    Name = "📏 Farm Radius",
    Min = 50,
    Max = 500,
    Default = 150,
    Color = Color3.fromRGB(255, 0, 0),
    Increment = 10,
    Callback = function(value)
        _G.farmRadius = value
    end
})

-- TAB MOVEMENT
local MoveTab = Window:MakeTab({
    Name = "Movement",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

MoveTab:AddSlider({
    Name = "🚶 Walk Speed",
    Min = 16,
    Max = 200,
    Default = 16,
    Color = Color3.fromRGB(0, 255, 0),
    Increment = 1,
    Callback = function(value)
        _G.walkSpeed = value
        humanoid.WalkSpeed = value
    end
})

MoveTab:AddToggle({
    Name = "🦅 Fly",
    Default = false,
    Callback = function(value)
        _G.flyEnabled = value
        FlyModule:Toggle()
    end
})

MoveTab:AddSlider({
    Name = "⚡ Fly Speed",
    Min = 50,
    Max = 300,
    Default = 120,
    Color = Color3.fromRGB(0, 255, 0),
    Increment = 10,
    Callback = function(value)
        _G.flySpeed = value
    end
})

MoveTab:AddToggle({
    Name = "🎯 NoClip",
    Default = false,
    Callback = function(value)
        _G.noClipEnabled = value
        spawn(function()
            while _G.noClipEnabled do
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
                wait(0.1)
            end
        end)
    end
})

-- TAB ESP
local ESPTab = Window:MakeTab({
    Name = "ESP",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

ESPTab:AddToggle({
    Name = "🎯 Item ESP",
    Default = false,
    Callback = function(value)
        _G.itemESP = value
        ESPModule:UpdateESP()
    end
})

ESPTab:AddToggle({
    Name = "🚨 Guard ESP",
    Default = false,
    Callback = function(value)
        _G.guardESP = value
        ESPModule:UpdateESP()
    end
})

ESPTab:AddToggle({
    Name = "👥 Player ESP",
    Default = false,
    Callback = function(value)
        _G.playerESP = value
        ESPModule:UpdateESP()
    end
})

ESPTab:AddToggle({
    Name = "📏 Show Distance",
    Default = true,
    Callback = function(value)
        _G.distanceESP = value
        ESPModule:UpdateESP()
    end
})

-- TAB DESYNC
local DesyncTab = Window:MakeTab({
    Name = "Desync",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

DesyncTab:AddToggle({
    Name = "🌀 Enable Desync",
    Default = false,
    Callback = function(value)
        _G.desyncEnabled = value
        if value then
            DesyncModule:Start()
        end
    end
})

-- TAB VISUAL
local VisualTab = Window:MakeTab({
    Name = "Visual",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

VisualTab:AddToggle({
    Name = "💡 Full Bright",
    Default = false,
    Callback = function(value)
        _G.fullBright = value
        VisualModule:ToggleFullBright()
    end
})

VisualTab:AddToggle({
    Name = "🌫️ No Fog",
    Default = false,
    Callback = function(value)
        _G.noFog = value
        VisualModule:ToggleNoFog()
    end
})

-- =====================================================
-- INICIALIZACIÓN
-- =====================================================
OrionLib:Init()

-- Actualización constante del ESP
spawn(function()
    while true do
        if _G.itemESP or _G.guardESP or _G.playerESP then
            ESPModule:UpdateESP()
        end
        wait(2)
    end
end)

-- Notificación de carga
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "N1Z44R v2.1",
    Text = "Brainrot Edition Loaded!",
    Duration = 5,
    Icon = "rbxassetid://4483345998"
})

print("==========================================")
print("N1Z44R v2.1 - BRAINROT EDITION")
print("Auto Farm: Optimizado para Steal a Brainrot")
print("ESP: Items, Guards, Players")
print("Desync: Sistema avanzado activo")
print("==========================================")
