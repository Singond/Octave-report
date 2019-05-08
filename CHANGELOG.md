Changelog
=========
This is a changelog for the Octave `report` package.

Unreleased
----------
### Fixed
- Corrected an error in the `test/writetable.m` test script.
  This was an internal error which appeared only in testing.

[0.2.0] - 2019-05-05
--------------------
**Important:** Package name has been changed from `gnuplotter` to `report`.

### Added
- It is now possible to pass raw tabular data to gnuplot from numeric array
  using the `data` function.
- Added this changelog.
- Added functions to export numeric arrays into CSV and similar formats.
  See functions `dlmformat` and `csvformat`.

### Changed
- **Incompatbility note:** The `addplot` function has been renamed to `plot`,
  while the original `plot` function is now called `doplot`.

[0.1.0] - 2019-04-02
--------------------
First version. Includes basic commands for starting, interaction
and termination of gnuplot process, as well as simple interface for
plotting. Distribution is enabled as an octave package.
