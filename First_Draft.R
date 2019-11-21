library(plotly)
library(raster) # package for raster manipulation
library(rgdal) # package for geospatial analysis
library(ggplot2) # package for plotting
library(data.table)


sm <- raster("data/empanada_clip.tif")*(-1)

sm_matrix <- as.matrix(sm)
rownames(sm_matrix) <- c(232000:233001)
colnames(sm_matrix) <- c(615000:616502)


plot(sm)
  

plot_ly(z= ~sm_matrix) %>% 
  add_surface() %>% 
  layout(scene= list(aspectmode='manual',
                     aspectratio = list(x=1, y=1, z=0.25)))

  
