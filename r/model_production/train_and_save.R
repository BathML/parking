#===============================================================================
# BMLM Team R: H2O models for parking prediction
#===============================================================================

#===== Preparing our data =====

# Load the BANEScarparking package (for the data!)
# Install or update first if necessary (make sure you're on at least v0.1.3):
# install.packages("devtools")
# devtools::install_github("owenjonesuob/BANEScarparking")
library(BANEScarparking)

# Load packages for manipulating data
library(dplyr)
library(lubridate)

# Set up a new data frame: create variables we will predict with
df <- transmute(full_dataset,
                Date = date(LastUpdate),
                name = Name,
                dtime = (lubridate::hour(LastUpdate) + minute(LastUpdate)/60), # decimal time
                wd = wday(LastUpdate),
                mth = lubridate::month(LastUpdate),
                prop = Proportion,
                bin = cut(Proportion, breaks = seq(0, 1.1, 0.1), right = FALSE),
                # Is there a rugby match on that day? Make a boolean column
                # * "rugby" data frame is from BANEScarparking
                rug = (date(LastUpdate) %in% date(rugby$GMT)))

# If there was a match on, did Bath win?
df <- left_join(df, rugby %>%
                  rename(Date = GMT) %>%
                  mutate(Date = date(Date)), by = "Date") %>%
  mutate(HomeWin = replace(HomeWin, is.na(HomeWin), FALSE))

# Add a "count" column, with a daily "event count" from www.bath.co.uk/events
# * "events" data frame is also from BANEScarparking! But have a look at the
#   documentation for get_events() and get_rugby() in the package, if you want
#   to update with more recent records. They scrape the relevant websites to
#   get the data. The code for those functions is really well commented so if
#   you want to do some web scraping yourself have a look at the code by
#   following the link to GitHub in the documentation.
df <- inner_join(df, events, by = "Date")


# Add precipitation (and fog) columns from weather data!
precip <- select(weather, Date, rainmm = precip_mm, rain = was_rainy,
                 snow = was_snowy, fog = was_foggy) %>%
  mutate(rainmm = as.numeric(rainmm))

df <- inner_join(df, precip, by = "Date")


# Spin up an H2O cluster
library(h2o)
h2o.init()

# Convert to H2OFrame
wet <- as.h2o(df)

# Split into training/test sets
wet_split <- h2o.splitFrame(wet, ratios = 0.8)

# Train a random forest to predict bin, ignoring Date, prop, bin columns
rf <- h2o.randomForest(y = "bin", x = -c(1, 6, 7), training_frame = wet_split[[1]],
                       ntrees = 5, model_id = "BANEScarparking_rf")

# Save the model in the current directory
h2o.saveModel(rf, path = "./models/")
h2o.shutdown()
