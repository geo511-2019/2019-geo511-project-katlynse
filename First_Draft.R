library(ncdf4) # package for netcdf manipulation
library(raster) # package for raster manipulation
library(rgdal) # package for geospatial analysis
library(ggplot2) # package for plotting
library(plot3D) #package for 3D plotting

sm <- raster("dsa2_2m.grd")

sm_crop <- crop(sm, extent(615000, 618000, 232000, 234000))

elev <- as.matrix(sm_crop$z)

sm_matrix <- as.matrix(sm_crop) 

empanada <- persp3D(x=sm_matrix, y=sm_matrix, z=elev)

