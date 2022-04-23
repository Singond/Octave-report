classdef gnuplotdef < handle
	## -*- texinfo -*-
	## @deftp Class gnuplotdef
	## Plot definition to be sent to Gnuplot.
	## @end deftp
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
			obj.plots = gnuplotdef.plotdata();
			obj._title = obj.UNDEFINED;
			obj._xlabel = obj.UNDEFINED;
			obj._ylabel = obj.UNDEFINED;
		endfunction

		## -*- texinfo -*-
		## @defmethod  gnuplotdef plot (@var{y})
		## @defmethodx gnuplotdef plot (@var{x}, @var{y})
		## @defmethodx gnuplotdef plot (@dots{}, @var{style})
		## @defmethodx gnuplotdef plot @
		##     (@var{x1}, @var{x2}, @dots{}, @var{xn}, @var{yn})
		## Define the plot data and style to be plotted later with
		## @code{doplot}.
		##
		## This function does not interact with gnuplot in any way,
		## it merely stores the plot definition for later retrieval.
		## @end defmethod
		function plot(obj, varargin)
			expect_data = true;
			expect_style = false;
			i = 0;
			x = y = [];
			style = "";
			while ++i <= numel(varargin)
				a = varargin{i};
				if (expect_data && !isempty(y))
					## Flush previous
					obj.plots(end+1) = gnuplotdef.plotdata(x, y, style);
					x = y = [];
					style = "";
				endif
				if (expect_data && isnumeric(a))
					if (i < numel(varargin) && isnumeric(varargin{i+1}))
						x = a;
						y = varargin{++i};
					else
						y = a;
					endif
					expect_data = false;
					expect_style = true;
				elseif (expect_data && ischar(a))
					y = a;
					expect_data = false;
					expect_style = true;
				elseif (expect_style && ischar(a))
					style = a;
					expect_data = true;
					expect_style = false;
				else
					error("gnuplotdef.plot: bad argument %d", i);
				endif
			endwhile
			if (!isempty(y))
				obj.plots(end+1) = gnuplotdef.plotdata(x, y, style);
			endif
		endfunction

		## -*- texinfo -*-
		## @defmethod gnuplotdef clearplot ()
		## Clear the plot definition given in @code{plot}.
		## @end defmethod
		function clearplot(obj)
			obj.plots = gnuplotdef.plotdata();
		endfunction

		## -*- texinfo -*-
		## @defmethod gnuplotdef doplot (@var{gnuplotter}, @var{fid})
		## Draw plot according to specifications and data given by calling
		## the @code{plot} function.
		## @end defmethod
		function doplot(obj, gp, fid)
			obj.outputtext(gp);
			obj.outputplot(fid);
		endfunction

		function xlabel(obj, label, varargin)
			obj._xlabel = sformat_args(label, varargin{:});
		endfunction

		function ylabel(obj, label, varargin)
			obj._ylabel = sformat_args(label, varargin{:});
		endfunction

		function title(obj, title, varargin)
			obj._title = sformat_args(title, varargin{:});
		endfunction

		function str = disp(obj)
			print_struct_array_contents(true, "local");
			if (nargout == 0)
				disp(obj.plots);
			else
				str = disp(obj.plots);
			endif
		endfunction
	endmethods

	methods (Access = private)
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

		## Output plot according to specifications and data given when calling
		## @code{plots}.
		function outputplot(obj, fid)
			## Return if plots is empty
			if (numel(obj.plots) < 1)
				error("Nothing to plot");
			endif
			## Execute plot command
			plotstring = "plot ";
			for r = 1:numel(obj.plots)
				x = obj.plots(r).x;
				y = obj.plots(r).y;
				style = obj.plots(r).style;
				if (isnumeric(y))
					## Data is numeric values
					if (isempty(x))
						using_cols = 0:columns(y);
					else
						using_cols = 1:columns(y)+1;
					endif
					using = sprintf("%d:", using_cols)(1:end-1);
					plotstring = [plotstring ...
						sprintf("'-' using %s %s, ", using, style)];
				elseif (ischar(y))
					## Data is function expression
					plotstring = [plotstring sprintf("%s %s, ", y, style)];
				endif
			endfor
##			disp([plotstring "\n"]);
			fputs(fid, [plotstring(1:end-2) "\n"]);
			## Pass numeric data to plot command
			for r = 1:numel(obj.plots)
				x = obj.plots(r).x;
				y = obj.plots(r).y;
				if (isnumeric(y))
					## Data is numeric values
					data = [x y];
					fmt = [repmat('%g ', [1 columns(data)])(1:end-1) "\n"];
					fprintf(fid, fmt, data');
					fputs(fid, "e\n");
				endif
			endfor
		endfunction
	endmethods

	methods (Access = private, Static = true)
		function pd = plotdata(x={}, y={}, style={})
			if (isrow(x))
				x = x';
			endif
			if (isrow(y))
				y = y';
			endif
			pd = struct("x", x, "y", y, "style", style);
		endfunction
	endmethods
endclassdef

%!function lines = testnoplot(plt)
%!    logname = tempname();
%!    gp = gnuplotter("logfile", logname);
%!    gp.exec('set term "dumb"');
%!    gp.exec('set output "/dev/null"');
%!    gp.doplot(plt);
%!    clear gp;
%!    f = fopen(logname, "r");
%!    bytes = fread(f);
%!    lines = strsplit(native2unicode(bytes)', "\n");
%!    fclose(f);
%!endfunction

%!test
%! p = gnuplotdef();
%! p.title('Case \\phi = 2');
%! p.plot("x");
%! log = testnoplot(p);
%! assert(any(strcmp(log, 'set title "Case \\phi = 2"')));
%!test
%! p = gnuplotdef();
%! p.title('Case \\phi = %.1f', 6.734);
%! p.plot("x");
%! log = testnoplot(p);
%! assert(any(strcmp(log, 'set title "Case \\phi = 6.7"')));

%!test
%! p = gnuplotdef();
%! p.xlabel('x_%d', 5);
%! p.plot("x");
%! log = testnoplot(p);
%! assert(any(strcmp(log, 'set xlabel "x_5"')));

%!test
%! p = gnuplotdef();
%! p.ylabel('y_%d', 2);
%! p.plot("x");
%! log = testnoplot(p);
%! assert(any(strcmp(log, 'set ylabel "y_2"')));

%!demo
%! x = linspace(0, 2)';
%! p = gnuplotdef();
%! p.plot(x, sin(pi*x), "w l", x, sin(1.1*pi*x), "w l");
%! gp = gnuplotter("verbose");
%! gp.doplot(p);
%! pause();
