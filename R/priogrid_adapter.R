pg_blank <- function(config = priogrid::pg_current_config()) {
  validate_pg_config(config)
  priogrid::prio_blank_grid(config = config)
}

pg_grid_as_sf <- function(config = priogrid::pg_current_config()) {
  blank <- pg_blank(config)
  grid <- sf::st_as_sf(terra::as.polygons(blank, values = TRUE, na.rm = TRUE))
  names(grid)[1L] <- "pgid"
  grid
}

transform_raster_to_pg <- function(
  raster,
  aggregation,
  disagg_method = "near",
  config = priogrid::pg_current_config(),
  ...
) {
  validate_pg_config(config)
  priogrid::robust_transformation(
    r = raster,
    agg_fun = aggregation,
    disagg_method = disagg_method,
    config = config,
    ...
  )
}

raster_to_pg_data <- function(
  raster,
  variable,
  time = NULL,
  config = priogrid::pg_current_config()
) {
  validate_pg_config(config)
  if (is.null(time)) {
    if (terra::nlyr(raster) != 1L) {
      stop("A raster without `time` must have exactly one layer.", call. = FALSE)
    }
    names(raster) <- variable
    return(as.data.frame(priogrid::rast_to_df(
      rast = raster,
      static = TRUE,
      config = config
    )))
  }
  names(raster) <- format(time, "%Y-%m-%d")
  as.data.frame(priogrid::rast_to_df(
    rast = raster,
    static = FALSE,
    varname = variable,
    config = config
  ))
}

