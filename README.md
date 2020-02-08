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
3. Run `make install`
4. Enter the `build` directory, launch Octave and install the package

```sh
git clone https://github.com/Singond/Octave-report.git
cd Octave-report/
make install
```

If the `octave` command is not available in your path, `make install`
will fail. In this case, you can run `make dist` and install the package
manually from the zip-file in `build/` directory:

```sh
make dist
cd build
octave
octave> pkg install "report-<version>.tar.gz";
octave> exit
```

From pre-built package
-------------------------------

Pre-built packages for Octave are available at the
[releases page](https://github.com/Singond/Octave-report/releases).
You can use this method to install the package without downloading the whole
repository:

1. From the `Assets` section in the desired version, find the file
   `report-*.tar.gz` (here `*` is the version number).
2. Copy the URL of the file.
3. In your Octave prompt, run `pkg install '<url>'` where `<url>`
   is the URL of the file.

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

