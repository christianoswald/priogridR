# Compare PRIO-GRID datasets

Compares configuration, keys, missingness, types, and selected values
while keeping absent keys distinct from observed missing values.

## Usage

``` r
pg_compare(
  x,
  y,
  id = "pgid",
  time = NULL,
  variables = NULL,
  tolerance = sqrt(.Machine$double.eps),
  config_x = NULL,
  config_y = NULL
)

# S3 method for class 'pg_comparison'
print(x, ...)
```

## Arguments

- x, y:

  Data frames or `pg_result` objects.

- id:

  Cell identifier column.

- time:

  Optional temporal column.

- variables:

  Variables to compare. Common non-key columns are used by default.

- tolerance:

  Numeric equality tolerance.

- config_x, config_y:

  Optional configurations for the two objects.

- ...:

  Additional arguments, currently unused.

## Value

A `pg_comparison` object.

## Examples

``` r
config <- priogrid::pg_config(nrow = 2, ncol = 3, verbose = FALSE)
x <- data.frame(pgid = 1:3, value = 1:3)
y <- data.frame(pgid = 2:4, value = c(2, 3, 5))
pg_compare(x, y, config_x = config, config_y = config)
#> <pg_comparison>
#>   Compatible: yes
#>   Keys: 2 shared; 1 x-only; 1 y-only
#>   Variables compared: 1
```
