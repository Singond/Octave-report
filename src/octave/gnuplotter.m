classdef gnuplotter < handle
	## -*- texinfo -*-
	## @deftp Class gnuplotter
	## Interface to a Gnuplot process.
	##
	## This class enables controlling Gnuplot from within Octave.
	## While Octave supports Gnuplot natively, it abstracts from its details
	## and makes fine-grained control over the final result difficult.
	## This class aims to fill this gap by providing a more direct control
	## over what is being passed to Gnuplot.
	##
	## Requires `gnuplot` to be installed and available on `PATH`.
	##
	## @strong{Caution}:
	## In earlier versions of Octave, removing the object by calling
	## @code{clear} fails to close the Gnuplot process. In order to avoid
	## this, the @code{delete} method of @code{gnuplotter} must be called
	## manually.
	## This used to be an issue in Octave 4.4, but was fixed at some point
	## between versions 4.4 and 6.2.
	## @end deftp
	##
	## @deftypefn  Constructor {@var{gp} =} gnuplotter ()
	## @deftypefnx Constructor {@var{gp} =} gnuplotter @
	##     (@dots{}, @qcode{"initfile"})
	## @deftypefnx Constructor {@var{gp} =} gnuplotter @
	##     (@dots{}, @qcode{"verbose"})
	## Construct a new @code{gnuplotter} object.
	##
	## If the @qcode{"initfile"} switch is given, launch Gnuplot without
	## the @code{--default-settings} option in order to load initialization
	## files like @code{~/.gnuplot}.
	## This used to be the default behaviour in version 0.4.1 of this package
	## and earlier.
	##
	## If the @qcode{"verbose"} switch is set, output some diagnostic messages
	## from @code{gnuplotter} into standard output.
	## Note that this does not affect verbosity of Gnuplot itself.
	## @end deftypefn
	properties (Access = private)
		## The gnuplot process
		gp
		## Default plot to be used when plotdef functions are invoked
		## directly on this object.
		plt
		## A list of all plotdefs sharing this gnuplot process
		allplots = cell();
		## Gnuplotter verbosity (not verbosity of gnuplot itself!)
		verbose;
	endproperties

	methods
		## fun
		function obj = gnuplotter(varargin)
			ip = inputParser();
			ip.addSwitch("initfile");
			ip.addSwitch("verbose");
			ip.parse(varargin{:});
			ipr = ip.Results;
			obj.verbose = ipr.verbose;

			cmd = "gnuplot";
			if (!ipr.initfile)
				cmd = [cmd " --default-settings"];
			endif
			if (obj.verbose)
				printf("Starting new gnuplot process with '%s'\n", cmd);
			endif
			obj.gp = popen(cmd, "w");
			obj.plt = obj.newplot();
		endfunction

		function p = newplot(obj)
			p = gnuplotdef();
			obj.allplots = [obj.allplots {p}];
		endfunction

		## In Octave version 4.4, calling this method implicitly
		## by the 'clear' command does not work, because the 'gp'
		## field is destroyed even before invoking 'delete'.
		function delete(obj)
			for i = 1:length(obj.allplots)
				clear obj.allplots{i};
			endfor
			if (obj.verbose)
				disp("Closing gnuplot process");
			endif
			fputs(obj.gp, "exit\n");
			pclose(obj.gp);
		endfunction

		##--------------------------------------------------------------
		## Gnuplot primitives
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

		function multiplot(obj, a, b, c)
			if (nargin < 2)
				error("Not enough arguments");
				#print_usage();     # Not working in classdef?
				return;
			elseif (isnumeric(a))
				rows = a;
				cols = rows;
				cmd = "";
				if (nargin == 3)
					if (isnumeric(b))
						cols = b;
					elseif (ischar(b))
						cmd = b;
					else
						#arg error
					endif
				elseif(nargin == 4)
					cols = b;
					cmd = c;
				else
					#arg error
				endif
				fprintf(obj.gp, "set multiplot layout %d,%d %s\n", ...
						rows, cols, cmd);
			else
				#arg error
			endif
		endfunction

		function singleplot(obj)
			fprintf(obj.gp, "unset multiplot\n");
		endfunction

		##--------------------------------------------------------------
		## High-level functions
		##--------------------------------------------------------------

		function doplot(obj, plotdef, varargin)
			if (nargin == 1)
				obj.plt.doplot(obj, obj.gp);
			elseif (nargin >= 2)
				if (iscell(plotdef))
					if (nargin == 2)
						cmd = "";
					elseif(length(varargin) == 1)
						cmd = varargin{1};
					else
						#arg error
					endif
					s = size(plotdef);
					if (length(s) != 2)
						error("'plotdef' must be a 2D cell array, got %s", ...
							typeinfo(plotdef));
					endif
					obj.multiplot(s(1), s(2), cmd);
					for pd = plotdef'(:)'
						pd{1}.doplot(obj, obj.gp);
					endfor
				elseif (isa(plotdef, "gnuplotdef"))
					plotdef.doplot(obj, obj.gp);
					if (!isempty(varargin))
						for arg = varargin(:)'
							arg{1}.doplot(obj, obj.gp);
						endfor
					endif
				else
					error("Expecting gnuplotdef, got %s", typeinfo(plotdef));
				endif
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
			if (ischar(file))
				ensure_dir_exists(file);
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

		function str = disp(obj)
			s = "gnuplotter";
			if (nargout == 0)
				disp(s);
			else
				str = s;
			endif
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

