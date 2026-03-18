local source = {} 
local Players = game:GetService "Players"
local ContextActionService = game:GetService "ContextActionService"

local Player = Players.LocalPlayer
local enums = {

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

function source.AddItem(tool)
if not tool:IsA "Tool" or tool:GetAttribute "InventorySetup" then return end

local ButtonTemp = script.Parent.ScrollingFrame.Template:Clone()

  if tool.Tooltip then
  ButtonTemp.Info.Image.Visible = true
    ButtonTemp.Info.Image.Image = tool.Tooltip

  else 

    ButtonTemp.Info.ToolName.Visible = true
    ButtonTemp.Info.ToolName.Text = tool.Name
   
    end 

     ButtonTemp.Name = `tool_ {tool.Name}`
  ButtonTemp.Parent = Player.PlayerGui.Inventory.Tools.ScrollingFrame

  
end 
