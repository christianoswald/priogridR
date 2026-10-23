validate_variable <- function(variable) {
  if (!is.character(variable) || length(variable) != 1L ||
      is.na(variable) || !nzchar(variable)) {
    stop("`variable` must be one non-empty character string.", call. = FALSE)
  }
  if (make.names(variable) != variable) {
    stop("`variable` must be a syntactically valid R name.", call. = FALSE)
  }
  invisible(variable)
}

validate_choice <- function(x, choices, argument) {
  if (!is.character(x) || length(x) != 1L || is.na(x) || !x %in% choices) {
    stop(
      "`", argument, "` must be one of: ",
      paste(choices, collapse = ", "), ".",
      call. = FALSE
    )
  }
  invisible(x)
}

validate_columns <- function(x, columns) {
  columns <- unlist(columns, use.names = FALSE)
  columns <- columns[!is.na(columns) & nzchar(columns)]
  missing_columns <- setdiff(columns, names(x))
  if (length(missing_columns)) {
    stop("Missing columns: ", paste(missing_columns, collapse = ", "), call. = FALSE)
  }
  invisible(columns)
}

validate_output_path <- function(filename, overwrite = FALSE) {
  if (!is.character(filename) || length(filename) != 1L ||
      is.na(filename) || !nzchar(filename)) {
    stop("`filename` must be one non-empty file path.", call. = FALSE)
  }
  if (file.exists(filename) && !isTRUE(overwrite)) {
    stop(
      "The output file already exists. Set `overwrite = TRUE` to replace it.",
      call. = FALSE
    )
  }
  invisible(filename)
}

validate_pg_config <- function(config) {
  if (!inherits(config, "pg_config")) {
    stop(
      "`config` must be a `pg_config` object created by `priogrid::pg_config()`.",
      call. = FALSE
    )
  }
  invisible(config)
}

