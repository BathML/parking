#' Download all raw records from Bath: Hacked datastore
#'
#' Reads the entire CSV file found on the Bath: Hacked datastore
#'  (\url{http://bit.ly/2i3Y1uF}). The data frame created can subsequently be
#'  updated using \code{\link{refuel_crude}}.\cr
#'  \emph{\strong{Warning:} The file is very large! This may take a while to
#'  run, depending on your internet connection.}
#'
#' @return The full dataset of car parking records
#' @examples
#' raw_data <- get_all_crude()
#'
#' str(raw_data)
#' @seealso
#' \itemize{
#'  \item \code{\link{refuel_crude}} for updating raw records
#'  \item \code{\link{refuel}} for updating data already processed with
#'   \code{\link{refine}}
#' }
#' @export

get_all_crude <- function() {
    token <- "3YCzwzu21i55UgommFeIikrkm"
    link <- paste0("https://data.bathhacked.org/resource/fn2s-zq2k.csv?",
                   "$limit=10000000&$order=dateuploaded&",
                   "$$app_token=", token)
    message("Making request to Socrata Open Data API...")
    df <- readr::read_csv(link, col_types = "iTcicTciiiiciiic")
    message(sprintf("Downloaded all %i records from Bath: Hacked datastore!",
                    nrow(df)))
    df
}


#' Add new raw records from Bath: Hacked datastore
#'
#' Update  data frame of raw records with any records that have since been added
#'  to the Bath: Hacked datastore.
#'
#' @param x The data frame of raw records from the Bath: Hacked datastore (see
#'  \code{\link{get_all_crude}}).
#' @return The data frame updated with any more recent records.
#' @examples
#' # raw_data <- get_all_crude()
#' # raw_data <- refuel_crude(raw_data)
#' @seealso
#' \itemize{
#'  \item \code{\link{get_all_crude}} for obtaining data frame of raw records
#'  \item \code{\link{refuel}} for updating data already processed with
#'   \code{\link{refine}}
#' }
#' @export

refuel_crude <- function(x) {
    if (!identical(names(x), c("capacity", "dateuploaded", "description",
                               "easting", "id", "lastupdate", "location",
                               "location_address", "location_city",
                               "location_state", "location_zip",
                               "name", "northing", "occupancy", "percentage",
                               "status")))
        stop(paste0("Column mismatch! Make sure you're adding to a data frame",
                    " which came from get_all_crude."))
    token <- "3YCzwzu21i55UgommFeIikrkm"
    lastdt <- toString(max(x$dateuploaded))
    lastdtstr <- paste0("'", substr(lastdt, 1, 10), "T", substr(lastdt, 12, 19),
                        ".000'")
    new_list <- httr::GET("https://data.bathhacked.org/resource/fn2s-zq2k.csv",
                          query = list("$limit" = "10000000",
                                       "$order" = "dateuploaded",
                                       "$where" = paste0("dateuploaded > ",
                                                         lastdtstr),
                                       "$$app_token" = token))
    new_records <- httr::content(new_list,
                                 "parsed", col_types = "iTcicTciiiiciiic")
    n <- nrow(new_records)
    message(sprintf(paste0("Added %d new records from Bath: Hacked datastore!",
                           " \n  Records added: %s to %s"),
                    n, new_records$lastupdate[1], new_records$lastupdate[n]))
    rbind(x, new_records)
}


#' Add new processed records from Bath: Hacked datastore
#'
#' Update data frame of records already processed with \code{\link{refine}} with
#'  any records that have since been added to the Bath: Hacked datastore.
#'
#' @param x The result of calling \code{\link{refine}} on the data frame of
#'  records from the Bath: Hacked datastore (see \code{\link{get_all_crude}}).
#' @param max_prop,first_upload See \code{\link{refine}}.
#' @return The data frame updated with any more recent records.
#' @examples
#' # raw_data <- get_all_crude()
#' # df <- refine(get_all_crude)
#' 
#' ## Add most recent records
#' # df <- refuel(df)
#' @seealso
#' \itemize{
#'  \item \code{\link{get_all_crude}} for obtaining data frame of raw records
#'  \item \code{\link{refuel_crude}} for updating data frame of raw records
#' }
#' @export

