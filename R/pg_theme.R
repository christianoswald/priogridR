#' A theme for plotting PRIO-GRID data
#'
#' @param legend.position Legend position accepted by [ggplot2::theme()].
#' @return A ggplot2 theme object.
#' @examples
#' ggplot2::ggplot(mtcars, ggplot2::aes(x = hp, y = mpg)) +
#'   ggplot2::geom_point() +
#'   pg_theme()
#' @export
pg_theme <- function(legend.position = "right") {
  ggplot2::theme_light() +
    ggplot2::theme(
      axis.line = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank(),
      axis.title = ggplot2::element_blank(),
      legend.position = legend.position,
      legend.key = ggplot2::element_blank(),
      legend.background = ggplot2::element_blank(),
      plot.background = ggplot2::element_blank(),
      panel.background = ggplot2::element_rect(color = "black", fill = NA),
      panel.border = ggplot2::element_blank(),
      panel.grid.major = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank()
    )
}
