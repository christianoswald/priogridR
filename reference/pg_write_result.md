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
