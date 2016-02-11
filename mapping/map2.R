# clear_global_environment
rm(list=ls(all=T))

# set_working_directory
setwd("~/repos/maps")

# READ IN DATA
edu63 <- read.csv("data/reformatted.csv")

# WHAT COLUMNS DO WE HAVE
library(plyr)
colwise(class)(edu63)

# LOADING THE MAP
library(rgeos)
library(maptools)
# library(gpclib)

# MAP
np_dist <- readShapeSpatial("data/NPL_adm_shp/NPL_adm3.shp")
# VERIFY IT LOADED PROPERLY
plot(np_dist)

## CHOROPLETH ITERATION I
library(ggplot2)
np_dist <- fortify(np_dist, region = "NAME_3")
np_dist$id <- toupper(np_dist$id)  #change ids to uppercase
ggplot() + geom_map(data = edu63, aes(map_id = District, fill = PASS.PERCENT), 
                    map = np_dist) + expand_limits(x = np_dist$long, y = np_dist$lat)

# Take the mean of PASS.PERCENT by District
districtpassavg63 <- ddply(edu63, .(District), summarize, PassMean63 = mean(PASS.PERCENT))
# Samed plot, but use the right dataset and fill parameter
ggplot() + geom_map(data = districtpassavg63, aes(map_id = District, fill = PassMean63),
                    map = np_dist) + expand_limits(x = np_dist$long, y = np_dist$lat)
