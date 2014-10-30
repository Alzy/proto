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

	-- [Player Stats]
	player.speed = 255
	player.hp = 1000
	player.energy = 5000
	player.attack = 2 -- out of 3. where 1 is weak, 2 is well average, and 3 is strong.
	player.defense = 2 -- ditto^

	-- [ Temp constants and variables (for dev)]
	gravity = 0.2

	--player.hitbox_x = player.x + 12
	--player.hitbox_y = player.y + 12
	--player.hitbox = Collider:addRectangle( player.hitbox_x, player.hitbox_y, 10, 15 )
end

function player.draw( )
	player.sprite = player.sprite
	love.graphics.draw ( player.sprite, player.x, player.y )
	-- player.hitbox:draw("fill")
end

function player.update( dt )
	if love.keyboard.isDown( "up" ) then
		if player.state ~= 'jumping' then
			player.state = 'jumping'
		elseif player.state == 'jumping' then
			-- jump
		end 
	end
	if love.keyboard.isDown( "down" ) then
		--
	end
	if love.keyboard.isDown( "left" ) then
		player.x = player.x - ( player.speed * dt )
		player.facing = "left"
	end
	if love.keyboard.isDown( "right" ) then
		player.x = player.x + ( player.speed * dt )
		player.facing = "right"
	end
	--player.hitbox:moveTo( player.hitbox_x, player.hitbox_y)
end