clear all;
addpath("../src");

gp = gnuplotter();
gp.load("header.gp");
x = 0.1:0.1:10;
y = sin(x) ./ x;
gp.addplot([x; y]', "w p");
gp.plotall;

pause();
gp.deletex();
