# Demonstrates how to draw a multiplot using a plotdef object.

clear all;
addpath("../src/octave");

gp = gnuplotter();
gp.load("header.gp");

x = (1:0.1:10)';
## Use the default plot definition inside gnuplotter for the first plot...
gp.title("Cardinal sine");
gp.xlabel("Angle");
gp.ylabel("Value");
gp.plot([x sin(x)  ./x], "w l title 'sinc(x)'  ls 1");
gp.plot([x sin(2*x)./x], "w l title 'sinc(2x)' ls 2");
## ... and create a new plot definition for the second plot
p2 = gp.newplot();
p2.title('\"Cardinal cosine\" (term not actually used)');
p2.xlabel("Angle");
p2.ylabel("Value");
p2.plot([x cos(x)  ./x], "w l title 'cosc(x)'  ls 1");
p2.plot([x cos(2*x)./x], "w l title 'cosc(2x)' ls 2");

## Execute the plot
gp.multiplot(2, 1, "title 'Multiplot created by separate plot definitions'");
gp.doplot();
gp.doplot(p2);
gp.singleplot();

pause();
gp.deletex();
