#1 Data Collection and preparation 
BANEScarparking <- read.csv("/Users/Austeja/Desktop/BANES_Historic_Car_Park_Occupancy.csv", header=TRUE) 
BANEScarparking$Name[1:10] # takes the column called Name
BANEScarpark <- BANEScarparking
head(BANEScarpark,1) #view one line

# create a data frame with the columns we will be using
library(dplyr)
df <- select(BANEScarpark,Name,LastUpdate,Capacity,Status,Occupancy,Percentage,DateUploaded) %>%
mutate(LastUpdate = as.POSIXct(LastUpdate, format = "%d/%m/%Y %I:%M:%S %p")) %>%
mutate(DateUploaded = as.POSIXct(DateUploaded, format = "%d/%m/%Y %I:%M:%S %p"))
head(df,3) #view 3 lines

# (Explanation of the code)
#    pipe %>%  it will pass whatever you've just done to the direction of arrow
#    mutate(LastUpdate = ) will write over on top of LastUpdate
#    POSIXct is a data format in R - but look at strptime for all the abbreviations
#    mutate - changing data in some way (mutating)
#    turning text into date

# Explore data
summary(df$Name)
summary(df$Capacity)
summary(df$Status)
summary(df$Occupancy) # includes negative!
summary(df$Percentage)  #includes negative!
summary(df$DateUploaded)

# remove negative Occupancy
df <- subset( df, df$Occupancy > 0)
# remove negative Percentage
df <- subset( df, df$Percentage >0) 
# also remove percentage over 100 to simplify the data
df <- subset( df, df$Percentage <101) 

# clean occupancy - remove duplicates

#rename carparks for simplicity
df <- mutate(df, Name = recode(Name, "Avon Street CP" = "Avon", 
                                       "Charlotte Street CP" = "Charlotte", 
                                       "Lansdown P+R" = "Lansdown",
                                       "Newbridge P+R" = "Newbridge",
                                       "Odd Down P+R" = "OddDown",
                                       "Podium CP" = "Podium",
                                       "SouthGate General CP" = "SouthGate",
                                       "SouthGate Rail CP" = "SouthgateRail",
                                       "test car park" = "testcarpark"))

#modify the time from exact hours to morning/daytime/evening for simplicity
df <- mutate(df, Morning=(hour(LastUpdate)<=12), 
             Midday =(hour(LastUpdate)>12 & hour(LastUpdate)<=15 ) ,
             Evening=(hour(LastUpdate)>15 & hour(LastUpdate)<=18),
             Night  =(hour(LastUpdate)>18),
             IsWeekend=(wday(LastUpdate)==7 | wday(LastUpdate)==1))

# Pick which carpark to work on
library(lubridate)
Avondf <- filter(df,Name == "Avon")  #Make a data frame only for Avon carpark
hist(Avondf$Percentage) #can see that this carpark is barely full
# try another carpark
SouthGatedf <- filter(df,Name == "SouthGate") #Make a data frame only for SouthGate carpark
hist(SouthGatedf$Percentage) #this carpark seems more interesting to work with
summary(SouthGatedf)

# Try some basic linear models for SouthGate carpark - but is linear modelling appropriate here?
linreg1<-lm( Percentage ~ wday(LastUpdate)+hour(LastUpdate), data=SouthGatedf) #?
summary(linreg1)
linreg2 <- lm(Percentage ~ IsWeekend + Morning + Midday + Evening + Night, data=SouthGatedf)  #?
summary(linreg2)

# Comment - But in the future when we will want to predict, we will need to 
#           factors such as the time, day of week, weather, special events and holidays.
#           free carparking times

# Exploratory data analysis (EDA) - make plots to explore data
March16SG <- filter(SouthGatedf,month(DateUploaded)==3,year(DateUploaded)==2016) #lubridate pulled out month from DateUploaded
plot(Percentage ~ LastUpdate, data=March16SG) # plot for March 2016 SouthGate carpark

March4th16SG <- filter(SouthGatedf,month(DateUploaded)==3,year(DateUploaded)==2016, day(DateUploaded)==4)
weekdays(March4th16SG$LastUpdate) #shows it is a Friday
plot(Percentage~LastUpdate, data=March4th16SG, main="04/03/2016 Friday") #busy lunch time
m<-nls(Percentage~a*LastUpdate/(b+LastUpdate))  #not right
lines(LastUpdate,predict(m),lty=2,col="red",lwd=3)

March11th16SG <- filter(SouthGatedf,month(DateUploaded)==3,year(DateUploaded)==2016, day(DateUploaded)==11) #try another Friday
weekdays(March11th16SG$LastUpdate) #Friday
plot(Percentage~LastUpdate, data=March11th16SG, main="11/03/2016 Friday")  #busy lunch time and 8-9pm

March5th16SG <- filter(SouthGatedf,month(DateUploaded)==3,year(DateUploaded)==2016, day(DateUploaded)==5)
weekdays(March5th16SG$LastUpdate) #Saturday
plot(Percentage~LastUpdate, data=March5th16SG, main="05/03/2016 Saturday") #busy 10-5pm, 8-9pm and random

March6th16SG <- filter(SouthGatedf,month(DateUploaded)==3,year(DateUploaded)==2016, day(DateUploaded)==6)
weekdays(March6th16SG$LastUpdate) #Sunday
plot(Percentage~LastUpdate, data=March6th16SG, main="06/03/2016 Sunday")  #busy 12-3pm

Bathhalf16 <- filter(SouthGatedf,month(DateUploaded)==3,year(DateUploaded)==2016, day(DateUploaded)==13)
weekdays(Bathhalf16$LastUpdate) #Sunday
plot(Percentage~LastUpdate, data=Bathhalf16, main="13/03/2016 Sunday, Bath Half Marathon")  
# Comments - It reached its maximum occupancy 32% by 12:14 noon. Reached 30% by 10:44am.
#            That could be when the marathon starts.
#            Further reading - http://bathhalf.co.uk/race-day/travel-information/


# More Linear Models
a1 <- lm(log(Percentage)~LastUpdate, data=March4th16SG) #try to linearise the model by transforming the data?
plot(log(Percentage)~LastUpdate, data=March4th16SG)
abline( lm(log(Percentage)~LastUpdate, data=March4th16SG) )  #not good enough

# ML
# Approach 1 (as in Google research paper)
# Predict carparking availability (not exact numbers!) using logistic regression
# Idea from a Google research paper https://research.googleblog.com/2017/02/using-machine-learning-to-predict.html
# Example - Percentage <30=easy, 30-60=less easy, 60-90=hard, 90>Limited availability
# Supervised learning to predict future occupancy percentage, hence regression algorithm.

# GLM - 

glm1 <- glm(Percentage/100 ~ IsWeekend + Morning + Midday + Evening + Night, 
            data=SouthGatedf, family = binomial)
summary(glm1)

# Approach 2 
# Predict occupancy percentage using glm 


# Approach 3
# Decision tree algorithms 
# CART - classification and regression trees


# Approach 4
# Time series forcasting (after glm)
# https://www.analyticsvidhya.com/blog/2015/12/complete-tutorial-time-series-modeling/
