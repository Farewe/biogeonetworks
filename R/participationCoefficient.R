#' Calculates the Participation Coefficient of nodes in a network
#'
#' This function calculates the participation coefficient, of nodes in a
#' network, i.e. the degree to which they are connected to nodes of a distinct
#' module. This metric is useful to identify, for example, transition zones,
#' which are zones that contain species from multiple regions.
#'
#' @param network the network data.frame, usually issued from
#' \code{\link{readInfomapTree}}
#' @param db the database that was used to construct the network.
#' @param site.field name or number of column of sites
#' @param species.field name or number of column of species
#' @param lvl column name of the level that you want to analyse
#' @export
#' @return The same data.frame as \code{network} with an additional column
#' containing participation coefficient values
#' @author
#' Boris Leroy \email{leroy.boris@@gmail.com}
#' @examples
#'
#'
#'
#' @export
participationCoefficient <- function(network, db, site.field, species.field,
                                     lvl = "lvl1")
{
  sites <- as.character(network$Name[which(network$Name %in% db[, site.field])])
  species <- as.character(network$Name[which(network$Name %in% db[, species.field])])
  db$species.cluster <- network[match(db[, species.field], network$Name), lvl]
  db$site.cluster <- network[match(db[, site.field], network$Name), lvl]
  if(any(sites %in% species) | any(species %in% sites))
  {
    stop("The network does not appear to be a bipartite network")
  }
  network$participation.coef <- NA
  for (site in sites)
  {
    subdb <- db[which(db[, site.field] %in% site), ]
    tmp <- ddply(subdb, "species.cluster", summarise, nlinks = length(species.cluster))
    network$participation.coef[network$Name == site] <- 1 - sum((tmp$nlinks / sum(tmp$nlinks))^2)
  }
  for (sp in species)
  {
    subdb <- db[which(db[, species.field] %in% sp), ]
    tmp <- ddply(subdb, "site.cluster", summarise, nlinks = length(site.cluster))
    network$participation.coef[network$Name == sp] <- 1 - sum((tmp$nlinks / sum(tmp$nlinks))^2)
  }
  return(network)
}
