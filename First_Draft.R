library(plotly) #3d plot
library(raster) # package for raster manipulation
library(rgdal) # package for geospatial analysis
library(ggplot2) # package for plotting
library(data.table)
library(readxl) #read excel file
library(sf)
library(rasterVis)
proj="+proj=utm +zone=15 +ellps=WGS84 +datum=WGS84 +units=m +no_defs"

sm <- raster("data/empanada_clip.tif")*(-1)
projection(sm)=proj
sm_slope=terrain(sm,opt="slope",unit="degrees")

sm_rough=terrain(sm,opt="roughness")

sm_matrix <- as.matrix(sm) #don't need?

emp1 <- gplot(sm_rough>8,maxpixels=1e5) +
  geom_tile(aes(fill=value))+
  scale_fill_viridis_c()
 
emp1 + geom_sf(data=dive_4607_sf, inherit.aes = F,col="red" )+
  coord_cartesian(xlim=
 
sm_df=as.data.frame(sm)

dive_4607 <- read.csv("data/sm_track.csv")

dive_4607_sf <- read.csv("data/sm_track.csv")%>%
  na.omit() %>%
  st_as_sf(coords=c("Easting", "Northing")) %>%
  st_set_crs("+proj=utm +zone=15 +ellps=WGS84 +datum=WGS84 +units=m +no_defs")
  

plot_ly(z= ~sm_matrix, x=xFromCol(sm), y=yFromRow(sm)) %>% 
  add_surface() %>% 
  add_markers(data=dive_4607, x=st_coordinates(dive_4607[, 1]), y=st_coordinates(dive_4607[,2]))
  layout(scene= list(aspectmode='manual',
                     aspectratio = list(x=1, y=1, z=0.25)))

