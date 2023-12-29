#' Get first order neighbors in PRIO-GRID.
#' TODO: does this work as cell2nb in spdep? Must probably map to PG indices?
#'
#' @param x The GID to the cell that you would like to find the neighbors of.
#' @param ncol The number of columns in the grid.
#' @param nrow The number of rows in the grid.
#' @return If asmat=TRUE: A matrix of the neighbors, If asmat=FALSE: A vector of the neighbors.
#' @examples
#' pg <- create_pg_indices(5, 5)
#' pgneighbors(1, ncol=5, nrow=5)
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
