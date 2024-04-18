#run_lesson <- function(name) {

#  parts <- strsplit(name, "/")[[1]]

#  trainr_dir <- Sys.getenv("trainr_dir")

  # Check if the string is in the correct format
#  if (length(parts) != 2) {
#    stop("The input string should be in the format <git_username>/<repository_name>")
#  }

#  git_username <- parts[1]
#  repository_name <- parts[2]

#  training_dir <- file.path(trainr_dir, git_username, repository_name)

#  if(dir.exists(training_dir)) {
#    settings <- yaml::yaml.load_file(file.path(training_dir, "trainr.yaml"))
#  } else {
#    stop(name, " not found. Try loading it first with `trainR::load('", name, "')`")
#  }

#  info("Welcome to", settings$name, "! This", settings$difficulty, "course will...")

#}
