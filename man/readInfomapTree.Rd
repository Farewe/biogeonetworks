% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/readInfomapTree.R
\name{readInfomapTree}
\alias{readInfomapTree}
\title{Read the infomap (Map Equation) output tree}
\usage{
readInfomapTree(
  file,
  network.summary = TRUE,
  replace.leaf.names = TRUE,
  db = NULL,
  site.field = colnames(db)[1],
  species.field = colnames(db)[2]
)
}
\arguments{
\item{file}{the .tree file written by infomap.}

\item{network.summary}{\code{TRUE} or {FALSE}. Do you want a small message
summarising your network?}

\item{replace.leaf.names}{\code{TRUE} or {FALSE}. Do you want to replace
leaf names with the names of sites and species? The procedure takes a little
longer on large databases}

\item{db}{a data.frame with at least two columns, site and species. Specify
this argument to add a column called \code{nodetype} which indicates the
nature of each node in the network (site or species)}

\item{site.field}{name or number of site column in \code{db}}

\item{species.field}{name or number of species column in \code{db}}
}
\value{
A data.frame
}
\description{
This function reads the file written by infomap (Map Equation) and transforms
it into a data.frame.
}
\examples{
## NOT RUN
readInfomapTree("file.tree")

}
\author{
Boris Leroy \email{leroy.boris@gmail.com}
}
