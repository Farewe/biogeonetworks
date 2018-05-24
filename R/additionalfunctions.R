## Additional functions
# Function to plot sites/basins based on their names
.plotbasin <- function(x, basin, col = "blue", ...)
{
  if(!exists("coastsCoarse"))
  {
    require(rworldmap)
    data(coastsCoarse)
  }
  plot(coastsCoarse, col = "grey", ...)
  plot(x[x@data$BasinName %in% basin, ], add = T,
       col = col)
}

# Function to plot species distributions based on their names
.plotfish <- function(x, db, sp, sp.field = "X6.Fishbase.Valid.Species.Name",
                     site.field = "X1.Basin.Name", col = "blue", ...)
{
  if(!exists("coastsCoarse"))
  {
    require(rworldmap)
    data(coastsCoarse)
  }
  plot(coastsCoarse, col = "grey", ...)
  plot(x[x@data$BasinName %in% db[db[, sp.field] %in% sp, site.field], ], add = T,
       col = col)
}
