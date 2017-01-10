.onAttach <- function(libname, pkgname) {

    messages <- vector("character", 10)
    messages[1] <- paste0("Why is R$elevation > 0?",
                          " Because R is above C level...")
    messages[2] <- paste0("Fun fact: at 15:29 on 5th May 2015, ",
                          "SouthGate General CP contained -14787 cars.")
    messages[3] <- "Have you tried asking R if \"Team R\" > \"Team Python\"?"
    messages[4] <- "Bath Machine Learning Meetup => iMpenetraBLe huMan teaching"
    messages[5] <- "ALL YOUR BANES ARE BELONG TO US"
    messages[6] <- "We think, therefore we R"
    messages[7] <- "More records than Guinness"
    messages[8] <- paste0("\"I wish I'd written this package myself, ",
                          "it's way better than all mine!\" - hadley")
    messages[9] <- "84% of statistics are made up on the spot"
    messages[10] <- paste0("Written by an Andrew Ng-verified \"expert on ",
                           "machine learning\"")

    i <- sample(1:10, 1)
    packageStartupMessage(sprintf(paste0("\nWelcome to the BANEScarparking ",
                                         "package!\n\n##  %s\n"),
                                  messages[i]))
}
