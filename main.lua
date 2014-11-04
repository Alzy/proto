--HC = require "hardoncollider"
require "player2"

function love.load(  )
	SCREEN_WIDTH = love.graphics.getWidth()
	SCREEN_HIGHT = love.graphics.getHeight()
	love.graphics.setBackgroundColor( 250, 241, 250 )


	--Collider = HC(100, onCollision, collision_stop)
	--rect = Collider:addRectangle(175, 40,40,100)

	-- Joysticks
	local joysticks = love.joystick.getJoysticks()
	joystick = joysticks[1]

	--TIMER STUFF
	Clock = love.timer.getTime()


	--LOAD TABLES
	player:load()
	player.moveQueue:push( ":P" )

	--LOAD BG
	bgLayer0 = love.graphics.newImage("bg/bg.jpg")
end

function love.draw(  )

	--graphics
    love.graphics.draw(bgLayer0, 0, 0)
	player:draw()
	
	-- vJoy dev info
	love.graphics.printf( "joysticks:  " .. love.joystick.getJoystickCount(), 10, 300, 550, 'left' )

    love.graphics.printf(joystick:getName(), 10, 320, 550, "left" )
    
    --if joystick:isGamepad() == true then love.graphics.printf("gamepad", 50, (i * 20) + 300, 550, "left" ) end
    -- C = count
    love.graphics.printf( "Axis C:  " .. joystick:getAxisCount(), 10 , 340, 550, "left" )
    love.graphics.printf( "Axis X:  " .. math.floor( 100 * joystick:getAxis(1) ) .. '%', 100 , 340, 100, "left" )
    love.graphics.printf( "Axis Y:  " .. math.floor( 100 * joystick:getAxis(2) ) .. '%', 200 , 340, 100, "left" )
end

function love.update ( dt )
	player:update( dt )
	--Collider:update( dt )
end

