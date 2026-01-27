-- ======================
-- ESP INNOCENT (TOGGLE POR EJECUCIÓN)
-- ======================

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ======================
-- TOGGLE GLOBAL
-- ======================
_G.InnocentESP = not _G.InnocentESP

-- ======================
-- FUNCIÓN LIMPIAR TODO
-- ======================
local function ClearESP()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Character then
			local h = plr.Character:FindFirstChild("InnocentESP")
			if h then h:Destroy() end
		end
	end
end

-- ======================
-- SI SE DESACTIVA
-- ======================
if not _G.InnocentESP then
	if _G.InnocentESPConnection then
		_G.InnocentESPConnection:Disconnect()
		_G.InnocentESPConnection = nil
	end
	ClearESP()
	warn("❌ ESP INNOCENT DESACTIVADO")
	return
end

warn("✅ ESP INNOCENT ACTIVADO")

-- ======================
-- FUNCIONES
-- ======================
local function isInnocent(player)
	if not player then return false end
	local hasKnife = false
	local hasGun = false

	local function check(container)
		if not container then return end
		for _, t in ipairs(container:GetChildren()) do
			if t:IsA("Tool") then
				if t.Name == "Knife" then hasKnife = true end
				if t.Name == "Gun" or t.Name == "Pistol" then hasGun = true end
			end
		end
	end

	check(player.Character)
	check(player:FindFirstChild("Backpack"))

	return not hasKnife and not hasGun
end

local function applyESP(player)
	if not player.Character then return end
	if player.Character:FindFirstChild("InnocentESP") then return end

	local h = Instance.new("Highlight")
	h.Name = "InnocentESP"
	h.Adornee = player.Character
	h.FillColor = Color3.fromRGB(0,255,0)
	h.OutlineColor = Color3.fromRGB(0,255,0)
	h.FillTransparency = 0.5
	h.OutlineTransparency = 0
	h.Parent = player.Character
end

-- ======================
-- LOOP ÚNICO Y CONTROLADO
-- ======================
_G.InnocentESPConnection = RunService.RenderStepped:Connect(function()
	if not _G.InnocentESP then return end

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") then
			if plr.Character.Humanoid.Health <= 0 then
				local h = plr.Character:FindFirstChild("InnocentESP")
				if h then h:Destroy() end
			else
				if isInnocent(plr) then
					applyESP(plr)
				else
					local h = plr.Character:FindFirstChild("InnocentESP")
					if h then h:Destroy() end
				end
			end
		end
	end
end)
