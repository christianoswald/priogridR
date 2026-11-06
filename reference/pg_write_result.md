# Write a PRIO-GRID conversion result

Write a PRIO-GRID conversion result

## Usage

``` r
pg_write_result(x, filename, overwrite = FALSE)
```

## Arguments

- x:

  A `pg_result`, `SpatRaster`, or data frame.

- filename:

  Output path. Supported extensions are `.csv`, `.rds`, `.parquet`,
  `.tif`, `.tiff`, and `.vrt`.

- overwrite:

  Replace an existing file?

## Value

`filename`, invisibly.

## Examples

``` r
output <- tempfile(fileext = ".csv")
pg_write_result(data.frame(pgid = 1:3, value = c(2, 4, 1)), output)
utils::read.csv(output)
#>   pgid value
#> 1    1     2
#> 2    2     4
#> 3    3     1
unlink(output)
```
