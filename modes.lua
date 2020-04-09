
local function drawCursor()
	local mx, my = love.mouse.getPosition()
	love.graphics.setColor( 1, 0.5, 0 )
	love.graphics.circle( "fill", mx, my, 2 )
	love.graphics.setColor( 1, 1, 1 )
end

local modes = {
	default = {
		draw = drawCursor,
	},
	remove = {
		draw = function()
			drawCursor()
			local mx, my = love.mouse.getPosition()
			love.graphics.setColor( 1, 0.5, 0 )
			local boxWidth, boxHeight
			local boxX, boxY = mode.data.boxX, mode.data.boxY
			love.graphics.print( "removing", mx, my )
			if boxX then
				boxWidth, boxHeight = mx - boxX, my - boxY
				love.graphics.rectangle( "line", boxX, boxY, boxWidth, boxHeight )
			end
			love.graphics.setColor( 1, 1, 1 )
		end,
		mousepressed = function( x, y, l, r )
			local boxX, boxY = mode.data.boxX, mode.data.boxY
			if not boxX then
				mode.data.boxX, mode.data.boxY = x, y
				return
			end
			removeBox( boxX, boxY, x - boxX, y - boxY )
			setMode"default"
		end,
	},
}

function setMode( m )
	mode = modes[m]
	mode.data = {}
end
setMode"default"
