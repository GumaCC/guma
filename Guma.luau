local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local oldGui = playerGui:FindFirstChild("GumaPanel")
if oldGui then
	oldGui:Destroy()
end

local RANGE = 3500
local DEPTH = workspace.FallenPartsDestroyHeight + 50
local active = false
local home = nil

local spinOn = false
local spinAngle = 0
local SPIN_STEP = math.rad(150)

local syncPause = 0.5
local syncOn = false
local syncing = false
local syncToken = 0
local stayTime = 0.5

local uiVisible = true
local locked = false

local RED = Color3.fromRGB(255, 40, 40)
local DARK = Color3.fromRGB(10, 10, 10)
local WHITE = Color3.new(1, 1, 1)

local BUTTON_W = 100
local BUTTON_H = 32

local gradients = {}

local gui = Instance.new("ScreenGui")
gui.Name = "GumaPanel"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local function style(obj, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = radius
	c.Parent = obj

	local s = Instance.new("UIStroke")
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Color = WHITE
	s.Thickness = 2
	s.Parent = obj

	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, RED),
		ColorSequenceKeypoint.new(0.3, RED),
		ColorSequenceKeypoint.new(0.5, WHITE),
		ColorSequenceKeypoint.new(0.7, RED),
		ColorSequenceKeypoint.new(1, RED),
	})
	g.Parent = s
	table.insert(gradients, g)
end

local function makeDraggable(target, handle)
	local dragging = false
	local dragStart
	local startPos

	handle.InputBegan:Connect(function(input)
		if locked then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = target.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging or locked then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			local delta = input.Position - dragStart
			target.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
end

local banner = Instance.new("Frame")
banner.AnchorPoint = Vector2.new(0.5, 0)
banner.Position = UDim2.new(0.5, 0, 0, 10)
banner.Size = UDim2.fromOffset(0, 36)
banner.AutomaticSize = Enum.AutomaticSize.X
banner.BackgroundColor3 = DARK
banner.BorderSizePixel = 0
banner.Parent = gui
style(banner, UDim.new(1, 0))

local bannerPadding = Instance.new("UIPadding")
bannerPadding.PaddingLeft = UDim.new(0, 4)
bannerPadding.PaddingRight = UDim.new(0, 14)
bannerPadding.Parent = banner

local bannerLayout = Instance.new("UIListLayout")
bannerLayout.FillDirection = Enum.FillDirection.Horizontal
bannerLayout.VerticalAlignment = Enum.VerticalAlignment.Center
bannerLayout.Padding = UDim.new(0, 8)
bannerLayout.SortOrder = Enum.SortOrder.LayoutOrder
bannerLayout.Parent = banner

local dot = Instance.new("Frame")
dot.Size = UDim2.fromOffset(28, 28)
dot.BackgroundColor3 = WHITE
dot.BorderSizePixel = 0
dot.LayoutOrder = 1
dot.Parent = banner

local dotCorner = Instance.new("UICorner")
dotCorner.CornerRadius = UDim.new(1, 0)
dotCorner.Parent = dot

local dotGradient = Instance.new("UIGradient")
dotGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, RED),
	ColorSequenceKeypoint.new(0.5, WHITE),
	ColorSequenceKeypoint.new(1, RED),
})
dotGradient.Parent = dot
table.insert(gradients, dotGradient)

local bannerText = Instance.new("TextLabel")
bannerText.Size = UDim2.fromOffset(0, 36)
bannerText.AutomaticSize = Enum.AutomaticSize.X
bannerText.BackgroundTransparency = 1
bannerText.Font = Enum.Font.GothamBold
bannerText.TextSize = 16
bannerText.TextColor3 = WHITE
bannerText.TextXAlignment = Enum.TextXAlignment.Left
bannerText.Text = "guma.cc | " .. player.Name .. " | 0 fps | 0 ms"
bannerText.LayoutOrder = 2
bannerText.Parent = banner

