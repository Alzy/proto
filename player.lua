-- this is a rewrite of player.lua. NOT code for 2nd Player.
-- purpose: allow inheritance.

player = {
	-- [Player Info]
	name,
	facing,

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
	charsheet,
	charSheetArray,
	moveQueue = { first = 0, last = 10 },
	action,
	prevYposition,
	xInput,

	-- temp variables
	gravity

} --CREATE PLAYER TABLE

function player:load( )
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
				self.charSheetArray[line:sub( 1, line:find("=")-  1 )] = line:sub(line:find("=") + 1)
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

	-- [Temp constants and variables (for dev)]
	self.gravity = 4125

	-- [Load Moveset]
	require "char/hughes/moves"

	-- [Load Queue]
	self.moveQueue:load()

	-- [ Helpers ]
	self.prevYposition = self.y

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

	-- [Dev Player Info : right side ]
	love.graphics.printf( "name :  " .. self.name, 550, 10, 150, 'left' )
	love.graphics.printf( "facing:  " .. self.facing, 550, 30, 150, 'left' )
	love.graphics.printf( "HP:  " .. self.hp, 550, 50, 150, 'left' )
	love.graphics.printf( "Energy:  " .. self.energy, 550, 70, 150, 'left' )
	love.graphics.printf( self.moveQueue[10], 550, 100, 150, 'left' )
	-- self.hitbox:draw("fill")
end

function player:update( dt )
	-- [ Joystick Motion ]
	self.xInput =  self.speed * joystick:getAxis(1)
	if joystick:getAxis(2) < -0.79 then --up
		if self.state ~= 'jumping' and self.state ~= 'falling' then
			self.state = 'jumping'
			self.velY = tonumber(self.charSheetArray["jumpVel"])  -- must be variable per character
		end
	end
	if joystick:getAxis(2) > 0.65 then --down
		self.velY = self.velY - 55
	end
	if joystick:getAxis(1) < -0.17 then --left
		if joystick:getAxis(1) > -0.35 and self.accX == 0 and self.velX == 0 then self.x = self.x + ( (self.speed * joystick:getAxis(1)) * dt ) 
		elseif self.velX > self.speed * -1 then
			if joystick:getAxis(1) > -0.85 then
				self.accX = self.accX + ( self.xInput * dt ) * 2
			else
				if math.abs(self.velX) < self.speed * 0.85 and self.accX == 0 then self.velX = self.speed * -0.85 end 
				self.accX = self.accX + ( self.xInput * dt ) * 50
			end
		end
		if self.state ~= "jumping" and self.state ~= 'falling' then
			self.facing = "left"
		end
	end
	if joystick:getAxis(1) > 0.17 then --right
		if joystick:getAxis(1) < 0.35 and self.accX == 0 and self.velX == 0 then self.x = self.x + ( (self.speed * joystick:getAxis(1)) * dt ) 
		elseif self.velX < self.speed then
			if joystick:getAxis(1) < 0.85 then
				self.accX = self.accX + ( self.xInput * dt ) * 2
			else
				if math.abs(self.velX) < self.speed * 0.85 and self.accX == 0 then self.velX = self.speed * 0.85 end 
				self.accX = self.accX + ( self.xInput * dt ) * 50
			end
		end
		if self.state ~= "jumping" and self.state ~= 'falling' then	
			self.facing = "right"
		end
	end

	-- stop player at joystick neutral position.
	if joystick:getAxis(1) >= -0.35 and joystick:getAxis(1) <= 0.35  and self.velX ~= 0 and self.state ~= "jumping" and self.state ~= "falling" then
		--bring player to hault.
		if math.abs(self.velX) <= self.speed * 0.35 then
			self.velX = 0
			self.accX = 0
		end

		if self.velX > 0 then
			self.accX = self.accX - ( (self.velX * 20) * dt )
		else
			self.accX = self.accX - ( (self.velX * 20) * dt )
		end

	end

	-- [Joystick Input]
	if joystick:isDown(11) then  -- see "joystick list of button indexs.txt"
		self.action = "punch -w"
	end


	-- [Player State Resolve]
	if self.state == "idle" then
		self.velY = 0
		self.accY = 0
		--self.speed = tonumber(self.charSheetArray["speed"])
	end

	if self.y > self.prevYposition then
		self.state = "falling"
	end
	if self.prevYposition ~= self.y then
		self.prevYposition = self.y
	end

	if self.state == 'jumping' or self.state == 'falling' then
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

	if self.playAnimation == true then
		self.sprite:update(dt)
	end

	-- limit speed and acceleration
	if self.velX > self.speed then self.velX = self.speed; self.accX = 0 end
	if self.velX < self.speed * -1 then self.velX = self.speed * -1; self.accX = 0 end
	-- update velocity
	self.velX = self.velX + ( self.accX * dt )
	-- update player x location
	self.x = self.x + ( self.velX * dt )

	self:performAction(self.action)

	-- [ Hitbox Position and Movement ]
	--self.hitbox:moveTo( self.hitbox_x, self.hitbox_y)
end




-- [ MOVEMENT QUEUE FUNCTIONS ]

function player.moveQueue:load()
	self[0] = "-"
	for i = 0, self.last do
		self[i] = "o.o"
	end
end

function player.moveQueue:push( action_ )
	if( action ~= nil ) then
		for i = 0, self.last - 1 do 
			self[i + 1] = self[i]	
		end
			self[0] = action_
	end
end

function player.moveQueue:pop( number )
	-- probably will not implement as is not necessary (so far)
end

function player.moveQueue:toString()
	-- body
	-- return formatted string ie: "UpDownPunchPunchDownKick" , "UDPPDK"
end