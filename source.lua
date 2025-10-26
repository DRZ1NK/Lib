local GUI = {}

local tween = game:GetService("TweenService")
local tweeninfo = TweenInfo.new
local input = game:GetService("UserInputService")
local run = game:GetService("RunService")

function GUI.CreateWindow(name: string)
	local playergui = game.Players.LocalPlayer.PlayerGui
	local ScreenGui = Instance.new("ScreenGui")
	
	ScreenGui.Parent = playergui
	ScreenGui.Name = name
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.ResetOnSpawn = false
	return ScreenGui
end

function GUI.Dragging(frame, parent)

	parent = parent or frame

	local dragging = false
	local dragInput = nil
	local dragStart = Vector2.new()
	local frameStart = Vector2.new()

	local function isAnySliderBeingDragged()
		local screenGui = frame:FindFirstAncestorOfClass("ScreenGui")
		if not screenGui then return false end
		for _, guiObject in ipairs(screenGui:GetDescendants()) do
			if guiObject:IsA("GuiObject") then
				local draggingFlag = guiObject:FindFirstChild("Dragging")
				if draggingFlag and draggingFlag.Value then
					return true
				end
			end
		end
		return false
	end

	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if isAnySliderBeingDragged() then return end
			dragging = true
			dragInput = input
			dragStart = input.Position
			-- capture the frame's absolute position
			frameStart = frame.AbsolutePosition
			print("Started dragging mainframe at", frameStart)
		end
	end)

	input.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			if isAnySliderBeingDragged() then return end
			local delta = input.Position - dragStart
			-- move frame using absolute position
			frame.Position = UDim2.new(
				0,
				frameStart.X + delta.X,
				0,
				frameStart.Y + delta.Y
			)
			print("Dragging mainframe, delta:", delta)
		end
	end)

	input.InputEnded:Connect(function(input)
		if input == dragInput then
			dragging = false
			dragInput = nil
			print("Stopped dragging mainframe")
		end
	end)
end

function GUI.makeframe(name: string, parent, size, color, position, AnchorPoint, backgroundtransparency: number, zindex: number)
	local Frame = Instance.new("Frame")
	Frame.ZIndex = zindex or 1
	Frame.Size = size or UDim2.new(0, 100, 0, 100)
	Frame.BackgroundColor3 = color or Color3.new(1,1,1)
	Frame.AnchorPoint = AnchorPoint or Vector2.new(0,0)
	Frame.Parent = parent or print("NO PARENT FOUND")
	Frame.Position = position or UDim2.new(0,0,0)
	Frame.Name = name or Frame.Name == "N/A"
	Frame.Active = true
	Frame.BackgroundTransparency = backgroundtransparency or Frame.BackgroundTransparency == 0
	return Frame
end

function GUI.makebutton(text, size, color, parent, name, position, backgroundtransparency)
	local Button = Instance.new("TextButton")
	Button.Name = name or Button.Name == "N/A"
	Button.Parent = parent or print("NO PARENT FOUND")
	Button.Size = size or UDim2.new(0, 100, 0, 100)
	Button.Text = text or Button.Text == "N/A"
	Button.Position = position or UDim2.new(0,0,0)
	Button.BackgroundColor3 = color or Color3.new(1,1,1)
	Button.BackgroundTransparency = backgroundtransparency or Button.BackgroundTransparency == 0
	return Button
end

function GUI.makelabel(text, size, textcolor, color, parent, name, position, backgroundtransparency)
	local label = Instance.new("TextLabel")
	label.Name = name or label.Name == "N/A"
	label.Parent = parent or print("NO PARENT FOUND LABEL: " .. name)
	label.Size = size or UDim2.new(0, 100, 0, 100)
	label.Text = text or label.Text == "N/A"
	label.Position = position or UDim2.new(0,0,0)
	label.BackgroundColor3 = color or Color3.new(1,1,1)
	label.TextColor3 = textcolor or Color3.new(1,1,1)
	label.BackgroundTransparency = backgroundtransparency or label.BackgroundTransparency == 0
	return label
end

function GUI.makeslider(parent, position, size, corners, minValue, maxValue, callback)
	minValue = minValue or 0
	maxValue = maxValue or 1
	
	local bar = Instance.new("Frame")
	bar.Name = "SliderBar"
	bar.Size = size or UDim2.new(0, 200, 0, 10)
	bar.Position = position or UDim2.new(0.5, 0, 0.5, 0)
	bar.AnchorPoint = Vector2.new(0.5, 0.5)
	bar.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	bar.BorderSizePixel = 0
	bar.Parent = parent
	bar.ZIndex = 2
	local draggingFlag = bar:FindFirstChild("Dragging")
	if not draggingFlag then
		draggingFlag = Instance.new("BoolValue")
		draggingFlag.Name = "Dragging"
		draggingFlag.Value = false
		draggingFlag.Parent = bar
	end

	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
	fill.BorderSizePixel = 0
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.Parent = bar
	fill.ZIndex = 2

	local handle = Instance.new("Frame")
	handle.Name = "Handle"
	handle.Size = UDim2.new(0, 14, 1, 0)
	handle.AnchorPoint = Vector2.new(0.5, 0.5)
	handle.Position = UDim2.new(0, 0, 0.5, 0)
	handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	handle.BorderSizePixel = 0
	handle.Parent = bar
	handle.ZIndex = 2
	
	if corners == true then
		local corners1 = Instance.new("UICorner")
		corners1.Parent = bar
		corners1.CornerRadius = UDim.new(1, 0)
		local corners2 = Instance.new("UICorner")
		corners2.Parent = handle
		corners2.CornerRadius = UDim.new(1, 0)
		local corners3 = Instance.new("UICorner")
		corners3.Parent = fill
		corners3.CornerRadius = UDim.new(1, 0)
	elseif corners == false then
	end
	
	local dragging = false
	local percent = 0
	local value = minValue

	function setSliderValue(p)
		p = math.clamp(p, 0, 1)
		percent = p
		value = minValue + (maxValue - minValue) * percent

		local barAbsSize = bar.AbsoluteSize.X
		local handleHalf = handle.AbsoluteSize.X / barAbsSize / 2
		local adjusted = handleHalf + (1 - 2 * handleHalf) * percent

		handle.Position = UDim2.new(adjusted, 0, 0.5, 0)
		fill.Size = UDim2.new(adjusted, 0, 1, 0)

		if callback then
			callback(value)
		end
	end

	local function updateFromInput(inputX)
		local barAbsPos = bar.AbsolutePosition.X
		local barAbsSize = bar.AbsoluteSize.X
		local handleHalf = handle.AbsoluteSize.X / 2

		local relX = math.clamp(inputX - barAbsPos, handleHalf, barAbsSize - handleHalf)
		local newPercent = (relX - handleHalf) / (barAbsSize - handle.AbsoluteSize.X)
		setSliderValue(newPercent)
	end

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			draggingFlag.Value = true
		end
	end)

	handle.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
			draggingFlag.Value = false
		end
	end)

	input.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			updateFromInput(input.Position.X)
		end
	end)

	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			updateFromInput(input.Position.X)
		end
	end)

	setSliderValue(0)

	return {
		Bar = bar,
		Handle = handle,
		Fill = fill,
		SetPercent = setSliderValue,
		SetValue = function(v)
			local p = (v - minValue) / (maxValue - minValue)
			setSliderValue(p)
		end,
		GetValue = function() return value end,
		GetPercent = function() return percent end,
	}
end

return GUI
