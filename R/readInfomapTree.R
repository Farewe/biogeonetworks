#' Read the infomap (Map Equation) output tree
#'
#' This function reads the file written by infomap (Map Equation) and transforms
#' it into a data.frame.
#'
#' @param file the .tree file written by infomap.
#' @param network.summary \code{TRUE} or {FALSE}. Do you want a small message
#' summarising your network?
#' @param replace.leaf.names \code{TRUE} or {FALSE}. Do you want to replace
#' leaf names with the names of sites and species? The procedure takes a little
#' longer on large databases
#' @param db a data.frame with at least two columns, site and species. Specify
#' this argument to add a column called \code{nodetype} which indicates the
#' nature of each node in the network (site or species)
#' @param site.field name or number of site column in \code{db}
#' @param species.field name or number of species column in \code{db}
#' @return A data.frame
#' @export
#' @author
#' Boris Leroy \email{leroy.boris@@gmail.com}
#' @examples
#' ## NOT RUN
#' readInfomapTree("file.tree")
#'
#' @export
readInfomapTree <- function(file, network.summary = TRUE,
                            replace.leaf.names = TRUE,
                            db = NULL,
                            site.field = colnames(db)[1],
                            species.field = colnames(db)[2])
{
  tree.infomap <- read.table(file, skip = 1, sep = " ", nrows = -1)
  colnames(tree.infomap) <- c("Groups", "Codelength", "Name", "id")
  tmp1 <- strsplit(as.character(tree.infomap$Groups), ":")
  indx <- sapply(tmp1, length)
  tmp2 <-  as.data.frame(do.call(rbind,lapply(tmp1, `length<-`, max(indx))))
  colnames(tmp2) <- paste("lvl", 1:ncol(tmp2), sep = "")
  tmp2$lvl1 <- factor(tmp2$lvl1, levels = 1:max(as.numeric(tmp2$lvl1),
                                                na.rm = T))
  nc <- ncol(tmp2)
  while(nc > 1)
  {
    tmp2[, nc] <- as.factor(apply(tmp2[, 1:nc], 1, .pastis, collapse = "."))
    nc <- nc - 1
  }

  tree.infomap <- data.frame(tree.infomap,
                             tmp2)

  if(network.summary)
  {
    message(paste0("Biogeographical network with up to ",
                   ncol(tmp2), " levels of complexity.\n",
                   paste0(colnames(tmp2), ": ",
                          sapply(sapply(tmp2, levels), length),
                          " clusters/leaf nodes",  collapse = "\n")))
  }

  if(replace.leaf.names)
  {
    leaf.names = "Name"
    levels = colnames(tree.infomap)[grep("lvl",
                                         colnames(tree.infomap))]
    if(any(!sapply(tree.infomap[, levels], is.factor)))
    {
      tree.infomap[, levels] <- lapply(tree.infomap[, levels], factor)
    }

    tree.infomap[, leaf.names] <- as.factor(tree.infomap[, leaf.names])

    tree.infomap <- droplevels(tree.infomap)

    if(!is.null(leaf.names))
    {
      if(!leaf.names %in% colnames(tree.infomap))
      {
        stop("leaf.names must be the name of one of your dataframe columns")
      } else
      {
        tree.infomap[, levels] <- lapply(tree.infomap[, levels], as.character)
        for(i in levels(tree.infomap[, leaf.names]))
        {
          tree.infomap[tree.infomap[, leaf.names] %in% i, levels] <- .replace.leaves(i, tree.infomap, levels, leaf.names)
        }
        tree.infomap[, levels] <- lapply(tree.infomap[, levels], factor)
      }
    }
  }
  
  
  tree.infomap[, grep("lvl", colnames(tree.infomap))] <-  
    lapply(tree.infomap[, grep("lvl", colnames(tree.infomap))], 
           function(x) factor(x, levels = 
                                levels(x)[order(table(x), decreasing = TRUE)]))
  
  if(!is.null(db))
  {
    tree.infomap$nodetype <- NA
    tree.infomap$nodetype[tree.infomap$Name %in% db[, site.field]] <- "site"
    tree.infomap$nodetype[tree.infomap$Name %in% db[, species.field]] <- "species"
  }
  
  return(tree.infomap)
}

.pastis <- function(x, collapse.){
  if(any(is.na(x)))
  {
    NA
  } else
  {
    paste(x, collapse = collapse.)
  }
}



.replace.leaves <- function(leaf.name, netwk, lvls, lf.nm)
{
  network.line <- netwk[which(netwk[, lf.nm] == leaf.name), lvls]
  if(any(is.na(network.line)))
  {
    network.line[min(which(is.na(network.line))) - 1] <- leaf.name
  } else
  {
    network.line[length(network.line)] <- leaf.name
  }
  return(network.line)
}
