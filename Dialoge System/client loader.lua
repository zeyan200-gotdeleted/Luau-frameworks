local CollectionService = game:GetService("CollectionService")
local module = require("@self/Client Dialoge")

function setup(rig)
	return module.new(rig)
end

for _, tagged in CollectionService:GetTagged("Dialoge") do
	if tagged:FindFirstChild("Humanoid") and tagged:FindFirstChild("Head") then
		setup(tagged)
	end	
end