refuel <- function(x, max_prop = 1.1, first_upload = FALSE) {
    if (!identical(names(x), c("Name", "LastUpdate", "DateUploaded",
                               "Occupancy", "Capacity", "Status",
                               "Proportion")))
        stop(paste0("Column mismatch! Make sure you're adding to a data frame",
                    " which has been \"refined\"."))
    token <- "3YCzwzu21i55UgommFeIikrkm"
    lastdt <- toString(max(x$DateUploaded))
    lastdtstr <- paste0("'", substr(lastdt, 1, 10), "T", substr(lastdt, 12, 19),
                        ".000'")
    new_list <- httr::GET("https://data.bathhacked.org/resource/fn2s-zq2k.csv",
                          query = list("$limit" = "10000000",
                                       "$order" = "dateuploaded",
                                       "$where" = paste0("dateuploaded > ",
                                                         lastdtstr),
                                       "$$app_token" = token))
    new_records <- httr::content(new_list,
                                 "parsed", col_types = "iTcicTciiiiciiic")
    refined <- refine(new_records, max_prop = max_prop,
                                       first_upload = first_upload)
    added <- refine.deduplicate(rbind(x, refined),
                                first_upload = first_upload)
    n <- nrow(added) - nrow(x)
    message(sprintf(paste0("Refined and added %d new records from Bath: Hacked",
                           " datastore!\n  Records added: %s to %s"),
                    n, new_records$lastupdate[1], new_records$lastupdate[n]))
    added
}


#' Download records from a specified range from the Bath: Hacked datastore
#'
#' Retrieve raw records uploaded to the datastore within a specified date range and/or from a subset of car parks.
#'
#' @param from Datetime object for the earliest record to retrieve.
#' @param to Datetime object for the latest record to retrieve.
#' @param abbrs Abbreviations of names of car parks from which to retrieve
#'   records:
#'   \describe{
#'     \item{as}{Avon Street CP}
#'     \item{cs}{Charlotte Street CP}
#'     \item{l}{Lansdown P+R}
#'     \item{n}{Newbridge P+R}
#'     \item{od}{Odd Down P+R}
#'     \item{p}{Podium CP}
#'     \item{sg}{SouthGate General CP}
#'     \item{sr}{Southgate Rail CP}
#'     \item{t}{test car park}
#'   }
#' @return Car parking records from the specified date range.
#' @examples
#' library(lubridate)
#'
#' # Records for June 2016
#' raw_data <- get_range_crude(ymd_hms("2016-06-01 00:00:00"),
#'                             ymd_hms("2016-06-30 23:59:59"))
#'
#' # All records from Podium CP since 14:30 on 1st January 2017
#' raw_data <- get_range_crude(from = ymd_hms("2017-01-01 14:30:00"),
#'                             abbrs = "p")
#'
#' # All records from P+Rs before 2015
#' raw_data <- get_range_crude(to = ymd_hms("2014-12-31 23:59:59"),
#'                             abbrs = c("l", "n", "od"))
#'
#' @seealso \code{\link{get_all_crude}}
#' @export

get_range_crude <- function(from = NULL, to = NULL, abbrs = NULL) {
    token <- "3YCzwzu21i55UgommFeIikrkm"
    if (!is.null(abbrs)) {
        full <- c("Avon%20Street%20CP", "Charlotte%20Street%20CP", "Lansdown%20P%2BR",
                   "Newbridge%20P%2BR", "Odd%20Down%20P%2BR", "Podium%20CP",
                   "SouthGate%20General%20CP", "SouthGate%20Rail%20CP",
                   "test%20car%20park")
        names(full) <- c("as", "cs", "l", "n", "od", "p", "sg", "sr", "t")
        abbrsfull <- full[abbrs]
        abbrsstring <- paste(abbrsfull, collapse = "%27,%20%27")
    }
    link <- paste0("https://data.bathhacked.org/resource/fn2s-zq2k.csv?",
                   "$limit=10000000&$order=dateuploaded",
                   ifelse(is.null(from), "",
                          paste0("&$where=dateuploaded%20>=%20%27",
                                 gsub(" ", "T", (from - 0.5)), "%27")),
                   ifelse(is.null(to), "",
                          paste0(ifelse(is.null(from), "&$where=", "%20and%20"),
                                 "dateuploaded%20<=%20%27",
                                 gsub(" ", "T", (to - 0.5)), "%27")),
                   ifelse(is.null(abbrs), "",
                          paste0(ifelse(is.null(c(from, to)),
                                        "&$where=", "%20and%20"),
                                 "name%20in(%27", abbrsstring, "%27)")),
                   "&$$app_token=", token)
    message("Making request to Socrata Open Data API...")
    df <- readr::read_csv(link, col_types = "iTcicTciiiiciiic")
    message(sprintf("Downloaded %i records from Bath: Hacked datastore!",
                    nrow(df)))
    df
}
