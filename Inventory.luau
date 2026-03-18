--!strict

local Inventory = {}
Inventory.__index = Inventory

local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")

local KeyCodes: {Enum.KeyCode} = {
	Enum.KeyCode.One,
	Enum.KeyCode.Two,
	Enum.KeyCode.Three,
	Enum.KeyCode.Four,
	Enum.KeyCode.Five,
	Enum.KeyCode.Six,
	Enum.KeyCode.Seven,
	Enum.KeyCode.Eight,
	Enum.KeyCode.Nine,
}

type ToolButton = TextButton & {
	Info: Frame & {
		Image: ImageLabel,
		ToolName: TextLabel,
		Count: TextLabel
	}
}

export type Slot = {
	Name: string,
	Tool: Tool,
	Button: ToolButton,
	Count: number
}

export type InventoryType = {
	Player: Player,
	Gui: ScreenGui,
	Container: ScrollingFrame,
	Template: ToolButton,

	Slots: {[string]: Slot},
	Order: {Slot},
	SelectedSlot: Slot?,

	Initialize: (self: InventoryType) -> (),
	AddItem: (self: InventoryType, tool: Instance) -> (),
	RemoveItem: (self: InventoryType, tool: Instance) -> (),
	UpdateStackUI: (self: InventoryType, slot: Slot) -> (),
	SelectSlot: (self: InventoryType, slot: Slot) -> (),
	ClearSelection: (self: InventoryType) -> (),
	AnimateSelection: (self: InventoryType, slot: Slot) -> (),
	AnimateDeselection: (self: InventoryType, slot: Slot) -> (),
	EquipTool: (self: InventoryType, tool: Tool) -> (),
	BindKeys: (self: InventoryType) -> (),
}

function Inventory.new(gui: ScreenGui): InventoryType
	local self = setmetatable({} :: InventoryType, Inventory)

	local player = Players.LocalPlayer
	local container = gui.Tools.ScrollingFrame

	self.Player = player
	self.Gui = gui
	self.Container = container
	self.Template = container.Template :: ToolButton

	self.Slots = {} :: {[string]: Slot}
	self.Order = {} :: {Slot}
	self.SelectedSlot = nil

	self:Initialize()

	return self
end

function Inventory:Initialize()
	for _, tool in ipairs(self.Player.Backpack:GetChildren()) do
		self:AddItem(tool)
	end

	self.Player.Backpack.ChildAdded:Connect(function(tool: Instance)
		self:AddItem(tool)
	end)

	self.Player.Backpack.ChildRemoved:Connect(function(tool: Instance)
		self:RemoveItem(tool)
	end)

	self:BindKeys()
end

function Inventory:AddItem(tool: Instance)
	if not tool:IsA("Tool") then return end

	local key = tool.Name
	local slot = self.Slots[key]

	if slot then
		slot.Count += 1
		self:UpdateStackUI(slot)
		return
	end

	local button = (self.Template:Clone() :: any) :: ToolButton
	button.Visible = true
	button.Name = "tool_" .. tool.Name

	if tool.ToolTip ~= "" then
		button.Info.Image.Visible = true
		button.Info.Image.Image = tool.ToolTip
	else
		button.Info.ToolName.Visible = true
		button.Info.ToolName.Text = tool.Name
	end

	button.Parent = self.Container

	local newSlot: Slot = {
		Name = key,
		Tool = tool,
		Button = button,
		Count = 1
	}

	self.Slots[key] = newSlot
	table.insert(self.Order, newSlot)

	button.MouseButton1Click:Connect(function()
		self:SelectSlot(newSlot)
	end)

	self:UpdateStackUI(newSlot)
end

function Inventory:RemoveItem(tool: Instance)
	if not tool:IsA("Tool") then return end

	local key = tool.Name
	local slot = self.Slots[key]
	if not slot then return end

	slot.Count -= 1

	if slot.Count > 0 then
		self:UpdateStackUI(slot)
		return
	end

	if self.SelectedSlot == slot then
		self:ClearSelection()
	end

	slot.Button:Destroy()
	self.Slots[key] = nil

	for i, v in ipairs(self.Order) do
		if v == slot then
			table.remove(self.Order, i)
			break
		end
	end
end

function Inventory:UpdateStackUI(slot: Slot)
	local label = slot.Button.Info.Count

	label.Visible = slot.Count > 1
	label.Text = "x" .. tostring(slot.Count)
end

function Inventory:SelectSlot(slot: Slot)
	if self.SelectedSlot == slot then return end

	if self.SelectedSlot then
		self:AnimateDeselection(self.SelectedSlot)
	end

	self.SelectedSlot = slot

	self:AnimateSelection(slot)
	self:EquipTool(slot.Tool)
end

function Inventory:ClearSelection()
	if self.SelectedSlot then
		self:AnimateDeselection(self.SelectedSlot)
		self.SelectedSlot = nil
	end
end

function Inventory:AnimateSelection(slot: Slot)
	TweenService:Create(
		slot.Button,
		TweenInfo.new(0.15),
		{
			Size = UDim2.new(1, 0, 0, 60),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		}
	):Play()
end

function Inventory:AnimateDeselection(slot: Slot)
	TweenService:Create(
		slot.Button,
		TweenInfo.new(0.15),
		{
			Size = UDim2.new(1, 0, 0, 50),
			BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		}
	):Play()
end

function Inventory:EquipTool(tool: Tool)
	local character = self.Player.Character
	if not character then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	humanoid:EquipTool(tool)
end

function Inventory:BindKeys()
	for index, key in ipairs(KeyCodes) do
		ContextActionService:BindAction(
			"InventoryKey_" .. tostring(index),
			function(_, state)
				if state ~= Enum.UserInputState.Begin then return end

				local slot = self.Order[index]
				if slot then
					self:SelectSlot(slot)
				end
			end,
			false,
			key
		)
	end
end

return Inventory
