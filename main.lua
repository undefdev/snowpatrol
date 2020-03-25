
require"utils"

function love.load()
	love.mouse.setVisible( false )
	t = 0
	w, h = love.graphics.getDimensions()
	W = 464
	H = 640
	RATIO = h/H
	img = love.graphics.newImage"test.jpg"
	heatmap_score = read_tsv_image( "test.tsv", W, H )
	heatmap_link  = read_tsv_image( "link.tsv", W, H )
	shader_threshold = love.graphics.newShader"threshold.glsl"
	shader_red       = love.graphics.newShader"threshold_red.glsl"
	isShowingImages, isShowingHeatmaps = true, true
	removeMode = 0
	threshold = 0.01
	shader = shader_threshold
	shader:send( "threshold", threshold )
end

function love.update( dt )
	t = t + dt
end

function love.draw()
	local he = img:getHeight()
	if isShowingImages then
		love.graphics.draw( img, 0, 0, 0, H/he*RATIO, H/he*RATIO )
		love.graphics.draw( img, W*RATIO, 0, 0, H/he*RATIO, H/he*RATIO )
	end
	if isShowingHeatmaps then
		love.graphics.setShader( shader )
		love.graphics.draw( heatmap_score.img, 0, 0, 0, RATIO, RATIO )
		love.graphics.draw( heatmap_link.img, RATIO*W, 0, 0, RATIO, RATIO )
		love.graphics.setShader()
	end
	-- draw the cursor and the boxes
	local mx, my = love.mouse.getPosition()
	local mode = { "LR", "L", "R" }
	love.graphics.setColor( 1, 0.5, 0 )
	love.graphics.circle( "fill", mx, my, 2 )
	if removeMode>0 then
		local boxWidth, boxHeight
		love.graphics.print( mode[removeMode], mx, my )
		if boxX then
  			boxWidth, boxHeight = mx - boxX, my - boxY
			love.graphics.rectangle( "line", boxX, boxY, boxWidth, boxHeight )
		end
		if removeMode==1 or removeMode==3 then
			local offset = RATIO*W
			mx_ = mx<=offset and mx + offset or mx - offset
			love.graphics.circle( "fill", mx_, my, 2 )
			love.graphics.print( mode[removeMode], mx_, my )
			if boxX then
				love.graphics.rectangle( "line", boxX + offset, boxY, boxWidth, boxHeight )
			end
		end
	end
	love.graphics.setColor( 1, 1, 1 )
end
keys = {
	escape = love.event.quit,
	r = function()  removeMode = (removeMode + 1)%4;  if removeMode==0 then  deleteBox()  end  end,
	space = function()  isShowingImages = not isShowingImages  end,
	m = function()  isShowingHeatmaps = not isShowingHeatmaps  end,
	tab = function()
		shader = shader==shader_threshold and shader_red or shader_threshold
		shader:send( "threshold", threshold )
	end,
}

function love.mousepressed( x, y, l, r )
	if removeMode>0 and not boxX then
		boxX, boxY = x, y
		return
	end
	return removeBox( removeMode, boxX, boxY, x - boxX, y - boxY )
end

function love.keypressed( k )
	local action = keys[k]
	if action then  return action()  end
end
