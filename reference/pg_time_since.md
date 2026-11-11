# Calculate time since the most recent within-cell event

Adds the number of rows or days since the latest event in each cell and
optional additional group. Event rows receive zero and observations
before the first event receive `NA`.

## Usage

``` r
pg_time_since(
  data,
  event,
  time = "measurement_date",
  pgid = "pgid",
  units = c("periods", "days"),
  group = NULL,
  name = paste0(event, "_time_since"),
  config = priogrid::pg_current_config()
)
```

## Arguments

- data:

  A data frame containing a cell-time panel.

- event:

  Name of a logical or binary numeric event column.

- time:

  Name of the temporal ordering column.

- pgid:

  Name of the PRIO-GRID cell-ID column.

- units:

  Measure elapsed time in `"periods"` or `"days"`.

- group:

  Optional additional grouping-column names.

- name:

  Name of the appended elapsed-time column.

- config:

  A PRIO-GRID configuration object.

## Value

`data` in its original row order with elapsed time appended.

## Examples

``` r
config <- priogrid::pg_config(nrow = 2, ncol = 3)
x <- data.frame(
  pgid = 1,
  date = as.Date("2020-01-01") + c(0, 10, 20, 30),
  event = c(FALSE, TRUE, FALSE, FALSE)
)
pg_time_since(x, "event", time = "date", units = "days", config = config)
#>   pgid       date event event_time_since
#> 1    1 2020-01-01 FALSE               NA
#> 2    1 2020-01-11  TRUE                0
#> 3    1 2020-01-21 FALSE               10
#> 4    1 2020-01-31 FALSE               20
```
