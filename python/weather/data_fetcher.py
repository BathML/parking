import requests
from pprint import pprint
from secrets import API_KEY

BASE_URL = f"https://api.darksky.net/forecast/{API_KEY}/"
QUERY_PARAMS = "?units=si"

BATH_LAT = 51.3758
BATH_LONG = 2.3599
BATH_URL = f"{BASE_URL}{BATH_LAT},{BATH_LONG}{QUERY_PARAMS}"


class DataFetcher:
    """
    The DataFetcher uses the darksky.net API to fetch historical and predicted
    weather forecasts.
    """

    def __init__(self):
        # Requirement for using the API.
        # Should we ever make a more GUI friendly application that takes
        # advantage of this API we'll need to put this as near the data
        # as possible.
        print("Powered by Dark Sky")

    def persist_current_weather_data(self):
        payload_dict = requests.get(BATH_URL).json()
        self.__persist_to_mongo(self.__get_relevant_data(payload_dict))

    def __get_relevant_data(self, payload_dict):
        """
        Would like to extract:

        temperature
        apparentTemperature
        percipIntensity
        percipProbability
        windSpeed
        windGust
        visibility
        summary


        for every hour.
        """

        desired_data = [None] * 24
        relevant_keys = ('temperature',
                         'apparentTemperature',
                         'percipIntensity',
                         'percipProbability',
                         'windSpeed',
                         'windGust',
                         'visibility',
                         'summary')

        for i in range(24):
            hourly_data = payload_dict['hourly']['data'][i]
            desired_data[i] = {k: hourly_data[k]
                               for k in relevant_keys
                               if k in hourly_data}

        return {'hourlyData': desired_data}

    def __persist_to_mongo(self, payload):
        print("Persisting to mongo...") # TODO: make this true
        pprint(payload)


fetcher = DataFetcher().persist_current_weather_data()
