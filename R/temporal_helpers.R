validate_temporal_panel <- function(
  data,
  value = NULL,
  pgid = "pgid",
  time = "measurement_date",
  group = NULL,
  numeric_value = FALSE,
  config = priogrid::pg_current_config()
) {
  if (!is.data.frame(data)) {
    stop("`data` must be a data frame.", call. = FALSE)
  }
  validate_variable(pgid)
  validate_variable(time)
  if (length(group) &&
      (!is.character(group) || anyNA(group) || any(!nzchar(group)))) {
    stop("`group` must contain column names.", call. = FALSE)
  }
  if (anyDuplicated(group)) {
    stop("`group` must not contain duplicate column names.", call. = FALSE)
  }
  validate_columns(data, c(pgid, time, group, value))
  validate_pgid_values(data[[pgid]], pgid, config)
  keys <- c(pgid, group, time)
  if (any(!stats::complete.cases(data[keys]))) {
    stop("Temporal panel keys must not contain missing values.", call. = FALSE)
  }
  if (anyDuplicated(data[keys])) {
    stop("`data` contains duplicate cell-time keys.", call. = FALSE)
  }
  if (!is.null(value)) {
    validate_variable(value)
    if (numeric_value && !is.numeric(data[[value]])) {
      stop("`value` must identify a numeric column.", call. = FALSE)
    }
  }
  order_args <- c(data[c(pgid, group, time)], list(na.last = TRUE))
  ordered_rows <- do.call(order, order_args)
  grouping <- c(pgid, group)
  group_key <- do.call(
    interaction,
    c(
      data[ordered_rows, grouping, drop = FALSE],
      list(drop = TRUE, lex.order = TRUE)
    )
  )
  rows <- split(ordered_rows, group_key, drop = TRUE)
  list(rows = unname(rows), keys = keys)
}

validate_periods <- function(periods, argument = "periods") {
  if (!is.numeric(periods) || length(periods) != 1L || is.na(periods) ||
      !is.finite(periods) || periods < 1 || periods %% 1 != 0) {
    stop("`", argument, "` must be one positive integer.", call. = FALSE)
  }
  as.integer(periods)
}

temporal_shift_values <- function(x, rows, periods = 1L, direction = "lag") {
  periods <- validate_periods(periods)
  output <- x[rep(NA_integer_, length(x))]
  for (index in rows) {
    n <- length(index)
    if (n <= periods) next
    if (direction == "lag") {
      output[index[(periods + 1L):n]] <- x[index[seq_len(n - periods)]]
    } else {
      output[index[seq_len(n - periods)]] <- x[index[(periods + 1L):n]]
    }
  }
  output
}

validate_new_column <- function(data, name) {
  validate_variable(name)
  if (name %in% names(data)) {
    stop("Output column `", name, "` already exists.", call. = FALSE)
  }
  invisible(name)
}

rolling_bounds <- function(position, n, window, align) {
  if (align == "right") {
    c(max(1L, position - window + 1L), position)
  } else if (align == "left") {
    c(position, min(n, position + window - 1L))
  } else {
    left <- floor((window - 1L) / 2L)
    right <- window - 1L - left
    c(max(1L, position - left), min(n, position + right))
  }
}

apply_rolling_function <- function(x, fun, na_rm) {
  if (!na_rm && anyNA(x)) return(NA_real_)
  x <- x[!is.na(x)]
  if (!length(x)) return(NA_real_)
  switch(
    fun,
    mean = mean(x),
    sum = sum(x),
    min = min(x),
    max = max(x),
    median = stats::median(x),
    sd = if (length(x) < 2L) NA_real_ else stats::sd(x)
  )
}
