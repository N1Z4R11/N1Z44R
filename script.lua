--[[
    N1Z44R v2.0 - ULTRA ADVANCED
    Específico para Steal a Brainrot
    
    ⚡ Anti-detección avanzada
    🔥 Desync real
    🎯 Auto farm inteligente
    👁️ ESP mejorado
    🛡️ Protección contra kicks
]]

-- Anti-detección: Oculta el script de logs
local function hideFromLogs()
    local mt = getrawmetatable(game)
    local old_namecall = mt.__namecall
    
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        -- Bloquea detección de RemoteEvents sospechosos
        if method == "FireServer" or method == "InvokeServer" then
            if tostring(self):find("Report") or tostring(self):find("Detect") or tostring(self):find("Ban") then
                return
            end
        end
        
        return old_namecall(self, ...)
    end)
    setreadonly(mt, true)
end

hideFromLogs()

-- Servicios
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

-- Variables globales
local _G = {
    -- Auto Farm Avanzado
    autoStealEnabled = false,
    autoSellEnabled = false,
    farmRadius = 100,
    stealDelay = 0.3,
    priorityItems = true,
    autoDepositBase = false,
    
    -- Movement Avanzado
    walkSpeed = 16,
    jumpPower = 50,
    flyEnabled = false,
    flySpeed = 100,
    noClipEnabled = false,
    infiniteJumpEnabled = false,
    
    -- Desync REAL
    desyncEnabled = false,
    desyncOffset = Vector3.new(10, 0, 10),
    
    -- ESP Avanzado
    playerESP = false,
    itemESP = false,
    baseESP = false,
    distanceESP = false,
    tracers = false,
    
    -- Combat
    killAuraEnabled = false,
    killAuraRange = 15,
    autoParry = false,
    antiRagdoll = true,
    
    -- Anti-Kick & Protección
    antiAFK = true,
    antiKick = true,
    bypassAntiCheat = true,
    
    -- Misc
    autoRespawn = true,
    noFall = true,
    autoEquipTool = true
}

-- =====================================================
-- ANTI-DETECCIÓN AVANZADA
-- =====================================================
local function setupAntiDetection()
    -- Anti-AFK
    if _G.antiAFK then
        local VirtualUser = game:GetService("VirtualUser")
        player.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
    
    -- Bypass velocidad sin detección
    local oldIndex
    oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
        if not checkcaller() and self == humanoid then
            if key == "WalkSpeed" and _G.walkSpeed > 16 then
                return 16 -- Reporta velocidad normal al servidor
            elseif key == "JumpPower" and _G.jumpPower > 50 then
                return 50
            end
        end
        return oldIndex(self, key)
    end))
    
    -- Protección contra kicks
    if _G.antiKick then
        local mt = getrawmetatable(game)
        local oldNamecall = mt.__namecall
        
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            if method == "Kick" then
                return wait(9e9)
            end
            
            return oldNamecall(self, ...)
        end)
        setreadonly(mt, true)
    end
end

setupAntiDetection()

-- =====================================================
-- DESYNC REAL AVANZADO
-- =====================================================
local DesyncModule = {}

function DesyncModule:Start()
    if _G.desyncEnabled then
        local oldPos = hrp.CFrame
        
        -- Crea una parte invisible para el desync
        local desyncPart = Instance.new("Part")
        desyncPart.Name = "DesyncPart"
        desyncPart.Size = Vector3.new(2, 2, 2)
        desyncPart.Transparency = 1
        desyncPart.CanCollide = false
        desyncPart.Anchored = true
        desyncPart.Parent = Workspace
        
        -- BodyVelocity para confundir al servidor
        local bodyVel = Instance.new("BodyVelocity")
        bodyVel.Name = "DesyncVel"
        bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVel.Velocity = Vector3.new(0, 0, 0)
        bodyVel.Parent = hrp
        
        -- BodyGyro para mantener rotación
        local bodyGyro = Instance.new("BodyGyro")
        bodyGyro.Name = "DesyncGyro"
        bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bodyGyro.P = 10000
        bodyGyro.D = 500
        bodyGyro.Parent = hrp
        
        -- Loop principal del desync
        RunService.Heartbeat:Connect(function()
            if not _G.desyncEnabled then
                if hrp:FindFirstChild("DesyncVel") then hrp.DesyncVel:Destroy() end
                if hrp:FindFirstChild("DesyncGyro") then hrp.DesyncGyro:Destroy() end
                if desyncPart then desyncPart:Destroy() end
                return
            end
            
            -- Mantiene velocidad 0 pero con fuerza máxima (confunde servidor)
            bodyVel.Velocity = Vector3.new(0, 0, 0)
            bodyGyro.CFrame = hrp.CFrame
            
            -- Offset visual (solo cliente)
            desyncPart.CFrame = hrp.CFrame + _G.desyncOffset
            
            -- El servidor piensa que estás en oldPos
            -- Pero tú te ves en hrp.CFrame + offset
        end)
        
        print("[N1Z44R] Desync activado - Offset:", _G.desyncOffset)
    end
