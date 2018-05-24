#' Get the data.frame of sites from a bipartite data.frame
#'
#' This function extracts the sites from a data.frame that contains both
#' sites and species (e.g. a data.frame read from \code{\link{readInfomapTree}})
#'
#' @param db the database that was used to construct the network.
#' @param site.field a character string giving the name of site column in
#' \code{db}
#' @param network the network data.frame, usually read from
#' \code{\link{readInfomapTree}}
#' @export
#' @return A subset of \code{network} containing only sites
#' @author
#' Boris Leroy \email{leroy.boris@@gmail.com}
#' @examples
#'
#'
#'
#' @export
getSiteTable <- function(db, site.field = 1, network)
{
  sites <- as.character(network$Name[which(network$Name %in% db[, site.field])])
  sites <- network[which(network$Name %in% sites), ]
  return(sites)
}

#' Get the data.frame of species from a bipartite data.frame
#'
#' This function extracts the species from a data.frame that contains both
#' sites and species (e.g. a data.frame read from \code{\link{readInfomapTree}})
#'
#' @param db the database that was used to construct the network.
#' @param species.field a character string giving the name of species column in
#' \code{db}
#' @param network the network data.frame, usually read from
#' \code{\link{readInfomapTree}}
#' @export
#' @author
#' Boris Leroy \email{leroy.boris@@gmail.com}
#' @return A subset of \code{network} containing only species
#' @examples
#'
#'
#'
#' @export
getSpeciesTable <- function(db, species.field = 2, network)
{
  species <- as.character(network$Name[which(network$Name %in% db[, species.field])])
  species <- network[which(network$Name %in% species), ]
  return(species)
}

