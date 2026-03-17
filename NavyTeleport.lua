-- ============================================
--   NAVY TP HUB v2
--   Teleport Pulau Sendiri + Pulau Player Lain
--   Auto Refresh 10 detik
--   GUI Horizontal | Draggable | - X
--   Compatible: Delta, Arceus X, Fluxus
-- ============================================

local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local plr  = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hrp  = char:WaitForChild("HumanoidRootPart")

local isRunning  = true
local isMinimized = false
local isDragging  = false
local dragStart   = nil
local dragFrame   = nil

-- ============================================
-- HAPUS GUI LAMA
-- ============================================
pcall(function()
    local old = plr.PlayerGui:FindFirstChild("NavyTPHub")
    if old then old:Destroy() end
end)

-- ============================================
-- GUI
-- ============================================
local sg = Instance.new("ScreenGui")
sg.Name           = "NavyTPHub"
sg.ResetOnSpawn   = false
sg.IgnoreGuiInset = true
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.DisplayOrder   = 999
sg.Parent         = plr.PlayerGui

local main = Instance.new("Frame")
main.Size             = UDim2.new(0, 320, 0, 44)
main.Position         = UDim2.new(0.5, -160, 1, -200)
main.BackgroundColor3 = Color3.fromRGB(8, 11, 20)
main.BorderSizePixel  = 0
main.ClipsDescendants = false
main.AutomaticSize    = Enum.AutomaticSize.Y
main.Parent           = sg
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
local mStroke = Instance.new("UIStroke", main)
mStroke.Color     = Color3.fromRGB(0, 80, 200)
mStroke.Thickness = 1.5

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Size             = UDim2.new(1, 0, 0, 44)
titleBar.BackgroundColor3 = Color3.fromRGB(12, 16, 30)
titleBar.BorderSizePixel  = 0
titleBar.ZIndex           = 10
titleBar.Parent           = main
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

local tbFix = Instance.new("Frame")
tbFix.Size             = UDim2.new(1, 0, 0.5, 0)
tbFix.Position         = UDim2.new(0, 0, 0.5, 0)
tbFix.BackgroundColor3 = Color3.fromRGB(12, 16, 30)
tbFix.BorderSizePixel  = 0
tbFix.ZIndex           = 10
tbFix.Parent           = titleBar

local accent = Instance.new("Frame")
accent.Size             = UDim2.new(1, 0, 0, 2)
accent.Position         = UDim2.new(0, 0, 1, -2)
accent.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
accent.BorderSizePixel  = 0
accent.ZIndex           = 11
accent.Parent           = titleBar

local titleTxt = Instance.new("TextLabel")
titleTxt.Size               = UDim2.new(1, -90, 1, 0)
titleTxt.Position           = UDim2.new(0, 12, 0, 0)
titleTxt.BackgroundTransparency = 1
titleTxt.Text               = "⚓ NAVY TP HUB"
titleTxt.TextColor3         = Color3.fromRGB(220, 230, 255)
titleTxt.Font               = Enum.Font.GothamBold
titleTxt.TextSize           = 14
titleTxt.TextXAlignment     = Enum.TextXAlignment.Left
titleTxt.ZIndex             = 11
titleTxt.Parent             = titleBar

-- Tombol - dan X
local btnFrame = Instance.new("Frame")
btnFrame.Size               = UDim2.new(0, 74, 0, 30)
btnFrame.Position           = UDim2.new(1, -82, 0.5, -15)
btnFrame.BackgroundTransparency = 1
btnFrame.ZIndex             = 12
btnFrame.Parent             = titleBar
local btnLayout = Instance.new("UIListLayout")
btnLayout.FillDirection     = Enum.FillDirection.Horizontal
btnLayout.VerticalAlignment = Enum.VerticalAlignment.Center
btnLayout.Padding           = UDim.new(0, 4)
btnLayout.Parent            = btnFrame

local minBtn = Instance.new("TextButton")
minBtn.Size             = UDim2.new(0, 34, 0, 28)
minBtn.BackgroundColor3 = Color3.fromRGB(25, 40, 75)
minBtn.Text             = "-"
minBtn.TextColor3       = Color3.new(1, 1, 1)
minBtn.Font             = Enum.Font.GothamBold
minBtn.TextSize         = 18
minBtn.BorderSizePixel  = 0
minBtn.AutoButtonColor  = false
minBtn.ZIndex           = 13
minBtn.Parent           = btnFrame
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 7)

