## Copyright (C) 2020 Jan Slany
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, see
## <https://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {Function file} {@var{r} =} rounds(@var{x}, @var{digits})
## @deftypefnx {Function file} {@var{r} =} rounds(@var{x})
## @deftypefnx {Function file} {[@var{r}, @var{f}, @var{l}] =} rounds(@dots{})
## Round @var{x} to the number of significant digits given by @var{digits}.
##
## @var{digits} must be either a scalar or a matrix broadcastable to the
## same shape as @var{x}. If it is omitted, it defaults to 1.
##
## The optional return values @var{f}, @var{l} return the (decimal) order
## of the first and last non-zero digit in the rounded result, respectively.
## @end deftypefn

## Author: Jan "Singon" Slany <singond@seznam.cz>
## Created: January 2020
## Keywords: round
function [r, f, l] = rounds(x, digits)
	if (!isnumeric(x))
		error("x must be numeric");
	endif
	if (nargin < 2)
		digits = 1;
	elseif (!isnumeric(digits) || any(digits) < 1)
		error("'digits' must be integer greater than zero");
	endif
	if (any(mod(digits, 1) != 0))
		error("'digits' must be integer");
	endif
	sgn = sign(x);
	x = abs(x);                 # Ensure x is positive
	f = floor(log10(x));        # Order of the first significant digit
	l = f - digits + 1;         # Order of the last non-zero digit in result
	r = zeros(size(x));
	M = (l != 0);
	r(M) = sgn(M) .* round(x(M).*(10.^(-l(M)))) .* 10.^l(M);
	r(!M) = sgn(!M) .* round(x)(!M);
endfunction

%!error <x must be numeric> rounds("abc", 1.5);
%!error <'digits' must be integer greater than zero> rounds(pi, "abc");
%!error <'digits' must be integer greater than zero> rounds(pi, 0);
%!error <'digits' must be integer> rounds(pi, 1.5);
%!error <'digits' must be integer> rounds(pi, 0.5);

%!assert(rounds(pi), 3);
%!assert(rounds(pi, 1), 3);
%!assert(rounds(pi, 2), 3.1, eps(3.1));
%!assert(rounds(pi, 3), 3.14, eps(3.14));
%!assert(rounds(pi, 4), 3.142, eps(3.142));
%!assert(rounds(pi, 5), 3.1416, eps(3.1416));
%!assert(rounds(pi, 6), 3.14159, eps(3.14159));
%!assert(rounds(pi, 7), 3.141593, eps(3.141593));
%!assert(rounds(pi, 8), 3.1415927, eps(3.1415927));

%!assert(rounds(-pi), -3);
%!assert(rounds(-pi, 1), -3);
%!assert(rounds(-pi, 2), -3.1, eps(3.1));
%!assert(rounds(-pi, 3), -3.14, eps(3.14));
%!assert(rounds(-pi, 4), -3.142, eps(3.142));
%!assert(rounds(-pi, 5), -3.1416, eps(3.1416));
%!assert(rounds(-pi, 6), -3.14159, eps(3.14159));
%!assert(rounds(-pi, 7), -3.141593, eps(3.141593));
%!assert(rounds(-pi, 8), -3.1415927, eps(3.1415927));

%!assert(rounds((1:3)'.*[pi e], [2 3]), [3.1 2.72; 6.3 5.44; 9.4 8.15], eps(10));
%!assert(rounds((1:3)'.*[pi e], [1 2 3]'), [3 3; 6.3 5.4; 9.42 8.15], eps(10));

%!test
%! [r, f, l] = rounds(e*1E-4, 3);
%! assert(r, 2.72E-4);
%! assert(f, -4);
%! assert(l, -6);