local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(150, 80)
panel.Position = UDim2.new(0, 10, 1, -100)
panel.BackgroundColor3 = DARK
panel.BorderSizePixel = 0
panel.Parent = gui
style(panel, UDim.new(0, 12))

local coordinates = Instance.new("TextLabel")
coordinates.Size = UDim2.new(1, -20, 1, -16)
coordinates.Position = UDim2.fromOffset(10, 8)
coordinates.BackgroundTransparency = 1
coordinates.TextColor3 = WHITE
coordinates.Font = Enum.Font.GothamBold
coordinates.TextSize = 14
coordinates.TextXAlignment = Enum.TextXAlignment.Center
coordinates.TextYAlignment = Enum.TextYAlignment.Center
coordinates.Text = "X 0.00\nY 0.00\nZ 0.00"
coordinates.Parent = panel

local speedPanel = Instance.new("Frame")
speedPanel.Size = UDim2.fromOffset(150, 80)
speedPanel.Position = UDim2.new(0, 10, 1, -186)
speedPanel.BackgroundColor3 = DARK
speedPanel.BorderSizePixel = 0
speedPanel.Parent = gui
style(speedPanel, UDim.new(0, 12))

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, -20, 1, -16)
speedLabel.Position = UDim2.fromOffset(10, 8)
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = WHITE
speedLabel.Font = Enum.Font.GothamBold
speedLabel.TextSize = 14
speedLabel.TextXAlignment = Enum.TextXAlignment.Center
speedLabel.TextYAlignment = Enum.TextYAlignment.Center
speedLabel.Text = "Speed\n0\nstuds/s"
speedLabel.Parent = speedPanel

local function makeButton(text, y)
	local button = Instance.new("TextButton")
	button.Size = UDim2.fromOffset(BUTTON_W, BUTTON_H)
	button.Position = UDim2.fromOffset(10, y)
	button.BackgroundColor3 = DARK
	button.BorderSizePixel = 0
	button.AutoButtonColor = false
	button.Text = text
	button.Font = Enum.Font.GothamBold
	button.TextSize = 14
	button.TextColor3 = WHITE
	button.Parent = gui
	style(button, UDim.new(0, 10))
	return button
end

local function makeBox(y, value, placeholder)
	local box = Instance.new("TextBox")
	box.Size = UDim2.fromOffset(BUTTON_W, BUTTON_H)
	box.Position = UDim2.fromOffset(10, y)
	box.BackgroundColor3 = DARK
	box.BorderSizePixel = 0
	box.Text = tostring(value)
	box.PlaceholderText = placeholder
	box.Font = Enum.Font.GothamBold
	box.TextSize = 14
	box.TextColor3 = WHITE
	box.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
	box.ClearTextOnFocus = false
	box.Visible = false
	box.Parent = gui
	style(box, UDim.new(0, 10))
	return box
end

local toggle = makeButton("Toggle UI", 10)
local lock = makeButton("Lock UI", 50)
local loopButton = makeButton("Voidspam: OFF", 90)
local spinButton = makeButton("Spin: OFF", 130)
local syncButton = makeButton("Sync: OFF", 170)

local syncBox = makeBox(210, stayTime, "sec")
local pauseBox = makeBox(250, syncPause, "sec")

local function refreshSyncBox()
	local show = uiVisible and syncOn
	syncBox.Visible = show
	pauseBox.Visible = show
end

syncBox.FocusLost:Connect(function()
	local n = tonumber(syncBox.Text)
	if n and n >= 0.1 then
		stayTime = n
	end
	syncBox.Text = tostring(stayTime)
end)

pauseBox.FocusLost:Connect(function()
	local n = tonumber(pauseBox.Text)
	if n and n >= 0.1 then
		syncPause = n
	end
	pauseBox.Text = tostring(syncPause)
end)

