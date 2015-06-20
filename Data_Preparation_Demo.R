# http://HandsOnDataScience.com/

# Initialize --------------------------------------------------------------

setwd("/Volumes/HD2/Users/pstessel/Documents/Github/R/Tutorials")

library(rattle)         # The weather dataset and normVarNames().
library(randomForest)   # Impute missing values using na.roughfix().
library(tidyr)          # Tidy the dataset.
library(ggplot2)        # Visualise the data.
library(dplyr)          # Data preparation and pipes %>%.
library(lubridate)      # Handle dates.
library(FSelector)      # Feature selection.

# Step 1: Load--Dataset ----------------------------------------------------

dspath <- "http://rattle.togaware.com/weather.csv"
weather <- read.csv(dspath)
dim(weather)
names(weather)
str(weather)

# Step 1: Load--Generic Variables ------------------------------------------

# We will store the dataset as the generic variable ds (short for dataset). This
# will make the following steps somewhat generic and often we can just load a
# different dataset into ds and these steps can simply be re-run without change.

dsname <- "weather"
ds <- get(dsname)
dim(ds)

# Step 1: Convenience of Table Data Frame ---------------------------------

# Another tip in dealing with larger datasets is to make use of tbl df() to add
# a couple of extra classes to the data frame. The simple aim here is to avoid
# the often made "mistake" of printing the whole data frame accidentally. 

class(ds)
ds <-tbl_df(ds)

# Step 2: Review—Observations ---------------------------------------------

# Once we have loaded the dataset, the next step is to understand the shape of
# the dataset. We review the data using head() and tail() to get our first feel
# for the observations contained in the dataset. We also have a look at some
# random observations from the dataset to provide further insight.

head(ds)
tail(ds)
ds[sample(nrow(ds),6),]


# Step 2: dReview—Structure --------------------------------------------------------

# Next we use str() to report on the structure of the dataset. Once again we get
# an overview of what the data looks like, and also now, how it is stored.

str(ds)

# Review—Summary ----------------------------------------------------------

# We use summary() to preview the distributions

summary(ds)

# Step 2: Review — Meta Data Cleansing --------------------------------------

# We demonstrate some meta-data changes here.

# Normalise Variable Names
# Sometimes it is convenient to map all variable names to low- ercase. R is case
# sensitive, so doing this does change the variable names. This can be useful
# when different upper/lower case conventions are intermixed in names like
# Incm_tax_PyBl and remembering how to capitalise when interactively exploring
# the data with 1,000 such variables is an annoyance. We often see such variable
# names arising when we import data from databases which are often case
# insensitive. Here we use normVarNames() from rattle, which attempts to do a
# reasonable job of converting variables from a dataset into a standard form.

names(ds)
names(ds) <- normVarNames(names(ds))

# Step 2: Review  — Data Formats ------------------------------------------

# We may want to correct the format of some of the variables in our dataset. We might first
# check the data type of each variable.

# We note that the date variable is a factor rather than a date. Thus we may like to convert
# it into a date using lubridate.

sapply(ds, class)
head(ds$date)
ds$date <- ymd(as.character(ds$date))


# Step 2: Review — Variable Roles -----------------------------------------

# We are now in a position to identify the roles played by the variables within
# the dataset. From our observations so far we note that the first variable
# (Date) is not relevant, as is, to the modelling (we could turn it into a
# seasonal variable which might be useful). Also we remove the second variable
# (Location) as in the data here it is a constant. We also identify the risk
# variable, if it is provided|it is a measure of the amount of risk or the
# importance of an observation with respect to the target variable. The risk is
# an output variable, and thus should not be used as an input to the modelling.

(vars <- names(ds))

target <- "rain_tomorrow"
risk <- "risk_mm"
id <- c("date", "location")

# Step 3: Clean — Ignore IDs, Outputs, Missing ----------------------------

# We will want to ignore some variables that are irrelevant or inappropriate for modelling.

# IDs and Outputs
# We start with the identifiers and the risk variable (which is an output
# variable). These should play no role in the modelling. Always watch out for
# including output variables as inputs to the modelling. This is one trap I
# regularly see from beginners.

ignore <- union(id, if (exists("risk")) risk)

# We might also identify any variable that has a unique value for every
# observation. These are sometimes identifiers as well and if so are candidates
# for ignoring.

(ids <- which(sapply(ds, function(x) length(unique(x))) == nrow(ds)))

ignore <- union(ignore, names(ids))

# All Missing
# We then remove any variables where all of the values are missing. There are
# none like this in the weather dataset, but in general across 1,000 variables,
# there may be some. We first count the number of missing values for each
# variable, and then list the names of those variables with only missing values.

mvc <- sapply(ds[vars], function(x) sum(is.na(x)))
mvn <- names(which(mvc == nrow(ds)))
ignore <- union(ignore, mvn)

# Many Missing
# Perhaps we also want to ignore variables with more than 70% of the values missing.

mvn <- names(which(mvc >= 0.7*nrow(ds)))
ignore <- union(ignore, mvn)

# Step 3: Clean — Ignore MultiLevel, Constants ----------------------------

# Too Many Levels
# We might also want to ignore variables with too many levels. Another approach
# is to group the levels into a smaller number of levels, but here we simply
# ignore them

factors <- which(sapply(ds[vars], is.factor))
lvls <- sapply(factors, function(x) length(levels(ds[[x]])))
(many <- names(which(lvls > 20)))

# Constants
# Ignore variables with constant values.

(constants <- names(which(sapply(ds[vars], function(x) all(x == x[1L])))))
ignore <- union(ignore, constants)


# Step 3: Clean — Identify Corelated Variables ----------------------------

mc <- cor(ds[which(sapply(ds, is.numeric))], use="complete.obs")
mc[upper.tri(mc, diag=TRUE)] <- NA
mc <-
  mc %>%
  abs() %>%
  data.frame() %>%
  mutate(var1=row.names(mc)) %>%
  gather(var2, cor, -var1) %>%
  na.omit()
mc <- mc[order(-abs(mc$cor)),]
mc

# Here we can identify pairs where we want to keep one but not the other,
# because they are highly correlated. We will select them manually since it is a
# judgement call. Normally we might limit the removals to those correlations
# that are 0.95 or more.

ignore <- union(ignore, c("temp_3pm1", "Pressure_9am", "temp_9am"))


# Step 3: Clean — Remove the Variables ------------------------------------

# Once we have identified the variables to ignore, we remove them from our list of
# variables to use.

length(vars)

vars <- setdiff(vars, ignore)
length(vars)


# Step 3: Clean — Feature Selection ---------------------------------------

# The FSelector (Romanski, 2013) package provides functions to identify subsets
# of variables that might be more effective for modelling.

library(FSelector) # information.gain()

form <- formula(paste(target, "~ ."))
cfs(form, ds[vars])

information.gain(form, ds[vars])
