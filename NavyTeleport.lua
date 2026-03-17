-- ============================================
--   NAVY TP HUB
--   Teleport Pulau Sendiri + Pulau Player Lain
--   GUI Horizontal | Draggable | − X
--   Compatible: Delta, Arceus X, Fluxus
-- ============================================

local Players     = game:GetService("Players")
local TweenService= game:GetService("TweenService")

local plr  = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hrp  = char:WaitForChild("HumanoidRootPart")

local STATE = {
    dragging   = false,
    dragStart  = nil,
    dragFrame  = nil,
    minimized  = false,
}

-- ============================================
-- HAPUS GUI LAMA
-- ============================================
pcall(function()
    local old = plr.PlayerGui:FindFirstChild("NavyTPHub")
    if old then old:Destroy() end
end)

-- ============================================
-- GUI ROOT
-- ============================================
local sg = Instance.new("ScreenGui")
sg.Name           = "NavyTPHub"
sg.ResetOnSpawn   = false
sg.IgnoreGuiInset = true
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.DisplayOrder   = 999
sg.Parent         = plr.PlayerGui

-- MAIN FRAME
local main = Instance.new("Frame")
main.Name             = "Main"
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

-- TITLE BAR
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

-- Tombol − dan X
local btnRow = Instance.new("Frame")
btnRow.Size               = UDim2.new(0, 72, 0, 30)
btnRow.Position           = UDim2.new(1, -80, 0.5, -15)
btnRow.BackgroundTransparency = 1
btnRow.ZIndex             = 12
btnRow.Parent             = titleBar

local btnLayout = Instance.new("UIListLayout")
btnLayout.FillDirection     = Enum.FillDirection.Horizontal
btnLayout.VerticalAlignment = Enum.VerticalAlignment.Center
btnLayout.Padding           = UDim.new(0, 4)
btnLayout.Parent            = btnRow

local function makeCtrlBtn(txt, col)
    local b = Instance.new("TextButton")
    b.Size             = UDim2.new(0, 34, 0, 28)
    b.BackgroundColor3 = col
    b.Text             = txt
    b.TextColor3       = Color3.new(1, 1, 1)
    b.Font             = Enum.Font.GothamBold
    b.TextSize         = 15
    b.BorderSizePixel  = 0
    b.AutoButtonColor  = false
    b.ZIndex           = 13
    b.Parent           = btnRow
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
    return b
end

local minBtn   = makeCtrlBtn("−", Color3.fromRGB(25, 40, 75))
local closeBtn = makeCtrlBtn("✕", Color3.fromRGB(160, 25, 25))

-- CONTENT WRAPPER
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
-- HELPERS
-- ============================================
local function makeLabel(parent, txt, col)
    local l = Instance.new("TextLabel")
    l.Size               = UDim2.new(1, 0, 0, 20)
    l.BackgroundTransparency = 1
    l.Text               = txt
    l.TextColor3         = col or Color3.fromRGB(80, 120, 200)
    l.Font               = Enum.Font.GothamBold
    l.TextSize           = 11
    l.TextXAlignment     = Enum.TextXAlignment.Left
    l.ZIndex             = 6
    l.Parent             = parent
    return l
end

local function makeTpBtn(parent, label, col, callback)
    local b = Instance.new("TextButton")
    b.Size             = UDim2.new(1, 0, 0, 40)
    b.BackgroundColor3 = col
    b.Text             = label
    b.TextColor3       = Color3.new(1, 1, 1)
    b.Font             = Enum.Font.GothamBold
    b.TextSize         = 13
    b.BorderSizePixel  = 0
    b.AutoButtonColor  = false
    b.ZIndex           = 7
    b.Parent           = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 9)

    b.MouseButton1Click:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.08), {
            BackgroundColor3 = Color3.fromRGB(0, 30, 80)
        }):Play()
        task.wait(0.12)
        TweenService:Create(b, TweenInfo.new(0.08), {
            BackgroundColor3 = col
        }):Play()
        pcall(callback)
    end)
    return b
end

local function makeSep()
    local s = Instance.new("Frame")
    s.Size             = UDim2.new(1, 0, 0, 1)
    s.BackgroundColor3 = Color3.fromRGB(20, 35, 65)
    s.BorderSizePixel  = 0
    s.ZIndex           = 6
    s.Parent           = content
end

-- ============================================
-- TELEPORT HELPER
-- ============================================

-- Cek apakah objek adalah karakter player
local function isPlayerCharacter(obj)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character == obj then return true end
    end
    return false
end

-- Kata kunci pulau/tycoon
local ISLAND_KW = {
    "island", "base", "plot", "tycoon",
    "pulau", "territory", "zone", "outpost",
    "area", "station", "port", "dock",
}

