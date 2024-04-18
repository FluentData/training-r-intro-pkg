#' Build a learnr Tutorial from a YAML File
#'
#' This function takes a YAML file path as input, which contains the structure and content for a learnr tutorial,
#' and converts it into an R Markdown file formatted for use with the learnr package. The function can also
#' directly return the generated content as a string without saving it to a file.
#'
#' @param template_file_path The path to the YAML file that contains the tutorial's structure and content.
#' @param save Logical, indicating whether to save the output to an R Markdown file. If TRUE, the function saves the
#'        R Markdown content to a file with the same name as the input file but with an .Rmd extension. If FALSE,
#'        the content is returned as a string.
#' @return If `save` is TRUE, returns the path to the generated R Markdown file. If FALSE, returns the R Markdown
#'         content as a string. If the operation is successful but there's nothing to return, the function
#'         returns invisibly.
#' @export
#' @examples
#' # Example usage (without actually running, as it depends on a YAML file)
#' # build_learnr("path/to/your_template.yaml", save = TRUE)
build_learnr <- function(template_file_path, save = FALSE) {
  if (!file.exists(template_file_path)) {
    stop("The specified template file does not exist.")
  }

  template <- tryCatch({
    yaml::yaml.load_file(template_file_path)
  }, error = function(e) {
    stop("Failed to load YAML file: ", e$message)
  })

  if (!is.list(template) || is.null(template$content)) {
    stop("The structure of the YAML file is not as expected.")
  }

  metadata <- template$metadata
  if (is.null(metadata)) {
    metadata <- list()
  }
  metadata$title <- template$title

  metadata <- build_metadata(metadata, "learnr")

  setup <- "```{r setup, include=FALSE}
library(learnr)
library(gradethis)
```
"

  intro <- template$introduction

  content <- build_content(template$content)

  exercises <- process_exercises(template$exercises)

  op <- paste(metadata, setup, intro, content, exercises, sep = "\n")

  if (save) {
    file_path <- paste0(tools::file_path_sans_ext(template_file_path), ".Rmd")
    writeLines(op, file_path)
    return(file_path)
  }

  return(invisible(op))
}

#' Build Metadata for a learnr Tutorial
#'
#' Given a metadata list and a type, this function integrates specific learnr tutorial metadata, converting
#' the metadata into a YAML-formatted string prefixed and suffixed with document separators.
#'
#' @param metadata A list containing the initial metadata for the document.
#' @param type A character string specifying the type of tutorial; currently, only "learnr" is supported.
#' @return A character string containing the YAML-formatted metadata, ready to be included in an R Markdown document.
#' @examples
#' # Example usage
#' metadata <- list(title = "Example Tutorial")
#' build_metadata(metadata, "learnr")
build_metadata <- function(metadata, type) {
  if (type != "learnr") {
    stop("Unsupported type: ", type)
  }

  learnr_metadata <- list(
    output = list(
      `learnr::tutorial` = list(
        allow_skip = TRUE
      )
    ),
    runtime = "shiny_prerendered"
  )

  metadata <- modifyList(metadata, learnr_metadata)

  metadata <- yaml::as.yaml(metadata)

  metadata <- paste0("---\n", metadata, "---\n\n")

  return(metadata)
}

#' Generate a Random Code Block Name
#'
#' Creates a random string of 5 characters, which can be used as a name for code blocks. This string consists of
#' randomly selected letters (both uppercase and lowercase) and digits.
#'
#' @return A character string containing a random sequence of 5 alphanumeric characters.
#' @examples
#' generateCodeBlockName()
generateCodeBlockName <- function() {
  characters <- c(letters, LETTERS, as.character(0:9))
  randomString <- paste(sample(characters, 5, replace = TRUE), collapse = "")
  return(randomString)
}

#' Convert YAML Content to Rmarkdown
#'
#' Processes a structured list representing the content of a tutorial as defined in a YAML file, converting
#' it into a Markdown string suitable for a learnr tutorial. It supports various content types, including
#' paragraphs, sections, images, code blocks, and tables.
#'
#' @param content A list containing the structured content extracted from a YAML file.
#' @param depth Integer, the current depth in the content structure, used to adjust section levels. Default is 1.
#' @param section An integer representing the current section number, primarily used internally. Default is 0.
#' @return A character string containing the R Markdown-formatted content.
#' @examples
#' # Assuming 'content' is a list structured appropriately
#' # build_content(content)
build_content <- function(content, depth = 1, section = 0) {
  markdownText <- ""
  prefix <- paste(rep("#", depth + 1), collapse = "")

  for (item in content) {
    if (item$type == "paragraph") {
      markdownText <- paste0(markdownText, item$content, "\n\n")
    } else if (item$type == "section") {
      markdownText <- paste0(markdownText, prefix, " ", item$title, "\n\n", build_content(item$content, depth + 1))
    } else if (item$type == "image") {
      markdownText <- paste0(markdownText, "![", item$alt, "](", item$url, ")\n\n")
    } else if (item$type == "code") {
      codeBlock <- paste0("```", item$language, "\n", item$content, "\n```\n\n")
      markdownText <- paste0(markdownText, codeBlock)
    } else if (item$type == "table") {
      headerRow <- paste("|", paste(item$header, collapse = " | "), "|")
      separatorRow <- paste("|", paste(rep("---", length(item$header)), collapse = " | "), "|")
      bodyRows <- sapply(item$rows, function(row) paste("|", paste(row, collapse = " | "), "|"))
      tableMarkdown <- paste(c(headerRow, separatorRow, bodyRows), collapse = "\n")
      markdownText <- paste0(markdownText, tableMarkdown, "\n\n")
    }
  }

  return(markdownText)
}

#' Build an Exercise Section for a learnr Tutorial
#'
#' Converts an exercise object into an R Markdown formatted string containing an exercise for a learnr tutorial.
#' This includes instructions, hints, a solution code block, and an automated solution check using `grade_this_code`.
#'
#' @param exercise A list containing details for the exercise, including instructions, hints, solution, and an explanation.
#' @param exercise_number An integer representing the exercise's order in the tutorial.
#' @return A character string containing the R Markdown-formatted exercise section.
#' @export
#' @examples
#' # Assuming 'exercise' is a list with the required structure
#' # build_exercise(exercise, 1)
build_exercise <- function(exercise, exercise_number) {
  instructions <- exercise$instructions
  hints <- exercise$hints
  solution <- exercise$solution$code
  explanation <- exercise$solution$explanation

  rmarkdown_content <- paste0("### Exercise ", exercise_number, "\n\n", instructions, "\n\n```{r exercise", exercise_number, ", exercise = TRUE}\n# Your code here\n```\n\n")

  for (i in seq_along(hints)) {
    hint <- hints[[i]]
    rmarkdown_content <- paste0(rmarkdown_content, "```{r exercise", exercise_number, "-hint-", i, "}\n", hint, "\n```\n\n")
  }

  rmarkdown_content <- paste0(rmarkdown_content, "```{r exercise", exercise_number, "-solution}\n", solution, "\n```\n\n")

  explanation_formatted <- explanation

  rmarkdown_content <- paste0(rmarkdown_content, "```{r exercise", exercise_number, "-check}\ngrade_this_code(\n  correct = c(gradethis::random_praise(), \"", explanation_formatted, "\")\n)\n```\n")

  return(rmarkdown_content)
}

#' Process and Build Exercises for a learnr Tutorial
#'
#' Takes a list of exercise objects and converts each into an R Markdown formatted string for inclusion
#' in a learnr tutorial. It groups all exercises under a single "Exercises" section.
#'
#' @param exercise_objects A list of lists, where each inner list contains the structure of an exercise.
#' @return A character string containing all exercises formatted for R Markdown, preceded by an "Exercises" header.
#' @export
#' @examples
#' # Assuming 'exercise_objects' is a list of exercise structures
#' # process_exercises(exercise_objects)
process_exercises <- function(exercise_objects) {
  if (!is.list(exercise_objects)) {
    stop("Expected 'exercise_objects' to be a list.")
  }

  rmarkdown_content <- "## Exercises\n\n"



  for (i in seq_along(exercise_objects)) {
    rmarkdown_content <- paste0(rmarkdown_content, build_exercise(exercise_objects[[i]], i), "\n\n")
  }

  return(rmarkdown_content)
}
