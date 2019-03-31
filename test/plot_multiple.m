clear all;
addpath("../src");

gp = gnuplotter();
gp.load("header.gp");
x = 1:0.1:10;
y = sin(x) ./ x;
z = cos(x) ./ x;
gp.addplot([x; y]', "w l title 'sinc(x)' ls 1");
gp.addplot("1/x", "w l title '1/x' ls 0");
gp.addplot("-1/x", "w l title '-1/x' ls 0");
gp.addplot([x; z]', "w l title 'cosc(x)' ls 2");
gp.xlabel("Angle");
gp.ylabel("Value");
gp.plot;

pause();
gp.deletex();
