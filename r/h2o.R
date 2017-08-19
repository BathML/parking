#===============================================================================
# BMLM Team R: H2O models for parking prediction
#===============================================================================

#===== Preparing our data =====

# Load the BANEScarparking package (for the data!)
# Install or update first if necessary (make sure you're on v0.1.3):
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
                bin = cut(prop, breaks = seq(0, 1.1, 0.1), right = FALSE),
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
precip <- select(weather, Date, rainmm = Precipitationmm, rain = Rain,
                 snow = Snow, fog = Fog)

df <- inner_join(df, precip, by = "Date")




# Make a single decision tree
library(rpart)

# We'll use a separate training and test set
smp <- sample(nrow(df), nrow(df)*0.2)

tree1 <- rpart(bin ~ . - Date - prop, data = df[-smp, ], minbucket = 20000, cp = 0.00001)

# Plot the tree, to see what it's doing
library(rpart.plot)
prp(tree1, cex = 0.8)

# Make some predictions
preds1 <- predict(tree1, df[smp, ], type = "class")

table(Predictions = preds1, Actual = df$bin[smp])
mean(preds1 == df$bin[smp])




# Spin up an H2O cluster
library(h2o)
h2o.init()

# Convert to H2OFrame
wet <- as.h2o(df)

# Split into training/test sets
wet_split <- h2o.splitFrame(wet, ratios = 0.8)

# Train a random forest to predict bin, ignoring Date, prop, bin columns
rf <- h2o.randomForest(y = "bin", x = -c(1, 6, 7), training_frame = wet_split[[1]],
                       ntrees = 5)

# Assess performance
h2o.performance(rf, wet_split[[2]])

# Calculate variable importance
h2o.varimp(rf)
h2o.varimp_plot(rf)



# Try a neural net. We need to change some variables!
# * dtime gets split up by hour, and mins is progress through hour
# * Make categorical variables factors, so H2O knows what to do with them
# * Scale numeric variables on 0-1
df2 <- df %>%
    mutate(hr = floor(dtime), mins = (dtime %% 1)) %>%
    select(-dtime) %>%
    mutate_at(vars(wd, mth, rug, HomeWin, rain, snow, fog, hr),
              funs(factor(.))) %>%
    mutate_if(is.numeric, function(x) (x-min(x))/(max(x)-min(x)))

wet2 <- as.h2o(df2)
wet_split2 <- h2o.splitFrame(wet2, ratios = 0.8)

nn <- h2o.deeplearning(y = "bin", x = -c(1, 5, 6), training_frame = wet_split2[[1]],
                       hidden = c(50, 50))

h2o.performance(nn, wet_split2[[2]])
h2o.varimp(nn)
h2o.varimp_plot(nn)
