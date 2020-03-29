
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
