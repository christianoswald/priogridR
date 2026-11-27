# Bind compatible PRIO-GRID datasets

Combines datasets by rows or variables after conservative grid, key, and
temporal compatibility checks.

## Usage

``` r
pg_bind(
  ...,
  along = c("rows", "variables"),
  id = "pgid",
  time = NULL,
  conflict = c("error", "first", "last"),
  config = priogrid::pg_current_config()
)
```

## Arguments

- ...:

  Two or more data frames or `pg_result` objects.

- along:

  Bind rows or variables.

- id:

  Cell identifier column.

- time:

  Optional temporal column.

- conflict:

  Handling of duplicate keys or conflicting shared variables.

- config:

  PRIO-GRID configuration used for compatibility checks.

## Value

A data frame with combination metadata attached.

## Examples

``` r
config <- priogrid::pg_config(nrow = 2, ncol = 3, verbose = FALSE)
x <- data.frame(pgid = 1:3, value = 1:3)
y <- data.frame(pgid = 4:6, value = 4:6)
pg_bind(x, y, config = config)
#>   pgid value
#> 1    1     1
#> 2    2     2
#> 3    3     3
#> 4    4     4
#> 5    5     5
#> 6    6     6
```
