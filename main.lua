

local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/ArNVN7WZ"))()

local Window = OrionLib:MakeWindow({
  Name = "ZyneyHub ・ AutoRob",
  HidePremium = false,
  SaveConfig = false,
  ConfigFolder = "ProjectNexar",
  IntroEnabled = true,
  IntroText = "Project Volara"
})

local AutorobberyTab = Window:MakeTab({
    Name = "Auto Robbery",
    Icon = "rbxassetid://73372120771587",
    PremiumOnly = false
})

local InformationTab = Window:MakeTab({
    Name = "Information",
    Icon = "rbxassetid://98510692857301",
    PremiumOnly = false
})

local Section = InformationTab:AddSection({
    Name = "Information"
})

InformationTab:AddParagraph("Warning!", "If your device is not that good you may get thrown out of your vehicle or kicked if that happens make sure your graphics are turned down.")

local Section = InformationTab:AddSection({
    Name = "Are you having problems?"
})    

InformationTab:AddButton({
    Name = "Copy Discord",
    Callback = function()
        setclipboard("discord.gg/project-volara")
        game:GetService("StarterGui"):SetCore("SendNotification", {Title="Copied!", Text="Discord invite copied.", Duration=3})
    end
})     

InformationTab:AddLabel("Script not working or bugs? Open a ticket on the dc.")
InformationTab:AddLabel("You got a error? Open a ticket on the dc.")
InformationTab:AddLabel("Script is in Release Version R3.")

local Section = AutorobberyTab:AddSection({
    Name = "Autorobbery Script"
})

AutorobberyTab:AddParagraph("Auto-Execute Status", "✅ Auto-Execute aktiv (Server-Hop)")

local Section = AutorobberyTab:AddSection({
    Name = "Autorobbery Options"
})

local configFileName = "ZyneyHub5.json"
local autorobToggle = false
local autoSellToggle = true
local vehicleSpeedDivider = 170
local healthAbortThreshold = 37
local collectSpeedDivider = 28

local function loadConfig()
    if isfile(configFileName) then
        local data = readfile(configFileName)
        local success, config = pcall(function()
            return game:GetService("HttpService"):JSONDecode(data)
        end)

        if success and config then
            autorobToggle = config.autorobToggle or false
            autoSellToggle = config.autoSellToggle or false
            vehicleSpeedDivider = config.vehicleSpeedDivider or 170
            healthAbortThreshold = config.healthAbortThreshold or 37
            collectSpeedDivider = config.collectSpeedDivider or 28
        end
    end
end

local function saveConfig()
    local config = {
        autorobToggle = autorobToggle,
        autoSellToggle = autoSellToggle,
        vehicleSpeedDivider = vehicleSpeedDivider,
        healthAbortThreshold = healthAbortThreshold,
        collectSpeedDivider = collectSpeedDivider
    }
    local json = game:GetService("HttpService"):JSONEncode(config)
    writefile(configFileName, json)
end

loadConfig()

AutorobberyTab:AddToggle({
    Name = "Autorob",
    Default = autorobToggle,
    Callback = function(Value)
        autorobToggle = Value
        saveConfig()

        if Value then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "AutoRob Enabled",
                Text = "Starting robbery sequence...",
                Duration = 3
            })
        else
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "AutoRob Disabled",
                Text = "Stopping robbery sequence...",
                Duration = 3
            })
        end
    end    
})

AutorobberyTab:AddToggle({
    Name = "Automatically sells stolen items",
    Default = autoSellToggle,
    Callback = function(Value)
        autoSellToggle = Value
        saveConfig()
    end    
})

local Section = AutorobberyTab:AddSection({
    Name = "Settings (Set it so that it matches the performance of your device.)"
})

AutorobberyTab:AddSlider({
    Name = "Vehicle speed",
    Min = 50,
    Max = 240,
    Default = vehicleSpeedDivider,
    Increment = 5,
    Callback = function(value)
        vehicleSpeedDivider = value
        saveConfig()
    end
})

AutorobberyTab:AddSlider({
    Name = "Item collection speed",
    Min = 15,
    Max = 40,
    Default = collectSpeedDivider,
    Increment = 1,
    Callback = function(value)
        collectSpeedDivider = value
        saveConfig()
    end
})

AutorobberyTab:AddSlider({
    Name = "Life limit where it should stop farming",
    Min = 27,
    Max = 100,
    Default = healthAbortThreshold,
    Increment = 1,
    Callback = function(value)
        healthAbortThreshold = value
        saveConfig()
    end
})

