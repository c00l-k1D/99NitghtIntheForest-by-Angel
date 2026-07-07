-- ================================================================
-- FLY FLY? | BY ANGEL (v7.0 – телепорт к еде, без ESP и анализа)
-- ================================================================

-- 1. ЗАГРУЖАЕМ RAYFIELD
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

if not Rayfield then
    print("❌ Rayfield не загружена! Fallback...")
    local sg = Instance.new("ScreenGui")
    sg.Name = "FlyFlyFallback"
    sg.Parent = game.CoreGui
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0, 300, 0, 150)
    f.Position = UDim2.new(0.5, -150, 0.5, -75)
    f.BackgroundColor3 = Color3.fromRGB(20,20,30)
    f.BorderSizePixel = 0
    f.Parent = sg
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "Rayfield не загружена\nНо скрипт работает!\nУправление через консоль (F9)"
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.TextSize = 16
    lbl.TextWrapped = true
    lbl.Font = Enum.Font.Gotham
    lbl.Parent = f
    return
end

-- 2. ОКНО
local Window = Rayfield:CreateWindow({
    Name = "Fly Fly? | by Angel",
    LoadingTitle = "Загрузка...",
    LoadingSubtitle = "v7.0",
    ConfigurationSaving = { Enabled = true, FolderName = "FlyFlyAngel", FileName = "FlyFlyAngel" },
    KeySystem = false
})

-- 3. ВКЛАДКИ
local FlightTab = Window:CreateTab("Flight", 4483362458)
local NoclipTab = Window:CreateTab("Noclip", 4483362458)
local FoodTab = Window:CreateTab("Food", 4483362458)
local SettingsTab = Window:CreateTab("Settings", 4483362458)

-- 4. ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local flyEnabled = false
local flySpeed = 50
local noclipEnabled = false

local flyBodyVelocity, flyBodyGyro
local flyConnections = {}
local noclipConnection = nil

-- 5. ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
local function getCharacter() return LocalPlayer.Character end
local function getRootPart()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end
local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChild("Humanoid")
end

