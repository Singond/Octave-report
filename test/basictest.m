clear all;
addpath("../src");

gp = gnuplotter();
gp.load("header.gp");
gp.plotsine();
pause();
gp.close();
