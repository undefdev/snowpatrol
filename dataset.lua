
require"filesystem"

function newDataset( dir )
	local tsvDir = dir .. "_TSV"
	local filenames = getImages( dir )
	NUMBER_OF_FILES = #filenames
	local dataSet_mt = { __index = function( tbl, k )
		if k=="entry" then
			return tbl[tbl.index]
		elseif k=="hmScale" then
			return h/tbl[tbl.index].mask.h
		end
		local name = filenames[k]
		if not name then  return  end
		local img = love.graphics.newImage( name )
		local w, h = img:getDimensions()
		local prefix = name:gsub( dir, tsvDir )
		local entry = {
			source = { img = img, w = w, h = h },
			mask = read_tsv_image( prefix .. "_region.tsv.gz",   "gzip" ),
			name = name,
			staged = {}, -- table of staged writes (distributions) to the mask
		}
		tbl[k] = entry
		-- only keep the next 10 and last 10 entries in memory
		tbl[k + 10] = nil
		tbl[k - 10] = nil
		return entry
	end }
	return setmetatable( { index = 1 }, dataSet_mt )
end

function preload( dataSet, numberOfEntries )
	for i=0, numberOfEntries - 1 do
		local _ = dataSet[dataSet.index + i]
	end
end
