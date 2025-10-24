--[[
    N1Z44R v1.0
    Hub para Steal a Brainrot
    
    Características:
    - ESP avanzado
    - Auto Farm
    - Velocidad y saltos
    - Auto robo
    - Y más...
]]

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("N1Z44R", "DarkTheme")

-- Variables globales
local player = game:GetService("Players").LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

-- Estados
local _G = {
    -- ESP
    espEnabled = false,
    espPlayers = false,
    espItems = false,
    espBases = false,
    
    -- Auto Farm
    autoSteal = false,
    autoSellEnabled = false,
    autoGrabItems = false,
    
    -- Movement
    walkSpeed = 16,
    jumpPower = 50,
    infiniteJump = false,
    fly = false,
    
    -- Combat
    autoKick = false,
    killAura = false,
    
    -- Misc
    antiRagdoll = false,
    noClip = false,
    desyncEnabled = false
}

-- =====================================================
-- TAB 1: MAIN
-- =====================================================
local MainTab = Window:NewTab("Main")
local MainSection = MainTab:NewSection("Auto Farm")

MainSection:NewToggle("Auto Steal Items", "Roba items automáticamente", function(state)
    _G.autoSteal = state
    
    spawn(function()
        while _G.autoSteal do
            wait(0.5)
            
            -- Busca items para robar
            for _, item in pairs(workspace:GetDescendants()) do
                if item.Name:find("Item") or item.Name:find("Brainrot") then
                    if item:IsA("BasePart") and item.Parent then
                        local distance = (hrp.Position - item.Position).Magnitude
                        
                        if distance < 50 then
                            hrp.CFrame = item.CFrame
                            wait(0.3)
                            
                            -- Intenta recoger el item
                            if item:FindFirstChild("ClickDetector") then
                                fireclickdetector(item.ClickDetector)
                            end
                        end
                    end
                end
            end
        end
    end)
end)

MainSection:NewToggle("Auto Sell", "Vende automáticamente", function(state)
    _G.autoSellEnabled = state
    
    spawn(function()
        while _G.autoSellEnabled do
            wait(2)
            
            -- Busca el punto de venta
            local sellZone = workspace:FindFirstChild("SellZone") or workspace:FindFirstChild("Sell")
            
            if sellZone then
                hrp.CFrame = sellZone.CFrame
                wait(1)
            end
        end
    end)
end)

MainSection:NewToggle("Auto Grab Items", "Agarra items cercanos", function(state)
    _G.autoGrabItems = state
    
    spawn(function()
        while _G.autoGrabItems do
            wait(0.1)
            
            for _, item in pairs(workspace:GetChildren()) do
                if item:IsA("Tool") or (item:IsA("Model") and item:FindFirstChild("Handle")) then
                    local distance = (hrp.Position - item:GetPivot().Position).Magnitude
                    
                    if distance < 20 then
                        item.Parent = player.Backpack
                    end
                end
            end
        end
    end)
end)

-- =====================================================
-- TAB 2: SETTINGS (Movement & Combat)
-- =====================================================
local SettingsTab = Window:NewTab("Settings")
local MovementSection = SettingsTab:NewSection("Movement")

MovementSection:NewSlider("Walk Speed", "Ajusta tu velocidad", 500, 16, function(s)
    _G.walkSpeed = s
    humanoid.WalkSpeed = s
end)

MovementSection:NewSlider("Jump Power", "Ajusta tu salto", 500, 50, function(s)
    _G.jumpPower = s
    humanoid.JumpPower = s
end)

MovementSection:NewToggle("Infinite Jump", "Salta infinitamente", function(state)
    _G.infiniteJump = state
    
    if state then
        local InfiniteJumpConnection
        InfiniteJumpConnection = game:GetService("UserInputService").JumpRequest:Connect(function()
            if _G.infiniteJump then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            else
                InfiniteJumpConnection:Disconnect()
            end
        end)
    end
end)

