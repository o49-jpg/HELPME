-- Anomaly LocalScript
-- Place in StarterPlayerScripts or StarterCharacterScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Wait for character
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- =====================
-- CONFIG
-- =====================
local BASEPLATE_POS  = Vector3.new(-14688, 5622, 15938)
local BASEPLATE_SIZE = Vector3.new(500, 1, 500)
local CUBE_POS       = Vector3.new(-14501, 5640, 15922)
local EFFECT_START   = 80
local BLACKOUT_DIST  = 5
local TERMINAL_DIST  = 15

local terminalTriggered = false
local terminalDone      = false

local DESTINATIONS = {
	{ name = "LOCATION 01", pos = Vector3.new(-390, 49, -20)   },
	{ name = "LOCATION 02", pos = Vector3.new(261, 34, 192)    },
	{ name = "LOCATION 03", pos = Vector3.new(223, -16, -4)    },
	{ name = "LOCATION 04", pos = Vector3.new(-0, -5, 188)     },
	{ name = "LOCATION 05", pos = Vector3.new(-183, -5, 2)     },
	{ name = "LOCATION 06", pos = Vector3.new(-5, -5, -245)    },
}

-- =====================
-- TELEPORT TO BASEPLATE
-- =====================
task.wait(0.5)
humanoidRootPart.CFrame = CFrame.new(BASEPLATE_POS + Vector3.new(0, 5, 0))

-- =====================
-- SPAWN BASEPLATE
-- =====================
local baseplate = Instance.new("Part")
baseplate.Name = "AnomalyBaseplate"
baseplate.Size = BASEPLATE_SIZE
baseplate.Position = BASEPLATE_POS
baseplate.Anchored = true
baseplate.Material = Enum.Material.SmoothPlastic
baseplate.Color = Color3.fromRGB(80, 80, 90)
baseplate.Parent = workspace

-- =====================
-- SPAWN CUBE
-- =====================
local cube = Instance.new("Part")
cube.Name = "AnomalyCube"
cube.Size = Vector3.new(1, 1, 1)
cube.CFrame = CFrame.new(CUBE_POS)
cube.Anchored = true
cube.Material = Enum.Material.SmoothPlastic
cube.Color = Color3.fromRGB(255, 255, 255)
cube.CastShadow = false
cube.Parent = workspace

local mesh = Instance.new("SpecialMesh")
mesh.MeshType = Enum.MeshType.FileMesh
mesh.MeshId = "rbxassetid://16115621005"
mesh.Scale = Vector3.new(0.5, 0.5, 0.5)
mesh.Parent = cube

for _, face in ipairs({
	Enum.NormalId.Front, Enum.NormalId.Back,
	Enum.NormalId.Top,   Enum.NormalId.Bottom,
	Enum.NormalId.Left,  Enum.NormalId.Right,
}) do
	local d = Instance.new("Decal")
	d.Texture = "rbxassetid://109983454067749"
	d.Face = face
	d.Parent = cube
end

-- =====================
-- LIGHTING SAVE
-- =====================
local origClockTime  = Lighting.ClockTime
local origFogEnd     = Lighting.FogEnd
local origFogColor   = Lighting.FogColor
local origAmbient    = Lighting.Ambient
local origBrightness = Lighting.Brightness

-- =====================
-- POST PROCESSING
-- =====================
local blurEffect = Instance.new("BlurEffect")
blurEffect.Size = 0
blurEffect.Parent = Lighting

local colorCorrection = Instance.new("ColorCorrectionEffect")
colorCorrection.Saturation = 0
colorCorrection.Brightness = 0
colorCorrection.Contrast = 0
colorCorrection.Parent = Lighting

local dof = Instance.new("DepthOfFieldEffect")
dof.FocusDistance = 50
dof.InFocusRadius = 50
dof.NearIntensity = 0
dof.FarIntensity = 0
dof.Parent = Lighting

-- =====================
-- SCREEN GUI
-- =====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AnomalyOverlay"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player.PlayerGui

local blackFrame = Instance.new("Frame")
blackFrame.Size = UDim2.fromScale(1, 1)
blackFrame.BackgroundColor3 = Color3.new(0, 0, 0)
blackFrame.BackgroundTransparency = 1
blackFrame.BorderSizePixel = 0
blackFrame.ZIndex = 10
blackFrame.Parent = screenGui

-- =====================
-- TERMINAL LABEL
-- =====================
local terminalFrame = Instance.new("Frame")
terminalFrame.Size = UDim2.fromScale(1, 1)
terminalFrame.BackgroundTransparency = 1
terminalFrame.ZIndex = 20
terminalFrame.Parent = screenGui

