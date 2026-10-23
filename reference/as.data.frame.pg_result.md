# Convert a PRIO-GRID result to a data frame

Convert a PRIO-GRID result to a data frame

## Usage

``` r
# S3 method for class 'pg_result'
as.data.frame(x, row.names = NULL, optional = FALSE, ...)
```

## Arguments

- x:

  A `pg_result` object.

- row.names, optional, ...:

  Passed to
  [`as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html).

## Value

The tabular component of `x`.
