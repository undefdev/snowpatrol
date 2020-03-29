
require"filesystem"

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
			mask = read_tsv_image( prefix .. "_region.tsv.gz",   "gzip" ),
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
