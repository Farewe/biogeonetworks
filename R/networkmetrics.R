#' Calculate species and site metrics according to clusters
#'
#' This function calculate a series of metrics for species and sites with 
#' respect to their characteristic clusters. 
#'
#' @param db a data.frame with at least two columns, site and species
#' @param network a network data.frame containing cluster information,
#' typically obtained from \code{\link{readInfomapTree}}
#' @param site.field name or number of site column
#' @param species.field name or number of species column
#' @param site.area \code{NULL} or a data.frame with two columns: \code{name}
#' (site name, for correspondence with \code{network}) and \code{area} 
#' (contains the area of each site). If \code{NULL}, area-based 
#' metrics will not be calculated (see details).
#' @param level a character string specifying the column/level containing 
#' clusters
#' @details 
#' This function calculates several metrics for species and sites. First,
#' species-level metrics are calculated: affinity, fidelity, Indicator Value
#' and Dilution Value. Second, site-level metrics are calculated on the basis of
#' the metrics of species occurring within sites.
#' 
#' \bold{Species-level metrics}
#' 
#' Species-level metrics are calculated on the basis of the distribution range
#' of species compared to the size of clusters in which they occur. Hence, they
#' are supposed to be calculated on areas. However, sometimes areas are not
#' available, so we implemented an occurrence-based version of these metrics, 
#' i.e. based on counts of species occurrences rather than based on distribution 
#' range size.
#' 
#' All metrics have an occurrence-based (always prefixed with \code{Occ.}) and
#' area-based version. Occurrence-based metrics are always calculated; area-
#' based metrics are only calculated if argument \code{site.area} is filled 
#' (see examples).
#' 
#' 
#' \itemize{
#' \item{Affinity of species to their region, \emph{Ai}
#' 
#' \ifelse{html}{\out{A<sub>i</sub> = R<sub>i</sub> / Z}}{\deqn{A_i=R_i/Z}}
#' where \emph{Ri} is the occurrence/range size of species \emph{i} in its associated
#' cluster, and \emph{Z} the total size (number of sites or total area) of the
#' the cluster
#' 
#' A high affinity means that the species is occupying most sites/areas of its
#' associated cluster.
#' }
#' 
#' \item{Fidelity of species to their region, \emph{Fi}
#' 
#' \ifelse{html}{\out{F<sub>i</sub> = R<sub>i</sub> / D<sub>i</sub>}}{\deqn{F_i=R_i/D_i}}
#' where \emph{Ri} is the occurrence/range size of species \emph{i} in its associated
#' cluster, and \emph{Di} is its total occurrence/range size. 
#' 
#' A high fidelity means that the species is not present in other clusters than
#' their associated one. 
#' }
#' 
#' \item{Indicator Value of species, \emph{IndVal}
#' 
#' \ifelse{html}{\out{IndVal = F<sub>i</sub> * A<sub>i</sub>}}{\deqn{IndVal=F_i A_i}}
#' where \emph{Fi} is the Fidelity of species \emph{i} to its associated
#' cluster, and Ai is its Affinity to its cluster.  
#' 
#' The IndVal will have a high value for species that occupy most of their 
#' associated cluster (high affinity) and are not present in any other 
#' cluster (high fidelity).}
#' 
#' 
#' \item{Dilution Value of species for their region, \emph{IndVal}
#' 
#' \ifelse{html}{\out{DilVal = (1 - F<sub>i</sub>) * A<sub>i</sub>}}{\deqn{DilVal=(1-F_i) A_i}}
#' where \emph{Fi} is the Fidelity of species \emph{i} to its associated
#' cluster, and Ai is its Affinity to its cluster.  
#' 
#' The DilVal substitues Fidelity (Fi) for Infidelity (1-Fi). A species 
#' overlapping with much of its associated cluster (high affinity) but mostly
#' distributed in other clusters (high infidelity) will have a high DilVal.
#' }
#' }
#' 
#' \bold{Site-level metrics}
#' 
#' Site-level metrics are calculated on the basis of indices of species occurring
#' in sites. 
#' 
#' \itemize{
#' \item{Robustness of cells, \emph{Rg}
#' 
#' \ifelse{html}{\out{R<sub>g</sub> = sum(IndVal<sub>i=1..C</sub>) - sum(DilVal<sub>j=1..N</sub>)}}{\deqn{R_g = \sum_{i=1}^C IndVal_i - \sum_{j=1}^N DilVal_j}}
#' 
#' where \emph{C} is the number of characteristic species of the cluster in 
#' site \emph{g}, and \emph{N} is the number of non-characteristic species.
#' 
#' Grid cells containing a large number of
#' highly indicative species and a few species with low dilution
#' values will have high biogeographical robustness and will be
#' less vulnerable to changing their zooregion assignation due to
#' e.g. changes in the dataset (addition/removal of species as new samplings
#' are included in the dataset or corrections are made), or species introductions,
#' and extinctions.
#' }
#' \item{Relative robustness of cells, \emph{RRg}. 
#' In case of large differences in size or sampling intensities between sites,
#' the robustness of cells can be overly influenced by species richness. Hence,
#' we implemented a "Relative" version of the robustness index:
#' 
#' \ifelse{html}{\out{RR<sub>g</sub> = R<sub>g</sub> / S}}{\deqn{RR_g = R_g / S}}
#' 
#' where \emph{S} is the total species richness of site \emph{g}.
#' 
#' }}
#' 
#' 
#' @return 
#' A list with 3 elements
#' \itemize{
#' \item{\code{region.stats}: a data.frame containing basic region stats (number
#'  of sites, area)}
#' \item{\code{species.stats}: a data.frame containing species-level metrics}
#' \item{\code{site.stats}: a data.frame containing site-level metrics}
#' }
#' @author
#' Boris Leroy \email{leroy.boris@@gmail.com}
#' @examples
#'
#'
#'
#' @export
clusterMetrics <- function(db, 
                          network = NULL, 
                          site.field = colnames(db)[1],
                          species.field = colnames(db)[2],
                          site.area = NULL, # A data.frame containing at least two columns with site name ("name") and site area ("area")
                          level = "lvl1")
{
  region.stats <- data.frame(region = levels(network[, level]),
                             nb.sites = sapply(levels(network[, level]),
                                                 function(x, net, database)
                                                 {
                                                   length(unique(database[which(database[, site.field] %in% 
                                                                                  net$Name[which(net[, level] == x)]), site.field]))
                                                 },
                                                 net = network,
                                                 database = db))
  
  if(!is.null(site.area))
  {
    region.stats <- data.frame(region.stats,
                               area = sapply(levels(network[, level]),
                                                function(x, net, surf){
                                                  sum(surf$area[which(surf$name %in%
                                                                           net$Name[which(net[, level] %in% x)])])
                                                },
                                                net = network,
                                                surf = site.area))
  }
                             
                             

  sp.stats <- data.frame(species = levels(as.factor(db[, species.field])))
  rownames(sp.stats) <- sp.stats$species
  for (sp in sp.stats$species)
  {
    # Cluster of our species
    sp.stats[sp, "cluster"] <- network[which(network$Name == sp), level]
    # All sites where species occurs
    site.occurrence.total <- unique(db[which(db[, species.field] == sp), site.field])
    # Sites of the native region where the species occurs
    site.occurrence.region <- site.occurrence.total[which(site.occurrence.total %in% 
                                                            network$Name[which(network[, level] == 
                                                                                 sp.stats[sp, "cluster"])])]

    # Raw occurrence of the species in the region to which it was assigned
    sp.stats[sp, "Occ.Ri"] <- length(site.occurrence.region)
    # Total raw occurrence of the species
    sp.stats[sp, "Occ.Di"] <- length(site.occurrence.total)
    

    # Occurrence-based affinity
    sp.stats[sp, "Occ.Ai"] <- sp.stats[sp, "Occ.Ri"] / region.stats$nb.sites[
      which(region.stats$region == sp.stats[sp, "cluster"])]
    # Occurrence-based Fidelity
    sp.stats[sp, "Occ.Fi"] <- sp.stats[sp, "Occ.Ri"] / sp.stats[sp, "Occ.Di"]
    
    # Occurrence-based IndVal
    sp.stats[sp, "Occ.IndVal"] <- sp.stats[sp, "Occ.Ai"] * sp.stats[sp, "Occ.Fi"]
    # Occurrence-based DilVal
    sp.stats[sp, "Occ.DilVal"] <- sp.stats[sp, "Occ.Ai"] * (1 - sp.stats[sp, "Occ.Fi"])

    if(!is.null(site.area))
    {
      # area of the distribution range of the species in the region to which it was assigned
      sp.stats[sp, "Ri"] <- sum(site.area$area[which(site.area$name %in% site.occurrence.region)])
      # Total area the distribution range of the species
      sp.stats[sp, "Di"] <- sum(site.area$area[which(site.area$name %in% site.occurrence.total)])
      
      # area-based affinity
      sp.stats[sp, "Ai"] <- sp.stats[sp, "Ri"] / region.stats$area[
        which(region.stats$region == sp.stats[sp, "cluster"])]
      # area-based Fidelity
      sp.stats[sp, "Fi"] <- sp.stats[sp, "Ri"] / sp.stats[sp, "Di"]
      
      # area-based IndVal
      sp.stats[sp, "IndVal"] <- sp.stats[sp, "Ai"] * sp.stats[sp, "Fi"]
      # area-based DilVal
      sp.stats[sp, "DilVal"] <- sp.stats[sp, "Ai"] * (1 - sp.stats[sp, "Fi"])
    }
  }
  
  site.stats <- data.frame(site = levels(as.factor(db[, site.field])))
  rownames(site.stats) <- site.stats$site
  for (site in site.stats$site)
  {
    # Cluster of current site
    site.stats[site, "cluster"] <- network[which(network$Name == site), level]
    
    
    sp.in.site <- unique(db[which(db[, site.field] == site), species.field])
    
    characteristic.sp <- sp.in.site[which(sp.in.site %in%
                                            network$Name[which(network[, level] == site.stats[site, "cluster"])])]
    
    noncharacteristic.sp <- sp.in.site[which(!(sp.in.site %in%
                                               network$Name[which(network[, level] == site.stats[site, "cluster"])]))]

    # Occurrence-based robustness
    site.stats[site, "Occ.Rg"] <- sum(sp.stats$Occ.IndVal[which(sp.stats$species %in% characteristic.sp)]) -
      sum(sp.stats$Occ.DilVal[which(sp.stats$species %in% noncharacteristic.sp)])
    # Occurrence-based relative robustness (= Rg/ species richness)
    site.stats[site, "Occ.RRg"] <- site.stats[site, "Occ.Rg"] / length(sp.in.site)
    
    if(!is.null(site.area))
    {
      # area-based robustness
      site.stats[site, "Rg"] <- sum(sp.stats$IndVal[which(sp.stats$species %in% characteristic.sp)]) -
        sum(sp.stats$DilVal[which(sp.stats$species %in% noncharacteristic.sp)])
      # area-based relative robustness (= Rg/ species richness)
      site.stats[site, "RRg"] <- site.stats[site, "Rg"] / length(sp.in.site)
    }
  }
  return(list(region.stats = region.stats,
              species.stats = sp.stats,
              site.stats = site.stats))
}