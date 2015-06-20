# http://cran.rstudio.com/web/packages/dplyr/vignettes/introduction.html

library(dplyr)
library(nycflights13)
library(ggplot2)

dim(flights)
head(flights)

tbl_df(flights)
# tbl_df is a wrapper around a data frame that won’t accidentally
# print a lot of data to the screen.

# FILTER ROWS WITH filter()

# filter() allows you to select a subset of the rows of a data frame. The first
# argument is the name of the data frame, and the second and subsequent are
# filtering expressions evaluated in the context of that data frame:

For example, we can select all flights on January 1st with:
filter(flights, month == 1, day == 1)

# This is equivalent to the more verbose:

# flights[flights$month == 1 & flights$day == 1, ]

# filter() works similarly to subset() except that you can give it any number of
# filtering conditions which are joined together with & (not && which is easy to
# do accidentally!). You can use other boolean operators explicitly:

filter(flights, month == 1 | month ==2)

# To select rows by position, use slice():

slice(flights, 1:10)

# ARRANGE ROWS WITH arrange()

# arrange() works similarly to filter() except that instead of filtering or
# selecting rows, it reorders them. It takes a data frame, and a set of column
# names (or more complicated expressions) to order by. If you provide more than
# one column name, each additional column will be used to break ties in the
# values of preceding columns:

arrange(flights, year, month, day)

# Use desc() to order a column in descending order:

arrange(flights, desc(arr_delay))

# dplyr::arrange() works the same way as plyr::arrange(). It’s a straighforward
# wrapper around order() that requires less typing. The previous code is
# equivalent to:

flights[order(flights$year, flights$month, flights$day), ]
flights[order(desc(flights$arr_delay)), ]

# SELECT COLUMNS WITH select()

# Often you work with large datasets with many columns where only a few are
# actually of interest to you. select() allows you to rapidly zoom in on a
# useful subset using operations that usually only work on numeric variable
# positions:

# Select columns by name
select(flights, year, month, day)

# Select all columns between year and day (inclusive)
select(flights, year:day)

# Select all columns except those from year to day (inclusive)
select(flights, -(year:day))

# This function works similarly to the select argument to the base::subset().
# It’s its own function in dplyr, because the dplyr philosophy is to have small
# functions that each do one thing well.
# 
# There are a number of helper functions you can use within select(), like 
# starts_with(), ends_with(), matches() and contains(). These let you quickly 
# match larger blocks of variable that meet some criterion. See ?select for more
# details.
# 
# You can rename variables with select() by using named arguments:

select(flights, tail_num = tailnum)

# But because select() drops all the variables not explicitly mentioned, it’s
# not that useful. Instead, use rename():

rename(flights, tail_num = tailnum)

# EXTRACT DISTINCT (UNIQUE) ROWS

# A common use of select() is to find out which values a set of variables takes.
# This is particularly useful in conjunction with the distinct() verb which only
# returns the unique values in a table.

distinct(select(flights, tailnum))

distinct(select(flights, origin, dest))

# (This is very similar to base::unique() but should be much faster.)

# ADD NEW COLUMNS WITH mutate()

# As well as selecting from the set of existing columns, it’s often useful to
# add new columns that are functions of existing columns. This is the job of
# mutate():

mutate(flights,
       gain = arr_delay - dep_delay,
       speed = distance / air_time * 60)

# dplyr::mutate() works the same way as plyr::mutate() and similarly to
# base::transform(). The key difference between mutate() and transform() is that
# mutate allows you to refer to columns that you just created:

mutate(flights,
       gain = arr_delay - dep_delay,
       gain_per_hour = gain / (air_time /60)
       )

# If you only want to keep the new variables, use transmute():

transmute(flights,
          gain = arr_delay - dep_delay,
          gain_per_hour = gain / (air_time / 60)
          )

# SUMMARISE VALUES WITH summarise()

# The last verb is summarise(), which collapses a data frame to a single row.
# It’s not very useful yet:

summarise(flights,
          delay = mean(dep_delay, na.rm =TRUE)
          )

# This is exactly equivalent to plyr::summarise().

# RANDOMLY SAMPLE ROWS WITH sample_n() and sample_frac()

# You can use sample_n() and sample_frac() to take a random sample of rows,
# either a fixed number for sample_n() or a fixed fraction for sample_frac().

sample_n(flights, 10)

sample_frac(flights, .01)

# Use replace = TRUE to perform a bootstrap sample, and optionally weight the
# sample with the weight argument.


# Commonalities
# 
# You may have noticed that all these functions are very similar:
# 
# The first argument is a data frame.
# 
# The subsequent arguments describe what to do with it, and you can refer to
# columns in the data frame directly without using $.
# 
# The result is a new data frame
# 
# Together these properties make it easy to chain together multiple simple steps
# to achieve a complex result.
# 
# These five functions provide the basis of a language of data manipulation. At
# the most basic level, you can only alter a tidy data frame in five useful
# ways: you can reorder the rows (arrange()), pick observations and variables of
# interest (filter() and select()), add new variables that are functions of
# existing variables (mutate()) or collapse many values to a summary
# (summarise()). The remainder of the language comes from applying the five
# functions to different types of data, like to grouped data, as described next.

# ////////////////////////////////////////////////////////////////

