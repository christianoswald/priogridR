#' @title pgneighbors
#' @description Provides a function to get first order neighbors in PRIO-GRID.
#'
#' @param x The GID to the cell you would like to find the neighbors of.
#' @param ncol The number of columns in the grid.
#' @param nrow The number of rows in the grid.
#' @return A vector of the neighbors.
#' @examples
#' dat <- as.data.frame(matrix(nrow = 9, ncol = 3))
#' dat[,1] <- c(234534, 234535, 234536,
#'              234208, 234209, 234210,
#'              233882, 233883, 233884)
#' dat[,2] <- c(534, 535, 536,
#'              208, 209, 2010,
#'              602, 603, 604)
#' dat[,3] <- c(326, 326, 326,
#'              326, 326, 326,
#'              325, 325, 325)
#' pgneighbors(234209, ncol = 209, nrow = 326)
pgneighbors <- function(x, ncol, nrow){

  farright <- ncol*1:nrow
  farleft <- c(1, farright[-length(farright)]+1)
  toprow <- ncol*nrow - ncol:1 + 1
  bottomrow <- 1:ncol

  #all(farleft + ncol-1 == farright
  if (x %in% farright){
    # x on the far right side
    uppern <- c(x+ncol-1, x+ncol, x+1)
    midn <- c(x-1, x-ncol+1)
    lown <- c(x-ncol-1, x-ncol, x-(2*ncol)+1)
  } else if (x %in% farleft){
    # x on the far left side
    uppern <- c(x+(2*ncol)-1, x+ncol, x+ncol+1)
    midn <- c(x+ncol-1, x+1)
    lown <- c(x-1, x-ncol, x-ncol+1)
  } else {
    uppern <- c(x+ncol-1, x+ncol, x+ncol+1)
    midn <- c(x-1, x+1)
    lown <- c(x-ncol-1, x-ncol, x-ncol+1)
  }

    if(x %in% toprow){
      return(c(midn, lown))
    } else if(x %in% bottomrow){
      return(c(uppern, midn))
    } else{
      return(c(uppern, midn, lown))
    }
}
