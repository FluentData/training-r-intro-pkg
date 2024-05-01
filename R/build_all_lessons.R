#' Build all lessons for the package.
#'
#' This function reads the YAML source for each lesson and builds the training materials for the package.
#' Depending on the options specified, it can build LearnR tutorials or GitHub markdown files.
#'
#' @param source_dir The base directory containing the tutorial sub directories.
#' @param learnr Logical, if TRUE, builds LearnR tutorials from the YAML files.
#' @param github Logical, if TRUE, builds GitHub markdown files from the YAML files.
#' @return A list containing the results of processing each YAML file.
build_all_lessons <- function(source_dir = file.path(getwd(), "source"), learnr = TRUE, github = TRUE) {

  # Validate base directory
  if (!dir.exists(source_dir)) {
    stop("The specified base directory does not exist.")
  }

  # Find YAML files in the directory
  yaml_files <- list.files(source_dir, pattern = "\\.yaml$", full.names = TRUE, recursive = TRUE)

  # Initialize a list to store the results
  results <- list()

  # Process each YAML file
  for (yaml_file in yaml_files) {
    message(paste(crayon::black("Processing file:"), crayon::blue(yaml_file)))

    # Process for learnR if enabled
    if (learnr) {
      results[[paste0(basename(yaml_file), "_learnr")]] <- build_learnr(yaml_file)
    }

    # Process for GitHub markdown if enabled
    if (github) {
      results[[paste0(basename(yaml_file), "_github")]] <- build_github_md(yaml_file)
    }
  }

  return(invisible(results))

}