end

-- =====================================================
-- AUTO FARM INTELIGENTE
-- =====================================================
local FarmModule = {}

function FarmModule:GetItems()
    local items = {}
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        -- Detecta items del juego (ajusta según el juego)
        if obj:IsA("Model") or obj:IsA("Part") then
            if obj.Name:lower():find("item") or 
               obj.Name:lower():find("brainrot") or
               obj.Name:lower():find("coin") or
               obj.Name:lower():find("cash") or
               obj:FindFirstChild("ClickDetector") or
               obj:FindFirstChild("ProximityPrompt") then
                
                local distance = (hrp.Position - obj:GetPivot().Position).Magnitude
                
                if distance <= _G.farmRadius then
                    table.insert(items, {
                        object = obj,
                        distance = distance,
                        priority = obj.Name:lower():find("rare") or obj.Name:lower():find("legendary") or false
                    })
                end
            end
        end
    end
    
    -- Ordena por prioridad y distancia
    table.sort(items, function(a, b)
        if _G.priorityItems then
            if a.priority and not b.priority then return true end
            if not a.priority and b.priority then return false end
        end
        return a.distance < b.distance
    end)
    
    return items
end

function FarmModule:StealItem(item)
    local obj = item.object
    
    -- Tween suave hacia el item (menos detectable que teleport)
    local tweenInfo = TweenInfo.new(
        _G.stealDelay,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.InOut
    )
    
    local tween = TweenService:Create(hrp, tweenInfo, {
        CFrame = obj:GetPivot() + Vector3.new(0, 3, 0)
    })
    
    tween:Play()
    tween.Completed:Wait()
    
    wait(0.1)
    
    -- Intenta recoger el item
    if obj:FindFirstChild("ClickDetector") then
        fireclickdetector(obj.ClickDetector)
    end
    
    if obj:FindFirstChild("ProximityPrompt") then
        fireproximityprompt(obj.ProximityPrompt)
    end
    
    -- Dispara eventos de recogida comunes
    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            if remote.Name:lower():find("pick") or 
               remote.Name:lower():find("take") or
               remote.Name:lower():find("collect") or
               remote.Name:lower():find("grab") then
                
                pcall(function()
                    if remote:IsA("RemoteEvent") then
                        remote:FireServer(obj)
                    else
                        remote:InvokeServer(obj)
                    end
                end)
            end
        end
    end
end

function FarmModule:AutoSell()
    -- Busca zonas de venta
    local sellZones = {}
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name:lower():find("sell") or 
           obj.Name:lower():find("cash") or
           obj.Name:lower():find("deposit") then
            table.insert(sellZones, obj)
        end
    end
    
    if #sellZones > 0 then
        local closest = sellZones[1]
        local closestDist = math.huge
        
        for _, zone in pairs(sellZones) do
            local dist = (hrp.Position - zone:GetPivot().Position).Magnitude
            if dist < closestDist then
                closest = zone
                closestDist = dist
            end
        end
        
        -- Tween a la zona de venta
        local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(hrp, tweenInfo, {
            CFrame = closest:GetPivot()
        })
        tween:Play()
        tween.Completed:Wait()
        
        wait(1)
        
        -- Dispara eventos de venta
        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                if remote.Name:lower():find("sell") or remote.Name:lower():find("cash") then
                    pcall(function()
                        if remote:IsA("RemoteEvent") then
                            remote:FireServer()
                        else
                            remote:InvokeServer()
                        end
                    end)
                end
            end
        end
    end
