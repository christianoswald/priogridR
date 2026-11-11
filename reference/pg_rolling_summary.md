# Calculate rolling summaries within PRIO-GRID cells

Calculates row-based windows after ordering observations by time within
each cell and optional additional groups. Missing periods are not
inserted automatically; complete the panel first when windows must
represent fixed calendar intervals.

## Usage

``` r
pg_rolling_summary(
  data,
  value,
  time = "measurement_date",
  pgid = "pgid",
  window = 3L,
  fun = c("mean", "sum", "min", "max", "median", "sd"),
  align = c("right", "center", "left"),
  min_obs = window,
  na_rm = FALSE,
  group = NULL,
  name = NULL,
  config = priogrid::pg_current_config()
)
```

## Arguments

- data:

  A data frame containing a cell-time panel.

- value:

  Name of a numeric value column.

- time:

  Name of the temporal ordering column.

- pgid:

  Name of the PRIO-GRID cell-ID column.

- window:

  Positive integer window size.

- fun:

  Summary function: `"mean"`, `"sum"`, `"min"`, `"max"`, `"median"`, or
  `"sd"`.

- align:

  Window alignment: `"right"`, `"center"`, or `"left"`.

- min_obs:

  Minimum number of non-missing observations required.

- na_rm:

  Should missing values be removed before summarizing?

- group:

  Optional additional grouping-column names.

- name:

  Name of the appended summary column.

- config:

  A PRIO-GRID configuration object.

## Value

`data` in its original row order with the rolling summary appended.

## Examples

``` r
config <- priogrid::pg_config(nrow = 2, ncol = 3)
x <- data.frame(pgid = 1, year = 2018:2022, events = 1:5)
pg_rolling_summary(
  x, "events", time = "year", window = 3, min_obs = 1,
  config = config
)
#>   pgid year events events_rolling_mean_3
#> 1    1 2018      1                   1.0
#> 2    1 2019      2                   1.5
#> 3    1 2020      3                   2.0
#> 4    1 2021      4                   3.0
#> 5    1 2022      5                   4.0
```
