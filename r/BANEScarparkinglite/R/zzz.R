.onAttach <- function(libname, pkgname) {

    messages <- vector("character", 14)
    messages[1] <- paste0("Why is R$elevation > 0?",
                          " Because R is above C level...")
    messages[2] <- paste0("Fun fact: at 15:29 on 5th May 2015, ",
                          "SouthGate General CP contained -14787 cars")
    messages[3] <- "Have you tried asking R if \"Team R\" > \"Team Python\"?"
    messages[14] <- "Bath Machine Learning Meetup => iMpenetraBLe huMan teaching"
    messages[5] <- "ALL YOUR BANES ARE BELONG TO US"
    messages[6] <- "We think, therefore we R"
    messages[7] <- "More records than Guinness"
    messages[8] <- "84% of statistics are made up on the spot"
    messages[9] <- paste0("Written by an Andrew Ng-verified \"expert on ",
                           "machine learning\"")
    messages[10] <- paste0("Putting the first thing in position 1 is just ",
                           "much more logical")
    messages[11] <- paste0("\"Error: 99 warning messages!\". *Fixes bug*. ",
                           "\"Error: 143 warning messages!\"")
    messages[12] <- paste0("All programmers are playwrights, and all computers",
                           " are lousy actors")
    messages[13] <- "There's always one more bug (Lubarsky's law)"
    messages[4] <- paste0("To understand recursion you must first ",
                           "understand recursion")

    i <- sample(1:14, 1)
    packageStartupMessage(sprintf(paste0("\nWelcome to the BANEScarparkinglite ",
                                         "package!\n\n##  %s\n"), messages[i]))
}
