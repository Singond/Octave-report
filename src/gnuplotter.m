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

		function disp(obj)
			disp("gnuplotter");
		endfunction

		function close(obj)
			fputs(obj.gp, "exit\n");
			pclose(obj.gp);
		endfunction
	endmethods
endclassdef
