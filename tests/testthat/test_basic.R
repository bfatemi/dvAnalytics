##
## Basic use of FnMix
##
library(data.table)
library(easydata)

## Load example dataset:
##  - Then change all potential numeric columns, to numeric
##    classes (this does it safely, quickly, and by reference)
#
data("fiberCountyDem")
NumMorph(fiberCountyDem)

## Calculate each state's share of total US population,
## by each year in our data
#
result <- fnWeight(fiberCountyDem, "State", "Year", sum(Population))
head(result)
