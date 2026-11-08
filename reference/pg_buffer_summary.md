# Summarize values around PRIO-GRID cells

Adds a summary of values observed in cells whose centres fall within a
specified radius of each focal cell. Temporal columns can be supplied to
prevent values from different periods being combined.

## Usage

``` r
pg_buffer_summary(
  data,
  value,
  radius,
  statistic = c("sum", "mean", "count", "min", "max"),
  pgid = "pgid",
  time = NULL,
  include_self = TRUE,
  na_rm = TRUE,
  name = paste0(value, "_buffer_", statistic[1L]),
  config = priogrid::pg_current_config()
)
```

## Arguments

- data:

  A data frame containing one observation per cell or cell-period.

- value:

  Name of the numeric value column.

- radius:

  Buffer radius in kilometres.

- statistic:

  Summary to calculate.

- pgid:

  Name of the cell-ID column.

- time:

  Optional character vector naming temporal grouping columns.

- include_self:

  Should the focal cell be included in its own buffer?

- na_rm:

  Should missing values be omitted?

- name:

  Name of the new summary column.

- config:

  A PRIO-GRID configuration object.

## Value

`data` with the buffer-summary column appended.

## Examples

``` r
config <- priogrid::pg_config(nrow = 18, ncol = 36)
x <- data.frame(pgid = 1:4, events = c(1, 0, 2, 1))
pg_buffer_summary(x, "events", radius = 1500, statistic = "sum",
                  config = config)
#>   pgid events events_buffer_sum
#> 1    1      1                 4
#> 2    2      0                 4
#> 3    3      2                 4
#> 4    4      1                 4
```
