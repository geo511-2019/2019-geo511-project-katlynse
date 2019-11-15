library(ncdf4) # package for netcdf manipulation
library(raster) # package for raster manipulation
library(rgdal) # package for geospatial analysis
library(ggplot2) # package for plotting
library(plot3D) #package for 3D plotting

sm <- raster("dsa2_2m.grd")
plot(sm)

sm_crop <- crop(sm, extent(615000, 618000, 232000, 234000))

plot(sm_crop)
