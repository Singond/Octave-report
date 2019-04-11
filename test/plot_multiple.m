clear all;
addpath("../src/octave");

gp = gnuplotter();
gp.load("header.gp");
x = 1:0.1:10;
y = sin(x) ./ x;
z = cos(x) ./ x;
gp.plot([x; y]', "w l title 'sinc(x)' ls 1");
gp.plot("1/x", "w l title '1/x' ls 0");
gp.plot("-1/x", "w l title '-1/x' ls 0");
gp.plot([x; z]', "w l title 'cosc(x)' ls 2");
gp.title("Cardinal trigonometric functions");
gp.xlabel("Angle");
gp.ylabel("Value");
gp.doplot;

pause();
gp.deletex();
