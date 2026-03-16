-- ============================================
--   APEX HUB
--   Fly | Noclip | God | Invisible
--   GUI Horizontal | Mobile Friendly
--   Fly speed up to 1500
--   Compatible: Delta, Arceus X, Fluxus
-- ============================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")

local plr  = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hrp  = char:WaitForChild("HumanoidRootPart")
local hum  = char:WaitForChild("Humanoid")

local STATE = {
    fly       = false,
    noclip    = false,
    god       = false,
    invisible = false,
    flySpeed  = 60,
    flyUp     = false,
    flyDown   = false,
    bv        = nil,
    bg        = nil,
    dragging  = false,
    dragStart = nil,
    dragFrame = nil,
    minimized = false,
    closed    = false,
}

-- ============================================
-- HAPUS GUI LAMA
-- ============================================
pcall(function()
    local old = plr.PlayerGui:FindFirstChild("ApexHub")
    if old then old:Destroy() end
end)

-- ============================================
-- GUI ROOT
-- ============================================
local sg = Instance.new("ScreenGui")
sg.Name           = "ApexHub"
sg.ResetOnSpawn   = false
sg.IgnoreGuiInset = true
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.DisplayOrder   = 999
sg.Parent         = plr.PlayerGui

-- ============================================
-- MAIN FRAME
-- ============================================
local main = Instance.new("Frame")
main.Name             = "Main"
main.Size             = UDim2.new(0, 340, 0, 44)
main.Position         = UDim2.new(0.5, -170, 1, -200)
main.BackgroundColor3 = Color3.fromRGB(8, 11, 20)
main.BorderSizePixel  = 0
main.ClipsDescendants = false
main.AutomaticSize    = Enum.AutomaticSize.Y
main.Parent           = sg
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
local mStroke = Instance.new("UIStroke", main)
mStroke.Color     = Color3.fromRGB(30, 80, 200)
mStroke.Thickness = 1.5

-- ============================================
-- TITLE BAR
-- ============================================
local titleBar = Instance.new("Frame")
titleBar.Size             = UDim2.new(1, 0, 0, 44)
titleBar.BackgroundColor3 = Color3.fromRGB(12, 16, 30)
titleBar.BorderSizePixel  = 0
titleBar.ZIndex           = 10
titleBar.Parent           = main
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

-- Fix sudut bawah title
local tbFix = Instance.new("Frame")
tbFix.Size             = UDim2.new(1, 0, 0.5, 0)
tbFix.Position         = UDim2.new(0, 0, 0.5, 0)
tbFix.BackgroundColor3 = Color3.fromRGB(12, 16, 30)
tbFix.BorderSizePixel  = 0
tbFix.ZIndex           = 10
tbFix.Parent           = titleBar

-- Accent line bawah title
local accent = Instance.new("Frame")
accent.Size             = UDim2.new(1, 0, 0, 2)
accent.Position         = UDim2.new(0, 0, 1, -2)
accent.BackgroundColor3 = Color3.fromRGB(40, 100, 255)
accent.BorderSizePixel  = 0
accent.ZIndex           = 11
accent.Parent           = titleBar

-- Title text
local titleTxt = Instance.new("TextLabel")
titleTxt.Size               = UDim2.new(1, -100, 1, 0)
titleTxt.Position           = UDim2.new(0, 12, 0, 0)
titleTxt.BackgroundTransparency = 1
titleTxt.Text               = "🚀  APEX HUB"
titleTxt.TextColor3         = Color3.fromRGB(220, 230, 255)
titleTxt.Font               = Enum.Font.GothamBold
titleTxt.TextSize           = 14
titleTxt.TextXAlignment     = Enum.TextXAlignment.Left
titleTxt.ZIndex             = 11
titleTxt.Parent             = titleBar

-- Tombol − (minimize) + X (close) di kanan
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

local function makeCtrlBtn(label, col)
    local b = Instance.new("TextButton")
    b.Size             = UDim2.new(0, 34, 0, 28)
    b.BackgroundColor3 = col
    b.Text             = label
    b.TextColor3       = Color3.new(1, 1, 1)
    b.Font             = Enum.Font.GothamBold
    b.TextSize         = 14
    b.BorderSizePixel  = 0
    b.AutoButtonColor  = false
    b.ZIndex           = 12
    b.Parent           = btnRow
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
    return b
end

local minBtn   = makeCtrlBtn("−", Color3.fromRGB(30, 50, 90))
local closeBtn = makeCtrlBtn("✕", Color3.fromRGB(160, 30, 30))

