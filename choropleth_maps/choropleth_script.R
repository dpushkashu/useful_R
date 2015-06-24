setwd("/Volumes/HD2/Users/pstessel/Documents/Git_Repos/useful_R/choropleth_maps")

# read in data
edu63 <- read.csv("fstat-063 reformatted.csv")

# what columns do we have?
library(plyr)
colwise(class)(edu63)

# So, basically, what we have are data, by school (with school code and name),
# as well as by district, the total number of students, and number of folks
# passing various subjects, as well as the column we'll look at deeply here
# PASS.PERCENT, or percentage of students attending the exams who passed the
# SLC.
# 
# Okay, now to get some maps. GADM.org is a great resource for administrative
# boundaries of countries around the world–I will go ahead and download the
# “Admin Boundary Level 3” shapefiles for Nepal from GADM, which correspond to
# districts we have in the dataset.

#loading the map

library(rgeos)
library(maptools)
library(gpclib) # may or may not be needed

# MAP
np_dist <- readShapeSpatial("NPL_adm/NPL_adm3.shp")
# VERIFY IT LOADED PROPERLY
plot(np_dist)

Choropleth iteration I

# We'll now generate our first choropleth–which will need plenty of
# revision–just to demonstrate the method in ggplot2! The method is to first
# fortify the map object we have read in, where we provide to ggplot the name of
# a region (for us, this is district, ie, NAME_3 for admin level 3). We'll also
# go ahead and uppercase the name of the districts because that is how our data
# names districts, and just try and produce something.

library(ggplot2)
np_dist <- fortify(np_dist, region = "NAME_3")
np_dist$id <- toupper(np_dist$id) # change ids to uppercase
ggplot() + geom_map(data = edu63, aes(map_id = District, fill = PASS.PERCENT),
                    map = np_dist) + expand_limits(x = np_dist$long, y = np_dist$lat)

# If you look at that command in detail, you'll notice that there isn't much
# there; we are passing in the data, saying that the “District” column should be
# mapped to the map's ids (which are districts), specifying the map source, and
# making sure that the boundaries are correct.
# 
# Of course, the map looks horrible right now. There are three major issues with
# it:
# 
# there is missing data! its not that pretty right now i'm not sure what data we
# are plotting
# 
# So lets deal with each in reverse order. Mapping the right data
# 
# Our dataset is not a dataset with a row per district, it is a dataset with a
# row per school. To make sure that we are mapping the right data, we should
# summarize our data by district, and then map this aggregated data. I like to
# use ddply for this kind of stuff.


