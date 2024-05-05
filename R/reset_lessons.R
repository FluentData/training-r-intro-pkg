#' Reset a specified lesson from the available tutorials
#'
#' This function allows the user to reset a specific lesson from the available tutorials in the `trainingRIntro` package.
#' It prompts the user to select a lesson if not specified. It checks the validity of the input and handles errors
#' appropriately, ensuring that only available lessons can be reset.
#'
#' @param number An optional integer specifying the lesson number to reset.
#'               If NA (default), the function will prompt the user to choose a lesson.
#'
#' @details If `number` is not provided or is NA, the function prompts the user interactively to choose a lesson from
#'          a list of available tutorials. The function ensures that the input corresponds to a valid lesson number
#'          and provides error feedback for invalid entries.
#'
#' @return NULL, the function is used for its side effects of running a lesson interactively.
#' @importFrom learnr available_tutorials
#' @importFrom learnr run_tutorial
#' @export
reset_lesson <- function(number = NA) {

  x <- learnr::available_tutorials()
  x <- x[x$package == "trainingRIntro", ]

  if(nrow(x) == 0) {
    stop("No lessons found")
  }

  # If number is NA (not provided), prompt user to choose a lesson
  if(is.na(number)) {
    cat("Please choose a lesson to reset by entering its number:\n")
    for(i in 1:nrow(x)) {
      cat(i, ": ", x$title[i], "\n", sep = "")
    }

    # Using readline() to get input from user
    repeat {
      number <- as.integer(readline(prompt = "Enter the lesson number: "))
      if(!is.na(number) && number > 0 && number <= nrow(x)) break
      cat("Invalid input. Please enter a number between 1 and ", nrow(x), ".\n", sep = "")
    }
  }

  user <- Sys.info()['user']

  dir <- paste0("training.r.intro.", number)

  storage_path <- file.path(rappdirs::user_data_dir(), "R", "learnr", "tutorial", "storage", user, dir)

  if (dir.exists(storage_path)) {
    dir.remove(storage_path, recursive = TRUE)
  }

}

#' Resets the user's progress in the trainingRIntro package
#'
#' This function allows the user to reset all lessons from the available tutorials in the `trainingRIntro` package.
#'
#' @export
reset_training <- function() {

  x <- learnr::available_tutorials()
  x <- x[x$package == "trainingRIntro", ]

  if(nrow(x) == 0) {
    stop("No lessons found")
  }

  for(i in 1:nrow(x)) {
    reset_lesson(i)
  }

  if(file.exists(user_state_file())) {
    file.remove(user_state_file())
  }

  return(invisible(TRUE))

}
