#' @title pgtheme
#' @description Provides a theme for plotting PRIO-GRID.
#'
#' @param x The GID to the cell that you would like to find the neighbors of.
#' @param ncol The number of columns in the grid.
#' @param nrow The number of rows in the grid.
#' @return A ggplot theme object
#' @importFrom ggplot2 "theme_light" "theme"
#' @examples
#' pg <- create_pg_indices(5, 5)
#' pgneighbors(1, ncol=5, nrow=5)
pgtheme <- function() {
  ggplot2::theme_light() +
    ggplot2::theme(plot.background = ggplot2::element_blank(),
                   panel.grid.major = ggplot2::element_blank(),
                   panel.grid.minor = ggplot2::element_blank(),
                   panel.border = ggplot2::element_blank(),
                   legend.position = c(.12, .19),
                   legend.key = ggplot2::element_blank(),
                   legend.background = ggplot2::element_blank())
}
