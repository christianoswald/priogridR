# Complete a PRIO-GRID panel

Adds absent cells or cell-time combinations to a data frame. Existing
rows and existing missing values are preserved; `fill` is applied only
to rows introduced by this function.

## Usage

``` r
pg_complete_panel(
  data,
  pg_id = "pgid",
  time = NULL,
  cells = NULL,
  times = NULL,
  fill = NULL,
  config = priogrid::pg_current_config()
)
```

## Arguments

- data:

  A data frame containing PRIO-GRID data.

- pg_id:

  Name of the cell-ID column.

- time:

  Optional name of the temporal identifier column.

- cells:

  Optional cell IDs to include. The configured grid is used by default.

- times:

  Optional time values to include. Observed non-missing values are used
  by default.

- fill:

  Optional named list of values used for newly created rows.

- config:

  A PRIO-GRID configuration object.

## Value

A data frame containing a complete grid or grid-time panel.

## Examples

``` r
config <- priogrid::pg_config(nrow = 2, ncol = 3)
x <- data.frame(pgid = c(1, 3), events = c(2, 1))
pg_complete_panel(x, fill = list(events = 0), config = config)
#>   pgid events
#> 1    4      0
#> 2    5      0
#> 3    6      0
#> 4    1      2
#> 5    2      0
#> 6    3      1
```
