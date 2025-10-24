--[[
    N1Z44R v2.1 - STEAL A BRAINROT
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local character = player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

local _G = {
    autoStealEnabled = false,
    autoSellEnabled = false,
    farmRadius = 150,
    stealDelay = 0.3,
    priorityRare = true,
    walkSpeed = 16,
    flyEnabled = false,
    flySpeed = 100,
    noClipEnabled = false,
    itemESP = false,
    guardESP = false,
    playerESP = false,
    fullBright = false,
    noFog = false
}

local VirtualUser = game:GetService("VirtualUser")
player.Idled:connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

local BrainrotItems = {
    "Brainrot", "Brain", "Cash", "Money", "Coin", "Diamond", 
    "Gold", "Ruby", "Sapphire", "Emerald", "Crystal"
}

local BrainrotGuards = {
    "Guard", "Police", "Security", "Cop", "Officer"
}

local FarmModule = {}

function FarmModule:IsBrainrotItem(obj)
    local objName = obj.Name:lower()
    for _, itemName in pairs(BrainrotItems) do
        if objName:find(itemName:lower()) then
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
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Part") or obj:IsA("Model") then
            local success, result = pcall(function()
                return (hrp.Position - obj:GetPivot().Position).Magnitude
            end)
            
            if success and result <= _G.farmRadius then
                if FarmModule:IsBrainrotItem(obj) then
                    local isRare = obj.Name:lower():find("rare") or obj.Name:lower():find("legendary")
                    table.insert(items, {
                        object = obj,
                        distance = result,
                        isRare = isRare
                    })
                end
            end
        end
    end
    
    table.sort(items, function(a, b)
        if _G.priorityRare then
            if a.isRare and not b.isRare then return true end
            if not a.isRare and b.isRare then return false end
        end
        return a.distance < b.distance
    end)
    
    return items
end

function FarmModule:CollectItem(itemObj)
    pcall(function()
        if itemObj:FindFirstChild("ClickDetector") then
            fireclickdetector(itemObj.ClickDetector)
        end
        
        if itemObj:FindFirstChild("ProximityPrompt") then
            fireproximityprompt(itemObj.ProximityPrompt)
        end
        
        local remotes = {"CollectItem", "PickupItem", "GrabItem"}
        for _, remoteName in pairs(remotes) do
            local remote = ReplicatedStorage:FindFirstChild(remoteName)
            if remote then
                remote:FireServer(itemObj)
            end
        end
    end)
end

function FarmModule:SmartSteal()
    local items = FarmModule:GetNearbyItems()
    
    if #items > 0 then
        local target = items[1]
        
        pcall(function()
            local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear)
            local targetCFrame = CFrame.new(target.object.Position + Vector3.new(0, 3, 0))
            local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
            tween:Play()
            
            wait(0.3)
            FarmModule:CollectItem(target.object)
        end)
    end
end

function FarmModule:AutoSell()
    local sellZones = {}
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name:lower():find("sell") or obj.Name:lower():find("bank") or obj.Name:lower():find("deposit") then
            table.insert(sellZones, obj)
        end
    end
    
    if #sellZones > 0 then
        local closestZone = sellZones[1]
        
        pcall(function()
            local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear)
            local tween = TweenService:Create(hrp, tweenInfo, {CFrame = closestZone:GetPivot()})
            tween:Play()
            tween.Completed:Wait()
            
            wait(0.5)
            
            local sellRemotes = {"SellItems", "DepositCash"}
            for _, remoteName in pairs(sellRemotes) do
                local remote = ReplicatedStorage:FindFirstChild(remoteName)
                if remote then
                    remote:FireServer()
                end
            end
        end)
    end
end

local ESPModule = {}
ESPModule.Highlights = {}

function ESPModule:CreateHighlight(obj, color, name)
    if obj:FindFirstChild("N1Z44R_Highlight") then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "N1Z44R_Highlight"
    highlight.FillColor = color
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.6
    highlight.OutlineTransparency = 0
    highlight.Parent = obj
    
    table.insert(ESPModule.Highlights, highlight)
end

function ESPModule:UpdateESP()
    for _, highlight in pairs(ESPModule.Highlights) do
        if highlight then
            highlight:Destroy()
        end
    end
    ESPModule.Highlights = {}
    
    if _G.itemESP then
        local items = FarmModule:GetNearbyItems()
        for _, item in pairs(items) do
            local color = item.isRare and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(0, 255, 0)
            ESPModule:CreateHighlight(item.object, color, "Item")
        end
    end
    
    if _G.guardESP then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if FarmModule:IsGuard(obj) then
                ESPModule:CreateHighlight(obj, Color3.fromRGB(255, 0, 0), "Guard")
            end
        end
    end
    
    if _G.playerESP then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character then
                ESPModule:CreateHighlight(plr.Character, Color3.fromRGB(0, 100, 255), plr.Name)
            end
        end
    end
