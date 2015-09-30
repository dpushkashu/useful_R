library(maptools)


#
# US Primary Roads
#

priroads <- readShapeLines("data/tl_2014_us_primaryroads/tl_2014_us_primaryroads.shp")

png("primary-roads.png", width=960, height=700)
par(mar=c(0,0,0,0))
plot(0, 0, type="n", axes=FALSE, xlim=c(-125.97,-66.32), ylim=c(24.39, 49.7), xlab=NA, ylab=NA)
lines(priroads)
dev.off()

# Adjust.
png("primary-roads-adj.png", width=960, height=600)
par(mar=c(0,0,0,0), bg="#f0f0f0")
plot(0, 0, type="n", axes=FALSE, xlim=c(-125.97,-66.32), ylim=c(24.39, 49.7), xlab=NA, ylab=NA)
lines(priroads, lwd=0.07)
dev.off()



#
# Roads for a county
#

countyroads <- readShapeLines("data/tl_2010_26085_roads/tl_2010_26085_roads.shp")
usroads <- subset(countyroads3, RTTYP == "U")
otherroads <- subset(countyroads3, RTTYP != "U")

png("county-roads-color-3.png", width=960, height=1500, bg="#f0f0f0")
par(mar=c(0,0,0,0))
plot(0, 0, type="n", axes=FALSE, xlim=countyroads3@bbox["x",], ylim=countyroads3@bbox["y",], xlab=NA, ylab=NA)
lines(usroads, col="red", lwd=2)
lines(otherroads, col="black", lwd=0.3)
dev.off()


#
# Multiple Counties
#

county1 <- readShapeLines("data/tl_2010_06001_roads/tl_2010_06001_roads.shp")
county2 <- readShapeLines("data/tl_2010_06013_roads/tl_2010_06013_roads.shp")
county3 <- readShapeLines("data/tl_2010_06081_roads/tl_2010_06081_roads.shp")
county4 <- readShapeLines("data/tl_2010_06075_roads/tl_2010_06075_roads.shp")

x1 <- min(county1@bbox["x", 1], county2@bbox["x", 1], county3@bbox["x", 1], county4@bbox["x", 1])
x2 <- max(county1@bbox["x", 2], county2@bbox["x", 2], county3@bbox["x", 2], county4@bbox["x", 2])
y1 <- min(county1@bbox["y", 1], county2@bbox["y", 1], county3@bbox["y", 1], county4@bbox["y", 1])
y2 <- max(county1@bbox["y", 2], county2@bbox["y", 2], county3@bbox["y", 2], county4@bbox["y", 2])

png("county-roads-color-bay.png", width=960, height=1200, bg="#f0f0f0")
par(mar=c(0,0,0,0))
plot(0, 0, type="n", axes=FALSE, xlim=c(x1, x2), ylim=c(y1, y2), xlab=NA, ylab=NA)
lines(county1, col="black", lwd=0.3)
lines(county2, col="black", lwd=0.3)
lines(county3, col="black", lwd=0.3)
lines(county4, col="black", lwd=0.3)
dev.off()


# Thickness for interstates
inter1 <- subset(county1, RTTYP == "I")
inter2 <- subset(county2, RTTYP == "I")
inter3 <- subset(county3, RTTYP == "I")
inter4 <- subset(county4, RTTYP == "I")

png("county-roads-color-bay.png", width=960, height=1200, bg="#f0f0f0")
par(mar=c(0,0,0,0))
plot(0, 0, type="n", axes=FALSE, xlim=c(x1, x2), ylim=c(y1, y2), xlab=NA, ylab=NA)
lines(county1, col="black", lwd=0.3)
lines(county2, col="black", lwd=0.3)
lines(county3, col="black", lwd=0.3)
lines(county4, col="black", lwd=0.3)

lines(inter1, col="purple", lwd=3)
lines(inter2, col="purple", lwd=3)
lines(inter3, col="purple", lwd=3)
lines(inter4, col="purple", lwd=3)
dev.off()



#
# Entire State (e.g. Montana)
#

# Bounding box coordinates. Taken from http://boundingbox.klokantech.com/
bboxX <- c(-116.43, -103.77)
bboxY <- c(44.23, 49.14)

# Directories with shapefiles
statedir <- "data/Montana/"
directories <- list.files(statedir)

png("montana-roads-2.png", width=960, height=600, bg="#f0f0f0")
par(mar=c(0,0,0,0))
plot(0, 0, type="n", axes=FALSE, xlim=bboxX, ylim=bboxY, xlab=NA, ylab=NA)
for (i in 1:length(directories)) {
	filepath <- paste(statedir, directories[i], "/", directories[i], ".shp", collapse="", sep="")
	currRoads <- readShapeLines(filepath)
	lines(currRoads, lwd=0.13)
}
dev.off()



#
# All of the United States?
#

# Bounding box coordinates. Taken from http://boundingbox.klokantech.com/
bboxX <- c(-125.97,-66.32)
bboxY <- c(24.39, 49.7)

# Directories with shapefiles
maindir <- "data/allroads/"
filenames <- list.files(maindir, pattern = "\\.shp$")

png("united-states-roads-2.png", width=7000, height=4000, bg="#f0f0f0")
par(mar=c(0,0,0,0))
plot(0, 0, type="n", axes=FALSE, xlim=bboxX, ylim=bboxY, xlab=NA, ylab=NA)
for (i in 1:length(filenames)) {
#for (i in 1:2) {
	filepath <- paste(maindir, filenames[i], collapse="", sep="")
	currRoads <- readShapeLines(filepath)
	lines(currRoads, lwd=0.05)
}
dev.off()


