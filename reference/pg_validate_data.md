# Validate PRIO-GRID data

Checks cell identifiers, missing keys, duplicate cell-time observations,
and optionally whether all configured cells and observed time periods
are represented.

## Usage

``` r
pg_validate_data(
  data,
  pg_id = "pgid",
  time = NULL,
  require_unique = TRUE,
  require_complete = FALSE,
  config = priogrid::pg_current_config()
)

# S3 method for class 'pg_validation'
print(x, ...)
```

## Arguments

- data:

  A data frame containing PRIO-GRID data.

- pg_id:

  Name of the cell-ID column.

- time:

  Optional name of the temporal identifier column.

- require_unique:

  Should duplicate cell or cell-time keys make the data invalid?

- require_complete:

  Should missing cell or cell-time combinations make the data invalid?

- config:

  A PRIO-GRID configuration object.

- x:

  A `pg_validation` object.

- ...:

  Additional arguments, currently unused.

## Value

A `pg_validation` object containing the overall result, counts, and a
table of detected issues.

## Examples

``` r
config <- priogrid::pg_config(nrow = 2, ncol = 3)
x <- data.frame(pgid = 1:6, value = runif(6))
pg_validate_data(x, config = config)
#> PRIO-GRID validation: valid
#> Rows: 6; observed cells: 6
#> No issues detected.
```
