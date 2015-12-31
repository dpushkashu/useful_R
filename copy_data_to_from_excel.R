# Copy Excel from clipboard to R

read.excel <- function(header=TRUE,...) {
  read.table("clipboard",sep="\t",header=header,...)
}


dat=read.excel()

dat

# Copy to R from Excel clipboard

write.excel <- function(x,row.names=FALSE,col.names=TRUE,...) {
  write.table(x,"clipboard",sep="\t",row.names=row.names,col.names=col.names,...)
}
 
write.excel(dat)


require(tables)
other.df <- paste.table()

x <- readClipboard()
x

x <- read.table(file = "clipboard", sep = "\t", header=FALSE)
moments(dat)
summary(dat)
hist(dat$Number.of.Reviews)
