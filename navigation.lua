
fetch = function() -- TODO get rid of this and do this in another thread
	if index%5==0 then  preload( dataSet, 10, index )  end
end

function goToPage( n )
	index = clamp( n, 1, NUMBER_OF_FILES )
	entry = dataSet[index]
	removeMode = false
	fetch() 						
end
function nextPage()  return goToPage( index + 1 )  end
function lastPage()  return goToPage( index - 1 )  end
