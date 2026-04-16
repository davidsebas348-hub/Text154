-- ======================
-- ROLE ESP + TEXT READER PRO (STABLE FIX)
-- ======================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local roleTable = getgenv().ROLE_TABLE or {}

getgenv().ROLE_ESP_ENABLED = getgenv().ROLE_ESP_ENABLED or false

-- 🔥 TOGGLE AUTOMÁTICO AL EJECUTAR SCRIPT
getgenv().ROLE_ESP_ENABLED = not getgenv().ROLE_ESP_ENABLED
getgenv().HIGHLIGHT_ME = (getgenv().HIGHLIGHT_ME == nil) and true or getgenv().HIGHLIGHT_ME

local ESP_PREFIX = "ROLE_ESP_"
local TEXT_PREFIX = "ROLE_TEXT_"

-- ======================
-- VALIDACIONES
-- ======================
local function isValidPlayer(plr)
	return plr and Players:FindFirstChild(plr.Name)
end

local function isValidCharacter(plr)
	local char = plr.Character
	if not char then return false end
	if not char:FindFirstChildOfClass("Humanoid") then return false end
	if not char:FindFirstChild("Head") then return false end
	return true
end

-- ======================
-- CLEAN SOLO SEGURO
-- ======================
local function cleanupESP()
	for _, plr in ipairs(Players:GetPlayers()) do
		if not isValidPlayer(plr) then
			local esp = CoreGui:FindFirstChild(ESP_PREFIX .. plr.Name)
			local txt = CoreGui:FindFirstChild(TEXT_PREFIX .. plr.Name)

			if esp then esp:Destroy() end
			if txt then txt:Destroy() end
		end
	end
end

-- ======================
-- TEXTO MURDER SIN DUPES
-- ======================
local function updateText(plr, role, color, alive)
	if not isValidPlayer(plr) or not isValidCharacter(plr) then return end

	local char = plr.Character
	local head = char:FindFirstChild("Head")
	if not head then return end

	local name = TEXT_PREFIX .. plr.Name
	local gui = CoreGui:FindFirstChild(name)

	if role ~= "Murderer" or alive ~= true then
		if gui then gui:Destroy() end
		return
	end

	if gui then
		gui.Adornee = head
		local label = gui:FindFirstChild("Label")
		if label then
			label.Text = "Murderer"
			label.TextColor3 = color
		end
		return
	end

	gui = Instance.new("BillboardGui")
	gui.Name = name
	gui.Size = UDim2.new(0, 100, 0, 35)
	gui.StudsOffset = Vector3.new(0, 2.5, 0)
	gui.AlwaysOnTop = true
	gui.Adornee = head
	gui.Parent = CoreGui

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.TextStrokeTransparency = 0
	label.TextStrokeColor3 = Color3.new(0,0,0)
	label.Text = "Murderer"
	label.TextColor3 = color
	label.Parent = gui
end

-- ======================
-- ESP PRINCIPAL
-- ======================
local function updateESP(plr)
	if not isValidPlayer(plr) then return end
	if not isValidCharacter(plr) then return end

	-- 🔥 SELF FIX
	if plr == LocalPlayer then
		local esp = CoreGui:FindFirstChild(ESP_PREFIX .. plr.Name)
		local txt = CoreGui:FindFirstChild(TEXT_PREFIX .. plr.Name)

		if getgenv().HIGHLIGHT_ME then
			-- normal
		else
			if esp then esp:Destroy() end
			if txt then txt:Destroy() end
			return
		end
	end

	local data = roleTable[plr.Name]

	local role = "Waiting"
	local color = Color3.fromRGB(120,120,120)
	local alive = false

	if data then
		role = data.Role or role
		color = data.Color or color
		alive = data.Alive
	end

	local name = ESP_PREFIX .. plr.Name
	local char = plr.Character

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

	updateText(plr, role, color, alive)
end

-- ======================
-- 🔥 FIX TOGGLE REAL (ESTO ES LO IMPORTANTE)
-- ======================
task.spawn(function()
	while true do

		if getgenv().ROLE_ESP_ENABLED then
			for _, plr in ipairs(Players:GetPlayers()) do
				updateESP(plr)
			end
		else
			-- 🔥 BORRAR TODO INSTANTE CUANDO ESTÁ OFF
			for _, v in ipairs(CoreGui:GetChildren()) do
				if v.Name:match("^ROLE_ESP_") or v.Name:match("^ROLE_TEXT_") then
					v:Destroy()
				end
			end
		end

		task.wait(0.25)
	end
end)
