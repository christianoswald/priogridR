# Create spatial weights

Adds binary or inverse-distance weights to a neighbor table, with
optional row standardization.

## Usage

``` r
pg_weights(
  neighbors,
  type = c("binary", "inverse_distance"),
  row_standardize = TRUE,
  power = 1
)
```

## Arguments

- neighbors:

  A neighbor table produced by
  [`pg_neighbor_table()`](https://christianoswald.github.io/priogridR/reference/pg_neighbor_table.md).

- type:

  Use binary or inverse-distance weights.

- row_standardize:

  Should weights sum to one within each source cell?

- power:

  Positive distance-decay exponent for inverse-distance weights.

## Value

The neighbor table with an added `weight` column.

## Examples

``` r
neighbors <- data.frame(
  pgid = c(1L, 1L, 2L),
  neighbor_pgid = c(2L, 3L, 1L),
  distance_km = c(10, 20, 10)
)
pg_weights(neighbors)
#>   pgid neighbor_pgid distance_km weight
#> 1    1             2          10    0.5
#> 2    1             3          20    0.5
#> 3    2             1          10    1.0
pg_weights(neighbors, type = "inverse_distance")
#>   pgid neighbor_pgid distance_km    weight
#> 1    1             2          10 0.6666667
#> 2    1             3          20 0.3333333
#> 3    2             1          10 1.0000000
```
