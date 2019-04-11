# Demonstrates how to draw a multiplot using a combination of `exec`
# and `data` functions.

clear all;
addpath("../src/octave");

gp = gnuplotter();
gp.load("header.gp");
#gp.title("Cardinal trigonometric functions");
gp.xlabel("Angle");
gp.ylabel("Value");

x = (1:0.1:10)';
y = sin(x) ./ x;
y2 = sin(2*x) ./ x;
z = cos(x) ./ x;
z2 = cos(2*x) ./ x;

gp.exec("set multiplot layout 2,1");
gp.title("Cardinal sine");
gp.exec("plot '-' w l title 'sinc(x)' ls 1, '-' w l title 'sinc(2x)' ls 2");
gp.data([x y]);
gp.data([x y2]);
gp.title('\"Cardinal cosine\" (term not actually used)');
gp.exec("plot '-' w l title 'cosc(x)' ls 1, '-' w l title 'cosc(2x)' ls 2");
gp.data([x z]);
gp.data([x z2]);
gp.exec("unset multiplot");

pause();
gp.deletex();
