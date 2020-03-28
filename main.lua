
require"utils"

function love.load()
	love.mouse.setVisible( false )
	t = 0
	w, h = love.graphics.getDimensions()
	shader_threshold = love.graphics.newShader"threshold.glsl"
	shader_red       = love.graphics.newShader"threshold_red.glsl"
	isShowingImages, isShowingHeatmaps = true, true
	removeMode = 0
	threshold = 0.01
	shader = shader_threshold
	shader:send( "threshold", threshold )

	dataSet = newDataset"japanese"
	index = 1
	-- preload 10 images
	preload( dataSet, 10, index )

	fetch = function() -- TODO get rid of this and do this in another thread
		if index%5==0 then  preload( dataSet, 10, index )  end
	end
end

function love.update( dt )
	t = t + dt
	local entry = dataSet[index]
	hmScale = h/entry.region.h
end

function love.draw()
	local entry = dataSet[index]
	local secondX = hmScale*entry.region.w
	if isShowingImages then
		local ratio = h/entry.source.h
		love.graphics.draw( entry.source.img, 0,       0, 0, ratio, ratio )
		love.graphics.draw( entry.source.img, secondX, 0, 0, ratio, ratio )
	end
	if isShowingHeatmaps then
		love.graphics.setShader( shader )
		love.graphics.draw( entry.region.img,   0,       0, 0, hmScale, hmScale )
		love.graphics.draw( entry.affinity.img, secondX, 0, 0, hmScale, hmScale )
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
			mx_ = mx<=secondX and mx + secondX or mx - secondX
			love.graphics.circle( "fill", mx_, my, 2 )
			love.graphics.print( mode[removeMode], mx_, my )
			if boxX then
				love.graphics.rectangle( "line", boxX + secondX, boxY, boxWidth, boxHeight )
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
	j = function()  index = math.min( index + 1, NUMBER_OF_FILES ); fetch()  end,
	k = function()  index = math.max( 1, index - 1 )              ; fetch()  end,
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
