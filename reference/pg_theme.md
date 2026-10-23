# A theme for plotting PRIO-GRID data

A theme for plotting PRIO-GRID data

## Usage

``` r
pg_theme(legend.position = "right")
```

## Arguments

- legend.position:

  Legend position accepted by
  [`ggplot2::theme()`](https://ggplot2.tidyverse.org/reference/theme.html).

## Value

A ggplot2 theme object.

## Examples

``` r
ggplot2::ggplot(mtcars, ggplot2::aes(x = hp, y = mpg)) +
  ggplot2::geom_point() +
  pg_theme()
```
