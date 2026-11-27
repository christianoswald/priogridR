# Reproducible PRIO-GRID workflows

`priogridR` keeps data conversion, quality assessment, combination, and
export in one explicit workflow. This vignette uses small offline data
so that every step can run during package checks.

## Construct two cell-period datasets

The first source has one observed missing value and several structurally
absent cell-periods. These are different conditions and should not be
treated as interchangeable.

``` r

climate <- data.frame(
  pgid = c(1, 2, 1, 2),
  year = c(2020, 2020, 2021, 2021),
  temperature = c(21, NA, 22, 20)
)

population <- data.frame(
  pgid = c(1, 2, 1, 2),
  year = c(2020, 2020, 2021, 2021),
  population = c(100, 80, 103, 82)
)
```

## Inspect metadata and structure

[`pg_metadata()`](https://christianoswald.github.io/priogridR/reference/pg_metadata.md)
reports only information that is stored in or supplied with an object.
It does not invent source provenance for an ordinary data frame.

``` r

pg_metadata(climate, config = config, time = "year")
#> <pg_metadata>
#>   Object: data.frame
#>   Grid: 2 x 3 (6 cells)
#>   Variables: temperature
#>   Time: year (2 periods)
pg_describe(climate, time = "year", config = config)
#> <pg_description>
#>   Rows: 4; cells: 2; periods: 2
#>   Variables: 1; duplicate keys: 0
#>   Balanced over observed domain: yes
```

## Separate coverage from missingness

Coverage uses the six configured cells and two requested years as its
explicit reference. Missingness, by contrast, uses only rows that
actually exist.

``` r

pg_coverage(
  climate,
  time = "year",
  variables = "temperature",
  config = config,
  reference_time = 2020:2021
)
#>   n_expected n_present n_structurally_absent n_outside_reference
#> 1         12         4                     8                   0
#>   n_observed_missing coverage_share
#> 1                  1      0.3333333

pg_missingness(climate, variables = "temperature", time = "year")
#>      variable n_observed n_missing n_non_missing missing_share
#> 1 temperature          4         1             3          0.25
```

An absent row does not imply a measured zero. Use
[`pg_complete_panel()`](https://christianoswald.github.io/priogridR/reference/pg_complete_panel.md)
only when a complete panel is substantively required, and provide `fill`
values only for variables with meaningful structural zeros.

## Check compatibility and combine sources

[`pg_assert_compatible()`](https://christianoswald.github.io/priogridR/reference/pg_assert_compatible.md)
checks grid, CRS, temporal, and key definitions.
[`pg_bind()`](https://christianoswald.github.io/priogridR/reference/pg_bind.md)
applies these safeguards before joining variables.

``` r

pg_assert_compatible(
  climate,
  population,
  config = config,
  time = "year"
)

analysis_data <- pg_bind(
  climate,
  population,
  along = "variables",
  config = config,
  time = "year"
)
analysis_data
#>   pgid year temperature population
#> 1    1 2020          21        100
#> 2    2 2020          NA         80
#> 3    1 2021          22        103
#> 4    2 2021          20         82
```

Row-wise binding is also supported. Duplicate keys and conflicting
values fail by default; `conflict = "first"` or `"last"` must be
requested explicitly.

## Compare versions

[`pg_compare()`](https://christianoswald.github.io/priogridR/reference/pg_compare.md)
distinguishes keys found in only one dataset, paired missing values,
one-sided missing values, and unequal observed values.

``` r

revised <- climate
revised$temperature[revised$pgid == 1 & revised$year == 2021] <- 22.25

comparison <- pg_compare(
  climate,
  revised,
  time = "year",
  variables = "temperature",
  config_x = config,
  config_y = config
)
comparison
#> <pg_comparison>
#>   Compatible: yes
#>   Keys: 4 shared; 0 x-only; 0 y-only
#>   Variables compared: 1
comparison$variables
#>      variable class_x class_y n_shared_keys n_equal n_unequal n_paired_missing
#> 1 temperature numeric numeric             4       2         1                1
#>   n_one_sided_missing mean_difference max_abs_difference
#> 1                   0     -0.08333333               0.25
```

## Apply existing utilities and export

The checked result remains an ordinary data frame and can be passed
directly to temporal, spatial, plotting, and output functions.

``` r

analysis_data <- pg_temporal_lag(
  analysis_data,
  variable = "temperature",
  time = "year"
)

pg_write_result(analysis_data, "analysis-data.parquet")
```

For a reproducible analysis, record the input data release, grid
configuration, variable semantics, transformations, and package version
alongside the result.
[`pg_metadata()`](https://christianoswald.github.io/priogridR/reference/pg_metadata.md)
provides a common schema for this information, but it cannot recover
provenance that was never recorded.
