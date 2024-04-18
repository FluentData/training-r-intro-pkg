#'@export
build_exercises <- function(json_data) {
  exercises <- json_data$Exercises
  question_list <- lapply(exercises, function(exercise) {
    question_title <- sprintf("Question %d", exercise$ExerciseNumber)
    question_description <- exercise$Description
    solution_code <- exercise$Solution$Code
    explanation <- ifelse(is.null(exercise$Solution$Explanation), "", exercise$Solution$Explanation)

    # Handle multiple solutions
    if (is.character(solution_code)) {
      solution_code <- list(solution_code)
    }
    check_code <- paste(sapply(solution_code, function(code) {
      sprintf("gradethis::grade_this_code(correct = \"%s\")", str_replace_all(code, "\"", "\\\\\""))
    }), collapse = "\n")

    question_md <- sprintf(
      "```{r %s, echo = FALSE}\nquestion(\"%s\",\n  question_text(\"%s\",\n    code = \"\",\n    hint = \"%s\"\n  ),\n  %s\n)\n```\n",
      question_title, question_title, question_description, explanation, check_code
    )
    question_md
  })

  paste(question_list, collapse = "\n")
}
