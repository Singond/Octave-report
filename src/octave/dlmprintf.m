## -*- texinfo -*-
## @deftypefn {Function File} {} dlmprintf(@var{file}, @var{format}, @var{M}, @var{dlm}, @var{h})
##
## Export numeric array @var{M} to delimiter separated values with a header
## @var{H} to @var{file}.
##
## @var{file} can be a filename or a file handle. If it is a filename, a file
## with this name is written.
##
## The individual cells are formatted according to @var{format}. This is
## a space-separated string containing a format string for each column.
## This argument is split at spaces, a delimiter @var{dlm} is inserted
## between them and a newline is appended to the end. Care must be taken
## to ensure that the number of elements matches the number of columns in
## the input matrix @var{M}.
## @end deftypefn
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
