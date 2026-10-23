read_raster_input <- function(x) {
  if (inherits(x, "SpatRaster")) {
    return(x)
  }
  if (!is.character(x) || !length(x)) {
    stop("`x` must be a SpatRaster or one or more raster file paths.", call. = FALSE)
  }
  missing_files <- x[!file.exists(x)]
  if (length(missing_files)) {
    stop("Raster files do not exist: ", paste(missing_files, collapse = ", "), call. = FALSE)
  }
  terra::rast(x)
}

read_vector_input <- function(x) {
  if (inherits(x, "sf")) {
    return(x)
  }
  if (inherits(x, "SpatVector")) {
    return(sf::st_as_sf(x))
  }
  if (!is.character(x) || length(x) != 1L) {
    stop("`x` must be an sf object, SpatVector, or one vector-file path.", call. = FALSE)
  }
  if (!file.exists(x)) {
    stop("The vector file does not exist: ", x, call. = FALSE)
  }
  sf::st_read(x, quiet = TRUE)
}

as_point_sf <- function(
  x,
  longitude = NULL,
  latitude = NULL,
  input_crs = 4326
) {
  if (inherits(x, "sf")) {
    return(x)
  }
  if (inherits(x, "SpatVector")) {
    return(sf::st_as_sf(x))
  }
  if (is.character(x) && length(x) == 1L && file.exists(x)) {
    return(read_vector_input(x))
  }
  if (!is.data.frame(x)) {
    stop(
      "`x` must be a data frame, sf object, SpatVector, or vector-file path.",
      call. = FALSE
    )
  }
  if (is.null(longitude) || is.null(latitude)) {
    stop(
      "`longitude` and `latitude` are required when `x` is a data frame.",
      call. = FALSE
    )
  }
  validate_columns(x, c(longitude, latitude))
  sf::st_as_sf(
    x,
    coords = c(longitude, latitude),
    crs = input_crs,
    remove = FALSE
  )
}

detect_geometry_type <- function(x) {
  geometry <- unique(as.character(sf::st_geometry_type(x)))
  if (!length(geometry)) {
    stop("The vector input contains no geometries.", call. = FALSE)
  }
  if (all(geometry %in% c("POINT", "MULTIPOINT"))) {
    return("point")
  }
  if (all(geometry %in% c("LINESTRING", "MULTILINESTRING"))) {
    return("line")
  }
  if (all(geometry %in% c("POLYGON", "MULTIPOLYGON"))) {
    return("polygon")
  }
  stop(
    "Unsupported or mixed geometry types: ", paste(geometry, collapse = ", "),
    call. = FALSE
  )
}
