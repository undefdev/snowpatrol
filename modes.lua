
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
	markCharacter = {
		draw = function()
			drawCursor()
			local dists = mode.data
			for k, dist in ipairs( dists ) do
				local x, y = dist.mean[1], dist.mean[2]
				love.graphics.circle( "line", x, y, h/100 )
				if k==#dists and #dist<2 then
					local mx, my = love.mouse.getPosition()
					local dx, dy = mx - x, my - y
					strokedLine( x - dx, y - dy, mx, my )
				end
				for _, vec in ipairs( dist ) do
					love.graphics.line( x, y, x + vec[1], y + vec[2] )
				end
			end
		end,
		mousepressed = function( x, y, l, r )
			local dists = mode.data
			if #dists==0 or #dists[#dists]==2 then
				return addMean( x, y )
			end
			return addPrincipalComponent( x, y )
		end,
	},
}

function setMode( m )
	mode = modes[m]
	mode.data = {}
end
setMode"default"
setMode"markCharacter"
