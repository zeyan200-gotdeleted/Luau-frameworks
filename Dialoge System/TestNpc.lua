return {
	OnResponse = function(dialogueNum, responseNum)
		if dialogueNum == 1 and responseNum == 3 then
			game.Players.LocalPlayer:Kick("Dont leave the NPC hanging.")
		end
	end,
	
	Dialoge = {
		
		[1] = {
			
			text = "Hello, I was used for testing!",
			responses = {
				
				{text = "Oh, That's cool!", nextId = 2},
				{text = "Who made this system?", nextId = 3},
				{text = "Ok. Goodbye", nextId = nil},
			}
			
		},
		
		[2] = {

			text = "I know right!",
			responses = {

				{text = "Yeah!", nextId = nil},
				
			}

		},
		
		[3] = {

			text = "@verva1_n did!",
			responses = {

				{text = "Cool!", nextId = nil},
				{text = "Start convo again?", nextId = 1},

			}

		},
		
	}
	
}
