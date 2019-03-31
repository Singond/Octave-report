clear all;
addpath("../src");

gp = gnuplotter();
gp.load("header.gp");
x = 1:0.1:10;
y = sin(x) ./ x;
z = cos(x) ./ x;
gp.addplot([x; y]');
gp.addplot([x; z]');
gp.plotall;

pause();
gp.deletex();
