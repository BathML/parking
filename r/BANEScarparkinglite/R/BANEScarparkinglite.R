#' Functions for obtaining and working with car parking data from Bath and North East Somerset
#'
#' Contains functions for importing and working with the BANES car parking
#'  records and other related datasets. For the full version of the package, including
#'  all datasets, see the repo at https://github.com/owenjonesuob/BANEScarparking.
#'
#' @docType package
#' @name BANEScarparkinglite-package
#' @author Owen Jones (\email{olj23@@bath.ac.uk})
NULL

## Quiets concerns of R CMD check re variables that appear in pipelines
if(getRversion() >= "2.15.1")  {
    utils::globalVariables(c(".", "GMT", "month", "year", "day",
                             "max_gust_kmph", "precip_type", "Date",
                             "name", "lastupdate", "dateuploaded", "occupancy",
                             "capacity", "status", "Name", "Status",
                             "Occupancy", "Capacity", "Proportion",
                             "LastUpdate", "DateUploaded"))
}
