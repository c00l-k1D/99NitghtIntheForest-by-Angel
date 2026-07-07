-- ================================================================
-- FLY FLY? ULTIMATE | BY ANGEL (v4 – с анализатором еды)
-- Версия 4.0 – сканер еды, копирование в буфер, исправлен телепорт
-- ================================================================

-- 1. ЗАГРУЖАЕМ RAYFIELD
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

if not Rayfield then
    print("❌ Rayfield не загружена! Создаём fallback...")
    local sg = Instance.new("ScreenGui")
    sg.Name = "FlyFlyFallback"
    sg.Parent = game.CoreGui
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0, 300, 0, 150)
    f.Position = UDim2.new(0.5, -150, 0.5, -75)
    f.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    f.BorderSizePixel = 0
    f.Parent = sg
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "Rayfield не загружена\nНо скрипт работает!\nУправление через консоль (F9)"
    lbl.TextColor3 = Color3.new(1, 1, 1)
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
    LoadingSubtitle = "Ultimate Edition v4",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "FlyFlyUltimate",
        FileName = "FlyFlyUltimate"
    },
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
local function getCharacter()
    return LocalPlayer.Character
end

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
    flyBodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
    flyBodyVelocity.Parent = root

    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    flyBodyGyro.Parent = root
    flyBodyGyro.CFrame = root.CFrame

    local moveDir = Vector3.new(0, 0, 0)
    local shiftPressed = false

    local con1 = UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.W then moveDir = moveDir + Vector3.new(0, 0, -1) end
        if input.KeyCode == Enum.KeyCode.S then moveDir = moveDir + Vector3.new(0, 0, 1) end
        if input.KeyCode == Enum.KeyCode.A then moveDir = moveDir + Vector3.new(-1, 0, 0) end
        if input.KeyCode == Enum.KeyCode.D then moveDir = moveDir + Vector3.new(1, 0, 0) end
        if input.KeyCode == Enum.KeyCode.Space then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
            shiftPressed = true
        end
    end)

    local con2 = UserInputService.InputEnded:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.W then moveDir = moveDir - Vector3.new(0, 0, -1) end
        if input.KeyCode == Enum.KeyCode.S then moveDir = moveDir - Vector3.new(0, 0, 1) end
        if input.KeyCode == Enum.KeyCode.A then moveDir = moveDir - Vector3.new(-1, 0, 0) end
        if input.KeyCode == Enum.KeyCode.D then moveDir = moveDir - Vector3.new(1, 0, 0) end
        if input.KeyCode == Enum.KeyCode.Space then moveDir = moveDir - Vector3.new(0, 1, 0) end
        if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
            shiftPressed = false
        end
    end)

    local con3 = RunService.Heartbeat:Connect(function()
        if not flyEnabled or not root or not root.Parent then return end
        local cam = Workspace.CurrentCamera
        local forward = cam.CFrame.LookVector * Vector3.new(1, 0, 1)
        forward = forward.Unit
        local right = cam.CFrame.RightVector * Vector3.new(1, 0, 1)
        right = right.Unit
        local up = Vector3.new(0, 1, 0)
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
    for _, conn in ipairs(flyConnections) do
        conn:Disconnect()
    end
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
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
    end
end

-- 8. ТЕЛЕПОРТ ЕДЫ
local function teleportFood(keyword)
    if not keyword or keyword == "" or keyword == "custom" then
        Rayfield:Notify({ Title = "Ошибка", Content = "Выберите конкретный тип еды", Duration = 2 })
        return
    end
    keyword = keyword:lower()
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
    local targetPos = root.Position
    local count = 0

    for _, obj in ipairs(Workspace:GetDescendants()) do
        local isPart = obj:IsA("BasePart")
        local isModel = obj:IsA("Model") and obj.PrimaryPart
        if isPart or isModel then
            local name = obj.Name:lower()
            if name:find(keyword) then
                if not obj:IsDescendantOf(char) then
                    if isPart then
                        obj.CFrame = CFrame.new(targetPos + Vector3.new(0, 2, 0))
                    else
                        obj.PrimaryPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 2, 0))
                    end
                    count = count + 1
                    task.wait(0.02)
                end
            end
        end
    end

    if count > 0 then
        Rayfield:Notify({ Title = "Телепорт еды", Content = "Телепортировано " .. count .. " объектов с '" .. keyword .. "'", Duration = 3 })
    else
        Rayfield:Notify({ Title = "Телепорт еды", Content = "Объекты с '" .. keyword .. "' не найдены", Duration = 3 })
    end
end

