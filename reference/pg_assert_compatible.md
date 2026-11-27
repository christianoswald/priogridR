# Assert compatibility of PRIO-GRID objects

Checks all requested compatibility dimensions and reports detected
problems together rather than stopping at the first mismatch.

## Usage

``` r
pg_assert_compatible(
  ...,
  check = c("grid", "crs", "time", "keys"),
  config = NULL,
  id = "pgid",
  time = NULL
)
```

## Arguments

- ...:

  Two or more data frames, `pg_result` objects, rasters, or
  configurations.

- check:

  Compatibility dimensions to check.

- config:

  Optional configuration applied to objects lacking retained grid
  metadata.

- id:

  Cell identifier column for data frames.

- time:

  Optional temporal column.

## Value

A compatibility report, invisibly. Incompatible inputs raise an error.

## Examples

``` r
config <- priogrid::pg_config(nrow = 2, ncol = 3, verbose = FALSE)
x <- data.frame(pgid = 1:3, value = 1:3)
y <- data.frame(pgid = 4:6, value = 4:6)
pg_assert_compatible(x, y, config = config)
```
