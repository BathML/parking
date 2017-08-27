#' Scrape Bath Rugby match dates, kick-off times and results
#'
#' Web scraping function to gather dates and times of Bath Rugby matches, and
#'  whether or not Bath won, from the
#'  \href{http://www.bathrugby.com/fixtures-results/results-tables/results-match-reports/}{Bath Rugby website}.\cr\cr
#'  \emph{Note: This function's code is heavily commented so that if you want
#'   to, you can use it as a tutorial/guide for writing similar functions of
#'   your own! You can view the commented code on the GitHub repo
#'   \href{https://github.com/owenjonesuob/BANEScarparking/blob/master/R/web_scraping.R}{here}}.
#'
#' @param x A vector of years of seasons to retrieve records from.
#' @return A data frame of kick-off date-times and match outcomes.
#' @examples
#' # Return matches from 2014/15, 2015/16 seasons
#' seasons <- c(2015, 2016)
#' rugby <- get_rugby(seasons)
#'
#' @export

get_rugby <- function(x) {

    # Set up data frame, to be added to shortly
    rugby <- data.frame(GMT = character(0), HomeWin = logical(0))

    # For each season:
    for (i in 1:length(x)) {

        # Put together the link to the webpage for the season's fixtures
        address <- paste0("https://www.bathrugby.com/fixtures-results/",
                          "results-tables/results-match-reports/",
                          "?seasonEnding=", x[i])


        # "Parse" page so we can work with it in R
        parsedpage <- RCurl::getURL(address,
                                    .opts = RCurl::curlOptions(followlocation = TRUE)) %>%
            XML::htmlParse()

        # Scrape required information from page (first, home match dates):
        # xpathSApply returns a vector (simplified from a list, hence SApply
        # rather than Apply) of HTML "nodes" satisfying certain conditions...
        dates <- XML::xpathSApply(parsedpage,
                                  # First, (visually) find the information we're
                                  # interested in on the webpage (just using a
                                  # browser). Then use the developer console
                                  # (launch with F12, or Cmd+Option+I on Mac) to
                                  # inspect the HTML.
                                  #
                                  # Now to grab the bits of HTML we are
                                  # interested in. Define conditions using XPath
                                  # query language:
                                  # * //dd finds all nodes of type "dd"
                                  # * [@class='...'] takes the subset of nodes
                                  #   with "class" attribute "..."
                                  # * / finds all "child" nodes of currently
                                  # selected nodes
                                  paste0("//dd[@class='fixture homeFixture']",
                                         "/span[@class='fixtureDate']"),
                                  # We want the value (in this case, the string)
                                  # contained between the HTML tags of these
                                  # nodes (the 'contents' of the node): the XML
                                  # function xmlValue does this for us!
                                  XML::xmlValue) %>%
            # We currently have a string such as " 6 Sep 2014" or "13 Sep 2014",
            # but this would be more useful as a date-time!
            # See documentation of strptime for % abbreviations to use in the
            # "format" string. In this case we're telling the as.POSIXct
            # function that:
            #   '%n': there might be a space, or a few spaces
            #   '%e': day number, as a decimal
            #   ' ' : there's definitely a space here
            #   '%b': abbreviated month name
            #   ' ' : another space
            #   '%Y': 4-digit year
            as.POSIXct(format = "%n%e %b %Y", tz = "UTC") %>%
            # Reverse order of elements (to restore chronological order)
            rev()

        # Now, kick-off times:
        KO <- XML::xpathSApply(parsedpage,
                               paste0("//dd[@class='fixture homeFixture']",
                                      "/span[@class='fixtureTime']"),
                               XML::xmlValue) %>%
            # Values are currently strings of form "Kick Off 00:00"
            # Take 10th character onwards:
            substring(10) %>%
            # Convert to hour-minute time
            lubridate::hm() %>%
            rev()

        # Combine date and time (just use +, R handles this for us!)
        GMT <- dates + KO

        # Results of the matches: did Bath win? (Maybe people hang around in
        # town for longer afterwards if so.)
        HomeWin <- XML::xpathSApply(parsedpage,
                                    paste0("//dd[@class='fixture homeFixture']",
                                           "/span[@class='fixtureResult']"),
                                    XML::xmlValue) %>%
            # Values are "Bath won ..." or "Bath lost ...".
            # grepl returns TRUE if element contains a string, FALSE if it
            # doesn't Note: The "." is the pipe's "placeholder" argument: by
            # default, %>% passes on the previous step's result as the FIRST
            # parameter. Here, we need to pass it as the second argument, so
            # have to use "." to represent it.
            grepl("won", .) %>%
            rev()

        # Stick the GMT and HomeWin vectors together as columns of a data frame
        toAdd <- data.frame(GMT, HomeWin)

        # Attach this dataframe to the existing data frame of all matches
        rugby <- rbind(rugby, toAdd)
    }

    # Return the complete data frame
    rugby
}





