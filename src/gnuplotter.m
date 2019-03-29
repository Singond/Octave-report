classdef gnuplotter < handle
	properties
		gp
	endproperties

	methods
		function obj = gnuplotter()
			disp("Starting new gnuplot process");
			obj.gp = popen("gnuplot", "w");
		endfunction

		function plotsine(obj)
			fputs(obj.gp, "plot sin(x)\n");
		endfunction

		function close(obj)
			fputs(obj.gp, "exit\n");
			pclose(obj.gp);
		endfunction
	endmethods
endclassdef
