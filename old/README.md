
<!-- README.md is generated from README.Rmd. Please edit that file -->
dvAnalytics
===========

The goal of dvAnalytics is to provide specific analytical tools for mining and exploration of Robotic Surgery data. Many of this functions are generalized and can be extended for use in other domains or data problems.

Example Usage
-------------

This is a basic example of how to use the function ***fnWeight*** to get the proportion of a group within a larger population

First setup the data and use the function from package to standardize column classes:

``` r
library(dvAnalytics)
library(data.table)
library(easydata)

# Load example dataset:
#  - Then change all potential numeric columns, to numeric
#    classes (this does it safely, quickly, and by reference)
#
data("fiberCountyDem")
NumMorph(fiberCountyDem)
```

------------------------------------------------------------------------

Now run the calculation with . Recall our goal... ***Calculate each U.S. state's share of total U.S. population, by each year in our data***

``` r
# Calculate each state's share of total US population,
# by each year in our data
#
result <- fnWeight(fiberCountyDem, "State", "Year", sum(Population))
head(result)
#>    State Year   Pct_Total
#> 1:    AK 2011 0.002320976
#> 2:    AL 2011 0.015650031
#> 3:    AR 2011 0.009558454
#> 4:    AZ 2011 0.021317204
#> 5:    CA 2011 0.122571242
#> 6:    CO 2011 0.016585031
```