#' Scrape the number of advertised events in Bath for each day
#'
#' Web scraping function to retrieve the number of events advertised at
#'  \url{http://www.bath.co.uk/events} for each day in a specified range of
#'  months.\cr\cr
#'  \emph{Note: Have a look at this package's GitHub repo - in particular,
#'   \href{https://github.com/owenjonesuob/BANEScarparking/blob/master/R/web_scraping.R}{here}
#'   - to see the code for this function, along with comments which
#'   explain the process followed. See \code{\link{get_rugby}} for a similar
#'   function with more detailed commentary!}
#'
#' @param from A date or date-time object, or YYYY-MM-DD string: the first day
#'  from which to get an event count.
#' @param to A date or date-time object, or YYYY-MM-DD string: the last day
#'  from which to get an event count.
#' @return A data frame of daily event counts for each day in the specified
#'  range.
#' @examples
#' # Return daily event counts from 01 Oct 2014 to 17 Jul 2015
#' events <- get_events("2014-10-01", "2015-07-17")
#'
#' ## Return daily event counts for all months in date range of parking records
#' # raw_data <- get_all_crude()
#' # df <- refine(raw_data)
#'
#' # events <- get_events(min(df$LastUpdate), max(df$LastUpdate))
#' @export

get_events <- function(from, to) {

    # Get all year-month combinations in specified range
    year_month <- seq(as.Date(from), as.Date(to), by = "months") %>%
        substr(., 0, nchar(.)+2)

    # Create web addresses for past events pages
    addresses <- paste0("http://www.bath.co.uk/events/", year_month)

    # Initialize event-count vector
    event_count <- vector("list", length(addresses))
    names(event_count) <- year_month
    
    # Create a text bar in the console

    pb <- utils::txtProgressBar(min = 0, max = length(addresses),
                                initial = 0, style = 3)
    
    # For each year-month:
    for (i in 1:length(addresses)) {

        # "Parse" page so we can work with it in R
        parsedpage <- RCurl::getURL(addresses[i],
                                    .opts = RCurl::curlOptions(followlocation = TRUE)) %>%
            XML::htmlParse()

        # Find all days from current month
        day_events <- XML::xpathApply(parsedpage,
                                      paste0("//td[contains(@class, ",
                                             "'tribe-events-thismonth')]"))

        # Set up a vector to store number of events from each day in a month
        daily_event_count <- vector("integer", length(day_events))

        # For each day:
        for (j in 1:length(day_events)) {

            # Look for a "view more" node
            view_more <- XML::xpathSApply(day_events[[j]],
                                         "div[@class='tribe-events-viewmore']",
                                         XML::xmlValue)

            # If such a node exists...
            if (length(view_more) > 0) {
                # ... it contains a string of the form "View all x events", so
                # we isolate x by using gsub to replace all non-digit characters
                # (the caret ^ means "all except") with "" (nothing!), and then
                # convert the string "x" to a number
                daily_event_count[j] <- view_more %>%
                    gsub("[^0-9]", "", .) %>%
                    as.numeric()
            } else {
                # If there is no "view more" node, then we simply count the
                # number of 'div's: there is one more div than events, because
                # the day number (which isn't an event!) is also found in a div
                daily_event_count[j] <- XML::xpathApply(day_events[[j]],
                                                        "div") %>%
                    length() - 1
            }
        }

        # Add this list to our list of year-month event counts
        event_count[[i]] <- daily_event_count
        
        # Update progress bar
        utils::setTxtProgressBar(pb, i)
    }

    # Trim the last month... (events only up to "to" date)
    lec <- length(event_count)
    event_count[[lec]] <- event_count[[lec]][1:{lubridate::day(to)}]

    # Then the first month... (events only from "from" date)
    event_count[[1]] <- event_count[[1]][{lubridate::day(from)}:length(event_count[[1]])]


    # Get all dates in the months we are looking at
    all_dates <- seq(as.Date(from), as.Date(to), by = "days")

    # Make a data frame with each date and the number of events that day:
    # "unlist" does exactly as it says on the tin, it just stretches a list out
    # into a long vector
    events <- data.frame(Date = all_dates, count = unlist(event_count))

    # Get rid of unnecessary numeric row names
    rownames(events) <- NULL

    # Return the complete data frame!
    events
}





