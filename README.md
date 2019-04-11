Gnuplot bindings for Octave
===========================

Enables controlling Gnuplot from within Octave.
While Octave supports Gnuplot natively, it abstracts from its details and makes
fine-grained control over the final result difficult. This utility aims to fill
this gap by providing more direct control over what is being passed to Gnuplot.

Requirements
============
- `gnuplot` must be installed on your system and available on `PATH`

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
cd Octave-gnuplot/
make dist
cd build
octave
octave> pkg install "gnuplotter-0.1.0.tar.gz";
octave> exit
```

The `gnuplotter` package should now be available in octave.

Usage
=====

In Octave, load `gnuplotter` as any other package:
```sh
octave> pkg load gnuplotter;
```

Examples
========

The following is a minimal example. This will plot the function `sinc(x)` in the default terminal:

```octave
gp = gnuplotter();
x = 1:0.1:10;
y = sin(x) ./ x;
gp.plot([x; y]', "with lines");      # Queue sinc(x) for plotting
gp.doplot();                         # Draw the defined plot in the default terminal
gp.deletex();                        # Close to release system resources
```

