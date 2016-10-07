#' A Flexibily Function to Calculate Proportions
#'
#' This function will take in a data set (of class data.table) and will calculate shares
#' by a specified volume, for a main variable (default is ToolName), and optional groupings.
#'
#' @param dat A dataset with a specified structure (details coming soon...)
#' @param resp The variable we would like to calculate a share for
#' @param term Any groupings we'd like to apply in our calculation
#' @param calc An r expression that will determine the numerator of our share calculation
#'
#' @return Returns a table with shares
#'
#' @import data.table
#' @export
#' @example inst/examples/ex_fnWeight.R
#'
fnWeight <- function(dat, resp = NULL, term = NULL, calc = NULL){
  expr <- substitute(calc) # capture expression
  if(is.null(resp))
    stop("Argument resp is required", call. = FALSE)

  ## Clean NAs
  ## Note that AND needs two args. Add arbitrary TRUE for cases with only 1 grouping
  fcall <- function(i) call("!", call("is.na", as.symbol(i)))
  cleandt <- dat[do.call("&", c(sapply(term, fcall), TRUE))]

  # default is to get the mix, by raw count
  if(is.null(expr))
    expr <- substitute(.N)

  # run calc given by expr
  ndt <- cleandt[, eval(expr), by = c(resp, term)]

  # make it wide, drop labels, do math, bind back together, make it long
  fw <- function(row) row / apply(mat, 2, sum)       # get the pct mix
  formula <- stats::reformulate(term, resp)          # formula defines how we cast

  sep <- "_._"
  wdt <- dcast(ndt, formula, fill=0, sep=sep)        # Use weird sep to seperate later w/out data issues
  lab <- wdt[,  resp, with=FALSE]                    # save the labels
  mat <- wdt[, !resp, with=FALSE]                    # drop the labels to run calc
  res <- data.table(t(apply(mat, 1, FUN = fw)))      # get the weights ("mix")

  var.name <- paste0(term, collapse = sep)
  mdat <- melt(cbind(lab, res),
               id.vars = resp,
               value.name = "Pct_Total",
               variable.name = var.name,
               variable.factor = FALSE)

  # if not true, then there is no seperator, thus no need to split columns, etc.
  if(length(term) > 1){
    tmp <- data.table(t(mdat[, stringr::str_split(get(var.name), pattern = sep, n = length(term))]))
    setnames(tmp, term)
    return(cbind(tmp, mdat)[, !var.name, with = FALSE])
  }
  return(mdat)
}


