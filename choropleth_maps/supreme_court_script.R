## LOAD PACKAGES

## download Biobase so we don't have to manually open codebook
source("http://bioconductor.org/biocLite.R")
biocLite("Biobase", suppressUpdates = TRUE)
library(qdap)
## Load initial required packages
lapply(qcv(ggplot2, maps, ggthemes, Biobase), require, character.only = T)

## GET DATA

# The Supreme Court Codebook opened without clicking
## download the pdf code book and open it
url_dl(SCDB_2012_01_codebook.pdf, url = "http://scdb.wustl.edu/_brickFiles/2012_01/")
openPDF(file.path(getwd(), "SCDB_2012_01_codebook.pdf"))

# The Supreme Court Data: Learn how to download and open a zip file
temp <-tempfile()
download.file("http://scdb.wustl.edu/_brickFiles/2012_01/SCDB_2012_01_caseCentered_Citation.csv.zip", 
              temp)
dat <-read.csv(unz(temp, "SCDB_2012_01_caseCentered_Citation.csv"))
unlink(temp)
htruncdf(dat, 6,6) # (this doesn't work)

## Source a Codebook for State Keys Usede by Supreme Court Data
source("state.key.R")
head(state.key)

## CLEAN DATA

dat$state <-lookup(dat$caseOriginState, state.key)
dat2 <-dat[!is.na(dat$state), ]
dat_state <-data.frame(with(dat2, prop.table(table(state))))
head(dat_state)
