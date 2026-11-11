# Lead values within PRIO-GRID cells

Adds a row-based lead after ordering observations by time within each
cell and optional additional groups. Missing periods are not inserted
automatically; use
[`pg_complete_panel()`](https://christianoswald.github.io/priogridR/reference/pg_complete_panel.md)
first when calendar-complete leads are required.

## Usage

``` r
pg_temporal_lead(
  data,
  value,
  time = "measurement_date",
  pgid = "pgid",
  periods = 1L,
  group = NULL,
  name = paste0(value, "_lead", periods),
  config = priogrid::pg_current_config()
)
```

## Arguments

- data:

  A data frame containing a cell-time panel.

- value:

  Name of the column to lead.

- time:

  Name of the temporal ordering column.

- pgid:

  Name of the PRIO-GRID cell-ID column.

- periods:

  Positive integer number of rows to lead.

- group:

  Optional additional grouping-column names.

- name:

  Name of the appended lead column.

- config:

  A PRIO-GRID configuration object.

## Value

`data` in its original row order with the lead column appended.

## Examples

``` r
config <- priogrid::pg_config(nrow = 2, ncol = 3)
x <- data.frame(
  pgid = rep(1:2, each = 3),
  year = rep(2020:2022, 2),
  events = 1:6
)
pg_temporal_lead(x, "events", time = "year", config = config)
#>   pgid year events events_lead1
#> 1    1 2020      1            2
#> 2    1 2021      2            3
#> 3    1 2022      3           NA
#> 4    2 2020      4            5
#> 5    2 2021      5            6
#> 6    2 2022      6           NA
```
