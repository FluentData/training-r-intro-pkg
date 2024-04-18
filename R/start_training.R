#'@export
start_training <- function() {

  lesson <- 0
  lesson_complete <- TRUE

  while(lesson_complete) {
    lesson <- lesson + 1
    lesson_complete <- get_user_state(paste0("lesson_", lesson, "_complete"))
    if(is.null(lesson_complete)) lesson_complete <- FALSE
    if(lesson > 8) {
      stop("Oops! Something went wrong!")
    }
  }

  run_lesson(lesson)
  rstudioapi::sendToConsole("start_training()", execute = FALSE, animate = FALSE)

}
