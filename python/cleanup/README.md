# Cleanup code repository

In this folder, you can find some useful python code that 
  * cleans up raw BANES data (`transform-records.py`)
  * integrates the cleaned up data with Bath Events, Bath Rugby and Weather data (`main.py`)

To do list:
1. In `transform-records.py`, need to add a function for removing duplicates that occur in the dataset when sensors break and send the same reading over a period of time,
2. In `main.py`, need to get the *weekday* column from *Date* column,
3. In `main.py`, need to convert categorical data in string format to numerical format

## Some useful resources

If you are a seasoned R user who is interested in learning Python, then you might find [this resource](https://pandas.pydata.org/pandas-docs/stable/comparison_with_r.html) useful on `Pandas` operators that are equivalent to R's `dplyr`

