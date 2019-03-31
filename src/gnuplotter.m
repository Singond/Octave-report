classdef gnuplotter < handle
	properties (Access = private)
		gp
		plots = cell(0,2)
	endproperties

	methods
		function obj = gnuplotter()
			disp("Starting new gnuplot process");
			obj.gp = popen("gnuplot", "w");
		endfunction

		function plotsine(obj)
			fputs(obj.gp, "plot sin(x), sin(x-0.4), sin(x-0.8)\n");
		endfunction

		## usage: exec(command)
		##
		## Executes arbitraty gnuplot command.
		function exec(obj, cmdline)
			fputs(obj.gp, [cmdline "\n"]);
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

		function plotdata(obj, D, style)
			datastring = sprintf("%f %f\n", D');
#			disp("Plotting numeric values");
			fputs(obj.gp, sprintf("plot '-' u 1:2 %s\n%se\n", style, datastring));
		endfunction

		function addplot(obj, D, style)
			obj.plots = [obj.plots; {D style}];
		endfunction

		function plotall(obj)
			# Return if plots is empty
			plotstring = "plot ";
			datastring = "";
			for r = 1:rows(obj.plots)
				plot = obj.plots{r,1};
				style = obj.plots{r,2};
				if (isnumeric(plot))
					# Data is numeric
					plotstring = [plotstring sprintf("'-' using 1:2 %s, ", style)];
					datastring = [datastring "\n" sprintf("%f %f\n", plot') "e\n"];
				elseif (ischar(plot))
					# Data is function expression
					plotstring = [plotstring sprintf("%s %s, ", plot, style)];
				endif
			endfor
#			disp([plotstring "\n"]);
			fputs(obj.gp, [plotstring "\n"]);
#			disp(datastring);
			fputs(obj.gp, datastring);
		endfunction

		function disp(obj)
			disp("gnuplotter");
		endfunction

		## DEPRECATED. Will be renamed to 'delete' in future release, once
		## the destructor methods on classdef objects work correctly
		## (this may already be true in Octave 5).
		## In Octave version 4.4, renaming this method to 'delete' and calling
		## it implicitly by the 'clear' command does not work, because the 'gp'
		## field is destroyed even before invoking 'delete'.
		function deletex(obj)
			disp("Closing gnuplotter");
			fputs(obj.gp, "exit\n");
			pclose(obj.gp);
		endfunction
	endmethods

	methods (Static = true)
		function D = datamatrix(X, Y)
			if (!isnumeric(X))
				error("X must be a numeric value");
			elseif (!isnumeric(Y))
				error("Y must be a numeric value");
			endif
			# TODO Check for size compatibility
			D = [X(:) Y(:)];
		endfunction
	endmethods
endclassdef
