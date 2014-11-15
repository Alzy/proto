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




function player:movement( dt )
	self.xInput =  self.speed * joystick:getAxis(1)
	-- UP
		if joystick:getAxis(2) < -0.79 then
			if self.state ~= 'jumping' and self.state ~= 'falling' then
				self.state = 'jumping'
				self.velY = tonumber(self.charSheetArray["jumpVel"])  -- must be variable per character
			end
		end
	-- DOWN
		if joystick:getAxis(2) > 0.65 then
			self.velY = self.velY - 55 -- must be the product of delta time.
		end

	-- LEFT AND RIGHT
		local joystickXpos = joystick:getAxis(1)
	-- POSITION 1 (walk)
		if math.abs(joystickXpos) > 0.17 and math.abs(joystickXpos) < 0.35 then
			-- if on the ground and accX == 0 & velX == 0
			self.x = self.x + ( self.xInput * dt )
	-- POSTITION 2 (run)
		elseif math.abs(joystickXpos) >= 0.35 and math.abs(joystickXpos < 0.85) then
			if self.velX == 0 and accX == 0 then self.velX = self.xInput end
			-- on ground
			self.accX = self.accX + ( self.xInput * dt )
	-- POSITION 3 (sprint)
		elseif math.abs(joystickXpos) >= 0.85 then
			-- on ground
			self.accX = self.accX + ( self.xInput * dt )
		end

	-- limit speed and acceleration
		if self.velX > self.speed then self.velX = self.speed; self.accX = 0 end
		if self.velX < self.speed * -1 then self.velX = self.speed * -1; self.accX = 0 end


	-- STOP PLAYER AT NEUTRAL POSITION.
		if math.abs(joystickXpos) < 0.35  and self.velX ~= 0 and self.state ~= "jumping" and self.state ~= "falling" then
			--bring player to hault.
			if math.abs(self.velX) <= self.speed * 0.2 then
				self.velX = 0
				self.accX = 0
			end

			if math.abs(self.velX) > 0 then
				self.accX = self.accX - ( (self.velX * 20) * dt )
			end

		end

	-- update velocity
	self.velX = self.velX + ( self.accX * dt )
	-- update player x location
	self.x = self.x + ( self.velX * dt )
end