#' Scrape the details of advertised events in Bath for each day
#'
#' Web scraping function to retrieve the detail for events advertised at
#'  \url{http://www.bath.co.uk/events} for each day in a specified range of
#'  dates.
#' @author Ryan Kenning (@@rkenning)
#' @param from A date or date-time object, or string, of the first
#'  date for which to find events.
#' @param to A date or date-time object, or string, of the last
#'  date for which to find events.
#' @return A data frame of daily event details for each day in the specified
#'  range of months.
#' @examples
#' # Return daily event details from 01 Oct 2014 to 08 Oct 2014
#' events <- get_events_detail("2014-10-01", "2014-10-08")
#'
#' @export

get_events_detail <- function(from, to) {

    # Get all year-month combinations in specified range
    year_month_day_seq <- seq(as.Date(from), as.Date(to), by = "days") %>%
        substr(., 0, nchar(.)+6)

    # Create web addresses for past event pages
    addresses <- paste0("http://www.bath.co.uk/events/", year_month_day_seq)

    # Initialize event-count vector
    event_count <- vector("list", length(addresses))
    names(event_count) <- year_month_day_seq


    # Initialise 0 length vectors to create the initial DF object (Not sure if this is the best approach to append to a df type pattern)
    year_month_day <- vector(mode="character",0)
    event_name <- vector(mode="character", 0)
    event_location_name <- vector(mode="character", 0)
    event_postcode <- vector(mode="character", 0)
    event_street <- vector(mode="character", 0)
    event_locality <- vector(mode="character", 0)
    event_start <- vector(mode="character", 0)
    event_end <- vector(mode="character", 0)
    time_slot <- vector(mode="character", 0)

    # Create the initial df (Not sure if this is the best approach to append to a df type pattern)
    events <- data.frame(year_month_day, time_slot, event_name, event_location_name, event_postcode, event_street, event_locality, event_start, event_end)
    
    # Add a progress bar to the console
    pb <- utils::txtProgressBar(min = 0, max = length(year_month_day_seq),
                                initial = 0, style = 3)
    
    # For each year-month-day loop through the URLs:
    for (ymd in 1:length(addresses)) {
        # Connect to address and return HTLM page from URL
        url <- addresses[ymd]
        # Parse the HTML page
        webpage <- xml2::read_html(url)

        # Find the Timeslot HTML nodes
        event_time_slot <- webpage %>%
            rvest::html_nodes(".tribe-events-day-time-slot")

        #Loop through the timeslots
        for (i in 2:length(event_time_slot)){
            # Get the current timeslot header text
            time_slot_val <- event_time_slot[i] %>%
                rvest::html_node(xpath=".//h5") %>%
                rvest::html_text()
            # From the current timeslot, get the event detail html node
            event_detail_nodes <- event_time_slot[i] %>%
                rvest::html_nodes(xpath=".//div[contains(@class, 'type-tribe_events')]")

            # Initialise the value vectors with the length based on number of events found
            event_name <- vector(mode="character", length=length(event_detail_nodes))
            event_location_name <- vector(mode="character", length=length(event_detail_nodes))
            event_postcode <- vector(mode="character", length=length(event_detail_nodes))
            event_street <- vector(mode="character", length=length(event_detail_nodes))
            event_locality <- vector(mode="character", length=length(event_detail_nodes))
            event_start <- vector(mode="character", length=length(event_detail_nodes))
            event_end <- vector(mode="character", length=length(event_detail_nodes))
            time_slot <- rep(time_slot_val,length=length(event_detail_nodes))


            # Revised html text function to retun NA if no HTML text value can be found
            html_text_na <- function(x, ...) {

                txt <- try(rvest::html_text(x, ...))
                if (inherits(txt, "try-error") |
                    (length(txt)==0)) { return(NA) }
                return(txt)

            }

            # Loop through each event node
            for (j in 1:length(event_detail_nodes)){
                #Add parsed event
                event_name[j] <- rvest::html_nodes(event_detail_nodes[j], xpath=".//a[@class='url']") %>% rvest::html_text(trim=TRUE)
                event_location_name[j] <- rvest::html_node(event_detail_nodes[j], xpath=".//div[@class='tribe-events-venue-details']//a/text()") %>% html_text_na()
                event_postcode[j] <- rvest::html_node(event_detail_nodes[j], xpath=".//*[contains(concat( ' ', @class, ' ' ), 'tribe-postal-code')]") %>% html_text_na()
                event_street[j] <- rvest::html_node(event_detail_nodes[j], xpath=".//*[contains(concat( ' ', @class, ' ' ), 'tribe-street-address')]") %>% html_text_na()
                event_locality[j] <- rvest::html_node(event_detail_nodes[j], xpath=".//*[contains(concat( ' ', @class, ' ' ), 'tribe-locality')]") %>% html_text_na()
                event_start[j] <- rvest::html_node(event_detail_nodes[j], xpath=".//*[contains(concat( ' ', @class, ' ' ), 'tribe-event-date-start')]") %>% html_text_na()
                event_end[j] <- rvest::html_node(event_detail_nodes[j], xpath=".//*[contains(concat( ' ', @class, ' ' ), 'tribe-event-date-end')]") %>% html_text_na()
            }


            # Make a Dataframe from the populated vectors (only if there are any events)
            if (length(event_detail_nodes)) {
                new_events <- data.frame(year_month_day_seq[ymd], time_slot, event_name, event_location_name, event_postcode, event_street, event_locality, event_start, event_end)
                # Combine the event details collect so far with the new event details parsed for the current day and timeslot
                events <- rbind(events, new_events )
            }
        }
        # Update the progress bar
        utils::setTxtProgressBar(pb, value = ymd) 
    }
    # Return the dataframe
    events
}






