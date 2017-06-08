#===============================================================================
# BMLM Team R: Decision trees for parking prediction
#===============================================================================


#===== Preparing our data =====

# Load the BANEScarparking package (for the data!)
# Install or update first if necessary (make sure you're on v0.1.3):
# install.packages("devtools")
# devtools::install_github("owenjonesuob/BANEScarparking")
library(BANEScarparking)

# Take a random sample (~25% of total records) to make train/test sets in a
# minute
# * Here we're using "full_dataset" from the package, which is records up to end
#   of 2016 - for more recent records look at refuel(), get_all_crude(),
#   refine(), in the package documentation
smp <- sample(1:nrow(full_dataset), 300000)

# Load packages for manipulating data
library(dplyr)
library(lubridate)

# Set up a new data frame: create variables we will "split" on
df <- transmute(full_dataset,
                Date = date(LastUpdate),
                n = Name,
                t = (hour(LastUpdate) + minute(LastUpdate)/60), # decimal time
                wd = wday(LastUpdate),
                m = month(LastUpdate),
                occ = Occupancy,
                # Is there a rugby match on that day? Make a boolean column
                #   "rugby" data frame is from BANEScarparking
                rug = (date(LastUpdate) %in% date(rugby$GMT))) 

# Add a "count" column, with a daily "event count" from www.bath.co.uk/events
# * "events" data frame is also from BANEScarparking! But have a look at the
#   documentation for get_events() and get_rugby() in the package, if you want
#   to update with more recent records. They scrape the relevant websites to
#   get the data. The code for those functions is really well commented so if
#   you want to do some web scraping yourself have a look at the code by
#   calling View(get_rugby) or View(get_events)
df <- inner_join(df, events, by = "Date")



# Add precipitation columns from weather data!
precip <- select(weather, Date, rain = Rain, snow = Snow)
df <- inner_join(df, precip, by = "Date")


# Create our test and train datasets
test <- df[smp, ]
train <- df[-smp, ]





#===== Decision trees =====

# We're gonna use a decision tree! The package rpart does them well
# install.packages("rpart") if you need to
library(rpart)

# Train a basic tree: predict occupancy by splitting on decimal time, weekday
# and month
tree0 <- rpart(occ ~ t + wd + m, data = train, method = "anova")

# Have a look at what decisions the tree is making
plot(tree0)
text(tree0, cex = 0.7)

# Make some predictions
preds0 <- predict(tree0, test)

# Let's see if they look close, for the first 50 data points in "test"
# * Set up an empty plot
plot(test$occ[1:50] ~ c(1:50), type = "n")
# * Add actual values in black
lines(test$occ[1:50] ~ c(1:50))
# * Add values predicted by tree0 in blue
lines(preds0[1:50], col = "blue")


# Not too bad... but let's add some more variables and more nodes. The tree will
# be much more complicated, but essentially doing the same thing!
# * Split on name, decimal time, weekday, month, rugby, event count
# * Split with a lower-than-default complexity parameter "cp", to get a deeper
#   tree
tree1 <- rpart(occ ~ n + t + wd + m + rug + count, data = train,
               minbucket = 10, maxcompete = 30, cp = 0.00001)

# Make some predictions
preds1 <- predict(tree1, test)

# Add them to our previous plot
lines(preds1[1:50], col = "red")

# Let's calculate how far off we are, on average:
# Calculate residuals; square them (to make them positive); sume them up (so
# we've found the RSS of our tree!); find average squared residual by dividing
# by the number of predictions made; take a square root to find average error in
# our predictions!

# * tree0 (basic tree)
sqrt(sum((test$occ - preds0)^2) / 300000)

# * tree1 (with extra features)
sqrt(sum((test$occ - preds1)^2) / 300000)

# So tree0 is wrong by, on average, ~150 cars and tree1 by ~60 cars!

# (We can try to look at tree1 but it's very messy...)
plot(tree1, uniform = TRUE)
text(tree1, cex = 0.5)



#===== Random forests =====

# Would a random forest of trees be any better?
# install.packages("randomForest")
library(randomForest)

# Make a forest of 10 trees. Use large buckets so that the trees aren't too big
# (This takes a while to train...)
forest <- randomForest(occ ~ n + t + wd + m + rug + count, data = train,
                       ntree = 10, nodesize = 10000)

# Let's make some predictions
predsrf <- predict(forest, test)
sqrt(sum((test$occ - predsrf)^2) / 300000)

# Seemingly, not that great :( well, better than tree0 but not tree1

# Try deeper trees? (but this will take AGES!)
# Start with 1 tree...
forest2 <- randomForest(occ ~ n + t + wd + m + rug + count, data = train,
                        ntree = 1, nodesize = 200)

# Any good?
predsrf2 <- predict(forest2, test)
sqrt(sum((test$occ - predsrf2)^2) / 300000)

# Nyeah. Better. We can add more trees... say, add 19 trees, so we get a forest
# of 20. WARNING that this takes absolutely ages. As in, I think it took an hour
# on a reasonably fast machine (a library computer).
forest2 <- grow(forest2, 19)

# Is it any better? I don't know, I didn't get this far to be honest!



#===== Other things to try? =====

# * There's a "weather" data frame in BANEScarparking too - maybe rain or snow
#   has an effect on parking
# * A C5.0 regression tree (Package "c50")
# * Different set-ups of randomForest


#===== M5P model tree =====

library(RWeka)

trainsmp <- sample(1:1315713, 300000)
testsmp <- sample(1:1315713, 80000)
m5p <- M5P(occ ~ ., train[trainsmp, ], control = Weka_control(M = 10000))

m5preds <- predict(m5p, test[testsmp, ])
sqrt(sum((test$occ[testsmp] - m5preds)^2, na.rm = TRUE) / 10000)



#===== Simple linear model =====

lmod <- lm(occ ~ ., train)
lpreds <- predict(lmod, test)

sqrt(sum((test$occ - lpreds)^2) / 300000)
