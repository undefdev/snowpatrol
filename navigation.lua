
fetch = function() -- TODO get rid of this and do this in another thread
	if dataSet.index%5==0 then  preload( dataSet, 10 )  end
end

function goToPage( n )
	dataSet.index = clamp( n, 1, NUMBER_OF_FILES )
	removeMode = false
	fetch() 						
end
function nextPage()  return goToPage( dataSet.index + 1 )  end
function lastPage()  return goToPage( dataSet.index - 1 )  end
