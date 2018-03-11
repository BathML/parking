# Very often R.exe & Rscript.exe do not have information where the user packages are installed,
# when they are run non-interactively. The R_USER_LIBS environment variable should be defined
# on the system and contain information on where to search.
if (length(.libPaths()) == 1) {
  user_lib <- Sys.getenv("R_USER_LIBS")
  .libPaths(user_lib)
}

library(plumber)
library(h2o)

h2o.init()
h2o.loadModel("./models/BANEScarparking_rf")

BANES <- plumb("./h2oserv.R")

BANES$registerHook("exit", function(){
  h2o.shutdown(prompt = FALSE)
  print("Bye bye!")
})

BANES$run(port=55111)


