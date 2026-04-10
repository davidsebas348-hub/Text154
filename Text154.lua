-- ======================
-- ROLE ESP + TEXT READER
-- ======================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local roleTable = getgenv().ROLE_TABLE or {}

getgenv().ROLE_ESP_ENABLED = not getgenv().ROLE_ESP_ENABLED

if getgenv().HIGHLIGHT_ME == nil then
    getgenv().HIGHLIGHT_ME = true
end

local ESP_PREFIX = "ROLE_ESP_"
local TEXT_PREFIX = "ROLE_TEXT_"

local function clearESP()
    for _, v in ipairs(CoreGui:GetChildren()) do
        if v.Name:match("^" .. ESP_PREFIX) or v.Name:match("^" .. TEXT_PREFIX) then
            v:Destroy()
        end
    end
end

if not getgenv().ROLE_ESP_ENABLED then
    clearESP()
    return
end

local function getColor(role)
    if role == "Murderer" then
        return Color3.fromRGB(255, 0, 0)
    elseif role == "Sheriff" then
        return Color3.fromRGB(0, 170, 255)
    else
        return Color3.fromRGB(0, 255, 0)
    end
end

local function updateText(plr, role, color)
    local name = TEXT_PREFIX .. plr.Name
    local existing = CoreGui:FindFirstChild(name)

    if role ~= "Murderer" then
        if existing then
            existing:Destroy()
        end
        return
    end

    local char = plr.Character
    if not char then return end

    local head = char:FindFirstChild("Head")
    if not head then return end

    local bill = existing

    if not bill then
        bill = Instance.new("BillboardGui")
        bill.Name = name
        bill.Size = UDim2.new(0, 100, 0, 35)
        bill.StudsOffset = Vector3.new(0, 2.5, 0)
        bill.AlwaysOnTop = true
        bill.Parent = CoreGui

        local txt = Instance.new("TextLabel")
        txt.Name = "Label"
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.BackgroundTransparency = 1
        txt.TextScaled = true
        txt.Font = Enum.Font.GothamBold
        txt.TextStrokeTransparency = 0
        txt.TextStrokeColor3 = Color3.new(0, 0, 0)
        txt.Parent = bill
    end

    bill.Adornee = head

    local txt = bill:FindFirstChild("Label")
    if txt then
        txt.Text = "Murderer"
        txt.TextColor3 = color
    end
end

local function updateESP(plr)
    local char = plr.Character
    if not char then return end

    if plr == LocalPlayer and not getgenv().HIGHLIGHT_ME then
        local old = CoreGui:FindFirstChild(ESP_PREFIX .. plr.Name)
        if old then old:Destroy() end

        local txt = CoreGui:FindFirstChild(TEXT_PREFIX .. plr.Name)
        if txt then txt:Destroy() end
        return
    end

    local role = roleTable[plr.Name] or "Innocent"
    local color = getColor(role)

    local name = ESP_PREFIX .. plr.Name
    local hl = CoreGui:FindFirstChild(name)

    if not hl then
        hl = Instance.new("Highlight")
        hl.Name = name
        hl.Parent = CoreGui
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.FillTransparency = 0.5
        hl.OutlineTransparency = 0
    end

    hl.Adornee = char
    hl.FillColor = color
    hl.OutlineColor = color

    updateText(plr, role, color)
end

task.spawn(function()
    while getgenv().ROLE_ESP_ENABLED do
        for _, plr in ipairs(Players:GetPlayers()) do
            updateESP(plr)
        end
        task.wait(0.2)
    end

    clearESP()
end)
