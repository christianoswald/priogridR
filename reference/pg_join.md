# Safely join PRIO-GRID data

Joins two data frames after checking key completeness and the expected
key relationship. This prevents accidental many-to-many expansion.

## Usage

``` r
pg_join(
  x,
  y,
  by = NULL,
  join = c("left", "inner", "full"),
  relationship = c("many-to-one", "one-to-one", "one-to-many", "many-to-many"),
  unmatched = c("keep", "error"),
  suffix = c(".x", ".y")
)
```

## Arguments

- x, y:

  Data frames to join.

- by:

  Character vector of join columns. If `NULL`, conventional PRIO-GRID
  and temporal column names are inferred.

- join:

  One of `"left"`, `"inner"`, or `"full"`.

- relationship:

  Expected key relationship between `x` and `y`.

- unmatched:

  Keep unmatched rows where the join permits them, or raise an error
  when either input has unmatched keys.

- suffix:

  Suffixes for overlapping non-key column names.

## Value

A joined data frame.

## Examples

``` r
x <- data.frame(pgid = 1:3, outcome = c(0, 1, 0))
y <- data.frame(pgid = 1:3, exposure = c(2, 4, 1))
pg_join(x, y)
#>   pgid outcome exposure
#> 1    1       0        2
#> 2    2       1        4
#> 3    3       0        1
```
