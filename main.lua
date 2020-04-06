
require"utils"
require"dataset"
require"edit"
require"navigation"

function love.load()
	love.mouse.setVisible( false )
	t = 0
	w, h = love.graphics.getDimensions()
	shader_threshold = love.graphics.newShader"threshold.glsl"
	shader_red       = love.graphics.newShader"threshold_red.glsl"
	isShowingImages, isShowingHeatmap = true, true
	removeMode = false
	threshold = 0.01
	shader = shader_threshold
	shader:send( "threshold", threshold )

	dataSet = newDataset"japanese"
	-- preload 10 images
	preload( dataSet, 10 )
end

function love.update( dt )
	t = t + dt
end

function love.draw()
	local entry, hmScale = dataSet.entry, dataSet.hmScale
	if isShowingImages then
		local ratio = h/entry.source.h
		love.graphics.draw( entry.source.img, 0, 0, 0, ratio, ratio )
	end
	if isShowingHeatmap then
		love.graphics.setShader( shader )
		love.graphics.draw( entry.mask.img, 0, 0, 0, hmScale, hmScale )
		love.graphics.setShader()
	end
	-- draw the cursor and the boxes
	local mx, my = love.mouse.getPosition()
	love.graphics.setColor( 1, 0.5, 0 )
	love.graphics.circle( "fill", mx, my, 2 )
	if removeMode then
		local boxWidth, boxHeight
		love.graphics.print( "removing", mx, my )
		if boxX then
			boxWidth, boxHeight = mx - boxX, my - boxY
			love.graphics.rectangle( "line", boxX, boxY, boxWidth, boxHeight )
		end
	end
	love.graphics.setColor( 1, 1, 1 )
end

keys = {
	escape = love.event.quit,
	r = function()  removeMode = not removeMode;  if not removeMode then  deleteBox()  end  end,
	space = function()  isShowingImages = not isShowingImages  end,
	m = function()  isShowingHeatmap = not isShowingHeatmap  end,
	tab = function()
		shader = shader==shader_threshold and shader_red or shader_threshold
		shader:send( "threshold", threshold )
	end,
	j = nextPage,
	k = lastPage,
}

function love.mousepressed( x, y, l, r )
	if not removeMode then  return  end
	if not boxX then
		boxX, boxY = x, y
		return
	end
	return removeBox( boxX, boxY, x - boxX, y - boxY )
end

function love.keypressed( k )
	local action = keys[k]
	if action then  return action()  end
end
