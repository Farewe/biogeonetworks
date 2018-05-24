#' Attribute colors to network clusters
#'
#' This function adds a color column to a network data.frame using RColorBrewer
#' palettes. A maximum number of clusters to colorize can be specified to only
#' highlight the most important clusters.
#'
#' @param network the network data.frame, usually issued from
#' \code{\link{readInfomapTree}} or getSitesTable or getSpeciesTable.
#' @param nb.max.colors a numeric <= 12 specifying the maximum number of
#' clusters to be colored.
#' @param palette a character string specifying the palette to use. See
#' \code{\link[RColorBrewer]{brewer.pal}}
#' @param lvl a character string specifying the level to which you want to
#' attribute colors
#' @param colname a character string specifying how to name the color column
#' @param sh.grey \code{TRUE} or \code{FALSE}. If \code{TRUE}, then all clusters
#' beyond \code{nb.max.colors} will be attributed distinct shades of grey. If
#' \code{FALSE}, they will all have the color specified at \code{other.color}
#' @param other.color a character string or function specifying the color to
#' attribute to clusters beyond \code{nb.max.colors}
#' @export
#' @importFrom RColorBrewer brewer.pal
#'
#' @return The same data.frame as \code{network} with an additional color
#' column
#' @author
#' Boris Leroy \email{leroy.boris@@gmail.com}
#' @examples
#'
#'
#'
#' @export
attributeColors <- function(network, nb.max.colors = 12, palette = "Paired",
                            lvl = "lvl1", colname = "color",
                            sh.grey = FALSE, other.color = grey(.5))
{
  require(RColorBrewer)
  if(max(as.numeric(network[, lvl])) == 2 | nb.max.colors == 2)
  {
    network[, colname] <-  c(RColorBrewer::brewer.pal(3, palette)[c(1, 3)],
                             rep(grey(.5),
                                 ifelse(max(as.numeric(network[, lvl])) >
                                          nb.max.colors,
                                        max(as.numeric(network[, lvl])) -
                                          nb.max.colors, 0)))[
                                            as.numeric(network[, lvl])]
  } else
  {
    if(max(as.numeric(network[, lvl])) > nb.max.colors)
    {
      if(sh.grey)
      {
        network[, colname] <- c(RColorBrewer::brewer.pal(
          min(c(max(as.numeric(network[, lvl])), nb.max.colors)), palette),
          grey(seq(0, .8,
                   length = max(as.numeric(network[, lvl])) -
                     nb.max.colors)))[as.numeric(network[, lvl])]
      } else
      {
        network[, colname] <- c(RColorBrewer::brewer.pal(
          min(c(max(as.numeric(network[, lvl])), nb.max.colors)), palette),
          rep(other.color, max(as.numeric(network[, lvl])) -
                nb.max.colors))[as.numeric(network[, lvl])]
      }
    } else
    {
      network[, colname] <- RColorBrewer::brewer.pal(
        min(c(max(as.numeric(network[, lvl])),
              nb.max.colors)), palette)[as.numeric(network[, lvl])]
    }
  }

  return(network)
}
