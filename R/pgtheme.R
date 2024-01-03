#' @title pgtheme
#' @description Provides a theme for plotting PRIO-GRID.
#'
#' @param legend.position Specify where you want to have the legend. Examples include c(.12, .19), "bottom", "right", and so on.
#' @return A ggplot theme object
#' @importFrom ggplot2 "theme_light" "theme"
#' @examples
#' ggplot2::ggplot(mtcars, ggplot2::aes(x = hp, y = mpg)) +
#' ggplot2::geom_point() +
#' pgtheme()
pgtheme <- function(legend.position) {
  ggplot2::theme_light() +
    ggplot2::theme(axis.line = ggplot2::element_blank(),
                   axis.ticks = ggplot2::element_blank(),
                   axis.title = ggplot2::element_blank(),
                   legend.position = legend.position,
                   legend.key = ggplot2::element_blank(),
                   legend.background = ggplot2::element_blank(),
                   plot.background = ggplot2::element_blank(),
                   panel.background = ggplot2::element_rect(color = "black"),
                   panel.border = ggplot2::element_blank(),
                   panel.grid.major = ggplot2::element_blank(),
                   panel.grid.minor = ggplot2::element_blank())
}