MovementSection:NewToggle("Fly", "Vuela libremente", function(state)
    _G.fly = state
    
    local flying = false
    local flySpeed = 50
    local bodyVelocity
    local bodyGyro
    
    if state then
        flying = true
        
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = hrp
        
        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bodyGyro.P = 9e4
        bodyGyro.Parent = hrp
        
        spawn(function()
            local camera = workspace.CurrentCamera
            
            while flying and _G.fly do
                wait()
                
                local moveDirection = Vector3.new(0, 0, 0)
                local keys = game:GetService("UserInputService"):GetKeysPressed()
                
                for _, key in pairs(keys) do
                    if key.KeyCode == Enum.KeyCode.W then
                        moveDirection = moveDirection + camera.CFrame.LookVector
                    elseif key.KeyCode == Enum.KeyCode.S then
                        moveDirection = moveDirection - camera.CFrame.LookVector
                    elseif key.KeyCode == Enum.KeyCode.A then
                        moveDirection = moveDirection - camera.CFrame.RightVector
                    elseif key.KeyCode == Enum.KeyCode.D then
                        moveDirection = moveDirection + camera.CFrame.RightVector
                    elseif key.KeyCode == Enum.KeyCode.Space then
                        moveDirection = moveDirection + Vector3.new(0, 1, 0)
                    elseif key.KeyCode == Enum.KeyCode.LeftShift then
                        moveDirection = moveDirection - Vector3.new(0, 1, 0)
                    end
                end
                
                bodyVelocity.Velocity = moveDirection.Unit * flySpeed
                bodyGyro.CFrame = camera.CFrame
            end
            
            if bodyVelocity then bodyVelocity:Destroy() end
            if bodyGyro then bodyGyro:Destroy() end
        end)
    else
        flying = false
    end
end)

-- Combat Section
local CombatSection = SettingsTab:NewSection("Combat")

CombatSection:NewToggle("Auto Kick After Steal", "Kickea después de robar", function(state)
    _G.autoKick = state
end)

CombatSection:NewToggle("Anti Ragdoll", "Previene que te caigas", function(state)
    _G.antiRagdoll = state
    
    if state then
        spawn(function()
            while _G.antiRagdoll do
                wait(0.1)
                
                humanoid:ChangeState(Enum.HumanoidStateType.Running)
                
                -- Elimina ragdoll parts
                for _, v in pairs(character:GetDescendants()) do
                    if v:IsA("BallSocketConstraint") or v:IsA("NoCollisionConstraint") then
                        v:Destroy()
                    end
                end
            end
        end)
    end
end)

CombatSection:NewToggle("Kill Aura", "Golpea enemigos cercanos", function(state)
    _G.killAura = state
    
    spawn(function()
        while _G.killAura do
            wait(0.5)
            
            for _, otherPlayer in pairs(game.Players:GetPlayers()) do
                if otherPlayer ~= player and otherPlayer.Character then
                    local otherHRP = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
                    
                    if otherHRP then
                        local distance = (hrp.Position - otherHRP.Position).Magnitude
                        
                        if distance < 10 then
                            -- Busca la tool de combate
                            local tool = player.Character:FindFirstChildOfClass("Tool")
                            
                            if tool and tool:FindFirstChild("Handle") then
                                tool:Activate()
                            end
                        end
                    end
                end
            end
        end
    end)
end)

-- =====================================================
-- TAB 3: ESP
-- =====================================================
local ESPTab = Window:NewTab("ESP")
local ESPSection = ESPTab:NewSection("Visual")

-- ESP Functions
local function createESP(obj, color, text)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Parent = obj
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = color
    frame.BackgroundTransparency = 0.7
    frame.BorderSizePixel = 0
    frame.Parent = billboard
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.Parent = frame
    
    return billboard
end

