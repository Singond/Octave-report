Changelog
=========
This is a changelog for the Octave `gnuplotter` package.

Unreleased
----------

### Added
- It is now possible to pass raw tabular data to gnuplot from numeric array
  using the `data` function.
- Added this changelog.

### Changed
- **Incompatbility note:** The `addplot` function has been renamed to `plot`,
  while the original `plot` function is now called `doplot`.

[0.1.0] - 2019-04-2
-------------------
First version. Includes basic commands for starting, interaction
and termination of gnuplot process, as well as simple interface for
plotting. Distribution is enabled as an octave package.
