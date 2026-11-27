# Calculate PRIO-GRID coverage

Distinguishes structurally absent keys from present rows containing
missing measurements relative to an explicit grid and temporal
reference.

## Usage

``` r
pg_coverage(
  x,
  id = "pgid",
  time = NULL,
  variables = NULL,
  config = priogrid::pg_current_config(),
  reference_ids = NULL,
  reference_time = NULL,
  by = c("overall", "cell", "time", "variable")
)
```

## Arguments

- x:

  A data frame or `pg_result` with a tabular component.

- id:

  Cell identifier column.

- time:

  Optional temporal column.

- variables:

  Measurement columns used to count observed missing values.

- config:

  PRIO-GRID configuration defining reference cells.

- reference_ids:

  Optional explicit reference cell identifiers.

- reference_time:

  Optional explicit reference periods.

- by:

  Summary dimension.

## Value

A data frame with expected, present, structurally absent, outside, and
observed-missing counts.

## Examples

``` r
config <- priogrid::pg_config(nrow = 2, ncol = 3, verbose = FALSE)
x <- data.frame(pgid = c(1, 3), value = c(1, NA))
pg_coverage(x, config = config)
#>   n_expected n_present n_structurally_absent n_outside_reference
#> 1          6         2                     4                   0
#>   n_observed_missing coverage_share
#> 1                  1      0.3333333
```