local closeBtn = Instance.new("TextButton")
closeBtn.Size             = UDim2.new(0, 34, 0, 28)
closeBtn.BackgroundColor3 = Color3.fromRGB(160, 25, 25)
closeBtn.Text             = "x"
closeBtn.TextColor3       = Color3.new(1, 1, 1)
closeBtn.Font             = Enum.Font.GothamBold
closeBtn.TextSize         = 14
closeBtn.BorderSizePixel  = 0
closeBtn.AutoButtonColor  = false
closeBtn.ZIndex           = 13
closeBtn.Parent           = btnFrame
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 7)

-- Content area
local content = Instance.new("Frame")
content.Size          = UDim2.new(1, 0, 0, 0)
content.Position      = UDim2.new(0, 0, 0, 44)
content.AutomaticSize = Enum.AutomaticSize.Y
content.BackgroundTransparency = 1
content.ZIndex        = 5
content.Parent        = main
local cLayout = Instance.new("UIListLayout")
cLayout.Padding = UDim.new(0, 6)
cLayout.Parent  = content
local cPad = Instance.new("UIPadding")
cPad.PaddingLeft   = UDim.new(0, 8)
cPad.PaddingRight  = UDim.new(0, 8)
cPad.PaddingTop    = UDim.new(0, 8)
cPad.PaddingBottom = UDim.new(0, 10)
cPad.Parent        = content

-- ============================================
-- HELPER FUNCTIONS
-- ============================================
local function makeLabel(txt, col)
    local l = Instance.new("TextLabel")
    l.Size               = UDim2.new(1, 0, 0, 20)
    l.BackgroundTransparency = 1
    l.Text               = txt
    l.TextColor3         = col or Color3.fromRGB(80, 120, 200)
    l.Font               = Enum.Font.GothamBold
    l.TextSize           = 11
    l.TextXAlignment     = Enum.TextXAlignment.Left
    l.ZIndex             = 6
    l.Parent             = content
    return l
end

local function makeSep()
    local s = Instance.new("Frame")
    s.Size             = UDim2.new(1, 0, 0, 1)
    s.BackgroundColor3 = Color3.fromRGB(20, 35, 65)
    s.BorderSizePixel  = 0
    s.ZIndex           = 6
    s.Parent           = content
end

local function makeTpBtn(lbl, col, cb)
    local b = Instance.new("TextButton")
    b.Size             = UDim2.new(1, 0, 0, 40)
    b.BackgroundColor3 = col
    b.Text             = lbl
    b.TextColor3       = Color3.new(1, 1, 1)
    b.Font             = Enum.Font.GothamBold
    b.TextSize         = 13
    b.BorderSizePixel  = 0
    b.AutoButtonColor  = false
    b.ZIndex           = 7
    b.Parent           = content
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 9)
    b.MouseButton1Click:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.08), {
            BackgroundColor3 = Color3.fromRGB(0, 25, 70)
        }):Play()
        task.wait(0.12)
        TweenService:Create(b, TweenInfo.new(0.08), {
            BackgroundColor3 = col
        }):Play()
        pcall(cb)
    end)
    return b
end

-- ============================================
-- TELEPORT FUNCTIONS
-- ============================================
local ISLAND_KW = {
    "island","base","plot","tycoon",
    "pulau","territory","zone","outpost",
    "area","station","port","dock",
}

local function isCharacter(obj)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character == obj then return true end
    end
    return false
end

local function getPart(obj)
    if obj:IsA("BasePart") then return obj end
    if obj:IsA("Model") then
        return obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
    end
    return nil
end

local function safeTP(pos)
    hrp.CFrame = CFrame.new(Vector3.new(pos.X, pos.Y + 70, pos.Z))
end

