# Demonstrates how to draw a multiplot using a plotdef object.

clear all;
addpath("../src/octave");

gp = gnuplotter();
gp.load("header.gp");
x = (1:0.1:10)';
p1 = gp.newplot();
p1.title("Cardinal sine");
p1.xlabel("Angle");
p1.ylabel("Value");
p1.plot([x sin(x)  ./x], "w l title 'sinc(x)'  ls 1");
p1.plot([x sin(2*x)./x], "w l title 'sinc(2x)' ls 2");
p2 = gp.newplot();
p2.title('\"Cardinal cosine\" (term not actually used)');
p2.xlabel("Angle");
p2.ylabel("Value");
p2.plot([x cos(x)  ./x], "w l title 'cosc(x)'  ls 1");
p2.plot([x cos(2*x)./x], "w l title 'cosc(2x)' ls 2");

## Execute the plot
gp.multiplot(2, 1, "title 'Multiplot created by separate plot definitions'");
gp.doplot(p1, p2);
gp.singleplot();

pause();
gp.deletex();
