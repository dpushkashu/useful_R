setwd("/Volumes/HD2/Users/pstessel/Documents/Git_Repos/useful_R")

library(ggplot2)
library(ggmap)
library(maps)

village.data <- read.csv("data/map_test_micha.csv", header=T)
names(village.data)
print(village.data)

latitude <- village.data$latitude
longitude <- village.data$longitude
pop <- village.data$population
survey.point <- village.data$survey.point

# ?get_map for different code options (e.g., type, color, terrain, satellite)

basemap <- get_map(location='Wuding, China', zoom=11, maptype='roadmap',
                   color='bw', source='google')

ggmap(basemap)

# We need to convert our data into a ggplot object. This does not plot anything
# (see map below), but links our column names “longitude” and “latitude” with
# the basemap’s x and y axes. To view your map at anytime use the function 
# print().

map1 <- ggmap(basemap, extent='panel', base_layer=ggplot(village.data, 
                                        aes(x=longitude, y=latitude)))
 
print(map1)

# To create a simple plot of the village locations, we’ll use the ggplot
# function geom_point() . Then we’ll add the map labels and theme aesthetics.

# add data points
map.villages <- map1 + geom_point(color = "blue", size = 4)
print(map.villages)

# add plot lables
map.villages <- map.villages + labs(title="Micha Villages in Yunnan",
                                    x="Longitude", y="Latitude")
print(map.villages)

# add title theme
map.villages <- map.villages + theme(plot.title = element_text(hjust = 0,
                                      vjust = 1, face = c("bold")))
print(map.villages)


# Identify Village Survey Points In my report, I also want to show which
# villages were survey points. The column “survey.point” has a binary yes/no
# variable, so I can use ggplot’s fill= to represent these points.

# use the basemap and linked data from above (map1) as the first layer
map.survey <- map1 + geom_point(aes(color=survey.point),
                                size = 4, alpha = .8)
print(map.survey)

# add plot lablels
map.survey <- map.survey + labs(title="Micha Village Survey Points",
                                x="Longitude", y="Latitude", color="Village Surveyed")
print(map.survey)

# re-label and re-level the variables in the legend
map.survey <- map.survey + scale_colour_hue(name = "Village Surveyed",
                                            breaks=c("yes", "no"), labels=c("Yes (n=13)", "No (n=28)"))
print(map.survey)

# add title theme
map.survey <- map.survey + theme(plot.title = element_text(hjust = 0, vjust = 1, face = c("bold")))
print(map.survey)

# Data Points Indicating Population Size To indicate population size in a point
# map, we can use the aes(size= ) function within geom_point().

map.pop <- map1 + geom_point(aes(size= pop ), color = "darkblue")
print

# add plot labels
map.pop <- map.pop + labs(title = "Micha Village Population", x ="Longitude", y="Latitude", size = "Village Population")

# add title theme
map.pop <- map.pop + theme(plot.title = element_text(hjust = 0, vjust = 1, face = c("bold")))
print(map.pop)

# Plot a Box to Highlight a Region Finally, I want to create a map that shows
# the survey region in the larger context of the province. For this, I’ll query
# a new basemap from the Google Maps server and then draw a rectangle using the
# longitude and latitude coordinates of the region

# query a new basemap. "Kunming, China" is at the center, with a zoom of 8.
yn <- get_map(location='Kunming, China', zoom = 8, source='google',
              maptype='roadmap', color='color')

# view the basemap using ggmap()
ggmap(yn)

# link the basemap with the data, establishing the x and y axes
map2 <- ggmap(yn, extent='panel', base_layer=ggplot(village.data,
                                                    aes(x=longitude, y=latitude)))
print(map2)

# create a data frame with the dimensions of the rectangle. the xmin and xmax
# are the longitude boundaries of the box, while the ymin and the ymax are the
# latitude boundaries.

rect <- data.frame(xmin=102.2, xmax=102.6, ymin=25.3, ymax=25.72)

# now add the rectangle data frame into ggplot using geom_rect() and specify the
# color and size

map.yn <- map2 + geom_rect(data=rect, aes(xmin=xmin, xmax=xmax, ymin=ymin,
                                          ymax=ymax), color="gray20", alpha=0.4,
                           inherit.aes=FALSE)
print(map.yn)

# add labels to the plot
map.yn <- map.yn + labs(title = "Core Micha Region in Yunnan",
                        x ="Longitude", y="Latitude")

# add title theme
map.yn <- map.yn +
theme(plot.title = element_text(hjust = 0, vjust = 1, face = c("bold")))

print(map.yn)

# Making a Scale Bar All maps should have a scale that shows the ratio of
# distance on a map to distance in reality (i.e. 1cm=100km). Currently gplot2 or
# ggmap does not have a function with this capability, so some R users online
# have come up with their own scripts to solve this problem. One that I got to
# work with these maps can be found on Editerna, from a post by Ewen
# (11-10-2013): http://editerna.free.fr/wp/?p=76
