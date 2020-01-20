function r = rounds(x, n)
	if (!isnumeric(x))
		error("x must be numeric");
	endif
	if (nargin < 2)
		n = 1;
	elseif (!isnumeric(x) || !isscalar(n))
		error("n must be an integer");
	endif
	f = floor(log10(x));        # Order of the first significant digit
	s = f - n + 1;              # Order of the last non-zero digit in result
	if (s != 0)
		r = round(x.*(10^(-s))) .* 10^s;
	else
		r = round(x);
	endif
endfunction