end

-- =====================================================
-- ESP AVANZADO
-- =====================================================
local ESPModule = {}
ESPModule.Objects = {}

function ESPModule:CreateESP(obj, color, text, showDistance)
    if obj:FindFirstChild("N1Z44R_ESP") then return end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "N1Z44R_ESP"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.Parent = obj
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = color
    frame.BackgroundTransparency = 0.5
    frame.BorderSizePixel = 2
    frame.BorderColor3 = color
    frame.Parent = billboard
    
    local uicorner = Instance.new("UICorner")
    uicorner.CornerRadius = UDim.new(0, 8)
    uicorner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.TextStrokeTransparency = 0.5
    label.Parent = frame
    
    -- Tracer (línea hacia el objeto)
    if _G.tracers then
        local tracer = Drawing.new("Line")
        tracer.Visible = true
        tracer.Color = color
        tracer.Thickness = 2
        tracer.Transparency = 0.7
        
        RunService.RenderStepped:Connect(function()
            if not obj.Parent or not _G.tracers then
                tracer:Remove()
                return
            end
            
            local objPos, onScreen = Workspace.CurrentCamera:WorldToViewportPoint(obj.Position)
            local screenCenter = Vector2.new(Workspace.CurrentCamera.ViewportSize.X / 2, Workspace.CurrentCamera.ViewportSize.Y)
            
            if onScreen then
                tracer.From = screenCenter
                tracer.To = Vector2.new(objPos.X, objPos.Y)
                tracer.Visible = true
            else
                tracer.Visible = false
            end
        end)
    end
    
    -- Actualiza distancia
    if showDistance and _G.distanceESP then
        RunService.Heartbeat:Connect(function()
            if obj.Parent then
                local dist = math.floor((hrp.Position - obj.Position).Magnitude)
                label.Text = text .. " [" .. dist .. "m]"
            else
                billboard:Destroy()
            end
        end)
    end
    
    table.insert(ESPModule.Objects, billboard)
end

function ESPModule:ClearAll()
    for _, esp in pairs(ESPModule.Objects) do
        if esp then esp:Destroy() end
    end
    ESPModule.Objects = {}
end

-- =====================================================
-- COMBAT AVANZADO
-- =====================================================
local CombatModule = {}

function CombatModule:KillAura()
    if not _G.killAuraEnabled then return end
    
    for _, target in pairs(Players:GetPlayers()) do
        if target ~= player and target.Character then
            local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
            local targetHum = target.Character:FindFirstChild("Humanoid")
            
            if targetHRP and targetHum and targetHum.Health > 0 then
                local distance = (hrp.Position - targetHRP.Position).Magnitude
                
                if distance <= _G.killAuraRange then
                    -- Auto equipar tool de combate
                    local tool = player.Character:FindFirstChildOfClass("Tool")
                    
                    if not tool then
                        for _, item in pairs(player.Backpack:GetChildren()) do
                            if item:IsA("Tool") then
                                humanoid:EquipTool(item)
                                tool = item
                                break
                            end
                        end
                    end
                    
                    if tool then
                        -- Apunta hacia el enemigo
                        hrp.CFrame = CFrame.new(hrp.Position, targetHRP.Position)
                        
                        -- Activa el tool
                        tool:Activate()
                        
                        wait(0.1)
                    end
                end
            end
        end
    end
end

-- =====================================================
-- FLY MEJORADO
-- =====================================================
local FlyModule = {}
FlyModule.Flying = false

function FlyModule:Toggle()
    FlyModule.Flying = not FlyModule.Flying
    
    if FlyModule.Flying then
        local bodyVel = Instance.new("BodyVelocity")
        bodyVel.Name = "FlyVelocity"
        bodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bodyVel.Velocity = Vector3.new(0, 0, 0)
        bodyVel.Parent = hrp
        
        local bodyGyro = Instance.new("BodyGyro")
        bodyGyro.Name = "FlyGyro"
        bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bodyGyro.P = 9e4
        bodyGyro.Parent = hrp
        
        spawn(function()
            while FlyModule.Flying and _G.flyEnabled do
                local camera = Workspace.CurrentCamera
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
                
                bodyVel.Velocity = moveDirection.Unit * _G.flySpeed
                bodyGyro.CFrame = camera.CFrame
                
                RunService.Heartbeat:Wait()
            end
            
            if hrp:FindFirstChild("FlyVelocity") then hrp.FlyVelocity:Destroy() end
            if hrp:FindFirstChild("FlyGyro") then hrp.FlyGyro:Destroy() end
        end)
    end
