#' Plot PRIO-GRID data
#'
#' Joins a variable to configured cell polygons and creates a publication-ready
#' `ggplot2` map using [pg_theme()].
#'
#' @param data A data frame containing cell IDs and the variable to plot.
#' @param variable Name of the variable to map.
#' @param pg_id Name of the cell-ID column.
#' @param time Optional temporal column name.
#' @param time_value A single temporal value to select when `time` is supplied.
#' @param crs Optional map coordinate reference system.
#' @param na_color Fill color for missing values.
#' @param border_color Cell-border color. Use `NA` for no borders.
#' @param config A PRIO-GRID configuration object.
#' @return A `ggplot` object.
#' @examples
#' config <- priogrid::pg_config(nrow = 2, ncol = 3)
#' x <- data.frame(pgid = 1:6, value = 1:6)
#' pg_plot(x, "value", config = config)
#' @export
pg_plot <- function(
  data,
  variable,
  pg_id = "pgid",
  time = NULL,
  time_value = NULL,
  crs = NULL,
  na_color = "grey90",
  border_color = NA,
  config = priogrid::pg_current_config()
) {
  if (!is.data.frame(data)) {
    stop("`data` must be a data frame.", call. = FALSE)
  }
  validate_variable(variable)
  validate_columns(data, c(pg_id, variable, time))
  if (is.null(time) && !is.null(time_value)) {
    stop("`time_value` requires a `time` column.", call. = FALSE)
  }
  if (!is.null(time)) {
    if (is.null(time_value) || length(time_value) != 1L || is.na(time_value)) {
      stop("Supply one non-missing `time_value` when `time` is used.",
           call. = FALSE)
    }
    data <- data[!is.na(data[[time]]) & data[[time]] == time_value, , drop = FALSE]
    if (!nrow(data)) {
      stop("No rows match `time_value`.", call. = FALSE)
    }
  }
  validation <- pg_validate_data(
    data, pg_id = pg_id, time = NULL, require_unique = TRUE,
    require_complete = FALSE, config = config
  )
  if (!validation$valid) {
    stop("`data` contains invalid or duplicate cell IDs.", call. = FALSE)
  }
  geometry <- pg_geometry(geometry = "polygon", crs = crs, config = config)
  geometry$.pg_value <- data[[variable]][match(geometry$pgid, data[[pg_id]])]
  plot <- ggplot2::ggplot(geometry) +
    ggplot2::geom_sf(ggplot2::aes(fill = .pg_value), color = border_color,
                     linewidth = 0.1) +
    ggplot2::labs(fill = variable) +
    pg_theme()
  if (is.numeric(geometry$.pg_value)) {
    plot <- plot + ggplot2::scale_fill_viridis_c(na.value = na_color)
  } else {
    plot <- plot + ggplot2::scale_fill_viridis_d(na.value = na_color)
  }
  plot
}

utils::globalVariables(".pg_value")
