
function getFilesystemTree( dir, paths )  paths = paths or {}
	local files = love.filesystem.getDirectoryItems( dir )
	for k, name in ipairs( files ) do
		local item = dir .. "/" .. name
		if love.filesystem.getInfo( item, "directory" ) then
			getFilesystemTree( item, paths )
		end
		paths[#paths+1] = item
	end
	return paths
end
function filter( list, filterFunction )
	local ret = {}
	for _, item in ipairs( list ) do
		if filterFunction( item ) then
			ret[#ret + 1] = item
		end
	end
	return ret
end
function getGZs( dir )
	local tree = getFilesystemTree( dir )
	return filter( tree, function( s )  return s:match"%.gz$"  end )
end
do
	local imageExtensions = { jpeg = true, jpg = true, png = true }
	local function hasImageExtension( s )
		return imageExtensions[(s:match"%.(%w+)$" or "not an image"):lower()]
	end
	function getImages( dir )
		local tree = getFilesystemTree( dir )
		return filter( tree, hasImageExtension  )
	end
end

function read_tsv_image( filename, compression )
	local file = love.filesystem.read( "string", filename )
	local tsv = compression and love.data.decompress( "string", compression, file )
							or  file
	local w, h = 0, 0
	for line in tsv:gmatch"(.-)\n" do
		if h==0 then
			for val in line:gmatch"%S+" do
				w = w + 1
			end
		end
		h = h + 1
	end
	local imageData = love.image.newImageData( w, h, "rgba32f" )
	local y = 0
	for line in tsv:gmatch"(.-)\n" do
		local x = 0
		for val in line:gmatch"%S+" do
			val = tonumber( val )
			local r = val>=0.5 and val or 0
			local g = val<0.5 and val or 0
			imageData:setPixel( x, y, r, g, val, 0.5 )
			x = x + 1
		end
		y = y + 1
	end
	return { img = love.graphics.newImage( imageData ), data = imageData, w = w, h = h }
end
function write_tsv_image( filename, imageData, compression )
	local w, h = imageData:getDimensions()
	local file = love.filesystem.newFile( filename, "w" )
	local fileTable = {}
	for y=0, h - 1 do
		local line, _ = {}
		for x=0, w - 1 do
			local _, _, v = imageData:getPixel( x, y )
			-- our input only has nine digits, so our output should too
			line[x] = v==0 and 0 or ("%.9f"):format( v )
		end
		fileTable[y] = table.concat( line, '\t', 0 )
	end
	local tsv = table.concat( fileTable, '\n', 0 )
	tsv = compression and love.data.compress( "string", compression, tsv )
					  or  tsv
	assert( file:write( tsv ) )
end

function newDataset( dir )
	local tsvDir = dir .. "_TSV"
	local filenames = getImages( dir )
	NUMBER_OF_FILES = #filenames
	local dataSet_mt = { __index = function( tbl, k )
		local name = filenames[k]
		if not name then  return  end
		local img = love.graphics.newImage( name )
		local w, h = img:getDimensions()
		local prefix = name:gsub( dir, tsvDir )
		local entry = {
			source = { img = img, w = w, h = h },
			region   = read_tsv_image( prefix .. "_region.tsv.gz",   "gzip" ),
			affinity = read_tsv_image( prefix .. "_affinity.tsv.gz", "gzip" ),
			name = name,
		}
		tbl[k] = entry
		-- only keep the next 10 and last 10 entries in memory
		tbl[k + 10] = nil
		tbl[k - 10] = nil
		return entry
	end }
	return setmetatable( {}, dataSet_mt )
end
function preload( dataSet, numberOfEntries, startIndex )
	startIndex = startIndex or 1
	for i=0, numberOfEntries - 1 do
		local _ = dataSet[startIndex + i]
	end
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
	if a then  return a/hmScale, descaleCoordinates( ... )  end
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
