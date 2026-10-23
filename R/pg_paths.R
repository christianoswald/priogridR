#' Construct standard project data paths
#'
#' @param root Root directory of a data project.
#' @param raw,processed,temporary Relative subdirectory names.
#' @param create Create missing subdirectories?
#' @return A named list of normalized paths.
#' @export
pg_paths <- function(
  root = ".",
  raw = "data/raw",
  processed = "data/processed",
  temporary = "data/temp",
  create = FALSE
) {
  root <- normalizePath(root, winslash = "/", mustWork = FALSE)
  paths <- list(
    root = root,
    raw = file.path(root, raw),
    processed = file.path(root, processed),
    temporary = file.path(root, temporary)
  )
  if (isTRUE(create)) {
    invisible(lapply(
      paths[c("raw", "processed", "temporary")],
      dir.create,
      recursive = TRUE,
      showWarnings = FALSE
    ))
  }
  paths
}