local terminalLabel = Instance.new("TextLabel")
terminalLabel.Size = UDim2.new(1, -80, 0.4, 0)
terminalLabel.Position = UDim2.fromOffset(40, 40)
terminalLabel.BackgroundTransparency = 1
terminalLabel.TextColor3 = Color3.fromRGB(0, 255, 80)
terminalLabel.Font = Enum.Font.Code
terminalLabel.TextScaled = false
terminalLabel.TextSize = 28
terminalLabel.TextXAlignment = Enum.TextXAlignment.Left
terminalLabel.TextYAlignment = Enum.TextYAlignment.Top
terminalLabel.RichText = true
terminalLabel.Text = ""
terminalLabel.ZIndex = 20
terminalLabel.TextWrapped = true
terminalLabel.Parent = terminalFrame

-- Destination buttons container
local buttonFrame = Instance.new("Frame")
buttonFrame.Size = UDim2.new(0, 320, 0, 360)
buttonFrame.Position = UDim2.new(0, 40, 0, 180)
buttonFrame.BackgroundTransparency = 1
buttonFrame.ZIndex = 21
buttonFrame.Visible = false
buttonFrame.Parent = screenGui

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 8)
listLayout.Parent = buttonFrame

-- =====================
-- UTILITY
-- =====================
local GLITCH_CHARS = {"#","@","!","%","&","?","*","X","_","~","^"}

local function lerpVal(a, b, t)
	return a + (b - a) * t
end

local function typewrite(label, msg, speed)
	speed = speed or 0.06
	label.Text = ""
	for i = 1, #msg do
		label.Text = msg:sub(1, i)
		task.wait(speed)
	end
end