local function findIsland(targetName)
    local tlow = targetName and targetName:lower() or nil

    -- Pass 1: nama obj mengandung nama player
    if tlow then
        for _, obj in ipairs(workspace:GetChildren()) do
            if not isCharacter(obj) then
                if obj.Name:lower():find(tlow, 1, true) then
                    local part = getPart(obj)
                    if part then return part.Position end
                end
            end
        end
    end

    -- Pass 2: StringValue Owner di dalam model island
    if tlow then
        for _, obj in ipairs(workspace:GetChildren()) do
            if not isCharacter(obj) and obj:IsA("Model") then
                local n = obj.Name:lower()
                local ok = false
                for _, kw in ipairs(ISLAND_KW) do
                    if n:find(kw, 1, true) then ok = true break end
                end
                if ok then
                    for _, v in ipairs(obj:GetDescendants()) do
                        if v:IsA("StringValue") then
                            local vn = v.Name:lower()
                            if vn == "owner" or vn == "playername"
                            or vn == "ownername" or vn == "player" then
                                if v.Value:lower() == tlow then
                                    local part = getPart(obj)
                                    if part then return part.Position end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- Pass 3: keyword island, hindari posisi dekat karakter
    local charPos = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            local h = p.Character:FindFirstChild("HumanoidRootPart")
            if h then table.insert(charPos, h.Position) end
        end
    end

    local function nearChar(pos)
        for _, cp in ipairs(charPos) do
            if (pos - cp).Magnitude < 30 then return true end
        end
        return false
    end

    for _, obj in ipairs(workspace:GetChildren()) do
        if not isCharacter(obj) then
            local n = obj.Name:lower()
            for _, kw in ipairs(ISLAND_KW) do
                if n:find(kw, 1, true) then
                    local part = getPart(obj)
                    if part and not nearChar(part.Position) then
                        return part.Position
                    end
                    break
                end
            end
        end
    end

    return nil
end

-- ============================================
-- SECTION: PULAU SENDIRI
-- ============================================
makeLabel("  -- Pulaumu --", Color3.fromRGB(0, 180, 90))

makeTpBtn("🏝  Teleport ke Pulau Sendiri", Color3.fromRGB(0, 100, 50), function()
    local pos = findIsland(plr.Name)
    if pos then
        safeTP(pos)
    else
        -- fallback: island terdekat
        local best, bestDist = nil, math.huge
        for _, obj in ipairs(workspace:GetChildren()) do
            if not isCharacter(obj) then
                local n = obj.Name:lower()
                for _, kw in ipairs(ISLAND_KW) do
                    if n:find(kw, 1, true) then
                        local part = getPart(obj)
                        if part then
                            local d = (hrp.Position - part.Position).Magnitude
                            if d < bestDist then
                                bestDist = d
                                best = part.Position
                            end
                        end
                        break
                    end
                end
            end
        end
        if best then safeTP(best) end
    end
end)

makeSep()

-- ============================================
-- SECTION: PULAU PLAYER LAIN
-- ============================================
makeLabel("  -- Pulau Player Lain --", Color3.fromRGB(60, 130, 255))

-- Container tombol player
local playerBox = Instance.new("Frame")
playerBox.Size          = UDim2.new(1, 0, 0, 0)
playerBox.AutomaticSize = Enum.AutomaticSize.Y
playerBox.BackgroundTransparency = 1
playerBox.ZIndex        = 5
playerBox.Parent        = content
local pbLayout = Instance.new("UIListLayout")
pbLayout.Padding = UDim.new(0, 5)
pbLayout.Parent  = playerBox

-- Build tombol per player
local function buildButtons()
    for _, c in ipairs(playerBox:GetChildren()) do
        if not c:IsA("UIListLayout") then c:Destroy() end
    end

    local others = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= plr then table.insert(others, p) end
    end

    if #others == 0 then
        local nl = Instance.new("TextLabel")
        nl.Size               = UDim2.new(1, 0, 0, 30)
        nl.BackgroundTransparency = 1
        nl.Text               = "  (Tidak ada player lain)"
        nl.TextColor3         = Color3.fromRGB(60, 80, 130)
        nl.Font               = Enum.Font.Gotham
        nl.TextSize           = 11
        nl.TextXAlignment     = Enum.TextXAlignment.Left
        nl.ZIndex             = 6
        nl.Parent             = playerBox
        return
    end

    for _, target in ipairs(others) do
        local tName = target.Name
        local btn = Instance.new("TextButton")
        btn.Size             = UDim2.new(1, 0, 0, 40)
        btn.BackgroundColor3 = Color3.fromRGB(0, 55, 130)
        btn.Text             = "🏝  " .. tName
        btn.TextColor3       = Color3.new(1, 1, 1)
        btn.Font             = Enum.Font.GothamBold
        btn.TextSize         = 13
        btn.BorderSizePixel  = 0
        btn.AutoButtonColor  = false
        btn.ZIndex           = 7
        btn.Parent           = playerBox
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 9)

        btn.MouseButton1Click:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.08), {
                BackgroundColor3 = Color3.fromRGB(0, 25, 70)
            }):Play()
            task.wait(0.12)
            TweenService:Create(btn, TweenInfo.new(0.08), {
                BackgroundColor3 = Color3.fromRGB(0, 55, 130)
            }):Play()
            pcall(function()
                local pos = findIsland(tName)
                if pos then safeTP(pos) end
            end)
        end)
    end
