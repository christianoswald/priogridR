# Summarize observed missing values

Missingness is calculated only among rows present in `x`; structurally
absent cell-periods are handled by
[`pg_coverage()`](https://christianoswald.github.io/priogridR/reference/pg_coverage.md).

## Usage

``` r
pg_missingness(
  x,
  variables = NULL,
  id = "pgid",
  time = NULL,
  group_columns = NULL,
  by = c("variable", "cell", "time", "group")
)
```

## Arguments

- x:

  A data frame or `pg_result` with a tabular component.

- variables:

  Columns to summarize. By default, all non-key and non-grouping columns
  are used.

- id:

  Cell identifier column.

- time:

  Optional temporal column.

- group_columns:

  Optional grouping columns.

- by:

  Summary dimension: variable, cell, time, or group.

## Value

A data frame with observed, missing, non-missing, and missing-share
columns.

## Examples

``` r
x <- data.frame(pgid = 1:3, value = c(1, NA, 3))
pg_missingness(x)
#>   variable n_observed n_missing n_non_missing missing_share
#> 1    value          3         1             2     0.3333333
```