# GROUPED OPERATIONS
# 
# These verbs are useful, but they become really powerful when you combine them
# with the idea of “group by”, repeating the operation individually on groups of
# observations within the dataset. In dplyr, you use the group_by() function to
# describe how to break a dataset down into groups of rows. You can then use the
# resulting object in exactly the same functions as above; they’ll automatically
# work “by group” when the input is a grouped.
# 
# The verbs are affected by grouping as follows:
# 
# grouped select() is the same as ungrouped select(), excepted that retains
# grouping variables are always retained.
# 
# grouped arrange() orders first by grouping variables
# 
# mutate() and filter() are most useful in conjunction with window functions
# (like rank(), or min(x) == x), and are described in detail in
# vignette("window-function").
# 
# sample_n() and sample_frac() sample the specified number/fraction of rows in
# each group.
# 
# slice() extracts rows within each group.
# 
# summarise() is easy to understand and very useful, and is described in more
# detail below.
# 
# In the following example, we split the complete dataset into individual planes
# and then summarise each plane by counting the number of flights (count = n())
# and computing the average distance (dist = mean(Distance, na.rm = TRUE)) and
# delay (delay = mean(ArrDelay, na.rm = TRUE)). We then use ggplot2 to display
# the output.

by_tailnum <- group_by(flights, tailnum)
delay <- summarise(by_tailnum,
                   count = n(),
                   dist = mean(distance, na.rm = TRUE),
                   delay = mean(arr_delay, na.rm = TRUE))
delay <- filter(delay, count > 20, dist < 2000)

# Interestingly, the average delay is only slightly related to the
# average distance flown by a plane.

ggplot(delay, aes(dist, delay)) +
  geom_point(aes(size = count), alpha = 1/2) +
  geom_smooth() +
  scale_size_area()

# You use summarise() with aggregate functions, which take a vector of values,
# and return a single number. There are many useful functions in base R like
# min(), max(), mean(), sum(), sd(), median(), and IQR(). dplyr provides a
# handful of others:
# 
# n(): number of observations in the current group
# 
# n_distinct(x): count the number of unique values in x.
# 
# first(x), last(x) and nth(x, n) - these work similarly to x[1], x[length(x)],
# and x[n] but give you more control of the result if the value isn’t present.
# 
# For example, we could use these to find the number of planes and the number of
# flights that go to each possible destination:

destinations  <- group_by(flights, dest)
a <- summarise(destinations,
          planes = n_distinct(tailnum),
          flights = n()
          )

# You can also use any function that you write yourself. For performance, dplyr
# provides optimised C++ versions of many of these functions. If you want to
# provide your own C++ function, see the hybrid-evaluation vignette for more
# details.
# 
# When you group by multiple variables, each summary peels off one level of the
# grouping. That makes it easy to progressively roll-up a dataset:

daily <- group_by(flights, year, month, day)
(per_day <- summarise(daily, flights = n()))
(per_month <- summarise(per_day, flights = sum(flights)))
(per_year <- summarise(per_month, flighs = sum(flights)))

The dplyr API is functional in the sense that function calls don’t have side-effects, and you must always save their results. This doesn’t lead to particularly elegant code if you want to do many operations at once. You either have to do it step-by-step:
  
  a1 <- group_by(flights, year, month, day)
a2 <- select(a1, arr_delay, dep_delay)
a3 <- summarise(a2,
                arr = mean(arr_delay, na.rm = TRUE),
                dep = mean(dep_delay, na.rm = TRUE))
a4 <- filter(a3, arr > 30 | dep > 30)

Or if you don’t want to save the intermediate results, you need to wrap the function calls inside each other:
  
  filter(
    summarise(
      select(
        group_by(flights, year, month, day),
        arr_delay, dep_delay
      ),
      arr = mean(arr_delay, na.rm = TRUE),
      dep = mean(dep_delay, na.rm = TRUE)
    ),
    arr > 30 | dep > 30
  )


# CHAINING
# 
# The dplyr API is functional in the sense that function calls don’t have
# side-effects, and you must always save their results. This doesn’t lead to
# particularly elegant code if you want to do many operations at once. You
# either have to do it step-by-step:
# 
# a1 <- group_by(flights, year, month, day) a2 <- select(a1, arr_delay,
# dep_delay) a3 <- summarise(a2, arr = mean(arr_delay, na.rm = TRUE), dep =
# mean(dep_delay, na.rm = TRUE)) a4 <- filter(a3, arr > 30 | dep > 30)
# 
# Or if you don’t want to save the intermediate results, you need to wrap the
# function calls inside each other:
# 
# filter( summarise( select( group_by(flights, year, month, day), arr_delay,
# dep_delay ), arr = mean(arr_delay, na.rm = TRUE), dep = mean(dep_delay, na.rm
# = TRUE) ), arr > 30 | dep > 30 )
#> Source: local data frame [49 x 5]
#> Groups: year, month
#> 
#>    year month day      arr      dep
#> 1  2013     1  16 34.24736 24.61287
#> 2  2013     1  31 32.60285 28.65836
#> 3  2013     2  11 36.29009 39.07360
#> 4  2013     2  27 31.25249 37.76327
#> ..  ...   ... ...      ...      ...

# This is difficult to read because the order of the operations is from inside
# to out, and the arguments are a long way away from the function. To get around
# this problem, dplyr provides the %>% operator. x %>% f(y) turns into f(x, y)
# so you can use it to rewrite multiple operations so you can read from
# left-to-right, top-to-bottom:

flights %>%
  group_by(year, month, day) %>%
  select(arr_delay, dep_delay) %>%
  summarise(
    arr = mean(arr_delay, na.rm = TRUE),
    dep = mean(dep_delay, na.rm = TRUE)
    ) %>%
  filter(arr > 30 | dep > 30)
