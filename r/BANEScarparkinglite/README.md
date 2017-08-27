# **BANEScarparkinglite: like BANEScarparking, but smaller!**

This is a stripped-down version of the [BANEScarparking](https://github.com/owenjonesuob/BANEScarparking) package. It contains functions for obtaining and working with the BANES car parking records from the [Bath: Hacked API](https://data.bathhacked.org/Government-and-Society/BANES-Historic-Car-Park-Occupancy/x29s-cczc), as well as some functions for getting other related datasets via web-scraping. Feel free to contribute anything you think might be useful!

---

### **Package contents**

* `get_all_crude` (and `get_range_crude`) for retrieving the full dataset (or a subset) of records from Bath: Hacked datastore
* `refine` for processing the raw records
* `refuel` and `refuel_crude` for updating existing data frames with recent records
* `get_rugby`, `get_events` (and `get_events_detail`) and `get_daily_weather` for obtaining information through web-scraping.

The full [BANEScarparking](https://github.com/owenjonesuob/BANEScarparking) package contains all of these functions, along with parking, events and rugby data up to the end of 2016 (stored as R datasets).

---

### **Installation**

To install the package just run this command in the R console:
```
devtools::install_github("BATH-ML/parking", subdir = "r/BANEScarparkinglite")
```
You'll need the `devtools` package to do this - you can install it with `install.packages("devtools")`

Then you can load the package with
```
library(BANEScarparkinglite)
```
and you should be good to go!

---

**Version:** 0.1.0

Development version [here](https://github.com/owenjonesuob/BANEScarparkinglite)  |  Status: [![Build Status](https://travis-ci.org/owenjonesuob/BANEScarparkinglite.svg?branch=master)](https://travis-ci.org/owenjonesuob/BANEScarparkinglite)

**Contact:** Owen Jones (olj23@bath.ac.uk)
