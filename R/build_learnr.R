#' Build a learnr tutorial from a specified template
#'
#' This function takes a YAML template for a learnr tutorial and compiles it into a .Rmd file
#' within a structured directory. It handles directory creation, file operations, and content
#' formatting to generate a ready-to-use learnr tutorial.
#'
#' @param template_file_path A string specifying the path to the YAML file containing the
#'        learnr tutorial template.
#'
#' @return A character string containing the compiled markdown content, invisibly.
build_learnr <- function(template_file_path, packages = c("learnr", "gradethis", "trainingRIntro", "shiny")) {

  template <- yaml::yaml.load_file(template_file_path)
  template_dir <- dirname(template_file_path)
  lesson_dir <- file.path("inst", "tutorials", basename(template_dir))

  if(!dir.exists(lesson_dir)) {
    dir.create(lesson_dir, recursive = TRUE)
  }

  metadata <- template$metadata
  metadata$title <- paste(template$lesson$number, ". ",template$title)

  metadata <- build_metadata(metadata, "learnr")

  if("packages" %in% names(template)) {
    packages <- c(packages, template$packages)
  }

  setup <- paste(
    "```{r setup, include=FALSE}\n",
    paste("library(", packages, ")", sep = "", collapse = "\n"),
    "\n",
    ifelse("setup" %in% names(template), template$setup, ""),
    "\n```\n")

  intro <- template$introduction

  content <- build_content(template$content)

  exercises <- process_exercises(template$exercises)

  next_lesson <- build_next_lesson(template$lesson)

  op <- paste(metadata, setup, intro, content, exercises, next_lesson, sep = "\n")

  op_path <- paste0(lesson_dir, "/lesson.Rmd")
  writeLines(op, op_path)

  dirs_to_copy <- list.dirs(template_dir, full.names = TRUE, recursive = FALSE)
  for (dir in dirs_to_copy) {
    dest_dir <- file.path(lesson_dir, basename(dir))
    if (!dir.exists(dest_dir)) {
      dir.create(dest_dir, recursive = TRUE)
    }
    file.copy(list.files(dir, full.names = TRUE, recursive = TRUE), dest_dir, recursive = TRUE)
  }


  return(invisible(op))

}

#' Build the navigation for the next lesson in a learnr tutorial
#'
#' Generates markdown formatted text for a button to mark the current lesson as complete and
#' proceed to the next lesson. Includes both UI and server side reactive expressions for Shiny.
#'
#' @param lesson A list containing details of the lesson, particularly the lesson number.
#'
#' @return A character string with R markdown format for UI and server blocks in a learnr tutorial.
build_next_lesson <- function(lesson) {

  nlui <- paste0('```{r example-button, echo=FALSE}\n',
'  actionButton("complete_lesson", "Mark Lesson ', lesson$number, ' Complete")\n',
'```\n\n')


  nls <- paste0('```{r, context = "server"}\n',
                "observeEvent(input$complete_lesson, {\n",
                "  showModal(modalDialog(\n",
                "    title = 'Congratulations!',\n",
                "tags$p(\"", lesson$closing, "\"),\n",
                "    easyClose = FALSE,\n",
                "    footer = tagList(\n",
                "      modalButton('Cancel'),\n",
                "      actionButton('confirm_complete', 'Confirm', class = 'btn-primary')\n",
                "    )\n",
                "  ))\n",
                "})\n\n",

                "observeEvent(input$confirm_complete, {\n",
                "  removeModal()\n",
                "  trainingRIntro::set_user_state(lesson_", lesson$number, "_complete=TRUE)\n",
                "  shiny::stopApp()\n",
                "})\n")

  return(paste0("\n## Next Lesson\n\nYou have completed Lesson ", lesson$no, ". Click the button below to mark it as complete and move on to the next lesson.\n\n", nlui, "\n", nls, "\n\n"))

}

