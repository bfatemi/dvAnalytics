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
  if(length(resp) > 1)
    stop("resp should only be one variable. Add additional groupings to term.", call. = FALSE)
  if(is.null(resp))
    stop("Argument resp is required", call. = FALSE)

  expr <- substitute(calc)   # need to capture this first in case it's not null
  if(is.null(expr))
    expr <- substitute(.N)   # default is to get the mix, by raw count

  # Ensure there are no NAs in the resp column and any term columns
  cleandt <- dat[!is.na(get(resp))]

  if(is.null(term))
    return(cleandt[, .(Pct_Total = eval(expr)/cleandt[, eval(expr)]), by = c(resp)])

  fcall <- function(i) call("[", substitute(cleandt), j=call("!", call("is.na", as.symbol(i))))
  cdt <- cleandt[Reduce(`&`, lapply(sapply(term, fcall), eval, sys.parent(-1)))]
  ndt <- cdt[, .(Res = eval(expr)), by = c(resp, term)]

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

  mdat <- mdat[Pct_Total > 0] # minimize work load on next task

  # if not true, then there is no seperator, thus no need to split columns, etc.
  if(length(term) > 1){
    tmp <- data.table(t(mdat[, stringr::str_split(get(var.name), pattern = sep, n = length(term))]))
    setnames(tmp, term)
    return(cbind(tmp, mdat)[, !var.name, with = FALSE])
  }
  return(mdat)
}

globalVariables(c(".", "Pct_Total"))

