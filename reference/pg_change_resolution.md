# Transfer PRIO-GRID values between configured resolutions

Uses exact cell intersections to allocate extensive totals or
area-average intensive values from one configured grid to another. This
function does not infer whether a variable is extensive or intensive.

## Usage

``` r
pg_change_resolution(
  data,
  values,
  from_config,
  to_config,
  variable_type,
  pgid = "pgid",
  time = NULL,
  group = NULL,
  na_rm = FALSE,
  return_crosswalk = FALSE
)
```

## Arguments

- data:

  A data frame containing values on `from_config`.

- values:

  Names of numeric value columns.

- from_config:

  Configuration describing the source grid.

- to_config:

  Configuration describing the target grid.

- variable_type:

  `"extensive"` or `"intensive"`, either once for all variables or as a
  named vector.

- pgid:

  Name of the source cell-ID column.

- time:

  Optional temporal key column.

- group:

  Optional additional grouping columns.

- na_rm:

  Should missing source values be ignored?

- return_crosswalk:

  Return only the converted data or a list containing both `data` and
  the generated `crosswalk`?

## Value

A data frame on the target grid, or a list when
`return_crosswalk = TRUE`.

## Examples

``` r
source <- priogrid::pg_config(nrow = 18, ncol = 36)
target <- priogrid::pg_config(nrow = 9, ncol = 18)
x <- data.frame(pgid = c(342, 343, 378, 379), population = rep(10, 4))
pg_change_resolution(
  x, "population", source, target, "extensive"
)
#>   pgid population population_coverage
#> 1   81  10.077138                   1
#> 2   82  10.077138                   1
#> 3   99   9.922862                   1
#> 4  100   9.922862                   1
```
