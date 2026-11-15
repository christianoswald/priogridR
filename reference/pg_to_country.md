# Aggregate PRIO-GRID values to supplied country boundaries

Builds a reproducible cell-to-country crosswalk from user-supplied
country polygons and transfers values using explicit extensive or
intensive semantics. Supplying boundaries keeps the territorial
definition and date under the researcher's control. A single boundary
definition is used per call; historical panels with changing borders
should be processed by boundary vintage and then combined explicitly.

## Usage

``` r
pg_to_country(
  data,
  countries,
  country_id,
  values,
  variable_type,
  pgid = "pgid",
  time = NULL,
  group = NULL,
  assignment = c("fractional", "largest", "centroid"),
  na_rm = FALSE,
  return_crosswalk = FALSE,
  config = priogrid::pg_current_config()
)
```

## Arguments

- data:

  A data frame containing cell-level values.

- countries:

  An `sf` object containing country polygons.

- country_id:

  Name of the country identifier column.

- values:

  Names of numeric value columns.

- variable_type:

  `"extensive"` or `"intensive"`, either once for all variables or as a
  named vector.

- pgid:

  Name of the cell-ID column in `data`.

- time:

  Optional temporal key column.

- group:

  Optional additional grouping columns.

- assignment:

  Cell assignment method passed to
  [`pg_crosswalk()`](https://christianoswald.github.io/priogridR/reference/pg_crosswalk.md).

- na_rm:

  Should missing source values be ignored?

- return_crosswalk:

  Return only the aggregated data or a list containing both `data` and
  the generated `crosswalk`?

- config:

  A PRIO-GRID configuration object.

## Value

A data frame, or a list when `return_crosswalk = TRUE`.

## Examples

``` r
config <- priogrid::pg_config(nrow = 18, ncol = 36)
countries <- pg_geometry(342:344, config = config)
countries$country <- c("a", "a", "b")
x <- data.frame(pgid = 342:344, population = c(10, 20, 30))
pg_to_country(
  x, countries, "country", "population", "extensive",
  config = config
)
#>   country population population_coverage
#> 1       a         30                   1
#> 2       b         30                   1
```
