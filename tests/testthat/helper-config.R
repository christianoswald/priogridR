test_config <- function() {
  priogrid::pg_config(
    nrow = 18,
    ncol = 36,
    start_date = as.Date("2000-12-31"),
    end_date = as.Date("2001-12-31"),
    temporal_resolution = "1 year"
  )
}

