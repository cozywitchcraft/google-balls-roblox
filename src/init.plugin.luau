local AssetService = game:GetService("AssetService")
local RunService = game:GetService("RunService")
local RuntimeScriptService = game:GetService("RuntimeScriptService")

local XY = Vector3.new(1, 1)

local ctx = AssetService:CreateEditableImage({
	Size = Vector2.new(360, 130),
})

-- Util
local function vector2ToVector3(v: Vector2): Vector3
	return Vector3.new(v.X, v.Y)
end

local function vector3ToVector2(v: Vector3): Vector2
	return Vector2.new(v.X, v.Y)
end

-- Point
type Point = {
	color: Color3,
	currentPosition: Vector3,
	originalPosition: Vector3,
	friction: number,
	radius: number,
	size: number,
	springStrength: number,
	targetPosition: Vector3,
	velocity: Vector3,
	update: (self: Point, deltaTime: number) -> (),
	draw: (self: Point) -> (),
}

local function updatePoint(self: Point, deltaTime: number)
	local offset = (self.currentPosition - self.originalPosition) * XY

	self.targetPosition *= XY
	self.targetPosition += Vector3.zAxis * (offset.Magnitude / 100 + 1.0)

	local delta = self.targetPosition - self.currentPosition

	self.velocity += delta * self.springStrength
	self.velocity *= self.friction

	self.currentPosition += self.velocity * (deltaTime * 30)
	self.radius = math.max(self.size * self.currentPosition.Z, 1.0)
end

local function drawPoint(self: Point)
	ctx:DrawCircle(vector3ToVector2(self.currentPosition), self.radius, self.color, 0, Enum.ImageCombineType.Overwrite)
end

function Point(x: number, y: number, z: number, size: number, color: string): Point
	local position = Vector3.new(x, y, z)

	return {
		color = Color3.fromHex(color),
		currentPosition = position,
		originalPosition = position,
		friction = 0.8,
		radius = size,
		size = size,
		springStrength = 0.1,
		targetPosition = position,
		velocity = Vector3.zero,
		update = updatePoint,
		draw = drawPoint,
	}
end

-- PointCollection
type PointCollection = {
	mousePosition: Vector3,
	points: { Point },
	update: (self: PointCollection, deltaTime: number) -> (),
	draw: (self: PointCollection) -> (),
}

local function updatePointCollection(self: PointCollection, deltaTime: number)
	for _, point in self.points do
		local delta = self.mousePosition - point.currentPosition

		if delta.Magnitude < 150 then
			point.targetPosition = point.currentPosition - delta
		else
			point.targetPosition = point.originalPosition
		end

		point:update(deltaTime)
	end
end

local function drawPointCollection(self: PointCollection)
	for _, point in self.points do
		point:draw()
	end
end

function PointCollection(points: { Point }): PointCollection
	return {
		mousePosition = Vector3.zero,
		points = points,
		update = updatePointCollection,
		draw = drawPointCollection,
	}
end

