classdef gnuplotdef < handle
	properties (Constant = true)
		UNDEFINED = -1
	endproperties

	properties (Access = private)
		plots
		_title
		_xlabel
		_ylabel
	endproperties

	methods
		function obj = gnuplotdef()
			plots = obj.initplots();
			_title = obj.UNDEFINED;
			_xlabel = obj.UNDEFINED;
			_ylabel = obj.UNDEFINED;
		endfunction

		function plot(obj, D, style="")
			obj.plots = [obj.plots; struct("data", D, "style", style)];
		endfunction

		function clearplot(obj)
			obj.plots = obj.initplots();
		endfunction

		## Draws plot according to specifications and data given in `plot`.
		function doplot(obj, gp, fid)
			obj.outputtext(gp);
			obj.outputplot(fid);
		endfunction

		function xlabel(obj, label)
			obj._xlabel = label;
		endfunction

		function ylabel(obj, label)
			obj._ylabel = label;
		endfunction

		function title(obj, title)
			obj._title = title;
		endfunction

		function disp(obj)
			disp("gnuplotdef");
		endfunction
	endmethods

	methods (Access = private)
		function P = initplots(obj)
			P = struct("data", {}, "style", {});
		endfunction

		function outputtext(obj, gp)
			if (obj._title != obj.UNDEFINED)
				gp.settitle(obj._title);
			endif
			if (obj._xlabel != obj.UNDEFINED)
				gp.setxlabel(obj._xlabel);
			endif
			if (obj._ylabel != obj.UNDEFINED)
				gp.setylabel(obj._ylabel);
			endif
		endfunction

		## Outputs plot according to specifications and data given in `plots`.
		function outputplot(obj, fid)
			if (rows(obj.plots) < 1)
				disp("Nothing to plot");
				return;
			endif
			# Return if plots is empty
			plotstring = "plot ";
			datastring = "";
			for r = 1:rows(obj.plots)
				plot = obj.plots(r).data;
				style = obj.plots(r).style;
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
			fputs(fid, [plotstring(1:end-2) "\n"]);
#			disp(datastring);
			fputs(fid, datastring);
		endfunction
	endmethods
endclassdef