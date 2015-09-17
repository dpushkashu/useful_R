Define your own operators:

`%+%` <- function(e1, e2) {
  e1[is.na(e1)] <- 0; e2[is.na(e2)] <- 0; return(e1 + e2)}
`%-%` <- function(e1, e2) {
  e1[is.na(e1)] <- 0; e2[is.na(e2)] <- 0; return(e1 - e2)}
within(df, e <- a %-% b %+% c)
  a  b  c  e
1 1  0  9 10
2 2  1 10 11
3 3 NA 11 14
4 4  3 NA  1
5 5  4 13 14