-- Main
local function init()
	local toolbar = plugin:CreateToolbar("Google Balls")

	local button = toolbar:CreateButton("Google Balls", "Google Balls", "rbxasset://textures/balls.png")
	button.ClickableWhenViewportHidden = true

	local widget = plugin:CreateDockWidgetPluginGuiAsync("GoogleBalls", DockWidgetPluginGuiInfo.new(
		Enum.InitialDockState.Float,
		false,
		false,
		360,
		130
	))

	widget.Title = "Google Balls"

	button.Click:Connect(function()
		widget.Enabled = not widget.Enabled
	end)

	widget:GetPropertyChangedSignal("Enabled"):Connect(function()
		button:SetActive(widget.Enabled)
	end)

	local canvas = Instance.new("ImageLabel")
	canvas.ImageContent = Content.fromObject(ctx)
	canvas.Size = UDim2.fromScale(1, 1)
	canvas.Parent = widget

	local pointCollection = PointCollection({ Point(202, 78, 0.0, 9, "#ed9d33"), Point(348, 83, 0.0, 9, "#d44d61"), Point(256, 69, 0.0, 9, "#4f7af2"), Point(214, 59, 0.0, 9, "#ef9a1e"), Point(265, 36, 0.0, 9, "#4976f3"), Point(300, 78, 0.0, 9, "#269230"), Point(294, 59, 0.0, 9, "#1f9e2c"), Point(45, 88, 0.0, 9, "#1c48dd"), Point(268, 52, 0.0, 9, "#2a56ea"), Point(73, 83, 0.0, 9, "#3355d8"), Point(294, 6, 0.0, 9, "#36b641"), Point(235, 62, 0.0, 9, "#2e5def"), Point(353, 42, 0.0, 8, "#d53747"), Point(336, 52, 0.0, 8, "#eb676f"), Point(208, 41, 0.0, 8, "#f9b125"), Point(321, 70, 0.0, 8, "#de3646"), Point(8, 60, 0.0, 8, "#2a59f0"), Point(180, 81, 0.0, 8, "#eb9c31"), Point(146, 65, 0.0, 8, "#c41731"), Point(145, 49, 0.0, 8, "#d82038"), Point(246, 34, 0.0, 8, "#5f8af8"), Point(169, 69, 0.0, 8, "#efa11e"), Point(273, 99, 0.0, 8, "#2e55e2"), Point(248, 120, 0.0, 8, "#4167e4"), Point(294, 41, 0.0, 8, "#0b991a"), Point(267, 114, 0.0, 8, "#4869e3"), Point(78, 67, 0.0, 8, "#3059e3"), Point(294, 23, 0.0, 8, "#10a11d"), Point(117, 83, 0.0, 8, "#cf4055"), Point(137, 80, 0.0, 8, "#cd4359"), Point(14, 71, 0.0, 8, "#2855ea"), Point(331, 80, 0.0, 8, "#ca273c"), Point(25, 82, 0.0, 8, "#2650e1"), Point(233, 46, 0.0, 8, "#4a7bf9"), Point(73, 13, 0.0, 8, "#3d65e7"), Point(327, 35, 0.0, 6, "#f47875"), Point(319, 46, 0.0, 6, "#f36764"), Point(256, 81, 0.0, 6, "#1d4eeb"), Point(244, 88, 0.0, 6, "#698bf1"), Point(194, 32, 0.0, 6, "#fac652"), Point(97, 56, 0.0, 6, "#ee5257"), Point(105, 75, 0.0, 6, "#cf2a3f"), Point(42, 4, 0.0, 6, "#5681f5"), Point(10, 27, 0.0, 6, "#4577f6"), Point(166, 55, 0.0, 6, "#f7b326"), Point(266, 88, 0.0, 6, "#2b58e8"), Point(178, 34, 0.0, 6, "#facb5e"), Point(100, 65, 0.0, 6, "#e02e3d"), Point(343, 32, 0.0, 6, "#f16d6f"), Point(59, 5, 0.0, 6, "#507bf2"), Point(27, 9, 0.0, 6, "#5683f7"), Point(233, 116, 0.0, 6, "#3158e2"), Point(123, 32, 0.0, 6, "#f0696c"), Point(6, 38, 0.0, 6, "#3769f6"), Point(63, 62, 0.0, 6, "#6084ef"), Point(6, 49, 0.0, 6, "#2a5cf4"), Point(108, 36, 0.0, 6, "#f4716e"), Point(169, 43, 0.0, 6, "#f8c247"), Point(137, 37, 0.0, 6, "#e74653"), Point(318, 58, 0.0, 6, "#ec4147"), Point(226, 100, 0.0, 5, "#4876f1"), Point(101, 46, 0.0, 5, "#ef5c5c"), Point(226, 108, 0.0, 5, "#2552ea"), Point(17, 17, 0.0, 5, "#4779f7"), Point(232, 93, 0.0, 5, "#4b78f1") })

	local lastCenter = Vector3.new(180, 65)

	local function draw()
		ctx:DrawRectangle(Vector2.zero, ctx.Size, Color3.new(1, 1, 1), 0, Enum.ImageCombineType.Overwrite)
		pointCollection:draw()
	end

	local function recenterPoints()
		local center = 0.5 * vector2ToVector3(canvas.AbsoluteSize)

		for _, point in pointCollection.points do
			point.originalPosition += center - lastCenter
			point.currentPosition += center - lastCenter
		end

		lastCenter = center
	end

	RunService.RenderStepped:Connect(function(deltaTime)
		if widget.Enabled then
			pointCollection:update(deltaTime)
			draw()
		end
	end)

	canvas.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			pointCollection.mousePosition = input.Position
		end
	end)

	canvas.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			-- Mouse is out of window
			pointCollection.mousePosition = -1000 * XY
		end
	end)

	canvas:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		ctx = AssetService:CreateEditableImage({
			Size = canvas.AbsoluteSize,
		})

		recenterPoints()
		draw()

		canvas.ImageContent = Content.fromObject(ctx)
	end)
end

if RunService:IsEdit() then
	init()
end