#' Scrape daily weather records for Bath
#'
#' This function scrapes the \href{https://www.wunderground.com/}{Wunderground}
#'  website to get daily weather summaries for Bath over a given date range.
#'
#' @note The website can only display up to 398 records in one go; asking for
#'  more than this will only give you 398 records, starting at \code{from}!
#'
#' @param from A date or date-time object, or YYYY-MM-DD string: the first day
#'  from which to get a weather summary.
#' @param to A date or date-time object, or YYYY-MM-DD string: the last day
#'  from which to get a weather summary.
#' @return A data frame of daily weather summaries for each day in the specified
#'  range.
#' @examples
#' # Return daily weather summaries from 01 Oct 2014 to 17 Jul 2015
#' weather <- get_daily_weather("2014-10-01", "2015-07-17")
#'
#'
#' ## Return daily event counts for all days in date range of parking records:
#' ## we have to do it in chunks because there are too many to collect in one go
#' 
#' # library(lubridate)
#'
#' # raw_data <- get_all_crude()
#' # df <- refine(raw_data)
#'
#' # weather <- rbind(get_daily_weather(min(df$LastUpdate),
#' #                                    min(df$LastUpdate) + years(1)),
#' #                  get_daily_weather(min(df$LastUpdate) + years(1) + days(1),
#' #                                    min(df$LastUpdate) + years(2)),
#' #                  get_daily_weather(min(df$LastUpdate) + years(2) + days(1),
#' #                                    max(df$LastUpdate)))
#' @export

