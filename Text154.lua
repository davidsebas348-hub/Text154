-- ======================
-- ESP INNOCENT (OPTIMIZADO SIN LOOP)
-- ======================

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ======================
-- TOGGLE GLOBAL
-- ======================
_G.InnocentESP = not _G.InnocentESP

-- ======================
-- LIMPIAR ESP
-- ======================
local function clearESP(player)
	if player.Character then
		local h = player.Character:FindFirstChild("InnocentESP")
		if h then h:Destroy() end
	end
end

if not _G.InnocentESP then
	for _, plr in ipairs(Players:GetPlayers()) do
		clearESP(plr)
	end
	warn("❌ ESP INNOCENT DESACTIVADO")
	return
end

warn("✅ ESP INNOCENT ACTIVADO")

-- ======================
-- VERIFICAR INNOCENT
-- ======================
local function isInnocent(player)

	local hasKnife = false
	local hasGun = false

	local function check(container)
		if not container then return end
		for _, t in ipairs(container:GetChildren()) do
			if t:IsA("Tool") then
				if t.Name == "Knife" then
					hasKnife = true
				end
				if t.Name == "Gun" or t.Name == "Pistol" then
					hasGun = true
				end
			end
		end
	end

	check(player.Character)
	check(player:FindFirstChild("Backpack"))

	return not hasKnife and not hasGun
end

-- ======================
-- CREAR ESP
-- ======================
local function applyESP(player)
	if not _G.InnocentESP then return end
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
-- ACTUALIZAR ESTADO
-- ======================
local function updatePlayer(player)
	if not _G.InnocentESP then return end
	if player == LocalPlayer then return end
	if not player.Character then return end

	local humanoid = player.Character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health <= 0 then
		clearESP(player)
		return
	end

	if isInnocent(player) then
		applyESP(player)
	else
		clearESP(player)
	end
end

-- ======================
-- MONITOREAR JUGADOR
-- ======================
local function monitorPlayer(player)
	if player == LocalPlayer then return end

	local function connectContainer(container)
		if not container then return end

		container.ChildAdded:Connect(function()
			updatePlayer(player)
		end)

		container.ChildRemoved:Connect(function()
			updatePlayer(player)
		end)
	end

	-- Backpack
	connectContainer(player:WaitForChild("Backpack"))

	-- Character
	if player.Character then
		connectContainer(player.Character)
		updatePlayer(player)
	end

	player.CharacterAdded:Connect(function(char)
		connectContainer(char)

		local humanoid = char:WaitForChild("Humanoid")
		humanoid.Died:Connect(function()
			clearESP(player)
		end)

		task.wait(0.2)
		updatePlayer(player)
	end)

	-- Check inicial
	updatePlayer(player)
end

-- ======================
-- APLICAR A TODOS
-- ======================
for _, plr in ipairs(Players:GetPlayers()) do
	monitorPlayer(plr)
end

Players.PlayerAdded:Connect(monitorPlayer)
