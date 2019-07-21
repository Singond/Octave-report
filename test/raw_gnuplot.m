clear all;
addpath("../src/octave");

gp = gnuplotter();
gp.load("raw_gnuplot.gp");
x = 0:0.1:12;
d = 0.2;
p = 0.1;
for i = 0:7
	xd = x - i*d;
	y = sin(x-i*d) ./ (x+i*p);
	gp.plot([x; y]', "w l");
endfor
gp.doplot;

pause();
gp.deletex();
