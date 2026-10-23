# Find first-order PRIO-GRID neighbors

Returns queen-contiguity neighbors: cells sharing either an edge or a
corner with the requested cell. Longitude wraps across the antimeridian
by default; latitude never wraps across the poles.

## Usage

``` r
pg_neighbors(x, nrow = 360L, ncol = 720L, wrap_longitude = TRUE)
```

## Arguments

- x:

  One PRIO-GRID cell identifier.

- nrow:

  Number of grid rows.

- ncol:

  Number of grid columns.

- wrap_longitude:

  Should the western and eastern edges be adjacent?

## Value

An integer vector containing neighboring cell identifiers. Interior
cells have eight neighbors and cells in the northern or southern row
have five when `wrap_longitude = TRUE`.

## Examples

``` r
pg_neighbors(234209)
#> [1] 234928 234929 234930 234208 234210 233488 233489 233490
pg_neighbors(1, nrow = 3, ncol = 3)
#> [1] 6 4 5 3 2
```