-- 9. АНАЛИЗАТОР ЕДЫ (СКАНИРУЕТ КАРТУ И КОПИРУЕТ СПИСОК)
local function scanFoodObjects()
    local keywords = {
        "food", "berry", "meat", "donut", "cake", "fruit", "bread", "mushroom",
        "apple", "pizza", "sandwich", "burger", "sushi", "steak", "pie", "cookie",
        "chocolate", "icecream", "pancake", "waffle", "milk", "egg", "cheese",
        "ham", "bacon", "sausage", "chicken", "fish", "crab", "lobster", "shrimp",
        "pasta", "rice", "noodle", "soup", "salad", "taco", "burrito", "nachos",
        "popcorn", "pretzel", "donut", "cupcake", "muffin", "brownie", "pie",
        "candy", "lollipop", "gum", "mint", "tea", "coffee", "juice", "soda",
        "water", "milk", "smoothie", "shake", "pancake", "waffle", "crepe"
    }
    local found = {}
    local char = getCharacter()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or (obj:IsA("Model") and obj.PrimaryPart) then
            local name = obj.Name:lower()
            -- Проверяем, содержит ли имя хотя бы одно ключевое слово
            for _, kw in ipairs(keywords) do
                if name:find(kw) then
                    -- Исключаем части персонажа
                    if not char or not obj:IsDescendantOf(char) then
                        found[obj.Name] = true
                    end
                    break
                end
            end
        end
    end
    local names = {}
    for name, _ in pairs(found) do
        table.insert(names, name)
    end
    table.sort(names)
    local result = table.concat(names, ", ")
    -- Копируем в буфер обмена
    local success, err = pcall(function()
        setclipboard(result)
    end)
    if success then
        Rayfield:Notify({ Title = "Анализатор еды", Content = "Найдено " .. #names .. " объектов. Список скопирован в буфер обмена!", Duration = 4 })
    else
        Rayfield:Notify({ Title = "Анализатор еды", Content = "Найдено " .. #names .. " объектов. Скопируйте список из консоли (F9)", Duration = 4 })
        print("=== Найденные объекты еды ===")
        for _, name in ipairs(names) do
            print(name)
        end
        print("=== Конец списка ===")
    end
end

-- 10. GUI – FLIGHT
FlightTab:CreateToggle({
    Name = "Режим полёта",
    CurrentValue = false,
    Flag = "Fly",
    Callback = function(v)
        if v then
            startFly()
            Rayfield:Notify({ Title = "Полёт", Content = "Включён", Duration = 2 })
        else
            stopFly()
            Rayfield:Notify({ Title = "Полёт", Content = "Выключен", Duration = 2 })
        end
    end
})

FlightTab:CreateSlider({
    Name = "Скорость полёта",
    Range = {10, 200},
    Increment = 1,
    Suffix = "studs/s",
    CurrentValue = 50,
    Flag = "FlySpeed",
    Callback = function(v)
        flySpeed = v
    end
})

-- 11. GUI – NOCLIP
NoclipTab:CreateToggle({
    Name = "Noclip (проход сквозь стены)",
    CurrentValue = false,
    Flag = "Noclip",
    Callback = function(v)
        toggleNoclip(v)
        Rayfield:Notify({ Title = "Noclip", Content = v and "Включён" or "Выключен", Duration = 2 })
    end
})

-- 12. GUI – FOOD (расширенный список + кнопка анализа)
local foodOptions = {
    "food", "berry", "meat", "donut", "cake", "fruit", "bread", "mushroom",
    "apple", "pizza", "sandwich", "burger", "sushi", "steak", "pie", "cookie",
    "chocolate", "icecream", "pancake", "waffle", "milk", "egg", "cheese",
    "ham", "bacon", "sausage", "chicken", "fish", "crab", "lobster", "shrimp",
    "pasta", "rice", "noodle", "soup", "salad", "taco", "burrito", "nachos",
    "popcorn", "pretzel", "cupcake", "muffin", "brownie", "candy", "lollipop",
    "gum", "mint", "tea", "coffee", "juice", "soda", "water", "smoothie",
    "shake", "crepe", "custom"
}
FoodTab:CreateDropdown({
    Name = "Тип еды",
    Options = foodOptions,
    CurrentOption = "food",
    Flag = "FoodType",
    Callback = function(option)
        if option == "custom" then
            Rayfield:Notify({ Title = "Ввод", Content = "Введите своё ключевое слово в поле ниже", Duration = 2 })
        end
        print("[Food] Выбран тип:", option)
    end
})

FoodTab:CreateInput({
    Name = "Своё ключевое слово",
    PlaceholderText = "Введите название (если выбран custom)",
    CurrentValue = "",
    Flag = "CustomFoodKeyword",
    Callback = function(v)
        print("[Food] Пользовательское слово:", v)
    end
})

FoodTab:CreateButton({
    Name = "Телепортировать всю еду к себе",
    Callback = function()
        local selected = Rayfield:GetFlag("FoodType") or "food"
        local keyword = selected
        if selected == "custom" then
            keyword = Rayfield:GetFlag("CustomFoodKeyword") or ""
            if keyword == "" then
                Rayfield:Notify({ Title = "Ошибка", Content = "Введите своё ключевое слово в поле ниже", Duration = 2 })
                return
            end
        end
        teleportFood(keyword)
    end
})

-- КНОПКА АНАЛИЗАТОРА
FoodTab:CreateButton({
    Name = "Анализировать еду на карте и скопировать список",
    Callback = function()
        scanFoodObjects()
    end
})

-- 13. GUI – SETTINGS
SettingsTab:CreateButton({
    Name = "Наш Telegram: t.me/pussydrinking",
    Callback = function()
        local success, err = pcall(function()
            setclipboard("https://t.me/pussydrinking")
        end)
        if success then
            Rayfield:Notify({ Title = "Telegram", Content = "Ссылка скопирована в буфер обмена!", Duration = 3 })
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

SettingsTab:CreateLabel("Версия: 4.0 (с анализатором)")
SettingsTab:CreateLabel("Автор: Angel")
SettingsTab:CreateLabel("Telegram: @pussydrinking")

-- 14. УВЕДОМЛЕНИЕ О ЗАГРУЗКЕ
Rayfield:Notify({
    Title = "Fly Fly? | by Angel",
    Content = "Скрипт загружен! Используйте анализатор для поиска еды.",
    Duration = 5
})

print("✅ Fly Fly? Ultimate v4 загружен!")