-- ============================================
-- CONTENT WRAPPER
-- ============================================
local contentWrap = Instance.new("Frame")
contentWrap.Size          = UDim2.new(1, 0, 0, 0)
contentWrap.Position      = UDim2.new(0, 0, 0, 44)
contentWrap.AutomaticSize = Enum.AutomaticSize.Y
contentWrap.BackgroundTransparency = 1
contentWrap.ZIndex        = 5
contentWrap.Parent        = main
local wLayout = Instance.new("UIListLayout")
wLayout.Padding = UDim.new(0, 6)
wLayout.Parent  = contentWrap
local wPad = Instance.new("UIPadding")
wPad.PaddingLeft   = UDim.new(0, 8)
wPad.PaddingRight  = UDim.new(0, 8)
wPad.PaddingTop    = UDim.new(0, 8)
wPad.PaddingBottom = UDim.new(0, 10)
wPad.Parent        = contentWrap

-- ============================================
-- HELPER: BUAT TOGGLE ROW
-- ============================================
local function makeToggle(icon, label, onColor, callback)
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1, 0, 0, 46)
    row.BackgroundColor3 = Color3.fromRGB(14, 18, 34)
    row.BorderSizePixel  = 0
    row.ZIndex           = 6
    row.Parent           = contentWrap
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)

    -- Icon
    local ic = Instance.new("TextLabel")
    ic.Size               = UDim2.new(0, 36, 1, 0)
    ic.Position           = UDim2.new(0, 6, 0, 0)
    ic.BackgroundTransparency = 1
    ic.Text               = icon
    ic.Font               = Enum.Font.GothamBold
    ic.TextSize           = 20
    ic.ZIndex             = 7
    ic.Parent             = row

    -- Label
    local lbl = Instance.new("TextLabel")
    lbl.Size               = UDim2.new(1, -120, 1, 0)
    lbl.Position           = UDim2.new(0, 46, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text               = label
    lbl.TextColor3         = Color3.fromRGB(200, 215, 255)
    lbl.Font               = Enum.Font.GothamBold
    lbl.TextSize           = 13
    lbl.TextXAlignment     = Enum.TextXAlignment.Left
    lbl.ZIndex             = 7
    lbl.Parent             = row

    -- Status pill
    local pill = Instance.new("Frame")
    pill.Size             = UDim2.new(0, 54, 0, 24)
    pill.Position         = UDim2.new(1, -62, 0.5, -12)
    pill.BackgroundColor3 = Color3.fromRGB(30, 40, 65)
    pill.BorderSizePixel  = 0
    pill.ZIndex           = 7
    pill.Parent           = row
    Instance.new("UICorner", pill).CornerRadius = UDim.new(0, 6)

    local pillTxt = Instance.new("TextLabel")
    pillTxt.Size               = UDim2.new(1, 0, 1, 0)
    pillTxt.BackgroundTransparency = 1
    pillTxt.Text               = "OFF"
    pillTxt.TextColor3         = Color3.fromRGB(140, 150, 180)
    pillTxt.Font               = Enum.Font.GothamBold
    pillTxt.TextSize           = 11
    pillTxt.ZIndex             = 8
    pillTxt.Parent             = pill

    local isOn = false
    local tw   = TweenInfo.new(0.15, Enum.EasingStyle.Quad)

    local function set(val)
        isOn = val
        if isOn then
            TweenService:Create(row,  tw, {BackgroundColor3 = Color3.fromRGB(14, 25, 55)}):Play()
            TweenService:Create(pill, tw, {BackgroundColor3 = onColor}):Play()
            pillTxt.Text      = "ON"
            pillTxt.TextColor3 = Color3.new(1, 1, 1)
        else
            TweenService:Create(row,  tw, {BackgroundColor3 = Color3.fromRGB(14, 18, 34)}):Play()
            TweenService:Create(pill, tw, {BackgroundColor3 = Color3.fromRGB(30, 40, 65)}):Play()
            pillTxt.Text      = "OFF"
            pillTxt.TextColor3 = Color3.fromRGB(140, 150, 180)
        end
        if callback then pcall(callback, isOn) end
    end

    -- Area klik transparan di atas semua
    local ca = Instance.new("TextButton")
    ca.Size               = UDim2.new(1, 0, 1, 0)
    ca.BackgroundTransparency = 1
    ca.Text               = ""
    ca.AutoButtonColor    = false
    ca.ZIndex             = 9
    ca.Parent             = row
    ca.MouseButton1Click:Connect(function() set(not isOn) end)

    return set
end

-- ============================================
-- HELPER: SEPARATOR
-- ============================================
local function makeSep()
    local s = Instance.new("Frame")
    s.Size             = UDim2.new(1, 0, 0, 1)
    s.BackgroundColor3 = Color3.fromRGB(25, 35, 60)
    s.BorderSizePixel  = 0
    s.ZIndex           = 6
    s.Parent           = contentWrap
end

-- ============================================
-- TOGGLE ROWS
-- ============================================

-- FLY
makeToggle("✈️", "Fly", Color3.fromRGB(0, 110, 255), function(on)
    STATE.fly = on
    if on then
        pcall(function()
            if STATE.bv and STATE.bv.Parent then STATE.bv:Destroy() end
            if STATE.bg and STATE.bg.Parent then STATE.bg:Destroy() end
            -- TIDAK pakai PlatformStand agar joystick tetap jalan
            -- Pakai AutoRotate false + BodyVelocity + BodyGyro
            hum.AutoRotate = false
            STATE.bv = Instance.new("BodyVelocity")
            STATE.bv.Velocity  = Vector3.zero
            STATE.bv.MaxForce  = Vector3.new(1e9, 1e9, 1e9)
            STATE.bv.Parent    = hrp
            STATE.bg = Instance.new("BodyGyro")
            STATE.bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
            STATE.bg.P         = 9000
            STATE.bg.D         = 100
            STATE.bg.CFrame    = hrp.CFrame
            STATE.bg.Parent    = hrp
        end)
    else
        STATE.flyUp   = false
        STATE.flyDown = false
        pcall(function()
            hum.AutoRotate = true
            if STATE.bv and STATE.bv.Parent then STATE.bv:Destroy() end
            if STATE.bg and STATE.bg.Parent then STATE.bg:Destroy() end
            STATE.bv = nil
            STATE.bg = nil
        end)
    end
end)

-- NOCLIP
makeToggle("👻", "Noclip", Color3.fromRGB(150, 0, 220), function(on)
    STATE.noclip = on
    if not on then
        pcall(function()
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end
        end)
    end
end)

-- GOD MODE
makeToggle("⚡", "God Mode", Color3.fromRGB(200, 150, 0), function(on)
    STATE.god = on
    if on then
        pcall(function()
            hum.MaxHealth = math.huge
            hum.Health    = math.huge
        end)
    else
        pcall(function()
            hum.MaxHealth = 100
            hum.Health    = 100
        end)
    end
end)

-- INVISIBLE
makeToggle("🌫️", "Invisible", Color3.fromRGB(80, 80, 160), function(on)
    STATE.invisible = on
    pcall(function()
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                p.Transparency = on and 1 or (p.Name == "HumanoidRootPart" and 1 or 0)
            elseif p:IsA("Decal") then
                p.Transparency = on and 1 or 0
            end
        end
    end)
end)

makeSep()

-- ============================================
-- FLY SPEED ROW
-- ============================================
local speedRow = Instance.new("Frame")
speedRow.Size             = UDim2.new(1, 0, 0, 46)
speedRow.BackgroundColor3 = Color3.fromRGB(14, 18, 34)
speedRow.BorderSizePixel  = 0
speedRow.ZIndex           = 6
speedRow.Parent           = contentWrap
Instance.new("UICorner", speedRow).CornerRadius = UDim.new(0, 10)

local speedIcon = Instance.new("TextLabel")
speedIcon.Size               = UDim2.new(0, 36, 1, 0)
speedIcon.Position           = UDim2.new(0, 6, 0, 0)
speedIcon.BackgroundTransparency = 1
speedIcon.Text               = "🎚️"
speedIcon.Font               = Enum.Font.GothamBold
speedIcon.TextSize           = 20
speedIcon.ZIndex             = 7
speedIcon.Parent             = speedRow

local speedTitleLbl = Instance.new("TextLabel")
speedTitleLbl.Size               = UDim2.new(0, 80, 1, 0)
speedTitleLbl.Position           = UDim2.new(0, 46, 0, 0)
speedTitleLbl.BackgroundTransparency = 1
speedTitleLbl.Text               = "Fly Speed"
speedTitleLbl.TextColor3         = Color3.fromRGB(200, 215, 255)
speedTitleLbl.Font               = Enum.Font.GothamBold
speedTitleLbl.TextSize           = 12
speedTitleLbl.TextXAlignment     = Enum.TextXAlignment.Left
speedTitleLbl.ZIndex             = 7
speedTitleLbl.Parent             = speedRow

local speedValLbl = Instance.new("TextLabel")
speedValLbl.Size               = UDim2.new(0, 50, 1, 0)
speedValLbl.Position           = UDim2.new(0, 126, 0, 0)
speedValLbl.BackgroundTransparency = 1
speedValLbl.Text               = tostring(STATE.flySpeed)
speedValLbl.TextColor3         = Color3.fromRGB(100, 200, 255)
speedValLbl.Font               = Enum.Font.GothamBold
speedValLbl.TextSize           = 13
speedValLbl.ZIndex             = 7
speedValLbl.Parent             = speedRow

-- Tombol − dan +
local function makeSpeedBtn(label, col, xOffset)
    local b = Instance.new("TextButton")
    b.Size             = UDim2.new(0, 34, 0, 30)
    b.Position         = UDim2.new(1, xOffset, 0.5, -15)
    b.BackgroundColor3 = col
    b.Text             = label
    b.TextColor3       = Color3.new(1, 1, 1)
    b.Font             = Enum.Font.GothamBold
    b.TextSize         = 18
    b.BorderSizePixel  = 0
    b.AutoButtonColor  = false
    b.ZIndex           = 8
    b.Parent           = speedRow
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
    return b
end

local sMinusBtn = makeSpeedBtn("−", Color3.fromRGB(25, 40, 75), -76)
local sPlusBtn  = makeSpeedBtn("+", Color3.fromRGB(0, 80, 190), -36)

sMinusBtn.MouseButton1Click:Connect(function()
    STATE.flySpeed = math.max(10, STATE.flySpeed - 10)
    speedValLbl.Text = tostring(STATE.flySpeed)
end)
sPlusBtn.MouseButton1Click:Connect(function()
    STATE.flySpeed = math.min(1500, STATE.flySpeed + 10)
    speedValLbl.Text = tostring(STATE.flySpeed)
end)

-- Hold untuk cepat naik/turun angka
local holdConnMinus = nil
local holdConnPlus  = nil

sMinusBtn.InputBegan:Connect(function(i)
    if i.UserInputType ~= Enum.UserInputType.Touch
    and i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    holdConnMinus = task.spawn(function()
        task.wait(0.4)
        while sMinusBtn and sMinusBtn.Parent do
            STATE.flySpeed = math.max(10, STATE.flySpeed - 10)
            speedValLbl.Text = tostring(STATE.flySpeed)
            task.wait(0.06)
        end
    end)
end)
sMinusBtn.InputEnded:Connect(function(i)
    if i.UserInputType ~= Enum.UserInputType.Touch
    and i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    if holdConnMinus then
        pcall(function() task.cancel(holdConnMinus) end)
        holdConnMinus = nil
    end
end)

sPlusBtn.InputBegan:Connect(function(i)
    if i.UserInputType ~= Enum.UserInputType.Touch
    and i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    holdConnPlus = task.spawn(function()
        task.wait(0.4)
        while sPlusBtn and sPlusBtn.Parent do
            STATE.flySpeed = math.min(1500, STATE.flySpeed + 10)
            speedValLbl.Text = tostring(STATE.flySpeed)
            task.wait(0.06)
        end
    end)
end)
sPlusBtn.InputEnded:Connect(function(i)
    if i.UserInputType ~= Enum.UserInputType.Touch
    and i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    if holdConnPlus then
        pcall(function() task.cancel(holdConnPlus) end)
        holdConnPlus = nil
    end
end)

makeSep()

-- ============================================
-- FLY NAIK / TURUN BUTTONS
-- ============================================
local flyCtrl = Instance.new("Frame")
flyCtrl.Size             = UDim2.new(1, 0, 0, 46)
flyCtrl.BackgroundColor3 = Color3.fromRGB(14, 18, 34)
flyCtrl.BorderSizePixel  = 0
flyCtrl.ZIndex           = 6
flyCtrl.Parent           = contentWrap
Instance.new("UICorner", flyCtrl).CornerRadius = UDim.new(0, 10)

local fcLbl = Instance.new("TextLabel")
fcLbl.Size               = UDim2.new(0, 110, 1, 0)
fcLbl.Position           = UDim2.new(0, 10, 0, 0)
fcLbl.BackgroundTransparency = 1
fcLbl.Text               = "✈️ Arah Terbang"
fcLbl.TextColor3         = Color3.fromRGB(100, 170, 255)
fcLbl.Font               = Enum.Font.GothamBold
fcLbl.TextSize           = 12
fcLbl.TextXAlignment     = Enum.TextXAlignment.Left
fcLbl.ZIndex             = 7
fcLbl.Parent             = flyCtrl

local function makeDirBtn(label, col, xOffset)
    local b = Instance.new("TextButton")
    b.Size             = UDim2.new(0, 72, 0, 32)
    b.Position         = UDim2.new(1, xOffset, 0.5, -16)
    b.BackgroundColor3 = col
    b.Text             = label
    b.TextColor3       = Color3.new(1, 1, 1)
    b.Font             = Enum.Font.GothamBold
    b.TextSize         = 11
    b.BorderSizePixel  = 0
    b.AutoButtonColor  = false
    b.ZIndex           = 8
    b.Parent           = flyCtrl
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    return b
end

local upBtn   = makeDirBtn("⬆  NAIK",  Color3.fromRGB(0, 90, 200), -156)
local downBtn = makeDirBtn("⬇ TURUN", Color3.fromRGB(80, 30, 150), -78)

upBtn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch
    or i.UserInputType == Enum.UserInputType.MouseButton1 then
        STATE.flyUp = true
    end
end)
upBtn.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch
    or i.UserInputType == Enum.UserInputType.MouseButton1 then
        STATE.flyUp = false
    end
