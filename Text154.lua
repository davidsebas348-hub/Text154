-- ======================
-- ROLE ESP + TEXT READER FIXED
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

-- ======================
-- LIMPIAR TODO
-- ======================
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

-- ======================
-- COLOR POR ROL
-- ======================
local function getColor(role)
	if role == "Murderer" then
		return Color3.fromRGB(255, 0, 0)
	elseif role == "Sheriff" then
		return Color3.fromRGB(0, 170, 255)
	else
		return Color3.fromRGB(0, 255, 0)
	end
end

-- ======================
-- TEXTO SOLO MURDERER
-- ======================
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

-- ======================
-- ESP FIXED
-- ======================
local function updateESP(plr)
	local char = plr.Character
	if not char then return end

	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

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

	-- destruir highlight viejo para evitar partes bug
	local old = CoreGui:FindFirstChild(name)
	if old then
		old:Destroy()
	end

	local hl = Instance.new("Highlight")
	hl.Name = name
	hl.Parent = CoreGui
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.FillTransparency = 0.5
	hl.OutlineTransparency = 0
	hl.Adornee = char
	hl.FillColor = color
	hl.OutlineColor = color

	updateText(plr, role, color)
end

-- ======================
-- LOOP
-- ======================
task.spawn(function()
	while getgenv().ROLE_ESP_ENABLED do
		for _, plr in ipairs(Players:GetPlayers()) do
			updateESP(plr)
		end
		task.wait(0.15)
	end

	clearESP()
end)
