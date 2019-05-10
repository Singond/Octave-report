## Enables controlling Gnuplot from within Octave.
## While Octave supports Gnuplot natively, it abstracts from its details and makes
## fine-grained control over the final result difficult. This utility aims to fill
## this gap by providing more direct control over what is being passed to Gnuplot.
##
## Requires `gnuplot` to be installed and available on `PATH`.

classdef gnuplotter < handle
	properties (Access = private)
		## The gnuplot process
		gp
		## Default plot to be used when plotdef functions are invoked
		## directly on this object.
		plt
		## A list of all plotdefs sharing this gnuplot process
		allplots = cell();
	endproperties

	methods
		function obj = gnuplotter()
			disp("Starting new gnuplot process");
			obj.gp = popen("gnuplot", "w");
			obj.plt = obj.newplot();
		endfunction

		function p = newplot(obj)
			p = gnuplotdef();
			obj.allplots = [obj.allplots {p}];
		endfunction

		## DEPRECATED. Will be renamed to 'delete' in future release, once
		## the destructor methods on classdef objects work correctly
		## (this may already be true in Octave 5).
		## In Octave version 4.4, renaming this method to 'delete' and calling
		## it implicitly by the 'clear' command does not work, because the 'gp'
		## field is destroyed even before invoking 'delete'.
		function deletex(obj)
			for i = 1:length(obj.allplots)
				clear obj.allplots{i};
			endfor
			disp("Closing gnuplotter");
			fputs(obj.gp, "exit\n");
			pclose(obj.gp);
		endfunction

		##--------------------------------------------------------------
		## Plotting primitives
		##--------------------------------------------------------------

		## usage: exec(command)
		##
		## Executes arbitraty gnuplot command.
		function exec(obj, cmdline)
			fputs(obj.gp, [cmdline "\n"]);
		endfunction

		function load(obj, filename)
			fputs(obj.gp, sprintf("load '%s'\n", filename));
		endfunction

		## Passes numerical data directly to gnuplot.
		function data(obj, D)
			fmt = [repmat('%g ', [1 columns(D)])(1:end-1) "\n"];
			fprintf(obj.gp, fmt, D');
			fputs(obj.gp, "e\n");
		endfunction

		function settitle(obj, title)
			fprintf(obj.gp, "set title \"%s\"\n", title);
		endfunction

		function setxlabel(obj, label)
			fprintf(obj.gp, "set xlabel \"%s\"\n", label);
		endfunction

		function setylabel(obj, label)
			fprintf(obj.gp, "set ylabel \"%s\"\n", label);
		endfunction

		##--------------------------------------------------------------
		## High-level functions
		##--------------------------------------------------------------

		function multiplot(obj, r, c, s="")
			if (nargin < 2)
				print_usage();
				return;
			elseif (nargin == 2)
				c = r;
			endif
			fprintf(obj.gp, "set multiplot layout %d,%d %s\n", r, c, s);
		endfunction

		function singleplot(obj)
			fprintf(obj.gp, "unset multiplot\n");
		endfunction

		function doplot(obj, plotdef)
			if (nargin == 1)
				obj.plt.doplot(obj, obj.gp);
			elseif (nargin >= 2)
				if (!isa(plotdef, "gnuplotdef"))
					error("Expecting gnuplotdef, got %s", typeinfo(plotdef));
				endif
				plotdef.doplot(obj, obj.gp);
			endif
		endfunction

		function export(obj, a, b, c, d)
			if (nargin < 3)
				error("Need at least two arguments");
			elseif (isa(a, "gnuplotdef"))
				if (nargin < 4)
					error("Missing 'term' argument");
				endif
				pd = a;
				file = b;
				term = c;
				if (nargin > 4)
					options = d;
				else
					options = "";
				endif
			else
				pd = obj.plt;
				file = a;
				term = b;
				if (nargin > 3)
					options = c;
				else
					options = "";
				endif
			endif
			fputs(obj.gp, "set terminal push\n");
			fputs(obj.gp, sprintf("set terminal %s %s\n", term, options));
			fputs(obj.gp, sprintf("set output \"%s\"\n", file));
			pd.doplot(obj, obj.gp);
			fputs(obj.gp, "set output\n");
			fputs(obj.gp, "set terminal pop\n");
		endfunction

		##--------------------------------------------------------------
		## Plotdef functions to be delegated to the default plot
		##--------------------------------------------------------------

		function xlabel(obj, label)
			obj.plt.xlabel(label);
		endfunction

		function ylabel(obj, label)
			obj.plt.ylabel(label);
		endfunction

		function title(obj, title)
			obj.plt.title(title);
		endfunction

		function plot(obj, D, style="")
			obj.plt.plot(D, style);
		endfunction

		function clearplot(obj)
			obj.plt.clearplot();
		endfunction

		function disp(obj)
			disp("gnuplotter");
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