-- 6. ПОЛЁТ
local function startFly()
    local root = getRootPart()
    local hum = getHumanoid()
    if not root or not hum then return end
    flyEnabled = true
    hum.PlatformStand = true
    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.MaxForce = Vector3.new(1e9,1e9,1e9)
    flyBodyVelocity.Velocity = Vector3.new(0,0,0)
    flyBodyVelocity.Parent = root
    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.MaxTorque = Vector3.new(1e9,1e9,1e9)
    flyBodyGyro.Parent = root
    flyBodyGyro.CFrame = root.CFrame
    local moveDir = Vector3.new(0,0,0)
    local shiftPressed = false
    local con1 = UserInputService.InputBegan:Connect(function(input,gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.W then moveDir = moveDir + Vector3.new(0,0,-1) end
        if input.KeyCode == Enum.KeyCode.S then moveDir = moveDir + Vector3.new(0,0,1) end
        if input.KeyCode == Enum.KeyCode.A then moveDir = moveDir + Vector3.new(-1,0,0) end
        if input.KeyCode == Enum.KeyCode.D then moveDir = moveDir + Vector3.new(1,0,0) end
        if input.KeyCode == Enum.KeyCode.Space then moveDir = moveDir + Vector3.new(0,1,0) end
        if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then shiftPressed = true end
    end)
    local con2 = UserInputService.InputEnded:Connect(function(input,gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.W then moveDir = moveDir - Vector3.new(0,0,-1) end
        if input.KeyCode == Enum.KeyCode.S then moveDir = moveDir - Vector3.new(0,0,1) end
        if input.KeyCode == Enum.KeyCode.A then moveDir = moveDir - Vector3.new(-1,0,0) end
        if input.KeyCode == Enum.KeyCode.D then moveDir = moveDir - Vector3.new(1,0,0) end
        if input.KeyCode == Enum.KeyCode.Space then moveDir = moveDir - Vector3.new(0,1,0) end
        if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then shiftPressed = false end
    end)
    local con3 = RunService.Heartbeat:Connect(function()
        if not flyEnabled or not root or not root.Parent then return end
        local cam = Workspace.CurrentCamera
        local forward = cam.CFrame.LookVector * Vector3.new(1,0,1)
        forward = forward.Unit
        local right = cam.CFrame.RightVector * Vector3.new(1,0,1)
        right = right.Unit
        local up = Vector3.new(0,1,0)
        local vel = (forward * -moveDir.Z + right * moveDir.X + up * moveDir.Y) * flySpeed
        if shiftPressed then vel = vel - up * flySpeed * 0.5 end
        if flyBodyVelocity then flyBodyVelocity.Velocity = vel end
        if flyBodyGyro then flyBodyGyro.CFrame = cam.CFrame end
    end)
    flyConnections = {con1, con2, con3}
end

local function stopFly()
    flyEnabled = false
    local hum = getHumanoid()
    if hum then hum.PlatformStand = false end
    if flyBodyVelocity then flyBodyVelocity:Destroy(); flyBodyVelocity = nil end
    if flyBodyGyro then flyBodyGyro:Destroy(); flyBodyGyro = nil end
    for _, conn in ipairs(flyConnections) do conn:Disconnect() end
    flyConnections = {}
end

-- 7. NOCLIP
local function toggleNoclip(state)
    noclipEnabled = state
    if noclipEnabled then
        if noclipConnection then noclipConnection:Disconnect() end
        noclipConnection = RunService.Heartbeat:Connect(function()
            local char = getCharacter()
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    else
        if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
    end
end

-- 8. ПОИСК БЛИЖАЙШЕЙ ЕДЫ
local function findClosestFood(keyword)
    keyword = keyword:lower()
    local root = getRootPart()
    if not root then return nil, math.huge end
    local pos = root.Position
    local closest = nil
    local minDist = math.huge
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local name = obj.Name
            if type(name) == "string" and name:lower():find(keyword) then
                local objPos
                if obj:IsA("BasePart") then
                    objPos = obj.Position
                elseif obj:IsA("Model") and obj.PrimaryPart then
                    objPos = obj.PrimaryPart.Position
                else
                    local firstPart = obj:FindFirstChildOfClass("BasePart")
                    if firstPart then objPos = firstPart.Position end
                end
                if objPos then
                    local dist = (objPos - pos).Magnitude
                    if dist < minDist then
                        minDist = dist
                        closest = obj
                    end
                end
            end
        end
    end
    return closest, minDist
end

-- 9. ТЕЛЕПОРТ ИГРОКА К БЛИЖАЙШЕЙ ЕДЕ
local function teleportToFood(keyword)
    if type(keyword) ~= "string" then
        Rayfield:Notify({ Title = "Ошибка", Content = "Неверный тип ключевого слова", Duration = 2 })
        return
    end
    keyword = keyword:lower()
    if keyword == "" or keyword == "custom" then
        Rayfield:Notify({ Title = "Ошибка", Content = "Выберите конкретный тип еды", Duration = 2 })
        return
    end

    local char = getCharacter()
    if not char then
        Rayfield:Notify({ Title = "Ошибка", Content = "Персонаж не найден", Duration = 2 })
        return
    end
    local root = getRootPart()
    if not root then
        Rayfield:Notify({ Title = "Ошибка", Content = "RootPart не найден", Duration = 2 })
        return
    end

    local target, dist = findClosestFood(keyword)
    if not target then
        Rayfield:Notify({ Title = "Ошибка", Content = "Нет еды с ключевым словом '" .. keyword .. "'", Duration = 2 })
        return
    end

    local targetPart
    if target:IsA("BasePart") then
        targetPart = target
    elseif target:IsA("Model") and target.PrimaryPart then
        targetPart = target.PrimaryPart
    else
        targetPart = target:FindFirstChildOfClass("BasePart")
    end

    if not targetPart then
        Rayfield:Notify({ Title = "Ошибка", Content = "Не удалось определить часть для взаимодействия", Duration = 2 })
        return
    end

    root.CFrame = targetPart.CFrame + Vector3.new(0, 1, 0)
    Rayfield:Notify({ Title = "Телепорт", Content = "Перемещён к '" .. keyword .. "'", Duration = 2 })
end

-- 10. СЪЕСТЬ ЕДУ (телепорт + симуляция касания)
local function eatFood(keyword)
    if type(keyword) ~= "string" then
        Rayfield:Notify({ Title = "Ошибка", Content = "Неверный тип ключевого слова", Duration = 2 })
        return
    end
    keyword = keyword:lower()
    if keyword == "" or keyword == "custom" then
        Rayfield:Notify({ Title = "Ошибка", Content = "Выберите конкретный тип еды", Duration = 2 })
        return
    end

    local char = getCharacter()
    if not char then
        Rayfield:Notify({ Title = "Ошибка", Content = "Персонаж не найден", Duration = 2 })
        return
    end
    local root = getRootPart()
    if not root then
        Rayfield:Notify({ Title = "Ошибка", Content = "RootPart не найден", Duration = 2 })
        return
    end

    local target, dist = findClosestFood(keyword)
    if not target then
        Rayfield:Notify({ Title = "Ошибка", Content = "Нет еды с ключевым словом '" .. keyword .. "'", Duration = 2 })
        return
    end

    local targetPart
    if target:IsA("BasePart") then
        targetPart = target
    elseif target:IsA("Model") and target.PrimaryPart then
        targetPart = target.PrimaryPart
    else
        targetPart = target:FindFirstChildOfClass("BasePart")
    end

    if not targetPart then
        Rayfield:Notify({ Title = "Ошибка", Content = "Не удалось определить часть для взаимодействия", Duration = 2 })
        return
    end

    -- Телепорт к еде
    root.CFrame = targetPart.CFrame + Vector3.new(0, 1, 0)
    task.wait(0.1)

    -- Симуляция касания
    local playerPart = root
    local success, err = pcall(function()
        firetouchinterest(playerPart, targetPart, 0)
        task.wait(0.05)
        firetouchinterest(playerPart, targetPart, 1)
    end)

    if success then
        Rayfield:Notify({ Title = "Еда", Content = "Съедена!", Duration = 2 })
    else
        -- Fallback: эмулируем клавишу E
        local virtualUser = game:GetService("VirtualUser")
        virtualUser:CaptureController()
        virtualUser:SetKeyDown(Enum.KeyCode.E)
        task.wait(0.1)
        virtualUser:SetKeyUp(Enum.KeyCode.E)
        Rayfield:Notify({ Title = "Еда", Content = "Попытка съесть (клавиша E)", Duration = 2 })
    end
end

-- 11. GUI – FLIGHT
FlightTab:CreateToggle({
    Name = "Режим полёта",
    CurrentValue = false,
    Flag = "Fly",
    Callback = function(v)
        if v then startFly() else stopFly() end
        Rayfield:Notify({ Title = "Полёт", Content = v and "Включён" or "Выключен", Duration = 2 })
    end
})
FlightTab:CreateSlider({
    Name = "Скорость полёта",
    Range = {10, 200},
    Increment = 1,
    Suffix = "studs/s",
    CurrentValue = 50,
    Flag = "FlySpeed",
    Callback = function(v) flySpeed = v end
})

-- 12. GUI – NOCLIP
NoclipTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "Noclip",
    Callback = function(v)
        toggleNoclip(v)
        Rayfield:Notify({ Title = "Noclip", Content = v and "Включён" or "Выключен", Duration = 2 })
    end
})

-- 13. GUI – FOOD
local foodOptions = {
    "Apple", "Apple.001", "AppleZone", "Apple_Slice", "Apple_SliceZone",
    "Berry", "BerryZone", "Berry_Cake75", "Bread", "Bread.001",
    "BreadZone", "Bread_Slice", "Bread_SliceZone", "DesertFruit",
    "DragonFruit", "Fish", "FoodNpcTestZone", "FoodZone_Ambrozy",
    "FoodZone_Banana", "FoodZone_GoldApple", "FoodZone_GoldPoop",
    "FoodZone_Rasberry", "FoodZone_Star", "GoldApple", "Meat",
    "MeatZone", "MeatZone1", "MeatZone2", "MeatZone3", "Mushroom",
    "MushroomZone", "Mushroom_2", "Mushroom_2Zone", "Mushroom_2Zone1",
    "Mushroom_2Zone2", "Mushroom_2Zone3", "Pineapple", "Poop_Food",
    "Rasberry", "RottenFish", "Strawberry", "StrawberryZone",
    "WaterMelon", "WaterPond", "WaterPond1", "WaterPond2",
    "Watermelon", "WatermelonBlue", "custom"
}
FoodTab:CreateDropdown({
    Name = "Тип еды",
    Options = foodOptions,
    CurrentOption = "Apple",
    Flag = "FoodType",
    Callback = function(option)
        if option == "custom" then
            Rayfield:Notify({ Title = "Ввод", Content = "Введите своё ключевое слово в поле ниже", Duration = 2 })
        end
    end
})
FoodTab:CreateInput({
    Name = "Своё ключевое слово",
    PlaceholderText = "Введите название (если выбран custom)",
    CurrentValue = "",
    Flag = "CustomFoodKeyword"
})
FoodTab:CreateButton({
    Name = "Телепорт к ближайшей еде",
    Callback = function()
        local selected = Rayfield.Flags["FoodType"]
        if type(selected) ~= "string" then selected = "Apple" end
        local keyword = selected
        if selected == "custom" then
            keyword = Rayfield.Flags["CustomFoodKeyword"]
            if type(keyword) ~= "string" or keyword == "" then
                Rayfield:Notify({ Title = "Ошибка", Content = "Введите своё ключевое слово", Duration = 2 })
                return
            end
        end
        teleportToFood(keyword)
    end
})
FoodTab:CreateButton({
    Name = "Подойти и съесть еду",
    Callback = function()
        local selected = Rayfield.Flags["FoodType"]
        if type(selected) ~= "string" then selected = "Apple" end
        local keyword = selected
        if selected == "custom" then
            keyword = Rayfield.Flags["CustomFoodKeyword"]
            if type(keyword) ~= "string" or keyword == "" then
                Rayfield:Notify({ Title = "Ошибка", Content = "Введите своё ключевое слово", Duration = 2 })
                return
            end
        end
        eatFood(keyword)
    end
})

-- 14. GUI – SETTINGS
SettingsTab:CreateButton({
    Name = "Наш Telegram: t.me/pussydrinking",
    Callback = function()
        local success = pcall(function() setclipboard("https://t.me/pussydrinking") end)
        if success then
            Rayfield:Notify({ Title = "Telegram", Content = "Ссылка скопирована!", Duration = 3 })
        else
            Rayfield:Notify({ Title = "Telegram", Content = "t.me/pussydrinking (скопируйте вручную)", Duration = 4 })
        end
    end
})
SettingsTab:CreateButton({
    Name = "Закрыть скрипт",
    Callback = function()
        if flyEnabled then stopFly() end
        if noclipEnabled then toggleNoclip(false) end
        local gui = Window.Gui
        if gui then gui:Destroy() end
        print("🛑 Fly Fly? скрипт закрыт")
    end
})
SettingsTab:CreateButton({
    Name = "Сбросить настройки",
    Callback = function()
        Rayfield:Notify({ Title = "Сброс", Content = "Перезапустите скрипт", Duration = 2 })
    end
})
SettingsTab:CreateLabel("Версия: 7.0 (телепорт к еде)")
SettingsTab:CreateLabel("Автор: Angel")
SettingsTab:CreateLabel("Telegram: @pussydrinking")

-- 15. ФИНАЛ
Rayfield:Notify({ Title = "Fly Fly? | by Angel", Content = "Скрипт загружен! Телепорт к еде работает.", Duration = 5 })
print("✅ Fly Fly? by Angel v7.0 загружен!")
