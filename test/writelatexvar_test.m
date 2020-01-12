clear all;
addpath("../src/octave");

R.threenum = 3;
R.threestr = "3";
R.fiftyfivenum = 55;
R.fiftyfivestr = "55";
writelatexvars("vars.tex", R);
