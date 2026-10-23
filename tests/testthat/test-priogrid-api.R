test_that("required PRIO-GRID functions are exported", {
  exports <- getNamespaceExports("priogrid")
  expect_true(all(c(
    "pg_current_config",
    "pg_config",
    "pg_date_intervals",
    "prio_blank_grid",
    "rast_to_df",
    "robust_transformation"
  ) %in% exports))
})

test_that("the adapter matches the released robust_transformation formals", {
  arguments <- names(formals(priogrid::robust_transformation))
  expect_true(all(c("r", "agg_fun", "disagg_method", "config") %in% arguments))
})

