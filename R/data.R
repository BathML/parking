#' Car Parking Data for Bath and North East Somerset
#'
#' Contains all records from 8 car parks located in Bath, United Kingdom, taken
#'  between October 2014 and December 2016. Data is open-source and is provided
#'  by Bath and North East Somerset Council in collaboration with Bath: Hacked,
#'  and has been processed in the way documented in \code{\link{refine}}.
#'
#' @source BANES Council, Bath: Hacked. See \url{http://bit.ly/2i3Y1uF} for the
#'  original dataset and \url{http://bit.ly/2i3Ub4U} for associated
#'  documentation.
#'
#' @format Data frame with 1315713 records of 7 variables:
#' \describe{
#'  \item{Name}{name of car park}
#'  \item{LastUpdate}{time record was taken}
#'  \item{DateUploaded}{time record was uploaded to server}
#'  \item{Occupancy}{number of cars present}
#'  \item{Capacity}{number of available spaces}
#'  \item{Status}{indicates change in occupancy since last record was taken}
#'  \item{Proportion}{calculated as (Occupancy/Capacity)}
#' }
#'

#' @name full_dataset
"DF"


#' Individual car park datasets
#'
#' All records from individual car parks from October 2014 to December 2016.
#'
#' @format Data frames with between 99225 and 201880 records of 7 variables.
#'
#' @name carpark_datasets
"Avon_Street_CP"   # (178585 records)
#' @rdname carpark_datasets
"Charlotte_Street_CP"   # (217457 records)
#' @rdname carpark_datasets
"Lansdown_P+R"   # (160794 records)
#' @rdname carpark_datasets
"Newbridge_P+R"   # (174823 records)
#' @rdname carpark_datasets
"Odd_Down_P+R"   # (177800 records)
#' @rdname carpark_datasets
"Podium_CP"   # (201880 records)
#' @rdname carpark_datasets
"SouthGate_General_CP"   # (99225 records)
#' @rdname carpark_datasets
"SouthGate_Rail_CP"   # (105149 records)


#' Individual month datasets
#'
#' Records for all car parks from individual months from October 2014 to
#'  December 2016. Each month contains approximately 50000 records (except
#'  \code{2014_10}).
#'
#'@format Data frames with approximately 50000 records of 7 variables.
#' @name month_datasets
"2014_10"
#' @rdname month_datasets
"2014_11"
#' @rdname month_datasets
"2014_12"
#' @rdname month_datasets
"2015_01"
#' @rdname month_datasets
"2015_02"
#' @rdname month_datasets
"2015_03"
#' @rdname month_datasets
"2015_04"
#' @rdname month_datasets
"2015_05"
#' @rdname month_datasets
"2015_06"
#' @rdname month_datasets
"2015_07"
#' @rdname month_datasets
"2015_08"
#' @rdname month_datasets
"2015_09"
#' @rdname month_datasets
"2015_10"
#' @rdname month_datasets
"2015_11"
#' @rdname month_datasets
"2015_12"
#' @rdname month_datasets
"2016_01"
#' @rdname month_datasets
"2016_02"
#' @rdname month_datasets
"2016_03"
#' @rdname month_datasets
"2016_04"
#' @rdname month_datasets
"2016_05"
#' @rdname month_datasets
"2016_06"
#' @rdname month_datasets
"2016_07"
#' @rdname month_datasets
"2016_08"
#' @rdname month_datasets
"2016_09"
#' @rdname month_datasets
"2016_10"
#' @rdname month_datasets
"2016_11"
#' @rdname month_datasets
"2016_12"
