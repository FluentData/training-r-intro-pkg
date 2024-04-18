# Define the path for storing the user state
user_state_file <- function() {
  r_user_dir <- normalizePath("~/.training-r-intro", winslash = "/")
  if (!dir.exists(r_user_dir)) {
    dir.create(r_user_dir, recursive = TRUE, showWarnings = FALSE)
  }
  file.path(r_user_dir, "user_state.RData")
}

# Load user state
load_user_state <- function() {
  state_path <- user_state_file()
  if (file.exists(state_path)) {
    load(state_path)
    if (exists("user_state")) {
      return(user_state)
    }
  }
  # Return default state if file does not exist or `user_state` not found
  list(last_message_displayed = Sys.time() - 24*3600, # 24 hours ago
       current_lesson = NULL,
       other_preferences = list())
}

# Save user state
save_user_state <- function(user_state) {
  state_path <- user_state_file()
  save(user_state, file = state_path)
}

# Set a parameter in the user state
set_user_state <- function(...) {
  dots <- list(...)
  if (any(names(dots) == "")) {
    stop("All arguments must be named.")
  }
  user_state <- load_user_state()
  for (name in names(dots)) {
    value <- dots[[name]]
    # Add here any specific validation for name or value as needed
    user_state[[name]] <- value
  }
  save_user_state(user_state)
}

get_user_state <- function(name) {
  user_state <- load_user_state()
  if(!name %in% names(user_state)) return(NULL)
  user_state[[name]]
}