-- Cari BasePart/Model di workspace root (bukan karakter)
local function findIslandPart(targetName)
    -- Pass 1: nama mengandung nama player
    for _, obj in ipairs(workspace:GetChildren()) do
        if not isPlayerCharacter(obj) then
            local n = obj.Name:lower()
            if targetName and n:find(targetName:lower(), 1, true) then
                local part = (obj:IsA("BasePart") and obj)
                    or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
                if part then return part end
            end
        end
    end

    -- Pass 2: cari model dengan StringValue Owner = nama player
    if targetName then
        for _, obj in ipairs(workspace:GetChildren()) do
            if not isPlayerCharacter(obj) and obj:IsA("Model") then
                local n = obj.Name:lower()
                local isIsland = false
                for _, kw in ipairs(ISLAND_KW) do
                    if n:find(kw, 1, true) then isIsland = true break end
                end
                if isIsland then
                    for _, val in ipairs(obj:GetDescendants()) do
                        if val:IsA("StringValue") then
                            local vn = val.Name:lower()
                            if vn == "owner" or vn == "playername"
                            or vn == "ownername" or vn == "player" then
                                if val.Value:lower() == targetName:lower() then
                                    local part = obj.PrimaryPart
                                        or obj:FindFirstChildWhichIsA("BasePart")
                                    if part then return part end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- Pass 3: keyword island di workspace root, pastikan tidak dekat karakter manapun
    local charPositions = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            local h = p.Character:FindFirstChild("HumanoidRootPart")
            if h then table.insert(charPositions, h.Position) end
        end
    end

    local function nearAnyChar(pos)
        for _, cp in ipairs(charPositions) do
            if (pos - cp).Magnitude < 25 then return true end
        end
        return false
    end

    for _, obj in ipairs(workspace:GetChildren()) do
        if not isPlayerCharacter(obj) then
            local n = obj.Name:lower()
            for _, kw in ipairs(ISLAND_KW) do
                if n:find(kw, 1, true) then
                    local part = (obj:IsA("BasePart") and obj)
                        or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
                    if part and not nearAnyChar(part.Position) then
                        return part
                    end
                    break
                end
            end
        end
    end

    return nil
end

-- Teleport 70 studs di atas posisi
local function safeTP(pos)
    hrp.CFrame = CFrame.new(Vector3.new(pos.X, pos.Y + 70, pos.Z))
end

-- ============================================
-- SECTION: PULAU SENDIRI
-- ============================================
makeLabel(content, "  ── Pulaumu ──", Color3.fromRGB(0, 180, 90))

makeTpBtn(content, "🏝️  Teleport ke Pulau Sendiri", Color3.fromRGB(0, 100, 50), function()
    local myName = plr.Name:lower()

    -- Cari nama mengandung username dulu
    local part = findIslandPart(plr.Name)
    if part then
        safeTP(part.Position)
        return
    end

    -- Fallback: cari keyword island terdekat dari posisi kita
    local myPos = hrp.Position
    local best, bestDist = nil, math.huge
    for _, obj in ipairs(workspace:GetChildren()) do
        if not isPlayerCharacter(obj) then
            local n = obj.Name:lower()
            for _, kw in ipairs(ISLAND_KW) do
                if n:find(kw, 1, true) then
                    local p2 = (obj:IsA("BasePart") and obj)
                        or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
                    if p2 then
                        local dist = (myPos - p2.Position).Magnitude
                        if dist < bestDist then
                            bestDist = dist
                            best = p2
                        end
                    end
                    break
                end
            end
        end
    end

    if best then
        safeTP(best.Position)
    end
end)

makeSep()

-- ============================================
-- SECTION: PULAU PLAYER LAIN
-- Container yang bisa di-refresh
-- ============================================
makeLabel(content, "  ── Pulau Player Lain ──", Color3.fromRGB(60, 130, 255))

-- Frame khusus untuk tombol player
local playerContainer = Instance.new("Frame")
playerContainer.Size          = UDim2.new(1, 0, 0, 0)
playerContainer.AutomaticSize = Enum.AutomaticSize.Y
playerContainer.BackgroundTransparency = 1
playerContainer.ZIndex        = 5
playerContainer.Parent        = content

local pcLayout = Instance.new("UIListLayout")
pcLayout.Padding = UDim.new(0, 5)
pcLayout.Parent  = playerContainer

-- Fungsi build tombol player
local function buildPlayerButtons()
    -- Hapus tombol lama
    for _, c in ipairs(playerContainer:GetChildren()) do
        if not c:IsA("UIListLayout") then c:Destroy() end
    end

    local others = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= plr then table.insert(others, p) end
    end

    if #others == 0 then
        local noLbl = Instance.new("TextLabel")
        noLbl.Size               = UDim2.new(1, 0, 0, 30)
        noLbl.BackgroundTransparency = 1
        noLbl.Text               = "  (Tidak ada player lain)"
        noLbl.TextColor3         = Color3.fromRGB(70, 90, 140)
        noLbl.Font               = Enum.Font.Gotham
        noLbl.TextSize           = 11
        noLbl.TextXAlignment     = Enum.TextXAlignment.Left
        noLbl.ZIndex             = 6
        noLbl.Parent             = playerContainer
        return
    end

    for _, target in ipairs(others) do
        local tName = target.Name
        local btn = Instance.new("TextButton")
        btn.Size             = UDim2.new(1, 0, 0, 40)
        btn.BackgroundColor3 = Color3.fromRGB(0, 55, 130)
        btn.Text             = "🏝️  " .. tName
        btn.TextColor3       = Color3.new(1, 1, 1)
        btn.Font             = Enum.Font.GothamBold
        btn.TextSize         = 13
        btn.BorderSizePixel  = 0
        btn.AutoButtonColor  = false
        btn.ZIndex           = 7
        btn.Parent           = playerContainer
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
                local part = findIslandPart(tName)
                if part then
                    safeTP(part.Position)
                else
                    -- Tidak ketemu pulau, tidak TP ke orangnya
                    -- Coba cari lagi dengan cara lain: scan semua model
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if not isPlayerCharacter(obj) then
                            local n = obj.Name:lower()
                            if n:find(tName:lower(), 1, true) then
                                local p2 = obj:IsA("BasePart") and obj
                                    or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
                                if p2 then
                                    safeTP(p2.Position)
                                    return
                                end
                            end
                        end
                    end
                end
            end)
        end)
    end
