data_dir <- "~/.training-r-intro"

.onAttach <- function(libname, pkgname) {

  if(interactive()) {
    if(!dir.exists(data_dir)) {
      dir.create(data_dir, recursive = TRUE, showWarnings = FALSE)
    }

    first_time <- is.null(get_user_state("last_opened"))

    set_user_state("last_opened" = Sys.time())

    message <- paste0(
      crayon::blue("\n\n======================================================\n\n"),
      crayon::green(crayon::bold("   Introduction to R for Air Quality Data Science\n\n")),
      crayon::green("                  Produced by\n"),
      crayon::green("                     LADCO\n"),
      crayon::green("                      and\n"),
      crayon::green("                  Fluent Data"),
      crayon::blue("\n\n======================================================\n\n")
    )

    message(message)

    if(first_time) {
      message <- paste0(
        crayon::green("This is a self-paced tutorial designed to introduce you to the R programming language and its use in air quality data science.\n\n"),
        crayon::green("The tutorial is divided into several lessons, each of which covers a different aspect of R programming.\n\n"),
        crayon::green("To get you started we have typed", crayon::underline(crayon::bold("start_training()")), "at the prompt below. All you need to do is press", crayon::bold("Enter."), "\n")
      )
      message(message)
      rstudioapi::sendToConsole("start_training()", execute = FALSE, animate = TRUE)
    } else {
      message(crayon::red("To get started or continue where you left off, type", crayon::underline(crayon::bold("start_training()")), "at the prompt below and press", crayon::bold("Enter."), "\n"))
    }
  }

}
