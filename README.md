# cubediff
Subtract two electrostatic maps, contained in Gaussian cube files, and generate a new electrostatic map with the difference.

## Rationale
This is a Julia script with the goal to subtract two electrostatic potential maps and obtain the
difference. These maps are obtained by a Poisson Boltzmann analysis of proteins as implemented in software such
as [Delphi](http://compbio.clemson.edu/delphi) or [APBS](http://www.poissonboltzmann.org/) (APBS
writes the maps in other format, OpenDX scalar, that need to be converted to a Gaussian cube, with tools such as
[openbabel](http://openbabel.org/wiki/Main_Page)).

For this subtraction to make sense both maps sources should be similar/related proteins (homologs, mutants,
chimeric variants, etc) and being structurally superimposed when the electrostatic
potential maps are calculated.

When the size of both maps are not equal, the second (reference) map, es resized by interpolation to
match the size of the first map.

## Usage
```
usage: cubediff [--version] [-h] map1 map2

Subtract two electrostatic potential maps, contained in Gaussian cube
files, and generate a new electrostatic potential map with the
difference.

positional arguments:
  map1        target electrostatic potential map
  map2        reference electrostatic potential map

optional arguments:
  --version   show version information and exit
  -h, --help  show this help message and exit
```

## Installation
This is not a Julia package, just a standalone script. Just download it and put it in your PATH. You
need a working Julia environment and to install the dependencies.

## Dependencies
This script depends on the following Julia packages:
* `ArgParse`
* `Images`
* `Printf`

