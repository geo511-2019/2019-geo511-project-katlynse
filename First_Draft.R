library(plotly) #3d plot
library(raster) # package for raster manipulation
library(rgdal) # package for geospatial analysis
library(ggplot2) # package for plotting
library(data.table)
library(readxl) #read excel file
library(sf)
library(sp) #converting lat long to utm
library(rasterVis)
library(rio) #convert excel to csv
library(docxtractr) # reads .doc 
library(tidyr) #used to split column into 2 columns
library(measurements) #convert deg min to decimal
dataurl <- "http://www.soest.hawaii.edu/gruvee/sci/Alvin_Dives/4607/Diver_Reports/4607_Port_transcript.xls"
dive_report <- convert(dataurl, "dive_report.csv")
dive_4607 <- read.csv(dive_report)

coordurl <- "http://www.soest.hawaii.edu/gruvee/sci/Alvin_Dives/4607/Diver_Reports/4607_Sample_table.doc"
coord <- read_docx(coordurl)
#4a Download a file with the X, Y and true coordinates from the GRUVEE website
coordurl <- "http://www.soest.hawaii.edu/gruvee/sci/Alvin_Dives/4607/Diver_Reports/4607_Sample_table.doc"
coord <- read_docx(coordurl) #must have LibreOffice installed

#4b Now that you have a document with true coordinates and X, Y manually copy and paste the table into an excel file so you can work with it in R, I have included my ecxel file in the data folder

#4c Read in the new excel file
coord_excel <- read_xlsx("data/coord_excel.xlsx")

#4d Seperate the latitude from the longitude
coord_split <- separate(coord_excel, "Lat, Long", c("Lat", "Long"), sep = "[,]")

#4e Convert the degree lat long into UTM, while I'm certain there is a way to do this in R, this programer was not able to discover it. Therefore you must use an outside site to convert the degrees to UTM, I used this site: http://www.rcn.montana.edu/resources/converter.aspx 
coord_split$Easting <- c(615760, 615809, 616218, 615848, 615918, 616063, 616180, 616302)
coord_split$Northing <- c(235171, 235154, 234317, 234133, 233736, 233416, 233151, 232770)

#4f Find the conversion factor to get from X to Easting and Y to Northing
## We know X + some# = Easting so Easting-X=conversion factor
coord_split[1, "Easting"] - coord_split[1, "X"]

## and Northing-Y=conversion factor
coord_split[1, "Northing"] - coord_split[1, "Y"]

## We can double check
mutate(coord_split, dbl_x= X + 600078)
mutate(coord_split, dbl_y= Y + 224781)
#Looks good! 

names(dive_4607) <- lapply(dive_4607[8, ], as.character)
dive_4607 <- dive_4607[-c(1:8),]
names(dive_4607)[7]<-"Samples"
dive_4607[, "X"] <- as.numeric(as.character(dive_4607[, "X"] ))
dive_4607[, "Y"] <- as.numeric(as.character(dive_4607[, "Y"] ))
dive_4607 <- mutate(dive_4607, Easting= X + 600078)
dive_4607 <- mutate(dive_4607, Northing= Y + 224781)
write.csv(dive_4607, file = "data/dive_4607.csv")

sm <- raster("data/empanada_clip.tif")*(-1)

proj="+proj=utm +zone=15 +ellps=WGS84 +datum=WGS84 +units=m +no_defs"
projection(sm)=proj

emp1 <- gplot(sm) +
  geom_tile(aes(fill=value))+
  scale_fill_viridis_c()
emp1

dive_4607 <- read.csv("data/dive_4607.csv")
dive_4607_sf <- read.csv("data/dive_4607.csv") %>%
  drop_na(Easting) %>%
  st_as_sf(coords=c("Easting", "Northing")) %>%
  st_set_crs(proj)

dive_track <- geom_sf(data=dive_4607_sf, inherit.aes = F,col="red", size=0.5, mapping=aes())
emp2 <- emp1 + dive_track
emp2
##################
proj="+proj=utm +zone=15 +ellps=GRS80 +datum=NAD83 +units=m +no_defs"

sm <- raster("data/empanada_clip.tif")*(-1)

projection(sm)=proj

sm_slope=terrain(sm,opt="slope",unit="degrees")

sm_rough=terrain(sm,opt="roughness")

sm_df=as.data.frame(sm)

dive_4607 <- read.csv(dive_report)

coordurl <- "http://www.soest.hawaii.edu/gruvee/sci/Alvin_Dives/4607/Diver_Reports/4607_Sample_table.doc"
coord <- read_docx(coordurl) #must have LibreOffice installed

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
  

