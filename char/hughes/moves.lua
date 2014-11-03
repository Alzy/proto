function player:attack( attack )
	-- conditional attack launches
	if attack == "punch -w" then
		self:weakPunch()
	end

end

function player:weakPunch()
	love.graphics.printf( "BAM!", 200, 70, 150, 'left' )
end