end

buildPlayerButtons()

makeSep()

-- Tombol Refresh
makeTpBtn(content, "🔄  Refresh Daftar Player", Color3.fromRGB(20, 45, 90), function()
    buildPlayerButtons()
end)

-- ============================================
-- AUTO REFRESH saat player join/leave
-- ============================================
Players.PlayerAdded:Connect(function()
    task.wait(1)
    buildPlayerButtons()
end)

Players.PlayerRemoving:Connect(function()
    task.wait(0.5)
    buildPlayerButtons()
end)

-- ============================================
-- MINIMIZE (−)
-- ============================================
minBtn.MouseButton1Click:Connect(function()
    STATE.minimized = not STATE.minimized
    content.Visible = not STATE.minimized
    if STATE.minimized then
        main.AutomaticSize = Enum.AutomaticSize.None
        main.Size          = UDim2.new(0, 320, 0, 44)
        minBtn.Text        = "+"
    else
        main.AutomaticSize = Enum.AutomaticSize.Y
        minBtn.Text        = "−"
    end
    TweenService:Create(accent, TweenInfo.new(0.2), {
        BackgroundColor3 = STATE.minimized
            and Color3.fromRGB(40, 40, 80)
            or  Color3.fromRGB(0, 100, 255)
    }):Play()
end)

-- ============================================
-- CLOSE (✕)
-- ============================================
closeBtn.MouseButton1Click:Connect(function()
    STATE.closed = true
    TweenService:Create(main, TweenInfo.new(0.2), {
        BackgroundTransparency = 1
    }):Play()
    task.wait(0.22)
    pcall(function() sg:Destroy() end)
end)

-- ============================================
-- DRAG
-- ============================================
titleBar.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.Touch
    or inp.UserInputType == Enum.UserInputType.MouseButton1 then
        STATE.dragging = true
        STATE.dragStart = inp.Position
        STATE.dragFrame = main.Position
    end
end)

titleBar.InputChanged:Connect(function(inp)
    if not STATE.dragging then return end
    if inp.UserInputType == Enum.UserInputType.Touch
    or inp.UserInputType == Enum.UserInputType.MouseMovement then
        pcall(function()
            local d = inp.Position - STATE.dragStart
            main.Position = UDim2.new(
                STATE.dragFrame.X.Scale, STATE.dragFrame.X.Offset + d.X,
                STATE.dragFrame.Y.Scale, STATE.dragFrame.Y.Offset + d.Y
            )
        end)
    end
end)

titleBar.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.Touch
    or inp.UserInputType == Enum.UserInputType.MouseButton1 then
        STATE.dragging = false
    end
end)

-- ============================================
-- RESPAWN
-- ============================================
plr.CharacterAdded:Connect(function(newChar)
    char = newChar
    hrp  = newChar:WaitForChild("HumanoidRootPart")
end)

-- ============================================
-- AUTO REFRESH TIAP 10 DETIK
-- ============================================

-- Countdown label
local countdownLbl = Instance.new("TextLabel")
countdownLbl.Size               = UDim2.new(1, 0, 0, 18)
countdownLbl.BackgroundTransparency = 1
countdownLbl.Text               = "🔄 Auto refresh dalam 10 detik..."
countdownLbl.TextColor3         = Color3.fromRGB(50, 80, 140)
countdownLbl.Font               = Enum.Font.Gotham
countdownLbl.TextSize           = 10
countdownLbl.TextXAlignment     = Enum.TextXAlignment.Left
countdownLbl.ZIndex             = 6
countdownLbl.Parent             = content

task.spawn(function()
    local countdown = 10
    while not STATE.closed do
        countdown = countdown - 1
        pcall(function()
            if countdown > 0 then
                countdownLbl.Text = "🔄 Auto refresh dalam " .. countdown .. " detik..."
            else
                countdownLbl.Text = "🔄 Refreshing..."
                buildPlayerButtons()
                countdown = 10
            end
        end)
        task.wait(1)
    end
end)

print("✅ Navy TP Hub loaded! Auto refresh tiap 10 detik.")
