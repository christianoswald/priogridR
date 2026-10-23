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
