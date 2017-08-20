# R code repository

Assorted R code related to the project. Feel free to contribute! (Please scroll down and have a look at the notes on style.)

---

### `BANEScarparkinglite`

The `BANEScarparkinglite` folder contains a stripped-down version of the [BANEScarparking](https://github.com/owenjonesuob/BANEScarparking) package. It contains functions for importing and working with the BANES parking data, as well as a couple of functions which collect other relevant data via web-scraping. The code is well-documented so feel free to dive in and have a look around!

You can install `BANEScarparkinglite` as follows:

* First, if you don't have `devtools` installed, run `install.packages("devtools")`
* Then run `devtools::install_github("Bath-ML/parking", subdir = "r/BANEScarparkinglite")`
* Load the package as usual: `library(BANEScarparkinglite)`

The full package additionally contains datasets of parking records, events, rugby and weather up to the end of 2016. If you discover a major discrepancy between the two versions of the package, please let Owen know (olj23@bath.ac.uk, @owenjonesuob)!

---

### Style guide

A great way to improve your programming skills is to read code other people have shared!

When working on code collaboratively, it is very helpful to use a consistent coding style. Most of the code in this repository follows [Hadley Wickham's R style guide](http://adv-r.had.co.nz/Style.html).

Comments are very helpful to other people who might be reading your code and learning from what you've written. Try to use descriptive comments explaining what the following line or block of code does. Make comments as long as they need to be to adequately describe what's going on!

Good commentary example (from `h2o.R`):

```
# Load packages for manipulating data
library(dplyr)
library(lubridate)

# Set up a new data frame: create variables we will predict with
df <- transmute(full_dataset,
                Date = date(LastUpdate),
                name = Name,
                dtime = (hour(LastUpdate) + minute(LastUpdate)/60), # decimal time
                wd = wday(LastUpdate),
                mth = month(LastUpdate),
                prop = Proportion,
                # `cut` puts continuous data into discrete bins
                bin = cut(prop, breaks = seq(0, 1.1, 0.1), right = FALSE),
                # Is there a rugby match on that day? Make a boolean column
                rug = (date(LastUpdate) %in% date(rugby$GMT)))
                
# If there was a match on, did Bath win?
df <- left_join(df, rugby %>%
                     rename(Date = GMT) %>%
                     mutate(Date = date(Date)), by = "Date") %>%
    mutate(HomeWin = replace(HomeWin, is.na(HomeWin), FALSE))
```
