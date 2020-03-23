
function read_compressed_tsv_image( filename, width, height )
	local imageData = love.image.newImageData( width, height, "rgba32f" )
	local file = love.filesystem.read( "string", filename )
	local decompressedData = love.data.decompress( "string", "gzip", file )
	local y = 0
	for line in decompressedData:gmatch"(.-)\n" do
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
