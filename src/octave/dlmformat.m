## -*- texinfo -*-
## @deftypefn {Function File} {} dlmformat(@var{file}, @var{format}, @var{M}, @var{dlm}, @var{h})
## Export numeric array @var{M} to delimiter-separated values format
## with header @var{h} to @var{file}.
##
## @var{file} can be a filename or a file handle. If it is a filename, a file
## with this name is written.
##
## The individual cells are formatted according to @var{format}. This is
## a cell array of @code{printf}-style format strings to be applied to the
## data. The size of this cell array must be equal to the number of columns
## in @var{M}. The formatted cells are separated by @var{dlm}.
##
## Column headers can be specified using @var{h}, which is is a cell array
## of strings.
##
## Both @var{format} and @var{header} can be also specified as a plain string.
## In that case, the string is split at whitespace into elements.
## @end deftypefn
function dlmformat(file, format, M, dlm, H)
	## Make sure 'file' is a valid file handle
	localhandle = 0; # File handle is local and should be closed before return
	if (is_valid_file_id(file))
		## Do nothing, 'file' is already an open and existing file
	elseif (ischar(file))
		ensure_dir_exists(file);
		file = fopen(file, "w");
		localhandle = 1;
	endif

	## Parse format and header to individual elements
	format = makecell(format);              # Format of individual cells
	H = makecell(H);                        # Header of individual columns
	c = columns(M);                         # Number of columns
	if (length(format) != c)
		error("Data has %d columns, but format has %d parts", c, length(format));
	endif
	if (length(H) != c)
		error("Data has %d columns, but header has %d parts", c, length(H));
	endif

	## Calculate width of each column
	## To avoid reading all data, consider only the header and first data row
	headerline = "";
	dataformatline = "";
	delim = dlm;
	for i = 1:c
		datafmt = format{i};
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

function C = makecell(a)
	if (iscell(a))
		C = a;
	elseif (ischar(a))
		C = strsplit(a);
	endif
endfunction
