#' @title pgtheme
#' @description Provides a theme for plotting PRIO-GRID.
#'
#' @param legend.position Specify where you want to have the legend. Examples include c(.12, .19), "bottom", "right", and so on.
#' @return A ggplot theme object
#' @importFrom ggplot2 "theme_light" "theme"
#' @examples
#' pg <- create_pg_indices(5, 5)
#' pgneighbors(1, ncol=5, nrow=5)
pgtheme <- function(legend.position) {
  ggplot2::theme_light() +
    ggplot2::theme(plot.background = ggplot2::element_blank(),
                   panel.grid.major = ggplot2::element_blank(),
                   panel.grid.minor = ggplot2::element_blank(),
                   panel.border = ggplot2::element_blank(),
                   legend.position = legend.position,
                   legend.key = ggplot2::element_blank(),
                   legend.background = ggplot2::element_blank())
}