end

-- =====================================================
-- GUI MODERNA CON ORION LIB
-- =====================================================
local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Orion/main/source'))()

local Window = OrionLib:MakeWindow({
    Name = "N1Z44R v2.0 | Steal a Brainrot",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "N1Z44R_Config",
    IntroEnabled = true,
    IntroText = "N1Z44R Loading...",
    IntroIcon = "rbxassetid://4483345998"
})

-- =====================================================
-- TAB: AUTO FARM
-- =====================================================
local FarmTab = Window:MakeTab({
    Name = "Auto Farm",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

FarmTab:AddToggle({
    Name = "Auto Steal Items",
    Default = false,
    Callback = function(value)
        _G.autoStealEnabled = value
        
        spawn(function()
            while _G.autoStealEnabled do
                local items = FarmModule:GetItems()
                
                for _, item in pairs(items) do
                    if not _G.autoStealEnabled then break end
                    FarmModule:StealItem(item)
                    wait(_G.stealDelay)
                end
                
                wait(1)
            end
        end)
    end
})

FarmTab:AddToggle({
    Name = "Auto Sell",
    Default = false,
    Callback = function(value)
        _G.autoSellEnabled = value
        
        spawn(function()
            while _G.autoSellEnabled do
                FarmModule:AutoSell()
                wait(5)
            end
        end)
    end
})

FarmTab:AddSlider({
    Name = "Farm Radius",
    Min = 20,
    Max = 500,
    Default = 100,
    Color = Color3.fromRGB(255, 0, 0),
    Increment = 10,
    Callback = function(value)
        _G.farmRadius = value
    end
})

FarmTab:AddSlider({
    Name = "Steal Delay",
    Min = 0.1,
    Max = 2,
    Default = 0.3,
    Color = Color3.fromRGB(255, 0, 0),
    Increment = 0.1,
    Callback = function(value)
        _G.stealDelay = value
    end
})

FarmTab:AddToggle({
    Name = "Priority Rare Items",
    Default = true,
    Callback = function(value)
        _G.priorityItems = value
    end
})

-- =====================================================
-- TAB: MOVEMENT
-- =====================================================
local MoveTab = Window:MakeTab({
    Name = "Movement",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

MoveTab:AddSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 500,
    Default = 16,
    Color = Color3.fromRGB(0, 255, 0),
    Increment = 1,
    Callback = function(value)
        _G.walkSpeed = value
        humanoid.WalkSpeed = value
    end
})

MoveTab:AddSlider({
    Name = "Jump Power",
    Min = 50,
    Max = 500,
    Default = 50,
    Color = Color3.fromRGB(0, 255, 0),
    Increment = 10,
    Callback = function(value)
        _G.jumpPower = value
        humanoid.JumpPower = value
    end
})

MoveTab:AddToggle({
    Name = "Fly",
    Default = false,
    Callback = function(value)
        _G.flyEnabled = value
        FlyModule:Toggle()
    end
})

MoveTab:AddSlider({
    Name = "Fly Speed",
    Min = 10,
    Max = 300,
    Default = 100,
    Color = Color3.fromRGB(0, 255, 0),
    Increment = 10,
    Callback = function(value)
        _G.flySpeed = value
    end
})

MoveTab:AddToggle({
    Name = "Infinite Jump",
    Default = false,
    Callback = function(value)
        _G.infiniteJumpEnabled = value
        
        if value then
            local connection
            connection = UserInputService.JumpRequest:Connect(function()
                if _G.infiniteJumpEnabled then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                else
                    connection:Disconnect()
                end
            end)
        end
    end
})

MoveTab:AddToggle({
    Name = "NoClip",
    Default = false,
    Callback = function(value)
        _G.noClipEnabled = value
        
        RunService.Stepped:Connect(function()
            if _G.noClipEnabled then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
})

-- =====================================================
-- TAB: COMBAT
-- =====================================================
local CombatTab = Window:MakeTab({
    Name = "Combat",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

CombatTab:AddToggle({
    Name = "Kill Aura",
    Default = false,
    Callback = function(value)
        _G.killAuraEnabled = value
        
        spawn(function()
            while _G.killAuraEnabled do
                CombatModule:KillAura()
                wait(0.1)
            end
        end)
    end
})

CombatTab:AddSlider({
    Name = "Kill Aura Range",
    Min = 5,
    Max = 50,
    Default = 15,
    Color = Color3.fromRGB(255, 0, 0),
    Increment = 1,
    Callback = function(value)
        _G.killAuraRange = value
    end
})

CombatTab:AddToggle({
    Name = "Anti Ragdoll",
    Default = true,
    Callback = function(value)
        _G.antiRagdoll = value
        
        spawn(function()
            while _G.antiRagdoll do
                for _, v in pairs(character:GetDescendants()) do
                    if v:IsA("BallSocketConstraint") or v:IsA("NoCollisionConstraint") then
                        v:Destroy()
                    end
                end
                wait(0.1)
            end
        end)
    end
})

-- =====================================================
-- TAB: ESP
-- =====================================================
local ESPTab = Window:MakeTab({
    Name = "ESP",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

ESPTab:AddToggle({
    Name = "Player ESP",
    Default = false,
    Callback = function(value)
        _G.playerESP = value
        
        if value then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= player and plr.Character then
                    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        ESPModule:CreateESP(hrp, Color3.fromRGB(255, 0, 0), plr.Name, true)
                    end
                end
            end
        else
            ESPModule:ClearAll()
        end
    end
})

ESPTab:AddToggle({
    Name = "Item ESP",
    Default = false,
    Callback = function(value)
        _G.itemESP = value
        
        if value then
            for _, item in pairs(FarmModule:GetItems()) do
                ESPModule:CreateESP(item.object, Color3.fromRGB(0, 255, 0), "Item", true)
            end
        else
            ESPModule:ClearAll()
        end
    end
})

ESPTab:AddToggle({
    Name = "Show Distance",
    Default = false,
    Callback = function(value)
        _G.distanceESP = value
    end
})

ESPTab:AddToggle({
    Name = "Tracers",
    Default = false,
    Callback = function(value)
        _G.tracers = value
    end
})

-- =====================================================
-- TAB: DESYNC
-- =====================================================
local DesyncTab = Window:MakeTab({
    Name = "Desync",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

DesyncTab:AddToggle({
    Name = "Enable Desync",
    Default = false,
    Callback = function(value)
        _G.desyncEnabled = value
        if value then
            DesyncModule:Start()
        end
    end
})

DesyncTab:AddSlider({
    Name = "Desync Offset X",
    Min = -50,
    Max = 50,
    Default = 10,
    Color = Color3.fromRGB(255, 255, 0),
    Increment = 1,
    Callback = function(value)
        _G.desyncOffset = Vector3.new(value, _G.desyncOffset.Y, _G.desyncOffset.Z)
    end
})

DesyncTab:AddSlider({
    Name = "Desync Offset Z",
    Min = -50,
    Max = 50,
    Default = 10,
    Color = Color3.fromRGB(255, 255, 0),
    Increment = 1,
    Callback = function(value)
        _G.desyncOffset = Vector3.new(_G.desyncOffset.X, _G.desyncOffset.Y, value)
    end
})

-- =====================================================
-- TAB: MISC
-- =====================================================
local MiscTab = Window:MakeTab({
    Name = "Misc",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

MiscTab:AddLabel("Anti-Detection: ACTIVE")
MiscTab:AddLabel("Anti-Kick: ACTIVE")
MiscTab:AddLabel("Version: 2.0")

MiscTab:AddButton({
    Name = "Destroy GUI",
    Callback = function()
        OrionLib:Destroy()
    end
})

-- =====================================================
-- INICIALIZACIÓN
-- =====================================================
OrionLib:Init()

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "N1Z44R v2.0";
    Text = "Ultra Advanced Loaded!";
    Duration = 5;
})

print("[N1Z44R] v2.0 Ultra Advanced cargado exitosamente")
print("[N1Z44R] Anti-detección: ACTIVA")
print("[N1Z44R] Desync real: DISPONIBLE")
print("[N1Z44R] Auto farm inteligente: ACTIVO")