local function glitchText(label, finalText, duration)
	local steps = math.floor(duration / 0.04)
	for i = 1, steps do
		local glitched = ""
		for j = 1, #finalText do
			if math.random() < 0.4 then
				glitched = glitched .. GLITCH_CHARS[math.random(#GLITCH_CHARS)]
			else
				glitched = glitched .. finalText:sub(j, j)
			end
		end
		label.Text = glitched
		task.wait(0.04)
	end
	label.Text = finalText
end

local function appendTypewrite(label, msg, speed)
	speed = speed or 0.06
	local current = label.Text
	for i = 1, #msg do
		label.Text = current .. msg:sub(1, i)
		task.wait(speed)
	end
end

-- =====================
-- TERMINAL SEQUENCE
-- =====================
local function doTerminalSequence()
	blackFrame.BackgroundTransparency = 0
	terminalLabel.Text = ""
	buttonFrame.Visible = false

	task.wait(0.8)

	-- Welcome line
	local welcomeMsg = string.format("WELCOME HOME, ADMIN %s.\n", player.Name:upper())
	typewrite(terminalLabel, welcomeMsg, 0.07)
	task.wait(0.4)

	-- Where to go prompt
	appendTypewrite(terminalLabel, "\nWHERE TO GO?\n", 0.06)
	task.wait(0.3)

	-- List destinations via typewrite
	for i, dest in ipairs(DESTINATIONS) do
		appendTypewrite(terminalLabel, string.format("  [%d] %s\n", i, dest.name), 0.04)
		task.wait(0.05)
	end

	task.wait(0.5)

	-- Show clickable buttons
	buttonFrame.Visible = true

	-- Build buttons
	local buttons = {}
	for i, dest in ipairs(DESTINATIONS) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 48)
		btn.BackgroundColor3 = Color3.fromRGB(0, 30, 0)
		btn.BorderColor3 = Color3.fromRGB(0, 255, 80)
		btn.BorderSizePixel = 1
		btn.Font = Enum.Font.Code
		btn.TextSize = 20
		btn.TextColor3 = Color3.fromRGB(0, 255, 80)
		btn.Text = string.format("[ %d ] %s", i, dest.name)
		btn.ZIndex = 22
		btn.Parent = buttonFrame
		buttons[i] = btn

		local idx = i
		btn.MouseButton1Click:Connect(function()
			if terminalDone then return end
			terminalDone = true

			-- Hide buttons
			buttonFrame.Visible = false

			-- Companions prompt with glitch
			task.wait(0.2)
			appendTypewrite(terminalLabel, "\n\nWHAT DO YOU WISH TO BRING ALONG?\n", 0.06)
			task.wait(0.4)

			-- Glitched options
			local fakeOptions = {
				"  [A] MEMORIES........",
				"  [B] REGRET..........",
				"  [C] NOTHING.........",
				"  [D] EVERYTHING......",
			}

			local optionLabels = {}
			for _, opt in ipairs(fakeOptions) do
				local lbl = Instance.new("TextLabel")
				lbl.Size = UDim2.new(1, -80, 0, 28)
				lbl.Position = UDim2.new(0, 40, 0, 0)  -- positioned below terminal
				lbl.BackgroundTransparency = 1
				lbl.TextColor3 = Color3.fromRGB(0, 255, 80)
				lbl.Font = Enum.Font.Code
				lbl.TextSize = 22
				lbl.TextXAlignment = Enum.TextXAlignment.Left
				lbl.Text = opt
				lbl.ZIndex = 21
				lbl.Parent = terminalFrame
				table.insert(optionLabels, lbl)
			end

			-- Stack them below the main terminal label
			local baseY = 460
			for j, lbl in ipairs(optionLabels) do
				lbl.Position = UDim2.fromOffset(40, baseY + (j - 1) * 32)
			end

			-- Glitch each one
			task.wait(0.3)
			for _, lbl in ipairs(optionLabels) do
				task.spawn(function()
					glitchText(lbl, lbl.Text, 1.2)
				end)
			end
			task.wait(1.4)

			-- Wipe options, say HAVE FUN
			for _, lbl in ipairs(optionLabels) do
				lbl:Destroy()
			end

			appendTypewrite(terminalLabel, "\n\nHAVE FUN.\n", 0.08)
			task.wait(1.2)

			-- Flash to black then teleport
			blackFrame.BackgroundTransparency = 0
			task.wait(0.6)

			humanoidRootPart.CFrame = CFrame.new(dest.pos + Vector3.new(0, 5, 0))

			task.wait(0.5)

			-- Fade out GUI
			for fade = 0, 10 do
				blackFrame.BackgroundTransparency = fade / 10
				task.wait(0.05)
			end

			-- Clean up terminal
			terminalLabel.Text = ""
			blackFrame.BackgroundTransparency = 1
			screenGui:Destroy()
		end)
	end
end

-- =====================
-- UTILITY
-- =====================
local function lerpVal2(a, b, t)
	return a + (b - a) * t
end

-- =====================
-- MAIN LOOP
-- =====================
RunService.Heartbeat:Connect(function()
	if not humanoidRootPart or not humanoidRootPart.Parent then return end

	local playerPos = humanoidRootPart.Position
	local dist = (playerPos - CUBE_POS).Magnitude
	local t = math.clamp((EFFECT_START - dist) / (EFFECT_START - BLACKOUT_DIST), 0, 1)

	-- Cube tracks player horizontally
	if dist > 0.5 then
		cube.CFrame = CFrame.lookAt(CUBE_POS, Vector3.new(playerPos.X, CUBE_POS.Y, playerPos.Z))
	end

	-- Blur
	blurEffect.Size = lerpVal(0, 40, t)

	-- Depth of Field
	dof.NearIntensity = lerpVal(0, 1, t)
	dof.FarIntensity  = lerpVal(0, 1, t)
	dof.FocusDistance = lerpVal(50, 1, t)
	dof.InFocusRadius = lerpVal(50, 0.1, t)

	-- Color distortion
	colorCorrection.Saturation = lerpVal(0, -2, t)
	colorCorrection.Contrast   = lerpVal(0, 3, t)
	colorCorrection.Brightness = lerpVal(0, -0.8, t)

	-- Time acceleration
	if t > 0 then
		Lighting.ClockTime = (Lighting.ClockTime + (0.005 + t * 0.15)) % 24
	end

	-- Fog
	Lighting.FogEnd   = lerpVal(1000, 20, t)
	Lighting.FogColor = Color3.fromRGB(
		math.floor(lerpVal(200, 0, t)),
		math.floor(lerpVal(200, 0, t)),
		math.floor(lerpVal(255, 0, t))
	)

	-- Ambient drain
	local ambientVal = math.floor(lerpVal(80, 0, t))
	Lighting.Ambient = Color3.fromRGB(ambientVal, ambientVal, ambientVal)

	-- Blackout fade
	local blackT = math.clamp((EFFECT_START * 0.3 - dist) / (EFFECT_START * 0.3 - BLACKOUT_DIST), 0, 1)
	if not terminalTriggered then
		blackFrame.BackgroundTransparency = 1 - math.clamp(blackT, 0, 1)
	end

	-- Terminal trigger
	if dist <= TERMINAL_DIST and not terminalTriggered then
		terminalTriggered = true
		task.spawn(doTerminalSequence)
	end
end)

print("[Anomaly] Loaded. The cube is watching.")
