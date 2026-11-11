# Calculate within-cell temporal change

Compares each observation with an earlier row from the same cell and
optional additional group. Percentage changes use the earlier value as
the denominator and return `NA` when it is zero. Log differences require
both values to be strictly positive.

## Usage

``` r
pg_temporal_change(
  data,
  value,
  time = "measurement_date",
  pgid = "pgid",
  periods = 1L,
  type = c("difference", "percent", "log"),
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

- periods:

  Positive integer comparison lag.

- type:

  One of `"difference"`, `"percent"`, or `"log"`.

- group:

  Optional additional grouping-column names.

- name:

  Name of the appended change column.

- config:

  A PRIO-GRID configuration object.

## Value

`data` in its original row order with the change column appended.

## Examples

``` r
config <- priogrid::pg_config(nrow = 2, ncol = 3)
x <- data.frame(pgid = 1, year = 2020:2022, value = c(10, 15, 12))
pg_temporal_change(x, "value", time = "year", config = config)
#>   pgid year value value_difference
#> 1    1 2020    10               NA
#> 2    1 2021    15                5
#> 3    1 2022    12               -3
```