#' Build metadata for a learnr tutorial
#'
#' Constructs a list of metadata settings specific to learnr tutorials, merging it with existing
#' metadata from a template and formatting it into YAML.
#'
#' @param metadata A list of existing metadata from the tutorial template.
#' @param type A character string specifying the type of tutorial, supports only "learnr".
#'
#' @return A character string with YAML formatted metadata, wrapped in appropriate YAML document delimiters.
build_metadata <- function(metadata, type) {

  learnr_metadata <- list(
    output = list(
      `learnr::tutorial` = list(
        allow_skip = TRUE,
        exercise.reuse = TRUE
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

#' Generate a consistent name for a code block based on its content
#'
#' This function creates a hash from the content of the code block which can be used as a name.
#' This ensures that the name is consistent across rebuilds unless the content changes.
#'
#' @param content Character string containing the content of the code block.
#' @return A character string containing a hash generated from the content, serving as the block name.
generateCodeBlockName <- function(block) {
  # Use SHA-1 hashing to generate a name based on the content
  content <- block$content
  if("options" %in% names(block)) {
    if("exercise.cap" %in% names(block$options)) {
      content <- paste(content, block$options$exercise.cap)
    }
  }
  hash <- digest::digest(content, algo = "sha1", serialize = FALSE)
  return(substr(hash, 1, 12))  # Shorten the hash for readability
}

#' Build content sections for a learnr tutorial
#'
#' Converts structured content data into markdown formatted text. Handles multiple types of content
#' including paragraphs, sections, images, code blocks, tables, and lists.
#'
#' @param content A list representing structured content for different sections of the tutorial.
#' @param depth Integer, initial nesting level for sections, default is 1.
#' @param section Integer, optional, specifies the section number.
#'
#' @return A character string containing markdown formatted content for the tutorial.
build_content <- function(content, depth = 1, section = 0) {

  markdownText <- ""

  prefix <- paste(rep("#", depth + 1), collapse = "") # Adjusts section level based on depth

  for (item in content) {

    # Check if 'skip' exists and contains 'learnr'
    if (!is.null(item$skip) && "learnr" %in% item$skip) {
      next  # Skip this item
    }

    if (item$type == "paragraph") {
      markdownText <- paste0(markdownText, item$content, "\n\n")
    } else if (item$type == "section") {
      markdownText <- paste0(markdownText, prefix, " ", item$title, "\n\n", build_content(item$content, depth + 1))
    } else if (item$type == "image") {
      markdownText <- paste0(markdownText, "<img src='", item$src, "' alt='", item$alt, "' style='max-width: 100%;' />\n\n")
      #markdownText <- paste0(markdownText, "![", item$alt, "](", item$src, ")\n\n")
    } else if (item$type == "code") {
      if(is.null(item$name)) {
        item$name <- paste0("ex-", generateCodeBlockName(item))
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
      separatorRow <- paste("|:", paste(rep("---", length(item$header)), collapse = " | "), "|")
      bodyRows <- sapply(item$rows, function(row) paste("|", paste(row, collapse = " | "), "|"))
      tableMarkdown <- paste(c(headerRow, separatorRow, bodyRows), collapse = "\n")
      markdownText <- paste0(markdownText, tableMarkdown, "\n\n")
    } else if (item$type == "list") {
      if (!is.null(item$bullets)) {
        # Handle bulleted list
        listItems <- paste0("- ", item$bullets, collapse = "\n")
        markdownText <- paste0(markdownText, listItems, "\n\n")
      } else if (!is.null(item$numbers)) {
        # Handle numbered list
        listItems <- paste0(seq_along(item$numbers), ". ", item$numbers, collapse = "\n")
        markdownText <- paste0(markdownText, listItems, "\n\n")
      } else {
        # Fallback or error message if neither property is found
        markdownText <- paste0(markdownText, "Error: List type not specified correctly.\n\n")
      }
    }

  }

  return(markdownText)

}

#' Process exercises for a learnr tutorial
#'
#' Converts a list of exercise specifications into formatted R markdown for interactive exercises
#' in a learnr tutorial. Each exercise includes instructions, hints, solutions, and checking logic.
#'
#' @param exercise_objects A list of lists, where each sub-list contains elements that define an exercise.
#'
#' @return A character string containing all exercises formatted in R markdown.
process_exercises <- function(exercise_objects) {
  # Initialize the Rmarkdown content with the Exercises header
  rmarkdown_content <- "## Exercises {data-progressive=TRUE}\n\n"

  # Loop through each exercise object and build its content
  for (i in seq_along(exercise_objects)) {
    rmarkdown_content <- paste0(rmarkdown_content, build_exercise(exercise_objects[[i]], i), "\n\n")
  }

  return(rmarkdown_content)
}


#' Build individual exercise content for a learnr tutorial
#'
#' This function takes a single exercise object and formats it into R Markdown. It handles
#' the creation of exercise prompts, hints, solutions, and the corresponding checking code
#' using the `gradethis` package. The output is designed to integrate seamlessly into a
#' learnr tutorial.
#'
#' @param exercise A list containing details of the exercise, such as instructions, hints,
#'        and solutions.
#' @param exercise_number An integer indicating the exercise sequence number which is used
#'        to uniquely identify exercise chunks.
#'
#' @return A character string containing the complete R Markdown for an exercise, including
#'         instructions, hints, solution code, and checking code.
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
