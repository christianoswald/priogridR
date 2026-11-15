# Compare values represented on a common grid

Compares reference and candidate data after both have been represented
on the same cell and optional panel keys. Cell detail exposes signed,
absolute, and relative differences; summary detail reports matching
coverage, bias, mean absolute error, root mean squared error, and
correlation.

## Usage

``` r
pg_compare_resolutions(
  reference,
  candidate,
  values,
  by = "pgid",
  detail = c("summary", "cells"),
  suffix = c("_reference", "_candidate")
)
```

## Arguments

- reference, candidate:

  Data frames represented on the same grid.

- values:

  Names of numeric columns present in both inputs.

- by:

  Key columns used to align observations.

- detail:

  Return `"summary"` diagnostics or `"cells"` differences.

- suffix:

  Two suffixes identifying reference and candidate values in cell-level
  output.

## Value

A data frame of summary metrics or aligned cell-level differences.

## Examples

``` r
reference <- data.frame(pgid = 1:3, value = c(1, 2, 3))
candidate <- data.frame(pgid = 1:3, value = c(1, 2.5, 2.5))
pg_compare_resolutions(reference, candidate, "value")
#>   variable n_reference n_candidate n_matched reference_coverage
#> 1    value           3           3         3                  1
#>   candidate_coverage mean_difference mean_absolute_difference      rmse
#> 1                  1               0                0.3333333 0.4082483
#>   correlation
#> 1   0.8660254
pg_compare_resolutions(reference, candidate, "value", detail = "cells")
#>   pgid value_reference value_candidate value_difference
#> 1    1               1             1.0              0.0
#> 2    2               2             2.5              0.5
#> 3    3               3             2.5             -0.5
#>   value_absolute_difference value_relative_difference
#> 1                       0.0                 0.0000000
#> 2                       0.5                 0.2500000
#> 3                       0.5                -0.1666667
```
