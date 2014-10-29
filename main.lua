--HC = require "hardoncollider"
require "player"

function love.load(  )
	SCREEN_WIDTH = love.graphics.getWidth()
	SCREEN_HIGHT = love.graphics.getHeight()
	love.graphics.setBackgroundColor( 250, 241, 250 )


	--Collider = HC(100, onCollision, collision_stop)
	--rect = Collider:addRectangle(175, 40,40,100)


	--TIMER STUFF
	Clock = love.timer.getTime()


	--LOAD TABLES
	player.load()

	--LOAD BG
	bgLayer0 = love.graphics.newImage("bg/bg.jpg")
end

function love.draw(  )

	--graphics scaling.

    love.graphics.draw(bgLayer0, 0, 0)
	player.draw()
	
end

function love.update ( dt )
	player.update( dt )
	--Collider:update( dt )
end

function love.textinput(t)
	text = text .. t
end