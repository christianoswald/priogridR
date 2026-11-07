# Construct standard project data paths

Construct standard project data paths

## Usage

``` r
pg_paths(
  root = ".",
  raw = "data/raw",
  processed = "data/processed",
  temporary = "data/temp",
  create = FALSE
)
```

## Arguments

- root:

  Root directory of a data project.

- raw, processed, temporary:

  Relative subdirectory names.

- create:

  Create missing subdirectories?

## Value

A named list of normalized paths.

## Examples

``` r
pg_paths(root = tempdir())
#> $root
#> [1] "/tmp/RtmpXV8zuW"
#> 
#> $raw
#> [1] "/tmp/RtmpXV8zuW/data/raw"
#> 
#> $processed
#> [1] "/tmp/RtmpXV8zuW/data/processed"
#> 
#> $temporary
#> [1] "/tmp/RtmpXV8zuW/data/temp"
#> 

example_root <- file.path(tempdir(), "priogridR-project")
pg_paths(root = example_root, create = TRUE)
#> $root
#> [1] "/tmp/RtmpXV8zuW/priogridR-project"
#> 
#> $raw
#> [1] "/tmp/RtmpXV8zuW/priogridR-project/data/raw"
#> 
#> $processed
#> [1] "/tmp/RtmpXV8zuW/priogridR-project/data/processed"
#> 
#> $temporary
#> [1] "/tmp/RtmpXV8zuW/priogridR-project/data/temp"
#> 
```
