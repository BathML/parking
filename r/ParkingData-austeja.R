# Simple cleaning on the raw parking data. Duplicates are not removed in this version. 

library(readr)
BANEScarpark <- read_csv("~/Downloads/BANES_Historic_Car_Park_Occupancy.csv")
head(BANEScarpark)

BANEScarpark <- BANEScarpark[,c("Name","DateUploaded", "LastUpdate","Capacity","Occupancy","Percentage")]
install.packages("lubridate", dependencies = TRUE) 
require(lubridate)
lubridate::date #to prevent masking that happened to me
lubridate::year
BANEScarpark$DateUploaded = as.POSIXct(BANEScarpark$DateUploaded, format = "%d/%m/%Y %H:%M:%S") 
BANEScarpark$LastUpdate = as.POSIXct(BANEScarpark$LastUpdate, format = "%d/%m/%Y %H:%M:%S")
BANEScarpark <- subset(BANEScarpark, year(DateUploaded) >= 2015) 
BANEScarpark <- BANEScarpark[ ! BANEScarpark$Name %in% c("test car park"), ]  #remove test carpark
colSums(is.na(BANEScarpark)) #check if we have any NAs
BANEScarpark <- BANEScarpark[complete.cases(BANEScarpark), ] #remove NAs 
BANEScarpark <- BANEScarpark[BANEScarpark$Occupancy >= 0,] # remove negative Occupancy
BANEScarpark <- BANEScarpark[BANEScarpark$Percentage >= 0,] # remove negative Percentage
BANEScarpark <- BANEScarpark[BANEScarpark$Percentage <= 110,] # remove % over 110 
BANEScarpark <- mutate(BANEScarpark, Name = recode(Name, "Avon Street CP" = "Avon", 
                                                   "Charlotte Street CP" = "Charlotte", 
                                                   "Lansdown P+R" = "Lansdown",
                                                   "Newbridge P+R" = "Newbridge",
                                                   "Odd Down P+R" = "OddDown",
                                                   "Podium CP" = "Podium",
                                                   "SouthGate General CP" = "SouthGate",
                                                   "SouthGate Rail CP" = "SouthgateRail",
                                                   "test car park" = "testcarpark"))

#set seconds to 0 because we don't care such details
second(BANEScarpark$DateUploaded) = 0
second(BANEScarpark$LastUpdate) = 0

#encode parking availability 
P <- BANEScarpark$Percentage #dummy variable
BANEScarpark$Availability <- ifelse(P >= 0 & P < 20, 0, 
                                    ifelse( P >= 20 & P < 40, 1,
                                            ifelse( P >= 40 & P <60, 2,
                                                    ifelse( P >= 60 & P < 80, 3,  4))))

#encode time of the day as 0 midnight / 1 morning / 2 afternoon / 3 evening
BANEScarpark$timeoftheday <- ifelse(hour(BANEScarpark$DateUploaded) >=0 & hour(BANEScarpark$DateUploaded) < 6 , 0, 
                                    ifelse(hour(BANEScarpark$DateUploaded) >= 6 & hour(BANEScarpark$DateUploaded) < 12, 1,
                                           ifelse(hour(BANEScarpark$DateUploaded) >= 12 & hour(BANEScarpark$DateUploaded) < 18, 2, 3)))

#create a weekday column, then encode it 
BANEScarpark$weekday <- as.factor(weekdays(BANEScarpark$DateUploaded))
M <- BANEScarpark$weekday #dummy variable
BANEScarpark$weekdayFeature <-ifelse(M == "Monday", 0, 
                                     ifelse( M == "Tuesday", 1,
                                             ifelse(M == "Wednesday", 2,
                                                    ifelse( M == "Thursday", 3,
                                                            ifelse(M == "Friday", 4,
                                                                   ifelse(M == "Saturday", 5, 6))))))
#add month, hour, minute, week number column
BANEScarpark$month <- month(BANEScarpark$DateUploaded)
BANEScarpark$hour <- hour(BANEScarpark$DateUploaded)
BANEScarpark$minute <- minute(BANEScarpark$DateUploaded)
BANEScarpark$weeknumber <- strftime(BANEScarpark$DateUploaded, format="%W")
BANEScarpark$weeknumber <- as.integer(BANEScarpark$weeknumber)

#season column, encoded as 0 spring / 1 summer / 2 autumn / 3 winter
BANEScarpark$season <- ifelse(month(BANEScarpark$DateUploaded) >=3 & month(BANEScarpark$DateUploaded) < 6, 0, 
                              ifelse(month(BANEScarpark$DateUploaded) >= 6 & hour(BANEScarpark$DateUploaded) < 9, 1,
                                     ifelse(hour(BANEScarpark$DateUploaded) >= 9 & hour(BANEScarpark$DateUploaded) < 12, 2,  3)))

#save as a csv file
write.csv(BANEScarpark, file = "BANEScarpark.csv")


# EXTRA
# If you want only one carpark, say SouthGate carpark
SouthGatedf <- filter(BANEScarpark) 
SouthGatedf <- arrange(SouthGatedf, DateUploaded) #can arrange by date like this




