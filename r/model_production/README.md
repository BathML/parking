## What is this?

These scripts expose an API through which you can run model predictions on
demand using the `plumber` package. The results are by default

* `train_and_save.R` - really just the random forest training, but saves a file
 with a model at the very end. This needs to be run first, but only once to
 generate the model file.
* `run_server.R` - loads the necessary model, function serving predictions on
request and start the server.
* `h2oserv.R` - function processing GET requests and returning predictions.

### Running a server

You can run a server in an interactive mode, or non-interactive. After you have
trained and saved the model, you have to run the `run_server.R`. Either
manually, sourcing the file, etc.

In non-interactive way this can be done like this:
`<path to Rscript.exe>/Rscript.exe run_server.R`

(I have been having trouble stopping the plumber server when run
non-interactively. If you want to test it this way, make sure that it does not
remain as an active process or it will keep blocking your port.)

### How to request the predictions

By default you can request a new prediction through a GET request with the
following variables:
* `name` - has to be exactly as it is in the training set,
* `dtime`
* `weekday`
* `month`
* `rugby`
* `homewin`
* `events`
* `rainmm`
* `is_rain`
* `is_snow`
* `is_fog`

An example:

[http://localhost:55111/score?name=Avon%20Street%20CP&dtime=19&weekday=2&
month=3&rugby=TRUE&homewin=TRUE&events=15&rainmm=0.2&is_rain=FALSE&
is_snow=FALSE&is_fog=FALSE](http://localhost:55111/score?name=Avon%20Street%20CP&dtime=19&weekday=2&month=3&rugby=TRUE&homewin=TRUE&events=15&rainmm=0.2&is_rain=FALSE&is_snow=FALSE&is_fog=FALSE)