end)
downBtn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch
    or i.UserInputType == Enum.UserInputType.MouseButton1 then
        STATE.flyDown = true
    end
end)
downBtn.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch
    or i.UserInputType == Enum.UserInputType.MouseButton1 then
        STATE.flyDown = false
    end
end)

makeSep()

-- ============================================
-- TIPS ROW
-- ============================================
local tipsLbl = Instance.new("TextLabel")
tipsLbl.Size               = UDim2.new(1, 0, 0, 20)
tipsLbl.BackgroundTransparency = 1
tipsLbl.Text = "💡 Joystick = maju/mundur/kiri/kanan  |  Tilt layar ke atas/bawah = naik/turun  |  NAIK TURUN = alternatif"
tipsLbl.TextColor3         = Color3.fromRGB(70, 100, 160)
tipsLbl.Font               = Enum.Font.Gotham
tipsLbl.TextSize           = 10
tipsLbl.TextXAlignment     = Enum.TextXAlignment.Left
tipsLbl.ZIndex             = 6
tipsLbl.Parent             = contentWrap

-- ============================================
-- FLY LOOP - MoveDirection world space
-- ============================================
-- ============================================
-- FLY LOOP
-- Sistem: MoveDirection (joystick) + kamera
-- Maju/mundur/kiri/kanan = joystick
-- Atas/bawah = tilt kamera ke atas/bawah
--              ATAU tombol NAIK/TURUN di GUI
-- Tidak pakai PlatformStand agar joystick jalan
-- ============================================
RunService.Heartbeat:Connect(function()
    if not STATE.fly then return end
    if not STATE.bv or not STATE.bv.Parent then return end
    if not STATE.bg or not STATE.bg.Parent then return end
    pcall(function()
        local cf       = workspace.CurrentCamera.CFrame
        local lookFull = cf.LookVector          -- arah kamera penuh (termasuk vertikal)
        local lookFlat = Vector3.new(cf.LookVector.X, 0, cf.LookVector.Z)
        local rightFlat= Vector3.new(cf.RightVector.X, 0, cf.RightVector.Z)

        if lookFlat.Magnitude  > 0 then lookFlat  = lookFlat.Unit  end
        if rightFlat.Magnitude > 0 then rightFlat = rightFlat.Unit end

        local dir = Vector3.zero

        -- MoveDirection dari joystick (aktif karena tidak pakai PlatformStand)
        local md = hum.MoveDirection
        if md.Magnitude > 0 then
            -- Komponen horizontal dari joystick, dikali arah kamera
            local mdFlat = Vector3.new(md.X, 0, md.Z)
            if mdFlat.Magnitude > 0 then
                mdFlat = mdFlat.Unit
            end
            -- Proyeksikan ke arah kamera
            local forward = lookFlat * (-md.Z)   -- joystick maju (Z negatif) = maju
            local strafe  = rightFlat * md.X      -- joystick kanan = kanan
            dir = forward + strafe

            -- ATAS BAWAH dari kamera:
            -- Kalau joystick didorong maju DAN kamera diarahkan ke atas/bawah,
            -- karakter juga naik/turun mengikuti arah pandang kamera
            -- Ini persis seperti Infinite Yield
            local camPitch = lookFull.Y  -- positif = lihat ke atas, negatif = lihat ke bawah
            dir = dir + Vector3.new(0, camPitch * math.abs(md.Z), 0)

            if dir.Magnitude > 0 then dir = dir.Unit end
        end

        -- Tombol GUI NAIK/TURUN (tambahan, selalu aktif)
        if STATE.flyUp   then dir = dir + Vector3.new(0, 1, 0) end
        if STATE.flyDown then dir = dir - Vector3.new(0, 1, 0) end

        -- Keyboard PC
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            dir = dir + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            dir = dir - Vector3.new(0, 1, 0)
        end

        -- Normalize akhir agar kecepatan konsisten
        if dir.Magnitude > 1 then dir = dir.Unit end

        STATE.bv.Velocity = dir * STATE.flySpeed

        -- Gyro: hadapkan karakter ke arah kamera (horizontal saja)
        -- agar karakter tidak miring saat lihat ke atas/bawah
        if lookFlat.Magnitude > 0 then
            STATE.bg.CFrame = CFrame.new(Vector3.zero, lookFlat)
        end
    end)
end)

