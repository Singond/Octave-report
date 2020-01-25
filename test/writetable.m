clear all;
addpath("../src/octave");

header = {"g", "Ua[V]", "I10[microA]", "I12[microA]", "Ia[microA]", "s"};
header_str = "g Ua[V] I10[microA] I12[microA] Ia[microA] s";
data = [
	1, 600, 0.08, 0.82,  5.0, 3.2016;
	2, 600, 0.07, 0.71,  4.0, 3.1848;
	3, 599, 0.05, 0.58,  3.3, 3.4059;
	4, 599, 0.04, 0.43,  2.2, 3.2787;
	5, 599, 0.02, 0.32,  1.4, 4.0000;
	6, 599, 0.02, 0.26,  0.9, 3.6056;
	7, 598, 0.01, 0.21,  0.6, 4.5826;
	8, 598, 0.01, 0.19,  0.3, 4.3589;
	1, 795, 0.55, 8.86, 84.0, 4.0136;
	2, 795, 0.43, 6.94, 65.5, 4.0174;
	3, 795, 0.35, 5.54, 53.0, 3.9785;
	4, 795, 0.25, 4.05, 39.5, 4.0249;
	5, 795, 0.18, 2.88, 27.0, 4.0000;
	6, 795, 0.13, 2.20, 21.0, 4.1138;
	7, 795, 0.10, 1.75, 15.5, 4.1833;
	8, 795, 0.09, 1.58, 14.0, 4.1899
];

format = {"%.0f", "%3.0f", "%4.2f", "%4.2f", "%4.1f", "%5.3f"};
format_str = "%.0f %3.0f %4.2f %4.2f %4.1f %5.3f";

disp("Writing decorated table to stdout:");
dlmformat(stdout, format, data, ' | ', header);
disp("");

disp("Writing table to stdout using string arguments for header and format:");
dlmformat(stdout, format_str, data, '  ', header_str);
disp("");

disp("Writing CSV table to stdout:");
csvformat(stdout, format, data, header);
disp("");

disp("Writing CSV table to test_output/writetable.csv");
csvformat("test_output/writetable.csv", format, data, header);
disp("");

filename = [non_existent_dir "/writetable.csv"];
printf("Writing CSV table to %s\n", filename);
csvformat(filename, format, data, header);
disp("");
