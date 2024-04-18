#'@export
build_learnr <- function(template_file_path, save = FALSE) {

  template <- yaml::yaml.load_file(template_file_path)

  metadata <- template$metadata
  metadata$title <- template$title

  metadata <- build_metadata(metadata, "learnr")

  setup <- "```{r setup, include=FALSE}
library(learnr)
library(gradethis)
library(trainingRIntro)
library(shiny)
```
"

  intro <- template$introduction

  content <- build_content(template$content)

  exercises <- process_exercises(template$exercises)

  next_lesson <- build_next_lesson(template$lesson)

  op <- paste(metadata, setup, intro, content, exercises, next_lesson, sep = "\n")

  if(save) {
    file_path <- paste0(tools::file_path_sans_ext(template_file_path), ".Rmd")
    writeLines(op, file_path)
    return(file_path)
  }

  return(invisible(op))

}

build_next_lesson <- function(lesson) {

  nlui <- paste0('```{r example-button, echo=FALSE}\n',
'  actionButton("complete_lesson", "Mark Lesson ', lesson$number, ' Complete")\n',
'```\n\n')

  nls <- paste0('```{r, context = "server"}\n',
'  observeEvent(input$complete_lesson, {\n',
'    shiny::stopApp()\n',
'    trainingRIntro::set_user_state(lesson_', lesson$number, '_complete=TRUE)\n',
'  })\n',
'```\n\n')

  return(paste0("\n## Next Lesson\n\n
You have completed Lesson {lesson$no}. Click the button below to mark it as complete and move on to the next lesson.\n\n", nlui, "\n", nls, "\n\n"))

}

build_metadata <- function(metadata, type) {

  learnr_metadata <- list(
    output = list(
      `learnr::tutorial` = list(
        allow_skip = TRUE
      )
    ),
    runtime = "shiny_prerendered"
  )

  if(type == "learnr") {
    metadata <- modifyList(metadata, learnr_metadata)
  } else {
    stop("Unsupported type: ", type)
  }

  metadata <- yaml::as.yaml(metadata)

  metadata <- paste0("---\n", metadata, "---\n\n")

  return(metadata)

}

generateCodeBlockName <- function() {
  # Create a character vector containing a-z, A-Z, and 0-9
  characters <- c(letters, LETTERS, as.character(0:9))

  # Randomly sample 5 characters from the vector without replacement and concatenate them
  randomString <- paste(sample(characters, 5, replace=TRUE), collapse="")

  return(randomString)
}

# Example function to convert YAML content to Rmarkdown
build_content <- function(content, depth = 1, section = 0) {

  exercise_count <- 1
  markdownText <- ""

  prefix <- paste(rep("#", depth + 1), collapse = "") # Adjusts section level based on depth

  for (item in content) {
    if (item$type == "paragraph") {
      markdownText <- paste0(markdownText, item$content, "\n\n")
    } else if (item$type == "section") {
      markdownText <- paste0(markdownText, prefix, " ", item$title, "\n\n", build_content(item$content, depth + 1))
    } else if (item$type == "image") {
      markdownText <- paste0(markdownText, "![", item$alt, "](", item$src, ")\n\n")
    } else if (item$type == "code") {
      if(is.null(item$name)) {
        item$name <- paste0("ex-", generateCodeBlockName(), "-", exercise_count)
        exercise_count <- exercise_count + 1
      }

      if(!is.null(item$options)) {
        block_options <- c()
        default_options <- list()
        opts <- c(default_options, item$options)
        for(i in seq_along(opts)) {
          if(is.logical(opts[[i]])) {
            opts[[i]] <- ifelse(opts[[i]], "TRUE", "FALSE")
          } else if(is.character(opts[[i]])) {
            opts[[i]] <- paste0("'", opts[[i]], "'", collapse = "")
          }
          block_options[length(block_options) + 1] <- paste0(names(opts)[i], " = ", opts[[i]])
        }
        block_options <- paste(block_options, collapse = ", ")
        block_setup <- paste0("```{r ", item$name, ", ", block_options, "}\n")
        codeBlock <- paste0(block_setup, item$content, "\n```\n\n")
      } else {
        codeBlock <- paste0("```", item$language, "\n", item$content, "\n```\n\n")
      }
      markdownText <- paste0(markdownText, codeBlock)
    } else if (item$type == "table") {
      # Simple table conversion; consider enhancing for complex tables
      headerRow <- paste("|", paste(item$header, collapse = " | "), "|")
      separatorRow <- paste("|", paste(rep("---", length(item$header)), collapse = " | "), "|")
      bodyRows <- sapply(item$rows, function(row) paste("|", paste(row, collapse = " | "), "|"))
      tableMarkdown <- paste(c(headerRow, separatorRow, bodyRows), collapse = "\n")
      markdownText <- paste0(markdownText, tableMarkdown, "\n\n")
    }
  }

  return(markdownText)

}

#'@export
build_exercise <- function(exercise, exercise_number) {

  # Extract information from the exercise object
  instructions <- exercise$instructions
  hints <- exercise$hints
  solution <- exercise$solution$code
  explanation <- exercise$solution$explanation

  # Initialize the Rmarkdown content with the exercise instruction
  rmarkdown_content <- paste0("### Exercise ", exercise_number, "\n\n", instructions, "\n\n```{r exercise", exercise_number, ", exercise = TRUE}\n# Your code here\n```\n\n")

  # Add hints to the Rmarkdown content
  for (i in seq_along(hints)) {
    hint <- stringr::str_replace_all(hints[[i]], "\n", "\n# ")
    rmarkdown_content <- paste0(rmarkdown_content, "```{r exercise", exercise_number, "-hint-", i, "}\n", hint, "\n```\n\n")
  }

  # Add the solution to the Rmarkdown content
  rmarkdown_content <- paste0(rmarkdown_content, "```{r exercise", exercise_number, "-solution}\n", solution, "\n```\n\n")

  # Format the solution explanation for the grade_this_code function, ensuring it's on one line
  explanation_formatted <- stringr::str_replace_all(explanation, "\n", " ")

  # Add the exercise check to the Rmarkdown content
  rmarkdown_content <- paste0(rmarkdown_content, "```{r exercise", exercise_number, "-check}\ngrade_this_code(\n  correct = c(gradethis::random_praise(), \"", explanation_formatted, "\")\n)\n```\n")

  return(rmarkdown_content)

}

#'@export
process_exercises <- function(exercise_objects) {
  # Initialize the Rmarkdown content with the Exercises header
  rmarkdown_content <- "## Exercises {data-progressive=TRUE}\n\n"

  # Loop through each exercise object and build its content
  for (i in seq_along(exercise_objects)) {
    rmarkdown_content <- paste0(rmarkdown_content, build_exercise(exercise_objects[[i]], i), "\n\n")
  }

  return(rmarkdown_content)
}
