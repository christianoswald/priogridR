# Aggregation and cross-level workflows

``` r

library(priogridR)
```

Cross-level analysis is not a single neutral operation. A population
total may be divided between overlapping regions, whereas a rate should
normally be averaged using the area represented by each source
observation. The functions in this vignette require that distinction to
be stated explicitly.

## Grouped summaries

[`pg_aggregate()`](https://christianoswald.github.io/priogridR/reference/pg_aggregate.md)
provides ordinary grouped summaries without introducing a
package-specific data class.

``` r

cells <- data.frame(
  region = c("a", "a", "b"),
  events = c(1, 2, 4),
  population = c(100, 200, 150)
)

pg_aggregate(
  cells,
  values = c("events", "population"),
  by = "region",
  fun = "sum"
)
#>   region events population
#> 1      a      3        300
#> 2      b      4        150
```

Weights may be supplied for means. Weighted totals are handled
separately by
[`pg_area_weight()`](https://christianoswald.github.io/priogridR/reference/pg_area_weight.md)
because they require a substantive allocation rule.

## Construct a spatial crosswalk

The target polygons are supplied by the researcher. This makes the
source, date, and territorial definition of administrative or country
boundaries part of the reproducible workflow.

``` r

config <- priogrid::pg_config(nrow = 18, ncol = 36, verbose = FALSE)

regions <- pg_geometry(342:344, config = config)
regions$region_id <- c("a", "a", "b")

crosswalk <- pg_crosswalk(
  regions,
  target_id = "region_id",
  pgid = 342:344,
  assignment = "fractional",
  config = config
)

crosswalk
#>   pgid region_id overlap_area_km2 allocation_area_km2 cell_fraction
#> 1  342         a          1233205             1233205             1
#> 2  343         a          1233205             1233205             1
#> 3  344         b          1233205             1233205             1
#>   target_fraction
#> 1             0.5
#> 2             0.5
#> 3             1.0
```

Repeated target identifiers are dissolved before intersection.
Fractional assignment returns every positive-area overlap.
`assignment = "largest"` assigns the whole source cell to the target
with its largest overlap, while `assignment = "centroid"` uses the cell
centre. Overlapping targets make a centroid assignment ambiguous and
therefore produce an error.

The returned diagnostics distinguish:

- `overlap_area_km2`: the observed geometric intersection;
- `allocation_area_km2`: the area used to weight intensive values;
- `cell_fraction`: the share of an extensive cell total assigned to a
  target;
- `target_fraction`: the share of the target represented by the
  intersection.

## Extensive and intensive variables

An extensive variable is additive over space. Population counts and
event counts are common examples. An intensive variable describes a
local level or rate and should not normally be summed.

``` r

grid_data <- data.frame(
  pgid = 342:344,
  population = c(100, 200, 300),
  rate = c(0.1, 0.2, 0.4)
)

transferred <- pg_area_weight(
  grid_data,
  crosswalk,
  values = c("population", "rate"),
  target_id = "region_id",
  variable_type = c(
    population = "extensive",
    rate = "intensive"
  )
)

transferred
#>   region_id population population_coverage rate rate_coverage
#> 1         a        300                   1 0.15             1
#> 2         b        300                   1 0.40             1
```

Each output variable receives a `_coverage` column. It is the share of
the relevant allocation weight represented by non-missing values. With
`na_rm = FALSE`, incomplete coverage produces a missing estimate but the
coverage diagnostic remains available.

## Aggregate to countries

[`pg_to_country()`](https://christianoswald.github.io/priogridR/reference/pg_to_country.md)
combines crosswalk construction and value transfer. It does not download
or bundle a particular country-boundary dataset.

``` r

country_result <- pg_to_country(
  grid_data,
  countries = regions,
  country_id = "region_id",
  values = "population",
  variable_type = "extensive",
  return_crosswalk = TRUE,
  config = config
)

country_result$data
#>   region_id population population_coverage
#> 1         a        300                   1
#> 2         b        300                   1
```

Setting `return_crosswalk = TRUE` makes the exact spatial allocation
available for inspection, storage, and reuse.

One boundary definition is used in each call. When a historical panel
spans territorial changes, split it into documented boundary vintages,
call
[`pg_to_country()`](https://christianoswald.github.io/priogridR/reference/pg_to_country.md)
separately for each vintage, and then combine the results. This prevents
the package from silently applying present-day borders to past
observations.

## Change grid resolution

Resolution changes use the same extensive-versus-intensive rules.

``` r

fine <- priogrid::pg_config(nrow = 18, ncol = 36, verbose = FALSE)
coarse <- priogrid::pg_config(nrow = 9, ncol = 18, verbose = FALSE)
fine_ids <- c(342L, 343L, 378L, 379L)
coordinates <- pg_coords_from_id(fine_ids, config = fine)

fine_data <- data.frame(
  pgid = fine_ids,
  population = rep(10, 4),
  rate = ifelse(coordinates$xcoord < 0, 2, 4)
)

coarse_data <- pg_change_resolution(
  fine_data,
  values = c("population", "rate"),
  from_config = fine,
  to_config = coarse,
  variable_type = c(
    population = "extensive",
    rate = "intensive"
  )
)

coarse_data
#>   pgid population population_coverage rate rate_coverage
#> 1   81  10.077138                   1    2             1
#> 2   82  10.077138                   1    4             1
#> 3   99   9.922862                   1    2             1
#> 4  100   9.922862                   1    4             1
```

Extensive totals are fractionally allocated, so a complete
transformation preserves their global sum apart from numerical
tolerance. Intensive values are averaged with allocated area as the
weight.

## Compare alternative representations

After two alternatives have been placed on the same grid,
[`pg_compare_resolutions()`](https://christianoswald.github.io/priogridR/reference/pg_compare_resolutions.md)
can return either row-level differences or compact diagnostics.

``` r

alternative <- coarse_data
alternative$rate <- alternative$rate + c(0.1, -0.1)

pg_compare_resolutions(
  coarse_data,
  alternative,
  values = c("population", "rate")
)
#>     variable n_reference n_candidate n_matched reference_coverage
#> 1 population           4           4         4                  1
#> 2       rate           4           4         4                  1
#>   candidate_coverage mean_difference mean_absolute_difference rmse correlation
#> 1                  1               0                      0.0  0.0           1
#> 2                  1               0                      0.1  0.1           1

pg_compare_resolutions(
  coarse_data,
  alternative,
  values = "rate",
  detail = "cells"
)
#>   pgid rate_reference rate_candidate rate_difference rate_absolute_difference
#> 1   81              2            2.1             0.1                      0.1
#> 2   82              4            3.9            -0.1                      0.1
#> 3   99              2            2.1             0.1                      0.1
#> 4  100              4            3.9            -0.1                      0.1
#>   rate_relative_difference
#> 1                    0.050
#> 2                   -0.025
#> 3                    0.050
#> 4                   -0.025
```

The summary reports matching coverage, mean difference, mean absolute
difference, root mean squared error, and correlation. These diagnostics
do not decide which spatial representation is substantively preferable;
they expose the consequences of that choice.
