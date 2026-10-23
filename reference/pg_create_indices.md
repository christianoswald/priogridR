# Create a matrix of PRIO-GRID identifiers

Creates a matrix using the PRIO-GRID numbering convention. Row one is
the northernmost row, while identifiers begin in the south-western cell.

## Usage

``` r
pg_create_indices(nrow, ncol)
```

## Arguments

- nrow:

  The number of rows in the grid.

- ncol:

  The number of columns in the grid.

## Value

An `nrow` by `ncol` integer matrix.

## Examples

``` r
pgrid <- pg_create_indices(3, 3)
stopifnot(pgrid[1, 1] == 7L)
stopifnot(pgrid[3, 1] == 1L)
stopifnot(pgrid[3, 3] == 3L)
stopifnot(pgrid[1, 3] == 9L)
```
