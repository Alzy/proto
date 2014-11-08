function player:attack( attack )
	-- conditional attack launches
	if attack == "punch -w" then
		self:weakPunch(5)
	end

end

function player:weakPunch( frames )
	self.state = "attacking"

	if self.sprite ~= self.spriteCollection["punching"] then
		self.sprite = self.spriteCollection["punching"]
		self.playAnimation = true
		self.sprite:play()
	end

	pressed = self.sprite:getCurrentFrame()

	if self.sprite:getCurrentFrame() == 5 then
		self.sprite:reset()
		self.state = "idle"
		self.sprite = self.spriteCollection["idle"]
		self.playAnimation = false
	end 
end
