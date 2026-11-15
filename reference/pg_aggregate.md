# Aggregate PRIO-GRID data by explicit groups

Summarizes one or more numeric variables while keeping grouping columns
explicit. Optional weights are supported for means; weighted totals
should instead be constructed with
[`pg_area_weight()`](https://christianoswald.github.io/priogridR/reference/pg_area_weight.md)
so that extensive and intensive variables cannot be confused.

## Usage

``` r
pg_aggregate(
  data,
  values,
  by,
  fun = c("sum", "mean", "min", "max", "median", "sd"),
  weights = NULL,
  na_rm = FALSE,
  suffix = NULL
)
```

## Arguments

- data:

  A data frame.

- values:

  Names of numeric columns to summarize.

- by:

  Names of grouping columns.

- fun:

  Summary function: `"sum"`, `"mean"`, `"min"`, `"max"`, `"median"`, or
  `"sd"`.

- weights:

  Optional name of a non-negative numeric weight column. Weights may
  only be used with `fun = "mean"`.

- na_rm:

  Should missing values be removed? When `FALSE`, a missing value in a
  group produces a missing summary.

- suffix:

  Optional suffix appended to output value-column names.

## Value

A data frame with one row per unique combination of `by`.

## Examples

``` r
x <- data.frame(
  region = c("a", "a", "b"),
  events = c(1, 2, 4),
  population = c(10, 20, 40)
)
pg_aggregate(x, c("events", "population"), by = "region", fun = "sum")
#>   region events population
#> 1      a      3         30
#> 2      b      4         40
```
