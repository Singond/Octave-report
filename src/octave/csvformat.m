## -*- texinfo -*-
## @deftypefn {Function File} {} csvformat(@var{file}, @var{format}, @var{M}, @var{h})
## Export numeric array @var{M} to comma-separated values format
## with header @var{h} to @var{file}.
##
## This is equivalent to calling
## @w{@code{dlmformat(file, format, M, ", ", H)}}.
## @seealso{dlmformat}
## @end deftypefn
function csvformat(file, format, M, H)
	dlmformat(file, format, M, ', ', H);
endfunction
