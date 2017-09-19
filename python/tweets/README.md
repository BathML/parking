# Bath Tweets

Getting and experimenting with local tweets. Is town busier if more people are tweeting? Do people tweet angrily about bad traffic? Who knows, maybe we'll find something useful...


### Getting tweets

* `searcher.py` is a script which searches the Twitter archive, finds all tweets matching a certain query, and then stores them in a mongoDB mLab database. It is currently run automatically once a day at 3am by Heroku and has been collecting tweets since 26/08/2017. It usually retrieves about 500 tweets per day.
* `requirements.txt` lists the modules used by `searcher.py` and `Procfile` defines the "job" to be done: these are both used by Heroku to run the script automatically.
* `tweetloc.py` is a "stream listener" - it catches live tweets from the Twitter firehose (the "firehose" is a small proportion of all tweets which is accessible via the Twitter API), and writes these to an mLab database.

### Experimentation
* `tweets_sentiment` is an attempt to perform some sentiment analysis on the tweets in the database.