end

local VisualModule = {}

function VisualModule:ToggleFullBright()
    if _G.fullBright then
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.Brightness = 2
    else
        Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
        Lighting.Brightness = 1
    end
end

function VisualModule:ToggleNoFog()
    if _G.noFog then
        Lighting.FogEnd = 100000
    else
        Lighting.FogEnd = 1000
    end
end

local FlyModule = {}
FlyModule.Enabled = false

function FlyModule:Toggle()
    FlyModule.Enabled = not FlyModule.Enabled
    
    if FlyModule.Enabled then
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
        bodyVelocity.Parent = hrp
        
        spawn(function()
            while FlyModule.Enabled and _G.flyEnabled do
                local moveDirection = Vector3.new(0, 0, 0)
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveDirection = moveDirection + Vector3.new(0, 0, -1)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveDirection = moveDirection + Vector3.new(0, 0, 1)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveDirection = moveDirection + Vector3.new(-1, 0, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveDirection = moveDirection + Vector3.new(1, 0, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    moveDirection = moveDirection + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    moveDirection = moveDirection + Vector3.new(0, -1, 0)
                end
                
                bodyVelocity.Velocity = moveDirection * _G.flySpeed
                RunService.Heartbeat:Wait()
            end
            
            if bodyVelocity then
                bodyVelocity:Destroy()
            end
        end)
    end
end

local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Orion/main/source'))()

local Window = OrionLib:MakeWindow({
    Name = "N1Z44R v2.1 | Brainrot",
    HidePremium = false,
    SaveConfig = false
})

local FarmTab = Window:MakeTab({Name = "Auto Farm"})

FarmTab:AddToggle({
    Name = "Auto Steal Items",
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
    Name = "Auto Sell",
    Default = false,
    Callback = function(value)
        _G.autoSellEnabled = value
        spawn(function()
            while _G.autoSellEnabled do
                FarmModule:AutoSell()
                wait(15)
            end
        end)
    end
})

FarmTab:AddToggle({
    Name = "Priority Rare Items",
    Default = true,
    Callback = function(value)
        _G.priorityRare = value
    end
})

FarmTab:AddSlider({
    Name = "Farm Radius",
    Min = 50,
    Max = 300,
    Default = 150,
    Increment = 10,
    Callback = function(value)
        _G.farmRadius = value
    end
})

local MoveTab = Window:MakeTab({Name = "Movement"})

MoveTab:AddSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 100,
    Default = 16,
    Increment = 1,
    Callback = function(value)
        _G.walkSpeed = value
        humanoid.WalkSpeed = value
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
    Min = 50,
    Max = 200,
    Default = 100,
    Increment = 10,
    Callback = function(value)
        _G.flySpeed = value
    end
})

MoveTab:AddToggle({
    Name = "NoClip",
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

local ESPTab = Window:MakeTab({Name = "ESP"})

ESPTab:AddToggle({
    Name = "Item ESP",
    Default = false,
    Callback = function(value)
        _G.itemESP = value
        ESPModule:UpdateESP()
    end
})

ESPTab:AddToggle({
    Name = "Guard ESP",
    Default = false,
    Callback = function(value)
        _G.guardESP = value
        ESPModule:UpdateESP()
    end
})

ESPTab:AddToggle({
    Name = "Player ESP",
    Default = false,
    Callback = function(value)
        _G.playerESP = value
        ESPModule:UpdateESP()
    end
})

local VisualTab = Window:MakeTab({Name = "Visual"})

VisualTab:AddToggle({
    Name = "Full Bright",
    Default = false,
    Callback = function(value)
        _G.fullBright = value
        VisualModule:ToggleFullBright()
    end
})

VisualTab:AddToggle({
    Name = "No Fog",
    Default = false,
    Callback = function(value)
        _G.noFog = value
        VisualModule:ToggleNoFog()
    end
})

OrionLib:Init()

spawn(function()
    while true do
        if _G.itemESP or _G.guardESP or _G.playerESP then
            ESPModule:UpdateESP()
        end
        wait(2)
    end
end)

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "N1Z44R v2.1",
    Text = "Script cargado!",
    Duration = 5
})
