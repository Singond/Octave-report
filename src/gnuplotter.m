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

		function addplot(obj, D, style="")
			obj.plots = [obj.plots; {D style}];
		endfunction

		## Draws plot according to specifications and data given in addplot.
		function plot(obj)
			if (rows(obj.plots) < 1)
				disp("Nothing to plot");
				return;
			endif
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
			fputs(obj.gp, [plotstring(1:end-2) "\n"]);
#			disp(datastring);
			fputs(obj.gp, datastring);
		endfunction

		function xlabel(obj, label)
			fputs(obj.gp, sprintf("set xlabel \"%s\"\n", label));
		endfunction

		function ylabel(obj, label)
			fputs(obj.gp, sprintf("set ylabel \"%s\"\n", label));
		endfunction

		function title(obj, title)
			fputs(obj.gp, sprintf("set title \"%s\"\n", title));
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
