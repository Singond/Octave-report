classdef gnuplotdef < handle
	## -*- texinfo -*-
	## @deftp Class gnuplotdef
	##
	## Plot definition to be sent to Gnuplot.
	##
	## @seealso{gnuplotter}
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
		##
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
			while ++i <= numel(varargin)
				a = varargin{i};
				if (expect_data && isnumeric(a))
					if (i < numel(varargin) && isnumeric(varargin{i+1}))
						obj.plots(end+1) = gnuplotdef.plotxydata(...
							a, varargin{++i});
					else
						obj.plots(end+1) = gnuplotdef.plotdata("numeric", a);
					endif
					expect_data = false;
					expect_style = true;
				elseif (expect_data && ischar(a))
					obj.plots(end+1) = gnuplotdef.plotdata("expression", a);
					expect_data = false;
					expect_style = true;
				elseif (expect_style && ischar(a))
					obj.plots(end).style = a;
					expect_data = true;
					expect_style = false;
				else
					error("gnuplotdef.plot: bad argument %d", i);
				endif
			endwhile
		endfunction

		## -*- texinfo -*-
		## @defmethod  gnuplotter {} plotmatrix (@var{M})
		## @defmethodx gnuplotter {} plotmatrix (@var{x}, @var{y}, @var{M})
		## @defmethodx gnuplotter {} plotmatrix (@dots{}, @var{style})
		##
		## Define the matrix @var{M} to be plotted later with @code{doplot}.
		##
		## This uses the @code{plot '-' matrix} Gnuplot command.
		##
		## If @var{x} and @var{y} are given, plot a non-uniform matrix
		## with @code{plot '-' nonuniform matrix}.
		##
		## This function does not interact with gnuplot in any way,
		## it merely stores the plot definition for later retrieval.
		## @end defmethod
		function plotmatrix(obj, varargin)
			i = 0;
			if (nargin >= 4 && all(cellfun("isnumeric", varargin(1:3))))
				[x, y, data] = varargin{1:3};
				M = [numel(x) x(:)'; y(:) data];
				pd = gnuplotdef.plotdata("non-uniform-matrix", M);
				i = 3;
			else
				pd = gnuplotdef.plotdata("uniform-matrix", varargin{1});
				i = 1;
			end
			if (nargin > i)
				pd.style = varargin{++i};
			end
			obj.plots(end+1) = pd;
		end

		## -*- texinfo -*-
		## @defmethod gnuplotdef clearplot ()
		##
		## Clear the plot definition given in @code{plot}.
		## @end defmethod
		function clearplot(obj)
			obj.plots = gnuplotdef.plotdata();
		endfunction

		## -*- texinfo -*-
		## @defmethod gnuplotdef doplot (@var{gnuplotter}, @var{fid})
		##
		## Draw plot according to specifications and data given by calling
		## the @code{plot} function.
		## @end defmethod
		function doplot(obj, gp, fid)
			obj.outputtext(gp);
			obj.outputplot(gp, fid);
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
		function outputplot(obj, gp, fid)
			## Return if plots is empty
			if (numel(obj.plots) < 1)
				error("Nothing to plot");
			endif
			## Execute plot command
			fputs(fid, "plot ");
			for r = 1:numel(obj.plots)
				if (r > 1)
					fputs(fid, ", ");
				endif
				gnuplotdef.outputplotcmd(fid, obj.plots(r));
			endfor
			fputs(fid, "\n");
			## Pass numeric data to plot command
			for r = 1:numel(obj.plots)
				gnuplotdef.outputplotdata(gp, obj.plots(r));
			endfor
		endfunction
	endmethods

	methods (Access = private, Static = true)
		function pd = plotdata(type, data, style="")
			if (nargin == 0)
				pd = struct("type", {}, "data", {}, "style", {});
				return;
			end
			pd = struct("type", type, "data", data, "style", style);
		endfunction

		function pd = plotxydata(x, y, style="")
			if (isrow(x))
				x = x';
			endif
			if (isrow(y))
				y = y';
			endif
			pd = gnuplotdef.plotdata("numeric", [x y], style);
		endfunction

		function outputplotcmd(fid, pd)
			switch (pd.type)
				case "numeric"
					fprintf(fid, "'-' %s", pd.style);
				case "uniform-matrix"
					fprintf(fid, "'-' matrix %s", pd.style);
				case "non-uniform-matrix"
					fprintf(fid, "'-' nonuniform matrix %s", pd.style);
				case "expression"
					fprintf(fid, "%s %s", pd.data, pd.style);
				otherwise
					error("gnuplotdef: bad type of plot data");
			endswitch
		endfunction

		function outputplotdata(gp, pd)
			switch (pd.type)
				case {"numeric", "uniform-matrix", "non-uniform-matrix"}
					gp.data(pd.data, "e\n");
				case "expression"
					## Do nothing
				otherwise
					error("gnuplotdef: bad type of plot data");
			endswitch
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
