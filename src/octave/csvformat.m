## -*- texinfo -*-
## @deftypefn {Function File} {} csvformat(@var{file}, @var{format}, @var{M}, @var{h})
##
## Export numeric array @var{M} to CSV format with a header @var{H}
## to @var{file}.
##
## This is equivalent to calling
## @w{@code{dlmformat(file, format, M, ", ", H)}}.
##
## @var{file} can be a filename or a file handle. If it is a filename, a file
## with this name is written.
##
## The individual cells are formatted according to @var{format}. This is
## a space-separated string containing a format string for each column.
## This argument is split at spaces, a comma and space is inserted
## between them and a newline is appended to the end. Care must be taken
## to ensure that the number of elements matches the number of columns in
## the input matrix @var{M}.
## @end deftypefn
function csvformat(file, format, M, H)
	dlmformat(file, format, M, ', ', H);
endfunction
