-- FUNCTIONS IN THIS FILE HAVE BEEN MOVED HERE VARIOUS REASONS.
-- most likely because they weren't necessary.
--
-- in other words.. this is left over code.


function player:keyboard()
	-- [ Keyboard Input ]
	if love.keyboard.isDown( "up" ) then
		if self.state ~= 'jumping' then
			self.state = 'jumping'
			self.velY = 450
		end
	end
	if love.keyboard.isDown( "down" ) then
		self.velY = self.velY - 25
	end
	if love.keyboard.isDown( "left" ) then
		self.x = self.x - ( self.speed * dt )
		if self.state ~= "jumping" then
			self.facing = "left"
		end

	end
	if love.keyboard.isDown( "right" ) then
		self.x = self.x + ( self.speed * dt )
		if self.state ~= "jumping" then	
			self.facing = "right"
		end
	end

		-- [Player State Resolve]
	if self.state == "idle" then
		self.velY = 0
		self.accY = 0
		--self.speed = 350
	end

	if self.state == 'jumping' then
		-- jump
		--apply gravity
		self.accY = self.accY - ( self.gravity * dt )
		--update velocity
		self.velY = self.velY + ( self.accY * dt )
		--update position
		self.y = self.y - self.velY * dt

		-- back jump resistance
		if love.keyboard.isDown( "left" ) and self.facing == "right" then
			self.speed = 10
		end
		if love.keyboard.isDown( "right" ) and self.facing == "left" then
			self.speed = 10
		end

		-- reset to idle
		if self.y >= 215 then
			self.accY = 0
			self.velY = 0
			self.state = 'idle'
		end

	end 


	-- body
end