library(plotly) #3d plot
library(raster) # package for raster manipulation
library(rgdal) # package for geospatial analysis
library(ggplot2) # package for plotting
library(data.table)
library(readxl) #read excel file
library(sf)
library(rasterVis)

proj="+proj=utm +zone=15 +ellps=GRS80 +datum=NAD83 +units=m +no_defs"

sm <- raster("data/empanada_clip.tif")*(-1)

projection(sm)=proj

sm_slope=terrain(sm,opt="slope",unit="degrees")

sm_rough=terrain(sm,opt="roughness")

sm_df=as.data.frame(sm)

dive_4607 <- read.csv("data/sm_track.csv")

dive_4607_sf <- read.csv("data/sm_track.csv")%>%
  na.omit() %>%
  st_as_sf(coords=c("Easting", "Northing")) %>%
  st_set_crs(proj)



sm_matrix <- as.matrix(sm) #don't need?

dive_track <- geom_sf(data=dive_4607_sf, inherit.aes = F,col="red", size=0.5)
#emp1=map of sentry data
emp1 <- gplot(sm) +
  geom_tile(aes(fill=value))+
  scale_fill_viridis_c()

emp1 

#emp2=dive track over sentry data
emp2 <- emp1 + dive_track
  
emp2 

 
#emp3=sentry data with roughness
emp3 <- gplot(sm_rough,maxpixels=1e5) +
  geom_tile(aes(fill=value))+
  scale_fill_viridis_c()
 
#emp4=sentry with roughness and dive track
emp4 <- emp3+dive_track

emp4 

#sentry with slope
emp5 <- gplot(sm_slope,maxpixels=1e5) +
  geom_tile(aes(fill=value))+
  scale_fill_viridis_c() 

emp5

#emp6=sentry with slope and dive track
emp6 <- emp5+dive_track

emp6

#just fancy looking don't use for analysis
plot_ly(z= ~sm_matrix, x=xFromCol(sm), y=yFromRow(sm)) %>% 
  add_surface() %>%
  layout(scene= list(aspectmode='manual',
                     aspectratio = list(x=1, y=1, z=0.25)))
# pipe in if I can figure out how (before layout)
  add_markers(data=dive_4607, x=st_coordinates(dive_4607[, 1]), y=st_coordinates(dive_4607[,2]))
  

