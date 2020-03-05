#' Identify clusters that do not have a minimum number of nodes
#'
#' This function identifies clusters that do not have a specified minimum number
#' of nodes, and can optionally remove them from the network data.frame.
#'
#' @param df the network data.frame, usually issued from
#' \code{\link{readInfomapTree}}
#' @param column column name of the level that you want to analyse
#' @param limit a numeric indicating the minimum number of nodes that separates
#' clusters above the limit from below the limit. Clusters must have a number of
#' nodes strictly superior to \code{limit} to be above.
#' @param rename \code{TRUE} or \code{FALSE}. If \code{TRUE}, then
#' the function will return a data.frame where clusters below \code{limit} have 
#' been renamed to "small.clusters"
#' @param remove.clusters \code{TRUE} or \code{FALSE}. If \code{TRUE}, then
#' the function will return a data.frame without clusters below \code{limit}
#' @export
#' @return If \code{remove.clusters = TRUE}, a subset of \code{df} will be
#' returned without all nodes below the specified \code{limit}
#' @author
#' Boris Leroy \email{leroy.boris@@gmail.com}
#' @examples
#'
#'
#'
#' @export
clustersBelowLimit <- function(df, column, limit, rename = FALSE, remove.clusters = FALSE)
{
  clustersbelowlimit <- which(sapply(levels(df[, column]),
                                     FUN = function(x, y) length(na.omit(y[y == x])),
                                     y = df[, column]) < limit)
  
  if(length(clustersbelowlimit))
  {

    a <- droplevels(df[which(df[, column] %in% clustersbelowlimit), ])
    message(paste(length(levels(a[, column])), " clusters are below the limit, corresponding to ",
            nrow(a), " nodes.\n",
            "  - Clusters below the limit: \n", paste(levels(a[, column]), collapse = ", "),
            "\n  - Nodes within these clusters: \n ", paste(levels(a$Name), collapse = ", "), "\n", sep =""))
    
    if(rename)
    {
      levels(df[, column])[which(levels(df[, column]) %in% clustersbelowlimit)] <- "small.clusters"
    } else if(remove.clusters)
    {
      df <- droplevels(df[-which(df[, column] %in% clustersbelowlimit), ])
    }

    return(df)

  } else
  {
    message("No levels below the specified limit\n")
    if(remove.clusters)
    {
      return(df)
    }
  }
}

