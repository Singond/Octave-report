classdef gnuplotter < handle
	properties (Access = private)
		gp
	endproperties

	methods
		function obj = gnuplotter()
			disp("Starting new gnuplot process");
			obj.gp = popen("gnuplot", "w");
		endfunction

		function plotsine(obj)
			fputs(obj.gp, "plot sin(x), sin(x-0.4), sin(x-0.8)\n");
		endfunction

		function load(obj, filename)
			fputs(obj.gp, sprintf("load '%s'\n", filename));
		endfunction

		function plot(obj, f, style)
			printf("Number of arguments %d\n", nargin);
			# If f is a string, treat it as function expression
			# to be passed to gnuplot as-is.
			if ((exist("f") == 1) && ischar(f))
				if (exist("style") == 1)
					# disp("Plotting as expression with style");
					plotfun(obj, f, style);
				else
					# disp("Plotting as expression");
					plotfun(obj, f);
				endif
			endif
		endfunction

		## usage: plotfun(o, function, style)
		##
		## Plots a function given by an expression with the given style.
		## FUNCTION is a math expression of the function in gnuplot format.
		## STYLE is a definition of the plot style, like "with points".
		## If STYLE is not given, plot with the current settings.
		function plotfun(obj, func, style)
			if (nargin < 2)
				error("No function given");
			elseif (nargin == 2)
				fputs(obj.gp, sprintf("plot %s\n", func));
			elseif (nargin == 3)
				fputs(obj.gp, sprintf("plot %s %s\n", func, style));
			endif
		endfunction

		function disp(obj)
			disp("gnuplotter");
		endfunction

		function close(obj)
			fputs(obj.gp, "exit\n");
			pclose(obj.gp);
		endfunction
	endmethods
endclassdef