-- ============================================
-- NOCLIP LOOP
-- ============================================
RunService.Stepped:Connect(function()
    if not STATE.noclip then return end
    pcall(function()
        if not char or not char.Parent then return end
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end)
end)

-- ============================================
-- GOD LOOP
-- ============================================
RunService.Heartbeat:Connect(function()
    if not STATE.god then return end
    pcall(function()
        if hum and hum.Health < hum.MaxHealth then
            hum.Health = hum.MaxHealth
        end
    end)
end)

-- ============================================
-- MINIMIZE (−)
-- ============================================
minBtn.MouseButton1Click:Connect(function()
    STATE.minimized = not STATE.minimized
    contentWrap.Visible = not STATE.minimized
    if STATE.minimized then
        main.AutomaticSize = Enum.AutomaticSize.None
        main.Size          = UDim2.new(0, 340, 0, 44)
        minBtn.Text        = "+"
    else
        main.AutomaticSize = Enum.AutomaticSize.Y
        minBtn.Text        = "−"
    end
    TweenService:Create(accent, TweenInfo.new(0.2), {
        BackgroundColor3 = STATE.minimized
            and Color3.fromRGB(50, 50, 90)
            or  Color3.fromRGB(40, 100, 255)
    }):Play()
end)

-- ============================================
-- CLOSE (✕)
-- ============================================
closeBtn.MouseButton1Click:Connect(function()
    STATE.closed = true
    -- Matikan semua fitur dulu
    STATE.fly      = false
    STATE.noclip   = false
    STATE.god      = false
    STATE.invisible = false
    STATE.flyUp    = false
    STATE.flyDown  = false
    pcall(function()
        hum.AutoRotate    = true
        hum.PlatformStand = false
        if STATE.bv and STATE.bv.Parent then STATE.bv:Destroy() end
        if STATE.bg and STATE.bg.Parent then STATE.bg:Destroy() end
        STATE.bv = nil
        STATE.bg = nil
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanCollide   = true
                p.Transparency = p.Name == "HumanoidRootPart" and 1 or 0
            elseif p:IsA("Decal") then
                p.Transparency = 0
            end
        end
        hum.MaxHealth = 100
        hum.Health    = 100
    end)
    -- Fade out lalu destroy
    TweenService:Create(main, TweenInfo.new(0.25), {
        BackgroundTransparency = 1,
        Position = main.Position + UDim2.new(0, 0, 0, 20)
    }):Play()
    task.wait(0.28)
    pcall(function() sg:Destroy() end)
end)

-- ============================================
-- DRAG (pegang title bar)
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
-- RESPAWN HANDLER
-- ============================================
plr.CharacterAdded:Connect(function(newChar)
    char = newChar
    hrp  = newChar:WaitForChild("HumanoidRootPart")
    hum  = newChar:WaitForChild("Humanoid")
    STATE.fly       = false
    STATE.noclip    = false
    STATE.god       = false
    STATE.invisible = false
    STATE.flyUp     = false
    STATE.flyDown   = false
    STATE.bv        = nil
    STATE.bg        = nil
    pcall(function() hum.AutoRotate = true end)
end)

print("✅ Apex Hub loaded!")
print("✈️  Fly speed: 10 - 1500")
print("📱 Naik/Turun: tombol di GUI | geser layar = arah")
