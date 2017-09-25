# This is a "stream listener" - it catches live tweets from the Twitter firehose
# (the "firehose" is a small proportion of all tweets which is accessible via the
# Twitter API).


# Import modules (you may need to `pip install` these at the command line):
# - tweepy, for interacting with the Twitter API
# - json, for working with the tweets themselves (they are returned as json objects)
# - pymongo, for connecting to a mongoDB mLab database where we'll store the tweets
import tweepy, json, pymongo


# Set up API - replace keys with your own: https://apps.twitter.com/
CONSUMER_KEY = "<CONSUMER_KEY>"
CONSUMER_SECRET = "<CONSUMER_SECRET>"
ACCESS_KEY = "<ACCESS_KEY>"
ACCESS_SECRET = "<ACCESS_TOKEN>"
auth = tweepy.OAuthHandler(CONSUMER_KEY, CONSUMER_SECRET)
auth.set_access_token(ACCESS_KEY, ACCESS_SECRET)
api = tweepy.API(auth)


# Define a class called LocationListener which extends tweepy's StreamListener class
class LocationListener(tweepy.StreamListener):

    def __init__(self, api):
    
        # We use super() to also run the __init__() of the parent class, i.e StreamListener
        super(tweepy.StreamListener, self).__init__()
    
        # Use the API we have set up
        self.api = api
        
        # Connect to the client and specify the database
        self.client = pymongo.MongoClient("mongodb://shareduser:shareduser@ds123614.mlab.com:23614/bmlm-parking-tweets")
        self.db = self.client["bmlm-parking-tweets"]
 
 
    # on_data() runs whenever the listener "hears" a tweet
    def on_data(self, tweet):
    
        # json.loads() translates a json object into a Python dictionary object, which
        # then gets inserted into the "overheard" collection in the database
        self.db.overheard.insert_one(json.loads(tweet))
 
    # If we hit an error, return True (meaning we just carry on as if nothing happened)
    def on_error(self, status):
        return True
        
    # Same thing if we time out
    def on_timeout(self):
        return True
 
 

# Set up an instance of the class we've just defined
location_stream = tweepy.Stream(auth, LocationListener(api))

# Filter the tweets the listener is catching, so that we only get tweets matching
# a particular query - in this case we will look for tweets from Bath
# Bath bounding box: SW corner long/lat, NE corner long/lat
location_stream.filter(locations=[-2.433472, 51.344231, -2.27726, 51.413662])

# New York/San Francisco, for testing (more tweets from there!):
# locations=[NYC_SW long/lat, NYC_NE long/lat, SF_SW long/lat, SF_NE long/lat]
#location_stream.filter(locations=[-122.75, 36.8, -121.75, 37.8, -74, 40, -73, 41])


# We could search for other things too, like words/phrases
#location_stream.filter(track=["#python"])