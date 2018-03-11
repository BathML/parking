library(h2o)

#* @get /score
get_score <- function(name, dtime, weekday, month, rugby, homewin, events, rainmm, is_rain, is_snow, is_fog) {
  
  # make sure that all parameters are the same as in the training frame
  to_pred <- data.frame(name = factor(name, levels = c("Avon Street CP", "Charlotte Street CP", 
                                                        "Lansdown P+R", "Newbridge P+R", "Odd Down P+R", 
                                                        "Podium CP", "SouthGate General CP", "SouthGate Rail CP")),
                         dtime = as.numeric(dtime),
                         wd = as.numeric(weekday),
                         mth = as.numeric(month),
                         rug = as.logical(rugby),
                         HomeWin = as.logical(homewin),
                         count = as.numeric(events),
                         rainmm = as.numeric(rainmm),
                         rain = as.logical(is_rain),
                         snow = as.logical(is_snow),
                         fog = as.logical(is_fog))
  
  # create temporary unique name of the data.frame in h2o
  # this will help avoid conflicts when two or more queries happen at the same time
  temp_h2o_name <- paste0("to_pred_", floor(runif(1, max = 999999)))

  # import frame into h2o and get its ID
  to_pred_h2o <- as.h2o(to_pred, destination_frame = temp_h2o_name)
  to_pred_id <- h2o.getId(to_pred_h2o)
  
  # get the reference to the model in h2o which we want to use
  rfmodel <- h2o.getModel("BANEScarparking_rf")
  
  preds <- h2o.predict(rfmodel, to_pred_h2o)
  
  # remove the temporary data frame from h2o cluster
  h2o.rm(to_pred_id)
  
  # head by default returns a data frame, and maintains nice column names
  # preds is not a data frame and fails when serialized to json
  # by default serialized through jsonlite::toJSON()
  return(head(preds, 1))
}