toggle.Activated:Connect(function()
	uiVisible = not uiVisible
	banner.Visible = uiVisible
	panel.Visible = uiVisible
	speedPanel.Visible = uiVisible
	loopButton.Visible = uiVisible
	spinButton.Visible = uiVisible
	syncButton.Visible = uiVisible
	refreshSyncBox()
end)

lock.Activated:Connect(function()
	locked = not locked
	lock.Text = locked and "Unlock UI" or "Lock UI"
end)

spinButton.Activated:Connect(function()
	spinOn = not spinOn
	spinButton.Text = spinOn and "Spin: ON" or "Spin: OFF"

	if not spinOn then
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if root then
			root.AssemblyAngularVelocity = Vector3.zero
		end
	end
end)

makeDraggable(banner, banner)
makeDraggable(panel, panel)
makeDraggable(speedPanel, speedPanel)

local function getPing()
	local ok, value = pcall(function()
		return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
	end)
	if ok and value then
		return math.floor(value + 0.5)
	end
	return math.floor(player:GetNetworkPing() * 1000 + 0.5)
end

local frames = 0
local timer = 0
local lastPos = nil
local spin = 0

loopButton.Activated:Connect(function()
	if syncing then return end

	active = not active
	loopButton.Text = active and "Voidspam: ON" or "Voidspam: OFF"

	if not active then
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if root and home then
			root.CFrame = home
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
		end
		home = nil
		lastPos = nil
	end
end)

local function runSyncLoop(token)
	while syncOn and syncToken == token do
		local elapsed = 0
		while elapsed < stayTime do
			local dt = task.wait()
			if not (syncOn and syncToken == token) then
				return
			end
			if active then
				elapsed += dt
			end
		end

		syncing = true
		active = false

		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if root and home then
			root.CFrame = home
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
		end
		home = nil
		lastPos = nil

		task.wait(syncPause)

		active = true
		syncing = false
	end
end

syncButton.Activated:Connect(function()
	syncOn = not syncOn
	syncButton.Text = syncOn and "Sync: ON" or "Sync: OFF"
	refreshSyncBox()

	syncToken += 1
	if syncOn then
		task.spawn(runSyncLoop, syncToken)
	end
end)

RunService.RenderStepped:Connect(function(dt)
	frames += 1
	timer += dt

	spin = (spin + dt * 180) % 360
	for _, g in ipairs(gradients) do
		g.Rotation = spin
	end

	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if root then
		local pos = root.Position
		coordinates.Text = string.format("X %.2f\nY %.2f\nZ %.2f", pos.X, pos.Y, pos.Z)

		if lastPos and dt > 0 then
			local speed = (pos - lastPos).Magnitude / dt
			speedLabel.Text = string.format("Speed\n%.0f\nstuds/s", speed)
		end
		lastPos = pos
	else
		lastPos = nil
	end

	if timer >= 0.5 then
		local fps = math.floor(frames / timer + 0.5)
		frames = 0
		timer = 0
		bannerText.Text = string.format("guma.cc | %s | %d fps | %d ms", player.Name, fps, getPing())
	end
end)

player.CharacterAdded:Connect(function()
	home = nil
	lastPos = nil
end)

RunService.Heartbeat:Connect(function()
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	if spinOn then
		spinAngle = (spinAngle + SPIN_STEP) % (math.pi * 2)
	end

	if active then
		if not home then
			home = root.CFrame
		end

		local target = CFrame.new(
			math.random(-RANGE, RANGE),
			DEPTH - math.random(0, 20),
			math.random(-RANGE, RANGE)
		)

		if spinOn then
			target = target * CFrame.Angles(0, spinAngle, 0)
		end

		root.CFrame = target
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
	elseif spinOn then
		root.CFrame = root.CFrame * CFrame.Angles(0, SPIN_STEP, 0)
		root.AssemblyAngularVelocity = Vector3.new(0, 10000, 0)
	end
end)
