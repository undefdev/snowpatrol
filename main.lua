
require"utils"
require"dataset"
require"edit"
require"navigation"
require"modes"

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
	mode.draw()
end

keys = {
	escape = love.event.quit,
	r = function()  setMode"remove"  end,
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
	if mode.mousepressed then
		return mode.mousepressed( x, y, l, r )
	end
end

function love.keypressed( k )
	local action = keys[k]
	if action then  return action()  end
end
