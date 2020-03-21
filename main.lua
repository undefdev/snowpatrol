function read_tsv_image( filename, width, height )
	local score_text = love.filesystem.newFile( filename )
	local imageData = love.image.newImageData( width, height, "rgba32f" )
	local y = 0
	for line in score_text:lines() do
		x = 0
		for val in line:gmatch"%S+" do
			val = tonumber( val )
			local r = val>=0.5 and val or 0
			local g = val<0.5 and val or 0
			imageData:setPixel( x, y, r, g, val, 0.5 )
			x = x + 1
		end
		y = y + 1
	end
	return { img = love.graphics.newImage( imageData ), data = imageData }
end

function write_tsv_image( filename, imageData )
	local w, h = imageData:getDimensions()
	local file = love.filesystem.newFile( filename, "w" )
	local fileTable = {}
	for y=0, h - 1 do
		local line, _ = {}
		for x=0, w - 1 do
			_, _, line[x] = imageData:getPixel( x, y )
		end
		fileTable[y] = table.concat( line, '\t', 0 )
	end
	assert( file:write( table.concat( fileTable, '\n', 0 ) ) )
end

function remove_box_from_heatmap( hm, x, y, w, h )
	hm.data:mapPixel( function()  return 0, 0, 0, 0.5  end, x, y, w, h )
	return hm.img:replacePixels( hm.data )
end
function apply_threshold_to_imageData( imageData, threshold )
	return imageData:mapPixel( function( x, y, r, g, b, a )
		if b<threshold  then
			return 0, 0, 0, a
		end
		return r, g, b, a
	end )
end

function love.load()
	love.mouse.setVisible( false )
	t = 0
	w, h = love.graphics.getDimensions()
	W = 464
	H = 640
	RATIO = h/H
	img = love.graphics.newImage"test.jpg"
	heatmap_score = read_tsv_image( "test.tsv", W, H )
	--write_tsv_image( "test_out.tsv", heatmap_score.data )
	--do return love.event.quit() end
	heatmap_link = read_tsv_image( "link.tsv", W, H )
	shader_threshold = love.graphics.newShader"threshold.glsl"
	shader_red = love.graphics.newShader"threshold_red.glsl"
	isShowingImages = true
	isShowingHeatmaps = true
	removeMode = 0
	threshold = 0.1
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

function deleteBox()  boxX, boxY = nil  end
function descaleCoordinates( a, ... )
	if a then  return a/RATIO, descaleCoordinates( ... )  end
end
function clamp( x, a, b )  return math.min( math.max( x, a ), b )  end
function processBoxCoordinates( x, y, w, h )
	local x, y, w, h = descaleCoordinates( x, y, w, h )
	if w<0 then  x = x + w;  w = -w  end
	if h<0 then  y = y + h;  h = -h  end
	x, y = clamp( x, 0, W     ), clamp( y, 0, H     )
	w, h = clamp( w, 0, W - x ), clamp( h, 0, H - y )
	return x, y, w, h
end
function getHeatmap( x, y )
	if x<=W then  return heatmap_score  end
	return heatmap_link
end
function removeBox( mode, x, y, w, h )
	local x, y, w, h = processBoxCoordinates( x, y, w, h )
	if w==0 or h==0 then  return deleteBox() end
	if mode<=2 then
		hm = getHeatmap( x, y )
		remove_box_from_heatmap( hm, x, y, w, h )
	end
	if mode%2==1 then
		hm = getHeatmap( x + W, y )
		remove_box_from_heatmap( hm, x, y, w, h )
	end
	deleteBox()
end
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
