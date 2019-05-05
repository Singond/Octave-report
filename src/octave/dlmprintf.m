## Export numeric array to a delimiter-separated value format with a header.
function dlmprintf(file, format, M, dlm, H)
	## Make sure 'file' is a valid file handle
	localhandle = 0; # File handle is local and should be closed before return
	if (is_valid_file_id(file))
		## Do nothing, 'file' is already an open and existing file
	elseif (ischar(file))
		file = fopen(file, "w");
		localhandle = 1;
	endif

	## Build format for header and data

	cellformat = strsplit(format);              # Format of individual cells
	c = length(cellformat);                     # Number of columns

	## Calculate width of each column
	## To avoid reading all data, consider only the header and first data row
	headerline = "";
	dataformatline = "";
	delim = dlm;
	for i = 1:c
		datafmt = cellformat{i};
		datastr = sprintf(datafmt, M(1,i));
		headerstr = H{i};
		colwidth = max([length(datastr), length(headerstr)]);
		if (i == c)
			delim = "";
		endif
		f = sprintf("%%%ds", colwidth);
		headerline = [headerline sprintf(f, headerstr) delim];
		f = sprintf("%%%ds", colwidth - length(datastr) + length(datafmt));
		dataformatline = [dataformatline sprintf(f, datafmt) delim];
	endfor

	## Write
	fprintf(file, headerline);
	fwrite(file, "\n");
	fprintf(file, [dataformatline "\n"], M');

	## Clean up resources
	if (localhandle)
		fclose(file);
	endif
endfunction
