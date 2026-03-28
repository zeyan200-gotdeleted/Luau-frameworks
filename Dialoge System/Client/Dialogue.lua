local Dialoge = {}
Dialoge.__index = Dialoge

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local Player = Players.LocalPlayer

local function createPrompt(rig)
	local head = rig:FindFirstChild("Head")
	if not head then return nil end
	local prompt = Instance.new("ProximityPrompt")
	prompt.Parent = head
	prompt.ActionText = "Talk"
	prompt.ObjectText = rig.Name
	prompt.HoldDuration = 0
	prompt.RequiresLineOfSight = false
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	return prompt
end

function Dialoge.new(rig)
	local self = setmetatable({}, Dialoge)
	self.Model = rig
	self.UI = Player:WaitForChild("PlayerGui"):WaitForChild("Dialog")
	self.Frame = self.UI:WaitForChild("DialogContainer")
	local tree = ReplicatedStorage:WaitForChild("Dialoge System").Tree:FindFirstChild(rig.Name)
	if not tree then return self end
	self.Tree = require(tree)
	self.Index = 1
	self.StartIndex = 1
	self.Prompt = createPrompt(rig)
	if self.Prompt then
		self.Prompt.Triggered:Connect(function()
			self:Show(1)
		end)
	end
	self.Util = {
		
		inputNumbers = {Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four},
		
		TypeWrite = function(label, text)
			label.Text = ""
			local Time = 0.05
			for i = 1, #text do
				label.Text = string.sub(text, 1, i)
				task.wait(Time)
			end
		end,
		
		HandleAction = function(actionName, inputState, inputObject)
			if inputState ~= Enum.UserInputState.Begin then return end
			local response = table.find(self.Util.inputNumbers, inputObject.KeyCode)
			if response then
				self:Respond(self.Index, response)
			end
		end,
		
		GetIndex = function() return self.Index end,
		
		SetupViewport = function(viewport, model)
			
			viewport:ClearAllChildren()
			
			local worldModel = Instance.new("WorldModel", viewport)
			local viewportModel = model:Clone()
			
			viewportModel:PivotTo(CFrame.new(0,0,0))
			viewportModel.Parent = worldModel
			
			local camera = Instance.new("Camera", viewport)
			local o, s = viewportModel:GetBoundingBox()
			local orgin = Vector3.new( 1, viewportModel.Head.Position.Y, -3 )
			
			camera.CFrame = CFrame.lookAt( orgin, viewportModel.Head.Position )
			viewport.CurrentCamera = camera
		end,
		
	}
	return self
end

function Dialoge:Show(index)
	local branch = self.Tree.Dialoge[index]
	self.Index = index
	if not self.Frame or not branch then
		self.UI.Enabled = false
		return
	end
	local speakerLabel = self.Frame:FindFirstChild("Speaker") and self.Frame.Speaker:FindFirstChild("TextLabel")
	local messageLabel = self.Frame:FindFirstChild("Message")
	if not speakerLabel or not messageLabel then return end
	
	speakerLabel.Text = self.Model.Name
	messageLabel.Text = branch.text

	for _, btn in self.Frame.Responses:GetChildren() do
		if btn:IsA("TextButton") and btn.Name ~= "ResponseTemplate" then
			btn:Destroy()
		end
	end
	for i, response in ipairs(branch.responses) do
		local responseButton = self.Frame.Responses.ResponseTemplate:Clone()
		responseButton.LayoutOrder = i
		responseButton.Text = string.format("[%d] %s", i, response.text)
		responseButton.Visible = true
		responseButton.Parent = self.Frame.Responses
		responseButton.Name = tostring(i)
		
		task.spawn(function()
			self.Util.TypeWrite(responseButton, string.format("[%d] %s", i, response.text))
		end)
		responseButton.Activated:Connect(function()
			self:Respond(index, i)
		end)
	end
	self.Util.SetupViewport( self.Frame.Speaker.ViewportFrame, self.Model )
	
	
	ContextActionService:BindAction("Dialoge", self.Util.HandleAction, false, table.unpack(self.Util.inputNumbers))
	self.UI.Enabled = true

task.spawn(function()
		self.Util.TypeWrite(messageLabel, branch.text)
	end)
end

function Dialoge:Respond(dialogueNum, responseNum)
	local branch = self.Tree.Dialoge[dialogueNum]
	
	if not branch or not branch.responses then return end
	
	local response = branch.responses[responseNum]
	
	if not response then return end
	
	ContextActionService:UnbindAction("Dialoge")
	
	if self.Tree.OnResponse then
		self.Tree.OnResponse(dialogueNum, responseNum)
	end
	
	if response.nextId then
		self:Show(response.nextId)
	else
		if self.UI then self.UI.Enabled = false end
		for _, btn in self.Frame.Responses:GetChildren() do
			if btn:IsA("TextButton") and btn.Name ~= "ResponseTemplate" then
				btn:Destroy()
			end
		end
	end
end

return Dialoge
