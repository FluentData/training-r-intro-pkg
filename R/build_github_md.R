#' @title Build GitHub Flavored Markdown from YAML Template
#' @description This function loads a YAML template and converts it to GitHub-flavored Markdown,
#'              saves it in a directory appropriate for GitHub repository display, and copies any
#'              directories from the source directory to the target directory.
#' @param template_file_path The file path to the YAML template.
#' @param save Logical; if TRUE, saves the output to a Markdown file and copies associated directories.
#' @return A character string containing the Markdown content or file path if saved.
#' @importFrom yaml yaml.load_file
#' @importFrom tools file_path_sans_ext
build_github_md <- function(template_file_path) {

  # Load YAML content
  template <- yaml::yaml.load_file(template_file_path)
  template_dir <- dirname(template_file_path)
  lesson_dir <- file.path("docs", basename(dirname(template_file_path)))

  # Generate Markdown content
  title <- paste("#", template$title, "\n")
  intro <- paste(template$introduction, "\n")
  toc <- generate_toc(template$content)  # Table of contents
  content <- build_github_content(template$content)
  exercises <- process_github_exercises(template$exercises)
  next_lesson <- build_github_next_lesson(template$lesson)
  full_content <- paste(title, intro, toc, content, exercises, next_lesson, sep = "\n")

  # Define destination file path
  md_file_path <- file.path(lesson_dir, "readme.md")

  # Ensure the directory exists
  if (!dir.exists(lesson_dir)) {
    dir.create(lesson_dir, recursive = TRUE)
  }
  # Save the Markdown file
  writeLines(full_content, md_file_path)

  # Copy directories from the template directory to the GitHub directory
  dirs_to_copy <- list.dirs(dirname(template_file_path), full.names = TRUE, recursive = FALSE)
  for (dir in dirs_to_copy) {
    dest_dir <- file.path(lesson_dir, basename(dir))
    if (!dir.exists(dest_dir)) {
      dir.create(dest_dir, recursive = TRUE)
    }
    file.copy(list.files(dir, full.names = TRUE, recursive = TRUE), dest_dir, recursive = TRUE)
  }

  # Return the path to the saved markdown file
  return(invisible(file.path(lesson_dir, basename(md_file_path))))

}


#' Generate a Table of Contents for GitHub Markdown
#' @param content The content structure from the YAML template
#' @return A Markdown formatted table of contents
generate_toc <- function(content, depth = 1) {
  toc_lines <- c()
  for (item in content) {
    if (!is.null(item$skip) && "github" %in% item$skip) {
      next
    }

    if (item$type == "section") {
      link <- paste(rep("  ", depth - 1), "- [", item$title, "](#", tolower(gsub(" ", "-", gsub("[^[:alnum:][:space:]|-]", "", item$title))), ")", sep = "")
      toc_lines <- c(toc_lines, link)
      if (!is.null(item$content)) {
        toc_lines <- c(toc_lines, generate_toc(item$content, depth + 1))
      }
    }
  }
  return(paste(toc_lines, collapse = "\n"))
}

#' @title Generate Markdown Link to the Next Lesson
#' @description This function creates a Markdown section with a link to the next lesson based on the lesson attribute in the YAML file.
#' @param lesson The name of the next lesson as specified in the YAML file.
#' @return A character string containing the Markdown formatted link to the next lesson.
#' @noRd
build_github_next_lesson <- function(lesson) {

  if (is.null(lesson$next_lesson)) {
    return("")
  }

  next_lesson_markdown <- paste0(
    "## Next Lesson\n\n",
    "Continue to the next part of this series:\n\n",
    "[Next Lesson:](../", gsub(" ", "-", lesson$next_lesson), "/readme.md)\n\n"
  )

  return(next_lesson_markdown)

}


#' Convert YAML Content to GitHub-flavored Markdown
#' @description Processes structured content from a YAML file and converts it into GitHub-flavored Markdown text.
#' @param content A list of content blocks parsed from the YAML file.
#' @return A character string containing formatted Markdown text.
#' @noRd
build_github_content <- function(content) {
  markdownText <- ""

  for (item in content) {

    if (!is.null(item$skip) && "github" %in% item$skip) {
      next
    }

    switch(item$type,
           paragraph = {
             markdownText <- paste0(markdownText, item$content, "\n\n")
           },
           section = {
             markdownText <- paste0(markdownText, "## ", item$title, "\n\n", build_content(item$content))
           },
           image = {
             markdownText <- paste0(markdownText, "![", item$alt, "](", item$src, ")\n\n")
           },
           code = {
             codeBlock <- paste0("```", item$language, "\n", item$content, "\n```\n\n")
             markdownText <- paste0(markdownText, codeBlock)
           },
           list = {
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
           },
           table = {
             headerRow <- paste("|", paste(item$header, collapse = " | "), "|")
             separatorRow <- paste("|", paste(rep("---", length(item$header)), collapse = " | "), "|")
             bodyRows <- sapply(item$rows, function(row) paste("|", paste(row, collapse = " | "), "|"))
             tableMarkdown <- paste(c(headerRow, separatorRow, bodyRows), collapse = "\n")
             markdownText <- paste0(markdownText, tableMarkdown, "\n\n")
           }
    )

  }

  return(markdownText)
}

#' @title Build exercises with hints and solutions in a collapsible format
#' @description This function creates GitHub-flavored Markdown formatted exercises with collapsible sections for hints and solutions.
#' @param exercise_objects List of exercises parsed from the YAML file.
#' @return A character string containing formatted Markdown exercises.
#' @noRd
process_github_exercises <- function(exercise_objects) {
  markdown_content <- "## Exercises\n\n"

  for (i in seq_along(exercise_objects)) {
    exercise <- exercise_objects[[i]]
    exercise_markdown <- paste0("### Exercise ", i, "\n\n", exercise$instructions, "\n\n")

    if (!is.null(exercise$hints)) {
      for(h in seq_along(exercise$hints)) {
        exercise_markdown <- paste0(exercise_markdown,
          "<details><summary>Click for Hint</summary>\n\n",
          "> ", exercise$hints[h], "\n\n",
          "</details>\n\n"
        )
      }
    }
    if (!is.null(exercise$solution)) {
      exercise_markdown <- paste0(exercise_markdown,
          "<details><summary>Click for Solution</summary>\n\n",
          "#### Solution\n\n",
          exercise$solution$explanation, "\n\n",
          "```r\n",
          exercise$solution$code, "\n",
          "```\n\n",
          "</details>\n\n"
        )
    }

    exercise_markdown <- paste0(exercise_markdown, "---\n\n")

    markdown_content <- paste(markdown_content, exercise_markdown, sep = "\n")

  }

  return(markdown_content)
}
