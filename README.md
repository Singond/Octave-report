Reporting tools for Octave
==========================

A set of tools to facilitate exporting data from Octave to other formats.

Installation
============

Manual installation from source
-------------------------------
Before proceeding, make sure that `make` is installed. Then follow these steps:

1. Download the project source
2. Enter the root directory of the project
3. Run `make dist`
4. Enter the `build` directory, launch Octave and install the package

In summary:

```sh
cd Octave-report/
make dist
cd build
octave
octave> pkg install "report-0.2.0.tar.gz";
octave> exit
```

The `report` package should now be available in octave.

Usage
=====

In Octave, load `report` as any other package:
```
octave> pkg load report;
```

Examples
========

Controlling `gnuplot` from within `octave`.
-------------------------------------------

The following is a minimal example. This will plot the function `sinc(x)`
in the default terminal:

```octave
gp = gnuplotter();
x = 1:0.1:10;
y = sin(x) ./ x;
gp.plot([x; y]', "with lines"); # Queue sinc(x) for plotting
gp.doplot();                    # Draw the defined plot in the default terminal
gp.deletex();                   # Close to release system resources
```

