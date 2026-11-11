# Lag values within PRIO-GRID cells

Adds a row-based lag after ordering observations by time within each
cell and optional additional groups. Missing periods are not inserted
automatically; use
[`pg_complete_panel()`](https://christianoswald.github.io/priogridR/reference/pg_complete_panel.md)
first when calendar-complete lags are required.

## Usage

``` r
pg_temporal_lag(
  data,
  value,
  time = "measurement_date",
  pgid = "pgid",
  periods = 1L,
  group = NULL,
  name = paste0(value, "_lag", periods),
  config = priogrid::pg_current_config()
)
```

## Arguments

- data:

  A data frame containing a cell-time panel.

- value:

  Name of the column to lag.

- time:

  Name of the temporal ordering column.

- pgid:

  Name of the PRIO-GRID cell-ID column.

- periods:

  Positive integer number of rows to lag.

- group:

  Optional additional grouping-column names.

- name:

  Name of the appended lag column.

- config:

  A PRIO-GRID configuration object.

## Value

`data` in its original row order with the lag column appended.

## Examples

``` r
config <- priogrid::pg_config(nrow = 2, ncol = 3)
x <- data.frame(
  pgid = rep(1:2, each = 3),
  year = rep(2020:2022, 2),
  events = 1:6
)
pg_temporal_lag(x, "events", time = "year", config = config)
#>   pgid year events events_lag1
#> 1    1 2020      1          NA
#> 2    1 2021      2           1
#> 3    1 2022      3           2
#> 4    2 2020      4          NA
#> 5    2 2021      5           4
#> 6    2 2022      6           5
```
