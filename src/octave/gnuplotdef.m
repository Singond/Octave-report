classdef gnuplotdef < handle
	properties (Access = private)
		gp
		plots = cell(0,2)
	endproperties

	methods
		function obj = gnuplotdef(gnuplotprocess)
			obj.gp = gnuplotprocess;
		endfunction

		function plot(obj, D, style="")
			obj.plots = [obj.plots; {D style}];
		endfunction

		function clearplot(obj)
			obj.plots = cell(0,2);
		endfunction

		## Draws plot according to specifications and data given in `plot`.
		function doplot(obj)
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
					c = columns(plot);
					cols = sprintf("%d:", 1:c)(1:end-1);
					plotstring = [plotstring ...
						sprintf("'-' using %s %s, ", cols, style)];
					fmt = [repmat('%g ', [1 c])(1:end-1) "\n"];
					datastring = [datastring sprintf(fmt, plot') "e\n"];
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

		function export(obj, file, term, options)
			fputs(obj.gp, "set terminal push\n");
			fputs(obj.gp, sprintf("set terminal %s %s\n", term, options));
			fputs(obj.gp, sprintf("set output \"%s\"\n", file));
			obj.doplot();
			fputs(obj.gp, "set output\n");
			fputs(obj.gp, "set terminal pop\n");
		endfunction

		function disp(obj)
			disp("gnuplotdef");
		endfunction

	endmethods
endclassdef