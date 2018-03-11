library(h2o, lib.loc = "C:/Users/piotr/OneDrive/Documents/R/win-library/3.4")

#* @get /score
get_score <- function(name, dtime, weekday, month, rugby, homewin, events, rainmm, is_rain, is_snow, is_fog) {
  print(name)
  df_check <- data.frame(name = factor(name, levels = c("Avon Street CP", "Charlotte Street CP", 
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
  
  print(df_check)
  
  df_check <- as.h2o(df_check)
  print(df_check)
  df_check_id <- h2o.getId(df_check)
  
  rfmodel <- h2o.getModel("DRF_model_R_1520781866877_1")
  
  preds <- h2o.predict(rfmodel, df_check)
  h2o.rm(df_check_id)
  
  return(head(preds, 1))
}

