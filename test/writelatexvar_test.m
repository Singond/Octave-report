clear all;
addpath("../src/octave");

R.threenum = 3;
R.threestr = "3";
R.fiftyfivenum = 55;
R.fiftyfivestr = "55";
writelatexvars("vars.tex", R);

## Try with non-existent directory
filename = [non_existent_dir() "/vars.tex"];
printf("Writing %s...\n", filename);
writelatexvars(filename, R);
