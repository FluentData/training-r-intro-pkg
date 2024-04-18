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
    learnr::run_tutorial(x$name[number], "trainingRIntro")
  } else {
    stop("Invalid lesson number")
  }

}

