
local Matrix = {}
Matrix.__index = Matrix

-- 0 is not a natural number here
local function isNat( a )  return a>0 and a%1==0  end

function Matrix.new( tableOfTables )
	local w = #tableOfTables[1]
	for row=2, #tableOfTables do
		local w2 = #tableOfTables[row]
		assert( w2==w, ("Matrix is malformed. Row %d has length %d, but the first row has length %d."):format( row, w2, w ) )
	end
	return setmetatable( tableOfTables, Matrix )
end

function Matrix:flatten()
	local vec = {}
	for _, v in ipairs( self ) do
		for _, val in ipairs( v ) do
			vec[#vec + 1] = val
		end
	end
	return setmetatable( vec, Matrix )
end

function Matrix:reshape( self, m, n )
	local entries = self:flatten()
	-- poor man's type safety
	assert( isNat( m ) and isNat( n ) , ("Dimensions of matrix must be natural numbers, got %s, %s"):format( m, n )   )
	assert( type( entries )=="table"  , ("matrix entries must be in a table, got %s"):format( type( entries ) )       )
	assert( #entries==m*n             , ("got %d entries, expected %d (%d*%d) entries"):format( #entries, m*n, m, n ) )

	local mat = {}
	for i=1, m do
		mat[i] = mat[i] or {}
		for j=1, n do
			mat[i][j] = entries[(i-1)*n + j]
		end
	end
	return setmetatable( mat, Matrix )
end

function Matrix.__tostring( self )
	return table.concat( imap( function( x )  return table.concat( x, '\t' )  end, self ), '\n' )
end

-- slow ass naive matrix multiplication
function Matrix.__mul( self, other )
	local m1, n1, m2, n2 = #self, #self[1], #other, #other[1]
	assert( n1==m2, ("Dimension mismatch! Tried to multiply (%dx%d) with (%dx%d)"):format( m1, n1, m2, n2 ) )
	local mat = {}
	for i=1, m1 do
		mat[i] = mat[i] or {}
		for j=1, n2 do
			local acc = 0
			for k=1, n1 do
				acc = acc + self[i][k]*other[k][j]
			end
			mat[i][j] = acc
		end
	end
	return setmetatable( mat, Matrix )
end

local function makeMatrixCombinator( f, self, other )
	return function( self, other )
		local m1, n1, m2, n2 = #self, #self[1], #other, #other[1]
		assert( m1==m2 and n1==n2 , ("Dimension mismatch! Tried to multiply (%dx%d) with (%dx%d)"):format( m1, n1, m2, n2 ) )
		local mat = {}
		for i=1, m1 do
			mat[i] = zipWith( f, self[i], other[i] )
		end
		return setmetatable( mat, Matrix )
	end
end
Matrix.__add = makeMatrixCombinator( function( a, b )  return a + b  end, self, other )
Matrix.__sub = makeMatrixCombinator( function( a, b )  return a - b  end, self, other )

return Matrix
