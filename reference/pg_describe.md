# Describe a PRIO-GRID dataset

Produces a compact structural summary without constructing a complete
panel.

## Usage

``` r
pg_describe(x, id = "pgid", time = NULL, variables = NULL, config = NULL)

# S3 method for class 'pg_description'
print(x, ...)
```

## Arguments

- x:

  A data frame or `pg_result` with a tabular component.

- id:

  Cell identifier column.

- time:

  Optional temporal column.

- variables:

  Variables for missingness summaries.

- config:

  Optional PRIO-GRID configuration.

- ...:

  Additional arguments, currently unused.

## Value

A `pg_description` object containing overview, missingness, validation,
and metadata components.

## Examples

``` r
x <- data.frame(pgid = c(1, 2, 2), year = c(2020, 2020, 2021), value = c(1, NA, 3))
pg_describe(x, time = "year", config = priogrid::pg_config(nrow = 2, ncol = 3, verbose = FALSE))
#> <pg_description>
#>   Rows: 3; cells: 2; periods: 2
#>   Variables: 1; duplicate keys: 0
#>   Balanced over observed domain: no
```