local plr = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local robRemoteEvent = ReplicatedStorage:WaitForChild("MW5"):WaitForChild("adc4b609-bcc8-4d34-972b-99152ad2e8a3")
local sellRemoteEvent = ReplicatedStorage:WaitForChild("MW5"):WaitForChild("7c0c6f72-73f4-48a5-81e6-8ccf02a96366")
local EquipRemoteEvent = ReplicatedStorage:WaitForChild("MW5"):WaitForChild("542a57d7-254c-43f1-8b1c-bb928c73db62")
local buyRemoteEvent = ReplicatedStorage:WaitForChild("MW5"):WaitForChild("c82cec53-dd03-4db0-aa12-1fc14334ffe0")
local fireBombRemoteEvent = ReplicatedStorage:WaitForChild("MW5"):WaitForChild("a44ab0b3-ea43-466a-8e72-e0dd121e718a")

local ProximityPromptTimeBet = 2.5
local key = Enum.KeyCode.E

local JEWELRY_VEHICLE_POS = Vector3.new(-447.92, 5.22, 3648.73)
local JEWELRY_BOMB_THROW_POS = Vector3.new(-437.72, 21.22, 3553.88)
local JEWELRY_BOMB_DETONATE_POS = Vector3.new(-416.52, 21.22, 3555.58)

-- Server-Hop Position
local SERVERHOP_POSITION = Vector3.new(-917.87, 5.84, 3983.01)

