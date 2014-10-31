player = {} --CREATE PLAYER TABLE

function player.load( )
	-- [Player Graphics]
	player.sprite = love.graphics.newImage( "char/hughes/stand.png" )
	player.facing = "right"

	-- [Player Position and Movement]
	player.state = 'idle'
	player.x = 50
	player.y = 215
	player.velX = 0
	player.velY = 0
	player.accX = 0
	player.accY = 0

	-- [Player Stats]
	player.speed = 350
	player.hp = 1000
	player.energy = 5000
	player.attack = 2 -- out of 3. where 1 is weak, 2 is well average, and 3 is strong.
	player.defense = 2 -- ditto^

	-- [ Temp constants and variables (for dev)]
	player.gravity = 2500

	--player.hitbox_x = player.x + 12
	--player.hitbox_y = player.y + 12
	--player.hitbox = Collider:addRectangle( player.hitbox_x, player.hitbox_y, 10, 15 )
end

function player.draw( )
	player.sprite = player.sprite
	love.graphics.draw ( player.sprite, player.x, player.y )

	-- [ Dev Player info ]
	love.graphics.printf( player.state, 10, 10, 150, 'left' )
	love.graphics.printf( "facing:  " .. player.facing, 500, 10, 150, 'left' )
	love.graphics.printf( "velocity:  " .. player.velY, 10, 30, 550, 'left' )
	love.graphics.printf( "acceleration:  " .. player.accY, 10, 50, 550, 'left' )
	love.graphics.printf( "speed:  " .. player.speed, 10, 70, 550, 'left' )
	-- player.hitbox:draw("fill")
end

function player.update( dt )

	-- [ Keyboard Input ]
	if love.keyboard.isDown( "up" ) then
		if player.state ~= 'jumping' then
			player.state = 'jumping'
			player.velY = 450
		end
	end
	if love.keyboard.isDown( "down" ) then
		player.velY = player.velY - 25
	end
	if love.keyboard.isDown( "left" ) then
		player.x = player.x - ( player.speed * dt )
		if player.state ~= "jumping" then
			player.facing = "left"
		end

	end
	if love.keyboard.isDown( "right" ) then
		player.x = player.x + ( player.speed * dt )
		if player.state ~= "jumping" then	
			player.facing = "right"
		end
	end

	-- [Joystick Input]
	--player.speed =  350 * joystick:getAxis(1)


	-- [Plater State Resolve]
	if player.state == "idle" then
		player.velY = 0
		player.accY = 0
		player.speed = 350
	end

	if player.state == 'jumping' then
		-- jump
		--apply gravity
		player.accY = player.accY - ( player.gravity * dt )
		--update velocity
		player.velY = player.velY + ( player.accY * dt )
		--update position
		player.y = player.y - player.velY * dt

		-- back jump resistance
		if love.keyboard.isDown( "left" ) and player.facing == "right" then
			player.speed = 200
		end
		if love.keyboard.isDown( "right" ) and player.facing == "left" then
			player.speed = 200
		end

		-- reset to idle
		if player.y >= 215 then
			player.state = 'idle'
		end

	end 

	-- [ Hitbox Position and Movement ]
	--player.hitbox:moveTo( player.hitbox_x, player.hitbox_y)
end