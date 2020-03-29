
function clamp( x, a, b )  return math.min( math.max( x, a ), b )  end

function filter( list, filterFunction )
	local ret = {}
	for _, item in ipairs( list ) do
		if filterFunction( item ) then
			ret[#ret + 1] = item
		end
	end
	return ret
end

function deleteBox()  boxX, boxY = nil  end

function descaleCoordinates( a, ... )
	if a then  return a/hmScale, descaleCoordinates( ... )  end
end

function processBoxCoordinates( x, y, w, h )
	local x, y, w, h = descaleCoordinates( x, y, w, h )
	if w<0 then  x = x + w;  w = -w  end
	if h<0 then  y = y + h;  h = -h  end
	x, y = clamp( x, 0, entry.mask.w     ), clamp( y, 0, entry.mask.h     )
	w, h = clamp( w, 0, entry.mask.w - x ), clamp( h, 0, entry.mask.h - y )
	return x, y, w, h
end
