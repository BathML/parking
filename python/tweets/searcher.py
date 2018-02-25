# This is a "tweet grabber" script - when run, it searches the Twitter archive and
# finds all tweets matching a certain query, and then stores them in a mongoDB mLab database.


# Import modules (you may need to `pip install` these at the command line):
# - tweepy, for interacting with the Twitter API
# - json, for working with the tweets themselves (they are returned as json objects)
# - pymongo, for connecting to a mongoDB mLab database where we'll store the tweets
import tweepy, json, pymongo


# Set up API - replace keys with your own: https://apps.twitter.com/
CONSUMER_KEY = "<CONSUMER_KEY>"
CONSUMER_SECRET = "<CONSUMER_SECRET>"
ACCESS_KEY = "<ACCESS_KEY>"
ACCESS_SECRET = "<ACCESS_SECRET>"
auth = tweepy.OAuthHandler(CONSUMER_KEY, CONSUMER_SECRET)
auth.set_access_token(ACCESS_KEY, ACCESS_SECRET)
api = tweepy.API(auth)


# Bath, England place id for twitter api is "1db4f0a70fc5c9db", found using api.geo_search:
# api.geo_search(query="Bath, England", granularity="city")[0]
# We'll search for tweets from here
search_query = "place:1db4f0a70fc5c9db"

# Max tweets to grab in one go (just a big number)
max_tweets = 1000000000
# Set to max per query that API allows (100)
tweets_per_query = 100

# Connect to the mLab database
client = pymongo.MongoClient("mongodb://shareduser:shareduser@ds123614.mlab.com:23614/bmlm-parking-tweets")
db = client["bmlm-parking-tweets"]

# If we already have some tweets, get the date of the most recent, and only look for tweets after that
try:
    most_recent = db.shared.find_one(sort=[("id", pymongo.DESCENDING)])
    since_id = most_recent["id"]
except:
    # Otherwise get all tweets that the API allows us to
    since_id = None

# Start from the most recent tweet matching the search query
max_id = -1


# Initialise a list to temporarily store the tweets
tweets_to_add = []
tweet_count = 0

print("Downloading max {0} tweets".format(max_tweets))

# Keep going until we hit max (or run out of tweets to get)
while tweet_count < max_tweets:
    
    # Grab a block of tweets
    if (max_id <= 0):
        if (not since_id):
            new_tweets = api.search(q=search_query, count=tweets_per_query)
        else:
            new_tweets = api.search(q=search_query, count=tweets_per_query,
                                    since_id=since_id)
    else:
        if (not since_id):
            new_tweets = api.search(q=search_query, count=tweets_per_query,
                                    max_id=str(max_id - 1))
        else:
            new_tweets = api.search(q=search_query, count=tweets_per_query,
                                    max_id=str(max_id - 1),
                                    since_id=since_id)
    if not new_tweets:
        print("No more tweets found")
        break
    
    # Add this block of tweets to our list
    tweets_to_add.extend([status._json for status in new_tweets])
    tweet_count += len(new_tweets)
    
    print("Downloaded {0} tweets".format(tweet_count))
    
    # Set starting point for next block
    max_id = new_tweets[-1].id

# If we found some new tweets, add them to the "shared" collection in mLab database
if tweet_count > 0:
    db.shared.insert_many(tweets_to_add)
    print ("Downloaded {0} tweets, saved to mLab database".format(tweet_count))
else:
    print("No tweets to add :(")