-- this is a rewrite of player.lua. NOT code for 2nd Player.
-- purpose: allow inheritance.

player = {
	-- [self Graphics]
	sprite,
	facing,
	
	-- [self Position and Movement]
	x,
	y,
	velX,
	velY,
	accX,
	accY,

	-- [self Stats]
	speed,
	hp,
	energy,
	attack,
	defense,

	-- temp variables
	gravity

} --CREATE PLAYER TABLE

function player:load( )
	-- [Player Graphics]
	self.sprite = love.graphics.newImage( "char/hughes/stand.png" )
	self.facing = "right"

	-- [Player Position and Movement]
	self.state = 'idle'
	self.x = 50
	self.y = 215
	self.velX = 0
	self.velY = 0
	self.accX = 0
	self.accY = 0

	-- [Player Stats]
	self.speed = 350
	self.hp = 1000
	self.energy = 5000
	self.attack = 2 -- out of 3. where 1 is weak, 2 is well average, and 3 is strong.
	self.defense = 2 -- ditto^

	-- [ Temp constants and variables (for dev)]
	self.gravity = 2500

	--self.hitbox_x = self.x + 12
	--self.hitbox_y = self.y + 12
	--self.hitbox = Collider:addRectangle( self.hitbox_x, self.hitbox_y, 10, 15 )
end

function player:draw( )
	self.sprite = self.sprite
	love.graphics.draw ( self.sprite, self.x, self.y )

	-- [ Dev Player info ]
	love.graphics.printf( self.state, 10, 10, 150, 'left' )
	love.graphics.printf( "facing:  " .. self.facing, 500, 10, 150, 'left' )
	love.graphics.printf( "velocity:  " .. self.velY, 10, 30, 550, 'left' )
	love.graphics.printf( "acceleration:  " .. self.accY, 10, 50, 550, 'left' )
	love.graphics.printf( "speed:  " .. self.speed, 10, 70, 550, 'left' )
	-- self.hitbox:draw("fill")
end

function player:update( dt )

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

	-- [Joystick Input]
	--self.speed =  350 * joystick:getAxis(1)


	-- [Player State Resolve]
	if self.state == "idle" then
		self.velY = 0
		self.accY = 0
		self.speed = 350
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
			self.speed = 200
		end
		if love.keyboard.isDown( "right" ) and self.facing == "left" then
			self.speed = 200
		end

		-- reset to idle
		if self.y >= 215 then
			self.state = 'idle'
		end

	end 

	-- [ Hitbox Position and Movement ]
	--self.hitbox:moveTo( self.hitbox_x, self.hitbox_y)
end