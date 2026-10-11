local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local RANGE = 2000
local DEPTH = workspace.FallenPartsDestroyHeight + 50

local gui = Instance.new("ScreenGui")
gui.Name = "TeleportPanel"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Top middle banner
local banner = Instance.new("Frame")
banner.AnchorPoint = Vector2.new(0.5, 0)
banner.Position = UDim2.new(0.5, 0, 0, 10)
banner.Size = UDim2.fromOffset(150, 36)
banner.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
banner.BorderSizePixel = 0
banner.Parent = gui

local bannerCorner = Instance.new("UICorner")
bannerCorner.CornerRadius = UDim.new(1, 0)
bannerCorner.Parent = banner

local bannerStroke = Instance.new("UIStroke")
bannerStroke.Color = Color3.fromRGB(120, 80, 255)
bannerStroke.Thickness = 1.5
bannerStroke.Parent = banner

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
bannerText.TextColor3 = Color3.new(1, 1, 1)
bannerText.Parent = banner

-- Bottom left coordinates panel
local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(230, 105)
panel.Position = UDim2.new(0, 10, 1, -125)
panel.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
panel.BorderSizePixel = 0
panel.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 24)
corner.Parent = panel

local panelStroke = Instance.new("UIStroke")
panelStroke.Color = Color3.fromRGB(120, 80, 255)
panelStroke.Thickness = 1.5
panelStroke.Parent = panel

local coordinates = Instance.new("TextLabel")
coordinates.Size = UDim2.new(1, -20, 1, -16)
coordinates.Position = UDim2.fromOffset(10, 8)
coordinates.BackgroundTransparency = 1
coordinates.TextColor3 = Color3.new(1, 1, 1)
coordinates.Font = Enum.Font.GothamBold
coordinates.TextSize = 14
coordinates.TextXAlignment = Enum.TextXAlignment.Left
coordinates.TextYAlignment = Enum.TextYAlignment.Center
coordinates.Text = "X 0.00\nY 0.00\nZ 0.00"
coordinates.Parent = panel

-- Void spam (always on)
RunService.Heartbeat:Connect(function()
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then return end

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
