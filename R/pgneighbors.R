#' @title pgneighbors
#' @description Provides a function to get first order neighbors in PRIO-GRID.
#'
#' @param x The GID to the cell you would like to find the neighbors of.
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
pgneighbors <- function(x){

  ## things to keep in mind, for this work:
  ## the neighbor above a given cell has a gid of +360 (the max number of columns)
  ## the neighbor below a given call has a gid of -360 (the max number of columns)

  ## the standard prio-grid has 720 columns and 360 rows
  ## this can be adjusted later once we have aggregated cells such that it fits with new cell id's
  pgrid <- create_pg_indices(360, 720)

  ## cell is in topleft corner
  if (x == pgrid[1,1]) {
    upperleft <- ncol(pgrid) #258481 -> 720
    uppermiddle <- pgrid[nrow(pgrid),1] # 258481 -> 1
    upperright <- pgrid[nrow(pgrid),2] #258481 -> 2
    middleleft <- nrow(pgrid) * ncol(pgrid) #258481 -> 259200
    middleright <- x + 1
    lowerleft <- x - 1 #258481 -> 258480
    lowermiddle <- x - ncol(pgrid)
    lowerright <- x - ncol(pgrid) + 1
    ## cell is in topright corner
  } else if (x == pgrid[1,ncol(pgrid)]) {
    upperleft <- ncol(pgrid) - 1 # 259200 -> 719
    uppermiddle <- ncol(pgrid) # 259200 -> 720
    upperright <- pgrid[nrow(pgrid),1] # 259200 -> 1
    middleleft <- x - 1
    middleright <- x + 1 # 259200 -> 258481
    lowerleft <- x - ncol(pgrid) - 1
    lowermiddle <- x - ncol(pgrid)
    lowerright <- x - ncol(pgrid) + 1 # 259200 -> 257761
    ## cell is in bottomleft corner
  } else if (x == pgrid[nrow(pgrid),1]) {
    upperleft <- pgrid[nrow(pgrid)-1,ncol(pgrid)] # 1 -> pgrid[nrow()-1,ncol]
    uppermiddle <- x + ncol(pgrid)
    upperright <- x + ncol(pgrid) + 1
    middleleft <- pgrid[nrow(pgrid), ncol(pgrid)] # 1 -> 720 [pgrid[720, 360]]
    middleright <- x + 1
    lowerleft <- pgrid[1, ncol(pgrid)] # 1 -> 259200 (topright) pgrid[1,720]
    lowermiddle <- pgrid[1,1] # 1 -> 258481 (topleft) pgrid[1,1]
    lowerright <- pgrid[1,2] # 1 -> 258481 pgrid[1,2]
    ## cell is in bottomright corner
  } else if (x == pgrid[nrow(pgrid),ncol(pgrid)]) {
    upperleft <- x + ncol(pgrid) - 1
    uppermiddle <- x + ncol(pgrid)
    upperright <- pgrid[nrow(pgrid)-1,1] # 720 -> 721
    middleleft <- x - 1
    middleright <- pgrid[nrow(pgrid),1] # 720 -> 1
    lowerleft <- pgrid[1, ncol(pgrid)-1] # 720 ->
    lowermiddle <- pgrid[1, ncol(pgrid)] # 720 ->
    lowerright <- pgrid[1,1] # 720 ->
    ## cell is in bottom row
  } else if (x %in% pgrid[nrow(pgrid),]) {
    upperleft <- x + ncol(pgrid) - 1
    uppermiddle <- x + ncol(pgrid)
    upperright <- x + ncol(pgrid) + 1
    middleleft <- x - 1
    middleright <- x + 1
    lowerleft <- x + (nrow(pgrid)*(ncol(pgrid)-2)) - 1
    lowermiddle <- x + (nrow(pgrid)*(ncol(pgrid)-2))
    lowerright <- x + (nrow(pgrid)*(ncol(pgrid)-2)) + 1
    ## cell is in top row
  } else if (x %in% pgrid[1,]) {
    upperleft <- x - (nrow(pgrid)*(ncol(pgrid)-2)) - 1
    uppermiddle <- x - (nrow(pgrid)*(ncol(pgrid)-2))
    upperright <- x - (nrow(pgrid)*(ncol(pgrid)-2)) + 1
    middleleft <- x - 1
    middleright <- x + 1
    lowerleft <- x - ncol(pgrid) - 1
    lowermiddle <- x - ncol(pgrid)
    lowerright <- x - ncol(pgrid) + 1
    ## cell is in leftmost column
  } else if (x %in% pgrid[,1]) {
    upperleft <- x + 2*ncol(pgrid) - 1 # 721 -> 2160 2*ncol(pgrid)-1
    uppermiddle <- x + ncol(pgrid)
    upperright <- x + ncol(pgrid) + 1
    middleleft <- x + ncol(pgrid)-1 # 721 -> 1440 ncol(pgrid)-1
    middleright <- x + 1
    lowerleft <- x - 1 # 721 -> 720
    lowermiddle <- x - ncol(pgrid)
    lowerright <- x - ncol(pgrid) + 1
    ## cell is in rightmost column
  } else if (x %in% pgrid[,ncol(pgrid)]) {
    upperleft <- x + ncol(pgrid) - 1
    uppermiddle <- x + ncol(pgrid)
    upperright <- x + 1 # 1440 -> 1441
    middleleft <- x - 1
    middleright <- x - ncol(pgrid) + 1 # 1440 -> 721
    lowerleft <- x - ncol(pgrid) - 1
    lowermiddle <- x - ncol(pgrid)
    lowerright <- x - 2*ncol(pgrid) + 1 # 1440 -> 1
    ## no top/bottom row or leftmost/rightmost column involved
  } else {
    upperleft <- x + ncol(pgrid) - 1
    uppermiddle <- x + ncol(pgrid)
    upperright <- x + ncol(pgrid) + 1
    middleleft <- x - 1
    middleright <- x + 1
    lowerleft <- x - ncol(pgrid) - 1
    lowermiddle <- x - ncol(pgrid)
    lowerright <- x - ncol(pgrid) + 1
  }
  out <- c(upperleft, uppermiddle, upperright, middleleft, middleright, lowerleft, lowermiddle, lowerright)

  return(out)
}
