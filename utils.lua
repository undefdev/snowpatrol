
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

function imap( fun, x )
	local ret = {}
	for k, v in ipairs( x ) do
		ret[k] = fun( v )
	end
	return ret
end

function zipWith( f, a, b )
	local ret = {}
	for k, v in ipairs( a ) do
		ret[k] = f( v, b[k] )
	end
end

function descaleCoordinates( a, ... )
	if a then  return a/dataSet.hmScale, descaleCoordinates( ... )  end
end

function processBoxCoordinates( x, y, w, h )
	local x, y, w, h = descaleCoordinates( x, y, w, h )
	local mask = dataSet.entry.mask
	if w<0 then  x = x + w;  w = -w  end
	if h<0 then  y = y + h;  h = -h  end
	x, y = clamp( x, 0, mask.w     ), clamp( y, 0, mask.h     )
	w, h = clamp( w, 0, mask.w - x ), clamp( h, 0, mask.h - y )
	return x, y, w, h
end

function dist( x1, y1, x2, y2 )
	local dx, dy = x2 - x1, y2 - y1
	return (dx^2 + dy^2)^(1/2)
end
function strokedLine( x1, y1, x2, y2 )
	local d = dist( x1, y1, x2, y2 )
	local l = h/100
	local dx, dy = l*(x2 - x1)/d, l*(y2 - y1)/d
	for i=0, d/l do
		if i%2==0 then
			love.graphics.line( x1 + dx*i, y1 + dy*i, x1 + dx*(i+1), y1 + dy*(i+1) )
		end
	end
end
