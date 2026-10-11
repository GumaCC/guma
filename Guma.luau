local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local RANGE = 3500
local DEPTH = workspace.FallenPartsDestroyHeight + 50

local active = true
local uiVisible = true
local locked = false
local home = nil

local PURPLE = Color3.fromRGB(120, 80, 255)
local DARK = Color3.fromRGB(10, 10, 10)
local WHITE = Color3.new(1, 1, 1)

local gui = Instance.new("ScreenGui")
gui.Name = "TeleportPanel"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local function style(obj, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = radius
	c.Parent = obj

	local s = Instance.new("UIStroke")
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Color = PURPLE
	s.Thickness = 1.5
	s.Parent = obj
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
banner.Size = UDim2.fromOffset(150, 36)
banner.BackgroundColor3 = DARK
banner.BorderSizePixel = 0
banner.Parent = gui
style(banner, UDim.new(1, 0))

local dot = Instance.new("Frame")
dot.Size = UDim2.fromOffset(28, 28)
dot.Position = UDim2.fromOffset(4, 4)
dot.BackgroundColor3 = Color3.fromRGB(150, 110, 255)
dot.BorderSizePixel = 0
dot.Parent = banner

local dotCorner = Instance.new("UICorner")
dotCorner.CornerRadius = UDim.new(1, 0)
dotCorner.Parent = dot

local bannerText = Instance.new("TextLabel")
bannerText.Size = UDim2.new(1, -40, 1, 0)
bannerText.Position = UDim2.fromOffset(36, 0)
bannerText.BackgroundTransparency = 1
bannerText.Text = "guma.cc"
bannerText.Font = Enum.Font.GothamBold
bannerText.TextSize = 18
bannerText.TextColor3 = WHITE
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

local function makeButton(text, y)
	local button = Instance.new("TextButton")
	button.Size = UDim2.fromOffset(100, 32)
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

local toggle = makeButton("Toggle UI", 10)
local lock = makeButton("Lock UI", 50)

toggle.Activated:Connect(function()
	uiVisible = not uiVisible
	panel.Visible = uiVisible
end)

lock.Activated:Connect(function()
	locked = not locked
	lock.Text = locked and "Unlock UI" or "Lock UI"
end)

makeDraggable(panel, panel)
makeDraggable(banner, banner)

player.CharacterAdded:Connect(function()
	home = nil
end)

RunService.Heartbeat:Connect(function()
	if not active then return end

	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	if not home then
		home = root.CFrame
	end

	root.CFrame = CFrame.new(
		math.random(-RANGE, RANGE),
		DEPTH - math.random(0, 20),
		math.random(-RANGE, RANGE)
	)
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero

	local pos = root.Position
	coordinates.Text = string.format("X %.2f\nY %.2f\nZ %.2f", pos.X, pos.Y, pos.Z)
end)
