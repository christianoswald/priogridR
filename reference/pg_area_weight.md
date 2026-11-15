# Transfer cell values to polygons with explicit area weights

Extensive values are allocated by the share of each source cell
overlapping a target and then summed. Intensive values are averaged with
allocation area as the weight. Coverage columns report the share of
relevant weight represented by non-missing observations.

## Usage

``` r
pg_area_weight(
  data,
  crosswalk,
  values,
  target_id,
  variable_type,
  pgid = "pgid",
  time = NULL,
  group = NULL,
  na_rm = FALSE
)
```

## Arguments

- data:

  A data frame containing cell-level values.

- crosswalk:

  A crosswalk created by
  [`pg_crosswalk()`](https://christianoswald.github.io/priogridR/reference/pg_crosswalk.md).

- values:

  Names of numeric value columns.

- target_id:

  Name of the target identifier column in `crosswalk`.

- variable_type:

  `"extensive"` or `"intensive"`. Supply one value for all variables or
  a named vector with one type per value.

- pgid:

  Name of the cell-ID column in `data`.

- time:

  Optional temporal key column.

- group:

  Optional additional grouping columns.

- na_rm:

  Should missing source values be ignored?

## Value

A data frame with target keys, transferred values, and a
`<value>_coverage` diagnostic for every value.

## Examples

``` r
crosswalk <- data.frame(
  pgid = c(1L, 2L), region = "a",
  overlap_area_km2 = c(1, 1), cell_fraction = c(1, 0.5),
  target_fraction = c(0.5, 0.5)
)
x <- data.frame(pgid = 1:2, population = c(10, 20))
pg_area_weight(x, crosswalk, "population", "region", "extensive")
#>   region population population_coverage
#> 1      a         20                   1
```
