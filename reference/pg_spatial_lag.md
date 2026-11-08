# Calculate a spatial lag

Adds a weighted sum of neighboring cell values to a cell-level or
cell-period data frame. The default is a row-standardized first-order
queen neighborhood, so the resulting lag is the neighboring-cell mean.

## Usage

``` r
pg_spatial_lag(
  data,
  value,
  pgid = "pgid",
  time = NULL,
  weights = NULL,
  method = c("queen", "rook"),
  wrap_longitude = TRUE,
  na_rm = FALSE,
  name = paste0(value, "_spatial_lag"),
  config = priogrid::pg_current_config()
)
```

## Arguments

- data:

  A data frame containing cell IDs and the variable to lag.

- value:

  Name of the numeric value column.

- pgid:

  Name of the PRIO-GRID cell-ID column.

- time:

  Optional character vector naming temporal grouping columns.

- weights:

  Optional table with `pgid`, `neighbor_pgid`, and `weight`. When
  omitted, weights are created from
  [`pg_neighbor_table()`](https://christianoswald.github.io/priogridR/reference/pg_neighbor_table.md).

- method:

  Contiguity method used when `weights` is omitted.

- wrap_longitude:

  Should default neighborhoods wrap across the antimeridian?

- na_rm:

  Should missing and unavailable neighbor values be omitted?

- name:

  Name of the new spatial-lag column.

- config:

  A PRIO-GRID configuration object.

## Value

`data` with the spatial-lag column appended.

## Examples

``` r
config <- priogrid::pg_config(nrow = 18, ncol = 36)
x <- data.frame(pgid = 1:4, value = c(1, 2, 3, 4))
pg_spatial_lag(x, "value", config = config)
#>   pgid value value_spatial_lag
#> 1    1     1                 2
#> 2    2     2                 2
#> 3    3     3                 3
#> 4    4     4                 3
```