%!demo
%! # Simple example.
%! gp = gnuplotter("verbose");
%! x = 1:0.1:10;
%! y = sin(x) ./ x;
%! z = cos(x) ./ x;
%! gp.plot([x; y]');
%! gp.plot([x; z]');
%! gp.doplot;
%! pause();

%!demo
%! gp = gnuplotter("verbose");
%! gp.exec("set style line 1 lw 2 lc rgb '#E41A1C' pt 13 ps 2");
%! gp.exec("set style line 2 lw 2 lc rgb '#377EB8' pt 5  ps 1.4");
%! x = 1:0.1:10;
%! y = sin(x) ./ x;
%! z = cos(x) ./ x;
%! gp.plot([x; y]', "w l title 'sinc(x)' ls 1");
%! gp.plot("1/x", "w l title '1/x' ls 0");
%! gp.plot("-1/x", "w l title '-1/x' ls 0");
%! gp.plot([x; z]', "w l title 'cosc(x)' ls 2");
%! gp.title("Cardinal trigonometric functions");
%! gp.xlabel("Angle");
%! gp.ylabel("Value");
%! gp.doplot;
%! pause();

%!demo
%! ## Control gnuplot directly.
%! gp = gnuplotter("verbose", "initfile");
%! gp.exec("\
%!     set style line 1 lt 1 lw 2 lc rgb '#D53E4F' \n\
%!     set style line 2 lt 1 lw 2 lc rgb '#F46D43' # orange\n\
%!     set style line 3 lt 1 lw 2 lc rgb '#FDAE61' # pale orange \n\
%!     set style line 4 lt 1 lw 2 lc rgb '#FEE08B' # pale yellow-orange \n\
%!     set style line 5 lt 1 lw 2 lc rgb '#E6F598' # pale yellow-green \n\
%!     set style line 6 lt 1 lw 2 lc rgb '#ABDDA4' # pale green \n\
%!     set style line 7 lt 1 lw 2 lc rgb '#66C2A5' # green \n\
%!     set style line 8 lt 1 lw 2 lc rgb '#3288BD' # blue \n\
%!     set style increment user \n\
%!     set xlabel 'Angle' \n\
%!     set ylabel 'Value' \n\
%!     set yrange [-0.6:1] \n\
%! ");
%! x = 0:0.1:12;
%! d = 0.2;
%! p = 0.1;
%! for i = 0:7
%!     xd = x - i*d;
%!     y = sin(x-i*d) ./ (x+i*p);
%!     gp.plot([x; y]', "w l");
%! endfor
%! gp.doplot;
%! pause();

%!demo
%! # Draw a multiplot using a cell array of plotdef objects.
%! gp = gnuplotter("verbose");
%! x = (1:0.1:10)';
%! p1 = gp.newplot();
%! p1.plot([x sin(x)  ./x], "w l title 'sinc(x)'  ls 1");
%! p2 = gp.newplot();
%! p2.plot([x cos(x)  ./x], "w l title 'cosc(x)'  ls 1");
%! gp.doplot({p1; p2}, "title 'Simple multiplot'");
%! pause();

%!demo
%! # Draw a multiplot with main title, labels, and individual plot titles.
%! # Also demonstrate the use of 'multiplot' function.
%! gp = gnuplotter("verbose");
%! x = (1:0.1:10)';
%! p1 = gp.newplot();
%! p1.title("Cardinal sine");
%! p1.xlabel("Angle");
%! p1.ylabel("Value");
%! p1.plot([x sin(x)  ./x], "w l title 'sinc(x)'  ls 1");
%! p1.plot([x sin(2*x)./x], "w l title 'sinc(2x)' ls 2");
%! p2 = gp.newplot();
%! p2.title('\"Cardinal cosine\"');
%! p2.xlabel("Angle");
%! p2.ylabel("Value");
%! p2.plot([x cos(x)  ./x], "w l title 'cosc(x)'  ls 1");
%! p2.plot([x cos(2*x)./x], "w l title 'cosc(2x)' ls 2");
%! gp.multiplot(2, 1, "title 'Multiplot created by \"multiplot\" function'");
%! gp.doplot(p1, p2);
%! pause();

%!demo
%! # Draw a multiplot manually.
%! gp = gnuplotter("verbose");
%! x = (1:0.1:10)';
%! y = sin(x) ./ x;
%! z = cos(x) ./ x;
%! z2 = cos(2*x) ./ x;
%! gp.exec("set multiplot layout 2,1");
%! gp.settitle("Cardinal sine");
%! gp.exec("plot '-' w l title 'sinc(x)' ls 1");
%! gp.data([x y]);
%! gp.settitle('\"Cardinal cosine\"');
%! gp.exec("plot '-' w l title 'cosc(x)' ls 1, '-' w l title 'cosc(2x)' ls 2");
%! gp.data([x z]);
%! gp.data([x z2]);
%! pause();
