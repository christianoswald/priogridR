test_that("variable names are validated before GIS work", {
  expect_error(priogridR:::validate_variable("not valid"), "syntactically valid")
  expect_error(priogridR:::validate_variable(character()), "non-empty")
})

test_that("missing columns are reported", {
  expect_error(
    priogridR:::validate_columns(data.frame(x = 1), "y"),
    "Missing columns: y"
  )
})