-- ALTER POLIZEI-CHECK (vom alten Code übernommen)
local function isPoliceNearby()
    local player = game.Players.LocalPlayer
    local policeTeam = game:GetService("Teams"):FindFirstChild("Police")
    
    if not policeTeam then 
        return false 
    end
    
    for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do
        if plr.Team == policeTeam and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (plr.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if distance <= 40 then
                return true
            end
        end
    end
    return false
end

-- Vereinfachte Funktion zum Überprüfen, ob der Juwelier offen ist (ANDERSHERUM!)
local function isJewelryStoreAlreadyRobbed()
    -- Wenn der Juwelier bereits geöffnet/ausgeraubt wurde, soll er übersprungen werden
    
    local jewelryRobbery = Workspace:FindFirstChild("Robberies")
    if not jewelryRobbery then 
        return true -- Sicherheitshalber überspringen
    end
    
    local jewelerSafe = jewelryRobbery:FindFirstChild("Jeweler Safe Robbery")
    if not jewelerSafe then 
        return true -- Sicherheitshalber überspringen
    end
    
    -- Prüfen, ob es bereits Items gibt (das bedeutet, er wurde schon geöffnet)
    local jeweler = jewelerSafe:FindFirstChild("Jeweler")
    if jeweler then
        -- Wenn der Jeweler-Ordner existiert UND Items enthält, wurde er schon geöffnet
        local items = jeweler:FindFirstChild("Items")
        local money = jeweler:FindFirstChild("Money")
        
        if items or money then
            -- Es gibt Items oder Money, also wurde der Safe schon geöffnet
            return true
        end
    end
    
    -- Prüfen, ob der Safedoor zerstört ist (Alternative Check)
    local safeDoor = jewelerSafe:FindFirstChild("Safedoor")
    if safeDoor then
        -- Wenn der Safedoor existiert, könnte er noch geschlossen sein
        -- Aber wenn er kaputt/transparent ist, wurde er schon geöffnet
        if safeDoor.Transparency > 0.9 then
            return true -- Safedoor ist durchsichtig/zerstört
        end
    end
    
    -- Wenn keine Anzeichen für einen bereits geöffneten Safe gefunden wurden
    return false
end

local function JumpOut()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid and humanoid.SeatPart then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end

local function ensurePlayerInVehicle()
    local vehicle = Workspace:FindFirstChild("Vehicles") and Workspace.Vehicles:FindFirstChild(LocalPlayer.Name)
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

    if vehicle and character then
        local humanoid = character:FindFirstChildWhichIsA("Humanoid")
        local driveSeat = vehicle:FindFirstChild("DriveSeat")
        if humanoid and driveSeat and humanoid.SeatPart ~= driveSeat then
            driveSeat:Sit(humanoid)
        end
    end
end

local function clickAtCoordinates(scaleX, scaleY, duration)
    local camera = game.Workspace.CurrentCamera
    local screenWidth = camera.ViewportSize.X
    local screenHeight = camera.ViewportSize.Y
    local absoluteX = screenWidth * scaleX
    local absoluteY = screenHeight * scaleY

    VirtualInputManager:SendMouseButtonEvent(absoluteX, absoluteY, 0, true, game, 0)  
    if duration and duration > 0 then
        task.wait(duration)  
    end
    VirtualInputManager:SendMouseButtonEvent(absoluteX, absoluteY, 0, false, game, 0) 
end

local function checkPlayerHealth()
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character or not character:FindFirstChild("Humanoid") then
        return false
    end

    return character.Humanoid.Health <= healthAbortThreshold
end

local function plrTween(destination)
    local char = plr.Character
    if not char or not char.PrimaryPart then
        return
    end

    local distance = (char.PrimaryPart.Position - destination).Magnitude
    local tweenDuration = distance / collectSpeedDivider
    local TweenInfoToUse = TweenInfo.new(tweenDuration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

    local TweenValue = Instance.new("CFrameValue")
    TweenValue.Value = char:GetPivot()

    TweenValue.Changed:Connect(function(newCFrame)
        char:PivotTo(newCFrame)
    end)

    local targetCFrame = CFrame.new(destination)
    local tween = TweenService:Create(TweenValue, TweenInfoToUse, { Value = targetCFrame })
    tween:Play()
    tween.Completed:Wait()
    TweenValue:Destroy()
end

local function plrInstantTeleport(destination)
    local char = plr.Character
    if not char or not char.PrimaryPart then
        return
    end

    char:PivotTo(CFrame.new(destination))
end

local function teleportVehicleToPosition(targetPos)
    ensurePlayerInVehicle()

    local vehicle = Workspace:FindFirstChild("Vehicles") and Workspace.Vehicles:FindFirstChild(LocalPlayer.Name)
    if not vehicle then return end

    local primaryPart = vehicle:FindFirstChild("DriveSeat") or vehicle.PrimaryPart
    if not primaryPart then return end
    vehicle.PrimaryPart = primaryPart

    local speed = vehicleSpeedDivider

    local currentPos = primaryPart.Position
    local downPos = Vector3.new(currentPos.X, currentPos.Y - 5, currentPos.Z)
    local downDistance = (currentPos - downPos).Magnitude

    if downDistance > 0.1 then
        local downTweenTime = downDistance / speed
        local downTweenInfo = TweenInfo.new(downTweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

        local downTweenValue = Instance.new("CFrameValue")
        downTweenValue.Value = vehicle:GetPivot()

        downTweenValue.Changed:Connect(function(newCFrame)
            if vehicle and vehicle.PrimaryPart then
                vehicle:PivotTo(newCFrame)
                local driveSeat = vehicle:FindFirstChild("DriveSeat")
                if driveSeat then
                    driveSeat.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    driveSeat.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                end
            end
        end)

        local downTargetCFrame = CFrame.new(downPos)
        local downTween = TweenService:Create(downTweenValue, downTweenInfo, { Value = downTargetCFrame })
        downTween:Play()
        downTween.Completed:Wait()
        downTweenValue:Destroy()
    end

    task.wait(0.1)

    local undergroundTargetPos = Vector3.new(targetPos.X, targetPos.Y - 5, targetPos.Z)
    local currentUndergroundPos = primaryPart.Position
    local horizontalDistance = (Vector3.new(currentUndergroundPos.X, 0, currentUndergroundPos.Z) - Vector3.new(undergroundTargetPos.X, 0, undergroundTargetPos.Z)).Magnitude

    if horizontalDistance > 0.1 then
        local tweenTime = horizontalDistance / speed
        local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

        local TweenValue = Instance.new("CFrameValue")
        TweenValue.Value = vehicle:GetPivot()

        TweenValue.Changed:Connect(function(newCFrame)
            if vehicle and vehicle.PrimaryPart then
                vehicle:PivotTo(newCFrame)
                local driveSeat = vehicle:FindFirstChild("DriveSeat")
                if driveSeat then
                    driveSeat.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    driveSeat.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                end
            end
        end)

        local targetCFrame = CFrame.new(undergroundTargetPos)
        local tween = TweenService:Create(TweenValue, tweenInfo, { Value = targetCFrame })
        tween:Play()
        tween.Completed:Wait()
        TweenValue:Destroy()
    end

    task.wait(0.1)

    local finalPos = Vector3.new(targetPos.X, targetPos.Y, targetPos.Z)
    local upDistance = 5
    local upTweenTime = upDistance / speed
    local upTweenInfo = TweenInfo.new(upTweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

    local upTweenValue = Instance.new("CFrameValue")
    upTweenValue.Value = vehicle:GetPivot()

    upTweenValue.Changed:Connect(function(newCFrame)
        if vehicle and vehicle.PrimaryPart then
            vehicle:PivotTo(newCFrame)
            local driveSeat = vehicle:FindFirstChild("DriveSeat")
            if driveSeat then
                driveSeat.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                driveSeat.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            end
        end
    end)

    local upTargetCFrame = CFrame.new(finalPos)
    local upTween = TweenService:Create(upTweenValue, upTweenInfo, { Value = upTargetCFrame })
    upTween:Play()
    upTween.Completed:Wait()
    upTweenValue:Destroy()
end

local function tweenTo(destination)
    return teleportVehicleToPosition(destination)
end

-- NEUE FUNKTION: Sammeln von einer festen Position aus (für Club und Juwelier)
local function collectFromFixedPosition(folder, standPosition)
    if not folder then return end
    local player = game.Players.LocalPlayer
    
    -- Alte Polizei-Check Logik
    local policeTeam = game:GetService("Teams"):FindFirstChild("Police")
    local function isPoliceNearbySimple()
        for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do
            if plr.Team == policeTeam and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local distance = (plr.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if distance <= 40 then
                    return true
                end
            end
        end
        return false
    end
    
    -- Zur Standposition teleportieren
    plrInstantTeleport(standPosition)
    task.wait(0.5)
    
    -- Alle MeshParts finden
    local meshParts = {}
    for _, child in ipairs(folder:GetChildren()) do
        if child:IsA("MeshPart") and child.Transparency == 0 then
            table.insert(meshParts, child)
        end
        for _, descendant in ipairs(child:GetDescendants()) do
            if descendant:IsA("MeshPart") and descendant.Transparency == 0 then
                table.insert(meshParts, descendant)
            end
        end
    end
    
    -- Nicht nach Entfernung sortieren - einfach alle nacheinander
    for _, meshPart in ipairs(meshParts) do
        -- Alte Polizei-Check Logik
        if isPoliceNearbySimple() then
            game.StarterGui:SetCore("SendNotification", {
                Title = "Police is nearby",
                Text = "Collection aborted",
            })
            return
        end

        if checkPlayerHealth() then
            game.StarterGui:SetCore("SendNotification", {
                Title = "Player is hurt",
                Text = "Collection aborted",
            })
            return
        end

        if meshPart.Transparency == 1 then
            continue
        end

        -- BLEIBT AN DER STAND-POSITION - bewegt sich nicht zu den Items!
        
        local itemName = meshPart.Name
        if itemName == "Gold" or (meshPart.Parent and meshPart.Parent.Name == "Gold") then
            local args = {meshPart, "OBG", true}
            robRemoteEvent:FireServer(unpack(args))
            task.wait(ProximityPromptTimeBet)
            local args = {meshPart, "OBG", false}
            robRemoteEvent:FireServer(unpack(args))
        elseif itemName == "Money" or (meshPart.Parent and meshPart.Parent.Name == "Money") then
            local args = {meshPart, "0Re", true}
            robRemoteEvent:FireServer(unpack(args))
            task.wait(ProximityPromptTimeBet)
            local args = {meshPart, "0Re", false}
            robRemoteEvent:FireServer(unpack(args))
        else
            local args = {meshPart, "OBG", true}
            robRemoteEvent:FireServer(unpack(args))
            task.wait(ProximityPromptTimeBet)
            local args = {meshPart, "OBG", false}
            robRemoteEvent:FireServer(unpack(args))
        end

        task.wait(0.1)
    end
end

-- ALTE FUNKTION: Normales Sammeln für die Bank
local function interactWithVisibleMeshPartsUniversal(folder)
    if not folder then return end
    local player = game.Players.LocalPlayer
    local policeTeam = game:GetService("Teams"):FindFirstChild("Police")
    if not policeTeam then return end
    
    -- Alte Polizei-Check Logik
    local function isPoliceNearbySimple()
        for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do
            if plr.Team == policeTeam and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local distance = (plr.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if distance <= 40 then
                    return true
                end
            end
        end
        return false
    end

    local meshParts = {}
    for _, child in ipairs(folder:GetChildren()) do
        if child:IsA("MeshPart") and child.Transparency == 0 then
            table.insert(meshParts, child)
        end
        for _, descendant in ipairs(child:GetDescendants()) do
            if descendant:IsA("MeshPart") and descendant.Transparency == 0 then
                table.insert(meshParts, descendant)
            end
        end
    end

    table.sort(meshParts, function(a, b)
        local aDist = (a.Position - player.Character.HumanoidRootPart.Position).Magnitude
        local bDist = (b.Position - player.Character.HumanoidRootPart.Position).Magnitude
        return aDist < bDist
    end)

    for _, meshPart in ipairs(meshParts) do
        -- Alte Polizei-Check Logik
        if isPoliceNearbySimple() then
            game.StarterGui:SetCore("SendNotification", {
                Title = "Police is nearby",
                Text = "Interaction aborted",
            })
            return
        end

        if checkPlayerHealth() then
            game.StarterGui:SetCore("SendNotification", {
                Title = "Player is hurt",
                Text = "Interaction aborted",
            })
            return
        end

        if meshPart.Transparency == 1 then
            continue
        end

        plrTween(meshPart.Position)
        task.wait(0.1)

        local itemName = meshPart.Name
        if itemName == "Gold" or (meshPart.Parent and meshPart.Parent.Name == "Gold") then
            local args = {meshPart, "OBG", true}
            robRemoteEvent:FireServer(unpack(args))
            task.wait(ProximityPromptTimeBet)
            local args = {meshPart, "OBG", false}
            robRemoteEvent:FireServer(unpack(args))
        elseif itemName == "Money" or (meshPart.Parent and meshPart.Parent.Name == "Money") then
            local args = {meshPart, "0Re", true}
            robRemoteEvent:FireServer(unpack(args))
            task.wait(ProximityPromptTimeBet)
            local args = {meshPart, "0Re", false}
            robRemoteEvent:FireServer(unpack(args))
        else
            local args = {meshPart, "OBG", true}
            robRemoteEvent:FireServer(unpack(args))
            task.wait(ProximityPromptTimeBet)
            local args = {meshPart, "OBG", false}
            robRemoteEvent:FireServer(unpack(args))
        end

        task.wait(0.1)
    end
end

local function MoveToDealer()
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local vehicle = Workspace.Vehicles:FindFirstChild(player.Name)

    if not vehicle then
        game.StarterGui:SetCore("SendNotification", {
            Title = "Error",
            Text = "No vehicle found.",
            Duration = 3,
        })
        return
    end

    local dealers = Workspace:FindFirstChild("Dealers")
    if not dealers then
        game.StarterGui:SetCore("SendNotification", {
            Title = "Error",
            Text = "Dealers not found.",
            Duration = 3,
        })
        tweenTo(SERVERHOP_POSITION)
        return
    end

    local closest, shortest = nil, math.huge
    for _, dealer in pairs(dealers:GetChildren()) do
        if dealer:FindFirstChild("Head") then
            local dist = (character.HumanoidRootPart.Position - dealer.Head.Position).Magnitude
            if dist < shortest then
                shortest = dist
                closest = dealer.Head
            end
        end
    end

    if not closest then
        game.StarterGui:SetCore("SendNotification", {
            Title = "Error",
            Text = "No dealer found.",
            Duration = 3,
        })
        tweenTo(SERVERHOP_POSITION)
        return
    end

    local destination1 = closest.Position + Vector3.new(0, 5, 0)
    tweenTo(destination1)
end

local function RobJewelryStore()
    -- ZUERST prüfen, ob der Juwelier bereits geöffnet/ausgeraubt wurde
    if isJewelryStoreAlreadyRobbed() then
        game.StarterGui:SetCore("SendNotification", {
            Title = "Jewelry Store",
            Text = "Juwelier ist bereits offen/ausgeraubt, überspringe...",
            Duration = 3,
        })
        return false -- Überspringen, weil schon jemand anders ihn ausraubt
    end
    
    game.StarterGui:SetCore("SendNotification", {
        Title = "Jewelry Store",
        Text = "Juwelier ist geschlossen, starte Überfall...",
        Duration = 3,
    })

    -- Alte Polizei-Check Logik
    if isPoliceNearby() then
        game.StarterGui:SetCore("SendNotification", {
            Title = "Police is nearby",
            Text = "Jewelry store robbery aborted",
            Duration = 3,
        })
        return false
    end

    if checkPlayerHealth() then
        game.StarterGui:SetCore("SendNotification", {
            Title = "Player is hurt",
            Text = "Jewelry store robbery aborted",
        })
        return false
    end

    ensurePlayerInVehicle()
    tweenTo(JEWELRY_VEHICLE_POS)
    task.wait(0.5)

    JumpOut()
    task.wait(0.5)

    local hasBomb = false
    local function checkContainer(container)
        for _, item in ipairs(container:GetChildren()) do
            if item:IsA("Tool") and item.Name == "Bomb" then
                return true
            end
        end
        return false
    end

    hasBomb = checkContainer(plr.Backpack) or checkContainer(plr.Character)

    if not hasBomb then
        ensurePlayerInVehicle()
        MoveToDealer()
        task.wait(0.5)
        local args = {"Bomb", "Dealer"}
        buyRemoteEvent:FireServer(unpack(args))
        task.wait(0.5)
        ensurePlayerInVehicle()
        tweenTo(JEWELRY_VEHICLE_POS)
        task.wait(0.5)
        JumpOut()
        task.wait(0.5)
    end

    plrInstantTeleport(JEWELRY_BOMB_THROW_POS)
    task.wait(0.5)

    -- Polizei-Check vor dem Bombenwurf
    if isPoliceNearby() then
        game.StarterGui:SetCore("SendNotification", {
            Title = "Police is nearby",
            Text = "Jewelry store robbery aborted",
            Duration = 3,
        })
        return false
    end

    local args = {"Bomb"}
    EquipRemoteEvent:FireServer(unpack(args))
    task.wait(0.5)

    local tool = plr.Character:FindFirstChild("Bomb")
    if tool then
        VirtualInputManager:SendMouseButtonEvent(0, 0, 1, true, game, 1)
        wait(1)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        wait(0.5)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 1, false, game, 1)
    end

    task.wait(0.5)

    plrInstantTeleport(JEWELRY_BOMB_DETONATE_POS)
    task.wait(0.5)

    fireBombRemoteEvent:FireServer()
    task.wait(4)

    -- GEÄNDERT: Bleibt an der Bomben-Position und sammelt von dort
    game.StarterGui:SetCore("SendNotification", {
        Title = "Collecting Items",
        Text = "Collecting from bomb position...",
        Duration = 3,
    })

    task.wait(1)

    local jewelryRobbery = Workspace:FindFirstChild("Robberies")
    if jewelryRobbery then
        local jewelerSafe = jewelryRobbery:FindFirstChild("Jeweler Safe Robbery")
        if jewelerSafe then
            local jeweler = jewelerSafe:FindFirstChild("Jeweler")
            if jeweler then
                -- NEU: Sammelt von der Bomben-Position aus
                collectFromFixedPosition(jeweler, JEWELRY_BOMB_THROW_POS)
            end
        end
    end

    game.StarterGui:SetCore("SendNotification", {
        Title = "Jewelry Store robbed",
        Text = "Moving to sell items...",
        Duration = 3,
    })

    ensurePlayerInVehicle()
    if autoSellToggle == true then
        MoveToDealer()
        task.wait(0.5)
        local args = {"Gold", "Dealer"}
        sellRemoteEvent:FireServer(unpack(args))
        sellRemoteEvent:FireServer(unpack(args))
        sellRemoteEvent:FireServer(unpack(args))
    end
    
    return true
end

-- Einfacher Server-Hop
local function serverHop()
    local TeleportService = game:GetService("TeleportService")
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer

    game.StarterGui:SetCore("SendNotification", {
        Title = "Server Hop",
        Text = "Teleporting to random server...",
        Duration = 5,
    })

    -- Warte kurz
    task.wait(2)

    -- Simple teleport to a random server
    local success, errorMessage = pcall(function()
        TeleportService:Teleport(game.PlaceId, player)
    end)

    if not success then
        warn("Teleport failed:", errorMessage)

        -- Try with different methods
        task.wait(3)

        -- Alternative method: Ensure player exists
        if player and player:IsDescendantOf(game) then
            TeleportService:TeleportAsync(game.PlaceId, {player})
        end
    end
end

spawn(function()
    while task.wait() do
        if autorobToggle == true then
            local player = game.Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            local humanoid = character:WaitForChild("Humanoid")
            local camera = game.Workspace.CurrentCamera

            local function lockCamera()
                local rootPart = character.HumanoidRootPart
                local heightOffset = 10
                local backOffset = 4
                local cameraPosition = rootPart.Position - rootPart.CFrame.LookVector * backOffset + Vector3.new(0, heightOffset, 0)
                local lookAtPosition = rootPart.Position + Vector3.new(0, 3, 0)
                camera.CFrame = CFrame.new(cameraPosition, lookAtPosition)
                camera.FieldOfView = 120
            end

            game:GetService("RunService").RenderStepped:Connect(lockCamera)

            -- Alte Polizei-Check Logik
            if isPoliceNearby() then
                game.StarterGui:SetCore("SendNotification", {
                    Title = "Police is nearby",
                    Text = "Waiting...",
                    Duration = 3,
                })
                task.wait(5)
                continue
            end

            if checkPlayerHealth() then
                game.StarterGui:SetCore("SendNotification", {
                    Title = "Player is hurt",
                    Text = "Waiting to heal...",
                    Duration = 3,
                })
                task.wait(5)
                continue
            end

            ensurePlayerInVehicle()
            task.wait(.5)
            clickAtCoordinates(0.5, 0.9)
            task.wait(.5)

            tweenTo(Vector3.new(-1370.972412109375, 5.499999046325684, 3127.154541015625))

            local musikPart = workspace.Robberies["Club Robbery"].Club.Door.Accessory.Black
            local bankLight = game.Workspace.Robberies.BankRobbery.LightGreen.Light
            local bankLight2 = game.Workspace.Robberies.BankRobbery.LightRed.Light

            if musikPart.Rotation == Vector3.new(180, 0, 180) then
                -- Alte Polizei-Check Logik
                if isPoliceNearby() then
                    game.StarterGui:SetCore("SendNotification", {
                        Title = "Police is nearby",
                        Text = "Club robbery skipped",
                        Duration = 3,
                    })
                    task.wait(2)
                else
                    clickAtCoordinates(0.5, 0.9)
                    game.StarterGui:SetCore("SendNotification", {
                        Title = "Club Safe is open",
                        Text = "Going to rob",
                    })

                    local function checkContainer(container)
                        for _, item in ipairs(container:GetChildren()) do
                            -- CLUB: Prüft auf "Grenade"
                            if item:IsA("Tool") and item.Name == "Grenade" then
                                return true
                            end
                        end
                        return false
                    end

                    local function playerHasGrenadeGui(player)
                        local playerGui = player:FindFirstChild("PlayerGui")
                        if not playerGui then return false end

                        local uiElement = playerGui:FindFirstChild("A6A23F59-70AC-4DDF-8F7B-C4E1E8D6434F")
                        if not uiElement then return false end

                        for _, guiObject in ipairs(uiElement:GetDescendants()) do
                            if (guiObject:IsA("ImageLabel") or guiObject:IsA("ImageButton")) then
                                -- Mögliche Bilder für Granate prüfen
                                if guiObject.Image == "rbxassetid://132706206999660" or 
                                   guiObject.Image == "rbxassetid://" then
                                    return true
                                end
                            end
                        end
                        return false
                    end

                    -- CLUB: Prüft auf "Grenade"
                    local hasGrenade = checkContainer(plr.Backpack) or checkContainer(plr.Character) or playerHasGrenadeGui(plr)

                    if not hasGrenade then
                        ensurePlayerInVehicle()
                        task.wait(0.5)
                        MoveToDealer()
                        task.wait(0.5)
                        -- CLUB: Kauft "Grenade"
                        local args = {"Grenade", "Dealer"}
                        buyRemoteEvent:FireServer(unpack(args))
                        task.wait(0.5)
                    end

                    ensurePlayerInVehicle()
                    task.wait(0.5)

                    local musikPos = Vector3.new(-1739.5330810546875, 11, 3052.31103515625)
                    local musikStand = Vector3.new(-1744.177001953125, 11.125, 3012.20263671875)
                    local musikSafe = Vector3.new(-1743.4300537109375, 11.124999046325684, 3049.96630859375)

                    tweenTo(musikPos)
                    task.wait(0.5)
                    JumpOut()
                    task.wait(0.5)

                    -- CLUB: Equipiert "Grenade"
                    local args = {"Grenade"}
                    EquipRemoteEvent:FireServer(unpack(args))
                    task.wait(0.5)

                    plrInstantTeleport(musikStand)
                    task.wait(0.5)

                    local tool = plr.Character:FindFirstChild("Grenade")
                    if tool then
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 1, true, game, 1)
                        wait(1)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                        wait(0.05)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                        wait(0.5)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 1, false, game, 1)
                    end

                    task.wait(0.5)
                    fireBombRemoteEvent:FireServer()
                    plrInstantTeleport(musikSafe)
                    task.wait(4)
                    
                    -- GEÄNDERT: Bleibt an der Stand-Position und sammelt von dort
                    local safeFolder = workspace.Robberies["Club Robbery"].Club
                    collectFromFixedPosition(safeFolder:FindFirstChild("Items"), musikStand)
                    collectFromFixedPosition(safeFolder:FindFirstChild("Money"), musikStand)

                    ensurePlayerInVehicle()
                    if autoSellToggle == true then
                        ensurePlayerInVehicle()
                        MoveToDealer()
                        task.wait(0.5)
                        local args = {"Gold", "Dealer"}
                        sellRemoteEvent:FireServer(unpack(args))
                        sellRemoteEvent:FireServer(unpack(args))
                        sellRemoteEvent:FireServer(unpack(args))
                    end

                    game.StarterGui:SetCore("SendNotification", {
                        Title = "Club robbed",
                        Text = "Moving to check bank",
                        Duration = 3,
                    })
                end

            else
                game.StarterGui:SetCore("SendNotification", {
                    Title = "Club Safe is not open",
                    Text = "Checking bank...",
                    Duration = 3,
                })
            end

            if bankLight2.Enabled == false and bankLight.Enabled == true then
                -- Alte Polizei-Check Logik
                if isPoliceNearby() then
                    game.StarterGui:SetCore("SendNotification", {
                        Title = "Police is nearby",
                        Text = "Bank robbery skipped",
                        Duration = 3,
                    })
                    task.wait(2)
                else
                    clickAtCoordinates(0.5, 0.9)
                    game.StarterGui:SetCore("SendNotification", {
                        Title = "Bank is open",
                        Text = "Going to rob",
                        Duration = 3,
                    })

                    ensurePlayerInVehicle()
                    local hasBomb1 = false  -- BANK: "Bomb"
                    local plr = game.Players.LocalPlayer

                    local function checkContainer(container)
                        for _, item in ipairs(container:GetChildren()) do
                            -- BANK: Prüft auf "Bomb"
                            if item:IsA("Tool") and item.Name == "Bomb" then
                                return true
                            end
                        end
                        return false
                    end

                    hasBomb1 = checkContainer(plr.Backpack) or checkContainer(plr.Character)

                    if not hasBomb1 then
                        ensurePlayerInVehicle()
                        task.wait(0.5)
                        MoveToDealer()
                        task.wait(0.5)
                        -- BANK: Kauft "Bomb"
                        local args = {"Bomb", "Dealer"}
                        buyRemoteEvent:FireServer(unpack(args))
                        task.wait(0.5)
                    end

                    tweenTo(Vector3.new(-1202.86181640625, 7.877995491027832, 3164.614501953125))
                    task.wait(0.5)
                    JumpOut()
                    task.wait(0.5)

                    plrInstantTeleport(Vector3.new(-1242.367919921875, 7.749999046325684, 3144.705322265625))
                    task.wait(0.5)

                    -- BANK: Equipiert "Bomb"
                    local args = {"Bomb"}
                    EquipRemoteEvent:FireServer(unpack(args))
                    task.wait(0.5)

                    local tool = plr.Character:FindFirstChild("Bomb")
                    if tool then
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 1, true, game, 1)
                        wait(1)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                        wait(0.05)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                        wait(0.5)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 1, false, game, 1)
                    end

                    task.wait(.5)
                    fireBombRemoteEvent:FireServer()
                    plrInstantTeleport(Vector3.new(-1246.291015625, 7.749999046325684, 3120.8505859375))
                    task.wait(4)

                    local safeFolder = Workspace.Robberies.BankRobbery
                    -- UNVERÄNDERT: Bank verwendet weiterhin das normale Sammeln
                    interactWithVisibleMeshPartsUniversal(safeFolder:FindFirstChild("Gold"))
                    interactWithVisibleMeshPartsUniversal(safeFolder:FindFirstChild("Money"))

                    ensurePlayerInVehicle()
                    if autoSellToggle == true then
                        task.wait(.5)
                        MoveToDealer()
                        task.wait(.5)
                        local args = {"Gold", "Dealer"}
                        sellRemoteEvent:FireServer(unpack(args))
                        sellRemoteEvent:FireServer(unpack(args))
                        sellRemoteEvent:FireServer(unpack(args))
                        task.wait(.5)
                    end

                    game.StarterGui:SetCore("SendNotification", {
                        Title = "Bank robbed",
                        Text = "Moving to jewelry store",
                        Duration = 3,
                    })
                end

            else
                game.StarterGui:SetCore("SendNotification", {
                    Title = "Bank is not open",
                    Text = "Moving to jewelry store",
                    Duration = 3,
                })
            end

            local jewelryRobbed = RobJewelryStore()
            
            if not jewelryRobbed then
                game.StarterGui:SetCore("SendNotification", {
                    Title = "Juwelier",
                    Text = "Übersprungen (bereits offen/Polizei/Gesundheit)",
                    Duration = 3,
                })
            end

            ensurePlayerInVehicle()
            game.StarterGui:SetCore("SendNotification", {
                Title = "Moving to serverhop",
                Text = "Alle Überfälle abgeschlossen, gehe zu Serverhop",
                Duration = 3,
            })

            tweenTo(SERVERHOP_POSITION)
            task.wait(1)

            -- Server-Hop aufrufen
            serverHop()

            task.wait(5)
        end
    end
end)
