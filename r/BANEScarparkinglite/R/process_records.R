#' Clean up raw records
#'
#' Uses functions from the \code{dplyr} package to clean up raw records obtained
#'  from the Bath: Hacked datastore. The process is as follows:
#' \itemize{
#'  \item Select columns containing useful information only
#'  \item Remove any records with NA entries
#'  \item Remove records for "test car park"
#'  \item Convert Name and Status to factors
#'  \item Remove records with negative occupancies
#'  \item Calculate Proportion column (Occupancy/Capacity)
#'  \item Remove records with Proportion greater than \code{max_prop}
#'  \item Remove duplicate records (see \code{first_upload})
#' }
#'
#' @param x A data frame containing records to be cleaned up (e.g. the data
#'  frame obtained by calling \code{\link{get_all_crude}}).
#' @param max_prop The point at which records are discarded due to overly-full
#'  Occupancy values (default is 1.1, or 110\% full, to allow for circulating
#'  cars).
#' @param first_upload If \code{TRUE}, ensures that when duplicate records are
#'   removed, the copy which is kept is the first one uploaded after the record
#'   was taken. This takes much longer to run, due to sorting.
#' @return A data frame of clean records, with 7 columns:
#' \describe{
#'  \item{Name}{The name of the car park where the record was taken.}
#'  \item{LastUpdate}{The time the record was taken (POSIXct date-time object).}
#'  \item{DateUploaded}{The time the record was uploaded to the Bath: Hacked
#'      database (POSIXct date-time object).}
#'  \item{Occupancy}{The total number of cars in the car park.}
#'  \item{Capacity}{The number of parking spaces in the car park.}
#'  \item{Status}{Description of the change in occupancy since the previous
#'      record from that car park.}
#'  \item{Proportion}{Calculated as (Occupancy/Capacity).}
#' }
#' @examples
#' \dontshow{
#' load(system.file("tests", "testthat", "data", "raw.rda", package = "BANEScarparkinglite"))
#' refined <- refine(raw)
#' }
#' \donttest{
#' raw_data <- get_all_crude()
#' some_records <- raw_data[1:1000, ]
#'
#' dim(some_records)
#' ## 1000   16
#'
#' df <- refine(raw_data)
#' dim(df)
#' ## 813   7
#' }
#' @export

refine <- function(x, max_prop = 1.1, first_upload = FALSE) {
    # Select columns of interest
    dplyr::select(x, Name = name, LastUpdate = lastupdate,
                  DateUploaded = dateuploaded, Occupancy = occupancy,
                  Capacity = capacity, Status = status) %>%
        # Remove any records with NA entries
        stats::na.omit() %>%
        # Remove records for test car park
        dplyr::filter(Name != "test car park") %>%
        # Convert Names and Statuses to factors
        dplyr::mutate(Name = as.factor(Name), Status = as.factor(Status)) %>%
        # Remove records with negative occupancies
        dplyr::filter(Occupancy >= 0) %>%
        # Calculate Proportion column
        dplyr::mutate(Proportion = (Occupancy / Capacity)) %>%
        # Remove records with overly-full occupancies (arbitrary)
        dplyr::filter(Proportion < max_prop) %>%
        # Convert date strings to POSIXct date objects (API provides date-time
        # objects already)
        # dplyr::mutate(LastUpdate = as.POSIXct(LastUpdate, tz = "UTC",
        #                                format = "%d/%m/%Y %I:%M:%S %p"),
        #        DateUploaded = as.POSIXct(DateUploaded, tz = "UTC",
        #                                  format = "%d/%m/%Y %I:%M:%S %p")) %>%
        # Remove duplicate records:
        refine.deduplicate(first_upload = first_upload)
}


#' Remove duplicate records (internal method)
#'
#' (Internal method)
#' 
#' @param x Data frame containing records.
#' @param first_upload If TRUE, ensures record with oldest DateUploaded is kept.

refine.deduplicate <- function(x, first_upload) {
    dplyr::group_by(x, Name, LastUpdate) %>%
    {if (first_upload == FALSE) {
        # Default: Doesn't matter which we keep - only difference between
        # records is DateUploaded
        dplyr::slice(., 1L)
    } else {
        # first_upload == TRUE: ensure to choose first uploaded copy after
        # record was taken. Takes much longer due to sorting!
        dplyr::filter(., LastUpdate < DateUploaded) %>%
            dplyr::top_n(-1, DateUploaded)
    }} %>%
        dplyr::ungroup()
}
