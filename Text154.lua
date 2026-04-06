local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

if getgenv().HIGHLIGHT_ME == nil then
    getgenv().HIGHLIGHT_ME = true
end


getgenv().ROLE_ESP_ENABLED = not getgenv().ROLE_ESP_ENABLED



local ESP_PREFIX = "MM2_ROLE_ESP_"
local TEXT_PREFIX = "MM2_ROLE_TEXT_"

local playerData = {}
local watchingGunDrop = false
local gunWatcherConnection = nil

local function clearAllESP()
	for _, obj in ipairs(CoreGui:GetChildren()) do
		if obj.Name:match("^" .. ESP_PREFIX) or obj.Name:match("^" .. TEXT_PREFIX) then
			obj:Destroy()
		end
	end
end

if not getgenv().ROLE_ESP_ENABLED then
	clearAllESP()
	return
end

local function getRoleByTool(plr)
	if plr.Backpack:FindFirstChild("Knife") then
		return "Murderer"
	end

	if plr.Backpack:FindFirstChild("Gun") then
		return "Sheriff"
	end

	if plr.Character then
		if plr.Character:FindFirstChild("Knife") then
			return "Murderer"
		end

		if plr.Character:FindFirstChild("Gun") then
			return "Sheriff"
		end
	end

	return nil
end

local function getRole(plr)
	local toolRole = getRoleByTool(plr)
	if toolRole then
		return toolRole
	end

	if playerData[plr.Name] and playerData[plr.Name].Role then
		return playerData[plr.Name].Role
	end

	return "Innocent"
end

local function hasSheriff()
	for _, plr in ipairs(Players:GetPlayers()) do
		if getRole(plr) == "Sheriff" then
			return true
		end
	end
	return false
end

local function getMapModel()
	for _, obj in ipairs(workspace:GetChildren()) do
		if obj:IsA("Model") and obj:FindFirstChild("Spawns") then
			return obj
		end
	end
	return nil
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
		txt.Size = UDim2.new(1,0,1,0)
		txt.BackgroundTransparency = 1
		txt.TextScaled = true
		txt.Font = Enum.Font.GothamBold
		txt.TextStrokeTransparency = 0
		txt.TextStrokeColor3 = Color3.new(0,0,0)
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
	if plr == LocalPlayer and not getgenv().HIGHLIGHT_ME then
    local old = CoreGui:FindFirstChild(ESP_PREFIX .. plr.Name)
    if old then
        old:Destroy()
    end

    local txt = CoreGui:FindFirstChild(TEXT_PREFIX .. plr.Name)
    if txt then
        txt:Destroy()
    end

    return
end

	local char = plr.Character
	if not char then return end

	local role = getRole(plr)

	local color = Color3.fromRGB(0,255,0)

	if role == "Murderer" then
		color = Color3.fromRGB(255,0,0)
	elseif role == "Sheriff" then
		color = Color3.fromRGB(0,170,255)
	end

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

local function reloadESP()
	for _, plr in ipairs(Players:GetPlayers()) do
		updateESP(plr)
	end
end

local function watchGunDropIfNoSheriff()
	if hasSheriff() then
		return
	end

	if watchingGunDrop then
		return
	end

	local map = getMapModel()
	if not map then
		return
	end

	local gunDrop = map:FindFirstChild("GunDrop")
	if not gunDrop then
		return
	end

	watchingGunDrop = true

	if gunWatcherConnection then
		gunWatcherConnection:Disconnect()
	end

	gunWatcherConnection = gunDrop.AncestryChanged:Connect(function(_, parent)
		if not parent then
			watchingGunDrop = false
			task.wait(0.2)
			reloadESP()
		end
	end)
end

RS:WaitForChild("Remotes")
	:WaitForChild("Gameplay")
	:WaitForChild("PlayerDataChanged", 5)
	.OnClientEvent:Connect(function(data)
		playerData = data
		reloadESP()
		watchGunDropIfNoSheriff()
	end)

Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function()
		task.wait(0.5)
		reloadESP()
	end)
end)

task.spawn(function()
	while getgenv().ROLE_ESP_ENABLED do
		reloadESP()
		watchGunDropIfNoSheriff()
		task.wait(0.2)
	end
end)

reloadESP()
watchGunDropIfNoSheriff()