get_daily_weather <- function(from, to) {

    # Make start date into correct format, and extract numbers from end date
    from_day <- gsub("-", "/", as.character(as.Date(from)))
    day_end <- lubridate::day(lubridate::as_date(to))
    month_end <- lubridate::month(lubridate::as_date(to))
    year_end <- lubridate::year(lubridate::as_date(to))

    # Set up the URL query (EGTG is closest location to Bath)
    url <- paste0("https://www.wunderground.com/history/airport/EGTG/",
                  from_day,
                  "/CustomHistory.html?dayend=", day_end,
                  "&monthend=", month_end,
                  "&yearend=", year_end,
                  "&req_city=&req_state=&req_statename=&reqdb.zip=&reqdb.magic=&reqdb.wmo=")

    # Get the HTML content of the webpage
    wg <- xml2::read_html(url)

    # Find the second table on the webpage (the massive weather table)
    wgtab <- rvest::html_table(wg, header = FALSE)[[2]]

    # Set column names
    names(wgtab) <- c("GMT", "Max TemperatureC", "Mean TemperatureC",
                      "Min TemperatureC", "Max DewPointC", "Mean DewPointC",
                      "Min DewpointC", "Max Humidity", "Mean Humidity",
                      "Min Humidity", "Max Sea Level PressurehPa",
                      "Mean Sea Level PressurehPa", "Min Sea Level PressurehPa",
                      "Max VisibilityKm", "Mean VisibilityKm", "Min VisibilitykM",
                      "Max Wind SpeedKm/h", "Mean Wind SpeedKm/h",
                      "Max Gust SpeedKm/h", "Precipitationmm",
                      "Events")

    # The GMT column of the table currently contains years, months AND days;
    # we'll use regex to separate them out into new columns
    #   First, if GMT contains a 1 or 2-digit number then this must be a day
    #   number, so put this number into a new column; or put in an NA if GMT
    #   did NOT contain a1 or 2-digit number
    wgtab <- dplyr::mutate(wgtab, day = ifelse(grepl("^\\d{1,2}$", GMT), GMT, NA),
                           # Do the same for 3-character strings (month names)
                           month = ifelse(grepl("^[A-Za-z]{3}$", GMT), GMT, NA),
                           # Do the same for 4-digit numbers (year numbers)
                           year = ifelse(grepl("^\\d{4}$", GMT), GMT, NA)) %>%
        # Whenever there's an NA in the month or year columns (i.e. most of the
        # time!) fill in each block of NAs with the first previous non-NA value;
        #   e.g. Jan  becomes  Jan
        #        NA            Jan
        #        NA            Jan
        #        Feb           Feb
        #        NA            Feb
        dplyr::mutate(month = zoo::na.locf(month, na.rm = FALSE),
                      year = zoo::na.locf(year, na.rm = FALSE)) %>%
        # Wherever there's an NA in the day column, this was a row containing
        # (unnecessary) headers, rather than data; so we drop these rows
        dplyr::filter(!is.na(day)) %>%
        # Now we stick the year-month-day columns together and convert to a date
        dplyr::mutate(Date = lubridate::ymd(paste(year, month, day, sep = "-"))) %>%
        # Then we can drop the old GMT column and the year-month-day columns
        dplyr::select(-day, -month, -year, -GMT) %>%
        # Re-order the columns to get Date on the left (currently on the right)
        dplyr::select(Date, dplyr::everything())

    # Return the table!
    wgtab
}
