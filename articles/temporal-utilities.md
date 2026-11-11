# Temporal utilities for PRIO-GRID panels

``` r

library(priogridR)
```

The temporal utilities operate within PRIO-GRID cells, order
observations by an explicit time column, and return rows in their
original order. Optional grouping columns can separate scenarios,
sources, or other repeated panels.

``` r

config <- priogrid::pg_config(nrow = 2, ncol = 3, verbose = FALSE)

panel <- data.frame(
  pgid = rep(1:2, each = 5),
  year = rep(2018:2022, 2),
  events = c(0, 1, 3, 0, 2, 5, 4, 6, 8, 7),
  onset = c(FALSE, TRUE, FALSE, FALSE, TRUE,
            FALSE, FALSE, TRUE, FALSE, FALSE)
)
```

## Lags and leads

[`pg_temporal_lag()`](https://christianoswald.github.io/priogridR/reference/pg_temporal_lag.md)
and
[`pg_temporal_lead()`](https://christianoswald.github.io/priogridR/reference/pg_temporal_lead.md)
shift observations only within the same cell. The first lag and final
lead in each cell are therefore missing.

``` r

lagged <- pg_temporal_lag(
  panel, value = "events", time = "year", config = config
)

shifted <- pg_temporal_lead(
  lagged, value = "events", time = "year", config = config
)

shifted[c("pgid", "year", "events", "events_lag1", "events_lead1")]
#>    pgid year events events_lag1 events_lead1
#> 1     1 2018      0          NA            1
#> 2     1 2019      1           0            3
#> 3     1 2020      3           1            0
#> 4     1 2021      0           3            2
#> 5     1 2022      2           0           NA
#> 6     2 2018      5          NA            4
#> 7     2 2019      4           5            6
#> 8     2 2020      6           4            8
#> 9     2 2021      8           6            7
#> 10    2 2022      7           8           NA
```

Set `periods` to a positive integer for longer shifts. Use `group` when
a cell contains several independent sequences, such as alternative
scenarios.

## Changes

[`pg_temporal_change()`](https://christianoswald.github.io/priogridR/reference/pg_temporal_change.md)
provides ordinary differences, percentage changes, and log differences.
Percentage changes are missing when the earlier value is zero. Log
differences are missing unless both values are strictly positive.

``` r

pg_temporal_change(
  panel,
  value = "events",
  time = "year",
  type = "difference",
  config = config
)[c("pgid", "year", "events", "events_difference")]
#>    pgid year events events_difference
#> 1     1 2018      0                NA
#> 2     1 2019      1                 1
#> 3     1 2020      3                 2
#> 4     1 2021      0                -3
#> 5     1 2022      2                 2
#> 6     2 2018      5                NA
#> 7     2 2019      4                -1
#> 8     2 2020      6                 2
#> 9     2 2021      8                 2
#> 10    2 2022      7                -1
```

## Rolling summaries

Rolling windows may be trailing (`"right"`), centered, or forward
(`"left"`). `min_obs` controls how many non-missing values are required,
while `na_rm` determines whether missing values invalidate an otherwise
sufficiently populated window.

``` r

rolled <- pg_rolling_summary(
  panel,
  value = "events",
  time = "year",
  window = 3,
  fun = "mean",
  align = "right",
  min_obs = 2,
  na_rm = TRUE,
  config = config
)

rolled[c("pgid", "year", "events", "events_rolling_mean_3")]
#>    pgid year events events_rolling_mean_3
#> 1     1 2018      0                    NA
#> 2     1 2019      1              0.500000
#> 3     1 2020      3              1.333333
#> 4     1 2021      0              1.333333
#> 5     1 2022      2              1.666667
#> 6     2 2018      5                    NA
#> 7     2 2019      4              4.500000
#> 8     2 2020      6              5.000000
#> 9     2 2021      8              6.000000
#> 10    2 2022      7              7.000000
```

## Time since an event

[`pg_time_since()`](https://christianoswald.github.io/priogridR/reference/pg_time_since.md)
resets to zero whenever an event occurs. Rows before the first event in
each cell remain missing.

``` r

elapsed <- pg_time_since(
  panel,
  event = "onset",
  time = "year",
  units = "periods",
  config = config
)

elapsed[c("pgid", "year", "onset", "onset_time_since")]
#>    pgid year onset onset_time_since
#> 1     1 2018 FALSE               NA
#> 2     1 2019  TRUE                0
#> 3     1 2020 FALSE                1
#> 4     1 2021 FALSE                2
#> 5     1 2022  TRUE                0
#> 6     2 2018 FALSE               NA
#> 7     2 2019 FALSE               NA
#> 8     2 2020  TRUE                0
#> 9     2 2021 FALSE                1
#> 10    2 2022 FALSE                2
```

For irregularly spaced `Date` or `POSIXt` observations, use
`units = "days"` to calculate elapsed calendar days.

## Row-based versus calendar-complete periods

Shifts and rolling windows are deliberately row based. If a cell has
records for 2018 and 2020 but not 2019, its one-row lag treats 2018 as
the previous observation. This avoids silently inventing observations or
choosing values for structural gaps.

When a lag or window must correspond to consecutive configured periods,
complete the panel first:

``` r

incomplete <- panel[!(panel$pgid == 1 & panel$year == 2020), ]

complete <- pg_complete_panel(
  incomplete,
  time = "year",
  cells = 1:2,
  times = 2018:2022,
  config = config
)

pg_temporal_lag(
  complete, value = "events", time = "year", config = config
)
#>    pgid year events onset events_lag1
#> 1     1 2018      0 FALSE          NA
#> 2     2 2018      5 FALSE          NA
#> 3     1 2019      1  TRUE           0
#> 4     2 2019      4 FALSE           5
#> 5     1 2020     NA    NA           1
#> 6     2 2020      6  TRUE           4
#> 7     1 2021      0 FALSE          NA
#> 8     2 2021      8 FALSE           6
#> 9     1 2022      2  TRUE           0
#> 10    2 2022      7 FALSE           8
```

The introduced row retains a missing value unless a substantively
justified fill rule is supplied to
[`pg_complete_panel()`](https://christianoswald.github.io/priogridR/reference/pg_complete_panel.md).
