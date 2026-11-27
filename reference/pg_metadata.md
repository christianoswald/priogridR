# Inspect PRIO-GRID metadata

Returns standardized spatial, temporal, variable, and provenance
metadata without inventing information that is unavailable from the
object.

## Usage

``` r
pg_metadata(x, config = NULL, id = "pgid", time = NULL)

# S3 method for class 'pg_metadata'
print(x, ...)
```

## Arguments

- x:

  A `pg_result`, data frame, `SpatRaster`, or `pg_config` object.

- config:

  Optional PRIO-GRID configuration used to describe a data frame or to
  supplement an object that does not retain configuration metadata.

- id:

  Cell identifier column for data-frame inputs.

- time:

  Optional temporal column. A unique conventional temporal column is
  detected when omitted.

- ...:

  Additional arguments, currently unused.

## Value

A structured `pg_metadata` list.

## Examples

``` r
config <- priogrid::pg_config(nrow = 2, ncol = 3, verbose = FALSE)
x <- data.frame(pgid = 1:6, value = seq_len(6))
pg_metadata(x, config = config)
#> <pg_metadata>
#>   Object: data.frame
#>   Grid: 2 x 3 (6 cells)
#>   Variables: value
```
