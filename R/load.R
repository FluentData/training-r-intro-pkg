 load_lesson <- function(name, run = TRUE, ver = "trainR") {

  # Split the string into username and repository name
  parts <- strsplit(name, "/")[[1]]

  trainr_dir <- Sys.getenv("trainr_dir")

  # Check if the string is in the correct format
  if (length(parts) != 2) {
    stop("The input string should be in the format <git_username>/<repository_name>")
  }

  git_username <- parts[1]
  repository_name <- parts[2]

  # Check if trainr.yaml exists in the remote repository using GitHub API
  api_url <- paste0("https://api.github.com/repos/", git_username, "/", repository_name, "/contents/trainr.yaml?ref=", ver)
  response <- httr::GET(api_url)

  if (httr::status_code(response) != 200) {
    stop(name, " doesn't appear to be a trainR repository.")
  }

  # Define the destination folder
  dest_folder <- file.path(trainr_dir, git_username, repository_name)

  # Check if the destination folder already exists
  if (dir.exists(dest_folder)) {
    # If it exists, pull the latest changes
    owd <- getwd()
    setwd(dest_folder)
    system("git pull", ignore.stdout = TRUE, ignore.stderr = TRUE, intern = TRUE)
    setwd(owd)
    info("Pulling any changes to `", name, "` from GitHub...")
  } else {
    # If it doesn't exist, clone the repository
    system(paste0("git clone -b ", ver, " https://github.com", "/", git_username, "/", repository_name, " ", dest_folder), ignore.stdout = TRUE)
    info("Loading `", name, "` from Github...")
  }

  if(run) {
    run(name)
  }

}
