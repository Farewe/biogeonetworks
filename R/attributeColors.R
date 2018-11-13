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
#' \code{\link[RColorBrewer]{RColorBrewer}}
#' @param lvl a character string specifying the level to which you want to
#' attribute colors
#' @param colname a character string specifying how to name the color column
#' @param sh.grey \code{TRUE} or \code{FALSE}. If \code{TRUE}, then all clusters
#' beyond \code{nb.max.colors} will be attributed distinct shades of grey. If
#' \code{FALSE}, they will all have the color specified at \code{other.color}
#' @param other.color a character string or function specifying the color to
#' attribute to clusters beyond \code{nb.max.colors}
#' @param cluster.order "undefined", "sites", "species", "sites+species".
#' This parameter defines in what order colors are attributed to clusters:
#' default order ("undefined"), or according to number of sites per cluster
#'  ("sites"), number of species per cluster ("species") or the total number
#'  of sites and species per cluster ("sites+species")
#' @param db a data.frame with at least two columns, site and species
#' @param site.field name or number of site column
#' @param species.field name or number of species column
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
attributeColors <- function(network, 
                            nb.max.colors = 12, palette = "Paired",
                            lvl = "lvl1", colname = "color",
                            sh.grey = FALSE, other.color = grey(.5),
                            cluster.order = "sites",
                            db, site.field = 1, species.field = 2)
{
  require(RColorBrewer)
  if(cluster.order == "sites")
  {
    nets <- getSiteTable(db, 
                         site.field = site.field,
                         network = network)
  } else if(cluster.order == "species")
  {
    nets <- getSpeciesTable(db, 
                            species.field = site.field,
                            network = network)
  } else if(cluster.order == "sites+species" | cluster.order == "undefined")
  {
    nets <- network
  } else 
  {
    error("cluster.order must be one of 'undefined', 'sites', 'species' or 'sites+species'")
  }
  freqs.per.cluster <- plyr::count(nets[, lvl])
  freqs.per.cluster$cluster.order <- rank(-freqs.per.cluster$freq)
  if(cluster.order != "undefined")
  {
    if(cluster.order == "sites" | cluster.order == "species")
    {
      # Sometimes not all clusters are in the site table or the species table...
      nets.short <- nets
      nets <- network
      nets$cluster.order <- max(as.numeric(network[, lvl]))
      nets$cluster.order[nets[, lvl] %in% nets.short[, lvl]] <- 
        freqs.per.cluster$cluster.order[match(nets[, lvl][nets[, lvl] %in% nets.short[, lvl]],
                                              freqs.per.cluster$x)]
      
    } else
    {
      nets$cluster.order <- freqs.per.cluster$cluster.order[match(nets[, lvl],
                                                                  freqs.per.cluster$x)]
    }
  } else
  {
    nets$cluster.order <- as.numeric(network[, lvl])
  }

  if(length(levels(network[, lvl])) == 2 | nb.max.colors == 2)
  {
    network[, colname] <-  c(RColorBrewer::brewer.pal(3, palette)[c(1, 3)],
                             rep(grey(.5),
                                 ifelse(max(nets$cluster.order) >
                                          nb.max.colors,
                                        max(nets$cluster.order) -
                                          nb.max.colors, 0)))[
                                            nets$cluster.order]
  } else
  {
    if(length(levels(network[, lvl])) > nb.max.colors)
    {
      if(sh.grey)
      {
        network[, colname] <- c(RColorBrewer::brewer.pal(
          min(c(max(nets$cluster.order), nb.max.colors)), palette),
          grey(seq(0, .8,
                   length = max(nets$cluster.order) -
                     nb.max.colors)))[nets$cluster.order]
      } else
      {
        network[, colname] <- c(RColorBrewer::brewer.pal(
          min(c(max(nets$cluster.order), nb.max.colors)), palette),
          rep(other.color, max(nets$cluster.order) -
                nb.max.colors))[nets$cluster.order]
      }
    } else
    {
      network[, colname] <- RColorBrewer::brewer.pal(
        min(c(max(nets$cluster.order),
              nb.max.colors)), palette)[nets$cluster.order]
    }
  }

  return(network)
}
