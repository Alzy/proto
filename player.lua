-- // THE ALMIGHTY PLAYER SCRIPT \\
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

player = {
	-- [Player Info]
	name,
	facing,
	permissions = {},

	-- [Player Graphics]
	sprite,
	spriteCollection = {},
	playAnimation = false,
	
	-- [Player Position and Movement]
	state,
	playerState,
	x,
	y,
	velX,
	velY,
	accX,
	accY,

	-- [Player Stats]
	speed,
	hp,
	energy,
	defense,

	-- [Helpers]
	-- character
	charsheet,
	charSheetArray,
	-- joystick
	buttonState     = { 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0 }, -- { 25 slots for 15 button indexs and 10 fake ones.
	buttonHoldTime  = { 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0 }, -- { I'd make a multi-dem array, but fuck it.
	xInput,
	-- action
	moveQueue = { first = 0, last = 10 },
	action,
	prevYposition,

	-- temp variables
	gravity -- delete later. This is a spec relative to map.

} --CREATE PLAYER TABLE

function player:load( joystick )
	-- [Load Character Sheet]
	self.charsheet = love.filesystem.newFile("char/hughes/char")
	self.charsheet:open("r")
	self.charSheetArray = {}
	-- parse file
	for line in self.charsheet:lines() do
		if line:sub(1,1) == "#" then
			-- do nothing
		else
			-- remove whitespace from string
			line = line:gsub("%s+", "")
			if line:find("=") ~= nil then
				-- populate array  ( Character["name"] = far )
				self.charSheetArray[line:sub( 1, line:find("=") - 1 )] = line:sub(line:find("=") + 1)
			end
		end
	end

	-- [Player Info]
	self.name = self.charSheetArray["name"]

	-- [Player Graphics]
	self.sprite = love.graphics.newImage( "char/hughes/stand.png" )
	self.spriteCollection["idle"] = self.sprite
	self.spriteCollection["punching"] = newAnimation(love.graphics.newImage("char/hughes/punching.png"), 100, 120, 0.1, 0)
	self.spriteCollection["punching"]:setMode("once")
	self.facing = "right"

	-- [Player Position and Movement]
	self.state = "idle"
	self.playerState = "idle"
	self.x = 50
	self.y = 215
	self.velX = 0
	self.velY = 0
	self.accX = 0
	self.accY = 0

	-- [Player Stats]
	self.speed = tonumber(self.charSheetArray["speed"])
	self.hp = tonumber(self.charSheetArray["hp"])
	self.energy = tonumber(self.charSheetArray["energy"])
	self.defense = tonumber(self.charSheetArray["defense"]) -- out of 3. where 1 is weak, 2 is well average, and 3 is strong.

	-- [Load Moveset]
	require "char/hughes/moves"

	-- [Load Queue]
	self.moveQueue:load()

	-- [ Helpers ]
	self.prevYposition = self.y
	self.gravity = 4125

	--self.hitbox_x = self.x + 12
	--self.hitbox_y = self.y + 12
	--self.hitbox = Collider:addRectangle( self.hitbox_x, self.hitbox_y, 10, 15 )
end

function player:draw( )
	-- [Player Sprite]
	if self.playAnimation == false then
		love.graphics.draw( self.sprite, self.x, self.y )
	else
		self.sprite:draw( self.x, self.y )
	end

	-- [ Dev Player Stats ]
	love.graphics.printf( self.state, 10, 10, 150, 'left' )
	love.graphics.printf( "velocity:  " .. self.velX, 10, 30, 550, 'left' )
	love.graphics.printf( "acceleration:  " .. self.accX, 10, 50, 550, 'left' )
	love.graphics.printf( "speed:  " .. self.speed, 10, 70, 550, 'left' )

	-- [ Dev Player Info : right side ]
	love.graphics.printf( "name :  " .. self.name, 550, 10, 150, 'left' )
	love.graphics.printf( "facing:  " .. self.facing, 550, 30, 150, 'left' )
	love.graphics.printf( "HP:  " .. self.hp, 550, 50, 150, 'left' )
	love.graphics.printf( "Energy:  " .. self.energy, 550, 70, 150, 'left' )

	-- [ Dev MoveQueue Info ]
	self.moveQueue:draw()
	love.graphics.printf( "Hold: " .. self.buttonHoldTime[25] , 550, 300, 20, 'left'  )
	-- [ Dev Draw Hitbox ]
	-- self.hitbox:draw("fill")
end

function player:update( dt, joystick )

	self:handleFootMovement(dt, joystick)
	self:handleInput(dt, joystick)

	-- [Joystick Input]
	if joystick:isDown(11) then  -- see "joystick list of button indexs.txt"
		self.action = "punch -w"
	end

	-- [Player State Resolve]
	if self.state == "idle" then
		self.velY = 0
		self.accY = 0
	end

	if self.y > self.prevYposition then
		self.state = "falling"
	end
	if self.prevYposition ~= self.y then
		self.prevYposition = self.y
	end

	if self.state == 'jumping' or self.state == 'falling' then
 		self.accX = 0 -- you can't accelerate when you jump, stupid.
		
		-- jump
		--apply gravity
		self.accY = self.accY - ( self.gravity * dt )
		--update velocity
		self.velY = self.velY + ( self.accY * dt )
		--update position
		self.y = self.y - self.velY * dt
	end 
	-- reset to idle
	if self.y >= 215 then
		self.accY = 0
		self.velY = 0
		self.state = 'idle'
		self.y = 215 -- lol
	end


	-- update velocity
	self.velX = self.velX + ( self.accX * dt )
	-- update player x location
	self.x = self.x + ( self.velX * dt )


	if self.playAnimation == true then
		self.sprite:update(dt)
	end

	self:performAction(self.action)

	-- HACKS (things are getting messy.) delete later
	-- pacman screen corners
	if( self.x > 640 ) then self.x = -72 end
	if( self.x < -72 ) then self.x = 640 end

	-- [ Hitbox Position and Movement ]
	--self.hitbox:moveTo( self.hitbox_x, self.hitbox_y)
end



-- [ Joystick Input Handling ]
function player:handleInput( dt, joystick )
	for c = 1, 15 do
		if joystick:isDown(c) then
			if self.buttonState[c] < 2 then self.buttonState[c] = self.buttonState[c] + 1 end
			if self.buttonState[c] == 1 then self.moveQueue:push(c,Clock) end
		elseif self.buttonState[c] == 2 then
			self.buttonState[c] = 0
		end
	end
	--FOR TESTING delete later
	if love.keyboard.isDown("o") then
		if self.buttonState[24] < 2 then 
			self.buttonState[24] = self.buttonState[24] + 1
			if self.buttonState[24] == 1 then 
				self.moveQueue:push(24,Clock)
			end
		else self.buttonHoldTime[24] = self.buttonHoldTime[24] + dt end
	elseif self.buttonState[24] == 2 then
		self.buttonState[24] = 0
		self.buttonHoldTime[24] = 0
	end
	--FOR TESTING delete later
	if love.keyboard.isDown("p") then
		if self.buttonState[25] < 2 then 
			self.buttonState[25] = self.buttonState[25] + 1
			if self.buttonState[25] == 1 then 
				self.moveQueue:push(25,Clock)
			end
		else self.buttonHoldTime[25] = self.buttonHoldTime[25] + dt end
	elseif self.buttonState[25] == 2 then
		self.buttonState[25] = 0
		self.buttonHoldTime[25] = 0
	end


	-- get analog stick inputs
	-- Left Stick
	if joystick:getAxis(2) < -0.25 then -- up
		if self.buttonState[16] < 2 then self.buttonState[16] = self.buttonState[16] + 1 end
		if self.buttonState[16] == 1 then self.moveQueue:push(16,Clock) end
	elseif joystick:getAxis(2) > 0.25 then -- down
		if self.buttonState[17] < 2 then self.buttonState[17] = self.buttonState[17] + 1 end
		if self.buttonState[17] == 1 then self.moveQueue:push(17,Clock) end
	else
		if self.buttonState[16] ~= 0 then self.buttonState[16] = 0 end
		if self.buttonState[17] ~= 0 then self.buttonState[17] = 0 end
	end
	if joystick:getAxis(1) < -0.25 then -- left 
		if self.buttonState[18] < 2 then self.buttonState[18] = self.buttonState[18] + 1 end
		if self.buttonState[18] == 1 then self.moveQueue:push(18,Clock) end
	elseif joystick:getAxis(1) > 0.25 then -- right
		if self.buttonState[19] < 2 then self.buttonState[19] = self.buttonState[19] + 1 end
		if self.buttonState[19] == 1 then self.moveQueue:push(19,Clock) end
	else
		if self.buttonState[18] ~= 0 then self.buttonState[18] = 0 end
		if self.buttonState[19] ~= 0 then self.buttonState[19] = 0 end
	end
end



-- [ Walking and Running ]
function player:handleFootMovement(dt, joystick)
	-- define helpers
	self.xInput =  self.speed * joystick:getAxis(1)
	local joystickXpos = joystick:getAxis(1)

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
	-- POSITION 1 (walk)
		if math.abs(joystickXpos) > 0.17 and math.abs(joystickXpos) < 0.35 then
			-- if on the ground and accX == 0 & velX == 0
			self.x = self.x + ( self.xInput * dt )
	-- POSTITION 2 (run)
		elseif math.abs(joystickXpos) >= 0.35 then
			-- on ground
			if self.velX == 0 and self.accX == 0 then self.velX = self.xInput; self.accX = self.xInput end
			if math.abs(self.accX) < self.speed then self.accX = self.accX + ( (self.xInput * 2) * dt ) else self.accX = self.speed * self:polarity(self.accX)  end
			if math.abs(self.velX) > self.speed then self.velX = self.speed * self:polarity(self.velX) end
			if math.abs(self.velX) >= self.speed then self.accX = 0 end

			if self:polarity(joystickXpos) ~= self:polarity(self.velX) and math.abs(self.velX) > self.speed * .25 then self.velX = self.velX * .5; self.accX = self.accX + (self.speed * 0.35) * self:polarity(joystickXpos)  end
			
			-- boost acceleration and velocity when below velocity threshold
			if math.abs(self.velX) < self.speed * 0.35 then self.velX = self.velX + (self.speed * 0.35) * self:polarity(joystickXpos); self.accX = self.accX + (self.speed * 0.35) * self:polarity(joystickXpos)
			elseif math.abs(self.velX) < self.speed * 0.5 then self.velX = self.velX + (self.speed * 0.5) * self:polarity(joystickXpos); self.accX = self.accX + (self.speed * 0.5) * self:polarity(joystickXpos) end
		end

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
end



-- [ MOVEMENT QUEUE FUNCTIONS ]
function player.moveQueue:load()
	for i = 0, self.last do
		self[i] = {}
		self[i][0] = "-"
		self[i][1] = "-"
	end
end

function player.moveQueue:push( action_, time_ )
	if( action_ ~= nil ) then
		for i = 0, self.last - 1 do 
			self[self.last - i][0] = self[self.last - i - 1][0]
			self[self.last - i][1] = self[self.last - i - 1][1]
		end
			self[0][0] = action_
			self[0][1] = time_
	end
end

function player.moveQueue:pop( number )
	-- probably will not implement as is not necessary (so far)
end

function player.moveQueue:draw()
	for i = 0 , self.last - 1 do 
		love.graphics.printf( i .. ": " .. self[i][0], 550, 100 + ( i * 20 ), 100, 'left' )
		if self[i][1] ~= "-" then
			love.graphics.printf( (math.floor(self[i][1]*10)*0.1), 590, 100 + ( i * 20 ), 100, 'left' )
		else love.graphics.printf( "-", 590, 100 + ( i * 20 ), 100, 'left' ) end
	end
end



-- [ HELPER FUNCTIONS ]
function player:polarity( num )
	-- returns -1 for negative. 1 for positive. 0 for 0.
	if num > 0 then return 1 elseif num < 0 then return -1 else return 0 end
end