"""
Clean up raw records

#' Uses standard Pandas operators to clean up raw records obtained
#'  from the Bath: Hacked datastore. The process is as follows:
#' \itemize{
#'  \item Select columns containing useful information only
#'  \item Remove any records with NA entries
#'  \item Remove records for "test car park"
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
#'
#' df = refine(raw_data)
#' df.head()
#' ## 813   7
"""

import pandas as pd

def refine(x, max_prop):
    # Select columns of interest
    refinedDF = pd.DataFrame(x, columns = ['LastUpdate', 'Name', 'DateUploaded',
                                             'Occupancy', 'Capacity', 'Status'])
    
    # refinedDF = rawData[['LastUpdate', 'Name', 'DateUploaded',
    #                                         'Occupancy', 'Capacity', 'Status']]
    # Remove any records with NA entries
    refinedDF = refinedDF.dropna()   
    # Remove records for test car park
    refinedDF = refinedDF[refinedDF['Name'] != 'test car park']                        
    # Remove records with negative occupancies
    refinedDF = refinedDF[refinedDF['Occupancy'] >0]
    # Calculate Proportion column
    # this is the equivalent of mutate in dplyr package in R
    refinedDF = refinedDF.assign(Proportion = refinedDF['Occupancy']/refinedDF['Capacity'])
    # alternatively, you can do this using concatenate function in Pandas:
    # refinedDF = pd.concat([refinedDF, refinedDF['Occupancy']/refinedDF['Capacity']], axis = 1)
    # but you will need to rename the new column from 0 to 'Proportion'
    # RenameColumn is a custom function defined earlier in this file
    # refinedDF = RenameColumn(refinedDF, 0, 'Proportion')
    # Remove records with overly-full occupancies (arbitrary)
    refinedDF = refinedDF[refinedDF['Proportion'] <max_prop]
    # Convert date strings to date objects (API provides date-time
    # objects already)
    refinedDF['LastUpdate'] = pd.to_datetime(refinedDF['LastUpdate'], format = '%d/%m/%Y %H:%M:%S %p')
    refinedDF['DateUploaded'] = pd.to_datetime(refinedDF['DateUploaded'], format = '%d/%m/%Y %H:%M:%S %p')
    
    return refinedDF

