library(plumber, lib.loc = "C:/Users/piotr/OneDrive/Documents/R/win-library/3.4")
library(h2o, lib.loc = "C:/Users/piotr/OneDrive/Documents/R/win-library/3.4")

h2o.init()
h2o.loadModel("C:/Repos/model.dat/DRF_model_R_1520781866877_1")

plum <- plumb("./h2oserv.R")
plum$run(port=55111)


