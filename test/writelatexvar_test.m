clear all;
addpath("../src/octave");

R.threenum = 3;
R.threestr = "3";
R.fiftyfivenum = 55;
R.fiftyfivestr = "55";
writelatexvars("vars.tex", R);

## Try with non-existent directory
dirname = "test_newdir";
if (isdir(dirname))
	printf("Removing %s\n", dirname);
	rmdir(dirname);
endif
filename = [dirname "/vars.tex"];
printf("Writing %s...\n", filename);
writelatexvars(filename, R);
