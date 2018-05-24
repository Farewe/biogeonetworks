#' Simplify the network into major clusters
#'
#' This function transforms the bipartite network data.frame into a unipartite
#' network data.frame that contains only major clusters. The link weights
#' correspond to the number of species shared between clusters or, in the case
#' where abundance is specified, the number of individuals between them.
#'
#' @param db the database that was used to construct the network.
#' @param network the network data.frame, usually issued from
#' \code{\link{readInfomapTree}}
#' @param site.field name or number of column of sites
#' @param species.field name or number of column of species
#' @param color the .tree file written by infomap.
#' @param directed \code{TRUE} or \code{FALSE}. If \code{TRUE}, then the graph
#' will be directed in order to show the number of species/individuals in
#'  cluster Y that
#' come from cluster X and the reverse. If \code{FALSE}, then the graph will
#' simply show the number of species/individuals that are shared between both
#' clusters.
#' @param level a character string specifying the level that will be used to
#' group nodes
#' @param color.field the name of the color field associated to \code{level}
#' @return A data.frame
#' @export
#' @author
#' Boris Leroy \email{leroy.boris@@gmail.com}
#' @examples
#' ## NOT RUN
#' readInfomapTree("file.tree")
#'
#' @export
groupNodesPerCluster <- function(db, site.field = 1, species.field = 2, network,
                                 level = "lvl1", directed = FALSE,
                                 color.field = NULL, abundance.field = NULL)
{
  db[, c(site.field, species.field)] <- apply(db[, c(site.field, species.field)], 2, as.character)
  db[, site.field] <- network$lvl1[match(db[, site.field], network$Name)]
  db[, species.field] <- network$lvl1[match(db[, species.field], network$Name)]
  db[, c(site.field, species.field)] <- lapply(db[, c(site.field, species.field)], factor)
  if(!is.null(abundance.field))
  {
    cluster.db <- plyr::ddply(db, c(site.field, species.field), .fun =
                          function(x){
                            sum(x[, abundance.field])
                          }
                        , .progress = "text")
  } else
  {
    cluster.db <- plyr::ddply(db, c(site.field, species.field), .fun =
                          function(x){
                            nrow(x)
                          }
                        , .progress = "text")
  }
  colnames(cluster.db) <- c("From", "To", "Weight")

  if(!directed)
  {
    tmp1 <- apply(cluster.db[, c("From", "To")], 1, paste, collapse = "")
    tmp2 <- apply(cluster.db[, c("To", "From")], 1, paste, collapse = "")

    duplic.rows <- which(
      as.numeric(as.character(cluster.db[, "From"])) >
        as.numeric(as.character(cluster.db[, "To"])))

    cluster.db2 <- cluster.db[-duplic.rows, ]
    for (i in duplic.rows)
    {
      cluster.db2$Weight[which(cluster.db2$From == cluster.db$To[i] &
                          cluster.db2$To == cluster.db$From[i])] <-
        sum(cluster.db2$Weight[which(cluster.db2$From == cluster.db$To[i] &
                                       cluster.db2$To == cluster.db$From[i])],
            cluster.db$Weight[i])
    }
    cluster.db <- cluster.db2
  }

  if(length(color.field))
  {
    # cluster.db[, color.field] <- apply(col2rgb(tolower(network[, color.field][match(cluster.db[, site.field], network$lvl1)])), 2, paste, collapse = ",")
    cluster.db[, color.field] <- network[, color.field][match(cluster.db[, site.field], network$lvl1)]
    cluster.db[, color.field] <- paste0("'", cluster.db[, color.field], "'")
  }
  return(cluster.db)
}
