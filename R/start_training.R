#' Start the training process automatically
#'
#' This function begins an automated training sequence, advancing through lessons sequentially.
#' It continues from the last incomplete lesson, checks user state to determine lesson completion,
#' and stops if it reaches beyond the defined number of lessons without finding an incomplete one.
#' It runs the next incomplete lesson and prepares the RStudio console for further commands.
#'
#' @details The function iteratively checks the completion status of each lesson starting from the first.
#'          If all lessons up to the eighth are marked complete, it will issue an error. It leverages
#'          user state information, which should persist between sessions, to determine the starting point.
#'          The function is intended for use within an interactive RStudio environment and utilizes
#'          `rstudioapi` to manage console interactions.
#'
#' @return NULL, the function is intended to be used for its side effects of initiating a training lesson.
#' @importFrom rstudioapi sendToConsole
#' @export
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
