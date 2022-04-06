#' Write a biogeographical network in Pajek format
#'
#' This function writes a biogeographical network in pajek file format
#' (readable by infomap) on the basis of a data.frame with at least two
#' columns (sites and species).
#'
#' @param db a data.frame with at least two columns, site and species. An
#' abundance field can also be useful.
#' @param site.field name or number column of sites
#' @param species.field name or number of column of species
#' @param filename name of the pajek file to be written on disk. Extension
#' should be ".net".
#' @param abundance.field (optional) name of abundance column
#' @export
#' @author
#' Boris Leroy \email{leroy.boris@@gmail.com}
#' @examples
#' database <- data.frame(sites = c("site1", "site1", "site2", "site2"),
#'                        species = c("A", "B", "A", "C"),
#'                        abundance = c(5, 2, 7, 1))
#'  database
#'
#' # Without abundance
#' writePajek(database, site.field = "sites", species.field = "species",
#'            filename = "pajektest.net")
#'
#' # With abundance
#' writePajek(database, site.field = "sites", species.field = "species",
#'            filename = "pajektest.net", abundance.field = "abundance")
#'
#' @export
#' db <- data.frame(site = 1:200000, species = c("a", "b"))
#' db[, 1] <- as.integer(db[, 1])
writePajek <- function(db, site.field = 1, species.field = 2, filename, abundance.field = NULL)
{
  scipen <- options()$scipen 
  options(scipen = 999999)
  if(!is.factor(db[, species.field]))
  {
    db[, species.field] <- as.factor(db[, species.field])
  }
  if(!is.factor(db[, site.field]))
  {
    db[, site.field] <- as.factor(db[, site.field])
  }
  if(any(duplicated(db[, c(species.field, site.field)])))
  {
    warning("There are duplicated lines in your site-species database. Check that this is expected behaviour.")
  }

  species <- data.frame(sp = levels(db[, species.field]),
                        id = as.integer(1:length(levels(db[, species.field]))))
  sites <- data.frame(site = levels(db[, site.field]),
                      id = as.integer(length(levels(db[, species.field])) + 1:length(levels(db[, site.field]))))

  links <- data.frame(from = species$id[match(db[, species.field], species$sp)],
                      to = sites$id[match(db[, site.field], sites$site)],
                      weight = ifelse(rep(length(abundance.field), nrow(db)),
                                      db[, abundance.field],
                                      rep(1, nrow(db))))
  links[, c(1:2)] <- sapply(links[, c(1:2)], as.integer)
  

  cat(paste("*Vertices ", max(sites$id), "\n",
            paste(species$id, ' "', species$sp, '"', sep = "", collapse = "\n"), "\n",
            paste(sites$id, ' "', sites$site, '"', sep = "", collapse = "\n"), "\n",
            "*Edges\n",
            paste(apply(links, 1, paste, collapse = " "), collapse = "\n"),
            sep = ""), file = filename)
  options(scipen = scipen)
}
