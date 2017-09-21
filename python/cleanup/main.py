# In this file we will do data integration and then, in the future, 
# apply machine learning algorithms to do some predictions


import pandas as pd
import numpy as np
import utilities as ut
import transform_records as tr
import time as tm


# import BANES car parking data - make sure you have it in the folder where 
# this python file is stored!
rawData = pd.read_csv('../../BANES_Historic_Car_Park_Occupancy.csv') 

# view the first 10 rows of the data
rawData.head(10)

# Just wanted to time this operation for reference (use time package in python 
# for this)
t = tm.time()
# transform the data so that it is in a format suitable for further analysis
OccupancyDF = tr.refine(rawData, 1.1)
elapsed = tm.time() - t

# Just want to extract Date and Time from LastUpdate - 
# we will do some joins on Date, so need this as a separate column
OccupancyDF['Date'] = OccupancyDF['LastUpdate'].dt.date
OccupancyDF['Time'] = OccupancyDF['LastUpdate'].dt.time


##########################################################################
# Do some work with external data

# Import rugby, events and weather data - make sure you have it in the folder where 
# this python file is stored!

RugbyDF = pd.read_csv('../../Rugby_events.csv') 
EventsDF = pd.read_csv('../../Bath_events.csv') 
WeatherDF = pd.read_csv('../../Weather.csv') 

# Now select the columns you need in Rugby dataset
RugbyDF = RugbyDF[['GMT', 'HomeWin'] ]  
# and alter the format of the GMT column
RugbyDF['GMT'] = pd.to_datetime(RugbyDF['GMT'], format = '%Y-%m-%d %H:%M:%S')
# extract Date and Time from GMT
RugbyDF['Date'] = [d.date() for d in RugbyDF['GMT']]
RugbyDF['Time'] = [d.time() for d in RugbyDF['GMT']]


# Same for Events Data:
EventsDF = EventsDF[['Date', 'count']]
EventsDF['Date'] = pd.to_datetime(EventsDF['Date'], format = '%d/%m/%Y')
EventsDF['Date'] = [d.date() for d in EventsDF['Date']]

# Same for Weather Data:
WeatherDF = WeatherDF[['Date', 'Max TemperatureC', 'Mean TemperatureC', 'Min TemperatureC',
                       'Events']]  
WeatherDF['Date'] = pd.to_datetime(WeatherDF['Date'], format = '%d/%m/%Y')
WeatherDF['Date'] = [d.date() for d in WeatherDF['Date']]

# This is to calculate the start and end dates for all datasets. 
# It will tale a little bit of time to run:
    # StartDate = Timestamp('2014-10-17 03:43:21')
    # EndDate = Timestamp('2016-10-31 12:59:26')
StartDate = max(min(OccupancyDF['Date']), min(RugbyDF['Date']), 
                min(EventsDF['Date']), min(WeatherDF['Date']))
EndDate = min(max(OccupancyDF['Date']), max(RugbyDF['Date']), 
                max(EventsDF['Date']), max(WeatherDF['Date']))

###########################################################################
#   Do some intermediate table joins:
    
# Begin by merging car park occupancy dataset with Rugby data
Merge1 = pd.merge(OccupancyDF[(OccupancyDF.LastUpdate >=StartDate) & 
                              (OccupancyDF.LastUpdate <=EndDate)],
                  RugbyDF[(RugbyDF.Date >=StartDate) & 
                              (RugbyDF.Date <=EndDate)], on='Date', how='left')
 
# After the merge there is a little bit of cleaning to do:
    # 1. if there is no data about rugby games on a particular day, 
    #    then record RugbyPlayed as 0; otherwise it's 1
Merge1['RugbyPlayed'] = np.where(Merge1.HomeWin.isnull(), 0, 1)
    # 2. drop data columns that we don't need - e.g. duplicates
Merge1.drop(['GMT', 'HomeWin', 'Time_y'], axis=1, inplace = 'True')
    # 3. rename the time column 
Merge1 = ut.RenameColumn(Merge1, 'Time_x','Time')

#Now merge Events data with the Weather data
Merge2 = pd.merge(EventsDF[(EventsDF.Date >=StartDate) & 
                              (EventsDF.Date <=EndDate)], 
                  WeatherDF[(WeatherDF.Date >=StartDate) & 
                              (WeatherDF.Date <=EndDate)], on='Date', how='left')

# Cleaning up after the merge:
    # I am going to remove Min and Max tempteratures and only keep teh mean
    # but we might include them later!
Merge2.drop(['Max TemperatureC', 'Min TemperatureC'], axis=1, inplace='True')

ut.RenameColumn(Merge2, 'count', 'EventsCount')
ut.RenameColumn(Merge2, 'Events', 'DrivingCond')
ut.RenameColumn(Merge2, 'Mean TemperatureC', 'MeanTemp')


###########################################################################
#    Do the final merge:
    
IntegratedDF = pd.merge(Merge1, Merge2, on= 'Date', how = 'left')

IntegratedDF['DrivingCond'] = np.where(IntegratedDF.DrivingCond.isnull(), 'Good', IntegratedDF.DrivingCond)
