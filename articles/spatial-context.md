# Spatial context

``` r

library(priogridR)
```

Spatial analyses often require choices about which cells count as
neighbors, how strongly neighbors are weighted, and whether observations
from different periods may interact. The spatial-context functions make
these choices explicit and return ordinary data frames that can be
inspected or reused.

## Configure an example grid

The examples use a coarse grid so that they render quickly.

``` r

config <- priogrid::pg_config(
  nrow = 18,
  ncol = 36,
  start_date = as.Date("2020-12-31"),
  end_date = as.Date("2021-12-31"),
  temporal_resolution = "1 year",
  verbose = FALSE
)
```

## Define neighborhoods

[`pg_neighbor_table()`](https://christianoswald.github.io/priogridR/reference/pg_neighbor_table.md)
creates directed source-neighbor pairs. Queen neighbors share an edge or
corner, whereas rook neighbors must share an edge.

``` r

queen <- pg_neighbor_table(20:22, method = "queen", config = config)
rook <- pg_neighbor_table(20:22, method = "rook", config = config)

queen
#>    pgid neighbor_pgid
#> 1    20            19
#> 2    20            21
#> 3    20            55
#> 4    20            56
#> 5    20            57
#> 6    21            20
#> 7    21            22
#> 8    21            56
#> 9    21            57
#> 10   21            58
#> 11   22            21
#> 12   22            23
#> 13   22            57
#> 14   22            58
#> 15   22            59
rook
#>   pgid neighbor_pgid
#> 1   20            19
#> 2   20            21
#> 3   20            56
#> 4   21            20
#> 5   21            22
#> 6   21            57
#> 7   22            21
#> 8   22            23
#> 9   22            58
```

Candidate cells can be restricted explicitly. This is useful when an
analysis contains only a regional or otherwise selected subset of the
global grid.

``` r

pg_neighbor_table(
  pgid = 20:22,
  candidates = 18:25,
  method = "rook",
  config = config
)
#>   pgid neighbor_pgid
#> 1   20            19
#> 2   20            21
#> 3   21            20
#> 4   21            22
#> 5   22            21
#> 6   22            23
```

Distance-band and k-nearest-neighbor definitions include distances
between cell centres in kilometres.

``` r

distance_neighbors <- pg_neighbor_table(
  20:22,
  candidates = 18:25,
  method = "distance",
  distance = 1200,
  config = config
)

nearest_neighbors <- pg_neighbor_table(
  20:22,
  candidates = 18:25,
  method = "knn",
  k = 2,
  config = config
)

distance_neighbors
#>    pgid neighbor_pgid distance_km
#> 1    20            18   192.85065
#> 2    20            19    96.79089
#> 3    20            21    96.79089
#> 4    20            22   192.85065
#> 5    20            23   287.45334
#> 6    20            24   379.88340
#> 7    20            25   469.44077
#> 8    21            18   287.45334
#> 9    21            19   192.85065
#> 10   21            20    96.79089
#> 11   21            22    96.79089
#> 12   21            23   192.85065
#> 13   21            24   287.45334
#> 14   21            25   379.88340
#> 15   22            18   379.88340
#> 16   22            19   287.45334
#> 17   22            20   192.85065
#> 18   22            21    96.79089
#> 19   22            23    96.79089
#> 20   22            24   192.85065
#> 21   22            25   287.45334
nearest_neighbors
#>   pgid neighbor_pgid distance_km
#> 1   20            19    96.79089
#> 2   20            21    96.79089
#> 3   21            22    96.79089
#> 4   21            20    96.79089
#> 5   22            21    96.79089
#> 6   22            23    96.79089
```

## Construct weights

Binary weights treat all listed neighbors equally. Row standardization,
which is enabled by default, makes the weights for each focal cell sum
to one.

``` r

rook_weights <- pg_weights(rook)
rook_weights
#>   pgid neighbor_pgid    weight
#> 1   20            19 0.3333333
#> 2   20            21 0.3333333
#> 3   20            56 0.3333333
#> 4   21            20 0.3333333
#> 5   21            22 0.3333333
#> 6   21            57 0.3333333
#> 7   22            21 0.3333333
#> 8   22            23 0.3333333
#> 9   22            58 0.3333333
```

Inverse-distance weights require a table containing `distance_km`.

``` r

pg_weights(nearest_neighbors, type = "inverse_distance")
#>   pgid neighbor_pgid distance_km weight
#> 1   20            19    96.79089    0.5
#> 2   20            21    96.79089    0.5
#> 3   21            22    96.79089    0.5
#> 4   21            20    96.79089    0.5
#> 5   22            21    96.79089    0.5
#> 6   22            23    96.79089    0.5
```

## Calculate spatial lags

[`pg_spatial_lag()`](https://christianoswald.github.io/priogridR/reference/pg_spatial_lag.md)
adds a weighted neighboring-cell value to a data frame. If no weights
are supplied, it uses a row-standardized queen neighborhood. Time
columns isolate periods, preventing values from one year from leaking
into another.

``` r

panel <- data.frame(
  pgid = rep(20:25, 2),
  year = rep(2020:2021, each = 6),
  events = c(0, 1, 2, 0, 3, 1, 1, 2, 4, 0, 2, 3)
)

lagged <- pg_spatial_lag(
  panel,
  value = "events",
  time = "year",
  config = config
)

lagged
#>    pgid year events events_spatial_lag
#> 1    20 2020      0                1.0
#> 2    21 2020      1                1.0
#> 3    22 2020      2                0.5
#> 4    23 2020      0                2.5
#> 5    24 2020      3                0.5
#> 6    25 2020      1                3.0
#> 7    20 2021      1                2.0
#> 8    21 2021      2                2.5
#> 9    22 2021      4                1.0
#> 10   23 2021      0                3.0
#> 11   24 2021      2                1.5
#> 12   25 2021      3                2.0
```

## Distances and nearest cells

[`pg_distance()`](https://christianoswald.github.io/priogridR/reference/pg_distance.md)
supports paired comparisons and all source-destination combinations.
[`pg_nearest()`](https://christianoswald.github.io/priogridR/reference/pg_nearest.md)
returns an ordered, deterministic nearest-cell table.

``` r

pg_distance(20:22, 23:25, config = config)
#>   from_pgid to_pgid distance_km
#> 1        20      23    287.4533
#> 2        21      24    287.4533
#> 3        22      25    287.4533
pg_distance(20:21, 22:25, pairwise = FALSE, config = config)
#>   from_pgid to_pgid distance_km
#> 1        20      22   192.85065
#> 2        20      23   287.45334
#> 3        20      24   379.88340
#> 4        20      25   469.44077
#> 5        21      22    96.79089
#> 6        21      23   192.85065
#> 7        21      24   287.45334
#> 8        21      25   379.88340

pg_nearest(
  from = 20:22,
  candidates = 18:25,
  n = 2,
  config = config
)
#>   from_pgid nearest_pgid distance_km rank
#> 1        20           19    96.79089    1
#> 2        20           21    96.79089    2
#> 3        21           22    96.79089    1
#> 4        21           20    96.79089    2
#> 5        22           21    96.79089    1
#> 6        22           23    96.79089    2
```

## Summarize values within buffers

[`pg_buffer_summary()`](https://christianoswald.github.io/priogridR/reference/pg_buffer_summary.md)
calculates a sum, mean, count, minimum, or maximum over cells within a
radius. The focal cell is included by default, and time columns again
keep periods separate.

``` r

buffered <- pg_buffer_summary(
  panel,
  value = "events",
  radius = 1200,
  statistic = "sum",
  time = "year",
  config = config
)

buffered
#>    pgid year events events_buffer_sum
#> 1    20 2020      0                 7
#> 2    21 2020      1                 7
#> 3    22 2020      2                 7
#> 4    23 2020      0                 7
#> 5    24 2020      3                 7
#> 6    25 2020      1                 7
#> 7    20 2021      1                12
#> 8    21 2021      2                12
#> 9    22 2021      4                12
#> 10   23 2021      0                12
#> 11   24 2021      2                12
#> 12   25 2021      3                12
```

Distances are based on cell centres. A distance-band or buffer therefore
does not mean that the corresponding cell polygons overlap the specified
radius. This distinction should be reported when it is substantively
important.