end

buildButtons()

makeSep()

-- Refresh manual
makeTpBtn("🔄  Refresh Daftar Player", Color3.fromRGB(20, 45, 90), function()
    buildButtons()
end)

-- Countdown label
local countLbl = Instance.new("TextLabel")
countLbl.Size               = UDim2.new(1, 0, 0, 18)
countLbl.BackgroundTransparency = 1
countLbl.Text               = "🔄 Auto refresh dalam 10 detik..."
countLbl.TextColor3         = Color3.fromRGB(45, 70, 130)
countLbl.Font               = Enum.Font.Gotham
countLbl.TextSize           = 10
countLbl.TextXAlignment     = Enum.TextXAlignment.Left
countLbl.ZIndex             = 6
countLbl.Parent             = content

-- ============================================
-- AUTO REFRESH LOOP 10 DETIK
-- ============================================
task.spawn(function()
    local t = 10
    while isRunning do
        task.wait(1)
        t = t - 1
        pcall(function()
            if t > 0 then
                countLbl.Text = "🔄 Auto refresh dalam " .. t .. " detik..."
            else
                countLbl.Text = "🔄 Refreshing..."
                buildButtons()
                t = 10
            end
        end)
    end
end)

-- ============================================
-- MINIMIZE
-- ============================================
minBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    content.Visible = not isMinimized
    if isMinimized then
        main.AutomaticSize = Enum.AutomaticSize.None
        main.Size          = UDim2.new(0, 320, 0, 44)
        minBtn.Text        = "+"
    else
        main.AutomaticSize = Enum.AutomaticSize.Y
        minBtn.Text        = "-"
    end
    TweenService:Create(accent, TweenInfo.new(0.2), {
        BackgroundColor3 = isMinimized
            and Color3.fromRGB(40, 40, 80)
            or  Color3.fromRGB(0, 100, 255)
    }):Play()
end)

-- ============================================
-- CLOSE
-- ============================================
closeBtn.MouseButton1Click:Connect(function()
    isRunning = false
    TweenService:Create(main, TweenInfo.new(0.2), {
        BackgroundTransparency = 1
    }):Play()
    task.wait(0.25)
    pcall(function() sg:Destroy() end)
end)

-- ============================================
-- DRAG
-- ============================================
titleBar.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.Touch
    or inp.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = true
        dragStart  = inp.Position
        dragFrame  = main.Position
    end
end)
titleBar.InputChanged:Connect(function(inp)
    if not isDragging then return end
    if inp.UserInputType == Enum.UserInputType.Touch
    or inp.UserInputType == Enum.UserInputType.MouseMovement then
        pcall(function()
            local d = inp.Position - dragStart
            main.Position = UDim2.new(
                dragFrame.X.Scale, dragFrame.X.Offset + d.X,
                dragFrame.Y.Scale, dragFrame.Y.Offset + d.Y
            )
        end)
    end
end)
titleBar.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.Touch
    or inp.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = false
    end
end)

-- ============================================
-- PLAYER JOIN/LEAVE
-- ============================================
Players.PlayerAdded:Connect(function()
    task.wait(1)
    pcall(buildButtons)
end)
Players.PlayerRemoving:Connect(function()
    task.wait(0.5)
    pcall(buildButtons)
end)

-- ============================================
-- RESPAWN
-- ============================================
plr.CharacterAdded:Connect(function(newChar)
    char = newChar
    hrp  = newChar:WaitForChild("HumanoidRootPart")
end)

print("✅ Navy TP Hub v2 loaded!")
