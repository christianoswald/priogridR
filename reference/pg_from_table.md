# Transfer geographically indexed table data to PRIO-GRID

Transfer geographically indexed table data to PRIO-GRID

## Usage

``` r
pg_from_table(
  x,
  variable,
  value,
  geography,
  source_id,
  geography_id,
  time = NULL,
  time_column = NULL,
  aggregation = c("area_weighted_mean", "area_weighted_sum", "constant"),
  return = c("data", "raster", "result"),
  config = priogrid::pg_current_config(),
  filename = NULL,
  overwrite = FALSE
)
```

## Arguments

- x:

  A data frame containing values.

- variable:

  Name of the resulting variable.

- value:

  Source value-column name.

- geography:

  Polygon geometries defining the source units.

- source_id:

  Identifier column in `x`.

- geography_id:

  Matching identifier column in `geography`.

- time:

  Optional static observation date or year.

- time_column:

  Optional observation-date column.

- aggregation:

  Spatial transfer rule.

- return:

  One of `"data"`, `"raster"`, or `"result"`.

- config:

  A PRIO-GRID configuration object.

- filename:

  Optional output filename.

- overwrite:

  Replace an existing output file?

## Value

A data frame, `SpatRaster`, or `pg_result`.

## Examples

``` r
rectangle <- sf::st_polygon(list(matrix(
  c(5, 45, 15, 45, 15, 55, 5, 55, 5, 45),
  ncol = 2, byrow = TRUE
)))
districts <- sf::st_sf(
  district_id = "A",
  geometry = sf::st_sfc(rectangle, crs = 4326)
)
population <- data.frame(district_id = "A", total = 100000)
config <- priogrid::pg_config(nrow = 18, ncol = 36, verbose = FALSE)
pg_from_table(
  population,
  variable = "population",
  value = "total",
  geography = districts,
  source_id = "district_id",
  geography_id = "district_id",
  aggregation = "area_weighted_sum",
  config = config
)
#>   pgid population
#> 1  487   26308.96
#> 2  488   26308.96
#> 3  523   23691.04
#> 4  524   23691.04
```
