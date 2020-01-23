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
## @deftypefn  {Function file} {@var{s} =} unc2str(@var{val}, @var{unc})
## @deftypefnx {Function file} {@var{s} =} unc2str(@dots{}, @var{digits})
## @deftypefnx {Function file} {@var{s} =} unc2str(@dots{}, @var{digits}, @var{format})
## @deftypefnx {Function file} {@var{s} =} unc2str(@dots{}, @qcode{"decimalComma"})
## Format a value @var{val} with uncertainty @var{unc} to string, with the
## value rounded to the same order as the uncertainty.
##
## If @var{val} and/or @var{unc} is a matrix, the output is a cell array
## of the corresponding size. Otherwise it is a simple string.
##
## The optional argument @var{digits} specifies the number of significant
## digits to round the uncertainty to. The default value is 1.
##
## The format of the output string can be changed by the optional argument
## @var{format}. This is a @code{printf}-style format accepting two string
## arguments, which are the (already formatted) value and uncertainty,
## respectively. The default value is @qcode{"%s +/- %s"}.
##
## The switch @qcode{"decimalComma"} can be used to change the decimal
## separator to comma.
## @end deftypefn

## Author: Jan "Singon" Slany <singond@seznam.cz>
## Created: January 2020
## Keywords: uncertainty, format
function S = unc2str(varargin)
	p = inputParser();
	p.FunctionName = "unc2str";
	p.addRequired("value", @isnumeric);
	p.addRequired("uncertainty", @isnumeric);
	p.addOptional("digits", 1, @isnumeric);
	p.addOptional("format", "%s +/- %s", @ischar);
	p.addSwitch("decimalComma");
	p.parse(varargin{:});
	v = p.Results.value;
	u = abs(p.Results.uncertainty);
	digits = p.Results.digits;
	fmt = p.Results.format;
	comma = p.Results.decimalComma;

	[u, ~, l] = rounds(u, digits);
	v = round(v .* 10.^(-l)) .* 10.^l;
	if (isscalar(v) && isscalar(u))
		S = unc2strfmt(v, u, l, {fmt}, comma);
	else
		S = arrayfun(@unc2strfmt, v, u, l, {fmt}, comma, "UniformOutput", false);
	endif
endfunction

function S = unc2strfmt(v, u, l, strfmt, comma)
	if (l < 0)
		## Decimal number
		numfmt = sprintf("%%.%df", -l);
	else
		# Integer
		numfmt = "%d";
	endif
	vstr = sprintf(numfmt, v);
	ustr = sprintf(numfmt, u);
	if (comma)
		vstr = strrep(vstr, '.', ',');
		ustr = strrep(ustr, '.', ',');
	endif
	S = sprintf(strfmt{1}, vstr, ustr);
endfunction

%!assert(unc2str(pi, 0.0151), "3.14 +/- 0.02");
%!assert(unc2str(pi, -0.0151), "3.14 +/- 0.02");
%!assert(unc2str(2681, 24), "2680 +/- 20");
%!assert(unc2str(2681, -24), "2680 +/- 20");

%!assert(unc2str([pi 2*pi], 0.014, 1), {"3.14 +/- 0.01", "6.28 +/- 0.01"});
%!assert(unc2str([pi 2*pi], [0.014 0.0078]),
%! {"3.14 +/- 0.01", "6.283 +/- 0.008"});
%!assert(unc2str([pi 2*pi], [0.014 0.0078], 2),
%! {"3.142 +/- 0.014", "6.2832 +/- 0.0078"});

%!assert(unc2str(pi, 0.067, "decimalComma"), "3,14 +/- 0,07");