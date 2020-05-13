#' Write a biogeographical network in GDF (Gephi) format
#'
#' This function writes a biogeographical network in GDF file format
#' (readable by Gephi) with the possibility to add custom fields such as colors.
#'
#' @param db a data.frame with at least two columns, site and species
#' @param network a network data.frame, typically obtained from
#' \code{\link{readInfomapTree}}
#' @param site.field name or number of site column
#' @param species.field name or number of species column
#' @param filename name of the GDF file to be written on disk. Extension
#' should be ".gdf".
#' @param color.field name of the column in \code{network}from which colors
#' should be fetched.
#' In Gephi, only one color column is used, so the desired one should be
#' specified here.
#' @param abundance.field (optional) name of abundance column
#' @param hex2rgb \code{TRUE} or {FALSE}. Specificies whether color codes should
#' be converted to RGB format. Required for Gephi 0.9.0-0.9.2
#' @param directed \code{TRUE} or {FALSE}. Specificies whether the network is
#' oriented or not.
#' @param additional.fields Not yet implemented.
#' @export
#' @author
#' Boris Leroy \email{leroy.boris@@gmail.com}
#' @examples
#'
writeGDF <- function(db, network = NULL, site.field = colnames(db)[1],
                     species.field = colnames(db)[2],
                     filename, color.field = NULL, abundance.field = NULL,
                     hex2rgb = TRUE, directed = FALSE,
                     additional.fields = NULL) # additional.fields to be implemented later
{
  if(!is.null(network)) # When a network is present, then write a gdf file taking into account network levels
  {
    network[, grep("lvl", colnames(network))] <- apply(network[, grep("lvl", colnames(network))], 2, as.character)
    # network[, grep("lvl", colnames(network))] <- apply(network[, grep("lvl", colnames(network))], 2, as.numeric)
    if(any(is.na(network))) network[is.na(network)] <- 0

    if(length(color.field) & hex2rgb)
    {
      network[, color.field] <- apply(col2rgb(tolower(network[, color.field])), 2, paste, collapse = ",")
      network[, color.field] <- paste0("'", network[, color.field] , "'")
    }

    species.table <- getSpeciesTable(db = db, network = network, species.field = species.field)
    sites.table <- getSiteTable(db = db, network = network, site.field = site.field)

    links <- data.frame(from = species.table$id[match(db[, species.field], species.table$Name)], # from species
                        to = sites.table$id[match(db[, site.field], sites.table$Name)], # to site
                        weight = ifelse(rep(length(abundance.field), nrow(db)), # if abundance
                                        db[, abundance.field], # paste abundance in weight
                                        rep(1, nrow(db)))) # else set weight = 1
    if(directed)
    {
      links$direction <- rep("true", nrow(links))
    }

    cat(paste(# Definition of node fields
      "nodedef>name VARCHAR,label VARCHAR,",
      paste("lvl", 1:length(grep("lvl", colnames(network))), # indicate level fields
            " VARCHAR", sep  = "",
            collapse = ","),
      ifelse(length(color.field), # if colors: indicate color field
             ifelse(hex2rgb, # if conversion to gephi format (rgb): name the column 'color', else 'ccolor'
                    ",color VARCHAR",
                    ",ccolor VARCHAR"),
             ""),
      "\n",
      # Nodes
      ## Species
      paste0(paste(species.table$id, # id
                   species.table$Name, # name
                   apply(species.table[, grep("lvl", colnames(species.table))], 1, paste, collapse = ","), # levels
                   sep = ","), ifelse(rep(length(color.field), nrow(species.table)), # if colors: paste colors from species table, else do nothing
                                      paste0(",", species.table[, color.field]),
                                      ""), collapse = "\n"),
      "\n",
      ## Sites
      paste0(paste(sites.table$id, # id
                   sites.table$Name, # name
                   apply(sites.table[, grep("lvl", colnames(sites.table))], 1, paste, collapse = ","),
                   sep = ","), ifelse(rep(length(color.field), nrow(sites.table)), # if colors: paste colors from site table, else do nothing
                                      paste0(",", sites.table[, color.field]),
                                      ""), collapse = "\n"),
      "\n",
      # Definition of edge fields
      paste0("edgedef>node1 VARCHAR,node2 VARCHAR,weight INTEGER",
             ifelse(directed, # if network is directed, indicate it, else do nothing
                    ",directed BOOLEAN",
                    "")),
      "\n",
      # Edge fields: paste everything including weight & direction
      paste(apply(links, 1, paste, collapse = ","), collapse = "\n"),
      sep = ""), file = filename)
  } else # Else when no network is present, use only the db to create a network and write the gdf file.
  {      # In this case, site.field is the source node field, and species.field is the target node field
    if(directed)
    {
      db$direction <- rep("true", nrow(db))
    } else {direction <- NULL}
    if(length(color.field))
    {
      colors <- cbind(unique(db[, c(site.field, color.field)]), deparse.level = 0)
      colnames(colors) <- c("node", "color")
      if(any(!(db[, species.field] %in% colors[, 1])))
      {
        colors <- rbind(colors,
                        cbind(node = unique(as.character(db[which(!(db[, species.field] %in% colors[, 1])), species.field])),
                              color = grey(.5))) # Attributing grey to nodes with no colour
      }
      if(hex2rgb)
      {
        colors[, "color"] <- apply(col2rgb(tolower(colors[, "color"])), 2, paste, collapse = ",")
        colors[, "color"] <- paste0("'", colors[, "color"], "'")
      }
    }
    if(!length(abundance.field))
    {
      abundance.field <- "weight"
      db$weight <- rep(1, nrow(db))
    }


    cat(paste(paste0("nodedef>name VARCHAR", ifelse(length(color.field),
                                                    ",color VARCHAR\n",
                                                    "\n")),
              paste(ifelse(rep(length(color.field), length(unique(c(levels(as.factor(db[, site.field])),
                                                                    levels(as.factor(db[, species.field])))))),
                           apply(colors, 1, paste, collapse = ","),
                           unique(c(levels(as.factor(db[, site.field])),
                                    levels(as.factor(db[, species.field]))))), collapse = "\n"),
              "\n",
              paste0("edgedef>node1 VARHCHAR,node2 VARCHAR,weight INTEGER",
                     ifelse(directed, ",directed BOOLEAN", ""), "\n"),
              paste(apply(db[, c(site.field, species.field, abundance.field, direction)], 1, paste, collapse = ","), collapse = "\n"),
              sep = ""), file = filename)
  }
}
