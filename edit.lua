
local Matrix = require"Matrix"

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

function removeBox( x, y, w, h )
	local x, y, w, h = processBoxCoordinates( x, y, w, h )
	if w==0 or h==0 then  return  end
	remove_box_from_heatmap( dataSet.entry.mask, x, y, w, h )
end
