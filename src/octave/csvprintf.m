## Export numeric array to CSV file.
##
## This is equivalent to calling `dlmprintf(file, format, M, ', ', H)`.
function csvprintf(file, format, M, H)
	dlmprintf(file, format, M, ', ', H);
endfunction