ESPSection:NewToggle("Player ESP", "Ve a los jugadores", function(state)
    _G.espPlayers = state
    
    if state then
        for _, otherPlayer in pairs(game.Players:GetPlayers()) do
            if otherPlayer ~= player then
                spawn(function()
                    repeat wait() until otherPlayer.Character
                    
                    local hrp = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and not hrp:FindFirstChild("ESP") then
                        createESP(hrp, Color3.fromRGB(255, 0, 0), otherPlayer.Name)
                    end
                end)
            end
        end
        
        game.Players.PlayerAdded:Connect(function(newPlayer)
            if _G.espPlayers then
                spawn(function()
                    repeat wait() until newPlayer.Character
                    
                    local hrp = newPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        createESP(hrp, Color3.fromRGB(255, 0, 0), newPlayer.Name)
                    end
                end)
            end
        end)
    else
        for _, otherPlayer in pairs(game.Players:GetPlayers()) do
            if otherPlayer.Character then
                local hrp = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp and hrp:FindFirstChild("ESP") then
                    hrp.ESP:Destroy()
                end
            end
        end
    end
end)

ESPSection:NewToggle("Item ESP", "Ve los items", function(state)
    _G.espItems = state
    
    if state then
        for _, item in pairs(workspace:GetDescendants()) do
            if item.Name:find("Item") or item.Name:find("Brainrot") then
                if item:IsA("BasePart") and not item:FindFirstChild("ESP") then
                    createESP(item, Color3.fromRGB(0, 255, 0), "Item")
                end
            end
        end
    else
        for _, item in pairs(workspace:GetDescendants()) do
            if item:IsA("BasePart") and item:FindFirstChild("ESP") then
                item.ESP:Destroy()
            end
        end
    end
end)

ESPSection:NewToggle("Base ESP", "Ve las bases", function(state)
    _G.espBases = state
    
    if state then
        for _, base in pairs(workspace:GetChildren()) do
            if base.Name:find("Base") or base.Name:find("House") then
                if base:IsA("Model") and base.PrimaryPart and not base.PrimaryPart:FindFirstChild("ESP") then
                    createESP(base.PrimaryPart, Color3.fromRGB(0, 0, 255), "Base")
                end
            end
        end
    else
        for _, base in pairs(workspace:GetChildren()) do
            if base:IsA("Model") and base.PrimaryPart and base.PrimaryPart:FindFirstChild("ESP") then
                base.PrimaryPart.ESP:Destroy()
            end
        end
    end
end)

-- =====================================================
-- TAB 4: INFO & MISC
-- =====================================================
local InfoTab = Window:NewTab("Info")
local InfoSection = InfoTab:NewSection("Información")

InfoSection:NewLabel("N1Z44R v1.0")
InfoSection:NewLabel("Para: Steal a Brainrot")
InfoSection:NewLabel("Creado para testing")

local MiscSection = InfoTab:NewSection("Misc")

MiscSection:NewToggle("Desync (Cloner)", "Desincronización básica", function(state)
    _G.desyncEnabled = state
    
    if state then
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Name = "DesyncVelocity"
        bodyVelocity.MaxForce = Vector3.new(math.huge, 0, math.huge)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = hrp
        
        spawn(function()
            while _G.desyncEnabled do
                wait()
                if hrp:FindFirstChild("DesyncVelocity") then
                    hrp.DesyncVelocity.Velocity = Vector3.new(0, 0, 0)
                end
            end
        end)
    else
        if hrp:FindFirstChild("DesyncVelocity") then
            hrp.DesyncVelocity:Destroy()
        end
    end
end)

MiscSection:NewToggle("NoClip", "Atraviesa paredes", function(state)
    _G.noClip = state
    
    spawn(function()
        game:GetService("RunService").Stepped:Connect(function()
            if _G.noClip then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end)
end)

MiscSection:NewButton("Destroy GUI", "Cierra el menu", function()
    game:GetService("CoreGui"):FindFirstChild("N1Z44R"):Destroy()
end)

-- =====================================================
-- NOTIFICACIÓN INICIAL
-- =====================================================
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "N1Z44R";
    Text = "Cargado exitosamente!";
    Duration = 5;
})

print("N1Z44R v1.0 cargado")
print("Para Steal a Brainrot")
