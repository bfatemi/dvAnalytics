library(easydata)
library(data.table)

context("Testing basic use of fnWeight")

test_that(desc = "basic usage of fnWeight",
          code = {
            data("fiberCountyDem")
            NumMorph(fiberCountyDem)

            ## Calculate each state's share of total US population,
            ## by each year in our data
            #
            compare <- readRDS("testdata_fnWeight")
            result <- fnWeight(fiberCountyDem, "State", "Year", sum(Population))
            expect_equal(compare, result)

            ## Now test for multiple term variable
            a <- fnWeight(dat = fiberCountyDem,
                          resp = "State",
                          term = c("Year", "County"),
                          calc = sum(Population))
            expect_equal(ncol(a), 4)

            ## Test for NO term variables
            b <- fnWeight(dat = fiberCountyDem,
                          resp = "State",
                          calc = sum(Population))
            expect_equal(ncol(b), 2)
          })

