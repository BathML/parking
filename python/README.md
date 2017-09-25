# Python code repository

Python code exploring different approaches to the project.
You can find the following Jupyter Notebooks here 
  * `analyze-data.ipynb`   for raw data exploration
  * `predict-simple.ipynb`   for simple linear model for predicitions for one of the car parks
  * `predict-decision-tree.ipynb`   for using decision trees for predictions

The [BANES Historic Car Park Occupancy](https://data.bathhacked.org/Government-and-Society/BANES-Historic-Car-Park-Occupancy/x29s-cczc) dataset requires considerable cleaning before ML algorithms can be developed for predictions. 

On top of that, the occupancy data alone does not provide enough features to create accurate predictions - the only features it has are: date (year, month, day, day of the week, time), car park names and occupancy ratios. In order to get more data, we've written web-scraping scripts ([currently only in R](https://github.com/Bath-ML/parking/blob/master/r/BANEScarparkinglite/R/web_scraping.R)) to get Bath Events, Rugby Games and Weather data.

In the **cleanup** folder, you can find some useful python code that 
  * cleans up raw BANES data (`transform-records.py`)
  * integrates the cleaned up data with Bath Events, Bath Rugby and Weather data (`main.py`)


## Some useful links for those starting out in Python

You can download Python via [anaconda distribution](https://www.anaconda.com/download/) which will download Python IDE called Spyder for you as well as Jupyter Notebooks.

It's worth getting familiar with the following useful libraries for data wrangling and analysis before diving into the deep end:
  * [Pandas](http://pandas.pydata.org/) - library of high-performance, easy-to-use data structures and data analysis tools 
  * [NumPy](http://www.numpy.org/) - a powerful package for scientific computing (e.g. dealing with large data frames)

The ML library we are currently exploring for predicting the car parking occupancy is [scikit learn](http://scikit-learn.org/stable/). If you know how to use it and wouldn't mind helping us - please let us know! 



