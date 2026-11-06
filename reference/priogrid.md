# PRIO-GRID information

The data include identifying information about all grid cells: the grid
id, xcoord and ycoord, the row and col(umn), and geometry. It helps use
the convenience function to get information such as row and column
numbers such that the user does not have to provide them. Further
information can be found here: https://grid.prio.org/#/codebook

## Usage

``` r
data(priogrid)
```

## Format

An object of class `"data.frame"`

- gid:

  grid cell identifier, a unique id code for each cell in the grid

- xcoord:

  longitude coordinate (decimal degrees) for the centroid of the grid
  cell. Negative coordinates are located west of the Prime Meridian
  (Greenwich) at 0 degrees longitude

- ycoord:

  latitude coordinate (decimal degrees) for the centroid of the grid
  cell. Negative coordinates are located south of the Equator at 0
  degrees latitude

- col:

  column number for the grid cell. Column 1 is the westernmost column in
  the grid, between 180 and 179.5 decimal degrees W. With one column per
  half degree, there are 720 columns in PRIO-GRID.

- row:

  row number for the grid cell. Row 1 is the southernmost row (between
  90 and 89.5 degrees S) and row 360 is the northernmost row in the full
  grid in the underlying data

- geometry:

  Polygon information about each individual cell

## Source

[PRIO-GRID website](https://grid.prio.org/#/download)

## References

Tollefsen, Andreas Forø, Håvard Strand & Halvard Buhaug. 2012.
PRIO-GRID: A unified spatial data structure. Journal of Peace Research,
49(2): 363-374. ([Published
paper](https://doi.org/10.1177/0022343311431287))

## Examples

``` r

data(priogrid)
head(priogrid)
#> Simple feature collection with 6 features and 5 fields
#> Geometry type: POLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 163.5 ymin: 89.5 xmax: 166.5 ymax: 90
#> Geodetic CRS:  WGS 84
#>      gid xcoord ycoord col row                       geometry
#> 1 259168 163.75  89.75 688 360 POLYGON ((163.5 89.5, 163.5...
#> 2 259169 164.25  89.75 689 360 POLYGON ((164 89.5, 164 90,...
#> 3 259170 164.75  89.75 690 360 POLYGON ((164.5 89.5, 164.5...
#> 4 259171 165.25  89.75 691 360 POLYGON ((165 89.5, 165 90,...
#> 5 259172 165.75  89.75 692 360 POLYGON ((165.5 89.5, 165.5...
#> 6 259173 166.25  89.75 693 360 POLYGON ((166 89.5, 166 90,...
```
