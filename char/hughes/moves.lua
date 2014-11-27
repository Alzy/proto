function player:performAction( action )
	-- conditional attack launches
	if action == "punch -w" then
		self:weakPunch(5)
	end

end

function player:weakPunch( frames )
	self.playerState = "attacking"

	if self.sprite ~= self.spriteCollection["punching"] then
		self.sprite = self.spriteCollection["punching"]
		self.playAnimation = true
		self.sprite:play()
	end

	pressed = self.sprite:getCurrentFrame()

	

	if self.sprite:getCurrentFrame() == 5 then
		self.playerState = "idle"
		self.playAnimation = false
		self.sprite:reset()
		self.sprite = self.spriteCollection["idle"]
		self.action = "idle"
	end
end
