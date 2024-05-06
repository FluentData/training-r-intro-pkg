#' Run a specified lesson from the available tutorials
#'
#' This function allows the user to run a specific lesson from the available tutorials in the `trainingRIntro` package.
#' It prompts the user to select a lesson if not specified. It checks the validity of the input and handles errors
#' appropriately, ensuring that only available lessons can be run.
#'
#' @param number An optional integer specifying the lesson number to run.
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
run_lesson <- function(number = NA) {

  x <- learnr::available_tutorials()
  x <- x[x$package == "trainingRIntro", ]

  if(nrow(x) == 0) {
    stop("No lessons found")
  }

  # If number is NA (not provided), prompt user to choose a lesson
  if(is.na(number)) {
    cat("Please choose a lesson to run by entering its number:\n")
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

  # Check if number is within the valid range and run the lesson
  if(number > 0 & number <= nrow(x)) {
    message("Running lesson: ", x$title[number])
#      options(shiny.launch.browser = "pane")
      print(learnr::run_tutorial(x$name[number], "trainingRIntro"))
  } else {
    stop("Invalid lesson number")
  }

}

